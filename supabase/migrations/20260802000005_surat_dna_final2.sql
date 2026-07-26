-- Migration: 20260802000005_surat_dna_final2.sql
-- DNA Fields untuk surat final batch 2

DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  -- BERITA ACARA SERAH TERIMA (30.7)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.7' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.7', 'tanggal', 'Tanggal', 'date', '', true, 'Acara', 1, NULL),
      (v_tenant_id, v_jenis, '30.7', 'pihak_i', 'Pihak I', 'textarea', '', true, 'Pihak', 10, NULL),
      (v_tenant_id, v_jenis, '30.7', 'pihak_ii', 'Pihak II', 'textarea', '', true, 'Pihak', 11, NULL),
      (v_tenant_id, v_jenis, '30.7', 'nama_barang', 'Nama Barang/Pekerjaan', 'textarea', '', true, 'Acara', 20, NULL),
      (v_tenant_id, v_jenis, '30.7', 'lokasi', 'Lokasi', 'text', '', true, 'Acara', 21, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT REKOMENDASI (140.3)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.3', 'nik_rek', 'NIK yang Direkomendasikan', 'text', '', true, 'Data', 1, NULL),
      (v_tenant_id, v_jenis, '140.3', 'jabatan', 'Jabatan', 'text', '', true, 'Data', 2, NULL),
      (v_tenant_id, v_jenis, '140.3', 'hal', 'Hal', 'textarea', '', true, 'Data', 10, NULL),
      (v_tenant_id, v_jenis, '140.3', 'alasan', 'Alasan', 'textarea', '', true, 'Data', 11, NULL),
      (v_tenant_id, v_jenis, '140.3', 'ditujukan', 'Ditujukan Kepada', 'text', '', true, 'Data', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PERNYATAAN TIDAK ADA SENGKETA (30.8)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.8' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '30.8', 'pihak_i', 'Pihak I', 'textarea', '', true, 'Pihak', 1, NULL),
      (v_tenant_id, v_jenis, '30.8', 'pihak_ii', 'Pihak II', 'textarea', '', true, 'Pihak', 2, NULL),
      (v_tenant_id, v_jenis, '30.8', 'objek', 'Objek yang Dinyatakan', 'textarea', '', true, 'Sengketa', 10, NULL),
      (v_tenant_id, v_jenis, '30.8', 'lokasi_objek', 'Lokasi Objek', 'textarea', '', true, 'Sengketa', 11, NULL),
      (v_tenant_id, v_jenis, '30.8', 'keterangan', 'Keterangan', 'textarea', '', false, 'Sengketa', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- NOTA DINAS (60.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '60.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '60.0', 'no_nota', 'No. Nota Dinas', 'text', '', true, 'Nota', 1, NULL),
      (v_tenant_id, v_jenis, '60.0', 'tanggal', 'Tanggal', 'date', '', true, 'Nota', 2, NULL),
      (v_tenant_id, v_jenis, '60.0', 'dari', 'Dari', 'text', '', true, 'Nota', 10, NULL),
      (v_tenant_id, v_jenis, '60.0', 'kepada', 'Kepada', 'text', '', true, 'Nota', 11, NULL),
      (v_tenant_id, v_jenis, '60.0', 'hal', 'Hal', 'text', '', true, 'Nota', 12, NULL),
      (v_tenant_id, v_jenis, '60.0', 'isi', 'Isi Nota', 'textarea', '', true, 'Nota', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PERJANJIAN KERJASAMA/MoU (140.4)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.4', 'no_pks', 'No. PKS/MoU', 'text', '', true, 'Kerja', 1, NULL),
      (v_tenant_id, v_jenis, '140.4', 'tanggal', 'Tanggal', 'date', '', true, 'Kerja', 2, NULL),
      (v_tenant_id, v_jenis, '140.4', 'mitra', 'Mitra/Pihak II', 'text', '', true, 'Kerja', 10, NULL),
      (v_tenant_id, v_jenis, '140.4', 'ruang_lingkup', 'Ruang Lingkup', 'textarea', '', true, 'Kerja', 11, NULL),
      (v_tenant_id, v_jenis, '140.4', 'hak_kewajiban', 'Hak dan Kewajiban', 'textarea', '', true, 'Kerja', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PERMOHONAN PERBAIKAN JALAN (610.0)
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

  -- LAPORAN PELAKSANAAN KEGIATAN (50.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '50.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '50.0', 'judul_kegiatan', 'Judul Kegiatan', 'text', '', true, 'Kegiatan', 1, NULL),
      (v_tenant_id, v_jenis, '50.0', 'tanggal', 'Tanggal', 'date', '', true, 'Kegiatan', 2, NULL),
      (v_tenant_id, v_jenis, '50.0', 'lokasi', 'Lokasi', 'text', '', true, 'Kegiatan', 10, NULL),
      (v_tenant_id, v_jenis, '50.0', 'peserta', 'Jumlah Peserta', 'number', '', true, 'Kegiatan', 11, NULL),
      (v_tenant_id, v_jenis, '50.0', 'pagu', 'Pagu Dana (Rp)', 'number', '', true, 'Kegiatan', 12, NULL),
      (v_tenant_id, v_jenis, '50.0', 'realisasi', 'Realisasi Dana (Rp)', 'number', '', true, 'Kegiatan', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN BEASISWA (420.0)
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

  -- SURAT KETERANGAN PPDB ZONASI (420.1)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.1', 'jenjang', 'Jenjang yang Dituju', 'select', '', true, 'PPDB', 1, NULL),
      (v_tenant_id, v_jenis, '420.1', 'nama_sekolah', 'Nama Sekolah Tujuan', 'text', '', true, 'PPDB', 10, NULL),
      (v_tenant_id, v_jenis, '420.1', 'jarak_sekolah', 'Jarak ke Sekolah (km)', 'number', '', true, 'PPDB', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["SD","SMP","SMA","SMK"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenjang';
  END IF;

  -- SURAT KETERANGAN PENELITIAN/KKN/PKL (420.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.2', 'nim', 'NIM/NIS', 'text', '', true, 'Akademik', 1, NULL),
      (v_tenant_id, v_jenis, '420.2', 'institusi', 'Asal Institusi', 'text', '', true, 'Akademik', 10, NULL),
      (v_tenant_id, v_jenis, '420.2', 'jenis_kegiatan', 'Jenis Kegiatan', 'select', '', true, 'Akademik', 11, NULL),
      (v_tenant_id, v_jenis, '420.2', 'tema', 'Tema/Topik', 'textarea', '', true, 'Akademik', 12, NULL),
      (v_tenant_id, v_jenis, '420.2', 'tanggal_mulai', 'Tanggal Mulai', 'date', '', true, 'Akademik', 13, NULL),
      (v_tenant_id, v_jenis, '420.2', 'tanggal_selesai', 'Tanggal Selesai', 'date', '', true, 'Akademik', 14, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Penelitian","KKN","PKL","Kerja Praktek"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_kegiatan';
  END IF;

  -- SURAT KETERANGAN PUTUS SEKOLAH (420.3)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.3' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.3', 'jenjang', 'Jenjang Terakhir', 'select', '', true, 'Pendidikan', 1, NULL),
      (v_tenant_id, v_jenis, '420.3', 'nama_sekolah', 'Nama Sekolah', 'text', '', true, 'Pendidikan', 10, NULL),
      (v_tenant_id, v_jenis, '420.3', 'kelas_terakhir', 'Kelas Terakhir', 'text', '', true, 'Pendidikan', 11, NULL),
      (v_tenant_id, v_jenis, '420.3', 'tahun', 'Tahun Putus', 'text', '', true, 'Pendidikan', 12, NULL),
      (v_tenant_id, v_jenis, '420.3', 'alasan', 'Alasan Putus Sekolah', 'textarea', '', true, 'Pendidikan', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["SD","SMP","SMA","SMK","Lainnya"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenjang';
  END IF;

  RAISE NOTICE 'DNA fields final2 seeded!';
END $$;

SELECT kode_surat, count(*) as field_count FROM public.surat_jenis_dna GROUP BY kode_surat ORDER BY kode_surat;
