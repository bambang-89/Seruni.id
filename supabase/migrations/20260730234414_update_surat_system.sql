-- Masalah #3: Tambah kolom instansi_tujuan
ALTER TABLE public.surat_ajuan ADD COLUMN IF NOT EXISTS instansi_tujuan VARCHAR(255);
ALTER TABLE public.surat_terbit ADD COLUMN IF NOT EXISTS instansi_tujuan VARCHAR(255);

-- Masalah #5: Tambah kolom template_html pada surat_jenis
ALTER TABLE public.surat_jenis ADD COLUMN IF NOT EXISTS template_html TEXT;

-- Refresh PostgREST schema cache implicitly
NOTIFY pgrst, 'reload schema';
