import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
const supabaseKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY || '';

const supabase = createClient(supabaseUrl, supabaseKey);

async function clearData() {
  console.log('Clearing surat_terbit...');
  const res1 = await supabase.from('surat_terbit').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Result:', res1.error ? res1.error : 'Success');

  console.log('Clearing surat_ajuan...');
  const res2 = await supabase.from('surat_ajuan').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Result:', res2.error ? res2.error : 'Success');
}

clearData();
