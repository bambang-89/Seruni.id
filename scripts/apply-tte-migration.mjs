import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function applyTTE() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    console.log('✅ Connected to database!');

    const filePath = path.join('supabase', 'migrations', '20260804000001_create_tte_signature_tables.sql');
    const sql = fs.readFileSync(filePath, 'utf8');

    console.log('🚀 Creating tte_signatures table...');
    await client.query(sql);
    console.log('✅ tte_signatures table created successfully!');
  } catch (error) {
    console.error('❌ Error executing TTE migration:', error.message);
  } finally {
    await client.end();
  }
}

applyTTE();
