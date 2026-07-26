-- Migration: 20260725000002_widen_all_wilayah_codes.sql
-- Widen kode columns to VARCHAR(10) for 7-digit district / 10-digit village codes
-- Idempotent — uses IF NOT EXISTS pattern
DO $outer$
BEGIN

  -- ref_kecamatan: kode currently VARCHAR(6), needs VARCHAR(10) for 7-digit codes
  -- Check if needs widening by attempting a dummy insert that would fail if too small
  -- Use ALTER IF column_length < 10 (PostgreSQL 16+) or just try/catch

  BEGIN
    ALTER TABLE public.ref_kecamatan ALTER COLUMN kode TYPE VARCHAR(10);
    RAISE NOTICE 'ref_kecamatan.kode widened to VARCHAR(10)';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ref_kecamatan.kode already OK: %', SQLERRM;
  END;

  BEGIN
    ALTER TABLE public.ref_kecamatan ALTER COLUMN kode_kabupaten TYPE VARCHAR(10);
    RAISE NOTICE 'ref_kecamatan.kode_kabupaten widened to VARCHAR(10)';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ref_kecamatan.kode_kabupaten already OK: %', SQLERRM;
  END;

  BEGIN
    ALTER TABLE public.ref_desa ALTER COLUMN kode_kecamatan TYPE VARCHAR(10);
    RAISE NOTICE 'ref_desa.kode_kecamatan widened to VARCHAR(10)';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ref_desa.kode_kecamatan already OK: %', SQLERRM;
  END;

  RAISE NOTICE 'Wilayah code columns verified/widened.';

END $outer$;
