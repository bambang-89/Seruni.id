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

async function seed() {
  console.log('Inserting tenant...');
  let tenantId = null;
  const { data: tenant, error: tenantErr } = await supabase.from('tenants').insert({ subdomain: 'localhost', nama_desa: 'Desa Seruni Test' }).select().single();
  if (tenantErr) {
    console.error('Tenant error:', tenantErr.message);
    const { data: ext } = await supabase.from('tenants').select('*').eq('subdomain', 'localhost').single();
    if (ext) tenantId = ext.id;
  } else {
    tenantId = tenant.id;
  }
  
  console.log('Tenant ID:', tenantId);

  if (tenantId) {
    console.log('Inserting penduduk...');
    const { error: pErr } = await supabase.from('penduduk').insert({
      tenant_id: tenantId,
      nik: '1234567890123456',
      nama: 'Warga Test Seruni',
      tempat_lahir: 'Jakarta',
      tanggal_lahir: '1990-01-01',
      jenis_kelamin: 'L',
      status_hidup: 'hidup',
      status_kawin: 'Belum Kawin'
    });
    if (pErr) console.error('Penduduk error:', pErr.message);
    else console.log('Penduduk inserted.');
  }
  
  console.log('Creating Admin User...');
  const { data: authData, error: authErr } = await supabase.auth.admin.createUser({
    email: 'nik-1234567890123456@admin.seruni.local',
    password: 'password123!',
    email_confirm: true
  });
  
  if (authErr) {
     console.error('Auth error (maybe exists?):', authErr.message);
  }
  
  const { data: users } = await supabase.auth.admin.listUsers();
  const adminUser = users.users.find(u => u.email === 'nik-1234567890123456@admin.seruni.local');
  if (adminUser) {
     console.log('Admin user found, ID:', adminUser.id);
     await supabase.from('admin_profiles').upsert({ id: adminUser.id, nik: '1234567890123456', nama: 'Admin Seruni' });
     await supabase.from('user_roles').upsert({ user_id: adminUser.id, role: 'admin' });
     await supabase.from('user_peran').upsert({ user_id: adminUser.id, peran: 'admin', aktif: true });
     console.log('Admin roles granted.');
  }
}
seed();
