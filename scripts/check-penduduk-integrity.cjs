#!/usr/bin/env node
/**
 * Cek Integritas Data via RPC
 * Run: node scripts/check-penduduk-integrity.cjs
 */

const fs = require("fs");
const path = require("path");

const envPath = path.join(__dirname, "..", ".env");
const envContent = fs.readFileSync(envPath, "utf8");
const env = {};
envContent.split("\n").forEach(function(line) {
  const parts = line.split("=");
  const key = (parts[0] || "").trim();
  if (key && !key.startsWith("#")) {
    env[key] = parts.slice(1).join("=").trim().replace(/^["']|["']$/g, "");
  }
});

const SUPABASE_URL = env.VITE_SUPABASE_URL;
const ANON_KEY = env.VITE_SUPABASE_PUBLISHABLE_KEY;

const HEADERS = {
  apikey: ANON_KEY,
  Authorization: "Bearer " + ANON_KEY,
  "Content-Type": "application/json",
  Prefer: "return=representation",
};

async function rpc(fn, params) {
  const url = SUPABASE_URL + "/rest/v1/rpc/" + fn;
  const res = await fetch(url, {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify(params || {}),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(res.status + " " + res.statusText + " - " + text.slice(0, 300));
  }
  return res.json();
}

async function main() {
  console.log("");
  console.log("======================================================================");
  console.log("  CEK INTEGRITAS DATA PENDUDUK vs KELUARGA");
  console.log("  Tanggal: " + new Date().toISOString().split("T")[0]);
  console.log("======================================================================");
  console.log("");

  let rows = [];
  try {
    rows = await rpc("cek_integritas_penduduk", {});
  } catch (e) {
    console.log("[ERROR] Gagal memanggil RPC cek_integritas_penduduk:");
    console.log("        " + e.message);
    console.log("");
    console.log("        Pastikan migration sudah di-apply ke Supabase!");
    console.log("        Jalankan di SQL Editor Supabase:");
    console.log("        https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql");
    console.log("");
    console.log("        Atau gunakan script alternatif:");
    console.log("        node scripts/verify-penduduk-integrity.mjs");
    console.log("        (butuh SERVICE_ROLE key)");
    return;
  }

  // Group by check_name
  const byName = {};
  for (var i = 0; i < rows.length; i++) {
    var r = rows[i];
    byName[r.check_name] = r;
  }

  // --- SUMMARY ---
  console.log("1. RINGKASAN");
  console.log("--------------------------------------------------");
  var summaryRows = ["total_penduduk", "total_keluarga", "distinct_no_kk"];
  for (var si = 0; si < summaryRows.length; si++) {
    var sk = summaryRows[si];
    if (byName[sk]) {
      var sv = byName[sk];
      console.log("   " + sv.detail + ": " + Number(sv.issue_count));
    }
  }

  // --- KELUARGA_ID INTEGRITY ---
  console.log("");
  console.log("2. KELUARGA_ID INTEGRITY");
  console.log("--------------------------------------------------");

  var checks = [
    { key: "penduduk_tanpa_keluarga_id", label: "Penduduk TANPA keluarga_id" },
    { key: "kepala_tanpa_keluarga", label: "Kepala Keluarga TANPA keluarga_id" },
    { key: "orphan_keluarga_id", label: "keluarga_id orphan (tdk ada di keluarga)" },
    { key: "keluarga_tak_tereferensikan", label: "Keluarga tidak direferensikan" },
  ];

  for (var ci = 0; ci < checks.length; ci++) {
    var ck = checks[ci];
    if (byName[ck.key]) {
      var cr = byName[ck.key];
      var count = Number(cr.issue_count);
      var icon = count === 0 ? "[OK]    " : "[ISSUE] ";
      console.log("   " + icon + ck.label + ": " + count);
      if (cr.sample_data && cr.sample_data.length > 0 && cr.sample_data[0] !== null) {
        var samples = cr.sample_data.slice(0, 5);
        for (var sj = 0; sj < samples.length; sj++) {
          var s = samples[sj];
          if (!s) continue;
          var info = "";
          if (s.nik) info += " NIK:" + s.nik;
          if (s.nama) info += " Nama:" + s.nama;
          if (s.no_kk) info += " KK:" + s.no_kk;
          if (s.keluarga_id) info += " keluarga_id:" + s.keluarga_id;
          if (s.count) info += " (" + s.count + " rows)";
          if (s.hubungan_kk) info += " hub:" + s.hubungan_kk;
          if (s.dusun) info += " dusun:" + s.dusun;
          console.log("        ->" + info);
        }
        if (cr.sample_data.length > 5) {
          console.log("        ... dan " + (cr.sample_data.length - 5) + " lagi");
        }
      }
    } else {
      console.log("   [OK]    " + ck.label + ": 0");
    }
  }

  // --- DUSUN CONSISTENCY ---
  console.log("");
  console.log("3. DUSUN CONSISTENCY");
  console.log("--------------------------------------------------");

  if (byName["dusun_tak_terdaftar"]) {
    var dc = Number(byName["dusun_tak_terdaftar"].issue_count);
    if (dc > 0) {
      console.log("   [ISSUE] " + dc + " dusun di penduduk TIDAK ADA di wilayah_dusun:");
      if (byName["dusun_tak_terdaftar"].sample_data && byName["dusun_tak_terdaftar"].sample_data[0]) {
        byName["dusun_tak_terdaftar"].sample_data.forEach(function(s) {
          if (s) console.log("           - \"" + s.dusun + "\" (" + s.count + " penduduk)");
        });
      }
    } else {
      console.log("   [OK]    Semua dusun sudah ada di wilayah_dusun");
    }
  }

  if (byName["penduduk_tanpa_dusun_id"]) {
    var dSid = Number(byName["penduduk_tanpa_dusun_id"].issue_count);
    if (dSid > 0) {
      console.log("   [ISSUE] " + dSid + " penduduk tanpa dusun_id (sudah punya nama dusun)");
    } else {
      console.log("   [OK]    Semua penduduk dengan nama dusun sudah punya dusun_id");
    }
  }

  // --- OVERALL SUMMARY ---
  console.log("");
  console.log("======================================================================");
  console.log("  RINGKASAN");
  console.log("======================================================================");

  var issues = [];
  checks.forEach(function(ck) {
    if (byName[ck.key] && Number(byName[ck.key].issue_count) > 0) {
      issues.push("   - " + ck.label + ": " + byName[ck.key].issue_count + " row(s)");
    }
  });
  if (byName["dusun_tak_terdaftar"] && Number(byName["dusun_tak_terdaftar"].issue_count) > 0) {
    issues.push("   - " + Number(byName["dusun_tak_terdaftar"].issue_count) + " dusun tidak ada di wilayah_dusun");
  }
  if (byName["penduduk_tanpa_dusun_id"] && Number(byName["penduduk_tanpa_dusun_id"].issue_count) > 0) {
    issues.push("   - " + Number(byName["penduduk_tanpa_dusun_id"].issue_count) + " penduduk tanpa dusun_id");
  }

  if (issues.length === 0) {
    console.log("   [OK] Tidak ada masalah integritas yang ditemukan!");
  } else {
    issues.forEach(function(issue) { console.log(issue); });
    console.log("");
    console.log("   Jalankan fix:");
    console.log("   node scripts/fix-penduduk-integrity.mjs");
    console.log("   (atau apply migration SQL di Supabase)");
  }

  console.log("");
}

main().catch(function(e) { console.error(e); });
