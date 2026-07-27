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

-- 2. Grant EXECUTE for has_role on all existing roles (redundant but explicit)
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, TEXT) TO supabase_admin;

-- 3. Fix page_hero_config trigger: update_updated_at_column() -> set_updated_at()
-- The trigger referenced a non-existent function name
DO $$
BEGIN
  -- Drop the incorrectly named trigger if it exists
  DROP TRIGGER IF EXISTS page_hero_config_updated ON public.page_hero_config;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  -- Recreate with the correct function name
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'page_hero_config_updated'
    AND tgrelid = 'public.page_hero_config'::regclass
  ) THEN
    CREATE TRIGGER page_hero_config_updated
      BEFORE UPDATE ON public.page_hero_config
      FOR EACH ROW
      EXECUTE FUNCTION public.set_updated_at();
  END IF;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Trigger creation skipped: %', SQLERRM;
END $$;
