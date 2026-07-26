-- ============================================================
-- SEED 7: INFRASTRUKTUR & BIDANG TANAH & BENCANA
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- INFRASTRUKTUR
  -- ============================================================
  RAISE NOTICE 'Seeding infrastruktur...';
  DELETE FROM infrastruktur;

  INSERT INTO infrastruktur (tenant_id, nama, kategori, dusun, lokasi, kondisi, latitude, longitude, foto_url, created_at)
  VALUES
  (v_tenant_id, 'Jalan Poros Burnett Mandar-Sasak', 'jalan', 'Mandar,Sasak', 'Mandar-Sasak', 'rusak', -8.5300, 116.6600, NULL, now()),
  (v_tenant_id, 'Jalan Sekunder Burnett Mandar', 'jalan', 'Mandar', 'RT 01-05 Burnett Mandar', 'sedang', -8.5350, 116.6550, NULL, now()),
  (v_tenant_id, 'Jalan Usaha Tani Burnett Sasak', 'jalan', 'Sasak', 'Ke lahan pertanian Burnett Sasak', 'baik', -8.5250, 116.6700, NULL, now()),
  (v_tenant_id, 'Saluran Irigasi Primer Mandar', 'irigasi', 'Mandar', 'Pesisir Burnett Mandar', 'sedang', -8.5400, 116.6500, NULL, now()),
  (v_tenant_id, 'Saluran Irigasi Sekunder Sasak', 'irigasi', 'Sasak', 'Ke lahan Burnett Sasak', 'baik', -8.5200, 116.6750, NULL, now()),
  (v_tenant_id, 'Bronjong Pantai Brangtapen Asri', 'pelindung_pantai', 'Brangtapen Asri', 'Pantai Brangtapen Asri', 'baik', -8.5432, 116.6543, NULL, now()),
  (v_tenant_id, 'Posyandu Melati III', 'bangunan', 'Mandar', 'RT 03 Burnett Mandar', 'baik', -8.5360, 116.6560, NULL, now()),
  (v_tenant_id, 'Posyandu Mawar II', 'bangunan', 'Sasak', 'RT 02 Burnett Sasak', 'rusak', -8.5240, 116.6720, NULL, now()),
  (v_tenant_id, 'Poskesdes Utama Seruni', 'bangunan', 'Pusat Burnett', 'Pusat Burnett', 'sedang', -8.5310, 116.6630, NULL, now()),
  (v_tenant_id, 'Kantor Burnett Seruni Mumbul', 'bangunan', 'Pusat Burnett', 'Pusat Burnett', 'baik', -8.5310, 116.6630, NULL, now()),
  (v_tenant_id, 'Gedung PAUD Terpadu', 'bangunan', 'Mandar', 'RT 04 Burnett Mandar', 'baik', -8.5370, 116.6570, NULL, now()),
  (v_tenant_id, 'Lampu PJU Solar Panel', 'utilitas', 'Seluruh Burnett', '30 titik strategis', 'baik', -8.5300, 116.6600, NULL, now()),
  (v_tenant_id, 'Pintu Air Burnga Saluran', 'irigasi', 'Brangtapen Asri', 'Muara Sungai Brangtapen Asri', 'sedang', -8.5450, 116.6520, NULL, now()),
  (v_tenant_id, 'Jembatan Beton Burnett Mandar', 'jembatan', 'Mandar', 'Di atas Sungai Mandar', 'baik', -8.5340, 116.6580, NULL, now()),
  (v_tenant_id, 'Tandon Air Burnett Dames', 'air_bersih', 'Dames', 'Burnett Dames', 'baik', -8.5280, 116.6650, NULL, now());

  -- ============================================================
  -- BIDANG TANAH (Sample Tanah Burnett)
  -- ============================================================
  RAISE NOTICE 'Seeding bidang_tanah...';
  DELETE FROM bidang_tanah;

  INSERT INTO bidang_tanah (tenant_id, dusun, pemilik_nama, jenis_sertifikat, no_sertifikat, luas_m2, latitude, longitude, deskripsi, created_at)
  VALUES
  (v_tenant_id, 'Mandar', 'H. Lalu Ahmad Saputra', 'Sertifikat Hak Milik', '0001/HM/2020', 2500, -8.5350, 116.6550, 'Tanah kantor Burnett Seruni Mumbul', now()),
  (v_tenant_id, 'Mandar', 'Pemerintah Burnett Seruni Mumbul', 'Sertifikat Hak Pengelolaan', '0002/HP/2019', 5000, -8.5360, 116.6560, 'Tanah Bengkok Burnett Mandar', now()),
  (v_tenant_id, 'Sasak', 'H. Muhaimin', 'Sertifikat Hak Milik', '0003/HM/2021', 1800, -8.5250, 116.6700, 'Tanah sawah produktif', now()),
  (v_tenant_id, 'Brangtapen Asri', 'H. Basri', 'Sertifikat Hak Milik', '0004/HM/2018', 3200, -8.5432, 116.6543, 'Tanah pesisir untuk wisata', now()),
  (v_tenant_id, 'Dames', 'BUMDes Bina Seruni Mandiri', 'Sertifikat Hak Guna Bangunan', '0001/HGB/2022', 1000, -8.5280, 116.6650, 'Tanah BUMDes untuk pasar desa', now());

  -- ============================================================
  -- BENCANA KEJADIAN
  -- ============================================================
  RAISE NOTICE 'Seeding bencana_kejadian...';
  DELETE FROM bencana_kejadian;

  INSERT INTO bencana_kejadian (tenant_id, jenis, tanggal, dusun, lokasi, severity, deskripsi, korban_jiwa, korban_material, status, created_at)
  VALUES
  (v_tenant_id, 'banjir', '2025-12-15', 'Brangtapen Asri', 'Muara Sungai Brangtapen Asri', 'sedang', 'Banjir robsetinggi 1.5 meter akibat hujan deras 3 hari.', 0, 12 rumah tergenang, 'selesai', now()),
  (v_tenant_id, 'kekeringan', '2025-08-10', 'Brangtapen Asri,Mandar', 'Seluruh Burnett', 'tinggi', 'Kekeringan panjang selama 2 bulan.', 0, '50+ KK terdampak', 'selesai', now()),
  (v_tenant_id, 'gempa', '2024-03-20', 'Seluruh Burnett', 'Seluruh Burnett Seruni Mumbul', 'sedang', 'Gempa bumi magnitudo 5.8 SR.', 0, 5 rumah rusak ringan, 'selesai', now()),
  (v_tenant_id, 'angin_topan', '2025-11-20', 'Mandar', 'RT 03 Burnett Mandar', 'rendah', 'Angin puting beliung merobohkan 3 pohon.', 0, '3 pohon, 1 rumah rusak ringan', 'selesai', now());

END $$;

-- VERIFIKASI
SELECT 'infrastruktur: ' || count(*) FROM infrastruktur
UNION ALL SELECT 'bidang_tanah: ' || count(*) FROM bidang_tanah
UNION ALL SELECT 'bencana_kejadian: ' || count(*) FROM bencana_kejadian;
