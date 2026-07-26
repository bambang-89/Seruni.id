-- ============================================================
-- MIGRATION: 20260805000002_fix_surat_dna.sql
-- Tanggal: 2026-08-05
-- Deskripsi:
--   Perbaikan DNA fields untuk surat yang perlu diperbaiki
--   dan penambahan DNA untuk surat yang belum punya
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  RAISE NOTICE '=== FIX SURAT DNA MIGRATION STARTED ===';

  -- ============================================================
  -- 1. TAMBAH DNA UNTUK SURAT YANG BELUM PUNYA
  -- ============================================================

  -- 420.4: Izin Mendirikan Sanggar/Kursus
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.4' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.4', 'nama_lembaga', 'Nama Sanggar/Kursus', 'text', '', true, 'Lembaga', 1, NULL),
      (v_tenant_id, v_jenis, '420.4', 'jenis_kegiatan', 'Jenis Kegiatan', 'text', '', true, 'Lembaga', 2, NULL),
      (v_tenant_id, v_jenis, '420.4', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Lembaga', 10, NULL),
      (v_tenant_id, v_jenis, '420.4', 'dusun', 'Dusun', 'text', '', true, 'Lembaga', 11, NULL),
      (v_tenant_id, v_jenis, '420.4', 'pembina', 'Nama Pembina/Penanggung Jawab', 'text', '', true, 'Penanggung', 20, NULL),
      (v_tenant_id, v_jenis, '420.4', 'jumlah_peserta', 'Perkiraan Jumlah Peserta', 'number', '', true, 'Lembaga', 21, NULL),
      (v_tenant_id, v_jenis, '420.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 420.4';
  END IF;

  -- 440.0: SK Jamkesos/BPJS
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '440.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '440.0', 'jenis_bantuan', 'Jenis Bantuan', 'select', '', true, 'Bantuan', 1, NULL, '["BPJS Kesehatan","BPJS Ketenagakerjaan","Kartu Indonesia Pintar","Kartu Sembako","Bantuan Lansia","Bantuan Disabilitas"]'::jsonb),
      (v_tenant_id, v_jenis, '440.0', 'no_bpjs', 'No. Kartu BPJS', 'text', '', false, 'Bantuan', 2, NULL, NULL),
      (v_tenant_id, v_jenis, '440.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 440.0';
  END IF;

  -- 461.0: SK Penyandang Disabilitas
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '461.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '461.0', 'jenis_disabilitas', 'Jenis Disabilitas', 'select', '', true, 'Disabilitas', 1, NULL, '["Fisik","Netra/Tunanetra","Rungu/Tunarungu","Grahita","Daksa","Wicara","Ganda","Lainnya"]'::jsonb),
      (v_tenant_id, v_jenis, '461.0', 'no_ktp', 'No. KTP', 'text', '', true, 'Disabilitas', 2, NULL, NULL),
      (v_tenant_id, v_jenis, '461.0', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL, NULL),
      (v_tenant_id, v_jenis, '461.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 461.0';
  END IF;

  -- 463.0: SK Orang Terlantar
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.0', 'alamat_terlantar', 'Alamat Saat Ini', 'textarea', '', true, 'Domisili', 1, NULL),
      (v_tenant_id, v_jenis, '463.0', 'kondisi', 'Kondisi Saat Ini', 'textarea', '', true, 'Kondisi', 10, NULL),
      (v_tenant_id, v_jenis, '463.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 463.0';
  END IF;

  -- 520.0: SK Petani
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '520.0', 'jenis_lahan', 'Jenis Lahan', 'select', '', true, 'Lahan', 1, NULL),
      (v_tenant_id, v_jenis, '520.0', 'lokasi', 'Lokasi Lahan', 'textarea', '', true, 'Lahan', 10, NULL),
      (v_tenant_id, v_jenis, '520.0', 'luas_lahan', 'Luas Lahan (m2)', 'number', '', true, 'Lahan', 11, NULL),
      (v_tenant_id, v_jenis, '520.0', 'komoditas', 'Komoditas Utama', 'text', '', true, 'Lahan', 12, NULL),
      (v_tenant_id, v_jenis, '520.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    -- Add options
    UPDATE public.surat_jenis_dna SET options = '["Sawah","Ladang/Tegalan","Kebun","Lahan Kering"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_lahan';
    RAISE NOTICE 'Added DNA for 520.0';
  END IF;

  -- 523.0: SK Nelayan
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '523.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '523.0', 'jenis_nelayan', 'Jenis Nelayan', 'select', '', true, 'Nelayan', 1, NULL),
      (v_tenant_id, v_jenis, '523.0', 'nama_perahu', 'Nama Perahu (jika ada)', 'text', '', false, 'Nelayan', 2, NULL),
      (v_tenant_id, v_jenis, '523.0', 'lokasi_pesisir', 'Lokasi Pesisir', 'text', '', true, 'Nelayan', 10, NULL),
      (v_tenant_id, v_jenis, '523.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Penuh Waktu","Paruh Waktu","Nelayan Utama","Nelayan Sampingan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_nelayan';
    RAISE NOTICE 'Added DNA for 523.0';
  END IF;

  -- 220.0: SK Keaktifan Organisasi
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '220.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '220.0', 'nama_organisasi', 'Nama Organisasi', 'text', '', true, 'Organisasi', 1, NULL),
      (v_tenant_id, v_jenis, '220.0', 'jabatan', 'Jabatan di Organisasi', 'text', '', true, 'Organisasi', 2, NULL),
      (v_tenant_id, v_jenis, '220.0', 'lama_keanggotaan', 'Lama Keanggotaan (tahun)', 'number', '', true, 'Organisasi', 3, NULL),
      (v_tenant_id, v_jenis, '220.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 220.0';
  END IF;

  -- 880.0: SK Pensiun/Purna Tugas
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '880.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '880.0', 'instansi_terakhir', 'Instansi Terakhir', 'text', '', true, 'Pensiun', 1, NULL),
      (v_tenant_id, v_jenis, '880.0', 'tahun_pensiun', 'Tahun Pensiun', 'text', '', true, 'Pensiun', 2, NULL),
      (v_tenant_id, v_jenis, '880.0', 'no_sk_pensiun', 'No. SK Pensiun', 'text', '', false, 'Pensiun', 3, NULL),
      (v_tenant_id, v_jenis, '880.0', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '880.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 880.0';
  END IF;

  -- 463.1: SK Lansia
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.1' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.1', 'tanggal_lahir', 'Tanggal Lahir', 'date', '', true, 'Lansia', 1, NULL),
      (v_tenant_id, v_jenis, '463.1', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '463.1', 'nama_anak', 'Nama Anak/Wali', 'text', '', false, 'Wali', 20, NULL),
      (v_tenant_id, v_jenis, '463.1', 'kontak_wali', 'Kontak Wali', 'text', '', false, 'Wali', 21, NULL),
      (v_tenant_id, v_jenis, '463.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 463.1';
  END IF;

  -- 463.2: SK Anak Yatim/Piatu
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.2' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.2', 'nama_anak', 'Nama Anak', 'text', '', true, 'Anak', 1, NULL),
      (v_tenant_id, v_jenis, '463.2', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Anak', 2, NULL),
      (v_tenant_id, v_jenis, '463.2', 'nik', 'NIK', 'text', '', true, 'Anak', 3, NULL),
      (v_tenant_id, v_jenis, '463.2', 'jenis_yatim', 'Jenis', 'select', '', true, 'Anak', 4, NULL),
      (v_tenant_id, v_jenis, '463.2', 'nama_wali', 'Nama Wali', 'text', '', true, 'Wali', 10, NULL),
      (v_tenant_id, v_jenis, '463.2', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 20, NULL),
      (v_tenant_id, v_jenis, '463.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Yatim","Piatu","Yatim Piatu"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_yatim';
    RAISE NOTICE 'Added DNA for 463.2';
  END IF;

  -- 440.1: SK Hamil/Ibu Melahirkan
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '440.1' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '440.1', 'kehamilan_ke', 'Kehamilan ke-', 'number', '', true, 'Kehamilan', 1, NULL),
      (v_tenant_id, v_jenis, '440.1', 'hari_first', 'Hari Pertama Haid Terakhir (HPHT)', 'date', '', true, 'Kehamilan', 10, NULL),
      (v_tenant_id, v_jenis, '440.1', 'taksiran_lahir', 'Taksiran Persalinan', 'date', '', false, 'Kehamilan', 11, NULL),
      (v_tenant_id, v_jenis, '440.1', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 20, NULL),
      (v_tenant_id, v_jenis, '440.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 440.1';
  END IF;

  -- 441.0: SK Gangguan Jiwa (ODGJ)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '441.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '441.0', 'jenis_gangguan', 'Jenis Gangguan', 'select', '', true, 'Gangguan', 1, NULL),
      (v_tenant_id, v_jenis, '441.0', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '441.0', 'nama_wali', 'Nama Wali/Penanggung Jawab', 'text', '', true, 'Wali', 20, NULL),
      (v_tenant_id, v_jenis, '441.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["ODGJ","ODS","ODGJ dengan Perilaku Kekerasan","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_gangguan';
    RAISE NOTICE 'Added DNA for 441.0';
  END IF;

  -- 445.0: SK Rawat Inap/Rujukan
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '445.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '445.0', 'nama_rs', 'Nama Rumah Sakit/Puskesmas', 'text', '', true, 'Rawat', 1, NULL),
      (v_tenant_id, v_jenis, '445.0', 'jenis_rawat', 'Jenis Rawat', 'select', '', true, 'Rawat', 2, NULL),
      (v_tenant_id, v_jenis, '445.0', 'diagnosa', 'Diagnosa/Penyakit', 'textarea', '', true, 'Rawat', 10, NULL),
      (v_tenant_id, v_jenis, '445.0', 'tanggal_masuk', 'Tanggal Masuk', 'date', '', true, 'Rawat', 11, NULL),
      (v_tenant_id, v_jenis, '445.0', 'tanggal_keluar', 'Estimasi Tanggal Keluar', 'date', '', false, 'Rawat', 12, NULL),
      (v_tenant_id, v_jenis, '445.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Rawat Inap","Rawat Jalan","UGD"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_rawat';
    RAISE NOTICE 'Added DNA for 445.0';
  END IF;

  -- 477.5: SK Belum Ada Akta Lahir
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '477.5' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '477.5', 'nama', 'Nama Lengkap', 'text', '', true, 'Identitas', 1, NULL),
      (v_tenant_id, v_jenis, '477.5', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Identitas', 2, NULL),
      (v_tenant_id, v_jenis, '477.5', 'nik', 'NIK (jika ada)', 'text', '', false, 'Identitas', 3, NULL),
      (v_tenant_id, v_jenis, '477.5', 'nama_ayah', 'Nama Ayah', 'text', '', true, 'Orang Tua', 10, NULL),
      (v_tenant_id, v_jenis, '477.5', 'nama_ibu', 'Nama Ibu', 'text', '', true, 'Orang Tua', 11, NULL),
      (v_tenant_id, v_jenis, '477.5', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 20, NULL),
      (v_tenant_id, v_jenis, '477.5', 'alasan', 'Alasan Belum Punya Akta', 'textarea', '', true, 'Alasan', 30, NULL),
      (v_tenant_id, v_jenis, '477.5', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 40, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 477.5';
  END IF;

  -- 474.13: SK Pindah Agama
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.13' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '474.13', 'agama_asal', 'Agama Asal', 'select', '', true, 'Agama', 1, NULL, '["Islam","Kristen","Katolik","Hindu","Buddha","Konghucu"]'::jsonb),
      (v_tenant_id, v_jenis, '474.13', 'agama_tujuan', 'Agama Tujuan', 'select', '', true, 'Agama', 2, NULL, '["Islam","Kristen","Katolik","Hindu","Buddha","Konghucu"]'::jsonb),
      (v_tenant_id, v_jenis, '474.13', 'keperluan', 'Alasan/Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 474.13';
  END IF;

  -- 471.0: SK WNI Keturunan
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '471.0' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '471.0', 'nama_lengkap', 'Nama Lengkap', 'text', '', true, 'Identitas', 1, NULL),
      (v_tenant_id, v_jenis, '471.0', 'nik', 'NIK', 'text', '', true, 'Identitas', 2, NULL),
      (v_tenant_id, v_jenis, '471.0', 'ttl', 'Tempat & Tanggal Lahir', 'text', '', true, 'Identitas', 3, NULL),
      (v_tenant_id, v_jenis, '471.0', 'kebangsaan', 'Kebangsaan', 'text', '', true, 'Identitas', 4, NULL),
      (v_tenant_id, v_jenis, '471.0', 'alamat', 'Alamat Lengkap', 'textarea', '', true, 'Alamat', 10, NULL),
      (v_tenant_id, v_jenis, '471.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 471.0';
  END IF;

  -- ============================================================
  -- 2. SIMPLIFIKASI DNA YANG TERLALU KOMPLEKS
  -- ============================================================

  -- 474.9: SK Ahli Waris - Simplifikasi
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.9' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    -- Hapus field lama yang kompleks
    DELETE FROM public.surat_jenis_dna WHERE jenis_surat_id = v_jenis;

    -- Insert yang lebih sederhana
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.9', 'nama_pewaris', 'Nama yang Meninggal', 'text', '', true, 'Pewaris', 1, NULL),
      (v_tenant_id, v_jenis, '474.9', 'nik_pewaris', 'NIK yang Meninggal', 'text', '', true, 'Pewaris', 2, NULL),
      (v_tenant_id, v_jenis, '474.9', 'tanggal_meninggal', 'Tanggal Meninggal', 'date', '', true, 'Pewaris', 10, NULL),
      (v_tenant_id, v_jenis, '474.9', 'nama_ahli_waris', 'Nama Ahli Waris', 'text', '', true, 'Ahli Waris', 20, NULL),
      (v_tenant_id, v_jenis, '474.9', 'nik_ahli_waris', 'NIK Ahli Waris', 'text', '', true, 'Ahli Waris', 21, NULL),
      (v_tenant_id, v_jenis, '474.9', 'hubungan', 'Hubungan dengan Pewaris', 'text', '', true, 'Ahli Waris', 22, NULL),
      (v_tenant_id, v_jenis, '474.9', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 30, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Simplified DNA for 474.9';
  END IF;

  -- 474.4: SK Penduduk (Biodata Lengkap)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.4' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    -- Hapus DNA lama
    DELETE FROM public.surat_jenis_dna WHERE jenis_surat_id = v_jenis;

    -- Insert yang lebih sederhana (karena data sudah ada di tabel penduduk)
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Simplified DNA for 474.4';
  END IF;

  -- 474.10: SK Pembuatan Dokumen Kependudukan - Jadikan lebih spesifik
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.10' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    DELETE FROM public.surat_jenis_dna WHERE jenis_surat_id = v_jenis;

    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text, options)
    VALUES
      (v_tenant_id, v_jenis, '474.10', 'jenis_dokumen', 'Jenis Dokumen yang Akan Dibuat', 'select', '', true, 'Dokumen', 1, NULL, '["KTP","KK","Akta Lahir","Akta Kematian","KIA"]'::jsonb),
      (v_tenant_id, v_jenis, '474.10', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Simplified DNA for 474.10';
  END IF;

  -- 474.14: SK untuk Lamaran Kerja
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.14' AND aktif = true LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    DELETE FROM public.surat_jenis_dna WHERE jenis_surat_id = v_jenis;

    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.14', 'perusahaan', 'Nama Perusahaan/Instansi', 'text', '', true, 'Lamaran', 1, NULL),
      (v_tenant_id, v_jenis, '474.14', 'posisi', 'Posisi yang Dilamar', 'text', '', true, 'Lamaran', 2, NULL),
      (v_tenant_id, v_jenis, '474.14', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    RAISE NOTICE 'Added DNA for 474.14';
  END IF;

  RAISE NOTICE '=== FIX SURAT DNA MIGRATION COMPLETED ===';
END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT
  sj.kode_surat,
  sj.nama,
  count(sjd.id) as dna_fields,
  string_agg(sjd.field_name, ', ') as field_list
FROM public.surat_jenis sj
LEFT JOIN public.surat_jenis_dna sjd ON sjd.jenis_surat_id = sj.id
WHERE sj.aktif = true
GROUP BY sj.kode_surat, sj.nama, sj.urutan
HAVING count(sjd.id) > 0
ORDER BY sj.urutan;

-- Count surat aktif dan yang punya DNA
SELECT
  'Surat Aktif' as kategori,
  count(*) as jumlah
FROM public.surat_jenis WHERE aktif = true
UNION ALL
SELECT
  'Surat dengan DNA' as kategori,
  count(DISTINCT sjd.jenis_surat_id) as jumlah
FROM public.surat_jenis_dna sjd
JOIN public.surat_jenis sj ON sj.id = sjd.jenis_surat_id
WHERE sj.aktif = true;
