// Public endpoint: warga memberi suara pada voting resmi desa.
// Satu perangkat satu suara per topik. Menghormati jendela waktu & status.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const { topik_id, opsi_id, dusun } = await req.json().catch(() => ({}));
  if (!topik_id || !opsi_id) return json({ error: "topik_id & opsi_id wajib" }, 400);

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  const { data: topik } = await supabase
    .from("voting_topik").select("id,status,published,mulai,selesai").eq("id", topik_id).maybeSingle();
  if (!topik || !topik.published) return json({ error: "Topik tidak ditemukan" }, 404);
  if (topik.status !== "aktif") return json({ error: "Voting tidak aktif" }, 400);
  const now = new Date();
  if (topik.mulai && new Date(topik.mulai) > now) return json({ error: "Voting belum dimulai" }, 400);
  if (topik.selesai && new Date(topik.selesai) < now) return json({ error: "Voting sudah ditutup" }, 400);

  const { data: opsi } = await supabase
    .from("voting_opsi").select("id,topik_id").eq("id", opsi_id).maybeSingle();
  if (!opsi || opsi.topik_id !== topik_id) return json({ error: "Opsi tidak valid" }, 400);

  const voter = await voterHash("voting-topik", req, topik_id);
  const { error } = await supabase.from("voting_suara").insert({
    topik_id, opsi_id, voter_hash: voter, dusun: dusun ? String(dusun).slice(0, 80) : null,
  });
  if (error) {
    if (error.code === "23505") return json({ error: "Anda sudah memberikan suara.", already: true }, 409);
    return json({ error: error.message }, 400);
  }

  const { data: opsiRes } = await supabase
    .from("voting_opsi").select("id,label,jumlah_suara,urutan").eq("topik_id", topik_id).order("urutan");
  const { data: tRes } = await supabase.from("voting_topik").select("total_suara").eq("id", topik_id).maybeSingle();
  return json({ ok: true, total_suara: tRes?.total_suara ?? 0, opsi: opsiRes ?? [] });
});