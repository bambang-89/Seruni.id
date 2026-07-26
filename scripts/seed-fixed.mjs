/**
 * Seed Script - Fixed version with correct schema
 * Run: node scripts/seed-fixed.mjs
 */

import pg from 'pg';
const { Client } = pg;

const DB_URL = 'postgresql://postgres:Serunimumbul-88@db.smngqdpbmgcdbmkiuviq.supabase.co:5432/postgres';

async function seed() {
  const client = new Client({ connectionString: DB_URL });

  try {
    console.log('🔄 Connecting to database...\n');
    await client.connect();
    console.log('✅ Connected!\n');

    // Get tenant ID
    const tenantResult = await client.query('SELECT id FROM tenants LIMIT 1');
    const tenantId = tenantResult.rows[0]?.id;

    if (!tenantId) {
      console.error('❌ Tenant not found! Please create tenant first.');
      process.exit(1);
    }
    console.log('📍 Tenant ID:', tenantId);
    console.log('');

    // ============================================================
    // 1. WILAYAH DUSUN (has tenant_id)
    // ============================================================
    console.log('🗺️ Seeding wilayah_dusun...');
    await client.query('DELETE FROM wilayah_dusun WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO wilayah_dusun (tenant_id, nama, kk, jiwa, luas_ha, urutan) VALUES
      ($1, 'Mandar', 678, 2378, 285, 1),
      ($1, 'Sasak', 712, 2413, 302, 2),
      ($1, 'Dames', 543, 1348, 198, 3),
      ($1, 'Brangtapen Asri', 542, 1728, 215, 4)
    `, [tenantId]);
    console.log('✅ wilayah_dusun: 4 dusun (7867 penduduk)\n');

    // ============================================================
    // 2. BERITA (NO tenant_id - public table)
    // ============================================================
    console.log('📰 Seeding berita...');
    await client.query('DELETE FROM berita');
    await client.query(`
      INSERT INTO berita (slug, kategori, judul, ringkasan, isi, penulis, tanggal, published) VALUES
      ('progres-pengerasan-jalan-mandar', 'Pembangunan', 'Progres Pengerasan Jalan Mandar Mencapai 78%',
       'Kegiatan pengerasan jalan sepanjang 1,2 km ditargetkan rampung akhir Agustus.',
       '["Pengerjaan pengerasan Jalan Poros Mandar sepanjang 1,2 km telah mencapai progres fisik 78%.","Kegiatan ini didanai APBDes 2026 dengan pagu Rp 480 juta.","Target selesai 28 Agustus 2026.","Mengurangi waktu tempuh dari 22 menit menjadi 9 menit."]',
       'Kasi Pembangunan', '2026-07-17', true),
      ('stunting-turun-12-persen', 'Kesehatan', 'Kasus Stunting Turun 12% Setelah Program PMT Terpadu',
       'Hasil evaluasi Posyandu semester I menunjukkan penurunan prevalensi stunting.',
       '["PMT lokal menurunkan stunting dari 18,4% menjadi 16,2%.","412 balita terpantau.","Alokasi Rp 60 juta semester II."]',
       'Kasi Kesejahteraan', '2026-07-15', true),
      ('bumdes-buka-marketplace', 'Ekonomi', 'BUMDes Seruni Buka Gerai Marketplace Digital',
       'Marketplace desa menampung 47 produk UMKM lokal.',
       '["47 produk UMKM tersedia.","Transaksi pertama Rp 42 juta.","Pengiriman seluruh Lombok."]',
       'Direktur BUMDes', '2026-07-12', true),
      ('musdes-rkpdes-2027', 'Perencanaan', 'Jadwal Musdes Perencanaan RKPDes 2027',
       'Musyawarah desa diagendakan 28 Juli 2026.',
       '["Pembahasan prioritas pembangunan.","Alokasi APBDes.","Sinkronisasi usulan warga."]',
       'Kaur Perencanaan', '2026-07-10', true),
      ('pelatihan-umkm-digital', 'Ekonomi', '30 UMKM Terima Pelatihan Digital Marketing',
       'BUMDes melatih pemasaran digital.',
       '["3 hari pelatihan.","Buat konten promo.","Target 50% berjualan online."]',
       'Direksi BUMDes', '2026-07-08', true)
    `);
    console.log('✅ berita: 5 artikel\n');

    // ============================================================
    // 3. AGENDA (NO tenant_id - public table)
    // ============================================================
    console.log('📅 Seeding agenda...');
    await client.query('DELETE FROM agenda');
    await client.query(`
      INSERT INTO agenda (slug, jenis, judul, tanggal, waktu, lokasi, penyelenggara, deskripsi) VALUES
      ('musdes-rkpdes-2027', 'Musdes', 'Musyawarah Desa Perencanaan RKPDes 2027', '2026-07-28', '08.30-12.00 WITA', 'Aula Kantor Desa', 'Pemerintah Desa & BPD', 'Pembahasan prioritas pembangunan 2027.'),
      ('posyandu-mandar', 'Posyandu', 'Posyandu Balita Mandar', '2026-07-30', '08.00-11.00 WITA', 'Posyandu Melati III', 'PKK & Puskesmas', 'Penimbangan dan imunisasi balita.'),
      ('gotong-royong-pantai', 'Gotong Royong', 'Kerja Bakti Bersih Pantai Seruni', '2026-08-02', '07.00-10.00 WITA', 'Pantai Seruni', 'Karang Taruna & BUMDes', 'Aksi bersih pantai HUT ke-58.'),
      ('sosialisasi-bansos', 'Sosialisasi', 'Sosialisasi Bansos Semester II', '2026-08-05', '13.30-16.00 WITA', 'Balai Mandar', 'Kasi Kesejahteraan', 'Penjelasan BPNT dan PKH.'),
      ('pelatihan-digital', 'Pelatihan', 'Pelatihan Digital Marketing', '2026-08-10', '09.00-15.00 WITA', 'Aula BUMDes', 'BUMDes & Disperdagin', 'Pemasaran digital untuk UMKM.')
    `);
    console.log('✅ agenda: 5 agenda\n');

    // ============================================================
    // 4. GALERI (NO tenant_id - public table)
    // ============================================================
    console.log('🖼️ Seeding galeri...');
    await client.query('DELETE FROM galeri');
    await client.query(`
      INSERT INTO galeri (judul, emoji, album, tanggal, urutan) VALUES
      ('Festival Panen Raya 2026', 'festival', 'Kegiatan Desa', '2026-04-18', 1),
      ('Musdes Perencanaan', 'musyawarah', 'Kegiatan Desa', '2026-03-12', 2),
      ('Posyandu Balita', 'bayi', 'Kesehatan', '2026-05-08', 3),
      ('Gotong Royong Pantai', 'pantai', 'Lingkungan', '2026-06-15', 4),
      ('Pelatihan UMKM Digital', 'pelatihan', 'Ekonomi', '2026-06-22', 5),
      ('Turnamen Bola', 'bola', 'Olahraga', '2026-05-30', 6),
      ('Peresmian PJU Solar', 'lampu', 'Pembangunan', '2026-04-02', 7),
      ('Kirab Budaya Sasak', 'budaya', 'Budaya', '2026-03-25', 8),
      ('Pemeriksaan Kesehatan Lansia', 'kesehatan', 'Kesehatan', '2026-06-01', 9),
      ('Bazar UMKM', 'bazar', 'Ekonomi', '2026-05-20', 10)
    `);
    console.log('✅ galeri: 10 foto\n');

    // ============================================================
    // 5. PENGUMUMAN (NO tenant_id - public table)
    // ============================================================
    console.log('📢 Seeding pengumuman...');
    await client.query('DELETE FROM pengumuman');
    await client.query(`
      INSERT INTO pengumuman (nomor, tanggal, judul, ringkasan) VALUES
      ('148/PMR/SM/VII/2026', '2026-07-16', 'Jadwal Musdes Perencanaan RKPDes 2027', 'Undangan untuk perwakilan dusun.'),
      ('146/PMR/SM/VII/2026', '2026-07-10', 'Pemadaman Air Bersih', 'Perbaikan pipa PAMDes.'),
      ('142/PMR/SM/VII/2026', '2026-07-04', 'Pendaftaran Beasiswa', '5-20 Juli 2026.'),
      ('138/PMR/SM/VI/2026', '2026-06-28', 'Verifikasi Ulang DTKS', 'Kader dusun berkunjung.')
    `);
    console.log('✅ pengumuman: 4 pengumuman\n');

    // ============================================================
    // 6. POTENSI WISATA (has tenant_id)
    // ============================================================
    console.log('🏖️ Seeding potensi_wisata...');
    await client.query('DELETE FROM potensi_wisata WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO potensi_wisata (tenant_id, nama, jenis, dusun, deskripsi, fasilitas, latitude, longitude, status) VALUES
      ($1, 'Pantai Seruni Mumbul', 'Wisata Bahari', 'Brangtapen Asri', 'Pantai berpasir putih 2,4 km dengan snorkeling.', 'Gazebo, MCK, Warung', -8.5432, 116.6543, 'publish'),
      ($1, 'Bukit Panorama', 'Ekowisata', 'Sasak', 'Titik pandang matahari terbit di 380 mdpl.', 'Jalur tracking', -8.5210, 116.6780, 'publish'),
      ($1, 'Sentra Tenun Songket', 'Wisata Budaya', 'Mandar', 'Sanggar tenun aktif.', 'Sanggar tenun', -8.5350, 116.6620, 'publish')
    `, [tenantId]);
    console.log('✅ potensi_wisata: 3 destinasi\n');

    // ============================================================
    // 7. POTENSI UMKM (has tenant_id)
    // ============================================================
    console.log('🏪 Seeding potensi_umkm...');
    await client.query('DELETE FROM potensi_umkm WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO potensi_umkm (tenant_id, tipe, nama, pemilik, sektor, dusun, kontak, deskripsi, status) VALUES
      ($1, 'Kuliner', 'UMKM Madu Trigona', 'Hj. Rina', 'Perlebahan', 'Mandar', '+6281234567101', 'Madu trigona premium.', 'publish'),
      ($1, 'Kuliner', 'Koperasi Tani Maju', 'Andi Rahman', 'Pertanian', 'Sasak', '+6281234567102', 'Kopi robusta pilihan.', 'publish'),
      ($1, 'Kerajinan', 'Sanggar Tenun', 'Siti Aminah', 'Kerajinan', 'Mandar', '+6281234567103', 'Tenun songket Sasak.', 'publish'),
      ($1, 'Kuliner', 'UMKM Rumput Laut', 'H. Basri', 'Perikanan', 'Brangtapen Asri', '+6281234567104', 'Olahan rumput laut.', 'publish')
    `, [tenantId]);
    console.log('✅ potensi_umkm: 4 UMKM\n');

    // ============================================================
    // 8. POTENSI PRODUK (has tenant_id)
    // ============================================================
    console.log('🛒 Seeding potensi_produk...');
    await client.query('DELETE FROM potensi_produk WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO potensi_produk (tenant_id, penjual_nama, nama, kategori, harga, satuan, stok, deskripsi, featured, status) VALUES
      ($1, 'Hj. Rina', 'Madu Trigona 500ml', 'Makanan', 95000, 'botol', 50, 'Madu trigona premium.', true, 'publish'),
      ($1, 'Andi Rahman', 'Kopi Robusta 250g', 'Minuman', 65000, '250g', 100, 'Kopi robusta pilihan.', true, 'publish'),
      ($1, 'Siti Aminah', 'Tenun Songket', 'Kerajinan', 450000, 'helai', 15, 'Tenun songket asli.', true, 'publish'),
      ($1, 'H. Basri', 'Kerupuk Rumput Laut', 'Makanan', 22000, 'bungkus', 200, 'Kerupuk rumput laut.', true, 'publish')
    `, [tenantId]);
    console.log('✅ potensi_produk: 4 produk\n');

    // ============================================================
    // 9. KEGIATAN PEMBANGUNAN (has tenant_id)
    // ============================================================
    console.log('🏗️ Seeding kegiatan_pembangunan...');
    await client.query('DELETE FROM kegiatan_pembangunan WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO kegiatan_pembangunan (tenant_id, tahun, bidang, nama_kegiatan, lokasi, volume, anggaran, realization, sumber_dana, status) VALUES
      ($1, 2026, 'Pembangunan Desa', 'Rehabilitasi Saluran Irigasi', 'Mandar', '1.2 km', 280000000, 229600000, 'APBDes', 'diproses'),
      ($1, 2026, 'Pembangunan Desa', 'Pembangunan MCK Pasar', 'Pusat Desa', '1 unit', 150000000, 67500000, 'APBDes', 'diproses'),
      ($1, 2026, 'Pembangunan Desa', 'Pengadaan PJU Surya', 'Seluruh Desa', '30 titik', 90000000, 27000000, 'APBDes', 'diproses')
    `, [tenantId]);
    console.log('✅ kegiatan_pembangunan: 3 kegiatan\n');

    // ============================================================
    // 10. USULAN WARGA (has tenant_id)
    // ============================================================
    console.log('📝 Seeding usulan_warga...');
    await client.query('DELETE FROM usulan_warga WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO usulan_warga (tenant_id, nomor_tiket, nama, kontak, dusun, kategori, judul, deskripsi, lokasi, status, vote_count) VALUES
      ($1, 'USL-2026-001', 'Ahmad Zulkifli', '+6281234567001', 'Mandar', 'infrastruktur', 'Perbaikan Jalan Mandar-Sasak', 'Jalan rusak 2,3 km.', 'Mandar-Sasak', 'ditindaklanjuti', 342),
      ($1, 'USL-2026-002', 'Siti Aminah', '+6281234567002', 'Mandar', 'pendidikan', 'Pembangunan PAUD', 'PAUD untuk 87 balita.', 'Mandar', 'ditindaklanjuti', 289),
      ($1, 'USL-2026-003', 'Muhammad Ali', '+6281234567003', 'Brangtapen Asri', 'infrastruktur', 'Sumur Bor Air Bersih', 'Air bersih terbatas.', 'Brangtapen Asri', 'diverifikasi', 251),
      ($1, 'USL-2026-004', 'Hajjah Rahayu', '+6281234567004', 'Mandar', 'kesehatan', 'Renovasi Poskesdes', 'Poskesdes perlu renovasi.', 'Pusat Desa', 'diverifikasi', 198),
      ($1, 'USL-2026-005', 'Budi Santoso', '+6281234567005', 'Brangtapen Asri', 'sosial', 'Beasiswa Nelayan', '12 anak nelayan.', 'Brangtapen Asri', 'ditindaklanjuti', 176)
    `, [tenantId]);
    console.log('✅ usulan_warga: 5 usulan\n');

    // ============================================================
    // 11. IDM STATUS DESA (has tenant_id)
    // ============================================================
    console.log('📊 Seeding idm_status_desa...');
    await client.query(`
      INSERT INTO idm_status_desa (tenant_id, status, total_skor, dimensi_scores) VALUES
      ($1, 'Berkembang', 0.7412, '{"Kesehatan":0.84,"Pendidikan":0.90,"Modal Sosial":0.76,"Permukiman":0.82,"Ekonomi":0.72,"Ekologi":0.88}'::jsonb)
      ON CONFLICT (tenant_id) DO UPDATE SET status = EXCLUDED.status, total_skor = EXCLUDED.total_skor, dimensi_scores = EXCLUDED.dimensi_scores
    `, [tenantId]);
    console.log('✅ idm_status_desa: skor 0.7412\n');

    // ============================================================
    // 12. DESA PAMONG (has tenant_id)
    // ============================================================
    console.log('👥 Seeding desa_pamong...');
    await client.query('DELETE FROM desa_pamong WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO desa_pamong (tenant_id, nama, jabatan, periode, urutan) VALUES
      ($1, 'H. Lalu Ahmad Saputra', 'Kepala Desa', '2024-2030', 1),
      ($1, 'Baiq Nuraini', 'Sekretaris Desa', NULL, 2),
      ($1, 'Muhammad Sabri', 'Kasi Pemerintahan', NULL, 3),
      ($1, 'Lalu Zainuddin', 'Kasi Kesejahteraan', NULL, 4),
      ($1, 'Hj. Sri Wahyuni', 'Kasi Pelayanan', NULL, 5),
      ($1, 'Baiq Rahma Dewi', 'Kaur Keuangan', NULL, 6)
    `, [tenantId]);
    console.log('✅ desa_pamong: 6 perangkat\n');

    // ============================================================
    // 13. LEMBAGA DESA (has tenant_id)
    // ============================================================
    console.log('🏛️ Seeding lembaga_desa...');
    await client.query('DELETE FROM lembaga_desa WHERE tenant_id = $1', [tenantId]);
    await client.query(`
      INSERT INTO lembaga_desa (tenant_id, nama, ketua, jumlah_anggota, urutan) VALUES
      ($1, 'Badan Permusyawaratan Desa (BPD)', 'H. Muhaimin', 9, 1),
      ($1, 'LPMD', 'Lalu Sudirman', 11, 2),
      ($1, 'PKK Desa', 'Hj. Nurhayati', 25, 3),
      ($1, 'Karang Taruna', 'Ahmad Rizki', 42, 4),
      ($1, 'BUMDes Bina Seruni Mandiri', 'Baiq Salma', 7, 5)
    `, [tenantId]);
    console.log('✅ lembaga_desa: 5 lembaga\n');

    // ============================================================
    // VERIFIKASI AKHIR
    // ============================================================
    console.log('='.repeat(50));
    console.log('🎉 DATABASE POPULATION COMPLETE!');
    console.log('='.repeat(50));
    console.log('');

    const result = await client.query(`
      SELECT 'wilayah_dusun' as tbl, count(*)::text as jml FROM wilayah_dusun WHERE tenant_id = $1
      UNION ALL SELECT 'berita', count(*)::text FROM berita
      UNION ALL SELECT 'agenda', count(*)::text FROM agenda
      UNION ALL SELECT 'galeri', count(*)::text FROM galeri
      UNION ALL SELECT 'pengumuman', count(*)::text FROM pengumuman
      UNION ALL SELECT 'potensi_wisata', count(*)::text FROM potensi_wisata WHERE tenant_id = $1
      UNION ALL SELECT 'potensi_umkm', count(*)::text FROM potensi_umkm WHERE tenant_id = $1
      UNION ALL SELECT 'potensi_produk', count(*)::text FROM potensi_produk WHERE tenant_id = $1
      UNION ALL SELECT 'kegiatan_pembangunan', count(*)::text FROM kegiatan_pembangunan WHERE tenant_id = $1
      UNION ALL SELECT 'usulan_warga', count(*)::text FROM usulan_warga WHERE tenant_id = $1
      UNION ALL SELECT 'idm_status_desa', count(*)::text FROM idm_status_desa WHERE tenant_id = $1
      UNION ALL SELECT 'desa_pamong', count(*)::text FROM desa_pamong WHERE tenant_id = $1
      UNION ALL SELECT 'lembaga_desa', count(*)::text FROM lembaga_desa WHERE tenant_id = $1
    `, [tenantId]);

    console.log('📈 Summary:');
    result.rows.forEach(row => {
      console.log(`   ${row.tbl}: ${row.jml} rows`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('   Detail:', error.detail || 'N/A');
    process.exit(1);
  } finally {
    await client.end();
    console.log('\n✅ Database connection closed.');
  }
}

seed();
