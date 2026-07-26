/**
 * Seed Script - Fixed version using Supabase REST API
 * Run: node scripts/seed-fixed-api.mjs
 */

const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

async function supabaseDelete(table, filter = '') {
  const url = filter
    ? `${SUPABASE_URL}/rest/v1/${table}?${filter}`
    : `${SUPABASE_URL}/rest/v1/${table}?id=neq.00000000-0000-0000-0000-000000000000`;

  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`
    }
  });

  // Supabase returns 204 No Content on success
  if (!response.ok && response.status !== 204) {
    const data = await response.json().catch(() => ({}));
    throw new Error(`${table} DELETE: ${data.message || response.statusText}`);
  }
  return true;
}

async function supabasePost(table, body) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: JSON.stringify(body)
  });

  // Handle 201 Created or 200 OK
  const data = await response.json().catch(() => []);

  if (!response.ok) {
    const errMsg = Array.isArray(data) ? data[0]?.message : data?.message;
    throw new Error(`${table}: ${errMsg || response.statusText}`);
  }
  return data;
}

async function supabaseUpsert(table, body, conflict = '') {
  const params = conflict ? `?on_conflict=${conflict}` : '';
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}${params}`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'resolution=merge-duplicates'
    },
    body: JSON.stringify(body)
  });

  const data = await response.json().catch(() => []);

  if (!response.ok) {
    const errMsg = Array.isArray(data) ? data[0]?.message : data?.message;
    throw new Error(`${table}: ${errMsg || response.statusText}`);
  }
  return data;
}

async function seed() {
  console.log('Starting seed via REST API...\n');

  // Get tenant ID
  const tenantRes = await fetch(`${SUPABASE_URL}/rest/v1/tenants?select=id,subdomain`, {
    headers: { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}` }
  });
  const tenants = await tenantRes.json();
  const tenant = tenants.find(t => t.subdomain === 'seruni');

  if (!tenant) {
    console.error('Tenant "seruni" not found!');
    console.log('Available:', JSON.stringify(tenants, null, 2));
    process.exit(1);
  }
  console.log('Tenant ID:', tenant.id);
  console.log('');

  // ============================================================
  // 1. WILAYAH DUSUN
  // ============================================================
  console.log('Seeding wilayah_dusun...');
  await supabaseDelete('wilayah_dusun', `tenant_id=eq.${tenant.id}`);
  await supabasePost('wilayah_dusun', [
    { tenant_id: tenant.id, nama: 'Mandar', kk: 678, jiwa: 2378, luas_ha: 285, urutan: 1 },
    { tenant_id: tenant.id, nama: 'Sasak', kk: 712, jiwa: 2413, luas_ha: 302, urutan: 2 },
    { tenant_id: tenant.id, nama: 'Dames', kk: 543, jiwa: 1348, luas_ha: 198, urutan: 3 },
    { tenant_id: tenant.id, nama: 'Brangtapen Asri', kk: 542, jiwa: 1728, luas_ha: 215, urutan: 4 }
  ]);
  console.log('wilayah_dusun: 4 dusun (7867 penduduk)\n');

  // ============================================================
  // 2. BERITA
  // ============================================================
  console.log('Seeding berita...');
  await supabaseDelete('berita');
  await supabasePost('berita', [
    {
      slug: 'progres-pengerasan-jalan-mandar',
      kategori: 'Pembangunan',
      judul: 'Progres Pengerasan Jalan Mandar Mencapai 78%',
      ringkasan: 'Kegiatan pengerasan jalan sepanjang 1,2 km ditargetkan rampung akhir Agustus.',
      isi: '["Pengerjaan pengerasan Jalan Poros Mandar sepanjang 1,2 km telah mencapai progres fisik 78%.","Kegiatan ini didanai APBDes 2026 dengan pagu Rp 480 juta.","Target selesai 28 Agustus 2026.","Mengurangi waktu tempuh dari 22 menit menjadi 9 menit."]',
      penulis: 'Kasi Pembangunan',
      tanggal: '2026-07-17',
      published: true
    },
    {
      slug: 'stunting-turun-12-persen',
      kategori: 'Kesehatan',
      judul: 'Kasus Stunting Turun 12% Setelah Program PMT Terpadu',
      ringkasan: 'Hasil evaluasi Posyandu semester I menunjukkan penurunan prevalensi stunting.',
      isi: '["PMT lokal menurunkan stunting dari 18,4% menjadi 16,2%.","412 balita terpantau.","Alokasi Rp 60 juta semester II."]',
      penulis: 'Kasi Kesejahteraan',
      tanggal: '2026-07-15',
      published: true
    },
    {
      slug: 'bumdes-buka-marketplace',
      kategori: 'Ekonomi',
      judul: 'BUMDes Seruni Buka Gerai Marketplace Digital',
      ringkasan: 'Marketplace desa menampung 47 produk UMKM lokal.',
      isi: '["47 produk UMKM tersedia.","Transaksi pertama Rp 42 juta.","Pengiriman seluruh Lombok."]',
      penulis: 'Directeur BUMDes',
      tanggal: '2026-07-12',
      published: true
    },
    {
      slug: 'musdes-rkpdes-2027',
      kategori: 'Perencanaan',
      judul: 'Jadwal Musdes Perencanaan RKPDes 2027',
      ringkasan: 'Musyawarah desa diagendakan 28 Juli 2026.',
      isi: '["Pembahasan prioritas pembangunan.","Alokasi APBDes.","Sinkronisasi usulan warga."]',
      penulis: 'Kaur Perencanaan',
      tanggal: '2026-07-10',
      published: true
    }
  ]);
  console.log('berita: 4 artikel\n');

  // ============================================================
  // 3. AGENDA
  // ============================================================
  console.log('Seeding agenda...');
  await supabaseDelete('agenda');
  await supabasePost('agenda', [
    { slug: 'musdes-rkpdes-2027', jenis: 'Musdes', judul: 'Musyawarah Desa Perencanaan RKPDes 2027', tanggal: '2026-07-28', waktu: '08.30-12.00 WITA', lokasi: 'Aula Kantor Desa', penyelenggara: 'Pemerintah Desa & BPD', deskripsi: 'Pembahasan prioritas pembangunan 2027.' },
    { slug: 'posyandu-mandar', jenis: 'Posyandu', judul: 'Posyandu Balita Mandar', tanggal: '2026-07-30', waktu: '08.00-11.00 WITA', lokasi: 'Posyandu Melati III', penyelenggara: 'PKK & Puskesmas', deskripsi: 'Penimbangan dan imunisasi balita.' },
    { slug: 'gotong-royong-pantai', jenis: 'Gotong Royong', judul: 'Kerja Bakti Bersih Pantai Seruni', tanggal: '2026-08-02', waktu: '07.00-10.00 WITA', lokasi: 'Pantai Seruni', penyelenggara: 'Karang Taruna & BUMDes', deskripsi: 'Aksi bersih pantai HUT ke-58.' },
    { slug: 'sosialisasi-bansos', jenis: 'Sosialisasi', judul: 'Sosialisasi Bansos Semester II', tanggal: '2026-08-05', waktu: '13.30-16.00 WITA', lokasi: 'Balai Mandar', penyelenggara: 'Kasi Kesejahteraan', deskripsi: 'Penjelasan BPNT dan PKH.' },
    { slug: 'pelatihan-digital', jenis: 'Pelatihan', judul: 'Pelatihan Digital Marketing', tanggal: '2026-08-10', waktu: '09.00-15.00 WITA', lokasi: 'Aula BUMDes', penyelenggara: 'BUMDes & Disperdagin', deskripsi: 'Pemasaran digital untuk UMKM.' }
  ]);
  console.log('agenda: 5 agenda\n');

  // ============================================================
  // 4. GALERI
  // ============================================================
  console.log('Seeding galeri...');
  await supabaseDelete('galeri');
  await supabasePost('galeri', [
    { judul: 'Festival Panen Raya 2026', emoji: 'festival', album: 'Kegiatan Desa', tanggal: '2026-04-18', urutan: 1 },
    { judul: 'Musdes Perencanaan', emoji: 'musyawarah', album: 'Kegiatan Desa', tanggal: '2026-03-12', urutan: 2 },
    { judul: 'Posyandu Balita', emoji: 'bayi', album: 'Kesehatan', tanggal: '2026-05-08', urutan: 3 },
    { judul: 'Gotong Royong Pantai', emoji: 'pantai', album: 'Lingkungan', tanggal: '2026-06-15', urutan: 4 },
    { judul: 'Pelatihan UMKM Digital', emoji: 'pelatihan', album: 'Ekonomi', tanggal: '2026-06-22', urutan: 5 },
    { judul: 'Turnamen Bola', emoji: 'bola', album: 'Olahraga', tanggal: '2026-05-30', urutan: 6 },
    { judul: 'Peresmian PJU Solar', emoji: 'lampu', album: 'Pembangunan', tanggal: '2026-04-02', urutan: 7 },
    { judul: 'Kirab Budaya Sasak', emoji: 'budaya', album: 'Budaya', tanggal: '2026-03-25', urutan: 8 }
  ]);
  console.log('galeri: 8 foto\n');

  // ============================================================
  // 5. PENGUMUMAN
  // ============================================================
  console.log('Seeding pengumuman...');
  await supabaseDelete('pengumuman');
  await supabasePost('pengumuman', [
    { nomor: '148/PMR/SM/VII/2026', tanggal: '2026-07-16', judul: 'Jadwal Musdes Perencanaan RKPDes 2027', ringkasan: 'Undangan untuk perwakilan dusun.' },
    { nomor: '146/PMR/SM/VII/2026', tanggal: '2026-07-10', judul: 'Pemadaman Air Bersih', ringkasan: 'Perbaikan pipa PAMDes.' },
    { nomor: '142/PMR/SM/VII/2026', tanggal: '2026-07-04', judul: 'Pendaftaran Beasiswa', ringkasan: '5-20 Juli 2026.' },
    { nomor: '138/PMR/SM/VI/2026', tanggal: '2026-06-28', judul: 'Verifikasi Ulang DTKS', ringkasan: 'Kader dusun berkunjung.' }
  ]);
  console.log('pengumuman: 4 pengumuman\n');

  // ============================================================
  // 6. POTENSI WISATA
  // ============================================================
  console.log('Seeding potensi_wisata...');
  await supabaseDelete('potensi_wisata', `tenant_id=eq.${tenant.id}`);
  await supabasePost('potensi_wisata', [
    { tenant_id: tenant.id, nama: 'Pantai Seruni Mumbul', jenis: 'Wisata Bahari', dusun: 'Brangtapen Asri', deskripsi: 'Pantai berpasir putih 2,4 km dengan snorkeling.', fasilitas: 'Gazebo, MCK, Warung', latitude: -8.5432, longitude: 116.6543, status: 'publish' },
    { tenant_id: tenant.id, nama: 'Bukit Panorama', jenis: 'Ekowisata', dusun: 'Sasak', deskripsi: 'Titik pandang matahari terbit di 380 mdpl.', fasilitas: 'Jalur tracking', latitude: -8.5210, longitude: 116.6780, status: 'publish' },
    { tenant_id: tenant.id, nama: 'Sentra Tenun Songket', jenis: 'Wisata Budaya', dusun: 'Mandar', deskripsi: 'Sanggar tenun aktif.', fasilitas: 'Sanggar tenun', latitude: -8.5350, longitude: 116.6620, status: 'publish' }
  ]);
  console.log('potensi_wisata: 3 destinasi\n');

  // ============================================================
  // 7. POTENSI UMKM
  // ============================================================
  console.log('Seeding potensi_umkm...');
  await supabaseDelete('potensi_umkm', `tenant_id=eq.${tenant.id}`);
  await supabasePost('potensi_umkm', [
    { tenant_id: tenant.id, tipe: 'Kuliner', nama: 'UMKM Madu Trigona', pemilik: 'Hj. Rina', sektor: 'Perlebahan', dusun: 'Mandar', kontak: '+6281234567101', deskripsi: 'Madu trigona premium.', status: 'publish' },
    { tenant_id: tenant.id, tipe: 'Kuliner', nama: 'Koperasi Tani Maju', pemilik: 'Andi Rahman', sektor: 'Pertanian', dusun: 'Sasak', kontak: '+6281234567102', deskripsi: 'Kopi robusta pilihan.', status: 'publish' },
    { tenant_id: tenant.id, tipe: 'Kerajinan', nama: 'Sanggar Tenun', pemilik: 'Siti Aminah', sektor: 'Kerajinan', dusun: 'Mandar', kontak: '+6281234567103', deskripsi: 'Tenun songket Sasak.', status: 'publish' },
    { tenant_id: tenant.id, tipe: 'Kuliner', nama: 'UMKM Rumput Laut', pemilik: 'H. Basri', sektor: 'Perikanan', dusun: 'Brangtapen Asri', kontak: '+6281234567104', deskripsi: 'Olahan rumput laut.', status: 'publish' }
  ]);
  console.log('potensi_umkm: 4 UMKM\n');

  // ============================================================
  // 8. POTENSI PRODUK
  // ============================================================
  console.log('Seeding potensi_produk...');
  await supabaseDelete('potensi_produk', `tenant_id=eq.${tenant.id}`);
  await supabasePost('potensi_produk', [
    { tenant_id: tenant.id, penjual_nama: 'Hj. Rina', nama: 'Madu Trigona 500ml', kategori: 'Makanan', harga: 95000, satuan: 'botol', stok: 50, deskripsi: 'Madu trigona premium.', featured: true, status: 'publish' },
    { tenant_id: tenant.id, penjual_nama: 'Andi Rahman', nama: 'Kopi Robusta 250g', kategori: 'Minuman', harga: 65000, satuan: '250g', stok: 100, deskripsi: 'Kopi robusta pilihan.', featured: true, status: 'publish' },
    { tenant_id: tenant.id, penjual_nama: 'Siti Aminah', nama: 'Tenun Songket', kategori: 'Kerajinan', harga: 450000, satuan: 'helai', stok: 15, deskripsi: 'Tenun songket asli.', featured: true, status: 'publish' },
    { tenant_id: tenant.id, penjual_nama: 'H. Basri', nama: 'Kerupuk Rumput Laut', kategori: 'Makanan', harga: 22000, satuan: 'bungkus', stok: 200, deskripsi: 'Kerupuk rumput laut.', featured: true, status: 'publish' }
  ]);
  console.log('potensi_produk: 4 produk\n');

  // ============================================================
  // 9. KEGIATAN PEMBANGUNAN
  // ============================================================
  console.log('Seeding kegiatan_pembangunan...');
  await supabaseDelete('kegiatan_pembangunan', `tenant_id=eq.${tenant.id}`);
  await supabasePost('kegiatan_pembangunan', [
    { tenant_id: tenant.id, tahun: 2026, bidang: 'Pembangunan Desa', nama_kegiatan: 'Rehabilitasi Saluran Irigasi', lokasi: 'Mandar', volume: '1.2 km', anggaran: 280000000, realisasi: 229600000, sumber_dana: 'APBDes', status: 'diproses' },
    { tenant_id: tenant.id, tahun: 2026, bidang: 'Pembangunan Desa', nama_kegiatan: 'Pembangunan MCK Pasar', lokasi: 'Pusat Desa', volume: '1 unit', anggaran: 150000000, realisasi: 67500000, sumber_dana: 'APBDes', status: 'diproses' },
    { tenant_id: tenant.id, tahun: 2026, bidang: 'Pembangunan Desa', nama_kegiatan: 'Pengadaan PJU Surya', lokasi: 'Seluruh Desa', volume: '30 titik', anggaran: 90000000, realisasi: 27000000, sumber_dana: 'APBDes', status: 'diproses' }
  ]);
  console.log('kegiatan_pembangunan: 3 kegiatan\n');

  // ============================================================
  // 10. USULAN WARGA
  // ============================================================
  console.log('Seeding usulan_warga...');
  await supabaseDelete('usulan_warga', `tenant_id=eq.${tenant.id}`);
  await supabasePost('usulan_warga', [
    { tenant_id: tenant.id, nomor_tiket: 'USL-2026-001', nama: 'Ahmad Zulkifli', kontak: '+6281234567001', dusun: 'Mandar', kategori: 'infrastruktur', judul: 'Perbaikan Jalan Mandar-Sasak', deskripsi: 'Jalan rusak 2,3 km.', lokasi: 'Mandar-Sasak', status: 'ditindaklanjuti', vote_count: 342 },
    { tenant_id: tenant.id, nomor_tiket: 'USL-2026-002', nama: 'Siti Aminah', kontak: '+6281234567002', dusun: 'Mandar', kategori: 'pendidikan', judul: 'Pembangunan PAUD', deskripsi: 'PAUD untuk 87 balita.', lokasi: 'Mandar', status: 'ditindaklanjuti', vote_count: 289 },
    { tenant_id: tenant.id, nomor_tiket: 'USL-2026-003', nama: 'Muhammad Ali', kontak: '+6281234567003', dusun: 'Brangtapen Asri', kategori: 'infrastruktur', judul: 'Sumur Bor Air Bersih', deskripsi: 'Air bersih terbatas.', lokasi: 'Brangtapen Asri', status: 'diverifikasi', vote_count: 251 },
    { tenant_id: tenant.id, nomor_tiket: 'USL-2026-004', nama: 'Hajjah Rahayu', kontak: '+6281234567004', dusun: 'Mandar', kategori: 'kesehatan', judul: 'Renovasi Poskesdes', deskripsi: 'Poskesdes perlu renovasi.', lokasi: 'Pusat Desa', status: 'diverifikasi', vote_count: 198 },
    { tenant_id: tenant.id, nomor_tiket: 'USL-2026-005', nama: 'Budi Santoso', kontak: '+6281234567005', dusun: 'Brangtapen Asri', kategori: 'sosial', judul: 'Beasiswa Nelayan', deskripsi: '12 anak nelayan.', lokasi: 'Brangtapen Asri', status: 'ditindaklanjuti', vote_count: 176 }
  ]);
  console.log('usulan_warga: 5 usulan\n');

  // ============================================================
  // 11. IDM STATUS DESA
  // ============================================================
  console.log('Seeding idm_status_desa...');
  await supabaseDelete('idm_status_desa', `tenant_id=eq.${tenant.id}`);
  await supabasePost('idm_status_desa', [
    { tenant_id: tenant.id, status: 'Berkembang', total_skor: 0.7412, dimensi_scores: { 'Kesehatan': 0.84, 'Pendidikan': 0.90, 'Modal Sosial': 0.76, 'Permukiman': 0.82, 'Ekonomi': 0.72, 'Ekologi': 0.88 } }
  ]);
  console.log('idm_status_desa: skor 0.7412\n');

  // ============================================================
  // 12. DESA PAMONG
  // ============================================================
  console.log('Seeding desa_pamong...');
  await supabaseDelete('desa_pamong', `tenant_id=eq.${tenant.id}`);
  await supabasePost('desa_pamong', [
    { tenant_id: tenant.id, nama: 'H. Lalu Ahmad Saputra', jabatan: 'Kepala Desa', periode: '2024-2030', urutan: 1 },
    { tenant_id: tenant.id, nama: 'Baiq Nuraini', jabatan: 'Sekretaris Desa', periode: null, urutan: 2 },
    { tenant_id: tenant.id, nama: 'Muhammad Sabri', jabatan: 'Kasi Pemerintahan', periode: null, urutan: 3 },
    { tenant_id: tenant.id, nama: 'Lalu Zainuddin', jabatan: 'Kasi Kesejahteraan', periode: null, urutan: 4 },
    { tenant_id: tenant.id, nama: 'Hj. Sri Wahyuni', jabatan: 'Kasi Pelayanan', periode: null, urutan: 5 },
    { tenant_id: tenant.id, nama: 'Baiq Rahma Dewi', jabatan: 'Kaur Keuangan', periode: null, urutan: 6 }
  ]);
  console.log('desa_pamong: 6 perangkat\n');

  // ============================================================
  // 13. LEMBAGA DESA
  // ============================================================
  console.log('Seeding lembaga_desa...');
  await supabaseDelete('lembaga_desa', `tenant_id=eq.${tenant.id}`);
  await supabasePost('lembaga_desa', [
    { tenant_id: tenant.id, nama: 'Badan Permusyawaratan Desa (BPD)', ketua: 'H. Muhaimin', jumlah_anggota: 9, urutan: 1 },
    { tenant_id: tenant.id, nama: 'LPMD', ketua: 'Lalu Sudirman', jumlah_anggota: 11, urutan: 2 },
    { tenant_id: tenant.id, nama: 'PKK Desa', ketua: 'Hj. Nurhayati', jumlah_anggota: 25, urutan: 3 },
    { tenant_id: tenant.id, nama: 'Karang Taruna', ketua: 'Ahmad Rizki', jumlah_anggota: 42, urutan: 4 },
    { tenant_id: tenant.id, nama: 'BUMDes Bina Seruni Mandiri', ketua: 'Baiq Salma', jumlah_anggota: 7, urutan: 5 }
  ]);
  console.log('lembaga_desa: 5 lembaga\n');

  console.log('='.repeat(50));
  console.log('DATABASE SEEDING COMPLETE!');
  console.log('='.repeat(50));
}

seed().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
