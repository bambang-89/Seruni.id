import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';

const env = Object.fromEntries(fs.readFileSync('.env', 'utf8').split('\n').map(l => l.split('=').map(s => s.trim().replace(/['"]/g, ''))));
const s = createClient(env['VITE_SUPABASE_URL'] || 'http://127.0.0.1:54321', env['SUPABASE_SERVICE_ROLE_KEY'] || env['VITE_SUPABASE_ANON_KEY'] || 'dummy');

s.from('surat_jenis_dna').select('kode_surat, field_name, options').not('options', 'is', null).then(res => console.log(JSON.stringify(res.data, null, 2)));
