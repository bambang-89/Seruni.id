-- ============================================================
-- MIGRATION: 20260724000001_admin_password_hash.sql
-- Deskripsi: Tambah kolom password_hash ke admin_profiles
--            untuk auth NIK-based di Next.js
-- ============================================================

-- Tambah kolom password_hash
ALTER TABLE public.admin_profiles
  ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- Set default password (admin123) untuk admin existing
-- Hash bcrypt dari 'admin123' (10 rounds)
UPDATE public.admin_profiles
SET password_hash = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE password_hash IS NULL;

-- Tambah index
CREATE INDEX IF NOT EXISTS idx_admin_profiles_nik ON public.admin_profiles(nik);
CREATE INDEX IF NOT EXISTS idx_admin_profiles_password ON public.admin_profiles(password_hash);

-- Tambah CHECK constraint
ALTER TABLE public.admin_profiles
  ADD CONSTRAINT admin_profiles_password_required
  CHECK (password_hash IS NOT NULL);
