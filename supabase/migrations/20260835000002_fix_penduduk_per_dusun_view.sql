-- ============================================================
-- MIGRASI: 20260835000002_fix_penduduk_per_dusun_view.sql
-- Deskripsi: Update penduduk_per_dusun view to use dusun_id for grouping
-- ============================================================

-- Recreate view to group by dusun_id and get proper name
DROP VIEW IF EXISTS public.penduduk_per_dusun;
CREATE VIEW public.penduduk_per_dusun AS
SELECT
  p.tenant_id,
  COALESCE(rd.nama, p.dusun) AS dusun,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup') AS jumlah_penduduk,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'L') AS laki_laki,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'P') AS perempuan,
  COUNT(DISTINCT k.id) FILTER (WHERE k.id IS NOT NULL) AS jumlah_kk
FROM public.penduduk p
LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
LEFT JOIN public.ref_dusun rd ON rd.id = p.dusun_id
WHERE COALESCE(rd.nama, p.dusun) IS NOT NULL
GROUP BY p.tenant_id, COALESCE(rd.nama, p.dusun);

GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;
