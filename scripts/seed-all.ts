/**
 * Seed Database Script
 * Run: npx tsx scripts/seed-all.ts
 */

import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_SERVICE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY not set');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false }
});

async function executeSQL(sql: string): Promise<void> {
  console.log('Executing SQL...');
  const { error } = await supabase.rpc('exec', { sql_query: sql });
  if (error) {
    // Try direct query if RPC not available
    console.log('RPC exec not available, trying alternative...');
    throw error;
  }
}

async function seedFromFile(filePath: string): Promise<void> {
  console.log(`📄 Reading: ${filePath}`);
  const sql = fs.readFileSync(filePath, 'utf-8');

  // Split by semicolon and execute in transaction-like manner
  const statements = sql
    .split(/;\s*\n/)
    .map(s => s.trim())
    .filter(s => s.length > 0 && !s.startsWith('--'));

  console.log(`  Found ${statements.length} SQL statements`);

  for (const statement of statements) {
    try {
      // Use raw query since we have service role
      const { error } = await supabase.query(statement);
      if (error && !error.message.includes('already exists') && !error.message.includes('duplicate')) {
        console.log(`  ⚠️ ${error.message.substring(0, 80)}...`);
      }
    } catch (e: any) {
      // Ignore "already exists" errors
      if (!e.message?.includes('already exists') && !e.message?.includes('duplicate')) {
        console.log(`  ⚠️ ${e.message?.substring(0, 80) || 'Error'}`);
      }
    }
  }
}

async function main() {
  console.log('🚀 Seruni.id Database Seed Script');
  console.log('================================\n');

  // Read seed file
  const seedFile = path.join(process.cwd(), 'supabase', 'migrations', '20260801000001_seed_all_tables.sql');

  if (!fs.existsSync(seedFile)) {
    console.error(`❌ Seed file not found: ${seedFile}`);
    process.exit(1);
  }

  console.log(`📂 Project: ${process.cwd()}`);
  console.log(`🔗 Supabase: ${SUPABASE_URL}\n`);

  try {
    await seedFromFile(seedFile);
    console.log('\n✅ Seed completed!');
  } catch (error) {
    console.error('\n❌ Seed failed:', error);
    process.exit(1);
  }
}

main();
