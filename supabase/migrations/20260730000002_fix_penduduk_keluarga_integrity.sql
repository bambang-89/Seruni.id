-- ============================================================
-- MIGRASI: 20260730000002_fix_penduduk_keluarga_integrity.sql
-- Tanggal: 2026-07-30
-- Deskripsi: Fix relasi keluarga_id & kepala_penduduk_id
--            untuk semua data penduduk yang sudah ada
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_kepala_uuid UUID;
  v_kk_uuid UUID;
  v_total INTEGER := 0;
  v_fixed INTEGER := 0;
  v_orphan INTEGER := 0;
BEGIN

  -- Ambil tenant_id
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  RAISE NOTICE 'Tenant ID: %', v_tenant_id;

  -- =============================================================
  -- FIX 1: Fill keluarga_id di penduduk berdasarkan no_kk
  -- =============================================================
  RAISE NOTICE '--- FIX 1: Link penduduk.keluarga_id via no_kk ---';

  UPDATE public.penduduk p
  SET keluarga_id = k.id
  FROM public.keluarga k
  WHERE k.tenant_id = v_tenant_id
    AND k.no_kk = p.no_kk
    AND p.tenant_id = v_tenant_id
    AND p.keluarga_id IS NULL
    AND p.no_kk IS NOT NULL;

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  keluarga_id filled: % rows', v_fixed;

  -- =============================================================
  -- FIX 2: Fill kepala_penduduk_id di keluarga
  -- =============================================================
  RAISE NOTICE '--- FIX 2: Link keluarga.kepala_penduduk_id ---';

  -- Untuk setiap keluarga, cari penduduk dengan hubungan_kk='Kepala Keluarga'
  FOR v_kk_uuid, v_kepala_uuid IN
    SELECT DISTINCT k.id, p.id
    FROM public.keluarga k
    JOIN public.penduduk p ON p.keluarga_id = k.id
    WHERE k.tenant_id = v_tenant_id
      AND p.hubungan_kk = 'Kepala Keluarga'
      AND k.kepala_penduduk_id IS NULL
  LOOP
    UPDATE public.keluarga
    SET kepala_penduduk_id = v_kepala_uuid
    WHERE id = v_kk_uuid;
    v_fixed := v_fixed + 1;
  END LOOP;

  RAISE NOTICE '  kepala_penduduk_id filled: % families', v_fixed;

  -- =============================================================
  -- FIX 3: Fill kepala_nama di keluarga dari penduduk
  -- =============================================================
  RAISE NOTICE '--- FIX 3: Fill kepala_nama di keluarga ---';

  UPDATE public.keluarga k
  SET kepala_nama = p.nama
  FROM public.penduduk p
  WHERE p.id = k.kepala_penduduk_id
    AND k.tenant_id = v_tenant_id
    AND k.kepala_nama IS NULL
    AND k.kepala_penduduk_id IS NOT NULL;

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  kepala_nama filled: % families', v_fixed;

  -- =============================================================
  -- FIX 4: Fill hubungan_kk='Kepala Keluarga' untuk semua
  --         penduduk yang menjadi kepala keluarga
  -- =============================================================
  RAISE NOTICE '--- FIX 4: Normalize hubungan_kk ---';

  -- KK holder: penduduk WHERE keluarga_id ada AND is first or only member with this keluarga_id
  -- Using kepala_penduduk_id dari keluarga
  UPDATE public.penduduk p
  SET hubungan_kk = 'Kepala Keluarga'
  FROM public.keluarga k
  WHERE k.kepala_penduduk_id = p.id
    AND p.hubungan_kk IS DISTINCT FROM 'Kepala Keluarga';

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  hubungan_kk normalized: % rows', v_fixed;

  -- =============================================================
  -- FIX 5: Fill dusun_id di penduduk berdasarkan nama dusun
  -- =============================================================
  RAISE NOTICE '--- FIX 5: Fill dusun_id via ref_dusun match ---';

  UPDATE public.penduduk p
  SET dusun_id = rd.id
  FROM public.ref_dusun rd
  WHERE lower(p.dusun) = lower(rd.nama)
    AND p.dusun_id IS NULL;

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  dusun_id filled: % rows', v_fixed;

  -- =============================================================
  -- FIX 6: Fix NO_KK malformed values
  -- Replace placeholder values dengan NULL
  -- =============================================================
  RAISE NOTICE '--- FIX 6: Fix malformed NO_KK ---';

  UPDATE public.penduduk
  SET no_kk = NULL
  WHERE tenant_id = v_tenant_id
    AND no_kk IS NOT NULL
    AND (
      no_kk IN ('NON KK', 'BLM ADA KK', 'NON-KK')
      OR no_kk ~ '[a-zA-Z]'
      OR LENGTH(no_kk) < 16
    );

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  NO_KK cleared (malformed): % rows', v_fixed;

  -- Clear keluarga_id for those whose no_kk was cleared
  UPDATE public.penduduk
  SET keluarga_id = NULL
  WHERE keluarga_id IS NOT NULL
    AND no_kk IS NULL;

  GET DIAGNOSTICS v_fixed = ROW_COUNT;
  RAISE NOTICE '  keluarga_id cleared (orphaned): % rows', v_fixed;

  -- =============================================================
  -- REPORT: Summary
  -- =============================================================
  RAISE NOTICE '';
  RAISE NOTICE '==============================================================';
  RAISE NOTICE '  INTEGRITY FIX SUMMARY';
  RAISE NOTICE '==============================================================';

  SELECT COUNT(*) INTO v_total FROM public.penduduk WHERE tenant_id = v_tenant_id;
  RAISE NOTICE '  Total penduduk: %', v_total;

  SELECT COUNT(*) INTO v_fixed FROM public.penduduk WHERE tenant_id = v_tenant_id AND keluarga_id IS NULL;
  RAISE NOTICE '  Tanpa keluarga_id: %', v_fixed;

  SELECT COUNT(*) INTO v_fixed FROM public.penduduk WHERE tenant_id = v_tenant_id AND keluarga_id IS NOT NULL;
  RAISE NOTICE '  Dengan keluarga_id: %', v_fixed;

  SELECT COUNT(*) INTO v_total FROM public.keluarga WHERE tenant_id = v_tenant_id;
  RAISE NOTICE '  Total keluarga: %', v_total;

  SELECT COUNT(*) INTO v_fixed FROM public.keluarga WHERE tenant_id = v_tenant_id AND kepala_penduduk_id IS NULL;
  RAISE NOTICE '  KK tanpa kepala_penduduk_id: %', v_fixed;

  -- Orphan keluarga (not referenced by any penduduk)
  SELECT COUNT(*) INTO v_orphan
  FROM public.keluarga k
  WHERE k.tenant_id = v_tenant_id
    AND NOT EXISTS (SELECT 1 FROM public.penduduk p WHERE p.keluarga_id = k.id);
  RAISE NOTICE '  Orphan keluarga (no anggota): %', v_orphan;

  RAISE NOTICE '==============================================================';

END $$;

-- Grant untuk semua role
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
