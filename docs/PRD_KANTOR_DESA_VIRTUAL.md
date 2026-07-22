# PRD — Kantor Desa Virtual (DESAKU)
**Product Requirements Document** · Referensi presisi untuk AI coding agent (Claude Code)

---

## 1. Ringkasan Produk

**Kantor Desa Virtual** adalah platform SaaS multi-tenant (subdomain per desa) yang menyatukan layanan administrasi, keuangan, kesehatan, ekonomi, dan tata kelola desa ke dalam satu sistem dengan prinsip **"satu input, banyak dampak"**: setiap fakta yang dicatat di satu modul otomatis menyebarkan efeknya ke modul lain lewat Event Propagation Layer, termasuk rekalkulasi skor IDM (Indeks Desa Membangun) secara real-time.

### 1.1 Tujuan Produk
- Menghilangkan input data berulang antar-modul (data warga, objek pajak, kegiatan sekali dicatat, dipakai ulang di semua tempat relevan).
- Menjadikan skor IDM sebagai **hasil otomatis operasional harian**, bukan kuesioner tahunan manual.
- Menyediakan kanal layanan warga yang setara di web dan WhatsApp (termasuk chatbot).
- Menjamin integritas anggaran: usulan warga → verifikasi kelayakan → voting sah → RKPDes → APBDes, dengan jejak audit penuh.

### 1.2 Target Pengguna
| Peran | Kebutuhan Utama |
|---|---|
| Warga | Ajukan surat, ikut usulan kegiatan & voting, cek info desa, bayar PBB |
| Perangkat Desa (Admin/Sekdes) | Verifikasi surat, kelola keuangan, kelola objek pajak, kelola konten portal |
| Kepala Desa | TTE surat, lihat dashboard IDM & rekomendasi kebijakan, approve RKPDes |
| Kader Posyandu | Catat kunjungan & data kesehatan balita |
| Dinas PMD (Kabupaten) | Lihat agregat IDM lintas-desa (akses lintas-tenant terbatas) |

### 1.3 Non-Tujuan (Scope Exclusion)
- Bukan pengganti sistem SISKEUDES/SIPADES resmi Kemendagri — hanya *pelengkap* transparansi & analitik. Mekanisme ekspor konkret ke format resmi disediakan lewat modul `ekspor_kepatuhan` (file siap-unggah, bukan integrasi API langsung — lihat `ARSITEKTUR_SISTEM_TERINTEGRASI.md §4`), supaya prinsip "satu input, banyak dampak" tidak berhenti di kewajiban pelaporan resmi.
- Bukan sistem pembayaran pajak negara (PPh/PPN) — PBB di sini murni PBB-P2 tingkat desa dalam kewenangan yang berlaku.
- Tidak menggantikan proses hukum Musyawarah Desa fisik — voting online adalah *pendukung* keputusan, bukan pengganti forum resmi.

---

## 2. Enam Fitur Andalan (Flagship Features)

### F1 — Pelayanan Surat Online dengan TTE/QR Code
**User story:** Sebagai warga, saya ingin mengajukan surat keterangan tanpa datang ke kantor desa, dan menerima dokumen sah secara digital.

**Kriteria penerimaan:**
- Form pengajuan surat auto-fill dari data `penduduk` by NIK — tidak ada input identitas manual.
- Status pengajuan dapat dilacak real-time: DIAJUKAN → DIVERIFIKASI → DITANDATANGANI → DIKIRIM → ARSIP (atau DITOLAK dengan alasan).
- Surat final memiliki QR code yang tertaut ke halaman verifikasi publik (`/verifikasi/{uuid}`) menampilkan keabsahan dokumen.
- Surat dikirim otomatis ke WhatsApp pemohon setelah TTE selesai.
- Semua surat diterbitkan tercatat di arsip dengan nomor surat otomatis sesuai klasifikasi arsip desa.

### F2 — Usulan Kegiatan Online → RKPDes → Voting
**User story:** Sebagai warga, saya ingin mengusulkan kegiatan pembangunan dan mendukung usulan warga lain secara transparan.

**Kriteria penerimaan:**
- Warga submit usulan dengan kategori Bidang/Sub-Bidang (Permendagri 20/2018).
- Admin memverifikasi kelayakan regulasi (checklist) sebelum usulan tayang publik untuk voting.
- Usulan yang lolos verifikasi masuk pool RKPDes dan dapat divoting warga.
- **Model voting**: 1 NIK dapat mendukung banyak usulan berbeda, tetapi hanya 1x per usulan (`UNIQUE(usulan_id, nik)`), diverifikasi lewat OTP WhatsApp ke nomor terdaftar.
- Ranking hasil voting menjadi bahan pertimbangan Musrenbangdes (bukan keputusan otomatis final).

### F3 — Mesin Skoring IDM & Rekomendasi Kebijakan
**User story:** Sebagai Kepala Desa, saya ingin melihat status IDM desa saya secara real-time beserta rekomendasi kebijakan berbasis skor terkini, bukan hasil survei tahunan yang sudah usang.

**Kriteria penerimaan:**
- Skor 127 sub-indikator (6 dimensi) dihitung otomatis dari fakta operasional termasuk sesuai `PETA_DERIVATION_RULES_IDM.md`.
- Setiap indikator dengan skor rendah otomatis memicu draft usulan kegiatan dengan kode rekening sesuai Permendes 7/2023 (`idm_indicators.csv`).
- Dashboard menampilkan klasifikasi status desa (Sangat Tertinggal/Tertinggal/Berkembang/Maju/Mandiri) dan tren dari waktu ke waktu, bukan hanya snapshot.

### F4 — Informasi Data Kesehatan
**User story:** Sebagai warga, saya ingin tahu cakupan layanan kesehatan desa saya; sebagai kader Posyandu, saya ingin mencatat kunjungan balita secara digital.

**Kriteria penerimaan:**
- Kader input kunjungan (berat, tinggi, imunisasi) per balita.
- Data individu balita **tidak pernah tampil publik** — hanya agregat per dusun/RT (cakupan imunisasi %, jumlah kunjungan rutin).
- Indikasi gizi buruk pada level individu memicu draft usulan kegiatan intervensi (lihat F3), notifikasi ke admin — bukan ke publik.

### F5 — Sistem Informasi PBB (Pajak Bumi dan Bangunan)
**User story:** Sebagai admin, saya ingin mengelola objek pajak dan wajib pajak secara akurat meski relasinya kompleks (satu wajib pajak banyak objek, objek dihuni pihak lain, dst).

**Kriteria penerimaan (lihat detail skema di `SKEMA_DATABASE_ERD.md`):**
- Wajib pajak adalah entitas independen dari `penduduk`, dapat berdomisili luar desa.
- Satu wajib pajak dapat memiliki banyak objek pajak (dan sebaliknya, kepemilikan bersama didukung dengan persentase).
- Objek pajak dapat memiliki lokasi tanah dan bangunan yang berbeda koordinat.
- Penghuni (penyewa/pesuruh) dicatat terpisah dari kepemilikan, tidak pernah jadi wajib pajak.
- Tagihan menempel ke objek pajak, histori kepemilikan tidak pernah ditimpa (append-only dengan `tanggal_selesai`).
- Pembayaran PBB lunas otomatis menambah PADes dan memicu rekalkulasi skor IDM terkait (F3).

### F6 — Layanan Surat via WhatsApp Chatbot
**User story:** Sebagai warga yang tidak terbiasa pakai aplikasi web, saya ingin mengurus surat cukup lewat chat WhatsApp.

**Kriteria penerimaan:**
- Bot rule-based (bukan NLP kompleks): menu jenis surat → tanya data pelengkap → autofill dari NIK jika dikenali → konfirmasi → submit.
- State percakapan tersimpan per nomor HP (`wa_chat_session`), expire otomatis jika idle.
- Alur berbagi state machine yang sama dengan F1 (bukan sistem terpisah) — status berubah dikirim otomatis via WA.
- Setelah TTE selesai, dokumen dikirim langsung di chat.
- **Model tiering (mengacu preseden PANDAWA/CHIKA BPJS Kesehatan):** WA melayani dua tier — `info_instan` (cek status/info, dijawab langsung tanpa OTP maupun antrean admin) dan `transaksi` (ajukan surat/usulan, wajib OTP dan mengikuti state machine penuh). Pesan diterima 24 jam, tapi proses tier `transaksi` eksplisit dinyatakan hanya berjalan pada jam kerja — lihat `ARSITEKTUR_SISTEM_TERINTEGRASI.md §1`.
- Nomor WA resmi tunggal, terverifikasi (centang hijau WhatsApp Business), dipublikasikan di semua kanal resmi untuk mencegah penipuan mengatasnamakan kantor desa.

---

## 3. Prinsip Arsitektur Produk

1. **Satu sumber kebenaran per fakta.** Data warga hanya di `penduduk`; data objek pajak hanya di `pbb_objek_pajak`; tidak ada duplikasi antar modul.
2. **Event Propagation Layer.** Semua perubahan fakta mentah menerbitkan `domain_events`; efek turunan (skor, dashboard, draft usulan) dihitung ulang oleh worker, tidak pernah diinput manual.
3. **Fakta mentah vs fakta turunan dipisah tegas.** Tabel turunan (`idm_skor_cache`, `dashboard_agregat`, dll) hanya ditulis oleh worker, tidak pernah diedit admin langsung.
4. **Privasi berlapis.** Data sensitif (kesehatan individu, NIK penuh) dibatasi per peran; publik hanya melihat agregat.
5. **Kanal setara.** Web dan WhatsApp berbagi state machine dan data yang sama — tidak ada logika bisnis terduplikasi per kanal.

---

## 4. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| Multi-tenancy | Subdomain per desa, isolasi data ketat via `tenant_id` di setiap tabel |
| Kepatuhan regulasi | Permendagri 20/2018 (kode rekening), Permendes 21/2020 & 7/2023 (IDM/SDGs Desa) |
| Auditability | Semua transaksi kritikal (surat, tagihan, voting, kepemilikan objek pajak) append-only dengan jejak waktu & aktor |
| Ketersediaan kanal | Web responsif + WhatsApp (Fonnte API) |
| Keamanan dokumen | Hash dokumen + QR verifikasi publik untuk semua surat resmi |
| Skalabilitas worker | Bertahap: MVP 1 queue dengan job priority per dimensi; split ke 6 queue terpisah hanya jika lag terukur melebihi threshold (lihat `ARSITEKTUR_SISTEM_TERINTEGRASI.md §2`) |

---

## 5. Referensi Dokumen Terkait
- `PETA_DERIVATION_RULES_IDM.md` — peta event → efek turunan per dimensi IDM
- `idm_indicators.csv` — 127 indikator IDM lengkap dengan skor, rekomendasi, kode rekening
- `WORKFLOW_KANTOR_DESA_VIRTUAL.md` — alur proses detail tiap fitur
- `SKEMA_DATABASE_ERD.md` — skema database lengkap dan diagram ERD
- `pbb.schema.ts`, `pbb-derivation.worker.ts` — implementasi referensi domain PBB
- `ARSITEKTUR_SISTEM_TERINTEGRASI.md` — penyempurnaan tiering WA, sizing worker bertahap, klasifikasi sumber data indikator IDM, modul ekspor kepatuhan, RBAC data kesehatan
