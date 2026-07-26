-- ============================================================
-- SEED PENDUDUK - Seruni Mumbul
-- ============================================================
-- Copy ke SQL Editor Supabase Dashboard:
-- https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql/new
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_k1 UUID := gen_random_uuid();
  v_k2 UUID := gen_random_uuid();
  v_k3 UUID := gen_random_uuid();
  v_k4 UUID := gen_random_uuid();
  v_k5 UUID := gen_random_uuid();
  v_k6 UUID := gen_random_uuid();
  v_k7 UUID := gen_random_uuid();
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    v_tenant_id := gen_random_uuid();
    INSERT INTO public.tenants (id, nama_desa, subdomain) VALUES (v_tenant_id, 'Desa Seruni Mumbul', 'seruni');
  END IF;

  INSERT INTO public.keluarga (id, tenant_id, no_kk, kepala_nama, dusun, alamat, rt, rw) VALUES
    (v_k1, v_tenant_id, '5203083004880001', 'BAMBANG NURDIANSYAH', 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', '01', '01'),
    (v_k2, v_tenant_id, '5203083004880002', 'H. AHMAD ZAKI', 'Seruni Mumbul', 'Jl. Pantai Selatan No. 5', '01', '01'),
    (v_k3, v_tenant_id, '5203083004880003', 'SITI AMINAH', 'Seruni Mumbul', 'Jl. Masjid No. 3', '02', '01'),
    (v_k4, v_tenant_id, '5203083004880004', 'MUHAMMAD IRFAN', 'Seruni Timur', 'Dusun Timur RT 02', '02', '02'),
    (v_k5, v_tenant_id, '5203083004880005', 'DEWI LESTARI', 'Seruni Barat', 'Dusun Barat RT 01', '01', '03'),
    (v_k6, v_tenant_id, '5203083004880006', 'HARIANTO', 'Seruni Utara', 'Dusun Utara No. 8', '03', '01'),
    (v_k7, v_tenant_id, '5203083004880007', 'SUSILOWATI', 'Seruni Selatan', 'Dusun Selatan RT 02', '02', '02')
  ON CONFLICT (no_kk) DO NOTHING;

  INSERT INTO public.penduduk (tenant_id, nik, nama, jenis_kelamin, tempat_lahir, tanggal_lahir, agama, pendidikan, pekerjaan, status_kawin, hubungan_kk, keluarga_id, dusun, alamat, status_hidup) VALUES
    (v_tenant_id, '5203083004880001', 'BAMBANG NURDIANSYAH', 'L', 'Mataram', '1975-03-15', 'Islam', 'S1', 'Petani', 'Kawin', 'Kepala Keluarga', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880002', 'SITI RAHAYU', 'P', 'Mataram', '1978-07-22', 'Islam', 'SMA', 'Ibu Rumah Tangga', 'Kawin', 'Istri', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880003', 'ANDI NURDIANSYAH', 'L', 'Mataram', '2000-01-10', 'Islam', 'D3', 'Teknisi', 'Kawin', 'Anak', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880004', 'DEWI ANGGRAINI', 'P', 'Mataram', '2002-05-18', 'Islam', 'SMA', 'Pelajar', 'Belum Kawin', 'Anak', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880005', 'FIRZA NURDIANSYAH', 'L', 'Mataram', '2010-11-25', 'Islam', 'SD', 'Pelajar', 'Belum Kawin', 'Anak', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880006', 'H. AHMAD ZAKI', 'L', 'Mataram', '1968-12-05', 'Islam', 'S2', 'PNS', 'Kawin', 'Kepala Keluarga', v_k2, 'Seruni Mumbul', 'Jl. Pantai Selatan No. 5', 'hidup'),
    (v_tenant_id, '5203083004880007', 'HAJAR ASNAT', 'P', 'Mataram', '1972-03-20', 'Islam', 'SMA', 'Ibu Rumah Tangga', 'Kawin', 'Istri', v_k2, 'Seruni Mumbul', 'Jl. Pantai Selatan No. 5', 'hidup'),
    (v_tenant_id, '5203083004880008', 'ZAKIATUL KHUSNAINI', 'P', 'Mataram', '1998-08-14', 'Islam', 'S1', 'Wiraswasta', 'Kawin', 'Anak', v_k2, 'Seruni Mumbul', 'Jl. Pantai Selatan No. 5', 'hidup'),
    (v_tenant_id, '5203083004880009', 'M. FAISAL ZAKI', 'L', 'Mataram', '2001-02-28', 'Islam', 'D3', 'IT', 'Belum Kawin', 'Anak', v_k2, 'Seruni Mumbul', 'Jl. Pantai Selatan No. 5', 'hidup'),
    (v_tenant_id, '5203083004880010', 'SITI AMINAH', 'P', 'Mataram', '1980-09-10', 'Islam', 'S1', 'Guru', 'Cerai Mati', 'Kepala Keluarga', v_k3, 'Seruni Mumbul', 'Jl. Masjid No. 3', 'hidup'),
    (v_tenant_id, '5203083004880011', 'AHMAD FAISAL', 'L', 'Mataram', '2005-04-15', 'Islam', 'SMA', 'Pelajar', 'Belum Kawin', 'Anak', v_k3, 'Seruni Mumbul', 'Jl. Masjid No. 3', 'hidup'),
    (v_tenant_id, '5203083004880012', 'SITI NURHALIZA', 'P', 'Mataram', '2008-07-22', 'Islam', 'SMP', 'Pelajar', 'Belum Kawin', 'Anak', v_k3, 'Seruni Mumbul', 'Jl. Masjid No. 3', 'hidup'),
    (v_tenant_id, '5203083004880013', 'MUHAMMAD IRFAN', 'L', 'Mataram', '1985-06-18', 'Islam', 'S1', 'Pedagang', 'Kawin', 'Kepala Keluarga', v_k4, 'Seruni Timur', 'Dusun Timur RT 02', 'hidup'),
    (v_tenant_id, '5203083004880014', 'RINA MARLINA', 'P', 'Mataram', '1988-10-30', 'Islam', 'SMA', 'Pedagang', 'Kawin', 'Istri', v_k4, 'Seruni Timur', 'Dusun Timur RT 02', 'hidup'),
    (v_tenant_id, '5203083004880015', 'RAFI IRFAN', 'L', 'Mataram', '2012-03-08', 'Islam', 'SD', 'Pelajar', 'Belum Kawin', 'Anak', v_k4, 'Seruni Timur', 'Dusun Timur RT 02', 'hidup'),
    (v_tenant_id, '5203083004880016', 'SARI IRFAN', 'P', 'Mataram', '2015-11-12', 'Islam', 'SD', 'Pelajar', 'Belum Kawin', 'Anak', v_k4, 'Seruni Timur', 'Dusun Timur RT 02', 'hidup'),
    (v_tenant_id, '5203083004880017', 'DEWI LESTARI', 'P', 'Mataram', '1990-02-14', 'Islam', 'S1', 'Bidan', 'Kawin', 'Kepala Keluarga', v_k5, 'Seruni Barat', 'Dusun Barat RT 01', 'hidup'),
    (v_tenant_id, '5203083004880018', 'BUDI SANTOSO', 'L', 'Mataram', '1988-08-20', 'Islam', 'S1', 'Kontruksi', 'Kawin', 'Suami', v_k5, 'Seruni Barat', 'Dusun Barat RT 01', 'hidup'),
    (v_tenant_id, '5203083004880019', 'ANGGA BUDI', 'L', 'Mataram', '2015-05-05', 'Islam', 'PAUD', '-', 'Belum Kawin', 'Anak', v_k5, 'Seruni Barat', 'Dusun Barat RT 01', 'hidup'),
    (v_tenant_id, '5203083004880020', 'HARIANTO', 'L', 'Mataram', '1970-04-01', 'Islam', 'S1', 'Kepala Desa', 'Kawin', 'Kepala Keluarga', v_k6, 'Seruni Utara', 'Dusun Utara No. 8', 'hidup'),
    (v_tenant_id, '5203083004880021', 'NURHIDAYAH', 'P', 'Mataram', '1973-11-15', 'Islam', 'SMA', 'Ibu Rumah Tangga', 'Kawin', 'Istri', v_k6, 'Seruni Utara', 'Dusun Utara No. 8', 'hidup'),
    (v_tenant_id, '5203083004880022', 'WULAN HARIANTO', 'P', 'Mataram', '1998-01-20', 'Islam', 'S1', 'Staff Desa', 'Kawin', 'Anak', v_k6, 'Seruni Utara', 'Dusun Utara No. 8', 'hidup'),
    (v_tenant_id, '5203083004880023', 'DIMAS HARIANTO', 'L', 'Mataram', '2002-09-10', 'Islam', 'D3', 'Teknisi', 'Belum Kawin', 'Anak', v_k6, 'Seruni Utara', 'Dusun Utara No. 8', 'hidup'),
    (v_tenant_id, '5203083004880024', 'SUSILOWATI', 'P', 'Mataram', '1982-07-08', 'Islam', 'SMA', 'Kader Kesehatan', 'Kawin', 'Kepala Keluarga', v_k7, 'Seruni Selatan', 'Dusun Selatan RT 02', 'hidup'),
    (v_tenant_id, '5203083004880025', 'TONI HERMAWAN', 'L', 'Mataram', '1979-12-25', 'Islam', 'SMA', 'Sopir', 'Kawin', 'Suami', v_k7, 'Seruni Selatan', 'Dusun Selatan RT 02', 'hidup'),
    (v_tenant_id, '5203083004880026', 'SITI NURULIA', 'P', 'Mataram', '2006-03-18', 'Islam', 'SMP', 'Pelajar', 'Belum Kawin', 'Anak', v_k7, 'Seruni Selatan', 'Dusun Selatan RT 02', 'hidup'),
    (v_tenant_id, '5203083004880027', 'ANDI HERMAWAN', 'L', 'Mataram', '2010-08-30', 'Islam', 'SD', 'Pelajar', 'Belum Kawin', 'Anak', v_k7, 'Seruni Selatan', 'Dusun Selatan RT 02', 'hidup'),
    (v_tenant_id, '5203083004880028', 'H. BASRI', 'L', 'Mataram', '1945-08-12', 'Islam', 'Madrasah', 'Petani', 'Cerai Mati', 'Lainnya', NULL, 'Seruni Barat', 'Dusun Barat RT 03', 'hidup'),
    (v_tenant_id, '5203083004880029', 'HAJAH MINAH', 'P', 'Mataram', '1950-01-05', 'Islam', 'Madrasah', '-', 'Cerai Mati', 'Lainnya', NULL, 'Seruni Barat', 'Dusun Barat RT 03', 'hidup'),
    (v_tenant_id, '5203083004880030', 'ABU BAKAR', 'L', 'Mataram', '1942-05-20', 'Islam', 'Pesantren', 'Ustaz', 'Kawin', 'Lainnya', NULL, 'Seruni Mumbul', 'Jl. Masjid No. 1', 'hidup'),
    (v_tenant_id, '5203083004880031', 'NAJWA KHANZA', 'P', 'Mataram', '2018-07-15', 'Islam', 'PAUD', '-', 'Belum Kawin', 'Anak', v_k1, 'Seruni Mumbul', 'Jl. Raya Seruni No. 1', 'hidup'),
    (v_tenant_id, '5203083004880032', 'ARYA SAPUTRA', 'L', 'Mataram', '2019-03-22', 'Islam', 'PAUD', '-', 'Belum Kawin', 'Anak', v_k4, 'Seruni Timur', 'Dusun Timur RT 02', 'hidup'),
    (v_tenant_id, '5203083004880033', 'SITI ZAHRA', 'P', 'Mataram', '2017-11-08', 'Islam', 'PAUD', '-', 'Belum Kawin', 'Anak', v_k5, 'Seruni Barat', 'Dusun Barat RT 01', 'hidup')
  ON CONFLICT (nik) DO NOTHING;

  RAISE NOTICE '========================================';
  RAISE NOTICE 'SEED PENDUDUK SELESAI!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Total Keluarga: 7';
  RAISE NOTICE 'Total Penduduk: 33+';
  RAISE NOTICE '========================================';
END $$;

SELECT 'Keluarga' as jenis, count(*) as jumlah FROM public.keluarga
UNION ALL SELECT 'Penduduk', count(*) FROM public.penduduk
UNION ALL SELECT 'Laki-laki', count(*) FROM public.penduduk WHERE jenis_kelamin = 'L'
UNION ALL SELECT 'Perempuan', count(*) FROM public.penduduk WHERE jenis_kelamin = 'P';
