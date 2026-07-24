-- ============================================================
-- Migration: 20260724190005_wilayah_ref_tables.sql
-- Create reference tables for wilayah hierarchy + migrate penduduk
--
-- HIERARCHY: Provinsi → Kabupaten/Kota → Kecamatan → Desa/Kelurahan → RT/RW
-- Source: KEMENDAGRI API (https://wilayah.indonesia-api.f号召an.com)
-- ============================================================

DO $outer$
DECLARE
  _provinsi_id UUID;
  _kabupaten_id UUID;
  _kecamatan_id UUID;
  _desa_id UUID;
  _seq INT;
BEGIN

  -- ============================================================
  -- Create ref_provinsi
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_provinsi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(2) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    ibukota VARCHAR(100),
    urutan INT NOT NULL DEFAULT 0,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE public.ref_provinsi ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_provinsi" ON public.ref_provinsi;
  CREATE POLICY "Public read ref_provinsi" ON public.ref_provinsi FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_provinsi TO anon;

  -- ============================================================
  -- Create ref_kabupaten
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_kabupaten (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(4) NOT NULL UNIQUE,
    kode_provinsi VARCHAR(2) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    ibukota VARCHAR(100),
    jenis VARCHAR(20) NOT NULL DEFAULT 'Kabupaten' CHECK (jenis IN ('Kabupaten', 'Kota')),
    urutan INT NOT NULL DEFAULT 0,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE public.ref_kabupaten ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_kabupaten" ON public.ref_kabupaten;
  CREATE POLICY "Public read ref_kabupaten" ON public.ref_kabupaten FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_kabupaten TO anon;

  -- ============================================================
  -- Create ref_kecamatan
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_kecamatan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(6) NOT NULL UNIQUE,
    kode_kabupaten VARCHAR(4) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    urutan INT NOT NULL DEFAULT 0,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE public.ref_kecamatan ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_kecamatan" ON public.ref_kecamatan;
  CREATE POLICY "Public read ref_kecamatan" ON public.ref_kecamatan FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_kecamatan TO anon;

  -- ============================================================
  -- Create ref_desa
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_desa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(10) NOT NULL UNIQUE,
    kode_kecamatan VARCHAR(6) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) NOT NULL DEFAULT 'Desa' CHECK (jenis IN ('Desa', 'Kelurahan')),
    kode_pos VARCHAR(10),
    urutan INT NOT NULL DEFAULT 0,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE public.ref_desa ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_desa" ON public.ref_desa;
  CREATE POLICY "Public read ref_desa" ON public.ref_desa FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_desa TO anon;

  -- ============================================================
  -- Create ref_rw
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_rw (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(20) NOT NULL,
    kode_desa VARCHAR(10) NOT NULL,
    rw VARCHAR(5) NOT NULL,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(kode_desa, rw)
  );
  ALTER TABLE public.ref_rw ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_rw" ON public.ref_rw;
  CREATE POLICY "Public read ref_rw" ON public.ref_rw FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_rw TO anon;

  -- ============================================================
  -- Create ref_rt
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_rt (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(20) NOT NULL,
    kode_rw VARCHAR(20) NOT NULL,
    rt VARCHAR(5) NOT NULL,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(kode_rw, rt)
  );
  ALTER TABLE public.ref_rt ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_rt" ON public.ref_rt;
  CREATE POLICY "Public read ref_rt" ON public.ref_rt FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_rt TO anon;

  -- ============================================================
  -- Create ref_dusun
  -- ============================================================
  CREATE TABLE IF NOT EXISTS public.ref_dusun (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode VARCHAR(10) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    urutan INT NOT NULL DEFAULT 0,
    aktif BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE public.ref_dusun ENABLE ROW LEVEL SECURITY;
  DROP POLICY IF EXISTS "Public read ref_dusun" ON public.ref_dusun;
  CREATE POLICY "Public read ref_dusun" ON public.ref_dusun FOR SELECT TO authenticated USING (true);
  GRANT SELECT ON public.ref_dusun TO anon;

  -- ============================================================
  -- Seed ref_provinsi
  -- ============================================================
  INSERT INTO public.ref_provinsi (kode, nama, ibukota, urutan, aktif)
  VALUES
    ('52', 'Nusa Tenggara Barat', 'Mataram', 1, true),
    ('31', 'DKI Jakarta', 'Jakarta', 2, true),
    ('32', 'Jawa Barat', 'Bandung', 3, true),
    ('33', 'Jawa Tengah', 'Semarang', 4, true),
    ('34', 'DI Yogyakarta', 'Yogyakarta', 5, true),
    ('35', 'Jawa Timur', 'Surabaya', 6, true)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- Seed ref_kabupaten
  -- ============================================================
  INSERT INTO public.ref_kabupaten (kode, kode_provinsi, nama, ibukota, jenis, urutan, aktif)
  VALUES
    ('5204', '52', 'Lombok Timur', 'Selong', 'Kabupaten', 1, true),
    ('5201', '52', 'Lombok Barat', 'Gerung', 'Kabupaten', 2, true),
    ('5202', '52', 'Lombok Tengah', 'Praya', 'Kabupaten', 3, true),
    ('5203', '52', 'Lombok Utara', 'Tanjung', 'Kabupaten', 4, true),
    ('5271', '52', 'Kota Mataram', 'Mataram', 'Kota', 5, true)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- Seed ref_kecamatan (Lombok Timur)
  -- ============================================================
  INSERT INTO public.ref_kecamatan (kode, kode_kabupaten, nama, urutan, aktif)
  VALUES
    ('520401', '5204', 'Pringgabaya', 1, true),
    ('520402', '5204', 'Pringgabaya Utara', 2, true),
    ('520403', '5204', 'Pringgabaya Timur', 3, true),
    ('520404', '5204', 'Suela', 4, true),
    ('520405', '5204', 'Sukamulia', 5, true),
    ('520406', '5204', 'Jerowaru', 6, true),
    ('520407', '5204', 'Suralaga', 7, true),
    ('520408', '5204', 'Keruak', 8, true),
    ('520409', '5204', 'Sembalun', 9, true),
    ('520410', '5204', 'Ramani', 10, true),
    ('520411', '5204', 'Labuhan Haji', 11, true),
    ('520412', '5204', 'Masbagik', 12, true),
    ('520413', '5204', 'Sikur', 13, true),
    ('520414', '5204', 'Montong Gading', 14, true),
    ('520415', '5204', 'Terara', 15, true),
    ('520416', '5204', 'Sambelia', 16, true)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- Seed ref_desa (Pringgabaya)
  -- ============================================================
  INSERT INTO public.ref_desa (kode, kode_kecamatan, nama, jenis, kode_pos, urutan, aktif)
  VALUES
    ('5204011001', '520401', 'Seruni Mumbul', 'Desa', '83654', 1, true),
    ('5204011002', '520401', 'Pringgabaya', 'Desa', '83654', 2, true),
    ('5204011003', '520401', 'Lombok', 'Desa', '83654', 3, true),
    ('5204011004', '520401', 'Selaparang', 'Desa', '83654', 4, true),
    ('5204011005', '520401', 'Jenggala', 'Desa', '83654', 5, true)
  ON CONFLICT (kode) DO NOTHING;

  -- ============================================================
  -- Seed ref_dusun from existing wilayah_dusun
  -- ============================================================
  _seq := 1;
  FOR _seq IN 1..100 LOOP
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.wilayah_dusun wd
      WHERE NOT EXISTS (
        SELECT 1 FROM public.ref_dusun rd WHERE rd.nama = wd.nama
      )
    );
    BEGIN
      INSERT INTO public.ref_dusun (kode, nama, urutan, aktif)
      SELECT
        'DSN-' || LPAD(_seq::TEXT, 3, '0'),
        wd.nama,
        wd.urutan,
        true
      FROM public.wilayah_dusun wd
      WHERE NOT EXISTS (SELECT 1 FROM public.ref_dusun rd WHERE rd.nama = wd.nama)
      LIMIT 1;
      IF NOT FOUND THEN EXIT; END IF;
      _seq := _seq + 1;
    END;
  END LOOP;

  RAISE NOTICE 'ref tables created and seeded';

  -- ============================================================
  -- Add FK columns to penduduk
  -- ============================================================
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS provinsi_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS kabupaten_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS kecamatan_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS desa_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS dusun_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS rw_id UUID;
  ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS rt_id UUID;

  -- ============================================================
  -- Add FK constraints
  -- ============================================================
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_provinsi
    FOREIGN KEY (provinsi_id) REFERENCES public.ref_provinsi(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_kabupaten
    FOREIGN KEY (kabupaten_id) REFERENCES public.ref_kabupaten(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_kecamatan
    FOREIGN KEY (kecamatan_id) REFERENCES public.ref_kecamatan(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_desa
    FOREIGN KEY (desa_id) REFERENCES public.ref_desa(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_dusun
    FOREIGN KEY (dusun_id) REFERENCES public.ref_dusun(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_rw
    FOREIGN KEY (rw_id) REFERENCES public.ref_rw(id) DEFERRABLE INITIALLY DEFERRED;
  ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_rt
    FOREIGN KEY (rt_id) REFERENCES public.ref_rt(id) DEFERRABLE INITIALLY DEFERRED;

  -- ============================================================
  -- Backfill FK IDs from existing penduduk data
  -- ============================================================
  SELECT id INTO _provinsi_id FROM public.ref_provinsi WHERE kode = '52';
  SELECT id INTO _kabupaten_id FROM public.ref_kabupaten WHERE kode = '5204';
  SELECT id INTO _kecamatan_id FROM public.ref_kecamatan WHERE kode = '520401';
  SELECT id INTO _desa_id FROM public.ref_desa WHERE kode = '5204011001';

  RAISE NOTICE 'Provinsi ID: % | Kabupaten ID: % | Kecamatan ID: % | Desa ID: %',
    _provinsi_id, _kabupaten_id, _kecamatan_id, _desa_id;

  -- Backfill dusun_id by matching nama
  UPDATE public.penduduk p
  SET dusun_id = d.id
  FROM public.ref_dusun d
  WHERE p.dusun IS NOT NULL AND p.dusun = d.nama AND p.dusun_id IS NULL;

  -- Backfill static hierarchy (Seruni Mumbul context)
  UPDATE public.penduduk
  SET
    provinsi_id = COALESCE(provinsi_id, _provinsi_id),
    kabupaten_id = COALESCE(kabupaten_id, _kabupaten_id),
    kecamatan_id = COALESCE(kecamatan_id, _kecamatan_id),
    desa_id = COALESCE(desa_id, _desa_id)
  WHERE tenant_id IS NOT NULL;

  RAISE NOTICE 'FK backfill complete';

  -- ============================================================
  -- Create indexes
  -- ============================================================
  CREATE INDEX IF NOT EXISTS idx_penduduk_provinsi ON public.penduduk(provinsi_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_kabupaten ON public.penduduk(kabupaten_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_kecamatan ON public.penduduk(kecamatan_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_desa ON public.penduduk(desa_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_dusun_fk ON public.penduduk(dusun_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_rw ON public.penduduk(rw_id);
  CREATE INDEX IF NOT EXISTS idx_penduduk_rt ON public.penduduk(rt_id);

  -- Indexes on ref tables
  CREATE INDEX IF NOT EXISTS idx_kabupaten_provinsi ON public.ref_kabupaten(kode_provinsi);
  CREATE INDEX IF NOT EXISTS idx_kecamatan_kabupaten ON public.ref_kecamatan(kode_kabupaten);
  CREATE INDEX IF NOT EXISTS idx_desa_kecamatan ON public.ref_desa(kode_kecamatan);
  CREATE INDEX IF NOT EXISTS idx_rw_desa ON public.ref_rw(kode_desa);
  CREATE INDEX IF NOT EXISTS idx_rt_rw ON public.ref_rt(kode_rw);

END $outer$;
