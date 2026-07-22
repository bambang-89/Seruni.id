/**
 * Script Impor penduduk.csv ke Supabase
 * Usage: npx ts-node scripts/import-penduduk.ts
 */

import { createClient } from "@supabase/supabase-js";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { realtime: { enabled: false } }
);

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

function toBoolean(val: string): boolean | null {
  if (val === "Ya") return true;
  if (val === "Tidak") return false;
  return null;
}

interface Row {
  nik: string;
  nama: string;
  jenis_kelamin: string;
  hubungan_kk: string;
  no_kk: string;
  status_kawin: string;
  tempat_lahir: string;
  tanggal_lahir: string;
  pendidikan: string;
  pekerjaan: string;
  dusun: string;
  rt: string;
  agama: string;
  alamat: string;
}

function parseRow(line: string): Row | null {
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
    status_kawin: c[11] || "",
    tempat_lahir: normalize(c[12]) || "",
    tanggal_lahir: normalizeDate(c[13]) || "",
    pendidikan: normalize(c[14]) || "",
    pekerjaan: normalize(c[15]) || "",
    dusun,
    rt: normalize(c[5]) || "",
    agama: normalize(c[18]) || "",
    alamat: `${dusun} RT ${c[5] || ""}`,
  };
}

async function importPenduduk() {
  console.log("Starting import penduduk.csv...\n");

  const csvPath = path.join(__dirname, "../docs/penduduk.csv");
  const content = fs.readFileSync(csvPath, "utf-8");
  const lines = content.split("\n").slice(1).filter(Boolean);
  console.log(`Total rows in CSV: ${lines.length}`);

  const rows = lines.map(parseRow).filter(Boolean) as Row[];
  console.log(`Rows parsed: ${rows.length}`);
  console.log(`Rows skipped (invalid NIK/KK): ${lines.length - rows.length}`);

  // Deduplicate keluarga
  const keluargaMap = new Map<string, Row>();
  for (const row of rows) {
    if (!keluargaMap.has(row.no_kk)) {
      keluargaMap.set(row.no_kk, row);
    }
  }
  const keluargaList = Array.from(keluargaMap.values());
  console.log(`Unique KK: ${keluargaList.length}\n`);

  // Insert keluarga
  console.log("Step 1: Inserting keluarga...");
  let kInserted = 0, kSkipped = 0, kErrors = 0;
  for (const kk of keluargaList) {
    try {
      const { data: ex } = await supabase.from("keluarga").select("id").eq("no_kk", kk.no_kk).single();
      if (ex) { kSkipped++; continue; }

      const { error } = await supabase.from("keluarga").insert({
        no_kk: kk.no_kk,
        kepala_nama: kk.nama || null,
        alamat: kk.alamat || null,
        dusun: kk.dusun || null,
        rt: kk.rt || null,
        rw: null,
      });

      if (error) { console.error(`KK error ${kk.no_kk}: ${error.message}`); kErrors++; }
      else { kInserted++; }
    } catch (e: any) { console.error(`KK exception: ${e.message}`); kErrors++; }
  }
  console.log(`Keluarga: ${kInserted} inserted, ${kSkipped} skipped, ${kErrors} errors\n`);

  // Build KK lookup
  const { data: allKK } = await supabase.from("keluarga").select("id, no_kk");
  const kkIdMap = new Map<string, string>();
  for (const kk of allKK || []) { kkIdMap.set(kk.no_kk, kk.id); }
  console.log(`KK in DB: ${kkIdMap.size}\n`);

  // Insert penduduk
  console.log("Step 2: Inserting penduduk...");
  let pInserted = 0, pSkipped = 0, pErrors = 0, pNikInvalid = 0;

  for (const row of rows) {
    if (!row.nik || row.nik.length !== 16) { pNikInvalid++; continue; }
    try {
      const { data: ex } = await supabase.from("penduduk").select("id").eq("nik", row.nik).single();
      if (ex) { pSkipped++; continue; }

      const keluarga_id = kkIdMap.get(row.no_kk) || null;

      const { error } = await supabase.from("penduduk").insert({
        nik: row.nik,
        nama: row.nama,
        jenis_kelamin: row.jenis_kelamin,
        hubungan_kk: row.hubungan_kk,
        keluarga_id,
        status_kawin: row.status_kawin || null,
        tempat_lahir: row.tempat_lahir || null,
        tanggal_lahir: row.tanggal_lahir || null,
        pendidikan: row.pendidikan || null,
        pekerjaan: row.pekerjaan || null,
        dusun: row.dusun || null,
        rt: row.rt || null,
        agama: row.agama || null,
        alamat: row.alamat || null,
        status_hidup: "hidup",
      });

      if (error) { console.error(`Penduduk error ${row.nik}: ${error.message}`); pErrors++; }
      else { pInserted++; }
    } catch (e: any) { console.error(`Penduduk exception: ${e.message}`); pErrors++; }
  }
  console.log(`Penduduk: ${pInserted} inserted, ${pSkipped} skipped, ${pErrors} errors, ${pNikInvalid} NIK invalid\n`);

  console.log("=".repeat(50));
  console.log("DONE");
  console.log("=".repeat(50));
}

importPenduduk().catch(console.error);
