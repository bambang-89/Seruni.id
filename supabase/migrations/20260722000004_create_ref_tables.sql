-- ============================================================
-- MIGRASI: 20260726000002_create_ref_tables.sql
-- Tanggal: 2026-07-26
-- Deskripsi: Tabel referensi untuk dropdown field di AdminOps
-- ============================================================

-- 1. ref_penggunaan_tanah
CREATE TABLE IF NOT EXISTS ref_penggunaan_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_penggunaan_tanah_updated ON ref_penggunaan_tanah;
DO $$
BEGIN
  CREATE TRIGGER ref_penggunaan_tanah_updated BEFORE UPDATE ON ref_penggunaan_tanah
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_penggunaan_tanah TO authenticated;
GRANT ALL ON ref_penggunaan_tanah TO service_role;
ALTER TABLE ref_penggunaan_tanah ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_penggunaan_tanah" ON ref_penggunaan_tanah;
DO $$
BEGIN
  CREATE POLICY "Public read ref_penggunaan_tanah" ON ref_penggunaan_tanah FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_penggunaan_tanah (kode, nama, urutan) VALUES
  ('01', 'Pertanian', 1),
  ('02', 'Perkebunan', 2),
  ('03', 'Peternakan', 3),
  ('04', 'Perhutanan', 4),
  ('05', 'Perikanan/Air Tawar', 5),
  ('06', 'Permukiman', 6),
  ('07', 'Perdagangan/Jasa', 7),
  ('08', 'Industri/Usaha', 8),
  ('09', 'Kehutanan', 9),
  ('10', 'Lahan Kering', 10),
  ('11', 'Lahan Basah/Rawa', 11),
  ('12', 'Tambak', 12),
  ('13', 'Kosong/Tidak Dimanfaatkan', 13),
  ('14', 'Lainnya', 14)
ON CONFLICT (kode) DO NOTHING;

-- 2. ref_status_hak_tanah
CREATE TABLE IF NOT EXISTS ref_status_hak_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_status_hak_tanah_updated ON ref_status_hak_tanah;
DO $$
BEGIN
  CREATE TRIGGER ref_status_hak_tanah_updated BEFORE UPDATE ON ref_status_hak_tanah
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_status_hak_tanah TO authenticated;
GRANT ALL ON ref_status_hak_tanah TO service_role;
ALTER TABLE ref_status_hak_tanah ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_status_hak_tanah" ON ref_status_hak_tanah;
DO $$
BEGIN
  CREATE POLICY "Public read ref_status_hak_tanah" ON ref_status_hak_tanah FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_status_hak_tanah (kode, nama, urutan) VALUES
  ('01', 'Hak Milik', 1),
  ('02', 'Hak Guna Bangunan', 2),
  ('03', 'Hak Guna Usaha', 3),
  ('04', 'Hak Pakai', 4),
  ('05', 'Hak Sewa', 5),
  ('06', 'Tanah Negara', 6),
  ('07', 'Girik', 7),
  ('08', 'Letter C', 8),
  ('09', 'Letter D', 9),
  ('10', 'SPPT/PBB', 10),
  ('11', 'Belum Terdaftar', 11),
  ('12', 'Lainnya', 12)
ON CONFLICT (kode) DO NOTHING;

-- 3. ref_jenis_infrastruktur
CREATE TABLE IF NOT EXISTS ref_jenis_infrastruktur (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_jenis_infrastruktur_updated ON ref_jenis_infrastruktur;
DO $$
BEGIN
  CREATE TRIGGER ref_jenis_infrastruktur_updated BEFORE UPDATE ON ref_jenis_infrastruktur
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_jenis_infrastruktur TO authenticated;
GRANT ALL ON ref_jenis_infrastruktur TO service_role;
ALTER TABLE ref_jenis_infrastruktur ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_jenis_infrastruktur" ON ref_jenis_infrastruktur;
DO $$
BEGIN
  CREATE POLICY "Public read ref_jenis_infrastruktur" ON ref_jenis_infrastruktur FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_jenis_infrastruktur (kode, nama, kategori, urutan) VALUES
  ('01', 'Jalan Desa', 'transportasi', 1),
  ('02', 'Jembatan', 'transportasi', 2),
  ('03', 'Saluran Irigasi', 'pengairan', 3),
  ('04', 'Embung', 'pengairan', 4),
  ('05', 'Sumur Bor/Desa', 'pengairan', 5),
  ('06', 'Dam Parit', 'pengairan', 6),
  ('07', 'Jaringan Listrik', 'energi', 7),
  ('08', 'Jaringan Air Bersih', 'sanitasi', 8),
  ('09', 'Gorong-gorong', 'transportasi', 9),
  ('10', 'Tangga Desa', 'transportasi', 10),
  ('11', 'Drainase', 'pengairan', 11),
  ('12', 'MCK Umum', 'sanitasi', 12),
  ('13', 'TPS/Sampah', 'lingkungan', 13),
  ('14', 'Tempat Pembuangan Akhir', 'lingkungan', 14),
  ('15', 'Pasar Desa', 'ekonomi', 15),
  ('16', 'Gedung Desa/Pemerintah', 'fasilitas_publik', 16),
  ('17', 'Balai Desa', 'fasilitas_publik', 17),
  ('18', 'Pos Kesehatan Desa', 'kesehatan', 18),
  ('19', 'Posyandu', 'kesehatan', 19),
  ('20', 'PAUD/TPA', 'pendidikan', 20),
  ('21', 'Lapangan Olahraga', 'olahraga', 21),
  ('22', 'Taman Desa', 'lingkungan', 22),
  ('23', 'Mushola/Masjid', 'religious', 23),
  ('24', 'Gereja/Klenteng/Pura', 'religious', 24),
  ('25', 'Panggung Hiburan', 'budaya', 25),
  ('26', 'Monumen/Bangunan Bersejarah', 'budaya', 26),
  ('27', 'TPU (Kuburan)', 'umum', 27),
  ('28', 'Lainnya', 'umum', 28)
ON CONFLICT (kode) DO NOTHING;

-- 4. ref_bidang_pembangunan
CREATE TABLE IF NOT EXISTS ref_bidang_pembangunan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_bidang_pembangunan_updated ON ref_bidang_pembangunan;
DO $$
BEGIN
  CREATE TRIGGER ref_bidang_pembangunan_updated BEFORE UPDATE ON ref_bidang_pembangunan
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_bidang_pembangunan TO authenticated;
GRANT ALL ON ref_bidang_pembangunan TO service_role;
ALTER TABLE ref_bidang_pembangunan ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_bidang_pembangunan" ON ref_bidang_pembangunan;
DO $$
BEGIN
  CREATE POLICY "Public read ref_bidang_pembangunan" ON ref_bidang_pembangunan FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_bidang_pembangunan (kode, nama, urutan) VALUES
  ('01', 'Pembangunan Jalan & Jembatan', 1),
  ('02', 'Pembangunan Irigasi & Sumber Air', 2),
  ('03', 'Pembangunan Drainase', 3),
  ('04', 'Pembangunan Jaringan Listrik', 4),
  ('05', 'Pembangunan Air Bersih', 5),
  ('06', 'Pembangunan Sanitasi/MCK', 6),
  ('07', 'Pembangunan Pasar/Toko', 7),
  ('08', 'Pembangunan Gedung/Bangunan Desa', 8),
  ('09', 'Pembangunan Fasilitas Kesehatan', 9),
  ('10', 'Pembangunan Fasilitas Pendidikan', 10),
  ('11', 'Pembangunan Fasilitas Olahraga', 11),
  ('12', 'Pembangunan Fasilitas Keagamaan', 12),
  ('13', 'Pembangunan Taman & Ruang Terbuka', 13),
  ('14', 'Pembangunan TPS & Pengelolaan Sampah', 14),
  ('15', 'Pembangunan Dermaga', 15),
  ('16', 'Pelebaran Jalan', 16),
  ('17', 'Rehabilitasi Jalan', 17),
  ('18', 'Rehabilitasi Jembatan', 18),
  ('19', 'Normalisasi Sungai', 19),
  ('20', 'Pemeliharaan Gedung Desa', 20),
  ('21', 'Pengadaan Alat Kerja', 21),
  ('22', 'Pengadaan Mobil/Rongsokan', 22),
  ('23', 'Lainnya', 23)
ON CONFLICT (kode) DO NOTHING;

-- 5. ref_kategori_bansos
CREATE TABLE IF NOT EXISTS ref_kategori_bansos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori_utama VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_kategori_bansos_updated ON ref_kategori_bansos;
DO $$
BEGIN
  CREATE TRIGGER ref_kategori_bansos_updated BEFORE UPDATE ON ref_kategori_bansos
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_kategori_bansos TO authenticated;
GRANT ALL ON ref_kategori_bansos TO service_role;
ALTER TABLE ref_kategori_bansos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_kategori_bansos" ON ref_kategori_bansos;
DO $$
BEGIN
  CREATE POLICY "Public read ref_kategori_bansos" ON ref_kategori_bansos FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_kategori_bansos (kode, nama, kategori_utama, urutan) VALUES
  ('BLT', 'Bantuan Langsung Tunai (BLT)', 'bantuan_tunai', 1),
  ('BPNT', 'Bantuan Pangan Non Tunai', 'bantuan_nontunai', 2),
  ('PKH', 'Program Keluarga Harapan', 'bantuan_nontunai', 3),
  ('BST', 'Bantuan Sosial Tunai', 'bantuan_tunai', 4),
  ('KIS', 'Kartu Indonesia Sehat', 'kartu_social', 5),
  ('KIP', 'Kartu Indonesia Pintar', 'kartu_social', 6),
  ('KNT', 'Kartu Nusantara Terang', 'bantuan_tunai', 7),
  ('KUBE', 'KUBE (Kelompok Usaha Bersama)', 'bantuan_berkelompok', 8),
  ('BSUM', 'Bantuan Seragam Sekolah', 'bantuan_pendidikan', 9),
  ('BSP', 'Bantuan Sekolah Penggerak', 'bantuan_pendidikan', 10),
  ('RTLH', 'Rumah Tidak Layak Huni (RTLH)', 'bantuan_perumahan', 11),
  ('BLSM', 'Bantuan Langsung Sementara Masyarakat', 'bantuan_tunai', 12),
  ('BCOVID', 'Bantuan Covid-19', 'bantuan_darurat', 13),
  ('BGEMPA', 'Bantuan Bencana Alam/Gempa', 'bantuan_darurat', 14),
  ('BBANJIR', 'Bantuan Bencana Banjir', 'bantuan_darurat', 15),
  ('OTH', 'Bantuan Sosial Lainnya', 'lainnya', 16)
ON CONFLICT (kode) DO NOTHING;

-- 6. ref_jenis_bencana
CREATE TABLE IF NOT EXISTS ref_jenis_bencana (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_jenis_bencana_updated ON ref_jenis_bencana;
DO $$
BEGIN
  CREATE TRIGGER ref_jenis_bencana_updated BEFORE UPDATE ON ref_jenis_bencana
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_jenis_bencana TO authenticated;
GRANT ALL ON ref_jenis_bencana TO service_role;
ALTER TABLE ref_jenis_bencana ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_jenis_bencana" ON ref_jenis_bencana;
DO $$
BEGIN
  CREATE POLICY "Public read ref_jenis_bencana" ON ref_jenis_bencana FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_jenis_bencana (kode, nama, kategori, urutan) VALUES
  ('01', 'Gempa Bumi', 'alam', 1),
  ('02', 'Tsunami', 'alam', 2),
  ('03', 'Letusan Gunung Berapi', 'alam', 3),
  ('04', 'Banjir', 'alam', 4),
  ('05', 'Banjir Bandang', 'alam', 5),
  ('06', 'Tanah Longsor', 'alam', 6),
  ('07', 'Angin Topan/Kencang', 'alam', 7),
  ('08', 'Kekeringan', 'alam', 8),
  ('09', 'Gelombang Pasang', 'alam', 9),
  ('10', 'Kebakaran Hutan/Lahan', 'alam', 10),
  ('11', 'Kebakaran Permukiman', 'non_alam', 11),
  ('12', 'Epidemi/Wabah Penyakit', 'non_alam', 12),
  ('13', 'Kecelakaan Transportasi', 'non_alam', 13),
  ('14', 'Gagal Teknologi', 'non_alam', 14),
  ('15', 'Konflik Sosial', 'non_alam', 15),
  ('16', 'Lainnya', 'lainnya', 16)
ON CONFLICT (kode) DO NOTHING;

-- 7. ref_apbdes_kategori
CREATE TABLE IF NOT EXISTS ref_apbdes_kategori (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  jenis VARCHAR(20) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_apbdes_kategori_updated ON ref_apbdes_kategori;
DO $$
BEGIN
  CREATE TRIGGER ref_apbdes_kategori_updated BEFORE UPDATE ON ref_apbdes_kategori
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_apbdes_kategori TO authenticated;
GRANT ALL ON ref_apbdes_kategori TO service_role;
ALTER TABLE ref_apbdes_kategori ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_apbdes_kategori" ON ref_apbdes_kategori;
DO $$
BEGIN
  CREATE POLICY "Public read ref_apbdes_kategori" ON ref_apbdes_kategori FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_apbdes_kategori (kode, nama, jenis, urutan) VALUES
  ('PAD', 'Pendapatan Asli Desa (PAD)', 'pendapatan', 1),
  ('DD', 'Dana Desa (DD)', 'pendapatan', 2),
  ('ADD', 'Alokasi Dana Desa (ADD)', 'pendapatan', 3),
  ('BHPD', 'Bagian Hasil Pajak & Retribusi Daerah', 'pendapatan', 4),
  ('SOS', 'Bantuan Sosial dari Pemerintah', 'pendapatan', 5),
  ('BOP', 'Bantuan Operasional Pemerintah', 'pendapatan', 6),
  ('KOR', 'Koreksi/Surplus Tahun Lalu', 'pendapatan', 7),
  ('LAIN', 'Pendapatan Lain-Lain yang Sah', 'pendapatan', 8),
  ('BID', 'Bidang Penyelenggaraan Pemerintah Desa', 'belanja', 20),
  ('BPM', 'Bidang Pelaksanaan Pembangunan Desa', 'belanja', 21),
  ('BPK', 'Bidang Pembinaan Kemasyarakatan', 'belanja', 22),
  ('BPW', 'Bidang Pemberdayaan Masyarakat', 'belanja', 23),
  ('BKE', 'Bidang Keuangan & Pelayanan Publik', 'belanja', 24),
  ('BEM', 'Belanja Tidak Terduga (BTT)', 'belanja', 25),
  ('SILPA', 'Sisa Lebih Pembiayaan Anggaran (SILPA)', 'belanja', 26)
ON CONFLICT (kode) DO NOTHING;

-- 8. ref_sektor_umkm
CREATE TABLE IF NOT EXISTS ref_sektor_umkm (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_sektor_umkm_updated ON ref_sektor_umkm;
DO $$
BEGIN
  CREATE TRIGGER ref_sektor_umkm_updated BEFORE UPDATE ON ref_sektor_umkm
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_sektor_umkm TO authenticated;
GRANT ALL ON ref_sektor_umkm TO service_role;
ALTER TABLE ref_sektor_umkm ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_sektor_umkm" ON ref_sektor_umkm;
DO $$
BEGIN
  CREATE POLICY "Public read ref_sektor_umkm" ON ref_sektor_umkm FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_sektor_umkm (kode, nama, kategori, urutan) VALUES
  ('01', 'Pertanian & Perkebunan', 'agraris', 1),
  ('02', 'Peternakan', 'agraris', 2),
  ('03', 'Perikanan & Kelautan', 'agraris', 3),
  ('04', 'Pengolahan Hasil Pertanian', 'agraris', 4),
  ('05', 'Industri Kerajinan', 'industri', 5),
  ('06', 'Industri Makanan & Minuman', 'industri', 6),
  ('07', 'Industri Tekstil & Garmen', 'industri', 7),
  ('08', 'Pengelolaan Kayu & Mebel', 'industri', 8),
  ('09', 'Perdagangan Eceran/Kios', 'dagang', 9),
  ('10', 'Pedagang Keliling', 'dagang', 10),
  ('11', 'Warung/Makan Minum', 'dagang', 11),
  ('12', 'Jasa Angkutan/Ojek', 'jasa', 12),
  ('13', 'Jasa Bengkel/Montir', 'jasa', 13),
  ('14', 'Jasa Salon/Kecantikan', 'jasa', 14),
  ('15', 'Jasa Konstruksi', 'jasa', 15),
  ('16', 'Jasa Pendidikan/Bimbel', 'jasa', 16),
  ('17', 'Penginapan & Hospitality', 'jasa', 17),
  ('18', 'Wisata & Perhotelan', 'jasa', 18),
  ('19', 'Pertambangan & Quarry', 'pertambangan', 19),
  ('20', 'Lainnya', 'lainnya', 20)
ON CONFLICT (kode) DO NOTHING;

-- 9. ref_produk_kategori
CREATE TABLE IF NOT EXISTS ref_produk_kategori (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  kategori_utama VARCHAR(50),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DROP TRIGGER IF EXISTS ref_produk_kategori_updated ON ref_produk_kategori;
DO $$
BEGIN
  CREATE TRIGGER ref_produk_kategori_updated BEFORE UPDATE ON ref_produk_kategori
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON ref_produk_kategori TO authenticated;
GRANT ALL ON ref_produk_kategori TO service_role;
ALTER TABLE ref_produk_kategori ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ref_produk_kategori" ON ref_produk_kategori;
DO $$
BEGIN
  CREATE POLICY "Public read ref_produk_kategori" ON ref_produk_kategori FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

INSERT INTO ref_produk_kategori (kode, nama, kategori_utama, urutan) VALUES
  ('01', 'Sayuran', 'produk_tani', 1),
  ('02', 'Buah-buahan', 'produk_tani', 2),
  ('03', 'Padi & Gabah', 'produk_tani', 3),
  ('04', 'Palawija & Umbi', 'produk_tani', 4),
  ('05', 'Bumbu & Rempah', 'produk_tani', 5),
  ('06', 'Kopi & Teh', 'produk_tani', 6),
  ('07', 'Kelapa & Kopra', 'produk_tani', 7),
  ('08', 'Cengkeh & Kakao', 'produk_tani', 8),
  ('09', 'Gula Aren & Madu', 'produk_tani', 9),
  ('10', 'Tanaman Hias & Bunga', 'produk_tani', 10),
  ('11', 'Daging Sapi & Kerbau', 'peternakan', 11),
  ('12', 'Daging Ayam & Telur', 'peternakan', 12),
  ('13', 'Susu & Olahan Susu', 'peternakan', 13),
  ('14', 'Ikan Segar', 'perikanan', 14),
  ('15', 'Udang & Rajungan', 'perikanan', 15),
  ('16', 'Ikan Asin & Kering', 'perikanan', 16),
  ('17', 'Kerajinan Kayu', 'kerajinan', 17),
  ('18', 'Kerajinan Bambu & Rotan', 'kerajinan', 18),
  ('19', 'Tenun & Songket', 'kerajinan', 19),
  ('20', 'Anyaman & Pandan', 'kerajinan', 20),
  ('21', 'Keramik & Gerabah', 'kerajinan', 21),
  ('22', 'Makanan Olahan Lokal', 'makanan', 22),
  ('23', 'Minuman Tradisional', 'makanan', 23),
  ('24', 'Keripik & Abon', 'makanan', 24),
  ('25', 'Rempeyek & Kue Kering', 'makanan', 25),
  ('26', 'Jamu & Herbal', 'kesehatan', 26),
  ('27', 'Kosmetik Alami', 'kesehatan', 27),
  ('28', 'Batik & Sulam', 'fashion', 28),
  ('29', 'Tas & Sepatu Kulit', 'fashion', 29),
  ('30', 'Lainnya', 'lainnya', 30)
ON CONFLICT (kode) DO NOTHING;
