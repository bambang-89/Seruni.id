-- ============================================================
-- MIGRASI: 20260721000001_restore_missing_objects.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Restaurasi objek dari 002_reference_tables.sql yang gagal
--            karena syntax error di enum CREATE TYPE. Semua objek
--            tetap belum terbuat di DB meskipun migration sudah tercatat.
--            Sekarang dibuat ulang di versi baru.
-- ============================================================

-- 1. Enum ref_jenis_kelamin
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ref_jenis_kelamin') THEN
    CREATE TYPE ref_jenis_kelamin AS ENUM ('L', 'P');
  END IF;
END $$;

-- 2. Enum app_peran
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_peran') THEN
    CREATE TYPE app_peran AS ENUM ('admin', 'kades', 'sekdes', 'admin_keuangan', 'admin_kesehatan', 'kader_posyandu', 'dinas_pmd');
  END IF;
END $$;

-- 3. user_peran table
CREATE TABLE IF NOT EXISTS user_peran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  peran app_peran NOT NULL,
  dusun_id UUID,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, peran)
);

GRANT SELECT ON user_peran TO authenticated;
GRANT ALL ON user_peran TO service_role;
ALTER TABLE user_peran ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "User read own peran" ON user_peran;
CREATE POLICY "User read own peran" ON user_peran FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Service can manage peran" ON user_peran;
CREATE POLICY "Service can manage peran" ON user_peran FOR ALL TO service_role USING (true);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'user_peran_updated' AND tgrelid = 'public.user_peran'::regclass) THEN
    CREATE TRIGGER user_peran_updated BEFORE UPDATE ON public.user_peran
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- 4. has_peran() function
CREATE OR REPLACE FUNCTION public.has_peran(_user_id UUID, _peran app_peran)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_peran
    WHERE user_id = _user_id AND peran = _peran AND aktif = true
  );
$$;

COMMENT ON FUNCTION public.has_peran IS 'Check if user has specific peran. Usage: SELECT has_peran(auth.uid(), ''kades'')';

-- 5. Seed enum values untuk ref_jenis_kelamin (kalau enum baru dibuat)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ref_jenis_kelamin') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'L' AND enumtypid = 'ref_jenis_kelamin'::regtype) THEN
      ALTER TYPE ref_jenis_kelamin ADD VALUE 'L';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'P' AND enumtypid = 'ref_jenis_kelamin'::regtype) THEN
      ALTER TYPE ref_jenis_kelamin ADD VALUE 'P';
    END IF;
  END IF;
END $$;

-- 6. user_has_tenant_access (dari 004, dipindahkan karena butuh user_peran)
DROP FUNCTION IF EXISTS user_has_tenant_access(UUID, UUID);
CREATE FUNCTION user_has_tenant_access(p_user_id UUID, p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_peran
    WHERE user_id = p_user_id
      AND aktif = true
      AND peran IN ('admin', 'kades', 'sekdes')
  );
$$;

-- 7. tenant_filter (dari 004, dipindahkan karena butuh user_peran)
DROP FUNCTION IF EXISTS tenant_filter(UUID);
CREATE FUNCTION tenant_filter(p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.uid() IS NOT NULL
    AND (
      EXISTS (SELECT 1 FROM public.user_peran WHERE user_id = auth.uid() AND peran = 'admin' LIMIT 1)
      OR
      COALESCE(current_setting('app.current_tenant_id', true)::uuid, p_tenant_id) = p_tenant_id
    );
$$;
