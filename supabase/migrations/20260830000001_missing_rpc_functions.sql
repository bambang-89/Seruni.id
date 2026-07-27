-- ============================================================
-- MIGRATION: 20260830000001_missing_rpc_functions.sql
-- Date: 2026-08-30
-- Creates missing RPC functions called by frontend Admin components
-- ============================================================

-- 1. publish_site_draft - publishes a draft site content
CREATE OR REPLACE FUNCTION public.publish_site_draft(
  _draft_id UUID,
  _catatan TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_published_at TIMESTAMPTZ;
BEGIN
  v_published_at := now();

  UPDATE public.site_draft
  SET
    status = 'published',
    published_at = v_published_at,
    published_by = auth.uid()
  WHERE id = _draft_id
    AND status != 'published';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Draft not found or already published');
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'published_at', v_published_at
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.publish_site_draft(UUID, TEXT) TO authenticated;

-- 2. rollback_site_draft - reverts a published draft back to draft
CREATE OR REPLACE FUNCTION public.rollback_site_draft(
  _draft_id UUID,
  _catatan TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.site_draft
  SET
    status = 'draft',
    published_at = NULL,
    published_by = NULL
  WHERE id = _draft_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Draft not found');
  END IF;

  RETURN jsonb_build_object('success', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.rollback_site_draft(UUID, TEXT) TO authenticated;

-- 3. restore_site_version - creates a new draft from a version snapshot
CREATE OR REPLACE FUNCTION public.restore_site_version(_version_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_version RECORD;
  v_new_draft_id UUID;
  v_tenant_uuid UUID;
BEGIN
  -- Get the version record
  SELECT * INTO v_version FROM public.site_version WHERE id = _version_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Version not found');
  END IF;

  -- Determine tenant from the version or draft
  v_tenant_uuid := COALESCE(
    v_version.tenant_id,
    (SELECT tenant_id FROM public.site_draft WHERE id = v_version.draft_id LIMIT 1),
    (SELECT id FROM public.tenants LIMIT 1)
  );

  -- Create a new draft from the versioned content
  INSERT INTO public.site_draft (
    tenant_id,
    entity_type,
    entity_id,
    title,
    content,
    status,
    created_by
  ) VALUES (
    v_tenant_uuid,
    v_version.entity_type,
    v_version.entity_id,
    v_version.title || ' (Direstore)',
    v_version.content,
    'draft',
    auth.uid()
  ) RETURNING id INTO v_new_draft_id;

  RETURN jsonb_build_object(
    'success', true,
    'draft_id', v_new_draft_id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.restore_site_version(UUID) TO authenticated;

-- 4. tutup_voting_manual - manually closes a voting topic
CREATE OR REPLACE FUNCTION public.tutup_voting_manual(_topik_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_closed_at TIMESTAMPTZ;
  v_judul TEXT;
BEGIN
  v_closed_at := now();

  UPDATE public.voting_topik
  SET
    status = 'closed',
    closed_at = v_closed_at,
    closed_by = auth.uid()
  WHERE id = _topik_id
    AND status != 'closed'
  RETURNING judul INTO v_judul;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Topik voting not found or already closed');
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'closed_at', v_closed_at,
    'judul', v_judul
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.tutup_voting_manual(UUID) TO authenticated;
