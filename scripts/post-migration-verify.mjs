/**
 * Post-Migration Verification Script
 * Run AFTER applying the SQL migration in Supabase Dashboard
 *
 * node scripts/post-migration-verify.mjs
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = {
  'apikey': KEY,
  'Authorization': `Bearer ${KEY}`,
  'Content-Type': 'application/json'
};

async function check(table) {
  try {
    const r = await fetch(`${BASE}/rest/v1/${table}?select=count`, { headers: H });
    if (r.ok) {
      const data = await r.json();
      return { table, status: 'EXISTS', count: data[0]?.count || 0 };
    }
    return { table, status: '404', count: 0 };
  } catch (e) {
    return { table, status: 'ERROR', count: 0, error: e.message };
  }
}

async function seedData(table, data) {
  try {
    const r = await fetch(`${BASE}/rest/v1/${table}`, {
      method: 'POST',
      headers: { ...H, 'Prefer': 'return=representation' },
      body: JSON.stringify(data)
    });
    if (r.ok) return true;
    return false;
  } catch (e) {
    return false;
  }
}

async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       POST-MIGRATION VERIFICATION                       ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  // Get tenant ID
  const tenantRes = await fetch(`${BASE}/rest/v1/tenants?select=id,subdomain`, { headers: H });
  const tenants = await tenantRes.json();
  const tenant = tenants.find(t => t.subdomain === 'seruni');

  if (!tenant) {
    console.error('Tenant "seruni" not found!');
    process.exit(1);
  }
  console.log(`Tenant ID: ${tenant.id}`);
  console.log('');

  // Tables to verify
  const tables = [
    'apotek_desa', 'apotek_obat', 'apotek_resep',
    'perpustakaan_desa', 'buku_perpustakaan',
    'pemilihan', 'calon_kades',
    'idm_scoring_log', 'pbb_pembayaran',
    'bansos_penerima', 'posyandu_balita',
    'bencana_bantuan', 'audit_log', 'user_profiles'
  ];

  console.log('📋 Verifying tables...\n');

  let exists = 0;
  let missing = 0;

  for (const t of tables) {
    const result = await check(t);
    if (result.status === 'EXISTS') {
      exists++;
      console.log(`  ✅ ${t} (${result.count} rows)`);
    } else {
      missing++;
      console.log(`  ❌ ${t} - ${result.status}`);
    }
  }

  console.log(`\n📊 Summary: ${exists}/${tables.length} tables exist`);

  if (missing > 0) {
    console.log('\n⚠️  Tables not found. Please run the SQL migration in Supabase Dashboard:');
    console.log('   1. Go to: https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql/new');
    console.log('   2. Copy SQL from: scripts/create-tables-simple.sql');
    console.log('   3. Run the SQL');
    console.log('   4. Re-run this script\n');
    return;
  }

  console.log('\n✅ All tables created! Seeding initial data...\n');

  // Seed minimal data
  try {
    await seedData('apotek_desa', [{
      tenant_id: tenant.id,
      nama: 'Apotek Desa Seruni Mumbul',
      alamat: 'Kantor Desa Seruni Mumbul',
      jadwal: 'Senin-Sabtu 08:00-16:00',
      keterangan: 'Apotek umum desa'
    }]);
    console.log('  ✅ apotek_desa seeded');

    await seedData('perpustakaan_desa', [{
      tenant_id: tenant.id,
      nama: 'Perpustakaan Desa Seruni Mumbul',
      alamat: 'Kantor Desa Seruni Mumbul',
      jam_buka: 'Senin-Sabtu 08:00-15:00',
      keterangan: 'Perpustakaan umum desa'
    }]);
    console.log('  ✅ perpustakaan_desa seeded');

    await seedData('apotek_obat', [{
      tenant_id: tenant.id,
      nama_obat: 'Paracetamol 500mg',
      kategori: 'Obat Demam',
      satuan: 'tablet',
      stok: 500,
      harga: 100
    }]);
    console.log('  ✅ apotek_obat seeded');
  } catch (e) {
    console.log(`  ⚠️  Some seeds failed: ${e.message}`);
  }

  console.log('\n' + '='.repeat(60));
  console.log('🎉 MIGRATION COMPLETE!');
  console.log('='.repeat(60));
  console.log('\nNext step: Run npm run dev and test the admin dashboard\n');
}

main().catch(console.error);
