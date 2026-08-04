-- Fix: publish_site_draft and restore_site_version reference non-existent `id` column in page_config
-- page_config PK is `route` (text), not UUID. entitas_id is UUID but page_config uses route text.
-- Fix 1: publish_site_draft INSERT path - RETURNING route not id
-- Fix 2: publish_site_draft UPDATE path - WHERE route = d.entitas_id
-- Fix 3: restore_site_version UPDATE path - WHERE route = v.entitas_id

CREATE OR REPLACE FUNCTION public.publish_site_draft(_draft_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE d RECORD; new_id UUID; v_route TEXT;
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
      RETURNING route INTO v_route;
      new_id := NULL; -- route is text, not UUID; caller uses entitas_id set below
    ELSE
      UPDATE public.page_config SET
        eyebrow=COALESCE(d.payload->>'eyebrow', eyebrow),
        judul=COALESCE(d.payload->>'judul', judul),
        deskripsi=d.payload->>'deskripsi',
        hero_image_url=d.payload->>'hero_image_url',
        section_titles=COALESCE(d.payload->'section_titles', section_titles)
      WHERE route = d.entitas_id; -- entitas_id stores the route text for page_config
      v_route := d.entitas_id;
      new_id := NULL;
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
  RETURN COALESCE(new_id, d.entitas_id);
END; $function$;

CREATE OR REPLACE FUNCTION public.restore_site_version(_version_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    WHERE route = v.entitas_id; -- entitas_id stores the route text for page_config
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
END; $function$;
