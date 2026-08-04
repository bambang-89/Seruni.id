require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const sb = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);
async function run() {
  console.log("Running SQL...");
  const {data, error} = await sb.rpc('exec_sql', { sql: "ALTER TABLE site_settings ADD COLUMN IF NOT EXISTS singkatan_desa TEXT; ALTER TABLE tenants ADD COLUMN IF NOT EXISTS fonnte_token TEXT; NOTIFY pgrst, 'reload schema';" });
  console.log("data:", data, "error:", error);
}
run();
