/**
 * Generate SQL files dalam batch untuk import ke Supabase
 * Run: npx tsx scripts/generate-import-sql-batch.ts
 */

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const JENIS_KELAMIN_MAP: Record<string, string> = {
  "Laki-Laki": "L",
  "Perempuan": "P",
};

const HUBUNGAN_KK_MAP: Record<string, string> = {
  "Kepala Keluarga": "Kepala Keluarga",
  "Istri": "Istri/Suami",
  "Suami": "Istri/Suami",
  "Anak": "Anak",
  "Famili Lain": "Famili Lain",
  "Mertua": "Mertua",
  "Lainnya": "Lainnya",
};

const DUSUN_MAP: Record<string, string> = {
  Dames: "Dames",
  Mandar: "Mandar",
  Sasak: "Sasak",
  "Brangtapen Asri": "Brangtapen Asri",
};

function normalizeDate(dateStr: string): string | null {
  if (!dateStr || dateStr === "-") return null;
  const parts = dateStr.split("/");
  if (parts.length === 3) {
    return `${parts[2]}-${parts[1].padStart(2, "0")}-${parts[0].padStart(2, "0")}`;
  }
  return null;
}

function normalizeNik(nik: string): string | null {
  if (!nik || nik === "-") return null;
  return nik.replace(/O{3}/g, "000");
}

function normalize(val: string): string | null {
  return val && val.trim() !== "-" ? val.trim() : null;
}

function toBoolean(val: string): string | null {
  if (val === "Ya") return "true";
  if (val === "Tidak") return "false";
  return null;
}

function escapeSQL(val: string | null): string {
  if (val === null || val === undefined) return "NULL";
  const escaped = val.replace(/'/g, "''");
  return `'${escaped}'`;
}

function parseRow(line: string): any | null {
  const c = line.split(",").map((x: string) => x.trim());
  if (c.length < 15) return null;

  const no_kk = normalizeNik(c[9]);
  const nik = normalizeNik(c[10]);
  if (!no_kk || !nik) return null;

  const dusunRaw = c[4] || "";
  const dusun = DUSUN_MAP[dusunRaw] || dusunRaw;

  return {
    nik,
    nama: c[6],
    jenis_kelamin: JENIS_KELAMIN_MAP[c[7]] || c[7],
    hubungan_kk: HUBUNGAN_KK_MAP[c[8]] || c[8],
    no_kk,
    status_perkawinan: c[11] || "",
    tempat_lahir: normalize(c[12]) || "",
    tanggal_lahir: normalizeDate(c[13]) || "",
    pendidikan: normalize(c[14]) || "",
    pekerjaan: normalize(c[15]) || "",
    dusun,
    rt: normalize(c[5]) || "",
    agama: normalize(c[18]) || "",
    kewarganegaraan: normalize(c[17]) || "Indonesia",
    nama_ibu: normalize(c[37]) || "",
    nama_bapak: normalize(c[38]) || "",
    gol_darah: normalize(c[39]) || "",
    bpjs_kesehatan: toBoolean(c[32]),
    bpjs_ketenagakerjaan: toBoolean(c[33]),
    bansos: toBoolean(c[31]),
    kondisi_fisik: normalize(c[36]),
    alamat: `${dusun} RT ${c[5] || ""}`,
  };
}

function generateKKSQL(rows: any[]): string {
  const uniqueKK = new Map<string, any>();
  for (const row of rows) {
    if (!uniqueKK.has(row.no_kk)) {
      uniqueKK.set(row.no_kk, row);
    }
  }

  const values = Array.from(uniqueKK.values()).map(kk => {
    return `${escapeSQL(kk.no_kk)} AS no_kk, ${escapeSQL(kk.nama)} AS kepala_nama, ${escapeSQL(kk.alamat)} AS alamat, ${escapeSQL(kk.dusun)} AS dusun, ${escapeSQL(kk.rt)} AS rt, NULL::text AS rw, NULL::text AS catatan`;
  }).join("\n  UNION ALL\n  SELECT ");

  return `-- ============================================
-- KELUARGA (actual schema with tenant_id NOT NULL)
-- ============================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  INSERT INTO public.keluarga (tenant_id, no_kk, kepala_nama, alamat, dusun, rt, rw, catatan)
  SELECT v_tenant_id, t.no_kk, t.kepala_nama, t.alamat, t.dusun, t.rt, t.rw, t.catatan FROM (
    SELECT ${values}
  ) AS t(no_kk, kepala_nama, alamat, dusun, rt, rw, catatan)
  ON CONFLICT (no_kk) DO NOTHING;
END $$;
`;
}

function generatePendudukSQL(rows: any[]): string {
  const values = rows.map(row => {
    const tgllahir = row.tanggal_lahir ? `'${row.tanggal_lahir}'::date` : 'NULL::date';
    return `${escapeSQL(row.nik)} AS nik,
  ${escapeSQL(row.nama)} AS nama,
  ${escapeSQL(row.jenis_kelamin)} AS jenis_kelamin,
  ${escapeSQL(row.tempat_lahir)} AS tempat_lahir,
  ${tgllahir} AS tanggal_lahir,
  ${escapeSQL(row.agama)} AS agama,
  ${escapeSQL(row.pendidikan)} AS pendidikan,
  ${escapeSQL(row.pekerjaan)} AS pekerjaan,
  ${escapeSQL(row.status_perkawinan)} AS status_kawin,
  ${escapeSQL(row.hubungan_kk)} AS hubungan_kk,
  ${escapeSQL(row.no_kk)} AS no_kk_ref,
  ${escapeSQL(row.dusun)} AS dusun,
  ${escapeSQL(row.alamat)} AS alamat`;
  }).join("\n  UNION ALL\n  SELECT ");

  return `-- ============================================
-- PENDUDUK (all 32 columns match actual schema)
-- ============================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  INSERT INTO public.penduduk (
    tenant_id, nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
    agama, pendidikan, pekerjaan, status_kawin, hubungan_kk,
    keluarga_id, dusun, alamat,
    foto_url, status_hidup, catatan,
    created_at, updated_at,
    bpjs_status, bpjs_nomor,
    rt, rw, nomor_hp,
    created_by, updated_by,
    agama_id, pendidikan_id, pekerjaan_id,
    status_perkawinan_id, warga_negara_id,
    gol_darah_id, dusun_id, rt_id, rw_id
  )
  SELECT
    v_tenant_id,
    nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
    agama, pendidikan, pekerjaan, status_kawin, hubungan_kk,
    (SELECT id FROM public.keluarga WHERE no_kk = no_kk_ref LIMIT 1),
    dusun, alamat,
    NULL, 'hidup', NULL,
    NOW(), NOW(),
    NULL, NULL,
    rt, NULL, NULL,
    NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL, NULL, NULL
  FROM (
    SELECT ${values}
  ) AS t(
    nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
    agama, pendidikan, pekerjaan, status_kawin, hubungan_kk,
    no_kk_ref, dusun, alamat
  )
  WHERE nik NOT IN (SELECT nik FROM public.penduduk WHERE nik IS NOT NULL);
END $$;
`;
}

function main() {
  console.log("Generating batch SQL import files...\n");

  const csvPath = path.join(__dirname, "../docs/penduduk.csv");
  const outputDir = path.join(__dirname, "../docs/sql_import");

  // Create output directory
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const content = fs.readFileSync(csvPath, "utf-8");
  const lines = content.split("\n").slice(1).filter(Boolean);
  console.log(`Total rows in CSV: ${lines.length}`);

  const rows = lines.map(parseRow).filter(Boolean) as any[];
  console.log(`Rows parsed: ${rows.length}`);

  const uniqueKK = new Set(rows.map(r => r.no_kk));
  console.log(`Unique KK: ${uniqueKK.size}\n`);

  // Generate keluarga SQL (all in one file)
  const keluargaSQL = generateKKSQL(rows);
  fs.writeFileSync(path.join(outputDir, "01_keluarga.sql"), keluargaSQL, "utf-8");
  console.log(`Generated: 01_keluarga.sql`);

  // Generate penduduk SQL in batches
  const batchSize = 500;
  let batchNum = 1;

  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    const startRow = i + 1;
    const endRow = Math.min(i + batchSize, rows.length);

    const sql = generatePendudukSQL(batch);
    const filename = `02_penduduk_${String(batchNum).padStart(3, "0")}.sql`;
    fs.writeFileSync(path.join(outputDir, filename), sql, "utf-8");

    const sizeKB = (sql.length / 1024).toFixed(1);
    console.log(`Generated: ${filename} (${startRow}-${endRow}, ${sizeKB} KB)`);
    batchNum++;
  }

  // Generate verification SQL
  const verifySQL = `-- ============================================
-- VERIFICATION QUERIES
-- Run this after all imports are complete
-- ============================================

-- Check totals
SELECT
  'Keluarga' AS tabel,
  COUNT(*) AS jumlah
FROM public.keluarga
UNION ALL
SELECT
  'Penduduk Total' AS tabel,
  COUNT(*) AS jumlah
FROM public.penduduk
UNION ALL
SELECT
  'Penduduk Hidup' AS tabel,
  COUNT(*) AS jumlah
FROM public.penduduk WHERE status_hidup = 'hidup';

-- Check by dusun
SELECT dusun, COUNT(*) AS jumlah
FROM public.penduduk
WHERE status_hidup = 'hidup' AND dusun IS NOT NULL
GROUP BY dusun
ORDER BY dusun;

-- Check by jenis_kelamin
SELECT jenis_kelamin, COUNT(*) AS jumlah
FROM public.penduduk
WHERE status_hidup = 'hidup'
GROUP BY jenis_kelamin;
`;

  fs.writeFileSync(path.join(outputDir, "99_verify.sql"), verifySQL, "utf-8");
  console.log(`Generated: 99_verify.sql`);

  console.log(`\nAll files generated in: ${outputDir}`);
  console.log("\nNext steps:");
  console.log("1. Go to Supabase Dashboard: https://supabase.com/dashboard");
  console.log("2. Open SQL Editor");
  console.log("3. Run files in order:");
  console.log("   - 01_keluarga.sql (first!)");
  console.log("   - 02_penduduk_001.sql, 02_penduduk_002.sql, ...");
  console.log("   - 99_verify.sql (last)");
}

main();
