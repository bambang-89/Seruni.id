import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

import ws from 'ws';
const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: false, persistSession: false },
  realtime: { transport: ws }
});

async function seedSuratAjuan() {
  // Get tenant ID for 'seruni-mumbul' (the real active tenant)
  const { data: tenants } = await supabase.from('tenants').select('id, subdomain, nama_desa').eq('aktif', true).limit(5);
  console.log('Active tenants:', JSON.stringify(tenants, null, 2));
  
  // Get jenis surat
  const { data: jenisSurat } = await supabase.from('jenis_surat').select('id, nama').limit(5);
  console.log('Jenis surat:', JSON.stringify(jenisSurat, null, 2));
  
  if (!tenants || tenants.length === 0) {
    console.error('No active tenants found!');
    return;
  }
  
  // Use the first real tenant (seruni-mumbul)
  const tenant = tenants.find(t => t.subdomain === 'seruni-mumbul') || tenants[0];
  console.log('Using tenant:', tenant.id, tenant.subdomain);
  
  if (!jenisSurat || jenisSurat.length === 0) {
    console.error('No jenis_surat found!');
    return;
  }
  
  const jenisSuratId = jenisSurat[0].id;
  
  // Insert a test surat_ajuan with status 'menunggu'
  const { data: ajuan, error: ajuanErr } = await supabase.from('surat_ajuan').insert({
    tenant_id: tenant.id,
    nik: '1234567890123456',
    nama: 'Warga Test E2E',
    kontak: '08123456789',
    jenis_surat_id: jenisSuratId,
    keperluan: 'Pengujian sistem E2E surat workflow',
    status: 'menunggu',
    dokumen_ktp_url: 'https://placehold.co/400x300?text=KTP+Test',
    foto_pemohon_url: 'https://placehold.co/400x300?text=Selfie+Test',
    data_identitas: {
      tempat_lahir: 'Jakarta',
      tanggal_lahir: '01-01-1990',
      jenis_kelamin: 'L',
      status_kawin: 'Belum Kawin',
    }
  }).select().single();
  
  if (ajuanErr) {
    console.error('Error inserting surat_ajuan:', ajuanErr.message);
  } else {
    console.log('✅ surat_ajuan inserted:', ajuan.id, 'nomor_tiket:', ajuan.nomor_tiket);
  }
}

seedSuratAjuan();
