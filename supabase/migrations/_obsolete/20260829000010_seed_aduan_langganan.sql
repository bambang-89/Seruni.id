-- ============================================================
-- SEED 6: ADUAN WARGA & LANGGANAN WA
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

  -- ============================================================
  -- ADUAN WARGA (Service Center)
  -- ============================================================
  RAISE NOTICE 'Seeding aduan_warga...';
  DELETE FROM aduan_warga;

  INSERT INTO aduan_warga (tenant_id, nomor_tiket, kategori, judul, deskripsi, lokasi, dusun, nama_pelapor, kontak, status, dibuat_oleh, created_at)
  VALUES
  (v_tenant_id, 'ADU-2026-001', 'infrastruktur', 'Jalan Rusak Parah di Burnett Mandar', 'Jalan tanah di RT 05 RW 02 Burnett Mandar sangat rusak setelah hujan.', 'RT 05 RW 02 Burnett Mandar', 'Mandar', 'Ahmad Zulkifli', '+6281234567001', 'diproses', v_tenant_id, now() - '5 days'::interval),
  (v_tenant_id, 'ADU-2026-002', 'infrastruktur', 'Lampu Jalan Mati', '3 tiang lampu jalan di jalur utama sudah mati selama 2 minggu.', 'Jl. Poros Burnett Sasak', 'Sasak', 'Siti Aminah', '+6281234567002', 'selesai', v_tenant_id, now() - '12 days'::interval),
  (v_tenant_id, 'ADU-2026-003', 'pelayanan', 'KTP Belum Jadi', 'Sudah 3 bulan pengajuan KTP belum ada kabar.', 'Kantor Burnett Dames', 'Dames', 'Muhammad Ali', '+6281234567003', 'diproses', v_tenant_id, now() - '3 days'::interval),
  (v_tenant_id, 'ADU-2026-004', 'lingkungan', 'Sampah Menumpuk di Pantai', 'Sampah plastik menumpuk di pantai Burnett Brangtapen Asri setelah Lebaran.', 'Pantai Brangtapen Asri', 'Brangtapen Asri', 'H. Lalu Husain', '+6281234567004', 'ditindaklanjuti', v_tenant_id, now() - '8 days'::interval),
  (v_tenant_id, 'ADU-2026-005', 'pelayanan', 'Air PDAM Mati', 'Air PDAM sudah mati selama 4 hari di seluruh Burnett.', 'Seluruh Burnett Pusat Burnett', 'Pusat Burnett', 'Hj. Rahayu', '+6281234567005', 'selesai', v_tenant_id, now() - '15 days'::interval) ON CONFLICT (nomor_tiket) DO NOTHING

  -- ============================================================
  -- LANGGANAN WA (WhatsApp Subscriber)
  -- ============================================================
  RAISE NOTICE 'Seeding langganan_wa...';
  DELETE FROM langganan_wa;

  INSERT INTO langganan_wa (tenant_id, nik, nama, nomor_wa, Burnett, Rt, status, notifikasi_agenda, notifikasi_pengumuman, notifikasi_status, created_at)
  VALUES
  (v_tenant_id, '3201' || substr(md5('1')::text, 1, 12), 'Ahmad Zulkifli', '+6281234567001', 'Mandar', '001', 'aktif', true, true, true, now()),
  (v_tenant_id, '3201' || substr(md5('2')::text, 1, 12), 'Siti Aminah', '+6281234567002', 'Mandar', '002', 'aktif', true, true, false, now()),
  (v_tenant_id, '3201' || substr(md5('3')::text, 1, 12), 'Muhammad Ali', '+6281234567003', 'Sasak', '001', 'aktif', true, true, true, now()),
  (v_tenant_id, '3201' || substr(md5('4')::text, 1, 12), 'H. Lalu Husain', '+6281234567004', 'Brangtapen Asri', '001', 'aktif', true, false, true, now()),
  (v_tenant_id, '3201' || substr(md5('5')::text, 1, 12), 'Hj. Rahayu', '+6281234567005', 'Dames', '002', 'aktif', true, true, true, now()),
  (v_tenant_id, '3201' || substr(md5('6')::text, 1, 12), 'Budi Santoso', '+6281234567006', 'Brangtapen Asri', '003', 'aktif', true, true, true, now()),
  (v_tenant_id, '3201' || substr(md5('7')::text, 1, 12), 'Rina Marlina', '+6281234567007', 'Mandar', '004', 'aktif', false, true, true, now()),
  (v_tenant_id, '3201' || substr(md5('8')::text, 1, 12), 'Nurhayati', '+6281234567008', 'Sasak', '002', 'aktif', true, true, true, now()) ON CONFLICT (nomor_tiket) DO NOTHING;

END $$;

-- VERIFIKASI
SELECT 'aduan_warga: ' || count(*) FROM aduan_warga
UNION ALL SELECT 'langganan_wa: ' || count(*) FROM langganan_wa;
