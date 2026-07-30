-- ============================================================
-- MIGRASI: cek_integritas_penduduk.sql
-- Tanggal: 2026-07-30
-- Deskripsi: RPC SECURITY DEFINER untuk cek integritas data
--            penduduk vs keluarga tanpa terblokir RLS
-- ============================================================

CREATE OR REPLACE FUNCTION public.cek_integritas_penduduk(jsonb DEFAULT '{}')
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
    'keluarga_id'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk dengan NULL keluarga_id'::TEXT,
    jsonb_agg(jsonb_build_object(
      'nik', p.nik,
      'nama', p.nama,
      'hubungan_kk', p.hubungan_kk,
      'no_kk', p.no_kk,
      'dusun', p.dusun
    ) ORDER BY p.nik)
  FROM public.penduduk p
  WHERE p.keluarga_id IS NULL;

  -- 2. Keluarga tanpa kepala (kepala_id IS NULL atau kepala_id tidak ada di penduduk)
  RETURN QUERY
  SELECT
    'keluarga_tanpa_kepala'::TEXT,
    'keluarga'::TEXT,
    COUNT(*)::BIGINT,
    'Keluarga dengan NULL kepala_id atau kepala_id tidak valid'::TEXT,
    jsonb_agg(jsonb_build_object(
      'id', k.id,
      'no_kk', k.no_kk,
      'kepala_id', k.kepala_id,
      'kepala_nama', k.kepala_nama
    ) ORDER BY k.no_kk)
  FROM public.keluarga k
  WHERE k.kepala_id IS NULL
     OR NOT EXISTS (SELECT 1 FROM public.penduduk p2 WHERE p2.id = k.kepala_id);

  -- 3. Kepala Keluarga tanpa keluarga_id
  RETURN QUERY
  SELECT
    'kepala_tanpa_keluarga'::TEXT,
    'keluarga_id'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk dengan hubungan_kk=Kepala Keluarga tapi NULL keluarga_id'::TEXT,
    jsonb_agg(jsonb_build_object(
      'nik', p.nik,
      'nama', p.nama,
      'keluarga_id', p.keluarga_id,
      'no_kk', p.no_kk
    ) ORDER BY p.nik)
  FROM public.penduduk p
  WHERE p.hubungan_kk = 'Kepala Keluarga'
    AND p.keluarga_id IS NULL;

  -- 4. keluarga_id di penduduk yang tidak ada di keluarga
  RETURN QUERY
  SELECT
    'orphan_keluarga_id'::TEXT,
    'keluarga'::TEXT,
    COUNT(DISTINCT p.keluarga_id)::BIGINT,
    'keluarga_id di penduduk yang tidak ada di tabel keluarga'::TEXT,
    jsonb_agg(DISTINCT jsonb_build_object(
      'keluarga_id', p.keluarga_id,
      'count', sub.cnt
    ) ORDER BY sub.cnt DESC)
  FROM public.penduduk p
  JOIN LATERAL (
    SELECT COUNT(*) as cnt FROM public.penduduk p2 WHERE p2.keluarga_id = p.keluarga_id
  ) sub ON true
  WHERE p.keluarga_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM public.keluarga k WHERE k.id = p.keluarga_id);

  -- 5. Keluarga tidak direferensikan oleh siapapun
  RETURN QUERY
  SELECT
    'keluarga_tak_tereferensikan'::TEXT,
    'keluarga'::TEXT,
    COUNT(*)::BIGINT,
    'Keluarga yang tidak punya anggota di tabel penduduk'::TEXT,
    jsonb_agg(jsonb_build_object(
      'id', k.id,
      'no_kk', k.no_kk,
      'kepala_nama', k.kepala_nama,
      'alamat', k.alamat
    ) ORDER BY k.no_kk)
  FROM public.keluarga k
  WHERE NOT EXISTS (SELECT 1 FROM public.penduduk p WHERE p.keluarga_id = k.id);

  -- 6. Distribusi hubungan_kk
  RETURN QUERY
  SELECT
    'distribusi_hubungan_kk'::TEXT,
    'statistik'::TEXT,
    COUNT(*)::BIGINT,
    ('Hubungan KK: ' || p.hubungan_kk)::TEXT,
    NULL::JSONB
  FROM public.penduduk p
  WHERE p.hubungan_kk IS NOT NULL
  GROUP BY p.hubungan_kk;

  -- 7. Distinct dusun di penduduk
  RETURN QUERY
  SELECT
    'dusun_di_penduduk'::TEXT,
    'dusun'::TEXT,
    COUNT(*)::BIGINT,
    ('Dusun: ' || p.dusun)::TEXT,
    NULL::JSONB
  FROM public.penduduk p
  WHERE p.dusun IS NOT NULL
  GROUP BY p.dusun;

  -- 8. Distinct dusun di wilayah_dusun
  RETURN QUERY
  SELECT
    'dusun_di_wilayah'::TEXT,
    'dusun'::TEXT,
    COUNT(*)::BIGINT,
    ('Wilayah: ' || w.nama)::TEXT,
    NULL::JSONB
  FROM public.wilayah_dusun w
  WHERE w.nama IS NOT NULL
  GROUP BY w.nama;

  -- 9. Tenant mismatch:住户 dengan tenant_id berbeda dari keluarga
  RETURN QUERY
  SELECT
    'tenant_mismatch_penduduk_keluarga'::TEXT,
    'tenant'::TEXT,
    COUNT(*)::BIGINT,
    'Penduduk dengan tenant_id berbeda dari keluarga_id'::TEXT,
    jsonb_agg(jsonb_build_object(
      'penduduk_nik', p.nik,
      'penduduk_tenant', p.tenant_id,
      'keluarga_id', p.keluarga_id,
      'keluarga_tenant', k.tenant_id
    ) ORDER BY p.nik)
  FROM public.penduduk p
  JOIN public.keluarga k ON k.id = p.keluarga_id
  WHERE p.tenant_id IS DISTINCT FROM k.tenant_id;

  -- 10. Summary counts
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
    'distinct_no_kk_penduduk'::TEXT,
    'summary'::TEXT,
    COUNT(DISTINCT p.no_kk)::BIGINT,
    'Distinct NO_KK di tabel penduduk'::TEXT,
    NULL::JSONB
  FROM public.penduduk p
  WHERE p.no_kk IS NOT NULL;

  RETURN QUERY
  SELECT
    'distinct_no_kk_keluarga'::TEXT,
    'summary'::TEXT,
    COUNT(DISTINCT k.no_kk)::BIGINT,
    'Distinct NO_KK di tabel keluarga'::TEXT,
    NULL::JSONB
  FROM public.keluarga k
  WHERE k.no_kk IS NOT NULL;

  -- 11. dusun mismatch: ada di penduduk tapi tidak ada di wilayah_dusun
  RETURN QUERY
  SELECT
    'dusun_tak_terdaftar'::TEXT,
    'dusun'::TEXT,
    COUNT(*)::BIGINT,
    'Dusun di penduduk yang tidak ada di wilayah_dusun'::TEXT,
    jsonb_agg(jsonb_build_object(
      'dusun', p.dusun,
      'count', sub.cnt
    ) ORDER BY sub.cnt DESC)
  FROM (
    SELECT DISTINCT p2.dusun
    FROM public.penduduk p2
    WHERE p2.dusun IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM public.wilayah_dusun w WHERE w.nama = p2.dusun)
  ) sub
  JOIN LATERAL (
    SELECT COUNT(*) as cnt FROM public.penduduk p3 WHERE p3.dusun = sub.dusun
  ) sub2 ON true;

END;
$$;

-- Allow all roles to execute
GRANT EXECUTE ON FUNCTION public.cek_integritas_penduduk(jsonb) TO anon, authenticated, service_role;
