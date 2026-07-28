-- ============================================================
-- MIGRATION: 20260830000000_has_role_function.sql
-- Date: 2026-08-30
-- Fix: Create missing has_role() function used by 60+ RLS policies
-- ============================================================

-- 1. has_role(p_user_id UUID, p_role TEXT) RETURNS BOOLEAN
-- Checks if a user has a specific peran via user_peran table
-- Used by virtually ALL admin RLS policies in the codebase
CREATE OR REPLACE FUNCTION public.has_role(p_user_id UUID, p_role TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_peran
    WHERE user_id = p_user_id
      AND peran = p_role
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO supabase_admin;
