-- Migration: 20260802000006_surat_dna_final3.sql
-- DNA Fields untuk surat final batch 3

DO $$
DECLARE
  v_tenant_id UUID;
  v_jenis UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  -- SURAT KETERANGAN AKTIF SEKOLAH/PIP/KPS (420.5)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.5' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.5', 'nama_sekolah', 'Nama Sekolah', 'text', '', true, 'Sekolah', 1, NULL),
      (v_tenant_id, v_jenis, '420.5', 'kelas', 'Kelas', 'text', '', true, 'Sekolah', 2, NULL),
      (v_tenant_id, v_jenis, '420.5', 'nisn', 'NISN', 'text', '', false, 'Sekolah', 3, NULL),
      (v_tenant_id, v_jenis, '420.5', 'tahun_ajaran', 'Tahun Ajaran', 'text', '', true, 'Sekolah', 10, NULL),
      (v_tenant_id, v_jenis, '420.5', 'program', 'Program yang Diikuti', 'select', '', true, 'Sekolah', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["PIP","KPS","Kartu Indonesia Pintar","Kartu Indonesia Sehat"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'program';
  END IF;

  -- SURAT IZIN MENDIRIKAN SANGGAR/KURSUS (420.4)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.4' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '420.4', 'nama_lembaga', 'Nama Lembaga', 'text', '', true, 'Lembaga', 1, NULL),
      (v_tenant_id, v_jenis, '420.4', 'bidang', 'Bidang', 'text', '', true, 'Lembaga', 10, NULL),
      (v_tenant_id, v_jenis, '420.4', 'alamat', 'Alamat', 'textarea', '', true, 'Lembaga', 11, NULL),
      (v_tenant_id, v_jenis, '420.4', 'target_peserta', 'Target Peserta', 'text', '', true, 'Lembaga', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PENGANTAR PEMBUATAN DOKUMEN (474.10)
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

  -- SPTJM (474.12)
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

  -- SURAT KUASA (180.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '180.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '180.0', 'nik_penerima_kuasa', 'NIK Penerima Kuasa', 'text', '', true, 'Kuasa', 1, NULL),
      (v_tenant_id, v_jenis, '180.0', 'nama_penerima', 'Nama Penerima Kuasa', 'text', '', true, 'Kuasa', 2, NULL),
      (v_tenant_id, v_jenis, '180.0', 'hubungan', 'Hubungan dengan Pemberi', 'text', '', true, 'Kuasa', 10, NULL),
      (v_tenant_id, v_jenis, '180.0', 'hal_dikuasakan', 'Hal yang Dikuasakan', 'textarea', '', true, 'Kuasa', 20, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PINDAH AGAMA (474.13)
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

  -- SURAT KETERANGAN WNI KETURUNAN (471.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '471.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '471.0', 'keturunan', 'Keturunan/Etnis', 'text', '', true, 'WNI', 1, NULL),
      (v_tenant_id, v_jenis, '471.0', 'generasi', 'Generasi ke-', 'number', '', true, 'WNI', 2, NULL),
      (v_tenant_id, v_jenis, '471.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'WNI', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT NAIK HAJI/UMRAH (456.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '456.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '456.0', 'jenis_ibadah', 'Jenis Ibadah', 'select', '', true, 'Haji', 1, NULL),
      (v_tenant_id, v_jenis, '456.0', 'tahun_berangkat', 'Tahun Keberangkatan', 'text', '', true, 'Haji', 10, NULL),
      (v_tenant_id, v_jenis, '456.0', 'no_porsi', 'No. Porsi Haji', 'text', '', false, 'Haji', 11, NULL),
      (v_tenant_id, v_jenis, '456.0', 'nama_pendamping', 'Nama Pendamping (jika ada)', 'text', '', false, 'Haji', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
    UPDATE public.surat_jenis_dna SET options = '["Haji","Umrah"]'::jsonb
    WHERE jenis_surat_id = v_jenis AND field_name = 'jenis_ibadah';
  END IF;

  -- SURAT KETERANGAN UNTUK PASPOR (471.1)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '471.1' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '471.1', 'tujuan', 'Tujuan Pembuatan Paspor', 'text', '', true, 'Paspor', 1, NULL),
      (v_tenant_id, v_jenis, '471.1', 'alamat_domisili', 'Alamat Domisili', 'textarea', '', true, 'Paspor', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN CALON TKI/PMI (471.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '471.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '471.2', 'negara_tujuan', 'Negara Tujuan', 'text', '', true, 'PMI', 1, NULL),
      (v_tenant_id, v_jenis, '471.2', 'jenis_pekerjaan', 'Jenis Pekerjaan', 'text', '', true, 'PMI', 10, NULL),
      (v_tenant_id, v_jenis, '471.2', 'lembaga', 'Lembaga Penempatan', 'text', '', true, 'PMI', 11, NULL),
      (v_tenant_id, v_jenis, '471.2', 'no_pendaftaran', 'No. Pendaftaran', 'text', '', false, 'PMI', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT IZIN PENGGALANGAN DANA (466.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '466.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '466.0', 'nama_organisasi', 'Nama Organisasi', 'text', '', true, 'Galang', 1, NULL),
      (v_tenant_id, v_jenis, '466.0', 'tujuan', 'Tujuan Penggalangan', 'textarea', '', true, 'Galang', 10, NULL),
      (v_tenant_id, v_jenis, '466.0', 'target_dana', 'Target Dana (Rp)', 'number', '', true, 'Galang', 11, NULL),
      (v_tenant_id, v_jenis, '466.0', 'metode', 'Metode Pengumpulan', 'textarea', '', true, 'Galang', 12, NULL),
      (v_tenant_id, v_jenis, '466.0', 'periode', 'Periode', 'text', '', true, 'Galang', 13, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN BEBAS PBB (900.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '900.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '900.0', 'no_sppt', 'No. SPPT PBB', 'text', '', true, 'PBB', 1, NULL),
      (v_tenant_id, v_jenis, '900.0', 'lokasi_objek', 'Lokasi Objek Pajak', 'textarea', '', true, 'PBB', 10, NULL),
      (v_tenant_id, v_jenis, '900.0', 'luas', 'Luas (m2)', 'number', '', true, 'PBB', 11, NULL),
      (v_tenant_id, v_jenis, '900.0', 'bebas_hingga_tahun', 'Bebas PBB Hingga Tahun', 'text', '', true, 'PBB', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN KEAKTIFAN ORGANISASI (220.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '220.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '220.0', 'nama_org', 'Nama Organisasi', 'text', '', true, 'Org', 1, NULL),
      (v_tenant_id, v_jenis, '220.0', 'jenis_org', 'Jenis Organisasi', 'text', '', true, 'Org', 2, NULL),
      (v_tenant_id, v_jenis, '220.0', 'nama_ketua', 'Nama Ketua', 'text', '', true, 'Org', 10, NULL),
      (v_tenant_id, v_jenis, '220.0', 'jumlah_anggota', 'Jumlah Anggota', 'number', '', true, 'Org', 11, NULL),
      (v_tenant_id, v_jenis, '220.0', 'tahun_berdiri', 'Tahun Berdiri', 'text', '', true, 'Org', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN BELUM ADA AKTA LAHIR (477.5)
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

  -- SURAT KETERANGAN UNTUK LAMARAN KERJA (474.14)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.14' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '474.14', 'posisi', 'Posisi/Perusahaan Dilamar', 'text', '', true, 'Kerja', 1, NULL),
      (v_tenant_id, v_jenis, '474.14', 'keperluan', 'Keperluan', 'textarea', '', true, 'Kerja', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN PENSIUN/PURNA TUGAS (880.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '880.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '880.0', 'jabatan_terakhir', 'Jabatan Terakhir', 'text', '', true, 'Pensiun', 1, NULL),
      (v_tenant_id, v_jenis, '880.0', 'instansi', 'Instansi', 'text', '', true, 'Pensiun', 2, NULL),
      (v_tenant_id, v_jenis, '880.0', 'mulai_tugas', 'Mulai Tugas', 'date', '', true, 'Pensiun', 10, NULL),
      (v_tenant_id, v_jenis, '880.0', 'tanggal_pensiun', 'Tanggal Pensiun', 'date', '', true, 'Pensiun', 11, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KETERANGAN PENGRAJIN/SENIMAN (530.0)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '530.0' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '530.0', 'bidang', 'Bidang Kerajinan/Seni', 'text', '', true, 'Seniman', 1, NULL),
      (v_tenant_id, v_jenis, '530.0', 'nama_produk', 'Nama Produk/Hasil Karya', 'textarea', '', true, 'Seniman', 10, NULL),
      (v_tenant_id, v_jenis, '530.0', 'nama_sanggar', 'Nama Sanggar/Studio (jika ada)', 'text', '', false, 'Seniman', 11, NULL),
      (v_tenant_id, v_jenis, '530.0', 'alamat_workshop', 'Alamat Workshop', 'textarea', '', true, 'Seniman', 12, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT PENGANTAR BUAT PASPOR (300.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '300.2', 'tujuan', 'Tujuan', 'text', '', true, 'Paspor', 1, NULL),
      (v_tenant_id, v_jenis, '300.2', 'negara_tujuan', 'Negara Tujuan', 'text', '', true, 'Paspor', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  -- SURAT KUASA (140.2)
  SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.2' LIMIT 1;
  IF v_jenis IS NOT NULL THEN
    INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
    VALUES
      (v_tenant_id, v_jenis, '140.2', 'nik_penerima', 'NIK Penerima Kuasa', 'text', '', true, 'Kuasa', 1, NULL),
      (v_tenant_id, v_jenis, '140.2', 'nama_penerima', 'Nama Penerima Kuasa', 'text', '', true, 'Kuasa', 2, NULL),
      (v_tenant_id, v_jenis, '140.2', 'hal', 'Hal yang Dikuasakan', 'textarea', '', true, 'Kuasa', 10, NULL)
    ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
  END IF;

  RAISE NOTICE 'DNA fields final3 seeded!';
END $$;

SELECT kode_surat, count(*) as field_count FROM public.surat_jenis_dna GROUP BY kode_surat ORDER BY kode_surat;
