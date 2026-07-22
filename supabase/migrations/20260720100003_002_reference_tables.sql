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
