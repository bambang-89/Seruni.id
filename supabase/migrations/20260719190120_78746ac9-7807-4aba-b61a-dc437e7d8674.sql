
-- ===== page_config: hero + section titles per public route =====
CREATE TABLE public.page_config (
  route TEXT PRIMARY KEY,
  nama TEXT NOT NULL,
  eyebrow TEXT NOT NULL DEFAULT '',
  judul TEXT NOT NULL DEFAULT '',
  deskripsi TEXT,
  hero_image_url TEXT,
  section_titles JSONB NOT NULL DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.page_config TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.page_config TO authenticated;
GRANT ALL ON public.page_config TO service_role;
ALTER TABLE public.page_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "page_config read public"  ON public.page_config FOR SELECT USING (true);
CREATE POLICY "page_config admin write"  ON public.page_config FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_page_config_updated BEFORE UPDATE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_page_config_log AFTER INSERT OR UPDATE OR DELETE ON public.page_config
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== nav_item: navbar hierarkis =====
CREATE TABLE public.nav_item (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.nav_item(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  href TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_nav_item_parent ON public.nav_item(parent_id, urutan);
GRANT SELECT ON public.nav_item TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.nav_item TO authenticated;
GRANT ALL ON public.nav_item TO service_role;
ALTER TABLE public.nav_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY "nav_item read public" ON public.nav_item FOR SELECT USING (true);
CREATE POLICY "nav_item admin write" ON public.nav_item FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_nav_item_updated BEFORE UPDATE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_nav_item_log AFTER INSERT OR UPDATE OR DELETE ON public.nav_item
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== footer_column =====
CREATE TABLE public.footer_column (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  links JSONB NOT NULL DEFAULT '[]'::jsonb,  -- [{label, href}]
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.footer_column TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.footer_column TO authenticated;
GRANT ALL ON public.footer_column TO service_role;
ALTER TABLE public.footer_column ENABLE ROW LEVEL SECURITY;
CREATE POLICY "footer_column read public" ON public.footer_column FOR SELECT USING (true);
CREATE POLICY "footer_column admin write" ON public.footer_column FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_footer_column_updated BEFORE UPDATE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_footer_column_log AFTER INSERT OR UPDATE OR DELETE ON public.footer_column
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

-- ===== Seed page_config: semua rute publik =====
INSERT INTO public.page_config (route, nama, eyebrow, judul, deskripsi) VALUES
  ('/',                       'Beranda',            'Portal Desa',      'Beranda Desa',           'Halaman utama portal desa.'),
  ('/profil-desa',            'Profil Desa',        'Tentang',          'Profil Desa',            'Sejarah, visi, dan misi desa.'),
  ('/profil-desa/struktur',   'Struktur Pamong',    'Pemerintahan',     'Struktur Pamong',        'Susunan kepala desa dan perangkatnya.'),
  ('/profil-desa/wilayah',    'Wilayah Dusun',      'Geografis',        'Wilayah Dusun',          'Batas administratif dan dusun.'),
  ('/profil-desa/lembaga',    'Lembaga Desa',       'Kelembagaan',      'Lembaga Desa',           'BPD, LPM, PKK, dan Karang Taruna.'),
  ('/berita',                 'Berita',             'Informasi',        'Berita Terkini',         'Kabar terbaru dari desa.'),
  ('/kalender-desa',          'Kalender Desa',      'Agenda',           'Kalender Kegiatan',      'Jadwal kegiatan resmi desa.'),
  ('/galeri',                 'Galeri',             'Dokumentasi',      'Galeri Foto',            'Dokumentasi kegiatan desa.'),
  ('/pengumuman',             'Pengumuman',         'Maklumat',         'Pengumuman Resmi',       'Informasi resmi pemerintah desa.'),
  ('/layanan',                'Layanan Desa',       'Pelayanan',        'Layanan Warga',          'Semua layanan administratif desa.'),
  ('/layanan/surat',          'Layanan Surat',      'Administrasi',     'Layanan Surat',          'Ajukan surat administrasi.'),
  ('/layanan/pbb',            'Layanan PBB',        'Pajak',            'Cek PBB',                'Cek tagihan Pajak Bumi & Bangunan.'),
  ('/service-center',         'Service Center',     'Pengaduan',        'Service Center',         'Sampaikan aduan & aspirasi warga.'),
  ('/verifikasi',             'Verifikasi Dokumen', 'Keaslian',         'Verifikasi Dokumen',     'Cek keaslian dokumen desa.'),
  ('/statistik',              'Statistik',          'Data',             'Statistik Desa',         'Ringkasan data agregat desa.'),
  ('/status-idm',             'Status IDM',         'Indeks',           'Status IDM',             'Indeks Desa Membangun terkini.'),
  ('/statistik/penduduk',     'Statistik Penduduk', 'Demografi',        'Statistik Penduduk',     'Data kependudukan agregat.'),
  ('/pembangunan',            'Pembangunan',        'Infrastruktur',    'Pembangunan Desa',       'Progres kegiatan pembangunan.'),
  ('/perencanaan',            'Perencanaan',        'RKPDes',           'Perencanaan Desa',       'Usulan warga dan RKPDes.'),
  ('/keuangan',               'Keuangan',           'APBDes',           'Keuangan Desa',          'Rincian anggaran & realisasi.'),
  ('/potensi-desa',           'Potensi Desa',       'Potensi',          'Potensi Desa',           'UMKM, wisata, dan BUMDes.'),
  ('/marketplace',            'Marketplace',        'Ekonomi',          'Marketplace Desa',       'Produk unggulan warga.'),
  ('/peta-desa',              'Peta Desa',          'Peta',             'Peta Desa',              'Peta interaktif desa.'),
  ('/langganan-wa',           'Langganan WA',       'Notifikasi',       'Langganan WhatsApp',     'Berlangganan info via WA.')
ON CONFLICT (route) DO NOTHING;

-- ===== Seed nav_item: 7 kategori + submenu (mirror data.ts) =====
DO $$
DECLARE p_id UUID;
BEGIN
  -- Profil
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Profil','/profil-desa',1) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Sejarah','/profil-desa','Asal-usul, visi & misi desa',1),
    (p_id,'Struktur','/profil-desa/struktur','Kepala desa, pamong & perangkat',2),
    (p_id,'Wilayah','/profil-desa/wilayah','Batas, dusun, dan topografi',3),
    (p_id,'Lembaga','/profil-desa/lembaga','BPD, LPM, PKK & Karang Taruna',4);
  -- Informasi
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Informasi','/berita',2) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Berita','/berita','Kabar terbaru dari desa',1),
    (p_id,'Agenda','/kalender-desa','Kalender kegiatan resmi',2),
    (p_id,'Galeri','/galeri','Foto & video dokumentasi',3),
    (p_id,'Pengumuman','/pengumuman','Maklumat & informasi resmi',4);
  -- Layanan
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Layanan','/layanan',3) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'Surat','/layanan/surat','Ajukan surat administrasi online',1),
    (p_id,'Pengaduan','/service-center','Sampaikan aduan & aspirasi',2),
    (p_id,'PBB','/layanan/pbb','Cek tagihan Pajak Bumi & Bangunan',3),
    (p_id,'Verifikasi','/verifikasi','Cek keaslian dokumen desa',4);
  -- Data
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Data','/statistik',4) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'IDM','/status-idm','Indeks Desa Membangun terkini',1),
    (p_id,'Penduduk','/statistik/penduduk','Statistik demografi warga',2),
    (p_id,'APBDes','/keuangan','Rincian anggaran & realisasi',3),
    (p_id,'Perencanaan','/perencanaan','Voting usulan warga & RKPDes',4);
  -- Potensi
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Potensi','/potensi-desa',5) RETURNING id INTO p_id;
  INSERT INTO public.nav_item(parent_id,label,href,deskripsi,urutan) VALUES
    (p_id,'UMKM','/potensi-desa#ekonomi','Ekonomi kreatif & usaha warga',1),
    (p_id,'Wisata','/potensi-desa#pariwisata','Destinasi & atraksi desa',2),
    (p_id,'Marketplace','/marketplace','Produk unggulan warga',3),
    (p_id,'BUMDes','/potensi-desa#bumdes','Badan usaha & koperasi desa',4);
  -- Peta
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Peta','/peta-desa',6);
  -- Kontak
  INSERT INTO public.nav_item(label, href, urutan) VALUES ('Kontak','/service-center',7);
END $$;

-- ===== Seed footer_column =====
INSERT INTO public.footer_column (judul, urutan, links) VALUES
 ('Service Center', 1, '[
   {"label":"Aduan Warga","href":"/service-center"},
   {"label":"Verifikasi Dokumen","href":"/verifikasi"},
   {"label":"Langganan WA","href":"/langganan-wa"}
 ]'::jsonb),
 ('Informasi', 2, '[
   {"label":"Berita","href":"/berita"},
   {"label":"Agenda","href":"/kalender-desa"},
   {"label":"Pengumuman","href":"/pengumuman"},
   {"label":"Galeri","href":"/galeri"}
 ]'::jsonb),
 ('Terhubung', 3, '[
   {"label":"Facebook","href":"https://facebook.com/desa.serunimumbul"},
   {"label":"Instagram","href":"https://instagram.com/desa.serunimumbul"},
   {"label":"YouTube","href":"https://youtube.com/@desa.serunimumbul"}
 ]'::jsonb);
