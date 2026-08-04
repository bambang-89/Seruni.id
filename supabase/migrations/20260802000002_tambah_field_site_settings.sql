-- Migration: Tambah field lengkap ke site_settings untuk AdminUmum upgrade
-- Tanggal: 2026-08-02
-- Deskripsi: Menambahkan field website, kodepos, dusun, rt yang diperlukan
--            oleh AdminUmum.tsx versi baru

ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS website text,
  ADD COLUMN IF NOT EXISTS kodepos text,
  ADD COLUMN IF NOT EXISTS dusun text,
  ADD COLUMN IF NOT EXISTS rt text;

-- Verifikasi
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'site_settings'
  AND table_schema = 'public'
ORDER BY ordinal_position;
