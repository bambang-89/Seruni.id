import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config({ path: path.join(process.cwd(), '.env') });

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || 'dummy';
const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
    const { data: jenis, error: e1 } = await supabase.from('surat_jenis').select('*').eq('kode_surat', '300.0');
    console.log('Jenis:', jenis, e1);
    
    if (jenis && jenis.length > 0) {
        const { data: dna, error: e2 } = await supabase.from('surat_jenis_dna').select('*').eq('jenis_surat_id', jenis[0].id);
        console.log('DNA Fields for 300.0:', dna, e2);
    }
}
check();
