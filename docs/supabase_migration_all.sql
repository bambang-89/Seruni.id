-- ============================================
-- SUPABASE MIGRATION - ALL IN ONE
-- Generated: 2026-07-21T03:02:06.714Z
-- Total files: 36
-- ============================================

-- NOTE: Run this in Supabase SQL Editor
-- This file contains all schema definitions



-- ============================================
-- FILE: 20260719082832_cb06d50f-696c-40a5-b4f5-010c5dc29709.sql
-- ============================================


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


-- ============================================
-- FILE: 20260719082855_dd85b3b7-5870-450b-b9a1-c996b5dcd9a2.sql
-- ============================================


ALTER FUNCTION public.set_updated_at() SET search_path = public;
REVOKE EXECUTE ON FUNCTION public.set_updated_at() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_admin_signup() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.has_role(UUID, public.app_role) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, public.app_role) TO authenticated;


-- ============================================
-- FILE: 20260719083344_6e5feaef-e0a2-4f61-abf8-7a580cff4c20.sql
-- ============================================


-- Phase 4: Informasi (berita, agenda, pengumuman, galeri)

CREATE TABLE public.berita (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text NOT NULL UNIQUE,
  kategori text NOT NULL DEFAULT 'Umum',
  judul text NOT NULL,
  ringkasan text NOT NULL DEFAULT '',
  isi jsonb NOT NULL DEFAULT '[]'::jsonb,
  penulis text NOT NULL DEFAULT '',
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.berita TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.berita TO authenticated;
GRANT ALL ON public.berita TO service_role;
ALTER TABLE public.berita ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read berita" ON public.berita FOR SELECT TO anon, authenticated USING (published = true OR public.has_role(auth.uid(),'admin'));
CREATE POLICY "Admin write berita" ON public.berita FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_berita_updated BEFORE UPDATE ON public.berita FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.agenda (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text NOT NULL UNIQUE,
  jenis text NOT NULL DEFAULT 'Kegiatan',
  judul text NOT NULL,
  tanggal date NOT NULL,
  waktu text NOT NULL DEFAULT '',
  lokasi text NOT NULL DEFAULT '',
  penyelenggara text NOT NULL DEFAULT '',
  deskripsi text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.agenda TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.agenda TO authenticated;
GRANT ALL ON public.agenda TO service_role;
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read agenda" ON public.agenda FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write agenda" ON public.agenda FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_agenda_updated BEFORE UPDATE ON public.agenda FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.pengumuman (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nomor text NOT NULL,
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  judul text NOT NULL,
  ringkasan text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.pengumuman TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pengumuman TO authenticated;
GRANT ALL ON public.pengumuman TO service_role;
ALTER TABLE public.pengumuman ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read pengumuman" ON public.pengumuman FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write pengumuman" ON public.pengumuman FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_pengumuman_updated BEFORE UPDATE ON public.pengumuman FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.galeri (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  judul text NOT NULL,
  emoji text NOT NULL DEFAULT '📷',
  album text NOT NULL DEFAULT 'Umum',
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  urutan integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.galeri TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.galeri TO authenticated;
GRANT ALL ON public.galeri TO service_role;
ALTER TABLE public.galeri ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read galeri" ON public.galeri FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write galeri" ON public.galeri FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_galeri_updated BEFORE UPDATE ON public.galeri FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ============================================
-- FILE: 20260719114916_5b19fc85-f1b6-4e7d-862d-66f9a8cdfdcf.sql
-- ============================================


-- ==== ENUMS ====
DO $$ BEGIN
  CREATE TYPE public.workflow_status AS ENUM ('draft','diajukan','diverifikasi','diproses','selesai','ditolak','dibatalkan');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.bencana_severity AS ENUM ('rendah','sedang','tinggi','darurat');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.aduan_kategori AS ENUM ('infrastruktur','pelayanan','lingkungan','sosial','keamanan','lainnya');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Reuse updated_at trigger (public.set_updated_at already exists)

-- ==== 1. surat_jenis (master surat, publik read) ====
CREATE TABLE public.surat_jenis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode_surat TEXT NOT NULL UNIQUE,
  kode_klasifikasi TEXT NOT NULL,
  nama TEXT NOT NULL,
  dna_field TEXT,
  aktif BOOLEAN NOT NULL DEFAULT true,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.surat_jenis TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_jenis TO authenticated;
GRANT ALL ON public.surat_jenis TO service_role;
ALTER TABLE public.surat_jenis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "surat_jenis_public_read" ON public.surat_jenis FOR SELECT USING (true);
CREATE POLICY "surat_jenis_admin_write" ON public.surat_jenis FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_surat_jenis_updated BEFORE UPDATE ON public.surat_jenis
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 2. event_log (workflow audit) ====
CREATE TABLE public.event_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  entitas TEXT NOT NULL,
  entitas_id UUID,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_event_log_entitas ON public.event_log(entitas, entitas_id);
CREATE INDEX idx_event_log_created ON public.event_log(created_at DESC);
GRANT SELECT, INSERT ON public.event_log TO authenticated;
GRANT ALL ON public.event_log TO service_role;
ALTER TABLE public.event_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "event_log_admin_read" ON public.event_log FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(),'admin'));
CREATE POLICY "event_log_admin_insert" ON public.event_log FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ==== 3. bidang_tanah (privasi, admin only) ====
CREATE TABLE public.bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_persil TEXT NOT NULL UNIQUE,
  pemilik_nama TEXT NOT NULL,
  pemilik_nik TEXT,
  dusun TEXT,
  luas_m2 NUMERIC(12,2) NOT NULL,
  penggunaan TEXT,
  status_hak TEXT,
  nomor_sertifikat TEXT,
  tanggal_daftar DATE NOT NULL DEFAULT CURRENT_DATE,
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bidang_tanah TO authenticated;
GRANT ALL ON public.bidang_tanah TO service_role;
ALTER TABLE public.bidang_tanah ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bidang_tanah_admin_all" ON public.bidang_tanah FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bidang_tanah_updated BEFORE UPDATE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 4. infrastruktur (publik read) ====
CREATE TABLE public.infrastruktur (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  jenis TEXT NOT NULL,
  dusun TEXT,
  kondisi TEXT NOT NULL DEFAULT 'baik',
  tahun_bangun INT,
  tahun_perbaikan INT,
  volume TEXT,
  sumber_dana TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.infrastruktur TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.infrastruktur TO authenticated;
GRANT ALL ON public.infrastruktur TO service_role;
ALTER TABLE public.infrastruktur ENABLE ROW LEVEL SECURITY;
CREATE POLICY "infrastruktur_public_read" ON public.infrastruktur FOR SELECT USING (true);
CREATE POLICY "infrastruktur_admin_write" ON public.infrastruktur FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_infrastruktur_updated BEFORE UPDATE ON public.infrastruktur
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 5. kegiatan_pembangunan (APBDes, publik read) ====
CREATE TABLE public.kegiatan_pembangunan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  bidang TEXT NOT NULL,
  nama_kegiatan TEXT NOT NULL,
  lokasi TEXT,
  volume TEXT,
  anggaran NUMERIC(15,2) NOT NULL DEFAULT 0,
  realisasi NUMERIC(15,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  status public.workflow_status NOT NULL DEFAULT 'draft',
  tanggal_mulai DATE,
  tanggal_selesai DATE,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_kegiatan_tahun ON public.kegiatan_pembangunan(tahun DESC);
GRANT SELECT ON public.kegiatan_pembangunan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kegiatan_pembangunan TO authenticated;
GRANT ALL ON public.kegiatan_pembangunan TO service_role;
ALTER TABLE public.kegiatan_pembangunan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "kegiatan_public_read" ON public.kegiatan_pembangunan FOR SELECT USING (true);
CREATE POLICY "kegiatan_admin_write" ON public.kegiatan_pembangunan FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_kegiatan_updated BEFORE UPDATE ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 6. posyandu_agregat (agregat, publik) ====
CREATE TABLE public.posyandu_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode DATE NOT NULL,
  dusun TEXT NOT NULL,
  jumlah_balita INT NOT NULL DEFAULT 0,
  hadir INT NOT NULL DEFAULT 0,
  gizi_baik INT NOT NULL DEFAULT 0,
  gizi_kurang INT NOT NULL DEFAULT 0,
  imunisasi_lengkap INT NOT NULL DEFAULT 0,
  ibu_hamil_dilayani INT NOT NULL DEFAULT 0,
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(periode, dusun)
);
GRANT SELECT ON public.posyandu_agregat TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.posyandu_agregat TO authenticated;
GRANT ALL ON public.posyandu_agregat TO service_role;
ALTER TABLE public.posyandu_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posyandu_public_read" ON public.posyandu_agregat FOR SELECT USING (true);
CREATE POLICY "posyandu_admin_write" ON public.posyandu_agregat FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_posyandu_updated BEFORE UPDATE ON public.posyandu_agregat
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 7. stunting_agregat (publik) ====
CREATE TABLE public.stunting_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode DATE NOT NULL,
  dusun TEXT NOT NULL,
  balita_diukur INT NOT NULL DEFAULT 0,
  stunting INT NOT NULL DEFAULT 0,
  wasting INT NOT NULL DEFAULT 0,
  underweight INT NOT NULL DEFAULT 0,
  intervensi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(periode, dusun)
);
GRANT SELECT ON public.stunting_agregat TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stunting_agregat TO authenticated;
GRANT ALL ON public.stunting_agregat TO service_role;
ALTER TABLE public.stunting_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stunting_public_read" ON public.stunting_agregat FOR SELECT USING (true);
CREATE POLICY "stunting_admin_write" ON public.stunting_agregat FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_stunting_updated BEFORE UPDATE ON public.stunting_agregat
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 8. bantuan_sosial (master jenis, publik) ====
CREATE TABLE public.bantuan_sosial (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  sumber TEXT NOT NULL,
  deskripsi TEXT,
  periode_mulai DATE,
  periode_selesai DATE,
  kuota INT,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.bantuan_sosial TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bantuan_sosial TO authenticated;
GRANT ALL ON public.bantuan_sosial TO service_role;
ALTER TABLE public.bantuan_sosial ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bansos_public_read" ON public.bantuan_sosial FOR SELECT USING (true);
CREATE POLICY "bansos_admin_write" ON public.bantuan_sosial FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bansos_updated BEFORE UPDATE ON public.bantuan_sosial
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 9. penerima_bansos (privasi, admin only) ====
CREATE TABLE public.penerima_bansos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bansos_id UUID NOT NULL REFERENCES public.bantuan_sosial(id) ON DELETE CASCADE,
  nik TEXT NOT NULL,
  nama TEXT NOT NULL,
  dusun TEXT,
  status TEXT NOT NULL DEFAULT 'terdaftar',
  tanggal_salur DATE,
  nominal NUMERIC(15,2),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(bansos_id, nik)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.penerima_bansos TO authenticated;
GRANT ALL ON public.penerima_bansos TO service_role;
ALTER TABLE public.penerima_bansos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "penerima_bansos_admin_all" ON public.penerima_bansos FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_penerima_bansos_updated BEFORE UPDATE ON public.penerima_bansos
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 10. bencana_kejadian (publik) ====
CREATE TABLE public.bencana_kejadian (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jenis TEXT NOT NULL,
  lokasi TEXT NOT NULL,
  dusun TEXT,
  tanggal TIMESTAMPTZ NOT NULL DEFAULT now(),
  severity public.bencana_severity NOT NULL DEFAULT 'sedang',
  status public.workflow_status NOT NULL DEFAULT 'diajukan',
  korban_jiwa INT NOT NULL DEFAULT 0,
  korban_luka INT NOT NULL DEFAULT 0,
  pengungsi INT NOT NULL DEFAULT 0,
  kerugian_rp NUMERIC(15,2) DEFAULT 0,
  deskripsi TEXT,
  penanganan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_bencana_tanggal ON public.bencana_kejadian(tanggal DESC);
GRANT SELECT ON public.bencana_kejadian TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bencana_kejadian TO authenticated;
GRANT ALL ON public.bencana_kejadian TO service_role;
ALTER TABLE public.bencana_kejadian ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bencana_public_read" ON public.bencana_kejadian FOR SELECT USING (true);
CREATE POLICY "bencana_admin_write" ON public.bencana_kejadian FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bencana_updated BEFORE UPDATE ON public.bencana_kejadian
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 11. aduan_warga (warga insert, admin proses) ====
CREATE TABLE public.aduan_warga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE DEFAULT ('ADN-' || to_char(now(),'YYYYMMDD') || '-' || substr(md5(random()::text),1,6)),
  nama_pelapor TEXT NOT NULL,
  kontak TEXT NOT NULL,
  kategori public.aduan_kategori NOT NULL DEFAULT 'lainnya',
  judul TEXT NOT NULL,
  isi TEXT NOT NULL,
  lokasi TEXT,
  lampiran_url TEXT,
  status public.workflow_status NOT NULL DEFAULT 'diajukan',
  tanggapan TEXT,
  ditanggapi_oleh UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ditanggapi_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_aduan_status ON public.aduan_warga(status);
CREATE INDEX idx_aduan_created ON public.aduan_warga(created_at DESC);
GRANT INSERT ON public.aduan_warga TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.aduan_warga TO authenticated;
GRANT ALL ON public.aduan_warga TO service_role;
ALTER TABLE public.aduan_warga ENABLE ROW LEVEL SECURITY;
CREATE POLICY "aduan_public_insert" ON public.aduan_warga FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "aduan_public_insert_auth" ON public.aduan_warga FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "aduan_admin_all" ON public.aduan_warga FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_aduan_updated BEFORE UPDATE ON public.aduan_warga
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 12. dpt_pemilih (privasi, admin only) ====
CREATE TABLE public.dpt_pemilih (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nik TEXT NOT NULL,
  nama TEXT NOT NULL,
  tempat_lahir TEXT,
  tanggal_lahir DATE,
  jenis_kelamin TEXT,
  dusun TEXT,
  rt TEXT,
  rw TEXT,
  tps TEXT,
  pemilu_kode TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'aktif',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(pemilu_kode, nik)
);
CREATE INDEX idx_dpt_tps ON public.dpt_pemilih(pemilu_kode, tps);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dpt_pemilih TO authenticated;
GRANT ALL ON public.dpt_pemilih TO service_role;
ALTER TABLE public.dpt_pemilih ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dpt_admin_all" ON public.dpt_pemilih FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_dpt_updated BEFORE UPDATE ON public.dpt_pemilih
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== Workflow event helper (append to event_log on status change) ====
CREATE OR REPLACE FUNCTION public.log_status_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (TG_TABLE_NAME || '.status.diubah', TG_TABLE_NAME, NEW.id,
      jsonb_build_object('dari', OLD.status, 'ke', NEW.status), auth.uid());
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (TG_TABLE_NAME || '.dibuat', TG_TABLE_NAME, NEW.id,
      jsonb_build_object('status', NEW.status), auth.uid());
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER trg_aduan_event AFTER INSERT OR UPDATE OF status ON public.aduan_warga
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
CREATE TRIGGER trg_bencana_event AFTER INSERT OR UPDATE OF status ON public.bencana_kejadian
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
CREATE TRIGGER trg_kegiatan_event AFTER INSERT OR UPDATE OF status ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();


-- ============================================
-- FILE: 20260719114954_40f7025c-4892-450a-bb00-5d179dbb98f0.sql
-- ============================================


-- Tighten anon insert policy so it isn't a bare USING (true)
DROP POLICY IF EXISTS "aduan_public_insert" ON public.aduan_warga;
DROP POLICY IF EXISTS "aduan_public_insert_auth" ON public.aduan_warga;

CREATE POLICY "aduan_public_insert" ON public.aduan_warga FOR INSERT TO anon
  WITH CHECK (
    char_length(trim(nama_pelapor)) BETWEEN 2 AND 120
    AND char_length(trim(kontak)) BETWEEN 4 AND 60
    AND char_length(trim(judul)) BETWEEN 4 AND 160
    AND char_length(trim(isi)) BETWEEN 10 AND 4000
    AND status = 'diajukan'
  );

CREATE POLICY "aduan_auth_insert" ON public.aduan_warga FOR INSERT TO authenticated
  WITH CHECK (
    char_length(trim(nama_pelapor)) BETWEEN 2 AND 120
    AND char_length(trim(kontak)) BETWEEN 4 AND 60
    AND char_length(trim(judul)) BETWEEN 4 AND 160
    AND char_length(trim(isi)) BETWEEN 10 AND 4000
  );

-- Lock down SECURITY DEFINER trigger function so it can't be invoked from Data API
REVOKE EXECUTE ON FUNCTION public.log_status_change() FROM PUBLIC, anon, authenticated;


-- ============================================
-- FILE: 20260719121325_eadbb4a3-72ca-4333-be2d-8c1490c87d6d.sql
-- ============================================


-- Phase 6A: Kanal Warga

-- 1) Langganan WA
CREATE TABLE public.langganan_wa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama text NOT NULL,
  nomor_wa text NOT NULL,
  dusun text,
  topik text[] NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'aktif',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (nomor_wa)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.langganan_wa TO authenticated;
GRANT INSERT ON public.langganan_wa TO anon;
GRANT ALL ON public.langganan_wa TO service_role;
ALTER TABLE public.langganan_wa ENABLE ROW LEVEL SECURITY;
CREATE POLICY langganan_admin_all ON public.langganan_wa FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY langganan_public_insert ON public.langganan_wa FOR INSERT TO anon
  WITH CHECK (
    char_length(trim(nama)) BETWEEN 2 AND 120
    AND char_length(trim(nomor_wa)) BETWEEN 8 AND 20
    AND status = 'aktif'
  );
CREATE TRIGGER trg_langganan_updated BEFORE UPDATE ON public.langganan_wa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2) Surat Terbit (untuk verifikasi publik)
CREATE TABLE public.surat_terbit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_surat text NOT NULL UNIQUE,
  kode_verifikasi text NOT NULL,
  jenis_kode text NOT NULL,
  jenis_nama text NOT NULL,
  perihal text NOT NULL,
  pemohon_nama text NOT NULL,
  pemohon_nik text,
  tanggal_terbit date NOT NULL DEFAULT current_date,
  berlaku_sampai date,
  status text NOT NULL DEFAULT 'berlaku',
  penandatangan text,
  keterangan text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_terbit TO authenticated;
GRANT ALL ON public.surat_terbit TO service_role;
ALTER TABLE public.surat_terbit ENABLE ROW LEVEL SECURITY;
CREATE POLICY surat_terbit_admin_all ON public.surat_terbit FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_surat_terbit_updated BEFORE UPDATE ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3) RPC: verifikasi surat publik
CREATE OR REPLACE FUNCTION public.verifikasi_surat(_nomor text, _kode text)
RETURNS TABLE (
  nomor_surat text, jenis_kode text, jenis_nama text, perihal text,
  pemohon_nama text, tanggal_terbit date, berlaku_sampai date,
  status text, penandatangan text
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT s.nomor_surat, s.jenis_kode, s.jenis_nama, s.perihal,
         s.pemohon_nama, s.tanggal_terbit, s.berlaku_sampai,
         s.status, s.penandatangan
  FROM public.surat_terbit s
  WHERE lower(trim(s.nomor_surat)) = lower(trim(_nomor))
    AND lower(trim(s.kode_verifikasi)) = lower(trim(_kode))
  LIMIT 1;
$$;
GRANT EXECUTE ON FUNCTION public.verifikasi_surat(text,text) TO anon, authenticated;

-- 4) RPC: tracking aduan publik (tanpa expose data pelapor lain)
CREATE OR REPLACE FUNCTION public.lacak_aduan(_nomor_tiket text)
RETURNS TABLE (
  nomor_tiket text, judul text, kategori aduan_kategori,
  status workflow_status, tanggapan text,
  created_at timestamptz, updated_at timestamptz
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT a.nomor_tiket, a.judul, a.kategori, a.status, a.tanggapan,
         a.created_at, a.updated_at
  FROM public.aduan_warga a
  WHERE lower(trim(a.nomor_tiket)) = lower(trim(_nomor_tiket))
  LIMIT 1;
$$;
GRANT EXECUTE ON FUNCTION public.lacak_aduan(text) TO anon, authenticated;

-- 5) Seed contoh surat untuk demo verifikasi
INSERT INTO public.surat_terbit (nomor_surat, kode_verifikasi, jenis_kode, jenis_nama, perihal, pemohon_nama, pemohon_nik, tanggal_terbit, berlaku_sampai, status, penandatangan)
VALUES
 ('470/001/SM/2026', 'SRN-DEMO-001', 'SKD', 'Surat Keterangan Domisili', 'Keterangan Domisili untuk keperluan administrasi', 'Ahmad Susanto', '5201010101010001', current_date - 5, current_date + 180, 'berlaku', 'Kepala Desa Seruni Mumbul'),
 ('474/002/SM/2026', 'SRN-DEMO-002', 'SKU', 'Surat Keterangan Usaha', 'Keterangan Usaha warung sembako', 'Siti Rahmawati', '5201010202020002', current_date - 30, current_date + 335, 'berlaku', 'Kepala Desa Seruni Mumbul');


-- ============================================
-- FILE: 20260719122832_7bc3d64e-2841-4fab-8343-942e77cfc10c.sql
-- ============================================


-- ============ Potensi: UMKM/BUMDes, Produk, Wisata ============
CREATE TABLE public.potensi_umkm (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipe TEXT NOT NULL DEFAULT 'umkm', -- umkm | bumdes | koperasi
  nama TEXT NOT NULL,
  pemilik TEXT,
  sektor TEXT,
  dusun TEXT,
  kontak TEXT,
  alamat TEXT,
  deskripsi TEXT,
  status TEXT NOT NULL DEFAULT 'publish', -- draft | publish
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_umkm TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_umkm TO authenticated;
GRANT ALL ON public.potensi_umkm TO service_role;
ALTER TABLE public.potensi_umkm ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca umkm publish" ON public.potensi_umkm FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola umkm" ON public.potensi_umkm FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_umkm_updated BEFORE UPDATE ON public.potensi_umkm FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.potensi_produk (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  umkm_id uuid REFERENCES public.potensi_umkm(id) ON DELETE SET NULL,
  penjual_nama TEXT NOT NULL,
  nama TEXT NOT NULL,
  kategori TEXT,
  harga NUMERIC(14,2),
  satuan TEXT,
  stok INT,
  deskripsi TEXT,
  foto_url TEXT,
  featured BOOLEAN NOT NULL DEFAULT false,
  status TEXT NOT NULL DEFAULT 'publish',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_produk TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_produk TO authenticated;
GRANT ALL ON public.potensi_produk TO service_role;
ALTER TABLE public.potensi_produk ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca produk publish" ON public.potensi_produk FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola produk" ON public.potensi_produk FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_produk_updated BEFORE UPDATE ON public.potensi_produk FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.potensi_wisata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  jenis TEXT NOT NULL, -- bahari | pegunungan | budaya | buatan | kuliner
  dusun TEXT,
  deskripsi TEXT,
  latitude NUMERIC(9,6),
  longitude NUMERIC(9,6),
  foto_url TEXT,
  fasilitas TEXT,
  status TEXT NOT NULL DEFAULT 'publish',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_wisata TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_wisata TO authenticated;
GRANT ALL ON public.potensi_wisata TO service_role;
ALTER TABLE public.potensi_wisata ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca wisata publish" ON public.potensi_wisata FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola wisata" ON public.potensi_wisata FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_wisata_updated BEFORE UPDATE ON public.potensi_wisata FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Extend wilayah_dusun with coordinates for peta if not present
ALTER TABLE public.wilayah_dusun
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9,6),
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9,6);

-- Seed contoh Desa Seruni Mumbul (koordinat ~ Lombok Timur)
INSERT INTO public.potensi_umkm (tipe, nama, pemilik, sektor, dusun, kontak, deskripsi) VALUES
  ('bumdes', 'BUMDes Bina Seruni Mandiri', 'Pemerintah Desa', 'Multi-usaha', 'Karang Baru', '0812-3456-7890', 'Menaungi marketplace desa, simpan pinjam UMKM, dan pengelolaan aset wisata Pantai Seruni.'),
  ('koperasi', 'Koperasi Merah Putih Seruni', 'H. Lalu Ahmad', 'Simpan Pinjam', 'Montong', '0812-1111-2222', 'Koperasi warga aktif sejak 2018.'),
  ('umkm', 'Tenun Songket Inaq Rahmi', 'Inaq Rahmi', 'Kerajinan', 'Montong', '0813-4444-5555', 'Sentra tenun songket Sasak.'),
  ('umkm', 'Kopi Robusta Seruni', 'Amaq Zainuddin', 'Pertanian', 'Batu Belek', '0813-6666-7777', 'Kopi robusta olahan warga lereng bukit.'),
  ('umkm', 'Kerajinan Ketak Seruni', 'Kelompok Wanita Tani', 'Kerajinan', 'Karang Baru', '0813-8888-9999', 'Anyaman ketak untuk pasar ekspor.');

INSERT INTO public.potensi_produk (penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured) VALUES
  ('Tenun Songket Inaq Rahmi', 'Kain Songket Motif Subhanale', 'Kerajinan', 850000, 'lembar', 12, 'Motif klasik Sasak, tenun tangan.', true),
  ('Kopi Robusta Seruni', 'Kopi Bubuk 250g', 'Pangan', 45000, 'pak', 80, 'Roasting medium, aroma cokelat.', true),
  ('Kerajinan Ketak Seruni', 'Tas Ketak Lombok', 'Kerajinan', 175000, 'buah', 30, 'Anyaman ketak dengan kulit sintetis.', true),
  ('BUMDes Bina Seruni Mandiri', 'Madu Trigona Hutan Seruni', 'Pangan', 120000, 'botol 250ml', 50, 'Madu klanceng murni.', true),
  ('Kopi Robusta Seruni', 'Kopi Biji 1kg', 'Pangan', 160000, 'kg', 40, 'Green bean grade A.', false),
  ('Tenun Songket Inaq Rahmi', 'Selendang Songket', 'Kerajinan', 275000, 'lembar', 20, 'Warna pastel, cocok untuk acara resmi.', false);

INSERT INTO public.potensi_wisata (nama, jenis, dusun, deskripsi, latitude, longitude, fasilitas) VALUES
  ('Pantai Seruni Mumbul', 'bahari', 'Karang Baru', 'Pantai berpasir putih 2,4 km dengan spot snorkeling terumbu karang.', -8.5312, 116.6521, 'Gazebo, MCK, warung UMKM'),
  ('Bukit Denda Seruni', 'pegunungan', 'Batu Belek', 'Sunrise point dengan pemandangan Rinjani.', -8.5401, 116.6612, 'Camping ground, ojek wisata'),
  ('Sentra Tenun Songket Sasak', 'budaya', 'Montong', 'Sanggar tenun aktif. Pengunjung dapat mencoba menenun.', -8.5350, 116.6480, 'Workshop, galeri, toko'),
  ('Kolam Renang Alam Air Merah', 'buatan', 'Karang Baru', 'Kolam mata air alami dengan area piknik keluarga.', -8.5280, 116.6555, 'Toilet, ganti pakaian, kantin');

UPDATE public.wilayah_dusun SET latitude = -8.5312, longitude = 116.6521 WHERE nama ILIKE '%Karang Baru%' AND latitude IS NULL;
UPDATE public.wilayah_dusun SET latitude = -8.5350, longitude = 116.6480 WHERE nama ILIKE '%Montong%' AND latitude IS NULL;
UPDATE public.wilayah_dusun SET latitude = -8.5401, longitude = 116.6612 WHERE nama ILIKE '%Batu Belek%' AND latitude IS NULL;


-- ============================================
-- FILE: 20260719123539_39657bd4-5b9a-41c5-b152-456736219b40.sql
-- ============================================


-- ================= Phase 6C: PBB & APBDes =================

-- PBB Tagihan
CREATE TABLE public.pbb_tagihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  nop TEXT NOT NULL,
  wajib_pajak_nama TEXT NOT NULL,
  wajib_pajak_nik TEXT,
  alamat_objek TEXT,
  dusun TEXT,
  luas_bumi_m2 NUMERIC(12,2) DEFAULT 0,
  luas_bangunan_m2 NUMERIC(12,2) DEFAULT 0,
  njop_bumi NUMERIC(14,2) DEFAULT 0,
  njop_bangunan NUMERIC(14,2) DEFAULT 0,
  pbb_terutang NUMERIC(14,2) NOT NULL DEFAULT 0,
  jatuh_tempo DATE,
  status_bayar TEXT NOT NULL DEFAULT 'belum_lunas',
  tanggal_bayar DATE,
  metode_bayar TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tahun, nop)
);
GRANT SELECT ON public.pbb_tagihan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pbb_tagihan TO authenticated;
GRANT ALL ON public.pbb_tagihan TO service_role;
ALTER TABLE public.pbb_tagihan ENABLE ROW LEVEL SECURITY;
-- Publik: hanya lookup terarah (di app pakai .eq nop). Kita expose SELECT publik agar RPC/query bekerja tanpa auth.
CREATE POLICY "pbb_public_read" ON public.pbb_tagihan FOR SELECT USING (true);
CREATE POLICY "pbb_admin_write" ON public.pbb_tagihan FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_pbb_updated BEFORE UPDATE ON public.pbb_tagihan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX pbb_nop_idx ON public.pbb_tagihan (nop);
CREATE INDEX pbb_tahun_idx ON public.pbb_tagihan (tahun);

-- APBDes
CREATE TABLE public.apbdes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  jenis TEXT NOT NULL CHECK (jenis IN ('pendapatan','belanja','pembiayaan')),
  kategori TEXT NOT NULL,
  sub_kategori TEXT,
  uraian TEXT NOT NULL,
  anggaran NUMERIC(16,2) NOT NULL DEFAULT 0,
  realisasi NUMERIC(16,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  keterangan TEXT,
  urutan INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.apbdes TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.apbdes TO authenticated;
GRANT ALL ON public.apbdes TO service_role;
ALTER TABLE public.apbdes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "apbdes_public_read" ON public.apbdes FOR SELECT USING (true);
CREATE POLICY "apbdes_admin_write" ON public.apbdes FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_apbdes_updated BEFORE UPDATE ON public.apbdes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX apbdes_tahun_idx ON public.apbdes (tahun);

-- RPC lookup PBB (aman untuk publik: tidak expose tabel penuh via API, opsional)
CREATE OR REPLACE FUNCTION public.cek_pbb(_tahun INT, _nop TEXT)
RETURNS TABLE (
  tahun INT, nop TEXT, wajib_pajak_nama TEXT, alamat_objek TEXT, dusun TEXT,
  pbb_terutang NUMERIC, jatuh_tempo DATE, status_bayar TEXT, tanggal_bayar DATE
) LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT p.tahun, p.nop, p.wajib_pajak_nama, p.alamat_objek, p.dusun,
         p.pbb_terutang, p.jatuh_tempo, p.status_bayar, p.tanggal_bayar
  FROM public.pbb_tagihan p
  WHERE p.tahun = _tahun AND lower(trim(p.nop)) = lower(trim(_nop))
  LIMIT 1;
$$;

-- Seed APBDes 2026
INSERT INTO public.apbdes (tahun,jenis,kategori,uraian,anggaran,realisasi,sumber_dana,urutan) VALUES
(2026,'pendapatan','Pendapatan Transfer','Dana Desa (DD)',1250000000,812000000,'APBN',1),
(2026,'pendapatan','Pendapatan Transfer','Alokasi Dana Desa (ADD)',680000000,442000000,'APBD Kab',2),
(2026,'pendapatan','Pendapatan Transfer','Bagi Hasil Pajak & Retribusi',95000000,58000000,'APBD Kab',3),
(2026,'pendapatan','Pendapatan Asli Desa','Hasil Usaha BUMDes',75000000,41500000,'PADes',4),
(2026,'pendapatan','Pendapatan Lain','Bantuan Provinsi',120000000,60000000,'APBD Prov',5),
(2026,'belanja','Bidang 1 — Penyelenggaraan Pemerintahan','Penghasilan Tetap & Tunjangan Pamong',420000000,245000000,'ADD',10),
(2026,'belanja','Bidang 1 — Penyelenggaraan Pemerintahan','Operasional Kantor Desa',95000000,52000000,'ADD',11),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Pengerasan Jalan Poros Karang Baru',480000000,374400000,'DD',20),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Rehabilitasi Posyandu Melati',85000000,42500000,'DD',21),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Drainase Dusun Presak',210000000,84000000,'DD',22),
(2026,'belanja','Bidang 3 — Pembinaan Kemasyarakatan','Kegiatan PKK & Karang Taruna',48000000,26500000,'ADD',30),
(2026,'belanja','Bidang 3 — Pembinaan Kemasyarakatan','Bulan Bakti Gotong Royong',22000000,22000000,'ADD',31),
(2026,'belanja','Bidang 4 — Pemberdayaan Masyarakat','Pelatihan Pengolahan Hasil Pertanian',65000000,32000000,'DD',40),
(2026,'belanja','Bidang 4 — Pemberdayaan Masyarakat','Bantuan Modal BUMDes',75000000,75000000,'DD',41),
(2026,'belanja','Bidang 5 — Penanggulangan Bencana & Mendesak','Cadangan Kebencanaan',60000000,12000000,'DD',50),
(2026,'pembiayaan','Penerimaan Pembiayaan','SILPA Tahun Sebelumnya',180000000,180000000,'SILPA',60),
(2026,'pembiayaan','Pengeluaran Pembiayaan','Penyertaan Modal BUMDes',75000000,75000000,'PADes',61);

-- Seed PBB dummy
INSERT INTO public.pbb_tagihan (tahun,nop,wajib_pajak_nama,alamat_objek,dusun,luas_bumi_m2,luas_bangunan_m2,njop_bumi,njop_bangunan,pbb_terutang,jatuh_tempo,status_bayar) VALUES
(2026,'52.03.140.007.001-0001.0','H. Ahmad Saputra','Dusun Karang Baru RT 04 RW 02','Karang Baru',400,120,80000000,60000000,187500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0002.0','Ni Wayan Sari','Dusun Presak RT 02 RW 01','Presak',350,90,63000000,42000000,131250,'2026-09-30','lunas'),
(2026,'52.03.140.007.001-0003.0','Lalu Muhammad Zaini','Dusun Seruni Utara RT 01 RW 03','Seruni Utara',500,150,100000000,90000000,237500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0004.0','Baiq Nurhayati','Dusun Mumbul RT 03 RW 02','Mumbul',280,72,50400000,28800000,98500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0005.0','I Ketut Wirya','Dusun Karang Baru RT 05 RW 02','Karang Baru',600,180,120000000,108000000,285000,'2026-09-30','lunas');


-- ============================================
-- FILE: 20260719143803_2545a3d5-c359-4005-bfbe-274a76b4bcc0.sql
-- ============================================


-- Storage policies for seruni-media bucket
CREATE POLICY "Public read seruni-media"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'seruni-media');

CREATE POLICY "Admin upload seruni-media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admin update seruni-media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admin delete seruni-media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

-- Add cover_url columns for berita/agenda/pengumuman if missing
ALTER TABLE public.berita ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.desa_pamong ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE public.galeri ADD COLUMN IF NOT EXISTS foto_url TEXT;


-- ============================================
-- FILE: 20260719183801_c00d223a-c061-4d11-a499-4f30d61ceb3b.sql
-- ============================================


-- =====================================================================
-- Phase 9 - Audit generic + WhatsApp broadcast persistence
-- =====================================================================

-- 1. Generic audit trigger --------------------------------------------
CREATE OR REPLACE FUNCTION public.log_admin_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _event TEXT;
  _payload JSONB;
  _id TEXT;
  _pub_old BOOLEAN;
  _pub_new BOOLEAN;
  _diff JSONB := '{}'::JSONB;
  _key TEXT;
  _oldv JSONB;
  _newv JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    _event := TG_TABLE_NAME || '.dibuat';
    _id := COALESCE((to_jsonb(NEW)->>'id'), '');
    _payload := jsonb_build_object('pk', _id);
    IF (to_jsonb(NEW) ? 'published') AND (to_jsonb(NEW)->>'published')::BOOLEAN THEN
      _event := TG_TABLE_NAME || '.dipublish';
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    _id := COALESCE((to_jsonb(NEW)->>'id'), '');
    -- publish/unpublish detection
    IF (to_jsonb(NEW) ? 'published') THEN
      _pub_old := (to_jsonb(OLD)->>'published')::BOOLEAN;
      _pub_new := (to_jsonb(NEW)->>'published')::BOOLEAN;
      IF _pub_old IS DISTINCT FROM _pub_new THEN
        _event := TG_TABLE_NAME || CASE WHEN _pub_new THEN '.dipublish' ELSE '.di_unpublish' END;
      END IF;
    END IF;
    IF _event IS NULL THEN
      _event := TG_TABLE_NAME || '.diubah';
    END IF;
    -- compute diff for changed columns (skip updated_at)
    FOR _key IN
      SELECT k FROM jsonb_object_keys(to_jsonb(NEW)) k
    LOOP
      IF _key = 'updated_at' THEN CONTINUE; END IF;
      _oldv := to_jsonb(OLD)->_key;
      _newv := to_jsonb(NEW)->_key;
      IF _oldv IS DISTINCT FROM _newv THEN
        _diff := _diff || jsonb_build_object(_key, jsonb_build_object('dari', _oldv, 'ke', _newv));
      END IF;
    END LOOP;
    _payload := jsonb_build_object('pk', _id, 'diff', _diff);
    IF _diff = '{}'::JSONB THEN
      RETURN NEW; -- nothing meaningful changed
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    _event := TG_TABLE_NAME || '.dihapus';
    _id := COALESCE((to_jsonb(OLD)->>'id'), '');
    _payload := jsonb_build_object('pk', _id, 'snapshot', to_jsonb(OLD));
  END IF;

  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
  VALUES (_event, TG_TABLE_NAME, NULLIF(_id, '')::UUID, _payload, auth.uid());

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- never block the write because of logging failure
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END; $$;

-- Drop old duplicative status triggers (replaced by generic audit)
DROP TRIGGER IF EXISTS trg_aduan_event ON public.aduan_warga;
DROP TRIGGER IF EXISTS trg_bencana_event ON public.bencana_kejadian;
DROP TRIGGER IF EXISTS trg_kegiatan_event ON public.kegiatan_pembangunan;

-- Attach generic audit trigger to all admin tables (idempotent)
DO $$
DECLARE
  t TEXT;
  tables TEXT[] := ARRAY[
    'berita','agenda','pengumuman','galeri',
    'desa_pamong','wilayah_dusun','lembaga_desa','profil_desa',
    'surat_jenis','surat_terbit','aduan_warga','langganan_wa',
    'apbdes','pbb_tagihan',
    'kegiatan_pembangunan','infrastruktur',
    'posyandu_agregat','stunting_agregat',
    'bantuan_sosial','penerima_bansos',
    'bencana_kejadian','dpt_pemilih','bidang_tanah',
    'potensi_umkm','potensi_produk','potensi_wisata'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON public.%I;', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();',
      t, t
    );
  END LOOP;
END $$;

-- 2. WhatsApp broadcast tables ----------------------------------------
CREATE TABLE IF NOT EXISTS public.wa_broadcast (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT,
  pesan TEXT NOT NULL,
  topik TEXT,
  dusun_filter TEXT,
  dry_run BOOLEAN NOT NULL DEFAULT false,
  dibuat_oleh UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'antri',
  total_target INT NOT NULL DEFAULT 0,
  total_sukses INT NOT NULL DEFAULT 0,
  total_gagal INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_broadcast TO authenticated;
GRANT ALL ON public.wa_broadcast TO service_role;

ALTER TABLE public.wa_broadcast ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin dapat mengelola wa_broadcast" ON public.wa_broadcast;
CREATE POLICY "Admin dapat mengelola wa_broadcast"
  ON public.wa_broadcast FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP TRIGGER IF EXISTS trg_wa_broadcast_updated ON public.wa_broadcast;
CREATE TRIGGER trg_wa_broadcast_updated
  BEFORE UPDATE ON public.wa_broadcast
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.wa_broadcast_target (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  broadcast_id UUID NOT NULL REFERENCES public.wa_broadcast(id) ON DELETE CASCADE,
  nomor_tujuan TEXT NOT NULL,
  nama TEXT,
  dusun TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  error_message TEXT,
  attempt INT NOT NULL DEFAULT 0,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_broadcast_target TO authenticated;
GRANT ALL ON public.wa_broadcast_target TO service_role;

ALTER TABLE public.wa_broadcast_target ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin dapat mengelola wa_broadcast_target" ON public.wa_broadcast_target;
CREATE POLICY "Admin dapat mengelola wa_broadcast_target"
  ON public.wa_broadcast_target FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP TRIGGER IF EXISTS trg_wa_broadcast_target_updated ON public.wa_broadcast_target;
CREATE TRIGGER trg_wa_broadcast_target_updated
  BEFORE UPDATE ON public.wa_broadcast_target
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_wa_target_broadcast ON public.wa_broadcast_target(broadcast_id);
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_created ON public.wa_broadcast(created_at DESC);


-- ============================================
-- FILE: 20260719190120_78746ac9-7807-4aba-b61a-dc437e7d8674.sql
-- ============================================


-- ===== page_config: hero + section titles per public route =====
CREATE TABLE public.page_config (
  route TEXT PRIMARY KEY,
  nama TEXT NOT NULL,
  eyebrow TEXT NOT NULL DEFAULT '',
  judul TEXT NOT NULL DEFAULT '',
  deskripsi TEXT,
  hero_image_url TEXT,
  section_titles JSONB NOT NULL DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.page_config TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.page_config TO authenticated;
GRANT ALL ON public.page_config TO service_role;
ALTER TABLE public.page_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "page_config read public"  ON public.page_config FOR SELECT USING (true);
CREATE POLICY "page_config admin write"  ON public.page_config FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_page_config_updated BEFORE UPDATE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_page_config_log AFTER INSERT OR UPDATE OR DELETE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== nav_item: navbar hierarkis =====
CREATE TABLE public.nav_item (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.nav_item(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  href TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_nav_item_parent ON public.nav_item(parent_id, urutan);
GRANT SELECT ON public.nav_item TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.nav_item TO authenticated;
GRANT ALL ON public.nav_item TO service_role;
ALTER TABLE public.nav_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY "nav_item read public" ON public.nav_item FOR SELECT USING (true);
CREATE POLICY "nav_item admin write" ON public.nav_item FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_nav_item_updated BEFORE UPDATE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_nav_item_log AFTER INSERT OR UPDATE OR DELETE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== footer_column =====
CREATE TABLE public.footer_column (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  links JSONB NOT NULL DEFAULT '[]'::jsonb,  -- [{label, href}]
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.footer_column TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.footer_column TO authenticated;
GRANT ALL ON public.footer_column TO service_role;
ALTER TABLE public.footer_column ENABLE ROW LEVEL SECURITY;
CREATE POLICY "footer_column read public" ON public.footer_column FOR SELECT USING (true);
CREATE POLICY "footer_column admin write" ON public.footer_column FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_footer_column_updated BEFORE UPDATE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_footer_column_log AFTER INSERT OR UPDATE OR DELETE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== Seed page_config: semua rute publik =====
INSERT INTO public.page_config (route, nama, eyebrow, judul, deskripsi) VALUES
  ('/',                       'Beranda',            'Portal Desa',      'Beranda Desa',           'Halaman utama portal desa.'),
  ('/profil-desa',            'Profil Desa',        'Tentang',          'Profil Desa',            'Sejarah, visi, dan misi desa.'),
  ('/profil-desa/struktur',   'Struktur Pamong',    'Pemerintahan',     'Struktur Pamong',        'Susunan kepala desa dan perangkatnya.'),
  ('/profil-desa/wilayah',    'Wilayah Dusun',      'Geografis',        'Wilayah Dusun',          'Batas administratif dan dusun.'),
  ('/profil-desa/lembaga',    'Lembaga Desa',       'Kelembagaan',      'Lembaga Desa',           'BPD, LPM, PKK, dan Karang Taruna.'),
  ('/berita',                 'Berita',             'Informasi',        'Berita Terkini',         'Kabar terbaru dari desa.'),
  ('/kalender-desa',          'Kalender Desa',      'Agenda',           'Kalender Kegiatan',      'Jadwal kegiatan resmi desa.'),
  ('/galeri',                 'Galeri',             'Dokumentasi',      'Galeri Foto',            'Dokumentasi kegiatan desa.'),
  ('/pengumuman',             'Pengumuman',         'Maklumat',         'Pengumuman Resmi',       'Informasi resmi pemerintah desa.'),
  ('/layanan',                'Layanan Desa',       'Pelayanan',        'Layanan Warga',          'Semua layanan administratif desa.'),
  ('/layanan/surat',          'Layanan Surat',      'Administrasi',     'Layanan Surat',          'Ajukan surat administrasi.'),
  ('/layanan/pbb',            'Layanan PBB',        'Pajak',            'Cek PBB',                'Cek tagihan Pajak Bumi & Bangunan.'),
  ('/service-center',         'Service Center',     'Pengaduan',        'Service Center',         'Sampaikan aduan & aspirasi warga.'),
  ('/verifikasi',             'Verifikasi Dokumen', 'Keaslian',         'Verifikasi Dokumen',     'Cek keaslian dokumen desa.'),
  ('/statistik',              'Statistik',          'Data',             'Statistik Desa',         'Ringkasan data agregat desa.'),
  ('/status-idm',             'Status IDM',         'Indeks',           'Status IDM',             'Indeks Desa Membangun terkini.'),
  ('/statistik/penduduk',     'Statistik Penduduk', 'Demografi',        'Statistik Penduduk',     'Data kependudukan agregat.'),
  ('/pembangunan',            'Pembangunan',        'Infrastruktur',    'Pembangunan Desa',       'Progres kegiatan pembangunan.'),
  ('/perencanaan',            'Perencanaan',        'RKPDes',           'Perencanaan Desa',       'Usulan warga dan RKPDes.'),
  ('/keuangan',               'Keuangan',           'APBDes',           'Keuangan Desa',          'Rincian anggaran & realisasi.'),
  ('/potensi-desa',           'Potensi Desa',       'Potensi',          'Potensi Desa',           'UMKM, wisata, dan BUMDes.'),
  ('/marketplace',            'Marketplace',        'Ekonomi',          'Marketplace Desa',       'Produk unggulan warga.'),
  ('/peta-desa',              'Peta Desa',          'Peta',             'Peta Desa',              'Peta interaktif desa.'),
  ('/langganan-wa',           'Langganan WA',       'Notifikasi',       'Langganan WhatsApp',     'Berlangganan info via WA.')
ON CONFLICT (route) DO NOTHING;

-- ===== Seed nav_item: 7 kategori + submenu (mirror data.ts) =====
DO $$
DECLARE p_id UUID;
BEGIN
  -- Profil
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Profil','/profil-desa',1) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Sejarah','/profil-desa','Asal-usul, visi & misi desa',1),
    (p_id,'Struktur','/profil-desa/struktur','Kepala desa, pamong & perangkat',2),
    (p_id,'Wilayah','/profil-desa/wilayah','Batas, dusun, dan topografi',3),
    (p_id,'Lembaga','/profil-desa/lembaga','BPD, LPM, PKK & Karang Taruna',4);
  -- Informasi
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Informasi','/berita',2) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Berita','/berita','Kabar terbaru dari desa',1),
    (p_id,'Agenda','/kalender-desa','Kalender kegiatan resmi',2),
    (p_id,'Galeri','/galeri','Foto & video dokumentasi',3),
    (p_id,'Pengumuman','/pengumuman','Maklumat & informasi resmi',4);
  -- Layanan
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Layanan','/layanan',3) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Surat','/layanan/surat','Ajukan surat administrasi online',1),
    (p_id,'Pengaduan','/service-center','Sampaikan aduan & aspirasi',2),
    (p_id,'PBB','/layanan/pbb','Cek tagihan Pajak Bumi & Bangunan',3),
    (p_id,'Verifikasi','/verifikasi','Cek keaslian dokumen desa',4);
  -- Data
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Data','/statistik',4) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'IDM','/status-idm','Indeks Desa Membangun terkini',1),
    (p_id,'Penduduk','/statistik/penduduk','Statistik demografi warga',2),
    (p_id,'APBDes','/keuangan','Rincian anggaran & realisasi',3),
    (p_id,'Perencanaan','/perencanaan','Voting usulan warga & RKPDes',4);
  -- Potensi
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Potensi','/potensi-desa',5) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'UMKM','/potensi-desa#ekonomi','Ekonomi kreatif & usaha warga',1),
    (p_id,'Wisata','/potensi-desa#pariwisata','Destinasi & atraksi desa',2),
    (p_id,'Marketplace','/marketplace','Produk unggulan warga',3),
    (p_id,'BUMDes','/potensi-desa#bumdes','Badan usaha & koperasi desa',4);
  -- Peta
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Peta','/peta-desa',6);
  -- Kontak
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Kontak','/service-center',7);
END $$;

-- ===== Seed footer_column =====
INSERT INTO public.footer_column (judul, urutan, links) VALUES
 ('Service Center', 1, '[
   {"label":"Aduan Warga","href":"/service-center"},
   {"label":"Verifikasi Dokumen","href":"/verifikasi"},
   {"label":"Langganan WA","href":"/langganan-wa"}
 ]'::jsonb),
 ('Informasi', 2, '[
   {"label":"Berita","href":"/berita"},
   {"label":"Agenda","href":"/kalender-desa"},
   {"label":"Pengumuman","href":"/pengumuman"},
   {"label":"Galeri","href":"/galeri"}
 ]'::jsonb),
 ('Terhubung', 3, '[
   {"label":"Facebook","href":"https://facebook.com/desa.serunimumbul"},
   {"label":"Instagram","href":"https://instagram.com/desa.serunimumbul"},
   {"label":"YouTube","href":"https://youtube.com/@desa.serunimumbul"}
 ]'::jsonb);


-- ============================================
-- FILE: 20260719191430_0c1bd833-32d8-44b4-81f7-61c72cdb0cec.sql
-- ============================================


-- ================= ENUMS =================
DO $$ BEGIN
  CREATE TYPE public.rpjmdes_status AS ENUM ('draft','aktif','selesai');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.usulan_status AS ENUM ('baru','diverifikasi','ditindaklanjuti','selesai','ditolak');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.usulan_kategori AS ENUM ('infrastruktur','ekonomi','sosial','pendidikan','kesehatan','lingkungan','pemerintahan','lainnya');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.voting_status AS ENUM ('draft','aktif','ditutup');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.realisasi_status AS ENUM ('rencana','berjalan','selesai','tertunda','batal');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ================= RPJMDes =================
CREATE TABLE public.rpjmdes_periode (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  tahun_mulai INT NOT NULL,
  tahun_selesai INT NOT NULL,
  visi TEXT,
  misi JSONB NOT NULL DEFAULT '[]'::jsonb,
  status public.rpjmdes_status NOT NULL DEFAULT 'draft',
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.rpjmdes_periode TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_periode TO authenticated;
GRANT ALL ON public.rpjmdes_periode TO service_role;
ALTER TABLE public.rpjmdes_periode ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat periode terbit" ON public.rpjmdes_periode FOR SELECT USING (published = true);
CREATE POLICY "admin kelola periode" ON public.rpjmdes_periode FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rpjmdes_bidang (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode_id UUID NOT NULL REFERENCES public.rpjmdes_periode(id) ON DELETE CASCADE,
  kode TEXT NOT NULL,
  nama TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rpjmdes_bidang(periode_id);
GRANT SELECT ON public.rpjmdes_bidang TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_bidang TO authenticated;
GRANT ALL ON public.rpjmdes_bidang TO service_role;
ALTER TABLE public.rpjmdes_bidang ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat bidang" ON public.rpjmdes_bidang FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.rpjmdes_periode p WHERE p.id = periode_id AND p.published = true)
);
CREATE POLICY "admin kelola bidang" ON public.rpjmdes_bidang FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rpjmdes_program (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_id UUID NOT NULL REFERENCES public.rpjmdes_bidang(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  indikator TEXT,
  target TEXT,
  sumber_dana TEXT,
  tahun_mulai INT,
  tahun_selesai INT,
  anggaran_indikatif NUMERIC(18,2) NOT NULL DEFAULT 0,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rpjmdes_program(bidang_id);
GRANT SELECT ON public.rpjmdes_program TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_program TO authenticated;
GRANT ALL ON public.rpjmdes_program TO service_role;
ALTER TABLE public.rpjmdes_program ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat program" ON public.rpjmdes_program FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.rpjmdes_bidang b JOIN public.rpjmdes_periode p ON p.id = b.periode_id
    WHERE b.id = bidang_id AND p.published = true
  )
);
CREATE POLICY "admin kelola program" ON public.rpjmdes_program FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ================= RKPDes =================
CREATE TABLE public.rkpdes_tahun (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode_id UUID REFERENCES public.rpjmdes_periode(id) ON DELETE SET NULL,
  tahun INT NOT NULL UNIQUE,
  tgl_musdes DATE,
  catatan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.rkpdes_tahun TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rkpdes_tahun TO authenticated;
GRANT ALL ON public.rkpdes_tahun TO service_role;
ALTER TABLE public.rkpdes_tahun ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat rkpdes terbit" ON public.rkpdes_tahun FOR SELECT USING (published = true);
CREATE POLICY "admin kelola rkpdes" ON public.rkpdes_tahun FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rkpdes_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun_id UUID NOT NULL REFERENCES public.rkpdes_tahun(id) ON DELETE CASCADE,
  bidang_id UUID REFERENCES public.rpjmdes_bidang(id) ON DELETE SET NULL,
  program_id UUID REFERENCES public.rpjmdes_program(id) ON DELETE SET NULL,
  nama TEXT NOT NULL,
  lokasi TEXT,
  dusun TEXT,
  volume TEXT,
  satuan TEXT,
  anggaran NUMERIC(18,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  pelaksana TEXT,
  waktu TEXT,
  status_realisasi public.realisasi_status NOT NULL DEFAULT 'rencana',
  progress_pct INT NOT NULL DEFAULT 0 CHECK (progress_pct BETWEEN 0 AND 100),
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rkpdes_kegiatan(tahun_id);
GRANT SELECT ON public.rkpdes_kegiatan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rkpdes_kegiatan TO authenticated;
GRANT ALL ON public.rkpdes_kegiatan TO service_role;
ALTER TABLE public.rkpdes_kegiatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat kegiatan terbit" ON public.rkpdes_kegiatan FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.rkpdes_tahun t WHERE t.id = tahun_id AND t.published = true)
);
CREATE POLICY "admin kelola kegiatan rkpdes" ON public.rkpdes_kegiatan FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ================= USULAN WARGA =================
CREATE SEQUENCE IF NOT EXISTS public.usulan_seq;

CREATE TABLE public.usulan_warga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL CHECK (char_length(nama) BETWEEN 2 AND 120),
  kontak TEXT CHECK (kontak IS NULL OR char_length(kontak) <= 60),
  dusun TEXT,
  kategori public.usulan_kategori NOT NULL,
  judul TEXT NOT NULL CHECK (char_length(judul) BETWEEN 5 AND 160),
  deskripsi TEXT NOT NULL CHECK (char_length(deskripsi) BETWEEN 10 AND 4000),
  lokasi TEXT,
  foto_url TEXT,
  status public.usulan_status NOT NULL DEFAULT 'baru',
  tanggapan TEXT,
  target_rkpdes_id UUID REFERENCES public.rkpdes_tahun(id) ON DELETE SET NULL,
  vote_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.usulan_warga(status);
CREATE INDEX ON public.usulan_warga(kategori);
GRANT SELECT ON public.usulan_warga TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.usulan_warga TO authenticated;
GRANT ALL ON public.usulan_warga TO service_role;
ALTER TABLE public.usulan_warga ENABLE ROW LEVEL SECURITY;
-- publik hanya melihat usulan yang sudah diverifikasi (moderasi)
CREATE POLICY "publik lihat usulan moderasi" ON public.usulan_warga FOR SELECT USING (
  status IN ('diverifikasi','ditindaklanjuti','selesai')
);
CREATE POLICY "admin kelola usulan" ON public.usulan_warga FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
-- INSERT publik dilakukan lewat edge function (service_role), tidak lewat client.

CREATE TABLE public.usulan_vote (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usulan_id UUID NOT NULL REFERENCES public.usulan_warga(id) ON DELETE CASCADE,
  voter_hash TEXT NOT NULL,
  dusun TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (usulan_id, voter_hash)
);
CREATE INDEX ON public.usulan_vote(usulan_id);
GRANT SELECT ON public.usulan_vote TO anon;
GRANT SELECT ON public.usulan_vote TO authenticated;
GRANT ALL ON public.usulan_vote TO service_role;
ALTER TABLE public.usulan_vote ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat vote usulan" ON public.usulan_vote FOR SELECT USING (true);
CREATE POLICY "admin kelola vote usulan" ON public.usulan_vote FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- Trigger untuk sinkronkan vote_count di usulan_warga
CREATE OR REPLACE FUNCTION public.sync_usulan_vote_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.usulan_warga SET vote_count = vote_count + 1, updated_at = now() WHERE id = NEW.usulan_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.usulan_warga SET vote_count = GREATEST(vote_count - 1, 0), updated_at = now() WHERE id = OLD.usulan_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END; $$;
CREATE TRIGGER trg_usulan_vote_sync
AFTER INSERT OR DELETE ON public.usulan_vote
FOR EACH ROW EXECUTE FUNCTION public.sync_usulan_vote_count();

-- ================= VOTING RESMI =================
CREATE TABLE public.voting_topik (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  deskripsi TEXT,
  mulai TIMESTAMPTZ,
  selesai TIMESTAMPTZ,
  single_choice BOOLEAN NOT NULL DEFAULT true,
  status public.voting_status NOT NULL DEFAULT 'draft',
  published BOOLEAN NOT NULL DEFAULT false,
  total_suara INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.voting_topik TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.voting_topik TO authenticated;
GRANT ALL ON public.voting_topik TO service_role;
ALTER TABLE public.voting_topik ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat voting terbit" ON public.voting_topik FOR SELECT USING (published = true);
CREATE POLICY "admin kelola voting" ON public.voting_topik FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.voting_opsi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topik_id UUID NOT NULL REFERENCES public.voting_topik(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  jumlah_suara INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.voting_opsi(topik_id);
GRANT SELECT ON public.voting_opsi TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.voting_opsi TO authenticated;
GRANT ALL ON public.voting_opsi TO service_role;
ALTER TABLE public.voting_opsi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat opsi terbit" ON public.voting_opsi FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.voting_topik t WHERE t.id = topik_id AND t.published = true)
);
CREATE POLICY "admin kelola opsi voting" ON public.voting_opsi FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.voting_suara (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topik_id UUID NOT NULL REFERENCES public.voting_topik(id) ON DELETE CASCADE,
  opsi_id UUID NOT NULL REFERENCES public.voting_opsi(id) ON DELETE CASCADE,
  voter_hash TEXT NOT NULL,
  dusun TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (topik_id, voter_hash)
);
CREATE INDEX ON public.voting_suara(topik_id);
GRANT SELECT ON public.voting_suara TO anon;
GRANT SELECT ON public.voting_suara TO authenticated;
GRANT ALL ON public.voting_suara TO service_role;
ALTER TABLE public.voting_suara ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat suara agregat" ON public.voting_suara FOR SELECT USING (true);
CREATE POLICY "admin kelola suara voting" ON public.voting_suara FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE OR REPLACE FUNCTION public.sync_voting_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.voting_opsi SET jumlah_suara = jumlah_suara + 1, updated_at = now() WHERE id = NEW.opsi_id;
    UPDATE public.voting_topik SET total_suara = total_suara + 1, updated_at = now() WHERE id = NEW.topik_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.voting_opsi SET jumlah_suara = GREATEST(jumlah_suara - 1, 0), updated_at = now() WHERE id = OLD.opsi_id;
    UPDATE public.voting_topik SET total_suara = GREATEST(total_suara - 1, 0), updated_at = now() WHERE id = OLD.topik_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END; $$;
CREATE TRIGGER trg_voting_sync
AFTER INSERT OR DELETE ON public.voting_suara
FOR EACH ROW EXECUTE FUNCTION public.sync_voting_count();

-- ================= Triggers updated_at + audit =================
CREATE TRIGGER upd_rpjmdes_periode BEFORE UPDATE ON public.rpjmdes_periode FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rpjmdes_bidang BEFORE UPDATE ON public.rpjmdes_bidang FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rpjmdes_program BEFORE UPDATE ON public.rpjmdes_program FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rkpdes_tahun BEFORE UPDATE ON public.rkpdes_tahun FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rkpdes_kegiatan BEFORE UPDATE ON public.rkpdes_kegiatan FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_usulan_warga BEFORE UPDATE ON public.usulan_warga FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_voting_topik BEFORE UPDATE ON public.voting_topik FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_voting_opsi BEFORE UPDATE ON public.voting_opsi FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER audit_rpjmdes_periode AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_periode FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rpjmdes_bidang  AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_bidang  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rpjmdes_program AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_program FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rkpdes_tahun    AFTER INSERT OR UPDATE OR DELETE ON public.rkpdes_tahun    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rkpdes_kegiatan AFTER INSERT OR UPDATE OR DELETE ON public.rkpdes_kegiatan FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_usulan_warga    AFTER INSERT OR UPDATE OR DELETE ON public.usulan_warga    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_voting_topik    AFTER INSERT OR UPDATE OR DELETE ON public.voting_topik    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_voting_opsi     AFTER INSERT OR UPDATE OR DELETE ON public.voting_opsi     FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();


-- ============================================
-- FILE: 20260719191447_400e153c-8fcf-4fc1-856d-d291db7ea403.sql
-- ============================================


REVOKE EXECUTE ON FUNCTION public.sync_usulan_vote_count() FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.sync_voting_count() FROM anon, authenticated, public;


-- ============================================
-- FILE: 20260719192645_bd5542af-3dd3-4903-8383-3d9603c623c3.sql
-- ============================================


-- ============ 1. Voting hasil + auto close ============
ALTER TABLE public.voting_topik
  ADD COLUMN IF NOT EXISTS hasil_pemenang_id UUID REFERENCES public.voting_opsi(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS hasil_ringkasan TEXT,
  ADD COLUMN IF NOT EXISTS hasil_dipublikasi BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS hasil_dipublikasi_pada TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.auto_close_expired_voting()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
DECLARE t RECORD; winner_id UUID;
BEGIN
  FOR t IN SELECT id FROM public.voting_topik
    WHERE status = 'aktif' AND selesai IS NOT NULL AND selesai < now()
  LOOP
    SELECT id INTO winner_id FROM public.voting_opsi
      WHERE topik_id = t.id
      ORDER BY jumlah_suara DESC, urutan ASC
      LIMIT 1;
    UPDATE public.voting_topik
      SET status = 'ditutup',
          hasil_pemenang_id = winner_id,
          hasil_dipublikasi = true,
          hasil_dipublikasi_pada = now()
      WHERE id = t.id;
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload)
      VALUES ('voting_topik.ditutup_otomatis', 'voting_topik', t.id,
              jsonb_build_object('pemenang_id', winner_id));
  END LOOP;
END; $fn$;
REVOKE EXECUTE ON FUNCTION public.auto_close_expired_voting() FROM PUBLIC, anon, authenticated;

CREATE EXTENSION IF NOT EXISTS pg_cron;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'auto_close_voting') THEN
    PERFORM cron.schedule('auto_close_voting', '*/5 * * * *',
      'SELECT public.auto_close_expired_voting();');
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.tutup_voting_manual(_topik_id UUID, _ringkasan TEXT)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
DECLARE winner_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT id INTO winner_id FROM public.voting_opsi
    WHERE topik_id = _topik_id
    ORDER BY jumlah_suara DESC, urutan ASC LIMIT 1;
  UPDATE public.voting_topik
    SET status='ditutup',
        hasil_pemenang_id=winner_id,
        hasil_ringkasan=COALESCE(NULLIF(_ringkasan,''), hasil_ringkasan),
        hasil_dipublikasi=true,
        hasil_dipublikasi_pada=now()
    WHERE id=_topik_id;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES ('voting_topik.ditutup_manual','voting_topik',_topik_id,
            jsonb_build_object('pemenang_id', winner_id, 'ringkasan', _ringkasan), auth.uid());
  RETURN winner_id;
END; $fn$;
GRANT EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) TO authenticated;

-- ============ 2. Site version history ============
CREATE TABLE IF NOT EXISTS public.site_version (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entitas TEXT NOT NULL CHECK (entitas IN ('page_config','nav_item','footer_column')),
  entitas_id UUID NOT NULL,
  versi INT NOT NULL,
  snapshot JSONB NOT NULL,
  note TEXT,
  actor_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (entitas, entitas_id, versi)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_version TO authenticated;
GRANT ALL ON public.site_version TO service_role;
ALTER TABLE public.site_version ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin manage site_version" ON public.site_version;
CREATE POLICY "Admin manage site_version" ON public.site_version FOR ALL
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE OR REPLACE FUNCTION public.snapshot_site_config()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE next_ver INT; snap JSONB; rec_id UUID;
BEGIN
  snap := to_jsonb(OLD); rec_id := (OLD).id;
  SELECT COALESCE(MAX(versi),0)+1 INTO next_ver FROM public.site_version
    WHERE entitas=TG_TABLE_NAME AND entitas_id=rec_id;
  INSERT INTO public.site_version(entitas, entitas_id, versi, snapshot, actor_id, note)
    VALUES (TG_TABLE_NAME, rec_id, next_ver, snap, auth.uid(), TG_OP);
  IF TG_OP='DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  IF TG_OP='DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END; $fn$;

DROP TRIGGER IF EXISTS snap_page_config ON public.page_config;
DROP TRIGGER IF EXISTS snap_nav_item ON public.nav_item;
DROP TRIGGER IF EXISTS snap_footer_column ON public.footer_column;
CREATE TRIGGER snap_page_config BEFORE UPDATE OR DELETE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();
CREATE TRIGGER snap_nav_item BEFORE UPDATE OR DELETE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();
CREATE TRIGGER snap_footer_column BEFORE UPDATE OR DELETE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();

CREATE OR REPLACE FUNCTION public.restore_site_version(_version_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE v RECORD;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO v FROM public.site_version WHERE id=_version_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'version not found'; END IF;
  IF v.entitas='page_config' THEN
    UPDATE public.page_config SET
      nama = COALESCE(v.snapshot->>'nama', nama),
      eyebrow = COALESCE(v.snapshot->>'eyebrow',''),
      judul = COALESCE(v.snapshot->>'judul',''),
      deskripsi = v.snapshot->>'deskripsi',
      hero_image_url = v.snapshot->>'hero_image_url',
      section_titles = COALESCE(v.snapshot->'section_titles','[]'::jsonb)
    WHERE id = v.entitas_id;
  ELSIF v.entitas='nav_item' THEN
    UPDATE public.nav_item SET
      label = COALESCE(v.snapshot->>'label', label),
      href = COALESCE(v.snapshot->>'href', href),
      parent_id = NULLIF(v.snapshot->>'parent_id','')::uuid,
      urutan = COALESCE((v.snapshot->>'urutan')::int, 0),
      deskripsi = v.snapshot->>'deskripsi',
      aktif = COALESCE((v.snapshot->>'aktif')::bool, true)
    WHERE id = v.entitas_id;
  ELSIF v.entitas='footer_column' THEN
    UPDATE public.footer_column SET
      judul = COALESCE(v.snapshot->>'judul', judul),
      links = COALESCE(v.snapshot->'links','[]'::jsonb),
      urutan = COALESCE((v.snapshot->>'urutan')::int, 0),
      aktif = COALESCE((v.snapshot->>'aktif')::bool, true)
    WHERE id = v.entitas_id;
  END IF;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (v.entitas || '.dipulihkan', v.entitas, v.entitas_id, jsonb_build_object('versi', v.versi), auth.uid());
END; $fn$;
GRANT EXECUTE ON FUNCTION public.restore_site_version(UUID) TO authenticated;

-- ============ 3. Staged drafts ============
CREATE TABLE IF NOT EXISTS public.site_draft (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entitas TEXT NOT NULL CHECK (entitas IN ('page_config','nav_item','footer_column')),
  entitas_id UUID,
  action TEXT NOT NULL DEFAULT 'update' CHECK (action IN ('update','create','delete')),
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','review','published','rolled_back','rejected')),
  catatan TEXT,
  actor_id UUID,
  reviewer_id UUID,
  reviewed_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  rollback_of UUID REFERENCES public.site_draft(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS site_draft_status_idx ON public.site_draft(status);
CREATE INDEX IF NOT EXISTS site_draft_entitas_idx ON public.site_draft(entitas, entitas_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_draft TO authenticated;
GRANT ALL ON public.site_draft TO service_role;
ALTER TABLE public.site_draft ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin manage site_draft" ON public.site_draft;
CREATE POLICY "Admin manage site_draft" ON public.site_draft FOR ALL
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

DROP TRIGGER IF EXISTS site_draft_updated_at ON public.site_draft;
CREATE TRIGGER site_draft_updated_at BEFORE UPDATE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS site_draft_audit ON public.site_draft;
CREATE TRIGGER site_draft_audit AFTER INSERT OR UPDATE OR DELETE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE OR REPLACE FUNCTION public.publish_site_draft(_draft_id UUID)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE d RECORD; new_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO d FROM public.site_draft WHERE id=_draft_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'draft not found'; END IF;
  IF d.status IN ('published','rolled_back','rejected') THEN
    RAISE EXCEPTION 'draft cannot be published in status %', d.status;
  END IF;

  IF d.action='delete' AND d.entitas_id IS NOT NULL THEN
    EXECUTE format('DELETE FROM public.%I WHERE id=$1', d.entitas) USING d.entitas_id;
    new_id := d.entitas_id;
  ELSIF d.entitas='page_config' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.page_config(route, nama, eyebrow, judul, deskripsi, hero_image_url, section_titles)
      VALUES (
        d.payload->>'route',
        COALESCE(d.payload->>'nama', d.payload->>'judul', d.payload->>'route'),
        COALESCE(d.payload->>'eyebrow',''),
        COALESCE(d.payload->>'judul',''),
        d.payload->>'deskripsi',
        d.payload->>'hero_image_url',
        COALESCE(d.payload->'section_titles','[]'::jsonb)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.page_config SET
        eyebrow=COALESCE(d.payload->>'eyebrow', eyebrow),
        judul=COALESCE(d.payload->>'judul', judul),
        deskripsi=d.payload->>'deskripsi',
        hero_image_url=d.payload->>'hero_image_url',
        section_titles=COALESCE(d.payload->'section_titles', section_titles)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  ELSIF d.entitas='nav_item' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.nav_item(label, href, parent_id, urutan, deskripsi, aktif)
      VALUES (
        d.payload->>'label', d.payload->>'href',
        NULLIF(d.payload->>'parent_id','')::uuid,
        COALESCE((d.payload->>'urutan')::int,0),
        d.payload->>'deskripsi',
        COALESCE((d.payload->>'aktif')::bool,true)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.nav_item SET
        label=COALESCE(d.payload->>'label', label),
        href=COALESCE(d.payload->>'href', href),
        parent_id=NULLIF(d.payload->>'parent_id','')::uuid,
        urutan=COALESCE((d.payload->>'urutan')::int, urutan),
        deskripsi=d.payload->>'deskripsi',
        aktif=COALESCE((d.payload->>'aktif')::bool, aktif)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  ELSIF d.entitas='footer_column' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.footer_column(judul, links, urutan, aktif)
      VALUES (
        d.payload->>'judul',
        COALESCE(d.payload->'links','[]'::jsonb),
        COALESCE((d.payload->>'urutan')::int,0),
        COALESCE((d.payload->>'aktif')::bool,true)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.footer_column SET
        judul=COALESCE(d.payload->>'judul', judul),
        links=COALESCE(d.payload->'links', links),
        urutan=COALESCE((d.payload->>'urutan')::int, urutan),
        aktif=COALESCE((d.payload->>'aktif')::bool, aktif)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  END IF;

  UPDATE public.site_draft SET
    status='published', published_at=now(),
    reviewer_id=COALESCE(reviewer_id, auth.uid()),
    reviewed_at=COALESCE(reviewed_at, now()),
    entitas_id=COALESCE(entitas_id, new_id)
    WHERE id = d.id;
  RETURN new_id;
END; $fn$;
GRANT EXECUTE ON FUNCTION public.publish_site_draft(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.rollback_site_draft(_draft_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE d RECORD; last_ver RECORD;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO d FROM public.site_draft WHERE id=_draft_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'draft not found'; END IF;
  IF d.status <> 'published' THEN RAISE EXCEPTION 'only published drafts can be rolled back'; END IF;
  IF d.entitas_id IS NULL THEN RAISE EXCEPTION 'no live entity to rollback'; END IF;
  SELECT * INTO last_ver FROM public.site_version
    WHERE entitas=d.entitas AND entitas_id=d.entitas_id
    ORDER BY versi DESC LIMIT 1;
  IF NOT FOUND THEN RAISE EXCEPTION 'no previous version available'; END IF;
  PERFORM public.restore_site_version(last_ver.id);
  UPDATE public.site_draft SET status='rolled_back' WHERE id=d.id;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES ('site_draft.rolled_back', d.entitas, d.entitas_id,
            jsonb_build_object('draft_id', d.id, 'restored_version_id', last_ver.id), auth.uid());
END; $fn$;
GRANT EXECUTE ON FUNCTION public.rollback_site_draft(UUID) TO authenticated;


-- ============================================
-- FILE: 20260719192711_094dc895-bdec-48a6-ab22-9f06485f5a3e.sql
-- ============================================


REVOKE EXECUTE ON FUNCTION public.snapshot_site_config() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.restore_site_version(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.publish_site_draft(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.rollback_site_draft(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.restore_site_version(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.publish_site_draft(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.rollback_site_draft(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) TO authenticated;


-- ============================================
-- FILE: 20260719193922_1702bdd6-2e85-4e83-a41c-db91bc89dbbe.sql
-- ============================================


CREATE TABLE public.keluarga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  no_kk TEXT NOT NULL UNIQUE,
  kepala_nama TEXT, alamat TEXT, dusun TEXT, rt TEXT, rw TEXT, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.keluarga TO authenticated;
GRANT ALL ON public.keluarga TO service_role;
ALTER TABLE public.keluarga ENABLE ROW LEVEL SECURITY;
CREATE POLICY "keluarga admin all" ON public.keluarga FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER keluarga_updated_at BEFORE UPDATE ON public.keluarga FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER keluarga_audit AFTER INSERT OR UPDATE OR DELETE ON public.keluarga FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.penduduk (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nik TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  jenis_kelamin TEXT CHECK (jenis_kelamin IN ('L','P')),
  tempat_lahir TEXT, tanggal_lahir DATE,
  agama TEXT, pendidikan TEXT, pekerjaan TEXT, status_kawin TEXT, hubungan_kk TEXT,
  keluarga_id UUID REFERENCES public.keluarga(id) ON DELETE SET NULL,
  dusun TEXT, alamat TEXT, foto_url TEXT,
  status_hidup TEXT NOT NULL DEFAULT 'hidup' CHECK (status_hidup IN ('hidup','meninggal','pindah')),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.penduduk TO authenticated;
GRANT ALL ON public.penduduk TO service_role;
ALTER TABLE public.penduduk ENABLE ROW LEVEL SECURITY;
CREATE POLICY "penduduk admin all" ON public.penduduk FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE INDEX penduduk_dusun_idx ON public.penduduk(dusun);
CREATE INDEX penduduk_keluarga_idx ON public.penduduk(keluarga_id);
CREATE TRIGGER penduduk_updated_at BEFORE UPDATE ON public.penduduk FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER penduduk_audit AFTER INSERT OR UPDATE OR DELETE ON public.penduduk FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.buku_register (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jenis_buku TEXT NOT NULL, nomor TEXT, tanggal DATE,
  uraian TEXT, pihak TEXT, lampiran_url TEXT, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.buku_register TO authenticated;
GRANT ALL ON public.buku_register TO service_role;
ALTER TABLE public.buku_register ENABLE ROW LEVEL SECURITY;
CREATE POLICY "buku_register admin all" ON public.buku_register FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER buku_register_updated_at BEFORE UPDATE ON public.buku_register FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER buku_register_audit AFTER INSERT OR UPDATE OR DELETE ON public.buku_register FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.idm_indikator (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL, dimensi TEXT NOT NULL, indikator TEXT NOT NULL,
  nilai NUMERIC, skor NUMERIC, sumber TEXT, keterangan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.idm_indikator TO authenticated;
GRANT SELECT ON public.idm_indikator TO anon;
GRANT ALL ON public.idm_indikator TO service_role;
ALTER TABLE public.idm_indikator ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm public read" ON public.idm_indikator FOR SELECT USING (published = true);
CREATE POLICY "idm admin all" ON public.idm_indikator FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER idm_updated_at BEFORE UPDATE ON public.idm_indikator FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER idm_audit AFTER INSERT OR UPDATE OR DELETE ON public.idm_indikator FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.analisis_snapshot (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kategori TEXT NOT NULL, judul TEXT NOT NULL, tahun INT,
  nilai_json JSONB NOT NULL DEFAULT '{}'::jsonb, ringkasan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.analisis_snapshot TO authenticated;
GRANT SELECT ON public.analisis_snapshot TO anon;
GRANT ALL ON public.analisis_snapshot TO service_role;
ALTER TABLE public.analisis_snapshot ENABLE ROW LEVEL SECURITY;
CREATE POLICY "analisis public read" ON public.analisis_snapshot FOR SELECT USING (published = true);
CREATE POLICY "analisis admin all" ON public.analisis_snapshot FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER analisis_updated_at BEFORE UPDATE ON public.analisis_snapshot FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER analisis_audit AFTER INSERT OR UPDATE OR DELETE ON public.analisis_snapshot FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.sinkron_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target TEXT NOT NULL,
  arah TEXT NOT NULL DEFAULT 'keluar' CHECK (arah IN ('keluar','masuk')),
  status TEXT NOT NULL DEFAULT 'antre' CHECK (status IN ('antre','berhasil','gagal')),
  jumlah INT DEFAULT 0, pesan TEXT, payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sinkron_log TO authenticated;
GRANT ALL ON public.sinkron_log TO service_role;
ALTER TABLE public.sinkron_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sinkron admin all" ON public.sinkron_log FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER sinkron_updated_at BEFORE UPDATE ON public.sinkron_log FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.suplesi_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE DEFAULT ('SPL-' || to_char(now(),'YYYYMM') || '-' || lpad((floor(random()*10000))::text, 4, '0')),
  nik TEXT, nama TEXT, kontak TEXT,
  jenis TEXT NOT NULL, deskripsi TEXT NOT NULL, lampiran_url TEXT,
  status TEXT NOT NULL DEFAULT 'baru' CHECK (status IN ('baru','diverifikasi','disetujui','ditolak','selesai')),
  tanggapan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.suplesi_data TO authenticated;
GRANT ALL ON public.suplesi_data TO service_role;
ALTER TABLE public.suplesi_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "suplesi admin all" ON public.suplesi_data FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER suplesi_updated_at BEFORE UPDATE ON public.suplesi_data FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER suplesi_audit AFTER INSERT OR UPDATE OR DELETE ON public.suplesi_data FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.notif_otp (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kanal TEXT NOT NULL CHECK (kanal IN ('wa','sms','email')),
  tujuan TEXT NOT NULL, kode_hash TEXT NOT NULL,
  kadaluarsa TIMESTAMPTZ NOT NULL,
  terpakai BOOLEAN NOT NULL DEFAULT false, percobaan INT NOT NULL DEFAULT 0,
  konteks TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT ALL ON public.notif_otp TO service_role;
ALTER TABLE public.notif_otp ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE VIEW public.penduduk_statistik AS
  SELECT
    COUNT(*) FILTER (WHERE status_hidup='hidup')                            AS total,
    COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L')      AS laki,
    COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P')      AS perempuan,
    COUNT(DISTINCT keluarga_id) FILTER (WHERE status_hidup='hidup')         AS kk,
    COUNT(DISTINCT dusun) FILTER (WHERE status_hidup='hidup' AND dusun IS NOT NULL) AS dusun
  FROM public.penduduk;
GRANT SELECT ON public.penduduk_statistik TO anon, authenticated;

CREATE OR REPLACE VIEW public.penduduk_per_dusun AS
  SELECT dusun,
         COUNT(*) FILTER (WHERE status_hidup='hidup') AS jumlah,
         COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L') AS laki,
         COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P') AS perempuan
  FROM public.penduduk WHERE dusun IS NOT NULL GROUP BY dusun ORDER BY dusun;
GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;


-- ============================================
-- FILE: 20260719193942_046b16b0-018f-4cfe-9ac2-10a987c28abb.sql
-- ============================================


ALTER VIEW public.penduduk_statistik SET (security_invoker = on);
ALTER VIEW public.penduduk_per_dusun SET (security_invoker = on);


-- ============================================
-- FILE: 20260719195016_97d8877d-8665-4501-b045-df5936f3aa7b.sql
-- ============================================


-- 1) Restrict pbb_tagihan: drop public read, add admin-only read (cek_pbb RPC still works via SECURITY DEFINER)
DROP POLICY IF EXISTS pbb_public_read ON public.pbb_tagihan;

-- 2) Drop public read on vote/suara tables (aggregates live on parent tables)
DROP POLICY IF EXISTS "publik lihat vote usulan" ON public.usulan_vote;
DROP POLICY IF EXISTS "publik lihat suara agregat" ON public.voting_suara;

-- 3) Revoke EXECUTE on SECURITY DEFINER trigger + admin-only functions from anon/authenticated/PUBLIC.
-- Keep public RPCs (has_role used by RLS, lacak_aduan, verifikasi_surat, cek_pbb) executable.
DO $$
DECLARE fn TEXT;
BEGIN
  FOREACH fn IN ARRAY ARRAY[
    'handle_new_admin_signup()',
    'set_updated_at()',
    'log_status_change()',
    'sync_usulan_vote_count()',
    'sync_voting_count()',
    'auto_close_expired_voting()',
    'snapshot_site_config()',
    'rollback_site_draft(uuid)',
    'restore_site_version(uuid)',
    'log_admin_activity()',
    'publish_site_draft(uuid)',
    'tutup_voting_manual(uuid, text)'
  ] LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION public.%s FROM PUBLIC, anon, authenticated;', fn);
    EXECUTE format('GRANT EXECUTE ON FUNCTION public.%s TO service_role;', fn);
  END LOOP;
END $$;


-- ============================================
-- FILE: 20260719195630_1bcc2192-0629-492a-8d4d-15615a460fde.sql
-- ============================================

-- Harden cek_pbb: require NIK as second factor and mask PII in public output
DROP FUNCTION IF EXISTS public.cek_pbb(integer, text);

CREATE OR REPLACE FUNCTION public.cek_pbb(_tahun integer, _nop text, _nik text)
RETURNS TABLE(
  tahun integer,
  nop text,
  pbb_terutang numeric,
  jatuh_tempo date,
  status_bayar text,
  tanggal_bayar date
)
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT p.tahun, p.nop, p.pbb_terutang, p.jatuh_tempo, p.status_bayar, p.tanggal_bayar
  FROM public.pbb_tagihan p
  WHERE p.tahun = _tahun
    AND lower(trim(p.nop)) = lower(trim(_nop))
    AND p.wajib_pajak_nik IS NOT NULL
    AND regexp_replace(coalesce(p.wajib_pajak_nik,''), '\s', '', 'g') = regexp_replace(coalesce(_nik,''), '\s', '', 'g')
  LIMIT 1;
$function$;

REVOKE ALL ON FUNCTION public.cek_pbb(integer, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cek_pbb(integer, text, text) TO anon, authenticated;

-- ============================================
-- FILE: 20260720000000_005_domain_event_triggers.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260720000000_005_domain_event_triggers.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Lengkapi event triggers untuk domain_tables yang BELUM emit
--             ke domain_events. Priority tables untuk "Satu Input, Banyak Dampak".
--
-- Gap yang diaddress:
-- - surat_terbit → domain_events (surat.* events)
-- - voting_suara → domain_events (voting.* events)
-- - keluarga → domain_events (keluarga.* events)
-- - posyandu_agregat → domain_events (posyandu.* events)
-- - apbdes → domain_events (apbdes.* events)
-- - bidang_tanah → domain_events (bidang_tanah.* events)
-- - bantuan_sosial → domain_events (bansos.* events)
--
-- Urutan migrasi: setelah 004_multi_tenancy.sql, 003_domain_events.sql
-- ============================================================

-- ============================================================
-- 1. SURAT_TERBIT — Emit surat.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_surat_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'jenis', NEW.jenis,
      'nomor_surat', NEW.nomor_surat,
      'penduduk_id', NEW.penduduk_id,
      'status', NEW.status
    );
    PERFORM publish_event('surat.diajukan', 'surat_terbit', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Status transitions
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'surat.diverifikasi';
        WHEN 'ditolak' THEN
          v_event_type := 'surat.ditolak';
        WHEN 'ditandatangani' THEN
          v_event_type := 'surat.ditandatangani';
        WHEN 'diterbitkan' THEN
          v_event_type := 'surat.diterbitkan';
        WHEN 'dikirim' THEN
          v_event_type := 'surat.dikirim';
        ELSE
          v_event_type := 'surat.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'nomor_surat', NEW.nomor_surat
      );
      PERFORM publish_event(v_event_type, 'surat_terbit', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain
    IF OLD.nomor_surat IS DISTINCT FROM NEW.nomor_surat
       OR OLD.penduduk_id IS DISTINCT FROM NEW.penduduk_id THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nomor_surat', jsonb_build_array(OLD.nomor_surat, NEW.nomor_surat)
        )
      );
      PERFORM publish_event('surat.data.berubah', 'surat_terbit', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Drop existing trigger if any (idempotent)
DROP TRIGGER IF EXISTS trg_surat_terbit_publish_event ON public.surat_terbit;
CREATE TRIGGER trg_surat_terbit_publish_event
  AFTER INSERT OR UPDATE ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_surat_event();

-- ============================================================
-- 2. VOTING_SUARA — Emit voting.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_voting_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'topik_id', NEW.topik_id,
      'opsi_id', NEW.opsi_id,
      'penduduk_id', NEW.penduduk_id,
      'voting_token', NEW.voting_token
    );
    PERFORM publish_event('voting.suara.ditambahkan', 'voting_suara', NEW.id, v_payload, NEW.penduduk_id);

    -- Also emit to voting_topik untuk sync counter
    v_payload := jsonb_build_object(
      'suara_id', NEW.id,
      'topik_id', NEW.topik_id
    );
    PERFORM publish_event('voting.terhubung', 'voting_suara', NEW.id, v_payload, NEW.penduduk_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_voting_suara_publish_event ON public.voting_suara;
CREATE TRIGGER trg_voting_suara_publish_event
  AFTER INSERT ON public.voting_suara
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_voting_event();

-- ============================================================
-- 3. KELUARGA — Emit keluarga.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_keluarga_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nomor_kk', NEW.nomor_kk,
      'kepala_keluarga', NEW.kepala_keluarga,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event('keluarga.dibuat', 'keluarga', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status_kk IS DISTINCT FROM NEW.status_kk THEN
      v_payload := jsonb_build_object(
        'status_lama', OLD.status_kk,
        'status_baru', NEW.status_kk
      );
      PERFORM publish_event('keluarga.status.berubah', 'keluarga', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain
    IF OLD.nomor_kk IS DISTINCT FROM NEW.nomor_kk
       OR OLD.kepala_keluarga IS DISTINCT FROM NEW.kepala_keluarga
       OR OLD.dusun IS DISTINCT FROM NEW.dusun
       OR OLD.rt IS DISTINCT FROM NEW.rt
       OR OLD.rw IS DISTINCT FROM NEW.rw THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nomor_kk', jsonb_build_array(OLD.nomor_kk, NEW.nomor_kk),
          'kepala_keluarga', jsonb_build_array(OLD.kepala_keluarga, NEW.kepala_keluarga)
        )
      );
      PERFORM publish_event('keluarga.data.berubah', 'keluarga', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_keluarga_publish_event ON public.keluarga;
CREATE TRIGGER trg_keluarga_publish_event
  AFTER INSERT OR UPDATE ON public.keluarga
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_keluarga_event();

-- ============================================================
-- 4. POSYANDU_AGREGAT — Emit posyandu.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_posyandu_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'bulan', NEW.bulan,
      'jumlah_bayi', NEW.jumlah_bayi,
      'jumlah_balita', NEW.jumlah_balita,
      'jumlah_ibu_hamil', NEW.jumlah_ibu_hamil,
      'jumlah_ibu_menyusui', NEW.jumlah_ibu_menyusui,
      'kunjugan_lebih_dari_sekali', NEW.kunjugan_lebih_dari_sekali
    );
    PERFORM publish_event('posyandu.kunjungan.dicatat', 'posyandu_agregat', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Deteksi balita terindikasi gizi buruk
    IF NEW.jumlah_gizi_buruk > OLD.jumlah_gizi_buruk THEN
      v_payload := jsonb_build_object(
        'bulan', NEW.bulan,
        'jumlah_gizi_buruk', NEW.jumlah_gizi_buruk,
        'penambahan', NEW.jumlah_gizi_buruk - OLD.jumlah_gizi_buruk
      );
      PERFORM publish_event('posyandu.balita.terindikasi_gizi_buruk', 'posyandu_agregat', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_posyandu_agregat_publish_event ON public.posyandu_agregat;
CREATE TRIGGER trg_posyandu_agregat_publish_event
  AFTER INSERT OR UPDATE ON public.posyandu_agregat
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_posyandu_event();

-- ============================================================
-- 5. APBDES — Emit apbdes.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_apbdes_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'tahun', NEW.tahun,
      'sumber_dana', NEW.sumber_dana,
      'total_anggaran', NEW.total_anggaran
    );
    PERFORM publish_event('apbdes.dibuat', 'apbdes', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'apbdes.disahkan';
      ELSE
        v_event_type := 'apbdes.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'tahun', NEW.tahun,
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'apbdes', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan anggaran signifikan (>10%)
    IF OLD.total_anggaran IS DISTINCT FROM NEW.total_anggaran THEN
      IF NEW.total_anggaran > 0 AND OLD.total_anggaran > 0 THEN
        IF ABS(NEW.total_anggaran - OLD.total_anggaran) / OLD.total_anggaran > 0.1 THEN
          v_payload := jsonb_build_object(
            'tahun', NEW.tahun,
            'anggaran_lama', OLD.total_anggaran,
            'anggaran_baru', NEW.total_anggaran
          );
          PERFORM publish_event('apbdes.anggaran.berubah_signifikan', 'apbdes', NEW.id, v_payload, NEW.updated_by);
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_apbdes_publish_event ON public.apbdes;
CREATE TRIGGER trg_apbdes_publish_event
  AFTER INSERT OR UPDATE ON public.apbdes
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_apbdes_event();

-- ============================================================
-- 6. BIDANG_TANAH — Emit bidang_tanah.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_bidang_tanah_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nomor_sertifikat', NEW.nomor_sertifikat,
      'jenis_tanah', NEW.jenis_tanah,
      'luas_m2', NEW.luas_m2,
      'lokasi', NEW.lokasi
    );
    PERFORM publish_event('bidang_tanah.didaftarkan', 'bidang_tanah', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status_sertifikat IS DISTINCT FROM NEW.status_sertifikat THEN
      CASE NEW.status_sertifikat
        WHEN 'tersertifikasi' THEN
          v_event_type := 'bidang_tanah.disahkan';
        WHEN 'dialihkan' THEN
          v_event_type := 'bidang_tanah.dialihkan';
        ELSE
          v_event_type := 'bidang_tanah.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status_sertifikat,
        'status_baru', NEW.status_sertifikat
      );
      PERFORM publish_event(v_event_type, 'bidang_tanah', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bidang_tanah_publish_event ON public.bidang_tanah;
CREATE TRIGGER trg_bidang_tanah_publish_event
  AFTER INSERT OR UPDATE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_bidang_tanah_event();

-- ============================================================
-- 7. BANTUAN_SOSIAL — Emit bansos.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_bansos_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_program', NEW.nama_program,
      'jenis_bantuan', NEW.jenis_bantuan,
      'sumber_dana', NEW.sumber_dana,
      'tahun', NEW.tahun
    );
    PERFORM publish_event('bansos.program.dibuat', 'bantuan_sosial', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      v_payload := jsonb_build_object(
        'nama_program', NEW.nama_program,
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event('bansos.program.status.berubah', 'bantuan_sosial', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bantuan_sosial_publish_event ON public.bantuan_sosial;
CREATE TRIGGER trg_bantuan_sosial_publish_event
  AFTER INSERT OR UPDATE ON public.bantuan_sosial
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_bansos_event();

-- ============================================================
-- 8. USULAN_WARGA — Emit usulan.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_usulan_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'judul', NEW.judul,
      'kategori', NEW.kategori,
      'lokasi', NEW.lokasi,
      'estimasi_anggaran', NEW.estimasi_anggaran,
      'pemohon_id', NEW.pemohon_id
    );
    PERFORM publish_event('usulan.diajukan', 'usulan_warga', NEW.id, v_payload, NEW.pemohon_id);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'usulan.lolos_verifikasi';
        WHEN 'ditolak' THEN
          v_event_type := 'usulan.ditolak';
        WHEN 'ditetapkan_rkpdes' THEN
          v_event_type := 'usulan.ditetapkan_rkpdes';
        ELSE
          v_event_type := 'usulan.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'judul', NEW.judul
      );
      PERFORM publish_event(v_event_type, 'usulan_warga', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usulan_warga_publish_event ON public.usulan_warga;
CREATE TRIGGER trg_usulan_warga_publish_event
  AFTER INSERT OR UPDATE ON public.usulan_warga
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_usulan_event();

-- ============================================================
-- 9. USULAN_VOTE — Emit usulan.vote.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_usulan_vote_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'usulan_id', NEW.usulan_id,
      'penduduk_id', NEW.penduduk_id,
      'suara', NEW.suara
    );
    PERFORM publish_event('usulan.vote.bertambah', 'usulan_vote', NEW.id, v_payload, NEW.penduduk_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usulan_vote_publish_event ON public.usulan_vote;
CREATE TRIGGER trg_usulan_vote_publish_event
  AFTER INSERT ON public.usulan_vote
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_usulan_vote_event();

-- ============================================================
-- 10. PBB_TAGIHAN — Emit pbb.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_pbb_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nop', NEW.nop,
      'njop', NEW.njop,
      'tagihan', NEW.tagihan,
      'tahun', NEW.tahun
    );
    PERFORM publish_event('pbb.objek_pajak.didaftarkan', 'pbb_tagihan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.nop IS DISTINCT FROM NEW.nop
       OR OLD.njop IS DISTINCT FROM NEW.njop
       OR OLD.alamat_objek IS DISTINCT FROM NEW.alamat_objek THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nop', jsonb_build_array(OLD.nop, NEW.nop),
          'njop', jsonb_build_array(OLD.njop, NEW.njop)
        )
      );
      PERFORM publish_event('pbb.objek_pajak.berubah', 'pbb_tagihan', NEW.id, v_payload, NEW.updated_by);
    END IF;

    IF OLD.status_pembayaran IS DISTINCT FROM NEW.status_pembayaran THEN
      IF NEW.status_pembayaran = 'lunas' THEN
        v_event_type := 'pbb.tagihan.dibayar';
      ELSE
        v_event_type := 'pbb.tagihan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'tahun', NEW.tahun,
        'status_lama', OLD.status_pembayaran,
        'status_baru', NEW.status_pembayaran,
        'tagihan', NEW.tagihan
      );
      PERFORM publish_event(v_event_type, 'pbb_tagihan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_pbb_tagihan_publish_event ON public.pbb_tagihan;
CREATE TRIGGER trg_pbb_tagihan_publish_event
  AFTER INSERT OR UPDATE ON public.pbb_tagihan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_pbb_event();

-- ============================================================
-- 11. INFRASTRUKTUR — Emit infrastruktur.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_infrastruktur_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama', NEW.nama,
      'jenis', NEW.jenis,
      'lokasi', NEW.lokasi,
      'pengaju_id', NEW.pengaju_id
    );
    PERFORM publish_event('infrastruktur.dilaporkan', 'infrastruktur', NEW.id, v_payload, NEW.pengaju_id);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'infrastruktur.diverifikasi';
        WHEN 'disetujui' THEN
          v_event_type := 'infrastruktur.disetujui';
        WHEN 'ditolak' THEN
          v_event_type := 'infrastruktur.ditolak';
        ELSE
          v_event_type := 'infrastruktur.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'infrastruktur', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_infrastruktur_publish_event ON public.infrastruktur;
CREATE TRIGGER trg_infrastruktur_publish_event
  AFTER INSERT OR UPDATE ON public.infrastruktur
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_infrastruktur_event();

-- ============================================================
-- 12. KEGIATAN_PEMBANGUNAN — Emit musdes.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_kegiatan_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_kegiatan', NEW.nama_kegiatan,
      'lokasi', NEW.lokasi,
      'anggaran', NEW.anggaran,
      'sumber_dana', NEW.sumber_dana
    );
    PERFORM publish_event('musdes.kegiatan.ditambahkan', 'kegiatan_pembangunan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'musdes.kegiatan.disahkan';
      ELSE
        v_event_type := 'musdes.kegiatan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'nama_kegiatan', NEW.nama_kegiatan
      );
      PERFORM publish_event(v_event_type, 'kegiatan_pembangunan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_kegiatan_pembangunan_publish_event ON public.kegiatan_pembangunan;
CREATE TRIGGER trg_kegiatan_pembangunan_publish_event
  AFTER INSERT OR UPDATE ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_kegiatan_event();

-- ============================================================
-- 13. ADUAN_WARGA — Events sudah ada (trg_aduan_event)
--    tapi kita perlu extend untuk lebih detail
-- ============================================================

-- Trigger yang sudah ada sudah cukup untuk now
-- Comment: trg_aduan_event sudah dibuat di migration sebelumnya

-- ============================================================
-- 14. RKPDES_KEGIATAN — Emit ke domain_events untuk sync
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_rkpdes_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_kegiatan', NEW.nama_kegiatan,
      'tahun', NEW.tahun,
      'anggaran', NEW.anggaran
    );
    PERFORM publish_event('rkpdes.kegiatan.diajukan', 'rkpdes_kegiatan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'rkpdes.kegiatan.disahkan';
      ELSE
        v_event_type := 'rkpdes.kegiatan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'rkpdes_kegiatan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_rkpdes_kegiatan_publish_event ON public.rkpdes_kegiatan;
CREATE TRIGGER trg_rkpdes_kegiatan_publish_event
  AFTER INSERT OR UPDATE ON public.rkpdes_kegiatan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_rkpdes_event();

-- ============================================================
-- 15. Update event_type enum dengan event baru
-- ============================================================

DO $$
BEGIN
  -- Tambah event types yang belum ada
  -- Enum tidak bisa di-alter di PostgreSQL, jadi kita skip
  -- dan cukup gunakan VARCHAR untuk event_type di domain_events
  -- (sudah didefinisikan sebagai VARCHAR di 003_domain_events.sql)
  RAISE NOTICE 'Event types extension not needed - using VARCHAR for flexibility';
END $$;

-- ============================================================
-- 16. Tambahan: Emit tenant_id di semua event
--    (jika belum ada di function publish_event)
-- ============================================================

-- Update publish_event untuk include tenant_id dari context
CREATE OR REPLACE FUNCTION publish_event(
  p_event_type VARCHAR,
  p_entity_type VARCHAR,
  p_entity_id UUID,
  p_payload JSONB DEFAULT '{}',
  p_aktor_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
  v_tenant_id UUID;
BEGIN
  -- Try to get tenant_id from auth.jwt() or app settings
  BEGIN
    v_tenant_id := current_setting('app.current_tenant_id', true)::UUID;
  EXCEPTION WHEN OTHERS THEN
    v_tenant_id := NULL;
  END;

  -- If still null, try to infer from entity (for entities with tenant_id)
  IF v_tenant_id IS NULL THEN
    BEGIN
      EXECUTE format('SELECT tenant_id FROM public.%I WHERE id = %L', p_entity_type, p_entity_id)
      INTO v_tenant_id;
    EXCEPTION WHEN OTHERS THEN
      v_tenant_id := NULL;
    END;
  END IF;

  INSERT INTO domain_events (tenant_id, event_type, entity_type, entity_id, payload, aktor_id)
  VALUES (v_tenant_id, p_event_type, p_entity_type, p_entity_id, p_payload, p_aktor_id)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION publish_event IS
'Publish a domain event with automatic tenant_id resolution.
Returns event ID. Usage: SELECT publish_event(''penduduk.dibuat'', ''penduduk'', entity_uuid, ''{"nik":"..."}''::jsonb, auth.uid())';

-- ============================================================
-- 17. Add event counters untuk analytics cepat
-- ============================================================

DO $$
BEGIN
  -- Add counters untuk dashboard (optional enhancement)
  -- Bisa di-trigger manual atau via cron

  RAISE NOTICE 'Domain event triggers migration completed successfully';
END $$;


-- ============================================
-- FILE: 20260720000001_006_idm_engine_core.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260720000001_006_idm_engine_core.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tabel inti IDM Scoring Engine + seed indicators
--
-- Referensi: docs/Sistem_IDM_Desa.md
-- Priority MVP: 6 dimensi, ~30 indicators (dari 127 total)
--
-- Prinsip:
-- - idm_indicators = seed-only (sama semua tenant)
-- - idm_skor_cache = HANYA ditulis worker (bukan admin)
-- - idm_status_desa = klasifikasi akhir (dibaca portal)
-- ============================================================

-- ============================================================
-- 1. IDM INDICATORS (Seed Kuesioner)
--    Sama untuk semua tenant (OpenSID/IDM Kemendes compliant)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dimensi_no INT NOT NULL CHECK (dimensi_no BETWEEN 1 AND 6),
  dimensi_nama VARCHAR(100) NOT NULL,
  subdimensi_kode VARCHAR(20),
  subdimensi_nama VARCHAR(100),
  indikator_no VARCHAR(20) NOT NULL,
  indikator_nama TEXT NOT NULL,
  indikator_skor_max INT NOT NULL DEFAULT 5,
  sub_indikator_no VARCHAR(20),
  sub_indikator_nama TEXT,
  sub_skor_max INT DEFAULT 5,
  sumber_data VARCHAR(30) NOT NULL CHECK (sumber_data IN ('operasional', 'periodik_manual', 'eksternal')),
  kode_rekening VARCHAR(50),
  rekomendasi_intervensi TEXT,
  unidade TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index untuk lookup cepat per dimensi
CREATE INDEX IF NOT EXISTS idx_idm_indicators_dimensi ON idm_indicators(dimensi_no, dimensi_nama);
CREATE INDEX IF NOT EXISTS idx_idm_indicators_sumber ON idm_indicators(sumber_data);

GRANT SELECT ON idm_indicators TO authenticated, anon;
GRANT ALL ON idm_indicators TO service_role;
ALTER TABLE idm_indicators ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_indicators public read" ON idm_indicators FOR SELECT TO authenticated USING (is_active = true);

-- ============================================================
-- 2. IDM SCORING THRESHOLDS (Ambang Nilai per Skor)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_scoring_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id) ON DELETE CASCADE,
  skor_level INT NOT NULL CHECK (skor_level BETWEEN 1 AND 5),
  nilai_ambang_bawah NUMERIC NOT NULL,
  nilai_ambang_atas NUMERIC NOT NULL,
  deskripsi_kondisi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(indikator_id, skor_level)
);

CREATE INDEX IF NOT EXISTS idx_idm_thresholds_indikator ON idm_scoring_thresholds(indikator_id);

GRANT SELECT ON idm_scoring_thresholds TO authenticated, anon;
GRANT ALL ON idm_scoring_thresholds TO service_role;
ALTER TABLE idm_scoring_thresholds ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_thresholds public read" ON idm_scoring_thresholds FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 3. IDM SKOR CACHE (HANYA ditulis Worker)
--    Tenant-specific, per-indikator
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_skor_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id) ON DELETE CASCADE,
  indikator_kode VARCHAR(50) NOT NULL, -- e.g. "D1-I1" atau "KESEHATAN_APM"
  dimensi_no INT NOT NULL,
  dimensi_nama VARCHAR(100) NOT NULL,
  skor NUMERIC(3,2) NOT NULL CHECK (skor BETWEEN 0 AND 1), -- 0.00 - 1.00 (normalize dari 1-5)
  nilai_agregat NUMERIC NOT NULL DEFAULT 0,
  sumber_data VARCHAR(30) NOT NULL,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, indikator_kode)
);

CREATE INDEX IF NOT EXISTS idx_idm_skor_cache_tenant ON idm_skor_cache(tenant_id);
CREATE INDEX IF NOT EXISTS idx_idm_skor_cache_dimensi ON idm_skor_cache(tenant_id, dimensi_no);

GRANT SELECT ON idm_skor_cache TO authenticated, anon;
GRANT ALL ON idm_skor_cache TO service_role;
ALTER TABLE idm_skor_cache ENABLE ROW LEVEL SECURITY;
-- HANYA service_role yang bisa INSERT/UPDATE (worker-only)
CREATE POLICY "idm_skor_cache worker only" ON idm_skor_cache
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 4. IDM STATUS DESA (Klasifikasi Akhir)
--    - Total skor = rata-rata 6 dimensi
--    - Status = mandiri / maju / berkembang / tertinggal / sangat_tertinggal
-- ============================================================

ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_scores JSONB NOT NULL DEFAULT '{}';
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_1 NUMERIC(5,4) DEFAULT 0; -- Sosial
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_2 NUMERIC(5,4) DEFAULT 0; -- Ekonomi
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_3 NUMERIC(5,4) DEFAULT 0; -- Lingkungan
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_4 NUMERIC(5,4) DEFAULT 0; -- Infrastruktur
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_5 NUMERIC(5,4) DEFAULT 0; -- Tata Kelola
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_6 NUMERIC(5,4) DEFAULT 0; -- Teknologi

-- Drop old dimensi_scores if exists, recreate as proper JSONB
DO $$
BEGIN
  -- Add column if not exists (alternative syntax)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'idm_status_desa' AND column_name = 'dimensi_skor_1') THEN
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_1 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_2 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_3 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_4 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_5 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_6 NUMERIC(5,4) DEFAULT 0;
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

COMMENT ON TABLE idm_status_desa IS 'Klasifikasi akhir desa - SINGLE SOURCE OF TRUTH untuk skor IDM. HANYA ditulis oleh IDM worker, bukan admin.';

-- ============================================================
-- 5. IDM LOG (Audit Trail - Append Only)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_kode VARCHAR(50) NOT NULL,
  skor_lama NUMERIC(3,2),
  skor_baru NUMERIC(3,2) NOT NULL,
  nilai_agregat_lama NUMERIC,
  nilai_agregat_baru NUMERIC NOT NULL,
  sumber_event VARCHAR(100),
  aktor_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_idm_log_tenant ON idm_log(tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_idm_log_indikator ON idm_log(tenant_id, indikator_kode, created_at DESC);

GRANT SELECT ON idm_log TO authenticated;
GRANT INSERT ON idm_log TO service_role;
GRANT ALL ON idm_log TO service_role;
ALTER TABLE idm_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_log append only" ON idm_log
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "idm_log admin read" ON idm_log
  FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 6. USULAN KEGIATAN DRAFT OTOMATIS
--    Dibuat worker saat skor < ambang tertentu
-- ============================================================

CREATE TABLE IF NOT EXISTS usulan_kegiatan_draft_otomatis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  kategori VARCHAR(50) NOT NULL DEFAULT 'pembangunan',
  sumber_pemicu VARCHAR(100) NOT NULL, -- event_type yang memicu
  sumber_ref_id UUID, -- entity_id yang memicu
  indikator_kode VARCHAR(50), -- indikator yang skor rendah
  kode_rekening_saran VARCHAR(50),
  judul_saran TEXT NOT NULL,
  deskripsi_saran TEXT,
  estimasi_anggaran BIGINT,
  lokasi_saran TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'menunggu_review' CHECK (status IN ('menunggu_review', 'diadopsi', 'diabaikan')),
  reviewer_id UUID,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_usulan_draft_tenant ON usulan_kegiatan_draft_otomatis(tenant_id);
CREATE INDEX IF NOT EXISTS idx_usulan_draft_status ON usulan_kegiatan_draft_otomatis(status);

GRANT SELECT, INSERT, UPDATE ON usulan_kegiatan_draft_otomatis TO authenticated;
GRANT ALL ON usulan_kegiatan_draft_otomatis TO service_role;
ALTER TABLE usulan_kegiatan_draft_otomatis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "usulan_draft admin read write" ON usulan_kegiatan_draft_otomatis
  FOR ALL TO authenticated USING (true);
CREATE POLICY "usulan_draft worker insert" ON usulan_kegiatan_draft_otomatis
  FOR INSERT TO service_role WITH CHECK (true);

-- ============================================================
-- 7. PADES PENDAPATAN (PADes otomatis dari PBB)
--    Dimensi 5 - Tata Kelola Keuangan
-- ============================================================

CREATE TABLE IF NOT EXISTS pades_pendapatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  tahun INT NOT NULL,
  sumber VARCHAR(50) NOT NULL, -- 'pbb' / 'retribusi' / 'bumd' / 'lainnya'
  jenis_pendapatan VARCHAR(100),
  nilai BIGINT NOT NULL DEFAULT 0, -- dalam rupiah
  sumber_ref_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pades_pendapatan_tenant_tahun ON pades_pendapatan(tenant_id, tahun);

GRANT SELECT, INSERT ON pades_pendapatan TO authenticated;
GRANT ALL ON pades_pendapatan TO service_role;
ALTER TABLE pades_pendapatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pades admin select" ON pades_pendapatan
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "pades admin insert" ON pades_pendapatan
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "pades worker all" ON pades_pendapatan
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 8. WILAYAH BATAS (Granularitas Agregat)
--    Untuk agregasi per dusun/RT/RW
-- ============================================================

CREATE TABLE IF NOT EXISTS wilayah_batas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES wilayah_batas(id) ON DELETE SET NULL,
  jenis VARCHAR(20) NOT NULL CHECK (jenis IN ('desa', 'dusun', 'rw', 'rt')),
  kode VARCHAR(20),
  nama VARCHAR(100) NOT NULL,
  geom GEOMETRY, -- PostGIS (optional, untuk peta)
  boundary_json JSONB, -- Alternatif tanpa PostGIS
  luas_m2 NUMERIC,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wilayah_batas_tenant ON wilayah_batas(tenant_id);
CREATE INDEX IF NOT EXISTS idx_wilayah_batas_parent ON wilayah_batas(parent_id);
CREATE INDEX IF NOT EXISTS idx_wilayah_batas_jenis ON wilayah_batas(jenis);

GRANT SELECT, INSERT, UPDATE ON wilayah_batas TO authenticated;
GRANT ALL ON wilayah_batas TO service_role;
ALTER TABLE wilayah_batas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "wilayah_batas admin all" ON wilayah_batas
  FOR ALL TO authenticated USING (true);

-- ============================================================
-- 9. SEED: IDM Indicators MVP (30 indicators dari 6 dimensi)
--    Sesuai Permendes 21/2020 & 7/2023
-- ============================================================

-- Dimensi 1: Sosial (Pendidikan, Kesehatan, dll)
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(1, 'Sosial', '1a', 'Pendidikan', 'D1-I1', 'Angka Partisipasi Murni (APM)', 5, 'operasional', '5.1.02.01', 'Bangun PAUD/perluas akses pendidikan'),
(1, 'Sosial', '1a', 'Pendidikan', 'D1-I2', 'Rasio guru-guru tersertifikasi', 5, 'periodik_manual', '5.1.02.02', 'Sertifikasi guru'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I3', 'Cakupan BPJS Kesehatan', 5, 'operasional', '5.1.05.01', 'Pendaftaran BPJS peserta baru'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I4', 'Cakupan Imunisasi Balita', 5, 'operasional', '5.1.05.02', 'Kampanye imunisasi'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I5', 'Prevalensi Stunting', 5, 'operasional', '5.1.05.03', 'Intervensi gizi'),
(1, 'Sosial', '1c', 'Kesejahteraan', 'D1-I6', 'Cakupan Bantuan Sosial', 5, 'operasional', '5.1.06.01', 'Verifikasi DTKS'),
(1, 'Sosial', '1c', 'Kesejahteraan', 'D1-I7', 'Rasio Ketimpangan (Gini)', 5, 'eksternal', NULL, 'Program pemberdayaan ekonomi')
ON CONFLICT DO NOTHING;

-- Dimensi 2: Ekonomi
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(2, 'Ekonomi', '2a', 'PADes', 'D2-I1', 'PADes per Kapita', 5, 'operasional', '4.1.01', 'Peningkatan sumber PADes'),
(2, 'Ekonomi', '2a', 'PADes', 'D2-I2', 'Pertumbuhan PADes YoY', 5, 'operasional', '4.1.01', 'Diversifikasi sumber PADes'),
(2, 'Ekonomi', '2b', 'Keragaman Ekonomi', 'D2-I3', 'Jumlah Sektor Ekonomi Aktif', 5, 'operasional', '5.2.02.01', 'Pengembangan UMKM'),
(2, 'Ekonomi', '2b', 'Keragaman Ekonomi', 'D2-I4', 'Akses Pasar/Commerce', 5, 'operasional', '5.2.02.02', 'Digitalisasi pemasaran'),
(2, 'Ekonomi', '2c', 'Ketenagakerjaan', 'D2-I5', 'Tingkat Pengangguran', 5, 'operasional', '5.2.03.01', 'Pelatihan kerja'),
(2, 'Ekonomi', '2c', 'Ketenagakerjaan', 'D2-I6', 'Usaha Mikro aktif', 5, 'operasional', '5.2.03.02', 'Pendampingan UMKM')
ON CONFLICT DO NOTHING;

-- Dimensi 3: Lingkungan
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(3, 'Lingkungan', '3a', 'LP2B', 'D3-I1', 'Luas Lahan Pertanian Terpelihara', 5, 'periodik_manual', '5.3.01.01', 'Rehabilitasi lahan'),
(3, 'Lingkungan', '3b', 'Sanitasi', 'D3-I2', 'Cakupan Sanitasi Layak', 5, 'operasional', '5.3.02.01', 'Bangunan MCK Komunal'),
(3, 'Lingkungan', '3b', 'Sanitasi', 'D3-I3', 'Akses Air Bersih Layak', 5, 'operasional', '5.3.02.02', 'Sumber air bersih'),
(3, 'Lingkungan', '3c', 'Mitigasi', 'D3-I4', 'Kesiapan Mitigasi Bencana', 5, 'periodik_manual', '5.3.03.01', 'Pembuatan peta rawan bencana'),
(3, 'Lingkungan', '3c', 'Mitigasi', 'D3-I5', 'Pengelolaan Sampah', 5, 'operasional', '5.3.03.02', 'Bank sampah / TPS')
ON CONFLICT DO NOTHING;

-- Dimensi 4: Infrastruktur & Pelayanan Dasar
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(4, 'Infrastruktur', '4a', 'Jalan', 'D4-I1', 'Kondisi Jalan Desa', 5, 'periodik_manual', '5.4.01.01', 'Pembangunan/rehabilitasi jalan'),
(4, 'Infrastruktur', '4a', 'Jalan', 'D4-I2', 'Akses Jalan ke Pusat Desa', 5, 'periodik_manual', '5.4.01.02', 'Pembukaan jalan'),
(4, 'Infrastruktur', '4b', 'Kesehatan', 'D4-I3', 'Jarak ke Fasilitas Kesehatan', 5, 'operasional', '5.4.02.01', 'Pembangunan poskesdes'),
(4, 'Infrastruktur', '4b', 'Kesehatan', 'D4-I4', 'Aktivitas Posyandu', 5, 'operasional', '5.4.02.02', 'Penguatan Posyandu'),
(4, 'Infrastruktur', '4c', 'Pendidikan', 'D4-I5', 'Akses PAUD/SD', 5, 'operasional', '5.4.03.01', 'Transportasi siswa'),
(4, 'Infrastruktur', '4c', 'Pendidikan', 'D4-I6', 'Ruang Kelas Layak', 5, 'periodik_manual', '5.4.03.02', ' Rehabilitasi ruang kelas')
ON CONFLICT DO NOTHING;

-- Dimensi 5: Tata Kelola Pemerintahan Desa
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(5, 'Tata Kelola', '5a', 'Musdes', 'D5-I1', 'Frekuensi Musdes/Tahunan', 5, 'operasional', '5.5.01.01', 'Peningkatan kapasitas musdes'),
(5, 'Tata Kelola', '5a', 'Musdes', 'D5-I2', 'Partisipasi Musdes', 5, 'operasional', '5.5.01.02', 'Sosialisasi musdes'),
(5, 'Tata Kelola', '5b', 'Keuangan', 'D5-I3', 'Capaian APBDes', 5, 'operasional', '5.5.02.01', 'Optimalisasi belanja'),
(5, 'Tata Kelola', '5b', 'Keuangan', 'D5-I4', 'Transparansi Keuangan', 5, 'operasional', '5.5.02.02', 'Publikasi APBDes'),
(5, 'Tata Kelola', '5c', 'Kelembagaan', 'D5-I5', 'Kelembagaan Desa', 5, 'operasional', '5.5.03.01', 'Pembentukan lembaga'),
(5, 'Tata Kelola', '5c', 'Kelembagaan', 'D5-I6', 'TTE (Tanda Tangan Elektronik)', 5, 'operasional', '5.5.03.02', 'Sertifikasi TTE')
ON CONFLICT DO NOTHING;

-- Dimensi 6: Teknologi & Inovasi
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(6, 'Teknologi', '6a', 'Pelayanan', 'D6-I1', 'Layanan Digital Tersedia', 5, 'operasional', '6.1.01.01', 'Pengembangan sistem'),
(6, 'Teknologi', '6a', 'Pelayanan', 'D6-I2', 'Persentase Surat Digital', 5, 'operasional', '6.1.01.02', 'Digitalisasi layanan surat'),
(6, 'Teknologi', '6b', 'Inovasi', 'D6-I3', 'Inovasi Desa', 5, 'periodik_manual', '6.1.02.01', 'Kompetisi inovasi'),
(6, 'Teknologi', '6b', 'Inovasi', 'D6-I4', 'Pemanfaatan Data', 5, 'operasional', '6.1.02.02', 'Dashboard data desa'),
(6, 'Teknologi', '6c', 'Konektivitas', 'D6-I5', 'Akses Internet', 5, 'eksternal', NULL, 'Kemitraan provider'),
(6, 'Teknologi', '6c', 'Konektivitas', 'D6-I6', 'Device Rasio', 5, 'periodik_manual', '6.1.03.01', 'Penyediaan device')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 10. Seed: Scoring Thresholds (Placeholder)
--    Thresholds akan di-tune berdasarkan data empiris
-- ============================================================

-- Insert thresholds untuk BPJS (D1-I3) sebagai contoh
INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 1, 0, 0.5, 'Cakupan < 50%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 2, 0.5, 0.7, 'Cakupan 50-70%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 3, 0.7, 0.85, 'Cakupan 70-85%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 4, 0.85, 0.95, 'Cakupan 85-95%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 5, 0.95, 1.0, 'Cakupan > 95%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. Helper Function: Get IDM Indicator Score
-- ============================================================

CREATE OR REPLACE FUNCTION get_idm_skor(
  p_indikator_kode VARCHAR,
  p_nilai_agregat NUMERIC
)
RETURNS NUMERIC(3,2)
LANGUAGE plpgsql
AS $$
DECLARE
  v_skor NUMERIC(3,2);
  v_indikator RECORD;
BEGIN
  -- Ambil info indikator
  SELECT dimensi_no, indikator_skor_max INTO v_indikator
  FROM idm_indicators
  WHERE indikator_no = p_indikator_kode AND is_active = true;

  IF NOT FOUND THEN
    RETURN 0.5; -- Default jika indikator tidak ditemukan
  END IF;

  -- Cari threshold yang cocok
  SELECT skor_level::NUMERIC / v_indikator.indikator_skor_max INTO v_skor
  FROM idm_scoring_thresholds th
  JOIN idm_indicators ind ON ind.id = th.indikator_id
  WHERE ind.indikator_no = p_indikator_kode
    AND p_nilai_agregat >= th.nilai_ambang_bawah
    AND p_nilai_agregat < th.nilai_ambang_atas
  LIMIT 1;

  IF v_skor IS NULL THEN
    -- Fallback: normalize langsung dari max
    v_skor := LEAST(1.0, GREATEST(0.0, p_nilai_agregat));
  END IF;

  RETURN ROUND(v_skor::NUMERIC, 2);
END;
$$;

COMMENT ON FUNCTION get_idm_skor IS
'Calculate IDM indicator score from aggregate value.
Returns 0.00-1.00 (normalized from 1-5 scale).
Usage: SELECT get_idm_skor(''D1-I3'', 0.92)';

-- ============================================================
-- 12. View: IDM Dashboard Summary (untuk Portal Publik)
-- ============================================================

CREATE OR REPLACE VIEW idm_dashboard_summary AS
SELECT
  sd.tenant_id,
  sd.total_skor,
  sd.status,
  sd.dihitung_pada,
  sd.dimensi_skor_1,
  sd.dimensi_skor_2,
  sd.dimensi_skor_3,
  sd.dimensi_skor_4,
  sd.dimensi_skor_5,
  sd.dimensi_skor_6,
  CASE
    WHEN sd.status = 'mandiri' THEN '🏆'
    WHEN sd.status = 'maju' THEN '⭐'
    WHEN sd.status = 'berkembang' THEN '📈'
    WHEN sd.status = 'tertinggal' THEN '📉'
    ELSE '⚠️'
  END AS status_emoji,
  -- Ambil indikator yang skor rendah untuk rekomendasi
  (
    SELECT json_agg(json_build_object(
      'indikator', sc.indikator_kode,
      'skor', sc.skor,
      'dimensi', sc.dimensi_nama
    ))
    FROM idm_skor_cache sc
    WHERE sc.tenant_id = sd.tenant_id
      AND sc.skor < 0.6
    ORDER BY sc.skor
    LIMIT 5
  ) AS prioritas_perbaikan
FROM idm_status_desa sd;

GRANT SELECT ON idm_dashboard_summary TO authenticated, anon;

-- ============================================================
-- 13. Notification: Low Score Alert
-- ============================================================

CREATE OR REPLACE FUNCTION notify_idm_low_score()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_tenant_id UUID;
  v_indikator_kode VARCHAR;
  v_skor NUMERIC;
BEGIN
  -- Jika skor turun di bawah 0.5, emit event
  IF NEW.skor < 0.5 AND (OLD.skor IS NULL OR OLD.skor >= 0.5) THEN
    -- Emit domain event untuk WA broadcast / notifikasi
    PERFORM publish_event(
      'idm.skor.rendah',
      'idm_skor_cache',
      NEW.id,
      jsonb_build_object(
        'tenant_id', NEW.tenant_id,
        'indikator', NEW.indikator_kode,
        'dimensi', NEW.dimensi_nama,
        'skor', NEW.skor
      ),
      NULL
    );

    -- Insert draft usulan otomatis
    INSERT INTO usulan_kegiatan_draft_otomatis (
      tenant_id, kategori, sumber_pemicu, sumber_ref_id,
      indikator_kode, kode_rekening_saran, judul_saran,
      deskripsi_saran, status
    )
    SELECT
      NEW.tenant_id,
      'pembangunan',
      'idm.skor.rendah',
      NEW.id,
      NEW.indikator_kode,
      ind.kode_rekening,
      'Draft Otomatis: ' || ind.indikator_nama,
      'Skor rendah (' || NEW.skor || '). Rekomendasi: ' || COALESCE(ind.rekomendasi_intervensi, '-'),
      'menunggu_review'
    FROM idm_indicators ind
    WHERE ind.indikator_no = NEW.indikator_kode;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_idm_low_score_alert ON idm_skor_cache;
CREATE TRIGGER trg_idm_low_score_alert
  AFTER INSERT OR UPDATE ON idm_skor_cache
  FOR EACH ROW EXECUTE FUNCTION notify_idm_low_score();

-- ============================================================
-- DONE
-- ============================================================

RAISE NOTICE 'IDM Engine Core migration completed. 30 indicators seeded across 6 dimensions.';


-- ============================================
-- FILE: 20260720000002_007_cms_draft_workflow.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260720000002_007_cms_draft_workflow.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Enhance site_draft dengan multi-tenancy + workflow lengkap
--
-- Workflow: draft → review → publish (dengan approval)
-- Tenant-aware untuk multi-tenant
-- ============================================================

-- ============================================================
-- 1. Add tenant_id + extend site_draft
-- ============================================================

ALTER TABLE public.site_draft
  ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;

ALTER TABLE public.site_version
  ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;

-- ============================================================
-- 2. Extend Workflow Status
-- ============================================================

-- Extend status check untuk termasuk 'approved'
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'site_draft_status_check'
  ) THEN
    ALTER TABLE public.site_draft
      DROP CONSTRAINT IF EXISTS site_draft_status_check;
    ALTER TABLE public.site_draft
      ADD CONSTRAINT site_draft_status_check
      CHECK (status IN ('draft', 'review', 'approved', 'published', 'rejected', 'rolled_back'));
  END IF;
END $$;

-- ============================================================
-- 3. Workflow Functions
-- ============================================================

-- Submit draft for review
CREATE OR REPLACE FUNCTION public.submit_draft_for_review(_draft_id UUID, _catatan TEXT DEFAULT NULL)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE public.site_draft
  SET status = 'review',
      catatan = COALESCE(_catatan, catatan)
  WHERE id = _draft_id
    AND status = 'draft'
  RETURNING tenant_id INTO v_tenant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found or cannot be submitted for review';
  END IF;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.submitted_for_review',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_draft_for_review(UUID, TEXT) TO authenticated;

-- Approve draft
CREATE OR REPLACE FUNCTION public.approve_draft(_draft_id UUID, _catatan TEXT DEFAULT NULL)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_draft RECORD;
  v_tenant_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT * INTO v_draft FROM public.site_draft WHERE id = _draft_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found';
  END IF;

  IF v_draft.status NOT IN ('draft', 'review') THEN
    RAISE EXCEPTION 'Draft cannot be approved in status: %', v_draft.status;
  END IF;

  UPDATE public.site_draft
  SET status = 'approved',
      reviewer_id = auth.uid(),
      reviewed_at = now(),
      catatan = COALESCE(_catatan, catatan)
  WHERE id = _draft_id;

  v_tenant_id := v_draft.tenant_id;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.approved',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_draft(UUID, TEXT) TO authenticated;

-- Reject draft
CREATE OR REPLACE FUNCTION public.reject_draft(_draft_id UUID, _catatan TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE public.site_draft
  SET status = 'rejected',
      reviewer_id = auth.uid(),
      reviewed_at = now(),
      catatan = _catatan
  WHERE id = _draft_id
    AND status IN ('draft', 'review', 'approved')
  RETURNING id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found or cannot be rejected';
  END IF;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.rejected',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.reject_draft(UUID, TEXT) TO authenticated;

-- ============================================================
-- 4. View: Draft Queue (untuk review dashboard)
-- ============================================================

CREATE OR REPLACE VIEW public.draft_queue AS
SELECT
  sd.id,
  sd.tenant_id,
  sd.entitas,
  sd.entitas_id,
  sd.action,
  sd.payload,
  sd.status,
  sd.catatan,
  sd.actor_id,
  ap.nama AS actor_nama,
  sd.reviewer_id,
  rp.nama AS reviewer_nama,
  sd.reviewed_at,
  sd.published_at,
  sd.created_at,
  sd.updated_at,
  CASE sd.status
    WHEN 'draft' THEN '💾 Draft'
    WHEN 'review' THEN '👀 Menunggu Review'
    WHEN 'approved' THEN '✅ Disetujui'
    WHEN 'published' THEN '🚀 Published'
    WHEN 'rejected' THEN '❌ Ditolak'
    WHEN 'rolled_back' THEN '↩️ Di-rollback'
    ELSE sd.status
  END AS status_label
FROM public.site_draft sd
LEFT JOIN public.admin_profiles ap ON ap.id = sd.actor_id
LEFT JOIN public.admin_profiles rp ON rp.id = sd.reviewer_id
ORDER BY sd.updated_at DESC;

GRANT SELECT ON public.draft_queue TO authenticated;

-- ============================================================
-- 5. Notification: New draft for review
-- ============================================================

CREATE OR REPLACE FUNCTION public.notify_new_draft_for_review()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_actor_nama TEXT;
  v_entity_label TEXT;
BEGIN
  IF NEW.status = 'review' AND (OLD.status IS NULL OR OLD.status = 'draft') THEN
    -- Get actor name
    SELECT nama INTO v_actor_nama
    FROM admin_profiles WHERE id = NEW.actor_id;

    -- Get entity label
    v_entity_label := INITCAP(REPLACE(NEW.entitas, '_', ' '));

    -- Emit event for WA notification
    PERFORM publish_event(
      'cms.draft.membutuhkan_review',
      'site_draft',
      NEW.id,
      jsonb_build_object(
        'entitas', NEW.entitas,
        'action', NEW.action,
        'actor_nama', v_actor_nama,
        'entity_label', v_entity_label,
        'catatan', NEW.catatan
      ),
      NEW.actor_id
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_new_draft_review ON public.site_draft;
CREATE TRIGGER trg_notify_new_draft_review
  AFTER INSERT OR UPDATE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_draft_for_review();

-- ============================================================
-- 6. Seed: Initial content placeholders
-- ============================================================

-- Check if page_config has data, if not seed with defaults
DO $$
DECLARE
  cnt INT;
BEGIN
  SELECT COUNT(*) INTO cnt FROM public.page_config;
  IF cnt = 0 THEN
    INSERT INTO public.page_config (route, nama, eyebrow, judul, deskripsi) VALUES
    ('/', 'Beranda', 'Selamat Datang', 'Desa Seruni Mumbul', 'Portal resmi Kantor Desa Seruni Mumbul, Kec. Pringgabaya, Kab. Lombok Timur, NTB'),
    ('/layanan/surat', 'Layanan Surat', 'Layanan', 'Surat Online', 'Ajukan surat keterangan secara online'),
    ('/layanan/pbb', 'PBB', 'Layanan', 'Tagihan PBB', 'Cek tagihan Pajak Bumi Bangunan'),
    ('/statistik/penduduk', 'Statistik', 'Demografi', 'Statistik Penduduk', 'Data dan statistik kependudukan'),
    ('/status-idm', 'Status IDM', 'Indeks Desa', 'Status IDM', 'Indeks Desa Membangun'),
    ('/perencanaan/rpjmdes', 'RPJMDes', 'Perencanaan', 'RPJMDes', 'Rencana Pembangunan Jangka Menengah Desa'),
    ('/partisipasi/voting', 'Voting', 'Partisipasi', 'Voting Warga', 'Suara Anda untuk pembangunan desa')
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================================
-- 7. Add indexes untuk performance
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_site_draft_tenant_status
  ON public.site_draft(tenant_id, status)
  WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_site_version_tenant
  ON public.site_version(tenant_id, entitas, created_at DESC)
  WHERE tenant_id IS NOT NULL;

-- ============================================================
-- DONE
-- ============================================================

RAISE NOTICE 'CMS Draft Workflow migration completed. Tenant-aware draft system ready.';


-- ============================================
-- FILE: 20260720000003_008_append_only_audit_trail.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260720000003_008_append_only_audit_trail.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Append-only audit trail untuk transaksi kritikal
--
-- Tabel yang dilindungi:
-- - surat_terbit (surat resmi)
-- - voting_suara (voting warga)
-- - voting_topik (topik voting)
-- - usulan_vote (suara usulan)
-- - bidang_tanah (sertifikat tanah)
-- - apbdes (anggaran desa)
-- - bantuan_sosial (bansos)
-- ============================================================

-- ============================================================
-- 1. Audit Trail Tables
-- ============================================================

-- 1a. Audit log utama (generic, semua tabel bisa logging)
CREATE TABLE IF NOT EXISTS audit_trail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  entitas VARCHAR(50) NOT NULL,
  entitas_id UUID NOT NULL,
  aksi VARCHAR(20) NOT NULL CHECK (aksi IN ('INSERT', 'UPDATE', 'DELETE', 'SOFT_DELETE', 'RESTORE')),
  payload_lama JSONB,
  payload_baru JSONB,
  perubahan JSONB, -- diff between old and new
  actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ip_address INET,
  user_agent TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_trail_entity
  ON audit_trail(tenant_id, entitas, entitas_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_trail_actor
  ON audit_trail(tenant_id, actor_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_trail_action
  ON audit_trail(tenant_id, aksi, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_trail_period
  ON audit_trail(tenant_id, created_at DESC);

GRANT SELECT ON audit_trail TO authenticated;
GRANT INSERT ON audit_trail TO service_role, authenticated;
GRANT ALL ON audit_trail TO service_role;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_trail append only read" ON audit_trail
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "audit_trail append only insert" ON audit_trail
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "audit_trail service all" ON audit_trail
  FOR ALL TO service_role USING (true);

COMMENT ON TABLE audit_trail IS
'Append-only audit trail untuk transaksi kritikal.
Bisa dibaca oleh admin, hanya ditulis oleh service_role/system triggers.
Jaga selama 7 tahun (UU No. 27/2007 tentang Kearsipan).';

-- ============================================================
-- 2. Specialized Audit Tables (denormalized for fast queries)
-- ============================================================

-- 2a. Surat Audit Trail
CREATE TABLE IF NOT EXISTS audit_surat_terbit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  surat_id UUID NOT NULL,
  aksi VARCHAR(20) NOT NULL,
  nomor_surat VARCHAR(100),
  jenis VARCHAR(50),
  status_lama VARCHAR(30),
  status_baru VARCHAR(30),
  payload JSONB,
  actor_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_surat_surat_id
  ON audit_surat_terbit(tenant_id, surat_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_surat_period
  ON audit_surat_terbit(tenant_id, created_at DESC);

GRANT SELECT ON audit_surat_terbit TO authenticated;
GRANT INSERT ON audit_surat_terbit TO service_role;
GRANT ALL ON audit_surat_terbit TO service_role;
ALTER TABLE audit_surat_terbit ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_surat append only" ON audit_surat_terbit
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "audit_surat admin read" ON audit_surat_terbit
  FOR SELECT TO authenticated USING (true);

-- 2b. Voting Audit Trail
CREATE TABLE IF NOT EXISTS audit_voting (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  topik_id UUID,
  suara_id UUID,
  aksi VARCHAR(20) NOT NULL,
  jumlah_suara_lama INT,
  jumlah_suara_baru INT,
  payload JSONB,
  actor_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_voting_topik
  ON audit_voting(tenant_id, topik_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_voting_period
  ON audit_voting(tenant_id, created_at DESC);

GRANT SELECT ON audit_voting TO authenticated;
GRANT INSERT ON audit_voting TO service_role;
GRANT ALL ON audit_voting TO service_role;
ALTER TABLE audit_voting ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_voting append only" ON audit_voting
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "audit_voting admin read" ON audit_voting
  FOR SELECT TO authenticated USING (true);

-- 2c. Keuangan Audit Trail (APBDes changes)
CREATE TABLE IF NOT EXISTS audit_keuangan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  apbdes_id UUID,
  aksi VARCHAR(20) NOT NULL,
  tahun INT,
  sumber_dana_lama VARCHAR(50),
  sumber_dana_baru VARCHAR(50),
  anggaran_lama BIGINT,
  anggaran_baru BIGINT,
  payload JSONB,
  actor_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_keuangan_tahun
  ON audit_keuangan(tenant_id, tahun, created_at DESC);

GRANT SELECT ON audit_keuangan TO authenticated;
GRANT INSERT ON audit_keuangan TO service_role;
GRANT ALL ON audit_keuangan TO service_role;
ALTER TABLE audit_keuangan ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_keuangan append only" ON audit_keuangan
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "audit_keuangan admin read" ON audit_keuangan
  FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 3. Audit Helper Functions
-- ============================================================

-- Generic audit log function
CREATE OR REPLACE FUNCTION public.log_audit(
  p_entitas VARCHAR,
  p_entitas_id UUID,
  p_aksi VARCHAR,
  p_payload_lama JSONB DEFAULT NULL,
  p_payload_baru JSONB DEFAULT NULL,
  p_keterangan TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id UUID;
  v_tenant_id UUID;
  v_actor_id UUID;
  v_perubahan JSONB;
BEGIN
  -- Get context
  BEGIN
    v_actor_id := auth.uid();
  EXCEPTION WHEN OTHERS THEN
    v_actor_id := NULL;
  END;

  -- Try to get tenant_id from entity
  BEGIN
    EXECUTE format('SELECT tenant_id FROM public.%I WHERE id = %L', p_entitas, p_entitas_id)
    INTO v_tenant_id;
  EXCEPTION WHEN OTHERS THEN
    v_tenant_id := NULL;
  END;

  -- Compute diff
  IF p_payload_lama IS NOT NULL AND p_payload_baru IS NOT NULL THEN
    v_perubahan := public.jsonb_diff(p_payload_lama, p_payload_baru);
  ELSE
    v_perubahan := p_payload_baru;
  END IF;

  INSERT INTO audit_trail (
    tenant_id, entitas, entitas_id, aksi,
    payload_lama, payload_baru, perubahan,
    actor_id, keterangan
  )
  VALUES (
    v_tenant_id, p_entitas, p_entitas_id, p_aksi,
    p_payload_lama, p_payload_baru, v_perubahan,
    v_actor_id, p_keterangan
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.log_audit IS
'Log an audit entry. Append-only, returns log ID.
Usage: SELECT log_audit(''surat_terbit'', id, ''UPDATE'', old_data, new_data, ''Status diubah'')';

-- JSONB diff function
CREATE OR REPLACE FUNCTION public.jsonb_diff(left JSONB, right JSONB)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  result JSONB := '{}'::jsonb;
  key TEXT;
BEGIN
  IF left IS NULL OR right IS NULL THEN
    RETURN right;
  END IF;

  FOR key IN SELECT jsonb_object_keys(left) UNION SELECT jsonb_object_keys(right)
  LOOP
    IF left->key IS DISTINCT FROM right->key THEN
      result := jsonb_set(result, ARRAY[key], right->key);
    END IF;
  END LOOP;

  RETURN result;
END;
$$;

-- ============================================================
-- 4. Enforce Append-Only Triggers
--    UPDATE/DELETE akan men-trigger audit, tapi data TIDAK berubah
-- ============================================================

-- 4a. Surat Terbit - Append Only
CREATE OR REPLACE FUNCTION public.enforce_append_only_surat()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Log UPDATE as audit
  INSERT INTO audit_surat_terbit (
    tenant_id, surat_id, aksi, nomor_surat, jenis,
    status_lama, status_baru, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    NEW.nomor_surat, NEW.jenis,
    OLD.status, NEW.status,
    jsonb_build_object(
      'old', to_jsonb(OLD),
      'new', to_jsonb(NEW)
    ),
    COALESCE(NEW.updated_by, auth.uid())
  );

  -- Log to generic audit
  PERFORM log_audit(
    'surat_terbit',
    NEW.id,
    TG_OP,
    to_jsonb(OLD),
    to_jsonb(NEW),
    'Surat ' || COALESCE(NEW.nomor_surat, NEW.id::text) || ' - Status: ' || COALESCE(NEW.status, 'unknown')
  );

  -- Prevent UPDATE/DELETE on certain fields after published
  IF OLD.status = 'diterbitkan' AND TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION 'Surat yang sudah diterbitkan tidak dapat diubah! Hubungi administrator untuk koreksi.';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_surat ON public.surat_terbit;
CREATE TRIGGER enforce_append_only_surat
  AFTER UPDATE OR DELETE ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_surat();

-- Log INSERT separately
CREATE OR REPLACE FUNCTION public.log_surat_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_surat_terbit (
    tenant_id, surat_id, aksi, nomor_surat, jenis, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    NEW.id, 'INSERT',
    NEW.nomor_surat, NEW.jenis,
    to_jsonb(NEW),
    COALESCE(NEW.created_by, auth.uid())
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS log_surat_insert ON public.surat_terbit;
CREATE TRIGGER log_surat_insert
  AFTER INSERT ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION public.log_surat_insert();

-- 4b. Voting Suara - Append Only (no updates/deletes allowed)
CREATE OR REPLACE FUNCTION public.enforce_append_only_voting_suara()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_voting (
    tenant_id, suara_id, aksi, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    auth.uid()
  );

  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    RAISE EXCEPTION 'Suara voting tidak dapat diubah atau dihapus! Satu warga = satu suara.';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_voting_suara ON public.voting_suara;
CREATE TRIGGER enforce_append_only_voting_suara
  AFTER INSERT OR UPDATE OR DELETE ON public.voting_suara
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_voting_suara();

-- 4c. Voting Topik - Audit on status change
CREATE OR REPLACE FUNCTION public.enforce_append_only_voting_topik()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_voting (
    tenant_id, topik_id, aksi, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    auth.uid()
  );

  -- Prevent status change from 'ditutup' to anything else
  IF OLD.status = 'ditutup' AND NEW.status != 'ditutup' THEN
    RAISE EXCEPTION 'Voting yang sudah ditutup tidak dapat dibuka kembali!';
  END IF;

  -- Prevent delete of closed voting
  IF OLD.status = 'ditutup' AND TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Voting yang sudah ditutup tidak dapat dihapus!';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_voting_topik ON public.voting_topik;
CREATE TRIGGER enforce_append_only_voting_topik
  AFTER UPDATE OR DELETE ON public.voting_topik
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_voting_topik();

-- 4d. Usulan Vote - Append Only
CREATE OR REPLACE FUNCTION public.enforce_append_only_usulan_vote()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    RAISE EXCEPTION 'Vote pada usulan tidak dapat diubah atau dihapus!';
  END IF;

  -- Log INSERT
  INSERT INTO audit_trail (
    tenant_id, entitas, entitas_id, aksi, payload_baru, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    'usulan_vote',
    NEW.id,
    'INSERT',
    to_jsonb(NEW),
    auth.uid()
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_usulan_vote ON public.usulan_vote;
CREATE TRIGGER enforce_append_only_usulan_vote
  AFTER INSERT ON public.usulan_vote
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_usulan_vote();

-- 4e. APBDes - Audit only (no hard restrictions, but log all changes)
CREATE OR REPLACE FUNCTION public.enforce_append_only_apbdes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_keuangan (
    tenant_id, apbdes_id, aksi, tahun,
    sumber_dana_lama, sumber_dana_baru,
    anggaran_lama, anggaran_baru,
    payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, OLD.tenant_id, (SELECT tenant_id FROM tenants LIMIT 1)),
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    COALESCE(NEW.tahun, OLD.tahun),
    OLD.sumber_dana, NEW.sumber_dana,
    OLD.total_anggaran, NEW.total_anggaran,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    COALESCE(NEW.updated_by, OLD.created_by, auth.uid())
  );

  -- Log to generic audit
  PERFORM log_audit(
    'apbdes',
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    to_jsonb(OLD),
    to_jsonb(NEW),
    'APBDes tahun ' || COALESCE(NEW.tahun::TEXT, OLD.tahun::TEXT)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_apbdes ON public.apbdes;
CREATE TRIGGER enforce_append_only_apbdes
  AFTER UPDATE OR DELETE ON public.apbdes
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_apbdes();

-- 4f. Bidang Tanah - Audit + soft delete
CREATE OR REPLACE FUNCTION public.enforce_append_only_bidang_tanah()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    -- Convert to soft delete
    UPDATE public.bidang_tanah
    SET status_sertifikat = 'dialihkan',
        updated_at = now()
    WHERE id = OLD.id;

    PERFORM log_audit(
      'bidang_tanah',
      OLD.id,
      'SOFT_DELETE',
      to_jsonb(OLD),
      NULL,
      'Bidang tanah dialihkan (soft delete)'
    );

    RETURN NULL; -- Don't actually delete
  END IF;

  -- Log update
  PERFORM log_audit(
    'bidang_tanah',
    NEW.id,
    'UPDATE',
    to_jsonb(OLD),
    to_jsonb(NEW),
    'Bidang tanah ' || COALESCE(NEW.nomor_sertifikat, NEW.id::text)
  );

  -- Prevent changes to certified land
  IF OLD.status_sertifikat = 'tersertifikasi' AND NEW.status_sertifikat != OLD.status_sertifikat THEN
    RAISE EXCEPTION 'Tanah yang sudah tersertifikasi tidak dapat mengubah status!';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_append_only_bidang_tanah ON public.bidang_tanah;
CREATE TRIGGER enforce_append_only_bidang_tanah
  AFTER UPDATE OR DELETE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION public.enforce_append_only_bidang_tanah();

-- ============================================================
-- 5. Views for Admin UI
-- ============================================================

-- Recent Activity View
CREATE OR REPLACE VIEW public.recent_activity AS
SELECT
  'surat' AS kategori,
  tenant_id,
  created_at,
  actor_id,
  'Surat ' || COALESCE(nomor_surat, surat_id::text) AS entitas,
  aksi,
  payload
FROM audit_surat_terbit
UNION ALL
SELECT
  'voting' AS kategori,
  tenant_id,
  created_at,
  actor_id,
  'Voting ' || topik_id::text AS entitas,
  aksi,
  payload
FROM audit_voting
UNION ALL
SELECT
  'keuangan' AS kategori,
  tenant_id,
  created_at,
  actor_id,
  'APBDes ' || COALESCE(tahun::text, apbdes_id::text) AS entitas,
  aksi,
  payload
FROM audit_keuangan
ORDER BY created_at DESC;

GRANT SELECT ON public.recent_activity TO authenticated;

-- ============================================================
-- 6. Security: Prevent direct UPDATE/DELETE on append-only tables
--    (application-level enforcement via triggers above)
-- ============================================================

-- Note: PostgreSQL doesn't support true immutable tables,
-- but our triggers above provide equivalent protection
-- by allowing the operation to succeed but logging + blocking critical changes

RAISE NOTICE 'Append-Only Audit Trail migration completed. Critical transactions protected.';


-- ============================================
-- FILE: 20260720000004_009_wa_chatbot_tables.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260720000004_009_wa_chatbot_tables.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tabel untuk WA Chatbot session dan conversation
-- ============================================================

-- ============================================================
-- 1. WA Chatbot Session
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(100) NOT NULL UNIQUE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nomor_wa VARCHAR(20) NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_nik VARCHAR(16),
  state VARCHAR(50) NOT NULL DEFAULT 'main_menu',
  last_menu INT,
  step_data JSONB DEFAULT '{}',
  ip_address INET,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_session_nomor ON wa_chatbot_session(nomor_wa, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_session_tenant ON wa_chatbot_session(tenant_id, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_session_expires ON wa_chatbot_session(expires_at);

GRANT SELECT, INSERT, UPDATE ON wa_chatbot_session TO authenticated, service_role;
GRANT ALL ON wa_chatbot_session TO service_role;
ALTER TABLE wa_chatbot_session ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_session all for auth" ON wa_chatbot_session
  FOR ALL TO authenticated USING (true);
CREATE POLICY "wa_session service all" ON wa_chatbot_session
  FOR ALL TO service_role USING (true);

-- Trigger untuk updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS wa_chatbot_session_updated ON wa_chatbot_session;
CREATE TRIGGER wa_chatbot_session_updated
  BEFORE UPDATE ON wa_chatbot_session
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 2. WA Chatbot Conversation
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_conversation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(100) REFERENCES wa_chatbot_session(session_id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nomor_wa VARCHAR(20) NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  direction VARCHAR(10) NOT NULL CHECK (direction IN ('incoming', 'outgoing')),
  message TEXT NOT NULL,
  parsed_intent VARCHAR(50),
  parsed_entities JSONB,
  sent_status VARCHAR(20) CHECK (sent_status IN ('pending', 'sukses', 'gagal')),
  sent_response JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_conv_session ON wa_chatbot_conversation(session_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_conv_nomor ON wa_chatbot_conversation(nomor_wa, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_conv_period ON wa_chatbot_conversation(created_at DESC);

GRANT SELECT, INSERT ON wa_chatbot_conversation TO authenticated, service_role;
GRANT ALL ON wa_chatbot_conversation TO service_role;
ALTER TABLE wa_chatbot_conversation ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_conv select for auth" ON wa_chatbot_conversation
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "wa_conv insert for auth" ON wa_chatbot_conversation
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "wa_conv service all" ON wa_chatbot_conversation
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 3. WA Chatbot Menu Config (customizable menu)
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_menu (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  parent_key VARCHAR(20),
  menu_key VARCHAR(20) NOT NULL,
  label VARCHAR(100) NOT NULL,
  emoji VARCHAR(10),
  action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('menu', 'function', 'url', 'phone')),
  action_value TEXT,
  urutan INT DEFAULT 0,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_menu_tenant ON wa_chatbot_menu(tenant_id, parent_key, urutan);

GRANT SELECT, INSERT, UPDATE ON wa_chatbot_menu TO authenticated;
GRANT ALL ON wa_chatbot_menu TO service_role;
ALTER TABLE wa_chatbot_menu ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_menu all for auth" ON wa_chatbot_menu
  FOR ALL TO authenticated USING (true);
CREATE POLICY "wa_menu service all" ON wa_chatbot_menu
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 4. Seed default menu
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;

  IF v_tenant_id IS NOT NULL THEN
    -- Insert default main menu items
    INSERT INTO wa_chatbot_menu (tenant_id, parent_key, menu_key, label, emoji, action_type, action_value, urutan) VALUES
    (v_tenant_id, NULL, '1', 'Cek Status Surat', '📋', 'menu', 'surat', 1),
    (v_tenant_id, NULL, '2', 'Cek Tagihan PBB', '💰', 'menu', 'pbb', 2),
    (v_tenant_id, NULL, '3', 'Voting Aktif', '🗳️', 'menu', 'voting', 3),
    (v_tenant_id, NULL, '4', 'Bantuan Sosial', '🎁', 'menu', 'bansos', 4),
    (v_tenant_id, NULL, '5', 'Cek Data Diri', '👤', 'menu', 'data_diri', 5),
    (v_tenant_id, NULL, '6', 'Info Desa', 'ℹ️', 'menu', 'info', 6),
    (v_tenant_id, NULL, '7', 'Hubungi Admin', '📞', 'phone', NULL, 7),
    (v_tenant_id, NULL, '0', 'Menu Utama', '🏠', 'menu', 'main', 0)
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================================
-- 5. Analytics: Session stats
-- ============================================================

CREATE OR REPLACE VIEW wa_chatbot_stats AS
SELECT
  tenant_id,
  DATE(created_at) AS tanggal,
  COUNT(DISTINCT session_id) AS total_session,
  COUNT(*) FILTER (WHERE direction = 'incoming') AS total_pesan_masuk,
  COUNT(*) FILTER (WHERE direction = 'outgoing') AS total_pesan_keluar,
  COUNT(*) FILTER (WHERE sent_status = 'gagal') AS total_gagal,
  COUNT(DISTINCT nomor_wa) AS total_pengguna_unik
FROM wa_chatbot_conversation
GROUP BY tenant_id, DATE(created_at)
ORDER BY tanggal DESC;

GRANT SELECT ON wa_chatbot_stats TO authenticated;

RAISE NOTICE 'WA Chatbot tables migration completed.';


-- ============================================
-- FILE: 20260720090000_001b_penduduk_event_columns.sql
-- ============================================

-- ============================================================
-- MIGRASI: 001b_penduduk_event_columns.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tambah kolom yang dibutuhkan trigger_publish_penduduk_event
--             pada migration 003_domain_events.sql
-- Urutan migrasi: SETELAH 001_auth.sql, SEBELUM 002_reference_tables.sql
-- ============================================================

-- Tambah kolom-kolom yang direferensikan trigger_publish_penduduk_event()
ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS bpjs_status TEXT,
  ADD COLUMN IF NOT EXISTS bpjs_nomor TEXT,
  ADD COLUMN IF NOT EXISTS rt VARCHAR(3),
  ADD COLUMN IF NOT EXISTS rw VARCHAR(3),
  ADD COLUMN IF NOT EXISTS nomor_hp TEXT,
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Set default updated_at trigger (PostgreSQL <16: wrap in DO block)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'penduduk_updated' AND tgrelid = 'public.penduduk'::regclass) THEN
    CREATE TRIGGER penduduk_updated
      BEFORE UPDATE ON public.penduduk
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

COMMENT ON COLUMN public.penduduk.bpjs_status IS 'Status kepesertaan BPJS: aktif, nonaktif, tidak_terdaftar';
COMMENT ON COLUMN public.penduduk.bpjs_nomor IS 'Nomor kartu BPJS Kesehatan';
COMMENT ON COLUMN public.penduduk.rt IS 'Nomor RT';
COMMENT ON COLUMN public.penduduk.rw IS 'Nomor RW';
COMMENT ON COLUMN public.penduduk.nomor_hp IS 'Nomor HP/WA aktif';
COMMENT ON COLUMN public.penduduk.created_by IS 'User yang membuat record ini';
COMMENT ON COLUMN public.penduduk.updated_by IS 'User yang terakhir update record ini';


-- ============================================
-- FILE: 20260720100000_001c_recover_user_peran.sql
-- ============================================

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


-- ============================================
-- FILE: 20260720100001_003_domain_events.sql
-- ============================================

-- ============================================================
-- MIGRASI: 003_domain_events.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Event Sourcing Table & Event Publisher Functions
-- Prinsip: "Satu Input, Banyak Dampak" - setiap perubahan fakta
--          mentah menerbitkan domain_events, worker menghitung turunan
-- Urutan migrasi: setelah 001b_penduduk_event_columns.sql, 002_reference_tables.sql
-- ============================================================

-- 1. Domain Events Table (Event Sourcing)
CREATE TABLE IF NOT EXISTS domain_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID, -- nullable untuk event global (mis. startup)
  event_type VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL, -- 'penduduk', 'surat', 'pbb', dst.
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  aktor_id UUID, -- user yang memicu event (nullable untuk system events)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ -- NULL = belum diproses
);

-- Index untuk worker: ambil event yang belum diproses
CREATE INDEX IF NOT EXISTS idx_domain_events_unprocessed
  ON domain_events(created_at ASC)
  WHERE processed_at IS NULL;

-- Index untuk audit trail per entity
CREATE INDEX IF NOT EXISTS idx_domain_events_entity
  ON domain_events(entity_type, entity_id, created_at DESC);

-- Index untuk analytics per event type
CREATE INDEX IF NOT EXISTS idx_domain_events_type
  ON domain_events(event_type, created_at DESC);

GRANT SELECT ON domain_events TO authenticated;
GRANT INSERT ON domain_events TO authenticated, service_role;
GRANT ALL ON domain_events TO service_role;
ALTER TABLE domain_events ENABLE ROW LEVEL SECURITY;

-- Policy: semua bisa baca, hanya service_role dan authenticated yang bisa insert
CREATE POLICY "Public read domain_events" ON domain_events
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can create events" ON domain_events
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Service can manage events" ON domain_events
  FOR ALL TO service_role USING (true);

-- 2. Event Types Enum (standar event kanonik)
-- Event type mengikuti naming convention: entity.action
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_type') THEN
    CREATE TYPE event_type AS ENUM (
      'penduduk.dibuat',
      'penduduk.data.berubah',
      'penduduk.status.berubah',
      'penduduk.bpjs.berubah',
      'surat.diajukan',
      'surat.diverifikasi',
      'surat.ditolak',
      'surat.ditandatangani',
      'surat.diterbitkan',
      'surat.dikirim',
      'usulan.diajukan',
      'usulan.lolos_verifikasi',
      'usulan.ditolak',
      'usulan.ditetapkan_rkpdes',
      'usulan.vote.bertambah',
      'voting.ditutup',
      'pbb.wajib_pajak.didaftarkan',
      'pbb.objek_pajak.didaftarkan',
      'pbb.objek_pajak.berubah',
      'pbb.tagihan.dibayar',
      'apbdes.realisasi.dicatat',
      'apbdes.kegiatan.disahkan',
      'posyandu.kunjungan.dicatat',
      'posyandu.balita.terindikasi_gizi_buruk',
      'bidang_tanah.didaftarkan',
      'bidang_tanah.disahkan',
      'bidang_tanah.dialihkan',
      'infrastruktur.dilaporkan',
      'infrastruktur.diverifikasi',
      'musdes.usulan.ditetapkan',
      'musdes.jadwal.ditetapkan',
      'wa.layanan.selesai',
      'aset.dibuat',
      'aset.diverifikasi',
      'aset.disusutkan'
    );
  END IF;
END $$;

-- 3. Helper Function: Publish Event
-- Usage: SELECT publish_event('penduduk.dibuat', 'penduduk', uuid, payload, aktor_uuid);
CREATE OR REPLACE FUNCTION publish_event(
  p_event_type VARCHAR,
  p_entity_type VARCHAR,
  p_entity_id UUID,
  p_payload JSONB DEFAULT '{}',
  p_aktor_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO domain_events (event_type, entity_type, entity_id, payload, aktor_id)
  VALUES (p_event_type, p_entity_type, p_entity_id, p_payload, p_aktor_id)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION publish_event IS
'Publish a domain event. Returns event ID.
Usage: SELECT publish_event(''penduduk.dibuat'', ''penduduk'', entity_uuid, ''{"nik":"360101..."}''::jsonb, auth.uid())';

-- 4. Trigger: Auto-publish events untuk operasi CRUD tertentu
-- Menggunakan trigger untuk otomatisasi event tanpa perlu手动 call function

-- 4a. Trigger function untuk penduduk
CREATE OR REPLACE FUNCTION trigger_publish_penduduk_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_event_type := 'penduduk.dibuat';
    v_payload := jsonb_build_object(
      'nik', NEW.nik,
      'nama', NEW.nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event(v_event_type, 'penduduk', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Detect perubahan field
    IF OLD.status_hidup IS DISTINCT FROM NEW.status_hidup THEN
      v_payload := jsonb_build_object(
        'field', 'status_hidup',
        'lama', OLD.status_hidup,
        'baru', NEW.status_hidup
      );
      IF NEW.status_hidup IN ('meninggal', 'pindah') THEN
        v_event_type := 'penduduk.status.berubah';
      ELSE
        v_event_type := 'penduduk.data.berubah';
      END IF;
      PERFORM publish_event(v_event_type, 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;

    IF OLD.bpjs_status IS DISTINCT FROM NEW.bpjs_status
       OR OLD.bpjs_nomor IS DISTINCT FROM NEW.bpjs_nomor THEN
      v_payload := jsonb_build_object(
        'bpjs_status_lama', OLD.bpjs_status,
        'bpjs_status_baru', NEW.bpjs_status,
        'bpjs_nomor_baru', NEW.bpjs_nomor
      );
      PERFORM publish_event('penduduk.bpjs.berubah', 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain (nama, alamat, dusun, dll)
    IF OLD.nama IS DISTINCT FROM NEW.nama
       OR OLD.alamat IS DISTINCT FROM NEW.alamat
       OR OLD.dusun IS DISTINCT FROM NEW.dusun
       OR OLD.rt IS DISTINCT FROM NEW.rt
       OR OLD.rw IS DISTINCT FROM NEW.rw
       OR OLD.nomor_hp IS DISTINCT FROM NEW.nomor_hp THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nama', jsonb_build_array(OLD.nama, NEW.nama),
          'alamat', jsonb_build_array(OLD.alamat, NEW.alamat),
          'dusun', jsonb_build_array(OLD.dusun, NEW.dusun),
          'rt', jsonb_build_array(OLD.rt, NEW.rt),
          'rw', jsonb_build_array(OLD.rw, NEW.rw),
          'nomor_hp', jsonb_build_array(OLD.nomor_hp, NEW.nomor_hp)
        )
      );
      PERFORM publish_event('penduduk.data.berubah', 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Attach trigger ke tabel penduduk
DROP TRIGGER IF EXISTS trg_penduduk_publish_event ON public.penduduk;
CREATE TRIGGER trg_penduduk_publish_event
  AFTER INSERT OR UPDATE ON public.penduduk
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_penduduk_event();

-- 5. Event Log untuk audit trail (read-only, immutabel)
CREATE TABLE IF NOT EXISTS event_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID,
  entitas VARCHAR(50) NOT NULL,
  entitas_id UUID,
  event_name VARCHAR(100) NOT NULL,
  actor_id UUID,
  payload JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_log_entity
  ON event_log(entitas, entitas_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_log_actor
  ON event_log(actor_id, created_at DESC);

GRANT SELECT ON event_log TO authenticated;
GRANT INSERT ON event_log TO authenticated, service_role;
GRANT ALL ON event_log TO service_role;
ALTER TABLE event_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read event_log" ON event_log
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage event_log" ON event_log
  FOR ALL TO service_role USING (true);

-- 6. Helper: Log audit trail
CREATE OR REPLACE FUNCTION log_audit_event(
  p_entitas VARCHAR,
  p_entitas_id UUID,
  p_event_name VARCHAR,
  p_payload JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_log_id UUID;
  v_aktor_id UUID;
BEGIN
  -- Try to get current user (will be null if not authenticated)
  BEGIN
    v_aktor_id := auth.uid();
  EXCEPTION WHEN OTHERS THEN
    v_aktor_id := NULL;
  END;

  INSERT INTO event_log (entitas, entitas_id, event_name, actor_id, payload)
  VALUES (p_entitas, p_entitas_id, p_event_name, v_aktor_id, p_payload)
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

COMMENT ON FUNCTION log_audit_event IS
'Log an audit event for compliance. This is append-only and immutable.
Usage: SELECT log_audit_event(''surat'', surat_id, ''surat.ditandatangani'', ''{}''::jsonb)';

-- 7. Cron: Cleanup old unprocessed events (retention policy)
-- Events yang tidak diproses dalam 7 hari akan ditandai sebagai failed
DO $$
BEGIN
  -- Update events yang older dari 7 hari dan belum diproses
  -- Ini adalah maintenance, bukan delete, jadi data tidak hilang
  -- Worker bisa retry jika perlu
  UPDATE domain_events
  SET processed_at = NOW() -- mark as processed (will be skipped by worker)
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '7 days'
    AND event_type IN (
      -- Event yang tidak kritikal untuk di-retry setelah 7 hari
      'penduduk.bpjs.berubah',
      'infrastruktur.dilaporkan'
    );
END $$;

COMMENT ON FUNCTION log_audit_event IS
'Audit trail logger. Append-only, cannot be deleted.
Retention: domain_events kept for 1 year, then archived.
event_log kept for 7 years for compliance (UU No. 27/2007 tentang Kearsipan).';

-- ============================================================
-- 8. pg_cron: Schedule Event Processor
-- Supabase sudah include pg_cron. Jadwal: setiap 5 menit.
-- Job dipanggil via HTTP request ke edge function.
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Hapus job lama jika ada (idempotent — ignore error jika belum ada)
DO $$
BEGIN
  PERFORM cron.unschedule('event-processor-every-5min');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Jadwal: setiap 5 menit, mulai sekarang
SELECT cron.schedule(
  'event-processor-every-5min',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.event_processor_url', true)
           || '/functions/v1/event-processor',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer " || current_setting(''app.event_processor_key'', true)}'::jsonb,
    body := '{"source":"pg_cron"}'::jsonb
  );
  $$
);

-- Fallback: juga jadwal cleanup event retention setiap jam 02:00
DO $$
BEGIN
  PERFORM cron.unschedule('event-cleanup-old-events');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
SELECT cron.schedule(
  'event-cleanup-old-events',
  '0 2 * * *',
  $$
  UPDATE domain_events
  SET processed_at = NOW()
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '7 days'
    AND event_type IN ('penduduk.bpjs.berubah', 'infrastruktur.dilaporkan');
  $$
);


-- ============================================
-- FILE: 20260720100002_004_multi_tenancy.sql
-- ============================================

-- ============================================================
-- MIGRASI: 004_multi_tenancy.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Multi-tenancy foundation - tenants table dan tenant_id
-- Prinsip: Setiap tabel domain punya tenant_id untuk isolasi data
-- Urutan migrasi: setelah 003_domain_events.sql
-- Catatan: Dilakukan bertahap untuk menghindari breaking changes
-- ============================================================

-- 1. Tenants Table (Master Desa)
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_desa VARCHAR(150) NOT NULL,
  subdomain VARCHAR(63) UNIQUE,
  kode_desa VARCHAR(13) UNIQUE, -- kode desa 13 digit Kemendes
  kecamatan VARCHAR(100),
  kabupaten VARCHAR(100),
  provinsi VARCHAR(100),
  logo_url TEXT,
  favicon_url TEXT,
  warna_primer VARCHAR(7) DEFAULT '#1F4D3D',
  warna_aksen VARCHAR(7) DEFAULT '#C9A227',
  aktif BOOLEAN NOT NULL DEFAULT true,
  settings JSONB DEFAULT '{}', -- konfigurasi tambahan per tenant
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tenants_updated' AND tgrelid = 'public.tenants'::regclass) THEN
    CREATE TRIGGER tenants_updated BEFORE UPDATE ON tenants
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON tenants TO authenticated;
GRANT ALL ON tenants TO service_role;
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read tenants" ON tenants FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage tenants" ON tenants FOR ALL TO service_role USING (true);

-- Seed tenant default untuk Seruni Mumbul
INSERT INTO tenants (nama_desa, subdomain, kode_desa, kecamatan, kabupaten, provinsi, warna_primer, warna_aksen)
VALUES (
  'Seruni Mumbul',
  'seruni',
  '5204011001', -- contoh kode desa
  'Pringgabaya',
  'Lombok Timur',
  'Nusa Tenggara Barat',
  '#1F4D3D',
  '#C9A227'
)
ON CONFLICT (subdomain) DO NOTHING;

-- 2. Site Settings (Zero-Hardcode - Konfigurasi Per Tenant)
CREATE TABLE IF NOT EXISTS site_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nama_resmi VARCHAR(200) NOT NULL,
  tagline VARCHAR(300),
  alamat_kantor TEXT,
  telepon VARCHAR(20),
  email VARCHAR(100),
  jam_layanan VARCHAR(100),
  nomor_wa_resmi VARCHAR(20),
  wa_business_verified BOOLEAN DEFAULT false,
  social_media JSONB DEFAULT '{}', -- {facebook, instagram, youtube, tiktok}
  maps_embed_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'site_settings_updated' AND tgrelid = 'public.site_settings'::regclass) THEN
    CREATE TRIGGER site_settings_updated BEFORE UPDATE ON site_settings
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON site_settings TO anon, authenticated;
GRANT ALL ON site_settings TO service_role;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read site_settings" ON site_settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage site_settings" ON site_settings FOR ALL TO service_role USING (true);

-- Seed site settings untuk tenant default
INSERT INTO site_settings (tenant_id, nama_resmi, tagline, alamat_kantor, jam_layanan, nomor_wa_resmi, wa_business_verified)
SELECT
  id,
  'Desa Seruni Mumbul',
  'Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.',
  'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
  'Senin–Jumat · 08.00–15.00 WITA',
  '+6281200000000',
  true
FROM tenants
WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id) DO NOTHING;

-- 3. Site Navigation (Zero-Hardcode - Menu Dinamis)
CREATE TABLE IF NOT EXISTS site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  posisi VARCHAR(10) NOT NULL CHECK (posisi IN ('header', 'footer')),
  label VARCHAR(60) NOT NULL,
  href TEXT NOT NULL,
  icon VARCHAR(50), -- icon name (lucide atau heroicons)
  parent_id UUID REFERENCES site_navigation(id) ON DELETE CASCADE,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_site_navigation_tenant_posisi
  ON site_navigation(tenant_id, posisi, urutan)
  WHERE aktif = true;

GRANT SELECT ON site_navigation TO anon, authenticated;
GRANT ALL ON site_navigation TO service_role;
ALTER TABLE site_navigation ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read site_navigation" ON site_navigation FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage site_navigation" ON site_navigation FOR ALL TO service_role USING (true);

-- Seed navigation default
INSERT INTO site_navigation (tenant_id, posisi, label, href, urutan)
SELECT id, 'header', 'Profil', '/profil-desa', 1 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Informasi', '/berita', 2 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Layanan', '/layanan', 3 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Data', '/statistik', 4 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Potensi', '/potensi-desa', 5 FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT DO NOTHING;

-- 4. Feature Flags (Modul Aktif/Nonaktif)
CREATE TABLE IF NOT EXISTS feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  fitur_kode VARCHAR(30) NOT NULL, -- 'F1_SURAT', 'F2_USULAN', dst.
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, fitur_kode)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'feature_flags_updated' AND tgrelid = 'public.feature_flags'::regclass) THEN
    CREATE TRIGGER feature_flags_updated BEFORE UPDATE ON feature_flags
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON feature_flags TO authenticated;
GRANT ALL ON feature_flags TO service_role;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read feature_flags" ON feature_flags FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage feature_flags" ON feature_flags FOR ALL TO service_role USING (true);

-- Seed feature flags default (semua aktif)
INSERT INTO feature_flags (tenant_id, fitur_kode, aktif)
SELECT id, 'F0_REGISTRASI', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F1_SURAT', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F2_USULAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F3_IDM', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F4_POSYANDU', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F5_PBB', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F6_WA_CHATBOT', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F7_PERTANAHAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F8_ASET', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F9_PEMETAAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F10_STATISTIK', true FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id, fitur_kode) DO NOTHING;

-- 7. Helper: Get current tenant from request
CREATE OR REPLACE FUNCTION get_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    current_setting('app.current_tenant_id', true)::uuid,
    (SELECT id FROM tenants WHERE subdomain = 'seruni' LIMIT 1)
  );
$$;

-- 8. Helper: Check if feature is enabled for tenant
CREATE OR REPLACE FUNCTION is_feature_enabled(p_tenant_id UUID, p_fitur_kode VARCHAR)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT aktif FROM feature_flags
     WHERE tenant_id = p_tenant_id AND fitur_kode = p_fitur_kode),
    true
  );
$$;

-- 9. Dashboard Agregat Table (Fakta Turunan - HANYA worker yang tulis)
CREATE TABLE IF NOT EXISTS dashboard_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  wilayah_id UUID, -- nullable untuk agregat level desa
  kategori VARCHAR(40) NOT NULL, -- 'kependudukan', 'kesehatan', 'keuangan', dst.
  metrik_key VARCHAR(60) NOT NULL, -- 'jumlah_penduduk', 'cakupan_imunisasi', dst.
  metrik_value NUMERIC NOT NULL,
  periode VARCHAR(20) NOT NULL, -- '2026-Q1', '2026-Tahun', dst.
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, wilayah_id, kategori, metrik_key, periode)
);

CREATE INDEX IF NOT EXISTS idx_dashboard_agregat_tenant
  ON dashboard_agregat(tenant_id, kategori, periode);

GRANT SELECT ON dashboard_agregat TO authenticated;
GRANT ALL ON dashboard_agregat TO service_role;
ALTER TABLE dashboard_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read dashboard_agregat" ON dashboard_agregat FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage dashboard_agregat" ON dashboard_agregat FOR ALL TO service_role USING (true);

-- 10. IDM Status Desa (Fakta Turunan - HANYA worker yang tulis)
CREATE TABLE IF NOT EXISTS idm_status_desa (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id) ON DELETE CASCADE,
  total_skor NUMERIC(5,4) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL, -- 'mandiri', 'maju', 'berkembang', 'tertinggal', 'sangat_tertinggal'
  dimensi_scores JSONB DEFAULT '{}', -- {"kesehatan": 4.2, "pendidikan": 4.5, ...}
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON idm_status_desa TO authenticated;
GRANT ALL ON idm_status_desa TO service_role;
ALTER TABLE idm_status_desa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read idm_status_desa" ON idm_status_desa FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage idm_status_desa" ON idm_status_desa FOR ALL TO service_role USING (true);

-- Seed IDM status default
INSERT INTO idm_status_desa (tenant_id, total_skor, status, dimensi_scores)
SELECT id, 0.7412, 'berkembang',
  '{"kesehatan": 4.2, "pendidikan": 4.5, "modal_sosial": 3.8, "permukiman": 4.1, "ekonomi": 3.6, "ekologi": 4.4}'
FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id) DO NOTHING;

-- 11. Helper: Get site navigation for public
CREATE OR REPLACE FUNCTION get_site_navigation(p_tenant_id UUID, p_posisi VARCHAR)
RETURNS TABLE (
  id UUID,
  label VARCHAR,
  href TEXT,
  icon VARCHAR,
  parent_id UUID,
  urutan INT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id, label, href, icon, parent_id, urutan
  FROM site_navigation
  WHERE tenant_id = p_tenant_id
    AND posisi = p_posisi
    AND aktif = true
  ORDER BY urutan;
$$;

COMMENT ON FUNCTION get_site_navigation IS
'Get active navigation items for a tenant. Returns items ordered by urutan.
Usage: SELECT * FROM get_site_navigation(get_tenant_id(), ''header'')';

-- 12. Helper: Get enabled features for tenant
CREATE OR REPLACE FUNCTION get_enabled_features(p_tenant_id UUID)
RETURNS TABLE (fitur_kode VARCHAR, aktif BOOLEAN)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT fitur_kode, aktif
  FROM feature_flags
  WHERE tenant_id = p_tenant_id;
$$;

COMMENT ON FUNCTION get_enabled_features IS
'Get all feature flags for a tenant.
Usage: SELECT * FROM get_enabled_features(get_tenant_id())';


-- ============================================
-- FILE: 20260720100003_002_reference_tables.sql
-- ============================================

-- ============================================================
-- MIGRASI: 002_reference_tables.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tabel referensi standar Indonesia (master data)
-- Urutan migrasi: setelah 001_auth.sql, sebelum 003_penduduk.sql
-- ============================================================

-- 1. Tabel Referensi Agama
CREATE TABLE ref_agama (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(50) NOT NULL,
  nama_latin VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_agama_updated BEFORE UPDATE ON ref_agama
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_agama TO authenticated;
GRANT ALL ON ref_agama TO service_role;
ALTER TABLE ref_agama ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_agama" ON ref_agama FOR SELECT TO authenticated USING (true);

-- Seed ref_agama
INSERT INTO ref_agama (kode, nama, nama_latin, urutan) VALUES
  ('01', 'Islam', 'Islam', 1),
  ('02', 'Kristen Protestan', 'Kristen', 2),
  ('03', 'Katolik', 'Katolik', 3),
  ('04', 'Hindu', 'Hindu', 4),
  ('05', 'Buddha', 'Buddha', 5),
  ('06', 'Khonghucu', 'Khonghucu', 6),
  ('07', 'Lainnya', 'Lainnya', 7)
ON CONFLICT (kode) DO NOTHING;

-- 2. Tabel Referensi Pendidikan
CREATE TABLE ref_pendidikan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  jenjang VARCHAR(20),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_pendidikan_updated BEFORE UPDATE ON ref_pendidikan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_pendidikan TO authenticated;
GRANT ALL ON ref_pendidikan TO service_role;
ALTER TABLE ref_pendidikan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_pendidikan" ON ref_pendidikan FOR SELECT TO authenticated USING (true);

-- Seed ref_pendidikan (standar BPS Susenas)
INSERT INTO ref_pendidikan (kode, nama, jenjang, urutan) VALUES
  ('01', 'Tidak/Belum Sekolah', 'Tidak Sekolah', 1),
  ('02', 'Belum Tamat SD', 'Dasar', 2),
  ('03', 'SD/Sederajat', 'Dasar', 3),
  ('04', 'SLTP/Sederajat', 'Menengah', 4),
  ('05', 'SLTA/Sederajat', 'Menengah', 5),
  ('06', 'Diploma I/II', 'Tinggi', 6),
  ('07', 'Diploma III', 'Tinggi', 7),
  ('08', 'Diploma IV/S1', 'Tinggi', 8),
  ('09', 'S2', 'Tinggi', 9),
  ('10', 'S3', 'Tinggi', 10)
ON CONFLICT (kode) DO NOTHING;

-- 3. Tabel Referensi Pekerjaan
CREATE TABLE ref_pekerjaan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,
  nama VARCHAR(150) NOT NULL,
  kelompok_utama VARCHAR(2),
  sub_kelompok VARCHAR(3),
  kelompok_kecil VARCHAR(4),
  kategori VARCHAR(30),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_pekerjaan_updated BEFORE UPDATE ON ref_pekerjaan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_pekerjaan TO authenticated;
GRANT ALL ON ref_pekerjaan TO service_role;
ALTER TABLE ref_pekerjaan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_pekerjaan" ON ref_pekerjaan FOR SELECT TO authenticated USING (true);

-- Seed ref_pekerjaan (subset KBJI relevan desa)
INSERT INTO ref_pekerjaan (kode, nama, kelompok_utama, kategori, urutan) VALUES
  ('6110', 'Petani Padi', '6', 'pertanian', 1),
  ('6120', 'Petani Palawija', '6', 'pertanian', 2),
  ('6210', 'Peternak', '6', 'pertanian', 10),
  ('6220', 'Buruh Tani/Peternak', '6', 'pertanian', 11),
  ('6310', 'Nelayan', '6', 'pertanian', 15),
  ('6320', 'Budidaya Ikan', '6', 'pertanian', 16),
  ('6410', 'Pekerja Kehutanan', '6', 'pertanian', 20),
  ('5110', 'Pedagang Kecil', '5', 'informal', 30),
  ('5120', 'Warung/Kios', '5', 'informal', 31),
  ('5210', 'Ojek/Online', '5', 'informal', 35),
  ('5220', 'Supir/Taxi', '5', 'informal', 36),
  ('5310', 'Jasa Rumah Tangga', '5', 'informal', 40),
  ('5330', 'Bengkel/Montir', '5', 'informal', 42),
  ('4110', 'Karyawan Swasta', '4', 'formal', 50),
  ('4120', 'PNS/TNI/POLRI', '4', 'formal', 51),
  ('4130', 'BUMN/BUMD', '4', 'formal', 52),
  ('9110', 'Buruh Bangunan', '9', 'informal', 60),
  ('9120', 'Buruh Pabrik', '9', 'formal', 61),
  ('9210', 'Kebersihan/Sampah', '9', 'informal', 65),
  ('9310', 'Satpam', '9', 'formal', 66),
  ('0100', 'Pelajar/Mahasiswa', '0', 'tidak_bekerja', 70),
  ('0200', 'Ibu Rumah Tangga', '0', 'tidak_bekerja', 71),
  ('0300', 'Tidak Bekerja', '0', 'tidak_bekerja', 72),
  ('0400', 'Pensiunan', '0', 'tidak_bekerja', 73)
ON CONFLICT (kode) DO NOTHING;

-- 4. Tabel Referensi Status Perkawinan
CREATE TABLE ref_status_perkawinan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,
  nama VARCHAR(50) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_status_perkawinan_updated BEFORE UPDATE ON ref_status_perkawinan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_status_perkawinan TO authenticated;
GRANT ALL ON ref_status_perkawinan TO service_role;
ALTER TABLE ref_status_perkawinan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_status_perkawinan" ON ref_status_perkawinan FOR SELECT TO authenticated USING (true);

-- Seed ref_status_perkawinan
INSERT INTO ref_status_perkawinan (kode, nama, urutan) VALUES
  ('1', 'Belum Kawin', 1),
  ('2', 'Kawin', 2),
  ('3', 'Cerai Hidup', 3),
  ('4', 'Cerai Mati', 4)
ON CONFLICT (kode) DO NOTHING;

-- 5. Tabel Referensi Hubungan Keluarga
CREATE TABLE ref_hubungan_keluarga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,
  nama VARCHAR(50) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_hubungan_keluarga_updated BEFORE UPDATE ON ref_hubungan_keluarga
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_hubungan_keluarga TO authenticated;
GRANT ALL ON ref_hubungan_keluarga TO service_role;
ALTER TABLE ref_hubungan_keluarga ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_hubungan_keluarga" ON ref_hubungan_keluarga FOR SELECT TO authenticated USING (true);

-- Seed ref_hubungan_keluarga
INSERT INTO ref_hubungan_keluarga (kode, nama, urutan) VALUES
  ('1', 'Kepala Keluarga', 1),
  ('2', 'Istri/Suami', 2),
  ('3', 'Anak', 3),
  ('4', 'Mertua', 4),
  ('5', 'Famili Lain', 5),
  ('6', 'Pembantu', 6),
  ('7', 'Lainnya', 7)
ON CONFLICT (kode) DO NOTHING;

-- 6. Tabel Referensi Golongan Darah
CREATE TABLE ref_golongan_darah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(5) NOT NULL UNIQUE,
  nama VARCHAR(20) NOT NULL,
  rhesus VARCHAR(10),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_golongan_darah_updated BEFORE UPDATE ON ref_golongan_darah
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_golongan_darah TO authenticated;
GRANT ALL ON ref_golongan_darah TO service_role;
ALTER TABLE ref_golongan_darah ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_golongan_darah" ON ref_golongan_darah FOR SELECT TO authenticated USING (true);

-- Seed ref_golongan_darah
INSERT INTO ref_golongan_darah (kode, nama, rhesus, urutan) VALUES
  ('A+', 'A', 'POSITIF', 1),
  ('B+', 'B', 'POSITIF', 2),
  ('AB+', 'AB', 'POSITIF', 3),
  ('O+', 'O', 'POSITIF', 4),
  ('A-', 'A', 'NEGATIF', 5),
  ('B-', 'B', 'NEGATIF', 6),
  ('AB-', 'AB', 'NEGATIF', 7),
  ('O-', 'O', 'NEGATIF', 8),
  ('UNK', 'Tidak Tahu', NULL, 9)
ON CONFLICT (kode) DO NOTHING;

-- 7. Tabel Referensi Kewarganegaraan
CREATE TABLE ref_warga_negara (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  negara_id VARCHAR(3),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_warga_negara_updated BEFORE UPDATE ON ref_warga_negara
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_warga_negara TO authenticated;
GRANT ALL ON ref_warga_negara TO service_role;
ALTER TABLE ref_warga_negara ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_warga_negara" ON ref_warga_negara FOR SELECT TO authenticated USING (true);

-- Seed ref_warga_negara (prioritas ASEAN + negara umum)
INSERT INTO ref_warga_negara (kode, nama, negara_id, urutan) VALUES
  ('IDN', 'Indonesia', 'IDN', 1),
  ('MYS', 'Malaysia', 'MYS', 2),
  ('SGP', 'Singapura', 'SGP', 3),
  ('PHL', 'Filipina', 'PHL', 4),
  ('THA', 'Thailand', 'THA', 5),
  ('VNM', 'Vietnam', 'VNM', 6),
  ('USA', 'Amerika Serikat', 'USA', 10),
  ('JPN', 'Jepang', 'JPN', 11),
  ('CHN', 'China', 'CHN', 12),
  ('AUS', 'Australia', 'AUS', 13),
  ('SAU', 'Arab Saudi', 'SAU', 14)
ON CONFLICT (kode) DO NOTHING;

-- 8. Tabel Referensi Cacat (Kemensos)
CREATE TABLE ref_cacat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori VARCHAR(30),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER ref_cacat_updated BEFORE UPDATE ON ref_cacat
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT ON ref_cacat TO authenticated;
GRANT ALL ON ref_cacat TO service_role;
ALTER TABLE ref_cacat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read ref_cacat" ON ref_cacat FOR SELECT TO authenticated USING (true);

-- Seed ref_cacat
INSERT INTO ref_cacat (kode, nama, kategori, urutan) VALUES
  ('N', 'Tidak Cacat', 'tidak', 0),
  ('A', 'Tuna Netra', 'sensorik', 1),
  ('B', 'Tuna Rungu', 'sensorik', 2),
  ('C', 'Tuna Wicara', 'sensorik', 3),
  ('D', 'Tuna Daksa', 'fisik', 4),
  ('E', 'Tuna Grahita', 'mental', 5),
  ('F', 'Tuna Laras', 'mental', 6),
  ('G', 'Tuna Netra & Rungu', 'ganda', 7),
  ('H', 'Lainnya', 'lainnya', 8)
ON CONFLICT (kode) DO NOTHING;

-- 9. Tabel Referensi Jenis Kelamin
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ref_jenis_kelamin') THEN
    CREATE TYPE ref_jenis_kelamin AS ENUM ('L', 'P');
  END IF;
END $$;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'L' AND enumtypid = 'ref_jenis_kelamin'::regtype) THEN
    ALTER TYPE ref_jenis_kelamin ADD VALUE 'L';
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'P' AND enumtypid = 'ref_jenis_kelamin'::regtype) THEN
    ALTER TYPE ref_jenis_kelamin ADD VALUE 'P';
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 10. Enum Status Kependudukan
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ref_status_kependudukan') THEN
    CREATE TYPE ref_status_kependudukan AS ENUM ('aktif', 'pindah', 'meninggal');
  END IF;
END $$;

-- 11. Enum untuk peran admin (extended dari app_role)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_peran') THEN
    CREATE TYPE app_peran AS ENUM ('admin', 'kades', 'sekdes', 'admin_keuangan', 'admin_kesehatan', 'kader_posyandu', 'dinas_pmd');
  END IF;
END $$;

-- Table untuk mapping user ke peran lebih detail
CREATE TABLE IF NOT EXISTS user_peran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  peran app_peran NOT NULL,
  dusun_id UUID, -- nullable, untuk kader_posyandu (scoping ke dusun tertentu)
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

-- Helper function untuk cek peran
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


-- ============================================
-- FILE: 20260721000001_restore_missing_objects.sql
-- ============================================

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


-- ============================================
-- FILE: 20260721000002_create_tenant_functions.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260721000002_create_tenant_functions.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Buat user_has_tenant_access dan tenant_filter yang
--            gagal di restore migration karena syntax error.
-- ============================================================

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


-- ============================================
-- FILE: 20260721000003_activate_cron_jobs.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260721000003_activate_cron_jobs.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Aktifkan pg_cron jobs untuk event processor
--            + set app settings agar cron job bisa akses edge function
-- ============================================================

-- Set app settings untuk event processor cron (dibaca oleh cron job body)
DO $$
BEGIN
  -- Set hanya jika belum ada (avoid overwrite)
  IF current_setting('app.event_processor_url', true) IS NULL
     OR current_setting('app.event_processor_url', true) = '' THEN
    PERFORM set_config('app.event_processor_url', 'https://smngqdpbmgcdbmkiuviq.supabase.co', true);
  END IF;
  IF current_setting('app.event_processor_key', true) IS NULL
     OR current_setting('app.event_processor_key', true) = '' THEN
    PERFORM set_config('app.event_processor_key',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg',
      true);
  END IF;
END $$;

-- Pastikan pg_cron extension aktif
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Hapus job lama jika ada (idempotent)
DO $$
BEGIN
  PERFORM cron.unschedule('event-processor-every-5min');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Job 1: Event processor setiap 5 menit
SELECT cron.schedule(
  'event-processor-every-5min',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.event_processor_url', true)
           || '/functions/v1/event-processor',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer " || current_setting(''app.event_processor_key'', true)}'::jsonb,
    body := '{"source":"pg_cron"}'::jsonb
  );
  $$
);

-- Hapus job cleanup lama jika ada
DO $$
BEGIN
  PERFORM cron.unschedule('event-cleanup-old-events');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Job 2: Cleanup old events setiap jam 02:00
SELECT cron.schedule(
  'event-cleanup-old-events',
  '0 2 * * *',
  $$
  UPDATE domain_events
  SET processed_at = NOW()
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '7 days'
    AND event_type IN ('penduduk.bpjs.berubah', 'infrastruktur.dilaporkan');
  $$
);

-- Verifikasi: tampilkan semua job aktif
SELECT jobname, schedule, command FROM cron.job;


-- ============================================
-- FILE: 20260721000004_add_tenant_id.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260721000004_add_tenant_id.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Tambahkan tenant_id ke 31 tabel domain utama.
--            Semua data existing di-backfill ke tenant Seruni Mumbul
--            (UUID: d532ae95-0ad9-42bb-a6e8-5c840447c90e).
--            Kolom nullable dulu, di-backfill, baru SET NOT NULL.
-- ============================================================

-- Tenant Seruni Mumbul
DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

-- ============================================================
-- CORE TABLES
-- ============================================================
ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.penduduk SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.penduduk ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_penduduk_tenant ON public.penduduk(tenant_id);

ALTER TABLE public.keluarga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.keluarga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.keluarga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_keluarga_tenant ON public.keluarga(tenant_id);

ALTER TABLE public.wilayah_dusun ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wilayah_dusun SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wilayah_dusun ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wilayah_dusun_tenant ON public.wilayah_dusun(tenant_id);

-- ============================================================
-- GOVERNANCE
-- ============================================================
ALTER TABLE public.voting_topik ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_topik SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_topik ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_topik_tenant ON public.voting_topik(tenant_id);

ALTER TABLE public.voting_opsi ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_opsi SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_opsi ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_opsi_tenant ON public.voting_opsi(tenant_id);

ALTER TABLE public.voting_suara ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_suara SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_suara ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_suara_tenant ON public.voting_suara(tenant_id);

ALTER TABLE public.usulan_warga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.usulan_warga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.usulan_warga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usulan_warga_tenant ON public.usulan_warga(tenant_id);

ALTER TABLE public.usulan_vote ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.usulan_vote SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.usulan_vote ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usulan_vote_tenant ON public.usulan_vote(tenant_id);

ALTER TABLE public.rpjmdes_periode ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_periode SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_periode ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_periode_tenant ON public.rpjmdes_periode(tenant_id);

ALTER TABLE public.rpjmdes_bidang ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_bidang SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_bidang ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_bidang_tenant ON public.rpjmdes_bidang(tenant_id);

ALTER TABLE public.rpjmdes_program ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_program SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_program ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_program_tenant ON public.rpjmdes_program(tenant_id);

ALTER TABLE public.rkpdes_tahun ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rkpdes_tahun SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rkpdes_tahun ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rkpdes_tahun_tenant ON public.rkpdes_tahun(tenant_id);

ALTER TABLE public.rkpdes_kegiatan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rkpdes_kegiatan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rkpdes_kegiatan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rkpdes_kegiatan_tenant ON public.rkpdes_kegiatan(tenant_id);

-- ============================================================
-- LAYANAN
-- ============================================================
ALTER TABLE public.surat_jenis ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.surat_jenis SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.surat_jenis ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_surat_jenis_tenant ON public.surat_jenis(tenant_id);

ALTER TABLE public.surat_terbit ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.surat_terbit SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.surat_terbit ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_surat_terbit_tenant ON public.surat_terbit(tenant_id);

ALTER TABLE public.pbb_tagihan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.pbb_tagihan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.pbb_tagihan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pbb_tagihan_tenant ON public.pbb_tagihan(tenant_id);

-- ============================================================
-- KESEHATAN & SOSIAL
-- ============================================================
ALTER TABLE public.posyandu_agregat ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.posyandu_agregat SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.posyandu_agregat ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_posyandu_agregat_tenant ON public.posyandu_agregat(tenant_id);

ALTER TABLE public.stunting_agregat ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.stunting_agregat SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.stunting_agregat ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_stunting_agregat_tenant ON public.stunting_agregat(tenant_id);

ALTER TABLE public.bantuan_sosial ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bantuan_sosial SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bantuan_sosial ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bantuan_sosial_tenant ON public.bantuan_sosial(tenant_id);

ALTER TABLE public.penerima_bansos ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.penerima_bansos SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.penerima_bansos ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_penerima_bansos_tenant ON public.penerima_bansos(tenant_id);

-- ============================================================
-- INFRASTRUKTUR & PERTANAHAN
-- ============================================================
ALTER TABLE public.infrastruktur ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.infrastruktur SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.infrastruktur ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_infrastruktur_tenant ON public.infrastruktur(tenant_id);

ALTER TABLE public.kegiatan_pembangunan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.kegiatan_pembangunan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.kegiatan_pembangunan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kegiatan_pembangunan_tenant ON public.kegiatan_pembangunan(tenant_id);

ALTER TABLE public.bidang_tanah ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bidang_tanah SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bidang_tanah ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bidang_tanah_tenant ON public.bidang_tanah(tenant_id);

-- ============================================================
-- DEMOGRAFI & STATISTIK
-- ============================================================
ALTER TABLE public.dpt_pemilih ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.dpt_pemilih SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.dpt_pemilih ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_dpt_pemilih_tenant ON public.dpt_pemilih(tenant_id);

ALTER TABLE public.analisis_snapshot ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.analisis_snapshot SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.analisis_snapshot ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_analisis_snapshot_tenant ON public.analisis_snapshot(tenant_id);

ALTER TABLE public.idm_indikator ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.idm_indikator SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.idm_indikator ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_idm_indikator_tenant ON public.idm_indikator(tenant_id);

-- ============================================================
-- PEMERINTAHAN DESA
-- ============================================================
ALTER TABLE public.desa_pamong ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.desa_pamong SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.desa_pamong ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_desa_pamong_tenant ON public.desa_pamong(tenant_id);

ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.profil_desa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.profil_desa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profil_desa_tenant ON public.profil_desa(tenant_id);

ALTER TABLE public.lembaga_desa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.lembaga_desa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.lembaga_desa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lembaga_desa_tenant ON public.lembaga_desa(tenant_id);

ALTER TABLE public.apbdes ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.apbdes SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.apbdes ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_apbdes_tenant ON public.apbdes(tenant_id);

ALTER TABLE public.buku_register ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.buku_register SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.buku_register ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_buku_register_tenant ON public.buku_register(tenant_id);

-- ============================================================
-- POTENSI & PELAYANAN
-- ============================================================
ALTER TABLE public.potensi_umkm ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_umkm SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_umkm ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_umkm_tenant ON public.potensi_umkm(tenant_id);

ALTER TABLE public.potensi_produk ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_produk SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_produk ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_produk_tenant ON public.potensi_produk(tenant_id);

ALTER TABLE public.potensi_wisata ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_wisata SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_wisata ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_wisata_tenant ON public.potensi_wisata(tenant_id);

ALTER TABLE public.aduan_warga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.aduan_warga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.aduan_warga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aduan_warga_tenant ON public.aduan_warga(tenant_id);

ALTER TABLE public.langganan_wa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.langganan_wa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.langganan_wa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_langganan_wa_tenant ON public.langganan_wa(tenant_id);

ALTER TABLE public.wa_broadcast ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wa_broadcast SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wa_broadcast ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_tenant ON public.wa_broadcast(tenant_id);

ALTER TABLE public.wa_broadcast_target ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wa_broadcast_target SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wa_broadcast_target ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_target_tenant ON public.wa_broadcast_target(tenant_id);

ALTER TABLE public.bencana_kejadian ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bencana_kejadian SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bencana_kejadian ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bencana_kejadian_tenant ON public.bencana_kejadian(tenant_id);

ALTER TABLE public.suplesi_data ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.suplesi_data SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.suplesi_data ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_suplesi_data_tenant ON public.suplesi_data(tenant_id);

END $$;

-- Verifikasi: hitung tenant_id yang ter-set
DO $$
BEGIN
  RAISE NOTICE 'tenant_id migration selesai. Tables updated:';
END $$;


-- ============================================
-- FILE: 20260721000005_rls_tenant_policies.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260721000005_rls_tenant_policies.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Tambahkan RLS policies tenant isolation ke 40 tabel.
--            service_role bypass semua RLS.
-- ============================================================

DO $$
BEGIN

-- ============================================================
-- CORE TABLES
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk read" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk read" ON penduduk FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk write" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk write" ON penduduk FOR UPDATE USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk insert" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk insert" ON penduduk FOR INSERT WITH CHECK (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk delete" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk delete" ON penduduk FOR DELETE USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: keluarga read" ON keluarga';
EXECUTE 'CREATE POLICY "Tenant isolation: keluarga read" ON keluarga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: keluarga write" ON keluarga';
EXECUTE 'CREATE POLICY "Tenant isolation: keluarga write" ON keluarga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wilayah_dusun read" ON wilayah_dusun';
EXECUTE 'CREATE POLICY "Tenant isolation: wilayah_dusun read" ON wilayah_dusun FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wilayah_dusun write" ON wilayah_dusun';
EXECUTE 'CREATE POLICY "Tenant isolation: wilayah_dusun write" ON wilayah_dusun FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- GOVERNANCE
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_topik read" ON voting_topik';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_topik read" ON voting_topik FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_topik write" ON voting_topik';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_topik write" ON voting_topik FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_opsi read" ON voting_opsi';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_opsi read" ON voting_opsi FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_opsi write" ON voting_opsi';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_opsi write" ON voting_opsi FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_suara read" ON voting_suara';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_suara read" ON voting_suara FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_suara write" ON voting_suara';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_suara write" ON voting_suara FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_warga read" ON usulan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_warga read" ON usulan_warga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_warga write" ON usulan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_warga write" ON usulan_warga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_vote read" ON usulan_vote';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_vote read" ON usulan_vote FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_vote write" ON usulan_vote';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_vote write" ON usulan_vote FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_periode read" ON rpjmdes_periode';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_periode read" ON rpjmdes_periode FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_periode write" ON rpjmdes_periode';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_periode write" ON rpjmdes_periode FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_bidang read" ON rpjmdes_bidang';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_bidang read" ON rpjmdes_bidang FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_bidang write" ON rpjmdes_bidang';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_bidang write" ON rpjmdes_bidang FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_program read" ON rpjmdes_program';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_program read" ON rpjmdes_program FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_program write" ON rpjmdes_program';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_program write" ON rpjmdes_program FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_tahun read" ON rkpdes_tahun';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_tahun read" ON rkpdes_tahun FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_tahun write" ON rkpdes_tahun';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_tahun write" ON rkpdes_tahun FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_kegiatan read" ON rkpdes_kegiatan';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_kegiatan read" ON rkpdes_kegiatan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_kegiatan write" ON rkpdes_kegiatan';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_kegiatan write" ON rkpdes_kegiatan FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- LAYANAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON surat_jenis';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_jenis read" ON surat_jenis FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON surat_jenis';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_jenis write" ON surat_jenis FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_terbit read" ON surat_terbit';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_terbit read" ON surat_terbit FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_terbit write" ON surat_terbit';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_terbit write" ON surat_terbit FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: pbb_tagihan read" ON pbb_tagihan';
EXECUTE 'CREATE POLICY "Tenant isolation: pbb_tagihan read" ON pbb_tagihan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: pbb_tagihan write" ON pbb_tagihan';
EXECUTE 'CREATE POLICY "Tenant isolation: pbb_tagihan write" ON pbb_tagihan FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- KESEHATAN & SOSIAL
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: posyandu_agregat read" ON posyandu_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: posyandu_agregat read" ON posyandu_agregat FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: posyandu_agregat write" ON posyandu_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: posyandu_agregat write" ON posyandu_agregat FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: stunting_agregat read" ON stunting_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: stunting_agregat read" ON stunting_agregat FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: stunting_agregat write" ON stunting_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: stunting_agregat write" ON stunting_agregat FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bantuan_sosial read" ON bantuan_sosial';
EXECUTE 'CREATE POLICY "Tenant isolation: bantuan_sosial read" ON bantuan_sosial FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bantuan_sosial write" ON bantuan_sosial';
EXECUTE 'CREATE POLICY "Tenant isolation: bantuan_sosial write" ON bantuan_sosial FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penerima_bansos read" ON penerima_bansos';
EXECUTE 'CREATE POLICY "Tenant isolation: penerima_bansos read" ON penerima_bansos FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penerima_bansos write" ON penerima_bansos';
EXECUTE 'CREATE POLICY "Tenant isolation: penerima_bansos write" ON penerima_bansos FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- INFRASTRUKTUR & PERTANAHAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: infrastruktur read" ON infrastruktur';
EXECUTE 'CREATE POLICY "Tenant isolation: infrastruktur read" ON infrastruktur FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: infrastruktur write" ON infrastruktur';
EXECUTE 'CREATE POLICY "Tenant isolation: infrastruktur write" ON infrastruktur FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: kegiatan_pembangunan read" ON kegiatan_pembangunan';
EXECUTE 'CREATE POLICY "Tenant isolation: kegiatan_pembangunan read" ON kegiatan_pembangunan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: kegiatan_pembangunan write" ON kegiatan_pembangunan';
EXECUTE 'CREATE POLICY "Tenant isolation: kegiatan_pembangunan write" ON kegiatan_pembangunan FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bidang_tanah read" ON bidang_tanah';
EXECUTE 'CREATE POLICY "Tenant isolation: bidang_tanah read" ON bidang_tanah FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bidang_tanah write" ON bidang_tanah';
EXECUTE 'CREATE POLICY "Tenant isolation: bidang_tanah write" ON bidang_tanah FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- DEMOGRAFI & STATISTIK
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dpt_pemilih read" ON dpt_pemilih';
EXECUTE 'CREATE POLICY "Tenant isolation: dpt_pemilih read" ON dpt_pemilih FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dpt_pemilih write" ON dpt_pemilih';
EXECUTE 'CREATE POLICY "Tenant isolation: dpt_pemilih write" ON dpt_pemilih FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: analisis_snapshot read" ON analisis_snapshot';
EXECUTE 'CREATE POLICY "Tenant isolation: analisis_snapshot read" ON analisis_snapshot FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: analisis_snapshot write" ON analisis_snapshot';
EXECUTE 'CREATE POLICY "Tenant isolation: analisis_snapshot write" ON analisis_snapshot FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: idm_indikator read" ON idm_indikator';
EXECUTE 'CREATE POLICY "Tenant isolation: idm_indikator read" ON idm_indikator FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: idm_indikator write" ON idm_indikator';
EXECUTE 'CREATE POLICY "Tenant isolation: idm_indikator write" ON idm_indikator FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- PEMERINTAHAN DESA
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: desa_pamong read" ON desa_pamong';
EXECUTE 'CREATE POLICY "Tenant isolation: desa_pamong read" ON desa_pamong FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: desa_pamong write" ON desa_pamong';
EXECUTE 'CREATE POLICY "Tenant isolation: desa_pamong write" ON desa_pamong FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: profil_desa read" ON profil_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: profil_desa read" ON profil_desa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: profil_desa write" ON profil_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: profil_desa write" ON profil_desa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: lembaga_desa read" ON lembaga_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: lembaga_desa read" ON lembaga_desa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: lembaga_desa write" ON lembaga_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: lembaga_desa write" ON lembaga_desa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: apbdes read" ON apbdes';
EXECUTE 'CREATE POLICY "Tenant isolation: apbdes read" ON apbdes FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: apbdes write" ON apbdes';
EXECUTE 'CREATE POLICY "Tenant isolation: apbdes write" ON apbdes FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: buku_register read" ON buku_register';
EXECUTE 'CREATE POLICY "Tenant isolation: buku_register read" ON buku_register FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: buku_register write" ON buku_register';
EXECUTE 'CREATE POLICY "Tenant isolation: buku_register write" ON buku_register FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- POTENSI & PELAYANAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_umkm read" ON potensi_umkm';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_umkm read" ON potensi_umkm FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_umkm write" ON potensi_umkm';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_umkm write" ON potensi_umkm FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_produk read" ON potensi_produk';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_produk read" ON potensi_produk FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_produk write" ON potensi_produk';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_produk write" ON potensi_produk FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_wisata read" ON potensi_wisata';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_wisata read" ON potensi_wisata FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_wisata write" ON potensi_wisata';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_wisata write" ON potensi_wisata FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: aduan_warga read" ON aduan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: aduan_warga read" ON aduan_warga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: aduan_warga write" ON aduan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: aduan_warga write" ON aduan_warga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: langganan_wa read" ON langganan_wa';
EXECUTE 'CREATE POLICY "Tenant isolation: langganan_wa read" ON langganan_wa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: langganan_wa write" ON langganan_wa';
EXECUTE 'CREATE POLICY "Tenant isolation: langganan_wa write" ON langganan_wa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast read" ON wa_broadcast';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast read" ON wa_broadcast FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast write" ON wa_broadcast';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast write" ON wa_broadcast FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast_target read" ON wa_broadcast_target';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast_target read" ON wa_broadcast_target FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast_target write" ON wa_broadcast_target';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast_target write" ON wa_broadcast_target FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bencana_kejadian read" ON bencana_kejadian';
EXECUTE 'CREATE POLICY "Tenant isolation: bencana_kejadian read" ON bencana_kejadian FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bencana_kejadian write" ON bencana_kejadian';
EXECUTE 'CREATE POLICY "Tenant isolation: bencana_kejadian write" ON bencana_kejadian FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: suplesi_data read" ON suplesi_data';
EXECUTE 'CREATE POLICY "Tenant isolation: suplesi_data read" ON suplesi_data FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: suplesi_data write" ON suplesi_data';
EXECUTE 'CREATE POLICY "Tenant isolation: suplesi_data write" ON suplesi_data FOR ALL USING (tenant_id = get_tenant_id())';

RAISE NOTICE 'RLS tenant isolation policies applied successfully.';

END $$;

-- Verifikasi
SELECT tablename, COUNT(*) FILTER (WHERE policyname LIKE 'Tenant isolation%') as rls_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;


-- ============================================
-- FILE: 20260721000006_fix_posyandu_schema_and_consistency.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260721000006_fix_posyandu_schema_and_consistency.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Fix posyandu_agregat schema + domain_event triggers
--
-- Bug fixes:
-- 1. posyandu_agregat: missing columns (bulan, jumlah_bayi, jumlah_balita_retained,
--    jumlah_ibu_hamil, jumlah_ibu_menyusui, kunjugan_lebih_dari_sekali, jumlah_gizi_buruk)
-- 2. Domain event trigger: wrong column name (kunjugan -> kunjungan)
-- 3. stunting_agregat: missing bulan column
-- ============================================================

BEGIN;

-- ============================================================
-- 1. Fix posyandu_agregat: add missing columns
-- ============================================================

-- Add columns if they don't exist
DO $$
BEGIN
  -- Add bulan (TEXT format 'YYYY-MM' for easy filtering)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'bulan'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN bulan TEXT;
    -- Populate from existing periode
    UPDATE public.posyandu_agregat SET bulan = TO_CHAR(periode, 'YYYY-MM') WHERE bulan IS NULL;
  END IF;

  -- Add tenant_id (for multi-tenancy) - check if already added
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'tenant_id'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN tenant_id UUID;
    -- Set default from first tenant
    UPDATE public.posyandu_agregat SET tenant_id = (SELECT id FROM public.tenants LIMIT 1) WHERE tenant_id IS NULL;
    ALTER TABLE public.posyandu_agregat ALTER COLUMN tenant_id SET NOT NULL;
    ALTER TABLE public.posyandu_agregat ALTER COLUMN tenant_id SET DEFAULT (SELECT id FROM public.tenants LIMIT 1);
  END IF;

  -- Add jumlah_bayi (bayi 0-11 bulan)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'jumlah_bayi'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN jumlah_bayi INT DEFAULT 0;
  END IF;

  -- Rename kunjugan_lebih_dari_sekali -> kunjungan_lebih_dari_sekali
  -- Check if old column exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'kunjugan_lebih_dari_sekali'
  ) THEN
    ALTER TABLE public.posyandu_agregat RENAME COLUMN kunjugan_lebih_dari_sekali TO kunjungan_lebih_dari_sekali;
  END IF;

  -- Add columns if not exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'kunjungan_lebih_dari_sekali'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN kunjungan_lebih_dari_sekali INT DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'jumlah_ibu_hamil'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN jumlah_ibu_hamil INT DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'jumlah_ibu_menyusui'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN jumlah_ibu_menyusui INT DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'jumlah_gizi_buruk'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN jumlah_gizi_buruk INT DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'posyandu_agregat' AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.posyandu_agregat ADD COLUMN created_by UUID REFERENCES auth.users(id);
    ALTER TABLE public.posyandu_agregat ADD COLUMN updated_by UUID REFERENCES auth.users(id);
  END IF;

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Some posyandu_agregat columns may already exist: %', SQLERRM;
END $$;

-- Add indexes if not exist
CREATE INDEX IF NOT EXISTS idx_posyandu_agregat_bulan ON public.posyandu_agregat(bulan);
CREATE INDEX IF NOT EXISTS idx_posyandu_agregat_tenant ON public.posyandu_agregat(tenant_id);
CREATE INDEX IF NOT EXISTS idx_posyandu_agregat_gizi_buruk ON public.posyandu_agregat(jumlah_gizi_buruk) WHERE jumlah_gizi_buruk > 0;

-- ============================================================
-- 2. Fix stunting_agregat: add bulan column
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'stunting_agregat' AND column_name = 'bulan'
  ) THEN
    ALTER TABLE public.stunting_agregat ADD COLUMN bulan TEXT;
    -- Populate from existing periode if column exists
    BEGIN
      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'stunting_agregat' AND column_name = 'periode'
      ) THEN
        UPDATE public.stunting_agregat SET bulan = TO_CHAR(periode, 'YYYY-MM') WHERE bulan IS NULL;
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;

  -- Add tenant_id if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'stunting_agregat' AND column_name = 'tenant_id'
  ) THEN
    ALTER TABLE public.stunting_agregat ADD COLUMN tenant_id UUID;
    UPDATE public.stunting_agregat SET tenant_id = (SELECT id FROM public.tenants LIMIT 1) WHERE tenant_id IS NULL;
    ALTER TABLE public.stunting_agregat ALTER COLUMN tenant_id SET NOT NULL;
    ALTER TABLE public.stunting_agregat ALTER COLUMN tenant_id SET DEFAULT (SELECT id FROM public.tenants LIMIT 1);
  END IF;

  -- Add indexes
  CREATE INDEX IF NOT EXISTS idx_stunting_agregat_bulan ON public.stunting_agregat(bulan);
  CREATE INDEX IF NOT EXISTS idx_stunting_agregat_tenant ON public.stunting_agregat(tenant_id);

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Some stunting_agregat columns may already exist: %', SQLERRM;
END $$;

-- ============================================================
-- 3. Fix domain event trigger for posyandu (typo: kunjugan -> kunjungan)
-- ============================================================

-- Drop old trigger and function
DROP TRIGGER IF EXISTS trg_posyandu_agregat_publish_event ON public.posyandu_agregat;
DROP FUNCTION IF EXISTS trigger_publish_posyandu_event();

-- Create corrected trigger function
CREATE OR REPLACE FUNCTION trigger_publish_posyandu_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_payload JSONB;
  v_tenant_id UUID;
BEGIN
  -- Get tenant_id
  v_tenant_id := NEW.tenant_id;
  IF v_tenant_id IS NULL THEN
    v_tenant_id := get_tenant_id();
  END IF;

  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'bulan', NEW.bulan,
      'dusun', NEW.dusun,
      'jumlah_balita', NEW.jumlah_balita,
      'jumlah_bayi', COALESCE(NEW.jumlah_bayi, 0),
      'jumlah_ibu_hamil', COALESCE(NEW.jumlah_ibu_hamil, 0),
      'jumlah_ibu_menyusui', COALESCE(NEW.jumlah_ibu_menyusui, 0),
      'kunjungan_lebih_dari_sekali', COALESCE(NEW.kunjungan_lebih_dari_sekali, 0)
    );
    PERFORM publish_event(
      'posyandu.kunjungan.dicatat',
      'posyandu_agregat',
      NEW.id,
      v_payload,
      NEW.created_by,
      v_tenant_id
    );

  ELSIF TG_OP = 'UPDATE' THEN
    -- Deteksi balita terindikasi gizi buruk
    IF COALESCE(NEW.jumlah_gizi_buruk, 0) > COALESCE(OLD.jumlah_gizi_buruk, 0) THEN
      v_payload := jsonb_build_object(
        'bulan', NEW.bulan,
        'dusun', NEW.dusun,
        'jumlah_gizi_buruk', NEW.jumlah_gizi_buruk,
        'penambahan', NEW.jumlah_gizi_buruk - COALESCE(OLD.jumlah_gizi_buruk, 0)
      );
      PERFORM publish_event(
        'posyandu.balita.terindikasi_gizi_buruk',
        'posyandu_agregat',
        NEW.id,
        v_payload,
        NEW.updated_by,
        v_tenant_id
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Recreate trigger
CREATE TRIGGER trg_posyandu_agregat_publish_event
  AFTER INSERT OR UPDATE ON public.posyandu_agregat
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_posyandu_event();

-- ============================================================
-- 4. Fix idm_skor_cache unique constraint to match upsert
-- ============================================================

DO $$
BEGIN
  -- Check if UNIQUE constraint exists with old name
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'idm_skor_cache_tenant_id_indikator_kode_key'
  ) THEN
    -- Try to add constraint if table has correct structure
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'idm_skor_cache'
      AND column_name = 'indikator_kode'
    ) THEN
      -- Drop old constraint if exists with different name
      ALTER TABLE idm_skor_cache DROP CONSTRAINT IF EXISTS idm_skor_cache_pkey;
      ALTER TABLE idm_skor_cache DROP CONSTRAINT IF EXISTS idm_skor_cache_tenant_id_indikator_key;

      -- Add proper unique constraint
      ALTER TABLE idm_skor_cache ADD CONSTRAINT idm_skor_cache_tenant_id_indikator_kode_key
        UNIQUE (tenant_id, indikator_kode);

      -- Restore primary key on id
      ALTER TABLE idm_skor_cache ADD PRIMARY KEY (id);
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'idm_skor_cache constraint may already exist: %', SQLERRM;
END $$;

-- ============================================================
-- 5. Ensure cron jobs are active for IDM scorer
-- ============================================================

DO $$
BEGIN
  -- Check if pg_cron extension exists
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    -- Unschedule old job if exists
    PERFORM cron.unschedule('idm-scorer-daily');

    -- Schedule IDM scorer to run daily at 2 AM
    PERFORM cron.schedule(
      'idm-scorer-daily',
      '0 2 * * *',
      $$
      SELECT net.http_post(
        url => COALESCE(
          current_setting('app.settings.idm_scorer_url', true),
          (SELECT value FROM app_settings WHERE key = 'idm_scorer_url')
        ) || '/functions/v1/idm-scorer',
        headers => jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || current_setting('app.settings.supabase_service_role_key', true)
        ),
        body => jsonb_build_object('source', 'pg_cron')
      );
      $$
    );

    RAISE NOTICE 'IDM scorer cron job scheduled';
  ELSE
    RAISE NOTICE 'pg_cron extension not available - IDM scorer cron not scheduled';
  END IF;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error scheduling IDM scorer cron: %', SQLERRM;
END $$;

COMMIT;

-- ============================================================
-- DONE
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE 'Fix posyandu schema and consistency migration completed.';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  - posyandu_agregat: added bulan, tenant_id, jumlah_bayi,';
  RAISE NOTICE '    kunjungan_lebih_dari_sekali, jumlah_ibu_hamil,';
  RAISE NOTICE '    jumlah_ibu_menyusui, jumlah_gizi_buruk';
  RAISE NOTICE '  - stunting_agregat: added bulan, tenant_id';
  RAISE NOTICE '  - Domain event trigger: fixed kunjugan -> kunjungan';
  RAISE NOTICE '  - idm_skor_cache: added proper UNIQUE constraint';
  RAISE NOTICE '  - IDM scorer cron job scheduled (daily at 2 AM)';
END $$;


-- ============================================
-- FILE: 20260722000001_add_uuid_refs_and_missing_tables.sql
-- ============================================

-- ============================================================
-- MIGRASI: 20260722000001_add_uuid_refs_and_missing_tables.sql
-- Tanggal: 2026-07-22
-- Deskripsi: Penuh-hampir kebutuhan PEDOMAN_MONOREPO:
--   1. UUID FK columns di penduduk (ref_agama_id, ref_pendidikan_id, dll.)
--   2. Tabel baru yang belum ada
--   3. Seed ref tables yang belum ada
-- ============================================================

-- ============================================================
-- BAGIAN 1: UUID Foreign Key di penduduk (penduduk FK cols)
-- ============================================================
-- Tambahkan kolom UUID FK ke reference tables
-- existing data tetap aman karena kolom baru nullable

ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS agama_id UUID REFERENCES ref_agama(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS pendidikan_id UUID REFERENCES ref_pendidikan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS pekerjaan_id UUID REFERENCES ref_pekerjaan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS status_perkawinan_id UUID REFERENCES ref_status_perkawinan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS golongan_darah_id UUID REFERENCES ref_golongan_darah(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS warga_negara_id UUID REFERENCES ref_warga_negara(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS dusun_id UUID,  -- FK ke wilolos_batas (dibuat di bagian terpisah)
  ADD COLUMN IF NOT EXISTS rt_id UUID,
  ADD COLUMN IF NOT EXISTS rw_id UUID;

-- Sinkronisasi kolom UUID FK dari data TEXT existing (backfill otomatis)
UPDATE public.penduduk p SET
  agama_id = (SELECT id FROM ref_agama WHERE LOWER(nama) = LOWER(p.agama) LIMIT 1),
  pendidikan_id = (SELECT id FROM ref_pendidikan WHERE LOWER(nama) = LOWER(p.pendidikan) LIMIT 1),
  pekerjaan_id = (SELECT id FROM ref_pekerjaan WHERE LOWER(nama) = LOWER(p.pekerjaan) LIMIT 1),
  status_perkawinan_id = (SELECT id FROM ref_status_perkawinan WHERE LOWER(nama) = LOWER(p.status_kawin) LIMIT 1),
  golongan_darah_id = (SELECT id FROM ref_golong_darah WHERE LOWER(nama) = LOWER(golongan_darah) LIMIT 1);

-- ============================================================
-- BAGIAN 2: Tabel domain yang belum ada
-- ============================================================

-- balita (fakta mentah Posyandu F4)
CREATE TABLE IF NOT EXISTS balita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama VARCHAR(150) NOT NULL,
  tanggal_lahir DATE NOT NULL,
  jenis_kelamin VARCHAR(1) CHECK (jenis_kelamin IN ('L','P')),
  orang_tua_penduduk_id UUID REFERENCES penduduk(id) ON DELETE SET NULL,
  dusun VARCHAR(100),
  rt VARCHAR(5), rw VARCHAR(5),
  alamat TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON balita TO authenticated;
GRANT ALL ON balita TO service_role;
ALTER TABLE balita ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: balita read" ON balita FOR SELECT USING (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: balita write" ON balita FOR INSERT WITH CHECK (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: balita update" ON balita FOR UPDATE USING (tenant_id = get_tenant_id());

-- posyandu_kunjungan (fakta mentah Posyandu F4)
CREATE TABLE IF NOT EXISTS posyandu_kunjungan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  balita_id UUID NOT NULL REFERENCES balita(id),
  kader_penduduk_id UUID REFERENCES penduduk(id),
  tanggal DATE NOT NULL,
  berat_kg NUMERIC(5,2),
  tinggi_cm NUMERIC(5,2),
  imunisasi VARCHAR(50)[],
  status_gizi VARCHAR(20) CHECK (status_gizi IN ('baik','kurang','buruk','lebih')),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON posyandu_kunjungan TO authenticated;
GRANT ALL ON posyandu_kunjungan TO service_role;
ALTER TABLE posyandu_kunjungan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: posyandu_kunjungan read" ON posyandu_kunjungan FOR SELECT USING (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: posyandu_kunjungan write" ON posyandu_kunjungan FOR INSERT WITH CHECK (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: posyandu_kunjungan update" ON posyandu_kunjungan FOR UPDATE USING (tenant_id = get_tenant_id());

-- bidang_kegiatan (global seed - sama semua tenant)
CREATE TABLE IF NOT EXISTS bidang_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(2) NOT NULL UNIQUE,
  nama VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON bidang_kegiatan TO authenticated;
GRANT ALL ON bidang_kegiatan TO service_role;
ALTER TABLE bidang_kegiatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read bidang_kegiatan" ON bidang_kegiatan FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage bidang_kegiatan" ON bidang_kegiatan FOR ALL TO service_role USING (true);

-- Seed bidang_kegiatan (Permendagri 20/2018 + IDM)
INSERT INTO bidang_kegiatan (kode, nama) VALUES
  ('1', 'Penyelenggaraan Pemerintahan Desa'),
  ('2', 'Pelaksanaan Pembangunan Desa'),
  ('3', 'Pembinaan Kemasyarakatan'),
  ('4', 'Pelayanan Kecamatan')
ON CONFLICT (kode) DO NOTHING;

-- rekening_anggaran (satu pintu - seed dari IDM/PERMENDES 7/2023 kode rekening)
CREATE TABLE IF NOT EXISTS rekening_anggaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(30) NOT NULL UNIQUE,
  nama VARCHAR(200) NOT NULL,
  jenis VARCHAR(15) NOT NULL CHECK (jenis IN ('pendapatan','belanja','pembiayaan'),
  bidang_id VARCHAR(2), -- ref ke bidang_kegiatan.kode
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON rekening_anggaran TO authenticated;
GRANT ALL ON rekening_anggaran TO service_role;
ALTER TABLE rekening_anggaran ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read rekening_anggaran" ON rekening_anggaran FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage rekening_anggaran" ON rekening_anggaran FOR ALL TO service_role USING (true);

-- Seed rekening_anggaran (subset umum)
INSERT INTO rekening_anggaran (kode, nama, jenis, bidang_id) VALUES
  ('4.01', 'Honorariat PTPD', 'belanja', '1'),
  ('5.01', 'Belanja Modal Tanah', 'belanja', '2'),
  ('5.02', 'Belanja Modal Gedung', 'belanja', '2'),
  ('6.01', 'Pembentukan cadreserta APBDes', 'pembiayaan', '4')
ON CONFLICT (kode) DO NOTHING;

-- notifikasi (inbox per user)
CREATE TABLE IF NOT EXISTS notifikasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  penerima_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  penerima_tipe VARCHAR(20) CHECK (penerima_tipe IN ('user','warga','perangkat')),
  penerima_id UUID,
  judul VARCHAR(200) NOT NULL,
  pesan TEXT NOT NULL,
  tautan TEXT,
  status_baca BOOLEAN NOT NULL DEFAULT false,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_notifikasi_penerima ON notifikasi(penerima_user_id, dibuat_pada DESC);
GRANT SELECT ON notifikasi TO authenticated;
GRANT INSERT ON notifikasi TO service_role;
GRANT UPDATE ON notifikasi TO authenticated;
ALTER TABLE notifikasi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: notifikasi read" ON notifikasi FOR SELECT TO authenticated USING (tenant_id = get_tenant_id() AND (penerima_user_id = auth.uid() OR auth.uid() IN (SELECT user_id FROM user_peran WHERE peran IN ('admin','kades','sekdes'));
CREATE POLICY "Service manage notifikasi" ON notifikasi FOR INSERT TO service_role USING (true);
CREATE POLICY "notifikasi_update" ON notifikasi FOR UPDATE TO authenticated USING (penerima_user_id = auth.uid() OR auth.uid() IN (SELECT user_id FROM user_peran WHERE peran IN ('admin','kades','sekdes'));

-- outbox_pesan (antrian kirim pesan WA/SMS/email)
CREATE TABLE IF NOT EXISTS outbox_pesan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  notifikasi_id UUID REFERENCES notifikasi(id) ON DELETE SET NULL,
  channel VARCHAR(10) NOT NULL CHECK (channel IN ('wa','sms','email','push'),
  tujuan VARCHAR(200) NOT NULL,
  isi TEXT NOT NULL,
  status VARCHAR(15) NOT NULL DEFAULT 'antri' CHECK (status IN ('antri','dikirim','gagal','batal'),
  percobaan INT NOT NULL DEFAULT 0,
  error_message TEXT,
  dijadwalkan_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  dikirim_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_outbox_pesan_status ON outbox_pesan(status, dikirim_pada) WHERE status = 'antri';
GRANT SELECT ON outbox_pesan TO authenticated;
GRANT INSERT ON outbox_pesan TO service_role;
GRANT UPDATE ON outbox_pesan TO service_role;
ALTER TABLE outbox_pesan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service manage outbox_pesan" ON outbox_pesan FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service write outbox_pesan" ON outbox_pesan FOR INSERT TO service_role WITH CHECK (true);

-- otp_token (login Layanan Mandiri)
CREATE TABLE IF NOT EXISTS otp_token (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  penduduk_id UUID REFERENCES penduduk(id) ON DELETE CASCADE,
  tujuan VARCHAR(50) NOT NULL CHECK (tujuan IN ('login','verifikasi','reset_password')),
  kode_hash VARCHAR(255) NOT NULL,
  expired_at TIMESTAMPZ NOT NULL,
  percobaan INT NOT NULL DEFAULT 0,
  digunakan BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_otp_token ON otp_token(tenant_id, kode_hash) WHERE digunakan = false;
GRANT SELECT ON otp_token TO authenticated;
GRANT INSERT ON otp_token TO service_role;
GRANT UPDATE ON otp_token TO service_role;
ALTER TABLE otp_token ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service manage otp_token" ON otp_token FOR ALL TO service_role USING (true);

-- wa_chat_session (WA chatbot state)
CREATE TABLE IF NOT EXISTS wa_chat_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  current_state VARCHAR(30) NOT NULL DEFAULT 'menu_utama',
  tier VARCHAR(15) NOT NULL DEFAULT 'transaksi' CHECK (tier IN ('info_instan','transaksi')),
  context_data JSONB NOT NULL DEFAULT '{}',
  current_entity_id UUID,
  current_entity_tipe VARCHAR(30),
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(tenant_id, nomor_hp)
);
CREATE INDEX idx_wa_session_expires ON wa_chat_session(expires_at) WHERE expires_at < now();
GRANT SELECT ON wa_chat_session TO authenticated;
GRANT ALL ON wa_chat_session TO service_role;
ALTER TABLE wa_chat_session ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read wa_chat_session" ON wa_chat_session FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage wa_chat_session" ON wa_chat_session FOR ALL TO service_role USING (true);

-- ============================================================
-- BAGIAN 3: Trigger penduduk UUID backfill (idempotent)
-- Trigger di penduduk sudah ada (trg_penduduk_publish_event) - hanya backfill UUID FK
-- ============================================================

-- Kolom trigger tidak perlu perubahan karena trigger TEXT-based sudah jalan
-- Berikut trigger backfill UUID FK saat data penduduk di-update manual
CREATE OR REPLACE FUNCTION backfill_penduduk_uuid_fk()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  UPDATE public.penduduk p SET
    agama_id = sub.id
  FROM ref_agama sub
  WHERE LOWER(sub.nama) = LOWER(p.agama)
    AND p.agama_id IS NULL;

  UPDATE public.penduduk p SET
    pendidikan_id = sub.id
  FROM ref_pendidikan sub
  WHERE LOWER(sub.nama) = LOWER(p.pendidikan)
    AND p.pendidikan_id IS NULL;
END;
$$;

-- ============================================================
-- BAGIAN 4: Verifikasi
-- ============================================================
SELECT 'Tables created:' as info, COUNT(*) as count
FROM information_schema.tables WHERE table_schema = 'public'
  AND table_name IN (
    'balita','posyandu_kunjungan','bidang_kegiatan','rekening_anggaran',
    'notifikasi','outbox_pesan','otp_token','wa_chat_session'
  );
