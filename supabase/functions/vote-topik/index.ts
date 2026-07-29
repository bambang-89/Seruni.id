// Public endpoint: warga memberi suara pada voting resmi desa.
// Satu perangkat satu suara per topik. Menghormati jendela waktu & status.
// Rate limited: 1 vote per device per voting session
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash, isValidUUID, checkRateLimit } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => ({}));
  const { topik_id, opsi_id, dusun } = body;

  // Validate required fields
  if (!topik_id || !opsi_id) return json({ error: "topik_id & opsi_id wajib" }, 400, origin);

  // Validate UUID format
  if (!isValidUUID(topik_id)) return json({ error: "topik_id format invalid" }, 400, origin);
  if (!isValidUUID(opsi_id)) return json({ error: "opsi_id format invalid" }, 400, origin);

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // Rate limiting: 1 vote per device per 5 minutes
  const fp = await voterHash("vote-topik", req, topik_id);
  const rateLimit = await checkRateLimit(supabase, fp, "vote_topik.cast", 1, 300000); // 5 minutes
  if (!rateLimit.allowed) {
    return json({ error: "Terlalu cepat. Tunggu sebentar sebelum vote lagi." }, 429, origin);
  }

  // Check voting topic exists and is active
  const { data: topik } = await supabase
    .from("voting_topik").select("id,status,published,mulai,selesai,tenant_id").eq("id", topik_id).maybeSingle();

  if (!topik || !topik.published) return json({ error: "Topik tidak ditemukan" }, 404, origin);
  if (topik.status !== "aktif") return json({ error: "Voting tidak aktif" }, 400, origin);

  const now = new Date();
  if (topik.mulai && new Date(topik.mulai) > now) return json({ error: "Voting belum dimulai" }, 400, origin);
  if (topik.selesai && new Date(topik.selesai) < now) return json({ error: "Voting sudah ditutup" }, 400, origin);

  // Check opsi valid AND belongs to same tenant
  const { data: opsi } = await supabase
    .from("voting_opsi").select("id,topik_id").eq("id", opsi_id).eq("tenant_id", topik.tenant_id).maybeSingle();
  if (!opsi || opsi.topik_id !== topik_id) return json({ error: "Opsi tidak valid" }, 400, origin);

  // Cast vote with voter hash for deduplication
  const voterHashValue = await voterHash("voting-topik-v2", req, `${topik_id}:${opsi_id}`);
  const { error } = await supabase.from("voting_suara").insert({
    topik_id, opsi_id, voter_hash: voterHashValue,
    tenant_id: topik.tenant_id,
    dusun: dusun ? String(dusun).slice(0, 80) : null,
  });

  if (error) {
    if (error.code === "23505") return json({ error: "Anda sudah memberikan suara.", already: true }, 409, origin);
    return json({ error: error.message }, 400, origin);
  }

  // Log the vote
  await supabase.from("event_log").insert({
    event_name: "vote_topik.cast",
    entitas: "voting_suara",
    payload: { fp, topik_id, opsi_id },
  });

  // Get updated results
  const { data: opsiRes } = await supabase
    .from("voting_opsi").select("id,label,jumlah_suara,urutan").eq("topik_id", topik_id).order("urutan");
  const { data: tRes } = await supabase.from("voting_topik").select("total_suara").eq("id", topik_id).maybeSingle();

  return json({
    ok: true,
    total_suara: tRes?.total_suara ?? 0,
    opsi: opsiRes ?? [],
    rate_limit: rateLimit,
  }, 200, origin);
});
