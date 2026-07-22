
-- Phase 4: Informasi (berita, agenda, pengumuman, galeri)

CREATE TABLE public.berita (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text NOT NULL UNIQUE,
  kategori text NOT NULL DEFAULT 'Umum',
  judul text NOT NULL,
  ringkasan text NOT NULL DEFAULT '',
  isi jsonb NOT NULL DEFAULT '[]'::jsonb,
  penulis text NOT NULL DEFAULT '',
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.berita TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.berita TO authenticated;
GRANT ALL ON public.berita TO service_role;
ALTER TABLE public.berita ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read berita" ON public.berita FOR SELECT TO anon, authenticated USING (published = true OR public.has_role(auth.uid(),'admin'));
CREATE POLICY "Admin write berita" ON public.berita FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_berita_updated BEFORE UPDATE ON public.berita FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.agenda (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text NOT NULL UNIQUE,
  jenis text NOT NULL DEFAULT 'Kegiatan',
  judul text NOT NULL,
  tanggal date NOT NULL,
  waktu text NOT NULL DEFAULT '',
  lokasi text NOT NULL DEFAULT '',
  penyelenggara text NOT NULL DEFAULT '',
  deskripsi text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.agenda TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.agenda TO authenticated;
GRANT ALL ON public.agenda TO service_role;
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read agenda" ON public.agenda FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write agenda" ON public.agenda FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_agenda_updated BEFORE UPDATE ON public.agenda FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.pengumuman (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nomor text NOT NULL,
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  judul text NOT NULL,
  ringkasan text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.pengumuman TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pengumuman TO authenticated;
GRANT ALL ON public.pengumuman TO service_role;
ALTER TABLE public.pengumuman ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read pengumuman" ON public.pengumuman FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write pengumuman" ON public.pengumuman FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_pengumuman_updated BEFORE UPDATE ON public.pengumuman FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.galeri (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  judul text NOT NULL,
  emoji text NOT NULL DEFAULT '📷',
  album text NOT NULL DEFAULT 'Umum',
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  urutan integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.galeri TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.galeri TO authenticated;
GRANT ALL ON public.galeri TO service_role;
ALTER TABLE public.galeri ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read galeri" ON public.galeri FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admin write galeri" ON public.galeri FOR ALL TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_galeri_updated BEFORE UPDATE ON public.galeri FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
