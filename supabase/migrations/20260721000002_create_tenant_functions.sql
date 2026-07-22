-- ============================================================
-- MIGRASI: 20260721000002_create_tenant_functions.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Buat user_has_tenant_access dan tenant_filter yang
--            gagal di restore migration karena syntax error.
-- ============================================================

DROP FUNCTION IF EXISTS user_has_tenant_access(UUID, UUID);
CREATE FUNCTION user_has_tenant_access(p_user_id UUID, p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_peran
    WHERE user_id = p_user_id
      AND aktif = true
      AND peran IN ('admin', 'kades', 'sekdes')
  );
$$;

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
      EXISTS (SELECT 1 FROM public.user_peran WHERE user_id = auth.uid() AND peran = 'admin' LIMIT 1)
      OR
      COALESCE(current_setting('app.current_tenant_id', true)::uuid, p_tenant_id) = p_tenant_id
    );
$$;
