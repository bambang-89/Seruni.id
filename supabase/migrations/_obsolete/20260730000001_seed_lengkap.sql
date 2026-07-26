-- ============================================================
-- SEED DATA LENGKAP - Seruni Mumbul
-- 4 Burnett: Mandar, Sasak, Dames, Brangtapen Asri
-- ============================================================

-- AMBIL TENANT ID TERLEBIH DAHULU
DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    v_tenant_id := gen_random_uuid();
    INSERT INTO public.tenants (id, nama_desa, subdomain) VALUES (v_tenant_id, 'Desa Seruni Mumbul', 'seruni');
  END IF;
  RAISE NOTICE 'tenant_id: %', v_tenant_id;
END $$;

-- PROFIL DESA
INSERT INTO public.profil_desa (tenant_id, singleton, sejarah, visi, misi)
SELECT
  (SELECT id FROM tenants LIMIT 1),
  true,
  '["Desa Seruni Mumbul di Kec. Pringgabaya, Kab. Lombok Timur.","4 Burnett: Mandar, Sasak, Dames, Brangtapen Asri.","Sektor: perikanan, pertanian, perdagangan."]'::jsonb,
  'Terwujudnya Desa Seruni Mumbul yang maju dan berdaya saing.',
  '["Pelayanan publik berkualitas.","Ekonomi kerakyatan.","Lingkungan lestari.","SDM berkualitas."]'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM public.profil_desa);

-- WILAYAH DUSUN (4 Burnett: Mandar, Sasak, Dames, Brangtapen Asri)
INSERT INTO public.wilayah_dusun (tenant_id, nama, kk, jiwa, luas_ha, urutan)
SELECT * FROM (VALUES
  ((SELECT id FROM tenants LIMIT 1), 'Mandar', 678, 2378, 285, 1),
  ((SELECT id FROM tenants LIMIT 1), 'Sasak', 712, 2413, 302, 2),
  ((SELECT id FROM tenants LIMIT 1), 'Dames', 543, 1348, 198, 3),
  ((SELECT id FROM tenants LIMIT 1), 'Brangtapen Asri', 542, 1728, 215, 4)
) AS t(tenant_id, nama, kk, jiwa, luas_ha, urutan)
WHERE NOT EXISTS (SELECT 1 FROM public.wilayah_dusun WHERE nama = t.nama);

-- SURAT JENIS (85 Surat - tenant_id required)
INSERT INTO public.surat_jenis (tenant_id, kode_surat, kode_klasifikasi, nama, aktif, urutan)
SELECT (SELECT id FROM tenants LIMIT 1), * FROM (VALUES
  ('474.0', '474', 'Surat Keterangan Domisili', true, 1),
  ('475.0', '475', 'Surat Keterangan Pindah Domisili', true, 2),
  ('474.1', '474', 'Surat Keterangan bukan Penduduk Setempat', true, 3),
  ('474.2', '474', 'Surat Keterangan KK Sementara', true, 4),
  ('474.3', '474', 'Surat Keterangan Beda Nama', true, 5),
  ('474.4', '474', 'Surat Keterangan Penduduk (Biodata Lengkap)', true, 6),
  ('475.1', '475', 'Surat Keterangan Pendatang / Numpang KK', true, 7),
  ('475.2', '475', 'Surat Keterangan Alamat Sementara', true, 8),
  ('475.3', '475', 'Surat Keterangan Mutasi Penduduk Masuk', true, 9),
  ('474.5', '474', 'Surat Keterangan Kepala Keluarga', true, 10),
  ('475.5', '475', 'Surat Keterangan Tidak Berada di ', true, 11),
  ('465.0', '465', 'Surat Keterangan Tidak Mampu (SKTM)', true, 12),
  ('465.1', '465', 'Surat Keterangan Penerima Bantuan Sosial', true, 13),
  ('465.2', '465', 'Surat Keterangan Penghasilan', true, 14),
  ('440.0', '440', 'Surat Keterangan Jamkesos / BPJS', true, 15),
  ('474.6', '474', 'Surat Keterangan Kehilangan', true, 16),
  ('300.0', '300', 'Surat Pengantar SKCK', true, 17),
  ('300.1', '300', 'Surat Keterangan Kelakuan Baik', true, 18),
  ('465.4', '465', 'Surat Keterangan Tidak Punya Pekerjaan', true, 19),
  ('465.5', '465', 'Surat Keterangan Warga Miskin Ekstrem', true, 20),
  ('465.6', '465', 'Surat Pengantar Pengiriman Bantuan', true, 21),
  ('474.7', '474', 'Surat Keterangan Belum Menikah', true, 22),
  ('451.0', '451', 'Surat Keterangan Nikah (N-1 s/d N-6)', true, 23),
  ('477.0', '477', 'Surat Keterangan Nikah Non-Muslim', true, 24),
  ('477.1', '477', 'Surat Keterangan Status Janda / Duda', true, 25),
  ('474.8', '474', 'Surat Keterangan Hubungan Keluarga', true, 26),
  ('474.9', '474', 'Surat Keterangan Ahli Waris', true, 27),
  ('477.3', '477', 'Surat Keterangan Kelahiran', true, 28),
  ('477.4', '477', 'Surat Keterangan Kematian', true, 29),
  ('451.1', '451', 'Surat Dispensasi Nikah (Pengantar PA)', true, 30),
  ('451.2', '451', 'Surat Keterangan Wali Nikah Hakim', true, 31),
  ('451.3', '451', 'Surat Keterangan Tanah Wakaf', true, 32),
  ('451.4', '451', 'Surat Keterangan Numpang Nikah', true, 33),
  ('510.0', '510', 'Surat Keterangan Usaha (SKU)', true, 34),
  ('510.1', '510', 'Surat Keterangan Domisili Usaha', true, 35),
  ('140.0', '140', 'Surat Izin Keramaian', true, 36),
  ('30.0', '30', 'Surat Pengantar Peminjaman Tempat', true, 37),
  ('524.0', '524', 'Surat Keterangan Peternak', true, 38),
  ('530.0', '530', 'Surat Keterangan Pengrajin / Seniman', true, 39),
  ('510.2', '510', 'Surat Keterangan Pedagang Pasar', true, 40),
  ('510.3', '510', 'Surat Izin Reklame / Papan Nama', true, 41),
  ('30.1', '30', 'Surat Keterangan Kepemilikan Tanah', true, 42),
  ('30.2', '30', 'Surat Keterangan Tidak Sengketa Tanah', true, 43),
  ('30.3', '30', 'Surat Keterangan Hibah Tanah', true, 44),
  ('30.4', '30', 'Surat Keterangan Jual Beli Tanah', true, 45),
  ('650.0', '650', 'Surat Keterangan Kepemilikan Rumah', true, 46),
  ('650.1', '650', 'Surat Keterangan Belum Memiliki Rumah', true, 47),
  ('30.5', '30', 'Surat Keterangan Tanah Bengkok / Kas Burnett', true, 48),
  ('30.6', '30', 'Surat Keterangan Sporadik Tanah', true, 49),
  ('650.2', '650', 'Surat Pengantar IMB / PBG', true, 50),
  ('30.9', '30', 'Surat Pengantar PTSL', true, 51),
  ('420.0', '420', 'Surat Keterangan untuk Beasiswa', true, 52),
  ('420.1', '420', 'Surat Keterangan PPDB Zonasi', true, 53),
  ('420.2', '420', 'Surat Keterangan Penelitian / KKN / PKL', true, 54),
  ('420.3', '420', 'Surat Keterangan Putus Sekolah', true, 55),
  ('420.4', '420', 'Surat Izin Mendirikan Sanggar / Kursus', true, 56),
  ('420.5', '420', 'Surat Aktif Sekolah (PIP/KPS)', true, 57),
  ('461.0', '461', 'Surat Keterangan Penyandang Disabilitas', true, 58),
  ('463.0', '463', 'Surat Keterangan Orang Terlantar', true, 59),
  ('445.0', '445', 'Surat Keterangan Rawat Inap / Rujukan', true, 60),
  ('463.1', '463', 'Surat Keterangan Lansia', true, 61),
  ('463.2', '463', 'Surat Keterangan Yatim / Piatu', true, 62),
  ('440.1', '440', 'Surat Keterangan Hamil / Ibu Melahirkan', true, 63),
  ('441.0', '441', 'Surat Keterangan Gangguan Jiwa (ODGJ)', true, 64),
  ('80.0', '80', 'Surat Undangan Rapat', true, 65),
  ('90.0', '90', 'Surat Tugas Perangkat ', true, 66),
  ('890.0', '890', 'Surat Izin Cuti Perangkat ', true, 67),
  ('140.1', '140', 'Surat Pengantar ke Instansi Lain', true, 68),
  ('141.0', '141', 'Surat Keputusan Kepala Burnett (SK)', true, 69),
  ('140.2', '140', 'Surat Permohonan Bantuan', true, 70),
  ('30.7', '30', 'Berita Acara Serah Terima', true, 71),
  ('140.3', '140', 'Surat Rekomendasi', true, 72),
  ('30.8', '30', 'Surat Pernyataan Tidak Ada Sengketa', true, 73),
  ('60.0', '60', 'Nota Dinas', true, 74),
  ('140.4', '140', 'Surat Perjanjian Kerjasama (MoU/PKS)', true, 75),
  ('610.0', '610', 'Surat Permohonan Perbaikan Jalan', true, 76),
  ('50.0', '50', 'Laporan Pelaksanaan Kegiatan', true, 77),
  ('520.0', '520', 'Surat Keterangan Petani', true, 78),
  ('523.0', '523', 'Surat Keterangan Nelayan', true, 79),
  ('360.0', '360', 'Surat Keterangan Dampak Bencana', true, 80),
  ('520.1', '520', 'Surat Izin Penebangan Pohon', true, 81),
  ('520.2', '520', 'Surat Keterangan Penggunaan Lahan', true, 82),
  ('520.3', '520', 'Surat Keterangan Kelompok Tani / Nelayan', true, 83),
  ('620.0', '620', 'Surat Keterangan Penggunaan Air / Irigasi', true, 84),
  ('474.10', '474', 'Surat Pengantar Pembuatan Dokumen Kependudukan', true, 85)
) AS t(kode, klas, nama, aktif, urutan)
WHERE NOT EXISTS (SELECT 1 FROM public.surat_jenis WHERE kode_surat = t.kode);

-- VERIFIKASI
SELECT 'WILAYAH DUSUN' as tbl, count(*)::text as jml FROM public.wilayah_dusun
UNION ALL SELECT 'SURAT JENIS', count(*)::text FROM public.surat_jenis
UNION ALL SELECT 'PROFIL DESA', count(*)::text FROM public.profil_desa;
