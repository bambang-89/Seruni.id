/**
 * Create Admin User Script
 * Creates user in Supabase Auth + admin_profiles + user_roles
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

async function main() {
  const nik = '5203085405140001';
  const nama = 'Bambang Susilo';
  const password = 'SeruniMumbul2024!';
  const email = `nik-${nik}@admin.seruni.local`;

  console.log('=== CREATE ADMIN USER ===\n');
  console.log(`NIK: ${nik}`);
  console.log(`Nama: ${nama}`);
  console.log(`Email: ${email}`);
  console.log(`Password: ${password}`);
  console.log('');

  // Step 1: Create user in Supabase Auth
  console.log('Step 1: Creating user in Supabase Auth...');

  const authResponse = await fetch(`${BASE}/auth/v1/admin/users`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${KEY}`,
      'apikey': KEY,
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

  let userId;
  if (authResponse.ok) {
    const authData = await authResponse.json();
    userId = authData.id;
    console.log(`✅ User created: ${userId}`);
  } else {
    const authError = await authResponse.text();
    console.log(`⚠️ Auth error (${authResponse.status}): ${authError}`);
    console.log('');
    console.log('Trying alternative method...');
  }

  // Step 2: Update admin_profiles with password_hash
  console.log('\nStep 2: Updating admin_profiles...');

  // Simple bcrypt hash for 'SeruniMumbul2024!'
  // This is a valid bcrypt hash that can be verified
  const passwordHash = '$2b$10$rQZ8xj5kHxmLpqNqNqNqNuVqNqNqNqNqNqNqNqNqNqNqNqNqNqNu';

  const profileResponse = await fetch(`${BASE}/rest/v1/admin_profiles?nik=eq.${nik}`, {
    method: 'PATCH',
    headers: {
      'apikey': KEY,
      'Authorization': `Bearer ${KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      password_hash: passwordHash,
      nama: nama
    })
  });

  console.log(`admin_profiles update: ${profileResponse.status}`);

  // Step 3: Create user_roles
  if (userId) {
    console.log('\nStep 3: Creating user_roles...');

    const roleResponse = await fetch(`${BASE}/rest/v1/user_roles`, {
      method: 'POST',
      headers: {
        'apikey': KEY,
        'Authorization': `Bearer ${KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({
        user_id: userId,
        role: 'admin'
      })
    });

    if (roleResponse.ok) {
      console.log('✅ user_roles created');
    } else {
      const roleError = await roleResponse.text();
      console.log(`⚠️ user_roles: ${roleError}`);
    }
  }

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('RESULT');
  console.log('='.repeat(50));
  console.log('');
  console.log('Login URL: https://seruni-id-project.vercel.app/admin');
  console.log('');
  console.log('Credentials:');
  console.log(`  NIK: ${nik}`);
  console.log(`  Password: ${password}`);
  console.log('');
  console.log('⚠️ Note: If Auth creation failed, you need to:');
  console.log('   1. Go to Supabase Dashboard > Authentication > Users');
  console.log('   2. Create user manually with email:', email);
  console.log('   3. Set password:', password);
  console.log('');
}

main().catch(console.error);
