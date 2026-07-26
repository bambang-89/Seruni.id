import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';

const envPath = path.join(process.cwd(), '.env');
const envContent = fs.readFileSync(envPath, 'utf8');
const env: Record<string, string> = {};
envContent.split('\n').forEach(line => {
  const [key, ...values] = line.split('=');
  if (key && values.length > 0) {
    env[key.trim()] = values.join('=').trim().replace(/['"]/g, '');
  }
});

const supabaseUrl = env['VITE_SUPABASE_URL'] || 'http://127.0.0.1:54321';
const supabaseKey = env['SUPABASE_SERVICE_ROLE_KEY'] || env['VITE_SUPABASE_ANON_KEY'] || 'dummy';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
    console.log("Fetching tenant and surat_jenis...");
    const { data: jenis } = await supabase.from('surat_jenis').select('*').eq('kode_surat', '300.0').single();
    
    if (!jenis) {
        console.error("Jenis surat 300.0 not found!");
        return;
    }
    
    const tenant_id = jenis.tenant_id;
    const jenis_surat_id = jenis.id;
    
    const dnaFields = [
        {
            tenant_id, jenis_surat_id, kode_surat: '300.0', field_name: 'ciri_fisik', 
            label: 'Ciri Fisik', tipe: 'textarea', placeholder: 'Tinggi: ... cm, Rambut: ..., Kulit: ..., dll', 
            wajib: true, grup: 'Fisik', urutan: 1, help_text: null
        },
        {
            tenant_id, jenis_surat_id, kode_surat: '300.0', field_name: 'alamat_tinggal', 
            label: 'Alamat Tempat Tinggal', tipe: 'textarea', placeholder: '', 
            wajib: true, grup: 'Alamat', urutan: 10, help_text: null
        },
        {
            tenant_id, jenis_surat_id, kode_surat: '300.0', field_name: 'dusun', 
            label: 'Dusun', tipe: 'text', placeholder: '', 
            wajib: true, grup: 'Alamat', urutan: 11, help_text: null
        },
        {
            tenant_id, jenis_surat_id, kode_surat: '300.0', field_name: 'keperluan', 
            label: 'Keperluan SKCK', tipe: 'textarea', placeholder: '', 
            wajib: true, grup: 'Keperluan', urutan: 20, help_text: 'Contoh: Melamar kerja, Membuat paspor, dll'
        },
        {
            tenant_id, jenis_surat_id, kode_surat: '300.0', field_name: 'riwayat_pidana', 
            label: 'Riwayat Pidana', tipe: 'textarea', placeholder: 'Tidak ada / Jelaskan jika ada', 
            wajib: true, grup: 'Riwayat', urutan: 30, help_text: null
        }
    ];

    console.log("Inserting DNA fields for 300.0...");
    const { data, error } = await supabase.from('surat_jenis_dna').upsert(dnaFields, { onConflict: 'jenis_surat_id,field_name' });
    
    if (error) {
        console.error("Error inserting:", error);
    } else {
        console.log("Success! DNA Fields restored for 300.0");
    }
}
run();
