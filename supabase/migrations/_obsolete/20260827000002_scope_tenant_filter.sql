-- ============================================================
-- MIGRASI: 20260827000002_scope_tenant_filter.sql
-- Tanggal: 2026-08-27
-- Deskripsi: CRITICAL fix — scope admin bypass to own tenant.
--
-- PROBLEM: The previous tenant_filter() granted ALL admins access to
-- ALL tenant data. An admin from Tenant A could read/write Tenant B's data.
--
-- FIX: Remove the admin bypass entirely. tenant_filter() now strictly
-- enforces that get_tenant_id() must match the target tenant_id.
-- Admins also need proper tenant context (set by middleware via
-- app.current_tenant_id). If get_tenant_id() is NULL (setting not set),
-- ALL access is DENIED — including admins.
--
-- DEPENDENCY: Requires app.current_tenant_id to be set by middleware
--             before every query. See blockers in task-4-report.md.
-- ============================================================

DROP FUNCTION IF EXISTS tenant_filter(UUID);
CREATE OR REPLACE FUNCTION tenant_filter(p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  -- Strict tenant isolation: get_tenant_id() must match target tenant_id.
  -- If get_tenant_id() returns NULL (app.current_tenant_id not set),
  -- access is DENIED for everyone — including admins.
  -- Admin bypass has been removed to prevent cross-tenant data access.
  SELECT auth.uid() IS NOT NULL
    AND get_tenant_id() = p_tenant_id;
$$;

-- ============================================================
-- Verify the new function
--
--   -- With tenant setting NOT set (default):
--   SELECT get_tenant_id();           -- Expected: NULL
--   SELECT tenant_filter('some-uuid'); -- Expected: false
--
--   -- With tenant setting set:
--   SET LOCAL app.current_tenant_id = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
--   SELECT get_tenant_id();           -- Expected: d532ae95-0ad9-42bb-a6e8-5c840447c90e
--   SELECT tenant_filter('d532ae95-0ad9-42bb-a6e8-5c840447c90e'); -- Expected: true
--   SELECT tenant_filter('other-tenant-uuid');                     -- Expected: false
-- ============================================================
