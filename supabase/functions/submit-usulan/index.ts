// Public endpoint: warga menyampaikan usulan. Menghasilkan nomor tiket unik,
// menormalisasi input, dan menyimpan dengan status 'baru' menunggu moderasi admin.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash } from "../_shared/cors.ts";

const KATEGORI = new Set(["infrastruktur","ekonomi","sosial","pendidikan","kesehatan","lingkungan","pemerintahan","lainnya"]);

function clean(s: unknown, max: number): string {
  return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const body = await req.json().catch(() => ({}));
  const nama = clean(body.nama, 120);
  const kontak = clean(body.kontak, 60);
  const dusun = clean(body.dusun, 80);
  const kategori = clean(body.kategori, 40).toLowerCase();
  const judul = clean(body.judul, 160);
  const deskripsi = clean(body.deskripsi, 4000);
  const lokasi = clean(body.lokasi, 200);
  const foto_url = clean(body.foto_url, 500);

  if (nama.length < 2) return json({ error: "Nama minimal 2 karakter" }, 400);
  if (judul.length < 5) return json({ error: "Judul minimal 5 karakter" }, 400);
  if (deskripsi.length < 10) return json({ error: "Deskripsi terlalu pendek" }, 400);
  if (!KATEGORI.has(kategori)) return json({ error: "Kategori tidak valid" }, 400);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Rate limit ringan: satu perangkat maksimum 5 usulan per hari.
  const fp = await voterHash("usulan-submit", req);
  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { data: recent } = await supabase
    .from("event_log")
    .select("id")
    .eq("event_name", "usulan_warga.dibuat_publik")
    .gte("created_at", since)
    .eq("payload->>fp", fp);
  if ((recent?.length ?? 0) >= 5) {
    return json({ error: "Batas usulan harian tercapai. Coba lagi besok." }, 429);
  }

  // Generate nomor tiket: USL-YYYYMM-XXXX (increment harian per bulan).
  const now = new Date();
  const ym = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
  const prefix = `USL-${ym}-`;
  const { data: last } = await supabase
    .from("usulan_warga")
    .select("nomor_tiket")
    .like("nomor_tiket", `${prefix}%`)
    .order("nomor_tiket", { ascending: false })
    .limit(1);
  const nextSeq = last?.[0]?.nomor_tiket
    ? parseInt((last[0].nomor_tiket as string).split("-").pop() || "0", 10) + 1
    : 1;
  const nomor_tiket = `${prefix}${String(nextSeq).padStart(4, "0")}`;

  const { data: ins, error } = await supabase.from("usulan_warga").insert({
    nomor_tiket, nama, kontak: kontak || null, dusun: dusun || null,
    kategori, judul, deskripsi, lokasi: lokasi || null, foto_url: foto_url || null,
    status: "baru",
  }).select("id, nomor_tiket, status").single();
  if (error) return json({ error: error.message }, 400);

  await supabase.from("event_log").insert({
    event_name: "usulan_warga.dibuat_publik",
    entitas: "usulan_warga",
    entitas_id: ins.id,
    payload: { fp, kategori, dusun, nomor_tiket },
  });

  return json({ ok: true, nomor_tiket: ins.nomor_tiket, status: ins.status });
});