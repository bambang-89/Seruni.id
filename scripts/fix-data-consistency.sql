-- ============================================================
-- FIX DATA CONSISTENCY SCRIPT
-- Run: Paste to Supabase SQL Editor
-- Purpose: Fix hubungan_kk, link keluarga_id, link dusun_id
-- ============================================================

BEGIN;

-- ============================================================
-- STEP 1: Fix hubungan_kk values
-- ============================================================

-- A. Standardize "Kepala Keluarga" → "KK"
UPDATE penduduk
SET hubungan_kk = 'KK'
WHERE UPPER(hubungan_kk) LIKE '%KEPALA%' OR UPPER(hubungan_kk) = 'KEPALA KELUARGA';

-- B. Standardize other values
UPDATE penduduk SET hubungan_kk = 'ISTRI' WHERE UPPER(hubungan_KK) LIKE '%ISTRI%';
UPDATE penduduk SET hubungan_kk = 'ANAK' WHERE UPPER(hubungan_KK) LIKE '%ANAK%';
UPDATE penduduk SET hubungan_kk = 'ORTU' WHERE UPPER(hubungan_KK) LIKE '%ORTU%';
UPDATE penduduk SET hubungan_kk = 'ORANG TUA' WHERE UPPER(hubungan_KK) LIKE '%ORANG TUA%';
UPDATE penduduk SET hubungan_kk = 'LAINNYA' WHERE UPPER(hubungan_KK) LIKE '%LAIN%';

-- ============================================================
-- STEP 2: Link Penduduk → Keluarga (via no_kk)
-- ============================================================

-- Update keluarga_id based on no_kk match
UPDATE penduduk p
SET keluarga_id = k.id
FROM keluarga k
WHERE p.no_kk = k.no_kk
  AND p.keluarga_id IS NULL
  AND k.id IS NOT NULL;

-- ============================================================
-- STEP 3: Link Penduduk → Wilayah (via dusun)
-- ============================================================

-- Update dusun_id based on dusun name match
UPDATE penduduk p
SET dusun_id = w.id
FROM wilayah_dusun w
WHERE p.dusun = w.nama
  AND p.dusun_id IS NULL
  AND w.id IS NOT NULL;

-- ============================================================
-- STEP 4: Verify and Report
-- ============================================================

-- Count after fixes
DO $$
DECLARE
  v_total_penduduk INT;
  v_total_kk INT;
  v_linked_keluarga INT;
  v_linked_dusun INT;
  v_null_keluarga INT;
  v_null_dusun INT;
BEGIN
  -- Total count
  SELECT COUNT(*) INTO v_total_penduduk FROM penduduk;

  -- Count KK
  SELECT COUNT(*) INTO v_total_kk FROM penduduk WHERE hubungan_kk = 'KK';

  -- Linked to keluarga
  SELECT COUNT(*) INTO v_linked_keluarga FROM penduduk WHERE keluarga_id IS NOT NULL;

  -- Linked to dusun
  SELECT COUNT(*) INTO v_linked_dusun FROM penduduk WHERE dusun_id IS NOT NULL;

  -- Not linked
  SELECT COUNT(*) INTO v_null_keluarga FROM penduduk WHERE keluarga_id IS NULL;
  SELECT COUNT(*) INTO v_null_dusun FROM penduduk WHERE dusun_id IS NULL;

  -- Report
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'DATA CONSISTENCY FIX REPORT';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Total Penduduk: %', v_total_penduduk;
  RAISE NOTICE 'Total KK (hubungan_kk=KK): %', v_total_kk;
  RAISE NOTICE 'Linked to Keluarga: % (% of total)',
    v_linked_keluarga,
    ROUND((v_linked_keluarga::NUMERIC / v_total_penduduk * 100), 1);
  RAISE NOTICE 'Linked to Wilayah: % (% of total)',
    v_linked_dusun,
    ROUND((v_linked_dusun::NUMERIC / v_total_penduduk * 100), 1);
  RAISE NOTICE '';
  RAISE NOTICE 'Not Linked:';
  RAISE NOTICE '  - keluarga_id NULL: %', v_null_keluarga;
  RAISE NOTICE '  - dusun_id NULL: %', v_null_dusun;
  RAISE NOTICE '';
END $$;

-- ============================================================
-- STEP 5: Update Wilayah statistics
-- ============================================================

-- Update wilayah.jiwa based on actual penduduk count
UPDATE wilayah_dusun w
SET jiwa = sub.cnt
FROM (
  SELECT dusun_id, COUNT(*) as cnt
  FROM penduduk
  WHERE dusun_id IS NOT NULL
  GROUP BY dusun_id
) sub
WHERE w.id = sub.dusun_id;

-- Update wilayah.kk based on KK count
UPDATE wilayah_dusun w
SET kk = sub.cnt
FROM (
  SELECT dusun_id, COUNT(*) as cnt
  FROM penduduk
  WHERE dusun_id IS NOT NULL
    AND hubungan_kk = 'KK'
  GROUP BY dusun_id
) sub
WHERE w.id = sub.dusun_id;

-- ============================================================
-- STEP 6: Verify Wilayah
-- ============================================================

SELECT
  nama as dusun,
  kk as total_kk,
  jiwa as total_jiwa,
  luas_ha as luas_hektar
FROM wilayah_dusun
ORDER BY urutan;

COMMIT;
