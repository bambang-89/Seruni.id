-- ============================================================
-- MIGRATION: 20260802000001_surat_dna_fields.sql
-- Tanggal: 2026-08-02
-- Deskripsi:
--   Sistem DNA (Data Necara Administration) untuk surat desa
--   - Definisi field DNA per jenis surat
--   - Penyimpanan data DNA per pengajuan
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'surat_jenis_dna') THEN

    -- ============================================================
    -- 1. TABEL SURAT_JENIS_DNA - Definisi field DNA per jenis surat
    -- ============================================================
    CREATE TABLE public.surat_jenis_dna (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
      jenis_surat_id UUID REFERENCES public.surat_jenis(id) ON DELETE CASCADE,
      kode_surat TEXT NOT NULL,

      -- Field definition
      field_name TEXT NOT NULL,
      label TEXT NOT NULL,
      tipe TEXT NOT NULL DEFAULT 'text' CHECK (tipe IN (
        'text', 'textarea', 'number', 'date', 'select', 'checkbox', 'file', 'phone', 'email'
      )),
      placeholder TEXT,
      help_text TEXT,
      options JSONB,
      default_value TEXT,
      validation_pattern TEXT,
      min_length INT,
      max_length INT,
      min_value NUMERIC,
      max_value NUMERIC,

      -- Konfigurasi
      wajib BOOLEAN DEFAULT false,
      grup TEXT,
      urutan INT DEFAULT 0,
      tampil_di_cetak BOOLEAN DEFAULT true,
      label_cetak TEXT,

      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

      UNIQUE(jenis_surat_id, field_name)
    );

    -- Indexes
    CREATE INDEX idx_surat_jenis_dna_jenis ON public.surat_jenis_dna(jenis_surat_id);
    CREATE INDEX idx_surat_jenis_dna_urutan ON public.surat_jenis_dna(jenis_surat_id, urutan);

    -- Grants
    GRANT SELECT ON public.surat_jenis_dna TO anon, authenticated;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_jenis_dna TO authenticated;
    GRANT ALL ON public.surat_jenis_dna TO service_role;

    -- RLS
    ALTER TABLE public.surat_jenis_dna ENABLE ROW LEVEL SECURITY;
    DO $$
    BEGIN
      CREATE POLICY "surat_jenis_dna_public_read" ON public.surat_jenis_dna FOR SELECT TO authenticated USING (true);
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;
    DO $$
    BEGIN
      CREATE POLICY "surat_jenis_dna_admin_write" ON public.surat_jenis_dna FOR ALL TO authenticated
        USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    -- Trigger
    DO $$
    BEGIN
      CREATE TRIGGER trg_surat_jenis_dna_updated BEFORE UPDATE ON public.surat_jenis_dna
        FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    RAISE NOTICE 'Created table: surat_jenis_dna';
  ELSE
    RAISE NOTICE 'Table surat_jenis_dna already exists, skipping';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'surat_ajuan_data') THEN

    -- ============================================================
    -- 2. TABEL SURAT_AJUAN_DATA - Data DNA yang diinput pemohon
    -- ============================================================
    CREATE TABLE public.surat_ajuan_data (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
      surat_ajuan_id UUID NOT NULL REFERENCES public.surat_ajuan(id) ON DELETE CASCADE,
      penduduk_id UUID REFERENCES public.penduduk(id) ON DELETE SET NULL,

      -- Data DNA dalam JSONB
      data_dna JSONB NOT NULL DEFAULT '{}'::jsonb,

      -- Metadata verifikasi
      verified BOOLEAN DEFAULT false,
      verified_by UUID REFERENCES auth.users(id),
      verified_at TIMESTAMPTZ,
      verification_notes TEXT,

      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

      UNIQUE(surat_ajuan_id)
    );

    -- Indexes
    CREATE INDEX idx_surat_ajuan_data_surat ON public.surat_ajuan_data(surat_ajuan_id);
    CREATE INDEX idx_surat_ajuan_data_penduduk ON public.surat_ajuan_data(penduduk_id);

    -- Grants
    GRANT SELECT ON public.surat_ajuan_data TO anon, authenticated;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_ajuan_data TO authenticated;
    GRANT ALL ON public.surat_ajuan_data TO service_role;

    -- RLS
    ALTER TABLE public.surat_ajuan_data ENABLE ROW LEVEL SECURITY;
    DO $$
    BEGIN
      CREATE POLICY "surat_ajuan_data_public_read" ON public.surat_ajuan_data FOR SELECT TO authenticated USING (true);
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;
    DO $$
    BEGIN
      CREATE POLICY "surat_ajuan_data_admin_write" ON public.surat_ajuan_data FOR ALL TO authenticated
        USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    -- Trigger
    DO $$
    BEGIN
      CREATE TRIGGER trg_surat_ajuan_data_updated BEFORE UPDATE ON public.surat_ajuan_data
        FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    RAISE NOTICE 'Created table: surat_ajuan_data';
  ELSE
    RAISE NOTICE 'Table surat_ajuan_data already exists, skipping';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'surat_terbit_data') THEN

    -- ============================================================
    -- 3. TABEL SURAT_TERBIT_DATA - Data DNA untuk surat yang terbit
    -- ============================================================
    CREATE TABLE public.surat_terbit_data (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
      surat_terbit_id UUID NOT NULL REFERENCES public.surat_terbit(id) ON DELETE CASCADE,
      penduduk_id UUID REFERENCES public.penduduk(id) ON DELETE SET NULL,

      -- Data DNA dalam JSONB (copy dari surat_ajuan_data saat TTE)
      data_dna JSONB NOT NULL DEFAULT '{}'::jsonb,

      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

      UNIQUE(surat_terbit_id)
    );

    -- Indexes
    CREATE INDEX idx_surat_terbit_data_terbit ON public.surat_terbit_data(surat_terbit_id);
    CREATE INDEX idx_surat_terbit_data_penduduk ON public.surat_terbit_data(penduduk_id);

    -- Grants
    GRANT SELECT ON public.surat_terbit_data TO authenticated;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_terbit_data TO authenticated;
    GRANT ALL ON public.surat_terbit_data TO service_role;

    -- RLS
    ALTER TABLE public.surat_terbit_data ENABLE ROW LEVEL SECURITY;
    DO $$
    BEGIN
      CREATE POLICY "surat_terbit_data_admin_read" ON public.surat_terbit_data FOR SELECT TO authenticated
        USING (public.has_role(auth.uid(), 'admin'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;
    DO $$
    BEGIN
      CREATE POLICY "surat_terbit_data_admin_write" ON public.surat_terbit_data FOR ALL TO authenticated
        USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    -- Trigger
    DO $$
    BEGIN
      CREATE TRIGGER trg_surat_terbit_data_updated BEFORE UPDATE ON public.surat_terbit_data
        FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
    EXCEPTION WHEN OTHERS THEN NULL;
    END $$;

    RAISE NOTICE 'Created table: surat_terbit_data';
  ELSE
    RAISE NOTICE 'Table surat_terbit_data already exists, skipping';
  END IF;
END $$;

-- ============================================================
-- 4. FUNCTION: Get DNA Fields untuk jenis surat
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_surat_dna_fields(p_jenis_surat_id UUID)
RETURNS TABLE (
  id UUID,
  field_name TEXT,
  label TEXT,
  tipe TEXT,
  placeholder TEXT,
  help_text TEXT,
  options JSONB,
  wajib BOOLEAN,
  grup TEXT,
  urutan INT,
  tampil_di_cetak BOOLEAN,
  label_cetak TEXT,
  validation_pattern TEXT,
  min_length INT,
  max_length INT,
  min_value NUMERIC,
  max_value NUMERIC
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    id,
    field_name,
    label,
    tipe,
    placeholder,
    help_text,
    options,
    wajib,
    grup,
    urutan,
    tampil_di_cetak,
    COALESCE(label_cetak, label) as label_cetak,
    validation_pattern,
    min_length,
    max_length,
    min_value,
    max_value
  FROM public.surat_jenis_dna
  WHERE jenis_surat_id = p_jenis_surat_id
  ORDER BY grup NULLS LAST, urutan;
$$;

GRANT EXECUTE ON FUNCTION public.get_surat_dna_fields(UUID) TO anon, authenticated;

-- ============================================================
-- 5. FUNCTION: Get DNA Data untuk surat ajuan
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_surat_ajuan_dna(p_surat_ajuan_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_data JSONB;
BEGIN
  SELECT sad.data_dna INTO v_data
  FROM public.surat_ajuan_data sad
  WHERE sad.surat_ajuan_id = p_surat_ajuan_id;

  RETURN COALESCE(v_data, '{}'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_surat_ajuan_dna(UUID) TO anon, authenticated;

-- ============================================================
-- 6. SEED DNA FIELDS untuk beberapa jenis surat utama
-- ============================================================
DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found! Run seed first.';
  END IF;

  -- ============================================================
  -- A. SURAT KETERANGAN DOMISILI (474.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.0', 'alamat_domisili', 'Alamat Domisili', 'textarea', 'Jl. ... RT/RW ...', true, 'Domisili', 1, 'Alamat lengkap saat ini'),
      (v_tenant_id, v_jenis, '474.0', 'rt', 'RT', 'text', '001', true, 'Domisili', 2, 'Nomor RT'),
      (v_tenant_id, v_jenis, '474.0', 'rw', 'RW', 'text', '001', true, 'Domisili', 3, 'Nomor RW'),
      (v_tenant_id, v_jenis, '474.0', 'dusun', 'Dusun', 'text', 'Dusun ...', true, 'Domisili', 4, 'Nama dusun'),
      (v_tenant_id, v_jenis, '474.0', 'sejak_tanggal', 'Domisili Sejak Tanggal', 'date', '', false, 'Domisili', 5, 'Tanggal mulai domisili di alamat ini'),
      (v_tenant_id, v_jenis, '474.0', 'tujuan', 'Tujuan / Keperluan', 'textarea', 'Untuk keperluan ...', true, 'Keperluan', 10, 'Tujuan pembuatan surat')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- B. SURAT KETERANGAN PINDAH DOMISILI (475.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.0', 'alamat_tujuan', 'Alamat Tujuan', 'textarea', 'Jl. ... RT/RW ...', true, 'Tujuan', 1, 'Alamat lengkap tujuan pindah'),
      (v_tenant_id, v_jenis, '475.0', 'rt_tujuan', 'RT Tujuan', 'text', '001', true, 'Tujuan', 2, NULL),
      (v_tenant_id, v_jenis, '475.0', 'rw_tujuan', 'RW Tujuan', 'text', '001', true, 'Tujuan', 3, NULL),
      (v_tenant_id, v_jenis, '475.0', 'kab_kota_tujuan', 'Kabupaten/Kota Tujuan', 'text', 'Kabupaten Lombok Timur', true, 'Tujuan', 4, NULL),
      (v_tenant_id, v_jenis, '475.0', 'kec_tujuan', 'Kecamatan Tujuan', 'text', 'Kecamatan Pringgabaya', true, 'Tujuan', 5, NULL),
      (v_tenant_id, v_jenis, '475.0', 'desa_tujuan', 'Desa/Kelurahan Tujuan', 'text', 'Desa ...', true, 'Tujuan', 6, NULL),
      (v_tenant_id, v_jenis, '475.0', 'alasan_pindah', 'Alasan Pindah', 'textarea', 'Alasan ...', true, 'Pindah', 10, NULL),
      (v_tenant_id, v_jenis, '475.0', 'anggota_pindah', 'Daftar Anggota Pindah', 'textarea', '1. Nama - NIK - Hubungan%n2. ...', false, 'Pindah', 11, 'Daftar anggota keluarga yang ikut pindah'),
      (v_tenant_id, v_jenis, '475.0', 'no_surat_pindah_lama', 'No. Surat Pindah Lama', 'text', '', false, 'Pindah', 12, 'Jika ada surat pindah sebelumnya')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- C. SURAT KETERANGAN USAHA / SKU (510.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '510.0', 'nama_usaha', 'Nama Usaha', 'text', 'Warung Seruni', true, 'Usaha', 1, 'Nama dagang / usaha', NULL),
      (v_tenant_id, v_jenis, '510.0', 'jenis_bidang', 'Jenis Bidang Usaha', 'select', '', true, 'Usaha', 2, 'Sektor usaha', '["Perdagangan","Industri","Jasa","Pertanian","Peternakan","Perikanan","Kehutanan","Pertambangan","Konstruksi","Transportasi","Lainnya"]'::jsonb),
      (v_tenant_id, v_jenis, '510.0', 'komoditas', 'Komoditas / Produk Utama', 'text', 'Makanan, Minuman, Sembako', false, 'Usaha', 3, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'alamat_usaha', 'Alamat Usaha', 'textarea', 'Jl. ... RT/RW ...', true, 'Usaha', 4, 'Lokasi usaha lengkap', NULL),
      (v_tenant_id, v_jenis, '510.0', 'rt_usaha', 'RT', 'text', '001', true, 'Usaha', 5, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'rw_usaha', 'RW', 'text', '001', true, 'Usaha', 6, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'berdiri_sejak', 'Berdiri Sejak', 'date', '', false, 'Usaha', 7, 'Tanggal mulai usaha', NULL),
      (v_tenant_id, v_jenis, '510.0', 'jumlah_karyawan', 'Jumlah Karyawan', 'number', '0', false, 'Usaha', 8, 'Jumlah tenaga kerja', NULL),
      (v_tenant_id, v_jenis, '510.0', 'keperluan', 'Keperluan', 'textarea', 'Untuk pengajuan kredit / tender / dll', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- D. SURAT KETERANGAN KEMATIAN (477.4)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.4', 'nik_almarhum', 'NIK Almarhum/Almarhumah', 'text', '5201010101010001', true, 'Data', 1, 'Nomor NIK yang tertera di KTP'),
      (v_tenant_id, v_jenis, '477.4', 'nama_almarhum', 'Nama Lengkap', 'text', '', true, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tanggal_meninggal', 'Tanggal Meninggal', 'date', '', true, 'Kematian', 10, NULL),
      (v_tenant_id, v_jenis, '477.4', 'hari_meninggal', 'Hari Meninggal', 'text', 'Senin/Selasa/...', true, 'Kematian', 11, NULL),
      (v_tenant_id, v_jenis, '477.4', 'pukul_meninggal', 'Pukul (Waktu)', 'text', '14.00 WITA', false, 'Kematian', 12, NULL),
      (v_tenant_id, v_jenis, '477.4', 'sebab_meninggal', 'Sebab Meninggal', 'textarea', 'Sakit tua/ Kecelakaan/ Lainnya', true, 'Kematian', 13, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tempat_meninggal', 'Tempat Meninggal', 'text', 'Rumah Sakit/ Rumah/ Lainnya', true, 'Kematian', 14, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tempat_pemakaman', 'Tempat Pemakaman', 'text', '', true, 'Kematian', 15, NULL),
      (v_tenant_id, v_jenis, '477.4', 'no_akta_kematian', 'No. Akta Kematian', 'text', '', false, 'Kematian', 16, 'Diisi setelah ada akta kematian dari Dukcapil'),
      (v_tenant_id, v_jenis, '477.4', 'yang_melaporkan', 'Yang Melaporkan', 'text', '', true, 'Pelapor', 20, 'Nama pelapor'),
      (v_tenant_id, v_jenis, '477.4', 'hub_pelapor', 'Hubungan dengan Almarhum', 'text', '', true, 'Pelapor', 21, 'Contoh: Anak, Istri, Suami, etc')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- E. SURAT KETERANGAN KELAHIRAN (477.3)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '477.3', 'nama_bayi', 'Nama Bayi', 'text', '', true, 'Bayi', 1, 'Kosongkan jika belum diberi nama', NULL),
      (v_tenant_id, v_jenis, '477.3', 'jenis_kelamin_bayi', 'Jenis Kelamin', 'select', '', true, 'Bayi', 2, NULL, '["Laki-laki","Perempuan"]'::jsonb),
      (v_tenant_id, v_jenis, '477.3', 'anak_ke', 'Anak ke-', 'number', '1', true, 'Bayi', 3, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'tanggal_lahir', 'Tanggal Lahir', 'date', '', true, 'Bayi', 10, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'pukul_lahir', 'Pukul (Waktu)', 'text', '10.00 WITA', false, 'Bayi', 11, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'tempat_lahir', 'Tempat Lahir', 'text', '', true, 'Bayi', 12, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'no_akta_lahir', 'No. Akta Lahir (jika ada)', 'text', '', false, 'Bayi', 13, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ayah', 'NIK Ayah', 'text', '', true, 'Orang Tua', 20, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ayah', 'Nama Ayah', 'text', '', true, 'Orang Tua', 21, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ibu', 'NIK Ibu', 'text', '', true, 'Orang Tua', 22, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ibu', 'Nama Ibu', 'text', '', true, 'Orang Tua', 23, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'pelapor', 'Yang Melaporkan', 'text', '', true, 'Pelapor', 30, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'hub_pelapor', 'Hubungan dengan Bayi', 'text', '', true, 'Pelapor', 31, 'Contoh: Ayah, Ibu, Kakek, etc', NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- F. SURAT KETERANGAN TIDAK MAMPU / SKTM (465.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '465.0', 'penghasilan_per_bulan', 'Penghasilan per Bulan', 'number', '500000', true, 'Ekonomi', 1, 'Penghasilan kotor per bulan (Rp)', NULL),
      (v_tenant_id, v_jenis, '465.0', 'jumlah_tanggungan', 'Jumlah Tanggungan', 'number', '4', true, 'Ekonomi', 2, 'Jumlah anggota keluarga yang ditanggung', NULL),
      (v_tenant_id, v_jenis, '465.0', 'kondisi_tempat_tinggal', 'Kondisi Tempat Tinggal', 'select', '', true, 'Ekonomi', 3, NULL, '["Menumpang","Kontrak/Sewa","Milik Sendiri","Lainnya"]'::jsonb),
      (v_tenant_id, v_jenis, '465.0', 'sumber_penghasilan', 'Sumber Penghasilan', 'text', '', false, 'Ekonomi', 4, NULL, NULL),
      (v_tenant_id, v_jenis, '465.0', 'keperluan', 'Keperluan', 'textarea', 'Untuk biaya pendidikan/berobat/bantuan', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- G. SURAT KETERANGAN KEHILANGAN (474.6)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.6' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.6', 'barang_hilang', 'Barang/Dokumen yang Hilang', 'text', '', true, 'Kehilangan', 1, NULL),
      (v_tenant_id, v_jenis, '474.6', 'no_dokumen', 'Nomor Dokumen', 'text', '', false, 'Kehilangan', 2, 'No. KTP/SIM/dokumen yang hilang'),
      (v_tenant_id, v_jenis, '474.6', 'tanggal_hilang', 'Tanggal Perkiraan Hilang', 'date', '', true, 'Kehilangan', 10, NULL),
      (v_tenant_id, v_jenis, '474.6', 'lokasi_hilang', 'Lokasi Hilang', 'text', '', true, 'Kehilangan', 11, NULL),
      (v_tenant_id, v_jenis, '474.6', 'kronologi', 'Kronologi Kejadian', 'textarea', '', true, 'Kehilangan', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- H. SURAT PENGANTAR SKCK (300.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '300.0', 'ciri_fisik', 'Ciri Fisik', 'textarea', 'Tinggi: ... cm, Rambut: ..., Kulit: ..., dll', true, 'Fisik', 1, NULL),
      (v_tenant_id, v_jenis, '300.0', 'keperluan_skck', 'Keperluan SKCK', 'text', '', true, 'Keperluan', 10, 'Contoh: Melamar kerja, Membuat paspor, dll'),
      (v_tenant_id, v_jenis, '300.0', 'riwayat_pidana', 'Riwayat Pidana', 'textarea', 'Tidak ada / Jelaskan jika ada', true, 'Riwayat', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- I. SURAT KETERANGAN BELUM MENIKAH (474.7)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.7' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.7', 'nama_ayah', 'Nama Ayah Kandung', 'text', '', true, 'Orang Tua', 1, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nik_ayah', 'NIK Ayah', 'text', '', false, 'Orang Tua', 2, NULL),
      (v_tenant_id, v_jenis, '474.7', 'pekerjaan_ayah', 'Pekerjaan Ayah', 'text', '', false, 'Orang Tua', 3, NULL),
      (v_tenant_id, v_jenis, '474.7', 'alamat_ayah', 'Alamat Ayah', 'textarea', '', false, 'Orang Tua', 4, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nama_ibu', 'Nama Ibu Kandung', 'text', '', true, 'Orang Tua', 5, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nik_ibu', 'NIK Ibu', 'text', '', false, 'Orang Tua', 6, NULL),
      (v_tenant_id, v_jenis, '474.7', 'pekerjaan_ibu', 'Pekerjaan Ibu', 'text', '', false, 'Orang Tua', 7, NULL),
      (v_tenant_id, v_jenis, '474.7', 'alamat_ibu', 'Alamat Ibu', 'textarea', '', false, 'Orang Tua', 8, NULL),
      (v_tenant_id, v_jenis, '474.7', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- J. SURAT KETERANGAN AHLI WARIS (474.9)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.9' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.9', 'nama_pewaris', 'Nama Pewaris (Almarhum)', 'text', '', true, 'Pewaris', 1, NULL),
      (v_tenant_id, v_jenis, '474.9', 'nik_pewaris', 'NIK Pewaris', 'text', '', true, 'Pewaris', 2, NULL),
      (v_tenant_id, v_jenis, '474.9', 'tanggal_meninggal_pewaris', 'Tanggal Meninggal', 'date', '', true, 'Pewaris', 10, NULL),
      (v_tenant_id, v_jenis, '474.9', 'tempat_meninggal_pewaris', 'Tempat Meninggal', 'text', '', true, 'Pewaris', 11, NULL),
      (v_tenant_id, v_jenis, '474.9', 'no_akta_kematian_pewaris', 'No. Akta Kematian', 'text', '', false, 'Pewaris', 12, NULL),
      (v_tenant_id, v_jenis, '474.9', 'daftar_ahli_waris', 'Daftar Ahli Waris', 'textarea', '1. Nama - NIK - Hubungan%n2. ...', true, 'Ahli Waris', 20, 'Sesuai urutan hukum waris'),
      (v_tenant_id, v_jenis, '474.9', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  RAISE NOTICE 'DNA fields seeded successfully!';
END $$;

-- ============================================================
-- 7. VERIFIKASI
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '=== Surat DNA System Migration Complete ===';
  RAISE NOTICE 'Created tables:';
  RAISE NOTICE '  - surat_jenis_dna (definisi field DNA)';
  RAISE NOTICE '  - surat_ajuan_data (data DNA pengajuan)';
  RAISE NOTICE '  - surat_terbit_data (data DNA surat terbit)';
  RAISE NOTICE 'Created functions:';
  RAISE NOTICE '  - get_surat_dna_fields(jenis_surat_id)';
  RAISE NOTICE '  - get_surat_ajuan_dna(surat_ajuan_id)';
  RAISE NOTICE 'Seeded DNA fields for:';
  RAISE NOTICE '  - 474.0 Surat Keterangan Domisili';
  RAISE NOTICE '  - 475.0 Surat Keterangan Pindah Domisili';
  RAISE NOTICE '  - 510.0 Surat Keterangan Usaha (SKU)';
  RAISE NOTICE '  - 477.4 Surat Keterangan Kematian';
  RAISE NOTICE '  - 477.3 Surat Keterangan Kelahiran';
  RAISE NOTICE '  - 465.0 Surat Keterangan Tidak Mampu (SKTM)';
  RAISE NOTICE '  - 474.6 Surat Keterangan Kehilangan';
  RAISE NOTICE '  - 300.0 Surat Pengantar SKCK';
  RAISE NOTICE '  - 474.7 Surat Keterangan Belum Menikah';
  RAISE NOTICE '  - 474.9 Surat Keterangan Ahli Waris';
END $$;

-- Verify counts
SELECT 'surat_jenis_dna' as table_name, count(*) as count FROM public.surat_jenis_dna
UNION ALL
SELECT 'surat_ajuan_data' as table_name, count(*) as count FROM public.surat_ajuan_data
UNION ALL
SELECT 'surat_terbit_data' as table_name, count(*) as count FROM public.surat_terbit_data;
