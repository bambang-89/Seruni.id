-- ============================================================
-- Migration: Add fonnte_token to site_settings, fix kepala_nama
-- ============================================================

-- 1. Tambah kolom fonnte_token ke site_settings (idempoten)
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS fonnte_token text;

-- 2. Tambah singkatan_desa & singkatan_kades ke site_settings jika belum ada
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS singkatan_desa text,
  ADD COLUMN IF NOT EXISTS singkatan_kades text;

-- 3. Tambah kolom fonnte_token ke tenants juga (untuk backward compat)
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS fonnte_token text;

-- 4. Tambah kolom logo yang hilang ke tenants
ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS logo_kabupaten_url text,
  ADD COLUMN IF NOT EXISTS logo_provinsi_url text,
  ADD COLUMN IF NOT EXISTS favicon_url text;

-- 4. Backfill kepala_nama dari data penduduk kepala keluarga
--    (untuk KK yang sudah punya kepala_penduduk_id)
UPDATE public.keluarga k
SET kepala_nama = p.nama
FROM public.penduduk p
WHERE k.kepala_penduduk_id = p.id
  AND (k.kepala_nama IS NULL OR k.kepala_nama = '');
