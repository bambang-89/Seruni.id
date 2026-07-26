import pg from 'pg';
import fs from 'fs';
import path from 'path';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function applyImages() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    console.log('✅ Connected to database!');

    const filePath = path.join('supabase', 'migrations', '20260729000001_add_image_columns.sql');
    const sql = fs.readFileSync(filePath, 'utf8');

    console.log('🚀 Running add_image_columns migration...');
    await client.query(sql);
    console.log('✅ add_image_columns migration run successfully!');
  } catch (error) {
    console.error('❌ Error executing migration:', error.message);
  } finally {
    await client.end();
  }
}

applyImages();
