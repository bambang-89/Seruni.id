import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

const migrationFiles = [
  '20260805000002_fix_surat_dna.sql',
  '20260805000003_seed_jenis_surat_final.sql',
  '20260805000004_seed_dna_final.sql',
  '20260805000005_seed_dna_remaining.sql'
];

async function applyMigrations() {
  const client = new Client({ connectionString: DB_URL });
  try {
    console.log('🔄 Connecting to database...');
    await client.connect();
    console.log('✅ Connected!');

    for (const file of migrationFiles) {
      console.log(`\n📄 Reading migration file: ${file}...`);
      const filePath = path.join('supabase', 'migrations', file);
      const sql = fs.readFileSync(filePath, 'utf8');

      console.log(`🚀 Executing ${file}...`);
      // Since some sql scripts contain multiple SQL commands, we run it as a transaction
      await client.query('BEGIN');
      await client.query(sql);
      await client.query('COMMIT');
      console.log(`✅ Success: ${file}`);
    }

    console.log('\n🎉 All specified migrations applied successfully!');
  } catch (error) {
    console.error('\n❌ Error applying migration:', error.message);
    try {
      await client.query('ROLLBACK');
    } catch (e) {
      // ignore rollback error if query failed before starting transaction or similar
    }
    process.exit(1);
  } finally {
    await client.end();
    console.log('🔌 Database connection closed.');
  }
}

applyMigrations();
