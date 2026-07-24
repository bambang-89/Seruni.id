-- ============================================================
-- Migration: 20260724190001_fix_keluarga_trigger.sql
-- Fix trigger_publish_keluarga_event — remove status_kk reference
--
-- ROOT CAUSE: Trigger references OLD.status_kk / NEW.status_kk
-- which doesn't exist in keluarga table (only no_kk, kepala_nama, etc.)
--
-- Uses publish_event() from existing domain_events migration.
-- Idempotent: DROP + CREATE
-- ============================================================

-- Drop trigger first (removes dependency on function)
DROP TRIGGER IF EXISTS trg_keluarga_publish_event ON public.keluarga;
DROP TRIGGER IF EXISTS trigger_publish_keluarga_event ON public.keluarga;

-- Drop existing function
DROP FUNCTION IF EXISTS public.trigger_publish_keluarga_event();

-- Recreate: uses ONLY columns that actually exist in keluarga table
CREATE OR REPLACE FUNCTION public.trigger_publish_keluarga_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'no_kk', NEW.no_kk,
      'kepala_nama', NEW.kepala_nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event('keluarga.dibuat', 'keluarga', NEW.id, v_payload, NEW.tenant_id);

  ELSIF TG_OP = 'UPDATE' THEN
    v_payload := jsonb_build_object(
      'no_kk', NEW.no_kk,
      'kepala_nama', NEW.kepala_nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event('keluarga.data.berubah', 'keluarga', NEW.id, v_payload, NEW.tenant_id);

  ELSIF TG_OP = 'DELETE' THEN
    v_payload := jsonb_build_object(
      'no_kk', OLD.no_kk,
      'kepala_nama', OLD.kepala_nama
    );
    PERFORM publish_event('keluarga.dihapus', 'keluarga', OLD.id, v_payload, OLD.tenant_id);
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Recreate trigger (INSERT + UPDATE + DELETE)
CREATE TRIGGER trg_keluarga_publish_event
  AFTER INSERT OR UPDATE OR DELETE ON public.keluarga
  FOR EACH ROW EXECUTE FUNCTION public.trigger_publish_keluarga_event();
