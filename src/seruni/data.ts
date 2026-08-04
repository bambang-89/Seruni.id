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