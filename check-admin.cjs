const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://smmngqdpbmgcdbmkiuviq.supabase.co',
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkAdmin() {
  console.log('=== Cek Akun Admin ===\n');
  
  // 1. Check admin_profiles
  console.log('1. admin_profiles:');
  const { data: admins, error: e1 } = await supabase
    .from('admin_profiles')
    .select('*');
  
  if (e1) {
    console.log('   ERROR:', e1.message);
  } else if (!admins || admins.length === 0) {
    console.log('   Belum ada admin');
  } else {
    admins.forEach(a => console.log(`   - NIK: ${a.nik}, Nama: ${a.nama}, ID: ${a.id}`));
  }
  
  // 2. Check user_roles (role = admin)
  console.log('\n2. User dengan role admin:');
  const { data: roles, error: e2 } = await supabase
    .from('user_roles')
    .select('*, auth_user:user_id(id, email)')
    .eq('role', 'admin');
  
  if (e2) {
    console.log('   ERROR:', e2.message);
  } else if (!roles || roles.length === 0) {
    console.log('   Belum ada user dengan role admin');
  } else {
    roles.forEach(r => console.log(`   - User ID: ${r.user_id}, Email: ${r.auth_user?.email || 'N/A'}`));
  }
  
  // 3. Check user_peran
  console.log('\n3. User peran (semua):');
  const { data: perans, error: e3 } = await supabase
    .from('user_peran')
    .select('*');
  
  if (e3) {
    console.log('   ERROR:', e3.message);
  } else if (!perans || perans.length === 0) {
    console.log('   Belum ada data peran');
  } else {
    perans.forEach(p => console.log(`   - User ID: ${p.user_id}, Peran: ${p.peran}, Aktif: ${p.aktif}`));
  }
  
  // 4. Check auth.users (admin-related)
  console.log('\n4. Auth users (related to admin):');
  if (admins && admins.length > 0) {
    const adminIds = admins.map(a => a.id);
    const { data: users, error: e4 } = await supabase.auth.admin.listUsers();
    if (e4) {
      console.log('   ERROR:', e4.message);
    } else {
      const adminUsers = users.users.filter(u => adminIds.includes(u.id));
      if (adminUsers.length === 0) {
        console.log('   User di auth tapi belum login/terkonfirmasi');
      } else {
        adminUsers.forEach(u => console.log(`   - ${u.email}, confirmed: ${u.confirmed_at ? 'Ya' : 'Tidak'}`));
      }
    }
  } else {
    console.log('   (Tidak ada admin_profiles)');
  }
  
  console.log('\n=== Selesai ===');
}

checkAdmin().catch(console.error);
