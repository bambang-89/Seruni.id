-- ============================================================
-- MIGRASI: 20260730000003_fix_dusun_wilayah_and_grants.sql
-- Tanggal: 2026-07-30
-- Deskripsi:
--  1. Insert missing dusun names from CSV into wilayah_dusun
--  2. Ensure dusun_id populated for all penduduk
--  3. Grant EXECUTE for RPCs used by public form
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN

  -- 1. Get tenant_id
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  RAISE NOTICE 'Tenant ID: %', v_tenant_id;

  -- 2. Ensure all dusun from CSV exist in wilayah_dusun
  --    (Mumbul Utara, Mumbul Selatan, Seruni Barat, Seruni Timur,
  --     Seruni Selatan, Seruni Utara, Seruni Mumbul may not exist yet)
  RAISE NOTICE '--- Inserting missing dusun into wilayah_dusun ---';

  INSERT INTO public.wilayah_dusun (id, tenant_id, nama, kk, jiwa, luas_ha, urutan, created_at, updated_at)
  SELECT
    gen_random_uuid(),
    v_tenant_id,
    dusun_name,
    0,  -- kk, jiwa will be counted
    0,
    0,  -- luas_ha
    urutan,
    NOW(),
    NOW()
  FROM (VALUES
    ('Mumbul Utara',   5),
    ('Mumbul Selatan', 6),
    ('Seruni Barat',    7),
    ('Seruni Timur',    8),
    ('Seruni Selatan',  9),
    ('Seruni Utara',    10),
    ('Seruni Mumbul',   11)
  ) AS missing(dusun_name, urutan)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.wilayah_dusun
    WHERE tenant_id = v_tenant_id AND nama = missing.dusun_name
  )
  ON CONFLICT (tenant_id, nama) DO NOTHING;

  RAISE NOTICE '  Done inserting missing dusun.';

  -- 3. Backfill dusun_id for all penduduk
  RAISE NOTICE '--- Backfill dusun_id in penduduk ---';

  UPDATE public.penduduk p
  SET dusun_id = rd.id
  FROM public.ref_dusun rd
  WHERE lower(p.dusun) = lower(rd.nama)
    AND p.dusun_id IS NULL;

  RAISE NOTICE '  dusun_id backfilled.';

  -- For dusun names that don't exist in ref_dusun, just ensure they're in wilayah_dusun
  -- The ref_dusun mapping is optional for our use case

END $$;

-- Grant EXECUTE for find_penduduk_by_nik RPC
GRANT EXECUTE ON FUNCTION public.find_penduduk_by_nik(TEXT) TO anon, authenticated, service_role;

-- Grant EXECUTE for cek_integritas_penduduk RPC
GRANT EXECUTE ON FUNCTION public.cek_integritas_penduduk() TO anon, authenticated, service_role;

RAISE NOTICE 'Migration selesai.';
