-- ============================================================
-- Migration: 20260724190004_add_nik_fk_to_surat_ajuan.sql
-- Add FK constraint: surat_ajuan.nik REFERENCES penduduk.nik
--
-- ROOT CAUSE: surat_ajuan.nik is free-form TEXT with no referential
-- integrity to penduduk.nik. FK ensures all applicants are registered.
--
-- APPROACH: ADD NOT VALID (doesn't check existing rows)
-- then validate only if no orphans exist.
-- If orphans exist, constraint is added as NOT VALID (enforces
-- new inserts only, existing orphans remain).
-- ============================================================

-- Step 1: Check for orphan NIKs (nik in surat_ajuan but not in penduduk)
DO $$
DECLARE
  _orphan_count INTEGER;
  _sample_niks TEXT;
BEGIN
  SELECT COUNT(*), string_agg(DISTINCT sa.nik, ', ')
    INTO _orphan_count, _sample_niks
  FROM public.surat_ajuan sa
  LEFT JOIN public.penduduk p ON p.nik = sa.nik
  WHERE p.id IS NULL;

  IF _orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: % surat_ajuan rows have nik not found in penduduk. Sample: %', _orphan_count, LEFT(_sample_niks, 200);
  ELSE
    RAISE NOTICE 'All surat_ajuan.nik found in penduduk — FK can be validated';
  END IF;
END;
$$;

-- Step 2: Add FK constraint as NOT VALID (doesn't scan existing rows)
-- This enforces FK for new inserts but skips validation of existing data
ALTER TABLE public.surat_ajuan
  ADD CONSTRAINT fk_surat_ajuan_nik_penduduk
  FOREIGN KEY (nik)
  REFERENCES public.penduduk(nik)
  MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

-- Step 3: Validate if no orphans (will fail gracefully if orphans exist)
-- Run separately after reviewing orphan count above
-- DO $$
-- BEGIN
--   ALTER TABLE public.surat_ajuan VALIDATE CONSTRAINT fk_surat_ajuan_nik_penduduk;
--   RAISE NOTICE 'FK constraint fk_surat_ajuan_nik_penduduk validated successfully';
-- END;
-- $$;
