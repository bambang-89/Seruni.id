#!/usr/bin/env node
/**
 * Comprehensive FK Integrity Check
 * Checks ALL foreign key relationships across the entire system.
 *
 * Run: node scripts/check-all-fk.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// ── Helpers ───────────────────────────────────────────────────────────────────
async function count(table, filter) {
  const q = filter === null
    ? sb.from(table).select("*", { count: "exact", head: true }).is(Object.keys(filter || {})[0], null)
    : sb.from(table).select("*", { count: "exact", head: true });
  if (filter && filter !== null) {
    for (const [k, v] of Object.entries(filter)) {
      if (v === null) q.is(k, null);
      else q.eq(k, v);
    }
  }
  const { count: c, error } = await q;
  return { count: c, error };
}

async function checkFK(childTable, fkCol, parentTable, parentCol = "id", extraFilter = {}) {
  const results = { childTable, fkCol, parentTable, parentCol, total: 0, nullCount: 0, orphanCount: 0, orphans: [] };

  // Total rows
  const { count: total, error: err1 } = await count(childTable, {});
  results.total = total ?? 0;
  if (err1) { results.queryError = err1.message; return results; }

  // NULL count
  const { count: nullCount, error: err2 } = await count(childTable, { [fkCol]: null });
  results.nullCount = nullCount ?? 0;

  // Orphan count (FK exists but parent doesn't)
  // We check by getting distinct FK values that don't exist in parent
  try {
    const { data: fkData } = await sb
      .from(childTable)
      .select(fkCol)
      .not(fkCol, "is", null)
      .limit(10000);

    if (fkData && fkData.length > 0) {
      const fkValues = [...new Set(fkData.map(r => r[fkCol]))];
      const { data: parentRows } = await sb.from(parentTable).select(parentCol).limit(fkValues.length);
      const parentSet = new Set((parentRows || []).map(r => r[parentCol]));

      let orphans = 0;
      for (const v of fkValues) {
        if (!parentSet.has(v)) orphans++;
      }
      results.orphanCount = orphans;

      if (orphans > 0) {
        const orphanVals = fkValues.filter(v => !parentSet.has(v));
        results.orphans = orphanVals.slice(0, 10);
      }
    }
  } catch (e) {
    results.orphanError = e.message;
  }

  return results;
}

async function checkUnique(table, col) {
  try {
    // Count total
    const { count: total } = await count(table, {});

    // Count distinct
    const { data: distinctData } = await sb.from(table).select(col).limit(100000);
    const distinctCount = distinctData ? new Set(distinctData.map(r => r[col]).filter(Boolean)).size : 0;

    // Count nulls
    const { count: nullCount } = await count(table, { [col]: null });

    // Find duplicates (top 5 by count)
    const freq = {};
    for (const r of (distinctData || [])) {
      const v = r[col];
      if (v) freq[v] = (freq[v] || 0) + 1;
    }
    const duplicates = Object.entries(freq)
      .filter(([, cnt]) => cnt > 1)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([val, cnt]) => ({ val, count: cnt }));

    return { table, column: col, total: total ?? 0, distinct: distinctCount, nullCount: nullCount ?? 0, duplicates, hasDuplicates: duplicates.length > 0 };
  } catch (e) {
    return { table, column: col, error: e.message };
  }
}

// ── Main Audit ───────────────────────────────────────────────────────────────
async function main() {
  console.log("═".repeat(80));
  console.log("  AUDIT KOMPREHENSIF INTEGRITAS DATABASE");
  console.log("  " + new Date().toISOString());
  console.log("═".repeat(80));

  // Connection test
  const { error: connErr } = await sb.from("tenants").select("id").limit(1);
  if (connErr) { console.error("Connection failed:", connErr.message); process.exit(1); }
  console.log("[OK] Connected\n");

  const checks = [];
  const issues = [];

  // ════════════════════════════════════════════════════════════════════════════
  // 1. CORE TABLES
  // ════════════════════════════════════════════════════════════════════════════
  console.log("══ 1. CORE TABLES ═════════════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  // tenants
  const { count: tenantTotal } = await count("tenants", {});
  console.log(`  tenants              total: ${tenantTotal}  ${tenantTotal >= 1 ? "✅" : "❌ NEED DATA"}`);

  // ════════════════════════════════════════════════════════════════════════════
  // 2. PENDUDUK & KELUARGA
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n══ 2. PENDUDUK & KELUARGA ════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  const fkChecks = [
    // penduduk FKs
    { child: "penduduk", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "penduduk", fk: "keluarga_id", parent: "keluarga", pcol: "id" },
    { child: "penduduk", fk: "agama_id", parent: "ref_agama", pcol: "id" },
    { child: "penduduk", fk: "pendidikan_id", parent: "ref_pendidikan", pcol: "id" },
    { child: "penduduk", fk: "pekerjaan_id", parent: "ref_pekerjaan", pcol: "id" },
    { child: "penduduk", fk: "status_perkawinan_id", parent: "ref_status_perkawinan", pcol: "id" },
    { child: "penduduk", fk: "golongan_darah_id", parent: "ref_golongan_darah", pcol: "id" },
    { child: "penduduk", fk: "warga_negara_id", parent: "ref_warga_negara", pcol: "id" },
    { child: "penduduk", fk: "dusun_id", parent: "ref_dusun", pcol: "id" },
    // keluarga FKs
    { child: "keluarga", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "keluarga", fk: "kepala_penduduk_id", parent: "penduduk", pcol: "id" },
    // wilayah FKs
    { child: "wilayah_dusun", fk: "tenant_id", parent: "tenants", pcol: "id" },
    // surat FKs
    { child: "surat_ajuan", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "surat_ajuan", fk: "jenis_surat_id", parent: "surat_jenis", pcol: "id" },
    { child: "surat_ajuan_data", fk: "surat_ajuan_id", parent: "surat_ajuan", pcol: "id" },
    { child: "surat_terbit", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "surat_terbit", fk: "jenis_surat_id", parent: "surat_jenis", pcol: "id" },
    { child: "surat_terbit_data", fk: "surat_terbit_id", parent: "surat_terbit", pcol: "id" },
    { child: "surat_terbit_data", fk: "penduduk_id", parent: "penduduk", pcol: "id" },
    { child: "surat_jenis", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "surat_jenis_dna", fk: "jenis_surat_id", parent: "surat_jenis", pcol: "id" },
    { child: "surat_jenis_dna", fk: "tenant_id", parent: "tenants", pcol: "id" },
    // voting FKs
    { child: "voting_topik", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "voting_opsi", fk: "topik_id", parent: "voting_topik", pcol: "id" },
    { child: "voting_suara", fk: "topik_id", parent: "voting_topik", pcol: "id" },
    { child: "voting_suara", fk: "opsi_id", parent: "voting_opsi", pcol: "id" },
    // rpjmdes chain
    { child: "rpjmdes_periode", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "rpjmdes_bidang", fk: "periode_id", parent: "rpjmdes_periode", pcol: "id" },
    { child: "rpjmdes_program", fk: "bidang_id", parent: "rpjmdes_bidang", pcol: "id" },
    { child: "rkpdes_tahun", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "rkpdes_kegiatan", fk: "tahun_id", parent: "rkpdes_tahun", pcol: "id" },
    // bansos
    { child: "bantuan_sosial", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "penerima_bansos", fk: "bansos_id", parent: "bantuan_sosial", pcol: "id" },
    { child: "penerima_bansos", fk: "tenant_id", parent: "tenants", pcol: "id" },
    // others
    { child: "berita", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "agenda", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "pengumuman", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "galeri", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "hero_slider", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "usulan_warga", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "usulan_vote", fk: "usulan_id", parent: "usulan_warga", pcol: "id" },
    { child: "wa_broadcast", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "wa_broadcast_target", fk: "broadcast_id", parent: "wa_broadcast", pcol: "id" },
    { child: "balita", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "domain_events", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "event_log", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "apbdes", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "idm_status_desa", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "aduan_warga", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "profil_desa", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "desa_pamong", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "infrastruktur", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "bidang_tanah", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "bencana_kejadian", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "page_hero_config", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "admin_profiles", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "site_draft", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "dokumen_upload", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "pbb_tagihan", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_agama", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_pendidikan", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_pekerjaan", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_status_perkawinan", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_warga_negara", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_golongan_darah", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "ref_hubungan_keluarga", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "lembaga_desa", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "langganan_wa", fk: "tenant_id", parent: "tenants", pcol: "id" },
    { child: "identitas_desa", fk: "tenant_id", parent: "tenants", pcol: "id" },
  ];

  let totalFKChecks = 0;
  let fkWithIssues = 0;

  for (const c of fkChecks) {
    const r = await checkFK(c.child, c.fk, c.parent, c.pcol);
    totalFKChecks++;
    checks.push(r);

    const nullPct = r.total > 0 ? Math.round(r.nullCount / r.total * 100) : 0;
    const orphanPct = r.total > 0 ? Math.round(r.orphanCount / r.total * 100) : 0;

    let icon = "✅";
    let issueLevel = "ok";

    if (r.queryError) {
      icon = "❌"; issueLevel = "critical"; issues.push(`  ❌ ${c.child}.${c.fk} → ${c.parent}: Query error - ${r.queryError}`);
    } else if (r.orphanCount > 0) {
      icon = "❌"; issueLevel = "critical"; issues.push(`  ❌ ${c.child}.${c.fk} → ${c.parent}: ${r.orphanCount} orphan FK(s) ${r.orphans.length > 0 ? "(samples: " + r.orphans.slice(0,3).join(",") + ")" : ""}`);
      fkWithIssues++;
    } else if (r.nullCount > 0 && nullPct > 50) {
      icon = "⚠️"; issueLevel = "warning"; issues.push(`  ⚠️  ${c.child}.${c.fk}: ${r.nullCount}/${r.total} (${nullPct}%) NULL`);
    }

    const nullStr = r.nullCount > 0 ? ` NULL:${r.nullCount}(${nullPct}%)` : "";
    const orphanStr = r.orphanCount > 0 ? ` ORPHAN:${r.orphanCount}` : "";
    console.log(`  ${icon} ${c.child.padEnd(25)}.${c.fk.padEnd(28)} → ${c.parent}  total:${r.total}${nullStr}${orphanStr}`);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 3. UNIQUE CONSTRAINTS
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n══ 3. UNIQUE CONSTRAINTS ═════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  const uniqueChecks = [
    { table: "penduduk", col: "nik" },
    { table: "keluarga", col: "no_kk" },
    { table: "surat_jenis", col: "kode" },
    { table: "tenants", col: "id" },
    { table: "voting_topik", col: "id" },
  ];

  for (const u of uniqueChecks) {
    const r = await checkUnique(u.table, u.col);
    if (r.error) {
      console.log(`  ❌ ${u.table}.${u.col}: ${r.error}`);
    } else {
      const icon = r.hasDuplicates ? "❌" : "✅";
      console.log(`  ${icon} ${u.table.padEnd(25)}.${u.col.padEnd(25)} total:${r.total} distinct:${r.distinct} null:${r.nullCount}`);
      if (r.hasDuplicates) {
        r.duplicates.forEach(d => {
          issues.push(`  ❌ ${u.table}.${u.col}: DUPLICATE "${d.val}" appears ${d.count} times`);
          console.log(`       DUPLICATE: "${d.val}" (${d.count}x)`);
        });
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 4. REFERENCE TABLES (should have data)
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n══ 4. REFERENCE TABLES ════════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  const refTables = [
    "ref_agama", "ref_pendidikan", "ref_pekerjaan",
    "ref_status_perkawinan", "ref_warga_negara", "ref_golongan_darah",
    "ref_hubungan_keluarga", "ref_dusun"
  ];

  for (const t of refTables) {
    const { count: c } = await count(t, {});
    const icon = (c ?? 0) > 0 ? "✅" : "❌";
    console.log(`  ${icon} ${t.padEnd(30)} rows: ${c ?? "ERR"}`);
    if ((c ?? 0) === 0) issues.push(`  ❌ ${t}: EMPTY - no reference data`);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 5. ROW COUNTS SUMMARY
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n══ 5. ROW COUNTS ═════════════════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  const rowCountTables = [
    "penduduk", "keluarga", "wilayah_dusun",
    "surat_jenis", "surat_ajuan", "surat_terbit", "surat_terbit_data",
    "voting_topik", "voting_opsi", "voting_suara",
    "rpjmdes_periode", "rpjmdes_bidang", "rpjmdes_program",
    "rkpdes_tahun", "rkpdes_kegiatan",
    "bantuan_sosial", "penerima_bansos",
    "usulan_warga", "usulan_vote",
    "berita", "agenda", "pengumuman", "galeri", "hero_slider",
    "balita", "domain_events", "event_log", "apbdes",
    "idm_status_desa", "aduan_warga", "profil_desa",
    "page_hero_config", "dokumen_upload",
    "wa_broadcast", "wa_broadcast_target",
  ];

  for (const t of rowCountTables) {
    const { count: c } = await count(t, {});
    const icon = (c ?? 0) > 0 ? "📄" : "⚠️ ";
    console.log(`  ${icon} ${t.padEnd(25)} rows: ${(c ?? "ERR").toString().padStart(6)}`);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 6. SPECIAL CHECKS
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n══ 6. SPECIAL CHECKS ════════════════════════════════════════════");
  console.log("".padEnd(78, "─"));

  // Check: penduduk.statistik_consistency
  try {
    const { data: statRows } = await sb.from("penduduk_statistik").select("*");
    console.log(`  📊 penduduk_statistik: ${statRows?.length || 0} rows`);
    statRows?.forEach(r => {
      console.log(`     tenant=${r.tenant_id} penduduk=${r.penduduk} KK=${r.jumlah_kk} L=${r.laki_laki} P=${r.perempuan}`);
    });
  } catch (e) {
    console.log(`  ⚠️  penduduk_statistik view: ${e.message.slice(0, 80)}`);
  }

  // Check: surat_ajuan status distribution
  try {
    const { data: suratData } = await sb.from("surat_ajuan").select("status,jenis_surat_id");
    const statusDist = {};
    for (const s of (suratData || [])) {
      statusDist[s.status || "null"] = (statusDist[s.status || "null"] || 0) + 1;
    }
    console.log(`  📄 surat_ajuan status: ${JSON.stringify(statusDist)}`);
  } catch (e) {
    console.log(`  ⚠️  surat_ajuan: ${e.message.slice(0, 80)}`);
  }

  // Check: keluarga without anggota
  try {
    const { count: totalK } = await count("keluarga", {});
    const { data: anggotaCounts } = await sb.from("penduduk").select("keluarga_id").not("keluarga_id", "is", null).limit(100000);
    const referencedKK = new Set((anggotaCounts || []).map(p => p.keluarga_id));
    const orphanKK = (totalK ?? 0) - referencedKK.size;
    console.log(`  📄 keluarga tanpa anggota: ${orphanKK} / ${totalK}`);
    if (orphanKK > 0) issues.push(`  ⚠️  keluarga tanpa anggota: ${orphanKK} keluarga`);
  } catch (e) {
    console.log(`  ⚠️  keluarga tanpa anggota check: ${e.message.slice(0, 80)}`);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SUMMARY
  // ════════════════════════════════════════════════════════════════════════════
  console.log("\n" + "═".repeat(80));
  console.log("  RINGKASAN");
  console.log("═".repeat(80));
  console.log(`  Total FK checks: ${totalFKChecks}`);
  console.log(`  FK dengan orphan: ${fkWithIssues}`);
  console.log(`  Total issues: ${issues.length}`);

  if (issues.length === 0) {
    console.log("\n  🎉 TIDAK ADA MASALAH INTEGRITAS!");
  } else {
    console.log("\n  ISSUES:");
    const critical = issues.filter(i => i.includes("❌"));
    const warning = issues.filter(i => i.includes("⚠️"));
    if (critical.length > 0) {
      console.log("\n  ❌ CRITICAL:");
      critical.forEach(i => console.log(i));
    }
    if (warning.length > 0) {
      console.log("\n  ⚠️  WARNINGS:");
      warning.forEach(i => console.log(i));
    }
  }
  console.log("═".repeat(80));

  return { checks, issues, fkWithIssues };
}

main().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
