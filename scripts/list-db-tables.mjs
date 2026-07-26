import pg from 'pg';
const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function listTables() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name;
    `);
    console.log('--- TABLES IN DB ---');
    res.rows.forEach(row => console.log(row.table_name));
  } catch (error) {
    console.error('Error listing tables:', error.message);
  } finally {
    await client.end();
  }
}

listTables();
