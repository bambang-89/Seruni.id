// Data contoh untuk Desa Seruni Mumbul — Phase 1 stub.
// Di implementasi Next.js sesungguhnya, data ini datang dari:
//   site_settings, site_content_blocks, site_navigation, dashboard_agregat,
//   artikel_desa, agenda_kegiatan, dst. (lihat §D1.1 DESAIN_FRONTEND)
// Tidak ada teks/warna hardcode di komponen — semua props diambil dari sini.

// NOTE: Untuk konsistensi dengan database site_settings.social_media,
// field ini menggunakan nama 'social_media' (bukan 'sosial').
// Seed data berikut adalah fallback jika database belum terisi.
export const siteSettings = {
  nama_resmi: "Desa Seruni Mumbul",
  wilayah: "Kecamatan Pringgabaya, Kabupaten Lombok Timur, NTB",
  tagline: "Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.",
  jam_layanan: "Senin–Jumat · 08.00–15.00 WITA",
  alamat_kantor: "Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654",
  nomor_wa_resmi: "+6281200000000",
  wa_business_verified: true,
  telepon_darurat: "(0376) 000-0000",
  email: "kantor@serunimumbul.desa.id",
  sosial: {
    facebook: "https://facebook.com/desa.serunimumbul",
    instagram: "https://instagram.com/desa.serunimumbul",
    youtube: "https://youtube.com/@desa.serunimumbul",
  },
};

// §D2.5 — Navbar 6 kategori utama
export const navigation = [
  {
    label: "Profil",
    href: "/profil-desa",
    children: [
      { label: "Sejarah", href: "/profil-desa", desc: "Asal-usul, visi & misi" },
      { label: "Struktur", href: "/profil-desa/struktur", desc: "Kepala desa & perangkat" },
      { label: "Wilayah", href: "/profil-desa/wilayah", desc: "Batas & topografi" },
      { label: "Lembaga", href: "/profil-desa/lembaga", desc: "BPD, LPM, PKK & Karang Taruna" },
    ],
  },
  {
    label: "Informasi",
    href: "/berita",
    children: [
      { label: "Berita", href: "/berita", desc: "Kabar terbaru dari desa" },
      { label: "Pengumuman", href: "/pengumuman", desc: "Maklumat & informasi resmi" },
      { label: "Agenda", href: "/kalender-desa", desc: "Kalender kegiatan resmi" },
      { label: "Galeri", href: "/galeri", desc: "Foto & video dokumentasi" },
    ],
  },
  {
    label: "Layanan",
    href: "/layanan",
    children: [
      { label: "Ajukan Surat", href: "/layanan/surat", desc: "Ajukan surat online" },
      { label: "Cek Tagihan PBB", href: "/layanan/pbb", desc: "Cek tagihan Pajak Bumi & Bangunan" },
      { label: "Pengaduan", href: "/service-center", desc: "Sampaikan aduan & aspirasi" },
      { label: "Verifikasi", href: "/verifikasi", desc: "Cek keaslian dokumen" },
      { label: "Langganan WA", href: "/langganan-wa", desc: "Daftar info via WhatsApp" },
      { label: "Suplesi", href: "/layanan/suplesi", desc: "Cek data tumpang tindih" },
    ],
  },
  {
    label: "Data",
    href: "/statistik",
    children: [
      { label: "Statistik Penduduk", href: "/statistik/penduduk", desc: "Demografi & KK" },
      { label: "Status IDM", href: "/status-idm", desc: "Indeks Desa Membangun" },
      { label: "Analisis", href: "/analisis", desc: "Analisis data desa" },
      { label: "Peta Desa", href: "/peta-desa", desc: "Peta interaktif" },
    ],
  },
  {
    label: "Potensi",
    href: "/potensi-desa",
    children: [
      { label: "UMKM", href: "/potensi-desa#ekonomi", desc: "Ekonomi kreatif & usaha" },
      { label: "Pariwisata", href: "/potensi-desa#pariwisata", desc: "Destinasi & atraksi" },
      { label: "Marketplace", href: "/marketplace", desc: "Produk unggulan warga" },
    ],
  },
  {
    label: "Pembangunan",
    href: "/perencanaan",
    children: [
      { label: "Voting", href: "/partisipasi/voting", desc: "Suara untuk pembangunan" },
      { label: "Usulan", href: "/partisipasi/usulan", desc: "Ajukan gagasan" },
      { label: "RPJMDes", href: "/perencanaan/rpjmdes", desc: "Rencana 6 tahunan" },
      { label: "RKPDes", href: "/perencanaan/rkpdes", desc: "Rencana kerja tahunan" },
      { label: "Keuangan", href: "/keuangan", desc: "APBDes & realize" },
    ],
  },
];

// dashboard_agregat — angka dari worker (di sini: contoh statis)
export const idm = {
  status: "Berkembang", // mandiri | maju | berkembang | tertinggal | sangat_tertinggal
  skor_total: 0.7412,
  dimensi: [
    { nama: "Kesehatan", skor: 4.2 },
    { nama: "Pendidikan", skor: 4.5 },
    { nama: "Modal Sosial", skor: 3.8 },
    { nama: "Permukiman", skor: 4.1 },
    { nama: "Ekonomi", skor: 3.6 },
    { nama: "Ekologi", skor: 4.4 },
  ],
};

export const statistikDesa = {
  jumlah_penduduk: 6842,
  jumlah_kk: 1937,
  jumlah_dusun: 4,
  luas_wilayah_km2: 12.4,
  laki_laki: 3421,
  perempuan: 3421,
};

export const agendaMendatang = [
  { slug: "musdes-rkpdes-2027", jenis: "Musdes", judul: "Musyawarah Desa Perencanaan RKPDes 2027", tanggal: "2026-07-28", waktu: "08.30–12.00 WITA", lokasi: "Aula Kantor Desa", penyelenggara: "Pemerintah Desa & BPD", deskripsi: "Pembahasan prioritas pembangunan, alokasi APBDes, dan sinkronisasi usulan warga hasil voting daring untuk tahun anggaran 2027." },
  { slug: "posyandu-karang-baru", jenis: "Posyandu", judul: "Posyandu Balita Dusun Mandar", tanggal: "2026-07-30", waktu: "08.00–11.00 WITA", lokasi: "Posyandu Melati III", penyelenggara: "PKK Desa & Puskesmas Pringgabaya", deskripsi: "Penimbangan, pengukuran, imunisasi lanjutan, serta pembagian PMT untuk balita 0–5 tahun di Dusun Mandar." },
  { slug: "gotong-royong-pantai", jenis: "Gotong Royong", judul: "Kerja Bakti Bersih Pantai Seruni", tanggal: "2026-08-02", waktu: "07.00–10.00 WITA", lokasi: "Pantai Seruni Mumbul", penyelenggara: "Karang Taruna & BUMDes", deskripsi: "Aksi bersih pantai lintas dusun dalam rangka HUT ke-58 Desa Seruni Mumbul. Peserta membawa sarung tangan & tumbler." },
  { slug: "sosialisasi-bansos-2", jenis: "Sosialisasi", judul: "Sosialisasi Program Bansos Semester II", tanggal: "2026-08-05", waktu: "13.30–16.00 WITA", lokasi: "Balai Dusun Dames", penyelenggara: "Kasi Kesejahteraan", deskripsi: "Penjelasan kriteria penerima BPNT & PKH periode Juli–Desember 2026, mekanisme pengaduan, dan verifikasi DTKS." },
];

export const beritaTerbaru = [
  {
    slug: "progres-pengerasan-jalan-karang-baru",
    kategori: "Pembangunan",
    judul: "Progres Pengerasan Jalan Dusun Mandar Mencapai 78%",
    ringkasan: "Kegiatan pengerasan jalan sepanjang 1,2 km ditargetkan rampung akhir Agustus, didanai APBDes 2026.",
    tanggal: "2026-07-17",
    penulis: "Kasi Pembangunan",
    isi: [
      "Pekerjaan pengerasan Jalan Poros Dusun Mandar sepanjang 1,2 km telah mencapai progres fisik 78% per 15 Juli 2026. Kegiatan ini didanai APBDes 2026 dengan pagu Rp 480 juta.",
      "Kepala Desa menyebut penyelesaian ditargetkan pada 28 Agustus 2026, sebelum musim hujan tiba. Warga diminta menghindari jalur pada pukul 08.00–16.00 selama pengecoran.",
      "Realisasi ini mengurangi waktu tempuh Dusun Mandar–Pusat Desa dari 22 menit menjadi 9 menit dan diharapkan menekan biaya distribusi hasil pertanian.",
    ],
  },
  {
    slug: "stunting-turun-12-persen",
    kategori: "Kesehatan",
    judul: "Kasus Stunting Turun 12% Setelah Program PMT Terpadu",
    ringkasan: "Hasil evaluasi Posyandu semester I menunjukkan penurunan prevalensi stunting balita di 6 dusun.",
    tanggal: "2026-07-15",
    penulis: "Kasi Kesejahteraan",
    isi: [
      "Program Pemberian Makanan Tambahan (PMT) berbasis pangan lokal menurunkan prevalensi stunting dari 18,4% menjadi 16,2% pada semester I 2026.",
      "Enam Posyandu di seluruh dusun mencatat 412 balita rutin terpantau. Kader Posyandu bekerja sama dengan Puskesmas Pringgabaya melakukan konseling gizi keluarga.",
      "Desa mengalokasikan tambahan Rp 60 juta di semester II untuk perluasan sasaran PMT bagi ibu hamil KEK dan bayi 6–24 bulan.",
    ],
  },
  {
    slug: "bumdes-buka-marketplace",
    kategori: "Ekonomi",
    judul: "BUMDes Seruni Buka Gerai Marketplace Digital",
    ringkasan: "Marketplace desa kini menampung 47 produk UMKM lokal dengan pengiriman ke seluruh Lombok.",
    tanggal: "2026-07-12",
    penulis: "Direktur BUMDes",
    isi: [
      "BUMDes Bina Seruni Mandiri meluncurkan gerai marketplace digital yang menampung 47 produk UMKM warga, mencakup madu, kopi, tenun songket, dan olahan laut.",
      "Transaksi bulan pertama menembus Rp 42 juta dengan cakupan pengiriman seluruh Pulau Lombok. Kurir lokal digandeng untuk pengiriman same-day di area Lombok Timur.",
      "UMKM baru dapat mendaftar melalui menu Marketplace di portal ini atau langsung ke kantor BUMDes setiap Senin–Jumat.",
    ],
  },
];

export const layananTerlaris = [
  { kode: "F1_SURAT", nama: "Surat Keterangan Domisili", jumlah_bulan: 128, ikon: "📄" },
  { kode: "F5_PBB", nama: "Pembayaran PBB Online", jumlah_bulan: 96, ikon: "🏛️" },
  { kode: "F1_SURAT", nama: "Surat Pengantar Nikah", jumlah_bulan: 42, ikon: "💍" },
  { kode: "SC_ADUAN", nama: "Aduan Infrastruktur", jumlah_bulan: 37, ikon: "🛠️" },
];

export const marketplaceProduk = {
  terlaris: [
    { nama: "Madu Trigona Seruni 500ml", harga: "Rp 95.000", penjual: "UMKM Bunda Hj. Rina", emoji: "🍯" },
    { nama: "Kopi Robusta Sembalun", harga: "Rp 65.000", penjual: "Koperasi Tani Maju", emoji: "☕" },
  ],
  terbaru: [
    { nama: "Tenun Songket Sasak Motif Seruni", harga: "Rp 450.000", penjual: "Sanggar Tenun Ibu Aminah", emoji: "🧶" },
    { nama: "Kerupuk Rumput Laut", harga: "Rp 22.000", penjual: "UMKM Pesisir Mumbul", emoji: "🍘" },
  ],
};

export const pembangunan = {
  progres_fisik_avg: 64,
  anggaran_terserap_pct: 58,
  aset_baru: 14,
  kegiatan_aktif: [
    { nama: "Rehabilitasi Saluran Irigasi Dusun Sasak", progres: 82 },
    { nama: "Pembangunan MCK Umum Pasar Seruni", progres: 45 },
    { nama: "Pengadaan Lampu PJU Tenaga Surya (30 titik)", progres: 30 },
  ],
};

export const perencanaanUsulan = {
  total_usulan: 47,
  partisipasi_voting: 1284,
  top10: [
    { judul: "Perbaikan Jalan Poros Dusun Mandar–Timba Gading", suara: 342 },
    { judul: "Pembangunan PAUD Terpadu Dusun Dames", suara: 289 },
    { judul: "Sumur Bor Air Bersih Dusun Brangtapen Asri", suara: 251 },
    { judul: "Renovasi Poskesdes Utama", suara: 198 },
    { judul: "Beasiswa Anak Nelayan Tidak Mampu", suara: 176 },
    { judul: "Pelatihan Digital UMKM", suara: 154 },
    { judul: "Pengadaan Kapal Sampah Pesisir", suara: 132 },
    { judul: "Rumah Baca Desa", suara: 118 },
    { judul: "Rehab Lapangan Sepakbola", suara: 97 },
    { judul: "Bank Sampah Terpadu", suara: 84 },
  ],
};

export const potensi = {
  sektor: [
    { nama: "Perikanan Tangkap", nilai: "Rp 4,2 M/thn", ikon: "🐟" },
    { nama: "Pertanian Padi & Palawija", nilai: "Rp 3,1 M/thn", ikon: "🌾" },
    { nama: "UMKM Kuliner & Kerajinan", nilai: "Rp 1,8 M/thn", ikon: "🥘" },
    { nama: "Peternakan Sapi & Kambing", nilai: "Rp 1,2 M/thn", ikon: "🐄" },
  ],
  pariwisata: [
    { nama: "Pantai Seruni Mumbul", tipe: "Wisata Bahari", emoji: "🏖️" },
    { nama: "Bukit Panorama Timba Gading", tipe: "Ekowisata", emoji: "⛰️" },
  ],
  bumdes: "BUMDes Bina Seruni Mandiri",
};

export const galeri = [
  { judul: "Festival Panen Raya 2026", emoji: "🎉" },
  { judul: "Musdes Perencanaan", emoji: "🗣️" },
  { judul: "Posyandu Balita", emoji: "👶" },
  { judul: "Gotong Royong Pantai", emoji: "🧹" },
  { judul: "Pelatihan UMKM", emoji: "💡" },
  { judul: "Turnamen Bola Antar-Dusun", emoji: "⚽" },
];

export const petaLayer = [
  { kode: "wilayah", label: "Batas Wilayah & Dusun", aktif: true },
  { kode: "aset", label: "Aset Desa", aktif: true },
  { kode: "pbb", label: "Objek Pajak PBB", aktif: false },
  { kode: "bencana", label: "Zona Rawan Bencana", aktif: true },
  { kode: "pariwisata", label: "Destinasi Wisata", aktif: true },
  { kode: "layanan", label: "Fasilitas Layanan Publik", aktif: true },
];

export const aduanKategori = [
  { kode: "POSBANKU", label: "Pos Bantuan Keuangan" },
  { kode: "INFRASTRUKTUR", label: "Infrastruktur (jalan, jembatan, PJU)" },
  { kode: "KAMTIBMAS", label: "Keamanan & Ketertiban" },
  { kode: "KEDARURATAN", label: "Kedaruratan / Bencana" },
  { kode: "ULASAN", label: "Kritik & Saran Layanan" },
] as const;

// ---------------------- Phase 2 additions ----------------------

export const profilDesa = {
  sejarah: [
    "Desa Seruni Mumbul dibentuk pada tahun 1968 sebagai hasil pemekaran dari Desa Pringgabaya, seiring pertumbuhan permukiman pesisir di kaki timur Rinjani.",
    "Nama 'Seruni Mumbul' berasal dari hamparan bunga seruni liar yang tumbuh subur di padang gembalaan serta mata air 'mumbul' (memancar) yang menjadi sumber air bersih warga hingga era 1990-an.",
    "Sejak tahun 2010, desa mengembangkan sektor perikanan tangkap, tenun songket Sasak, dan ekowisata pantai. Kini Seruni Mumbul dihuni ±6.800 jiwa dalam 6 dusun.",
  ],
  visi: "Terwujudnya Desa Seruni Mumbul yang mandiri, berbudaya, dan berdaya saing melalui satu data desa dan pelayanan terbuka.",
  misi: [
    "Mewujudkan tata kelola pemerintahan desa yang transparan dan akuntabel.",
    "Meningkatkan kualitas layanan publik berbasis digital tanpa mengabaikan warga non-digital.",
    "Mendorong ekonomi kerakyatan melalui BUMDes, UMKM, dan marketplace desa.",
    "Menguatkan modal sosial, budaya Sasak, dan ketahanan lingkungan pesisir.",
  ],
};

export const strukturPamong = [
  { nama: "H. Lalu Ahmad Saputra", jabatan: "Kepala Desa", periode: "2024–2030" },
  { nama: "Baiq Nuraini", jabatan: "Sekretaris Desa" },
  { nama: "Muhammad Sabri", jabatan: "Kasi Pemerintahan" },
  { nama: "Lalu Zainuddin", jabatan: "Kasi Kesejahteraan" },
  { nama: "Hj. Sri Wahyuni", jabatan: "Kasi Pelayanan" },
  { nama: "Baiq Rahma Dewi", jabatan: "Kaur Keuangan" },
  { nama: "Ahmad Fauzi", jabatan: "Kaur Perencanaan" },
  { nama: "Lalu Ismail", jabatan: "Kaur Tata Usaha & Umum" },
];

export const wilayahDusun = [
  { nama: "Dusun Mandar", kk: 0, jiwa: 0, luas_ha: 0 },
  { nama: "Dusun Sasak", kk: 0, jiwa: 0, luas_ha: 0 },
  { nama: "Dusun Dames", kk: 0, jiwa: 0, luas_ha: 0 },
  { nama: "Dusun Brangtapen Asri", kk: 0, jiwa: 0, luas_ha: 0 },
];

export const lembagaDesa = [
  { nama: "Badan Permusyawaratan Desa (BPD)", ketua: "H. Muhaimin", jumlah_anggota: 9 },
  { nama: "LPMD", ketua: "Lalu Sudirman", jumlah_anggota: 11 },
  { nama: "PKK Desa", ketua: "Hj. Nurhayati", jumlah_anggota: 25 },
  { nama: "Karang Taruna Seruni", ketua: "Ahmad Rizki", jumlah_anggota: 42 },
  { nama: "Linmas", ketua: "Muhammad Yusuf", jumlah_anggota: 18 },
  { nama: "BUMDes Bina Seruni Mandiri", ketua: "Baiq Salma", jumlah_anggota: 7 },
];

export const pengumumanResmi = [
  { nomor: "148/PMR/SM/VII/2026", tanggal: "2026-07-16", judul: "Jadwal Musdes Perencanaan RKPDes 2027", ringkasan: "Diberitahukan kepada seluruh perwakilan dusun, lembaga desa, dan tokoh masyarakat untuk hadir tepat waktu." },
  { nomor: "146/PMR/SM/VII/2026", tanggal: "2026-07-10", judul: "Pemadaman Air Bersih Sementara Dusun Brangtapen Asri", ringkasan: "Perbaikan pipa distribusi PAMDes tanggal 12 Juli 2026, pukul 09.00–15.00 WITA." },
  { nomor: "142/PMR/SM/VII/2026", tanggal: "2026-07-04", judul: "Pembukaan Pendaftaran Beasiswa Anak Nelayan", ringkasan: "Dibuka 5–20 Juli 2026 di Kantor Desa, pukul 08.00–14.00 WITA." },
  { nomor: "138/PMR/SM/VI/2026", tanggal: "2026-06-28", judul: "Verifikasi Ulang DTKS Semester II", ringkasan: "Kader dusun akan berkunjung 1–15 Juli 2026 untuk pemutakhiran data kesejahteraan." },
];

export const jenisSurat = [
  { kode: "SKD", nama: "Surat Keterangan Domisili", sla_hari: 1, syarat: ["KTP", "KK"] },
  { kode: "SKTM", nama: "Surat Keterangan Tidak Mampu", sla_hari: 2, syarat: ["KTP", "KK", "Surat pengantar RT/RW"] },
  { kode: "SKU", nama: "Surat Keterangan Usaha", sla_hari: 2, syarat: ["KTP", "KK", "Foto tempat usaha"] },
  { kode: "SPN", nama: "Surat Pengantar Nikah (N1–N4)", sla_hari: 3, syarat: ["KTP kedua calon", "KK", "Akta lahir"] },
  { kode: "SKW", nama: "Surat Keterangan Waris", sla_hari: 5, syarat: ["KTP ahli waris", "Akta kematian", "KK pewaris"] },
  { kode: "SKCK", nama: "Pengantar SKCK", sla_hari: 1, syarat: ["KTP", "KK"] },
  { kode: "SKKL", nama: "Surat Keterangan Kelahiran", sla_hari: 1, syarat: ["KK", "KTP orang tua", "Surat bidan/RS"] },
  { kode: "SKKM", nama: "Surat Keterangan Kematian", sla_hari: 1, syarat: ["KTP almarhum", "KK", "Surat medis"] },
];

export const pariwisataDetail = [
  { nama: "Pantai Seruni Mumbul", tipe: "Wisata Bahari", emoji: "🏖️", deskripsi: "Pantai berpasir putih 2,4 km dengan spot snorkeling terumbu karang di sisi selatan. Fasilitas: gazebo, MCK, warung UMKM." },
  { nama: "Bukit Panorama Timba Gading", tipe: "Ekowisata", emoji: "⛰️", deskripsi: "Titik pandang matahari terbit di ketinggian 380 mdpl menghadap Selat Alas dan siluet Rinjani." },
  { nama: "Sentra Tenun Songket Sasak", tipe: "Wisata Budaya", emoji: "🧵", deskripsi: "Sanggar tenun aktif di Dusun Dames. Pengunjung dapat mencoba menenun dan membeli langsung dari perajin." },
];

export const galeriDetail = [
  { judul: "Festival Panen Raya 2026", emoji: "🎉", tanggal: "2026-04-18", album: "Kegiatan Desa" },
  { judul: "Musdes Perencanaan", emoji: "🗣️", tanggal: "2026-03-12", album: "Kegiatan Desa" },
  { judul: "Posyandu Balita", emoji: "👶", tanggal: "2026-05-08", album: "Kesehatan" },
  { judul: "Gotong Royong Pantai", emoji: "🧹", tanggal: "2026-06-15", album: "Lingkungan" },
  { judul: "Pelatihan UMKM", emoji: "💡", tanggal: "2026-06-22", album: "Ekonomi" },
  { judul: "Turnamen Bola Antar-Dusun", emoji: "⚽", tanggal: "2026-05-30", album: "Olahraga" },
  { judul: "Peresmian PJU Solar", emoji: "💡", tanggal: "2026-04-02", album: "Pembangunan" },
  { judul: "Kirab Budaya Sasak", emoji: "🥁", tanggal: "2026-03-25", album: "Budaya" },
  { judul: "Pemeriksaan Kesehatan Lansia", emoji: "🩺", tanggal: "2026-06-01", album: "Kesehatan" },
];

export const statistikPenduduk = {
  per_jenis_kelamin: [
    { label: "Laki-laki", nilai: 3421 },
    { label: "Perempuan", nilai: 3421 },
  ],
  per_umur: [
    { label: "0–4", nilai: 612 },
    { label: "5–14", nilai: 1204 },
    { label: "15–24", nilai: 1187 },
    { label: "25–54", nilai: 2841 },
    { label: "55–64", nilai: 601 },
    { label: "65+", nilai: 397 },
  ],
  per_pekerjaan: [
    { label: "Petani", nilai: 1420 },
    { label: "Nelayan", nilai: 612 },
    { label: "Pedagang / Wirausaha", nilai: 484 },
    { label: "Pegawai / Guru", nilai: 217 },
    { label: "Buruh / Jasa", nilai: 803 },
    { label: "Belum / Tidak Bekerja", nilai: 3306 },
  ],
  per_pendidikan: [
    { label: "Tidak / Belum Sekolah", nilai: 902 },
    { label: "SD / Sederajat", nilai: 2314 },
    { label: "SMP / Sederajat", nilai: 1487 },
    { label: "SMA / Sederajat", nilai: 1602 },
    { label: "Diploma / Sarjana", nilai: 537 },
  ],
};