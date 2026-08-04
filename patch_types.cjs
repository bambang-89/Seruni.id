const fs = require('fs');
let s = fs.readFileSync('src/integrations/supabase/types.ts', 'utf8');

// Update surat_terbit
s = s.replace(/surat_terbit: \{\s*Row: \{([\s\S]*?)\}/, (match, p1) => {
  if(!p1.includes('instansi_tujuan')) {
    return `surat_terbit: {\n        Row: {\n          instansi_tujuan: string | null\n${p1}}`;
  }
  return match;
});

// Update surat_jenis
s = s.replace(/surat_jenis: \{\s*Row: \{([\s\S]*?)\}/, (match, p1) => {
  if(!p1.includes('template_html')) {
    return `surat_jenis: {\n        Row: {\n          template_html: string | null\n${p1}}`;
  }
  return match;
});

// Add surat_ajuan if missing (for type safety)
if (!s.includes('surat_ajuan: {')) {
  // Let's just add it before surat_terbit
  s = s.replace(/surat_terbit: \{/, `surat_ajuan: {
        Row: {
          id: string
          tenant_id: string
          nomor_tiket: string
          nik: string
          nama: string
          kontak: string
          jenis_surat_id: string | null
          keperluan: string
          instansi_tujuan: string | null
          lampiran: Json | null
          status: string
          dokumen_ktp_url: string | null
          dokumen_kk_url: string | null
          foto_pemohon_url: string | null
          dokumen_pendukung_url: string | null
          created_at: string
          updated_at: string
        }
      },
      surat_ajuan_data: {
        Row: {
          id: string
          tenant_id: string
          surat_ajuan_id: string
          data_dna: Json | null
          data_identitas: Json | null
        }
      },
      surat_terbit: {`);
}

fs.writeFileSync('src/integrations/supabase/types.ts', s);
console.log('Types updated');
