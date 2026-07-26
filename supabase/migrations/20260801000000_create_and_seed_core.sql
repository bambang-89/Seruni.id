-- ============================================================
-- MIGRATION + SEED: Buat tabel & seed data Seruni.id
-- Tanggal: 2026-08-01
-- ============================================================

BEGIN;

-- ============================================================
-- 1. Buat TABEL IDENTITAS DESA
-- ============================================================
CREATE TABLE IF NOT EXISTS public.identitas_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  singleton BOOLEAN NOT NULL DEFAULT true UNIQUE,
  nama_desa VARCHAR(200) NOT NULL DEFAULT 'Seruni Mumbul',
  kabupaten VARCHAR(100),
  kecamatan VARCHAR(100),
  provinsi VARCHAR(100) DEFAULT 'Nusa Tenggara Barat',
  kode_pos VARCHAR(10),
  logo_url TEXT,
  slogan VARCHAR(255),
  tahun_bentuk INT,
  luas_wilayah NUMERIC(10,2),
  koordinat_lat NUMERIC(10,6),
  koordinat_lng NUMERIC(11,6),
  zoom_level INT DEFAULT 12,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.identitas_desa ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.identitas_desa TO authenticated;
GRANT ALL ON public.identitas_desa TO service_role;
DO $$
BEGIN
  CREATE POLICY "Public read identitas_desa" ON public.identitas_desa FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 2. Buat TABEL HERO_SLIDER
-- ============================================================
CREATE TABLE IF NOT EXISTS public.hero_slider (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul VARCHAR(255) NOT NULL,
  sub_judul TEXT,
  deskripsi TEXT,
  gambar_url TEXT NOT NULL,
  tombol_teks VARCHAR(100),
  tombol_url VARCHAR(500),
  urutan INT DEFAULT 0,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.hero_slider ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.hero_slider TO authenticated;
GRANT ALL ON public.hero_slider TO service_role;
DO $$
BEGIN
  CREATE POLICY "Public read hero_slider" ON public.hero_slider FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 3. Buat TABEL SURAT_TEMPLATE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.surat_template (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama VARCHAR(200) NOT NULL,
  kode VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  header_height INT DEFAULT 100,
  logo_kiri_url TEXT,
  logo_kanan_url TEXT,
  judul_instansi_text VARCHAR(255) DEFAULT 'PEMERINTAH KABUPATEN LOMBOK TIMUR',
  sub_judul_instansi_text VARCHAR(255) DEFAULT 'KECAMATAN PRINGGABAYA',
  nama_desa_text VARCHAR(255) DEFAULT 'DESA SERUNI MUMBUL',
  alamat_desa_text TEXT DEFAULT 'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
  garis_enabled BOOLEAN DEFAULT true,
  garis_height INT DEFAULT 2,
  footer_ttd_kanan_enabled BOOLEAN DEFAULT true,
  footer_ttd_kanan_judul VARCHAR(100) DEFAULT 'Kepala Desa',
  page_size VARCHAR(20) DEFAULT 'A4',
  page_orientation VARCHAR(20) DEFAULT 'portrait',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.surat_template ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.surat_template TO authenticated;
GRANT ALL ON public.surat_template TO service_role;
DO $$
BEGIN
  CREATE POLICY "Public read surat_template" ON public.surat_template FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 4. Buat TABEL REF_UPLOAD_PREFERENCES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ref_upload_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kategori VARCHAR(50) NOT NULL UNIQUE,
  folder_path VARCHAR(255) NOT NULL,
  max_size_mb INT NOT NULL DEFAULT 5,
  is_required BOOLEAN DEFAULT false,
  deskripsi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.ref_upload_preferences ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.ref_upload_preferences TO authenticated;

-- ============================================================
-- 5. Buat TABEL dokumen_upload
-- ============================================================
CREATE TABLE IF NOT EXISTS public.dokumen_upload (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID,
  kategori VARCHAR(50) NOT NULL,
  nama_file VARCHAR(255) NOT NULL,
  tipe_file VARCHAR(50) NOT NULL,
  ukuran_file BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  storage_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.dokumen_upload ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.dokumen_upload TO authenticated;
GRANT ALL ON public.dokumen_upload TO service_role;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Seed ref_upload_preferences
INSERT INTO public.ref_upload_preferences (kategori, folder_path, max_size_mb, is_required, deskripsi) VALUES
  ('foto_ktp', 'surat/ktp', 5, true, 'Foto KTP pemohon'),
  ('foto_kk', 'surat/kk', 5, false, 'Foto Kartu Keluarga'),
  ('foto_selfie_ktp', 'surat/selfie', 5, true, 'Foto selfie dengan KTP'),
  ('akta_lahir', 'surat/akta', 10, false, 'Akta Kelahiran'),
  ('akta_nikah', 'surat/akta', 10, false, 'Akta Nikah'),
  ('dokumen_pendukung', 'surat/pendukung', 10, false, 'Dokumen pendukung'),
  ('foto_profil', 'profil', 2, false, 'Foto profil'),
  ('foto_galeri', 'galeri', 10, false, 'Foto galeri'),
  ('foto_kegiatan', 'kegiatan', 10, false, 'Foto dokumentasi'),
  ('foto_produk', 'produk', 5, false, 'Foto produk UMKM')
ON CONFLICT (kategori) DO NOTHING;

-- Seed hero_slider
INSERT INTO public.hero_slider (judul, sub_judul, deskripsi, gambar_url, tombol_teks, tombol_url, urutan, aktif) VALUES
  ('Selamat Datang di Desa Seruni Mumbul', 'Melayani dengan Sepenuh Hati', 'Portal resmi Pemerintah Desa untuk informasi dan layanan publik', 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=1920', 'Pelajari Lebih Lanjut', '/profil-desa', 1, true),
  ('Layanan Surat Online', 'Ajukan Surat Mudah dan Cepat', 'Dapatkan surat keterangan dari rumah tanpa antri', 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=1920', 'Ajukan Surat', '/layanan/surat', 2, true),
  ('Partisipasi Masyarakat', 'Suaramu Berharga', 'Ikut serta dalam pembangunan desa melalui voting dan usulan', 'https://images.unsplash.com/photo-1531206715517-5c0ba140b2b8?w=1920', 'Ikuti Voting', '/partisipasi/voting', 3, true)
ON CONFLICT DO NOTHING;

-- Seed surat_template
INSERT INTO public.surat_template (nama, kode, is_default, is_active, judul_instansi_text, sub_judul_instansi_text, nama_desa_text, footer_ttd_kanan_judul) VALUES
  ('Template Standard Lombok Timur', 'STD_LOMBOK_TIMUR', true, true, 'PEMERINTAH KABUPATEN LOMBOK TIMUR', 'KECAMATAN PRINGGABAYA', 'DESA SERUNI MUMBUL', 'Kepala Desa Seruni Mumbul')
ON CONFLICT (kode) DO NOTHING;

-- Seed identitas_desa
INSERT INTO public.identitas_desa (singleton, nama_desa, kabupaten, kecamatan, provinsi, logo_url, slogan, tahun_bentuk, luas_wilayah, koordinat_lat, koordinat_lng, zoom_level) VALUES (
  true,
  'Seruni Mumbul',
  'Lombok Timur',
  'Pringgabaya',
  'Nusa Tenggara Barat',
  'https://storage.googleapis.com/gpt-engineer-file-uploads/aMjanxrDoUP1QJ5krTWiqhWnSbF3/uploads/1758710472461-logo-icon-BG-circle%20copy.png',
  'Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.',
  1968,
  12.4,
  -8.5589,
  116.5847,
  14
) ON CONFLICT (singleton) DO NOTHING;

COMMIT;

DO $$
BEGIN
  RAISE NOTICE 'Tables created & seeded: identitas_desa, hero_slider, surat_template, ref_upload_preferences, dokumen_upload';
END $$;
