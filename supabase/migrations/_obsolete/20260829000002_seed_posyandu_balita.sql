-- ============================================================
-- Seed: balita + posyandu_kunjungan
-- ============================================================
DO $$
DECLARE
  v_tid UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

  -- ============================================================
  -- 1. balita
  -- ============================================================

  DELETE FROM posyandu_kunjungan;
  DELETE FROM balita;

  INSERT INTO balita (id, tenant_id, nama, tanggal_lahir, jenis_kelamin, orang_tua_penduduk_id, dusun, rt, rw, alamat)
  VALUES
    (gen_random_uuid(), v_tid, 'Muhammad Rizki Pratama', '2023-03-15'::date, 'L', 'a004540f-f92e-4606-b1aa-c0ec6acea9bd', 'Mandar', '01', '03', 'RT 01 RW 03 Burnett Mandar'),
    (gen_random_uuid(), v_tid, 'Siti Aisyah', '2022-08-22'::date, 'P', '2dc2e972-6a81-40ad-80a1-4eefbe4683c2', 'Mandar', '02', '03', 'RT 02 RW 03 Burnett Mandar'),
    (gen_random_uuid(), v_tid, 'Ahmad Fauzan', '2023-01-10'::date, 'L', 'a021b291-e5d4-4d1e-81ce-2bb3f200db62', 'Brangtapen Asri', '01', '02', 'RT 01 RW 02 Burnett Brangtapen Asri'),
    (gen_random_uuid(), v_tid, 'Nurul Hikmah', '2022-11-05'::date, 'P', '63e61ad8-a55b-48fa-a2e5-f8d6ca46ebb6', 'Mandar', '03', '03', 'RT 03 RW 03 Burnett Mandar'),
    (gen_random_uuid(), v_tid, 'Budi Santoso Jr.', '2024-02-28'::date, 'L', '38357184-c04d-4dc0-8191-fadba94583d3', 'Dames', '01', '01', 'RT 01 RW 01 Burnett Dames'),
    (gen_random_uuid(), v_tid, 'Putri Ayu Lestari', '2023-06-18'::date, 'P', 'a004540f-f92e-4606-b1aa-c0ec6acea9bd', 'Mandar', '01', '03', 'RT 01 RW 03 Burnett Mandar'),
    (gen_random_uuid(), v_tid, 'Galang Ramadhan', '2022-04-12'::date, 'L', '40432d1a-5c1b-48ea-9853-d3620e29adf2', 'Brangtapen Asri', '02', '02', 'RT 02 RW 02 Burnett Brangtapen Asri'),
    (gen_random_uuid(), v_tid, 'Dewi Kartika Sari', '2023-09-30'::date, 'P', '2dc2e972-6a81-40ad-80a1-4eefbe4683c2', 'Mandar', '02', '03', 'RT 02 RW 03 Burnett Mandar'),
    (gen_random_uuid(), v_tid, 'Fajar Nugroho', '2024-01-07'::date, 'L', 'a021b291-e5d4-4d1e-81ce-2bb3f200db62', 'Brangtapen Asri', '01', '02', 'RT 01 RW 02 Burnett Brangtapen Asri'),
    (gen_random_uuid(), v_tid, 'Anisa Rahma', '2022-07-14'::date, 'P', '63e61ad8-a55b-48fa-a2e5-f8d6ca46ebb6', 'Mandar', '03', '03', 'RT 03 RW 03 Burnett Mandar');

  RAISE NOTICE 'balita done';

  -- ============================================================
  -- 2. posyandu_kunjungan
  -- ============================================================

  INSERT INTO posyandu_kunjungan (tenant_id, balita_id, kader_penduduk_id, tanggal, berat_kg, tinggi_cm, imunisasi, status_gizi, catatan)
  SELECT
    v_tid,
    b.id,
    (SELECT id FROM penduduk WHERE dusun = b.dusun LIMIT 1),
    d.tgl,
    d.berat,
    d.tinggi,
    d.imun,
    d.status_gizi,
    d.catatan
  FROM balita b
  CROSS JOIN LATERAL (
    VALUES
      ('2025-07-15'::date, 11.5, 75.0, ARRAY['BCG','Polio 1'], 'baik', 'Pertumbuhan normal'),
      ('2025-08-20'::date, 11.8, 76.5, ARRAY['BCG','Polio 1','DPT-HB 1'], 'baik', 'Sudah imunisasi DPT-HB 1'),
      ('2025-09-15'::date, 12.1, 78.0, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2'], 'baik', 'Berat naik 300g'),
      ('2025-10-15'::date, 12.4, 79.5, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2','DPT-HB 2'], 'baik', NULL),
      ('2025-11-15'::date, 12.7, 81.0, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2','DPT-HB 2','Polio 3'], 'baik', 'Imunisasi lengkap sesuai usia')
  ) AS d(tgl, berat, tinggi, imun, status_gizi, catatan)
  WHERE b.nama IN ('Muhammad Rizki Pratama','Siti Aisyah','Ahmad Fauzan','Nurul Hikmah','Budi Santoso Jr.');

  INSERT INTO posyandu_kunjungan (tenant_id, balita_id, kader_penduduk_id, tanggal, berat_kg, tinggi_cm, imunisasi, status_gizi, catatan)
  SELECT
    v_tid,
    b.id,
    (SELECT id FROM penduduk WHERE dusun = b.dusun LIMIT 1),
    d.tgl,
    d.berat,
    d.tinggi,
    d.imun,
    d.status_gizi,
    d.catatan
  FROM balita b
  CROSS JOIN LATERAL (
    VALUES
      ('2025-07-15'::date, 10.2, 72.0, ARRAY['BCG','Polio 1'], 'kurang', 'Perlu pemantauan gizi'),
      ('2025-08-20'::date, 10.5, 73.5, ARRAY['BCG','Polio 1','DPT-HB 1'], 'kurang', 'Orang tua edukasi PMBA'),
      ('2025-09-15'::date, 10.8, 75.0, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2'], 'kurang', 'Berat naik 300g, lanjut pantau'),
      ('2025-10-15'::date, 11.2, 76.5, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2','DPT-HB 2'], 'baik', 'Sudah membaik'),
      ('2025-11-15'::date, 11.5, 78.0, ARRAY['BCG','Polio 1','DPT-HB 1','Polio 2','DPT-HB 2','Polio 3'], 'baik', 'Status gizi baik')
  ) AS d(tgl, berat, tinggi, imun, status_gizi, catatan)
  WHERE b.nama IN ('Putri Ayu Lestari','Galang Ramadhan','Dewi Kartika Sari','Fajar Nugroho','Anisa Rahma');

  RAISE NOTICE 'posyandu_kunjungan done';

END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'balita: ' || count(*) FROM balita
UNION ALL
SELECT 'posyandu_kunjungan: ' || count(*) FROM posyandu_kunjungan;
