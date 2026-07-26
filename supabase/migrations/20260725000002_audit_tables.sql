-- ============================================================
-- CEK SEMUA TABEL - Status dan Jumlah Data
-- ============================================================

SELECT '=== TABEL MASTER & PUBLIK ===' as info
UNION ALL SELECT 'tenants: ' || count(*)::text FROM tenants
UNION ALL SELECT 'profil_desa: ' || count(*)::text FROM profil_desa
UNION ALL SELECT 'wilayah_dusun: ' || count(*)::text FROM wilayah_dusun
UNION ALL SELECT 'desa_pamong: ' || count(*)::text FROM desa_pamong
UNION ALL SELECT 'lembaga_desa: ' || count(*)::text FROM lembaga_desa
UNION ALL SELECT 'surat_jenis: ' || count(*)::text FROM surat_jenis
UNION ALL SELECT 'idm_status_desa: ' || count(*)::text FROM idm_status_desa
UNION ALL SELECT 'idm_indikator: ' || count(*)::text FROM idm_indikator
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL KONTEN ===' as info
UNION ALL SELECT 'berita: ' || count(*)::text FROM berita
UNION ALL SELECT 'agenda: ' || count(*)::text FROM agenda
UNION ALL SELECT 'galeri: ' || count(*)::text FROM galeri
UNION ALL SELECT 'pengumuman: ' || count(*)::text FROM pengumuman
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL POTENSI ===' as info
UNION ALL SELECT 'potensi_wisata: ' || count(*)::text FROM potensi_wisata
UNION ALL SELECT 'potensi_umkm: ' || count(*)::text FROM potensi_umkm
UNION ALL SELECT 'potensi_produk: ' || count(*)::text FROM potensi_produk
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL PELAYANAN ===' as info
UNION ALL SELECT 'kegiatan_pembangunan: ' || count(*)::text FROM kegiatan_pembangunan
UNION ALL SELECT 'usulan_warga: ' || count(*)::text FROM usulan_warga
UNION ALL SELECT 'langganan_wa: ' || count(*)::text FROM langganan_wa
UNION ALL SELECT 'aduan_warga: ' || count(*)::text FROM aduan_warga
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL PEMERINTAHAN ===' as info
UNION ALL SELECT 'rpjmdes_periode: ' || count(*)::text FROM rpjmdes_periode
UNION ALL SELECT 'rpjmdes_bidang: ' || count(*)::text FROM rpjmdes_bidang
UNION ALL SELECT 'rpjmdes_program: ' || count(*)::text FROM rpjmdes_program
UNION ALL SELECT 'rkpdes_tahun: ' || count(*)::text FROM rkpdes_tahun
UNION ALL SELECT 'rkpdes_kegiatan: ' || count(*)::text FROM rkpdes_kegiatan
UNION ALL SELECT 'apbdes: ' || count(*)::text FROM apbdes
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL VOTING ===' as info
UNION ALL SELECT 'voting_topik: ' || count(*)::text FROM voting_topik
UNION ALL SELECT 'voting_opsi: ' || count(*)::text FROM voting_opsi
UNION ALL SELECT 'voting_suara: ' || count(*)::text FROM voting_suara
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL PENDUDUK ===' as info
UNION ALL SELECT 'keluarga: ' || count(*)::text FROM keluarga
UNION ALL SELECT 'penduduk: ' || count(*)::text FROM penduduk
UNION ALL SELECT 'buku_register: ' || count(*)::text FROM buku_register
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL SEHAT/KESEJAHTERAAN ===' as info
UNION ALL SELECT 'posyandu_agregat: ' || count(*)::text FROM posyandu_agregat
UNION ALL SELECT 'stunting_agregat: ' || count(*)::text FROM stunting_agregat
UNION ALL SELECT 'bantuan_sosial: ' || count(*)::text FROM bantuan_sosial
UNION ALL SELECT 'penerima_bansos: ' || count(*)::text FROM penerima_bansos
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL PERTANAHAN ===' as info
UNION ALL SELECT 'bidang_tanah: ' || count(*)::text FROM bidang_tanah
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL INFRASTRUKTUR ===' as info
UNION ALL SELECT 'infrastruktur: ' || count(*)::text FROM infrastruktur
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL LAINNYA ===' as info
UNION ALL SELECT 'bencana_kejadian: ' || count(*)::text FROM bencana_kejadian
UNION ALL SELECT 'dpt_pemilih: ' || count(*)::text FROM dpt_pemilih
UNION ALL SELECT 'suplesi_data: ' || count(*)::text FROM suplesi_data
UNION ALL SELECT 'analisis_snapshot: ' || count(*)::text FROM analisis_snapshot
UNION ALL SELECT 'sinkron_log: ' || count(*)::text FROM sinkron_log
UNION ALL SELECT 'pbb_tagihan: ' || count(*)::text FROM pbb_tagihan
UNION ALL SELECT 'notif_otp: ' || count(*)::text FROM notif_otp
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL AUTH/ADMIN ===' as info
UNION ALL SELECT 'user_roles: ' || count(*)::text FROM user_roles
UNION ALL SELECT 'admin_profiles: ' || count(*)::text FROM admin_profiles
UNION ALL SELECT ''
UNION ALL SELECT '=== TABEL CMS ===' as info
UNION ALL SELECT 'page_config: ' || count(*)::text FROM page_config
UNION ALL SELECT 'nav_item: ' || count(*)::text FROM nav_item
UNION ALL SELECT 'footer_column: ' || count(*)::text FROM footer_column
UNION ALL SELECT 'event_log: ' || count(*)::text FROM event_log;
