/**
 * CRUD Test for Admin Dashboard Modules
 * Tests actual CRUD operations on key tables
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = {
  'apikey': KEY,
  'Authorization': `Bearer ${KEY}`,
  'Content-Type': 'application/json',
  'Prefer': 'return=representation'
};

async function testCRUD(table, testData) {
  const results = { table, create: false, read: false, update: false, delete: false };

  try {
    // CREATE
    const createRes = await fetch(`${BASE}/rest/v1/${table}`, {
      method: 'POST',
      headers: H,
      body: JSON.stringify([testData])
    });
    results.create = createRes.ok;
    const created = await createRes.json();
    const id = created?.[0]?.id;

    if (!id) {
      return results;
    }

    // READ
    const readRes = await fetch(`${BASE}/rest/v1/${table}?id=eq.${id}`, {
      headers: { 'apikey': KEY, 'Authorization': `Bearer ${KEY}` }
    });
    results.read = readRes.ok;

    // UPDATE
    const updateRes = await fetch(`${BASE}/rest/v1/${table}?id=eq.${id}`, {
      method: 'PATCH',
      headers: H,
      body: JSON.stringify({ keterangan: 'Updated via test' })
    });
    results.update = updateRes.ok;

    // DELETE
    const deleteRes = await fetch(`${BASE}/rest/v1/${table}?id=eq.${id}`, {
      method: 'DELETE',
      headers: { 'apikey': KEY, 'Authorization': `Bearer ${KEY}` }
    });
    results.delete = deleteRes.ok || deleteRes.status === 204;

  } catch (e) {
    console.log(`  Error: ${e.message}`);
  }

  return results;
}

async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       CRUD TEST - ADMIN DASHBOARD MODULES              ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  const tenantId = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
  const testSlug = 'test-' + Date.now();

  const tests = [
    {
      table: 'berita',
      data: {
        slug: testSlug,
        judul: 'Test CRUD Berita',
        kategori: 'Test',
        ringkasan: 'Test CRUD',
        published: true
      }
    },
    {
      table: 'agenda',
      data: {
        slug: testSlug,
        jenis: 'Test',
        judul: 'Test CRUD Agenda',
        tanggal: '2026-07-30'
      }
    },
    {
      table: 'apotek_desa',
      data: {
        tenant_id: tenantId,
        nama: 'Test Apotek',
        alamat: 'Test Alamat'
      }
    },
    {
      table: 'perpustakaan_desa',
      data: {
        tenant_id: tenantId,
        nama: 'Test Perpustakaan',
        alamat: 'Test Alamat'
      }
    },
    {
      table: 'usulan_warga',
      data: {
        tenant_id: tenantId,
        nomor_tiket: 'TEST-' + Date.now(),
        nama: 'Test User',
        judul: 'Test Usulan',
        kategori: 'infrastruktur',
        dusun: 'Test'
      }
    }
  ];

  let passed = 0;
  let failed = 0;

  for (const test of tests) {
    console.log(`Testing ${test.table}...`);
    const results = await testCRUD(test.table, test.data);

    const allPassed = results.create && results.read && results.update && results.delete;

    if (allPassed) {
      console.log(`  ✅ All CRUD operations passed`);
      passed++;
    } else {
      console.log(`  ❌ Failed: C=${results.create ? '✅' : '❌'} R=${results.read ? '✅' : '❌'} U=${results.update ? '✅' : '❌'} D=${results.delete ? '✅' : '❌'}`);
      failed++;
    }
  }

  console.log('');
  console.log('='.repeat(60));
  console.log(`📊 CRUD TEST RESULT: ${passed}/${tests.length} modules passed`);
  console.log('='.repeat(60));

  if (passed === tests.length) {
    console.log('\n🎉 ALL CRUD TESTS PASSED!');
    console.log('\nSistem siap digunakan! Admin dashboard berfungsi dengan baik.\n');
  } else {
    console.log(`\n⚠️  ${failed} tests failed. Check the results above.\n`);
  }
}

main().catch(console.error);
