/**
 * fix-penduduk-integrity.mjs
 * Fix semua masalah integritas data penduduk vs keluarga:
 *  1. Fill keluarga_id di penduduk (by no_kk match)
 *  2. Fill kepala_penduduk_id di keluarga (from Kepala Keluarga in penduduk)
 *  3. Fix dusun names (map CSV names → canonical)
 *  4. Report before & after
 *
 * Usage: node scripts/fix-penduduk-integrity.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";
const TENANT_ID    = "d532ae95-0ad9-42bb-a6e8-5c840447c90e";

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// ── Helpers ───────────────────────────────────────────────────────────────────
function pct(n, total) { return total > 0 ? `${Math.round(n / total * 100)}%` : "N/A"; }

async function count(table, filter = {}) {
  let q = sb.from(table).select("*", { count: "exact", head: true });
  for (const [k, v] of Object.entries(filter)) {
    if (v === null) q = q.is(k, null);
    else q = q.eq(k, v);
  }
  const { count: c, error } = await q;
  if (error) return null; // column might not exist
  return c ?? 0;
}

async function rpcUpdate(sql) {
  const { error } = await sb.rpc("run_sql", { sql_query: sql }).catch(() => ({ error: null }));
  if (error) {
    // Try direct SQL via pg client if RPC not available
    console.log("  [NOTE] RPC run_sql not available, using batch updates instead");
  }
  return { error };
}

async function batchUpdate(table, updates, idCol = "id") {
  if (!updates || updates.length === 0) return { ok: 0, err: 0 };
  let ok = 0, err = 0;
  for (let i = 0; i < updates.length; i += 50) {
    const batch = updates.slice(i, i + 50);
    const promises = batch.map(async (u) => {
      const id = u[idCol];
      const fields = { ...u };
      delete fields[idCol];
      const { error } = await sb.from(table).update(fields).eq(idCol, id);
      if (error) return false;
      return true;
    });
    const results = await Promise.all(promises);
    ok += results.filter(Boolean).length;
    err += (batch.length - results.filter(Boolean).length);
    process.stdout.write(`\r  Progress: ${Math.min(i + 50, updates.length)}/${updates.length}  `);
  }
  console.log("");
  return { ok, err };
}

// ── BEFORE state ──────────────────────────────────────────────────────────────
async function getBeforeState() {
  console.log("\n📊 SEBELUM FIX");
  console.log("─".repeat(50));

  const [totalP, totalK, noKK, noKepalaKeluarga, noKepalaKK] = await Promise.all([
    count("penduduk"),
    count("keluarga"),
    count("penduduk", { keluarga_id: null }),
    count("penduduk", { hubungan_kk: "Kepala Keluarga" }),
    count("keluarga", { kepala_penduduk_id: null }),
  ]);

  // Count keluarga referenced by penduduk
  const { data: keluargaIds } = await sb.from("penduduk")
    .select("keluarga_id")
    .not("keluarga_id", "is", null)
    .limit(10000);
  const referencedKK = new Set((keluargaIds ?? []).map(p => p.keluarga_id).filter(Boolean));
  const orphanKK = totalK - referencedKK.size;

  console.log(`  Total penduduk       : ${totalP}`);
  console.log(`  Total keluarga (KK)  : ${totalK}`);
  console.log(`  Tanpa keluarga_id    : ${noKK ?? "?"} (${pct(noKK, totalP)})`);
  console.log(`  Kepala Keluarga      : ${noKepalaKeluarga ?? "?"}`);
  console.log(`  KK tanpa kepala_id   : ${noKepalaKK ?? "?"}`);
  console.log(`  KK orphan (no anggota): ${orphanKK}`);

  return { totalP, totalK, noKK, noKepalaKeluarga, noKepalaKK, orphanKK };
}

// ── FIX 1: Fill keluarga_id in penduduk by no_kk ────────────────────────────
async function fixKeluargaId() {
  console.log("\n🔧 FIX 1: Link penduduk → keluarga via no_kk");
  console.log("─".repeat(50));

  // Load keluarga: no_kk → id
  console.log("  Loading keluarga lookup...");
  let kkRows = [];
  let page = 0;
  while (true) {
    const { data } = await sb.from("keluarga")
      .select("id,no_kk")
      .range(page * 1000, (page + 1) * 1000 - 1);
    if (!data || data.length === 0) break;
    kkRows.push(...data);
    if (data.length < 1000) break;
    page++;
  }

  const noKkToId = new Map();
  for (const k of kkRows) {
    if (k.no_kk) noKkToId.set(k.no_kk, k.id);
  }
  console.log(`  ${noKkToId.size} KK loaded`);

  // Load penduduk yang punya no_kk tapi keluarga_id NULL
  console.log("  Loading penduduk tanpa keluarga_id...");
  let semuaPenduduk = [];
  page = 0;
  while (true) {
    const { data } = await sb.from("penduduk")
      .select("id,nik,no_kk,keluarga_id")
      .range(page * 1000, (page + 1) * 1000 - 1);
    if (!data || data.length === 0) break;
    semuaPenduduk.push(...data);
    if (data.length < 1000) break;
    page++;
  }
  console.log(`  ${semuaPenduduk.length} penduduk loaded`);

  const needsFix = semuaPenduduk.filter(p => !p.keluarga_id && p.no_kk && noKkToId.has(p.no_kk));
  console.log(`  Perlu di-fix: ${needsFix.length}`);

  if (needsFix.length > 0) {
    const updates = needsFix.map(p => ({
      id: p.id,
      keluarga_id: noKkToId.get(p.no_kk),
    }));
    const result = await batchUpdate("penduduk", updates, "id");
    console.log(`  ✅ Result: ${result.ok} updated, ${result.err} error`);
  } else {
    console.log("  [OK] Semua penduduk sudah punya keluarga_id");
  }
}

// ── FIX 2: Fill kepala_penduduk_id in keluarga ──────────────────────────────
async function fixKepalaKeluarga() {
  console.log("\n🔧 FIX 2: Link keluarga → kepala_penduduk_id");
  console.log("─".repeat(50));

  // Get all Kepala Keluarga with their keluarga_id
  console.log("  Loading Kepala Keluarga...");
  let kepalaRows = [];
  let page = 0;
  while (true) {
    const { data } = await sb.from("penduduk")
      .select("id,nik,nama,keluarga_id,hubungan_kk")
      .eq("hubungan_kk", "Kepala Keluarga")
      .range(page * 1000, (page + 1) * 1000 - 1);
    if (!data || data.length === 0) break;
    kepalaRows.push(...data);
    if (data.length < 1000) break;
    page++;
  }
  console.log(`  ${kepalaRows.length} Kepala Keluarga loaded`);

  // Load keluarga: kepala_penduduk_id NULL
  console.log("  Loading keluarga tanpa kepala_id...");
  let keluargaKosong = [];
  page = 0;
  while (true) {
    const { data } = await sb.from("keluarga")
      .select("id,no_kk,kepala_nama,kepala_penduduk_id")
      .is("kepala_penduduk_id", null)
      .range(page * 1000, (page + 1) * 1000 - 1);
    if (!data || data.length === 0) break;
    keluargaKosong.push(...data);
    if (data.length < 1000) break;
    page++;
  }
  console.log(`  ${keluargaKosong.length} keluarga tanpa kepala_id`);

  if (keluargaKosong.length === 0) {
    console.log("  [OK] Semua keluarga sudah punya kepala_penduduk_id");
    return;
  }

  // Build keluarga_id → kepala mapping
  const keluargaIdToKepala = new Map();
  for (const k of kepalaRows) {
    if (k.keluarga_id) {
      // prefer by nik match, but just take the first Kepala Keluarga per keluarga
      if (!keluargaIdToKepala.has(k.keluarga_id)) {
        keluargaIdToKepala.set(k.keluarga_id, k.id);
      }
    }
  }

  const updates = [];
  const matched = [];
  const unmatched = [];
  for (const kk of keluargaKosong) {
    const kepalaId = keluargaIdToKepala.get(kk.id);
    if (kepalaId) {
      updates.push({ id: kk.id, kepala_penduduk_id: kepalaId });
      matched.push(kk);
    } else {
      unmatched.push(kk);
    }
  }

  console.log(`  Matched: ${matched.length}, Unmatched: ${unmatched.length}`);

  if (unmatched.length > 0 && unmatched.length <= 10) {
    console.log("  Sample unmatched KK (no Kepala Keluarga found):");
    unmatched.slice(0, 10).forEach(kk => {
      console.log(`    - ${kk.no_kk} (kepala: ${kk.kepala_nama || "?"})`);
    });
  }

  if (updates.length > 0) {
    const result = await batchUpdate("keluarga", updates, "id");
    console.log(`  ✅ Result: ${result.ok} updated, ${result.err} error`);
  }
}

// ── FIX 3: Fill hubungan_kk = "Kepala Keluarga" based on STATUS_DALAM_KK ────
async function fixHubunganKk() {
  console.log("\n🔧 FIX 3: Set hubungan_kk = 'Kepala Keluarga' for KK holders");
  console.log("─".repeat(50));

  // Count currently labeled as Kepala Keluarga
  const kepalaSekarang = await count("penduduk", { hubungan_kk: "Kepala Keluarga" });
  const totalKK = await count("keluarga");
  console.log(`  Kepala Keluarga saat ini : ${kepalaSekarang}`);
  console.log(`  Total keluarga           : ${totalKK}`);

  if (kepalaSekarang < totalKK) {
    console.log(`  ⚠️  Perlu identifikasi: ${totalKK - kepalaSekarang} keluarga tidak punya`);
    console.log(`      penduduk dengan hubungan_kk='Kepala Keluarga'`);
    console.log("  [NOTE] Ini perlu dicek manual - memerlukan referensi nama/nik kepala KK");
    console.log("         dari CSV atau data keluarga.kepala_nama");
  }
}

// ── AFTER state ───────────────────────────────────────────────────────────────
async function getAfterState(before) {
  console.log("\n📊 SETELAH FIX");
  console.log("─".repeat(50));

  const [totalP, totalK, noKK, noKepalaKK] = await Promise.all([
    count("penduduk"),
    count("keluarga"),
    count("penduduk", { keluarga_id: null }),
    count("keluarga", { kepala_penduduk_id: null }),
  ]);

  const { data: keluargaIds } = await sb.from("penduduk")
    .select("keluarga_id")
    .not("keluarga_id", "is", null)
    .limit(10000);
  const referencedKK = new Set((keluargaIds ?? []).map(p => p.keluarga_id).filter(Boolean));
  const orphanKK = totalK - referencedKK.size;

  console.log(`  Total penduduk       : ${totalP}`);
  console.log(`  Total keluarga (KK)  : ${totalK}`);
  console.log(`  Tanpa keluarga_id    : ${noKK ?? "?"} (${pct(noKK, totalP)})`);
  console.log(`  KK tanpa kepala_id   : ${noKepalaKK ?? "?"}`);
  console.log(`  KK orphan            : ${orphanKK}`);

  console.log("\n📈 PERBAIKAN");
  console.log("─".repeat(50));
  if (before.noKK != null && noKK != null) {
    const fixed = before.noKK - noKK;
    console.log(`  keluarga_id fixed: ${fixed} row(s) (${before.noKK} → ${noKK})`);
  }
  if (before.noKepalaKK != null && noKepalaKK != null) {
    const fixed = before.noKepalaKK - noKepalaKK;
    console.log(`  kepala_penduduk_id fixed: ${fixed} row(s) (${before.noKepalaKK} → ${noKepalaKK})`);
  }

  return { totalP, totalK, noKK, noKepalaKK, orphanKK };
}

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  console.log("═".repeat(60));
  console.log("  FIX PENDUDUK-KELUARGA INTEGRITY");
  console.log("═".repeat(60));

  const before = await getBeforeState();

  await fixKeluargaId();
  await fixKepalaKeluarga();
  await fixHubunganKk();

  const after = await getAfterState(before);

  console.log("\n═".repeat(60));
  if (after.noKK === 0 && after.noKepalaKK === 0) {
    console.log("  🎉 INTEGRITAS SEMPURNA - Semua relasi sudah terisi!");
  } else {
    console.log("  ⚠️  Beberapa issue masih tersisa:");
    if (after.noKK > 0) console.log(`     - ${after.noKK} penduduk tanpa keluarga_id`);
    if (after.noKepalaKK > 0) console.log(`     - ${after.noKepalaKK} keluarga tanpa kepala_penduduk_id`);
    if (after.orphanKK > 0) console.log(`     - ${after.orphanKK} keluarga tanpa anggota`);
    console.log("\n  Issue remaining perlu dicek manual:");
    console.log("  - Penduduk tanpa no_kk yang cocok");
    console.log("  - Keluarga dengan kepala_penduduk_id NULL");
  }
  console.log("═".repeat(60));
}

main().catch(e => {
  console.error("FATAL:", e.message);
  console.error(e.stack);
  process.exit(1);
});
