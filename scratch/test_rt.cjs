require('dotenv').config({ path: '.env.vercel' });
const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');

async function run() {
  const sb = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_PUBLISHABLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: { fetch: require('node-fetch') }
  });
  
  const { data, error } = await sb.from('ref_rt').select('*').limit(1);
  console.log("ref_rt check:", { data, error });
}
run();
