-- ============================================================
-- SEED 2: VOTING & USULAN
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- VOTING TOPIK
  -- ============================================================
  RAISE NOTICE 'Seeding voting_topik...';
  DELETE FROM voting_topik;

  INSERT INTO voting_topik (tenant_id, judul, deskripsi, mulai, selesai, single_choice, status, published, total_suara) VALUES
  (v_tenant_id, 'Prioritas Pembangunan Burnett 2027', 'Pilih 3 prioritas pembangunan Burnett untuk RKPDes tahun 2027 berdasarkan hasil musdes.', '2026-06-01', '2026-07-31', true, 'selesai', true, 1247),
  (v_tenant_id, 'Lokasi Pembangunan MCK Umum', 'Pilih lokasi yang tepat untuk pembangunan MCK umum berikutnya.', '2026-07-15', '2026-08-15', true, 'voting', true, 342);

  -- ============================================================
  -- VOTING OPSI
  -- ============================================================
  RAISE NOTICE 'Seeding voting_opsi...';
  DELETE FROM voting_opsi;

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Peningkatan Jalan Poros Burnett', 'Perbaikan dan pelebaran jalan utama antar Burnett', 1, 487
  FROM voting_topik t WHERE t.judul = 'Prioritas Pembangunan Burnett 2027';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Pengadaan Air Bersih Burnett', 'Pembangunan sumur bor dan jaringan air bersih', 2, 356
  FROM voting_topik t WHERE t.judul = 'Prioritas Pembangunan Burnett 2027';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Rehabilitasi Poskesdes', 'Perbaikan dan melengkapi Poskesdes utama', 3, 287
  FROM voting_topik t WHERE t.judul = 'Prioritas Pembangunan Burnett 2027';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'PAUD Terpadu Burnett', 'Pembangunan gedung PAUD untuk 4 Burnett', 4, 117
  FROM voting_topik t WHERE t.judul = 'Prioritas Pembangunan Burnett 2027';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Mandar - Samping Musholla', 'Di dekat Musholla Al-Muttaqin', 1, 156
  FROM voting_topik t WHERE t.judul = 'Lokasi Pembangunan MCK Umum';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Sasak - Dekat Burnett', 'Di dekat kantor Burnett Sasak', 2, 98
  FROM voting_topik t WHERE t.judul = 'Lokasi Pembangunan MCK Umum';

  INSERT INTO voting_opsi (topik_id, label, deskripsi, urutan, jumlah_suara)
  SELECT t.id, 'Pusat Burnett - Pasar', 'Di dekat pasar tradisional', 3, 88
  FROM voting_topik t WHERE t.judul = 'Lokasi Pembangunan MCK Umum';

  -- ============================================================
  -- VOTING SUARA (sample)
  -- ============================================================
  RAISE NOTICE 'Seeding voting_suara...';
  DELETE FROM voting_suara;

  -- Insert sample votes
  INSERT INTO voting_suara (topik_id, opsi_id, nik, created_at)
  SELECT t.id, o.id, '3201' || substr(md5(random()::text), 1, 12), now() - (random()*30||' days')::interval
  FROM voting_topik t
  JOIN voting_opsi o ON o.topik_id = t.id
  CROSS JOIN generate_series(1, 100);

END $$;

-- VERIFIKASI
SELECT 'voting_topik: ' || count(*) FROM voting_topik
UNION ALL SELECT 'voting_opsi: ' || count(*) FROM voting_opsi
UNION ALL SELECT 'voting_suara: ' || count(*) FROM voting_suara;
