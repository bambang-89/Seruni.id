-- ============================================================
-- SEED JENIS SURAT - Seruni Mumbul (FINAL)
-- Tanggal: 2026-08-05
-- Deskripsi: Jenis surat final setelah cleanup
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  -- Clear existing
  DELETE FROM public.surat_jenis_dna;
  DELETE FROM public.surat_jenis;

  -- ============================================================
  -- A. KEPENDUDUKAN & DOMISILI (KODE 474/475)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '474.0', '474', 'Surat Keterangan Domisili (SKD)', true, 1),
  (v_tenant_id, '475.0', '475', 'Surat Keterangan Pindah Domisili', true, 2),
  (v_tenant_id, '474.3', '474', 'Surat Keterangan Beda Nama', true, 3),
  (v_tenant_id, '474.4', '474', 'Surat Keterangan Biodata Penduduk', true, 4),
  (v_tenant_id, '474.5', '474', 'Surat Keterangan Kepala Keluarga (KK)', true, 5),
  (v_tenant_id, '474.6', '474', 'Surat Keterangan Kehilangan', true, 6),
  (v_tenant_id, '474.7', '474', 'Surat Keterangan Belum Menikah', true, 7),
  (v_tenant_id, '474.8', '474', 'Surat Keterangan Hubungan Keluarga', true, 8),
  (v_tenant_id, '474.9', '474', 'Surat Keterangan Ahli Waris', true, 9),
  (v_tenant_id, '474.10', '474', 'Surat Keterangan Domisili Sementara', true, 10),
  (v_tenant_id, '474.12', '474', 'Surat Pernyataan Tanggung Jawab Mutlak (SPTJM)', true, 11),
  (v_tenant_id, '474.13', '474', 'Surat Keterangan Pindah Agama', true, 12),
  (v_tenant_id, '474.14', '474', 'Surat Keterangan untuk Lamaran Kerja', true, 13);

  -- ============================================================
  -- B. KELUARGA & KEHIDUPAN (KODE 477)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '451.0', '451', 'Surat Keterangan Nikah (N-1)', true, 20),
  (v_tenant_id, '477.3', '477', 'Surat Keterangan Kelahiran (N-1)', true, 21),
  (v_tenant_id, '477.4', '477', 'Surat Keterangan Kematian (N-2)', true, 22),
  (v_tenant_id, '451.1', '451', 'Surat Dispensasi Nikah (N-5)', true, 23),
  (v_tenant_id, '451.2', '451', 'Surat Keterangan Wali Nikah (N-3)', true, 24),
  (v_tenant_id, '451.3', '451', 'Surat Keterangan Tanah Wakaf', true, 25),
  (v_tenant_id, '451.4', '451', 'Surat Keterangan Numpang Nikah (N-6)', true, 26),
  (v_tenant_id, '477.5', '477', 'Surat Keterangan Belum Ada Akta Lahir', true, 27),
  (v_tenant_id, '477.1', '477', 'Surat Keterangan Status Janda/Duda', true, 28);

  -- ============================================================
  -- C. SOSIAL & KESEJAHTERAAN (KODE 465/440/441/463)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '465.0', '465', 'Surat Keterangan Tidak Mampu (SKTM)', true, 30),
  (v_tenant_id, '465.1', '465', 'Surat Keterangan Penerima Bantuan Sosial', true, 31),
  (v_tenant_id, '465.2', '465', 'Surat Keterangan Penghasilan', true, 32),
  (v_tenant_id, '465.4', '465', 'Surat Keterangan Tidak Punya Pekerjaan', true, 33),
  (v_tenant_id, '465.5', '465', 'Surat Keterangan Warga Miskin Ekstrem', true, 34),
  (v_tenant_id, '440.0', '440', 'Surat Keterangan Jamkesos / BPJS', true, 35),
  (v_tenant_id, '461.0', '461', 'Surat Keterangan Penyandang Disabilitas', true, 36),
  (v_tenant_id, '463.0', '463', 'Surat Keterangan Orang Terlantar', true, 37),
  (v_tenant_id, '463.1', '463', 'Surat Keterangan Lansia', true, 38),
  (v_tenant_id, '463.2', '463', 'Surat Keterangan Anak Yatim/Piatu', true, 39),
  (v_tenant_id, '440.1', '440', 'Surat Keterangan Hamil / Ibu Melahirkan', true, 40),
  (v_tenant_id, '441.0', '441', 'Surat Keterangan Gangguan Jiwa (ODGJ)', true, 41),
  (v_tenant_id, '445.0', '445', 'Surat Keterangan Rawat Inap / Rujukan', true, 42);

  -- ============================================================
  -- D. KEPERCAYAAN DIRI & KELAKUAN (KODE 300)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '300.0', '300', 'Surat Pengantar SKCK', true, 50),
  (v_tenant_id, '300.1', '300', 'Surat Keterangan Kelakuan Baik', true, 51);

  -- ============================================================
  -- E. USAHA & EKONOMI (KODE 510/140)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '510.0', '510', 'Surat Keterangan Usaha (SKU)', true, 60),
  (v_tenant_id, '510.3', '510', 'Surat Izin Reklame / Papan Nama', true, 61),
  (v_tenant_id, '140.0', '140', 'Surat Izin Keramaian', true, 62),
  (v_tenant_id, '524.0', '524', 'Surat Keterangan Peternak', true, 63),
  (v_tenant_id, '530.0', '530', 'Surat Keterangan Pengrajin / Seniman', true, 64);

  -- ============================================================
  -- F. TANAH & PROPERTI (KODE 30/650)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '30.1', '30', 'Surat Keterangan Kepemilikan Tanah', true, 70),
  (v_tenant_id, '30.2', '30', 'Surat Keterangan Tidak Sengketa Tanah', true, 71),
  (v_tenant_id, '30.3', '30', 'Surat Keterangan Hibah Tanah', true, 72),
  (v_tenant_id, '30.4', '30', 'Surat Keterangan Jual Beli Tanah', true, 73),
  (v_tenant_id, '650.0', '650', 'Surat Keterangan Kepemilikan Rumah', true, 74),
  (v_tenant_id, '650.1', '650', 'Surat Keterangan Belum Memiliki Rumah', true, 75),
  (v_tenant_id, '30.6', '30', 'Surat Keterangan Sporadik Tanah', true, 76),
  (v_tenant_id, '30.9', '30', 'Surat Pengantar PTSL / Sertifikasi Tanah', true, 77);

  -- ============================================================
  -- G. PENDIDIKAN (KODE 420)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '420.0', '420', 'Surat Keterangan untuk Beasiswa', true, 80),
  (v_tenant_id, '420.1', '420', 'Surat Keterangan PPDB Zonasi', true, 81),
  (v_tenant_id, '420.2', '420', 'Surat Keterangan Penelitian / KKN / PKL', true, 82),
  (v_tenant_id, '420.3', '420', 'Surat Keterangan Putus Sekolah', true, 83),
  (v_tenant_id, '420.4', '420', 'Surat Izin Mendirikan Sanggar / Kursus', true, 84),
  (v_tenant_id, '420.5', '420', 'Surat Aktif Sekolah (PIP/KPS)', true, 85);

  -- ============================================================
  -- H. PERTANIAN & LINGKUNGAN (KODE 520/523/360/620)
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '520.0', '520', 'Surat Keterangan Petani', true, 90),
  (v_tenant_id, '523.0', '523', 'Surat Keterangan Nelayan', true, 91),
  (v_tenant_id, '360.0', '360', 'Surat Keterangan Dampak Bencana', true, 92),
  (v_tenant_id, '520.1', '520', 'Surat Izin Penebangan Pohon', true, 93),
  (v_tenant_id, '520.2', '520', 'Surat Keterangan Penggunaan Lahan', true, 94),
  (v_tenant_id, '620.0', '620', 'Surat Keterangan Penggunaan Air / Irigasi', true, 95);

  -- ============================================================
  -- I. SURAT UMUM & LAINNYA
  -- ============================================================
  INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan) VALUES
  (v_tenant_id, '140.1', '140', 'Surat Pengantar ke Instansi Lain', true, 100),
  (v_tenant_id, '140.2', '140', 'Surat Permohonan Bantuan', true, 101),
  (v_tenant_id, '140.3', '140', 'Surat Rekomendasi', true, 102),
  (v_tenant_id, '30.8', '30', 'Surat Pernyataan Tidak Ada Sengketa', true, 103),
  (v_tenant_id, '140.4', '140', 'Surat Perjanjian Kerjasama (MoU/PKS)', true, 104),
  (v_tenant_id, '610.0', '610', 'Surat Permohonan Perbaikan Jalan', true, 105),
  (v_tenant_id, '180.0', '180', 'Surat Kuasa', true, 106),
  (v_tenant_id, '220.0', '220', 'Surat Keterangan Keaktifan Organisasi', true, 107),
  (v_tenant_id, '900.0', '900', 'Surat Keterangan Bebas PBB', true, 108),
  (v_tenant_id, '880.0', '880', 'Surat Keterangan Pensiun / Purna Tugas', true, 109),
  (v_tenant_id, '471.0', '471', 'Surat Keterangan WNI Keturunan', true, 110);

  RAISE NOTICE 'Seed surat_jenis (FINAL) complete! Total: %', (SELECT count(*) FROM public.surat_jenis);
END $$;

-- Verify
SELECT count(*) as total_surat FROM public.surat_jenis;
