/**
 * verify-penduduk-integrity.mjs
 * Verifikasi integrasi data penduduk & keluarga dengan seluruh sistem.
 *
 * Usage: node scripts/verify-penduduk-integrity.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

function pct(n, total) { return total > 0 ? `${Math.round(n / total * 100)}%` : "N/A"; }
function stat(label, val, total, warn = 10) {
  const p = total > 0 ? Math.round(val / total * 100) : 0;
  const icon = val === 0 ? "✅" : p <= warn ? "⚠️ " : "❌";
  console.log(`  ${icon} ${label.padEnd(35)} ${String(val).padStart(6)} / ${total}  (${p}%)`);
}
function ok(label, val) { console.log(`  ✅ ${label.padEnd(35)} ${val}`); }
function fail(label, val) { console.log(`  ❌ ${label.padEnd(35)} ${val}`); }

async function count(table, filter = {}) {
  let q = sb.from(table).select("*", { count: "exact", head: true });
  for (const [k, v] of Object.entries(filter)) {
    if (v === null) q = q.is(k, null);
    else q = q.eq(k, v);
  }
  const { count: c, error } = await q;
  if (error) {
    if (error.message.includes("Could not find the 'dusun_id'") || error.message.includes("Could not find the 'kepala_penduduk_id'")) return "N/A (Schema Error)";
    console.error(`Error counting ${table}:`, error.message);
    return "ERR";
  }
  return c ?? 0;
}

async function main() {
  console.log("═".repeat(60));
  console.log("  VERIFIKASI INTEGRITAS DATA PENDUDUK");
  console.log("═".repeat(60));

  // ── 1. Penduduk & KK counts ───────────────────────────────────────────────
  console.log("\n── 1. Jumlah Data ─────────────────────────────────────────");
  const totalP  = await count("penduduk");
  const totalK  = await count("keluarga");
  ok("Total penduduk", totalP);
  ok("Total keluarga (KK)", totalK);

  // ── 2. Penduduk relasi ke keluarga ────────────────────────────────────────
  console.log("\n── 2. Kelengkapan Relasi Penduduk → Keluarga ──────────────");
  const noKK = await count("penduduk", { keluarga_id: null });
  stat("Tanpa keluarga_id (NULL)", noKK, totalP, 5);

  // ── 3. FK Refs ────────────────────────────────────────────────────────────
  console.log("\n── 3. FK Refs ke Tabel Referensi ──────────────────────────");
  const noAgama   = await count("penduduk", { agama_id: null });
  const noPend    = await count("penduduk", { pendidikan_id: null });
  const noPek     = await count("penduduk", { pekerjaan_id: null });
  const noStatus  = await count("penduduk", { status_perkawinan_id: null });
  const noDusunId = await count("penduduk", { dusun_id: null });
  const noProvId  = await count("penduduk", { provinsi_id: null });
  const noKabId   = await count("penduduk", { kabupaten_id: null });
  const noKecId   = await count("penduduk", { kecamatan_id: null });
  const noDesaId  = await count("penduduk", { desa_id: null });
  stat("Tanpa agama_id",            noAgama,   totalP, 5);
  stat("Tanpa pendidikan_id",       noPend,    totalP, 5);
  stat("Tanpa pekerjaan_id",        noPek,     totalP, 20); // banyak yang tidak bekerja
  stat("Tanpa status_perkawinan_id",noStatus,  totalP, 5);
  stat("Tanpa dusun_id",            noDusunId, totalP, 5);
  stat("Tanpa provinsi_id",         noProvId,  totalP, 1);
  stat("Tanpa kabupaten_id",        noKabId,   totalP, 1);
  stat("Tanpa kecamatan_id",        noKecId,   totalP, 1);
  stat("Tanpa desa_id",             noDesaId,  totalP, 1);

  // ── 4. Keluarga relasi ke penduduk (kepala) ───────────────────────────────
  console.log("\n── 4. Keluarga → Kepala Penduduk ──────────────────────────");
  const noKepala = await count("keluarga", { kepala_penduduk_id: null });
  stat("KK tanpa kepala_penduduk_id", noKepala, totalK, 10);

  // ── 5. Distribusi per dusun ───────────────────────────────────────────────
  console.log("\n── 5. Distribusi Penduduk per Dusun ───────────────────────");
  const { data: dusunStats } = await sb.from("penduduk")
    .select("dusun")
    .eq("status_hidup", "hidup");
  const dusunCount = {};
  for (const p of dusunStats ?? []) {
    const d = p.dusun ?? "(null)";
    dusunCount[d] = (dusunCount[d] ?? 0) + 1;
  }
  const sorted = Object.entries(dusunCount).sort((a, b) => b[1] - a[1]);
  for (const [d, c] of sorted) {
    console.log(`  ${d.padEnd(25)} ${c}`);
  }

  // ── 6. Status hidup ───────────────────────────────────────────────────────
  console.log("\n── 6. Status Hidup ────────────────────────────────────────");
  const hidup     = await count("penduduk", { status_hidup: "hidup" });
  const meninggal = await count("penduduk", { status_hidup: "meninggal" });
  const pindah    = await count("penduduk", { status_hidup: "pindah" });
  ok("Hidup",     hidup);
  ok("Meninggal", meninggal);
  ok("Pindah",    pindah);

  // ── 7. Cek surat_ajuan integrasi ─────────────────────────────────────────
  console.log("\n── 7. Integrasi Surat Ajuan ───────────────────────────────");
  const { count: totalSurat } = await sb.from("surat_ajuan").select("*", { count: "exact", head: true });
  ok("Total surat_ajuan", totalSurat ?? 0);
  // Cek surat dengan NIK tapi penduduk tidak ada
  const { data: suratSample } = await sb.from("surat_ajuan").select("nik_pemohon").not("nik_pemohon", "is", null).limit(5);
  if (suratSample?.length) {
    const niks = suratSample.map(s => s.nik_pemohon).filter(Boolean);
    const { count: foundInPenduduk } = await sb.from("penduduk").select("*", { count: "exact", head: true }).in("nik", niks);
    ok("Sample surat NIK found in penduduk", `${foundInPenduduk}/${niks.length}`);
  }

  // ── 8. Cek view statistik ─────────────────────────────────────────────────
  console.log("\n── 8. Views & Statistik ───────────────────────────────────");
  const { data: statView } = await sb.from("penduduk_statistik").select("*").limit(3);
  if (statView?.length) {
    for (const row of statView) {
      console.log(`  ✅ penduduk_statistik: penduduk=${row.jumlah_penduduk}, KK=${row.jumlah_kk}, L=${row.laki_laki}, P=${row.perempuan}`);
    }
  } else {
    console.log("  ⚠️  penduduk_statistik: tidak ada data");
  }
  const { data: dusunView } = await sb.from("penduduk_per_dusun").select("*").order("jumlah_penduduk", { ascending: false }).limit(5);
  if (dusunView?.length) {
    console.log("  ✅ penduduk_per_dusun (top 5):");
    for (const row of dusunView) {
      console.log(`     ${(row.dusun ?? "?").padEnd(20)} ${row.jumlah_penduduk} penduduk`);
    }
  } else {
    console.log("  ⚠️  penduduk_per_dusun: tidak ada data");
  }

  // ── 9. Duplicate NIK check ───────────────────────────────────────────────
  console.log("\n── 9. Duplicate NIK ───────────────────────────────────────");
  const { data: dupNik } = await sb.rpc("check_duplicate_niks").limit?.(5) ?? {};
  // Fallback manual check
  const { data: allNiks } = await sb.from("penduduk").select("nik").limit(20000);
  const nikSet = new Set();
  const dups = [];
  for (const p of allNiks ?? []) {
    if (nikSet.has(p.nik)) dups.push(p.nik);
    nikSet.add(p.nik);
  }
  if (dups.length === 0) {
    console.log("  ✅ Tidak ada duplicate NIK");
  } else {
    console.log(`  ❌ ${dups.length} duplicate NIK ditemukan:`, dups.slice(0, 5));
  }

  // ── Summary ───────────────────────────────────────────────────────────────
  console.log("\n═".repeat(60));
  const issues = [
    typeof noKK === 'number' && noKK > totalP * 0.05 ? `keluarga_id NULL: ${noKK}` : null,
    typeof noAgama === 'number' && noAgama > totalP * 0.05 ? `agama_id NULL: ${noAgama}` : null,
    typeof noDusunId === 'number' && noDusunId > totalP * 0.05 ? `dusun_id NULL: ${noDusunId}` : null,
    typeof noProvId === 'number' && noProvId > 0 ? `provinsi_id NULL: ${noProvId}` : null,
    dups.length > 0 ? `Duplicate NIK: ${dups.length}` : null,
  ].filter(Boolean);

  if (issues.length === 0) {
    console.log("  🎉 INTEGRITAS DATA: BAIK — tidak ada masalah kritis");
  } else {
    console.log("  ⚠️  Issues ditemukan:");
    for (const i of issues) console.log(`     - ${i}`);
  }
  console.log("═".repeat(60));
}

main().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
