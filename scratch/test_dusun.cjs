require('dotenv').config({ path: '.env.vercel' });
const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');

async function run() {
  const sb = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    realtime: { transport: ws }
  });
  
  const { data, error } = await sb.from('wilayah_dusun').select('*').limit(1);
  console.log("Dusun check:", { data, error });
}
run();
