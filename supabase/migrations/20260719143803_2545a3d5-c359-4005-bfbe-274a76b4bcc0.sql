
-- Storage policies for seruni-media bucket
CREATE POLICY "Public read seruni-media"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'seruni-media');

CREATE POLICY "Admin upload seruni-media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admin update seruni-media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admin delete seruni-media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'seruni-media' AND public.has_role(auth.uid(), 'admin'));

-- Add cover_url columns for berita/agenda/pengumuman if missing
ALTER TABLE public.berita ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.desa_pamong ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE public.galeri ADD COLUMN IF NOT EXISTS foto_url TEXT;
