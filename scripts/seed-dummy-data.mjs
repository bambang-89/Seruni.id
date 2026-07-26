/**
 * Script untuk populate database dengan data dummy
 * Menggunakan Supabase Admin API
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://smmngqdpbmgcdbmkiuviq.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function getTenantId() {
  const { data } = await supabase.from('tenants').select('id').limit(1);
  return data?.[0]?.id;
}

async function seedData() {
  console.log('🔄 Starting database population...\n');

  // Get or create tenant
  let tenantId = await getTenantId();
  if (!tenantId) {
    const { data, error } = await supabase.from('tenants').insert({
      nama_desa: 'Desa Seruni Mumbul',
      subdomain: 'seruni'
    }).select('id').single();
    if (error) {
      console.error('Error creating tenant:', error);
      return;
    }
    tenantId = data.id;
  }
  console.log('✅ Tenant ID:', tenantId);

  // 1. Seed berita
  console.log('\n📰 Seeding berita...');
  const beritaData = [
    {
      slug: 'progres-pengerasan-jalan-mandar',
      kategori: 'Pembangunan',
      judul: 'Progres Pengerasan Jalan Mandar Mencapai 78%',
      ringkasan: 'Kegiatan pengerasan jalan sepanjang 1,2 km ditargetkan rampung akhir Agustus, didanai APBDes 2026.',
      isi: ['Pengerjaan pengerasan Jalan Poros Mandar sepanjang 1,2 km telah mencapai progres fisik 78% per 15 Juli 2026. Kegiatan ini didanai APBDes 2026 dengan pagu Rp 480 juta.', 'Kepala Desa menyebut penyelesaian ditargetkan pada 28 Agustus 2026, sebelum musim hujan tiba. Warga diminta menghindari jalur pada pukul 08.00–16.00 selama pengecoran.', 'Realisasi ini mengurangi waktu tempuh Mandar–Pusat Desa dari 22 menit menjadi 9 menit.'],
      penulis: 'Kasi Pembangunan',
      tanggal: '2026-07-17',
      published: true
    },
    {
      slug: 'stunting-turun-12-persen',
      kategori: 'Kesehatan',
      judul: 'Kasus Stunting Turun 12% Setelah Program PMT Terpadu',
      ringkasan: 'Hasil evaluasi Posyandu semester I menunjukkan penurunan prevalensi stunting balita di 4 dusun.',
      isi: ['Program Pemberian Makanan Tambahan (PMT) berbasis pangan lokal menurunkan prevalensi stunting dari 18,4% menjadi 16,2% pada semester I 2026.', 'Empat Posyandu di seluruh dusun mencatat 412 balita rutin terpantau. Kader Posyandu bekerja sama dengan Puskesmas Pringgabaya melakukan konseling gizi keluarga.', 'Desa mengalokasikan tambahan Rp 60 juta di semester II untuk perluasan sasaran PMT bagi ibu hamil KEK dan bayi 6–24 bulan.'],
      penulis: 'Kasi Kesejahteraan',
      tanggal: '2026-07-15',
      published: true
    },
    {
      slug: 'bumdes-buka-marketplace',
      kategori: 'Ekonomi',
      judul: 'BUMDes Seruni Buka Gerai Marketplace Digital',
      ringkasan: 'Marketplace desa kini menampung 47 produk UMKM lokal dengan pengiriman ke seluruh Lombok.',
      isi: ['BUMDes Bina Seruni Mandiri peluncuran gerai marketplace digital yang menampung 47 produk UMKM warga, mencakup madu, kopi, tenun songket, dan olahan laut.', 'Transaksi bulan pertama menembus Rp 42 juta dengan cakupan pengiriman seluruh Pulau Lombok.', 'UMKM baru dapat mendaftar melalui menu Marketplace di portal ini atau langsung ke kantor BUMDes.'],
      penulis: 'Direktur BUMDes',
      tanggal: '2026-07-12',
      published: true
    },
    {
      slug: 'musdes-rkpdes-2027',
      kategori: 'Perencanaan',
      judul: 'Jadwal Musdes Perencanaan RKPDes 2027 Diumumkan',
      ringkasan: 'Musyawarah desa untuk penyusunan RKPDes tahun 2027 diagendakan tanggal 28 Juli 2026.',
      isi: ['Pemerintah Desa dan BPD mengajak seluruh perwakilan dusun dan tokoh masyarakat untuk hadir dalam Musdes.', 'Agenda meliputi pembahasan prioritas pembangunan, alokasi APBDes, dan sinkronisasi usulan warga hasil voting daring.', 'Hasil musdes akan menjadi dasar penyusunan RKPDes 2027 yang akan dibahas bersama Pemerintah Desa.'],
      penulis: 'Kaur Perencanaan',
      tanggal: '2026-07-10',
      published: true
    }
  ];

  const { error: beritaError } = await supabase.from('berita').upsert(beritaData, { onConflict: 'slug' });
  if (beritaError) console.error('Error seeding berita:', beritaError);
  else console.log('✅ berita: 4 rows');

  // 2. Seed agenda
  console.log('\n📅 Seeding agenda...');
  const agendaData = [
    {
      slug: 'musdes-rkpdes-2027',
      jenis: 'Musdes',
      judul: 'Musyawarah Desa Perencanaan RKPDes 2027',
      tanggal: '2026-07-28',
      waktu: '08.30–12.00 WITA',
      lokasi: 'Aula Kantor Desa',
      penyelenggara: 'Pemerintah Desa & BPD',
      deskripsi: 'Pembahasan prioritas pembangunan, alokasi APBDes, dan sinkronisasi usulan warga hasil voting daring untuk tahun anggaran 2027.'
    },
    {
      slug: 'posyandu-mandar',
      jenis: 'Posyandu',
      judul: 'Posyandu Balita Mandar',
      tanggal: '2026-07-30',
      waktu: '08.00–11.00 WITA',
      lokasi: 'Posyandu Melati III',
      penyelenggara: 'PKK Desa & Puskesmas Pringgabaya',
      deskripsi: 'Penimbangan, pengukuran, imunisasi lanjutan, serta pembagian PMT untuk balita 0–5 tahun di Mandar.'
    },
    {
      slug: 'gotong-royong-pantai',
      jenis: 'Gotong Royong',
      judul: 'Kerja Bakti Bersih Pantai Seruni',
      tanggal: '2026-08-02',
      waktu: '07.00–10.00 WITA',
      lokasi: 'Pantai Seruni Mumbul',
      penyelenggara: 'Karang Taruna & BUMDes',
      deskripsi: 'Aksi bersih pantai lintas dusun dalam rangka HUT ke-58 Desa Seruni Mumbul.'
    },
    {
      slug: 'sosialisasi-bansos',
      jenis: 'Sosialisasi',
      judul: 'Sosialisasi Program Bansos Semester II',
      tanggal: '2026-08-05',
      waktu: '13.30–16.00 WITA',
      lokasi: 'Balai Mandar',
      penyelenggara: 'Kasi Kesejahteraan',
      deskripsi: 'Penjelasan kriteria penerima BPNT & PKH periode Juli–Desember 2026, mekanisme pengaduan, dan verifikasi DTKS.'
    },
    {
      slug: 'pelatihan-digital',
      jenis: 'Pelatihan',
      judul: 'Pelatihan Digital Marketing UMKM',
      tanggal: '2026-08-10',
      waktu: '09.00–15.00 WITA',
      lokasi: 'Aula BUMDes',
      penyelenggara: 'BUMDes & Disperdagin',
      deskripsi: 'Pelatihan pemasaran digital untuk 30 peserta UMKM se-desa.'
    }
  ];

  const { error: agendaError } = await supabase.from('agenda').upsert(agendaData, { onConflict: 'slug' });
  if (agendaError) console.error('Error seeding agenda:', agendaError);
  else console.log('✅ agenda: 5 rows');

  // 3. Seed galeri
  console.log('\n🖼️ Seeding galeri...');
  const galeriData = [
    { judul: 'Festival Panen Raya 2026', emoji: 'festival', album: 'Kegiatan Desa', tanggal: '2026-04-18', urutan: 1 },
    { judul: 'Musdes Perencanaan', emoji: 'musyawarah', album: 'Kegiatan Desa', tanggal: '2026-03-12', urutan: 2 },
    { judul: 'Posyandu Balita', emoji: 'bayi', album: 'Kesehatan', tanggal: '2026-05-08', urutan: 3 },
    { judul: 'Gotong Royong Pantai', emoji: 'pantai', album: 'Lingkungan', tanggal: '2026-06-15', urutan: 4 },
    { judul: 'Pelatihan UMKM Digital', emoji: 'pelatihan', album: 'Ekonomi', tanggal: '2026-06-22', urutan: 5 },
    { judul: 'Turnamen Bola Antar-Dusun', emoji: 'bola', album: 'Olahraga', tanggal: '2026-05-30', urutan: 6 },
    { judul: 'Peresmian PJU Solar', emoji: 'lampu', album: 'Pembangunan', tanggal: '2026-04-02', urutan: 7 },
    { judul: 'Kirab Budaya Sasak', emoji: 'budaya', album: 'Budaya', tanggal: '2026-03-25', urutan: 8 },
    { judul: 'Pemeriksaan Kesehatan Lansia', emoji: 'kesehatan', album: 'Kesehatan', tanggal: '2026-06-01', urutan: 9 }
  ];

  const { error: galeriError } = await supabase.from('galeri').upsert(galeriData);
  if (galeriError) console.error('Error seeding galeri:', galeriError);
  else console.log('✅ galeri: 9 rows');

  // 4. Seed potensi_wisata
  console.log('\n🏖️ Seeding potensi_wisata...');
  const wisataData = [
    {
      tenant_id: tenantId,
      nama: 'Pantai Seruni Mumbul',
      jenis: 'Wisata Bahari',
      dusun: 'Brangtapen Asri',
      deskripsi: 'Pantai berpasir putih 2,4 km dengan spot snorkeling terumbu karang di sisi selatan.',
      fasilitas: 'Gazebo, MCK, Warung UMKM',
      latitude: -8.5432,
      longitude: 116.6543,
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      nama: 'Bukit Panorama Timba Gading',
      jenis: 'Ekowisata',
      dusun: 'Sasak',
      deskripsi: 'Titik pandang matahari terbit di ketinggian 380 mdpl menghadap Selat Alas dan siluet Rinjani.',
      fasilitas: 'Jalur tracking',
      latitude: -8.5210,
      longitude: 116.6780,
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      nama: 'Sentra Tenun Songket Sasak',
      jenis: 'Wisata Budaya',
      dusun: 'Dames',
      deskripsi: 'Sanggar tenun aktif di Mandar. Pengunjung dapat mencoba menenun dan membeli langsung.',
      fasilitas: 'Sanggar tenun',
      latitude: -8.5350,
      longitude: 116.6620,
      status: 'publish'
    }
  ];

  const { error: wisataError } = await supabase.from('potensi_wisata').upsert(wisataData);
  if (wisataError) console.error('Error seeding potensi_wisata:', wisataError);
  else console.log('✅ potensi_wisata: 3 rows');

  // 5. Seed potensi_umkm
  console.log('\n🏪 Seeding potensi_umkm...');
  const umkmData = [
    {
      tenant_id: tenantId,
      tipe: 'Kuliner',
      nama: 'UMKM Madu Trigona Seruni',
      pemilik: 'Hj. Rina',
      sektor: 'Perlebahan',
      dusun: 'Mandar',
      kontak: '+6281234567101',
      deskripsi: 'Madu trigona premium dari hutan Lombok Timur.',
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      tipe: 'Kuliner',
      nama: 'Koperasi Tani Maju',
      pemilik: 'Andi Rahman',
      sektor: 'Pertanian',
      dusun: 'Sasak',
      kontak: '+6281234567102',
      deskripsi: 'Kopi robusta pilihan dari dataran tinggi Lombok.',
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      tipe: 'Kerajinan',
      nama: 'Sanggar Tenun Ibu Aminah',
      pemilik: 'Siti Aminah',
      sektor: 'Kerajinan',
      dusun: 'Dames',
      kontak: '+6281234567103',
      deskripsi: 'Tenun songket Sasak dengan motif tradisional.',
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      tipe: 'Kuliner',
      nama: 'UMKM Brangtapen Asri Mumbul',
      pemilik: 'H. Basri',
      sektor: 'Perikanan',
      dusun: 'Brangtapen Asri',
      kontak: '+6281234567104',
      deskripsi: 'Olahan rumput laut dan hasil tangkapan segar.',
      status: 'publish'
    }
  ];

  const { error: umkmError } = await supabase.from('potensi_umkm').upsert(umkmData);
  if (umkmError) console.error('Error seeding potensi_umkm:', umkmError);
  else console.log('✅ potensi_umkm: 4 rows');

  // 6. Seed potensi_produk
  console.log('\n🛒 Seeding potensi_produk...');
  const produkData = [
    {
      tenant_id: tenantId,
      penjual_nama: 'Hj. Rina',
      nama: 'Madu Trigona Seruni 500ml',
      kategori: 'Makanan',
      harga: 95000,
      satuan: 'botol',
      stok: 50,
      deskripsi: 'Madu trigona premium dari hutan Lombok Timur.',
      featured: true,
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      penjual_nama: 'Andi Rahman',
      nama: 'Kopi Robusta Sembalun 250g',
      kategori: 'Minuman',
      harga: 65000,
      satuan: '250g',
      stok: 100,
      deskripsi: 'Kopi robusta pilihan dari dataran tinggi Lombok.',
      featured: true,
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      penjual_nama: 'Siti Aminah',
      nama: 'Tenun Songket Sasak Motif Seruni',
      kategori: 'Kerajinan',
      harga: 450000,
      satuan: 'helai',
      stok: 15,
      deskripsi: 'Tenun songket asli dengan motif tradisional Sasak.',
      featured: true,
      status: 'publish'
    },
    {
      tenant_id: tenantId,
      penjual_nama: 'H. Basri',
      nama: 'Kerupuk Rumput Laut 200g',
      kategori: 'Makanan',
      harga: 22000,
      satuan: 'bungkus',
      stok: 200,
      deskripsi: 'Kerupuk rumput laut dari pantai Lombok Timur.',
      featured: true,
      status: 'publish'
    }
  ];

  const { error: produkError } = await supabase.from('potensi_produk').upsert(produkData);
  if (produkError) console.error('Error seeding potensi_produk:', produkError);
  else console.log('✅ potensi_produk: 4 rows');

  // 7. Seed kegiatan_pembangunan
  console.log('\n🏗️ Seeding kegiatan_pembangunan...');
  const pembangunanData = [
    {
      tenant_id: tenantId,
      tahun: 2026,
      bidang: 'Pembangunan Desa',
      nama_kegiatan: 'Rehabilitasi Saluran Irigasi Mandar',
      lokasi: 'Mandar',
      volume: '1.2 km',
      anggaran: 280000000,
      realisasi: 229600000,
      sumber_dana: 'APBDes',
      status: 'diproses'
    },
    {
      tenant_id: tenantId,
      tahun: 2026,
      bidang: 'Pembangunan Desa',
      nama_kegiatan: 'Pembangunan MCK Umum Pasar Seruni',
      lokasi: 'Pusat Desa',
      volume: '1 unit',
      anggaran: 150000000,
      realisasi: 67500000,
      sumber_dana: 'APBDes',
      status: 'diproses'
    },
    {
      tenant_id: tenantId,
      tahun: 2026,
      bidang: 'Pembangunan Desa',
      nama_kegiatan: 'Pengadaan Lampu PJU Tenaga Surya',
      lokasi: 'Seluruh Desa',
      volume: '30 titik',
      anggaran: 90000000,
      realizations: 27000000,
      sumber_dana: 'APBDes',
      status: 'diproses'
    }
  ];

  const { error: pembangunanError } = await supabase.from('kegiatan_pembangunan').upsert(pembangunanData);
  if (pembangunanError) console.error('Error seeding kegiatan_pembangunan:', pembangunanError);
  else console.log('✅ kegiatan_pembangunan: 3 rows');

  // 8. Seed usulan_warga
  console.log('\n📝 Seeding usulan_warga...');
  const usulanData = [
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-001',
      nama: 'Ahmad Zulkifli',
      kontak: '+6281234567001',
      dusun: 'Mandar',
      kategori: 'infrastruktur',
      judul: 'Perbaikan Jalan Poros Mandar-Sasak',
      deskripsi: 'Jalan rusak sepanjang 2,3 km menghubungkan Mandar ke pusat desa.',
      lokasi: 'Mandar-Sasak',
      status: 'ditindaklanjuti',
      vote_count: 342
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-002',
      nama: 'Siti Aminah',
      kontak: '+6281234567002',
      dusun: 'Dames',
      kategori: 'pendidikan',
      judul: 'Pembangunan PAUD Terpadu Mandar',
      deskripsi: 'PAUD untuk 87 balita di Mandar.',
      lokasi: 'Dames',
      status: 'ditindaklanjuti',
      vote_count: 289
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-003',
      nama: 'Muhammad Ali',
      kontak: '+6281234567003',
      dusun: 'Brangtapen Asri',
      kategori: 'infrastruktur',
      judul: 'Sumur Bor Air Bersih Mandar Brangtapen Asri',
      deskripsi: 'Air bersih terbatas di musim kemarau.',
      lokasi: 'Brangtapen Asri',
      status: 'diverifikasi',
      vote_count: 251
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-004',
      nama: 'Hajjah Rahayu',
      kontak: '+6281234567004',
      dusun: 'Dames',
      kategori: 'kesehatan',
      judul: 'Renovasi Poskesdes Utama',
      deskripsi: 'Poskesdes perlu renovasi dan penambahan peralatan.',
      lokasi: 'Pusat Desa',
      status: 'diverifikasi',
      vote_count: 198
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-005',
      nama: 'Budi Santoso',
      kontak: '+6281234567005',
      dusun: 'Brangtapen Asri',
      kategori: 'sosial',
      judul: 'Beasiswa Anak Nelayan Tidak Mampu',
      deskripsi: '12 anak keluarga nelayan tidak mampu.',
      lokasi: 'Brangtapen Asri',
      status: 'ditindaklanjuti',
      vote_count: 176
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-006',
      nama: 'Rina Marlina',
      kontak: '+6281234567006',
      dusun: 'Mandar',
      kategori: 'ekonomi',
      judul: 'Pelatihan Digital Marketing UMKM',
      deskripsi: 'Pemasaran digital untuk UMKM desa.',
      lokasi: 'Mandar',
      status: 'diverifikasi',
      vote_count: 154
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-007',
      nama: 'H. Lalu Husain',
      kontak: '+6281234567007',
      dusun: 'Brangtapen Asri',
      kategori: 'lingkungan',
      judul: 'Pengadaan Kapal Sampah Pantai',
      deskripsi: 'Pengelolaan sampah plastik di pesisir.',
      lokasi: 'Brangtapen Asri',
      status: 'diverifikasi',
      vote_count: 132
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-008',
      nama: 'Nurhayati',
      kontak: '+6281234567008',
      dusun: 'Sasak',
      kategori: 'pendidikan',
      judul: 'Rumah Baca Anak Sasak',
      deskripsi: 'Ruang baca untuk anak-anak.',
      lokasi: 'Sasak',
      status: 'diverifikasi',
      vote_count: 118
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-009',
      nama: 'Ahmad Fauzi',
      kontak: '+6281234567009',
      dusun: 'Mandar',
      kategori: 'sosial',
      judul: 'Rehabilitasi Lapangan Sepakbola',
      deskripsi: 'Lapangan perlu rehab.',
      lokasi: 'Mandar',
      status: 'diverifikasi',
      vote_count: 97
    },
    {
      tenant_id: tenantId,
      nomor_tiket: 'USL-2026-010',
      nama: 'Siti Zahra',
      kontak: '+6281234567010',
      dusun: 'Brangtapen Asri',
      kategori: 'lingkungan',
      judul: 'Bank Sampah Terpadu',
      deskripsi: 'Pengelolaan sampah terpadu.',
      lokasi: 'Brangtapen Asri',
      status: 'diverifikasi',
      vote_count: 84
    }
  ];

  const { error: usulanError } = await supabase.from('usulan_warga').upsert(usulanData, { onConflict: 'nomor_tiket' });
  if (usulanError) console.error('Error seeding usulan_warga:', usulanError);
  else console.log('✅ usulan_warga: 10 rows');

  // 9. Seed idm_status_desa
  console.log('\n📊 Seeding idm_status_desa...');
  const idmData = {
    tenant_id: tenantId,
    status: 'Berkembang',
    total_skor: 0.7412,
    dimensi_scores: {
      'Kesehatan': 0.84,
      'Pendidikan': 0.90,
      'Modal Sosial': 0.76,
      'Permukiman': 0.82,
      'Ekonomi': 0.72,
      'Ekologi': 0.88
    }
  };

  const { error: idmError } = await supabase.from('idm_status_desa').upsert(idmData, { onConflict: 'tenant_id' });
  if (idmError) console.error('Error seeding idm_status_desa:', idmError);
  else console.log('✅ idm_status_desa: 1 row');

  // 10. Seed wilayah_dusun dengan data real
  console.log('\n🗺️ Seeding wilayah_dusun...');
  const dusunData = [
    { tenant_id: tenantId, nama: 'Mandar', kk: 678, jiwa: 2378, luas_ha: 285, urutan: 1 },
    { tenant_id: tenantId, nama: 'Sasak', kk: 712, jiwa: 2413, luas_ha: 302, urutan: 2 },
    { tenant_id: tenantId, nama: 'Dames', kk: 543, jiwa: 1348, luas_ha: 198, urutan: 3 },
    { tenant_id: tenantId, nama: 'Brangtapen Asri', kk: 542, jiwa: 1728, luas_ha: 215, urutan: 4 }
  ];

  // Delete existing and re-insert for accurate data
  await supabase.from('wilayah_dusun').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  const { error: dusunError } = await supabase.from('wilayah_dusun').insert(dusunData);
  if (dusunError) console.error('Error seeding wilayah_dusun:', dusunError);
  else console.log('✅ wilayah_dusun: 4 rows (2378+2413+1348+1728 = 7867 penduduk)');

  console.log('\n🎉 Database population complete!');
  console.log('\nSummary:');
  console.log('- berita: Kabar terbaru');
  console.log('- agenda: 5 agenda kegiatan');
  console.log('- galeri: 9 foto dokumentasi');
  console.log('- potensi_wisata: 3 destinasi');
  console.log('- potensi_umkm: 4 UMKM');
  console.log('- potensi_produk: 4 produk marketplace');
  console.log('- kegiatan_pembangunan: 3 kegiatan 2026');
  console.log('- usulan_warga: 10 usulan warga');
  console.log('- idm_status_desa: skor 0.7412');
  console.log('- wilayah_dusun: 4 dusun (7867 penduduk)');
}

seedData().catch(console.error);
