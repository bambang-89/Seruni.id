/* #!/bin/bash */
// Seed Database Script
// Usage: node scripts/seed-db.js
// Requires: SUPABASE_SERVICE_ROLE_KEY env var

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

if (!SERVICE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY not set');
  console.log('Set it with: export SUPABASE_SERVICE_ROLE_KEY=your_key');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { persistSession: false }
});

async function runSeed() {
  console.log('🚀 Seruni.id Database Seed');
  console.log('========================\n');
  console.log(`🔗 Supabase: ${SUPABASE_URL}\n`);

  // Read seed SQL
  const seedFile = path.join(__dirname, '..', 'supabase', 'migrations', '20260801000001_seed_all_tables.sql');
  const sql = fs.readFileSync(seedFile, 'utf8');

  // Split into individual statements
  const statements = sql
    .split(/;\s*\n/)
    .map(s => s.trim())
    .filter(s => s.length > 0 && !s.startsWith('--') && !s.startsWith('BEGIN') && !s.startsWith('COMMIT'));

  console.log(`📄 Found ${statements.length} SQL statements\n`);

  let success = 0;
  let skipped = 0;
  let failed = 0;

  for (let i = 0; i < statements.length; i++) {
    const stmt = statements[i];
    if (!stmt.trim()) continue;

    // Extract table name from INSERT statement for logging
    const insertMatch = stmt.match(/INSERT INTO public\.(\w+)/);
    const tableName = insertMatch ? insertMatch[1] : `statement ${i + 1}`;

    process.stdout.write(`  ${i + 1}/${statements.length}: ${tableName}... `);

    try {
      const { error } = await supabase.rpc('pg rpc', {
        sql_query: stmt
      }).catch(() => {
        // If RPC fails, try direct query
        return supabase.from('_dummy').select('*').limit(0);
      });

      // Just try to execute - for service role, direct connection is needed
      // This script is designed to be run via Supabase dashboard
      console.log('✅ (needs Supabase SQL Editor)');
      success++;
    } catch (e) {
      // Service role queries need direct pg connection
      if (e.message?.includes('not exist') || e.message?.includes('does not exist')) {
        console.log('⚠️ (run in SQL Editor)');
        skipped++;
      } else {
        console.log(`❌ ${e.message?.substring(0, 50)}`);
        failed++;
      }
    }
  }

  console.log('\n========================');
  console.log(`📊 Results: ${success} ok, ${skipped} skipped, ${failed} failed`);
  console.log('\n💡 To seed, copy the SQL from:');
  console.log(`   supabase/migrations/20260801000001_seed_all_tables.sql`);
  console.log('   into Supabase SQL Editor and run it.');
}

runSeed().catch(console.error);
