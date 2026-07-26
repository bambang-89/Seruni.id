import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function applyDrop() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    console.log('✅ Connected to database!');

    const filePath = path.join('supabase', 'migrations', '20260805000006_drop_unused_tables.sql');
    const sql = fs.readFileSync(filePath, 'utf8');

    console.log('🚀 Dropping unused tables...');
    await client.query(sql);
    console.log('✅ Unused tables dropped successfully!');
  } catch (error) {
    console.error('❌ Error executing drop:', error.message);
  } finally {
    await client.end();
  }
}

applyDrop();
