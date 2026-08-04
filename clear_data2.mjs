import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_PUBLISHABLE_KEY || '';

async function clearData() {
  console.log('Clearing surat_terbit...');
  const res1 = await fetch(`${supabaseUrl}/rest/v1/surat_terbit?id=neq.00000000-0000-0000-0000-000000000000`, {
    method: 'DELETE',
    headers: {
      'apikey': supabaseKey,
      'Authorization': `Bearer ${supabaseKey}`
    }
  });
  console.log('Result surat_terbit:', res1.status, await res1.text());

  console.log('Clearing surat_ajuan...');
  const res2 = await fetch(`${supabaseUrl}/rest/v1/surat_ajuan?id=neq.00000000-0000-0000-0000-000000000000`, {
    method: 'DELETE',
    headers: {
      'apikey': supabaseKey,
      'Authorization': `Bearer ${supabaseKey}`
    }
  });
  console.log('Result surat_ajuan:', res2.status, await res2.text());
}

clearData();
