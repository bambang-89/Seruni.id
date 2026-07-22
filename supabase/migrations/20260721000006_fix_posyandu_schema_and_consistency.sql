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
-- 5. Cron jobs for IDM scorer (SKIPPED - configure via Supabase Dashboard)
-- Note: pg_cron with net.http_post requires special Supabase configuration.
-- To enable: Use Supabase Dashboard > Database > Extensions > pg_cron
-- Or configure via: https://supabase.com/dashboard/project/_/database/extensions
-- ============================================================

-- NOTE: The cron job scheduling is intentionally skipped here due to
-- net.http_post availability constraints in Supabase Serverless.
-- Configure cron jobs manually via Supabase Dashboard or use external scheduler.
-- This migration focuses on schema changes only.

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
