import pg from 'pg';
import fs from 'fs';

const { Client } = pg;
const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function extractSchema() {
  const client = new Client({ connectionString: DB_URL });
  try {
    await client.connect();
    console.log('✅ Connected to database!');

    const res = await client.query(`
      SELECT table_name, column_name, data_type 
      FROM information_schema.columns 
      WHERE table_schema = 'public'
      ORDER BY table_name, column_name;
    `);

    const schema = {};
    res.rows.forEach(row => {
      if (!schema[row.table_name]) {
        schema[row.table_name] = [];
      }
      schema[row.table_name].push(row.column_name);
    });

    fs.writeFileSync('scripts/db-schema-reference.json', JSON.stringify(schema, null, 2));
    console.log('✅ DB Schema extracted to scripts/db-schema-reference.json');
  } catch (error) {
    console.error('❌ Error extracting schema:', error.message);
  } finally {
    await client.end();
  }
}

extractSchema();
