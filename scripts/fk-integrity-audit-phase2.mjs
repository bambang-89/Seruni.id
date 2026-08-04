// Phase 2: Deep investigation of issues found
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  realtime: { transport: 'ws' }
});

// ─────────────────────────────────────────────────────────────
// Test each "missing" table with verbose error output
// ─────────────────────────────────────────────────────────────
async function testTable(table) {
  const { data, error, count } = await supabase
    .from(table)
    .select('*', { count: 'exact', head: true })
    .limit(1);
  return { data, error, count };
}

// ─────────────────────────────────────────────────────────────
// Get column names for a table (try a select *)
// ─────────────────────────────────────────────────────────────
async function getColumns(table) {
  try {
    const { data, error } = await supabase
      .from(table)
      .select('*')
      .limit(1);
    if (error) return { columns: null, error };
    if (!data || data.length === 0) {
      // Try getting just count to confirm table exists
      const { count } = await supabase
        .from(table)
        .select('*', { count: 'exact', head: true });
      return { columns: null, error, count };
    }
    return { columns: Object.keys(data[0] || {}), error: null };
  } catch (e) {
    return { columns: null, error: e };
  }
}

// ─────────────────────────────────────────────────────────────
// Count nulls for a UUID/text column
// ─────────────────────────────────────────────────────────────
async function countNulls(table, col) {
  // Approach: get all IDs + the FK column, classify in JS
  try {
    const { data, error } = await supabase
      .from(table)
      .select('id')
      .limit(200000);
    if (error) return { nulls: -1, total: -1, error: error.message };

    const total = data.length;

    // Now get FK column values
    const { data: fkData } = await supabase
      .from(table)
      .select(col)
      .limit(200000);
    if (fkData) {
      const nulls = fkData.filter(r => r[col] === null).length;
      return { nulls, total, error: null };
    }
    return { nulls: -1, total, error: 'could not fetch FK column' };
  } catch (e) {
    return { nulls: -1, total: -1, error: e.message };
  }
}

// ─────────────────────────────────────────────────────────────
// Count orphans for UUID FK
// ─────────────────────────────────────────────────────────────
async function countOrphans(table, fkCol, refTable, refCol = 'id') {
  try {
    // Get all rows where FK is not null
    const { data: fkRows } = await supabase
      .from(table)
      .select(fkCol)
      .not(fkCol, 'is', null)
      .limit(50000);

    if (!fkRows || fkRows.length === 0) return { orphans: 0, sampled: 0, total: -1 };

    const fkVals = [...new Set(fkRows.map(r => r[fkCol]))];

    // Get valid IDs from ref table
    const { data: refRows } = await supabase
      .from(refTable)
      .select(refCol)
      .in(refCol, fkVals);

    const validSet = new Set((refRows || []).map(r => r[refCol]));

    let orphans = 0;
    for (const v of fkVals) {
      if (!validSet.has(v)) orphans++;
    }

    return { orphans, sampled: fkVals.length, total: -1 };
  } catch (e) {
    return { orphans: -1, sampled: -1, error: e.message };
  }
}

// ─────────────────────────────────────────────────────────────
// Check unique column duplicates
// ─────────────────────────────────────────────────────────────
async function checkDuplicates(table, col, sampleSize = 50000) {
  try {
    const { data, error } = await supabase
      .from(table)
      .select(col)
      .not(col, 'is', null)
      .limit(sampleSize);

    if (error) return { duplicates: -1, error: error.message };

    const counts = {};
    for (const r of data) {
      const v = r[col];
      counts[v] = (counts[v] || 0) + 1;
    }

    const dupes = Object.entries(counts).filter(([, c]) => c > 1);
    return {
      total: data.length,
      nulls: 0,
      duplicates: dupes.length,
      samples: dupes.slice(0, 5),
    };
  } catch (e) {
    return { duplicates: -1, error: e.message };
  }
}

// ─────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────
async function main() {
  console.log('FK AUDIT - PHASE 2: DEEP INVESTIGATION');
  console.log('='.repeat(80));

  // ── 1. Investigate "missing" tables ───────────────────────
  console.log('\n1. INVESTIGATING "MISSING" TABLES');
  console.log('-'.repeat(80));
  const missingTables = ['users', 'page_configs', 'warga', 'admin_users'];
  for (const t of missingTables) {
    const result = await testTable(t);
    if (result.error) {
      console.log(`  ${t}: ERROR - code=${result.error.code}, msg=${result.error.message}`);
    } else {
      console.log(`  ${t}: OK - count=${result.count}`);
    }
  }

  // ── 2. Get actual column names for existing tables ───────
  console.log('\n2. ACTUAL COLUMN NAMES FOR EXISTING TABLES');
  console.log('-'.repeat(80));
  const existingTables = ['tenants', 'penduduk', 'keluarga', 'surat_ajuan', 'surat_jenis',
                           'wilayah_dusun', 'domain_events'];
  for (const t of existingTables) {
    const result = await getColumns(t);
    if (result.error) {
      console.log(`  ${t}: ERROR - ${result.error.message}`);
    } else if (result.columns) {
      console.log(`  ${t}: ${result.columns.join(', ')}`);
    } else {
      console.log(`  ${t}: no data, count=${result.count}`);
      // Try selecting specific columns that might exist
      const { data, error } = await supabase.from(t).select('*').limit(1);
      if (error) {
        console.log(`         ERROR: ${error.message}`);
      } else {
        console.log(`         columns: ${Object.keys(data[0] || {}).join(', ')}`);
      }
    }
  }

  // ── 3. Re-check NULL counts for UUID/text columns ────────
  console.log('\n3. NULL / ORPHAN COUNTS FOR UUID-FK COLUMNS');
  console.log('-'.repeat(80));

  const uuidChecks = [
    { tbl: 'penduduk',      col: 'kepala_keluarga_id', ref: 'penduduk',    refCol: 'id',       note: '(this column might not exist in penduduk)' },
    { tbl: 'penduduk',      col: 'dusun_id',            ref: 'ref_dusun',  refCol: 'id',       note: '' },
    { tbl: 'penduduk',      col: 'no_kk',               ref: 'keluarga',   refCol: 'no_kk',   note: '' },
    { tbl: 'keluarga',      col: 'kepala_keluarga_id',  ref: 'penduduk',   refCol: 'id',       note: '' },
    { tbl: 'wilayah_dusun', col: 'dusun_id',            ref: 'ref_dusun',  refCol: 'id',       note: '' },
    { tbl: 'surat_ajuan',   col: 'penduduk_id',         ref: 'penduduk',   refCol: 'id',       note: '' },
    { tbl: 'surat_ajuan',   col: 'jenis_id',            ref: 'surat_jenis',refCol: 'id',       note: '' },
    { tbl: 'surat_ajuan',   col: 'dusun_id',            ref: 'ref_dusun',  refCol: 'id',       note: '' },
    { tbl: 'tenants',       col: 'created_by',          ref: 'users',      refCol: 'id',       note: '(users table missing)' },
  ];

  for (const c of uuidChecks) {
    const nullsResult = await countNulls(c.tbl, c.col);
    const orphansResult = await countOrphans(c.tbl, c.col, c.ref, c.refCol);

    const nullStr = nullsResult.nulls >= 0 ? String(nullsResult.nulls) : `ERR(${nullsResult.error || nullsResult.nulls})`;
    const totStr  = nullsResult.total >= 0 ? `/${nullsResult.total}` : '';
    const orpStr  = orphansResult.orphans >= 0 ? String(orphansResult.orphans) : `ERR(${orphansResult.error || orphansResult.orphans})`;
    const note    = c.note ? `  ${c.note}` : '';

    console.log(`  ${c.tbl}.${c.col} -> ${c.ref}`);
    console.log(`    total=${nullsResult.total}${totStr}, nulls=${nullStr}, orphans=${orpStr} (${orphansResult.sampled} vals checked)${note}`);
  }

  // ── 4. Full penduduk nik / keluarga no_kk check ─────────
  console.log('\n4. FULL PENDUDUK NIK / KELUARGA NO_KK UNIQUE CHECK');
  console.log('-'.repeat(80));

  const dupChecks = [
    { tbl: 'penduduk', col: 'nik' },
    { tbl: 'keluarga',  col: 'no_kk' },
  ];

  for (const c of dupChecks) {
    const result = await checkDuplicates(c.tbl, c.col, 50000);
    if (result.error) {
      console.log(`  ${c.tbl}.${c.col}: ERROR - ${result.error}`);
    } else if (result.duplicates < 0) {
      console.log(`  ${c.tbl}.${c.col}: could not check`);
    } else {
      console.log(`  ${c.tbl}.${c.col}:`);
      console.log(`    checked=${result.total}, duplicates=${result.duplicates}`);
      if (result.duplicates > 0) {
        for (const [v, cnt] of result.samples) {
          console.log(`      "${v}" => ${cnt} rows`);
        }
      }
    }
  }

  // ── 5. Check what columns exist for duplicate checks ─────
  console.log('\n5. TENANTS UNIQUE COLUMN CHECKS');
  console.log('-'.repeat(80));
  const tenantCols = await getColumns('tenants');
  if (tenantCols.columns) {
    console.log(`  tenants columns: ${tenantCols.columns.join(', ')}`);
  }
  // Check slug/domain alternatives
  const possibleTenantUniqueCols = ['slug', 'domain', 'name', 'id'];
  for (const col of possibleTenantUniqueCols) {
    const r = await checkDuplicates('tenants', col, 100);
    if (r.error) {
      console.log(`  tenants.${col}: ERROR - ${r.error}`);
    } else {
      console.log(`  tenants.${col}: total=${r.total}, duplicates=${r.duplicates}`);
      if (r.duplicates > 0) {
        for (const [v, cnt] of r.samples) console.log(`    "${v}" => ${cnt}`);
      }
    }
  }

  // ── 6. Check surat_jenis columns ──────────────────────────
  console.log('\n6. SURAT_JENIS UNIQUE COLUMN CHECKS');
  console.log('-'.repeat(80));
  const sjCols = await getColumns('surat_jenis');
  if (sjCols.columns) {
    console.log(`  surat_jenis columns: ${sjCols.columns.join(', ')}`);
  }
  const possibleSJUniqueCols = ['kode', 'kode_surat', 'nama', 'jenis'];
  for (const col of possibleSJUniqueCols) {
    const r = await checkDuplicates('surat_jenis', col, 100);
    if (r.error) {
      console.log(`  surat_jenis.${col}: ERROR - ${r.error}`);
    } else {
      console.log(`  surat_jenis.${col}: total=${r.total}, duplicates=${r.duplicates}`);
      if (r.duplicates > 0) {
        for (const [v, cnt] of r.samples) console.log(`    "${v}" => ${cnt}`);
      }
    }
  }

  // ── 7. Check for any other hidden tables via probing ──────
  console.log('\n7. PROBING FOR ADDITIONAL TABLES');
  console.log('-'.repeat(80));
  const candidates = [
    'akta_kelahiran', 'akta_kematian', 'akta_perkawinan', 'akta_cerai',
    'surat_tiket', 'statistik_desa', 'lampirans', 'klasifikasi_surat',
    'alur_surat', 'tenant_settings', 'profile', 'user_profiles',
    'kategori_surat', 'log_aktivitas', 'audit_log', 'notifications',
    'penduduk_history', 'keluarga_history', 'migrations',
  ];
  for (const t of candidates) {
    const { data, error, count } = await supabase
      .from(t)
      .select('*', { count: 'exact', head: true })
      .limit(1);
    if (!error) {
      console.log(`  FOUND: ${t} (count=${count})`);
    }
  }

  // ── 8. Check domain_events columns and orphan check ─────
  console.log('\n8. DOMAIN_EVENTS DETAILED CHECK');
  console.log('-'.repeat(80));
  const deCols = await getColumns('domain_events');
  if (deCols.columns) {
    console.log(`  domain_events columns: ${deCols.columns.join(', ')}`);
    // Check for event_type duplicates
    if (deCols.columns.includes('event_type')) {
      const { data } = await supabase.from('domain_events').select('event_type').limit(20000);
      if (data) {
        const counts = {};
        for (const r of data) counts[r.event_type] = (counts[r.event_type] || 0) + 1;
        console.log('  domain_events.event_type distribution:');
        for (const [k, v] of Object.entries(counts)) {
          console.log(`    ${k}: ${v}`);
        }
      }
    }
  }

  // Check domain_events for orphans
  const deTenant = await countOrphans('domain_events', 'tenant_id', 'tenants', 'id');
  console.log(`  domain_events.tenant_id orphans: ${deTenant.orphans >= 0 ? deTenant.orphans : 'ERR'}`);

  // ── 9. Check if all-NULL columns were ever populated ─────
  console.log('\n9. ALL-NULL COLUMN ANALYSIS');
  console.log('-'.repeat(80));
  console.log('  These columns are ALL NULL in penduduk (7889 rows):');
  console.log('  - warga_negara_id -> ref_warga_negara (11 options exist, but 0 used)');
  console.log('  - golongan_darah_id -> ref_golongan_darah (9 options exist, but 0 used)');
  console.log('  Implication: nationality and blood type data was never imported/entered for any penduduk.');
  console.log('  Recommendation: Add data migration to populate from existing data columns if they exist.');

  // Check if there are alternative columns in penduduk that might hold this data
  const pendCols = await getColumns('penduduk');
  if (pendCols.columns) {
    console.log(`\n  All penduduk columns: ${pendCols.columns.join(', ')}`);
  }
}

main().catch(console.error);
