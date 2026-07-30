#!/usr/bin/env node
/**
 * Apply migrations to Supabase via service_role client.
 * Uses direct SQL via rpc("run_sql", ...) if available,
 * or falls back to individual table operations.
 *
 * Run: node scripts/apply-migrations.cjs
 */

import { createClient } from "@supabase/supabase-js";
import ws from "ws";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SUPABASE_URL = "https://smngqdpbmgcdbmkiuviq.supabase.co";
const SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { realtime: { transport: ws } });

// Migration files to apply (in order)
const MIGRATIONS = [
  "20260728000001_find_penduduk_by_nik.sql",
  "20260730000001_cek_integritas_penduduk.sql",
  "20260730000002_fix_penduduk_keluarga_integrity.sql",
  "20260730000003_fix_dusun_wilayah_and_grants.sql",
  "20260730000004_cek_integritas_rpc.sql",
];

// Load SQL files
const migrationsDir = path.join(__dirname, "..", "supabase", "migrations");

async function runSql(sql) {
  try {
    // Try the run_sql RPC first
    const result = await sb.rpc("run_sql", { sql_query: sql });
    return { success: true, data: result };
  } catch (error1) {
    try {
      // Fallback: try exec_sql if available
      const result2 = await sb.rpc("exec_sql", { query: sql });
      return { success: true, data: result2 };
    } catch (error2) {
      return { success: false, error: error1.message || error2.message || "RPC not available" };
    }
  }
}

async function applyMigration(filename) {
  const filepath = path.join(migrationsDir, filename);
  if (!fs.existsSync(filepath)) {
    console.log(`  [SKIP] File not found: ${filename}`);
    return { skipped: true };
  }

  const sql = fs.readFileSync(filepath, "utf8");
  console.log(`\n[${filename}]`);
  console.log("  Executing via run_sql RPC...");

  // For DO$$ blocks, we need pg executor. The run_sql RPC should work if it exists.
  const result = await runSql(sql);

  if (result.success) {
    console.log("  [OK] SQL executed successfully");
    if (result.data) {
      const lines = JSON.stringify(result.data, null, 2).split("\n");
      if (lines.length <= 10) {
        lines.forEach(l => console.log("  " + l));
      }
    }
    return { success: true };
  } else {
    console.log(`  [WARN] run_sql RPC not available: ${result.error}`);
    console.log("  Manual apply required at:");
    console.log("  https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql");
    console.log("\n  Copy contents of:");
    console.log(`  supabase/migrations/${filename}`);
    return { success: false, error: result.error };
  }
}

async function main() {
  console.log("=".repeat(60));
  console.log("  APPLY MIGRATIONS TO SUPABASE");
  console.log("=".repeat(60));

  // Test connection
  console.log("\n[Connection test]");
  const { error: testErr } = await sb.from("tenants").select("id").limit(1);
  if (testErr) {
    console.log(`  [ERROR] Connection failed: ${testErr.message}`);
    process.exit(1);
  }
  console.log("  [OK] Connected to Supabase");

  let allSuccess = true;
  for (const filename of MIGRATIONS) {
    const result = await applyMigration(filename);
    if (!result.success && !result.skipped) {
      allSuccess = false;
    }
  }

  console.log("\n" + "=".repeat(60));
  if (allSuccess) {
    console.log("  All migrations applied successfully!");
  } else {
    console.log("  Some migrations need manual apply.");
    console.log("  Open SQL Editor and run the .sql files manually.");
  }
  console.log("=".repeat(60));
}

main().catch(e => {
  console.error("FATAL:", e.message);
  process.exit(1);
});
