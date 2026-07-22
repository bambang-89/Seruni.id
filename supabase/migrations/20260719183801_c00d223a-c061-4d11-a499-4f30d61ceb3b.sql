
-- =====================================================================
-- Phase 9 - Audit generic + WhatsApp broadcast persistence
-- =====================================================================

-- 1. Generic audit trigger --------------------------------------------
CREATE OR REPLACE FUNCTION public.log_admin_activity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _event TEXT;
  _payload JSONB;
  _id TEXT;
  _pub_old BOOLEAN;
  _pub_new BOOLEAN;
  _diff JSONB := '{}'::JSONB;
  _key TEXT;
  _oldv JSONB;
  _newv JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    _event := TG_TABLE_NAME || '.dibuat';
    _id := COALESCE((to_jsonb(NEW)->>'id'), '');
    _payload := jsonb_build_object('pk', _id);
    IF (to_jsonb(NEW) ? 'published') AND (to_jsonb(NEW)->>'published')::BOOLEAN THEN
      _event := TG_TABLE_NAME || '.dipublish';
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    _id := COALESCE((to_jsonb(NEW)->>'id'), '');
    -- publish/unpublish detection
    IF (to_jsonb(NEW) ? 'published') THEN
      _pub_old := (to_jsonb(OLD)->>'published')::BOOLEAN;
      _pub_new := (to_jsonb(NEW)->>'published')::BOOLEAN;
      IF _pub_old IS DISTINCT FROM _pub_new THEN
        _event := TG_TABLE_NAME || CASE WHEN _pub_new THEN '.dipublish' ELSE '.di_unpublish' END;
      END IF;
    END IF;
    IF _event IS NULL THEN
      _event := TG_TABLE_NAME || '.diubah';
    END IF;
    -- compute diff for changed columns (skip updated_at)
    FOR _key IN
      SELECT k FROM jsonb_object_keys(to_jsonb(NEW)) k
    LOOP
      IF _key = 'updated_at' THEN CONTINUE; END IF;
      _oldv := to_jsonb(OLD)->_key;
      _newv := to_jsonb(NEW)->_key;
      IF _oldv IS DISTINCT FROM _newv THEN
        _diff := _diff || jsonb_build_object(_key, jsonb_build_object('dari', _oldv, 'ke', _newv));
      END IF;
    END LOOP;
    _payload := jsonb_build_object('pk', _id, 'diff', _diff);
    IF _diff = '{}'::JSONB THEN
      RETURN NEW; -- nothing meaningful changed
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    _event := TG_TABLE_NAME || '.dihapus';
    _id := COALESCE((to_jsonb(OLD)->>'id'), '');
    _payload := jsonb_build_object('pk', _id, 'snapshot', to_jsonb(OLD));
  END IF;

  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
  VALUES (_event, TG_TABLE_NAME, NULLIF(_id, '')::UUID, _payload, auth.uid());

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- never block the write because of logging failure
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END; $$;

-- Drop old duplicative status triggers (replaced by generic audit)
DROP TRIGGER IF EXISTS trg_aduan_event ON public.aduan_warga;
DROP TRIGGER IF EXISTS trg_bencana_event ON public.bencana_kejadian;
DROP TRIGGER IF EXISTS trg_kegiatan_event ON public.kegiatan_pembangunan;

-- Attach generic audit trigger to all admin tables (idempotent)
DO $$
DECLARE
  t TEXT;
  tables TEXT[] := ARRAY[
    'berita','agenda','pengumuman','galeri',
    'desa_pamong','wilayah_dusun','lembaga_desa','profil_desa',
    'surat_jenis','surat_terbit','aduan_warga','langganan_wa',
    'apbdes','pbb_tagihan',
    'kegiatan_pembangunan','infrastruktur',
    'posyandu_agregat','stunting_agregat',
    'bantuan_sosial','penerima_bansos',
    'bencana_kejadian','dpt_pemilih','bidang_tanah',
    'potensi_umkm','potensi_produk','potensi_wisata'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON public.%I;', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();',
      t, t
    );
  END LOOP;
END $$;

-- 2. WhatsApp broadcast tables ----------------------------------------
CREATE TABLE IF NOT EXISTS public.wa_broadcast (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT,
  pesan TEXT NOT NULL,
  topik TEXT,
  dusun_filter TEXT,
  dry_run BOOLEAN NOT NULL DEFAULT false,
  dibuat_oleh UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'antri',
  total_target INT NOT NULL DEFAULT 0,
  total_sukses INT NOT NULL DEFAULT 0,
  total_gagal INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_broadcast TO authenticated;
GRANT ALL ON public.wa_broadcast TO service_role;

ALTER TABLE public.wa_broadcast ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin dapat mengelola wa_broadcast" ON public.wa_broadcast;
CREATE POLICY "Admin dapat mengelola wa_broadcast"
  ON public.wa_broadcast FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP TRIGGER IF EXISTS trg_wa_broadcast_updated ON public.wa_broadcast;
CREATE TRIGGER trg_wa_broadcast_updated
  BEFORE UPDATE ON public.wa_broadcast
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.wa_broadcast_target (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  broadcast_id UUID NOT NULL REFERENCES public.wa_broadcast(id) ON DELETE CASCADE,
  nomor_tujuan TEXT NOT NULL,
  nama TEXT,
  dusun TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  error_message TEXT,
  attempt INT NOT NULL DEFAULT 0,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.wa_broadcast_target TO authenticated;
GRANT ALL ON public.wa_broadcast_target TO service_role;

ALTER TABLE public.wa_broadcast_target ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin dapat mengelola wa_broadcast_target" ON public.wa_broadcast_target;
CREATE POLICY "Admin dapat mengelola wa_broadcast_target"
  ON public.wa_broadcast_target FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP TRIGGER IF EXISTS trg_wa_broadcast_target_updated ON public.wa_broadcast_target;
CREATE TRIGGER trg_wa_broadcast_target_updated
  BEFORE UPDATE ON public.wa_broadcast_target
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_wa_target_broadcast ON public.wa_broadcast_target(broadcast_id);
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_created ON public.wa_broadcast(created_at DESC);
