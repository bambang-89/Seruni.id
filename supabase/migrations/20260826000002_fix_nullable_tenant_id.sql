-- ============================================================
-- MIGRASI: 20260826000002_fix_nullable_tenant_id.sql
-- Tanggal: 2026-08-26
-- Deskripsi: Make tenant_id NOT NULL on event_log and domain_events,
--            add FK constraints to tenants(id).
-- Idempotent: safe to run multiple times.
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

-- ============================================================
-- event_log.tenant_id
-- NOTE: column may not exist yet (was missing from remote DB)
-- ============================================================

-- Step 1: Add column if missing
IF NOT EXISTS (
  SELECT 1 FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'event_log'
    AND column_name = 'tenant_id'
) THEN
  ALTER TABLE public.event_log ADD COLUMN tenant_id UUID;
  RAISE NOTICE 'Added tenant_id column to event_log';
END IF;

-- Step 2: Backfill NULL values
UPDATE public.event_log SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
RAISE NOTICE 'Backfilled event_log tenant_id: % rows updated',
  (SELECT count(*) FROM event_log WHERE tenant_id = v_tenant_id);

-- Step 3: Set NOT NULL (ignore if already NOT NULL)
IF EXISTS (
  SELECT 1 FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'event_log'
    AND column_name = 'tenant_id'
    AND is_nullable = 'YES'
) THEN
  ALTER TABLE public.event_log ALTER COLUMN tenant_id SET NOT NULL;
  RAISE NOTICE 'Set event_log.tenant_id NOT NULL';
ELSE
  RAISE NOTICE 'event_log.tenant_id is already NOT NULL';
END IF;

-- Step 4: Add FK constraint (idempotent via exception handling)
BEGIN
  ALTER TABLE public.event_log
    ADD CONSTRAINT event_log_tenant_id_fkey
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
  RAISE NOTICE 'Added event_log_tenant_id_fkey constraint';
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'event_log_tenant_id_fkey already exists, skipping';
END;

-- ============================================================
-- domain_events.tenant_id
-- NOTE: column already exists on remote with all values populated
-- ============================================================

-- Step 1: Backfill NULL values (should be 0, but defensive)
UPDATE public.domain_events SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
RAISE NOTICE 'Backfilled domain_events tenant_id: % rows updated',
  (SELECT count(*) FROM domain_events WHERE tenant_id = v_tenant_id);

-- Step 2: Set NOT NULL (ignore if already NOT NULL)
IF EXISTS (
  SELECT 1 FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'domain_events'
    AND column_name = 'tenant_id'
    AND is_nullable = 'YES'
) THEN
  ALTER TABLE public.domain_events ALTER COLUMN tenant_id SET NOT NULL;
  RAISE NOTICE 'Set domain_events.tenant_id NOT NULL';
ELSE
  RAISE NOTICE 'domain_events.tenant_id is already NOT NULL';
END IF;

-- Step 3: Add FK constraint (idempotent via exception handling)
BEGIN
  ALTER TABLE public.domain_events
    ADD CONSTRAINT domain_events_tenant_id_fkey
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
  RAISE NOTICE 'Added domain_events_tenant_id_fkey constraint';
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'domain_events_tenant_id_fkey already exists, skipping';
END;

-- ============================================================
-- Indexes for query performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_event_log_tenant ON public.event_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_domain_events_tenant ON public.domain_events(tenant_id);

END $$;

-- Verification queries (run separately):
-- SELECT count(*) FROM event_log WHERE tenant_id IS NULL;  -- must return 0
-- SELECT count(*) FROM domain_events WHERE tenant_id IS NULL;  -- must return 0
-- SELECT column_name, is_nullable FROM information_schema.columns
--   WHERE table_name IN ('event_log', 'domain_events') AND column_name = 'tenant_id';
-- SELECT conname FROM pg_constraint WHERE conrelid IN ('event_log'::regclass, 'domain_events'::regclass)
--   AND conname LIKE '%tenant_id%';
