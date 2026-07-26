-- ============================================================
-- SEED: All tables seed for Seruni.id (FIXED schema)
-- Tanggal: 2026-08-01
-- Notes: Uses ON CONFLICT DO NOTHING - safe to run multiple times
-- ============================================================

BEGIN;

-- ============================================================
-- 1. SITE_SETTINGS
-- ============================================================
INSERT INTO public.site_settings (
  tenant_id, nama_resmi, tagline, alamat_kantor, telepon, email, jam_layanan,
  nomor_wa_resmi, wa_business_verified, social_media
) VALUES (
  (SELECT id FROM tenants WHERE subdomain = 'seruni' LIMIT 1),
  'Desa Seruni Mumbul',
  'Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.',
  'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
  '0376-000000',
  'kantor@serunimumbul.desa.id',
  'Senin-Kamis 08:00-15:00 WITA, Jumat 08:00-11:30 WITA',
  '+6287763170088',
  true,
  '{"facebook": "https://facebook.com/desa.serunimumbul", "instagram": "https://instagram.com/desa.serunimumbul", "youtube": "https://youtube.com/@desa.serunimumbul"}'::jsonb
) ON CONFLICT (tenant_id) DO NOTHING;

-- ============================================================
-- 2. REFERENCE TABLES (FIXED: kode required)
-- ============================================================

-- ref_agama (kode required, unique)
INSERT INTO public.ref_agama (kode, nama, nama_latin, urutan) VALUES
  ('01', 'Islam', 'Islam', 1),
  ('02', 'Kristen Protestan', 'Kristen', 2),
  ('03', 'Katolik', 'Katolik', 3),
  ('04', 'Hindu', 'Hindu', 4),
  ('05', 'Buddha', 'Buddha', 5),
  ('06', 'Khonghucu', 'Khonghucu', 6),
  ('07', 'Lainnya', 'Lainnya', 7)
ON CONFLICT (kode) DO NOTHING;

-- ref_pendidikan (kode required, unique)
INSERT INTO public.ref_pendidikan (kode, nama, jenjang, urutan) VALUES
  ('01', 'Tidak/Belum Sekolah', 'Tidak Sekolah', 1),
  ('02', 'Belum Tamat SD', 'Dasar', 2),
  ('03', 'SD/Sederajat', 'Dasar', 3),
  ('04', 'SLTP/Sederajat', 'Menengah', 4),
  ('05', 'SLTA/Sederajat', 'Menengah', 5),
  ('06', 'Diploma I/II', 'Tinggi', 6),
  ('07', 'Diploma III', 'Tinggi', 7),
  ('08', 'Diploma IV/S1', 'Tinggi', 8),
  ('09', 'S2', 'Tinggi', 9),
  ('10', 'S3', 'Tinggi', 10)
ON CONFLICT (kode) DO NOTHING;

-- ref_pekerjaan (kode required, unique)
INSERT INTO public.ref_pekerjaan (kode, nama, kelompok_utama, kategori, urutan) VALUES
  ('0100', 'Pelajar/Mahasiswa', '0', 'tidak_bekerja', 70),
  ('0200', 'Ibu Rumah Tangga', '0', 'tidak_bekerja', 71),
  ('0300', 'Tidak Bekerja', '0', 'tidak_bekerja', 72),
  ('6110', 'Petani Padi', '6', 'pertanian', 1),
  ('6120', 'Petani Palawija', '6', 'pertanian', 2),
  ('6210', 'Peternak', '6', 'pertanian', 10),
  ('6310', 'Nelayan', '6', 'pertanian', 15),
  ('4110', 'Karyawan Swasta', '4', 'formal', 50),
  ('4120', 'PNS/TNI/Polri', '4', 'formal', 51),
  ('5110', 'Pedagang Kecil', '5', 'informal', 30),
  ('9110', 'Buruh Bangunan', '9', 'informal', 60),
  ('9111', 'Buruh Pabrik', '9', 'formal', 61),
  ('7101', 'Guru', '7', 'profesional', 80),
  ('7102', 'Dokter', '7', 'profesional', 81),
  ('7103', 'Perawat', '7', 'profesional', 82)
ON CONFLICT (kode) DO NOTHING;

-- ref_status_perkawinan (kode required)
INSERT INTO public.ref_status_perkawinan (kode, nama, urutan) VALUES
  ('1', 'Belum Kawin', 1),
  ('2', 'Kawin', 2),
  ('3', 'Cerai Hidup', 3),
  ('4', 'Cerai Mati', 4)
ON CONFLICT (kode) DO NOTHING;

-- ref_golong_darah (kode required)
INSERT INTO public.ref_golong_darah (kode, nama) VALUES
  ('A', 'A'),
  ('B', 'B'),
  ('AB', 'AB'),
  ('O', 'O'),
  ('A+', 'A+'),
  ('B+', 'B+'),
  ('O+', 'O+'),
  ('AB+', 'AB+'),
  ('A-', 'A-'),
  ('B-', 'B-'),
  ('O-', 'O-'),
  ('AB-', 'AB-'),
  ('XX', 'Tidak Tahu')
ON CONFLICT (kode) DO NOTHING;

-- ref_warga_negara (kode required)
INSERT INTO public.ref_warga_negara (kode, nama) VALUES
  ('WNI', 'WNI - Warga Negara Indonesia'),
  ('WNA', 'WNA - Warga Negara Asing'),
  ('DW', 'Dwi Kewarganegaraan')
ON CONFLICT (kode) DO NOTHING;

-- ref_hubungan_kk (kode required)
INSERT INTO public.ref_hubungan_kk (kode, nama) VALUES
  ('KK', 'Kepala Keluarga'),
  ('IST', 'Istri'),
  ('SUA', 'Suami'),
  ('ANI', 'Anak'),
  ('MEN', 'Menantu'),
  ('CUC', 'Cucu'),
  ('ORT', 'Orang Tua'),
  ('MRT', 'Mertua'),
  ('KLR', 'Keluarga Lain'),
  ('PEM', 'Pembantu')
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- 3. WILAYAH DUSUN
-- ============================================================
INSERT INTO public.wilayah_dusun (nama, kk, jiwa, luas_ha, urutan) VALUES
  ('Mandar', 520, 2080, 3.2, 1),
  ('Presak', 485, 1940, 2.8, 2),
  ('Dames', 450, 1800, 3.5, 3),
  ('Batu Kolo', 482, 1928, 2.9, 4)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. PROFIL DESA
-- ============================================================
INSERT INTO public.profil_desa (sejarah, visi, misi, singleton) VALUES (
  '["Seruni Mumbul dibentuk pada tahun 1968 sebagai hasil pemekaran dari Desa Pringgabaya.", "Desa ini terletak di kaki timur Gunung Rinjani.", "Dikenal dengan tradisi tenun songket, hasil pertanian organik, dan gotong royong."]'::jsonb,
  'Terwujuda Desa Seruni Mumbul yang maju, mandiri, sejahtera dan berakhlak mulia',
  '["Meningkatkan kualitas layanan publik", "Membangun infrastruktur yang merata", "Meningkatkan kesejahteraan ekonomi", "Melestarikan budaya dan lingkungan", "Meningkatkan partisipasi masyarakat"]'::jsonb,
  true
) ON CONFLICT (singleton) DO NOTHING;

-- ============================================================
-- 5. DESA PAMONG
-- ============================================================
INSERT INTO public.desa_pamong (nama, jabatan, periode, urutan, no_hp) VALUES
  ('H. Ahmad Zaelani', 'Kepala Desa', '2022-2028', 1, '+6281234567890'),
  ('Siti Aminah, S.Pd', 'Sekretaris Desa', '2022-2028', 2, '+6281234567891'),
  ('Budi Santoso', 'Kasi Pemerintahan', '2022-2028', 3, '+6281234567892'),
  ('Dewi Rahayu', 'Kasi Kesejahteraan', '2022-2028', 4, '+6281234567893'),
  ('Ahmad Fauzi', 'Kasi Pembangunan', '2022-2028', 5, '+6281234567894'),
  ('Siti Nurhaliza', 'Kaur Keuangan', '2022-2028', 6, '+6281234567895'),
  ('Rudi Hermawan', 'Kaur Umum', '2022-2028', 7, '+6281234567896')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 6. LEMBAGA DESA
-- ============================================================
INSERT INTO public.lembaga_desa (nama, ketua, jumlah_anggota, urutan) VALUES
  ('BPD', 'H. Mansur', 9, 1),
  ('LPM', 'Sukarno', 7, 2),
  ('PKK', 'Hj. Fatmah', 15, 3),
  ('Karang Taruna', 'Andi Pratama', 25, 4),
  ('BUMDes Bina Seruni Mandiri', 'H. Marzuki', 8, 5)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 7. BERITA
-- ============================================================
INSERT INTO public.berita (tenant_id, kategori, judul, slug, ringkasan, isi, penulis, tanggal) VALUES
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Pembangunan', 'Progres Pengerasan Jalan Poros Desa Mandar Mencapai 78%', 'progres-pengerasan-jalan-mandar', 'Pengerasan jalan sepanjang 1,2 km ditargetkan rampung akhir Agustus 2026.', '["Pengerjaan pengerasan Jalan Poros Desa Mandar sepanjang 1,2 km telah mencapai progres fisik 78%.","Kegiatan ini didanai APBDes 2026 dengan pagu Rp 480 juta.","Penyelesaian ditargetkan pada 28 Agustus 2026."]'::jsonb, 'Kasi Pembangunan', '2026-07-17'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Kesehatan', 'Kasus Stunting Turun 12% Setelah Program PMT Terpadu', 'stunting-turun-12-persen', 'Hasil evaluasi Posyandu semester I menunjukkan penurunan prevalensi stunting.', '["Program PMT berbasis pangan lokal menurunkan prevalensi stunting.","Enam Posyandu mencatat 412 balita rutin terpantau.","Desa mengalokasikan tambahan Rp 60 juta untuk PMT."]'::jsonb, 'Kasi Kesejahteraan', '2026-07-15'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Ekonomi', 'BUMDes Seruni Buka Gerai Marketplace Digital', 'bumdes-buka-marketplace', 'Marketplace desa kini menampung 47 produk UMKM lokal.', '["BUMDes Bina Seruni Mandiri luncurkan gerai marketplace digital.","Transaksi bulan pertama menembus Rp 42 juta.","UMKM baru dapat mendaftar melalui portal."]'::jsonb, 'Direksi BUMDes', '2026-07-12'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Umum', 'Musyawarah Desa RPJMDes 2026-2032', 'musdes-rpjmdes-2026', 'Musyawarah Desa untuk menyusun Rencana Pembangunan Jangka Menengah.', '["Musyawarah Desa dilaksanakan pada 28 Juni 2026.","Hadir 87 warga dari 4 dusun.","Terdapat 47 usulan program untuk 6 tahun ke depan."]'::jsonb, 'Sekretaris Desa', '2026-06-28'),
('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Kebencanaan', 'Sosialisasi Gempa dan Tsunami', 'sosialisasi-gempa-tsunami', 'Belasan warga ikuti sosialisasi kesiapsiagaan bencana.', '["Penyuluh dan Tagana melakukan sosialisasi.","Peserta belajar mengenali tanda-tanda bahaya.","Desa memiliki 2 jalur evakuasi dan 3 titik pengungsian."]'::jsonb, 'Kasi Kesejahteraan', '2026-07-05')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 8. AGENDA
-- ============================================================
INSERT INTO public.agenda (tenant_id, jenis, judul, slug, deskripsi, tanggal, waktu, lokasi, penyelenggara) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Musdes', 'Musyawarah Desa Perencanaan RKPDes 2027', 'musdes-rkpdes-2027', 'Pembahasan prioritas pembangunan untuk tahun anggaran 2027.', '2026-07-28', '08.30-12.00 WITA', 'Aula Kantor Desa', 'Pemerintah Desa & BPD'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Posyandu', 'Posyandu Balita & Ibu Hamil', 'posyandu-mandar', 'Penimbangan, pengukuran, imunisasi, dan pembagian PMT untuk balita.', '2026-07-30', '08.00-11.00 WITA', 'Posyandu Melati III, Mandar', 'PKK & Puskesmas Pringgabaya'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Gotong Royong', 'Kerja Bakti Bersih Pantai', 'gotong-royong-pantai', 'Aksi bersih pantai lintas dusun dalam rangka HUT ke-58 Desa Seruni Mumbul.', '2026-08-02', '07.00-10.00 WITA', 'Pantai Seruni Mumbul', 'Karang Taruna & BUMDes'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Sosialisasi', 'Sosialisasi Program Bansos Semester II', 'sosialisasi-bansos-2', 'Penjelasan kriteria penerima BPNT & PKH periode Juli-Desember 2026.', '2026-08-05', '13.30-16.00 WITA', 'Balai Desa Dames', 'Kasi Kesejahteraan')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 9. GALERI
-- ============================================================
INSERT INTO public.galeri (tenant_id, judul, emoji, album, tanggal, urutan) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Pengerasan jalan Mandar', '🏗️', 'Pembangunan', '2026-07-15', 1),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Posyandu Bulanan', '👶', 'Kesehatan', '2026-07-01', 2),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Musdes RPJMDes', '🗳️', 'Kepemerintahan', '2026-06-28', 3),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Kerja Bakti', '🧹', 'Kemasyyarakatan', '2026-07-05', 4),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Pelatihan Tenun', '🧶', 'Ekonomi', '2026-06-20', 5)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 10. PENGUMUMAN
-- ============================================================
INSERT INTO public.pengumuman (tenant_id, nomor, tanggal, judul, ringkasan) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', '001/PEMDES-SM/VII/2026', '2026-07-01', 'Jadwal Layanan Surat Minggu Ini', 'Layanan pengajuan surat tetap buka Senin-Jumat pukul 08.00-14.00 WITA.'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', '002/PEMDES-SM/VII/2026', '2026-07-10', 'Pemberitahuan Pemadaman Listrik', 'AKN Lombok Timur akan melakukan pemadaman bergilir pada Kamis, 15 Juli 2026.'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', '003/PEMDES-SM/VII/2026', '2026-07-15', 'Pendaftaran Bantuan Langsung Tunai', 'BLT tahap 2 mulai pendaftaran 20-31 Juli 2026.')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. JENIS SURAT
-- ============================================================
INSERT INTO public.jenis_surat (nama, kode_surat, kategori, lampiran_default, multipart) VALUES
  ('Surat Keterangan Domisili', 'SKD', 'keterangan', 0, false),
  ('Surat Keterangan Usaha', 'SKU', 'keterangan', 0, false),
  ('Surat Keterangan Tidak Mampu', 'SKTM', 'keterangan', 1, false),
  ('Surat Keterangan Kelahiran', 'SKL', 'kelahiran', 0, false),
  ('Surat Keterangan Kematian', 'SKK', 'kematian', 1, false),
  ('Surat Keterangan Pengantar Nikah', 'SKPN', 'nikah', 2, true),
  ('Surat Pengantar Permohonan KTP', 'SP-KTP', 'administrasi', 0, false),
  ('Surat Pengantar KK', 'SP-KK', 'administrasi', 0, false),
  ('Surat Keterangan Ahli Waris', 'SKAW', 'waris', 3, true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 12. BIDANG KEGIATAN
-- ============================================================
INSERT INTO public.bidang_kegiatan (kode, nama) VALUES
  ('1', 'Penyelenggaraan Pemerintahan Desa'),
  ('2', 'Pelaksanaan Pembangunan Desa'),
  ('3', 'Pembinaan Kemasyarakatan'),
  ('4', 'Pemberdayaan Masyarakat'),
  ('5', 'Penanggulangan Bencana & Mendesak')
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- 13. BANSOS
-- ============================================================
INSERT INTO public.bansos (kode, nama, sumber, deskripsi, periode_mulai, periode_selesai, kuota, aktif) VALUES
  ('BLT-DD', 'Bantuan Langsung Tunai Dana Desa', 'APBN/Dana Desa', 'Bantuan langsung tunai untuk keluarga penerima manfaat', '2026-01-01', '2026-12-31', 45, true),
  ('BPNT', 'Bantuan Pangan Non Tunai', 'APBN', 'Bantuan pangan melalui mekanisme transaksi elektronik', '2026-01-01', '2026-12-31', 120, true),
  ('PKH', 'Program Keluarga Harapan', 'APBN', 'Bantuan sosial bersyarat untuk keluarga miskin', '2026-01-01', '2026-12-31', 85, true),
  ('BSUM', 'Bantuan Sosial Usaha Mikro', 'APBD Kab', 'Bantuan modal usaha mikro untuk warga kurang mampu', '2026-03-01', '2026-09-30', 30, true)
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- 14. POSYANDU
-- ============================================================
INSERT INTO public.posyandu (nama, dusun, kader, hari_posyandu, jam_mulai, jam_selesai) VALUES
  ('Melati I', 'Mandar', 'Siti Aminah', 'Selasa', '08:00', '11:00'),
  ('Melati II', 'Mandar', 'Dewi Rohmah', 'Rabu', '08:00', '11:00'),
  ('Melati III', 'Presak', 'Nur Hayati', 'Kamis', '08:00', '11:00'),
  ('Anggrek I', 'Dames', 'Siti Rahayu', 'Senin', '08:00', '11:00'),
  ('Anggrek II', 'Batu Kolo', 'Lisa Andriyani', 'Jumat', '08:00', '11:00')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 15. INFRASTRUKTUR
-- ============================================================
INSERT INTO public.infrastruktur (nama, jenis, dusun, deskripsi, kondisi, tahun_pembuatan) VALUES
  ('Jalan Poros Mandar-Presak', 'jalan', 'Mandar', 'Jalan desa berbatu sepanjang 1,2 km', 'cukup', 2021),
  ('Saluran Irigasi Dames', 'bridging', 'Dames', 'Saluran irigasi primer sepanjang 800 meter', 'baik', 2019),
  ('Pasar Seruni', 'pasar', 'Mandar', 'Pasar desa dengan 45 kios dan 20 los', 'baik', 2018),
  ('Sumur Bor DSTW', 'air', 'Presak', 'Sumur bor dengan kapasitas 5 liter/detik', 'baik', 2020),
  ('Gedung PAUD', 'dan_lainnya', 'Mandar', 'Gedung PAUD Melati dengan kapasitas 40 anak', 'baik', 2022)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 16. HERO SLIDER
-- ============================================================
INSERT INTO public.hero_slider (judul, sub_judul, deskripsi, gambar_url, tombol_teks, tombol_url, urutan, aktif) VALUES
  ('Selamat Datang di Desa Seruni Mumbul', 'Melayani dengan Sepenuh Hati', 'Portal resmi Pemerintah Desa untuk informasi dan layanan publik', 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=1920', 'Pelajari Lebih Lanjut', '/profil-desa', 1, true),
  ('Layanan Surat Online', 'Ajukan Surat Mudah dan Cepat', 'Dapatkan surat keterangan dari rumah tanpa antri', 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=1920', 'Ajukan Surat', '/layanan/surat', 2, true),
  ('Partisipasi Masyarakat', 'Suaramu Berharga', 'Ikut serta dalam pembangunan desa melalui voting dan usulan', 'https://images.unsplash.com/photo-1531206715517-5c0ba140b2b8?w=1920', 'Ikuti Voting', '/partisipasi/voting', 3, true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 17. SURAT TEMPLATE
-- ============================================================
INSERT INTO public.surat_template (nama, kode, is_default, is_active, judul_instansi_text, sub_judul_instansi_text, nama_desa_text, alamat_desa_text, footer_ttd_kanan_judul) VALUES
  ('Template Standard Lombok Timur', 'STD_LOMBOK_TIMUR', true, true, 'PEMERINTAH KABUPATEN LOMBOK TIMUR', 'KECAMATAN PRINGGABAYA', 'DESA SERUNI MUMBUL', 'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654', 'Kepala Desa Seruni Mumbul')
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- 18. REF UPLOAD PREFERENCES
-- ============================================================
INSERT INTO public.ref_upload_preferences (kategori, folder_path, max_size_mb, is_required, deskripsi) VALUES
  ('foto_ktp', 'surat/ktp', 5, true, 'Foto KTP pemohon'),
  ('foto_kk', 'surat/kk', 5, false, 'Foto Kartu Keluarga'),
  ('foto_selfie_ktp', 'surat/selfie', 5, true, 'Foto selfie dengan KTP'),
  ('akta_lahir', 'surat/akta', 10, false, 'Akta Kelahiran'),
  ('akta_nikah', 'surat/akta', 10, false, 'Akta Nikah'),
  ('dokumen_pendukung', 'surat/pendukung', 10, false, 'Dokumen pendukung'),
  ('foto_profil', 'profil', 2, false, 'Foto profil'),
  ('foto_galeri', 'galeri', 10, false, 'Foto galeri'),
  ('foto_kegiatan', 'kegiatan', 10, false, 'Foto kegiatan'),
  ('foto_produk', 'produk', 5, false, 'Foto produk UMKM')
ON CONFLICT (kategori) DO NOTHING;

-- ============================================================
-- 19. IDENTITAS DESA
-- ============================================================
INSERT INTO public.identitas_desa (singleton, nama_desa, kabupaten, kecamatan, provinsi, kode_pos, logo_url, slogan, tahun_bentuk, luas_wilayah, koordinat_lat, koordinat_lng, zoom_level) VALUES (
  true,
  'Seruni Mumbul',
  'Lombok Timur',
  'Pringgabaya',
  'Nusa Tenggara Barat',
  '83654',
  'https://storage.googleapis.com/gpt-engineer-file-uploads/aMjanxrDoUP1QJ5krTWiqhWnSbF3/uploads/1758710472461-logo-icon-BG-circle%20copy.png',
  'Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.',
  1968,
  12.4,
  -8.5589,
  116.5847,
  14
) ON CONFLICT (singleton) DO NOTHING;

COMMIT;

-- ============================================================
-- SUMMARY
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'SEED COMPLETE - Seruni.id';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Tables seeded:';
  RAISE NOTICE '  - site_settings';
  RAISE NOTICE '  - ref_agama, ref_pendidikan, ref_pekerjaan, dll';
  RAISE NOTICE '  - wilayah_dusun';
  RAISE NOTICE '  - profil_desa';
  RAISE NOTICE '  - desa_pamong, lembaga_desa';
  RAISE NOTICE '  - berita, agenda, galeri, pengumuman';
  RAISE NOTICE '  - jenis_surat, bansos, posyandu, infrastruktur';
  RAISE NOTICE '  - hero_slider, surat_template';
  RAISE NOTICE '  - identitas_desa';
  RAISE NOTICE '';
END $$;
