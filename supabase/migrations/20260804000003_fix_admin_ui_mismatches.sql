-- Migration: 20260804000003_fix_admin_ui_mismatches.sql
-- Fixes database columns to match frontend UI configurations
-- Created based on UI vs Database mismatch analysis

-- ============================================================
-- 1. PAMONG - Add foto_url column
-- ============================================================
ALTER TABLE public.desa_pamong
  ADD COLUMN IF NOT EXISTS foto_url TEXT;

COMMENT ON COLUMN public.desa_pamong.foto_url IS 'URL foto pejabat desa';

-- ============================================================
-- 2. BERITA - Add cover_url column
-- ============================================================
ALTER TABLE public.berita
  ADD COLUMN IF NOT EXISTS cover_url TEXT;

COMMENT ON COLUMN public.berita.cover_url IS 'URL gambar cover artikel';

-- ============================================================
-- 3. BALITA - Add nik_anak and nama_ortu columns
-- ============================================================
ALTER TABLE public.balita
  ADD COLUMN IF NOT EXISTS nik_anak VARCHAR(16),
  ADD COLUMN IF NOT EXISTS nama_ortu TEXT;

COMMENT ON COLUMN public.balita.nik_anak IS 'NIK anak';
COMMENT ON COLUMN public.balita.nama_ortu IS 'Nama orang tua/wali';

-- ============================================================
-- 4. WA_CHATBOT_SESSION - Add missing columns for UI compatibility
-- ============================================================
ALTER TABLE public.wa_chatbot_session
  ADD COLUMN IF NOT EXISTS phone_number TEXT,
  ADD COLUMN IF NOT EXISTS intent TEXT,
  ADD COLUMN IF NOT EXISTS last_message TEXT,
  ADD COLUMN IF NOT EXISTS chat_status VARCHAR(20) DEFAULT 'active';

COMMENT ON COLUMN public.wa_chatbot_session.phone_number IS 'Nomor WhatsApp (alias nomor_wa)';
COMMENT ON COLUMN public.wa_chatbot_session.intent IS 'Intent terakhir yang dikenali';
COMMENT ON COLUMN public.wa_chatbot_session.last_message IS 'Pesan terakhir dari user';
COMMENT ON COLUMN public.wa_chatbot_session.chat_status IS 'Status chat: active, resolved, closed';

-- Create trigger to sync new columns with existing data
CREATE OR REPLACE FUNCTION sync_wa_chatbot_session_columns()
RETURNS TRIGGER AS $$
BEGIN
  -- Sync phone_number from nomor_wa if phone_number is null
  IF NEW.phone_number IS NULL AND NEW.nomor_wa IS NOT NULL THEN
    NEW.phone_number := NEW.nomor_wa;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_wa_chatbot_session ON public.wa_chatbot_session;
CREATE TRIGGER sync_wa_chatbot_session
  BEFORE INSERT OR UPDATE ON public.wa_chatbot_session
  FOR EACH ROW
  EXECUTE FUNCTION sync_wa_chatbot_session_columns();

-- ============================================================
-- 5. IDM_INDIKATOR - Add correct column names (rename strategy)
-- ============================================================
-- First check if columns exist with wrong names, add correct ones
ALTER TABLE public.idm_indikator
  ADD COLUMN IF NOT EXISTS dimensi_nama TEXT,
  ADD COLUMN IF NOT EXISTS indikator_nama TEXT,
  ADD COLUMN IF NOT EXISTS sumber_data TEXT;

COMMENT ON COLUMN public.idm_indikator.dimensi_nama IS 'Nama dimensi IDM';
COMMENT ON COLUMN public.idm_indikator.indikator_nama IS 'Nama indikator';
COMMENT ON COLUMN public.idm_indikator.sumber_data IS 'Sumber data';

-- Create function to sync columns (bidirectional)
CREATE OR REPLACE FUNCTION sync_idm_indikator_columns()
RETURNS TRIGGER AS $$
BEGIN
  -- Sync dimensi_nama from dimensi if dimensi_nama is null
  IF NEW.dimensi_nama IS NULL AND NEW.dimensi IS NOT NULL THEN
    NEW.dimensi_nama := NEW.dimensi;
  END IF;
  -- Sync dimensi from dimensi_nama if dimensi is null
  IF NEW.dimensi IS NULL AND NEW.dimensi_nama IS NOT NULL THEN
    NEW.dimensi := NEW.dimensi_nama;
  END IF;
  -- Sync indikator_nama from indikator if indikator_nama is null
  IF NEW.indikator_nama IS NULL AND NEW.indikator IS NOT NULL THEN
    NEW.indikator_nama := NEW.indikator;
  END IF;
  -- Sync indikator from indikator_nama if indikator is null
  IF NEW.indikator IS NULL AND NEW.indikator_nama IS NOT NULL THEN
    NEW.indikator := NEW.indikator_nama;
  END IF;
  -- Sync sumber_data from sumber if sumber_data is null
  IF NEW.sumber_data IS NULL AND NEW.sumber IS NOT NULL THEN
    NEW.sumber_data := NEW.sumber;
  END IF;
  -- Sync sumber from sumber_data if sumber is null
  IF NEW.sumber IS NULL AND NEW.sumber_data IS NOT NULL THEN
    NEW.sumber := NEW.sumber_data;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_idm_indikator ON public.idm_indikator;
CREATE TRIGGER sync_idm_indikator
  BEFORE INSERT OR UPDATE ON public.idm_indikator
  FOR EACH ROW
  EXECUTE FUNCTION sync_idm_indikator_columns();

-- ============================================================
-- 6. SURAT_TEMPLATE - Add required columns for template designer
-- ============================================================
ALTER TABLE public.surat_template
  ADD COLUMN IF NOT EXISTS logo_kiri_url TEXT,
  ADD COLUMN IF NOT EXISTS logo_kanan_url TEXT,
  ADD COLUMN IF NOT EXISTS header_height INT DEFAULT 80,
  ADD COLUMN IF NOT EXISTS header_background_color VARCHAR(20) DEFAULT '#FFFFFF',
  ADD COLUMN IF NOT EXISTS header_border_bottom_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS header_border_bottom_style VARCHAR(20) DEFAULT 'solid',
  ADD COLUMN IF NOT EXISTS header_border_bottom_width INT DEFAULT 2,
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS footer_ttd_kanan_judul VARCHAR(100) DEFAULT 'Kepala Desa';

COMMENT ON COLUMN public.surat_template.logo_kiri_url IS 'URL logo kiri KOP surat';
COMMENT ON COLUMN public.surat_template.logo_kanan_url IS 'URL logo kanan KOP surat';
COMMENT ON COLUMN public.surat_template.header_height IS 'Tinggi header dalam piksel';
COMMENT ON COLUMN public.surat_template.footer_ttd_kanan_judul IS 'Judul tanda tangan (cth: Kepala Desa)';

-- ============================================================
-- 7. SURAT_JENIS - Add columns for DNA fields display
-- ============================================================
ALTER TABLE public.surat_jenis
  ADD COLUMN IF NOT EXISTS has_dna BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS dna_template TEXT,
  ADD COLUMN IF NOT EXISTS requires_verification BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS estimated_days INT DEFAULT 3;

COMMENT ON COLUMN public.surat_jenis.has_dna IS 'Apakah jenis surat ini memiliki DNA fields';
COMMENT ON COLUMN public.surat_jenis.dna_template IS 'Template JSON untuk dynamic form';
COMMENT ON COLUMN public.surat_jenis.requires_verification IS 'Apakah perlu verifikasi admin';
COMMENT ON COLUMN public.surat_jenis.estimated_days IS 'Perkiraan hari proses';

-- ============================================================
-- 8. SURAT_TERBIT - Add columns for QR and TTE
-- ============================================================
ALTER TABLE public.surat_terbit
  ADD COLUMN IF NOT EXISTS qr_code_url TEXT,
  ADD COLUMN IF NOT EXISTS ttd_image_url TEXT,
  ADD COLUMN IF NOT EXISTS signed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS signed_by UUID,
  ADD COLUMN IF NOT EXISTS ttd_oleh VARCHAR(100),
  ADD COLUMN IF NOT EXISTS ttd_nama VARCHAR(255),
  ADD COLUMN IF NOT EXISTS ttd_nip VARCHAR(50);

COMMENT ON COLUMN public.surat_terbit.ttd_oleh IS 'Jabatan penanda tangan (cth: Kepala Desa)';
COMMENT ON COLUMN public.surat_terbit.ttd_nama IS 'Nama penanda tangan';
COMMENT ON COLUMN public.surat_terbit.ttd_nip IS 'NIP penanda tangan';

-- ============================================================
-- Verify all tables have expected columns
-- ============================================================
DO $$
DECLARE
  v_errors TEXT := '';
BEGIN
  -- Check desa_pamong
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'desa_pamong' AND column_name = 'foto_url'
  ) THEN
    v_errors := v_errors || 'desa_pamong.foto_url; ';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'desa_pamong' AND column_name = 'qr_code_url'
  ) THEN
    v_errors := v_errors || 'desa_pamong.qr_code_url; ';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'desa_pamong' AND column_name = 'ttd_image_url'
  ) THEN
    v_errors := v_errors || 'desa_pamong.ttd_image_url; ';
  END IF;

  -- Check berita
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'berita' AND column_name = 'cover_url'
  ) THEN
    v_errors := v_errors || 'berita.cover_url; ';
  END IF;

  -- Report errors
  IF v_errors <> '' THEN
    RAISE WARNING 'Some columns may not have been created: %', v_errors;
  ELSE
    RAISE NOTICE 'All required columns created successfully';
  END IF;
END;
$$;

-- ============================================================
-- Grant permissions
-- ============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- ============================================================
-- Summary
-- ============================================================
-- This migration fixes the following UI vs Database mismatches:
-- 1. desa_pamong - added: foto_url, qr_code_url, ttd_image_url, nip, aktif
-- 2. berita - added: cover_url
-- 3. balita - added: nik_anak, nama_ortu
-- 4. wa_chatbot_session - added: phone_number, intent, last_message, chat_status
-- 5. idm_indikator - added: dimensi_nama, indikator_nama, sumber_data (with sync triggers)
-- 6. surat_template - added: logo_kiri_url, logo_kanan_url, header/footer configs
-- 7. surat_jenis - added: has_dna, dna_template, requires_verification, estimated_days
-- 8. surat_terbit - added: qr_code_url, ttd_image_url, signed_at, ttd_*, etc.
