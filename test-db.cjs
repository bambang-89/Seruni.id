const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://smmngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ'
);

async function test() {
  console.log('=== Testing Supabase Connection ===\n');
  
  // Test 1: Check tenants
  const { data: tenants, error: e1 } = await supabase.from('tenants').select('*');
  console.log('1. tenants:', tenants?.length || 0, 'rows', e1 ? '(ERROR: ' + e1.message + ')' : 'OK');
  
  // Test 2: Check some domain tables
  const tables = ['penduduk', 'keluarga', 'surat_terbit', 'voting_topik', 'apbdes', 'idm_indicators', 'audit_trail'];
  
  for (const table of tables) {
    const { count, error } = await supabase.from(table).select('*', { count: 'exact', head: true });
    if (error) {
      console.log(`2. ${table}: ERROR - ${error.message}`);
    } else {
      console.log(`   ${table}: ${count} rows`);
    }
  }
  
  // Test 3: Check ref tables
  const refTables = ['ref_agama', 'ref_pendidikan', 'ref_pekerjaan', 'ref_status_perkawinan'];
  console.log('\n3. Reference Tables:');
  for (const table of refTables) {
    const { count, error } = await supabase.from(table).select('*', { count: 'exact', head: true });
    if (error) {
      console.log(`   ${table}: MISSING (${error.message})`);
    } else {
      console.log(`   ${table}: ${count} rows`);
    }
  }
  
  console.log('\n=== Done ===');
}

test().catch(console.error);
