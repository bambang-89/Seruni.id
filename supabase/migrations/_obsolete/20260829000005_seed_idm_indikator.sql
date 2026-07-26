-- ============================================================
-- SEED 1: IDM INDIKATOR
-- ============================================================

DELETE FROM idm_indikator;

INSERT INTO idm_indikator (kode, nama, dimensi, bobot, tipe, deskripsi, aktif) VALUES
-- Ekonomi (6 indikator)
('EKO.01', 'Ketersediaan Fasilitas Kesehatan', 'Ekonomi', 1.0, 'fasilitas', 'Akses terhadap fasilitas kesehatan', true),
('EKO.02', 'Akses Air Bersih', 'Ekonomi', 1.0, 'air', 'Akses air bersih layak', true),
('EKO.03', 'Akses Sanitasi Layak', 'Ekonomi', 1.0, 'sanitasi', 'Akses sanitasi layak', true),
('EKO.04', 'Jenis Pekerjaan Utama', 'Ekonomi', 1.0, 'pekerjaan', 'Diversifikasi mata pencaharian', true),
('EKO.05', 'Pendapatan Per Kapita', 'Ekonomi', 1.0, 'pendapatan', 'Pendapatan per kapita desa', true),
('EKO.06', 'Kemiskinan Ekstrem', 'Ekonomi', 1.0, 'kemiskinan', 'Persentase penduduk miskin ekstrem', true),

-- Kesehatan (5 indikator)
('KES.01', 'Angka Kematian Bayi', 'Kesehatan', 1.0, 'kematian', 'Kematian bayi per 1000 kelahiran', true),
('KES.02', 'Angka Kematian Balita', 'Kesehatan', 1.0, 'kematian', 'Kematian balita per 1000 kelahiran', true),
('KES.03', 'Prevalensi Stunting', 'Kesehatan', 1.0, 'stunting', 'Persentase balita stunting', true),
('KES.04', 'Akses Imunisasi', 'Kesehatan', 1.0, 'imunisasi', 'Cakupan imunisasi dasar lengkap', true),
('KES.05', 'Kesehatan Ibu & KB', 'Kesehatan', 1.0, 'ibu', 'Pelayanan kesehatan ibu dan KB', true),

-- Pendidikan (5 indikator)
('PEN.01', 'Angka Putus Sekolah', 'Pendidikan', 1.0, 'pendidikan', 'Tingkat putus sekolah', true),
('PEN.02', 'Ketersediaan Sekolah', 'Pendidikan', 1.0, 'sekolah', 'Akses terhadap sekolah', true),
('PEN.03', 'Tingkat Pendidikan Penduduk', 'Pendidikan', 1.0, 'pendidikan', 'Rata-rata tingkat pendidikan', true),
('PEN.04', 'Tingkat Melek Huruf', 'Pendidikan', 1.0, 'melek_huruf', 'Persentase melek huruf', true),
('PEN.05', 'Partisipasi PAUD', 'Pendidikan', 1.0, 'paud', 'Cakupan partisipasi PAUD', true),

-- Permukiman (5 indikator)
('PER.01', 'Ketersediaan Rumah Layak', 'Permukiman', 1.0, 'rumah', 'Persentase rumah layak huni', true),
('PER.02', 'Ketersediaan Listrik', 'Permukiman', 1.0, 'listrik', 'Rasio rumah berlistrik', true),
('PER.03', 'Keterbukaan Transportasi', 'Permukiman', 1.0, 'transport', 'Akses jalan transportasi', true),
('PER.04', 'Persampahan', 'Permukiman', 1.0, 'sampah', 'Pengelolaan persampahan', true),
('PER.05', 'Drainase', 'Permukiman', 1.0, 'drainase', 'Kondisi drainase/pengairan', true),

-- Modal Sosial (6 indikator)
('MOS.01', 'Kapasitas Pemerintah Desa', 'Modal Sosial', 1.0, 'pemerintah', 'APBDes dan kapasitas aparatur', true),
('MOS.02', 'Keaktifan BPD', 'Modal Sosial', 1.0, 'lembaga', 'Keaktifan Badan Permusyawaratan', true),
('MOS.03', 'Keaktifan Lembaga Desa', 'Modal Sosial', 1.0, 'lembaga', 'Keaktifan lembaga kemasyarakatan', true),
('MOS.04', 'Partisipasi Publik', 'Modal Sosial', 1.0, 'partisipasi', 'Partisipasi masyarakat', true),
('MOS.05', 'Toleransi Sosial', 'Modal Sosial', 1.0, 'toleransi', 'Toleransi dan kerukunan', true),
('MOS.06', 'Kesiapan Donor', 'Modal Sosial', 1.0, 'donor', 'Kesiapan dan keberdayaan donor', true),

-- Ekologi (5 indikator)
('EKO.07', 'RTNH/RTH', 'Ekologi', 1.0, 'hutan', 'Ruang terbuka hijau/hutan', true),
('EKO.08', 'Kelola Sampah', 'Ekologi', 1.0, 'sampah', 'Pengelolaan sampah', true),
('EKO.09', 'Drainase/Limbah', 'Ekologi', 1.0, 'drainase', 'Drainase dan limbah', true),
('EKO.10', 'Pencemaran Air', 'Ekologi', 1.0, 'air', 'Pencemaran air', true),
('EKO.11', 'Tanggap Bencana', 'Ekologi', 1.0, 'bencana', 'Kesiapan tanggap bencana', true);

-- VERIFIKASI
SELECT 'idm_indikator: ' || count(*) FROM idm_indikator;
