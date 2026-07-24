-- ============================================================
-- Migration: 20260724190001_fix_penduduk_keluarga_tenant_id.sql
-- Critical Fix: Add tenant_id to penduduk & keluarga tables + cleanup
--
-- ROOT CAUSES:
-- 1. penduduk & keluarga created WITHOUT tenant_id column
-- 2. RLS policies reference tenant_id that doesn't exist → all queries return 0 rows
-- 3. Dead index on non-existent column keluarga.kepala_keluarga_id
-- 4. Dead columns rt_id and rw_id in penduduk (no FK, no usage)
-- 5. Trigger references non-existent column keluarga.status_kk
--
-- RUN ORDER: Execute AFTER existing migrations (idempotent)
-- ============================================================

DO $outer$
DECLARE
  _tenant_id UUID;
BEGIN
  -- Get the default tenant_id for Seruni Mumbul
  SELECT id INTO _tenant_id
  FROM public.tenants
  WHERE subdomain = 'seruni-mumbul'
  LIMIT 1;

  -- Fallback: get first tenant if subdomain not found
  IF _tenant_id IS NULL THEN
    SELECT id INTO _tenant_id
    FROM public.tenants
    LIMIT 1;
  END IF;

  RAISE NOTICE 'Using tenant_id: %', _tenant_id;

  -- ============================================================
  -- STEP 1: Add tenant_id to penduduk if not exists
  -- ============================================================
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'penduduk'
      AND column_name = 'tenant_id'
  ) THEN
    ALTER TABLE public.penduduk
      ADD COLUMN tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

    -- Backfill existing records
    UPDATE public.penduduk
    SET tenant_id = _tenant_id
    WHERE tenant_id IS NULL;

    -- Ensure NOT NULL
    ALTER TABLE public.penduduk
      ALTER COLUMN tenant_id SET NOT NULL;

    RAISE NOTICE 'Added tenant_id to penduduk';
  ELSE
    RAISE NOTICE 'tenant_id already exists in penduduk';
  END IF;

  -- ============================================================
  -- STEP 2: Add tenant_id to keluarga if not exists
  -- ============================================================
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'keluarga'
      AND column_name = 'tenant_id'
  ) THEN
    ALTER TABLE public.keluarga
      ADD COLUMN tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

    -- Backfill from anggota (head of family)
    UPDATE public.keluarga k
    SET tenant_id = p.tenant_id
    FROM public.penduduk p
    WHERE p.id = k.id
      AND k.tenant_id IS NULL;

    -- Backfill remaining with default tenant
    UPDATE public.keluarga
    SET tenant_id = _tenant_id
    WHERE tenant_id IS NULL;

    -- Ensure NOT NULL
    ALTER TABLE public.keluarga
      ALTER COLUMN tenant_id SET NOT NULL;

    RAISE NOTICE 'Added tenant_id to keluarga';
  ELSE
    RAISE NOTICE 'tenant_id already exists in keluarga';
  END IF;

  -- ============================================================
  -- STEP 3: Drop dead index on non-existent column
  -- ============================================================
  DROP INDEX IF EXISTS public.idx_keluarga_kepala;
  RAISE NOTICE 'Dropped dead index idx_keluarga_kepala';

  -- ============================================================
  -- STEP 4: Drop dead columns rt_id and rw_id
  -- ============================================================
  -- Check if columns exist before dropping
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'penduduk'
      AND column_name = 'rt_id'
  ) THEN
    ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rt_id;
    RAISE NOTICE 'Dropped column rt_id from penduduk';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'penduduk'
      AND column_name = 'rw_id'
  ) THEN
    ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rw_id;
    RAISE NOTICE 'Dropped column rw_id from penduduk';
  END IF;

  -- ============================================================
  -- STEP 5: Fix keluarga trigger — remove reference to status_kk
  -- ============================================================
  -- Drop existing trigger function if it has the bug
  DROP TRIGGER IF EXISTS trigger_publish_keluarga_event ON public.keluarga;
  DROP FUNCTION IF EXISTS public.trigger_publish_keluarga_event();

  -- Recreate trigger function WITHOUT status_kk reference
  CREATE OR REPLACE FUNCTION public.trigger_publish_keluarga_event()
  RETURNS TRIGGER LANGUAGE plpgsql
  SECURITY DEFINER SET search_path = public
  AS $$
  DECLARE
    _tenant_id UUID;
  BEGIN
    -- Get tenant_id from the keluarga record
    _tenant_id := NEW.tenant_id;

    -- Publish created event
    INSERT INTO public.domain_events (tenant_id, entity_type, entity_id, event_type, payload)
    VALUES (
      _tenant_id,
      'keluarga',
      NEW.id,
      'keluarga.dibuat',
      jsonb_build_object(
        'no_kk', NEW.no_kk,
        'kepala_nama', NEW.kepala_nama,
        'dusun', NEW.dusun,
        'alamat', NEW.alamat
      )
    );

    -- Publish data changed event for UPDATE
    IF TG_OP = 'UPDATE' THEN
      INSERT INTO public.domain_events (tenant_id, entity_type, entity_id, event_type, payload)
      VALUES (
        _tenant_id,
        'keluarga',
        NEW.id,
        'keluarga.data.berubah',
        jsonb_build_object(
          'no_kk', NEW.no_kk,
          'kepala_nama', NEW.kepala_nama,
          'dusun', NEW.dusun,
          'alamat', NEW.alamat
        )
      );
    END IF;

    RETURN NEW;
  END;
  $$;

  -- Recreate trigger
  CREATE TRIGGER trigger_publish_keluarga_event
    AFTER INSERT OR UPDATE ON public.keluarga
    FOR EACH ROW EXECUTE FUNCTION public.trigger_publish_keluarga_event();

  RAISE NOTICE 'Fixed keluarga trigger — removed status_kk reference';

  -- ============================================================
  -- STEP 6: Add NIK validation CHECK constraint
  -- ============================================================
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND table_name = 'penduduk'
      AND constraint_name = 'chk_nik_16_digit'
  ) THEN
    ALTER TABLE public.penduduk
      ADD CONSTRAINT chk_nik_16_digit
      CHECK (char_length(nik) = 16 AND nik ~ '^[0-9]{16}$');
    RAISE NOTICE 'Added NIK 16-digit validation constraint';
  END IF;

  -- ============================================================
  -- STEP 7: Fix double RLS policies on penduduk
  -- ============================================================
  -- Remove old role-based policies, keep tenant-isolation policies
  DROP POLICY IF EXISTS "penduduk admin all" ON public.penduduk;

  -- Ensure tenant-isolation SELECT policy exists
  DROP POLICY IF EXISTS "Tenant isolation: penduduk read" ON public.penduduk;
  CREATE POLICY "Tenant isolation: penduduk read"
    ON public.penduduk FOR SELECT
    TO authenticated
    USING (tenant_id = get_tenant_id());

  -- Ensure tenant-isolation INSERT policy
  DROP POLICY IF EXISTS "Tenant isolation: penduduk insert" ON public.penduduk;
  CREATE POLICY "Tenant isolation: penduduk insert"
    ON public.penduduk FOR INSERT
    TO authenticated
    WITH CHECK (tenant_id = get_tenant_id());

  -- Ensure tenant-isolation UPDATE policy
  DROP POLICY IF EXISTS "Tenant isolation: penduduk update" ON public.penduduk;
  CREATE POLICY "Tenant isolation: penduduk update"
    ON public.penduduk FOR UPDATE
    TO authenticated
    USING (tenant_id = get_tenant_id());

  -- Ensure tenant-isolation DELETE policy
  DROP POLICY IF EXISTS "Tenant isolation: penduduk delete" ON public.penduduk;
  CREATE POLICY "Tenant isolation: penduduk delete"
    ON public.penduduk FOR DELETE
    TO authenticated
    USING (tenant_id = get_tenant_id());

  -- Admin role can do anything (service_role bypasses RLS anyway)
  CREATE POLICY "Admin full access to penduduk"
    ON public.penduduk FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));

  RAISE NOTICE 'Fixed RLS policies on penduduk';

  -- ============================================================
  -- STEP 8: Fix double RLS policies on keluarga
  -- ============================================================
  DROP POLICY IF EXISTS "keluarga admin all" ON public.keluarga;

  DROP POLICY IF EXISTS "Tenant isolation: keluarga read" ON public.keluarga;
  CREATE POLICY "Tenant isolation: keluarga read"
    ON public.keluarga FOR SELECT
    TO authenticated
    USING (tenant_id = get_tenant_id());

  DROP POLICY IF EXISTS "Tenant isolation: keluarga write" ON public.keluarga;
  CREATE POLICY "Tenant isolation: keluarga write"
    ON public.keluarga FOR ALL
    TO authenticated
    USING (tenant_id = get_tenant_id());

  CREATE POLICY "Admin full access to keluarga"
    ON public.keluarga FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));

  RAISE NOTICE 'Fixed RLS policies on keluarga';

  -- ============================================================
  -- STEP 9: Grant has_role to authenticated
  -- ============================================================
  GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated;

END $outer$;

-- ============================================================
-- STEP 10: Add missing indexes (new)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_penduduk_nik_tenant
  ON public.penduduk(tenant_id, nik);

CREATE INDEX IF NOT EXISTS idx_penduduk_status_hidup
  ON public.penduduk(tenant_id, status_hidup);

CREATE INDEX IF NOT EXISTS idx_keluarga_no_kk_tenant
  ON public.keluarga(tenant_id, no_kk);

-- ============================================================
-- STEP 11: Create penduduk_statistik view if not exists
-- ============================================================
CREATE OR REPLACE VIEW public.penduduk_statistik AS
SELECT
  p.tenant_id,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup') AS jumlah_penduduk,
  COUNT(DISTINCT k.id) FILTER (WHERE k.id IS NOT NULL) AS jumlah_kk,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'L') AS laki_laki,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'P') AS perempuan,
  COUNT(DISTINCT p.dusun) FILTER (WHERE p.dusun IS NOT NULL) AS jumlah_dusun
FROM public.penduduk p
LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
WHERE p.status_hidup IN ('hidup', 'meninggal', 'pindah')
GROUP BY p.tenant_id;

-- ============================================================
-- STEP 12: Create penduduk_per_dusun view if not exists
-- ============================================================
CREATE OR REPLACE VIEW public.penduduk_per_dusun AS
SELECT
  p.tenant_id,
  p.dusun,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup') AS jumlah_penduduk,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'L') AS laki_laki,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'P') AS perempuan,
  COUNT(DISTINCT k.id) FILTER (WHERE k.id IS NOT NULL) AS jumlah_kk
FROM public.penduduk p
LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
WHERE p.dusun IS NOT NULL
GROUP BY p.tenant_id, p.dusun;

-- ============================================================
-- STEP 13: Grant access to views
-- ============================================================
GRANT SELECT ON public.penduduk_statistik TO anon, authenticated;
GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;
