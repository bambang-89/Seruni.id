// Public endpoint: warga menyampaikan aduan/masukan ke desa.
// Mendapatkan nomor tiket unik, dan aduan masuk antrian menunggu respons admin.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash } from "../_shared/cors.ts";

const KATEGORI = new Set([
  "infrastruktur", "pelayanan", "lingkungan", "keamanan",
  "kesehatan", "pendidikan", "ekonomi", "sosial", "lainnya"
]);

const STATUS_MAP: Record<string, string> = {
  infrastruktur: "infrastruktur",
  jalan: "infrastruktur",
  lampu: "infrastruktur",
  drainase: "infrastruktur",
  pelayanan: "pelayanan",
  adminduk: "pelayanan",
  pdam: "pelayanan",
  kesehatan: "kesehatan",
  rsud: "kesehatan",
  puskesmas: "kesehatan",
  pendidikan: "pendidikan",
  sekolah: "pendidikan",
  lingkungan: "lingkungan",
  sampah: "lingkungan",
  security: "keamanan",
  keamanan: "keamanan",
  sosial: "sosial",
  ekonomi: "ekonomi",
  lainnya: "lainnya",
};

function clean(s: unknown, max: number): string {
  return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max);
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => ({}));
  const nama = clean(body.nama, 120);
  const kontak = clean(body.kontak, 20);
  const kategori = clean(body.kategori, 40).toLowerCase();
  const judul = clean(body.judul, 160);
  const isi = clean(body.deskripsi || body.isi, 4000);
  const lokasi = clean(body.lokasi, 200);
  const lampiran_url = clean(body.lampiran_url, 500);

  if (nama.length < 2) return json({ error: "Nama minimal 2 karakter" }, 400, origin);
  if (judul.length < 5) return json({ error: "Judul minimal 5 karakter" }, 400, origin);
  if (isi.length < 10) return json({ error: "Deskripsi terlalu pendek" }, 400, origin);

  const normalizedKategori = STATUS_MAP[kategori] || kategori;
  if (!KATEGORI.has(normalizedKategori)) {
    return json({ error: "Kategori tidak valid. Pilih: infrastruktur, pelayanan, lingkungan, keamanan, kesehatan, pendidikan, ekonomi, sosial, lainnya" }, 400, origin);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Get tenant_id
  const { data: tenant } = await supabase
    .from("tenants")
    .select("id")
    .limit(1)
    .maybeSingle();
  if (!tenant) return json({ error: "Konfigurasi tenant tidak ditemukan" }, 500, origin);

  // Rate limit: satu perangkat maksimal 5 aduan per hari
  const fp = await voterHash("aduan-submit", req);
  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { data: recent } = await supabase
    .from("event_log")
    .select("id")
    .eq("event_name", "aduan_warga.dibuat")
    .gte("created_at", since)
    .eq("payload->>fp", fp);
  if ((recent?.length ?? 0) >= 5) {
    return json({ error: "Batas aduan harian tercapai. Coba lagi besok." }, 429, origin);
  }

  // Generate nomor tiket: ADU-YYYY-XXXX
  const year = new Date().getUTCFullYear();
  const prefix = `ADU-${year}-`;
  const { data: last } = await supabase
    .from("aduan_warga")
    .select("nomor_tiket")
    .like("nomor_tiket", `${prefix}%`)
    .order("nomor_tiket", { ascending: false })
    .limit(1);
  const nextSeq = last?.[0]?.nomor_tiket
    ? parseInt((last[0].nomor_tiket as string).split("-").pop() || "0", 10) + 1
    : 1;
  const nomor_tiket = `${prefix}${String(nextSeq).padStart(4, "0")}`;

  // Insert aduan sesuai schema aduan_warga
  const { data: ins, error } = await supabase
    .from("aduan_warga")
    .insert({
      tenant_id: tenant.id,
      nomor_tiket,
      kategori: normalizedKategori,
      judul,
      isi,
      lokasi: lokasi || null,
      lampiran_url: lampiran_url || null,
      nama_pelapor: nama,
      kontak: kontak || null,
      status: "diajukan",
    })
    .select("id, nomor_tiket, status")
    .single();

  if (error) {
    return json({ error: error.message }, 400, origin);
  }

  await supabase.from("event_log").insert({
    event_name: "aduan_warga.dibuat",
    entitas: "aduan_warga",
    entitas_id: ins.id,
    payload: { fp, kategori: normalizedKategori, nomor_tiket },
  });

  return json({
    ok: true,
    nomor_tiket: ins.nomor_tiket,
    status: ins.status,
    pesan: `Aduan Anda telah diterima. Nomor tiket: ${ins.nomor_tiket}. Tim desa akan memproses dalam 1-3 hari kerja.`,
  });
});
