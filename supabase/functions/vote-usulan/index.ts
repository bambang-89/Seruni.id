// Public endpoint: warga memberi dukungan pada usulan yang sudah diverifikasi.
// Satu perangkat satu suara per usulan (hash IP+UA).
// Rate limited: 1 vote per device per 5 minutes
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash, isValidUUID, checkRateLimit } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => ({}));
  const { usulan_id, dusun } = body;
  if (!usulan_id || typeof usulan_id !== "string") return json({ error: "usulan_id wajib" }, 400, origin);

  // Validate UUID format
  if (!isValidUUID(usulan_id)) return json({ error: "usulan_id format invalid" }, 400, origin);

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // Rate limiting: 1 vote per 5 minutes
  const fp = await voterHash("vote-usulan", req, usulan_id);
  const rateLimit = await checkRateLimit(supabase, fp, "usulan_vote.cast", 1, 300000); // 5 minutes
  if (!rateLimit.allowed) {
    return json({ error: "Terlalu cepat. Tunggu sebentar sebelum vote lagi." }, 429, origin);
  }

  // Check usulan exists and is votable
  const { data: usulan, error: uErr } = await supabase
    .from("usulan_warga").select("id,status,vote_count,tenant_id").eq("id", usulan_id).maybeSingle();

  if (uErr) return json({ error: "Terjadi kesalahan sistem" }, 500, origin);
  if (!usulan) return json({ error: "Usulan tidak ditemukan" }, 404, origin);

  if (!["diverifikasi", "ditindaklanjuti"].includes(usulan.status)) {
    return json({ error: "Usulan belum dibuka untuk dukungan" }, 400, origin);
  }

  // Cast vote with improved voter hash
  const voterHashValue = await voterHash("usulan-vote-v2", req, `${usulan_id}`);
  const { error } = await supabase.from("usulan_vote").insert({
    usulan_id, voter_hash: voterHashValue, tenant_id:usulan.tenant_id, dusun: dusun ? String(dusun).slice(0, 80) : null,
  });

  if (error) {
    if (error.code === "23505") return json({ error: "Anda sudah mendukung usulan ini.", already: true }, 409, origin);
    return json({ error: error.message }, 400, origin);
  }

  // Log the vote
  await supabase.from("event_log").insert({
    event_name: "usulan_vote.cast",
    entitas: "usulan_vote",
    payload: { fp, usulan_id },
  });

  const { data: r } = await supabase.from("usulan_warga").select("vote_count").eq("id", usulan_id).maybeSingle();
  return json({
    ok: true,
    vote_count: r?.vote_count ?? usulan.vote_count + 1,
    rate_limit: rateLimit,
  }, 200, origin);
});
