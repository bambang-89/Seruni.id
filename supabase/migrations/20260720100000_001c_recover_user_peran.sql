-- ============================================================
-- MIGRASI: 001c_recover_user_peran.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Recovery — remake objek dari 002_reference_tables.sql yang
--            gagal di-commit karena syntax error sebelumnya.
--            Objek: ref_jenis_kelamin enum, app_peran enum,
--            user_peran table, has_peran() function
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
CREATE POLICY "User read own peran" ON user_peran FOR SELECT TO authenticated USING (auth.uid() = user_id);
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
