-- ============================================================
-- MIGRATION: 20260802000003_surat_dna_lanjutan.sql
-- Tanggal: 2026-08-02
-- Deskripsi:
--   Melengkapi DNA Fields untuk surat lainnya
--   Sumber: Sistem_Surat.md
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found! Run seed first.';
  END IF;

  -- ============================================================
  -- A. SURAT KETERANGAN PENDUDUK / BIODATA (474.4)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- B. SURAT KETERANGAN KK SEMENTARA (474.2)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.2', 'alasan_kk', 'Alasan Pembuatan KK Baru', 'textarea', '', true, 'KK', 1, NULL),
      (v_tenant_id, v_jenis, '474.2', 'no_kk_lama', 'No. KK Lama (jika ada)', 'text', '', false, 'KK', 2, NULL),
      (v_tenant_id, v_jenis, '474.2', 'anggota_kk', 'Daftar Anggota KK Baru', 'textarea', '', true, 'KK', 10, 'Nama - NIK - Hubungan')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- C. SURAT KETERANGAN BUKAN PENDUDUK SETEMPAT (474.1)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.1', 'nik_daerah_lain', 'NIK Daerah Lain', 'text', '', true, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '474.1', 'alamat_ktp', 'Alamat KTP', 'textarea', '', true, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '474.1', 'keterangan_keberadaan', 'Keterangan Keberadaan di Desa', 'textarea', '', true, 'Data', 11, NULL),
      (v_tenant_id, v_jenis, '474.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- D. SURAT KETERANGAN KEPALA KELUARGA (474.5)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.5', 'anggota_keluarga', 'Daftar Anggota Keluarga', 'textarea', '', true, 'Keluarga', 10, 'Nama - NIK - Hubungan')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- E. SURAT KETERANGAN PENDATANG/NUMPANG KK (475.1)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.1', 'nik_pendatang', 'NIK Pendatang', 'text', '', true, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '475.1', 'asal_kota', 'Asal Kota/Kabupaten', 'text', '', true, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '475.1', 'alamat_asal', 'Alamat KTP Asal', 'textarea', '', true, 'Data', 11, NULL),
      (v_tenant_id, v_jenis, '475.1', 'nama_pemilik_rumah', 'Nama Pemilik Rumah Tumpangan', 'text', '', true, 'Data', 12, NULL),
      (v_tenant_id, v_jenis, '475.1', 'hubungan', 'Hubungan dengan Pemilik', 'text', '', true, 'Data', 13, NULL),
      (v_tenant_id, v_jenis, '475.1', 'lama_numpang', 'Lama Menumpang', 'text', '', true, 'Data', 14, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- F. SURAT KETERANGAN ALAMAT SEMENTARA (475.2)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.2', 'alamat_permanen', 'Alamat KTP Permanen', 'textarea', '', true, 'Asal', 1, NULL),
      (v_tenant_id, v_jenis, '475.2', 'alamat_sementara', 'Alamat Sementara', 'textarea', '', true, 'Tujuan', 10, NULL),
      (v_tenant_id, v_jenis, '475.2', 'rt_sementara', 'RT', 'text', '', true, 'Tujuan', 11, NULL),
      (v_tenant_id, v_jenis, '475.2', 'rw_sementara', 'RW', 'text', '', true, 'Tujuan', 12, NULL),
      (v_tenant_id, v_jenis, '475.2', 'sejak_tanggal', 'Sejak Tanggal', 'date', '', true, 'Tujuan', 13, NULL),
      (v_tenant_id, v_jenis, '475.2', 'perkiraan_selesai', 'Perkiraan Selesai', 'date', '', false, 'Tujuan', 14, NULL),
      (v_tenant_id, v_jenis, '475.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- G. SURAT KETERANGAN MUTASI PENDUDUK MASUK (475.3)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.3', 'nik_daerah_asal', 'NIK Daerah Asal', 'text', '', true, 'Asal', 1, NULL),
      (v_tenant_id, v_jenis, '475.3', 'no_kk_asal', 'No. KK Asal', 'text', '', true, 'Asal', 2, NULL),
      (v_tenant_id, v_jenis, '475.3', 'desa_asal', 'Desa/Kec/Kab Asal', 'text', '', true, 'Asal', 3, NULL),
      (v_tenant_id, v_jenis, '475.3', 'no_surat_pindah', 'No. Surat Pindah Asal', 'text', '', true, 'Asal', 4, NULL),
      (v_tenant_id, v_jenis, '475.3', 'tanggal_surat_pindah', 'Tanggal Surat Pindah', 'date', '', true, 'Asal', 5, NULL),
      (v_tenant_id, v_jenis, '475.3', 'anggota_pindah', 'Daftar Anggota Pindah', 'textarea', '', true, 'Mutasi', 10, 'Nama - NIK')
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- H. SURAT KETERANGAN TIDAK BERADA DI DESA (475.5)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '475.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '475.5', 'tanggal_pergi', 'Tanggal Meninggalkan Desa', 'date', '', true, 'Keberangkatan', 1, NULL),
      (v_tenant_id, v_jenis, '475.5', 'perkiraan_kembali', 'Perkiraan Tanggal Kembali', 'date', '', false, 'Keberangkatan', 2, NULL),
      (v_tenant_id, v_jenis, '475.5', 'tujuan_kota', 'Tujuan Kota', 'text', '', true, 'Keberangkatan', 10, NULL),
      (v_tenant_id, v_jenis, '475.5', 'alasan', 'Alasan', 'textarea', '', true, 'Keberangkatan', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- I. SURAT KETERANGAN PENERIMA BANTUAN SOSIAL (465.1)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '465.1', 'jenis_bantuan', 'Jenis Bantuan', 'select', '', true, 'Bantuan', 1, NULL),
      (v_tenant_id, v_jenis, '465.1', 'no_dtks', 'No. DTKS', 'text', '', false, 'Bantuan', 2, NULL),
      (v_tenant_id, v_jenis, '465.1', 'no_kks', 'No. KKS', 'text', '', false, 'Bantuan', 3, NULL),
      (v_tenant_id, v_jenis, '465.1', 'periode', 'Periode', 'text', '', true, 'Bantuan', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["PKH","BPNT","BLT DD","PIP","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_bantuan';
  END IF;

  -- ============================================================
  -- J. SURAT KETERANGAN TIDAK PUNYA PEKERJAAN (465.4)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '465.4', 'status_kerja', 'Status Ketenagakerjaan', 'select', '', true, 'Pekerjaan', 1, NULL),
      (v_tenant_id, v_jenis, '465.4', 'sejak_tanggal', 'Sejak Tidak Bekerja', 'date', '', true, 'Pekerjaan', 10, NULL),
      (v_tenant_id, v_jenis, '465.4', 'alasan', 'Alasan', 'textarea', '', true, 'Pekerjaan', 11, NULL),
      (v_tenant_id, v_jenis, '465.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Menganggur","IRT","Pensiunan","Penyandang Disabilitas"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_kerja';
  END IF;

  -- ============================================================
  -- K. SURAT KETERANGAN WARGA MISKIN EKSTREM (465.5)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '465.5', 'penghasilan_per_hari', 'Penghasilan per Hari (Rp)', 'number', '', true, 'Ekonomi', 1, NULL),
      (v_tenant_id, v_jenis, '465.5', 'jumlah_tanggungan', 'Jumlah Tanggungan', 'number', '', true, 'Ekonomi', 2, NULL),
      (v_tenant_id, v_jenis, '465.5', 'kondisi_tempat_tinggal', 'Kondisi Tempat Tinggal', 'select', '', true, 'Ekonomi', 3, NULL),
      (v_tenant_id, v_jenis, '465.5', 'sumber_data', 'Sumber Data P3KE/DTKS', 'text', '', false, 'Ekonomi', 4, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Menumpang","Kontrak","Milik Sendiri","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'kondisi_tempat_tinggal';
  END IF;

  -- ============================================================
  -- L. SURAT PENGANTAR PENGIRIMAN BANTUAN (465.6)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.6' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '465.6', 'jenis_bantuan', 'Jenis Bantuan', 'text', '', true, 'Bantuan', 1, NULL),
      (v_tenant_id, v_jenis, '465.6', 'jumlah_paket', 'Jumlah Paket', 'number', '', true, 'Bantuan', 2, NULL),
      (v_tenant_id, v_jenis, '465.6', 'nilai_rp', 'Nilai (Rp)', 'number', '', true, 'Bantuan', 3, NULL),
      (v_tenant_id, v_jenis, '465.6', 'sumber_pengirim', 'Sumber/Pengirim', 'text', '', true, 'Bantuan', 4, NULL),
      (v_tenant_id, v_jenis, '465.6', 'nama_penerima', 'Nama Penerima', 'text', '', true, 'Bantuan', 5, NULL),
      (v_tenant_id, v_jenis, '465.6', 'alamat_penerima', 'Alamat Penerima', 'textarea', '', true, 'Bantuan', 6, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- M. SURAT KETERANGAN JAMKESOS/BPJS (440.0)
  -- ============================================================
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

  -- ============================================================
  -- N. SURAT KETERANGAN KELAKUAN BAIK (300.1)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '300.1', 'lama_berdomisili', 'Lama Berdomisili di Desa', 'text', '', true, 'Domisili', 1, NULL),
      (v_tenant_id, v_jenis, '300.1', 'riwayat_kriminal', 'Riwayat Catatan Kriminal', 'textarea', '', true, 'Riwayat', 10, NULL),
      (v_tenant_id, v_jenis, '300.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- O. SURAT KETERANGAN DOMISILI USAHA (510.1)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '510.1', 'bentuk_usaha', 'Bentuk Badan Usaha', 'select', '', true, 'Usaha', 1, NULL),
      (v_tenant_id, v_jenis, '510.1', 'bidang_usaha', 'Bidang Usaha', 'text', '', true, 'Usaha', 10, NULL),
      (v_tenant_id, v_jenis, '510.1', 'alamat_usaha', 'Alamat + RT/RW', 'textarea', '', true, 'Usaha', 11, NULL),
      (v_tenant_id, v_jenis, '510.1', 'no_nib', 'No. NIB (jika ada)', 'text', '', false, 'Usaha', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Perorangan","CV","PT","Koperasi","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'bentuk_usaha';
  END IF;

  -- ============================================================
  -- P. SURAT KETERANGAN PEDAGANG (510.2)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '510.2', 'nama_pasar', 'Nama Pasar', 'text', '', true, 'Pedagang', 1, NULL),
      (v_tenant_id, v_jenis, '510.2', 'no_lapak', 'No. Lapak/Kios', 'text', '', true, 'Pedagang', 2, NULL),
      (v_tenant_id, v_jenis, '510.2', 'komoditas', 'Komoditas Dagang', 'text', '', true, 'Pedagang', 10, NULL),
      (v_tenant_id, v_jenis, '510.2', 'hari_berdagang', 'Hari Berdagang', 'text', '', true, 'Pedagang', 11, NULL),
      (v_tenant_id, v_jenis, '510.2', 'sejak_tanggal', 'Sejak Tanggal', 'date', '', true, 'Pedagang', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- Q. SURAT IZIN REKLAME (510.3)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '510.3', 'nama_usaha', 'Nama Usaha', 'text', '', true, 'Usaha', 1, NULL),
      (v_tenant_id, v_jenis, '510.3', 'teks_reklame', 'Teks Reklame', 'text', '', true, 'Reklame', 10, NULL),
      (v_tenant_id, v_jenis, '510.3', 'jenis_reklame', 'Jenis Reklame', 'select', '', true, 'Reklame', 11, NULL),
      (v_tenant_id, v_jenis, '510.3', 'ukuran', 'Ukuran', 'text', '', true, 'Reklame', 12, NULL),
      (v_tenant_id, v_jenis, '510.3', 'lokasi_pemasangan', 'Lokasi Pemasangan', 'text', '', true, 'Reklame', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;

    UPDATE public.surat_jenis_dna SET options = '["Billboard","Spanduk","Bando","Baliho","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_reklame';
  END IF;

  -- ============================================================
  -- R. SURAT PENGANTAR PEMINJAMAN TEMPAT (30.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.0', 'nama_peminjam', 'Nama Peminjam/Organisasi', 'text', '', true, 'Peminjam', 1, NULL),
      (v_tenant_id, v_jenis, '30.0', 'nama_tempat', 'Nama Tempat', 'text', '', true, 'Peminjam', 10, NULL),
      (v_tenant_id, v_jenis, '30.0', 'tanggal', 'Tanggal', 'date', '', true, 'Peminjam', 11, NULL),
      (v_tenant_id, v_jenis, '30.0', 'jam', 'Jam', 'text', '', true, 'Peminjam', 12, NULL),
      (v_tenant_id, v_jenis, '30.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Peminjam', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- S. SURAT KETERANGAN PETERNAK (524.0)
  -- ============================================================
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '524.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '524.0', 'jenis_ternak', 'Jenis Ternak', 'text', '', true, 'Ternak', 1, NULL),
      (v_tenant_id, v_jenis, '524.0', 'jumlah_ekor', 'Jumlah Ekor', 'number', '', true, 'Ternak', 2, NULL),
      (v_tenant_id, v_jenis, '524.0', 'lokasi_kandang', 'Lokasi Kandang', 'textarea', '', true, 'Ternak', 10, NULL),
      (v_tenant_id, v_jenis, '524.0', 'luas_kandang', 'Luas Kandang (m2)', 'number', '', true, 'Ternak', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- ============================================================
  -- T. SURAT KETERANGAN NELAYAN (523.0)
  -- ============================================================
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

  -- ============================================================
  -- U. SURAT KETERANGAN PETANI (520.0)
  -- ============================================================
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

  RAISE NOTICE 'DNA fields (lanjutan 3) seeded successfully!';
END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '=== Surat DNA Fields Lanjutan ===';
  RAISE NOTICE 'Total surat dengan DNA:';
END $$;

SELECT kode_surat, count(*) as field_count
FROM public.surat_jenis_dna
GROUP BY kode_surat
ORDER BY kode_surat;
