-- ============================================================
-- SEED DATA - Seruni Mumbul (Tenant-Aware)
-- ============================================================

-- Fix missing columns in kegiatan_pembangunan
ALTER TABLE public.kegiatan_pembangunan ADD COLUMN IF NOT EXISTS created_by UUID;
ALTER TABLE public.kegiatan_pembangunan ADD COLUMN IF NOT EXISTS updated_by UUID;

-- Fix missing columns in usulan_warga (referenced by trigger)
ALTER TABLE public.usulan_warga ADD COLUMN IF NOT EXISTS estimasi_anggaran NUMERIC;
ALTER TABLE public.usulan_warga ADD COLUMN IF NOT EXISTS pemohon_id UUID;
ALTER TABLE public.usulan_warga ADD COLUMN IF NOT EXISTS updated_by UUID;

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  -- Get or create tenant
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    v_tenant_id := gen_random_uuid();
    INSERT INTO public.tenants (id, nama_desa, subdomain) VALUES (v_tenant_id, 'Desa Seruni Mumbul', 'seruni');
  END IF;
  RAISE NOTICE 'Using tenant_id: %', v_tenant_id;

  -- ============================================================
  -- 1. PROFIL DESA
  -- ============================================================
  UPDATE public.profil_desa SET
    sejarah = '["Desa Seruni Mumbul dibentuk pada tahun 1968 sebagai hasil pemekaran dari Desa Pringgabaya.","Sejak 2010 mengembangkan perikanan, tenun, dan ekowisata pantai."]'::jsonb,
    visi = 'Terwujudnya Desa Seruni Mumbul yang mandiri, berbudaya, dan berdaya saing.',
    misi = '["Tata kelola transparan dan akuntabel.","Layanan publik digital.","Ekonomi kerakyatan.","Menguatkan budaya Sasak."]'::jsonb
  WHERE tenant_id = v_tenant_id;

  INSERT INTO public.profil_desa (tenant_id, singleton, sejarah, visi, misi)
  SELECT v_tenant_id, true,
    '["Desa Seruni Mumbul dibentuk pada tahun 1968.","Sejak 2010 mengembangkan perikanan, tenun, dan ekowisata."]'::jsonb,
    'Terwujudnya Desa Seruni Mumbul yang mandiri dan berdaya saing.',
    '["Tata kelola transparan.","Layanan publik digital.","Ekonomi kerakyatan.","Menguatkan budaya Sasak."]'::jsonb
  WHERE NOT EXISTS (SELECT 1 FROM public.profil_desa WHERE tenant_id = v_tenant_id);

  -- ============================================================
  -- 2. DESA PAMONG
  -- ============================================================
  INSERT INTO public.desa_pamong (tenant_id, nama, jabatan, periode, urutan)
  SELECT v_tenant_id, nama, jabatan, periode, urutan FROM (VALUES
    ('H. Lalu Ahmad Saputra', 'Kepala Desa', '2024-2030', 1),
    ('Baiq Nuraini', 'Sekretaris Desa', NULL, 2),
    ('Muhammad Sabri', 'Kasi Pemerintahan', NULL, 3),
    ('Lalu Zainuddin', 'Kasi Kesejahteraan', NULL, 4),
    ('Hj. Sri Wahyuni', 'Kasi Pelayanan', NULL, 5),
    ('Baiq Rahma Dewi', 'Kaur Keuangan', NULL, 6),
    ('Ahmad Fauzi', 'Kaur Perencanaan', NULL, 7),
    ('Lalu Ismail', 'Kaur Tata Usaha dan Umum', NULL, 8)
  ) AS t(nama, jabatan, periode, urutan)
  WHERE NOT EXISTS (SELECT 1 FROM public.desa_pamong WHERE nama = t.nama);

  -- ============================================================
  -- 3. WILAYAH DUSUN
  -- ============================================================
  INSERT INTO public.wilayah_dusun (tenant_id, nama, kk, jiwa, luas_ha, urutan)
  SELECT v_tenant_id, nama, kk, jiwa, luas_ha, urutan FROM (VALUES
    ('Mandar', 0, 0, 0, 1),
    ('Sasak', 0, 0, 0, 2),
    ('Dames', 0, 0, 0, 3),
    ('Brangtapen Asri', 0, 0, 0, 4)
  ) AS t(nama, kk, jiwa, luas_ha, urutan)
  WHERE NOT EXISTS (SELECT 1 FROM public.wilayah_dusun WHERE nama = t.nama);

  -- ============================================================
  -- 4. LEMBAGA DESA
  -- ============================================================
  INSERT INTO public.lembaga_desa (tenant_id, nama, ketua, jumlah_anggota, urutan)
  SELECT v_tenant_id, nama, ketua, jumlah_anggota, urutan FROM (VALUES
    ('Badan Permusyawaratan Desa (BPD)', 'H. Muhaimin', 9, 1),
    ('LPMD', 'Lalu Sudirman', 11, 2),
    ('PKK Desa', 'Hj. Nurhayati', 25, 3),
    ('Karang Taruna Seruni', 'Ahmad Rizki', 42, 4),
    ('Linmas', 'Muhammad Yusuf', 18, 5),
    ('BUMDes Bina Seruni Mandiri', 'Baiq Salma', 7, 6)
  ) AS t(nama, ketua, jumlah_anggota, urutan)
  WHERE NOT EXISTS (SELECT 1 FROM public.lembaga_desa WHERE nama = t.nama);

  -- ============================================================
  -- 5. SURAT JENIS
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan)
  SELECT v_tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan FROM (VALUES
    ('SKD', 'F.1.01', 'Surat Keterangan Domisili', true, 1),
    ('SKTM', 'F.1.02', 'Surat Keterangan Tidak Mampu', true, 2),
    ('SKU', 'F.1.03', 'Surat Keterangan Usaha', true, 3),
    ('SPN', 'F.1.04', 'Surat Pengantar Nikah (N1-N4)', true, 4),
    ('SKW', 'F.1.05', 'Surat Keterangan Waris', true, 5),
    ('SKCK', 'F.1.06', 'Pengantar SKCK', true, 6),
    ('SKKL', 'F.1.07', 'Surat Keterangan Kelahiran', true, 7),
    ('SKKM', 'F.1.08', 'Surat Keterangan Kematian', true, 8)
  ) AS t(kode_surat, kode_klasifikasi, nama, aktif, urutan)
  WHERE NOT EXISTS (SELECT 1 FROM public.surat_jenis WHERE kode_surat = t.kode_surat);

  -- ============================================================
  -- 6. KEGIATAN PEMBANGUNAN
  -- ============================================================
  INSERT INTO public.kegiatan_pembangunan (tenant_id, tahun, bidang, nama_kegiatan, lokasi, volume, anggaran, realisasi, sumber_dana, status)
  SELECT v_tenant_id, tahun, bidang, nama_kegiatan, lokasi, volume, anggaran, realization, sumber_dana, status::workflow_status FROM (VALUES
    (2026, 'Pembangunan Desa', 'Rehabilitasi Saluran Irigasi Dusun Sasak', 'Sasak', '1.2 km', 280000000, 229600000, 'APBDes', 'diproses'::workflow_status),
    (2026, 'Pembangunan Desa', 'Pembangunan MCK Umum Pasar Seruni', 'Pusat Desa', '1 unit', 150000000, 67500000, 'APBDes', 'diproses'::workflow_status),
    (2026, 'Pembangunan Desa', 'Pengadaan Lampu PJU Tenaga Surya', 'Seluruh ', '30 titik', 90000000, 27000000, 'APBDes', 'diproses'::workflow_status)
  ) AS t(tahun, bidang, nama_kegiatan, lokasi, volume, anggaran, realization, sumber_dana, status)
  WHERE NOT EXISTS (SELECT 1 FROM public.kegiatan_pembangunan WHERE nama_kegiatan = t.nama_kegiatan);

  -- ============================================================
  -- 7. USULAN WARGA
  -- ============================================================
  INSERT INTO public.usulan_warga (tenant_id, nomor_tiket, nama, kontak, dusun, kategori, judul, deskripsi, lokasi, status, vote_count)
  SELECT v_tenant_id, nomor_tiket, nama, kontak, dusun, kategori::usulan_kategori, judul, deskripsi, lokasi, status::usulan_status, vote_count FROM (VALUES
    ('USL-2026-001', 'Ahmad Zulkifli', '+6281234567001', 'Mandar', 'infrastruktur', 'Perbaikan Jalan Poros Mandar-Sasak', 'Jalan rusak 2,3 km.', 'Mandar-Sasak', 'ditindaklanjuti', 342),
    ('USL-2026-002', 'Siti Aminah', '+6281234567002', 'Dames', 'pendidikan', 'Pembangunan PAUD Dusun Dames', 'PAUD untuk 87 balita.', 'Dames', 'ditindaklanjuti', 289),
    ('USL-2026-003', 'Muhammad Ali', '+6281234567003', 'Brangtapen Asri', 'infrastruktur', 'Sumur Bor Air Bersih Dusun Brangtapen Asri', 'Air bersih terbatas.', 'Brangtapen Asri', 'diverifikasi', 251),
    ('USL-2026-004', 'Hajjah Rahayu', '+6281234567004', 'Dames', 'kesehatan', 'Renovasi Poskesdes Utama', 'Poskesdes perlu renovasi.', 'Pusat Desa', 'diverifikasi', 198),
    ('USL-2026-005', 'Budi Santoso', '+6281234567005', 'Brangtapen Asri', 'sosial', 'Beasiswa Dusun Nelayan Tidak Mampu', '12 anak nelayan.', 'Brangtapen Asri', 'ditindaklanjuti', 176),
    ('USL-2026-006', 'Rina Marlina', '+6281234567006', 'Mandar', 'ekonomi', 'Pelatihan Digital UMKM', 'Pemasaran digital.', 'Mandar', 'diverifikasi', 154),
    ('USL-2026-007', 'H. Lalu Husain', '+6281234567007', 'Brangtapen Asri', 'lingkungan', 'Pengadaan Kapal Sampah Brangtapen Asri', 'Sampah plastik.', 'Brangtapen Asri', 'diverifikasi', 132),
    ('USL-2026-008', 'Nurhayati', '+6281234567008', 'Sasak', 'pendidikan', 'Rumah Baca ', 'Ruang baca anak.', 'Sasak', 'diverifikasi', 118),
    ('USL-2026-009', 'Ahmad Fauzi', '+6281234567009', 'Mandar', 'sosial', 'Rehab Lapangan Sepakbola', 'Lapangan perlu rehab.', 'Mandar', 'diverifikasi', 97),
    ('USL-2026-010', 'Siti Zahra', '+6281234567010', 'Brangtapen Asri', 'lingkungan', 'Bank Sampah Terpadu', 'Pengelolaan sampah.', 'Brangtapen Asri', 'diverifikasi', 84)
  ) AS t(nomor_tiket, nama, kontak, dusun, kategori, judul, deskripsi, lokasi, status, vote_count)
  WHERE NOT EXISTS (SELECT 1 FROM public.usulan_warga WHERE nomor_tiket = t.nomor_tiket);

  -- ============================================================
  -- 8. POTENSI WISATA
  -- ============================================================
  INSERT INTO public.potensi_wisata (tenant_id, nama, jenis, dusun, deskripsi, fasilitas, latitude, longitude, status)
  SELECT v_tenant_id, nama, jenis, dusun, deskripsi, fasilitas, latitude, longitude, status FROM (VALUES
    ('Pantai Seruni Mumbul', 'Wisata Bahari', 'Brangtapen Asri', 'Pantai berpasir putih 2,4 km dengan snorkeling.', 'Gazebo, MCK, Warung', -8.5432, 116.6543, 'publish'),
    ('Bukit Panorama Sasak', 'Ekowisata', 'Sasak', 'Titik pandang matahari terbit di 380 mdpl.', 'Jalur tracking', -8.5210, 116.6780, 'publish'),
    ('Sentra Tenun Songket Sasak', 'Wisata Budaya', 'Dames', 'Sanggar tenun aktif di .', 'Sanggar tenun', -8.5350, 116.6620, 'publish')
  ) AS t(nama, jenis, dusun, deskripsi, fasilitas, latitude, longitude, status)
  WHERE NOT EXISTS (SELECT 1 FROM public.potensi_wisata WHERE nama = t.nama);

  -- ============================================================
  -- 9. POTENSI UMKM
  -- ============================================================
  INSERT INTO public.potensi_umkm (tenant_id, tipe, nama, pemilik, sektor, dusun, kontak, deskripsi, status)
  SELECT v_tenant_id, tipe, nama, pemilik, sektor, dusun, kontak, deskripsi, status FROM (VALUES
    ('Kuliner', 'UMKM Madu Trigona Seruni', 'Hj. Rina', 'Perlebahan', 'Mandar', '+6281234567101', 'Madu trigona premium.', 'publish'),
    ('Kuliner', 'Koperasi Tani Maju', 'Andi Rahman', 'Pertanian', 'Sasak', '+6281234567102', 'Kopi robusta.', 'publish'),
    ('Kerajinan', 'Sanggar Tenun Ibu Aminah', 'Siti Aminah', 'Kerajinan', 'Dames', '+6281234567103', 'Tenun songket Sasak.', 'publish'),
    ('Kuliner', 'UMKM Brangtapen Asri Mumbul', 'H. Basri', 'Perikanan', 'Brangtapen Asri', '+6281234567104', 'Olahan rumput laut.', 'publish')
  ) AS t(tipe, nama, pemilik, sektor, dusun, kontak, deskripsi, status)
  WHERE NOT EXISTS (SELECT 1 FROM public.potensi_umkm WHERE nama = t.nama);

  -- ============================================================
  -- 10. PRODUK MARKETPLACE
  -- ============================================================
  INSERT INTO public.potensi_produk (tenant_id, penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured, status)
  SELECT v_tenant_id, penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured, status FROM (VALUES
    ('Hj. Rina', 'Madu Trigona Seruni 500ml', 'Makanan', 95000, 'botol', 50, 'Madu trigona premium', true, 'publish'),
    ('Andi Rahman', 'Kopi Robusta Sembalun', 'Minuman', 65000, '250g', 100, 'Kopi robusta pilihan', true, 'publish'),
    ('Siti Aminah', 'Tenun Songket Sasak Motif Seruni', 'Kerajinan', 450000, 'helai', 15, 'Tenun songket asli', true, 'publish'),
    ('H. Basri', 'Kerupuk Rumput Laut', 'Makanan', 22000, 'bungkus', 200, 'Kerupuk rumput laut', true, 'publish')
  ) AS t(penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured, status)
  WHERE NOT EXISTS (SELECT 1 FROM public.potensi_produk WHERE nama = t.nama);

  -- ============================================================
  -- 11. IDM STATUS DESA
  -- ============================================================
  INSERT INTO public.idm_status_desa (tenant_id, status, total_skor, dimensi_scores)
  VALUES (v_tenant_id, 'Berkembang', 0.7412, '{"Kesehatan":0.84,"Pendidikan":0.90,"Modal Sosial":0.76,"Permukiman":0.82,"Ekonomi":0.72,"Ekologi":0.88}'::jsonb)
  ON CONFLICT (tenant_id) DO UPDATE SET status = EXCLUDED.status, total_skor = EXCLUDED.total_skor, dimensi_scores = EXCLUDED.dimensi_scores;

  RAISE NOTICE 'All tenant-aware tables: DONE';
END $$;

-- ============================================================
-- 12. BERITA (no tenant_id)
-- ============================================================
INSERT INTO public.berita (slug, kategori, judul, ringkasan, isi, penulis, tanggal, published)
SELECT slug, kategori, judul, ringkasan, isi, penulis, tanggal, published FROM (VALUES
  (
    'progres-pengerasan-jalan-karang-baru',
    'Pembangunan',
    'Progres Pengerasan Jalan Mandar Mencapai 78%',
    'Kegiatan pengerasan jalan sepanjang 1,2 km ditargetkan rampung.',
    '["Pengerjaan telah mencapai 78%.","Target selesai 28 Agustus 2026.","Mengurangi waktu tempuh."]'::jsonb,
    'Kasi Pembangunan',
    '2026-07-17'::date,
    true
  ),
  (
    'stunting-turun-12-persen',
    'Kesehatan',
    'Kasus Stunting Turun 12% Setelah Program PMT Terpadu',
    'Hasil evaluasi Posyandu semester I menunjukkan penurunan stunting.',
    '["PMT lokal menurunkan stunting.","412 balita terpantau.","Alokasi Rp 60 juta."]'::jsonb,
    'Kasi Kesejahteraan',
    '2026-07-15'::date,
    true
  ),
  (
    'bumdes-buka-marketplace',
    'Ekonomi',
    'BUMDes Seruni Buka Gerai Marketplace Digital',
    'Marketplace desa menampung 47 produk UMKM lokal.',
    '["47 produk UMKM tersedia.","Transaksi pertama Rp 42 juta."]'::jsonb,
    'Direktur BUMDes',
    '2026-07-12'::date,
    true
  )
) AS t(slug, kategori, judul, ringkasan, isi, penulis, tanggal, published)
WHERE NOT EXISTS (SELECT 1 FROM public.berita WHERE slug = t.slug);

-- ============================================================
-- 13. AGENDA (no tenant_id)
-- ============================================================
INSERT INTO public.agenda (slug, jenis, judul, tanggal, waktu, lokasi, penyelenggara, deskripsi)
SELECT slug, jenis, judul, tanggal, waktu, lokasi, penyelenggara, deskripsi FROM (VALUES
  ('musdes-rkpdes-2027', 'Musdes', 'Musyawarah Desa Perencanaan RKPDes 2027', '2026-07-28'::date, '08.30-12.00 WITA', 'Aula Kantor Desa', 'Pemerintah Desa dan BPD', 'Pembahasan prioritas pembangunan 2027.'),
  ('posyandu-karang-baru', 'Posyandu', 'Posyandu Balita Mandar', '2026-07-30'::date, '08.00-11.00 WITA', 'Posyandu Melati III', 'PKK Desa dan Puskesmas', 'Penimbangan dan imunisasi.'),
  ('gotong-royong-pantai', 'Gotong Royong', 'Kerja Bakti Bersih Pantai Seruni', '2026-08-02'::date, '07.00-10.00 WITA', 'Pantai Seruni', 'Karang Taruna dan BUMDes', 'Aksi bersih pantai.'),
  ('sosialisasi-bansos', 'Sosialisasi', 'Sosialisasi Program Bansos Semester II', '2026-08-05'::date, '13.30-16.00 WITA', 'Balai Desa', 'Kasi Kesejahteraan', 'Penjelasan BPNT dan PKH.')
) AS t(slug, jenis, judul, tanggal, waktu, lokasi, penyelenggara, deskripsi)
WHERE NOT EXISTS (SELECT 1 FROM public.agenda WHERE slug = t.slug);

-- ============================================================
-- 14. PENGUMUMAN (no tenant_id)
-- ============================================================
INSERT INTO public.pengumuman (nomor, tanggal, judul, ringkasan)
SELECT nomor, tanggal, judul, ringkasan FROM (VALUES
  ('148/PMR/SM/VII/2026', '2026-07-16'::date, 'Jadwal Musdes Perencanaan RKPDes 2027', 'Undangan untuk perwakilan dusun.'),
  ('146/PMR/SM/VII/2026', '2026-07-10'::date, 'Pemadaman Air Bersih Sementara', 'Perbaikan pipa PAMDes.'),
  ('142/PMR/SM/VII/2026', '2026-07-04'::date, 'Pendaftaran Beasiswa Dusun Nelayan', '5-20 Juli 2026.'),
  ('138/PMR/SM/VI/2026', '2026-06-28'::date, 'Verifikasi Ulang DTKS Semester II', 'Kader dusun berkunjung.')
) AS t(nomor, tanggal, judul, ringkasan)
WHERE NOT EXISTS (SELECT 1 FROM public.pengumuman WHERE nomor = t.nomor);

-- ============================================================
-- 15. GALERI (no tenant_id)
-- ============================================================
INSERT INTO public.galeri (judul, emoji, album, tanggal, urutan)
SELECT judul, emoji, album, tanggal, urutan FROM (VALUES
  ('Festival Panen Raya 2026', 'festival', 'Kegiatan Desa', '2026-04-18'::date, 1),
  ('Musdes Perencanaan', 'musyawarah', 'Kegiatan Desa', '2026-03-12'::date, 2),
  ('Posyandu Balita', 'bayi', 'Kesehatan', '2026-05-08'::date, 3),
  ('Gotong Royong Pantai', 'pantai', 'Lingkungan', '2026-06-15'::date, 4),
  ('Pelatihan UMKM', 'pelatihan', 'Ekonomi', '2026-06-22'::date, 5),
  ('Turnamen Bola ', 'bola', 'Olahraga', '2026-05-30'::date, 6),
  ('Peresmian PJU Solar', 'lampu', 'Pembangunan', '2026-04-02'::date, 7),
  ('Kirab Budaya Sasak', 'budaya', 'Budaya', '2026-03-25'::date, 8),
  ('Pemeriksaan Kesehatan ', 'kesehatan', 'Kesehatan', '2026-06-01'::date, 9)
) AS t(judul, emoji, album, tanggal, urutan)
WHERE NOT EXISTS (SELECT 1 FROM public.galeri WHERE judul = t.judul);

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'PROFIL DESA' as tabel, count(*)::text as jumlah FROM public.profil_desa
UNION ALL SELECT 'DESA PAMONG', count(*)::text FROM public.desa_pamong
UNION ALL SELECT 'WILAYAH DUSUN', count(*)::text FROM public.wilayah_dusun
UNION ALL SELECT 'LEMBAGA DESA', count(*)::text FROM public.lembaga_desa
UNION ALL SELECT 'BERITA', count(*)::text FROM public.berita
UNION ALL SELECT 'AGENDA', count(*)::text FROM public.agenda
UNION ALL SELECT 'PENGUMUMAN', count(*)::text FROM public.pengumuman
UNION ALL SELECT 'GALERI', count(*)::text FROM public.galeri
UNION ALL SELECT 'SURAT JENIS', count(*)::text FROM public.surat_jenis
UNION ALL SELECT 'KEGIATAN PEMBANGUNAN', count(*)::text FROM public.kegiatan_pembangunan
UNION ALL SELECT 'USULAN WARGA', count(*)::text FROM public.usulan_warga
UNION ALL SELECT 'POTENSI WISATA', count(*)::text FROM public.potensi_wisata
UNION ALL SELECT 'POTENSI UMKM', count(*)::text FROM public.potensi_umkm
UNION ALL SELECT 'PRODUK', count(*)::text FROM public.potensi_produk
UNION ALL SELECT 'IDM STATUS', count(*)::text FROM public.idm_status_desa;
