require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.VITE_SUPABASE_PUBLISHABLE_KEY
);

async function testNotif() {
  console.log("Fetching a surat_ajuan...");
  const { data: ajuan, error: errAjuan } = await supabase
    .from("surat_ajuan")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(1)
    .single();
    
  if (errAjuan) {
    console.error("Error fetching ajuan", errAjuan);
    return;
  }
  
  console.log(`Testing notif for ajuan ${ajuan.id} (Tiket: ${ajuan.nomor_tiket})`);
  
  const { data, error } = await supabase.functions.invoke("notifikasi-status-surat", {
    body: { surat_ajuan_id: ajuan.id, status_baru: "diterima" }
  });
  
  console.log("Result:", data);
  console.log("Error:", error);
}

testNotif();
