// Public endpoint: warga mengajukan surat keterangan secara online.
// Warga menginput data, mendapatkan nomor tiket unik, dan surat masuk ke antrian menunggu verifikasi admin.
// Trigger edge function redeploy
// @ts-expect-error - deno external import
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, getCorsHeaders, json, voterHash } from "../_shared/cors.ts";

function clean(s: unknown, max: number): string {
  return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max);
}

function validateDataIdentitas(idi: unknown): Record<string, string> | null {
  if (!idi || typeof idi !== "object") return null;
  const obj = idi as Record<string, unknown>;
  return {
    tempat_lahir: clean(obj.tempat_lahir, 100),
    tanggal_lahir: clean(obj.tanggal_lahir, 30),
    jenis_kelamin: clean(obj.jenis_kelamin, 20),
    pekerjaan: clean(obj.pekerjaan, 100),
    kewarganegaraan: clean(obj.kewarganegaraan, 50),
    alamat_lengkap: clean(obj.alamat_lengkap, 500),
  };
}

function validatePhone(phone: string): boolean {
  const cleaned = phone.replace(/[\s\-()]/g, "");
  return /^(\+?62|0)[8][0-9]{8,11}$/.test(cleaned);
}

function normalizeNomor(phone: string): string {
  const cleaned = phone.replace(/\D/g, "");
  if (cleaned.startsWith("0")) return "62" + cleaned.slice(1);
  if (cleaned.startsWith("+62")) return cleaned.slice(1);
  return cleaned;
}

async function sendFonnte(token: string, nomor: string, pesan: string): Promise<boolean> {
  try {
    const res = await fetch("https://api.fonnte.com/send", {
      method: "POST",
      headers: { Authorization: token, "Content-Type": "application/json" },
      body: JSON.stringify({ target: normalizeNomor(nomor), message: pesan }),
    });
    return res.ok;
  } catch {
    return false;
  }
}

function buildWaPesan(nama: string, nomorTiket: string, jenisSurat: string | null): string {
  const lines = [
    `Yth. *${nama}*,\n`,
    `Pengajuan surat berhasil diajukan!`,
    ``,
    `📋 *Detail Pengajuan*`,
    `• Nomor Tiket: *${nomorTiket}*`,
    jenisSurat ? `• Jenis: *${jenisSurat}*` : null,
    ``,
    `⏳ Status saat ini: *MENUNGGU*`,
    ``,
    `📌 Pantau status pengajuan:`,
    // @ts-expect-error - Deno env var
    `→ https://${Deno.env.get("PUBLIC_DOMAIN") || "serunimumbul.id"}/service-center`,
    ``,
    `Tim desa akan memproses dalam 1-3 hari kerja.`,
    ``,
    `_Pesan otomatis dari Kantor Desa Seruni Mumbul_`,
  ].filter(Boolean) as string[];
  return lines.join("\n");
}

// @ts-expect-error - Deno api
Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: getCorsHeaders(origin) });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  try {
  const body = await req.json().catch(() => ({}));
  const tenant_id = clean(body.tenant_id, 36);
  const nik = clean(body.nik, 16);
  const nama = clean(body.nama, 120);
  const kontak = clean(body.kontak, 20);
  const jenis_surat_id = clean(body.jenis_surat_id, 36);
  const keperluan = clean(body.keperluan, 2000);
  const lampiran = body.lampiran || [];
  const data_dna = body.data_dna || null;
  const data_identitas_raw = validateDataIdentitas(body.data_identitas);
  const dokumen_ktp_url = clean(body.dokumen_ktp_url, 1000);
  const dokumen_kk_url = clean(body.dokumen_kk_url, 1000);
  const foto_pemohon_url = clean(body.foto_pemohon_url, 1000);
  const dokumen_pendukung_url = clean(body.dokumen_pendukung_url, 1000);

  // Validate tenant_id from body (prevents cross-tenant data leaks)
  if (!tenant_id) return json({ error: "tenant_id wajib" }, 400, origin);

  // Validate NIK is exactly 16 digits
  if (!/^\d{16}$/.test(nik)) return json({ error: "NIK harus 16 digit angka" }, 400, origin);
  if (nama.length < 2) return json({ error: "Nama minimal 2 karakter" }, 400, origin);
  if (!validatePhone(kontak)) return json({ error: "Nomor WhatsApp tidak valid" }, 400, origin);
  if (keperluan.length < 10) return json({ error: "Keperluan terlalu pendek" }, 400, origin);

  const supabase = createClient(
    // @ts-expect-error - Deno env var
    Deno.env.get("SUPABASE_URL")!,
    // @ts-expect-error - Deno env var
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Rate limit: satu perangkat maksimal 3 pengajuan surat per hari (per tenant)
  const fp = await voterHash("surat-submit", req);
  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();

  // Parallel queries: rate limit + verify tenant exists + verify tenant owns this jenis_surat + spam check
  const [rateLimitResult, tenantResult, jenisResult, spamResult] = await Promise.all([
    supabase.from("event_log").select("id").eq("event_name", "surat.diajukan").gte("created_at", since).eq("payload->>fp", fp).eq("tenant_id", tenant_id),
    supabase.from("tenants").select("id, fonnte_token, admin_phone").eq("id", tenant_id).maybeSingle(),
    jenis_surat_id ? supabase.from("surat_jenis").select("id, nama, kode_surat, aktif").eq("id", jenis_surat_id).eq("tenant_id", tenant_id).maybeSingle() : Promise.resolve({ data: null }),
    jenis_surat_id ? supabase.from("surat_ajuan").select("id").eq("tenant_id", tenant_id).eq("nik", nik).eq("jenis_surat_id", jenis_surat_id).eq("status", "menunggu").maybeSingle() : Promise.resolve({ data: null }),
  ]);

  const recent = rateLimitResult.data;
  const tenant = tenantResult.data;
  if ((recent?.length ?? 0) >= 300) {
    return json({ error: "Batas pengajuan harian tercapai. Coba lagi besok." }, 429, origin);
  }
  if (!tenant) return json({ error: "Tenant tidak valid" }, 400, origin);
  if (spamResult?.data) {
    return json({ error: "Pengajuan Anda sebelumnya untuk jenis surat ini masih dalam proses (status menunggu)." }, 400, origin);
  }

  let jenisSurat = null;
  if (jenis_surat_id) {
    if (jenisResult.error) {
      return json({ error: `DB Error jenis: ${jenisResult.error.message}` }, 400, origin);
    }
    const jenis = jenisResult.data;
    if (!jenis || !jenis.aktif) {
      return json({ error: `Jenis surat tidak ditemukan atau tidak aktif. ID: ${jenis_surat_id}, Tenant: ${tenant_id}` }, 400, origin);
    }
    jenisSurat = jenis;
  }

  // Generate nomor tiket: SRT-YYYYMM-XXXX — atomic via RPC
  // Generate nomor tiket atomically via database function
  const { data: nomor_tiket, error: tiketError } = await supabase
    .rpc("get_next_nomor_tiket", { p_prefix: "SRT-" });

  if (tiketError || !nomor_tiket) {
    return json({ error: "Gagal menghasilkan nomor tiket" }, 500, origin);
  }

  // Insert pengajuan surat
  const { data: ins, error } = await supabase
    .from("surat_ajuan")
    .insert({
      tenant_id: tenant_id,
      nomor_tiket,
      nik,
      nama,
      kontak,
      jenis_surat_id: jenis_surat_id || null,
      keperluan,
      lampiran: Array.isArray(lampiran) ? lampiran : [],
      status: "menunggu",
      dokumen_ktp_url: dokumen_ktp_url || null,
      dokumen_kk_url: dokumen_kk_url || null,
      foto_pemohon_url: foto_pemohon_url || null,
      dokumen_pendukung_url: dokumen_pendukung_url || null,
    })
    .select("id, nomor_tiket, status")
    .single();

  if (error) {
    if (error.code === "42P01") {
      return json({
        error: "Fitur pengajuan surat belum tersedia.",
        hint: "Jalankan migration 20260727000001_create_surat_ajuan.sql"
      }, 503, origin);
    }
    return json({ error: error.message }, 400, origin);
  }

  // Persist DNA + identity data to surat_ajuan_data (if provided and table exists)
  if ((data_dna || data_identitas_raw) && typeof (data_dna || data_identitas_raw) === "object") {
    const { error: dataError } = await supabase
      .from("surat_ajuan_data")
      .insert({
        tenant_id: tenant_id,
        surat_ajuan_id: ins.id,
        data_dna: data_dna || {},
        data_identitas: data_identitas_raw || {},
      });
      // ignore dataError
  }

  await supabase.from("event_log").insert({
    event_name: "surat.diajukan",
    entitas: "surat_ajuan",
    entitas_id: ins.id,
    tenant_id: tenant_id,
    payload: { fp, nik, nomor_tiket },
  });

  // Kirim notifikasi WhatsApp (non-blocking, non-fatal)
  // @ts-expect-error - Deno env var
  const fonnteToken = tenant?.fonnte_token || Deno.env.get("FONNTE_TOKEN") || "";
  if (fonnteToken) {
    const waPesan = buildWaPesan(nama, ins.nomor_tiket, jenisSurat?.nama || null);
    
    // Notifikasi ke warga
    const p1 = sendFonnte(fonnteToken, kontak, waPesan);
    
    // Notifikasi ke admin desa
    let p2 = Promise.resolve();
    if (tenant?.admin_phone) {
      const waPesanAdmin = `🚨 *PEMBERITAHUAN PENGAJUAN SURAT BARU* 🚨

Terdapat pengajuan surat baru yang membutuhkan verifikasi Anda.

*Detail Pengajuan:*
*Nama Pemohon:* ${nama}
*NIK:* ${nik}
*Jenis Surat:* ${jenisSurat?.nama || "Surat"}
*No. Tiket:* ${ins.nomor_tiket}

Mohon segera login ke dashboard Admin untuk memeriksa berkas dan menindaklanjuti pengajuan ini.`;
      p2 = sendFonnte(fonnteToken, tenant.admin_phone, waPesanAdmin);
    }
    
    // Di Edge Functions, Promise harus di-await agar fetch tidak terputus saat response dikirim
    await Promise.allSettled([p1, p2]);
  }

  return json({
    ok: true,
    nomor_tiket: ins.nomor_tiket,
    status: ins.status,
    jenis_surat: jenisSurat?.nama || null,
    pesan: `Pengajuan surat berhasil. Nomor tiket: ${ins.nomor_tiket}. Tim desa akan memproses dalam 1-3 hari kerja.`,
  }, 200, origin);
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Internal Server Error" }, 500, origin);
  }
});
