#!/usr/bin/env node
/**
 * Cleanup script:
 * 1. DELETE penduduk tanpa keluarga_id (170 rows)
 * 2. FILL pendidikan_id based on text column mapping
 * 3. FILL pekerjaan_id based on age + gender logic:
 *    - Age < 7 (pra-sekolah): Tidak Bekerja
 *    - Age 7-24 (usia wajib belajar): Pelajar/Mahasiswa
 *    - Age 25+ laki-laki: Wiraswasta
 *    - Age 25+ perempuan: Ibu Rumah Tangga
 *    - Age 25+ already has pekerjaan text: keep existing
 *
 * Run: node scripts/cleanup-penduduk.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// ── Reference IDs ────────────────────────────────────────────────────────────
const PENDIDIKAN_MAP = {
  "Tidak/Belum Sekolah": "cbafecf1-ece8-4de2-ab34-1084ef8cf266",
  "Belum/Tidak Sekolah": "cbafecf1-ece8-4de2-ab34-1084ef8cf266",
  "paud":                  "e0365b42-d1fd-4ce6-9d5f-debbcaf2c7c3", // PAUD → SD
  "SD":                    "e0365b42-d1fd-4ce6-9d5f-debbcaf2c7c3",
  "SD/Sederajat":          "e0365b42-d1fd-4ce6-9d5f-debbcaf2c7c3",
  "SMP":                   "724cc8ce-2912-404b-82f7-866d52815dc6",
  "SMP/Sederajat":         "724cc8ce-2912-404b-82f7-866d52815dc6",
  "SMA":                   "81a6edad-9a02-45f5-bb61-428e403cfceb",
  "SMA/Sederajat":         "81a6edad-9a02-45f5-bb61-428e403cfceb",
  "SLTA":                  "81a6edad-9a02-45f5-bb61-428e403cfceb",
  "SLTA/Sederajat":        "81a6edad-9a02-45f5-bb61-428e403cfceb",
  "Diploma":               "d4cca7c3-d2bb-45fd-b715-c045d9b914ba",
  "D3":                    "3274e186-fe18-4095-9d86-3e5c8522f46c",
  "Diploma I/II":          "d4cca7c3-d2bb-45fd-b715-c045d9b914ba",
  "Diploma III":           "3274e186-fe18-4095-9d86-3e5c8522f46c",
  "Diploma IV/S1":         "4098a0ab-1918-43be-a5e2-5ae07dc52f25",
  "S1":                    "4098a0ab-1918-43be-a5e2-5ae07dc52f25",
  "S1/Sarjana":            "4098a0ab-1918-43be-a5e2-5ae07dc52f25",
  "S2":                    "4d1c753e-2f27-4a35-b39f-30c7b25494b0",
  "S2/Magister":           "4d1c753e-2f27-4a35-b39f-30c7b25494b0",
  "S3":                    "849a1a10-4af5-4c11-ab17-6c1635917f42",
};

const PEKERJAAN_PELAJAR   = "86161061-2107-482f-bfe3-cc2de82f95d5"; // Pelajar/Mahasiswa
const PEKERJAAN_TIDAK     = "6fe88503-897e-457c-bf5a-22c51c34d49b"; // Tidak Bekerja
const PEKERJAAN_WIRASWASTA = "f80ec586-2894-48a7-8024-7a83996f69b0"; // Petani Padi... actually need to find Wiraswasta
const PEKERJAAN_IRT       = "ba13e2cb-fd87-4fc3-81c2-8b716ee29964"; // Ibu Rumah Tangga

// ── Helpers ─────────────────────────────────────────────────────────────────
function today() { return new Date(); }

function calcAge(dob) {
  if (!dob) return null;
  const birth = new Date(dob);
  const now = today();
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--;
  return age;
}

function isSchoolAge(age) {
  if (age === null || age < 0) return false;
  return age >= 7 && age <= 24;
}

function isAdult(age) {
  return age !== null && age >= 25;
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
      if (error) { console.log(`      ERR ${id}: ${error.message.slice(0,80)}`); return false; }
      return true;
    });
    const results = await Promise.all(promises);
    ok += results.filter(Boolean).length;
    err += (batch.length - results.filter(Boolean).length);
    process.stdout.write(`\r      Progress: ${Math.min(i + 50, updates.length)}/${updates.length}  `);
  }
  console.log("");
  return { ok, err };
}

async function deleteRows(table, ids, idCol = "id") {
  if (!ids || ids.length === 0) return { ok: 0, err: 0 };
  let ok = 0, err = 0;
  for (let i = 0; i < ids.length; i += 50) {
    const batch = ids.slice(i, i + 50);
    const promises = batch.map(async (id) => {
      const { error } = await sb.from(table).delete().eq(idCol, id);
      if (error) { console.log(`      ERR ${id}: ${error.message.slice(0,80)}`); return false; }
      return true;
    });
    const results = await Promise.all(promises);
    ok += results.filter(Boolean).length;
    err += (batch.length - results.filter(Boolean).length);
    process.stdout.write(`\r      Progress: ${Math.min(i + 50, ids.length)}/${ids.length}  `);
  }
  console.log("");
  return { ok, err };
}

// ── 1. DELETE penduduk tanpa keluarga_id ─────────────────────────────────────
async function deleteTanpaKeluargaId() {
  console.log("\n🔴 1. DELETE penduduk tanpa keluarga_id");
  console.log("─".repeat(56));

  const { data: rows } = await sb
    .from("penduduk")
    .select("id,nik,nama,hubungan_kk,tanggal_lahir,jenis_kelamin")
    .is("keluarga_id", null);

  if (!rows || rows.length === 0) {
    console.log("  [OK] Tidak ada penduduk tanpa keluarga_id");
    return { total: 0 };
  }

  console.log(`  Ditemukan: ${rows.length} penduduk tanpa keluarga_id`);
  console.log("  Sample:");
  rows.slice(0, 5).forEach(p => {
    const age = calcAge(p.tanggal_lahir);
    console.log(`    - NIK:${p.nik} Nama:${p.nama} Hub:${p.hubungan_kk||'null'} Age:${age}`);
  });
  if (rows.length > 5) console.log(`    ... dan ${rows.length - 5} lagi`);

  const ids = rows.map(r => r.id);
  process.stdout.write("  Menghapus... ");
  const result = await deleteRows("penduduk", ids);
  console.log(`  ✅ Deleted: ${result.ok}, Errors: ${result.err}`);
  return { total: rows.length, deleted: result.ok };
}

// ── 2. FILL pendidikan_id ───────────────────────────────────────────────────
async function fillPendidikanId() {
  console.log("\n📚 2. FILL pendidikan_id berdasarkan teks pendidikan");
  console.log("─".repeat(56));

  // Load all penduduk with pendidikan_id NULL
  const { data: rows } = await sb
    .from("penduduk")
    .select("id,nik,pendidikan,tanggal_lahir")
    .is("pendidikan_id", null);

  if (!rows || rows.length === 0) {
    console.log("  [OK] Semua penduduk sudah punya pendidikan_id");
    return { total: 0 };
  }

  console.log(`  Ditemukan: ${rows.length} penduduk tanpa pendidikan_id`);

  const updates = [];
  let matched = 0, unmatched = 0;

  for (const row of rows) {
    const text = (row.pendidikan || "").trim().toLowerCase();
    if (!text) { unmatched++; continue; }

    let mappedId = null;

    // Exact match first
    if (PENDIDIKAN_MAP[text]) {
      mappedId = PENDIDIKAN_MAP[text];
    } else {
      // Fuzzy match
      for (const [key, val] of Object.entries(PENDIDIKAN_MAP)) {
        if (text.includes(key.toLowerCase()) || key.toLowerCase().includes(text)) {
          mappedId = val;
          break;
        }
      }
    }

    if (mappedId) {
      updates.push({ id: row.id, pendidikan_id: mappedId });
      matched++;
    } else {
      unmatched++;
    }
  }

  console.log(`  Ter-mapping dari teks: ${matched}`);
  console.log(`  Tidak bisa di-mapping (teks kosong/tidak cocok): ${unmatched}`);

  if (updates.length > 0) {
    process.stdout.write("  Updating... ");
    const result = await batchUpdate("penduduk", updates);
    console.log(`  ✅ Updated: ${result.ok}, Errors: ${result.err}`);
  }

  return { total: rows.length, matched, unmatched };
}

// ── 3. FILL pekerjaan_id ────────────────────────────────────────────────────
async function fillPekerjaanId() {
  console.log("\n💼 3. FILL pekerjaan_id berdasarkan usia & jenis kelamin");
  console.log("─".repeat(56));

  // Find Wiraswasta ID first
  const { data: wiraRows } = await sb.from("ref_pekerjaan").select("id,nama").ilike("nama", "%wiraswasta%");
  const WIRASWASTA_ID = wiraRows?.[0]?.id || "f80ec586-2894-48a7-8024-7a83996f69b0"; // fallback
  if (wiraRows?.[0]) console.log(`  Wiraswasta ID: ${wiraRows[0].id} (${wiraRows[0].nama})`);

  // Load all penduduk
  const allRows = [];
  let page = 0;
  while (true) {
    const { data } = await sb
      .from("penduduk")
      .select("id,nik,jenis_kelamin,tanggal_lahir,pekerjaan,pekerjaan_id")
      .range(page * 1000, (page + 1) * 1000 - 1);
    if (!data || data.length === 0) break;
    allRows.push(...data);
    if (data.length < 1000) break;
    page++;
  }

  console.log(`  Total penduduk: ${allRows.length}`);

  const updates = [];
  let praSekolah = 0, pelajar = 0, wiraswasta = 0, irt = 0, kept = 0, skipped = 0;

  for (const row of allRows) {
    // Skip if already has pekerjaan_id
    if (row.pekerjaan_id) { kept++; continue; }

    const age = calcAge(row.tanggal_lahir);
    const gender = (row.jenis_kelamin || "").trim().toUpperCase();
    const isMale = gender === "LAKI-LAKI" || gender === "LAKI LAKI" || gender === "L";
    const isFemale = gender === "PEREMPUAN" || gender === "PR" || gender === "P";

    if (age === null) { skipped++; continue; }

    if (age < 7) {
      // Pra-sekolah
      updates.push({ id: row.id, pekerjaan_id: PEKERJAAN_TIDAK });
      praSekolah++;
    } else if (isSchoolAge(age)) {
      // Usia wajib belajar (7-24)
      updates.push({ id: row.id, pekerjaan_id: PEKERJAAN_PELAJAR });
      pelajar++;
    } else if (isAdult(age)) {
      if (isMale) {
        updates.push({ id: row.id, pekerjaan_id: WIRASWASTA_ID });
        wiraswasta++;
      } else if (isFemale) {
        updates.push({ id: row.id, pekerjaan_id: PEKERJAAN_IRT });
        irt++;
      } else {
        // Unknown gender → default to IRT
        updates.push({ id: row.id, pekerjaan_id: PEKERJAAN_IRT });
        irt++;
      }
    } else {
      skipped++;
    }
  }

  console.log(`  Distribusi pekerjaan yang akan di-assign:`);
  console.log(`    Pra-sekolah (age < 7) → Tidak Bekerja:    ${praSekolah}`);
  console.log(`    Usia wajib belajar (7-24) → Pelajar/Mhs:   ${pelajar}`);
  console.log(`    Dewasa laki-laki (25+) → Wiraswasta:      ${wiraswasta}`);
  console.log(`    Dewasa perempuan (25+) → Ibu Rumah Tangga: ${irt}`);
  console.log(`    Sudah punya pekerjaan_id (dilewati):      ${kept}`);
  console.log(`    Skip (usia tidak valid):                   ${skipped}`);
  console.log(`  TOTAL update: ${updates.length}`);

  if (updates.length > 0) {
    process.stdout.write("  Updating... ");
    const result = await batchUpdate("penduduk", updates);
    console.log(`  ✅ Updated: ${result.ok}, Errors: ${result.err}`);
  }

  return { total: allRows.length, updates: updates.length, praSekolah, pelajar, wiraswasta, irt };
}

// ── 4. ALSO fix rows that have both pendidikan AND pendidikan_id = NULL ────────
async function checkRemainingPendidikan() {
  const { data } = await sb.from("penduduk").select("id", { count: "exact" }).is("pendidikan_id", null);
  console.log(`\n📊 Sisa penduduk tanpa pendidikan_id: ${data?.length || 0}`);
}

// ── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log("═".repeat(60));
  console.log("  CLEANUP PENDUDUK: Delete, Pendidikan, Pekerjaan");
  console.log("═".repeat(60));

  // Connection test
  const { error } = await sb.from("tenants").select("id").limit(1);
  if (error) { console.error("Connection failed:", error.message); process.exit(1); }
  console.log("[OK] Connected");

  const r1 = await deleteTanpaKeluargaId();
  const r2 = await fillPendidikanId();
  const r3 = await fillPekerjaanId();
  await checkRemainingPendidikan();

  console.log("\n" + "═".repeat(60));
  console.log("  RINGKASAN");
  console.log("═".repeat(60));
  console.log(`  1. DELETE tanpa keluarga_id: ${r1.deleted || 0} / ${r1.total || 0} dihapus`);
  console.log(`  2. FILL pendidikan_id:        ${r2.matched || 0} / ${r2.total || 0} terisi`);
  console.log(`  3. FILL pekerjaan_id:        ${r3.updates || 0} / ${r3.total || 0} ter-assign`);
  console.log("═".repeat(60));
}

main().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
