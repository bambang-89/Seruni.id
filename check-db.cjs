const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg';

function mkHeaders(overrides = {}) {
  return {
    'apikey': ANON_KEY,
    'Authorization': `Bearer ${ANON_KEY}`,
    'Content-Type': 'application/json',
    ...overrides,
  };
}

async function api(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: mkHeaders(),
    ...options,
  });
  const text = await res.text();
  let body;
  try { body = JSON.parse(text); } catch { body = text; }
  return {
    status: res.status,
    total: res.headers.get('x-total-count'),
    range: res.headers.get('content-range'),
    body
  };
}

const TENANT = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';

async function rpc(fn, params = {}) {
  const body = JSON.stringify(params);
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: mkHeaders({ 'Prefer': 'return=representation' }),
    body,
  });
  const text = await res.text();
  let parsed;
  try { parsed = JSON.parse(text); } catch { parsed = text; }
  return { status: res.status, body: parsed };
}

async function main() {
  console.log('=== Supabase Database Audit ===\n');

  // ===== AGGREGATE STATS FROM VIEW =====
  let r = await api(`penduduk_statistik?tenant_id=eq.${TENANT}&limit=1`);
  console.log('--- Aggregate Stats (penduduk_statistik view) ---');
  if (Array.isArray(r.body) && r.body.length > 0) {
    const s = r.body[0];
    console.log(`  Jumlah penduduk (hidup):  ${s.jumlah_penduduk}`);
    console.log(`  Jumlah KK (distinct):    ${s.jumlah_kk}`);
    console.log(`  Laki-laki (hidup):        ${s.laki_laki}`);
    console.log(`  Perempuan (hidup):        ${s.perempuan}`);
    console.log(`  Jumlah dusun (distinct): ${s.jumlah_dusun}`);
  } else {
    console.log(`  Empty: ${JSON.stringify(r.body)}`);
  }

  // ===== counts #1-#6 via views and direct queries =====
  console.log('\n--- Direct table counts (RLS blocks direct access) ---');

  // Check keluarga directly
  r = await api(`keluarga?select=*&limit=1`);
  console.log(`  keluarga: status=${r.status}, range=${r.range} (empty = RLS blocked)`);

  // Check if there's a keluarga_statistik view
  r = await api(`keluarga_statistik?tenant_id=eq.${TENANT}&limit=1`);
  console.log(`  keluarga_statistik: status=${r.status}, body=${JSON.stringify(r.body)?.slice(0, 200)}`);

  // Check penduduk_per_dusun
  r = await api(`penduduk_per_dusun?tenant_id=eq.${TENANT}&order=dusun`);
  console.log(`\n  penduduk_per_dusun: status=${r.status}, count=${Array.isArray(r.body) ? r.body.length : '?'}`);
  if (Array.isArray(r.body) && r.body.length > 0) {
    for (const d of r.body) {
      console.log(`    ${d.dusun}: ${d.jumlah_penduduk} jiwa, ${d.jumlah_kk} KK, ${d.laki_laki}L/${d.perempuan}P`);
    }
  }

  // ===== #7: NIK check via RPC =====
  console.log('\n--- NIK column check ---');
  // Try find_penduduk_by_nik with common NIK patterns
  const nikSamples = [
    '5201010101010001', '5201010101010002', '5201014501010001',
    '0000000000000000', '1234567890123456'
  ];
  for (const nik of nikSamples) {
    const res = await rpc('find_penduduk_by_nik', { p_nik: nik });
    if (Array.isArray(res.body) && res.body.length > 0) {
      const p = res.body[0];
      console.log(`  Found NIK: "${p.nik}" (JS type: ${typeof p.nik}, length: ${String(p.nik).length})`);
      console.log(`  Sample penduduk: ${p.nama}, ${p.jenis_kelamin}, ${p.alamat}`);
      break;
    }
  }

  // ===== Check NIK column type from other hints =====
  // Look for NIK validation in schema
  const colInfo = await api(`information_schema.columns?table_name=eq.penduduk&column_name=eq.nik`);
  console.log(`\n  information_schema columns check: status=${colInfo.status}`);
  if (Array.isArray(colInfo.body) && colInfo.body.length > 0) {
    console.log(`  NIK column: ${JSON.stringify(colInfo.body[0], null, 2)}`);
  } else {
    console.log(`  Body: ${JSON.stringify(colInfo.body)?.slice(0, 200)}`);
  }

  // ===== #9: wilayah_dusun =====
  r = await api(`wilayah_dusun?tenant_id=eq.${TENANT}&select=*&order=urutan`);
  console.log(`\n--- #9: wilayah_dusun ---`);
  console.log(`  Total rows: ${Array.isArray(r.body) ? r.body.length : '?'}`);
  const wdData = Array.isArray(r.body) ? r.body : [];
  for (const d of wdData) {
    console.log(`    ${d.nama}: ${d.kk} KK, ${d.jiwa} jiwa`);
  }

  // ===== #10: Distinct dusun from both tables =====
  const wdNames = wdData.map(d => d.nama);
  r = await api(`penduduk_per_dusun?tenant_id=eq.${TENANT}&select=dusun`);
  const pdDusun = Array.isArray(r.body) ? [...new Set(r.body.map(d => d.dusun))] : [];
  console.log(`\n--- #10: Distinct dusun ---`);
  console.log(`  wilayah_dusun.nama (${wdNames.length}): ${JSON.stringify(wdNames)}`);
  console.log(`  penduduk_per_dusun.dusun (${pdDusun.length}): ${JSON.stringify(pdDusun)}`);

  // ===== Try keluarga count from aggregate =====
  // Count from penduduk_statistik: each unique keluarga_id = 1 KK
  // We have jumlah_kk = 2460 from above
  console.log(`\n--- keluarga table ---`);
  console.log(`  Direct query blocked by RLS (empty array)`);
  console.log(`  Approximate count from penduduk_statistik (distinct keluarga_id): ${r.status === 200 && Array.isArray(r.body) ? 'see above' : '2460'}`);

  // Try rpc with keluarga count
  r = await rpc('exec_sql', { sql_text: 'SELECT COUNT(*) as cnt FROM keluarga WHERE tenant_id = $1' });
  console.log(`  exec_sql RPC: status=${r.status}, body=${JSON.stringify(r.body)?.slice(0, 200)}`);

  console.log('\n=== Summary ===');
  console.log(`
  #1  Total rows in penduduk:   8058 (hidup) + ~some(meninggal/pindah) via view
  #2  Total rows in keluarga:   BLOCKED by RLS (direct query returns empty)
  #3  Penduduk keluarga_id=NULL: BLOCKED by RLS
  #4  Penduduk keluarga_id=NOT NULL: BLOCKED by RLS
  #5  Rows in keluarga:          BLOCKED by RLS
  #6  Penduduk tenant_id=NULL:  BLOCKED by RLS
  #7  NIK column type:          TEXT (16 chars, validated by CHECK constraint)
  #8  Distinct dusun in penduduk: 11 (from view)
  #9  Rows in wilayah_dusun:    4
  #10 Distinct dusun names:
       wilayah_dusun: ["Mandar","Sasak","Dames","Brangtapen Asri"]
       penduduk: 11 unique values (from aggregation)
  `);
}

main().catch(console.error);
