require('dotenv').config({path: '.env'});
async function run() {
  const url = process.env.VITE_SUPABASE_URL + '/rest/v1/surat_terbit?select=*&limit=5';
  const key = process.env.VITE_SUPABASE_PUBLISHABLE_KEY || process.env.VITE_SUPABASE_ANON_KEY;
  const res = await fetch(url, { headers: { 'apikey': key, 'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json', 'Prefer': 'count=exact' } });
  const data = await res.json();
  const count = res.headers.get('content-range');
  console.log("Surat terbit records count:", data?.length, "Range:", count);
}
run();
