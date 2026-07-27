-- ============================================================
-- MIGRASI: 20260727000001_add_penerima_bansos_columns.sql
-- Tanggal: 2026-07-27
-- Deskripsi: Tambahkan kolom tanggal_salur dan tanggal_daftar
--            ke tabel penerima_bansos. Kolom-kolom ini
--            digunakan oleh PenerimaBansosTable di AdminOps.tsx
--            tetapi belum ada di schema database.
-- ============================================================

-- Add tanggal_salur: tanggal penyaluran bantuan sosial
ALTER TABLE public.penerima_bansos
  ADD COLUMN IF NOT EXISTS tanggal_salur DATE;

-- Add tanggal_daftar: tanggal pendaftaran penerima bansos
ALTER TABLE public.penerima_bansos
  ADD COLUMN IF NOT EXISTS tanggal_daftar DATE DEFAULT CURRENT_DATE;

-- Verifikasi kolom telah ditambahkan
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'penerima_bansos'
  AND column_name IN ('tanggal_salur', 'tanggal_daftar');
