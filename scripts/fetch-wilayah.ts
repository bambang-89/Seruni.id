/**
 * fetch-wilayah.ts
 * Fetch wilayah data from KEMENDAGRI Indonesia (via emsifa/api-wilayah-indonesia CSV)
 * and seed ref tables.
 *
 * CSV Source: https://github.com/emsifa/api-wilayah-indonesia/tree/master/data
 * Format: code,name or code,parent_code,name
 *
 * Usage:
 *   npx tsx scripts/fetch-wilayah.ts        # Lombok Timur only (default)
 *   npx tsx scripts/fetch-wilayah.ts --full # All Indonesia
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { join } from 'path';

// Load .env manually
const envFile = readFileSync(join(process.cwd(), '.env'), 'utf-8');
for (const line of envFile.split('\n')) {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith('#')) continue;
  const eqIdx = trimmed.indexOf('=');
  if (eqIdx < 0) continue;
  const key = trimmed.slice(0, eqIdx).trim();
  const val = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, '');
  if (!process.env[key]) process.env[key] = val;
}

const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env");
}

const supabase = createClient(supabaseUrl, supabaseKey);

const BASE = "https://raw.githubusercontent.com/emsifa/api-wilayah-indonesia/master/data";

async function fetchCsv<T>(url: string): Promise<string[]> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${url}`);
  return (await res.text()).trim().split('\n');
}

function parseCSVLine(line: string): string[] {
  return line.split(',').map(s => s.trim());
}

async function main() {
  console.log("Fetching wilayah data from GitHub...\n");

  const FULL_INDONESIA = process.argv.includes("--full");

  // Fetch all CSV (fetch all, filter later — faster than individual requests per region)
  console.log("Downloading CSV files...");
  const [provinceLines, regencyLines, districtLines, villageLines] = await Promise.all([
    fetchCsv(`${BASE}/provinces.csv`),
    fetchCsv(`${BASE}/regencies.csv`),
    fetchCsv(`${BASE}/districts.csv`),
    fetchCsv(`${BASE}/villages.csv`),
  ]);

  // Parse provinces
  const provinces = provinceLines.map(l => {
    const [code, name] = parseCSVLine(l);
    return { code, name };
  });

  // Parse regencies
  const regencies = regencyLines.map(l => {
    const [code, provCode, name] = parseCSVLine(l);
    return { code, provCode, name };
  });

  // Parse districts
  const districts = districtLines.map(l => {
    const [code, regCode, name] = parseCSVLine(l);
    return { code, regCode, name };
  });

  // Parse villages
  const villages = villageLines.map(l => {
    const [code, distCode, name] = parseCSVLine(l);
    return { code, distCode, name };
  });

  console.log(`  Provinces: ${provinces.length}`);
  console.log(`  Regencies: ${regencies.length}`);
  console.log(`  Districts: ${districts.length}`);
  console.log(`  Villages: ${villages.length}`);

  // Filter Lombok Timur (regency 5203)
  const lombokDistrictCodes = new Set(
    districts.filter(d => d.regCode === "5203").map(d => d.code)
  );

  const lombokVillages = villages.filter(v => lombokDistrictCodes.has(v.distCode));

  console.log(`\nLombok Timur (5203):`);
  console.log(`  Regencies: 1 (Lombok Timur)`);
  console.log(`  Districts: ${lombokDistrictCodes.size}`);
  console.log(`  Villages: ${lombokVillages.length}`);

  const targetProvinces = FULL_INDONESIA ? provinces : provinces.filter(p => p.code === "52");
  const targetRegencies = FULL_INDONESIA ? regencies : regencies.filter(r => r.code === "5203");
  const targetDistricts = FULL_INDONESIA ? districts : districts.filter(d => d.regCode === "5203");
  const targetVillages = FULL_INDONESIA ? villages : lombokVillages;

  console.log(`\nSeeding ${targetProvinces.length} provinces, ${targetRegencies.length} regencies, ${targetDistricts.length} districts, ${targetVillages.length} villages...`);

  // Provinces
  let seeded = 0;
  for (const p of targetProvinces) {
    const { error } = await supabase.from("ref_provinsi").upsert({
      kode: p.code,
      nama: p.name,
      aktif: true,
    }, { onConflict: "kode" });
    if (!error) seeded++;
  }
  console.log(`  Provinces: ${seeded} upserted`);

  // Regencies
  seeded = 0;
  for (const r of targetRegencies) {
    const jenis = r.name.toLowerCase().includes("kota") ? "Kota" : "Kabupaten";
    const { error } = await supabase.from("ref_kabupaten").upsert({
      kode: r.code,
      kode_provinsi: r.provCode,
      nama: r.name,
      jenis,
      aktif: true,
    }, { onConflict: "kode" });
    if (!error) seeded++;
  }
  console.log(`  Regencies: ${seeded} upserted`);

  // Districts
  seeded = 0;
  for (const d of targetDistricts) {
    const { error } = await supabase.from("ref_kecamatan").upsert({
      kode: d.code,
      kode_kabupaten: d.regCode,
      nama: d.name,
      aktif: true,
    }, { onConflict: "kode" });
    if (error) console.error(`  District error [${d.code}]: ${error.message}`);
    else seeded++;
  }
  console.log(`  Districts: ${seeded} upserted`);

  // Villages — kode 10 digit, kode_kecamatan 7 digit (both fit in VARCHAR(10) after migration)
  seeded = 0;
  for (const v of targetVillages) {
    const name = v.name.replace(/^(Desa|Kelurahan)\s+/i, "");
    const jenis = v.name.toLowerCase().startsWith("kelurahan") ? "Kelurahan" : "Desa";
    const { error } = await supabase.from("ref_desa").upsert({
      kode: v.code,
      kode_kecamatan: v.distCode,
      nama: name,
      jenis,
      aktif: true,
    }, { onConflict: "kode" });
    if (error) console.error(`  Village error [${v.code}]: ${error.message}`);
    else seeded++;
  }
  console.log(`  Villages: ${seeded} upserted`);

  console.log("\nDone! Wilayah data synced from KEMENDAGRI API.");
  if (!FULL_INDONESIA) {
    console.log("Run with --full to sync all of Indonesia.");
  }
}

main().catch(console.error);
