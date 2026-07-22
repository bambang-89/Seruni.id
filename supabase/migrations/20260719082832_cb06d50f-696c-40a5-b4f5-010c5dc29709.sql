
-- 1. Enum peran
CREATE TYPE public.app_role AS ENUM ('admin');

-- 2. user_roles
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$$;

CREATE POLICY "Users read own roles" ON public.user_roles
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- 3. admin_profiles
CREATE TABLE public.admin_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nik TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.admin_profiles TO authenticated;
GRANT ALL ON public.admin_profiles TO service_role;
ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin read own profile" ON public.admin_profiles
  FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Admin update own profile" ON public.admin_profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id);
CREATE POLICY "Admin insert own profile" ON public.admin_profiles
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- 4. Trigger auto-create admin_profile + auto-grant admin ke user pertama
CREATE OR REPLACE FUNCTION public.handle_new_admin_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _nik TEXT;
  _nama TEXT;
  _admin_count INT;
BEGIN
  _nik := COALESCE(NEW.raw_user_meta_data->>'nik', '');
  _nama := COALESCE(NEW.raw_user_meta_data->>'nama', 'Admin');
  IF _nik <> '' THEN
    INSERT INTO public.admin_profiles(id, nik, nama) VALUES (NEW.id, _nik, _nama)
      ON CONFLICT (id) DO NOTHING;
  END IF;
  -- User pertama otomatis jadi admin
  SELECT COUNT(*) INTO _admin_count FROM public.user_roles WHERE role = 'admin';
  IF _admin_count = 0 THEN
    INSERT INTO public.user_roles(user_id, role) VALUES (NEW.id, 'admin')
      ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_admin_signup();

-- 5. Fungsi updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

CREATE TRIGGER admin_profiles_updated BEFORE UPDATE ON public.admin_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 6. profil_desa (singleton)
CREATE TABLE public.profil_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  singleton BOOLEAN NOT NULL DEFAULT true UNIQUE,
  sejarah JSONB NOT NULL DEFAULT '[]'::jsonb,
  visi TEXT NOT NULL DEFAULT '',
  misi JSONB NOT NULL DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.profil_desa TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.profil_desa TO authenticated;
GRANT ALL ON public.profil_desa TO service_role;
ALTER TABLE public.profil_desa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read profil" ON public.profil_desa FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write profil" ON public.profil_desa FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER profil_desa_updated BEFORE UPDATE ON public.profil_desa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 7. desa_pamong
CREATE TABLE public.desa_pamong (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  jabatan TEXT NOT NULL,
  periode TEXT,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.desa_pamong TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.desa_pamong TO authenticated;
GRANT ALL ON public.desa_pamong TO service_role;
ALTER TABLE public.desa_pamong ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read pamong" ON public.desa_pamong FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write pamong" ON public.desa_pamong FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER desa_pamong_updated BEFORE UPDATE ON public.desa_pamong
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 8. wilayah_dusun
CREATE TABLE public.wilayah_dusun (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  kk INT NOT NULL DEFAULT 0,
  jiwa INT NOT NULL DEFAULT 0,
  luas_ha NUMERIC(10,2) NOT NULL DEFAULT 0,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.wilayah_dusun TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.wilayah_dusun TO authenticated;
GRANT ALL ON public.wilayah_dusun TO service_role;
ALTER TABLE public.wilayah_dusun ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read dusun" ON public.wilayah_dusun FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write dusun" ON public.wilayah_dusun FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER wilayah_dusun_updated BEFORE UPDATE ON public.wilayah_dusun
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 9. lembaga_desa
CREATE TABLE public.lembaga_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  ketua TEXT NOT NULL,
  jumlah_anggota INT NOT NULL DEFAULT 0,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.lembaga_desa TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.lembaga_desa TO authenticated;
GRANT ALL ON public.lembaga_desa TO service_role;
ALTER TABLE public.lembaga_desa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read lembaga" ON public.lembaga_desa FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write lembaga" ON public.lembaga_desa FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER lembaga_desa_updated BEFORE UPDATE ON public.lembaga_desa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
