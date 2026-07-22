-- TEST: Import 1 KK + 1 penduduk (minimal test
DO $$
DECLARE v_tid UUID;
BEGIN
  SELECT id INTO v_tid FROM public.tenants LIMIT 1;

  -- Insert test keluarga
  INSERT INTO public.keluarga (tenant_id, no_kk, kepala_nama, alamat, dusun, rt, rw, catatan)
  VALUES (v_tid, 'TEST001234567890', 'Test User', 'Test Alamat RT 001', 'Dames', '001', NULL, NULL)
  ON CONFLICT (no_kk) DO NOTHING;

  -- Insert test penduduk
  INSERT INTO public.penduduk (tenant_id, nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir, agama, pendidikan, pekerjaan, status_kawin, hubungan_kk, keluarga_id, dusun, alamat, foto_url, status_hidup, catatan, created_at, updated_at, bpjs_status, bpjs_nomor, rt, rw, nomor_hp, created_by, updated_by)
  SELECT v_tid, 'TEST001234567890', 'Test User', 'L', 'Test Kota', '1990-01-01'::date, 'Islam', 'SMA/Sederajat', 'Pedani', 'Kepala Keluarga', (SELECT id FROM public.keluarga WHERE no_kk = 'TEST001234567890'), 'Dames', 'Test Alamat', NULL, 'hidup', NULL, NOW(), NOW(), NULL, NULL, '001', NULL, NULL, NULL, NULL;
END $$;
