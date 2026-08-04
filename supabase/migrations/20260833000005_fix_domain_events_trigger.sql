CREATE OR REPLACE FUNCTION trigger_publish_surat_event()
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
      'jenis', NEW.jenis_nama,
      'nomor_surat', NEW.nomor_surat,
      'status', NEW.status
    );
    PERFORM publish_event('surat.diajukan', 'surat_terbit', NEW.id, v_payload, auth.uid());

  ELSIF TG_OP = 'UPDATE' THEN
    -- Status transitions
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'surat.diverifikasi';
        WHEN 'ditolak' THEN
          v_event_type := 'surat.ditolak';
        WHEN 'ditandatangani' THEN
          v_event_type := 'surat.ditandatangani';
        WHEN 'diterbitkan' THEN
          v_event_type := 'surat.diterbitkan';
        WHEN 'dikirim' THEN
          v_event_type := 'surat.dikirim';
        ELSE
          v_event_type := 'surat.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'nomor_surat', NEW.nomor_surat
      );
      PERFORM publish_event(v_event_type, 'surat_terbit', NEW.id, v_payload, auth.uid());
    END IF;

    -- Perubahan data lain
    IF OLD.nomor_surat IS DISTINCT FROM NEW.nomor_surat THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nomor_surat', jsonb_build_array(OLD.nomor_surat, NEW.nomor_surat)
        )
      );
      PERFORM publish_event('surat.data.berubah', 'surat_terbit', NEW.id, v_payload, auth.uid());
    END IF;
  END IF;

  RETURN NEW;
END;
$$;
