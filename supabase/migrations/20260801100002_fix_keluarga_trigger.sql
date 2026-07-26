-- ============================================================
-- FIX: trigger_publish_keluarga_event() wrong column names
-- Bug: trigger references NEW.nomor_kk and NEW.kepala_keluarga
-- Fix: correct to NEW.no_kk and NEW.kepala_nama
-- Also: keluarga table has NO created_by/updated_by columns
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_keluarga_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
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
    PERFORM publish_event('keluarga.dibuat', 'keluarga', NEW.id, v_payload, NULL);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status_kk IS DISTINCT FROM NEW.status_kk THEN
      v_payload := jsonb_build_object(
        'status_lama', OLD.status_kk,
        'status_baru', NEW.status_kk
      );
      PERFORM publish_event('keluarga.status.berubah', 'keluarga', NEW.id, v_payload, NULL);
    END IF;

    v_payload := jsonb_build_object(
      'no_kk', NEW.no_kk,
      'kepala_nama', NEW.kepala_nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event('keluarga.data.berubah', 'keluarga', NEW.id, v_payload, NULL);

  ELSIF TG_OP = 'DELETE' THEN
    v_payload := jsonb_build_object(
      'no_kk', OLD.no_kk,
      'kepala_nama', OLD.kepala_nama
    );
    PERFORM publish_event('keluarga.dihapus', 'keluarga', OLD.id, v_payload, NULL);
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Verify
SELECT 'trigger_publish_keluarga_event() re-created OK' AS status;
