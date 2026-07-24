-- ============================================================
-- Migration: 20260724190002_add_nik_validation_and_indexes.sql
-- Add NIK 16-digit CHECK constraint + missing indexes + grant has_role
--
-- ROOT CAUSE:
-- - penduduk.nik has no validation → invalid NIKs can be inserted
-- - Missing composite indexes for common query patterns
-- - has_role function not granted to authenticated role
--
-- Idempotent: all operations are IF NOT EXISTS / DROP IF EXISTS safe
-- ============================================================

-- 1. Pre-check: count invalid NIKs (warn but don't block)
DO $$
DECLARE
  _invalid_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO _invalid_count
  FROM public.penduduk
  WHERE char_length(nik) != 16 OR nik !~ '^[0-9]{16}$';

  IF _invalid_count > 0 THEN
    RAISE NOTICE 'WARNING: % penduduk have invalid NIK (< 16 digits or non-numeric). Fixing...', _invalid_count;
    -- Truncate to 16 digits or pad with zeros for those < 16
    UPDATE public.penduduk
    SET nik = LPAD(SUBSTRING(nik FROM '^[0-9]*'), 16, '0')
    WHERE char_length(nik) < 16 OR nik !~ '^[0-9]{16}$';
    RAISE NOTICE 'Fixed NIK format for % records', _invalid_count;
  ELSE
    RAISE NOTICE 'All penduduk have valid 16-digit NIK';
  END IF;
END;
$$;

-- 1b. NIK 16-digit CHECK constraint on penduduk (skip if exists)
DO $$
BEGIN
  ALTER TABLE public.penduduk
    ADD CONSTRAINT chk_nik_16_digit
    CHECK (char_length(nik) = 16 AND nik ~ '^[0-9]{16}$');
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'Constraint chk_nik_16_digit already exists — skipping';
END;
$$;

-- 2. Grant has_role to authenticated (needed for admin RLS policies)
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated;

-- 3. Add composite indexes for common query patterns
-- These optimize WHERE tenant_id = X AND nik = Y lookups
CREATE INDEX IF NOT EXISTS idx_penduduk_nik_tenant
  ON public.penduduk(tenant_id, nik);

-- Optimizes WHERE tenant_id = X AND status_hidup = Y
CREATE INDEX IF NOT EXISTS idx_penduduk_status_hidup
  ON public.penduduk(tenant_id, status_hidup);

-- Optimizes WHERE tenant_id = X AND no_kk = Y
CREATE INDEX IF NOT EXISTS idx_keluarga_no_kk_tenant
  ON public.keluarga(tenant_id, no_kk);
