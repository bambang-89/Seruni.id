// Endpoint publik: warga mengajukan pembetulan / pemutakhiran data kependudukan.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash } from "../_shared/cors.ts";

const JENIS = new Set(["koreksi_data","pindah_datang","pindah_keluar","kematian","kelahiran","lainnya"]);
function clean(s: unknown, max: number) { return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max); }

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const b = await req.json().catch(() => ({}));
  const nik = clean(b.nik, 20);
  const nama = clean(b.nama, 120);
  const kontak = clean(b.kontak, 60);
  const jenis = clean(b.jenis, 40).toLowerCase();
  const deskripsi = clean(b.deskripsi, 4000);
  const lampiran_url = clean(b.lampiran_url, 500);

  if (nama.length < 2) return json({ error: "Nama minimal 2 karakter" }, 400);
  if (deskripsi.length < 10) return json({ error: "Deskripsi terlalu pendek" }, 400);
  if (!JENIS.has(jenis)) return json({ error: "Jenis tidak valid" }, 400);

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const fp = await voterHash("suplesi-submit", req);
  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { data: recent } = await supabase.from("event_log").select("id")
    .eq("event_name", "suplesi_data.dibuat_publik").gte("created_at", since).eq("payload->>fp", fp);
  if ((recent?.length ?? 0) >= 5) return json({ error: "Batas pengajuan harian tercapai." }, 429);

  const { data: ins, error } = await supabase.from("suplesi_data").insert({
    nik: nik || null, nama, kontak: kontak || null, jenis, deskripsi,
    lampiran_url: lampiran_url || null, status: "baru",
  }).select("id, nomor_tiket, status").single();
  if (error) return json({ error: error.message }, 400);
  await supabase.from("event_log").insert({
    event_name: "suplesi_data.dibuat_publik", entitas: "suplesi_data", entitas_id: ins.id,
    payload: { fp, jenis, nomor_tiket: ins.nomor_tiket },
  });
  return json({ ok: true, nomor_tiket: ins.nomor_tiket, status: ins.status });
});