import ws from 'ws';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: false, persistSession: false },
  realtime: { transport: ws }
});

// Apply migration via Postgres REST endpoint (pg function)
const sql = `
ALTER TABLE public.surat_ajuan 
  DROP CONSTRAINT IF EXISTS surat_ajuan_status_check;

ALTER TABLE public.surat_ajuan
  ADD CONSTRAINT surat_ajuan_status_check 
  CHECK (status IN (
    'menunggu',
    'diproses',
    'diverifikasi',
    'ditandatangani',
    'selesai',
    'ditolak'
  ));
`;

console.log('Applying migration via pg_execute_sql...');
const { data, error } = await supabase.rpc('pg_execute_sql', { sql_query: sql });
if (error) {
  console.log('RPC pg_execute_sql error:', error.message);
  
  // Fallback: try exec_sql
  const { data: d2, error: e2 } = await supabase.rpc('exec_sql', { query: sql });
  if (e2) {
    console.log('RPC exec_sql error:', e2.message);
    
    // Last resort: try via raw fetch to Management API
    console.log('Trying to apply constraint fix via direct REST...');
    // Test valid statuses by trying each status update
    console.log('\nManual migration needed:');
    console.log('Please run this SQL in your Supabase Dashboard > SQL Editor:');
    console.log('---');
    console.log(sql);
    console.log('---');
  } else {
    console.log('✅ exec_sql success:', d2);
  }
} else {
  console.log('✅ Migration applied:', data);
}
