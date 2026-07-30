-- ============================================================
-- MIGRASI: 20260730000004_cek_integritas_rpc.sql
-- Tanggal: 2026-07-30
-- Deskripsi: RPC SECURITY DEFINER untuk cek integritas data
--            Bypasses RLS - untuk monitoring & debugging
-- ============================================================

CREATE OR REPLACE FUNCTION public.cek_integritas_penduduk()
RETURNS TABLE (
  check_name TEXT,
  category TEXT,
  issue_count BIGINT,
  detail TEXT,
  sample_data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- 1. Penduduk tanpa keluarga_id
  RETURN QUERY
  SELECT
    'penduduk_tanpa_keluarga_id'::TEXT,
    'integrity'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk dengan NULL keluarga_id'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'nik', p.nik,
      'nama', p.nama,
      'hubungan_kk', p.hubungan_kk,
      'no_kk', p.no_kk,
      'dusun', p.dusun
    ) ORDER BY p.nik) FILTER (WHERE COUNT(*) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.penduduk p
  WHERE p.keluarga_id IS NULL
  GROUP BY TRUE;

  -- 2. Keluarga tanpa kepala_penduduk_id
  RETURN QUERY
  SELECT
    'keluarga_tanpa_kepala'::TEXT,
    'integrity'::TEXT,
    COUNT(*)::BIGINT,
    'Keluarga dengan NULL kepala_penduduk_id'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'id', k.id,
      'no_kk', k.no_kk,
      'kepala_id', k.kepala_penduduk_id,
      'kepala_nama', k.kepala_nama
    ) ORDER BY k.no_kk) FILTER (WHERE COUNT(*) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.keluarga k
  WHERE k.kepala_penduduk_id IS NULL
  GROUP BY TRUE;

  -- 3. Kepala Keluarga tanpa keluarga_id
  RETURN QUERY
  SELECT
    'kepala_tanpa_keluarga'::TEXT,
    'integrity'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk hubungan_kk=Kepala Keluarga tapi NULL keluarga_id'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'nik', p.nik,
      'nama', p.nama,
      'keluarga_id', p.keluarga_id,
      'no_kk', p.no_kk
    ) ORDER BY p.nik) FILTER (WHERE COUNT(*) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.penduduk p
  WHERE p.hubungan_kk = 'Kepala Keluarga'
    AND p.keluarga_id IS NULL
  GROUP BY TRUE;

  -- 4. Orphan keluarga_id in penduduk
  RETURN QUERY
  SELECT
    'orphan_keluarga_id'::TEXT,
    'integrity'::TEXT,
    COUNT(DISTINCT p.keluarga_id)::BIGINT,
    'keluarga_id di penduduk tidak ada di tabel keluarga'::TEXT,
    COALESCE(jsonb_agg(DISTINCT jsonb_build_object(
      'keluarga_id', p.keluarga_id,
      'cnt', sub.cnt
    ) ORDER BY sub.cnt DESC) FILTER (WHERE COUNT(DISTINCT p.keluarga_id) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.penduduk p
  JOIN LATERAL (SELECT COUNT(*) as cnt FROM public.penduduk p2 WHERE p2.keluarga_id = p.keluarga_id) sub ON true
  WHERE p.keluarga_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM public.keluarga k WHERE k.id = p.keluarga_id)
  GROUP BY TRUE;

  -- 5. Keluarga tidak direferensikan
  RETURN QUERY
  SELECT
    'keluarga_tak_tereferensikan'::TEXT,
    'integrity'::TEXT,
    COUNT(*)::BIGINT,
    'Keluarga tanpa anggota di penduduk'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'id', k.id,
      'no_kk', k.no_kk,
      'kepala_nama', k.kepala_nama,
      'alamat', k.alamat
    ) ORDER BY k.no_kk) FILTER (WHERE COUNT(*) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.keluarga k
  WHERE NOT EXISTS (SELECT 1 FROM public.penduduk p WHERE p.keluarga_id = k.id)
  GROUP BY TRUE;

  -- 6. Summary counts
  RETURN QUERY
  SELECT
    'total_penduduk'::TEXT,
    'summary'::TEXT,
    COUNT(*)::BIGINT,
    'Total penduduk di database'::TEXT,
    NULL::JSONB
  FROM public.penduduk;

  RETURN QUERY
  SELECT
    'total_keluarga'::TEXT,
    'summary'::TEXT,
    COUNT(*)::BIGINT,
    'Total keluarga di database'::TEXT,
    NULL::JSONB
  FROM public.keluarga;

  RETURN QUERY
  SELECT
    'distinct_no_kk'::TEXT,
    'summary'::TEXT,
    COUNT(DISTINCT p.no_kk)::BIGINT,
    'Distinct NO_KK di penduduk'::TEXT,
    NULL::JSONB
  FROM public.penduduk p
  WHERE p.no_kk IS NOT NULL;

  -- 7. dusun takterdaftar
  RETURN QUERY
  SELECT
    'dusun_tak_terdaftar'::TEXT,
    'dusun'::TEXT,
    COUNT(DISTINCT p.dusun)::BIGINT,
    'Dusun di penduduk tidak ada di wilayah_dusun'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'dusun', sub.dusun,
      'count', sub.cnt
    ) ORDER BY sub.cnt DESC) FILTER (WHERE COUNT(DISTINCT p.dusun) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM (
    SELECT DISTINCT p2.dusun, COUNT(*) as cnt
    FROM public.penduduk p2
    WHERE p2.dusun IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM public.wilayah_dusun w WHERE w.nama = p2.dusun)
    GROUP BY p2.dusun
  ) sub
  GROUP BY TRUE;

  -- 8. Null dusun_id
  RETURN QUERY
  SELECT
    'penduduk_tanpa_dusun_id'::TEXT,
    'dusun'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk tanpa dusun_id'::TEXT,
    COALESCE(jsonb_agg(jsonb_build_object(
      'nik', p.nik,
      'nama', p.nama,
      'dusun', p.dusun
    ) ORDER BY p.nik) FILTER (WHERE COUNT(*) OVER () <= 20), jsonb_build_array()::JSONB)
  FROM public.penduduk p
  WHERE p.dusun IS NOT NULL
    AND p.dusun_id IS NULL
  GROUP BY TRUE;

END;
$$;

GRANT EXECUTE ON FUNCTION public.cek_integritas_penduduk() TO anon, authenticated, service_role;
