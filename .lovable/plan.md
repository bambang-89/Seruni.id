# Phase 11 — Perencanaan Desa (RPJMDes/RKPDes) + Usulan Warga + Voting Nyata

Fokus: memastikan setiap modul benar-benar berfungsi (form → submit → penyimpanan → moderasi → status lanjut), bukan sekadar tampilan.

## 1. Database (migrasi baru)

Tabel baru (RLS + GRANT + audit log trigger):

- `rpjmdes_periode` — periode (mis. 2025–2030), visi, misi[], status (draft/aktif/selesai), published.
- `rpjmdes_bidang` — bidang pembangunan per periode (kode, nama, deskripsi, urutan).
- `rpjmdes_program` — program per bidang (nama, indikator, target, sumber_dana, tahun_mulai, tahun_selesai, anggaran_indikatif).
- `rkpdes_tahun` — RKPDes per tahun (tahun, periode_id, status, tgl_musdes, published).
- `rkpdes_kegiatan` — kegiatan per RKPDes (bidang_id, program_id, nama, lokasi/dusun, volume, satuan, anggaran, sumber_dana, pelaksana, waktu, status_realisasi, progress %).
- `usulan_warga` — usulan publik (nomor_tiket auto, nama, nik_masked, kontak, dusun, kategori enum[infrastruktur, ekonomi, sosial, pendidikan, kesehatan, lingkungan, pemerintahan, lainnya], judul, deskripsi, lokasi, foto_url, status workflow_status, tanggapan, target_rkpdes_id nullable, created_at).
- `usulan_vote` — vote per usulan (usulan_id, voter_hash unique per usulan, dusun opsional, created_at). Hash = sha256(usulan_id + ip + user-agent) via edge function agar 1 device 1 vote tanpa login.
- `voting_topik` — topik voting resmi desa (judul, deskripsi, mulai, selesai, status, single_choice bool, published).
- `voting_opsi` — opsi per topik (label, deskripsi, urutan).
- `voting_suara` — suara (topik_id, opsi_id, voter_hash unique per topik, dusun opsional).

RLS:
- Publik SELECT semua yang `published=true` atau status `terbit/aktif`.
- Publik INSERT `usulan_warga` (dengan cap panjang & rate limit di edge function), `usulan_vote`, `voting_suara` (lewat edge function saja untuk hashing → tabel pakai policy `service_role` only untuk insert).
- Admin ALL untuk tabel perencanaan & voting.

## 2. Edge Functions

- `submit-usulan` — validasi zod, sanitasi, generate nomor tiket `USL-YYYYMM-XXXX`, simpan, kembalikan tiket.
- `vote-usulan` — hash IP+UA+usulan, cek unik, insert, kembalikan total suara.
- `vote-topik` — sama untuk voting resmi, cek window mulai/selesai & status aktif.

## 3. Halaman Publik (fungsional, ada form + submit)

- `/perencanaan/rpjmdes` — pilih periode aktif, tampilkan visi/misi, bidang, program (tabel + filter bidang/tahun). Data dari DB.
- `/perencanaan/rkpdes` — pilih tahun, tampilkan daftar kegiatan (filter bidang/dusun/status), progress bar realisasi, total anggaran per bidang (chart).
- `/partisipasi/usulan` —
  - Form usulan (nama, kontak, dusun, kategori, judul, deskripsi, lokasi, foto upload ke `seruni-media/usulan`), validasi zod, submit ke `submit-usulan`, tampilkan nomor tiket.
  - Daftar usulan publik (status ≥ diverifikasi) dengan filter kategori/dusun/status + tombol "Dukung" (vote) memakai `vote-usulan`, tampil jumlah dukungan real-time (refresh).
  - Lacak tiket (input nomor → status & tanggapan).
- `/partisipasi/voting` — daftar topik voting aktif; klik → detail dengan opsi + tombol Pilih (via `vote-topik`), hasil live (bar chart), status window (belum mulai / berjalan / ditutup).

Semua halaman mengikuti sistem SplitTitle + ToneGuard + PageHeader dari `page_config`.

## 4. Admin (CRUD nyata + workflow)

Grup baru "Perencanaan" di `AdminShell`:
- `AdminRPJMDes` — CRUD periode, bidang, program (nested).
- `AdminRKPDes` — CRUD tahun & kegiatan; import kegiatan dari program RPJMDes; update progress.
- `AdminUsulan` — inbox usulan warga: filter status, ubah status (baru→diverifikasi→ditindaklanjuti→selesai/ditolak), balas tanggapan, kaitkan ke RKPDes tahun tertentu (jadi kegiatan), lihat jumlah dukungan.
- `AdminVoting` — CRUD topik & opsi, mulai/tutup manual, lihat hasil per opsi + per dusun, ekspor CSV.

## 5. Audit fungsi modul lain

Sapuan cepat setiap manajer admin untuk memastikan setiap tombol benar-benar menyimpan/menghapus/mempublish (Berita, Agenda, Pengumuman, Galeri, PBB, APBDes, Bansos, dst.). Perbaiki yang masih stub. Semua form pakai zod + toast sukses/gagal.

## 6. Navigasi & konfigurasi

- Tambah entri nav `Perencanaan` (RPJMDes, RKPDes) & `Partisipasi` (Usulan, Voting) via seed `nav_item` + `page_config` untuk masing-masing rute.

## Teknis singkat

- Rate limit sederhana di edge function pakai in-memory + Deno KV opsional; utamakan uniqueness hash.
- Chart: Recharts (sudah terpasang).
- Upload foto: `supabase.storage.from('seruni-media').upload('usulan/...')`.
- Semua tabel: trigger `set_updated_at` + `log_admin_activity` + `log_status_change` untuk yang punya kolom `status`.

Setelah plan disetujui, saya jalankan migrasi dulu, lalu edge functions, lalu UI publik & admin, ditutup audit modul.
