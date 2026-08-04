/**
 * apply-ddl-migration.mjs
 * Apply DDL migration directly via pg driver to Supabase.
 */
import pg from "pg";
const { Client } = pg;

// Supabase connection - using transaction pooler (port 6543) with session mode
// Try multiple connection strings
const CONNECTIONS = [
  // Direct connection (may not work without db password)
  `postgresql://postgres.smngqdpbmgcdbmkiuviq:Serunimumbul88@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres`,
  // Session pooler
  `postgresql://postgres.smngqdpbmgcdbmkiuviq:Serunimumbul88@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres`,
];

const DDL = `
-- Add dusun_id FK to penduduk (ref_dusun table)
ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS dusun_id UUID REFERENCES public.ref_dusun(id) ON DELETE SET NULL;

-- Add kepala_penduduk_id FK to keluarga
ALTER TABLE public.keluarga
  ADD COLUMN IF NOT EXISTS kepala_penduduk_id UUID REFERENCES public.penduduk(id) ON DELETE SET NULL;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_penduduk_dusun_id  ON public.penduduk(dusun_id);
CREATE INDEX IF NOT EXISTS idx_keluarga_kepala_id ON public.keluarga(kepala_penduduk_id);

-- Backfill dusun_id for existing rows (match by name, case-insensitive)
UPDATE public.penduduk p
SET dusun_id = rd.id
FROM public.ref_dusun rd
WHERE lower(p.dusun) = lower(rd.nama)
  AND p.dusun_id IS NULL;
`;

async function run() {
  let client = null;
  for (const connStr of CONNECTIONS) {
    try {
      console.log("Trying connection:", connStr.replace(/:([^@]+)@/, ":***@"));
      client = new Client({ connectionString: connStr, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 8000 });
      await client.connect();
      console.log("✅ Connected!");
      break;
    } catch (e) {
      console.log("  ❌", e.message.slice(0, 100));
      client = null;
    }
  }

  if (!client) {
    console.error("Could not connect via pg. Printing SQL for manual execution:");
    console.log("\n" + "=".repeat(60));
    console.log("Run this SQL in Supabase SQL Editor:");
    console.log("https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql/new");
    console.log("=".repeat(60));
    console.log(DDL);
    process.exit(1);
  }

  try {
    console.log("\nApplying DDL...");
    await client.query(DDL);
    console.log("✅ DDL applied successfully!");
    
    // Verify
    const res = await client.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'penduduk' AND column_name = 'dusun_id'
    `);
    console.log("dusun_id column exists:", res.rows.length > 0 ? "YES ✅" : "NO ❌");

    const kk = await client.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'keluarga' AND column_name = 'kepala_penduduk_id'
    `);
    console.log("kepala_penduduk_id column exists:", kk.rows.length > 0 ? "YES ✅" : "NO ❌");

    const backfill = await client.query(`SELECT COUNT(*) FROM public.penduduk WHERE dusun_id IS NOT NULL`);
    console.log("dusun_id backfilled:", backfill.rows[0].count, "rows");
  } catch (e) {
    console.error("DDL error:", e.message);
  } finally {
    await client.end();
  }
}

run().catch(e => { console.error("FATAL:", e.message); process.exit(1); });
