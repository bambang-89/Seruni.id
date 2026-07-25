-- ============================================================
-- 20260727000002_column_mismatches.sql
-- profil_desa: add image cols
-- stunting_agregat: add bulan column
-- ============================================================

-- 1. profil_desa image columns
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS gambar_hero_url TEXT;
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS gambar_logo_url TEXT;
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS video_url TEXT;

-- 2. stunting_agregat.bulan
ALTER TABLE public.stunting_agregat ADD COLUMN IF NOT EXISTS bulan VARCHAR(20);
UPDATE stunting_agregat SET bulan = to_char(periode, 'YYYY-MM') WHERE bulan IS NULL;
