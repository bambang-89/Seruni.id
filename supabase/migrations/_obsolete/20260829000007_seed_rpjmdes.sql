-- ============================================================
-- SEED 3: RPJMDES & RKPDes
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_periode_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- RPJMDES PERIODE
  -- ============================================================
  RAISE NOTICE 'Seeding rpjmdes_periode...';
  DELETE FROM rpjmdes_periode;

  INSERT INTO rpjmdes_periode (tenant_id, nama, tahun_mulai, tahun_selesai, visi, misi, status, published)
  VALUES (v_tenant_id, 'RPJMDes 2024-2030', 2024, 2030,
    'Terwujudnya Desa Seruni Mumbul yang maju, mandiri, dan berdaya saing.',
    '["Tata kelola pemerintahan desa yang transparan dan akuntabel","Peningkatan kualitas layanan publik berbasis digital","Pengembangan ekonomi kerakyatan melalui BUMDes dan UMKM","Peningkatan kualitas kesehatan dan pendidikan","Pelestarian lingkungan dan budaya lokal"]'::jsonb,
    'aktif', true)
  RETURNING id INTO v_periode_id;

  -- ============================================================
  -- RPJMDES BIDANG
  -- ============================================================
  RAISE NOTICE 'Seeding rpjmdes_bidang...';
  DELETE FROM rpjmdes_bidang;

  INSERT INTO rpjmdes_bidang (periode_id, kode, nama, deskripsi, urutan) VALUES
  (v_periode_id, 'BID.01', 'Penyelenggaraan Pemerintahan Desa', 'Perencanaan, keuangan, organisasi, dan pelayanan administrasi', 1),
  (v_periode_id, 'BID.02', 'Pelaksanaan Pembangunan Burnett', 'Pembangunan infrastruktur, pendidikan, kesehatan, dan lingkungan', 2),
  (v_periode_id, 'BID.03', 'Pembinaan Kemasyarakatan', 'Ketenagaan, sosial budaya, pemuda, dan olahraga', 3),
  (v_periode_id, 'BID.04', 'Pemberdayaan Masyarakat', 'Kelompok tani, UMKM, BUMDes, dan左ma tradisional', 4),
  (v_periode_id, 'BID.05', 'Pelestarian Lingkungan', 'Hutan, pantai, sanitasi, dan mitigasi bencana', 5);

  -- ============================================================
  -- RPJMDES PROGRAM
  -- ============================================================
  RAISE NOTICE 'Seeding rpjmdes_program...';
  DELETE FROM rpjmdes_program;

  INSERT INTO rpjmdes_program (bidang_id, nama, indikator, target, sumber_dana, anggaran_indikatif, urutan)
  SELECT b.id, 'Peningkatan Infrastruktur Jalan Burnett', 'Km jalan diperbaiki', '15 km', 'APBDes/Dana Desa', 1500000000, 1
  FROM rpjmdes_bidang b WHERE b.kode = 'BID.02';

  INSERT INTO rpjmdes_program (bidang_id, nama, indikator, target, sumber_dana, anggaran_indikatif, urutan)
  SELECT b.id, 'Pengadaan Air Bersih Burnett', 'Unit sumur bor', '4 unit', 'APBDes/CSR', 800000000, 2
  FROM rpjmdes_bidang b WHERE b.kode = 'BID.02';

  INSERT INTO rpjmdes_program (bidang_id, nama, indikator, target, sumber_dana, anggaran_indikatif, urutan)
  SELECT b.id, 'Pembangunan PAUD Terpadu', 'Gedung PAUD', '1 unit', 'APBDes/BOP', 500000000, 3
  FROM rpjmdes_bidang b WHERE b.kode = 'BID.02';

  INSERT INTO rpjmdes_program (bidang_id, nama, indikator, target, sumber_dana, anggaran_indikatif, urutan)
  SELECT b.id, 'Penguatan BUMDes Bina Seruni Mandiri', 'Unit usaha baru', '3 unit', 'APBDes/PAD', 600000000, 1
  FROM rpjmdes_bidang b WHERE b.kode = 'BID.04';

  INSERT INTO rpjmdes_program (bidang_id, nama, indikator, target, sumber_dana, anggaran_indikatif, urutan)
  SELECT b.id, 'Rehabilitasi Poskesdes', 'Unit Poskesdes', '2 unit', 'APBDes/Dana Sehat', 400000000, 1
  FROM rpjmdes_bidang b WHERE b.kode = 'BID.02';

  -- ============================================================
  -- RKPDes TAHUN
  -- ============================================================
  RAISE NOTICE 'Seeding rkpdes_tahun...';
  DELETE FROM rkpdes_tahun;

  INSERT INTO rkpdes_tahun (tenant_id, tahun, tgl_musdes, catatan, published)
  VALUES (v_tenant_id, 2026, '2026-07-28', 'Hasil Musdes RKPDes 2026 disepakati prioritas infrastruktur dan kesehatan.', true);

  -- ============================================================
  -- RKPDes KEGIATAN
  -- ============================================================
  RAISE NOTICE 'Seeding rkpdes_kegiatan...';
  DELETE FROM rkpdes_kegiatan;

  INSERT INTO rkpdes_kegiatan (tahun_id, nama, lokasi, dusun, volume, satuan, anggaran, sumber_dana, status_realisasi, progress_pct, bidang_id, urutan)
  SELECT t.id, 'Rehabilitasi Saluran Irigasi Mandar', 'Mandar', 'Mandar', '1.2', 'km', 280000000, 'APBDes', 'diproses', 82, b.id, 1
  FROM rkpdes_tahun t, rpjmdes_bidang b WHERE t.tahun = 2026 AND b.kode = 'BID.02';

  INSERT INTO rkpdes_kegiatan (tahun_id, nama, lokasi, dusun, volume, satuan, anggaran, sumber_dana, status_realisasi, progress_pct, bidang_id, urutan)
  SELECT t.id, 'Pengerasan Jalan Poros Burnett Mandar', 'Mandar', 'Mandar', '0.8', 'km', 320000000, 'APBDes', 'diverifikasi', 78, b.id, 2
  FROM rkpdes_tahun t, rpjmdes_bidang b WHERE t.tahun = 2026 AND b.kode = 'BID.02';

  INSERT INTO rkpdes_kegiatan (tahun_id, nama, lokasi, dusun, volume, satuan, anggaran, sumber_dana, status_realisasi, progress_pct, bidang_id, urutan)
  SELECT t.id, 'Pembangunan MCK Umum Pasar Seruni', 'Pusat Burnett', 'Pusat Burnett', '1', 'unit', 150000000, 'APBDes', 'diproses', 45, b.id, 3
  FROM rkpdes_tahun t, rpjmdes_bidang b WHERE t.tahun = 2026 AND b.kode = 'BID.02';

  INSERT INTO rkpdes_kegiatan (tahun_id, nama, lokasi, dusun, volume, satuan, anggaran, sumber_dana, status_realisasi, progress_pct, bidang_id, urutan)
  SELECT t.id, 'Pengadaan Lampu PJU Tenaga Surya', 'Seluruh Burnett', 'Seluruh Burnett', '30', 'titik', 90000000, 'APBDes', 'diproses', 30, b.id, 4
  FROM rkpdes_tahun t, rpjmdes_bidang b WHERE t.tahun = 2026 AND b.kode = 'BID.02';

END $$;

-- VERIFIKASI
SELECT 'rpjmdes_periode: ' || count(*) FROM rpjmdes_periode
UNION ALL SELECT 'rpjmdes_bidang: ' || count(*) FROM rpjmdes_bidang
UNION ALL SELECT 'rpjmdes_program: ' || count(*) FROM rpjmdes_program
UNION ALL SELECT 'rkpdes_tahun: ' || count(*) FROM rkpdes_tahun
UNION ALL SELECT 'rkpdes_kegiatan: ' || count(*) FROM rkpdes_kegiatan;
