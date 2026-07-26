import pg from 'pg';
const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function describeKeluarga() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    const res = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'keluarga';
    `);
    console.log('--- COLUMNS IN KELUARGA ---');
    res.rows.forEach(row => console.log(`${row.column_name}: ${row.data_type}`));
  } catch (error) {
    console.error('Error describing keluarga:', error.message);
  } finally {
    await client.end();
  }
}

describeKeluarga();
