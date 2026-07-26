-- ============================================================
-- MIGRATION: 20260802000004_surat_dna_final.sql
-- Tanggal: 2026-08-02
-- Deskripsi:
--   DNA Fields untuk surat-surat final
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

  -- A. SURAT KETERANGAN PENGGUNAAN LAHAN (520.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '520.2', 'lokasi', 'Lokasi Lahan', 'textarea', '', true, 'Lahan', 1, NULL),
      (v_tenant_id, v_jenis, '520.2', 'luas', 'Luas (m2)', 'number', '', true, 'Lahan', 2, NULL),
      (v_tenant_id, v_jenis, '520.2', 'peruntukan', 'Peruntukan', 'text', '', true, 'Lahan', 10, NULL),
      (v_tenant_id, v_jenis, '520.2', 'status_penguasaan', 'Status Penguasaan', 'select', '', true, 'Lahan', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Milik Sendiri","Sewa","Garapan","Bengkok"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status_penguasaan';
  END IF;

  -- B. SURAT KETERANGAN KELOMPOK TANI (520.3)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '520.3', 'nama_kelompok', 'Nama Kelompok', 'text', '', true, 'Kelompok', 1, NULL),
      (v_tenant_id, v_jenis, '520.3', 'jenis_kelompok', 'Jenis Kelompok', 'select', '', true, 'Kelompok', 2, NULL),
      (v_tenant_id, v_jenis, '520.3', 'nama_ketua', 'Nama Ketua', 'text', '', true, 'Kelompok', 10, NULL),
      (v_tenant_id, v_jenis, '520.3', 'jumlah_anggota', 'Jumlah Anggota', 'number', '', true, 'Kelompok', 11, NULL),
      (v_tenant_id, v_jenis, '520.3', 'no_hp', 'No. HP Ketua', 'text', '', true, 'Kelompok', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Tani","Nelayan","Gabungan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_kelompok';
  END IF;

  -- C. SURAT IZIN PENEBANGAN POHON (520.1)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '520.1', 'jenis_pohon', 'Jenis Pohon', 'text', '', true, 'Pohon', 1, NULL),
      (v_tenant_id, v_jenis, '520.1', 'jumlah', 'Jumlah Pohon', 'number', '', true, 'Pohon', 2, NULL),
      (v_tenant_id, v_jenis, '520.1', 'diameter', 'Diameter (cm)', 'number', '', true, 'Pohon', 10, NULL),
      (v_tenant_id, v_jenis, '520.1', 'lokasi', 'Lokasi Penebangan', 'textarea', '', true, 'Pohon', 11, NULL),
      (v_tenant_id, v_jenis, '520.1', 'alasan', 'Alasan Penebangan', 'textarea', '', true, 'Pohon', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- D. SURAT KETERANGAN PENGGUNAAN AIR/IRIGASI (620.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '620.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '620.0', 'sumber_air', 'Sumber Air', 'text', '', true, 'Air', 1, NULL),
      (v_tenant_id, v_jenis, '620.0', 'nama_saluran', 'Nama Saluran/Bendungan', 'text', '', true, 'Air', 2, NULL),
      (v_tenant_id, v_jenis, '620.0', 'luas_lahan', 'Luas Lahan Diairi (m2)', 'number', '', true, 'Air', 10, NULL),
      (v_tenant_id, v_jenis, '620.0', 'lokasi', 'Lokasi', 'textarea', '', true, 'Air', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- E. SURAT KETERANGAN DAMPAK BENCANA (360.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '360.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '360.0', 'jenis_bencana', 'Jenis Bencana', 'text', '', true, 'Bencana', 1, NULL),
      (v_tenant_id, v_jenis, '360.0', 'tanggal_kejadian', 'Tanggal Kejadian', 'date', '', true, 'Bencana', 2, NULL),
      (v_tenant_id, v_jenis, '360.0', 'lokasi', 'Lokasi', 'textarea', '', true, 'Bencana', 10, NULL),
      (v_tenant_id, v_jenis, '360.0', 'dampak_jiwa', 'Dampak Jiwa', 'textarea', '', true, 'Bencana', 11, NULL),
      (v_tenant_id, v_jenis, '360.0', 'dampak_harta', 'Kerugian Harta/Bangunan', 'textarea', '', true, 'Bencana', 12, NULL),
      (v_tenant_id, v_jenis, '360.0', 'kerugian_rp', 'Perkiraan Kerugian (Rp)', 'number', '', true, 'Bencana', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- F. SURAT KETERANGAN PENYANDANG DISABILITAS (461.0)
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

  -- G. SURAT KETERANGAN ORANG TERLANTAR (463.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.0', 'nama', 'Nama (jika diketahui)', 'text', '', false, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '463.0', 'perkiraan_usia', 'Perkiraan Usia', 'text', '', true, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '463.0', 'jenis_kelamin', 'Jenis Kelamin', 'select', '', true, 'Data', 3, NULL),
      (v_tenant_id, v_jenis, '463.0', 'ciri_fisik', 'Ciri Fisik', 'textarea', '', true, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '463.0', 'lokasi_ditemukan', 'Lokasi Ditemukan', 'textarea', '', true, 'Data', 11, NULL),
      (v_tenant_id, v_jenis, '463.0', 'tanggal_ditemukan', 'Tanggal Ditemukan', 'date', '', true, 'Data', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Laki-laki","Perempuan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_kelamin';
  END IF;

  -- H. SURAT KETERANGAN RAWAT INAP/RUJUKAN (445.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '445.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '445.0', 'no_kartu_bpjs', 'No. Kartu BPJS', 'text', '', true, 'BPJS', 1, NULL),
      (v_tenant_id, v_jenis, '445.0', 'jenis_layanan', 'Jenis Layanan', 'select', '', true, 'BPJS', 2, NULL),
      (v_tenant_id, v_jenis, '445.0', 'keluhan', 'Keluhan/Diagnosa', 'textarea', '', true, 'BPJS', 10, NULL),
      (v_tenant_id, v_jenis, '445.0', 'rs_tujuan', 'RS/Faskes Tujuan', 'text', '', true, 'BPJS', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Rawat Inap","Rawat Jalan","UGD","Kendala"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_layanan';
  END IF;

  -- I. SURAT KETERANGAN LANSIA (463.1)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.1', 'usia', 'Usia', 'text', '', true, 'Lansia', 1, NULL),
      (v_tenant_id, v_jenis, '463.1', 'kondisi_kesehatan', 'Kondisi Kesehatan Umum', 'textarea', '', true, 'Lansia', 10, NULL),
      (v_tenant_id, v_jenis, '463.1', 'penyakit_kronis', 'Penyakit Kronis (jika ada)', 'text', '', false, 'Lansia', 11, NULL),
      (v_tenant_id, v_jenis, '463.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Lansia', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- J. SURAT KETERANGAN ANAK YATIM/PIATU (463.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '463.2', 'status', 'Status', 'select', '', true, 'Anak', 1, NULL),
      (v_tenant_id, v_jenis, '463.2', 'nama_ortu', 'Nama Orang Tua Meninggal', 'text', '', true, 'Anak', 10, NULL),
      (v_tenant_id, v_jenis, '463.2', 'tanggal_meninggal', 'Tanggal Meninggal', 'date', '', true, 'Anak', 11, NULL),
      (v_tenant_id, v_jenis, '463.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Anak', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Yatim","Piatu","Yatim Piatu"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'status';
  END IF;

  -- K. SURAT KETERANGAN IBU HAMIL/MELAHIRKAN (440.1)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '440.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '440.1', 'nik_suami', 'NIK Suami', 'text', '', true, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '440.1', 'kondisi', 'Kondisi', 'select', '', true, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '440.1', 'usia_kehamilan', 'Usia Kehamilan (minggu)', 'number', '', false, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '440.1', 'no_kia', 'No. KIA (jika ada)', 'text', '', false, 'Data', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Hamil","Melahirkan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'kondisi';
  END IF;

  -- L. SURAT KETERANGAN GANGGUAN JIWA (ODGJ) (441.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '441.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '441.0', 'jenis_gangguan', 'Jenis Gangguan', 'text', '', true, 'ODGJ', 1, NULL),
      (v_tenant_id, v_jenis, '441.0', 'sejak_tahun', 'Sejak Tahun', 'text', '', true, 'ODGJ', 2, NULL),
      (v_tenant_id, v_jenis, '441.0', 'status_penanganan', 'Status Penanganan', 'textarea', '', true, 'ODGJ', 10, NULL),
      (v_tenant_id, v_jenis, '441.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'ODGJ', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- M. SURAT UNDANGAN RAPAT (80.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '80.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '80.0', 'agenda', 'Agenda Rapat', 'textarea', '', true, 'Rapat', 1, NULL),
      (v_tenant_id, v_jenis, '80.0', 'tanggal', 'Tanggal', 'date', '', true, 'Rapat', 10, NULL),
      (v_tenant_id, v_jenis, '80.0', 'hari', 'Hari', 'text', '', true, 'Rapat', 11, NULL),
      (v_tenant_id, v_jenis, '80.0', 'jam', 'Jam', 'text', '', true, 'Rapat', 12, NULL),
      (v_tenant_id, v_jenis, '80.0', 'tempat', 'Tempat', 'text', '', true, 'Rapat', 13, NULL),
      (v_tenant_id, v_jenis, '80.0', 'peserta', 'Peserta', 'textarea', '', true, 'Rapat', 14, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- N. SURAT TUGAS PERANGKAT DESA (90.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '90.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '90.0', 'rincian_tugas', 'Rincian Tugas', 'textarea', '', true, 'Tugas', 1, NULL),
      (v_tenant_id, v_jenis, '90.0', 'lokasi', 'Lokasi', 'textarea', '', true, 'Tugas', 10, NULL),
      (v_tenant_id, v_jenis, '90.0', 'tanggal_mulai', 'Tanggal Mulai', 'date', '', true, 'Tugas', 11, NULL),
      (v_tenant_id, v_jenis, '90.0', 'tanggal_selesai', 'Tanggal Selesai', 'date', '', true, 'Tugas', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- O. SURAT IZIN CUTI (890.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '890.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '890.0', 'jenis_cuti', 'Jenis Cuti', 'select', '', true, 'Cuti', 1, NULL),
      (v_tenant_id, v_jenis, '890.0', 'tanggal_mulai', 'Tanggal Mulai', 'date', '', true, 'Cuti', 10, NULL),
      (v_tenant_id, v_jenis, '890.0', 'tanggal_selesai', 'Tanggal Selesai', 'date', '', true, 'Cuti', 11, NULL),
      (v_tenant_id, v_jenis, '890.0', 'alasan', 'Alasan Cuti', 'textarea', '', true, 'Cuti', 12, NULL),
      (v_tenant_id, v_jenis, '890.0', 'plt', 'Pelaksana Tugas (jika ada)', 'text', '', false, 'Cuti', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Cuti Tahunan","Cuti Sakit","Cuti Besar","Cuti Diluar Tanggungan"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_cuti';
  END IF;

  -- P. SURAT KEPUTUSAN KADES (SK) (141.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '141.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '141.0', 'no_sk', 'No. SK', 'text', '', true, 'SK', 1, NULL),
      (v_tenant_id, v_jenis, '141.0', 'perihal', 'Perihal', 'textarea', '', true, 'SK', 10, NULL),
      (v_tenant_id, v_jenis, '141.0', 'pihak_ditetapkan', 'Pihak yang Ditetapkan', 'textarea', '', true, 'SK', 11, NULL),
      (v_tenant_id, v_jenis, '141.0', 'jabatan', 'Jabatan', 'text', '', true, 'SK', 12, NULL),
      (v_tenant_id, v_jenis, '141.0', 'tanggal_berlaku', 'Tanggal Berlaku', 'date', '', true, 'SK', 13, NULL),
      (v_tenant_id, v_jenis, '141.0', 'tanggal_berakhir', 'Tanggal Berakhir (jika ada)', 'date', '', false, 'SK', 14, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- Q. SURAT PERMOHONAN BANTUAN (140.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.2', 'ditujukan', 'Ditujukan Kepada', 'text', '', true, 'Bantuan', 1, NULL),
      (v_tenant_id, v_jenis, '140.2', 'jenis_bantuan', 'Jenis Bantuan', 'text', '', true, 'Bantuan', 10, NULL),
      (v_tenant_id, v_jenis, '140.2', 'uraian', 'Uraian Kebutuhan', 'textarea', '', true, 'Bantuan', 11, NULL),
      (v_tenant_id, v_jenis, '140.2', 'tujuan_manfaat', 'Tujuan/Manfaat', 'textarea', '', true, 'Bantuan', 12, NULL),
      (v_tenant_id, v_jenis, '140.2', 'jumlah_warga', 'Jumlah Warga Terdampak', 'number', '', true, 'Bantuan', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  RAISE NOTICE 'DNA fields final (batch 1) seeded!';
END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT kode_surat, count(*) as field_count
FROM public.surat_jenis_dna
GROUP BY kode_surat
ORDER BY kode_surat;
