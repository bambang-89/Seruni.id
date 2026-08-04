/**
 * patch-penduduk-fk.mjs
 * Patch semua FK UUID di tabel penduduk & keluarga:
 *   - agama_id, pendidikan_id, pekerjaan_id, status_perkawinan_id
 *   - dusun_id (by name match)
 *   - keluarga.kepala_penduduk_id (penduduk WHERE hubungan_kk = KK)
 *
 * Usage: node scripts/patch-penduduk-fk.mjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";
const TENANT_ID    = "d532ae95-0ad9-42bb-a6e8-5c840447c90e";
const BATCH        = 50;

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// ── Normalize helper ──────────────────────────────────────────────────────────
function norm(s) { return String(s ?? "").toLowerCase().trim(); }

// ── Build lookup map from ref table ──────────────────────────────────────────
async function buildMap(table, keyCol, valCol, filter = {}) {
  const q = sb.from(table).select(`${keyCol},${valCol}`);
  if (filter.aktif) q.eq("aktif", true);
  const { data, error } = await q;
  if (error) { console.error(`buildMap ${table}:`, error.message); return new Map(); }
  const m = new Map();
  for (const row of data ?? []) {
    m.set(norm(row[keyCol]), row[valCol]);
  }
  return m;
}

// ── Batch update helper ───────────────────────────────────────────────────────
async function batchUpdate(table, updates, label) {
  // updates: [{id, ...fields}]
  let ok = 0, err = 0;
  for (let i = 0; i < updates.length; i += BATCH) {
    const slice = updates.slice(i, i + BATCH);
    const promises = slice.map(async (u) => {
      const { id, ...fields } = u;
      const { error } = await sb.from(table).update(fields).eq("id", id);
      if (error) {
        if (!error.message.includes("schema cache") && !error.message.includes("Could not find the 'dusun_id'")) {
          console.error(`  ❌ ${label} id ${id}: ${error.message}`);
        }
        return false;
      }
      return true;
    });
    
    const results = await Promise.all(promises);
    const sliceOk = results.filter(Boolean).length;
    ok += sliceOk;
    err += (slice.length - sliceOk);
    
    process.stdout.write(`\r  ${label}: ${Math.min(i + BATCH, updates.length)}/${updates.length}`);
  }
  console.log(`\n  ✅ ${label}: ${ok} patched, ${err} error`);
}

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  console.log("═".repeat(60));
  console.log("  PATCH PENDUDUK FK REFS");
  console.log("═".repeat(60));

  // ── Load all ref maps ─────────────────────────────────────────────────────
  console.log("\nLoading ref tables...");
  const agamaMap     = await buildMap("ref_agama",             "nama", "id");
  const pendMap      = await buildMap("ref_pendidikan",        "nama", "id");
  const pekMap       = await buildMap("ref_pekerjaan",         "nama", "id");
  const statusKawinMap = await buildMap("ref_status_perkawinan","nama", "id");
  const dusunMap     = await buildMap("ref_dusun",             "nama", "id");

  // Aliases / normalization for pendidikan
  const PEND_ALIAS = {
    "smp/sederajat":       "SLTP/Sederajat",
    "sltp/sederajat":      "SLTP/Sederajat",
    "sma/sederajat":       "SLTA/Sederajat",
    "slta/sederajat":      "SLTA/Sederajat",
    "sma":                 "SLTA/Sederajat",
    "sd/sederajat":        "SD/Sederajat",
    "sd":                  "SD/Sederajat",
    "tidak/belum sekolah": "Tidak/Belum Sekolah",
    "tidak sekolah":       "Tidak/Belum Sekolah",
    "belum sekolah":       "Tidak/Belum Sekolah",
    "belum tamat sd":      "Belum Tamat SD",
    "diploma i/ii":        "Diploma I/II",
    "diploma iii":         "Diploma III",
    "diploma iv/s1":       "Diploma IV/S1",
    "s1":                  "Diploma IV/S1",
    "s2":                  "S2",
    "s3":                  "S3",
  };

  const STATUS_ALIAS = {
    "belum kawin": "Belum Kawin",
    "kawin":       "Kawin",
    "cerai hidup": "Cerai Hidup",
    "cerai mati":  "Cerai Mati",
  };

  function resolveId(map, val, alias = {}) {
    if (!val) return null;
    const key = norm(val);
    // direct match
    if (map.has(key)) return map.get(key);
    // alias match
    const aliasKey = alias[key];
    if (aliasKey && map.has(norm(aliasKey))) return map.get(norm(aliasKey));
    return null;
  }

  console.log(`  agama: ${agamaMap.size}, pendidikan: ${pendMap.size}, pekerjaan: ${pekMap.size}, status: ${statusKawinMap.size}, dusun: ${dusunMap.size}`);

  // ── Load ALL penduduk (paginated) ─────────────────────────────────────────
  console.log("\nLoading all penduduk...");
  let allPenduduk = [];
  let page = 0;
  const PAGE_SIZE = 1000;
  while (true) {
    const { data, error } = await sb.from("penduduk")
      .select("id,nik,agama,pendidikan,pekerjaan,status_kawin,dusun,hubungan_kk,keluarga_id")
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);
    if (error) { console.error("Load error:", error.message); break; }
    if (!data || data.length === 0) break;
    allPenduduk = allPenduduk.concat(data);
    if (data.length < PAGE_SIZE) break;
    page++;
  }
  console.log(`  Loaded: ${allPenduduk.length} penduduk`);

  // ── Patch 1: agama_id, pendidikan_id, pekerjaan_id, status_perkawinan_id, dusun_id ──
  console.log("\n─── Patch 1: ref FKs (agama, pendidikan, pekerjaan, status_kawin, dusun) ───");
  const refUpdates = [];
  let noMatch = { agama: 0, pend: 0, pek: 0, skaw: 0, dusun: 0 };

  for (const p of allPenduduk) {
    const agama_id             = resolveId(agamaMap, p.agama);
    const pendidikan_id        = resolveId(pendMap, p.pendidikan, PEND_ALIAS);
    const pekerjaan_id         = resolveId(pekMap, p.pekerjaan);
    const status_perkawinan_id = resolveId(statusKawinMap, p.status_kawin, STATUS_ALIAS);
    const dusun_id             = resolveId(dusunMap, p.dusun);

    if (!agama_id) noMatch.agama++;
    if (!pendidikan_id) noMatch.pend++;
    if (!pekerjaan_id) noMatch.pek++;
    if (!status_perkawinan_id) noMatch.skaw++;
    if (!dusun_id) noMatch.dusun++;

    refUpdates.push({
      id: p.id,
      nik: p.nik,
      agama_id:              agama_id ?? undefined,
      pendidikan_id:         pendidikan_id ?? undefined,
      pekerjaan_id:          pekerjaan_id ?? undefined,
      status_perkawinan_id:  status_perkawinan_id ?? undefined,
      dusun_id:              dusun_id ?? undefined,
    });
  }

  // Remove undefined values per row
  const cleanedRefUpdates = refUpdates.map(r => {
    const out = { id: r.id, nik: r.nik };
    if (r.agama_id !== undefined) out.agama_id = r.agama_id;
    if (r.pendidikan_id !== undefined) out.pendidikan_id = r.pendidikan_id;
    if (r.pekerjaan_id !== undefined) out.pekerjaan_id = r.pekerjaan_id;
    if (r.status_perkawinan_id !== undefined) out.status_perkawinan_id = r.status_perkawinan_id;
    // Omit dusun_id to prevent PostgREST schema cache rejection until migration is fully applied
    // if (r.dusun_id !== undefined) out.dusun_id = r.dusun_id;
    return out;
  });

  await batchUpdate("penduduk", cleanedRefUpdates, "ref FK patch");

  console.log("\n  No-match stats:");
  console.log(`    agama_id      unresolved: ${noMatch.agama}`);
  console.log(`    pendidikan_id unresolved: ${noMatch.pend}`);
  console.log(`    pekerjaan_id  unresolved: ${noMatch.pek}`);
  console.log(`    status_kaw_id unresolved: ${noMatch.skaw}`);
  console.log(`    dusun_id      unresolved: ${noMatch.dusun}`);

  // ── Patch 2: wilayah UUID — hardcode untuk semua warga Seruni Mumbul ──────
  console.log("\n─── Patch 2: Wilayah UUID (provinsi, kabupaten, kecamatan, desa) ───");
  const wilayahUpdates = allPenduduk.map(p => ({
    id:           p.id,
    nik:          p.nik,
    provinsi_id:  "133cd1be-28d4-41d4-abbb-0e84995e76af", // NTB
    kabupaten_id: "12b08ba5-ead7-4747-be7e-653d49e6e3b5", // Lombok Timur
    kecamatan_id: "4c70cd4c-c14b-41e3-96d3-a4290169999a", // Pringgabaya
    desa_id:      "be4dda9d-334b-43e2-89a3-50c724ced517", // Seruni Mumbul
  }));
  await batchUpdate("penduduk", wilayahUpdates, "wilayah UUID patch");

  // ── Patch 3: keluarga.kepala_penduduk_id ─────────────────────────────────
  console.log("\n─── Patch 3: keluarga.kepala_penduduk_id ───");
  // Omitted because column 'kepala_penduduk_id' might not exist in schema cache yet
  console.log("  (Skipped until schema cache is reloaded/migration is applied)");
  /*
  // Find penduduk with hubungan_kk = Kepala Keluarga
  const kepalaList = allPenduduk.filter(p =>
    p.hubungan_kk && ["kepala keluarga", "kk"].includes(norm(p.hubungan_kk)) && p.keluarga_id
  );
  console.log(`  Kepala keluarga ditemukan: ${kepalaList.length}`);

  const kkUpdates = kepalaList.map(p => ({
    id: p.keluarga_id,
    kepala_penduduk_id: p.id,
  }));

  if (kkUpdates.length > 0) {
    // Filter nulls
    const validKkUpdates = kkUpdates.filter(u => u.id);
    await batchUpdate("keluarga", validKkUpdates, "keluarga.kepala_penduduk_id");
  }
  */

  // ── Final stats ───────────────────────────────────────────────────────────
  console.log("\n═".repeat(60));
  const { count: noAgama }    = await sb.from("penduduk").select("*", { count: "exact", head: true }).is("agama_id", null);
  const { count: noPend }     = await sb.from("penduduk").select("*", { count: "exact", head: true }).is("pendidikan_id", null);
  const { count: noKK }       = await sb.from("penduduk").select("*", { count: "exact", head: true }).is("keluarga_id", null);
  const { count: noDusunId }  = await sb.from("penduduk").select("*", { count: "exact", head: true }).is("dusun_id", null);
  const { count: totalP }     = await sb.from("penduduk").select("*", { count: "exact", head: true });
  console.log(`  Total penduduk : ${totalP}`);
  console.log(`  Tanpa agama_id : ${noAgama} (${Math.round(noAgama/totalP*100)}%)`);
  console.log(`  Tanpa pend_id  : ${noPend} (${Math.round(noPend/totalP*100)}%)`);
  console.log(`  Tanpa KK link  : ${noKK} (${Math.round(noKK/totalP*100)}%)`);
  console.log(`  Tanpa dusun_id : ${noDusunId} (${Math.round(noDusunId/totalP*100)}%)`);
  console.log("═".repeat(60));
  console.log("  Patch selesai! Jalankan verify-penduduk-integrity.mjs untuk verifikasi.");
  console.log("═".repeat(60));
}

main().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
