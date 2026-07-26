import fs from 'fs';

const filePath = 'supabase/migrations/20260731000001_surat_template_system.sql';
let content = fs.readFileSync(filePath, 'utf8');

// Replace public.jenis_surat with public.surat_jenis
content = content.replace(/public\.jenis_surat/g, 'public.surat_jenis');
content = content.replace(/public\.jenis_surat_id/g, 'public.surat_jenis_id');
content = content.replace(/p_jenis_surat_id/g, 'p_surat_jenis_id');

// Replace st.jenis with st.jenis_nama
content = content.replace(/st\.jenis\s*=\s*/g, 'st.jenis_nama = ');

fs.writeFileSync(filePath, content);
console.log('✅ Updated table and column names in 20260731000001_surat_template_system.sql');
