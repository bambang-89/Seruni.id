import pg from 'pg';
import fs from 'fs';
const { Client } = pg;

// Connect via Supabase direct postgres connection
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

const migrationFile = 'supabase/migrations/20260722000004_create_ref_tables.sql';

async function applyMigration() {
  const client = new Client({ connectionString: DB_URL });
  try {
    console.log('Connecting to database...');
    await client.connect();
    console.log('Connected!');

    console.log('Reading migration file:', migrationFile);
    const sql = fs.readFileSync(migrationFile, 'utf8');

    console.log('Executing migration...');
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('Migration applied successfully!');

    // Verify
    const tables = [
      'ref_penggunaan_tanah',
      'ref_status_hak_tanah',
      'ref_jenis_infrastruktur',
      'ref_bidang_pembangunan',
      'ref_kategori_bansos',
      'ref_jenis_bencana',
      'ref_apbdes_kategori',
      'ref_sektor_umkm',
      'ref_produk_kategori'
    ];
    console.log('\nVerifying tables...');
    for (const t of tables) {
      const r = await client.query(`SELECT COUNT(*) FROM ${t}`);
      console.log(`  ${t}: ${r.rows[0].count} rows`);
    }

  } catch (error) {
    console.error('\nError:', error.message);
    try { await client.query('ROLLBACK'); } catch (e) {}
  } finally {
    await client.end();
  }
}

applyMigration();
