/**
 * Edge Function: notifikasi-status-surat
 * Dipanggil oleh admin browser saat status pengajuan surat berubah.
 * Mengirim notifikasi WhatsApp via Fonnte API.
 *
 * POST body: {
 *   surat_ajuan_id: UUID,
 *   status_baru: "diproses" | "diterima" | "ditolak" | "dibatalkan",
 *   admin_nama?: string
 * }
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders } from "../_shared/cors.ts";

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function normalizeNomor(phone: string): string {
  const cleaned = (phone || "").replace(/\D/g, "");
  if (cleaned.startsWith("0")) return "62" + cleaned.slice(1);
  if (cleaned.startsWith("62")) return cleaned;
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

const STATUS_LABEL: Record<string, string> = {
  menunggu: "MENUNGGU",
  diproses: "DIPROSES",
  diterima: "DITERIMA",
  ditolak: "DITOLAK",
  dibatalkan: "DIBATALKAN",
  ditandatangani: "DITANDATANGANI",
};

function buildPesan(
  nama: string,
  nomorTiket: string,
  statusBaru: string,
  jenisNama: string | null,
): string {
  const label = STATUS_LABEL[statusBaru] || statusBaru.toUpperCase();
  let body = "";

  if (statusBaru === "diproses") {
    body = "📌 Pengajuan Anda sedang *DIPROSES* oleh tim desa.\nEstimasi selesai: 1-3 hari kerja.";
  } else if (statusBaru === "diterima") {
    body = "🎉 Selamat! Surat Anda telah *DISETUJUI*.\nSilakan ambil surat di Kantor Desa dengan membawa KTP asli.";
  } else if (statusBaru === "ditandatangani") {
    body = "🎉 Surat Anda telah *DITANDATANGANI SECARA ELEKTRONIK*.\nDokumen siap diunduh di halaman Service Center.\n\nSurat ini telah ditandatangani oleh Pemerintah Desa dan memiliki legalitas elektronik.";
  } else if (statusBaru === "ditolak") {
    body = "⚠️ Maaf, pengajuan surat ditolak.\nSilakan hubungi Kantor Desa untuk informasi lebih lanjut.";
  } else if (statusBaru === "dibatalkan") {
    body = "⚠️ Pengajuan ini telah *DIBATALKAN*.\nSilakan ajukan kembali jika diperlukan.";
  } else {
    body = `Status pengajuan Anda saat ini: *${label}*.`;
  }

  return [
    `Yth. *${nama}*,\n`,
    ``,
    `Update status pengajuan surat:\n`,
    `• No. Tiket: *${nomorTiket}*`,
    jenisNama ? `• Jenis: *${jenisNama}*` : null,
    `• Status: *${label}*`,
    ``,
    body,
    ``,
    `Lacak: https://${Deno.env.get("PUBLIC_DOMAIN") || "serunimumbul.id"}/service-center`,
    ``,
    `_Pesan otomatis dari Kantor Desa Seruni Mumbul_`,
  ].filter(Boolean).join("\n");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const body = await req.json().catch(() => ({}));
  const { surat_ajuan_id, status_baru } = body as {
    surat_ajuan_id?: string;
    status_baru?: string;
  };

  if (!surat_ajuan_id || !status_baru) {
    return json({ error: "surat_ajuan_id dan status_baru wajib diisi" }, 400);
  }

  const validStatus = ["menunggu", "diproses", "diterima", "ditolak", "dibatalkan", "ditandatangani"];
  if (!validStatus.includes(status_baru)) {
    return json({ error: "status_baru tidak valid" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Support both surat_ajuan_id and surat_terbit_id
  let ajuan: { nomor_tiket: string; nama: string; kontak: string; jenis_surat_id: string | null } | null = null;
  let ajuanId: string | null = body.surat_ajuan_id || null;

  if (body.surat_ajuan_id) {
    const { data, error } = await supabase
      .from("surat_ajuan")
      .select("nomor_tiket, nama, kontak, jenis_surat_id")
      .eq("id", body.surat_ajuan_id)
      .single();
    if (error || !data) return json({ error: "Pengajuan tidak ditemukan" }, 404);
    ajuan = data;
  } else if (body.surat_terbit_id) {
    // Get ajuan from terbit record
    const { data: terbit, error: terbitError } = await supabase
      .from("surat_terbit")
      .select("surat_ajuan_id")
      .eq("id", body.surat_terbit_id)
      .single();
    if (terbitError || !terbit) return json({ error: "Surat terbit tidak ditemukan" }, 404);
    if (terbit.surat_ajuan_id) {
      const { data, error } = await supabase
        .from("surat_ajuan")
        .select("nomor_tiket, nama, kontak, jenis_surat_id")
        .eq("id", terbit.surat_ajuan_id)
        .single();
      if (error || !data) return json({ error: "Pengajuan tidak ditemukan" }, 404);
      ajuan = data;
      ajuanId = terbit.surat_ajuan_id;
    }
  } else {
    return json({ error: "surat_ajuan_id atau surat_terbit_id wajib diisi" }, 400);
  }

  if (!ajuan) return json({ error: "Data pengajuan tidak ditemukan" }, 404);

  // Ambil nama jenis surat
  let jenisNama: string | null = null;
  if (ajuan.jenis_surat_id) {
    const { data: js } = await supabase
      .from("surat_jenis")
      .select("nama")
      .eq("id", ajuan.jenis_surat_id)
      .maybeSingle();
    jenisNama = js?.nama || null;
  }

  // Kirim WA (non-blocking, tapi harus di-await agar Edge Function tidak mati duluan)
  const fonnteToken = Deno.env.get("FONNTE_TOKEN");
  if (fonnteToken && ajuan.kontak) {
    const pesan = buildPesan(ajuan.nama, ajuan.nomor_tiket, status_baru, jenisNama);
    await sendFonnte(fonnteToken, ajuan.kontak, pesan);
  }

  // Log event
  await supabase.from("event_log").insert({
    event_name: "surat.notifikasi_wa",
    entitas: "surat_ajuan",
    entitas_id: ajuanId,
    payload: { status: status_baru, nomor_tiket: ajuan.nomor_tiket, kirim_wa: !!fonnteToken },
  });

  return json({ ok: true, dikirim: !!fonnteToken });
});
