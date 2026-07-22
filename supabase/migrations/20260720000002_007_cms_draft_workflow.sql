-- ============================================================
-- MIGRASI: 20260720000002_007_cms_draft_workflow.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Enhance site_draft dengan multi-tenancy + workflow lengkap
--
-- Workflow: draft → review → publish (dengan approval)
-- Tenant-aware untuk multi-tenant
-- ============================================================

-- ============================================================
-- 1. Add tenant_id + extend site_draft
-- ============================================================

ALTER TABLE public.site_draft
  ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;

ALTER TABLE public.site_version
  ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;

-- ============================================================
-- 2. Extend Workflow Status
-- ============================================================

-- Extend status check untuk termasuk 'approved'
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'site_draft_status_check'
  ) THEN
    ALTER TABLE public.site_draft
      DROP CONSTRAINT IF EXISTS site_draft_status_check;
    ALTER TABLE public.site_draft
      ADD CONSTRAINT site_draft_status_check
      CHECK (status IN ('draft', 'review', 'approved', 'published', 'rejected', 'rolled_back'));
  END IF;
END $$;

-- ============================================================
-- 3. Workflow Functions
-- ============================================================

-- Submit draft for review
CREATE OR REPLACE FUNCTION public.submit_draft_for_review(_draft_id UUID, _catatan TEXT DEFAULT NULL)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE public.site_draft
  SET status = 'review',
      catatan = COALESCE(_catatan, catatan)
  WHERE id = _draft_id
    AND status = 'draft'
  RETURNING tenant_id INTO v_tenant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found or cannot be submitted for review';
  END IF;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.submitted_for_review',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_draft_for_review(UUID, TEXT) TO authenticated;

-- Approve draft
CREATE OR REPLACE FUNCTION public.approve_draft(_draft_id UUID, _catatan TEXT DEFAULT NULL)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_draft RECORD;
  v_tenant_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT * INTO v_draft FROM public.site_draft WHERE id = _draft_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found';
  END IF;

  IF v_draft.status NOT IN ('draft', 'review') THEN
    RAISE EXCEPTION 'Draft cannot be approved in status: %', v_draft.status;
  END IF;

  UPDATE public.site_draft
  SET status = 'approved',
      reviewer_id = auth.uid(),
      reviewed_at = now(),
      catatan = COALESCE(_catatan, catatan)
  WHERE id = _draft_id;

  v_tenant_id := v_draft.tenant_id;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.approved',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_draft(UUID, TEXT) TO authenticated;

-- Reject draft
CREATE OR REPLACE FUNCTION public.reject_draft(_draft_id UUID, _catatan TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  UPDATE public.site_draft
  SET status = 'rejected',
      reviewer_id = auth.uid(),
      reviewed_at = now(),
      catatan = _catatan
  WHERE id = _draft_id
    AND status IN ('draft', 'review', 'approved')
  RETURNING id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Draft not found or cannot be rejected';
  END IF;

  -- Emit domain event
  PERFORM publish_event(
    'cms.draft.rejected',
    'site_draft',
    _draft_id,
    jsonb_build_object('catatan', _catatan),
    auth.uid()
  );

  RETURN _draft_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.reject_draft(UUID, TEXT) TO authenticated;

-- ============================================================
-- 4. View: Draft Queue (untuk review dashboard)
-- ============================================================

CREATE OR REPLACE VIEW public.draft_queue AS
SELECT
  sd.id,
  sd.tenant_id,
  sd.entitas,
  sd.entitas_id,
  sd.action,
  sd.payload,
  sd.status,
  sd.catatan,
  sd.actor_id,
  ap.nama AS actor_nama,
  sd.reviewer_id,
  rp.nama AS reviewer_nama,
  sd.reviewed_at,
  sd.published_at,
  sd.created_at,
  sd.updated_at,
  CASE sd.status
    WHEN 'draft' THEN '💾 Draft'
    WHEN 'review' THEN '👀 Menunggu Review'
    WHEN 'approved' THEN '✅ Disetujui'
    WHEN 'published' THEN '🚀 Published'
    WHEN 'rejected' THEN '❌ Ditolak'
    WHEN 'rolled_back' THEN '↩️ Di-rollback'
    ELSE sd.status
  END AS status_label
FROM public.site_draft sd
LEFT JOIN public.admin_profiles ap ON ap.id = sd.actor_id
LEFT JOIN public.admin_profiles rp ON rp.id = sd.reviewer_id
ORDER BY sd.updated_at DESC;

GRANT SELECT ON public.draft_queue TO authenticated;

-- ============================================================
-- 5. Notification: New draft for review
-- ============================================================

CREATE OR REPLACE FUNCTION public.notify_new_draft_for_review()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_actor_nama TEXT;
  v_entity_label TEXT;
BEGIN
  IF NEW.status = 'review' AND (OLD.status IS NULL OR OLD.status = 'draft') THEN
    -- Get actor name
    SELECT nama INTO v_actor_nama
    FROM admin_profiles WHERE id = NEW.actor_id;

    -- Get entity label
    v_entity_label := INITCAP(REPLACE(NEW.entitas, '_', ' '));

    -- Emit event for WA notification
    PERFORM publish_event(
      'cms.draft.membutuhkan_review',
      'site_draft',
      NEW.id,
      jsonb_build_object(
        'entitas', NEW.entitas,
        'action', NEW.action,
        'actor_nama', v_actor_nama,
        'entity_label', v_entity_label,
        'catatan', NEW.catatan
      ),
      NEW.actor_id
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_new_draft_review ON public.site_draft;
CREATE TRIGGER trg_notify_new_draft_review
  AFTER INSERT OR UPDATE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_draft_for_review();

-- ============================================================
-- 6. Seed: Initial content placeholders
-- ============================================================

-- Check if page_config has data, if not seed with defaults
DO $$
DECLARE
  cnt INT;
BEGIN
  SELECT COUNT(*) INTO cnt FROM public.page_config;
  IF cnt = 0 THEN
    INSERT INTO public.page_config (route, nama, eyebrow, judul, deskripsi) VALUES
    ('/', 'Beranda', 'Selamat Datang', 'Desa Seruni Mumbul', 'Portal resmi Kantor Desa Seruni Mumbul, Kec. Pringgabaya, Kab. Lombok Timur, NTB'),
    ('/layanan/surat', 'Layanan Surat', 'Layanan', 'Surat Online', 'Ajukan surat keterangan secara online'),
    ('/layanan/pbb', 'PBB', 'Layanan', 'Tagihan PBB', 'Cek tagihan Pajak Bumi Bangunan'),
    ('/statistik/penduduk', 'Statistik', 'Demografi', 'Statistik Penduduk', 'Data dan statistik kependudukan'),
    ('/status-idm', 'Status IDM', 'Indeks Desa', 'Status IDM', 'Indeks Desa Membangun'),
    ('/perencanaan/rpjmdes', 'RPJMDes', 'Perencanaan', 'RPJMDes', 'Rencana Pembangunan Jangka Menengah Desa'),
    ('/partisipasi/voting', 'Voting', 'Partisipasi', 'Voting Warga', 'Suara Anda untuk pembangunan desa')
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================================
-- 7. Add indexes untuk performance
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_site_draft_tenant_status
  ON public.site_draft(tenant_id, status)
  WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_site_version_tenant
  ON public.site_version(tenant_id, entitas, created_at DESC)
  WHERE tenant_id IS NOT NULL;

-- ============================================================
-- DONE
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE 'CMS Draft Workflow migration completed. Tenant-aware draft system ready.';
END $$;
