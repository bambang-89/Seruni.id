require('dotenv').config({path: '.env'});

async function run() {
  const url = process.env.VITE_SUPABASE_URL + '/rest/v1/penduduk?select=*&limit=5';
  const key = process.env.VITE_SUPABASE_PUBLISHABLE_KEY || process.env.VITE_SUPABASE_ANON_KEY;
  
  const res = await fetch(url, {
    headers: {
      'apikey': key,
      'Authorization': 'Bearer ' + key,
      'Content-Type': 'application/json',
      'Prefer': 'count=exact'
    }
  });
  
  if (!res.ok) {
    const text = await res.text();
    console.error("Error:", res.status, text);
    return;
  }
  
  const data = await res.json();
  const count = res.headers.get('content-range');
  console.log("Penduduk records count:", data?.length, "Range:", count);
  if (data?.length > 0) {
    console.log("Sample ID:", data[0].id);
    console.log("Sample nama:", data[0].nama);
  }
}
run();
