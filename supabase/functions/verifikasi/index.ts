// Public endpoint: verifikasi surat by nomor_surat + kode_verifikasi
// Used by warga to verify if a letter is genuine
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => ({}));
  const nomor = String(body.nomor || "").trim();
  const kode = String(body.kode || "").trim();

  if (!nomor || !kode) {
    return json({ error: "nomor and kode are required" }, 400, origin);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data, error } = await supabase
    .from("surat_terbit")
    .select("nomor_surat, jenis_kode, jenis_nama, perihal, pemohon_nama, tanggal_terbit, berlaku_sampai, status, penandatangan, kode_verifikasi")
    .eq("nomor_surat", nomor)
    .maybeSingle();

  if (error) {
    return json({ error: error.message }, 500, origin);
  }

  if (!data) {
    return json({ notfound: true }, 404, origin);
  }

  // Verify kode matches (case-insensitive)
  if ((data.kode_verifikasi || "").toLowerCase() !== kode.toLowerCase()) {
    return json({ notfound: true }, 404, origin);
  }

  return json(data);
});
