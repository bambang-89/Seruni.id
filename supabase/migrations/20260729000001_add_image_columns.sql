-- ============================================================
-- MIGRATION: 20260729000001_add_image_columns.sql
-- Tanggal: 2026-07-29
-- Deskripsi: Menambahkan kolom gambar/foto untuk:
--   1. Profil Perangkat Desa (foto, selfie)
--   2. Berita (gambar, gallery)
--   3. Galeri (gambar, video)
--   4. Profil Desa (hero, logo)
--   5. Surat Ajuan (dokumen pendukung)
--   6. Kegiatan Pembangunan (dokumentasi)
--   7. Bidang Tanah (dokumen, foto)
--   8. Homepage/Hero section
-- ============================================================

-- ============================================================
-- 1. PROFIL PERANGKAT DESA - Tambah foto & selfie
-- ============================================================
ALTER TABLE public.desa_pamong
  ADD COLUMN IF NOT EXISTS foto_url TEXT,
  ADD COLUMN IF NOT EXISTS foto_selfie_url TEXT,
  ADD COLUMN IF NOT EXISTS nip TEXT,
  ADD COLUMN IF NOT EXISTS email TEXT,
  ADD COLUMN IF NOT EXISTS no_hp TEXT;

CREATE INDEX IF NOT EXISTS idx_desa_pamong_nip ON public.desa_pamong(nip);

-- ============================================================
-- 2. BERITA - Tambah gambar & gallery
-- ============================================================
ALTER TABLE public.berita
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_gallery JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS gambar_alt TEXT;

CREATE INDEX IF NOT EXISTS idx_berita_gambar ON public.berita(gambar_url);

-- ============================================================
-- 3. GALERI - Tambah gambar & video
-- ============================================================
ALTER TABLE public.galeri
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS video_url TEXT,
  ADD COLUMN IF NOT EXISTS thumbnail_url TEXT,
  ADD COLUMN IF NOT EXISTS jenis VARCHAR(20) DEFAULT 'foto'
    CHECK (jenis IN ('foto','video','dokumentasi'));

CREATE INDEX IF NOT EXISTS idx_galeri_jenis ON public.galeri(jenis);

-- ============================================================
-- 4. PROFIL DESA - Tambah hero & logo
-- ============================================================
ALTER TABLE public.profil_desa
  ADD COLUMN IF NOT EXISTS gambar_hero_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_logo_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_latarset_1_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_latarset_2_url TEXT,
  ADD COLUMN IF NOT EXISTS video_url TEXT,
  ADD COLUMN IF NOT EXISTS video_embed_url TEXT;

-- ============================================================
-- 5. SURAT AJUAN - Tambah dokumen pendukung
-- ============================================================
ALTER TABLE public.surat_ajuan
  ADD COLUMN IF NOT EXISTS dokumen_ktp_url TEXT,
  ADD COLUMN IF NOT EXISTS dokumen_kk_url TEXT,
  ADD COLUMN IF NOT EXISTS dokumen_pendukung_url TEXT,
  ADD COLUMN IF NOT EXISTS dokumen_lain_url TEXT,
  ADD COLUMN IF NOT EXISTS foto_pemohon_url TEXT;

CREATE INDEX IF NOT EXISTS idx_surat_ajuan_dokumen ON public.surat_ajuan(dokumen_ktp_url);

-- ============================================================
-- 6. KEGIATAN PEMBANGUNAN - Tambah dokumentasi
-- ============================================================
CREATE TABLE IF NOT EXISTS public.kegiatan_pembangunan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  judul VARCHAR(255) NOT NULL,
  deskripsi TEXT,
  tahun INT,
  anggaran NUMERIC(16,2),
  sumber_dana VARCHAR(100),
  lokasi TEXT,
  dusun VARCHAR(100),
  tanggal_mulai DATE,
  tanggal_selesai DATE,
  status VARCHAR(50) DEFAULT 'rencana',
  gambar_url TEXT,
  gambar_dokumentasi JSONB DEFAULT '[]'::jsonb,
  video_url TEXT,
  progress_persen INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.kegiatan_pembangunan TO anon, authenticated;
GRANT ALL ON public.kegiatan_pembangunan TO service_role;
ALTER TABLE public.kegiatan_pembangunan ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read kegiatan_pembangunan" ON public.kegiatan_pembangunan;
DO $$
BEGIN
  CREATE POLICY "Public read kegiatan_pembangunan" ON public.kegiatan_pembangunan
    FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write kegiatan_pembangunan" ON public.kegiatan_pembangunan;
DO $$
BEGIN
  CREATE POLICY "Admin write kegiatan_pembangunan" ON public.kegiatan_pembangunan
    FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.kegiatan_pembangunan
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS judul VARCHAR(255),
  ADD COLUMN IF NOT EXISTS deskripsi TEXT,
  ADD COLUMN IF NOT EXISTS tahun INT,
  ADD COLUMN IF NOT EXISTS anggaran NUMERIC(16,2),
  ADD COLUMN IF NOT EXISTS sumber_dana VARCHAR(100),
  ADD COLUMN IF NOT EXISTS lokasi TEXT,
  ADD COLUMN IF NOT EXISTS dusun VARCHAR(100),
  ADD COLUMN IF NOT EXISTS tanggal_mulai DATE,
  ADD COLUMN IF NOT EXISTS tanggal_selesai DATE,
  ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'rencana',
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_dokumentasi JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS video_url TEXT,
  ADD COLUMN IF NOT EXISTS progress_persen INT DEFAULT 0;

DROP TRIGGER IF EXISTS trg_kegiatan_updated ON public.kegiatan_pembangunan;
CREATE TRIGGER trg_kegiatan_updated BEFORE UPDATE ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_kegiatan_tahun ON public.kegiatan_pembangunan(tahun);
CREATE INDEX IF NOT EXISTS idx_kegiatan_dusun ON public.kegiatan_pembangunan(dusun);

-- ============================================================
-- 7. BIDANG TANAH - Tambah dokumen & foto
-- ============================================================
CREATE TABLE IF NOT EXISTS public.bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  no_sertifikat TEXT,
  jenis_sertifikat VARCHAR(50) DEFAULT 'sertifikat'
    CHECK (jenis_sertifikat IN ('sertifikat','akta','girik','leter_c')),
  nama_pemegang VARCHAR(200),
  nik_pemegang TEXT,
  alamat_pemegang TEXT,
  luas_m2 NUMERIC(12,2),
  lokasi TEXT,
  dusun VARCHAR(100),
  rt VARCHAR(5),
  rw VARCHAR(5),
  koordinat_lat NUMERIC(10,6),
  koordinat_lng NUMERIC(11,6),
  dokumen_url TEXT,
  gambar_url TEXT,
  gambar_lampiran JSONB DEFAULT '[]'::jsonb,
  status VARCHAR(50) DEFAULT 'terdaftar'
    CHECK (status IN ('terdaftar','sengketa','dialihkan','belum_sertifikasi')),
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.bidang_tanah TO anon, authenticated;
GRANT ALL ON public.bidang_tanah TO service_role;
ALTER TABLE public.bidang_tanah ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read bidang_tanah" ON public.bidang_tanah;
DO $$
BEGIN
  CREATE POLICY "Public read bidang_tanah" ON public.bidang_tanah
    FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write bidang_tanah" ON public.bidang_tanah;
DO $$
BEGIN
  CREATE POLICY "Admin write bidang_tanah" ON public.bidang_tanah
    FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.bidang_tanah
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS no_sertifikat TEXT,
  ADD COLUMN IF NOT EXISTS jenis_sertifikat VARCHAR(50) DEFAULT 'sertifikat',
  ADD COLUMN IF NOT EXISTS nama_pemegang VARCHAR(200),
  ADD COLUMN IF NOT EXISTS nik_pemegang TEXT,
  ADD COLUMN IF NOT EXISTS alamat_pemegang TEXT,
  ADD COLUMN IF NOT EXISTS luas_m2 NUMERIC(12,2),
  ADD COLUMN IF NOT EXISTS lokasi TEXT,
  ADD COLUMN IF NOT EXISTS dusun VARCHAR(100),
  ADD COLUMN IF NOT EXISTS rt VARCHAR(5),
  ADD COLUMN IF NOT EXISTS rw VARCHAR(5),
  ADD COLUMN IF NOT EXISTS koordinat_lat NUMERIC(10,6),
  ADD COLUMN IF NOT EXISTS koordinat_lng NUMERIC(11,6),
  ADD COLUMN IF NOT EXISTS dokumen_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_lampiran JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'terdaftar',
  ADD COLUMN IF NOT EXISTS keterangan TEXT;

DROP TRIGGER IF EXISTS trg_bidang_tanah_updated ON public.bidang_tanah;
CREATE TRIGGER trg_bidang_tanah_updated BEFORE UPDATE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_bidang_tanah_sertifikat ON public.bidang_tanah(no_sertifikat);
CREATE INDEX IF NOT EXISTS idx_bidang_tanah_pemegang ON public.bidang_tanah(nama_pemegang);

-- ============================================================
-- 8. HERO SLIDER - Untuk homepage/landing page
-- ============================================================
CREATE TABLE IF NOT EXISTS public.hero_slider (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  judul VARCHAR(255) NOT NULL,
  sub_judul TEXT,
  deskripsi TEXT,
  gambar_url TEXT NOT NULL,
  gambar_mobile_url TEXT,
  tombol_teks VARCHAR(100),
  tombol_url VARCHAR(500),
  urutan INT DEFAULT 0,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.hero_slider TO anon, authenticated;
GRANT ALL ON public.hero_slider TO service_role;
ALTER TABLE public.hero_slider ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read hero_slider" ON public.hero_slider;
DO $$
BEGIN
  CREATE POLICY "Public read hero_slider" ON public.hero_slider
    FOR SELECT TO anon, authenticated USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write hero_slider" ON public.hero_slider;
DO $$
BEGIN
  CREATE POLICY "Admin write hero_slider" ON public.hero_slider
    FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.hero_slider
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS judul VARCHAR(255),
  ADD COLUMN IF NOT EXISTS sub_judul TEXT,
  ADD COLUMN IF NOT EXISTS deskripsi TEXT,
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_mobile_url TEXT,
  ADD COLUMN IF NOT EXISTS tombol_teks VARCHAR(100),
  ADD COLUMN IF NOT EXISTS tombol_url VARCHAR(500),
  ADD COLUMN IF NOT EXISTS urutan INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS aktif BOOLEAN DEFAULT true;

DROP TRIGGER IF EXISTS trg_hero_slider_updated ON public.hero_slider;
CREATE TRIGGER trg_hero_slider_updated BEFORE UPDATE ON public.hero_slider
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_hero_slider_urutan ON public.hero_slider(urutan);

-- ============================================================
-- 9. POTENSI DESA - Tambah gambar
-- ============================================================
CREATE TABLE IF NOT EXISTS public.potensi_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  kategori VARCHAR(50) NOT NULL
    CHECK (kategori IN ('umkm','wisata','pertanian','perikanan','peternakan','kekayaan_desa','lainnya')),
  nama VARCHAR(200) NOT NULL,
  deskripsi TEXT,
  alamat TEXT,
  dusun VARCHAR(100),
  koordinat_lat NUMERIC(10,6),
  koordinat_lng NUMERIC(11,6),
  gambar_url TEXT,
  gambar_gallery JSONB DEFAULT '[]'::jsonb,
  kontak VARCHAR(100),
  jam_operasional TEXT,
  website VARCHAR(500),
  media_sosial JSONB DEFAULT '{}'::jsonb,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.potensi_desa TO anon, authenticated;
GRANT ALL ON public.potensi_desa TO service_role;
ALTER TABLE public.potensi_desa ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read potensi_desa" ON public.potensi_desa;
DO $$
BEGIN
  CREATE POLICY "Public read potensi_desa" ON public.potensi_desa
    FOR SELECT TO anon, authenticated USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write potensi_desa" ON public.potensi_desa;
DO $$
BEGIN
  CREATE POLICY "Admin write potensi_desa" ON public.potensi_desa
    FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.potensi_desa
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS kategori VARCHAR(50),
  ADD COLUMN IF NOT EXISTS nama VARCHAR(200),
  ADD COLUMN IF NOT EXISTS deskripsi TEXT,
  ADD COLUMN IF NOT EXISTS alamat TEXT,
  ADD COLUMN IF NOT EXISTS dusun VARCHAR(100),
  ADD COLUMN IF NOT EXISTS koordinat_lat NUMERIC(10,6),
  ADD COLUMN IF NOT EXISTS koordinat_lng NUMERIC(11,6),
  ADD COLUMN IF NOT EXISTS gambar_url TEXT,
  ADD COLUMN IF NOT EXISTS gambar_gallery JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS kontak VARCHAR(100),
  ADD COLUMN IF NOT EXISTS jam_operasional TEXT,
  ADD COLUMN IF NOT EXISTS website VARCHAR(500),
  ADD COLUMN IF NOT EXISTS media_sosial JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS aktif BOOLEAN DEFAULT true;

DROP TRIGGER IF EXISTS trg_potensi_updated ON public.potensi_desa;
CREATE TRIGGER trg_potensi_updated BEFORE UPDATE ON public.potensi_desa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_potensi_kategori ON public.potensi_desa(kategori);
CREATE INDEX IF NOT EXISTS idx_potensi_dusun ON public.potensi_desa(dusun);

-- ============================================================
-- 10. DOKUMEN DESA - Untuk arsip dokumen resmi
-- ============================================================
CREATE TABLE IF NOT EXISTS public.dokumen_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  kategori VARCHAR(50) NOT NULL
    CHECK (kategori IN ('peraturan_desa','keputusan_kades','inventaris','laporan','transparansi','lainnya')),
  judul VARCHAR(255) NOT NULL,
  deskripsi TEXT,
  file_url TEXT NOT NULL,
  tipe_file VARCHAR(20) DEFAULT 'pdf'
    CHECK (tipe_file IN ('pdf','doc','docx','xls','xlsx','zip')),
  ukuran_file BIGINT,
  tahun INT,
  nomor_dokumen VARCHAR(50),
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.dokumen_desa TO anon, authenticated;
GRANT ALL ON public.dokumen_desa TO service_role;
ALTER TABLE public.dokumen_desa ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read dokumen_desa" ON public.dokumen_desa;
DO $$
BEGIN
  CREATE POLICY "Public read dokumen_desa" ON public.dokumen_desa
    FOR SELECT TO anon, authenticated USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DROP POLICY IF EXISTS "Admin write dokumen_desa" ON public.dokumen_desa;
DO $$
BEGIN
  CREATE POLICY "Admin write dokumen_desa" ON public.dokumen_desa
    FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.dokumen_desa
  ADD COLUMN IF NOT EXISTS tenant_id UUID,
  ADD COLUMN IF NOT EXISTS kategori VARCHAR(50),
  ADD COLUMN IF NOT EXISTS judul VARCHAR(255),
  ADD COLUMN IF NOT EXISTS deskripsi TEXT,
  ADD COLUMN IF NOT EXISTS file_url TEXT,
  ADD COLUMN IF NOT EXISTS tipe_file VARCHAR(20) DEFAULT 'pdf',
  ADD COLUMN IF NOT EXISTS ukuran_file BIGINT,
  ADD COLUMN IF NOT EXISTS tahun INT,
  ADD COLUMN IF NOT EXISTS nomor_dokumen VARCHAR(50),
  ADD COLUMN IF NOT EXISTS aktif BOOLEAN DEFAULT true;

DROP TRIGGER IF EXISTS trg_dokumen_updated ON public.dokumen_desa;
CREATE TRIGGER trg_dokumen_updated BEFORE UPDATE ON public.dokumen_desa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_dokumen_kategori ON public.dokumen_desa(kategori);
CREATE INDEX IF NOT EXISTS idx_dokumen_tahun ON public.dokumen_desa(tahun);

-- ============================================================
-- 11. Seed data untuk hero_slider (demo)
-- ============================================================
INSERT INTO public.hero_slider (tenant_id, judul, sub_judul, deskripsi, gambar_url, tombol_teks, tombol_url, urutan, aktif)
SELECT
  t.id,
  'Selamat Datang di ' || t.nama_desa,
  'Melayani dengan Sepenuh Hati',
  'Portal resmi Pemerintah Desa untuk informasi dan layanan publik',
  'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=1920',
  'Pelajari Lebih Lanjut',
  '/profil-desa',
  1,
  true
FROM public.tenants t
WHERE t.subdomain = 'seruni'
ON CONFLICT DO NOTHING;

INSERT INTO public.hero_slider (tenant_id, judul, sub_judul, deskripsi, gambar_url, tombol_teks, tombol_url, urutan, aktif)
SELECT
  t.id,
  'Layanan Surat Online',
  'Ajukan Surat Mudah dan Cepat',
  'Dapatkan surat keterangan dari rumah tanpa antri',
  'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=1920',
  'Ajukan Surat',
  '/layanan/surat',
  2,
  true
FROM public.tenants t
WHERE t.subdomain = 'seruni'
ON CONFLICT DO NOTHING;

INSERT INTO public.hero_slider (tenant_id, judul, sub_judul, deskripsi, gambar_url, tombol_teks, tombol_url, urutan, aktif)
SELECT
  t.id,
  'Partisipasi Masyarakat',
  'Suaramu Berharga',
  'Ikut serta dalam pembangunan desa melalui voting dan usulan',
  'https://images.unsplash.com/photo-1531206715517-5c0ba140b2b8?w=1920',
  'Ikuti Voting',
  '/partisipasi/voting',
  3,
  true
FROM public.tenants t
WHERE t.subdomain = 'seruni'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 12. Seed data untuk desa_pamong (demo dengan placeholder)
-- ============================================================
UPDATE public.desa_pamong SET
  foto_url = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
  foto_selfie_url = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400'
WHERE jabatan = 'Kepala Desa'
AND foto_url IS NULL;

-- ============================================================
-- 13. Seed data untuk profil_desa hero
-- ============================================================
UPDATE public.profil_desa SET
  gambar_hero_url = 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1920',
  video_url = NULL
WHERE singleton = true
AND gambar_hero_url IS NULL;

-- ============================================================
-- Log
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '=== Image columns migration completed ===';
  RAISE NOTICE 'Added image columns to:';
  RAISE NOTICE '  - desa_pamong (foto_url, foto_selfie_url)';
  RAISE NOTICE '  - berita (gambar_url, gambar_gallery, gambar_alt)';
  RAISE NOTICE '  - galeri (gambar_url, video_url, thumbnail_url, jenis)';
  RAISE NOTICE '  - profil_desa (gambar_hero_url, gambar_logo_url, dll)';
  RAISE NOTICE '  - surat_ajuan (dokumen_ktp_url, dokumen_kk_url, dll)';
  RAISE NOTICE 'Created tables:';
  RAISE NOTICE '  - kegiatan_pembangunan';
  RAISE NOTICE '  - bidang_tanah';
  RAISE NOTICE '  - hero_slider';
  RAISE NOTICE '  - potensi_desa';
  RAISE NOTICE '  - dokumen_desa';
END $$;
