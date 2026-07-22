// Public endpoint: warga memberi dukungan pada usulan yang sudah diverifikasi.
// Satu perangkat satu suara per usulan (hash IP+UA).
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const { usulan_id, dusun } = await req.json().catch(() => ({}));
  if (!usulan_id || typeof usulan_id !== "string") return json({ error: "usulan_id wajib" }, 400);

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  const { data: usulan, error: uErr } = await supabase
    .from("usulan_warga").select("id,status,vote_count").eq("id", usulan_id).maybeSingle();
  if (uErr) return json({ error: uErr.message }, 400);
  if (!usulan) return json({ error: "Usulan tidak ditemukan" }, 404);
  if (!["diverifikasi", "ditindaklanjuti"].includes(usulan.status)) {
    return json({ error: "Usulan belum dibuka untuk dukungan" }, 400);
  }

  const voter = await voterHash("usulan-vote", req, usulan_id);
  const { error } = await supabase.from("usulan_vote").insert({
    usulan_id, voter_hash: voter, dusun: dusun ? String(dusun).slice(0, 80) : null,
  });
  if (error) {
    if (error.code === "23505") return json({ error: "Anda sudah mendukung usulan ini.", already: true }, 409);
    return json({ error: error.message }, 400);
  }
  const { data: r } = await supabase.from("usulan_warga").select("vote_count").eq("id", usulan_id).maybeSingle();
  return json({ ok: true, vote_count: r?.vote_count ?? usulan.vote_count + 1 });
});