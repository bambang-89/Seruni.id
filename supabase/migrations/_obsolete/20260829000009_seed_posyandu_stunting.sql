-- ============================================================
-- SEED 5: POSYANDU & STUNTING
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- POSYANDU AGREGAT
  -- ============================================================
  RAISE NOTICE 'Seeding posyandu_agregat...';
  DELETE FROM posyandu_agregat;

  INSERT INTO posyandu_agregat (tenant_id, dusun, tahun, bulan, jumlah_balita, jumlah_ditimbang, berat_rendah, gizi_buruk, stunting, catatan, created_at)
  VALUES
  (v_tenant_id, 'Mandar', 2026, 7, 187, 165, 12, 0, 28, 'Pemantauan rutin bulanan', now()),
  (v_tenant_id, 'Sasak', 2026, 7, 203, 178, 15, 1, 32, 'Ada 1 kasus gizi buruk dirujuk', now()),
  (v_tenant_id, 'Dames', 2026, 7, 156, 142, 8, 0, 22, 'Cakupan baik', now()),
  (v_tenant_id, 'Brangtapen Asri', 2026, 7, 142, 128, 10, 0, 25, 'Perlu peningkatan partisipasi', now()),
  (v_tenant_id, 'Mandar', 2026, 6, 185, 158, 14, 0, 30, 'Pemantauan rutin bulanan', now()),
  (v_tenant_id, 'Sasak', 2026, 6, 201, 172, 17, 1, 35, 'Ada 1 kasus gizi buruk dirujuk', now()),
  (v_tenant_id, 'Dames', 2026, 6, 154, 138, 9, 0, 24, 'Cakupan baik', now()),
  (v_tenant_id, 'Brangtapen Asri', 2026, 6, 140, 122, 11, 0, 27, 'Perlu peningkatan partisipasi', now());

  -- ============================================================
  -- STUNTING AGREGAT
  -- ============================================================
  RAISE NOTICE 'Seeding stunting_agregat...';
  DELETE FROM stunting_agregat;

  INSERT INTO stunting_agregat (tenant_id, dusun, tahun, semester, total_balita, stunting_pendek, stunting_ sangat_pendek, prevalensi_persen, intervensi, catatan, created_at)
  VALUES
  (v_tenant_id, 'Mandar', 2026, 1, 187, 18, 10, 14.97, 'PMT Lokal, Edukasi Gizi', 'Stunting turun dari 18% semester lalu', now()),
  (v_tenant_id, 'Sasak', 2026, 1, 203, 22, 10, 15.76, 'PMT Lokal, Konseling KB', 'Stunting turun dari 17% semester lalu', now()),
  (v_tenant_id, 'Dames', 2026, 1, 156, 14, 8, 14.10, 'PMT Lokal', 'Cakupan baik, prevalensi rendah', now()),
  (v_tenant_id, 'Brangtapen Asri', 2026, 1, 142, 16, 9, 17.61, 'PMT Lokal, Kelas Ibu Hamil', 'Prevalensi tertinggi, perlu intervensi khusus', now()),
  (v_tenant_id, 'TOTAL', 2026, 1, 688, 70, 37, 15.55, 'PMT Lokal, Edukasi Gizi, Kelas Ibu Hamil', 'Total prevalensi stunting 15.55% turun dari 18.4%', now());

END $$;

-- VERIFIKASI
SELECT 'posyandu_agregat: ' || count(*) FROM posyandu_agregat
UNION ALL SELECT 'stunting_agregat: ' || count(*) FROM stunting_agregat;
