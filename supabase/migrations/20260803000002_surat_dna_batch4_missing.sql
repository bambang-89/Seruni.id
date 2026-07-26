-- Migration: 20260803000002_surat_dna_batch4_missing.sql
-- DNA Fields untuk jenis surat yang BELUM punya field definitions

DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  -- 465.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '465.0', 'keperluan', 'Keperluan / Tujuan Permohonan', 'textarea', '', true, 'Keperluan', 1, NULL),
      (v_tenant_id, v_jenis, '465.0', 'alamat_domisili', 'Alamat Domisili Lengkap', 'textarea', '', true, 'Domisili', 10, NULL),
      (v_tenant_id, v_jenis, '465.0', 'dusun', 'Dusun', 'text', '', true, 'Domisili', 11, NULL),
      (v_tenant_id, v_jenis, '465.0', 'rt_rw', 'RT / RW', 'text', '', true, 'Domisili', 12, NULL),
      (v_tenant_id, v_jenis, '465.0', 'pekerjaan', 'Pekerjaan', 'text', '', true, 'Ekonomi', 20, NULL),
      (v_tenant_id, v_jenis, '465.0', 'penghasilan', 'Penghasilan per Bulan (Rp)', 'number', '', true, 'Ekonomi', 21, NULL),
      (v_tenant_id, v_jenis, '465.0', 'jumlah_tanggungan', 'Jumlah Tanggungan', 'number', '', true, 'Keluarga', 22, NULL),
      (v_tenant_id, v_jenis, '465.0', 'status_rumah', 'Status Kepemilikan Rumah', 'select', '', true, 'Ekonomi', 23, NULL),
      (v_tenant_id, v_jenis, '465.0', 'no_kk', 'No. Kartu Keluarga', 'text', '', true, 'Keluarga', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 474.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.0', 'alamat_domisili', 'Alamat Domisili Lengkap', 'textarea', '', true, 'Domisili', 1, NULL),
      (v_tenant_id, v_jenis, '474.0', 'dusun', 'Dusun', 'text', '', true, 'Domisili', 10, NULL),
      (v_tenant_id, v_jenis, '474.0', 'rt_rw', 'RT / RW', 'text', '', true, 'Domisili', 11, NULL),
      (v_tenant_id, v_jenis, '474.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 474.6
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.6' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.6', 'jenis_hilang', 'Jenis Dokumen/Benda yang Hilang', 'text', '', true, 'Kehilangan', 1, NULL),
      (v_tenant_id, v_jenis, '474.6', 'nama_barang', 'Nama/Merk Barang', 'text', '', true, 'Kehilangan', 2, NULL),
      (v_tenant_id, v_jenis, '474.6', 'tanggal_hilang', 'Tanggal Hilang', 'date', '', true, 'Kehilangan', 10, NULL),
      (v_tenant_id, v_jenis, '474.6', 'tempat_hilang', 'Tempat Hilang', 'textarea', '', true, 'Kehilangan', 11, NULL),
      (v_tenant_id, v_jenis, '474.6', 'penjelasan', 'Penjelasan Kejadian', 'textarea', '', true, 'Kehilangan', 12, NULL),
      (v_tenant_id, v_jenis, '474.6', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 474.7
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.7' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.7', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Identitas', 1, NULL),
      (v_tenant_id, v_jenis, '474.7', 'nik', 'NIK', 'text', '', true, 'Identitas', 2, NULL),
      (v_tenant_id, v_jenis, '474.7', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '474.7', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
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

  -- 475.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.0', 'alamat_asal', 'Alamat Asal', 'textarea', '', true, 'Asal', 1, NULL),
      (v_tenant_id, v_jenis, '475.0', 'alamat_tujuan', 'Alamat Tujuan', 'textarea', '', true, 'Tujuan', 10, NULL),
      (v_tenant_id, v_jenis, '475.0', 'alasan', 'Alasan Pindah', 'textarea', '', true, 'Alasan', 20, NULL),
      (v_tenant_id, v_jenis, '475.0', 'jumlah_anggota', 'Jumlah Anggota Keluarga yang Ikut', 'number', '', true, 'Keluarga', 30, NULL),
      (v_tenant_id, v_jenis, '475.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 40, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 477.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.0', 'nama_calon', 'Nama Lengkap', 'text', '', true, 'Calon Mempelai', 1, NULL),
      (v_tenant_id, v_jenis, '477.0', 'ttl_calon', 'Tempat & Tanggal Lahir', 'text', '', true, 'Calon Mempelai', 2, NULL),
      (v_tenant_id, v_jenis, '477.0', 'nik_calon', 'NIK', 'text', '', true, 'Calon Mempelai', 3, NULL),
      (v_tenant_id, v_jenis, '477.0', 'alamat_calon', 'Alamat Lengkap', 'textarea', '', true, 'Calon Mempelai', 10, NULL),
      (v_tenant_id, v_jenis, '477.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 477.3
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.3', 'nama_bayi', 'Nama Bayi', 'text', '', true, 'Bayi', 1, NULL),
      (v_tenant_id, v_jenis, '477.3', 'jenis_kelamin', 'Jenis Kelamin', 'select', '', true, 'Bayi', 2, NULL),
      (v_tenant_id, v_jenis, '477.3', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Bayi', 3, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ayah', 'Nama Ayah', 'text', '', true, 'Orang Tua', 10, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ayah', 'NIK Ayah', 'text', '', true, 'Orang Tua', 11, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nama_ibu', 'Nama Ibu', 'text', '', true, 'Orang Tua', 12, NULL),
      (v_tenant_id, v_jenis, '477.3', 'nik_ibu', 'NIK Ibu', 'text', '', true, 'Orang Tua', 13, NULL),
      (v_tenant_id, v_jenis, '477.3', 'alamat', 'Alamat Keluarga', 'textarea', '', true, 'Alamat', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 477.4
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.4', 'nama_meninggal', 'Nama Lengkap yang Meninggal', 'text', '', true, 'Meninggal', 1, NULL),
      (v_tenant_id, v_jenis, '477.4', 'nik_meninggal', 'NIK', 'text', '', true, 'Meninggal', 2, NULL),
      (v_tenant_id, v_jenis, '477.4', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Meninggal', 3, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tanggal_wafat', 'Tanggal Wafat', 'date', '', true, 'Meninggal', 10, NULL),
      (v_tenant_id, v_jenis, '477.4', 'tempat_wafat', 'Tempat Wafat', 'textarea', '', true, 'Meninggal', 11, NULL),
      (v_tenant_id, v_jenis, '477.4', 'penyebab', 'Penyebab Kematian', 'text', '', false, 'Meninggal', 12, NULL),
      (v_tenant_id, v_jenis, '477.4', 'nama_pelapor', 'Nama Pelapor', 'text', '', true, 'Pelapor', 20, NULL),
      (v_tenant_id, v_jenis, '477.4', 'nik_pelapor', 'NIK Pelapor', 'text', '', true, 'Pelapor', 21, NULL),
      (v_tenant_id, v_jenis, '477.4', 'hubungan', 'Hubungan dengan yang Meninggal', 'text', '', true, 'Pelapor', 22, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 510.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '510.0', 'nama_usaha', 'Nama Usaha', 'text', '', true, 'Usaha', 1, NULL),
      (v_tenant_id, v_jenis, '510.0', 'jenis_usaha', 'Jenis/Bidang Usaha', 'text', '', true, 'Usaha', 2, NULL),
      (v_tenant_id, v_jenis, '510.0', 'alamat_usaha', 'Alamat Tempat Usaha', 'textarea', '', true, 'Usaha', 10, NULL),
      (v_tenant_id, v_jenis, '510.0', 'modal', 'Perkiraan Modal (Rp)', 'number', '', true, 'Ekonomi', 20, NULL),
      (v_tenant_id, v_jenis, '510.0', 'omset', 'Perkiraan Omset/Bulan (Rp)', 'number', '', false, 'Ekonomi', 21, NULL),
      (v_tenant_id, v_jenis, '510.0', 'tenaga_kerja', 'Jumlah Tenaga Kerja', 'number', '', true, 'Ekonomi', 22, NULL),
      (v_tenant_id, v_jenis, '510.0', 'tahun_mulai', 'Tahun Mulai Usaha', 'text', '', true, 'Usaha', 30, NULL),
      (v_tenant_id, v_jenis, '510.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 40, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 650.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '650.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '650.0', 'nama_pemilik', 'Nama Pemilik', 'text', '', true, 'Pemilik', 1, NULL),
      (v_tenant_id, v_jenis, '650.0', 'nik_pemilik', 'NIK Pemilik', 'text', '', true, 'Pemilik', 2, NULL),
      (v_tenant_id, v_jenis, '650.0', 'alamat_tanah', 'Alamat/Lokasi Tanah', 'textarea', '', true, 'Tanah', 10, NULL),
      (v_tenant_id, v_jenis, '650.0', 'luas_tanah', 'Luas Tanah (m2)', 'number', '', true, 'Tanah', 11, NULL),
      (v_tenant_id, v_jenis, '650.0', 'status_hak', 'Status Hak Milik', 'text', '', true, 'Tanah', 12, NULL),
      (v_tenant_id, v_jenis, '650.0', 'no_sertifikat', 'No. Sertifikat (jika ada)', 'text', '', false, 'Tanah', 13, NULL),
      (v_tenant_id, v_jenis, '650.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 650.1
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '650.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '650.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 1, NULL),
      (v_tenant_id, v_jenis, '650.1', 'alamat_domisili', 'Alamat Domisili', 'textarea', '', true, 'Domisili', 10, NULL),
      (v_tenant_id, v_jenis, '650.1', 'jumlah_keluarga', 'Jumlah Anggota Keluarga', 'number', '', true, 'Keluarga', 20, NULL)
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

  -- 300.0
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '300.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 1, NULL),
      (v_tenant_id, v_jenis, '300.0', 'alamat_tinggal', 'Alamat Tempat Tinggal', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '300.0', 'dusun', 'Dusun', 'text', '', true, 'Alamat', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- 441.1
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '441.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '441.1', 'nama', 'Nama Lengkap', 'text', '', true, 'Identitas', 1, NULL),
      (v_tenant_id, v_jenis, '441.1', 'nik', 'NIK', 'text', '', true, 'Identitas', 2, NULL),
      (v_tenant_id, v_jenis, '441.1', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Identitas', 3, NULL),
      (v_tenant_id, v_jenis, '441.1', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '441.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
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

  -- 30.3: Hibah Tanah
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.3', 'nama_wakif', 'Nama Wakif (yang mewakafkan)', 'text', '', true, 'Wakif', 1, NULL),
      (v_tenant_id, v_jenis, '30.3', 'nik_wakif', 'NIK Wakif', 'text', '', true, 'Wakif', 2, NULL),
      (v_tenant_id, v_jenis, '30.3', 'alamat_wakif', 'Alamat Lengkap Wakif', 'textarea', '', true, 'Wakif', 3, NULL),
      (v_tenant_id, v_jenis, '30.3', 'lokasi_tanah', 'Lokasi Tanah yang Diwakafkan', 'textarea', '', true, 'Tanah', 10, NULL),
      (v_tenant_id, v_jenis, '30.3', 'luas_tanah', 'Luas Tanah (m2)', 'number', '', true, 'Tanah', 11, NULL),
      (v_tenant_id, v_jenis, '30.3', 'no_sertifikat', 'No. Sertifikat/Letter C', 'text', '', false, 'Tanah', 12, NULL),
      (v_tenant_id, v_jenis, '30.3', 'nama_mauquf', 'Nama Mauquf Alaih (penerima Wakaf)', 'text', '', true, 'Mauquf', 20, NULL),
      (v_tenant_id, v_jenis, '30.3', 'alamat_mauquf', 'Alamat Mauquf', 'textarea', '', true, 'Mauquf', 21, NULL),
      (v_tenant_id, v_jenis, '30.3', 'nama_nazhir', 'Nama Nazhir / Pengelola', 'text', '', true, 'Nazhir', 30, NULL),
      (v_tenant_id, v_jenis, '30.3', 'keperluan', 'Keperluan / Tujuan Wakaf', 'textarea', '', true, 'Keperluan', 40, NULL),
      (v_tenant_id, v_jenis, '30.3', 'tanggal_akta', 'Tanggal Akta / Pernyataan', 'date', '', false, 'Dokumen', 50, NULL),
      (v_tenant_id, v_jenis, '30.3', 'no_akta', 'No. Akta / Surat Pernyataan', 'text', '', false, 'Dokumen', 51, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- Add options for select fields
  UPDATE public.surat_jenis_dna SET options = '["Milik Sendiri","Sewa/Kontrak","Menumpang","Numpang","Lainnya"]'::jsonb
    WHERE kode_surat = '465.0' AND field_name = 'status_rumah';
  UPDATE public.surat_jenis_dna SET options = '["Laki-laki","Perempuan"]'::jsonb
    WHERE kode_surat = '477.3' AND field_name = 'jenis_kelamin';

  RAISE NOTICE 'DNA batch4 (missing types) seeded!';
END $$;

SELECT kode_surat, count(*) as field_count FROM public.surat_jenis_dna GROUP BY kode_surat ORDER BY kode_surat;