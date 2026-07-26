-- ============================================================
-- SEED DNA FIELDS - Sisa jenis surat
-- Tanggal: 2026-08-05
-- ============================================================

DO $$
DECLARE v_tenant_id UUID; v_jenis UUID;
BEGIN SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

-- 465.1 Penerima Bantuan Sosial
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '465.1', 'nama_bantuan', 'Nama Bantuan', 'text', '', true, 'Bantuan', 1),
         (v_tenant_id, v_jenis, '465.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 465.2 Penghasilan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '465.2', 'penghasilan', 'Penghasilan/Bulan (Rp)', 'number', '0', true, 'Ekonomi', 1),
         (v_tenant_id, v_jenis, '465.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 465.4 Tidak Punya Pekerjaan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.4' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '465.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 465.5 Warga Miskin Ekstrem
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '465.5' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '465.5', 'kriteria', 'Kriteria Miskin', 'textarea', '', true, 'Ekonomi', 1),
         (v_tenant_id, v_jenis, '465.5', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 463.0 Orang Terlantar
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '463.0', 'alamat', 'Alamat', 'textarea', '', true, 'Domisili', 1),
         (v_tenant_id, v_jenis, '463.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 463.1 Lansia
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '463.1', 'tanggal_lahir', 'Tanggal Lahir', 'date', '', true, 'Lansia', 1),
         (v_tenant_id, v_jenis, '463.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 463.2 Yatim Piatu
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '463.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '463.2', 'nama_anak', 'Nama Anak', 'text', '', true, 'Anak', 1),
         (v_tenant_id, v_jenis, '463.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 440.1 Hamil
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '440.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '440.1', 'hpht', 'HPHT', 'date', '', true, 'Kehamilan', 1),
         (v_tenant_id, v_jenis, '440.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 441.0 ODGJ
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '441.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '441.0', 'jenis_gangguan', 'Jenis Gangguan', 'text', '', true, 'Gangguan', 1),
         (v_tenant_id, v_jenis, '441.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 445.0 Rawat Inap
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '445.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '445.0', 'nama_rs', 'Nama RS/Puskesmas', 'text', '', true, 'Rawat', 1),
         (v_tenant_id, v_jenis, '445.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 300.1 Kelakuan Baik
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '300.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 510.3 Izin Reklame
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '510.3' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '510.3', 'nama_reklame', 'Nama Reklame', 'text', '', true, 'Reklame', 1),
         (v_tenant_id, v_jenis, '510.3', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 524.0 Peternak
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '524.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '524.0', 'jenis_ternak', 'Jenis Ternak', 'text', '', true, 'Ternak', 1),
         (v_tenant_id, v_jenis, '524.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 530.0 Pengrajin
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '530.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '530.0', 'jenis_kerajinan', 'Jenis Kerajinan', 'text', '', true, 'Kerajinan', 1),
         (v_tenant_id, v_jenis, '530.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 30.2 Tidak Sengketa Tanah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '30.2', 'lokasi_tanah', 'Lokasi', 'textarea', '', true, 'Tanah', 1),
         (v_tenant_id, v_jenis, '30.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 30.3 Hibah Tanah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.3' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '30.3', 'nama_wakif', 'Nama Wakif', 'text', '', true, 'Wakaf', 1),
         (v_tenant_id, v_jenis, '30.3', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 30.4 Jual Beli Tanah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.4' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '30.4', 'lokasi_tanah', 'Lokasi', 'textarea', '', true, 'Tanah', 1),
         (v_tenant_id, v_jenis, '30.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 650.0 Kepemilikan Rumah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '650.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '650.0', 'alamat_rumah', 'Alamat', 'textarea', '', true, 'Rumah', 1),
         (v_tenant_id, v_jenis, '650.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 650.1 Belum Punya Rumah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '650.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '650.1', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 30.6 Sporadik Tanah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.6' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '30.6', 'lokasi', 'Lokasi', 'textarea', '', true, 'Tanah', 1),
         (v_tenant_id, v_jenis, '30.6', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 420.1 PPDB Zonasi
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '420.1', 'nama_sekolah', 'Nama Sekolah', 'text', '', true, 'PPDB', 1),
         (v_tenant_id, v_jenis, '420.1', 'jarak', 'Jarak ke Sekolah (km)', 'number', '0', true, 'PPDB', 2)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 420.2 Penelitian/KKN
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '420.2', 'institusi', 'Institusi', 'text', '', true, 'Akademik', 1),
         (v_tenant_id, v_jenis, '420.2', 'jenis_kegiatan', 'Jenis', 'text', '', true, 'Akademik', 2),
         (v_tenant_id, v_jenis, '420.2', 'tema', 'Tema', 'text', '', true, 'Akademik', 3)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 420.3 Putus Sekolah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.3' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '420.3', 'nama_sekolah', 'Nama Sekolah', 'text', '', true, 'Pendidikan', 1),
         (v_tenant_id, v_jenis, '420.3', 'alasan', 'Alasan', 'textarea', '', true, 'Pendidikan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 420.4 Sanggar/Kursus
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.4' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '420.4', 'nama_lembaga', 'Nama Lembaga', 'text', '', true, 'Lembaga', 1),
         (v_tenant_id, v_jenis, '420.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 420.5 Aktif Sekolah
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '420.5' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '420.5', 'nama_sekolah', 'Nama Sekolah', 'text', '', true, 'Pendidikan', 1),
         (v_tenant_id, v_jenis, '420.5', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 360.0 Dampak Bencana
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '360.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '360.0', 'jenis_bencana', 'Jenis Bencana', 'text', '', true, 'Bencana', 1),
         (v_tenant_id, v_jenis, '360.0', 'lokasi', 'Lokasi', 'textarea', '', true, 'Bencana', 10),
         (v_tenant_id, v_jenis, '360.0', 'kerugian', 'Perkiraan Kerugian', 'textarea', '', false, 'Bencana', 20)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 520.1 Izin Penebangan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.1' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '520.1', 'lokasi', 'Lokasi Penebangan', 'textarea', '', true, 'Penebangan', 1),
         (v_tenant_id, v_jenis, '520.1', 'jumlah_pohon', 'Jumlah Pohon', 'number', '0', true, 'Penebangan', 2)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 520.2 Penggunaan Lahan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '520.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '520.2', 'lokasi', 'Lokasi', 'textarea', '', true, 'Lahan', 1),
         (v_tenant_id, v_jenis, '520.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 620.0 Penggunaan Air
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '620.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '620.0', 'lokasi', 'Lokasi', 'textarea', '', true, 'Air', 1),
         (v_tenant_id, v_jenis, '620.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 140.2 Permohonan Bantuan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.2' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '140.2', 'instansi', 'Instansi Tujuan', 'text', '', true, 'Bantuan', 1),
         (v_tenant_id, v_jenis, '140.2', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 140.3 Rekomendasi
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.3' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '140.3', 'ditujukan', 'Ditujukan Kepada', 'text', '', true, 'Rekomendasi', 1),
         (v_tenant_id, v_jenis, '140.3', 'hal', 'Hal', 'textarea', '', true, 'Rekomendasi', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 30.8 Pernyataan Tidak Sengketa
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '30.8' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '30.8', 'objek', 'Objek', 'textarea', '', true, 'Sengketa', 1),
         (v_tenant_id, v_jenis, '30.8', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 140.4 MoU/PKS
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '140.4' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '140.4', 'mitra', 'Mitra', 'text', '', true, 'Kerja', 1),
         (v_tenant_id, v_jenis, '140.4', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 180.0 Surat Kuasa
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '180.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '180.0', 'pemberi_kuasa', 'Pemberi Kuasa', 'text', '', true, 'Kuasa', 1),
         (v_tenant_id, v_jenis, '180.0', 'penerima_kuasa', 'Penerima Kuasa', 'text', '', true, 'Kuasa', 2),
         (v_tenant_id, v_jenis, '180.0', 'hal', 'Hal', 'textarea', '', true, 'Kuasa', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 220.0 Keaktifan Organisasi
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '220.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '220.0', 'nama_organisasi', 'Nama Organisasi', 'text', '', true, 'Organisasi', 1),
         (v_tenant_id, v_jenis, '220.0', 'jabatan', 'Jabatan', 'text', '', true, 'Organisasi', 2)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 900.0 Bebas PBB
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '900.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '900.0', 'nop', 'NOP', 'text', '', true, 'PBB', 1),
         (v_tenant_id, v_jenis, '900.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 880.0 Pensiun
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '880.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '880.0', 'instansi', 'Instansi Terakhir', 'text', '', true, 'Pensiun', 1),
         (v_tenant_id, v_jenis, '880.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

-- 471.0 WNI Keturunan
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '471.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '471.0', 'kebangsaan', 'Kebangsaan', 'text', '', true, 'Identitas', 1),
         (v_tenant_id, v_jenis, '471.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

END $$;
