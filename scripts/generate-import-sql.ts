/**
 * Generate SQL file untuk import penduduk.csv ke Supabase
 * Run: npx tsx scripts/generate-import-sql.ts
 * Then copy the SQL to Supabase Dashboard SQL Editor
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
  return "NULL";
}

function escapeSQL(val: string | null): string {
  if (val === null || val === undefined) return "NULL";
  // Escape single quotes
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

function generateKKInsert(rows: any[]): string {
  // Deduplicate by no_kk
  const uniqueKK = new Map<string, any>();
  for (const row of rows) {
    if (!uniqueKK.has(row.no_kk)) {
      uniqueKK.set(row.no_kk, row);
    }
  }

  const statements: string[] = [];
  statements.push("-- ============================================");
  statements.push("-- INSERT KELUARGA");
  statements.push("-- ============================================\n");

  statements.push("DO $$");
  statements.push("BEGIN");
  statements.push("  -- Insert KK (ignore if exists)");

  for (const kk of uniqueKK.values()) {
    const stmt = `  INSERT INTO public.keluarga (no_kk, kepala_nama, alamat, dusun, rt, rw, created_at, updated_at)
  SELECT ${escapeSQL(kk.no_kk)}, ${escapeSQL(kk.nama)}, ${escapeSQL(kk.alamat)}, ${escapeSQL(kk.dusun)}, ${escapeSQL(kk.rt)}, NULL, NOW(), NOW()
  ON CONFLICT (no_kk) DO NOTHING;`;
    statements.push(stmt);
  }

  statements.push("END $$;");
  statements.push("");

  return statements.join("\n");
}

function generatePendudukInsert(rows: any[]): string {
  const statements: string[] = [];
  statements.push("-- ============================================");
  statements.push("-- INSERT PENDUDUK");
  statements.push("-- ============================================\n");

  statements.push("DO $$");
  statements.push("BEGIN");
  statements.push("  -- Insert penduduk (ignore if exists)");

  // Process in batches of 100 for better performance
  const batchSize = 100;
  let batchCount = 0;

  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    batchCount++;

    const values = batch.map(row => {
      const keluargaIdSubquery = `(SELECT id FROM public.keluarga WHERE no_kk = ${escapeSQL(row.no_kk)} LIMIT 1)`;
      return `(
        ${escapeSQL(row.nik)},
        ${escapeSQL(row.nama)},
        ${escapeSQL(row.jenis_kelamin)},
        ${escapeSQL(row.tempat_lahir)},
        ${row.tanggal_lahir ? escapeSQL(row.tanggal_lahir) : "NULL::date"},
        ${escapeSQL(row.agama)},
        ${escapeSQL(row.pendidikan)},
        ${escapeSQL(row.pekerjaan)},
        ${escapeSQL(row.status_perkawinan)},
        ${escapeSQL(row.hubungan_kk)},
        ${keluargaIdSubquery},
        ${escapeSQL(row.dusun)},
        ${escapeSQL(row.alamat)},
        NULL,
        'hidup',
        NULL,
        NOW(),
        NOW(),
        ${escapeSQL(row.kewarganegaraan)},
        ${escapeSQL(row.nama_ibu)},
        ${escapeSQL(row.nama_bapak)},
        ${escapeSQL(row.gol_darah)},
        ${row.bpjs_kesehatan === "true" ? "true" : row.bpjs_kesehatan === "false" ? "false" : "NULL"},
        ${row.bpjs_ketenagakerjaan === "true" ? "true" : row.bpjs_ketenagakerjaan === "false" ? "false" : "NULL"},
        ${row.bansos === "true" ? "true" : row.bansos === "false" ? "false" : "NULL"},
        ${escapeSQL(row.kondisi_fisik)}
      )`;
    }).join(",\n      ");

    statements.push(`
  -- Batch ${batchCount} (${i + 1} - ${Math.min(i + batchSize, rows.length)})
  INSERT INTO public.penduduk (
    nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
    agama, pendidikan, pekerjaan, status_perkawinan, hubungan_kk,
    keluarga_id, dusun, alamat, foto_url, status_hidup, catatan,
    created_at, updated_at, kewarganegaraan, nama_ibu, nama_bapak,
    gol_darah, bpjs_kesehatan, bpjs_ketenagakerjaan, bansos, kondisi_fisik
  )
  SELECT * FROM (VALUES
      ${values}
  ) AS t(nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
         agama, pendidikan, pekerjaan, status_perkawinan, hubungan_kk,
         keluarga_id, dusun, alamat, foto_url, status_hidup, catatan,
         created_at, updated_at, kewarganegaraan, nama_ibu, nama_bapak,
         gol_darah, bpjs_kesehatan, bpjs_ketenagakerjaan, bansos, kondisi_fisik)
  WHERE nik NOT IN (SELECT nik FROM public.penduduk WHERE nik IS NOT NULL);`);
  }

  statements.push("END $$;");

  return statements.join("\n");
}

function main() {
  console.log("Generating SQL import file...\n");

  const csvPath = path.join(__dirname, "../docs/penduduk.csv");
  const outputPath = path.join(__dirname, "../docs/import_penduduk.sql");

  const content = fs.readFileSync(csvPath, "utf-8");
  const lines = content.split("\n").slice(1).filter(Boolean);
  console.log(`Total rows in CSV: ${lines.length}`);

  const rows = lines.map(parseRow).filter(Boolean) as any[];
  console.log(`Rows parsed: ${rows.length}`);

  const uniqueKK = new Set(rows.map(r => r.no_kk));
  console.log(`Unique KK: ${uniqueKK.size}\n`);

  // Generate SQL
  const header = `-- ============================================
-- IMPORT PENDUDUK SQL
-- Generated: ${new Date().toISOString()}
-- Total records: ${rows.length} penduduk, ${uniqueKK.size} keluarga
-- ============================================

-- Disable triggers temporarily for faster import
ALTER TABLE public.keluarga DISABLE TRIGGER ALL;
ALTER TABLE public.penduduk DISABLE TRIGGER ALL;
`;

  const footer = `
-- Re-enable triggers
ALTER TABLE public.keluarga ENABLE TRIGGER ALL;
ALTER TABLE public.penduduk ENABLE TRIGGER ALL;

-- Verify import
SELECT
  (SELECT COUNT(*) FROM public.keluarga) AS total_keluarga,
  (SELECT COUNT(*) FROM public.penduduk) AS total_penduduk,
  (SELECT COUNT(*) FROM public.penduduk WHERE status_hidup = 'hidup') AS penduduk_hidup,
  (SELECT COUNT(*) FROM public.penduduk WHERE jenis_kelamin = 'L') AS laki_laki,
  (SELECT COUNT(*) FROM public.penduduk WHERE jenis_kelamin = 'P') AS perempuan;
`;

  const sql = header + generateKKInsert(rows) + "\n" + generatePendudukInsert(rows) + footer;

  fs.writeFileSync(outputPath, sql, "utf-8");

  console.log(`SQL file generated: ${outputPath}`);
  console.log(`File size: ${(sql.length / 1024 / 1024).toFixed(2)} MB`);
  console.log("\nNext steps:");
  console.log("1. Open Supabase Dashboard: https://supabase.com/dashboard");
  console.log("2. Go to SQL Editor");
  console.log("3. Copy-paste contents of docs/import_penduduk.sql");
  console.log("4. Run the SQL");
}

main();
