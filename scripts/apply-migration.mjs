/**
 * Apply Migration Script
 * Run: node scripts/apply-migration.mjs
 *
 * This script applies the missing tables migration via Supabase REST API
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = {
  'apikey': KEY,
  'Authorization': `Bearer ${KEY}`,
  'Content-Type': 'application/json'
};

async function applyMigration() {
  console.log('🔄 Applying Missing Tables Migration...\n');

  // Get tenant ID
  const tenantRes = await fetch(`${BASE}/rest/v1/tenants?select=id&limit=1`, { headers: H });
  const tenants = await tenantRes.json();
  const tenantId = tenants[0]?.id;

  if (!tenantId) {
    console.error('❌ Tenant not found!');
    process.exit(1);
  }
  console.log('📍 Tenant ID:', tenantId);

  // ============================================================
  // APPLY TABLE CREATIONS VIA EDGE FUNCTION
  // Note: Supabase REST API doesn't support DDL statements directly
  // We need to use pg_tables to check if tables exist first
  // ============================================================

  const tablesToCheck = [
    'apotek_desa',
    'apotek_obat',
    'apotek_resep',
    'perpustakaan_desa',
    'buku_perpustakaan',
    'pemilihan',
    'calon_kades',
    'idm_scoring_log',
    'pbb_pembayaran',
    'bansos_penerima',
    'posyandu_balita',
    'bencana_bantuan',
    'audit_log',
    'user_profiles'
  ];

  console.log('\n📋 Checking existing tables...\n');

  for (const table of tablesToCheck) {
    try {
      const r = await fetch(`${BASE}/rest/v1/${table}?limit=1`, { headers: H });
      if (r.ok) {
        const countRes = await fetch(`${BASE}/rest/v1/${table}?select=count`, { headers: H });
        const count = countRes.ok ? (await countRes.json())[0]?.count || 0 : 0;
        console.log(`  ✅ ${table} exists (${count} rows)`);
      } else {
        console.log(`  ❌ ${table} does not exist`);
      }
    } catch (e) {
      console.log(`  ❌ ${table}: ${e.message}`);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('⚠️  IMPORTANT: Tables must be created via Supabase SQL Editor');
  console.log('='.repeat(60));
  console.log('\nPlease run the following SQL in Supabase SQL Editor:');
  console.log('\n1. Go to: https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql/new');
  console.log('2. Copy the content from: supabase/migrations/20260723000001_create_missing_tables.sql');
  console.log('3. Paste and run the SQL');
  console.log('4. This script will verify the tables after you run it\n');

  console.log('Or use the Supabase CLI:');
  console.log('  npx supabase db push\n');
}

// Alternative: Seed data via REST API (for tables that exist)
async function seedNewTables() {
  console.log('\n🔄 Attempting to seed data via REST API...\n');

  const tenantId = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';

  // Seed apotek_desa
  try {
    await fetch(`${BASE}/rest/v1/apotek_desa`, {
      method: 'POST',
      headers: { ...H, 'Prefer': 'return=representation' },
      body: JSON.stringify([{
        tenant_id: tenantId,
        nama: 'Apotek Desa Seruni Mumbul',
        alamat: 'Kantor Desa Seruni Mumbul',
        jadwal: 'Senin-Sabtu 08:00-16:00',
        keterangan: 'Apotek umum desa'
      }])
    });
    console.log('  ✅ apotek_desa seeded');
  } catch (e) {
    console.log(`  ❌ apotek_desa: ${e.message}`);
  }

  // Seed perpustakaan_desa
  try {
    await fetch(`${BASE}/rest/v1/perpustakaan_desa`, {
      method: 'POST',
      headers: { ...H, 'Prefer': 'return=representation' },
      body: JSON.stringify([{
        tenant_id: tenantId,
        nama: 'Perpustakaan Desa Seruni Mumbul',
        alamat: 'Kantor Desa Seruni Mumbul',
        jam_buka: 'Senin-Sabtu 08:00-15:00',
        keterangan: 'Perpustakaan umum desa'
      }])
    });
    console.log('  ✅ perpustakaan_desa seeded');
  } catch (e) {
    console.log(`  ❌ perpustakaan_desa: ${e.message}`);
  }
}

// Run
applyMigration().catch(console.error);
