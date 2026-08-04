/**
 * Edge Function: surat-tte-sign
 * Memproses TTE: Generate QRCode unik, ubah status surat_ajuan jadi 'ditandatangani',
 * lalu kirim Notifikasi WA.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { json as sharedJson, getCorsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  const json = (data: unknown, status = 200) => sharedJson(data, status, origin);

  if (req.method === "OPTIONS") return new Response("ok", { headers: getCorsHeaders(origin) });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const body = await req.json().catch(() => ({}));
    const { surat_ajuan_id, pin } = body as {
      surat_ajuan_id?: string;
      pin?: string;
    };

    if (!surat_ajuan_id || !pin) {
      return json({ error: "surat_ajuan_id dan PIN wajib diisi" }, 400);
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: { user }, error: userError } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
    if (userError || !user) return json({ error: "Invalid token" }, 401);

    // 1. Validasi surat_ajuan exist
    const { data: ajuan, error: ajuanError } = await supabase
      .from("surat_ajuan")
      .select("*")
      .eq("id", surat_ajuan_id)
      .single();

    if (ajuanError || !ajuan) {
      return json({ error: "Surat ajuan tidak ditemukan" }, 404);
    }

    if (ajuan.status !== "diverifikasi") {
      return json({ error: "Surat belum diverifikasi atau sudah selesai" }, 400);
    }

    // 2. Simulasi Validasi PIN Kades (Dalam production, check pin dari profil user)
    // Untuk purwarupa, asumsikan PIN benar jika length >= 4
    if (pin.length < 4) {
      return json({ error: "PIN tidak valid" }, 400);
    }

    // 3. Generate Token QR (TTE)
    const tokenTTE = crypto.randomUUID();
    const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https://${Deno.env.get("PUBLIC_DOMAIN") || "serunimumbul.id"}/layanan/verify/${tokenTTE}`;

    // 4. Update status ke ditandatangani
    const { error: updateError } = await supabase
      .from("surat_ajuan")
      .update({
        status: "ditandatangani",
        keterangan: "Telah ditandatangani elektronik",
      })
      .eq("id", surat_ajuan_id);

    if (updateError) {
      return json({ error: "Gagal update status: " + updateError.message }, 500);
    }

    // 5. Panggil Notifikasi (Asynchronous)
    supabase.functions.invoke("notifikasi-status-surat", {
      body: { surat_ajuan_id: surat_ajuan_id, status_baru: "ditandatangani" },
    }).catch(() => {});

    return json({
      ok: true,
      pesan: "Tanda Tangan Elektronik berhasil diterapkan.",
      qr_code_url: qrCodeUrl,
      token_tte: tokenTTE,
    }, 200);

  } catch (err) {
    return json({ error: err instanceof Error ? err.message : "Internal Server Error" }, 500);
  }
});
