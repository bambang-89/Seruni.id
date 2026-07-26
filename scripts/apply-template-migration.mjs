import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function applyTemplate() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    console.log('✅ Connected to database!');

    const filePath = path.join('supabase', 'migrations', '20260731000001_surat_template_system.sql');
    const sql = fs.readFileSync(filePath, 'utf8');

    console.log('🚀 Running surat_template_system migration...');
    await client.query(sql);
    console.log('✅ surat_template_system migration run successfully!');
  } catch (error) {
    console.error('❌ Error executing migration:', error.message);
  } finally {
    await client.end();
  }
}

applyTemplate();
