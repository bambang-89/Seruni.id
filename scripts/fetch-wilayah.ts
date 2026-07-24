/**
 * fetch-wilayah.ts
 * Fetch wilayah data from KEMENDAGRI Indonesia API and seed ref tables.
 *
 * API Source: https://emsifa.github.io/api-wilayah-indonesia/
 * Mirror of KEMENDAGRI official wilayah data.
 *
 * Usage:
 *   npx tsx scripts/fetch-wilayah.ts
 *
 * Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY in .env
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const API = "https://www.emsifa.github.io/api-wilayah-indonesia";

async function fetchJson<T>(url: string): Promise<T[]> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${url}`);
  return res.json() as Promise<T[]>;
}

interface Province { id: string; name: string; }
interface Regency { id: string; province_id: string; name: string; }
interface District { id: string; regency_id: string; name: string; }
interface Village { id: string; district_id: string; name: string; code: string; }

async function main() {
  console.log("Fetching wilayah data from API...");

  const [provinces, regencies, districts, villages] = await Promise.all([
    fetchJson<Province>(`${API}/static/api/provinces.json`),
    fetchJson<Regency>(`${API}/static/api/regencies.json`),
    fetchJson<District>(`${API}/static/api/districts.json`),
    fetchJson<Village>(`${API}/static/api/villages.json`),
  ]);

  console.log(`  Provinces: ${provinces.length}`);
  console.log(`  Regencies: ${regencies.length}`);
  console.log(`  Districts: ${districts.length}`);
  console.log(`  Villages: ${villages.length}`);

  // Filter to Lombok Timur (kode 5204)
  const lombokTimur = regencies.filter(r => r.id.startsWith("52"));
  const lombokKecamatan = districts.filter(d => lombokTimur.some(r => r.id === d.regency_id));
  const lombokDesa = villages.filter(v => lombokKecamatan.some(k => k.id === v.district_id));

  console.log(`\nLombok Timur only:`);
  console.log(`  Regencies: ${lombokTimur.length}`);
  console.log(`  Districts: ${lombokKecamatan.length}`);
  console.log(`  Villages: ${lombokDesa.length}`);

  // Option: full Indonesia or Lombok only
  const FULL_INDONESIA = process.argv.includes("--full");

  const targetProvinces = FULL_INDONESIA ? provinces : provinces.filter(p => p.id === "52");
  const targetRegencies = FULL_INDONESIA ? regencies : lombokTimur;
  const targetDistricts = FULL_INDONESIA ? districts : lombokKecamatan;
  const targetVillages = FULL_INDONESIA ? villages : lombokDesa;

  console.log(`\nSeeding ${targetProvinces.length} provinces, ${targetRegencies.length} regencies, ${targetDistricts.length} districts, ${targetVillages.length} villages...`);

  // Seed provinces
  for (const p of targetProvinces) {
    await supabase.from("ref_provinsi").upsert({
      kode: p.id,
      nama: p.name,
      aktif: true,
    }, { onConflict: "kode" });
  }
  console.log("  Provinces seeded");

  // Seed regencies
  for (const r of targetRegencies) {
    const jenis = r.name.includes("Kota") ? "Kota" : "Kabupaten";
    await supabase.from("ref_kabupaten").upsert({
      kode: r.id,
      kode_provinsi: r.province_id,
      nama: r.name,
      jenis,
      aktif: true,
    }, { onConflict: "kode" });
  }
  console.log("  Regencies seeded");

  // Seed districts
  for (const d of targetDistricts) {
    await supabase.from("ref_kecamatan").upsert({
      kode: d.id,
      kode_kabupaten: d.regency_id,
      nama: d.name,
      aktif: true,
    }, { onConflict: "kode" });
  }
  console.log("  Districts seeded");

  // Seed villages
  for (const v of targetVillages) {
    const jenis = v.name.includes("Kelurahan") ? "Kelurahan" : "Desa";
    await supabase.from("ref_desa").upsert({
      kode: v.code || v.id,
      kode_kecamatan: v.district_id,
      nama: v.name.replace(/^(Desa|Kelurahan)\s+/i, ""),
      jenis,
      aktif: true,
    }, { onConflict: "kode" });
  }
  console.log("  Villages seeded");

  console.log("\nDone! Wilayah data synced from KEMENDAGRI API.");
  console.log("Run with --full to sync all of Indonesia.");
}

main().catch(console.error);
