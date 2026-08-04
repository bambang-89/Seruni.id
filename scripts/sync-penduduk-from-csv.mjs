/**
 * sync-penduduk-from-csv.mjs
 * UPSERT data penduduk & keluarga dari docs/penduduk.csv ke Supabase.
 * Idempotent: bisa dijalankan ulang. Conflict by NIK / no_kk.
 *
 * Usage: node scripts/sync-penduduk-from-csv.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createReadStream } from "fs";
import readline from "readline";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ── Config ──────────────────────────────────────────────────────────────────
const SUPABASE_URL   = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";
const TENANT_ID      = "d532ae95-0ad9-42bb-a6e8-5c840447c90e";
const CSV_PATH       = path.join(__dirname, "../docs/penduduk.csv");
const BATCH_SIZE     = 100;

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// ── Lookup maps (populated at runtime) ──────────────────────────────────────
const dusunNameToId  = new Map(); // "Dames" → uuid
const kkNoToId       = new Map(); // no_kk  → uuid

// ── Normalizers ─────────────────────────────────────────────────────────────
const JK_MAP = {
  "laki-laki": "L", "laki laki": "L", "l": "L",
  "perempuan": "P", "p": "P",
};
const STATUS_MAP = {
  "belum kawin": "Belum Kawin",
  "kawin": "Kawin",
  "cerai hidup": "Cerai Hidup",
  "cerai mati": "Cerai Mati",
};
const HUBUNGAN_MAP = {
  "kepala keluarga": "Kepala Keluarga", "kk": "Kepala Keluarga",
  "istri": "Istri/Suami", "suami": "Istri/Suami",
  "anak": "Anak",
  "famili lain": "Famili Lain",
  "mertua": "Mertua",
  "cucu": "Cucu",
  "orang tua": "Orang Tua",
  "lainnya": "Lainnya",
};
// CSV dusun → nama canonical (sesuai ref_dusun)
const DUSUN_MAP = {
  "dames":          "Dames",
  "mandar":         "Mandar",
  "sasak":          "Sasak",
  "brangtapen asri":"Brangtapen Asri",
  "seruni barat":   "Seruni Barat",
  "seruni timur":   "Seruni Timur",
  "mumbul utara":   "Mumbul Utara",
  "mumbul selatan": "Mumbul Selatan",
};

function fixNik(v) {
  if (!v) return null;
  let s = String(v).trim().replace(/\s/g, "");
  // Fix OCR artifacts: replace O/o with 0
  s = s.replace(/[Oo]{2,}/g, m => "0".repeat(m.length));
  s = s.replace(/[^0-9]/g, "");
  return s.length === 16 ? s : null;
}

function gv(v) {
  if (v === undefined || v === null) return null;
  const s = String(v).trim();
  return s === "" || s === "-" || s.toLowerCase() === "nan" ? null : s;
}

function mapJk(v) {
  if (!v) return null;
  return JK_MAP[String(v).toLowerCase().trim()] ?? gv(v);
}

function mapStatus(v) {
  if (!v) return null;
  return STATUS_MAP[String(v).toLowerCase().trim()] ?? gv(v);
}

function mapHubungan(v) {
  if (!v) return null;
  return HUBUNGAN_MAP[String(v).toLowerCase().trim()] ?? gv(v);
}

function mapDusun(v) {
  if (!v) return null;
  const key = String(v).toLowerCase().trim();
  return DUSUN_MAP[key] ?? gv(v);
}

function normalizeDate(v) {
  if (!v) return null;
  const s = String(v).trim();
  // dd/mm/yyyy
  if (/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(s)) {
    const [d, m, y] = s.split("/");
    return `${y}-${m.padStart(2,"0")}-${d.padStart(2,"0")}`;
  }
  // yyyy-mm-dd
  if (/^\d{4}-\d{2}-\d{2}/.test(s)) return s.slice(0, 10);
  return null;
}

// ── CSV parser ───────────────────────────────────────────────────────────────
async function readCsv(filePath) {
  const rows = [];
  const rl = readline.createInterface({ input: createReadStream(filePath, "utf-8"), crlfDelay: Infinity });
  let headers = null;
  for await (const line of rl) {
    if (!line.trim()) continue;
    if (!headers) {
      // strip BOM
      headers = line.replace(/^\uFEFF/, "").split(",");
      continue;
    }
    // Simple split — CSV values don't have commas inside quotes in this file
    const vals = line.split(",");
    const row = {};
    headers.forEach((h, i) => { row[h.trim()] = (vals[i] ?? "").trim(); });
    rows.push(row);
  }
  return rows;
}

// ── Batch upsert helper ──────────────────────────────────────────────────────
async function batchUpsert(table, rows, conflictCol, label) {
  let ok = 0, err = 0;
  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE);
    const { error } = await sb.from(table).upsert(batch, { onConflict: conflictCol, ignoreDuplicates: false });
    if (error) {
      console.error(`  ❌ ${label} batch ${i}-${i+batch.length}: ${error.message}`);
      err += batch.length;
    } else {
      ok += batch.length;
    }
    process.stdout.write(`\r  ${label}: ${Math.min(i + BATCH_SIZE, rows.length)}/${rows.length}`);
  }
  console.log(`\n  ✅ ${label}: ${ok} ok, ${err} error`);
  return { ok, err };
}

// ── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log("═".repeat(60));
  console.log("  SYNC PENDUDUK FROM CSV");
  console.log("═".repeat(60));
  console.log(`  CSV   : ${CSV_PATH}`);
  console.log(`  Tenant: ${TENANT_ID}`);
  console.log();

  // ── Load ref_dusun ────────────────────────────────────────────────────────
  console.log("Loading ref_dusun...");
  const { data: dusunRows } = await sb.from("ref_dusun").select("id,nama");
  for (const d of dusunRows ?? []) dusunNameToId.set(d.nama.toLowerCase(), d.id);
  console.log(`  ${dusunNameToId.size} dusun loaded`);

  // ── Parse CSV ─────────────────────────────────────────────────────────────
  console.log("\nParsing CSV...");
  const rawRows = await readCsv(CSV_PATH);
  console.log(`  Total rows: ${rawRows.length}`);

  let skippedNik = 0;
  const validRows = [];
  for (const r of rawRows) {
    const nik = fixNik(r.NIK);
    const no_kk = fixNik(r.NO_KK);
    if (!nik || !no_kk) { skippedNik++; continue; }
    validRows.push({ raw: r, nik, no_kk });
  }
  console.log(`  Valid: ${validRows.length}, skipped (bad NIK/KK): ${skippedNik}`);

  // ── Phase 2: UPSERT keluarga ──────────────────────────────────────────────
  console.log("\n─── Phase 2: UPSERT keluarga ───");
  const kkMap = new Map(); // no_kk → first row with that KK
  for (const { raw, nik, no_kk } of validRows) {
    if (!kkMap.has(no_kk)) {
      const dusunRaw = mapDusun(raw.DUSUN) ?? gv(raw.DUSUN);
      const rt = gv(raw.RT);
      kkMap.set(no_kk, {
        no_kk,
        dusun: dusunRaw,
        rt: rt,
        alamat: dusunRaw ? `${dusunRaw}${rt ? ` RT ${rt}` : ""}` : null,
        tenant_id: TENANT_ID,
        // kepala_nama will be set in the penduduk loop below
      });
    }
  }

  // Fill kepala_nama per KK (from KK member)
  for (const { raw, nik, no_kk } of validRows) {
    const hub = mapHubungan(raw.STATUS_DALAM_KK);
    if (hub === "Kepala Keluarga" && kkMap.has(no_kk)) {
      kkMap.get(no_kk).kepala_nama = gv(raw.NAMA);
    }
  }

  const kkRows = Array.from(kkMap.values());
  console.log(`  Unique KK: ${kkRows.length}`);
  await batchUpsert("keluarga", kkRows, "no_kk", "keluarga");

  // Reload KK IDs after upsert
  console.log("  Reloading keluarga IDs...");
  let allKK = [];
  let page = 0;
  while (true) {
    const { data: batch } = await sb.from("keluarga").select("id,no_kk").range(page * 1000, (page + 1) * 1000 - 1);
    if (!batch || batch.length === 0) break;
    allKK.push(...batch);
    page++;
  }
  for (const kk of allKK) kkNoToId.set(kk.no_kk, kk.id);
  console.log(`  ${kkNoToId.size} KK loaded`);

  // ── Phase 1: UPSERT penduduk ──────────────────────────────────────────────
  console.log("\n─── Phase 1: UPSERT penduduk ───");
  const pendudukRows = [];
  for (const { raw, nik, no_kk } of validRows) {
    const dusunNama = mapDusun(raw.DUSUN) ?? gv(raw.DUSUN);
    const dusunId   = dusunNama ? dusunNameToId.get(dusunNama.toLowerCase()) ?? null : null;
    const keluarga_id = kkNoToId.get(no_kk) ?? null;
    const rt = gv(raw.RT);
    const rw = gv(raw.RW);
    const statusHidup = (() => {
      const sp = gv(raw.STATUS_PENDUDUK);
      if (!sp || sp === "aktif") return "hidup";
      if (sp === "meninggal") return "meninggal";
      if (sp.includes("pindah")) return "pindah";
      return "hidup";
    })();

    pendudukRows.push({
      nik,
      nama:          gv(raw.NAMA),
      jenis_kelamin: mapJk(raw.JENIS_KELAMIN),
      tempat_lahir:  gv(raw.TEMPAT_LAHIR),
      tanggal_lahir: normalizeDate(raw.TANGGAL_LAHIR),
      agama:         gv(raw.AGAMA),
      pendidikan:    gv(raw.PENDIDIKAN),
      pekerjaan:     gv(raw.PEKERJAAN),
      status_kawin:  mapStatus(raw.STATUS_PERKAWINAN),
      hubungan_kk:   mapHubungan(raw.STATUS_DALAM_KK),
      keluarga_id,
      dusun:         dusunNama,
      rt,
      rw,
      alamat:        dusunNama ? `${dusunNama}${rt ? ` RT ${rt}` : ""}` : null,
      status_hidup:  statusHidup,
      bpjs_status:   gv(raw.BPJS_KESEHATAN) ?? "Tidak",
      // Wilayah UUID hardcoded — Seruni Mumbul, Pringgabaya, Lombok Timur, NTB
      provinsi_id:   "133cd1be-28d4-41d4-abbb-0e84995e76af",
      kabupaten_id:  "12b08ba5-ead7-4747-be7e-653d49e6e3b5",
      kecamatan_id:  "4c70cd4c-c14b-41e3-96d3-a4290169999a",
      desa_id:       "be4dda9d-334b-43e2-89a3-50c724ced517",
      tenant_id:     TENANT_ID,
      // NOTE: dusun_id will be patched separately after column is added via migration
    });

  }

  console.log(`  Penduduk to upsert: ${pendudukRows.length}`);
  await batchUpsert("penduduk", pendudukRows, "nik", "penduduk");

  // ── Summary ───────────────────────────────────────────────────────────────
  console.log("\n═".repeat(60));
  const { count: totalP } = await sb.from("penduduk").select("*", { count: "exact", head: true });
  const { count: totalK } = await sb.from("keluarga").select("*", { count: "exact", head: true });
  const { count: noKK }   = await sb.from("penduduk").select("*", { count: "exact", head: true }).is("keluarga_id", null);
  console.log(`  ✅ Total penduduk di DB : ${totalP}`);
  console.log(`  ✅ Total keluarga di DB : ${totalK}`);
  console.log(`  ⚠️  Penduduk tanpa KK  : ${noKK}`);
  console.log("═".repeat(60));
  console.log("  Selesai! Jalankan patch-penduduk-fk.mjs untuk patching FK refs.");
  console.log("═".repeat(60));
}

main().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
