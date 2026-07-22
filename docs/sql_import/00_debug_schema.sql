-- ============================================================
-- DEBUG: Cek schema keluarga dan penduduk di database Anda
-- Jalankan di Supabase SQL Editor dulu sebelum import
-- ============================================================

-- 1. Cek kolom keluarga
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'keluarga'
ORDER BY ordinal_position;

-- 2. Cek kolom penduduk
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'penduduk'
ORDER BY ordinal_position;

-- 3. Cek apakah ada tenants
SELECT * FROM tenants LIMIT 1;
