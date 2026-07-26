-- ============================================================
-- MIGRATION: 20260731000001_surat_template_system.sql
-- Tanggal: 2026-07-31
-- Deskripsi:
--   1. Tabel surat_template - Template KOP & desain surat
--   2. Sistem preview surat dengan template
--   3. Update surat_terbit dengan template_id
-- ============================================================

-- ============================================================
-- 1. TABEL JENIS SURAT (sudah ada, tapi kita tambah kolom)
-- ============================================================
ALTER TABLE public.surat_jenis
  ADD COLUMN IF NOT EXISTS template_id UUID,
  ADD COLUMN IF NOT EXISTS kode_surat VARCHAR(20),
  ADD COLUMN IF NOT EXISTS "format" VARCHAR(50) DEFAULT 'standard'
    CHECK ("format" IN ('standard', 'legal', 'a4', 'custom')),
  ADD COLUMN IF NOT EXISTS requires_signature BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS requires_stamp BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS qr_code_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS qr_code_label VARCHAR(100);

-- ============================================================
-- 2. TABEL SURAT TEMPLATE (Template KOP & desain surat)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.surat_template (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  nama VARCHAR(200) NOT NULL,
  kode VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,

  -- Header (KOP Surat)
  header_enabled BOOLEAN DEFAULT true,
  header_height INT DEFAULT 120, -- pixel
  header_background_color VARCHAR(20) DEFAULT '#FFFFFF',
  header_background_image TEXT,
  header_border_bottom_enabled BOOLEAN DEFAULT true,
  header_border_bottom_color VARCHAR(20) DEFAULT '#000000',
  header_border_bottom_style VARCHAR(20) DEFAULT 'solid',
  header_border_bottom_width INT DEFAULT 2,

  -- Logo Kiri
  logo_kiri_url TEXT,
  logo_kiri_width INT DEFAULT 60,
  logo_kiri_height INT DEFAULT 60,
  logo_kiri_position VARCHAR(20) DEFAULT 'left', -- left, center, right
  logo_kiri_visible BOOLEAN DEFAULT true,

  -- Logo Kanan
  logo_kanan_url TEXT,
  logo_kanan_width INT DEFAULT 60,
  logo_kanan_height INT DEFAULT 60,
  logo_kanan_position VARCHAR(20) DEFAULT 'right',
  logo_kanan_visible BOOLEAN DEFAULT true,

  -- Judul Instansi
  judul_instansi_enabled BOOLEAN DEFAULT true,
  judul_instansi_text VARCHAR(255) DEFAULT 'PEMERINTAH KABUPATEN LOMBOK TIMUR',
  judul_instansi_font_size INT DEFAULT 14,
  judul_instansi_font_weight VARCHAR(20) DEFAULT 'bold',
  judul_instansi_text_align VARCHAR(20) DEFAULT 'center',

  sub_judul_instansi_text VARCHAR(255) DEFAULT 'KECAMATAN PRINGGABAYA',
  sub_judul_font_size INT DEFAULT 12,
  sub_judul_font_weight VARCHAR(20) DEFAULT 'normal',
  sub_judul_text_align VARCHAR(20) DEFAULT 'center',

  nama_desa_text VARCHAR(255) DEFAULT 'DESA SERUNI MUMBUL',
  nama_desa_font_size INT DEFAULT 16,
  nama_desa_font_weight VARCHAR(20) DEFAULT 'bold',
  nama_desa_text_align VARCHAR(20) DEFAULT 'center',

  alamat_desa_text TEXT DEFAULT 'Jl. Raya Seruni Mumbul, Pringgabaya, Lombok Timur 83654',
  alamat_font_size INT DEFAULT 10,
  alamat_text_align VARCHAR(20) DEFAULT 'center',

  telepon_text VARCHAR(255),
  fax_text VARCHAR(255),
  email_text VARCHAR(255),
  website_text VARCHAR(255),

  -- Garis Pembatas
  garis_enabled BOOLEAN DEFAULT true,
  garis_color VARCHAR(20) DEFAULT '#000000',
  garis_height INT DEFAULT 2,
  garis_style VARCHAR(20) DEFAULT 'solid', -- solid, dashed, double

  -- Nomor Surat
  nomor_surat_enabled BOOLEAN DEFAULT true,
  nomor_surat_label VARCHAR(50) DEFAULT 'Nomor',
  nomor_surat_format VARCHAR(100) DEFAULT '{{kode_surat}}/{{nomor}}/{{bulan_romawi}}/{{tahun}}',
  nomor_surat_font_size INT DEFAULT 12,
  nomor_surat_font_weight VARCHAR(20) DEFAULT 'normal',

  -- Body Surat
  body_margin_top INT DEFAULT 30,
  body_margin_bottom INT DEFAULT 30,
  body_margin_left INT DEFAULT 40,
  body_margin_right INT DEFAULT 40,
  body_font_family VARCHAR(100) DEFAULT 'Times New Roman',
  body_font_size INT DEFAULT 12,
  body_line_height NUMERIC(4,2) DEFAULT 1.5,
  body_text_align VARCHAR(20) DEFAULT 'justify',

  -- Footer
  footer_enabled BOOLEAN DEFAULT true,
  footer_height INT DEFAULT 100,
  footer_background_color VARCHAR(20) DEFAULT '#FFFFFF',
  footer_ttd_kanan_enabled BOOLEAN DEFAULT true,
  footer_ttd_kanan_judul VARCHAR(100) DEFAULT 'Kepala Desa',
  footer_ttd_kanan_nama VARCHAR(200),
  footer_ttd_kanan_nip VARCHAR(50),
  footer_ttd_tengah_enabled BOOLEAN DEFAULT false,
  footer_ttd_tengah_text TEXT,
  footer_ttd_kiri_enabled BOOLEAN DEFAULT false,
  footer_ttd_kiri_text TEXT,

  -- QR Code
  qr_code_enabled BOOLEAN DEFAULT false,
  qr_code_position VARCHAR(20) DEFAULT 'footer_right',
  qr_code_size INT DEFAULT 80,
  qr_code_label VARCHAR(100),

  -- Tanda Tangan
  tanda_tangan_struk_enabled BOOLEAN DEFAULT true,
  tanda_tangan_struk_url TEXT,
  tanda_tangan_struk_width INT DEFAULT 100,
  tanda_tangan_struk_position VARCHAR(20) DEFAULT 'kanan',

  -- Watermark
  watermark_enabled BOOLEAN DEFAULT false,
  watermark_text VARCHAR(100) DEFAULT 'DRAFT',
  watermark_color VARCHAR(20) DEFAULT '#CCCCCC',
  watermark_font_size INT DEFAULT 60,
  watermark_opacity NUMERIC(3,2) DEFAULT 0.1,
  watermark_angle INT DEFAULT -45,

  -- Page Settings
  page_size VARCHAR(20) DEFAULT 'A4',
  page_orientation VARCHAR(20) DEFAULT 'portrait',
  page_margin_top INT DEFAULT 20,
  page_margin_bottom INT DEFAULT 20,
  page_margin_left INT DEFAULT 25,
  page_margin_right INT DEFAULT 25,

  -- JSON Template untuk placeholder
  template_json JSONB DEFAULT '{
    "kop": {
      "logo_kiri": "{{logo_url}}",
      "logo_kanan": "{{logo_url}}",
      "instansi": "{{nama_instansi}}",
      "alamat": "{{alamat_kantor}}"
    },
    "body": {
      "nomor_surat": "{{nomor_surat}}",
      "lampiran": "{{lampiran}}",
      "perihal": "{{perihal}}",
      "kepada": "{{kepada}}",
      "isi": "{{isi_surat}}",
      "penutup": "{{penutup_surat}}"
    },
    "footer": {
      "tanggal_surat": "{{tanggal_surat}}",
      "kepala_desa": "{{nama_kades}}",
      "nip_kades": "{{nip_kades}}"
    }
  }'::jsonb,

  -- Styling custom CSS/JSON
  custom_css TEXT,
  custom_styles JSONB DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.surat_template TO anon, authenticated;
GRANT ALL ON public.surat_template TO service_role;
ALTER TABLE public.surat_template ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read surat_template" ON public.surat_template;
DO $$
BEGIN
  CREATE POLICY "Public read surat_template" ON public.surat_template
    FOR SELECT TO authenticated USING (is_active = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write surat_template" ON public.surat_template;
DO $$
BEGIN
  CREATE POLICY "Admin write surat_template" ON public.surat_template
    FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.surat_template
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS nama VARCHAR(200),
  ADD COLUMN IF NOT EXISTS kode VARCHAR(50),
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS is_default BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS header_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS header_height INT DEFAULT 120,
  ADD COLUMN IF NOT EXISTS header_background_color VARCHAR(20) DEFAULT '#FFFFFF',
  ADD COLUMN IF NOT EXISTS header_background_image TEXT,
  ADD COLUMN IF NOT EXISTS header_border_bottom_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS header_border_bottom_color VARCHAR(20) DEFAULT '#000000',
  ADD COLUMN IF NOT EXISTS header_border_bottom_style VARCHAR(20) DEFAULT 'solid',
  ADD COLUMN IF NOT EXISTS header_border_bottom_width INT DEFAULT 2,
  ADD COLUMN IF NOT EXISTS logo_kiri_url TEXT,
  ADD COLUMN IF NOT EXISTS logo_kiri_width INT DEFAULT 60,
  ADD COLUMN IF NOT EXISTS logo_kiri_height INT DEFAULT 60,
  ADD COLUMN IF NOT EXISTS logo_kiri_position VARCHAR(20) DEFAULT 'left',
  ADD COLUMN IF NOT EXISTS logo_kiri_visible BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS logo_kanan_url TEXT,
  ADD COLUMN IF NOT EXISTS logo_kanan_width INT DEFAULT 60,
  ADD COLUMN IF NOT EXISTS logo_kanan_height INT DEFAULT 60,
  ADD COLUMN IF NOT EXISTS logo_kanan_position VARCHAR(20) DEFAULT 'right',
  ADD COLUMN IF NOT EXISTS logo_kanan_visible BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS judul_instansi_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS judul_instansi_text VARCHAR(255) DEFAULT 'PEMERINTAH KABUPATEN LOMBOK TIMUR',
  ADD COLUMN IF NOT EXISTS judul_instansi_font_size INT DEFAULT 14,
  ADD COLUMN IF NOT EXISTS judul_instansi_font_weight VARCHAR(20) DEFAULT 'bold',
  ADD COLUMN IF NOT EXISTS judul_instansi_text_align VARCHAR(20) DEFAULT 'center',
  ADD COLUMN IF NOT EXISTS sub_judul_instansi_text VARCHAR(255) DEFAULT 'KECAMATAN PRINGGABAYA',
  ADD COLUMN IF NOT EXISTS sub_judul_font_size INT DEFAULT 12,
  ADD COLUMN IF NOT EXISTS sub_judul_font_weight VARCHAR(20) DEFAULT 'normal',
  ADD COLUMN IF NOT EXISTS sub_judul_text_align VARCHAR(20) DEFAULT 'center',
  ADD COLUMN IF NOT EXISTS nama_desa_text VARCHAR(255) DEFAULT 'DESA SERUNI MUMBUL',
  ADD COLUMN IF NOT EXISTS nama_desa_font_size INT DEFAULT 16,
  ADD COLUMN IF NOT EXISTS nama_desa_font_weight VARCHAR(20) DEFAULT 'bold',
  ADD COLUMN IF NOT EXISTS nama_desa_text_align VARCHAR(20) DEFAULT 'center',
  ADD COLUMN IF NOT EXISTS alamat_desa_text TEXT DEFAULT 'Jl. Raya Seruni Mumbul, Pringgabaya, Lombok Timur 83654',
  ADD COLUMN IF NOT EXISTS alamat_font_size INT DEFAULT 10,
  ADD COLUMN IF NOT EXISTS alamat_text_align VARCHAR(20) DEFAULT 'center',
  ADD COLUMN IF NOT EXISTS telepon_text VARCHAR(255),
  ADD COLUMN IF NOT EXISTS fax_text VARCHAR(255),
  ADD COLUMN IF NOT EXISTS email_text VARCHAR(255),
  ADD COLUMN IF NOT EXISTS website_text VARCHAR(255),
  ADD COLUMN IF NOT EXISTS garis_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS garis_color VARCHAR(20) DEFAULT '#000000',
  ADD COLUMN IF NOT EXISTS garis_height INT DEFAULT 2,
  ADD COLUMN IF NOT EXISTS garis_style VARCHAR(20) DEFAULT 'solid',
  ADD COLUMN IF NOT EXISTS nomor_surat_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS nomor_surat_label VARCHAR(50) DEFAULT 'Nomor',
  ADD COLUMN IF NOT EXISTS nomor_surat_format VARCHAR(100) DEFAULT '{{kode_surat}}/{{nomor}}/{{bulan_romawi}}/{{tahun}}',
  ADD COLUMN IF NOT EXISTS nomor_surat_font_size INT DEFAULT 12,
  ADD COLUMN IF NOT EXISTS nomor_surat_font_weight VARCHAR(20) DEFAULT 'normal',
  ADD COLUMN IF NOT EXISTS body_margin_top INT DEFAULT 30,
  ADD COLUMN IF NOT EXISTS body_margin_bottom INT DEFAULT 30,
  ADD COLUMN IF NOT EXISTS body_margin_left INT DEFAULT 40,
  ADD COLUMN IF NOT EXISTS body_margin_right INT DEFAULT 40,
  ADD COLUMN IF NOT EXISTS body_font_family VARCHAR(100) DEFAULT 'Times New Roman',
  ADD COLUMN IF NOT EXISTS body_font_size INT DEFAULT 12,
  ADD COLUMN IF NOT EXISTS body_line_height NUMERIC(4,2) DEFAULT 1.5,
  ADD COLUMN IF NOT EXISTS body_text_align VARCHAR(20) DEFAULT 'justify',
  ADD COLUMN IF NOT EXISTS footer_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS footer_height INT DEFAULT 100,
  ADD COLUMN IF NOT EXISTS footer_background_color VARCHAR(20) DEFAULT '#FFFFFF',
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_judul VARCHAR(100) DEFAULT 'Kepala Desa',
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_nama VARCHAR(200),
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_nip VARCHAR(50),
  ADD COLUMN IF NOT EXISTS footer_ttd_tengah_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS footer_ttd_tengah_text TEXT,
  ADD COLUMN IF NOT EXISTS footer_ttd_kiri_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS footer_ttd_kiri_text TEXT,
  ADD COLUMN IF NOT EXISTS qr_code_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS qr_code_position VARCHAR(20) DEFAULT 'footer_right',
  ADD COLUMN IF NOT EXISTS qr_code_size INT DEFAULT 80,
  ADD COLUMN IF NOT EXISTS qr_code_label VARCHAR(100),
  ADD COLUMN IF NOT EXISTS tanda_tangan_struk_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS tanda_tangan_struk_url TEXT,
  ADD COLUMN IF NOT EXISTS tanda_tangan_struk_width INT DEFAULT 100,
  ADD COLUMN IF NOT EXISTS tanda_tangan_struk_position VARCHAR(20) DEFAULT 'kanan',
  ADD COLUMN IF NOT EXISTS watermark_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS watermark_text VARCHAR(100) DEFAULT 'DRAFT',
  ADD COLUMN IF NOT EXISTS watermark_color VARCHAR(20) DEFAULT '#CCCCCC',
  ADD COLUMN IF NOT EXISTS watermark_font_size INT DEFAULT 60,
  ADD COLUMN IF NOT EXISTS watermark_opacity NUMERIC(3,2) DEFAULT 0.1,
  ADD COLUMN IF NOT EXISTS watermark_angle INT DEFAULT -45,
  ADD COLUMN IF NOT EXISTS page_size VARCHAR(20) DEFAULT 'A4',
  ADD COLUMN IF NOT EXISTS page_orientation VARCHAR(20) DEFAULT 'portrait',
  ADD COLUMN IF NOT EXISTS page_margin_top INT DEFAULT 20,
  ADD COLUMN IF NOT EXISTS page_margin_bottom INT DEFAULT 20,
  ADD COLUMN IF NOT EXISTS page_margin_left INT DEFAULT 25,
  ADD COLUMN IF NOT EXISTS page_margin_right INT DEFAULT 25,
  ADD COLUMN IF NOT EXISTS template_json JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS custom_css TEXT,
  ADD COLUMN IF NOT EXISTS custom_styles JSONB DEFAULT '{}'::jsonb;

DROP TRIGGER IF EXISTS trg_surat_template_updated ON public.surat_template;
DO $$
BEGIN
  CREATE TRIGGER trg_surat_template_updated BEFORE UPDATE ON public.surat_template
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_surat_template_kode ON public.surat_template(kode);

-- ============================================================
-- 3. SEED DEFAULT TEMPLATE
-- ============================================================
INSERT INTO public.surat_template (
  tenant_id,
  nama,
  kode,
  description,
  is_default,
  is_active,
  logo_kiri_url,
  logo_kanan_url,
  header_enabled,
  header_height,
  header_border_bottom_enabled,
  header_border_bottom_color,
  header_border_bottom_width,
  judul_instansi_text,
  sub_judul_instansi_text,
  nama_desa_text,
  nama_desa_font_size,
  nama_desa_font_weight,
  alamat_desa_text,
  garis_enabled,
  garis_color,
  garis_height,
  nomor_surat_enabled,
  footer_ttd_kanan_enabled,
  footer_ttd_kanan_judul,
  page_size,
  page_orientation,
  page_margin_top,
  page_margin_bottom,
  page_margin_left,
  page_margin_right
) VALUES (
  (SELECT id FROM tenants WHERE subdomain = 'seruni'),
  'Template Standard Lombok Timur',
  'STD_LOMBOK_TIMUR',
  'Template surat resmi dengan format KOP Lombok Timur',
  true,
  true,
  'https://storage.googleapis.com/gpt-engineer-file-uploads/aMjanxrDoUP1QJ5krTWiqhWnSbF3/uploads/1758710472461-logo-icon-BG-circle%20copy.png',
  'https://storage.googleapis.com/gpt-engineer-file-uploads/aMjanxrDoUP1QJ5krTWiqhWnSbF3/uploads/1758710472461-logo-icon-BG-circle%20copy.png',
  true,
  100,
  true,
  '#000000',
  3,
  'PEMERINTAH KABUPATEN LOMBOK TIMUR',
  'KECAMATAN PRINGGABAYA',
  'DESA SERUNI MUMBUL',
  18,
  'bold',
  'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
  true,
  '#000000',
  2,
  true,
  true,
  'Kepala Desa Seruni Mumbul',
  'A4',
  'portrait',
  20,
  20,
  25,
  25
) ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- 4. TABEL SURAT_TERBIT - Update dengan template & preview
-- ============================================================
ALTER TABLE public.surat_terbit
  ADD COLUMN IF NOT EXISTS template_id UUID REFERENCES public.surat_template(id),
  ADD COLUMN IF NOT EXISTS preview_url TEXT,
  ADD COLUMN IF NOT EXISTS preview_generated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS status_preview VARCHAR(50) DEFAULT 'pending'
    CHECK (status_preview IN ('pending', 'generated', 'approved', 'rejected')),
  ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS rejected_reason TEXT,
  ADD COLUMN IF NOT EXISTS qr_code_url TEXT,
  ADD COLUMN IF NOT EXISTS signed_url TEXT,
  ADD COLUMN IF NOT EXISTS nomor_urut INT,
  ADD COLUMN IF NOT EXISTS tanggal_cetak TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS kop_terCustom BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS kop_custom_json JSONB;

-- Index baru
CREATE INDEX IF NOT EXISTS idx_surat_terbit_template ON public.surat_terbit(template_id);
CREATE INDEX IF NOT EXISTS idx_surat_terbit_status_preview ON public.surat_terbit(status_preview);
CREATE INDEX IF NOT EXISTS idx_surat_terbit_approved ON public.surat_terbit(approved_by);

-- ============================================================
-- 5. TABEL SURAT_AJUAN - Update dengan dokumen
-- ============================================================
ALTER TABLE public.surat_ajuan
  ADD COLUMN IF NOT EXISTS template_id UUID REFERENCES public.surat_template(id),
  ADD COLUMN IF NOT EXISTS preview_url TEXT,
  ADD COLUMN IF NOT EXISTS status_preview VARCHAR(50) DEFAULT 'pending'
    CHECK (status_preview IN ('pending', 'generated', 'viewed'));

-- ============================================================
-- 6. FUNCTION: Generate Nomor Surat Otomatis
-- ============================================================
CREATE OR REPLACE FUNCTION public.generate_nomor_surat(
  p_surat_jenis_id UUID,
  p_tahun INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)
)
RETURNS VARCHAR(100)
LANGUAGE plpgsql
AS $$
DECLARE
  v_nomor INT;
  v_prefix VARCHAR(20);
  v_bulan INT := EXTRACT(MONTH FROM CURRENT_DATE);
  v_bulan_romawi VARCHAR(10);
  v_result VARCHAR(100);
BEGIN
  -- Get prefix dari jenis_surat
  SELECT COALESCE(kode_surat, 'SURAT')
  INTO v_prefix
  FROM public.surat_jenis
  WHERE id = p_surat_jenis_id;

  -- Get next nomor urut untuk tahun ini
  SELECT COALESCE(MAX(nomor_urut), 0) + 1
  INTO v_nomor
  FROM public.surat_terbit
  WHERE EXTRACT(YEAR FROM created_at) = p_tahun;

  -- Convert bulan ke romawi
  v_bulan_romawi := CASE v_bulan
    WHEN 1 THEN 'I'
    WHEN 2 THEN 'II'
    WHEN 3 THEN 'III'
    WHEN 4 THEN 'IV'
    WHEN 5 THEN 'V'
    WHEN 6 THEN 'VI'
    WHEN 7 THEN 'VII'
    WHEN 8 THEN 'VIII'
    WHEN 9 THEN 'IX'
    WHEN 10 THEN 'X'
    WHEN 11 THEN 'XI'
    WHEN 12 THEN 'XII'
  END;

  -- Format: PREFIX/Nomor/BulanRomawi/Tahun
  v_result := v_prefix || '/' || v_nomor || '/' || v_bulan_romawi || '/' || p_tahun;

  RETURN v_result;
END;
$$;

-- ============================================================
-- 7. FUNCTION: Preview Surat
-- ============================================================
CREATE OR REPLACE FUNCTION public.generate_surat_preview(
  p_surat_terbit_id UUID,
  p_entity_type VARCHAR(50) DEFAULT 'surat_terbit'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_record RECORD;
  v_template RECORD;
  v_result JSONB;
  v_penduduk RECORD;
  v_data JSONB;
BEGIN
  -- Get surat record
  SELECT st.*, js.nama as jenis_surat_nama, js.kode as jenis_surat_kode
  INTO v_record
  FROM public.surat_terbit st
  JOIN public.surat_jenis js ON st.jenis_nama = js.nama
  WHERE st.id = p_surat_terbit_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Surat tidak ditemukan';
  END IF;

  -- Get template
  SELECT *
  INTO v_template
  FROM public.surat_template
  WHERE id = v_record.template_id OR is_default = true
  ORDER BY CASE WHEN id = v_record.template_id THEN 0 ELSE 1 END
  LIMIT 1;

  IF NOT FOUND THEN
    -- Use default inline template
    v_template := ROW(
      NULL, NULL, 'Default', 'DEFAULT', NULL, true, true,
      true, 100, '#FFFFFF', NULL, true, '#000000', 'solid', 2,
      NULL, 60, 60, 'left', true,
      NULL, 60, 60, 'right', true,
      true, 'PEMERINTAH KABUPATEN LOMBOK TIMUR', 14, 'bold', 'center',
      'KECAMATAN PRINGGABAYA', 12, 'normal', 'center',
      'DESA SERUNI MUMBUL', 18, 'bold', 'center',
      'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654', 10, 'center',
      NULL, NULL, NULL, NULL,
      true, '#000000', 2,
      true, 'Nomor', NULL, 12, 'normal',
      30, 30, 40, 40, 'Times New Roman', 12, 1.5, 'justify',
      true, 100, '#FFFFFF', true, 'Kepala Desa', NULL, NULL,
      false, NULL, false, NULL,
      false, 80, NULL,
      true, NULL, 100, 'kanan',
      false, 'DRAFT', '#CCCCCC', 60, 0.1, -45,
      'A4', 'portrait', 20, 20, 25, 25,
      NULL, NULL, '{}'::jsonb,
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    )::public.surat_template;
  END IF;

  -- Get penduduk data if exists
  IF v_record.penduduk_id IS NOT NULL THEN
    SELECT p.*, k.no_kk, k.alamat as alamat_kk
    INTO v_penduduk
    FROM public.penduduk p
    LEFT JOIN public.keluarga k ON p.keluarga_id = k.id
    WHERE p.id = v_record.penduduk_id;
  END IF;

  -- Build preview data
  v_data := jsonb_build_object(
    'surat_id', v_record.id,
    'nomor_surat', v_record.nomor_surat,
    'jenis_surat', v_record.jenis_surat_nama,
    'tanggal_surat', v_record.tanggal_terbit,
    'tanggal_cetak', CURRENT_TIMESTAMP,

    'penduduk', CASE WHEN v_penduduk IS NOT NULL THEN jsonb_build_object(
      'nama', v_penduduk.nama,
      'nik', v_penduduk.nik,
      'tempat_lahir', v_penduduk.tempat_lahir,
      'tanggal_lahir', v_penduduk.tanggal_lahir,
      'jenis_kelamin', v_penduduk.jenis_kelamin,
      'alamat', COALESCE(v_penduduk.alamat, v_penduduk.alamat_kk),
      'pekerjaan', v_penduduk.pekerjaan,
      'agama', v_penduduk.agama,
      'status_kawin', v_penduduk.status_kawin,
      'no_kk', v_penduduk.no_kk,
      'foto_url', v_penduduk.foto_url
    ) ELSE NULL END,

    'template', jsonb_build_object(
      'kop', jsonb_build_object(
        'logo_kiri_url', v_template.logo_kiri_url,
        'logo_kanan_url', v_template.logo_kanan_url,
        'instansi', v_template.judul_instansi_text,
        'sub_instansi', v_template.sub_judul_instansi_text,
        'nama_desa', v_template.nama_desa_text,
        'alamat', v_template.alamat_desa_text
      ),
      'header', jsonb_build_object(
        'height', v_template.header_height,
        'background_color', v_template.header_background_color,
        'border_bottom_enabled', v_template.header_border_bottom_enabled,
        'border_bottom_style', v_template.header_border_bottom_style,
        'border_bottom_width', v_template.header_border_bottom_width
      ),
      'footer', jsonb_build_object(
        'ttd_kanan_enabled', v_template.footer_ttd_kanan_enabled,
        'ttd_kanan_judul', v_template.footer_ttd_kanan_judul
      )
    )
  );

  -- Update surat status
  UPDATE public.surat_terbit
  SET status_preview = 'generated',
      preview_generated_at = CURRENT_TIMESTAMP,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_surat_terbit_id;

  RETURN v_data;
END;
$$;

-- ============================================================
-- 8. LOG
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '=== Surat Template System Migration Complete ===';
  RAISE NOTICE 'Created tables:';
  RAISE NOTICE '  - surat_template (KOP & desain surat)';
  RAISE NOTICE 'Updated tables:';
  RAISE NOTICE '  - jenis_surat (template_id, kode_surat, dll)';
  RAISE NOTICE '  - surat_terbit (preview_url, status_preview, dll)';
  RAISE NOTICE '  - surat_ajuan (template_id, preview_url)';
  RAISE NOTICE 'Created functions:';
  RAISE NOTICE '  - generate_nomor_surat()';
  RAISE NOTICE '  - generate_surat_preview()';
END $$;
