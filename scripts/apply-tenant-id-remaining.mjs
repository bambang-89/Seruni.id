/**
 * Apply Task 1 Migration: Add tenant_id to 13 remaining tables
 * Run: node scripts/apply-tenant-id-remaining.mjs
 */
import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;

const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

const MIGRATION_FILE = '20260826000001_add_tenant_id_remaining_tables.sql';

async function applyMigration() {
  const client = new Client({ connectionString: DB_URL });
  try {
    console.log('Connecting to database...');
    await client.connect();
    console.log('Connected!\n');

    const filePath = path.join('supabase', 'migrations', MIGRATION_FILE);
    console.log(`Reading: ${filePath}`);
    const sql = fs.readFileSync(filePath, 'utf8');
    console.log(`SQL length: ${sql.length} chars\n`);

    console.log('Executing migration...');
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('Migration committed successfully!\n');

    // Verify: check tenant_id is NOT NULL and no NULLs
    const tables = [
      'berita', 'agenda', 'pengumuman', 'galeri',
      'idm_scoring_log', 'perpustakaan_desa', 'buku_perpustakaan',
      'pemilihan', 'calon_kades', 'posyandu_balita',
      'pbb_pembayaran', 'bencana_bantuan', 'user_profiles'
    ];

    console.log('=== VERIFICATION ===\n');

    for (const table of tables) {
      // Check column exists and is NOT NULL
      const colResult = await client.query(
        `SELECT column_name, data_type, is_nullable
         FROM information_schema.columns
         WHERE table_name = $1 AND column_name = 'tenant_id'`,
        [table]
      );

      if (colResult.rows.length === 0) {
        console.log(`  ${table}: tenant_id column MISSING`);
      } else {
        const col = colResult.rows[0];
        console.log(`  ${table}: tenant_id ${col.data_type} nullable=${col.is_nullable}`);
      }

      // Check no NULL values remain
      const nullResult = await client.query(
        `SELECT count(*) as cnt FROM public.${table} WHERE tenant_id IS NULL`
      );
      const nullCount = parseInt(nullResult.rows[0].cnt);
      console.log(`    NULL rows: ${nullCount} (expected: 0)`);
      if (nullCount > 0) {
        console.log(`    WARNING: ${nullCount} rows still have NULL tenant_id!`);
      }

      // Check index exists
      const idxResult = await client.query(
        `SELECT indexname FROM pg_indexes
         WHERE tablename = $1 AND indexname LIKE '%tenant%'`,
        [table]
      );
      if (idxResult.rows.length > 0) {
        console.log(`    Indexes: ${idxResult.rows.map(r => r.indexname).join(', ')}`);
      } else {
        console.log(`    No tenant index found`);
      }
    }

    console.log('\nAll done!');

  } catch (error) {
    console.error('\nError:', error.message);
    try { await client.query('ROLLBACK'); } catch (e) { /* ignore */ }
    process.exit(1);
  } finally {
    await client.end();
    console.log('Connection closed.');
  }
}

applyMigration();
