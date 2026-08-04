
-- ============================================================
-- SEED DNA FIELDS - Restoring all missing fields
-- Tanggal: 2026-08-05
-- ============================================================
DO $$
DECLARE v_tenant_id UUID; v_jenis UUID;
BEGIN SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

-- 475.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.0', 'alamat_tujuan', 'Alamat Tujuan', 'textarea', 'Jl. ... RT/RW ...', true, 'Tujuan', 1, 'Alamat lengkap tujuan pindah'),
      (v_tenant_id, v_jenis, '475.0', 'rt_tujuan', 'RT Tujuan', 'text', '001', true, 'Tujuan', 2, NULL),
      (v_tenant_id, v_jenis, '475.0', 'rw_tujuan', 'RW Tujuan', 'text', '001', true, 'Tujuan', 3, NULL),
      (v_tenant_id, v_jenis, '475.0', 'kab_kota_tujuan', 'Kabupaten/Kota Tujuan', 'text', 'Kabupaten Lombok Timur', true, 'Tujuan', 4, NULL),
      (v_tenant_id, v_jenis, '475.0', 'kec_tujuan', 'Kecamatan Tujuan', 'text', 'Kecamatan Pringgabaya', true, 'Tujuan', 5, NULL),
      (v_tenant_id, v_jenis, '475.0', 'desa_tujuan', 'Desa/Kelurahan Tujuan', 'text', 'Desa ...', true, 'Tujuan', 6, NULL),
      (v_tenant_id, v_jenis, '475.0', 'alasan_pindah', 'Alasan Pindah', 'textarea', 'Alasan ...', true, 'Pindah', 10, NULL),
      (v_tenant_id, v_jenis, '475.0', 'anggota_pindah', 'Daftar Anggota Pindah', 'textarea', '1. Nama - NIK - Hubungan%n2. ...', false, 'Pindah', 11, 'Daftar anggota keluarga yang ikut pindah'),
      (v_tenant_id, v_jenis, '475.0', 'no_surat_pindah_lama', 'No. Surat Pindah Lama', 'text', '', false, 'Pindah', 12, 'Jika ada surat pindah sebelumnya')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 510.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '510.0', 'nama_usaha', 'Nama Usaha', 'text', 'Warung Seruni', true, 'Usaha', 1, 'Nama dagang / usaha', NULL),
      (v_tenant_id, v_jenis, '510.0', 'jenis_bidang', 'Jenis Bidang Usaha', 'select', '', true, 'Usaha', 2, 'Sektor usaha', '["Perdagangan","Industri","Jasa","Pertanian","Peternakan","Perikanan","Kehutanan","Pertambangan","Konstruksi","Transportasi","Lainnya"]'::jsonb),
      (v_tenant_id, v_jenis, '510.0', 'komoditas', 'Komoditas / Produk Utama', 'text', 'Makanan, Minuman, Sembako', false, 'Usaha', 3, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'alamat_usaha', 'Alamat Usaha', 'textarea', 'Jl. ... RT/RW ...', true, 'Usaha', 4, 'Lokasi usaha lengkap', NULL),
      (v_tenant_id, v_jenis, '510.0', 'rt_usaha', 'RT', 'text', '001', true, 'Usaha', 5, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'rw_usaha', 'RW', 'text', '001', true, 'Usaha', 6, NULL, NULL),
      (v_tenant_id, v_jenis, '510.0', 'berdiri_sejak', 'Berdiri Sejak', 'date', '', false, 'Usaha', 7, 'Tanggal mulai usaha', NULL),
      (v_tenant_id, v_jenis, '510.0', 'jumlah_karyawan', 'Jumlah Karyawan', 'number', '0', false, 'Usaha', 8, 'Jumlah tenaga kerja', NULL),
      (v_tenant_id, v_jenis, '510.0', 'keperluan', 'Keperluan', 'textarea', 'Untuk pengajuan kredit / tender / dll', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 477.4
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.4', 'nik_almarhum', 'NIK Almarhum/Almarhumah', 'text', '5201010101010001', true, 'Data', 1, 'Nomor NIK yang tertera di KTP'),
      (v_tenant_id, v_jenis, '477.4', 'nama_almarhum', 'Nama Lengkap', 'text', '', true, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tanggal_meninggal', 'Tanggal Meninggal', 'date', '', true, 'Kematian', 10, NULL),
      (v_tenant_id, v_jenis, '477.4', 'hari_meninggal', 'Hari Meninggal', 'text', 'Senin/Selasa/...', true, 'Kematian', 11, NULL),
      (v_tenant_id, v_jenis, '477.4', 'pukul_meninggal', 'Pukul (Waktu)', 'text', '14.00 WITA', false, 'Kematian', 12, NULL),
      (v_tenant_id, v_jenis, '477.4', 'sebab_meninggal', 'Sebab Meninggal', 'textarea', 'Sakit tua/ Kecelakaan/ Lainnya', true, 'Kematian', 13, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tempat_meninggal', 'Tempat Meninggal', 'text', 'Rumah Sakit/ Rumah/ Lainnya', true, 'Kematian', 14, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tempat_pemakaman', 'Tempat Pemakaman', 'text', '', true, 'Kematian', 15, NULL),
      (v_tenant_id, v_jenis, '477.4', 'no_akta_kematian', 'No. Akta Kematian', 'text', '', false, 'Kematian', 16, 'Diisi setelah ada akta kematian dari Dukcapil'),
      (v_tenant_id, v_jenis, '477.4', 'yang_melaporkan', 'Yang Melaporkan', 'text', '', true, 'Pelapor', 20, 'Nama pelapor'),
      (v_tenant_id, v_jenis, '477.4', 'hub_pelapor', 'Hubungan dengan Almarhum', 'text', '', true, 'Pelapor', 21, 'Contoh: Anak, Istri, Suami, etc')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 477.3
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '477.3', 'nama_bayi', 'Nama Bayi', 'text', '', true, 'Bayi', 1, 'Kosongkan jika belum diberi nama', NULL),
      (v_tenant_id, v_jenis, '477.3', 'jenis_kelamin_bayi', 'Jenis Kelamin', 'select', '', true, 'Bayi', 2, NULL, '["Laki-laki","Perempuan"]'::jsonb),
      (v_tenant_id, v_jenis, '477.3', 'anak_ke', 'Anak ke-', 'number', '1', true, 'Bayi', 3, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'tanggal_lahir', 'Tanggal Lahir', 'date', '', true, 'Bayi', 10, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'pukul_lahir', 'Pukul (Waktu)', 'text', '10.00 WITA', false, 'Bayi', 11, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'tempat_lahir', 'Tempat Lahir', 'text', '', true, 'Bayi', 12, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'no_akta_lahir', 'No. Akta Lahir (jika ada)', 'text', '', false, 'Bayi', 13, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ayah', 'NIK Ayah', 'text', '', true, 'Orang Tua', 20, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ayah', 'Nama Ayah', 'text', '', true, 'Orang Tua', 21, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ibu', 'NIK Ibu', 'text', '', true, 'Orang Tua', 22, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ibu', 'Nama Ibu', 'text', '', true, 'Orang Tua', 23, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'pelapor', 'Yang Melaporkan', 'text', '', true, 'Pelapor', 30, NULL, NULL),
      (v_tenant_id, v_jenis, '477.3', 'hub_pelapor', 'Hubungan dengan Bayi', 'text', '', true, 'Pelapor', 31, 'Contoh: Ayah, Ibu, Kakek, etc', NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 465.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '465.0', 'penghasilan_per_bulan', 'Penghasilan per Bulan', 'number', '500000', true, 'Ekonomi', 1, 'Penghasilan kotor per bulan (Rp)', NULL),
      (v_tenant_id, v_jenis, '465.0', 'jumlah_tanggungan', 'Jumlah Tanggungan', 'number', '4', true, 'Ekonomi', 2, 'Jumlah anggota keluarga yang ditanggung', NULL),
      (v_tenant_id, v_jenis, '465.0', 'kondisi_tempat_tinggal', 'Kondisi Tempat Tinggal', 'select', '', true, 'Ekonomi', 3, NULL, '["Menumpang","Kontrak/Sewa","Milik Sendiri","Lainnya"]'::jsonb),
      (v_tenant_id, v_jenis, '465.0', 'sumber_penghasilan', 'Sumber Penghasilan', 'text', '', false, 'Ekonomi', 4, NULL, NULL),
      (v_tenant_id, v_jenis, '465.0', 'keperluan', 'Keperluan', 'textarea', 'Untuk biaya pendidikan/berobat/bantuan', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.6
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.6' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.6', 'barang_hilang', 'Barang/Dokumen yang Hilang', 'text', '', true, 'Kehilangan', 1, NULL),
      (v_tenant_id, v_jenis, '474.6', 'no_dokumen', 'Nomor Dokumen', 'text', '', false, 'Kehilangan', 2, 'No. KTP/SIM/dokumen yang hilang'),
      (v_tenant_id, v_jenis, '474.6', 'tanggal_hilang', 'Tanggal Perkiraan Hilang', 'date', '', true, 'Kehilangan', 10, NULL),
      (v_tenant_id, v_jenis, '474.6', 'lokasi_hilang', 'Lokasi Hilang', 'text', '', true, 'Kehilangan', 11, NULL),
      (v_tenant_id, v_jenis, '474.6', 'kronologi', 'Kronologi Kejadian', 'textarea', '', true, 'Kehilangan', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.7
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.7' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.7', 'nama_ayah', 'Nama Ayah Kandung', 'text', '', true, 'Orang Tua', 1, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nik_ayah', 'NIK Ayah', 'text', '', false, 'Orang Tua', 2, NULL),
      (v_tenant_id, v_jenis, '474.7', 'pekerjaan_ayah', 'Pekerjaan Ayah', 'text', '', false, 'Orang Tua', 3, NULL),
      (v_tenant_id, v_jenis, '474.7', 'alamat_ayah', 'Alamat Ayah', 'textarea', '', false, 'Orang Tua', 4, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nama_ibu', 'Nama Ibu Kandung', 'text', '', true, 'Orang Tua', 5, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nik_ibu', 'NIK Ibu', 'text', '', false, 'Orang Tua', 6, NULL),
      (v_tenant_id, v_jenis, '474.7', 'pekerjaan_ibu', 'Pekerjaan Ibu', 'text', '', false, 'Orang Tua', 7, NULL),
      (v_tenant_id, v_jenis, '474.7', 'alamat_ibu', 'Alamat Ibu', 'textarea', '', false, 'Orang Tua', 8, NULL),
      (v_tenant_id, v_jenis, '474.7', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.9
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.9' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.9', 'nama_pewaris', 'Nama Pewaris (Almarhum)', 'text', '', true, 'Pewaris', 1, NULL),
      (v_tenant_id, v_jenis, '474.9', 'nik_pewaris', 'NIK Pewaris', 'text', '', true, 'Pewaris', 2, NULL),
      (v_tenant_id, v_jenis, '474.9', 'tanggal_meninggal_pewaris', 'Tanggal Meninggal', 'date', '', true, 'Pewaris', 10, NULL),
      (v_tenant_id, v_jenis, '474.9', 'tempat_meninggal_pewaris', 'Tempat Meninggal', 'text', '', true, 'Pewaris', 11, NULL),
      (v_tenant_id, v_jenis, '474.9', 'no_akta_kematian_pewaris', 'No. Akta Kematian', 'text', '', false, 'Pewaris', 12, NULL),
      (v_tenant_id, v_jenis, '474.9', 'daftar_ahli_waris', 'Daftar Ahli Waris', 'textarea', '1. Nama - NIK - Hubungan%n2. ...', true, 'Ahli Waris', 20, 'Sesuai urutan hukum waris'),
      (v_tenant_id, v_jenis, '474.9', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.3
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.3', 'nama_di_ktp', 'Nama di KTP', 'text', '', true, 'Dokumen', 1, 'Nama resmi di KTP/KK'),
      (v_tenant_id, v_jenis, '474.3', 'nama_di_dokumen_lain', 'Nama di Dokumen Lain', 'text', '', true, 'Dokumen', 2, 'Nama yang tertulis berbeda'),
      (v_tenant_id, v_jenis, '474.3', 'jenis_dokumen', 'Jenis Dokumen', 'select', '', true, 'Dokumen', 3, NULL),
      (v_tenant_id, v_jenis, '474.3', 'penyebab', 'Penyebab Perbedaan', 'textarea', '', true, 'Dokumen', 4, NULL),
      (v_tenant_id, v_jenis, '474.3', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Ijazah","Akta Lahir","Buku Nikah","KTP","KK","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_dokumen';
  END IF;

-- 451.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '451.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '451.0', 'nik_suami', 'NIK Calon Suami', 'text', '', true, 'Data Suami', 1, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_suami', 'Nama Calon Suami', 'text', '', true, 'Data Suami', 2, NULL),
      (v_tenant_id, v_jenis, '451.0', 'ttl_suami', 'TTL Calon Suami', 'text', '', true, 'Data Suami', 3, NULL),
      (v_tenant_id, v_jenis, '451.0', 'status_suami', 'Status Pernikahan', 'select', '', true, 'Data Suami', 4, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_ayah_suami', 'Nama Ayah Suami', 'text', '', true, 'Data Suami', 5, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_ibu_suami', 'Nama Ibu Suami', 'text', '', true, 'Data Suami', 6, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nik_istri', 'NIK Calon Istri', 'text', '', true, 'Data Istri', 10, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_istri', 'Nama Calon Istri', 'text', '', true, 'Data Istri', 11, NULL),
      (v_tenant_id, v_jenis, '451.0', 'ttl_istri', 'TTL Calon Istri', 'text', '', true, 'Data Istri', 12, NULL),
      (v_tenant_id, v_jenis, '451.0', 'status_istri', 'Status Pernikahan', 'select', '', true, 'Data Istri', 13, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_ayah_istri', 'Nama Ayah Istri', 'text', '', true, 'Data Istri', 14, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_ibu_istri', 'Nama Ibu Istri', 'text', '', true, 'Data Istri', 15, NULL),
      (v_tenant_id, v_jenis, '451.0', 'nama_wali', 'Nama Wali Nikah', 'text', '', true, 'Wali', 20, NULL),
      (v_tenant_id, v_jenis, '451.0', 'hubungan_wali', 'Hubungan Wali', 'select', '', true, 'Wali', 21, NULL),
      (v_tenant_id, v_jenis, '451.0', 'tanggal_akad', 'Tanggal Rencana Akad', 'date', '', true, 'Nikah', 30, NULL),
      (v_tenant_id, v_jenis, '451.0', 'tempat_akad', 'Tempat Akad', 'text', '', true, 'Nikah', 31, NULL),
      (v_tenant_id, v_jenis, '451.0', 'kua_tujuan', 'KUA Kecamatan', 'text', '', true, 'Nikah', 32, NULL),
      (v_tenant_id, v_jenis, '451.0', 'seri_formulir', 'Seri Formulir', 'select', '', true, 'Nikah', 33, NULL),
      (v_tenant_id, v_jenis, '451.0', 'no_akta_cerai', 'No. Akta Cerai (jika ada)', 'text', '', false, 'Nikah', 34, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Belum Kawin","Duda","Poligami"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_suami';
    UPDATE public.surat_jenis_dna SET options = '["Belum Kawin","Janda","Cerai"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_istri';
    UPDATE public.surat_jenis_dna SET options = '["Ayah Kandung","Kakak","Paman","Hakim"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'hubungan_wali';
    UPDATE public.surat_jenis_dna SET options = '["N-1","N-2","N-3","N-4","N-5","N-6"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'seri_formulir';
  END IF;

-- 477.1
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.1', 'nama_mantan', 'Nama Suami/Mantan Suami', 'text', '', true, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '477.1', 'nik_mantan', 'NIK Mantan Pasangan', 'text', '', false, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '477.1', 'penyebab', 'Penyebab Status', 'select', '', true, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '477.1', 'no_akta_cerai', 'No. Akta Cerai/Putusan PA', 'text', '', false, 'Data', 11, NULL),
      (v_tenant_id, v_jenis, '477.1', 'tanggal_cerai', 'Tanggal Cerai/Meninggal', 'date', '', true, 'Data', 12, NULL),
      (v_tenant_id, v_jenis, '477.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Cerai Mati","Cerai Hidup Gugatan","Cerai Hidup Talak"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'penyebab';
  END IF;

-- 140.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.0', 'nama_penyelenggara', 'Nama Penyelenggara/PIC', 'text', '', true, 'Penyelenggara', 1, NULL),
      (v_tenant_id, v_jenis, '140.0', 'nik_penyelenggara', 'NIK Penyelenggara', 'text', '', true, 'Penyelenggara', 2, NULL),
      (v_tenant_id, v_jenis, '140.0', 'nama_organisasi', 'Nama Organisasi (jika ada)', 'text', '', false, 'Penyelenggara', 3, NULL),
      (v_tenant_id, v_jenis, '140.0', 'jenis_acara', 'Jenis/Nama Acara', 'text', '', true, 'Acara', 10, NULL),
      (v_tenant_id, v_jenis, '140.0', 'tanggal_pelaksanaan', 'Tanggal Pelaksanaan', 'date', '', true, 'Acara', 11, NULL),
      (v_tenant_id, v_jenis, '140.0', 'jam_mulai', 'Jam Mulai', 'text', '', true, 'Acara', 12, NULL),
      (v_tenant_id, v_jenis, '140.0', 'jam_selesai', 'Jam Selesai', 'text', '', true, 'Acara', 13, NULL),
      (v_tenant_id, v_jenis, '140.0', 'tempat_acara', 'Tempat/Lokasi', 'text', '', true, 'Acara', 14, NULL),
      (v_tenant_id, v_jenis, '140.0', 'jumlah_peserta', 'Perkiraan Jumlah Peserta', 'number', '', true, 'Acara', 15, NULL),
      (v_tenant_id, v_jenis, '140.0', 'sound_system', 'Menggunakan Sound System', 'select', '', true, 'Acara', 16, NULL),
      (v_tenant_id, v_jenis, '140.0', 'petugas_keamanan', 'Petugas Keamanan', 'text', '', true, 'Acara', 17, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Ya","Tidak"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'sound_system';
  END IF;

-- 30.1
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.1', 'lokasi_tanah', 'Lokasi/Alamat Tanah', 'textarea', '', true, 'Tanah', 1, NULL),
      (v_tenant_id, v_jenis, '30.1', 'luas_tanah', 'Luas Tanah (m2)', 'number', '', true, 'Tanah', 2, NULL),
      (v_tenant_id, v_jenis, '30.1', 'no_persil', 'Nomor Persil/Blok', 'text', '', false, 'Tanah', 3, NULL),
      (v_tenant_id, v_jenis, '30.1', 'kelas_tanah', 'Kelas/Jenis Tanah', 'select', '', true, 'Tanah', 4, NULL),
      (v_tenant_id, v_jenis, '30.1', 'batas_utara', 'Batas Utara', 'text', '', true, 'Batas', 10, NULL),
      (v_tenant_id, v_jenis, '30.1', 'batas_selatan', 'Batas Selatan', 'text', '', true, 'Batas', 11, NULL),
      (v_tenant_id, v_jenis, '30.1', 'batas_timur', 'Batas Timur', 'text', '', true, 'Batas', 12, NULL),
      (v_tenant_id, v_jenis, '30.1', 'batas_barat', 'Batas Barat', 'text', '', true, 'Batas', 13, NULL),
      (v_tenant_id, v_jenis, '30.1', 'status_kepemilikan', 'Status/Dasar Kepemilikan', 'select', '', true, 'Kepemilikan', 20, NULL),
      (v_tenant_id, v_jenis, '30.1', 'no_sppt', 'Nomor SPPT PBB', 'text', '', true, 'Kepemilikan', 21, NULL),
      (v_tenant_id, v_jenis, '30.1', 'peruntukan', 'Penggunaan/Peruntukan', 'select', '', true, 'Kepemilikan', 22, NULL),
      (v_tenant_id, v_jenis, '30.1', 'keperluan', 'Keperluan', 'select', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Sawah","Sawah Tadah Hujan","Tanah Kering","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'kelas_tanah';
    UPDATE public.surat_jenis_dna SET options = '["Sertifikat","Letter C","AJB","Hibah","Warisan","Beli"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_kepemilikan';
    UPDATE public.surat_jenis_dna SET options = '["Rumah","Sawah","Kebun","Usaha","Kosong"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'peruntukan';
    UPDATE public.surat_jenis_dna SET options = '["Sertifikasi","Jual Beli","Jaminan Bank","Hibah","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'keperluan';
  END IF;

-- 30.9
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.9' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.9', 'lokasi', 'Lokasi Tanah', 'textarea', '', true, 'Tanah', 1, NULL),
      (v_tenant_id, v_jenis, '30.9', 'luas', 'Luas (m2)', 'number', '', true, 'Tanah', 2, NULL),
      (v_tenant_id, v_jenis, '30.9', 'no_persil', 'Nomor Persil', 'text', '', false, 'Tanah', 3, NULL),
      (v_tenant_id, v_jenis, '30.9', 'bukti_kepemilikan', 'Bukti Kepemilikan', 'text', '', true, 'Tanah', 10, NULL),
      (v_tenant_id, v_jenis, '30.9', 'no_bidang', 'Nomor Bidang', 'text', '', false, 'Tanah', 11, NULL),
      (v_tenant_id, v_jenis, '30.9', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.4
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.5
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.5', 'anggota_keluarga', 'Daftar Anggota Keluarga', 'textarea', '', true, 'Keluarga', 10, 'Nama - NIK - Hubungan')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 440.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '440.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '440.0', 'no_bpjs_lama', 'No. BPJS Lama (jika ada)', 'text', '', false, 'BPJS', 1, NULL),
      (v_tenant_id, v_jenis, '440.0', 'kategori_peserta', 'Kategori Peserta', 'select', '', true, 'BPJS', 2, NULL),
      (v_tenant_id, v_jenis, '440.0', 'anggota_daftar', 'Anggota yang Didaftarkan', 'textarea', '', true, 'BPJS', 10, 'Nama - NIK'),
      (v_tenant_id, v_jenis, '440.0', 'faskes', 'Faskes Tujuan', 'text', '', true, 'BPJS', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["PBI","PBPU","PPU"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'kategori_peserta';
  END IF;

-- 523.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '523.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '523.0', 'jenis_nelayan', 'Jenis Nelayan', 'select', '', true, 'Nelayan', 1, NULL),
      (v_tenant_id, v_jenis, '523.0', 'alat_tangkap', 'Alat Tangkap', 'text', '', true, 'Nelayan', 10, NULL),
      (v_tenant_id, v_jenis, '523.0', 'jenis_ukuran_kapal', 'Jenis/Ukuran Kapal', 'text', '', false, 'Nelayan', 11, NULL),
      (v_tenant_id, v_jenis, '523.0', 'no_registrasi', 'No. Registrasi Kapal', 'text', '', false, 'Nelayan', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Nelayan Penangkap","Nelayan Budidayawan","Nelayan Pengolah"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_nelayan';
  END IF;

-- 520.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '520.0', 'komoditas_utama', 'Komoditas Utama', 'text', '', true, 'Petani', 1, NULL),
      (v_tenant_id, v_jenis, '520.0', 'luas_lahan', 'Luas Lahan (m2)', 'number', '', true, 'Petani', 2, NULL),
      (v_tenant_id, v_jenis, '520.0', 'status_kepemilikan', 'Status Kepemilikan Lahan', 'select', '', true, 'Petani', 10, NULL),
      (v_tenant_id, v_jenis, '520.0', 'lokasi_blok', 'Lokasi/Blok', 'text', '', true, 'Petani', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Milik Sendiri","Sewa","Garapan","Bagi Hasil"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_kepemilikan';
  END IF;

-- 461.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '461.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '461.0', 'jenis_disabilitas', 'Jenis Disabilitas', 'select', '', true, 'Disabilitas', 1, NULL),
      (v_tenant_id, v_jenis, '461.0', 'tingkat', 'Tingkat Disabilitas', 'select', '', true, 'Disabilitas', 2, NULL),
      (v_tenant_id, v_jenis, '461.0', 'penyebab', 'Penyebab', 'textarea', '', false, 'Disabilitas', 10, NULL),
      (v_tenant_id, v_jenis, '461.0', 'alat_bantu', 'Alat Bantu yang Digunakan', 'text', '', false, 'Disabilitas', 11, NULL),
      (v_tenant_id, v_jenis, '461.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Disabilitas', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Fisik","Intelektual","Mental","Sensorik","Ganda"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_disabilitas';
    UPDATE public.surat_jenis_dna SET options = '["Ringan","Sedang","Berat"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'tingkat';
  END IF;

-- 610.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '610.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '610.0', 'nama_ruas', 'Nama Ruas Jalan', 'text', '', true, 'Jalan', 1, NULL),
      (v_tenant_id, v_jenis, '610.0', 'lokasi', 'Lokasi/Rute', 'textarea', '', true, 'Jalan', 10, NULL),
      (v_tenant_id, v_jenis, '610.0', 'panjang_rusak', 'Panjang Rusak (m)', 'number', '', true, 'Jalan', 11, NULL),
      (v_tenant_id, v_jenis, '610.0', 'lebar', 'Lebar (m)', 'number', '', true, 'Jalan', 12, NULL),
      (v_tenant_id, v_jenis, '610.0', 'kondisi', 'Kondisi', 'select', '', true, 'Jalan', 13, NULL),
      (v_tenant_id, v_jenis, '610.0', 'status_jalan', 'Status Jalan', 'select', '', true, 'Jalan', 14, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Rusak Ringan","Rusak Sedang","Rusak Berat","Putus"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'kondisi';
    UPDATE public.surat_jenis_dna SET options = '["Desa","Kecamatan","Kabupaten","Nasional"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_jalan';
  END IF;

-- 420.0
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.0', 'jenjang', 'Jenjang Pendidikan', 'select', '', true, 'Pendidikan', 1, NULL),
      (v_tenant_id, v_jenis, '420.0', 'nama_sekolah', 'Nama Sekolah/Kampus', 'text', '', true, 'Pendidikan', 10, NULL),
      (v_tenant_id, v_jenis, '420.0', 'prodi', 'Program Studi/Jurusan', 'text', '', false, 'Pendidikan', 11, NULL),
      (v_tenant_id, v_jenis, '420.0', 'prestasiscore', 'Prestasi/IPK Terakhir', 'text', '', false, 'Pendidikan', 12, NULL),
      (v_tenant_id, v_jenis, '420.0', 'keperluan', 'Keperluan Beasiswa', 'textarea', '', true, 'Pendidikan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["SD","SMP","SMA/SMK","D1","D2","D3","S1","S2","S3"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenjang';
  END IF;

-- 474.10
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.10' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.10', 'jenis_dokumen', 'Jenis Dokumen', 'select', '', true, 'Dokumen', 1, NULL),
      (v_tenant_id, v_jenis, '474.10', 'alasan', 'Alasan', 'textarea', '', true, 'Dokumen', 10, NULL),
      (v_tenant_id, v_jenis, '474.10', 'kantor_tujuan', 'Kantor Dukcapil Tujuan', 'text', '', true, 'Dokumen', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["KTP","KK","Akta Lahir","Akta Nikah","Kartu Identitas Anak"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_dokumen';
  END IF;

-- 474.12
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.12' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.12', 'jenis_sptjm', 'Jenis SPTJM', 'text', '', true, 'SPTJM', 1, NULL),
      (v_tenant_id, v_jenis, '474.12', 'isi_pernyataan', 'Isi Pernyataan', 'textarea', '', true, 'SPTJM', 10, NULL),
      (v_tenant_id, v_jenis, '474.12', 'saksi1', 'Saksi 1 - Nama & NIK', 'text', '', true, 'SPTJM', 20, NULL),
      (v_tenant_id, v_jenis, '474.12', 'saksi2', 'Saksi 2 - Nama & NIK', 'text', '', true, 'SPTJM', 21, NULL),
      (v_tenant_id, v_jenis, '474.12', 'keperluan', 'Keperluan', 'textarea', '', true, 'SPTJM', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.13
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.13' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.13', 'agama_asal', 'Agama Asal', 'text', '', true, 'Agama', 1, NULL),
      (v_tenant_id, v_jenis, '474.13', 'agama_sekarang', 'Agama Sekarang', 'text', '', true, 'Agama', 2, NULL),
      (v_tenant_id, v_jenis, '474.13', 'keterangan', 'Keterangan Perpindahan', 'textarea', '', true, 'Agama', 10, NULL),
      (v_tenant_id, v_jenis, '474.13', 'keperluan', 'Keperluan', 'textarea', '', true, 'Agama', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 477.5
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.5', 'nama_anak', 'Nama Anak', 'text', '', true, 'Akta', 1, NULL),
      (v_tenant_id, v_jenis, '477.5', 'ttl_anak', 'TTL', 'text', '', true, 'Akta', 2, NULL),
      (v_tenant_id, v_jenis, '477.5', 'jk', 'Jenis Kelamin', 'select', '', true, 'Akta', 3, NULL),
      (v_tenant_id, v_jenis, '477.5', 'anak_ke', 'Anak ke-', 'number', '', true, 'Akta', 4, NULL),
      (v_tenant_id, v_jenis, '477.5', 'nik_ayah', 'NIK Ayah', 'text', '', true, 'Akta', 10, NULL),
      (v_tenant_id, v_jenis, '477.5', 'nik_ibu', 'NIK Ibu', 'text', '', true, 'Akta', 11, NULL),
      (v_tenant_id, v_jenis, '477.5', 'keperluan', 'Keperluan', 'textarea', '', true, 'Akta', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Laki-laki","Perempuan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jk';
  END IF;

-- 474.14
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.14' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.14', 'posisi', 'Posisi/Perusahaan Dilamar', 'text', '', true, 'Kerja', 1, NULL),
      (v_tenant_id, v_jenis, '474.14', 'keperluan', 'Keperluan', 'textarea', '', true, 'Kerja', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 474.8
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.8' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.8', 'nama_warga', 'Nama Lengkap', 'text', '', true, 'Identitas', 1, NULL),
      (v_tenant_id, v_jenis, '474.8', 'nik_warga', 'NIK', 'text', '', true, 'Identitas', 2, NULL),
      (v_tenant_id, v_jenis, '474.8', 'hubungan', 'Hubungan dengan yang Dipohonkan', 'text', '', true, 'Keluarga', 10, NULL),
      (v_tenant_id, v_jenis, '474.8', 'nama_yang_dipohon', 'Nama yang Dipohonkan', 'text', '', true, 'Keluarga', 11, NULL),
      (v_tenant_id, v_jenis, '474.8', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 140.1
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.1', 'tujuan', 'Tujuan / Instansi', 'text', '', true, 'Tujuan', 1, NULL),
      (v_tenant_id, v_jenis, '140.1', 'nama', 'Nama Lengkap', 'text', '', true, 'Identitas', 10, NULL),
      (v_tenant_id, v_jenis, '140.1', 'nik', 'NIK', 'text', '', true, 'Identitas', 11, NULL),
      (v_tenant_id, v_jenis, '140.1', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 12, NULL),
      (v_tenant_id, v_jenis, '140.1', 'keperluan', 'Uraian Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 451.1
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '451.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '451.1', 'nama_calon', 'Nama Lengkap', 'text', '', true, 'Calon', 1, NULL),
      (v_tenant_id, v_jenis, '451.1', 'ttl_calon', 'Tempat & Tanggal Lahir', 'text', '', true, 'Calon', 2, NULL),
      (v_tenant_id, v_jenis, '451.1', 'nik_calon', 'NIK', 'text', '', true, 'Calon', 3, NULL),
      (v_tenant_id, v_jenis, '451.1', 'alamat_calon', 'Alamat', 'textarea', '', true, 'Calon', 10, NULL),
      (v_tenant_id, v_jenis, '451.1', 'alasan', 'Alasan Dispensasi', 'textarea', '', true, 'Alasan', 20, NULL),
      (v_tenant_id, v_jenis, '451.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 451.2
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '451.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '451.2', 'nama_calon', 'Nama Lengkap', 'text', '', true, 'Calon', 1, NULL),
      (v_tenant_id, v_jenis, '451.2', 'ttl_calon', 'Tempat & Tanggal Lahir', 'text', '', true, 'Calon', 2, NULL),
      (v_tenant_id, v_jenis, '451.2', 'nik_calon', 'NIK', 'text', '', true, 'Calon', 3, NULL),
      (v_tenant_id, v_jenis, '451.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 451.3
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '451.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '451.3', 'nama_wakif', 'Nama Wakif (yang mewakafkan)', 'text', '', true, 'Wakif', 1, NULL),
      (v_tenant_id, v_jenis, '451.3', 'nik_wakif', 'NIK Wakif', 'text', '', true, 'Wakif', 2, NULL),
      (v_tenant_id, v_jenis, '451.3', 'alamat_wakif', 'Alamat Wakif', 'textarea', '', true, 'Wakif', 3, NULL),
      (v_tenant_id, v_jenis, '451.3', 'lokasi_tanah', 'Lokasi Tanah yang Diwakafkan', 'textarea', '', true, 'Tanah', 10, NULL),
      (v_tenant_id, v_jenis, '451.3', 'luas_tanah', 'Luas (m2)', 'number', '', true, 'Tanah', 11, NULL),
      (v_tenant_id, v_jenis, '451.3', 'nama_mauquf', 'Nama Mauquf Alaih (penerima)', 'text', '', true, 'Mauquf', 20, NULL),
      (v_tenant_id, v_jenis, '451.3', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

-- 451.4
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '451.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '451.4', 'nama_calon', 'Nama Lengkap', 'text', '', true, 'Calon', 1, NULL),
      (v_tenant_id, v_jenis, '451.4', 'ttl_calon', 'Tempat & Tanggal Lahir', 'text', '', true, 'Calon', 2, NULL),
      (v_tenant_id, v_jenis, '451.4', 'nik_calon', 'NIK', 'text', '', true, 'Calon', 3, NULL),
      (v_tenant_id, v_jenis, '451.4', 'alamat_asal', 'Alamat Asal', 'textarea', '', true, 'Asal', 10, NULL),
      (v_tenant_id, v_jenis, '451.4', 'alamat_num', 'Alamat Numpang', 'textarea', '', true, 'Num', 20, NULL),
      (v_tenant_id, v_jenis, '451.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

END $$;
