-- ============================================
-- VERIFICATION QUERIES
-- Run this after all imports are complete
-- ============================================

-- Check totals
SELECT
  'Keluarga' AS tabel,
  COUNT(*) AS jumlah
FROM public.keluarga
UNION ALL
SELECT
  'Penduduk Total' AS tabel,
  COUNT(*) AS jumlah
FROM public.penduduk
UNION ALL
SELECT
  'Penduduk Hidup' AS tabel,
  COUNT(*) AS jumlah
FROM public.penduduk WHERE status_hidup = 'hidup';

-- Check by dusun
SELECT dusun, COUNT(*) AS jumlah
FROM public.penduduk
WHERE status_hidup = 'hidup' AND dusun IS NOT NULL
GROUP BY dusun
ORDER BY dusun;

-- Check by jenis_kelamin
SELECT jenis_kelamin, COUNT(*) AS jumlah
FROM public.penduduk
WHERE status_hidup = 'hidup'
GROUP BY jenis_kelamin;
