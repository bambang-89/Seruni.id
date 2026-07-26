-- ============================================================
-- SEED 4: BANTUAN SOSIAL & PENERIMA BANSOS
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- BANTUAN SOSIAL (Jenis)
  -- ============================================================
  RAISE NOTICE 'Seeding bantuan_sosial...';
  DELETE FROM bantuan_sosial;

  INSERT INTO bantuan_sosial (tenant_id, nama, jenis, deskripsi, sumber, tahun, status) VALUES
  (v_tenant_id, 'Bantuan Langsung Tunai (BLT) DD', 'Bansos Tunai', 'Bantuan langsung tunai dari Dana Desa untuk keluarga miskin', 'Dana Desa', 2026, 'aktif'),
  (v_tenant_id, 'Program Keluarga Harapan (PKH)', 'Bansos Tunai', 'Bantuan untuk keluarga miskin terdaftar di DTKS', 'APBN', 2026, 'aktif'),
  (v_tenant_id, 'Bantuan Pangan Non Tunai (BPNT)', 'Bansos NonTunai', 'Bantuan pangan melalui e-warong', 'APBN', 2026, 'aktif'),
  (v_tenant_id, 'Program Indonesia Pintar (PIP)', 'Bansos Pendidikan', 'Bantuan pendidikan untuk anak sekolah', 'APBN', 2026, 'aktif'),
  (v_tenant_id, 'Kartu Indonesia Sehat (KIS)', 'Bansos Kesehatan', 'BPJS kesehatan gratis untuk keluarga miskin', 'APBN', 2026, 'aktif'),
  (v_tenant_id, 'Kartu Prakerja', 'Bansos Pelatihan', 'Bantuan pelatihan dan pencari kerja', 'APBN', 2026, 'aktif'),
  (v_tenant_id, 'BST Kemensos', 'Bansos Tunai', 'Bantuan sosial langsung dari Kemensos', 'APBN', 2026, 'nonaktif'),
  (v_tenant_id, 'Cadangan Beras Burnett (CBP)', 'Bansos Pangan', 'Distribusi beras untuk keluarga miskin', 'APBN', 2026, 'aktif');

  -- ============================================================
  -- PENERIMA BANSOS (Sample 50 orang)
  -- ============================================================
  RAISE NOTICE 'Seeding penerima_bansos...';
  DELETE FROM penerima_bansos;

  INSERT INTO penerimaan_bansos (tenant_id, bansos_id, nik, nama, alamat, dusun, status, tgl_input)
  SELECT v_tenant_id, b.id, '3201' || substr(md5(random()::text), 1, 12), 'Penerima ' || generate_series, 'Alamat ' || generate_series, 'Mandar', 'aktif', now() - (random()*180||' days')::interval
  FROM bantuan_sosial b
  CROSS JOIN generate_series(1, 50)
  WHERE b.status = 'aktif';

END $$;

-- VERIFIKASI
SELECT 'bantuan_sosial: ' || count(*) FROM bantuan_sosial
UNION ALL SELECT 'penerima_bansos: ' || count(*) FROM penerimaan_bansos;
