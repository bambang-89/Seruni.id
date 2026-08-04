-- Add HTML Template support to surat_jenis for dynamic printing
ALTER TABLE public.surat_jenis ADD COLUMN IF NOT EXISTS html_template TEXT;

-- Empty out irrelevant DNA fields as requested
-- Since we moved keperluan and instansi_tujuan to the main table,
-- and other things can just be queried directly or aren't needed,
-- we'll just empty required_dna for now to clean up the form.
UPDATE public.surat_jenis SET required_dna = '[]'::jsonb;
