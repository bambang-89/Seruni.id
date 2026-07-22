/**
 * Generate single combined SQL file for import
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

function main() {
  console.log("Generating combined SQL import file...\n");

  const csvPath = path.join(__dirname, "../docs/penduduk.csv");
  const outputPath = path.join(__dirname, "../docs/import_penduduk_full.sql");

  const content = fs.readFileSync(csvPath, "utf-8");
  const lines = content.split("\n").slice(1).filter(Boolean);
  console.log(`Total rows in CSV: ${lines.length}`);

  const rows = lines.map(parseRow).filter(Boolean) as any[];
  console.log(`Rows parsed: ${rows.length}`);

  const uniqueKK = new Set(rows.map(r => r.no_kk));
  console.log(`Unique KK: ${uniqueKK.size}\n`);

  // Generate keluarga values
  const keluargaMap = new Map<string, any>();
  for (const row of rows) {
    if (!keluargaMap.has(row.no_kk)) {
      keluargaMap.set(row.no_kk, row);
    }
  }

  const keluargaValues = Array.from(keluargaMap.values()).map(kk => {
    return `(${escapeSQL(kk.no_kk)}, ${escapeSQL(kk.nama)}, ${escapeSQL(kk.alamat)}, ${escapeSQL(kk.dusun)}, ${escapeSQL(kk.rt)}, NULL)`;
  }).join(",\n  ");

  // Generate penduduk values
  const pendudukValues = rows.map(row => {
    const bpjsK = row.bpjs_kesehatan === "true" ? "true" : row.bpjs_kesehatan === "false" ? "false" : "NULL";
    const bpjsTk = row.bpjs_ketenagakerjaan === "true" ? "true" : row.bpjs_ketenagakerjaan === "false" ? "false" : "NULL";
    const bans = row.bansos === "true" ? "true" : row.bansos === "false" ? "false" : "NULL";
    const tgl = row.tanggal_lahir ? `DATE '${row.tanggal_lahir}'` : "NULL";

    return `(${escapeSQL(row.nik)}, ${escapeSQL(row.nama)}, ${escapeSQL(row.jenis_kelamin)}, ${escapeSQL(row.tempat_lahir)}, ${tgl}, ${escapeSQL(row.agama)}, ${escapeSQL(row.pendidikan)}, ${escapeSQL(row.pekerjaan)}, ${escapeSQL(row.status_perkawinan)}, ${escapeSQL(row.hubungan_kk)}, ${escapeSQL(row.no_kk)}, ${escapeSQL(row.dusun)}, ${escapeSQL(row.alamat)}, 'Indonesia', ${escapeSQL(row.nama_ibu)}, ${escapeSQL(row.nama_bapak)}, ${escapeSQL(row.gol_darah)}, ${bpjsK}, ${bpjsTk}, ${bans}, ${escapeSQL(row.kondisi_fisik)})`;
  }).join(",\n  ");

  // Build final SQL
  const sql = `-- ============================================
-- IMPORT PENDUDUK - DESA SERUNI MUMBUL
-- Generated: ${new Date().toISOString()}
-- Total: ${rows.length} penduduk, ${keluargaMap.size} keluarga
-- ============================================

-- Disable triggers for faster import
ALTER TABLE public.keluarga DISABLE TRIGGER ALL;
ALTER TABLE public.penduduk DISABLE TRIGGER ALL;

-- ============================================
-- INSERT KELUARGA
-- ============================================
INSERT INTO public.keluarga (no_kk, kepala_nama, alamat, dusun, rt, rw, created_at, updated_at)
VALUES
  ${keluargaValues}
ON CONFLICT (no_kk) DO NOTHING;

-- ============================================
-- INSERT PENDUDUK
-- ============================================
INSERT INTO public.penduduk (
  nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
  agama, pendidikan, pekerjaan, status_perkawinan, hubungan_kk,
  keluarga_id, dusun, alamat, kewarganegaraan,
  nama_ibu, nama_bapak, gol_darah,
  bpjs_kesehatan, bpjs_ketenagakerjaan, bansos, kondisi_fisik,
  status_hidup, created_at, updated_at
)
SELECT
  v.nik, v.nama, v.jk, v.tl, v.tgl,
  v.agama, v.pend, v.pek, v.skaw, v.hub,
  k.id, v.dusun, v.alamat, v.kwn,
  v.ibu, v.bapak, v.gol,
  v.bpjs_k, v.bpjs_tk, v.bansos, v.kondisi,
  'hidup', NOW(), NOW()
FROM (VALUES
  ${pendudukValues}
) AS v(
  nik, nama, jk, tl, tgl,
  agama, pend, pek, skaw, hub,
  no_kk, dusun, alamat, kwn,
  ibu, bapak, gol,
  bpjs_k, bpjs_tk, bansos, kondisi
)
LEFT JOIN public.keluarga k ON k.no_kk = v.no_kk
WHERE v.nik NOT IN (SELECT nik FROM public.penduduk WHERE nik IS NOT NULL);

-- Re-enable triggers
ALTER TABLE public.keluarga ENABLE TRIGGER ALL;
ALTER TABLE public.penduduk ENABLE TRIGGER ALL;

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
  (SELECT COUNT(*) FROM public.keluarga) AS total_keluarga,
  (SELECT COUNT(*) FROM public.penduduk) AS total_penduduk,
  (SELECT COUNT(*) FROM public.penduduk WHERE status_hidup = 'hidup') AS hidup,
  (SELECT COUNT(*) FROM public.penduduk WHERE status_hidup = 'hidup' AND jenis_kelamin = 'L') AS laki_laki,
  (SELECT COUNT(*) FROM public.penduduk WHERE status_hidup = 'hidup' AND jenis_kelamin = 'P') AS perempuan;
`;

  fs.writeFileSync(outputPath, sql, "utf-8");

  const sizeMB = (sql.length / 1024 / 1024).toFixed(2);
  console.log(`SQL file generated: ${outputPath}`);
  console.log(`File size: ${sizeMB} MB`);
  console.log("\nNext steps:");
  console.log("1. Open Supabase Dashboard");
  console.log("2. Go to SQL Editor");
  console.log("3. Copy-paste entire contents of docs/import_penduduk_full.sql");
  console.log("4. Click RUN");
}

main();
