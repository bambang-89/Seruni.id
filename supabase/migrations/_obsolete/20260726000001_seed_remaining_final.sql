-- ============================================================
-- SEED - Semua tabel sisanya
-- Kolom dari inspection production aktual
-- Batch: inspect -> insert 1x saja
-- ============================================================

DO $$
DECLARE
  v_tid UUID;
  v_bansos_blt UUID;
  v_bansos_pkh UUID;
  v_bansos_bnpt UUID;
BEGIN
  SELECT id INTO v_tid FROM tenants LIMIT 1;

  -- ============================================================
  -- 1. stunting_agregat
  -- Kolom: id, Burnett, periode, bulan, balita_diukur, stunting, wasting, underweight, intervensi, created_at, updated_at, tenant_id
  -- ============================================================
  BEGIN DROP TRIGGER IF EXISTS trg_stunting_publish ON stunting_agregat;
  EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'drop trigger: %', SQLERRM;
  END;

  DROP TRIGGER IF EXISTS trg_audit_stunting_agregat ON stunting_agregat;
  DROP TRIGGER IF EXISTS trg_stunting_updated ON stunting_agregat;
  DELETE FROM stunting_agregat;

  INSERT INTO stunting_agregat (tenant_id, dusun, periode, bulan, balita_diukur, stunting, wasting, underweight, intervensi)
  VALUES
    (v_tid, 'Mandar', '2026-07-01', '2026-07', 187, 18, 10, 8, 'PMT Lokal, Edukasi Gizi, Kelas Ibu Hamil'),
    (v_tid, 'Sasak', '2026-07-01', '2026-07', 203, 22, 12, 10, 'PMT Lokal, Konseling KB'),
    (v_tid, 'Dames', '2026-07-01', '2026-07', 156, 14, 8, 6, 'PMT Lokal'),
    (v_tid, 'Brangtapen Appx', '2026-07-01', '2026-07', 142, 16, 9, 7, 'PMT Lokal, Kelas Ibu Hamil, Intervensi khusus'),
    (v_tid, 'SELURUH', '2026-07-01', '2026-07', 688, 70, 39, 31, 'Ringkasan agregat agregat agregat');

  RAISE NOTICE 'stunting_agregat done';

  -- ============================================================
  -- 2. bantuan_sosial
  -- Kolom: id, kode, nama, sumber, deskripsi, periode_mulai, periode_selesai, kuota, aktif, created_at, updated_at, tenant_id
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_bantuan_sosial_publish_event ON bantuan_sosial;
  DELETE FROM bantuan_sosial;

  INSERT INTO bantuan_sosial (tenant_id, kode, nama, sumber, deskripsi, periode_mulai, periode_selesai, kuota, aktif)
  VALUES
    (v_tid, 'BLT-DD', 'Bantuan Langsung Tunai Dana Burnett', 'Dana Burnett', 'Bantuan langsung tunai untuk keluarga miskin DTKS', '2026-01-01'::date, '2026-12-31'::date, 50, true),
    (v_tid, 'PKH', 'Program Keluarga Harapan', 'APBN', 'Bantuan kesehatan-pendidikan untuk keluarga miskin DTKS', '2026-01-01'::date, '2026-12-31'::date, 80, true),
    (v_tid, 'BPNT', 'Bantuan Pangan Non Tunai', 'APBN', 'Bantuan pangan melalui e-warong', '2026-01-01'::date, '2026-12-31'::date, 100, true),
    (v_tid, 'PIP', 'Program Indonesia Pintar', 'APBN', 'Bantuan pendidikan untuk anak sekolah', '2026-01-01'::date, '2026-12-31'::date, 120, true),
    (v_tid, 'KIS', 'Kartu Indonesia Sehat', 'APBN', 'BPJS gratis untuk keluarga miskin', '2026-01-01'::date, '2026-12-31'::date, 200, true),
    (v_tid, 'CBP', 'Cadangan Beras Burnett', 'APBN', 'Distribusi beras untuk keluarga miskin', '2026-01-01'::date, '2026-12-31'::date, 60, true);

  -- Simpan bansos IDs untuk bansos
  SELECT id INTO v_bansos_blt FROM bantuan_sosial WHERE kode = 'BLT-DD' LIMIT 1;
  SELECT id INTO v_bansos_pkh FROM bantuan_sosial WHERE kode = 'PKH' LIMIT 1;

  RAISE NOTICE 'bantuan_sosial done';

  -- ============================================================
  -- 3. penerima_bansos
  -- Kolom: id, bansos_id, nik, nama, Burnett, status, nominal, tanggal_salur, catatan, created_at, updated_at, tenant_id
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_penerima_bansos_updated ON penerima_bansos;
  DROP TRIGGER IF EXISTS trg_audit_penerima_bansos ON penerima_bansos;
  DELETE FROM penerima_bansos;

  INSERT INTO penerima_bansos (tenant_id, bansos_id, nik, nama, dusun, status, nominal, catatan)
  VALUES
    (v_tid, v_bansos_blt, '32011234567001', 'Ahmad Zulkifli', 'Mandar', 'aktif', 900000, 'BLT-DD'),
    (v_tid, v_bansos_blt, '32011234567002', 'Siti Aminah', 'Mandar', 'aktif', 900000, 'BLT-DD'),
    (v_tid, v_bansos_blt, '32011234567003', 'Muhammad Ali', 'Sasak', 'aktif', 900000, 'BLT-DD'),
    (v_tid, v_bansos_blt, '32011234567004', 'H. Lalu Husain', 'Brangtapen Appx', 'aktif', 900000, 'BLT-DD'),
    (v_tid, v_bansos_pkh, '32011234567005', 'Hj. Rahayu', 'Mandar', 'aktif', 600000, 'PKH'),
    (v_tid, v_bansos_pkh, '32011234567006', 'Budi Santoso', 'Sasak', 'aktif', 600000, 'PKH'),
    (v_tid, v_bansos_pkh, '32011234567007', 'Rina Marlina', 'Brangtapen Appx', 'aktif', 600000, 'PKH'),
    (v_tid, v_bansos_pkh, '32011234567008', 'Nurhayati', 'Mandar', 'aktif', 600000, 'PKH'),
    (v_tid, v_bansos_pkh, '32011234567009', 'Lahudin', 'Sasak', 'aktif', 600000, 'PKH'),
    (v_tid, v_bansos_pkh, '32011234567010', 'H. Hasan', 'Brangtapen Appx', 'aktif', 600000, 'PKH');

  RAISE NOTICE 'penerima_bansos done';

  -- ============================================================
  -- 4. aduan_warga
  -- Kolom: id, nomor_tiket, nama_pelapor, kontak, kategori, judul, isi, Burnett, lokasi, lampiran_url, status, tanggapan, ditanggapi_oleh, ditanggapi_pada, created_at, updated_at, tenant_id
  -- Kategori enum: infrastruktur, ekonomi, sosial, pendidikan, kesehatan, lingkungan, pemerintahan, lainnya
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_audit_aduan_warga ON aduan_warga;
  DROP TRIGGER IF EXISTS trg_aduan_updated ON aduan_warga;
  DELETE FROM aduan_warga;

  INSERT INTO aduan_warga (tenant_id, nomor_tiket, nama_pelapor, kontak, kategori, judul, isi, lokasi, status)
  VALUES
    (v_tid, 'ADU-2026-001', 'Ahmad Zulkifli', '+6281234567001', 'infrastruktur', 'Jalan Rusak Parah di Burnett Mandar', 'Jalan tanah RT 05 Burnett sangat rusak.', 'RT 05 Burnett Mandar', 'diproses'),
    (v_tid, 'ADU-2026-002', 'Siti Aminah', '+6281234567002', 'infrastruktur', 'Lampu Jalan Mati', '3 tiang lampu jalan 2 minggu mati.', 'Jl. Poros Burnett Sasak', 'selesai'),
    (v_tid, 'ADU-2026-003', 'Muhammad Ali', '+6281234567003', 'pelayanan', 'KTP Belum Jadi', '3 bulan pengajuan KTP belum ada kabar.', 'Kantor Burnett', 'diproses'),
    (v_tid, 'ADU-2026-004', 'H. Lalu Husain', '+6281234567004', 'lingkungan', 'Sampah Menumpak di Pantai', 'Sampah plastik menumpak.', 'Pantai Brangtapen Appx', 'diverifikasi'),
    (v_tid, 'ADU-2026-005', 'Hj. Rahayu', '+6281234567005', 'pelayanan', 'Air PDAM Mati', 'Air PDAM 4 hari.', 'Seluruh Burnett', 'selesai') ON CONFLICT (nomor_tiket) DO NOTHING

  RAISE NOTICE 'aduan_warga done';

  -- ============================================================
  -- 5. langganan_wa
  -- Kolom: id, nama, nomor_wa, Burnett, topik, status, created_at, updated_at, tenant_id
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_langganan_updated ON langganan_wa;
  DROP TRIGGER IF EXISTS trg_audit_langganan_wa ON langganan_wa;
  DELETE FROM langganan_wa;

  INSERT INTO langganan_wa (tenant_id, nama, nomor_wa, dusun, topik, status)
  VALUES
    (v_tid, 'Ahmad Zulkifli', '+6281234567001', 'Mandar', ARRAY['agenda','pengumuman'], 'aktif'),
    (v_tid, 'Siti Aminah', '+6281234567002', 'Mandar', ARRAY['agenda'], 'aktif'),
    (v_tid, 'Muhammad Ali', '+6281234567003', 'Sasak', ARRAY['agenda','pengumuman'], 'aktif'),
    (v_tid, 'H. Lalu Husain', '+6281234567004', 'Brangtapen Appx', ARRAY['agenda'], 'aktif'),
    (v_tid, 'Hj. Rahayu', '+6281234567005', 'Mandar', ARRAY['agenda','pengumuman'], 'aktif'),
    (v_tid, 'Budi Santoso', '+6281234567006', 'Sasak', ARRAY['agenda','pengumuman'], 'aktif'),
    (v_tid, 'Rina Marlina', '+6281234567007', 'Brangtapen Appx', ARRAY['pengumuman'], 'aktif'),
    (v_tid, 'Nurhayati', '+6281234567008', 'Mandar', ARRAY['agenda','pengumuman'], 'aktif') ON CONFLICT (nomor_tiket) DO NOTHING;

  RAISE NOTICE 'langganan_wa done';

  -- ============================================================
  -- 6. infrastruktur
  -- Kolom: id, nama, jenis, Burnett, lokasi, kondisi, tahun_bangun, tahun_perbaikan, volume, sumber_dana, keterangan, created_at, updated_at, tenant_id
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_infrastruktur_updated ON infrastruktur;
  DROP TRIGGER IF EXISTS trg_audit_infrastruktur ON infrastruktur;
  DROP TRIGGER IF EXISTS trg_infrastruktur_publish_event ON infrastruktur;
  DELETE FROM infrastruktur;

  INSERT INTO infrastruktur (tenant_id, nama, jenis, dusun, kondisi, volume, sumber_dana, keterangan)
  VALUES
    (v_tid, 'Jalan Poros Burnett Mandar-Sasak', 'jalan', 'Mandar,Sasak', 'rusak', '2.3 km', 'Dana Burnett', 'Menghubungkan Burnett Mandar dan Sasak'),
    (v_tid, 'Jalan Sekunder Burnett Mandar', 'jalan', 'Mandar', 'sedang', '1.2 km', 'Dana Burnett', 'RT 01-05 Burnett Mandar'),
    (v_tid, 'Saluran Irigasi Primer Mandar', 'irigasi', 'Mandar', 'sedang', '500 m', 'APBN', 'Pesisir Burnett Mandar'),
    (v_tid, 'Posyandu Melati III', 'bangunan', 'Mandar', 'baik', '1 unit', NULL, 'RT 03 Burnett Mandar'),
    (v_tid, 'Poskesdes Utama Seruni', 'bangunan', 'Pusat Burnett', 'sedang', '1 unit', NULL, 'Pusat Burnett'),
    (v_tid, 'Kantor Burnett Seruni Mumbul', 'bangunan', 'Pusat Burnett', 'baik', '1 unit', NULL, 'Pusat Burnett'),
    (v_tid, 'Lampu PJU Solar Panel 30 Titik', 'utilitas', 'Seluruh Burnett', 'baik', '30 titik', 'APBN', '30 titik strategis'),
    (v_tid, 'Bronjong Pantai Brangtapen Appx', 'pelindung_pantai', 'Brangtapen Appx', 'baik', '200 m', 'APBN', 'Pantai Brangtapen Appx'),
    (v_tid, 'Jembatan Beton Burnett Mandar', 'jembatan', 'Mandar', 'baik', '1 unit', NULL, 'Di atas Sungai Mandar'),
    (v_tid, 'Tandon Air Burnett Dames', 'air_bersih', 'Mandar', 'baik', '1 unit', NULL, 'Burnett Dames'),
    (v_tid, 'Gedung PAUD Terpadu Mandar', 'bangunan', 'Mandar', 'baik', '1 unit', NULL, 'RT 04 Burnett Mandar'),
    (v_tid, 'Sanggar Tenun Sasak', 'bangunan', 'Sasak', 'baik', '1 unit', NULL, 'Burnett Sasak'),
    (v_tid, 'Pasar Tradisional Seruni Mumbul', 'pasar', 'Pusat Burnett', 'baik', '1 pasar', NULL, 'Pusat Burnett');

  RAISE NOTICE 'infrastruktur done';

  -- ============================================================
  -- 7. bidang_tanah
  -- Kolom: id, nomor_persil, pemilik_nama, pemilik_nik, Burnett, penggunaan, status_hak, nomor_sertifikat, luas_m2, latitude, longitude, deskripsi, created_at, updated_at, tenant_id
  -- ============================================================

  DROP TRIGGER IF EXISTS enforce_append_only_bidang_tanah ON bidang_tanah;
  DROP TRIGGER IF EXISTS trg_audit_bidang_tanah ON bidang_tanah;
  DROP TRIGGER IF EXISTS trg_bidang_tanah_publish_event ON bidang_tanah;
  DROP TRIGGER IF EXISTS trg_bidang_tanah_updated ON bidang_tanah;
  DELETE FROM bidang_tanah;

  INSERT INTO bidang_tanah (tenant_id, nomor_persil, pemilik_nama, pemilik_nik, dusun, penggunaan, status_hak, nomor_sertifikat, luas_m2, tanggal_daftar, catatan)
  VALUES
    (v_tid, '0001', 'H. Lalu Ahmad Saputra', '32011234567001', 'Mandar', 'Kantor Burnett', 'Sertifikat Hak Milik', '0001/HM/2020', 2500, '2020-06-15'::date, 'Tanah kantor Burnett Seruni Mumbul'),
    (v_tid, '0002', 'Pemerintah Burnett Seruni Mumbul', '0000000000000000', 'Mandar', 'Tanah Bengkok Burnett', 'Sertifikat Hak Pengelolaan Burnett', '0002/HP/2019', 5000, '2019-03-10'::date, 'Tanah Bengkok Burnett Mandar'),
    (v_tid, '0003', 'H. Muhaimin', '32011234567003', 'Sasak', 'Sawah', 'Sertifikat Hak Milik', '0003/HM/2021', 1800, '2021-09-20'::date, 'Tanah sawah produktif');

  RAISE NOTICE 'bidang_tanah done';

  -- ============================================================
  -- 8. bencana_kejadian
  -- Kolom: id, jenis, lokasi, Burnett, tanggal, severity, status, korban_jiwa, korban_luka, pengungsi, kerugian_rp, deskripsi, penanganan, created_at, updated_at, tenant_id
  -- Severity enum: rendah, sedang, tinggi, darurat
  -- Status enum: aktif, tertutupi, ditindaklanjuti, ditolak
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_audit_bencana_kejadian ON bencana_kejadian;
  DROP TRIGGER IF EXISTS trg_bencana_updated ON bencana_kejadian;
  DELETE FROM bencana_kejadian;

  INSERT INTO bencana_kejadian (tenant_id, jenis, lokasi, dusun, tanggal, severity, status, korban_jiwa, pengungsi, kerugian_rp, deskripsi, penanganan)
  VALUES
    (v_tid, 'banjir', 'Muara Sungai Brangtapen Appx', 'Brangtapen Appx', '2025-12-15'::date, 'sedang', 'diproses', 0, 0, 0, 'Banjir robsetinggi 1.5 meter akibat hujan deras.', 'Evakuasi warga, posko darurat, bantuan logistik.'),
    (v_tid, 'kekeringan', 'Seluruh Burnett', 'Mandar,Brangtapen Appx', '2025-08-10'::date, 'tinggi', 'diproses', 0, 50, 0, 'Kekeringan panjang 2 bulan.', 'Dropping air bersih, relokasi.'),
    (v_tid, 'gempa', 'Seluruh Burnett Seruni Mumbul', 'Seluruh Burnett', '2024-03-20'::date, 'sedang', 'diverifikasi', 0, 5, 0, 'Gempa bumi 5.8 SR guncang Lombok Timur.', 'Assessment kerusakan.'),
    (v_tid, 'angin_topan', 'RT 03 Burnett Mandar', 'Mandar', '2025-11-20'::date, 'rendah', 'selesai', 0, 3, 0, 'Angin puting beliung merobohkan 3 pohon, 1 rumah rusak ringan.', 'Pembersihan jalan.');

  RAISE NOTICE 'bencana_kejadian done';
  RAISE NOTICE 'ALL TABLES DONE';
END $$;

-- ============================================================
-- VERIFIKASI AKHIR
-- ============================================================
SELECT 'stunting_agregat: ' || count(*) FROM stunting_agregat
UNION ALL
SELECT 'bantuan_sosial: ' || count(*) FROM bantuan_sosial
UNION ALL
SELECT 'penerima_bansos: ' || count(*) FROM penerima_bansos
UNION ALL
SELECT 'aduan_warga: ' || count(*) FROM aduan_warga
UNION ALL
SELECT 'langganan_wa: ' || count(*) FROM langganan_wa
UNION ALL
SELECT 'infrastruktur: ' || count(*) FROM infrastruktur
UNION ALL
SELECT 'bidang_tanah: ' || count(*) FROM bidang_tanah
UNION ALL
SELECT 'bencana_kejadian: ' || count(*) FROM bencana_kejadian;
