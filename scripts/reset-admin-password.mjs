/**
 * Reset Admin Password Script
 * Creates/sets admin account with known password
 */

const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

async function main() {
  const nik = '5203085405140001';
  const password = 'SeruniMumbul2024!';
  const nama = 'Bambang Susilo';

  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       RESET ADMIN PASSWORD                         ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`NIK: ${nik}`);
  console.log(`Nama: ${nama}`);
  console.log(`Password: ${password}`);
  console.log('');

  // First, try to create/update the admin via signUp
  const email = `nik-${nik}@admin.seruni.local`;

  console.log('Creating/updating admin user via Auth...');

  // Use the auth.users endpoint to create user
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SERVICE_KEY}`,
      'apikey': SERVICE_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      email: email,
      password: password,
      email_confirm: true,
      user_metadata: {
        nik: nik,
        nama: nama
      }
    })
  });

  if (response.ok) {
    const data = await response.json();
    console.log('✅ Admin user created/updated successfully!');
    console.log(`User ID: ${data.id}`);
    console.log('');
  } else {
    const error = await response.text();
    console.log('⚠️ Auth API response:', response.status);
    console.log(error);
    console.log('');
  }

  // Also update admin_profiles table
  console.log('Updating admin_profiles table...');

  const updateResponse = await fetch(`${SUPABASE_URL}/rest/v1/admin_profiles?nik=eq.${nik}`, {
    method: 'PATCH',
    headers: {
      'apikey': SERVICE_KEY,
      'Authorization': `Bearer ${SERVICE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify({
      nama: nama
    })
  });

  if (updateResponse.ok) {
    console.log('✅ admin_profiles updated');
  } else {
    console.log('⚠️ admin_profiles update:', updateResponse.status);
  }

  console.log('');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('CREDENTIALS');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');
  console.log('Login URL: https://seruni-id-project.vercel.app/admin');
  console.log('');
  console.log('Login dengan:');
  console.log(`  NIK: ${nik}`);
  console.log(`  Password: ${password}`);
  console.log('');
  console.log('Catatan: Jika NIK tidak terdaftar di Supabase Auth,');
  console.log('       gunakan halaman "Daftar Admin Baru" di /admin/login');
  console.log('');
}

main().catch(console.error);
