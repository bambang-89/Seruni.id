-- ============================================================
-- SECURITY & INTEGRITY FIXES - Drop Dead Artifacts
-- Tanggal: 2026-08-26
-- Deskripsi: Drop dead index and columns identified during audit
-- ============================================================

-- 1. Drop dead index on non-existent column kepala_keluarga_id in keluarga table
--    The index was created in 20260728000003 but was never pushed to remote DB
--    Using DO$$ block for idempotency (indexes don't support IF NOT EXISTS syntax)
DO $$
BEGIN
  DROP INDEX IF EXISTS public.idx_keluarga_kepala;
  RAISE NOTICE 'idx_keluarga_kepala dropped or did not exist';
EXCEPTION
  WHEN undefined_table OR undefined_object THEN
    RAISE NOTICE 'idx_keluarga_kepala does not exist, skipping';
END $$;

-- 2. Drop dead columns from penduduk table
--    rt_id, rw_id: created in 20260722000001 but no FK, no backfill, no UI usage
--    dusun_id: created in 20260722000001 with FK pointing to non-existent table wilayah_batas
--    All columns are nullable and contain no meaningful data
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rt_id;
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rw_id;
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS dusun_id;

-- 3. Verification
SELECT 'Dead artifacts dropped: idx_keluarga_kepala, rt_id, rw_id, dusun_id' AS result;

-- Verify columns are gone
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'penduduk'
  AND column_name IN ('rt_id', 'rw_id', 'dusun_id');

-- Verify penduduk table is still functional
SELECT count(*) AS penduduk_count FROM public.penduduk LIMIT 1;
