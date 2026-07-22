// Broadcast WhatsApp — Phase 9 edition.
// Persists broadcast + per-target status to wa_broadcast / wa_broadcast_target.
// Provider: Fonnte (https://fonnte.com). Set FONNTE_TOKEN to enable real send.
// Without FONNTE_TOKEN, runs in dry_run mode (records targets, no send).
//
// Actions:
//   POST { pesan, judul?, topik?, dusun? }                    → new broadcast
//   POST { action: "retry", broadcastId: "..." }             → resend failed/pending targets

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders } from "npm:@supabase/supabase-js@2/cors";

interface NewPayload {
  pesan?: string;
  judul?: string;
  topik?: string;
  dusun?: string;
  action?: "new" | "retry";
  broadcastId?: string;
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function normalizeNomor(v: string) {
  return String(v).replace(/[^0-9]/g, "").replace(/^0/, "62");
}

async function sendOne(fonnteToken: string, nomor: string, pesan: string) {
  try {
    const res = await fetch("https://api.fonnte.com/send", {
      method: "POST",
      headers: { Authorization: fonnteToken, "Content-Type": "application/json" },
      body: JSON.stringify({ target: nomor, message: pesan }),
    });
    const body = await res.json().catch(() => ({}));
    const ok = res.ok && (body?.status === true || body?.status === undefined);
    return { ok, response: body };
  } catch (e: any) {
    return { ok: false, response: { error: e?.message || String(e) } };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_PUBLISHABLE_KEY")!;

    // Verify user & admin role.
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userRes, error: userErr } = await userClient.auth.getUser();
    if (userErr || !userRes.user) return json({ error: "Unauthorized" }, 401);

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: roleRow } = await admin
      .from("user_roles")
      .select("role")
      .eq("user_id", userRes.user.id)
      .eq("role", "admin")
      .maybeSingle();
    if (!roleRow) return json({ error: "Hanya admin yang dapat melakukan broadcast." }, 403);

    const body: NewPayload = await req.json();
    const fonnteToken = Deno.env.get("FONNTE_TOKEN");
    const dryRun = !fonnteToken;

    // -------------------- RETRY branch --------------------
    if (body.action === "retry" && body.broadcastId) {
      const { data: bc, error: bcErr } = await admin
        .from("wa_broadcast")
        .select("*")
        .eq("id", body.broadcastId)
        .maybeSingle();
      if (bcErr || !bc) return json({ error: "Broadcast tidak ditemukan." }, 404);

      const { data: pending } = await admin
        .from("wa_broadcast_target")
        .select("*")
        .eq("broadcast_id", body.broadcastId)
        .in("status", ["pending", "gagal"]);

      const list = (pending || []) as any[];
      if (list.length === 0) return json({ ok: true, message: "Tidak ada target yang perlu diulang." });

      await admin.from("wa_broadcast").update({ status: "berjalan" }).eq("id", body.broadcastId);

      let sukses = 0, gagal = 0;
      for (const t of list) {
        if (dryRun) {
          await admin.from("wa_broadcast_target").update({
            status: "gagal", attempt: t.attempt + 1,
            error_message: "FONNTE_TOKEN belum diset (dry-run).",
          }).eq("id", t.id);
          gagal++;
          continue;
        }
        const r = await sendOne(fonnteToken!, normalizeNomor(t.nomor_tujuan), bc.pesan);
        await admin.from("wa_broadcast_target").update({
          status: r.ok ? "sukses" : "gagal",
          attempt: t.attempt + 1,
          sent_at: r.ok ? new Date().toISOString() : null,
          error_message: r.ok ? null : JSON.stringify(r.response).slice(0, 500),
        }).eq("id", t.id);
        r.ok ? sukses++ : gagal++;
      }

      // Recount totals from source of truth
      const { data: agg } = await admin
        .from("wa_broadcast_target")
        .select("status")
        .eq("broadcast_id", body.broadcastId);
      const rows = (agg || []) as any[];
      const totalSukses = rows.filter((r) => r.status === "sukses").length;
      const totalGagal = rows.filter((r) => r.status === "gagal").length;
      const finalStatus = totalGagal === 0 ? "selesai" : totalSukses === 0 ? "gagal" : "selesai";
      await admin.from("wa_broadcast").update({
        total_sukses: totalSukses, total_gagal: totalGagal, status: finalStatus,
      }).eq("id", body.broadcastId);

      return json({ ok: true, broadcastId: body.broadcastId, retried: list.length, sukses, gagal });
    }

    // -------------------- NEW branch --------------------
    if (!body.pesan?.trim()) return json({ error: "Pesan tidak boleh kosong." }, 400);

    let q = admin.from("langganan_wa").select("id,nama,nomor_wa,dusun,topik").eq("status", "aktif");
    if (body.dusun) q = q.eq("dusun", body.dusun);
    const { data: subs, error: subsErr } = await q;
    if (subsErr) return json({ error: subsErr.message }, 500);

    const targets = (subs || []).filter((s: any) => {
      if (!body.topik) return true;
      const t = Array.isArray(s.topik) ? s.topik : [];
      return t.includes(body.topik);
    });

    // Create broadcast row
    const { data: bcRow, error: bcInsErr } = await admin
      .from("wa_broadcast")
      .insert({
        judul: body.judul || null,
        pesan: body.pesan,
        topik: body.topik || null,
        dusun_filter: body.dusun || null,
        dry_run: dryRun,
        dibuat_oleh: userRes.user.id,
        status: "berjalan",
        total_target: targets.length,
      })
      .select()
      .single();
    if (bcInsErr || !bcRow) return json({ error: bcInsErr?.message || "Gagal membuat broadcast" }, 500);

    if (targets.length === 0) {
      await admin.from("wa_broadcast").update({ status: "selesai" }).eq("id", bcRow.id);
      return json({ broadcastId: bcRow.id, dryRun, total: 0, sukses: 0, gagal: 0 });
    }

    // Seed target rows
    const targetRows = targets.map((t: any) => ({
      broadcast_id: bcRow.id,
      nomor_tujuan: String(t.nomor_wa),
      nama: t.nama,
      dusun: t.dusun,
      status: "pending",
      attempt: 0,
    }));
    const { data: insertedTargets, error: tErr } = await admin
      .from("wa_broadcast_target")
      .insert(targetRows)
      .select();
    if (tErr) return json({ error: tErr.message }, 500);

    // Deliver
    let sukses = 0, gagal = 0;
    for (const t of insertedTargets || []) {
      if (dryRun) {
        await admin.from("wa_broadcast_target").update({
          status: "gagal", attempt: 1,
          error_message: "FONNTE_TOKEN belum diset (dry-run).",
        }).eq("id", t.id);
        gagal++;
        continue;
      }
      const r = await sendOne(fonnteToken!, normalizeNomor(t.nomor_tujuan), body.pesan);
      await admin.from("wa_broadcast_target").update({
        status: r.ok ? "sukses" : "gagal",
        attempt: 1,
        sent_at: r.ok ? new Date().toISOString() : null,
        error_message: r.ok ? null : JSON.stringify(r.response).slice(0, 500),
      }).eq("id", t.id);
      r.ok ? sukses++ : gagal++;
    }

    const finalStatus = dryRun ? "selesai" : gagal === 0 ? "selesai" : sukses === 0 ? "gagal" : "selesai";
    await admin.from("wa_broadcast").update({
      total_sukses: sukses, total_gagal: gagal, status: finalStatus,
    }).eq("id", bcRow.id);

    return json({
      broadcastId: bcRow.id,
      dryRun,
      total: targets.length,
      sukses,
      gagal,
      message: dryRun ? "FONNTE_TOKEN belum diset. Semua target tercatat sebagai gagal (mode uji)." : undefined,
    });
  } catch (e: any) {
    return json({ error: e?.message || "Internal error" }, 500);
  }
});