const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join('e:', 'Seruni.id', '.env.local') });

const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Missing URL or KEY", supabaseUrl, supabaseKey);
  process.exit(1);
}

const sb = createClient(supabaseUrl, supabaseKey);

async function wipeData() {
  console.log('Wiping dummy data...');
  
  // Wipe surat data
  const resAjuan = await sb.from('surat_ajuan').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Wiped surat_ajuan:', resAjuan.error ? resAjuan.error : resAjuan.data);

  const resTerbit = await sb.from('surat_terbit').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Wiped surat_terbit:', resTerbit.error ? resTerbit.error : resTerbit.data);

  const resArsip = await sb.from('surat_arsip').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Wiped surat_arsip:', resArsip.error ? resArsip.error : resArsip.data);

  const resAntrean = await sb.from('surat_antrean').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  console.log('Wiped surat_antrean:', resAntrean.error ? resAntrean.error : resAntrean.data);
  
  console.log('Wipe complete!');
}

wipeData();
