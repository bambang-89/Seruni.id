-- Migration: Create all reference tables for Seruni.id portal
-- Created: 2026-07-27
-- Description: ref_kategori_aduan, ref_tipe_umkm, ref_jenis_wisata, ref_kategori_usulan,
--              ref_sumber_dana, ref_sistem_target, ref_tipe_keluarga, ref_rt_rw

DO $$
DECLARE
  _fn text;
BEGIN
  -- Get the actual update trigger function name from the database
  SELECT proname INTO _fn FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'public' AND p.proname LIKE '%updated_at%' AND p.pronargs = 0
  LIMIT 1;
  IF _fn IS NULL THEN _fn := 'set_updated_at'; END IF;

  -- ============================================================
  -- 1. ref_kategori_aduan
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_kategori_aduan (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_kategori_aduan ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_kategori_aduan" ON ref_kategori_aduan FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_kategori_aduan TO authenticated;
  GRANT ALL ON ref_kategori_aduan TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_kategori_aduan_updated_at BEFORE UPDATE ON ref_kategori_aduan FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_kategori_aduan (kode, nama, urutan) VALUES
    ('01', 'Infrastruktur', 1),
    ('02', 'Layanan', 2),
    ('03', 'Keamanan', 3),
    ('04', 'Lingkungan', 4),
    ('05', 'Sosial', 5),
    ('06', 'Lainnya', 6)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 2. ref_tipe_umkm
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_tipe_umkm (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_tipe_umkm ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_tipe_umkm" ON ref_tipe_umkm FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_tipe_umkm TO authenticated;
  GRANT ALL ON ref_tipe_umkm TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_tipe_umkm_updated_at BEFORE UPDATE ON ref_tipe_umkm FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_tipe_umkm (kode, nama, urutan) VALUES
    ('01', 'UMKM', 1),
    ('02', 'BUMDes', 2),
    ('03', 'Koperasi', 3)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 3. ref_jenis_wisata
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_jenis_wisata (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_jenis_wisata ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_jenis_wisata" ON ref_jenis_wisata FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_jenis_wisata TO authenticated;
  GRANT ALL ON ref_jenis_wisata TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_jenis_wisata_updated_at BEFORE UPDATE ON ref_jenis_wisata FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_jenis_wisata (kode, nama, urutan) VALUES
    ('01', 'Bahari', 1),
    ('02', 'Pegunungan', 2),
    ('03', 'Budaya', 3),
    ('04', 'Buatan', 4),
    ('05', 'Kuliner', 5)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 4. ref_kategori_usulan
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_kategori_usulan (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_kategori_usulan ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_kategori_usulan" ON ref_kategori_usulan FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_kategori_usulan TO authenticated;
  GRANT ALL ON ref_kategori_usulan TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_kategori_usulan_updated_at BEFORE UPDATE ON ref_kategori_usulan FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_kategori_usulan (kode, nama, urutan) VALUES
    ('01', 'Infrastruktur', 1),
    ('02', 'Pendidikan', 2),
    ('03', 'Kesehatan', 3),
    ('04', 'Ekonomi', 4),
    ('05', 'Lingkungan', 5),
    ('06', 'Sosial', 6),
    ('07', 'Lainnya', 7)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 5. ref_sumber_dana
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_sumber_dana (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_sumber_dana ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_sumber_dana" ON ref_sumber_dana FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_sumber_dana TO authenticated;
  GRANT ALL ON ref_sumber_dana TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_sumber_dana_updated_at BEFORE UPDATE ON ref_sumber_dana FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_sumber_dana (kode, nama, urutan) VALUES
    ('01', 'APBD Desa', 1),
    ('02', 'Dana Desa (DD)', 2),
    ('03', 'Alokasi Dana Desa (ADD)', 3),
    ('04', 'Bantuan Provinsi', 4),
    ('05', 'Bantuan Kabupaten/Kota', 5),
    ('06', 'Bantuan Pusat', 6),
    ('07', 'Swadaya Masyarakat', 7),
    ('08', 'CSR / Partnership', 8),
    ('09', 'Lainnya', 9)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 6. ref_sistem_target
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_sistem_target (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_sistem_target ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_sistem_target" ON ref_sistem_target FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_sistem_target TO authenticated;
  GRANT ALL ON ref_sistem_target TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_sistem_target_updated_at BEFORE UPDATE ON ref_sistem_target FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_sistem_target (kode, nama, urutan) VALUES
    ('01', 'Dukcapil', 1),
    ('02', 'SIPD', 2),
    ('03', 'Prodeskel', 3),
    ('04', 'BPS', 4),
    ('05', 'Lainnya', 5)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 7. ref_tipe_keluarga
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_tipe_keluarga (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(100) NOT NULL,
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_tipe_keluarga ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_tipe_keluarga" ON ref_tipe_keluarga FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_tipe_keluarga TO authenticated;
  GRANT ALL ON ref_tipe_keluarga TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_tipe_keluarga_updated_at BEFORE UPDATE ON ref_tipe_keluarga FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_tipe_keluarga (kode, nama, urutan) VALUES
    ('01', 'Umum', 1),
    ('02', 'Pra Sejahtera', 2),
    ('03', 'Keluarga Sejahtera I', 3),
    ('04', 'Keluarga Sejahtera II', 4),
    ('05', 'Keluarga Sejahtera III', 5),
    ('06', 'Keluarga Sejahtera III Plus', 6)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- 8. ref_rt_rw
  -- ============================================================
  CREATE TABLE IF NOT EXISTS ref_rt_rw (
      id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
      kode        VARCHAR(10) NOT NULL UNIQUE,
      nama        VARCHAR(50) NOT NULL,
      jenis       VARCHAR(10) NOT NULL CHECK (jenis IN ('rt', 'rw')),
      urutan      INT         NOT NULL DEFAULT 0,
      aktif       BOOLEAN     NOT NULL DEFAULT true,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE ref_rt_rw ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Public read ref_rt_rw" ON ref_rt_rw FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON ref_rt_rw TO authenticated;
  GRANT ALL ON ref_rt_rw TO service_role;
  EXECUTE format('CREATE TRIGGER trg_ref_rt_rw_updated_at BEFORE UPDATE ON ref_rt_rw FOR EACH ROW EXECUTE FUNCTION public.%I()', _fn);
  INSERT INTO ref_rt_rw (kode, nama, jenis, urutan) VALUES
    ('RW01', 'RW 01', 'rw', 1),
    ('RW02', 'RW 02', 'rw', 2),
    ('RW03', 'RW 03', 'rw', 3),
    ('RW04', 'RW 04', 'rw', 4),
    ('RW05', 'RW 05', 'rw', 5),
    ('RW06', 'RW 06', 'rw', 6),
    ('RW07', 'RW 07', 'rw', 7),
    ('RT01', 'RT 01', 'rt', 10),
    ('RT02', 'RT 02', 'rt', 11),
    ('RT03', 'RT 03', 'rt', 12),
    ('RT04', 'RT 04', 'rt', 13),
    ('RT05', 'RT 05', 'rt', 14)
  ON CONFLICT (kode) DO NOTHING;

END $$;
