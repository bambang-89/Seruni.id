
-- ============ 1. Voting hasil + auto close ============
ALTER TABLE public.voting_topik
  ADD COLUMN IF NOT EXISTS hasil_pemenang_id UUID REFERENCES public.voting_opsi(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS hasil_ringkasan TEXT,
  ADD COLUMN IF NOT EXISTS hasil_dipublikasi BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS hasil_dipublikasi_pada TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.auto_close_expired_voting()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
DECLARE t RECORD; winner_id UUID;
BEGIN
  FOR t IN SELECT id FROM public.voting_topik
    WHERE status = 'aktif' AND selesai IS NOT NULL AND selesai < now()
  LOOP
    SELECT id INTO winner_id FROM public.voting_opsi
      WHERE topik_id = t.id
      ORDER BY jumlah_suara DESC, urutan ASC
      LIMIT 1;
    UPDATE public.voting_topik
      SET status = 'ditutup',
          hasil_pemenang_id = winner_id,
          hasil_dipublikasi = true,
          hasil_dipublikasi_pada = now()
      WHERE id = t.id;
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload)
      VALUES ('voting_topik.ditutup_otomatis', 'voting_topik', t.id,
              jsonb_build_object('pemenang_id', winner_id));
  END LOOP;
END; $fn$;
REVOKE EXECUTE ON FUNCTION public.auto_close_expired_voting() FROM PUBLIC, anon, authenticated;

CREATE EXTENSION IF NOT EXISTS pg_cron;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'auto_close_voting') THEN
    PERFORM cron.schedule('auto_close_voting', '*/5 * * * *',
      'SELECT public.auto_close_expired_voting();');
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.tutup_voting_manual(_topik_id UUID, _ringkasan TEXT)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
DECLARE winner_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT id INTO winner_id FROM public.voting_opsi
    WHERE topik_id = _topik_id
    ORDER BY jumlah_suara DESC, urutan ASC LIMIT 1;
  UPDATE public.voting_topik
    SET status='ditutup',
        hasil_pemenang_id=winner_id,
        hasil_ringkasan=COALESCE(NULLIF(_ringkasan,''), hasil_ringkasan),
        hasil_dipublikasi=true,
        hasil_dipublikasi_pada=now()
    WHERE id=_topik_id;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES ('voting_topik.ditutup_manual','voting_topik',_topik_id,
            jsonb_build_object('pemenang_id', winner_id, 'ringkasan', _ringkasan), auth.uid());
  RETURN winner_id;
END; $fn$;
GRANT EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) TO authenticated;

-- ============ 2. Site version history ============
CREATE TABLE IF NOT EXISTS public.site_version (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entitas TEXT NOT NULL CHECK (entitas IN ('page_config','nav_item','footer_column')),
  entitas_id UUID NOT NULL,
  versi INT NOT NULL,
  snapshot JSONB NOT NULL,
  note TEXT,
  actor_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (entitas, entitas_id, versi)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_version TO authenticated;
GRANT ALL ON public.site_version TO service_role;
ALTER TABLE public.site_version ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin manage site_version" ON public.site_version;
CREATE POLICY "Admin manage site_version" ON public.site_version FOR ALL
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE OR REPLACE FUNCTION public.snapshot_site_config()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE next_ver INT; snap JSONB; rec_id UUID;
BEGIN
  snap := to_jsonb(OLD); rec_id := (OLD).id;
  SELECT COALESCE(MAX(versi),0)+1 INTO next_ver FROM public.site_version
    WHERE entitas=TG_TABLE_NAME AND entitas_id=rec_id;
  INSERT INTO public.site_version(entitas, entitas_id, versi, snapshot, actor_id, note)
    VALUES (TG_TABLE_NAME, rec_id, next_ver, snap, auth.uid(), TG_OP);
  IF TG_OP='DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  IF TG_OP='DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END; $fn$;

DROP TRIGGER IF EXISTS snap_page_config ON public.page_config;
DROP TRIGGER IF EXISTS snap_nav_item ON public.nav_item;
DROP TRIGGER IF EXISTS snap_footer_column ON public.footer_column;
CREATE TRIGGER snap_page_config BEFORE UPDATE OR DELETE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();
CREATE TRIGGER snap_nav_item BEFORE UPDATE OR DELETE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();
CREATE TRIGGER snap_footer_column BEFORE UPDATE OR DELETE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.snapshot_site_config();

CREATE OR REPLACE FUNCTION public.restore_site_version(_version_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE v RECORD;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO v FROM public.site_version WHERE id=_version_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'version not found'; END IF;
  IF v.entitas='page_config' THEN
    UPDATE public.page_config SET
      nama = COALESCE(v.snapshot->>'nama', nama),
      eyebrow = COALESCE(v.snapshot->>'eyebrow',''),
      judul = COALESCE(v.snapshot->>'judul',''),
      deskripsi = v.snapshot->>'deskripsi',
      hero_image_url = v.snapshot->>'hero_image_url',
      section_titles = COALESCE(v.snapshot->'section_titles','[]'::jsonb)
    WHERE id = v.entitas_id;
  ELSIF v.entitas='nav_item' THEN
    UPDATE public.nav_item SET
      label = COALESCE(v.snapshot->>'label', label),
      href = COALESCE(v.snapshot->>'href', href),
      parent_id = NULLIF(v.snapshot->>'parent_id','')::uuid,
      urutan = COALESCE((v.snapshot->>'urutan')::int, 0),
      deskripsi = v.snapshot->>'deskripsi',
      aktif = COALESCE((v.snapshot->>'aktif')::bool, true)
    WHERE id = v.entitas_id;
  ELSIF v.entitas='footer_column' THEN
    UPDATE public.footer_column SET
      judul = COALESCE(v.snapshot->>'judul', judul),
      links = COALESCE(v.snapshot->'links','[]'::jsonb),
      urutan = COALESCE((v.snapshot->>'urutan')::int, 0),
      aktif = COALESCE((v.snapshot->>'aktif')::bool, true)
    WHERE id = v.entitas_id;
  END IF;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (v.entitas || '.dipulihkan', v.entitas, v.entitas_id, jsonb_build_object('versi', v.versi), auth.uid());
END; $fn$;
GRANT EXECUTE ON FUNCTION public.restore_site_version(UUID) TO authenticated;

-- ============ 3. Staged drafts ============
CREATE TABLE IF NOT EXISTS public.site_draft (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entitas TEXT NOT NULL CHECK (entitas IN ('page_config','nav_item','footer_column')),
  entitas_id UUID,
  action TEXT NOT NULL DEFAULT 'update' CHECK (action IN ('update','create','delete')),
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','review','published','rolled_back','rejected')),
  catatan TEXT,
  actor_id UUID,
  reviewer_id UUID,
  reviewed_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  rollback_of UUID REFERENCES public.site_draft(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS site_draft_status_idx ON public.site_draft(status);
CREATE INDEX IF NOT EXISTS site_draft_entitas_idx ON public.site_draft(entitas, entitas_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_draft TO authenticated;
GRANT ALL ON public.site_draft TO service_role;
ALTER TABLE public.site_draft ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin manage site_draft" ON public.site_draft;
CREATE POLICY "Admin manage site_draft" ON public.site_draft FOR ALL
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

DROP TRIGGER IF EXISTS site_draft_updated_at ON public.site_draft;
CREATE TRIGGER site_draft_updated_at BEFORE UPDATE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS site_draft_audit ON public.site_draft;
CREATE TRIGGER site_draft_audit AFTER INSERT OR UPDATE OR DELETE ON public.site_draft
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE OR REPLACE FUNCTION public.publish_site_draft(_draft_id UUID)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE d RECORD; new_id UUID;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO d FROM public.site_draft WHERE id=_draft_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'draft not found'; END IF;
  IF d.status IN ('published','rolled_back','rejected') THEN
    RAISE EXCEPTION 'draft cannot be published in status %', d.status;
  END IF;

  IF d.action='delete' AND d.entitas_id IS NOT NULL THEN
    EXECUTE format('DELETE FROM public.%I WHERE id=$1', d.entitas) USING d.entitas_id;
    new_id := d.entitas_id;
  ELSIF d.entitas='page_config' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.page_config(route, nama, eyebrow, judul, deskripsi, hero_image_url, section_titles)
      VALUES (
        d.payload->>'route',
        COALESCE(d.payload->>'nama', d.payload->>'judul', d.payload->>'route'),
        COALESCE(d.payload->>'eyebrow',''),
        COALESCE(d.payload->>'judul',''),
        d.payload->>'deskripsi',
        d.payload->>'hero_image_url',
        COALESCE(d.payload->'section_titles','[]'::jsonb)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.page_config SET
        eyebrow=COALESCE(d.payload->>'eyebrow', eyebrow),
        judul=COALESCE(d.payload->>'judul', judul),
        deskripsi=d.payload->>'deskripsi',
        hero_image_url=d.payload->>'hero_image_url',
        section_titles=COALESCE(d.payload->'section_titles', section_titles)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  ELSIF d.entitas='nav_item' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.nav_item(label, href, parent_id, urutan, deskripsi, aktif)
      VALUES (
        d.payload->>'label', d.payload->>'href',
        NULLIF(d.payload->>'parent_id','')::uuid,
        COALESCE((d.payload->>'urutan')::int,0),
        d.payload->>'deskripsi',
        COALESCE((d.payload->>'aktif')::bool,true)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.nav_item SET
        label=COALESCE(d.payload->>'label', label),
        href=COALESCE(d.payload->>'href', href),
        parent_id=NULLIF(d.payload->>'parent_id','')::uuid,
        urutan=COALESCE((d.payload->>'urutan')::int, urutan),
        deskripsi=d.payload->>'deskripsi',
        aktif=COALESCE((d.payload->>'aktif')::bool, aktif)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  ELSIF d.entitas='footer_column' THEN
    IF d.entitas_id IS NULL THEN
      INSERT INTO public.footer_column(judul, links, urutan, aktif)
      VALUES (
        d.payload->>'judul',
        COALESCE(d.payload->'links','[]'::jsonb),
        COALESCE((d.payload->>'urutan')::int,0),
        COALESCE((d.payload->>'aktif')::bool,true)
      )
      RETURNING id INTO new_id;
    ELSE
      UPDATE public.footer_column SET
        judul=COALESCE(d.payload->>'judul', judul),
        links=COALESCE(d.payload->'links', links),
        urutan=COALESCE((d.payload->>'urutan')::int, urutan),
        aktif=COALESCE((d.payload->>'aktif')::bool, aktif)
      WHERE id = d.entitas_id;
      new_id := d.entitas_id;
    END IF;
  END IF;

  UPDATE public.site_draft SET
    status='published', published_at=now(),
    reviewer_id=COALESCE(reviewer_id, auth.uid()),
    reviewed_at=COALESCE(reviewed_at, now()),
    entitas_id=COALESCE(entitas_id, new_id)
    WHERE id = d.id;
  RETURN new_id;
END; $fn$;
GRANT EXECUTE ON FUNCTION public.publish_site_draft(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.rollback_site_draft(_draft_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $fn$
DECLARE d RECORD; last_ver RECORD;
BEGIN
  IF NOT public.has_role(auth.uid(),'admin') THEN RAISE EXCEPTION 'unauthorized'; END IF;
  SELECT * INTO d FROM public.site_draft WHERE id=_draft_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'draft not found'; END IF;
  IF d.status <> 'published' THEN RAISE EXCEPTION 'only published drafts can be rolled back'; END IF;
  IF d.entitas_id IS NULL THEN RAISE EXCEPTION 'no live entity to rollback'; END IF;
  SELECT * INTO last_ver FROM public.site_version
    WHERE entitas=d.entitas AND entitas_id=d.entitas_id
    ORDER BY versi DESC LIMIT 1;
  IF NOT FOUND THEN RAISE EXCEPTION 'no previous version available'; END IF;
  PERFORM public.restore_site_version(last_ver.id);
  UPDATE public.site_draft SET status='rolled_back' WHERE id=d.id;
  INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES ('site_draft.rolled_back', d.entitas, d.entitas_id,
            jsonb_build_object('draft_id', d.id, 'restored_version_id', last_ver.id), auth.uid());
END; $fn$;
GRANT EXECUTE ON FUNCTION public.rollback_site_draft(UUID) TO authenticated;
