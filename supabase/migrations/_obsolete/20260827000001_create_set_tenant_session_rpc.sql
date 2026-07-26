-- ============================================================
-- Create set_tenant_session RPC function
-- Called by frontend to set app.current_tenant_id session variable
-- Usage: supabase.rpc('set_tenant_session', { tenant_id: 'uuid-here' })
-- ============================================================
CREATE OR REPLACE FUNCTION set_tenant_session(p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Validate tenant exists
  IF NOT EXISTS (SELECT 1 FROM public.tenants WHERE id = p_tenant_id) THEN
    RAISE EXCEPTION 'Invalid tenant_id: tenant does not exist';
  END IF;

  -- Set the session variable (LOCAL for transaction-scoped, or just SET)
  PERFORM set_config('app.current_tenant_id', p_tenant_id::text, true);

  RETURN true;
END;
$$;

-- Also create a wrapper that sets tenant from subdomain (convenience)
CREATE OR REPLACE FUNCTION set_tenant_session_by_subdomain(p_subdomain TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants WHERE subdomain = p_subdomain;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Invalid subdomain: %', p_subdomain;
  END IF;
  PERFORM set_config('app.current_tenant_id', v_tenant_id::text, true);
  RETURN true;
END;
$$;
