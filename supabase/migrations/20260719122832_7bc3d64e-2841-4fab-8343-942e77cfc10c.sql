
-- ============ Potensi: UMKM/BUMDes, Produk, Wisata ============
CREATE TABLE public.potensi_umkm (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipe TEXT NOT NULL DEFAULT 'umkm', -- umkm | bumdes | koperasi
  nama TEXT NOT NULL,
  pemilik TEXT,
  sektor TEXT,
  dusun TEXT,
  kontak TEXT,
  alamat TEXT,
  deskripsi TEXT,
  status TEXT NOT NULL DEFAULT 'publish', -- draft | publish
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_umkm TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_umkm TO authenticated;
GRANT ALL ON public.potensi_umkm TO service_role;
ALTER TABLE public.potensi_umkm ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca umkm publish" ON public.potensi_umkm FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola umkm" ON public.potensi_umkm FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_umkm_updated BEFORE UPDATE ON public.potensi_umkm FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.potensi_produk (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  umkm_id uuid REFERENCES public.potensi_umkm(id) ON DELETE SET NULL,
  penjual_nama TEXT NOT NULL,
  nama TEXT NOT NULL,
  kategori TEXT,
  harga NUMERIC(14,2),
  satuan TEXT,
  stok INT,
  deskripsi TEXT,
  foto_url TEXT,
  featured BOOLEAN NOT NULL DEFAULT false,
  status TEXT NOT NULL DEFAULT 'publish',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_produk TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_produk TO authenticated;
GRANT ALL ON public.potensi_produk TO service_role;
ALTER TABLE public.potensi_produk ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca produk publish" ON public.potensi_produk FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola produk" ON public.potensi_produk FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_produk_updated BEFORE UPDATE ON public.potensi_produk FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.potensi_wisata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  jenis TEXT NOT NULL, -- bahari | pegunungan | budaya | buatan | kuliner
  dusun TEXT,
  deskripsi TEXT,
  latitude NUMERIC(9,6),
  longitude NUMERIC(9,6),
  foto_url TEXT,
  fasilitas TEXT,
  status TEXT NOT NULL DEFAULT 'publish',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.potensi_wisata TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.potensi_wisata TO authenticated;
GRANT ALL ON public.potensi_wisata TO service_role;
ALTER TABLE public.potensi_wisata ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik baca wisata publish" ON public.potensi_wisata FOR SELECT USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "admin kelola wisata" ON public.potensi_wisata FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_potensi_wisata_updated BEFORE UPDATE ON public.potensi_wisata FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Extend wilayah_dusun with coordinates for peta if not present
ALTER TABLE public.wilayah_dusun
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9,6),
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9,6);

-- Seed contoh Desa Seruni Mumbul (koordinat ~ Lombok Timur)
INSERT INTO public.potensi_umkm (tipe, nama, pemilik, sektor, dusun, kontak, deskripsi) VALUES
  ('bumdes', 'BUMDes Bina Seruni Mandiri', 'Pemerintah Desa', 'Multi-usaha', 'Karang Baru', '0812-3456-7890', 'Menaungi marketplace desa, simpan pinjam UMKM, dan pengelolaan aset wisata Pantai Seruni.'),
  ('koperasi', 'Koperasi Merah Putih Seruni', 'H. Lalu Ahmad', 'Simpan Pinjam', 'Montong', '0812-1111-2222', 'Koperasi warga aktif sejak 2018.'),
  ('umkm', 'Tenun Songket Inaq Rahmi', 'Inaq Rahmi', 'Kerajinan', 'Montong', '0813-4444-5555', 'Sentra tenun songket Sasak.'),
  ('umkm', 'Kopi Robusta Seruni', 'Amaq Zainuddin', 'Pertanian', 'Batu Belek', '0813-6666-7777', 'Kopi robusta olahan warga lereng bukit.'),
  ('umkm', 'Kerajinan Ketak Seruni', 'Kelompok Wanita Tani', 'Kerajinan', 'Karang Baru', '0813-8888-9999', 'Anyaman ketak untuk pasar ekspor.');

INSERT INTO public.potensi_produk (penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured) VALUES
  ('Tenun Songket Inaq Rahmi', 'Kain Songket Motif Subhanale', 'Kerajinan', 850000, 'lembar', 12, 'Motif klasik Sasak, tenun tangan.', true),
  ('Kopi Robusta Seruni', 'Kopi Bubuk 250g', 'Pangan', 45000, 'pak', 80, 'Roasting medium, aroma cokelat.', true),
  ('Kerajinan Ketak Seruni', 'Tas Ketak Lombok', 'Kerajinan', 175000, 'buah', 30, 'Anyaman ketak dengan kulit sintetis.', true),
  ('BUMDes Bina Seruni Mandiri', 'Madu Trigona Hutan Seruni', 'Pangan', 120000, 'botol 250ml', 50, 'Madu klanceng murni.', true),
  ('Kopi Robusta Seruni', 'Kopi Biji 1kg', 'Pangan', 160000, 'kg', 40, 'Green bean grade A.', false),
  ('Tenun Songket Inaq Rahmi', 'Selendang Songket', 'Kerajinan', 275000, 'lembar', 20, 'Warna pastel, cocok untuk acara resmi.', false);

INSERT INTO public.potensi_wisata (nama, jenis, dusun, deskripsi, latitude, longitude, fasilitas) VALUES
  ('Pantai Seruni Mumbul', 'bahari', 'Karang Baru', 'Pantai berpasir putih 2,4 km dengan spot snorkeling terumbu karang.', -8.5312, 116.6521, 'Gazebo, MCK, warung UMKM'),
  ('Bukit Denda Seruni', 'pegunungan', 'Batu Belek', 'Sunrise point dengan pemandangan Rinjani.', -8.5401, 116.6612, 'Camping ground, ojek wisata'),
  ('Sentra Tenun Songket Sasak', 'budaya', 'Montong', 'Sanggar tenun aktif. Pengunjung dapat mencoba menenun.', -8.5350, 116.6480, 'Workshop, galeri, toko'),
  ('Kolam Renang Alam Air Merah', 'buatan', 'Karang Baru', 'Kolam mata air alami dengan area piknik keluarga.', -8.5280, 116.6555, 'Toilet, ganti pakaian, kantin');

UPDATE public.wilayah_dusun SET latitude = -8.5312, longitude = 116.6521 WHERE nama ILIKE '%Karang Baru%' AND latitude IS NULL;
UPDATE public.wilayah_dusun SET latitude = -8.5350, longitude = 116.6480 WHERE nama ILIKE '%Montong%' AND latitude IS NULL;
UPDATE public.wilayah_dusun SET latitude = -8.5401, longitude = 116.6612 WHERE nama ILIKE '%Batu Belek%' AND latitude IS NULL;
