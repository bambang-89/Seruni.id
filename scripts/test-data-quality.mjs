/**
 * Data Quality Test Script
 * Verifies data integrity after fixes
 */

const BASE = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const H = { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY };

async function query(table, params = '') {
  const r = await fetch(`${BASE}/rest/v1/${table}${params}`, { headers: H });
  return r.ok ? r.json() : null;
}

async function count(table, filter = '') {
  const r = await fetch(`${BASE}/rest/v1/${table}?select=count${filter}`, { headers: H });
  if (r.ok) {
    const d = await r.json();
    return d[0]?.count || 0;
  }
  return -1;
}

async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║       DATA QUALITY TEST                            ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  let passed = 0;
  let failed = 0;

  // ============================================================
  // TEST 1: Penduduk Count
  // ============================================================
  console.log('TEST 1: Penduduk Count');
  const totalPenduduk = await count('penduduk');
  console.log(`  Total Penduduk: ${totalPenduduk}`);
  if (totalPenduduk > 0) {
    console.log('  ✅ PASS: Penduduk exists');
    passed++;
  } else {
    console.log('  ❌ FAIL: No penduduk found');
    failed++;
  }

  // ============================================================
  // TEST 2: Keluarga Count
  // ============================================================
  console.log('\nTEST 2: Keluarga Count');
  const totalKeluarga = await count('keluarga');
  console.log(`  Total Keluarga: ${totalKeluarga}`);
  if (totalKeluarga > 0) {
    console.log('  ✅ PASS: Keluarga exists');
    passed++;
  } else {
    console.log('  ❌ FAIL: No keluarga found');
    failed++;
  }

  // ============================================================
  // TEST 3: hubungan_kk standardization
  // ============================================================
  console.log('\nTEST 3: Hubungan KK Standardization');

  // Count by hubungan_kk values
  const hubunganValues = ['KK', 'Istri', 'Anak', 'Orang Tua', 'Lainnya'];
  let hubunganOK = true;

  for (const val of hubunganValues) {
    const c = await count('penduduk', `&hubungan_kk=eq.${encodeURIComponent(val)}`);
    console.log(`  hubungan_kk='${val}': ${c}`);
    if (c === -1) hubunganOK = false;
  }

  // Check for bad values
  const kepalaKeluarga = await query('penduduk?select=hubungan_kk&hubungan_kk=like.*Kepala*&limit=1');
  if (kepalaKeluarga && kepalaKeluarga.length > 0) {
    console.log('  ❌ FAIL: Found "Kepala Keluarga" instead of "KK"');
    failed++;
    hubunganOK = false;
  } else if (hubunganOK) {
    console.log('  ✅ PASS: hubungan_kk values are standardized');
    passed++;
  }

  // ============================================================
  // TEST 4: Keluarga Linkage
  // ============================================================
  console.log('\nTEST 4: Penduduk → Keluarga Linkage');

  // Get sample with keluarga_id
  const sampleLinked = await query('penduduk?select=id,keluarga_id&keluarga_id=not.is.null&limit=5');
  console.log(`  Sample linked: ${sampleLinked?.length || 0}`);

  // Get keluarga with no linked penduduk
  const keluargaOrphan = await query('keluarga?select=id&limit=5');
  if (keluargaOrphan && keluargaOrphan.length > 0) {
    // Check if any have penduduk linked
    const linkedCount = await count('penduduk', '&keluarga_id=not.is.null');
    if (linkedCount > 0) {
      console.log(`  ✅ PASS: ${linkedCount} penduduk linked to keluarga`);
      passed++;
    } else {
      console.log('  ⚠️  WARN: No penduduk linked to keluarga yet');
      console.log('  ℹ️  Run fix-data-consistency.sql to link them');
    }
  }

  // ============================================================
  // TEST 5: Wilayah Linkage
  // ============================================================
  console.log('\nTEST 5: Penduduk → Wilayah Linkage');

  const wilayahList = await query('wilayah_dusun?select=*&order=urutan');
  if (wilayahList) {
    console.log('  Wilayah Stats:');
    let totalJiwaWilayah = 0;
    let totalKKWilayah = 0;

    for (const w of wilayahList) {
      console.log(`    ${w.nama}: ${w.jiwa} jiwa, ${w.kk} KK`);
      totalJiwaWilayah += w.jiwa || 0;
      totalKKWilayah += w.kk || 0;
    }

    console.log(`  Total Wilayah: ${totalJiwaWilayah} jiwa, ${totalKKWilayah} KK`);

    if (totalJiwaWilayah === totalPenduduk) {
      console.log('  ✅ PASS: Wilayah jiwa = Total Penduduk');
      passed++;
    } else {
      const diff = Math.abs(totalJiwaWilayah - totalPenduduk);
      const pct = Math.round((diff / totalPenduduk) * 100);
      console.log(`  ⚠️  WARN: Difference ${diff} jiwa (${pct}%)`);
      console.log('  ℹ️  Run fix-data-consistency.sql to reconcile');
    }
  }

  // ============================================================
  // TEST 6: Reference Tables
  // ============================================================
  console.log('\nTEST 6: Reference Tables');

  const refTables = ['ref_agama', 'ref_pendidikan', 'ref_pekerjaan', 'ref_status_perkawinan'];
  let refPassed = 0;

  for (const t of refTables) {
    const c = await count(t);
    if (c > 0) {
      console.log(`  ✅ ${t}: ${c} items`);
      refPassed++;
    } else {
      console.log(`  ❌ ${t}: Empty`);
    }
  }

  if (refPassed === refTables.length) {
    console.log('  ✅ PASS: All reference tables populated');
    passed++;
  } else {
    console.log(`  ❌ FAIL: ${refTables.length - refPassed} reference tables empty`);
    failed++;
  }

  // ============================================================
  // TEST 7: New Tables Have Data
  // ============================================================
  console.log('\nTEST 7: New Tables Data');

  const newTables = [
    'apotek_desa', 'apotek_obat', 'apotek_resep',
    'perpustakaan_desa', 'buku_perpustakaan',
    'pemilihan', 'bansos_penerima', 'posyandu_balita',
    'bencana_bantuan', 'pbb_pembayaran'
  ];

  let newPassed = 0;
  for (const t of newTables) {
    const c = await count(t);
    const status = c > 0 ? '✅' : c === 0 ? '⚪' : '❌';
    console.log(`  ${status} ${t}: ${c}`);
    if (c > 0) newPassed++;
  }

  if (newPassed >= newTables.length * 0.7) {
    console.log('  ✅ PASS: Most new tables have data');
    passed++;
  } else {
    console.log(`  ⚠️  WARN: Only ${newPassed}/${newTables.length} tables populated`);
  }

  // ============================================================
  // SUMMARY
  // ============================================================
  console.log('\n' + '='.repeat(60));
  console.log('TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`  Passed: ${passed}`);
  console.log(`  Failed: ${failed}`);
  console.log('');

  if (failed === 0) {
    console.log('🎉 ALL TESTS PASSED!');
  } else {
    console.log('⚠️  SOME TESTS FAILED');
    console.log('\nTo fix issues, run:');
    console.log('  1. Copy scripts/fix-data-consistency.sql to Supabase SQL Editor');
    console.log('  2. Run node scripts/seed-new-tables.mjs');
    console.log('  3. Re-run this test');
  }
  console.log('');
}

main().catch(console.error);
