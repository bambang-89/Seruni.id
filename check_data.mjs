import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: false, persistSession: false }
});

async function main() {
    console.log("Checking tenants...");
    const { data: tenants, error: errT } = await supabase.from('tenants').select('*');
    if (errT) console.error(errT);
    else console.log(tenants);

    console.log("\nChecking penduduk summary...");
    const { count: countTotal } = await supabase.from('penduduk').select('*', { count: 'exact', head: true });
    console.log(`Total penduduk: ${countTotal}`);

    const { count: countTenantNull } = await supabase.from('penduduk').select('*', { count: 'exact', head: true }).is('tenant_id', null);
    console.log(`Penduduk without tenant_id: ${countTenantNull}`);
    
    console.log("\nSample penduduk:");
    const { data: sampleP } = await supabase.from('penduduk').select('id, tenant_id, nik, nama, dusun, dusun_id, rt, rw').limit(5);
    console.log(sampleP);
    
    console.log("\nChecking surat_ajuan...");
    const { count: countSurat } = await supabase.from('surat_ajuan').select('*', { count: 'exact', head: true });
    console.log(`Total surat_ajuan: ${countSurat}`);
}
main();
