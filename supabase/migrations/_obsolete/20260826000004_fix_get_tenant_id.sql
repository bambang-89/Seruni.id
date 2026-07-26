-- ============================================================
-- MIGRASI: 20260826000004_fix_get_tenant_id.sql
-- Tanggal: 2026-08-26
-- Deskripsi: Replace get_tenant_id() with strict version — no hardcoded fallback.
--             Also update tenant_filter() to match.
-- CRITICAL: This is a ZERO-FALLBACK implementation.
--            If app.current_tenant_id is NOT set, get_tenant_id() returns NULL.
--            RLS policies using get_tenant_id() will then DENY access (NULL != any tenant_id).
--            The application MUST set app.current_tenant_id before every query that uses tenant-isolated tables.
--
-- DEPENDENCY: Requires middleware/client to set app.current_tenant_id.
--             See blockers in task-4-report.md.
-- ============================================================

-- ============================================================
-- 1. Replace get_tenant_id() with strict version
--
-- OLD (VULNERABLE):
--   SELECT COALESCE(
--     current_setting('app.current_tenant_id', true)::uuid,
--     (SELECT id FROM tenants WHERE subdomain = 'seruni' LIMIT 1)
--   );
--
-- NEW (STRICT):
--   SELECT NULLIF(current_setting('app.current_tenant_id', true)::uuid, '00000000-0000-0000-0000-000000000000'::uuid);
--
-- NULLIF handles the case where current_setting returns empty string or invalid UUID —
-- it converts to NULL instead of throwing a cast error. This is safer than bare ::uuid.
-- If the setting is not set, get_tenant_id() returns NULL, and RLS denies access.
-- ============================================================
CREATE OR REPLACE FUNCTION get_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT NULLIF(current_setting('app.current_tenant_id', true)::uuid, '00000000-0000-0000-0000-000000000000'::uuid);
$$;

-- ============================================================
-- 2. Replace tenant_filter() to work with strict get_tenant_id()
--
-- Logic:
--   - Admin users bypass tenant isolation (they can see all tenant data)
--   - Non-admin users: get_tenant_id() must match the target tenant_id
--   - If get_tenant_id() returns NULL (setting not set), access is DENIED
-- ============================================================
DROP FUNCTION IF EXISTS tenant_filter(UUID);
CREATE FUNCTION tenant_filter(p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.uid() IS NOT NULL
    AND (
      -- Admin bypass: any admin can access any tenant's data
      EXISTS (SELECT 1 FROM public.user_peran WHERE user_id = auth.uid() AND peran = 'admin' LIMIT 1)
      OR
      -- Tenant match: get_tenant_id() returns NULL if setting not set = DENIED
      get_tenant_id() = p_tenant_id
    );
$$;

-- ============================================================
-- 3. Verify the new functions
-- Run these to confirm:
--
--   SELECT get_tenant_id();
--   -- Expected: NULL (because no setting is set in this session)
--
--   SELECT tenant_filter(NULL::uuid);
--   -- Expected: false (NULL tenant = denied)
--
--   -- To test with a setting:
--   SET LOCAL app.current_tenant_id = '<actual-tenant-uuid>';
--   SELECT get_tenant_id();
--   -- Expected: the UUID you set
-- ============================================================
