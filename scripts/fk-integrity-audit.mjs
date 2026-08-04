// FK integrity audit script v2 - more robust
// Run: node scripts/fk-integrity-audit.mjs

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  realtime: { transport: 'ws' }
});

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

async function countRows(table) {
  try {
    const { count, error } = await supabase
      .from(table)
      .select('*', { count: 'exact', head: true });
    if (error) return -1;
    return count ?? -1;
  } catch (e) { return -1; }
}

async function countNulls(table, col) {
  try {
    // Use not().not() to count nulls differently
    const { count, error } = await supabase
      .from(table)
      .select('*', { count: 'exact', head: true })
      .is(col, null);
    if (error) {
      // Fallback: get all values and count nulls
      const { data } = await supabase.from(table).select(col).limit(100000);
      if (!data) return -1;
      return data.filter(r => r[col] === null).length;
    }
    return count ?? -1;
  } catch (e) {
    // Fallback
    const { data } = await supabase.from(table).select(col).limit(100000);
    if (!data) return -1;
    return data.filter(r => r[col] === null).length;
  }
}

async function countOrphans(table, fkCol, refTable, refCol = 'id') {
  try {
    // Get all rows where FK is not null, up to 10000
    const { data, error } = await supabase
      .from(table)
      .select(fkCol)
      .not(fkCol, 'is', null)
      .limit(10000);

    if (error || !data) return -1;
    if (data.length === 0) return 0;

    const fkValues = data.map(r => r[fkCol]);
    // Deduplicate
    const uniqueVals = [...new Set(fkValues)];

    // Get valid IDs from ref table
    const { data: refRows } = await supabase
      .from(refTable)
      .select(refCol)
      .in(refCol, uniqueVals);

    const validSet = new Set((refRows || []).map(r => r[refCol]));

    // Count orphans (FK values that don't exist in ref table)
    // Note: data.length may be limited to 10000, so this is a sample
    let orphanCount = 0;
    for (const v of fkValues) {
      if (!validSet.has(v)) orphanCount++;
    }

    // If we hit the limit, note it
    const totalRows = await countRows(table);
    if (data.length < totalRows && totalRows > 10000) {
      return `~${orphanCount} (sampled 10000/${totalRows})`;
    }
    return orphanCount;
  } catch (e) { return -1; }
}

// ─────────────────────────────────────────────────────────────
// TABLE LIST (discovered by probing)
// ─────────────────────────────────────────────────────────────
const ALL_TABLES = [
  'tenants', 'users', 'penduduk', 'keluarga', 'wilayah_dusun',
  'ref_dusun', 'ref_pendidikan', 'ref_pekerjaan', 'ref_agama',
  'ref_status_perkawinan', 'ref_warga_negara', 'ref_golongan_darah',
  'surat_ajuan', 'surat_jenis', 'domain_events', 'page_configs',
  'warga', 'admin_users',
];

// FK definitions - we probe each one and determine the type of issue
// Format: { sourceTable, fkColumn, refTable, refCol }
const FK_DEFINITIONS = [
  // tenants
  { src: 'tenants', col: 'created_by', ref: 'users', refCol: 'id' },

  // users
  { src: 'users', col: 'tenant_id', ref: 'tenants', refCol: 'id' },

  // keluarga
  { src: 'keluarga', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'keluarga', col: 'kepala_keluarga_id', ref: 'penduduk', refCol: 'id' },

  // penduduk
  { src: 'penduduk', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'penduduk', col: 'keluarga_id', ref: 'keluarga', refCol: 'id' },
  { src: 'penduduk', col: 'dusun_id', ref: 'ref_dusun', refCol: 'id' },
  { src: 'penduduk', col: 'agama_id', ref: 'ref_agama', refCol: 'id' },
  { src: 'penduduk', col: 'pendidikan_id', ref: 'ref_pendidikan', refCol: 'id' },
  { src: 'penduduk', col: 'pekerjaan_id', ref: 'ref_pekerjaan', refCol: 'id' },
  { src: 'penduduk', col: 'status_perkawinan_id', ref: 'ref_status_perkawinan', refCol: 'id' },
  { src: 'penduduk', col: 'warga_negara_id', ref: 'ref_warga_negara', refCol: 'id' },
  { src: 'penduduk', col: 'golongan_darah_id', ref: 'ref_golongan_darah', refCol: 'id' },
  { src: 'penduduk', col: 'no_kk', ref: 'keluarga', refCol: 'no_kk' },

  // wilayah_dusun
  { src: 'wilayah_dusun', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'wilayah_dusun', col: 'dusun_id', ref: 'ref_dusun', refCol: 'id' },

  // warga
  { src: 'warga', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'warga', col: 'penduduk_id', ref: 'penduduk', refCol: 'id' },

  // admin_users
  { src: 'admin_users', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'admin_users', col: 'user_id', ref: 'users', refCol: 'id' },

  // surat_ajuan
  { src: 'surat_ajuan', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
  { src: 'surat_ajuan', col: 'penduduk_id', ref: 'penduduk', refCol: 'id' },
  { src: 'surat_ajuan', col: 'jenis_id', ref: 'surat_jenis', refCol: 'id' },
  { src: 'surat_ajuan', col: 'dusun_id', ref: 'ref_dusun', refCol: 'id' },

  // domain_events
  { src: 'domain_events', col: 'tenant_id', ref: 'tenants', refCol: 'id' },

  // page_configs
  { src: 'page_configs', col: 'tenant_id', ref: 'tenants', refCol: 'id' },
];

// Unique columns per table
const UNIQUE_CHECKS = {
  tenants: ['slug', 'domain'],
  users: ['email'],
  penduduk: ['nik'],
  keluarga: ['no_kk'],
  surat_jenis: ['kode'],
  warga: ['email'],
};

// ─────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────
async function main() {
  console.log('FK INTEGRITY AUDIT REPORT');
  console.log('=' .repeat(80));
  console.log(`Supabase: ${SUPABASE_URL}`);
  console.log(`Timestamp: ${new Date().toISOString()}\n`);

  // ── SECTION 1: Table row counts ──────────────────────────────
  console.log('SECTION 1: TABLE ROW COUNTS');
  console.log('-'.repeat(80));
  const counts = {};
  for (const t of ALL_TABLES) {
    const cnt = await countRows(t);
    counts[t] = cnt;
    const exists = cnt >= 0 ? 'EXISTS' : 'MISSING';
    console.log(`  ${t.padEnd(30)} ${String(cnt).padStart(8)} rows  [${exists}]`);
  }

  // Check for any other tables we might have missed
  console.log('\n  Probing for additional tables...');
  const extraTables = [];
  for (const name of ['akta_kelahiran', 'akta_kematian', 'akta_perkawinan', 'akta_cerai',
                      'surat_tiket', 'statistik_desa', 'surat_template', 'lampirans',
                      'klasifikasi_surat', 'alur_surat', 'tenant_settings']) {
    const c = await countRows(name);
    if (c >= 0) {
      extraTables.push({ name, count: c });
      counts[name] = c;
    }
  }
  if (extraTables.length > 0) {
    console.log('  Found additional tables:');
    for (const t of extraTables) {
      console.log(`    ${t.name.padEnd(30)} ${String(t.count).padStart(8)} rows`);
    }
  } else {
    console.log('  No additional tables found.');
  }

  // ── SECTION 2: Ref tables data check ──────────────────────
  console.log('\nSECTION 2: REFERENCE TABLES DATA CHECK');
  console.log('-'.repeat(80));
  const refTables = [
    'ref_dusun', 'ref_pendidikan', 'ref_pekerjaan', 'ref_agama',
    'ref_status_perkawinan', 'ref_warga_negara', 'ref_golongan_darah'
  ];
  for (const rt of refTables) {
    const cnt = counts[rt] ?? await countRows(rt);
    const status = cnt === 0 ? 'EMPTY' : cnt > 0 ? 'HAS DATA' : 'MISSING';
    console.log(`  ${rt.padEnd(30)} ${String(cnt).padStart(8)} rows  [${status}]`);
  }

  // ── SECTION 3: FK Integrity ─────────────────────────────────
  console.log('\nSECTION 3: FOREIGN KEY INTEGRITY');
  console.log('-'.repeat(80));
  console.log(
    '| Source Table         | FK Column                | Ref Table          | Total  | NULL Cnt | Orphan Cnt | Status      |'
  );
  console.log('|' + '-'.repeat(21) + '|' + '-'.repeat(25) + '|' + '-'.repeat(20) + '|' + '-'.repeat(7) + '|' + '-'.repeat(9) + '|' + '-'.repeat(11) + '|' + '-'.repeat(13) + '|');

  const fkResults = [];
  for (const fk of FK_DEFINITIONS) {
    const total = counts[fk.src] ?? await countRows(fk.src);
    let nullCount = -1;
    let orphanCount = -1;

    if (total >= 0) {
      nullCount = await countNulls(fk.src, fk.col);
      orphanCount = await countOrphans(fk.src, fk.col, fk.ref, fk.refCol);
    }

    let status = 'N/A';
    if (total >= 0) {
      if (typeof orphanCount === 'number' && orphanCount > 0) status = 'HAS_ORPHANS';
      else if (nullCount === total) status = 'ALL_NULL';
      else if (nullCount > 0 && (typeof orphanCount !== 'number' || orphanCount === 0)) status = 'OK_NULLS';
      else if (orphanCount === 0) status = 'OK';
      else if (orphanCount === -1) status = 'ERR_CHECK';
    } else {
      status = 'TABLE_MISSING';
    }

    fkResults.push({ ...fk, total, nullCount, orphanCount, status });

    const sTot = total >= 0 ? String(total) : 'N/A';
    const sNul = nullCount >= 0 ? String(nullCount) : 'N/A';
    const sOrp = typeof orphanCount === 'number' ? String(orphanCount) : String(orphanCount);
    console.log(
      `| ${fk.src.padEnd(21)} | ${(fk.src + '.' + fk.col).padEnd(25)} | ${fk.ref.padEnd(20)} | ${sTot.padStart(6)} | ${sNul.padStart(8)} | ${sOrp.padStart(10)} | ${status.padEnd(12)} |`
    );
  }

  // ── SECTION 4: Duplicate unique columns ─────────────────────
  console.log('\nSECTION 4: DUPLICATE VALUES IN UNIQUE COLUMNS');
  console.log('-'.repeat(80));
  for (const [table, cols] of Object.entries(UNIQUE_CHECKS)) {
    const total = counts[table] ?? -1;
    if (total < 0) {
      console.log(`  [SKIP] ${table}: table not found`);
      continue;
    }
    for (const col of cols) {
      try {
        const { data, error } = await supabase
          .from(table)
          .select(col)
          .not(col, 'is', null)
          .limit(50000);

        if (error || !data) {
          console.log(`  [ERR]  ${table}.${col}: ${error?.message || 'no data'}`);
          continue;
        }

        const counts_map = {};
        for (const row of data) {
          const v = row[col];
          if (v !== null) counts_map[v] = (counts_map[v] || 0) + 1;
        }

        const duplicates = Object.entries(counts_map).filter(([, c]) => c > 1);
        if (duplicates.length > 0) {
          console.log(`  [DUPE] ${table}.${col}: ${duplicates.length} duplicate value(s)`);
          for (const [val, cnt] of duplicates.slice(0, 5)) {
            console.log(`         value="${val}" appears ${cnt} times`);
          }
          if (duplicates.length > 5) {
            console.log(`         ... and ${duplicates.length - 5} more`);
          }
        } else {
          console.log(`  [OK]   ${table}.${col}: no duplicates (${data.length} rows checked)`);
        }
      } catch (e) {
        console.log(`  [ERR]  ${table}.${col}: ${e.message}`);
      }
    }
  }

  // ── SECTION 5: penduduk NIK / keluarga no_kk full scan ─────
  console.log('\nSECTION 5: PENDUDUK NIK / KELUARGA NO_KK FULL CHECK');
  console.log('-'.repeat(80));
  for (const [table, col] of [['penduduk', 'nik'], ['keluarga', 'no_kk']]) {
    const total = counts[table] ?? -1;
    if (total < 0) continue;
    try {
      const { data } = await supabase.from(table).select(col).limit(50000);
      if (!data) continue;
      const nulls = data.filter(r => r[col] === null).length;
      const counts_map = {};
      for (const row of data) {
        if (row[col] !== null) {
          counts_map[row[col]] = (counts_map[row[col]] || 0) + 1;
        }
      }
      const dupes = Object.entries(counts_map).filter(([, c]) => c > 1);
      console.log(`  ${table}.${col}:`);
      console.log(`    total=${data.length}${total > data.length ? ` (sampled ${data.length}/${total})` : ''}, null=${nulls}, duplicates=${dupes.length}`);
      if (dupes.length > 0) {
        for (const [v, c] of dupes.slice(0, 5)) {
          console.log(`      "${v}" => ${c} rows`);
        }
      }
    } catch (e) {
      console.log(`  ${table}.${col}: ERROR - ${e.message}`);
    }
  }

  // ── SECTION 6: Special FK concerns ─────────────────────────
  console.log('\nSECTION 6: SPECIAL FK ANALYSIS');
  console.log('-'.repeat(80));

  // Check ref tables referenced by penduduk columns
  const pendudukTotal = counts['penduduk'] ?? -1;
  if (pendudukTotal >= 0) {
    for (const [col, refT] of [
      ['agama_id', 'ref_agama'],
      ['warga_negara_id', 'ref_warga_negara'],
      ['golongan_darah_id', 'ref_golongan_darah'],
      ['status_perkawinan_id', 'ref_status_perkawinan'],
    ]) {
      const nulls = await countNulls('penduduk', col);
      const refCount = counts[refT] ?? await countRows(refT);
      console.log(`  penduduk.${col} -> ${refT}: ${nulls}/${pendudukTotal} NULL (${refCount} ref rows)`);
    }
  }

  // Check if all-NULL ref columns are actually supposed to be nullable
  console.log('\n  Analysis: ALL_NULL FK columns in penduduk');
  console.log('  - warga_negara_id: ALL NULL. Is this intentional (no nationality data) or a missing data import?');
  console.log('  - golongan_darah_id: ALL NULL. Is this intentional or a missing data import?');
  console.log('  - agama_id: only 4 NULLs out of 7889 (0.05%). Likely intentional.');

  // Check surat_ajuan distribution
  const suratTotal = counts['surat_ajuan'] ?? -1;
  if (suratTotal >= 0 && suratTotal > 0) {
    const { data: suratData } = await supabase.from('surat_ajuan').select('status, jenis_id').limit(suratTotal);
    if (suratData) {
      const byStatus = {};
      for (const r of suratData) byStatus[r.status] = (byStatus[r.status] || 0) + 1;
      console.log(`\n  surat_ajuan status distribution (${suratData.length} rows):`);
      for (const [s, c] of Object.entries(byStatus)) {
        console.log(`    ${s}: ${c}`);
      }
    }
  }

  // ── SUMMARY ─────────────────────────────────────────────────
  console.log('\n' + '='.repeat(80));
  console.log('SUMMARY');
  console.log('='.repeat(80));
  const orphans = fkResults.filter(r => typeof r.orphanCount === 'number' && r.orphanCount > 0);
  const allNull = fkResults.filter(r => r.total >= 0 && r.nullCount === r.total && r.total > 0);
  const tableMissing = fkResults.filter(r => r.total < 0);
  console.log(`  Tables checked: ${ALL_TABLES.length}`);
  console.log(`  FK relationships audited: ${fkResults.length}`);
  console.log(`  FKs with orphans: ${orphans.length}`);
  console.log(`  FKs all-NULL (likely missing data): ${allNull.length}`);
  console.log(`  FKs pointing to missing tables: ${tableMissing.length}`);

  if (orphans.length > 0) {
    console.log('\n  FKs WITH ORPHANS:');
    for (const r of orphans) {
      console.log(`    - ${r.src}.${r.col} -> ${r.ref} (${r.orphanCount} orphan rows)`);
    }
  }
  if (allNull.length > 0) {
    console.log('\n  ALL-NULL FKs (no data in FK column):');
    for (const r of allNull) {
      console.log(`    - ${r.src}.${r.col} -> ${r.ref} (${r.total} rows, all NULL)`);
    }
  }
  if (tableMissing.length > 0) {
    console.log('\n  FKs TO MISSING TABLES:');
    for (const r of tableMissing) {
      console.log(`    - ${r.src}.${r.col} -> ${r.ref} [table ${r.ref} does not exist]`);
    }
  }

  if (orphans.length === 0 && allNull.length === 0 && tableMissing.length === 0) {
    console.log('\n  NO INTEGRITY ISSUES FOUND.');
  }
}

main().catch(console.error);
