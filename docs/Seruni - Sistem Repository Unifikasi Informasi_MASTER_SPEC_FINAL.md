# KANTOR DESA VIRTUAL (Seruni - Sistem Repository Unifikasi Informasi) — DOKUMEN MASTER

**Referensi tunggal dan final untuk AI coding agent (Claude Code)**
Dokumen ini adalah spesifikasi produk, alur proses, skema database, dan desain frontend yang terintegrasi penuh untuk platform Kantor Desa Virtual (Seruni - Sistem Repository Unifikasi Informasi).

Tiga dokumen pendukung masih **belum tersedia** dan tetap jadi blocker implementasi sebagian: `PETA_DERIVATION_RULES_IDM.md`, `idm_indicators.csv`, dan `ARSITEKTUR_SISTEM_TERINTEGRASI.md`. Seluruh titik ketergantungan pada ketiganya dikumpulkan di **Bagian E**.

---

## Daftar Isi

- **Bagian A — Produk**: A1 Ringkasan Produk · A2 Sepuluh Fitur Andalan (F1–F10) · A3 Prinsip Arsitektur Produk · A4 Kebutuhan Non-Fungsional
- **Bagian B — Alur Proses & State Machine**: W1–W12
- **Bagian C — Skema Database & ERD**: Konvensi · Core Registry · Modul Surat · Usulan & Voting · PBB · APBDes · IDM & Event Propagation · Kepatuhan & Data Sensitif · Pertanahan/Aset/GIS/Agenda · Pemisahan Fakta Mentah vs Turunan · Urutan Migrasi
- **Bagian D — Desain Frontend**: Prinsip · Zero Hardcode · Design Token · Halaman 1–4 · Modul F7–F10 · Routing
- **Bagian E — Status Dokumen, Dependensi & Catatan Terbuka** (satu-satunya tempat rujukan ke dokumen yang belum tersedia)

---

# BAGIAN A — PRODUK

## A1. Ringkasan Produk

**Kantor Desa Virtual (Seruni - Sistem Repository Unifikasi Informasi)** adalah platform SaaS multi-tenant (subdomain per desa) yang menyatukan layanan administrasi, keuangan, kesehatan, ekonomi, dan tata kelola desa ke dalam satu sistem dengan prinsip **"satu input, banyak dampak"**: setiap fakta yang dicatat di satu modul otomatis menyebarkan efeknya ke modul lain lewat Event Propagation Layer, termasuk rekalkulasi skor IDM (Indeks Desa Membangun) secara real-time.

### A1.1 Tujuan Produk
- Menghilangkan input data berulang antar-modul (data warga, objek pajak, kegiatan sekali dicatat, dipakai ulang di semua tempat relevan).
- Menjadikan skor IDM sebagai **hasil otomatis operasional harian**, bukan kuesioner tahunan manual.
- Menyediakan kanal layanan warga yang setara di web dan WhatsApp (termasuk chatbot).
- Menjamin integritas anggaran: usulan warga → verifikasi kelayakan → voting sah → RKPDes → APBDes, dengan jejak audit penuh.

### A1.2 Target Pengguna
| Peran | Kebutuhan Utama |
|---|---|
| Warga | Ajukan surat, ikut usulan kegiatan & voting, cek info desa, bayar PBB |
| Perangkat Desa (Admin/Sekdes) | Verifikasi surat, kelola keuangan, kelola objek pajak, kelola konten portal |
| Kepala Desa | TTE surat, lihat dashboard IDM & rekomendasi kebijakan, approve RKPDes |
| Kader Posyandu | Catat kunjungan & data kesehatan balita |
| Dinas PMD (Kabupaten) | Lihat agregat IDM lintas-desa (akses lintas-tenant terbatas) |

### A1.3 Non-Tujuan (Scope Exclusion)
- Bukan pengganti sistem SISKEUDES/SIPADES resmi Kemendagri — hanya *pelengkap* transparansi & analitik. Mekanisme ekspor konkret ke format resmi disediakan lewat modul `ekspor_kepatuhan` (file siap-unggah, bukan integrasi API langsung — lihat W7 di Bagian B dan §C6b), supaya prinsip "satu input, banyak dampak" tidak berhenti di kewajiban pelaporan resmi.
- Bukan sistem pembayaran pajak negara (PPh/PPN) — PBB di sini murni PBB-P2 tingkat desa dalam kewenangan yang berlaku.
- Tidak menggantikan proses hukum Musyawarah Desa fisik — voting online adalah *pendukung* keputusan, bukan pengganti forum resmi.

---

## A2. Sepuluh Fitur Andalan (F1–F10)

### F1 — Pelayanan Surat Online dengan TTE/QR Code
**User story:** Sebagai warga, saya ingin mengajukan surat keterangan tanpa datang ke kantor desa, dan menerima dokumen sah secara digital.

**Kriteria penerimaan:**
- Form pengajuan surat auto-fill dari data `penduduk` by NIK — tidak ada input identitas manual.
- Status pengajuan dapat dilacak real-time: DIAJUKAN → DIVERIFIKASI → DITANDATANGANI → DIKIRIM → ARSIP (atau DITOLAK dengan alasan). Alur lengkap: lihat **W1**.
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
- Ranking hasil voting menjadi bahan pertimbangan Musrenbangdes (bukan keputusan otomatis final). Alur lengkap: lihat **W2**.

### F3 — Mesin Skoring IDM & Rekomendasi Kebijakan
**User story:** Sebagai Kepala Desa, saya ingin melihat status IDM desa saya secara real-time beserta rekomendasi kebijakan berbasis skor terkini, bukan hasil survei tahunan yang sudah usang.

**Kriteria penerimaan:**
- Skor 127 sub-indikator (6 dimensi) dihitung otomatis dari fakta operasional termasuk sesuai `PETA_DERIVATION_RULES_IDM.md` (**belum tersedia** — lihat Bagian E).
- Setiap indikator dengan skor rendah otomatis memicu draft usulan kegiatan dengan kode rekening sesuai Permendes 7/2023 (`idm_indicators.csv`, **belum tersedia** — lihat Bagian E).
- Dashboard menampilkan klasifikasi status desa (Sangat Tertinggal/Tertinggal/Berkembang/Maju/Mandiri) dan tren dari waktu ke waktu, bukan hanya snapshot.
- Jumlah pasti indikator ("127") wajib diverifikasi manual terhadap `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`, bukan diasumsikan. Alur lengkap: lihat **W3**.

### F4 — Informasi Data Kesehatan
**User story:** Sebagai warga, saya ingin tahu cakupan layanan kesehatan desa saya; sebagai kader Posyandu, saya ingin mencatat kunjungan balita secara digital.

**Kriteria penerimaan:**
- Kader input kunjungan (berat, tinggi, imunisasi) per balita.
- Data individu balita **tidak pernah tampil publik** — hanya agregat per dusun/RT (cakupan imunisasi %, jumlah kunjungan rutin).
- Indikasi gizi buruk pada level individu memicu draft usulan kegiatan intervensi (lihat F3), notifikasi ke admin — bukan ke publik. Alur lengkap dan aturan RBAC: lihat **W4**.

### F5 — Sistem Informasi PBB (Pajak Bumi dan Bangunan)
**User story:** Sebagai admin, saya ingin mengelola objek pajak dan wajib pajak secara akurat meski relasinya kompleks (satu wajib pajak banyak objek, objek dihuni pihak lain, dst).

**Kriteria penerimaan (lihat detail skema di §C5):**
- Wajib pajak adalah entitas independen dari `penduduk`, dapat berdomisili luar desa.
- Satu wajib pajak dapat memiliki banyak objek pajak (dan sebaliknya, kepemilikan bersama didukung dengan persentase).
- Objek pajak dapat memiliki lokasi tanah dan bangunan yang berbeda koordinat.
- Penghuni (penyewa/pesuruh) dicatat terpisah dari kepemilikan, tidak pernah jadi wajib pajak.
- Tagihan menempel ke objek pajak, histori kepemilikan tidak pernah ditimpa (append-only dengan `tanggal_selesai`).
- Pembayaran PBB lunas otomatis menambah PADes dan memicu rekalkulasi skor IDM terkait (F3). Alur lengkap: lihat **W5**.

### F6 — Layanan Surat via WhatsApp Chatbot
**User story:** Sebagai warga yang tidak terbiasa pakai aplikasi web, saya ingin mengurus surat cukup lewat chat WhatsApp.

**Kriteria penerimaan:**
- Bot rule-based (bukan NLP kompleks): menu jenis surat → tanya data pelengkap → autofill dari NIK jika dikenali → konfirmasi → submit.
- State percakapan tersimpan per nomor HP (`wa_chat_session`), expire otomatis jika idle.
- Alur berbagi state machine yang sama dengan F1 (bukan sistem terpisah) — status berubah dikirim otomatis via WA.
- Setelah TTE selesai, dokumen dikirim langsung di chat.
- **Model tiering (mengacu preseden PANDAWA/CHIKA BPJS Kesehatan):** WA melayani dua tier — `info_instan` (cek status/info, dijawab langsung tanpa OTP maupun antrean admin) dan `transaksi` (ajukan surat/usulan, wajib OTP dan mengikuti state machine penuh). Pesan diterima 24 jam, tapi proses tier `transaksi` eksplisit dinyatakan hanya berjalan pada jam kerja — lihat rasional lengkap di `ARSITEKTUR_SISTEM_TERINTEGRASI.md` (**belum tersedia** — Bagian E).
- Nomor WA resmi tunggal, terverifikasi (centang hijau WhatsApp Business), dipublikasikan di semua kanal resmi untuk mencegah penipuan mengatasnamakan kantor desa. Alur lengkap: lihat **W6**.

### F7 — Pertanahan
- Pendaftaran bidang tanah (NIB/girik/tanah kas desa) dengan riwayat kepemilikan **append-only**, mengikuti pola `kepemilikan_objek` yang sudah terbukti di modul PBB.
- **Diferensiator:** `bidang_tanah` jadi fakta mentah tunggal untuk luas & lokasi — `objek_pajak` mereferensikannya, bukan mencatat ulang. Event pengalihan kepemilikan tanah otomatis memutakhirkan `wajib_pajak` PBB, sesuatu yang biasanya jadi dua pencatatan terpisah dan rawan tidak sinkron di implementasi OpenSID pada umumnya. Alur lengkap: lihat **W8**.

### F8 — Aset & Inventaris Desa
- Pencatatan aset bergerak/tidak bergerak, termasuk tanah kas desa dari F7.
- **Diferensiator:** belanja modal dari `apbdes_realisasi` (event yang sudah ada) otomatis membuat draft entri aset — admin tinggal verifikasi, bukan mencatat anggaran lalu mencatat ulang aset secara manual terpisah.
- Penyusutan dihitung terjadwal (worker ringan), bukan proses manual tahunan. Alur lengkap: lihat **W9**.

### F9 — Pemetaan & GIS Partisipatif
- Batas wilayah dusun/RT/RW (poligon), plus pelaporan titik infrastruktur (jalan rusak, fasilitas umum) oleh warga dengan foto & lokasi — melalui web atau WA (tier transaksi), terverifikasi admin sebelum tampil publik.
- **Diferensiator:** peta bukan modul berdiri sendiri — ia jadi lapisan visual di atas data yang sudah ada (titik objek pajak dari F7, titik posyandu dari F4, titik infrastruktur baru). Laporan infrastruktur kondisi buruk otomatis memicu draft usulan kegiatan, memakai pola draft-otomatis-verifikasi-manusia yang sama dengan skor IDM rendah (W3). Alur lengkap: lihat **W10**.

### F10 — Statistik & Agenda Terpadu
- Statistik desa dihasilkan live dari `domain_events` yang sudah mengalir dari seluruh modul — bukan dashboard yang diisi manual terpisah.
- Agenda/kalender kegiatan terhubung otomatis ke jadwal Musdes (F2) dan Posyandu (F4); admin hanya menambah entri kegiatan umum secara manual.
- Reminder kegiatan memakai kanal WA tier `info_instan` yang sudah dibangun di F6 (opt-in per warga) — tidak membangun kanal notifikasi baru. Alur lengkap: lihat **W11**.

Fitur F7–F10 dirancang untuk menutup gap terhadap modul yang sudah lazim ada di OpenSID (pertanahan, aset desa, pemetaan/GIS, statistik & agenda), dengan prinsip yang sama seperti F1–F6: **reuse fakta yang sudah ada, bukan silo baru**.

---

## A3. Prinsip Arsitektur Produk

1. **Satu sumber kebenaran per fakta.** Data warga hanya di `penduduk`; data objek pajak hanya di `objek_pajak`; tidak ada duplikasi antar modul.
2. **Event Propagation Layer.** Semua perubahan fakta mentah menerbitkan `domain_events`; efek turunan (skor, dashboard, draft usulan) dihitung ulang oleh worker, tidak pernah diinput manual.
3. **Fakta mentah vs fakta turunan dipisah tegas.** Tabel turunan (`idm_skor_cache`, `dashboard_agregat`, dll) hanya ditulis oleh worker, tidak pernah diedit admin langsung. Daftar lengkap tabel per kategori: lihat **§C10**.
4. **Privasi berlapis.** Data sensitif (kesehatan individu, NIK penuh) dibatasi per peran; publik hanya melihat agregat.
5. **Kanal setara.** Web dan WhatsApp berbagi state machine dan data yang sama — tidak ada logika bisnis terduplikasi per kanal.
6. **Zero hardcode di frontend.** Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen — semua berasal dari config/database. Detail penuh: lihat **§D1**.
7. **Tidak ada aksi kritikal tanpa persetujuan manusia.** Draft otomatis (usulan kegiatan, aset desa, ekspor kepatuhan) selalu berstatus menunggu review, tidak pernah auto-approve/auto-eksekusi.

---

## A4. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| Multi-tenancy | Subdomain per desa, isolasi data ketat via `tenant_id` di setiap tabel |
| Kepatuhan regulasi | Permendagri 20/2018 (kode rekening), Permendes 21/2020 & 7/2023 (IDM/SDGs Desa) |
| Auditability | Semua transaksi kritikal (surat, tagihan, voting, kepemilikan objek pajak) append-only dengan jejak waktu & aktor |
| Ketersediaan kanal | Web responsif + WhatsApp (Fonnte API) |
| Keamanan dokumen | Hash dokumen + QR verifikasi publik untuk semua surat resmi |
| Skalabilitas worker | Bertahap: MVP 1 queue dengan job priority per dimensi; split ke 6 queue terpisah hanya jika lag terukur melebihi threshold (rasional lengkap: `ARSITEKTUR_SISTEM_TERINTEGRASI.md`, belum tersedia — Bagian E) |


---

# BAGIAN B — ALUR PROSES & STATE MACHINE

Referensi state machine untuk implementasi Claude Code. Setiap alur mengacu ke kriteria penerimaan terkait di Bagian A dan skema tabel di Bagian C.

## W1. Alur Surat Online (TTE/QR) — F1

```
[Warga: Web/WA] Pilih jenis surat
        │
        ▼
Form autofill dari `penduduk` (by NIK) ── field non-identitas diisi manual
        │
        ▼
Submit ──► status: DIAJUKAN ──► event: surat.diajukan
        │
        ▼
[Admin] Verifikasi kelengkapan & keabsahan data
        │
   ┌────┴────┐
   ▼         ▼
DITOLAK   DIVERIFIKASI ──► event: surat.diverifikasi
(+alasan)      │
   │           ▼
   │      [Kades/Sekdes] TTE (QR + hash dokumen)
   │           │
   │           ▼
   │      status: DITANDATANGANI ──► event: surat.diterbitkan
   │           │
   │           ▼
   │      Kirim otomatis via WA (Fonnte API) ──► status: DIKIRIM
   │           │
   │           ▼
   │      status: ARSIP (rekam log lengkap: waktu, aktor tiap transisi)
   │
   ▼
[Warga] Notifikasi penolakan, dapat ajukan ulang dari DRAFT
```

**Event yang diterbitkan ke Propagation Layer:**
- `surat.diterbitkan` → Dimensi 6 IDM (indikator 45.b, Pemanfaatan Teknologi Pelayanan) — persentase surat digital vs manual dihitung ulang.

**Aturan validasi kritikal:**
- Nomor surat digenerate otomatis mengikuti format klasifikasi arsip desa, tidak boleh diinput manual admin (mencegah duplikasi/nomor loncat).
- QR code hanya digenerate setelah TTE sah — tidak ada QR untuk dokumen DRAFT/DIAJUKAN.

---

## W2. Alur Usulan Kegiatan → RKPDes → Voting — F2

```
[Warga] Submit usulan kegiatan (judul, kategori Bidang/Sub-Bidang, lokasi, estimasi manfaat)
        │
        ▼
status: DIAJUKAN ──► event: usulan.diajukan
        │
        ▼
[Admin] Verifikasi kelayakan regulasi (checklist: sesuai RPJMDes? tidak duplikasi? sesuai kewenangan desa?)
        │
   ┌────┴────┐
   ▼         ▼
DITOLAK   LOLOS_VERIFIKASI ──► event: usulan.lolos_verifikasi
(+alasan)      │
               ▼
          Masuk POOL_RKPDES, tayang publik untuk voting
               │
               ▼
     [Warga] Dukung usulan (OTP WhatsApp → verifikasi NIK)
               │
               ▼
     INSERT usulan_votes (usulan_id, nik) ── constraint UNIQUE(usulan_id, nik)
               │           (NIK boleh dukung usulan LAIN, tidak boleh ulang di usulan SAMA)
               ▼
          Ranking real-time (jumlah dukungan) ──► event: usulan.vote.bertambah
               │
               ▼
     [Musyawarah Desa] Bahan pertimbangan Musrenbangdes (keputusan final tetap forum resmi)
               │
               ▼
          status: DITETAPKAN_RKPDES ──► event: musdes.usulan.ditetapkan
               │
               ▼
          [Modul Keuangan] Masuk draft APBDes tahun berikutnya (kode rekening sesuai Bidang/Sub-Bidang)
```

**Event yang diterbitkan ke Propagation Layer:**
- `musdes.usulan.ditetapkan` → Dimensi 6 IDM (indikator 46, Musyawarah Desa) — frekuensi & partisipasi musdes.

**Aturan validasi kritikal:**
- Voting hanya dibuka untuk usulan berstatus `LOLOS_VERIFIKASI` — usulan yang masih `DIAJUKAN` tidak bisa divoting.
- Verifikasi NIK saat vote wajib OTP WA ke nomor terdaftar di `penduduk` — bukan sekadar input NIK manual.

---

## W3. Alur Mesin Skoring IDM (Event-Driven) — F3

```
[Modul manapun] Fakta mentah berubah (kunjungan posyandu, tagihan PBB, surat terbit, dst)
        │
        ▼
INSERT domain_events (event_type, entity_id, payload, processed_at=NULL)
        │
        ▼
[Worker BullMQ — queue sesuai dimensi] Ambil event belum diproses
        │
        ▼
Jalankan derivation rule terkait (lihat PETA_DERIVATION_RULES_IDM.md — belum tersedia, Bagian E)
        │
        ├──► Hitung ulang nilai agregat indikator (mis. APM, cakupan imunisasi, PADes)
        │
        ├──► Bandingkan dengan threshold dari `idm_scoring_thresholds` (seed dari idm_indicators.csv)
        │
        ├──► UPSERT idm_skor_cache (tenant_id, indikator_kode, skor, dihitung_pada)
        │
        ├──► Jika skor turun di bawah ambang → INSERT usulan_kegiatan_draft_otomatis
        │        (status: menunggu_review — TIDAK auto-approve, admin wajib review)
        │
        ▼
UPDATE domain_events SET processed_at = now()
        │
        ▼
[Trigger tambahan] Refresh idm_status_desa (total skor 6 dimensi → klasifikasi status desa)
        │
        ▼
Portal Publik & Dashboard menampilkan status terkini (read-only dari cache, tidak hitung ulang di frontend)
```

**Aturan kritikal:**
- Worker idempotent — event yang diproses ulang (retry) tidak boleh menghasilkan efek ganda (gunakan `ON CONFLICT DO UPDATE`, bukan `INSERT` polos, untuk tabel cache).
- Draft usulan otomatis **wajib melalui alur verifikasi manusia** (W2) sebelum masuk RKPDes — sistem tidak pernah mengeksekusi anggaran tanpa persetujuan manusia.
- Alur di atas hanya berlaku untuk indikator `sumber_data = 'operasional'`. Indikator `periodik_manual`/`eksternal` (lihat `idm_indicators.sumber_data`) di-update lewat `/admin/pengaturan/idm`, bukan worker — dashboard wajib menampilkan tanggal update terakhir untuk indikator jenis ini supaya tidak terlihat seolah real-time padahal statis.
- Sizing worker bertahap: MVP cukup 1 queue dengan job priority per dimensi; split ke 6 queue terpisah hanya jika lag terukur melebihi threshold (bukan default sejak awal).

---

## W4. Alur Data Kesehatan (Posyandu) — F4

```
[Kader Posyandu] Input kunjungan balita (berat, tinggi, imunisasi, tanggal)
        │
        ▼
INSERT posyandu_kunjungan ──► event: posyandu.kunjungan.dicatat
        │
        ├──► [Worker] Hitung status gizi (Z-score berat/tinggi/usia)
        │        │
        │        ├── Normal → hanya update agregat dusun
        │        └── Terindikasi masalah gizi → INSERT usulan_kegiatan_draft_otomatis
        │             (kategori: intervensi_gizi, notifikasi HANYA ke admin & kader, TIDAK publik)
        │
        ▼
[Worker] Update dashboard_agregat (cakupan imunisasi %, frekuensi kunjungan per dusun)
        │
        ▼
[Worker] Rekalkulasi skor indikator 7.b (Aktivitas Posyandu, Dimensi Kesehatan)
        │
        ▼
Portal Publik menampilkan agregat saja — tidak pernah data individu balita
```

**Aturan kritikal (RBAC & audit):**
- Setiap akses ke data individu balita (bukan agregat) dicatat di `posyandu_akses_log` — siapa, peran apa, kapan.
- Akses data individu dibatasi ke peran `kader` (dusun terkait saja, bukan lintas dusun) dan `admin_kesehatan`. Kades hanya melihat agregat dashboard, kecuali eskalasi kasus gizi buruk yang sudah masuk `usulan_kegiatan_draft_otomatis`.
- **Catatan terbuka:** alur ini masih berasumsi koneksi backend aktif. Strategi offline-first untuk kader Posyandu di lapangan tanpa sinyal belum dijawab dokumen manapun — lihat Bagian E.

---

## W5. Alur PBB — Pendaftaran Objek hingga Pembayaran — F5

```
[Admin] Daftarkan wajib pajak baru (independen dari `penduduk`, boleh luar desa)
        │
        ▼
[Admin] Daftarkan objek pajak baru
        │
        ├──► Input lokasi (1..N baris: tanah/bangunan, bisa beda koordinat)
        ├──► Input kepemilikan (kepemilikan_objek: wajib_pajak_id + objek_pajak_id + persentase)
        └──► (opsional) Input penghuni (penyewa/pesuruh — TIDAK masuk kepemilikan)
        │
        ▼
event: pbb.objek_pajak.didaftarkan
        │
        ├──► [Worker] Update total NJOP desa (basis skor Dimensi Ekonomi)
        ├──► Jika akses jalan objek buruk → draft usulan infrastruktur (menunggu review admin)
        └──► Jika objek usaha → ikut basis skor Keragaman Aktivitas Ekonomi
        │
        ▼
[Sistem] Generate tagihan tahunan otomatis (pbb_tagihan, status: belum_bayar)
        │
        ▼
[Wajib Pajak] Bayar (tunai/transfer/QRIS) ──► [Admin] Update status_bayar = lunas
        │
        ▼
event: pbb.tagihan.dibayar
        │
        ├──► [Worker] INSERT pades_pendapatan (sumber: pbb) — otomatis, tanpa input manual terpisah
        ├──► Rekalkulasi skor indikator 47.a (PADes, Dimensi Tata Kelola Keuangan)
        └──► Jika objek usaha → rekalkulasi skor indikator 22 (Ekonomi)
```

**Aturan kritikal kepemilikan:**
- Perpindahan kepemilikan (jual-beli/waris) **tidak pernah** meng-UPDATE baris `kepemilikan_objek` lama — tutup dengan `tanggal_selesai`, buat baris baru. Ini menjaga histori tagihan tetap valid meski kepemilikan berubah di kemudian hari.

---

## W6. Alur WhatsApp Chatbot untuk Surat — F6

```
[Warga] Kirim pesan ke nomor WA resmi desa (terverifikasi centang hijau)
        │
        ▼
[Bot] Cek wa_chat_session by nomor HP
        │
   ┌────┴────┐
   ▼         ▼
Belum ada   Ada session aktif
session         │
   │             ▼
   ▼        Lanjutkan dari state terakhir
Buat session baru, state: MENU_UTAMA
        │
        ▼
Bot: "Pilih layanan: 1) Cek info & status (instan)  2) Ajukan surat/usulan  3) Lapor infrastruktur (jalan rusak/fasilitas umum)"
        │
   ┌────┴────────────────────┐
   ▼                          ▼
tier: info_instan         tier: transaksi
   │                          │
   ▼                          ▼
Jawab langsung dari       Bot: "Mau ajukan surat apa?" (list menu jenis surat)
idm_status_desa /              │
dashboard_agregat /            ▼
status surat by NIK       [Warga] Pilih jenis surat ──► state: MENGISI_FORM
(read-only, TANPA OTP,
TANPA masuk antrean admin)
        │
        ▼
Bot cek NIK dikenali? ──► Ya: autofill dari `penduduk`, tanya field pelengkap saja
                      └──► Tidak: minta NIK dulu untuk verifikasi
        │
        ▼
Bot tampilkan ringkasan ──► state: KONFIRMASI
        │
        ▼
[Warga] "Ya" ──► Submit ke alur W1 (status: DIAJUKAN, sumber_kanal: whatsapp)
        │             session di-clear/expire
        ▼
Bot kirim update status otomatis di setiap transisi W1 (diverifikasi/ditolak/selesai)
        │
        ▼
Setelah DITANDATANGANI ──► Bot kirim PDF+QR langsung di chat
```

**Aturan kritikal:**
- Session expire otomatis (mis. 30 menit idle) untuk mencegah state menggantung selamanya.
- Bot rule-based (menu + regex sederhana untuk input bebas seperti alamat) — tidak butuh NLP kompleks di tahap awal.
- **Jam terima vs jam proses (model PANDAWA/CHIKA):** pesan tier `info_instan` dijawab 24 jam nonstop. Pesan tier `transaksi` diterima 24 jam tapi diproses admin hanya pada jam kerja — bot wajib menyampaikan ini eksplisit setelah submit, mis. *"Pesan Anda sudah tersimpan. Verifikasi diproses admin pada jam kerja (Senin–Jumat, 08.00–15.00 WITA)."*, bukan membiarkan warga menunggu tanpa kejelasan.

---

## W7. Alur Ekspor Kepatuhan (SISKEUDES/SIPADES)

```
[Admin] Pilih periode & jenis ekspor (siskeudes/sipades)
        │
        ▼
[Sistem] Tarik data dari fakta turunan terkait
        ├── siskeudes ← apbdes_realisasi, pades_pendapatan
        └── sipades   ← objek_pajak, objek_pajak_lokasi
        │
        ▼
Generate file format resmi (CSV/XML sesuai spesifikasi Kemendagri) ──► status: draft
        │
        ▼
[Admin] Verifikasi isi file ──► status: diverifikasi_admin
        │
        ▼
[Admin] Unduh & unggah manual ke portal SISKEUDES/SIPADES resmi ──► status: diunduh
```

**Aturan kritikal:**
- Satu arah, tanpa integrasi API langsung — SISKEUDES/SIPADES tidak menyediakan API publik yang bisa diandalkan.
- Ekspor tidak boleh dijalankan otomatis tanpa verifikasi admin (`status: draft` wajib direview sebelum `diunduh`) — konsisten dengan prinsip tidak ada aksi kritikal tanpa persetujuan manusia (lihat W3, A3 poin 7).

---

## W8. Alur Pertanahan — F7

```
[Admin] Daftarkan bidang tanah baru: nomor persil, jenis alas hak, luas, poligon lokasi
        │
        ▼
state: DIAJUKAN ──► [Admin verifikasi dokumen alas hak] ──► state: DISAHKAN
        │
        ▼
INSERT kepemilikan_bidang_tanah (berlaku_dari = hari ini, berlaku_sampai = null)
```

**Alur pengalihan kepemilikan (jual-beli/waris/hibah):**
```
[Admin] Catat pengalihan ──► verifikasi dokumen (akta/surat waris) ──►
UPDATE kepemilikan lama SET berlaku_sampai = tanggal_alih
INSERT kepemilikan baru (berlaku_dari = tanggal_alih)
        │
        ▼
Terbitkan event: bidang_tanah.dialihkan
        │
   ┌────┴────┬──────────────┐
   ▼          ▼               ▼
PBB wajib_pajak   F9 peta re-render   F8 (jika tanah_kas_desa berpindah status)
diperbarui         poligon
otomatis
```

**Aturan kritikal:**
- Riwayat kepemilikan append-only — baris lama tidak pernah dihapus/diedit, hanya ditutup `berlaku_sampai`.
- Pengalihan wajib verifikasi admin sebelum insert baris baru — mencegah klaim kepemilikan sepihak tercatat sebagai fakta.

---

## W9. Alur Aset & Inventaris Desa — F8

```
[Event] apbdes.realisasi.dicatat, jenis_belanja = 'modal'
        │
        ▼
[Worker] INSERT aset_desa (status: draft, apbdes_realisasi_id terisi otomatis)
        │
        ▼
[Admin] Buka antrean draft ──► verifikasi kesesuaian dengan realisasi anggaran ──► status: diverifikasi
        │
        ▼
[Admin] Konfirmasi aset diterima/terpasang ──► status: aktif
```

**Alur penyusutan (terjadwal, bukan manual):**
```
[Cron worker, tahunan] Ambil semua aset_desa status='aktif'
        │
        ▼
Hitung nilai_buku sesuai kategori ──► INSERT aset_penyusutan (periode berjalan)
```

**Aturan kritikal:**
- Aset tidak pernah dicatat manual dari nol jika sumbernya belanja modal APBDes — selalu lewat draft otomatis + verifikasi, mencegah data anggaran dan data aset tidak sinkron.
- Aset dari hibah/tanah kas desa lama (bukan dari APBDes) tetap bisa didaftarkan manual oleh admin.

---

## W10. Alur Pemetaan & GIS Partisipatif — F9

```
[Warga] Lapor infrastruktur via web atau WA (tier: transaksi) — foto + lokasi + deskripsi
        │
        ▼
INSERT titik_infrastruktur (status: dilaporkan)
        │
        ▼
[Admin] Verifikasi laporan (cek foto & lokasi) ──► status: diverifikasi
        │
        ▼
Tampil di peta publik (layer titik_infrastruktur)
        │
   ┌────┴────┐
   ▼         ▼
kondisi baik   kondisi rusak_berat
   │             │
   ▼             ▼
status: selesai   Terbitkan draft usulan_kegiatan_draft_otomatis (reuse pola W3)
(jika sudah         status: usulan_dibuat
diperbaiki)
```

**Aturan kritikal:**
- Peta publik menggabungkan beberapa sumber data yang sudah ada (`wilayah_batas`, titik infrastruktur terverifikasi, tanah kas desa dari F7, lokasi posyandu dari F4) — bukan pencatatan lokasi terpisah.
- Privasi: `bidang_tanah.lokasi_geom` milik warga **tidak pernah** ditampilkan di peta publik, hanya tanah kas desa dan titik infrastruktur.

---

## W11. Alur Statistik & Agenda Terpadu — F10

```
[Event] musdes.jadwal.ditetapkan (F2) atau posyandu.jadwal.ditetapkan (F4)
        │
        ▼
[Worker] INSERT agenda_kegiatan (dibuat_otomatis: true, sumber_id terisi)
        │
        ▼
Tampil di /kalender-desa (publik)
        │
        ▼
[Worker, H-1] Untuk setiap agenda_subscriber yang jenis_agenda cocok:
        kirim reminder WA tier info_instan
```

**Statistik desa:** tidak ada alur input tersendiri — dashboard adalah *materialized view* di atas `idm_status_desa`, `dashboard_agregat`, `aset_desa`, `bidang_tanah` yang di-refresh oleh worker propagasi yang sudah ada di W3. Admin tidak pernah mengisi angka statistik secara manual.

**Aturan kritikal:**
- Reminder WA memakai kanal & tier yang sama dengan F6 (`info_instan`) — tidak membangun sistem notifikasi terpisah.
- Subscriber bersifat opt-in per jenis agenda — bukan broadcast otomatis ke semua kontak.

---

## W12. Ringkasan Peta Event Lintas-Modul

| Event | Diterbitkan oleh | Konsumen (efek turunan) |
|---|---|---|
| `penduduk.status.berubah` | Core Registry | Semua rasio IDM berbasis populasi, eligibilitas surat, daftar pemilih voting |
| `posyandu.kunjungan.dicatat` | Modul Kesehatan | Skor 7.b, dashboard kesehatan, draft usulan gizi |
| `surat.diterbitkan` | Modul Surat | Skor 45.b, arsip, notifikasi WA |
| `usulan.vote.bertambah` | Modul Voting | Ranking RKPDes |
| `musdes.usulan.ditetapkan` | Modul Voting/Musdes | Skor 46, draft APBDes |
| `pbb.tagihan.dibayar` | Modul PBB | PADes, skor 47.a, skor 22 (jika usaha) |
| `pbb.objek_pajak.didaftarkan` | Modul PBB | Total NJOP, draft usulan infrastruktur |
| `apbdes.realisasi.dicatat` | Modul Keuangan | Skor Dimensi Tata Kelola Keuangan; jika belanja modal → draft `aset_desa` (F8) |
| `wa.layanan.selesai` | WA Chatbot | Skor 45.c/d (kanal pelayanan) |
| `bidang_tanah.dialihkan` | Modul Pertanahan | `wajib_pajak` (otomatis), poligon peta (F9), status tanah kas desa (F8) |
| `infrastruktur.dilaporkan` | Modul Pemetaan | Draft usulan kegiatan (jika rusak_berat), peta publik |
| `musdes.jadwal.ditetapkan` / `posyandu.jadwal.ditetapkan` | Modul Voting / Kesehatan | `agenda_kegiatan` otomatis, reminder WA (F10) |

---

# BAGIAN C — SKEMA DATABASE & ERD

PostgreSQL + Drizzle ORM · Referensi presisi untuk Claude Code.

## C1. Konvensi Umum

- Semua tabel domain (kecuali tabel referensi global) memiliki `tenant_id UUID NOT NULL` untuk isolasi multi-tenant.
- Primary key: `UUID DEFAULT gen_random_uuid()` di semua tabel.
- Tabel fakta mentah vs fakta turunan dipisah tegas (lihat **§C10**) — hanya fakta turunan yang boleh ditulis oleh worker.
- Semua tabel transaksional kritikal (surat, tagihan, kepemilikan, voting) bersifat **append-only untuk histori** — perubahan status dicatat sebagai baris/log baru, bukan overwrite.

---

## C2. ERD — Core Registry & Kependudukan

```
┌─────────────────┐        ┌──────────────────┐
│     tenants      │        │     penduduk      │
├─────────────────┤   1   N├──────────────────┤
│ id (PK)          ├───────┤ id (PK)            │
│ nama_desa        │        │ tenant_id (FK)     │
│ subdomain        │        │ nik (UQ per tenant)│
│ kode_desa        │        │ nama               │
└─────────────────┘        │ tanggal_lahir       │
                            │ status_kependudukan │
                            │ nomor_hp            │
                            │ bpjs_status         │
                            │ dusun, rt, rw       │
                            └────────┬─────────┘
                                     │ 1
                     ┌───────────────┼───────────────┬─────────────┐
                     │ N             │ N              │ N           │ N
              ┌──────▼─────┐  ┌──────▼──────┐  ┌──────▼─────┐ ┌────▼─────┐
              │   surat_    │  │  usulan_    │  │   pbb_     │ │  wa_chat_│
              │ pengajuan   │  │  votes      │  │ wajib_pajak│ │  session │
              │ (by NIK)    │  │ (by NIK)    │  │ (by NIK,   │ │(by nomor │
              └─────────────┘  └─────────────┘  │  opsional) │ │   hp)    │
                                                  └────────────┘ └──────────┘
```

**Tabel:**
```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_desa VARCHAR(150) NOT NULL,
  subdomain VARCHAR(63) NOT NULL UNIQUE,     -- mis. 'seruni-mumbul' → seruni-mumbul.desaku.id
  kode_desa VARCHAR(13) NOT NULL UNIQUE,     -- kode Kemendagri (provinsi-kab-kec-desa)
  kecamatan VARCHAR(100),
  kabupaten VARCHAR(100),
  provinsi VARCHAR(100),
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE penduduk (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nik VARCHAR(16) NOT NULL,
  nama VARCHAR(150) NOT NULL,
  jenis_kelamin VARCHAR(1) CHECK (jenis_kelamin IN ('L','P')),
  tanggal_lahir DATE,
  status_kependudukan VARCHAR(20) NOT NULL DEFAULT 'aktif'
    CHECK (status_kependudukan IN ('aktif','pindah','meninggal')),
  nomor_hp VARCHAR(20),
  bpjs_status VARCHAR(20) CHECK (bpjs_status IN ('aktif','tidak_aktif','tidak_ada','tidak_diketahui')),
  alamat TEXT,
  dusun VARCHAR(50), rt VARCHAR(5), rw VARCHAR(5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, nik)
);
-- Catatan: nomor_hp TIDAK diberi UNIQUE — satu HP bisa dipakai bergantian oleh anggota
-- keluarga yang sama untuk wa_chat_session; identitas transaksi tetap berbasis NIK/penduduk_id.
```

---

## C3. ERD — Modul Surat (F1 & F6)

```
┌──────────────────┐        ┌───────────────────┐        ┌────────────────────┐
│   surat_jenis     │   1   N│  surat_pengajuan   │   1   1│   surat_dokumen     │
├──────────────────┤────────├───────────────────┤────────├────────────────────┤
│ id (PK)           │        │ id (PK)            │        │ id (PK)             │
│ nama_jenis        │        │ tenant_id (FK)     │        │ surat_pengajuan_id  │
│ template_field[]  │        │ jenis_surat_id (FK)│        │ file_path           │
│ format_nomor_arsip│        │ penduduk_id (FK)   │        │ document_hash       │
└──────────────────┘        │ status             │        │ qr_uuid             │
                             │ sumber_kanal        │        │ ttd_oleh (FK→penduduk│
                             │ (web/whatsapp)      │        │            /pejabat)│
                             │ nomor_surat          │        │ tanggal_ttd         │
                             │ data_form (JSONB)    │        └────────────────────┘
                             └─────────┬───────────┘
                                       │ 1
                                       │ N
                             ┌─────────▼───────────┐
                             │  surat_log_status     │
                             ├──────────────────────┤
                             │ id (PK)               │
                             │ surat_pengajuan_id(FK)│
                             │ status_dari, status_ke│
                             │ aktor_id, catatan      │
                             │ created_at             │
                             └──────────────────────┘

┌──────────────────────┐
│   wa_chat_session      │
├──────────────────────┤
│ id (PK)                │
│ tenant_id (FK)          │
│ nomor_hp                │
│ current_state           │  (MENU_UTAMA/MENGISI_FORM/KONFIRMASI)
│ context_data (JSONB)     │
│ surat_pengajuan_id (FK, nullable)
│ last_activity_at         │
│ expires_at               │
└──────────────────────┘
```

**Tabel:**
```sql
CREATE TABLE surat_jenis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama_jenis VARCHAR(150) NOT NULL,
  template_field JSONB NOT NULL,        -- daftar field non-identitas yang perlu diisi
  format_nomor_arsip VARCHAR(50) NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE surat_pengajuan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_surat_id UUID NOT NULL REFERENCES surat_jenis(id),
  penduduk_id UUID NOT NULL REFERENCES penduduk(id),
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diajukan','diverifikasi','ditolak','ditandatangani','dikirim','arsip')),
  sumber_kanal VARCHAR(10) NOT NULL DEFAULT 'web' CHECK (sumber_kanal IN ('web','whatsapp')),
  nomor_surat VARCHAR(60) UNIQUE,        -- diisi saat status=ditandatangani
  data_form JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE surat_dokumen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL UNIQUE REFERENCES surat_pengajuan(id),
  file_path TEXT NOT NULL,
  document_hash VARCHAR(128) NOT NULL,
  qr_uuid UUID NOT NULL DEFAULT gen_random_uuid(),
  ttd_oleh_penduduk_id UUID REFERENCES penduduk(id),  -- Kades/Sekdes
  tanggal_ttd TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE surat_log_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL REFERENCES surat_pengajuan(id),
  status_dari VARCHAR(20), status_ke VARCHAR(20) NOT NULL,
  aktor_id UUID, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE wa_chat_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  current_state VARCHAR(30) NOT NULL DEFAULT 'menu_utama',
  tier VARCHAR(15) NOT NULL DEFAULT 'transaksi'
    CHECK (tier IN ('info_instan','transaksi')),  -- info_instan: read-only, tanpa OTP, tanpa antrean admin
  context_data JSONB NOT NULL DEFAULT '{}',
  surat_pengajuan_id UUID REFERENCES surat_pengajuan(id),
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(tenant_id, nomor_hp)
);
```

---

## C4. ERD — Modul Usulan Kegiatan & Voting (F2)

```
┌───────────────────────┐        ┌──────────────────┐
│   usulan_kegiatan       │   1  N│  usulan_votes      │
├───────────────────────┤────────├──────────────────┤
│ id (PK)                  │      │ id (PK)             │
│ tenant_id (FK)            │     │ usulan_id (FK)       │
│ pengusul_penduduk_id (FK) │     │ nik                  │
│ judul, deskripsi           │    │ voted_at             │
│ kategori_bidang             │   │ UNIQUE(usulan_id,nik)│
│ kategori_sub_bidang          │  └──────────────────┘
│ lokasi, estimasi_manfaat      │
│ status ('diajukan'/            │
│  'lolos_verifikasi'/'ditolak'/ │
│  'ditetapkan_rkpdes')           │
│ kode_rekening_saran (nullable,  │  ← diisi otomatis jika berasal
│   FK-like ke idm_indicators)     │    dari usulan_kegiatan_draft_otomatis
│ sumber ('warga'/'draft_otomatis')│
│ created_at                        │
└───────────────────────┘

┌──────────────────────────────────┐
│  usulan_kegiatan_draft_otomatis     │   ← ditulis HANYA oleh worker propagasi
├──────────────────────────────────┤
│ id (PK)                            │
│ tenant_id (FK)                      │
│ kategori                             │
│ sumber_pemicu (event_type)            │
│ sumber_ref_id                          │
│ kode_rekening_saran                     │
│ status ('menunggu_review'/'diadopsi'/    │
│         'diabaikan')                      │
│ created_at                                 │
└──────────────────────────────────┘
```

```sql
CREATE TABLE usulan_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  pengusul_penduduk_id UUID REFERENCES penduduk(id),  -- nullable jika sumber=draft_otomatis
  judul VARCHAR(200) NOT NULL,
  deskripsi TEXT NOT NULL,
  kategori_bidang VARCHAR(100) NOT NULL,     -- sesuai Permendagri 20/2018
  kategori_sub_bidang VARCHAR(100) NOT NULL,
  lokasi TEXT,
  estimasi_manfaat TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'diajukan'
    CHECK (status IN ('diajukan','ditolak','lolos_verifikasi','ditetapkan_rkpdes')),
  kode_rekening_saran VARCHAR(30),
  sumber VARCHAR(20) NOT NULL DEFAULT 'warga' CHECK (sumber IN ('warga','draft_otomatis')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE usulan_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usulan_id UUID NOT NULL REFERENCES usulan_kegiatan(id),
  nik VARCHAR(16) NOT NULL,
  voted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(usulan_id, nik)   -- kunci anti-spam: 1 NIK, 1x per usulan (bukan per sesi)
);

CREATE TABLE usulan_kegiatan_draft_otomatis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kategori VARCHAR(50) NOT NULL,
  sumber_pemicu VARCHAR(100) NOT NULL,
  sumber_ref_id UUID NOT NULL,
  kode_rekening_saran VARCHAR(30),
  status VARCHAR(20) NOT NULL DEFAULT 'menunggu_review'
    CHECK (status IN ('menunggu_review','diadopsi','diabaikan')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## C5. ERD — Modul PBB (F5)

DDL berikut sudah **mandiri dan lengkap**, siap dieksekusi berdiri sendiri tanpa dependensi ke berkas eksternal.

```
┌────────────────┐          ┌─────────────────────┐          ┌────────────────┐
│  wajib_pajak     │  N    N │  kepemilikan_objek     │  N    1  │  objek_pajak     │
├────────────────┤──────────├─────────────────────┤──────────├────────────────┤
│ id (PK)           │        │ id (PK)                │        │ id (PK)          │
│ tenant_id          │        │ wajib_pajak_id (FK)     │        │ tenant_id         │
│ penduduk_id (FK,    │       │ objek_pajak_id (FK)      │       │ nop               │
│   nullable)           │     │ persentase_kepemilikan    │      │ status             │
│ nik, nama               │   │ tanggal_mulai               │    │ jenis_usaha         │
│ alamat_domisili           │ │ tanggal_selesai (null=aktif)  │  │ nilai_njop_total     │
│ is_luar_desa                │└─────────────────────┘        └────────┬─────────┘
└────────────────┘                                                     │ 1
                                                            ┌───────────┼───────────┐
                                                            │ N                    N │
                                                  ┌─────────▼─────────┐   ┌─────────▼──────────┐
                                                  │ objek_pajak_lokasi   │   │ objek_pajak_penghuni │
                                                  ├─────────────────┤   ├────────────────────┤
                                                  │ id (PK)              │   │ id (PK)                │
                                                  │ objek_pajak_id (FK)   │   │ objek_pajak_id (FK)     │
                                                  │ jenis_lokasi (tanah/   │  │ nama_penghuni            │
                                                  │  bangunan)               │ │ jenis_penghuni            │
                                                  │ latitude, longitude        │ (penyewa/pesuruh/dll)      │
                                                  │ luas_m2, kelas_njop           │ tanggal_mulai/selesai       │
                                                  └─────────────────┘   └────────────────────┘
                                                            │ 1
                                                            │ N
                                                  ┌─────────▼─────────┐
                                                  │   pbb_tagihan        │
                                                  ├─────────────────┤
                                                  │ id (PK)               │
                                                  │ objek_pajak_id (FK)    │
                                                  │ tahun_pajak              │
                                                  │ jumlah_pokok, denda        │
                                                  │ status_bayar                 │
                                                  │ snapshot_wajib_pajak_utama(FK)│
                                                  └─────────────────┘
```

```sql
CREATE TABLE wajib_pajak (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  penduduk_id UUID REFERENCES penduduk(id),   -- null jika wajib pajak bukan warga terdaftar (is_luar_desa)
  nik VARCHAR(16) NOT NULL,
  nama VARCHAR(150) NOT NULL,
  alamat_domisili TEXT,
  is_luar_desa BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE objek_pajak (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nop VARCHAR(30) NOT NULL,                    -- Nomor Objek Pajak
  bidang_tanah_id UUID REFERENCES bidang_tanah(id),  -- fakta luas & lokasi tunggal, lihat §C9/F7
  status VARCHAR(20) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif','nonaktif','sengketa')),
  jenis_usaha VARCHAR(100),                    -- null jika objek murni hunian, non-usaha
  nilai_njop_total NUMERIC(15,2) NOT NULL DEFAULT 0,  -- turunan dari SUM(objek_pajak_lokasi), di-refresh worker
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, nop)
);

CREATE TABLE objek_pajak_lokasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  jenis_lokasi VARCHAR(10) NOT NULL CHECK (jenis_lokasi IN ('tanah','bangunan')),
  latitude NUMERIC(10,7), longitude NUMERIC(10,7),
  luas_m2 NUMERIC(12,2) NOT NULL,
  kelas_njop VARCHAR(10) NOT NULL,             -- kode kelas NJOP tanah/bangunan sesuai SK Bupati
  nilai_njop_per_m2 NUMERIC(15,2) NOT NULL
);
CREATE INDEX idx_objek_pajak_lokasi_geo ON objek_pajak_lokasi(latitude, longitude);

CREATE TABLE objek_pajak_penghuni (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  nama_penghuni VARCHAR(150) NOT NULL,
  jenis_penghuni VARCHAR(20) NOT NULL CHECK (jenis_penghuni IN ('penyewa','pesuruh','lainnya')),
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE                          -- null = masih menghuni
);

CREATE TABLE kepemilikan_objek (              -- append-only, pola sama dengan kepemilikan_bidang_tanah (§C9)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wajib_pajak_id UUID NOT NULL REFERENCES wajib_pajak(id),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  persentase_kepemilikan NUMERIC(5,2) NOT NULL CHECK (persentase_kepemilikan > 0 AND persentase_kepemilikan <= 100),
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE                          -- null = kepemilikan masih berlaku
);
-- Event: bidang_tanah.dialihkan → worker menutup kepemilikan_objek lama (tanggal_selesai)
-- dan INSERT baris baru mengikuti kepemilikan_bidang_tanah terbaru (lihat §C9)

CREATE TABLE pbb_tagihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  tahun_pajak INT NOT NULL,
  jumlah_pokok NUMERIC(15,2) NOT NULL,
  denda NUMERIC(15,2) NOT NULL DEFAULT 0,
  status_bayar VARCHAR(15) NOT NULL DEFAULT 'belum_bayar'
    CHECK (status_bayar IN ('belum_bayar','sebagian','lunas')),
  snapshot_wajib_pajak_utama_id UUID NOT NULL REFERENCES wajib_pajak(id),  -- pemilik mayoritas saat tagihan terbit
  tanggal_bayar TIMESTAMPTZ,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(objek_pajak_id, tahun_pajak)
);
-- Event: pbb.tagihan.dibayar (saat status_bayar → 'lunas') → worker INSERT pades_pendapatan (§C6)
-- dan update idm_skor_cache (skor 47.a, skor 22 jika jenis_usaha terisi)
```

*(Logika worker turunan — event → efek PADes/skor IDM — tetap perlu ditulis sebagai kode aplikasi terpisah, tapi strukturnya sudah bisa diturunkan langsung dari kolom `jenis_belanja`, event `pbb.tagihan.dibayar`, dan tabel `pades_pendapatan`/`idm_skor_cache` di atas.)*

---

## C6. ERD — Modul APBDes / SIKEUDES (fondasi anggaran)

Struktur berjenjang mengikuti Permendagri 20/2018: **Bidang → Sub-Bidang → Kegiatan → Rekening Anggaran**. `usulan_kegiatan.kategori_bidang`/`kategori_sub_bidang` (§C4) tetap `VARCHAR` bebas untuk kompatibilitas mundur, tapi harus diisi dari `nama` tabel di bawah ini agar konsisten — bukan diketik bebas oleh admin.

```sql
CREATE TABLE bidang_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(2) NOT NULL UNIQUE,             -- '1'..'5' sesuai Permendagri 20/2018, sama untuk semua tenant
  nama VARCHAR(150) NOT NULL
);
-- Seed baku (5 bidang resmi, sama untuk seluruh tenant — bukan per-desa):
-- ('1','Penyelenggaraan Pemerintahan Desa'), ('2','Pelaksanaan Pembangunan Desa'),
-- ('3','Pembinaan Kemasyarakatan Desa'), ('4','Pemberdayaan Masyarakat Desa'),
-- ('5','Penanggulangan Bencana, Keadaan Darurat, dan Mendesak Desa')

CREATE TABLE sub_bidang (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_kegiatan_id UUID NOT NULL REFERENCES bidang_kegiatan(id),
  kode VARCHAR(10) NOT NULL,
  nama VARCHAR(200) NOT NULL,
  UNIQUE(bidang_kegiatan_id, kode)
);
-- Daftar lengkap sub-bidang per Permendagri 20/2018 tidak dituliskan manual di sini (puluhan entri,
-- rawan salah ketik) — impor dari tabel referensi resmi Kemendagri saat seeding, satu kali untuk semua tenant.

CREATE TABLE rekening_anggaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sub_bidang_id UUID NOT NULL REFERENCES sub_bidang(id),
  kode_rekening VARCHAR(30) NOT NULL UNIQUE,   -- mis. '2.1.4.02' — konsisten dengan idm_indicators.kode_rekening
  nama_rekening VARCHAR(200) NOT NULL,
  jenis_belanja VARCHAR(15) NOT NULL
    CHECK (jenis_belanja IN ('operasional','modal','tak_terduga','transfer'))
);

CREATE TABLE kegiatan_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  sub_bidang_id UUID NOT NULL REFERENCES sub_bidang(id),
  rekening_anggaran_id UUID NOT NULL REFERENCES rekening_anggaran(id),
  nama_kegiatan VARCHAR(200) NOT NULL,
  usulan_kegiatan_id UUID REFERENCES usulan_kegiatan(id),  -- null jika kegiatan rutin, bukan hasil usulan warga
  tahun_anggaran VARCHAR(4) NOT NULL,
  pagu_anggaran NUMERIC(15,2) NOT NULL,
  sumber_dana VARCHAR(20) NOT NULL DEFAULT 'add'
    CHECK (sumber_dana IN ('add','dana_desa','pad','bagi_hasil_pajak','lainnya')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE apbdes_realisasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kegiatan_desa_id UUID NOT NULL REFERENCES kegiatan_desa(id),
  jenis_belanja VARCHAR(15) NOT NULL
    CHECK (jenis_belanja IN ('operasional','modal','tak_terduga','transfer')),  -- snapshot dari rekening_anggaran saat dicatat
  jumlah NUMERIC(15,2) NOT NULL,
  tanggal_realisasi DATE NOT NULL,
  keterangan TEXT,
  dicatat_oleh UUID,                            -- admin/bendahara desa, tidak FK ke penduduk (peran internal)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: apbdes.realisasi.dicatat → konsumen: ekspor_kepatuhan (siskeudes), dan jika jenis_belanja='modal'
-- → W9 draft aset_desa otomatis (§C9)

CREATE TABLE pades_pendapatan (               -- FAKTA TURUNAN — ditulis hanya oleh worker
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  sumber VARCHAR(20) NOT NULL CHECK (sumber IN ('pbb','retribusi','hibah','lainnya')),
  sumber_ref_id UUID,                           -- FK dinamis, mis. pbb_tagihan.id saat sumber='pbb'
  jumlah NUMERIC(15,2) NOT NULL,
  tanggal DATE NOT NULL,
  dicatat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Ditulis oleh worker saat event pbb.tagihan.dibayar diterima (lihat W5) —
-- TIDAK ADA endpoint admin untuk INSERT manual ke tabel ini (konsisten §C10)
```

---

## C7. ERD — Modul IDM / Event Propagation Layer

```
┌───────────────────┐        ┌───────────────────────┐
│   domain_events      │        │  idm_indicators          │  ← seed dari idm_indicators.csv
├───────────────────┤        ├───────────────────────┤
│ id (PK)               │      │ id (PK)                    │
│ tenant_id               │    │ dimensi_no, dimensi_nama     │
│ event_type                │  │ subdim_kode, indikator_no      │
│ entity_id                    │ │ sub_kode, sub_pertanyaan          │
│ payload (JSONB)                │ │ skor_max                             │
│ created_at, processed_at          │ └───────────────────────┘
└───────────────────┘                        │ 1
        │ dikonsumsi oleh worker              │ N
        ▼                             ┌───────▼──────────────┐
┌───────────────────────┐             │ idm_scoring_thresholds │
│    idm_skor_cache        │◄─────────┤ (ambang nilai per skor)│
├───────────────────────┤   ditulis   └───────────────────────┘
│ id (PK)                  │   worker
│ tenant_id                  │
│ indikator_kode                │
│ skor, nilai_agregat               │
│ dihitung_pada                        │
│ UNIQUE(tenant_id, indikator_kode)       │
└───────────────────────┘
        │ agregat
        ▼
┌───────────────────────┐
│   idm_status_desa         │  ← klasifikasi akhir, dibaca Portal Publik
├───────────────────────┤
│ tenant_id (PK)             │
│ total_skor                    │
│ status ('mandiri'/'maju'/       │
│  'berkembang'/'tertinggal'/       │
│  'sangat_tertinggal')                │
│ updated_at                              │
└───────────────────────┘
```

```sql
CREATE TABLE domain_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  event_type VARCHAR(100) NOT NULL,
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ
);
CREATE INDEX idx_events_unprocessed ON domain_events(tenant_id, processed_at) WHERE processed_at IS NULL;

CREATE TABLE idm_indicators (        -- seed dari idm_indicators.csv, sama untuk semua tenant
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dimensi_no INT NOT NULL, dimensi_nama VARCHAR(100) NOT NULL,
  subdim_kode VARCHAR(20), subdim_nama VARCHAR(150),
  indikator_no INT NOT NULL, indikator_nama VARCHAR(200) NOT NULL,
  indikator_skor_max INT,
  sub_kode VARCHAR(10), sub_pertanyaan TEXT, sub_skor_max INT,
  rekomendasi_intervensi TEXT, kode_rekening VARCHAR(30), pelaksana TEXT,
  sumber_data VARCHAR(20) NOT NULL DEFAULT 'operasional'
    CHECK (sumber_data IN ('operasional','periodik_manual','eksternal'))
    -- operasional: dihitung dari domain_events (benar-benar real-time)
    -- periodik_manual: diinput admin berkala, dashboard wajib tampilkan tanggal update terakhir
    -- eksternal: impor berkala dari BPS/Kemendes SDGs, bukan event internal
);

CREATE TABLE idm_scoring_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id),
  skor_level INT NOT NULL CHECK (skor_level BETWEEN 1 AND 5),
  deskripsi_kondisi TEXT NOT NULL,      -- dari kolom contoh_deskripsi_skor_maks
  nilai_ambang_bawah NUMERIC, nilai_ambang_atas NUMERIC   -- untuk indikator berbasis rasio
);

CREATE TABLE idm_skor_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  indikator_kode VARCHAR(30) NOT NULL,
  skor NUMERIC, nilai_agregat NUMERIC,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, indikator_kode)
);

CREATE TABLE idm_status_desa (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  total_skor NUMERIC NOT NULL,
  status VARCHAR(30) NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE dashboard_agregat (              -- FAKTA TURUNAN — ditulis hanya oleh worker (§C10)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  wilayah_id UUID REFERENCES wilayah_batas(id),   -- null = agregat tingkat desa penuh, non-null = per dusun/RT/RW
  kategori VARCHAR(40) NOT NULL,                  -- mis. 'kesehatan', 'ekonomi', 'infrastruktur'
  metrik_key VARCHAR(60) NOT NULL,                -- mis. 'cakupan_imunisasi_persen', 'frekuensi_kunjungan_posyandu'
  metrik_value NUMERIC NOT NULL,
  periode VARCHAR(20) NOT NULL,                   -- mis. '2026-07' (bulanan) atau '2026' (tahunan)
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, wilayah_id, kategori, metrik_key, periode)
);
-- Tabel generik key-value agar tidak perlu 1 kolom baru tiap metrik dashboard baru ditambahkan.
-- Granularitas ditentukan oleh wilayah_id: null untuk kartu ringkasan desa, terisi untuk breakdown per dusun/RT/RW
-- yang dipakai F3/F4/W4/W11 (mis. "cakupan imunisasi per dusun").
```

---

## C8. ERD — Kepatuhan Pelaporan & Akses Data Sensitif

```sql
CREATE TABLE ekspor_kepatuhan (       -- jalur konkret non-tujuan A1.3 (SISKEUDES/SIPADES)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_ekspor VARCHAR(30) NOT NULL CHECK (jenis_ekspor IN ('siskeudes','sipades')),
  periode VARCHAR(20) NOT NULL,          -- mis. '2026-Q3'
  file_path TEXT NOT NULL,               -- format resmi CSV/XML sesuai spesifikasi Kemendagri
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diverifikasi_admin','diunduh')),
  dihasilkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Sumber data: apbdes_realisasi/pades_pendapatan (siskeudes), objek_pajak/objek_pajak_lokasi (sipades)
-- Satu arah: hasilkan file siap-unggah, bukan integrasi API langsung

CREATE TABLE balita (                 -- fakta mentah dasar F4, dirujuk posyandu_kunjungan & posyandu_akses_log
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama VARCHAR(150) NOT NULL,
  tanggal_lahir DATE NOT NULL,
  orang_tua_penduduk_id UUID REFERENCES penduduk(id),
  dusun_id UUID REFERENCES wilayah_batas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE posyandu_kunjungan (     -- fakta mentah, diinput kader (lihat W4)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  balita_id UUID NOT NULL REFERENCES balita(id),
  tanggal DATE NOT NULL,
  berat_kg NUMERIC(5,2), tinggi_cm NUMERIC(5,2),
  imunisasi VARCHAR(50)[],             -- daftar jenis imunisasi yang diberikan pada kunjungan ini
  status_gizi VARCHAR(20) CHECK (status_gizi IN ('baik','kurang','buruk','lebih')),
  dicatat_oleh_penduduk_id UUID REFERENCES penduduk(id),  -- kader posyandu
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: posyandu.kunjungan.dicatat → worker update dashboard_agregat (cakupan imunisasi per dusun)
-- dan, jika status_gizi='buruk', INSERT usulan_kegiatan_draft_otomatis (pola sama dengan W3)

CREATE TABLE posyandu_akses_log (     -- RBAC & audit akses data individu balita (perluasan F4/W4)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kunjungan_id UUID NOT NULL REFERENCES posyandu_kunjungan(id),
  diakses_oleh UUID NOT NULL,
  peran_pengakses VARCHAR(20) NOT NULL CHECK (peran_pengakses IN ('kader','admin_kesehatan','kades')),
  diakses_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Akses data individu dibatasi: kader (dusun terkait saja), admin_kesehatan; Kades hanya lihat agregat
-- kecuali eskalasi kasus gizi buruk yang sudah memicu usulan_kegiatan_draft_otomatis
```

---

## C9. ERD — Pertanahan, Aset Desa, Pemetaan, Statistik & Agenda (F7–F10)

```sql
-- F7. PERTANAHAN
CREATE TABLE bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_persil VARCHAR(50),            -- NIB / nomor girik / nomor persil lokal
  jenis_alas_hak VARCHAR(20) NOT NULL
    CHECK (jenis_alas_hak IN ('shm','shgb','girik','tanah_kas_desa','lainnya')),
  luas_m2 NUMERIC(12,2) NOT NULL,
  lokasi_geom GEOMETRY(POLYGON, 4326),  -- PostGIS, opsional jika belum ada data ukur
  dusun_id UUID REFERENCES wilayah_batas(id),   -- FK ke baris wilayah_batas dengan jenis='dusun';
                                                  -- nama tabel final adalah wilayah_batas (bukan wilayah_administratif)
  status VARCHAR(20) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif','sengketa','nonaktif')),
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE kepemilikan_bidang_tanah (   -- append-only, pola sama dengan kepemilikan_objek PBB
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_tanah_id UUID NOT NULL REFERENCES bidang_tanah(id),
  penduduk_id UUID REFERENCES penduduk(id),    -- null jika milik desa (tanah kas desa)
  jenis_perolehan VARCHAR(20) NOT NULL
    CHECK (jenis_perolehan IN ('jual_beli','waris','hibah','girik_awal','pengadaan_desa')),
  berlaku_dari DATE NOT NULL,
  berlaku_sampai DATE,                 -- null = masih berlaku
  dicatat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: bidang_tanah.dialihkan (insert baris baru) → konsumen: wajib_pajak (update otomatis),
-- F9 pemetaan (re-render poligon), F8 aset_desa (jika jenis_alas_hak = tanah_kas_desa)

-- F8. ASET & INVENTARIS DESA
CREATE TABLE aset_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kode_aset VARCHAR(30) NOT NULL,
  nama_aset VARCHAR(200) NOT NULL,
  kategori VARCHAR(30) NOT NULL CHECK (kategori IN ('tanah','bangunan','kendaraan','peralatan','lainnya')),
  bidang_tanah_id UUID REFERENCES bidang_tanah(id),        -- jika kategori = tanah
  nilai_perolehan NUMERIC(15,2),
  tanggal_perolehan DATE,
  sumber_perolehan VARCHAR(20) CHECK (sumber_perolehan IN ('apbdes','hibah','tanah_kas_desa_lama')),
  apbdes_realisasi_id UUID REFERENCES apbdes_realisasi(id), -- link ke belanja modal asal (draft otomatis)
  kondisi VARCHAR(20) NOT NULL DEFAULT 'baik' CHECK (kondisi IN ('baik','rusak_ringan','rusak_berat')),
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diverifikasi','aktif','dihapusbukukan')),
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE aset_penyusutan (        -- fakta turunan, dihitung worker terjadwal (bukan event-driven)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aset_id UUID NOT NULL REFERENCES aset_desa(id),
  periode VARCHAR(10) NOT NULL,       -- '2026'
  nilai_buku NUMERIC(15,2) NOT NULL,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event konsumen: apbdes.realisasi.dicatat dengan jenis_belanja='modal' → INSERT aset_desa(status='draft')

-- F9. PEMETAAN & GIS PARTISIPATIF
CREATE TABLE wilayah_batas (          -- poligon dusun/RT/RW — satu-satunya tabel wilayah (bukan dua)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis VARCHAR(10) NOT NULL CHECK (jenis IN ('dusun','rt','rw')),
  nama VARCHAR(100) NOT NULL,
  geom GEOMETRY(POLYGON, 4326) NOT NULL,
  parent_id UUID REFERENCES wilayah_batas(id)   -- RT di dalam RW di dalam dusun
);

CREATE TABLE titik_infrastruktur (    -- dilaporkan warga, terverifikasi admin sebelum publik
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  pelapor_penduduk_id UUID REFERENCES penduduk(id),
  jenis VARCHAR(30) NOT NULL CHECK (jenis IN ('jalan_rusak','fasilitas_umum','lampu_jalan','lainnya')),
  deskripsi TEXT,
  foto_url TEXT,
  lokasi_geom GEOMETRY(POINT, 4326) NOT NULL,
  kondisi VARCHAR(20) CHECK (kondisi IN ('baik','rusak_ringan','rusak_berat')),
  status VARCHAR(20) NOT NULL DEFAULT 'dilaporkan'
    CHECK (status IN ('dilaporkan','diverifikasi','usulan_dibuat','selesai')),
  dilaporkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: infrastruktur.dilaporkan → jika kondisi='rusak_berat' & diverifikasi admin
--        → INSERT usulan_kegiatan_draft_otomatis (reuse pola W3)
-- Privasi peta publik: bidang_tanah.lokasi_geom milik warga TIDAK ditampilkan publik,
--        hanya tanah_kas_desa dan titik_infrastruktur terverifikasi

-- F10. STATISTIK & AGENDA TERPADU
CREATE TABLE agenda_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  judul VARCHAR(200) NOT NULL,
  jenis VARCHAR(20) NOT NULL CHECK (jenis IN ('musdes','posyandu','umum')),
  sumber_id UUID,                     -- FK dinamis ke jadwal musdes/posyandu, null jika 'umum'
  waktu_mulai TIMESTAMPTZ NOT NULL,
  waktu_selesai TIMESTAMPTZ,
  lokasi TEXT,
  dibuat_otomatis BOOLEAN NOT NULL DEFAULT false
);
-- Event konsumen: jadwal musdes (F2) & jadwal posyandu (F4) → INSERT agenda_kegiatan(dibuat_otomatis=true)
-- Statistik: TIDAK ada tabel baru — materialized view di atas idm_status_desa, dashboard_agregat,
--        aset_desa, bidang_tanah, di-refresh oleh worker yang sudah ada

CREATE TABLE agenda_subscriber (      -- opt-in reminder WA, reuse tier info_instan dari F6
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  jenis_agenda VARCHAR(20)[] NOT NULL DEFAULT ARRAY['musdes','posyandu','umum'],
  PRIMARY KEY (tenant_id, nomor_hp)
);
```

---

## C10. Aturan Pemisahan Fakta Mentah vs Fakta Turunan

| Kategori | Tabel | Ditulis oleh |
|---|---|---|
| **Fakta mentah** | `tenants`, `penduduk`, `surat_pengajuan`, `usulan_kegiatan` (sumber=warga), `usulan_votes`, `wajib_pajak`, `objek_pajak*`, `kepemilikan_objek`, `pbb_tagihan`, `bidang_kegiatan`, `sub_bidang`, `rekening_anggaran`, `kegiatan_desa`, `apbdes_realisasi`, `balita`, `posyandu_kunjungan`, `bidang_tanah`, `kepemilikan_bidang_tanah` | Manusia (form web/WA) atau integrasi eksternal |
| **Fakta turunan** | `idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `usulan_kegiatan_draft_otomatis`, `pades_pendapatan`, `aset_penyusutan` | **Hanya** worker propagasi (BullMQ) |

**Aturan tegas:** tidak ada endpoint API yang mengizinkan admin meng-edit langsung tabel fakta turunan. Koreksi selalu dilakukan di fakta mentah, sistem menghitung ulang otomatis.

---

## C11. Urutan Eksekusi Migrasi

Urutan penulisan tabel di dokumen ini **bukan** urutan eksekusi SQL yang valid — beberapa tabel di bagian awal mem-FK ke tabel yang baru didefinisikan di bagian belakang (mis. `objek_pajak` → `bidang_tanah` di §C9). Jalankan `CREATE TABLE` sesuai urutan dependensi berikut, bukan urutan halaman dokumen ini:

1. `tenants`
2. `penduduk`
3. `wilayah_batas` (self-referencing lewat `parent_id`, tidak butuh tabel lain)
4. `bidang_tanah`, `kepemilikan_bidang_tanah`
5. `bidang_kegiatan` → `sub_bidang` → `rekening_anggaran`
6. `surat_jenis` → `surat_pengajuan` → `surat_dokumen`, `surat_log_status`, `wa_chat_session`
7. `usulan_kegiatan` → `usulan_votes`, `usulan_kegiatan_draft_otomatis`
8. `kegiatan_desa` → `apbdes_realisasi`
9. `wajib_pajak`, `objek_pajak` → `objek_pajak_lokasi`, `objek_pajak_penghuni`, `kepemilikan_objek` → `pbb_tagihan`
10. `balita` → `posyandu_kunjungan` → `posyandu_akses_log`
11. `domain_events`, `idm_indicators` → `idm_scoring_thresholds`, `idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `pades_pendapatan`
12. `ekspor_kepatuhan`
13. `aset_desa` → `aset_penyusutan`
14. `titik_infrastruktur`, `agenda_kegiatan` → `agenda_subscriber`

Ini bisa langsung dipakai sebagai urutan file migrasi Drizzle (`0001_tenants.sql`, `0002_penduduk.sql`, dst.) tanpa perlu AI agent menebak ulang dependensinya.

> **Catatan integrasi Bagian D:** skema pendukung frontend zero-hardcode (`tenant_theme_config`, `site_content_blocks`, `site_navigation`, `feature_flags`, `i18n_strings`, `site_settings`) didefinisikan di **§D1.2** — perlu ditambahkan ke migrasi bersama skema domain di atas, idealnya setelah langkah 1 (`tenants`) karena semuanya mem-FK ke `tenants`.

---

# BAGIAN D — DESAIN FRONTEND

Multi-Page Architecture · Mobile-First · Zero Hardcode · Referensi presisi untuk Claude Code.

## D0. Tiga Prinsip Wajib

1. **Multi-Page, bukan SPA.** Setiap halaman punya route server-rendered sendiri (Next.js App Router `app/(public)/page.tsx`, `app/login/page.tsx`, `app/admin/pengaturan/page.tsx`, dst). Navigasi antar-halaman adalah *full page load* yang dioptimalkan (RSC streaming), bukan client-side router tunggal yang menyamar jadi banyak "halaman". Ini penting untuk SEO portal publik & performa di HP low-end warga desa.
2. **Mobile-First.** Semua breakpoint didesain dari 360px ke atas. Layout desktop adalah *penambahan*, bukan penyusutan dari desktop.
3. **Zero Hardcode.** Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen. Semua berasal dari config/database (lihat §D1). Mengganti nama desa, logo, warna tema, atau urutan section beranda **tidak boleh butuh redeploy kode**.

---

## D1. Arsitektur "Zero Hardcode"

### D1.1 Sumber kebenaran konten
```
tenant_theme_config      → warna, logo, favicon, font pilihan (dari 2-3 preset resmi)
site_content_blocks      → isi tiap section beranda (tipe, urutan, JSON konten)
site_navigation          → menu header/footer, urutan, label, link (internal/eksternal)
site_settings            → nama resmi desa, alamat kantor, jam layanan, kontak, nomor WA resmi terverifikasi
feature_flags            → modul mana yang aktif per tenant (F1-F10 bisa dinyalakan/dimatikan)
i18n_strings             → semua label UI (default id-ID, siap tambah bahasa daerah/EN)
```

### D1.2 Skema pendukung (ringkas)
```sql
CREATE TABLE tenant_theme_config (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  logo_url TEXT, favicon_url TEXT,
  warna_primer VARCHAR(7), warna_aksen VARCHAR(7), warna_netral VARCHAR(7),
  preset_font VARCHAR(30) NOT NULL DEFAULT 'default'  -- lihat §D2.2, terbatas preset resmi
);

CREATE TABLE site_content_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  halaman VARCHAR(30) NOT NULL,        -- 'beranda', 'profil-desa', dst
  tipe_blok VARCHAR(30) NOT NULL,      -- 'hero','statistik','berita','layanan_unggulan','peta','testimoni'
  urutan INT NOT NULL,
  konten JSONB NOT NULL,               -- struktur bebas sesuai tipe_blok, divalidasi Zod schema per tipe
  aktif BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  posisi VARCHAR(10) NOT NULL CHECK (posisi IN ('header','footer')),
  label VARCHAR(60) NOT NULL, href TEXT NOT NULL,
  urutan INT NOT NULL, parent_id UUID REFERENCES site_navigation(id)  -- dukung submenu
);

CREATE TABLE feature_flags (
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  fitur_kode VARCHAR(30) NOT NULL,     -- 'F1_SURAT','F2_USULAN','F5_PBB', dst
  aktif BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fitur_kode)
);

-- Nomor WA resmi terverifikasi pada site_settings
ALTER TABLE site_settings
  ADD COLUMN nomor_wa_resmi VARCHAR(20),
  ADD COLUMN wa_business_verified BOOLEAN NOT NULL DEFAULT false;
```

### D1.3 Aturan render
- Setiap komponen section (`<HeroBlock>`, `<StatistikBlock>`, dst) menerima **props dari `konten` JSONB**, tervalidasi skema Zod per tipe — bukan menerima teks langsung ditulis di JSX.
- Navigasi header/footer di-render dari query `site_navigation`, bukan array tetap di komponen `<Header>`.
- Modul yang `feature_flags.aktif = false` **tidak muncul** di navigasi maupun dashboard admin — dicek di layer server sebelum render, bukan disembunyikan pakai CSS.
- Warna & font hanya boleh diambil dari `tenant_theme_config`, diinjeksikan sebagai CSS variable di root layout (`--color-primer`, `--color-aksen`, dst) — komponen tidak pernah menulis hex/nama warna langsung.

---

## D2. Design Token System

### D2.1 Palet Warna (default preset — tenant boleh override primer/aksen dalam batas kontras aksesibilitas)

| Token | Hex | Peran |
|---|---|---|
| `--color-primer` | `#1F4D3D` (hijau tua sawah) | Header, tombol utama, identitas resmi |
| `--color-primer-dark` | `#12231C` | Mode gelap, footer |
| `--color-aksen` | `#C9A227` (emas padi) | Highlight, status positif, elemen tanda tangan/stempel |
| `--color-siaga` | `#A63D40` (merah bata pudar) | Status urgent/tolak, dipakai sangat terbatas |
| `--color-netral-100` | `#F6F3EA` (kertas) | Background terang |
| `--color-netral-900` | `#1C1C1A` | Teks utama |

**Kenapa bukan palet cream+terracotta generik**: warna diambil dari elemen fisik nyata dunia desa — hijau sawah, emas padi, merah bata — bukan palet AI-generik. Terracotta (`#D97757`-ish) sengaja dihindari.

### D2.2 Tipografi

| Peran | Font | Alasan |
|---|---|---|
| Display (H1/Hero) | **Fraunces** (slab-serif, kontras tinggi) | Berkarakter seperti huruf pada kop surat/prasasti resmi, bukan sans generik |
| Body | **Inter** atau **Plus Jakarta Sans** | Netral, keterbacaan tinggi di layar kecil |
| Data/Utility (NOP, kode surat, tabel) | **JetBrains Mono** | Membedakan data terstruktur (nomor objek pajak, nomor surat) dari teks naratif — penting di dashboard admin |

Preset font di `tenant_theme_config.preset_font` dibatasi 2-3 kombinasi resmi (bukan bebas pilih font apapun) supaya konsistensi visual antar-desa tetap terjaga.

### D2.3 Signature Element — "Stempel Digital"

Elemen unik yang mengikat identitas produk ini ke subjeknya: **badge melingkar bergaya stempel/cap resmi desa**, dipakai konsisten di:
- Halaman verifikasi surat (`/verifikasi/{uuid}`) — animasi ringan "cap menempel" saat halaman verifikasi berhasil.
- Badge status IDM di dashboard publik (mis. lingkaran skor dengan tepi bertekstur seperti stempel).
- Watermark tipis pola garis radial (meniru guilloche pada stempel resmi) di background hero, sangat halus (opacity ≤4%), bukan dekorasi mencolok.

Ini satu-satunya tempat "keberanian visual" dipakai — bagian lain tetap tenang dan disiplin.

### D2.4 Breakpoint (Mobile-First)

| Breakpoint | Lebar | Prioritas layout |
|---|---|---|
| Base (default, tanpa prefix) | 360px+ | 1 kolom, navigasi hamburger, hero full-viewport-height |
| `sm:` | 640px+ | Grid 2 kolom untuk kartu section |
| `md:` | 768px+ | Navigasi header horizontal muncul |
| `lg:` | 1024px+ | Grid 3-4 kolom, sidebar dashboard admin muncul permanen |
| `xl:` | 1280px+ | Max-width content container aktif |

---

## D3. Halaman 1 — Landing Page / Beranda

### D3.1 Struktur (top to bottom)
```
┌─────────────────────────────────────┐
│ HEADER (sticky)                       │
│ [Logo+Nama Desa]      [☰ mobile]      │  ← desktop: menu horizontal dari site_navigation
├─────────────────────────────────────┤
│                                         │
│         HERO — FULL VIEWPORT           │  ← 100dvh, TANPA CTA (sesuai brief)
│                                         │
│   [Headline dari content_blocks]        │
│   [Sub-headline]                          │
│   [Watermark stempel radial, opacity~4%]   │
│                                              │
│              ↓ scroll indicator                │
├─────────────────────────────────────┤
│ SECTION: Statistik Desa Real-Time      │  ← dari idm_status_desa & dashboard_agregat
│ (jumlah penduduk, status IDM, dst)      │     BUKAN angka statis di kode
├─────────────────────────────────────┤
│ SECTION: Layanan Unggulan               │  ← kartu per fitur AKTIF (feature_flags)
│ [Surat Online] [Usulan Kegiatan]          │     kartu tidak render jika modul nonaktif
│ [Info Kesehatan] [PBB Online]               │
├─────────────────────────────────────┤
│ SECTION: Berita & Pengumuman Terkini      │  ← dari tabel berita_desa (CMS ringan)
├─────────────────────────────────────┤
│ SECTION: Peta Sebaran & Profil Wilayah      │  ← embed peta dusun, dari data GIS objek desa
├─────────────────────────────────────┤
│ SECTION: Transparansi Anggaran (ringkas)      │ ← grafik ringkas realisasi APBDes
├─────────────────────────────────────┤
│ FOOTER                                          │
│ [Kontak] [Jam Layanan] [Menu footer dari nav]     │
│ [Link Verifikasi Dokumen] [Media Sosial]            │
└─────────────────────────────────────┘
```

### D3.2 Catatan implementasi Hero (tanpa CTA)
- Hero murni sebagai *tesis visual*: menegaskan identitas desa (nama, tagline dari `site_content_blocks` tipe `hero`), tanpa tombol aksi — sesuai permintaan eksplisit "No CTA". Ajakan bertindak dipindah ke section "Layanan Unggulan" di bawahnya, bukan dipaksakan di hero.
- Elemen di hero: nama resmi desa + kecamatan/kabupaten (dari `site_settings`), satu kalimat identitas singkat (dari `content_blocks`), watermark stempel radial halus, dan indikator scroll (bukan tombol).
- Tinggi hero: `min-h-[100dvh]` (bukan `100vh`, agar akurat di mobile browser dengan address bar dinamis).

### D3.3 Mobile-first behaviour
- Header mobile: logo + hamburger, menu full-screen overlay saat dibuka (bukan dropdown sempit).
- Section "Layanan Unggulan": mobile 1 kolom stack vertikal, `sm:` 2 kolom, `lg:` 4 kolom.
- Statistik desa: mobile carousel swipe horizontal, desktop grid statis.

---

## D4. Halaman 2 — Public Page (template generik)

Dipakai untuk semua halaman statis/dinamis publik: Profil Desa, Struktur Organisasi, Berita detail, halaman Verifikasi Dokumen, halaman Status IDM publik, dsb. **Satu template, konten dari `site_content_blocks` dengan `halaman` berbeda** — bukan halaman terpisah yang dihardcode per topik.

```
┌─────────────────────────────────────┐
│ HEADER (sama seperti beranda)          │
├─────────────────────────────────────┤
│ Breadcrumb (dinamis dari route)          │
├─────────────────────────────────────┤
│ Judul Halaman (dari site_content_blocks)   │
│ Konten Blok 1..N (render sesuai tipe_blok)    │
│   - teks kaya (rich text dari CMS)               │
│   - tabel data (mis. struktur organisasi)          │
│   - kartu berita terkait                              │
├─────────────────────────────────────┤
│ FOOTER                                                  │
└─────────────────────────────────────┘
```

**Kasus khusus — Halaman Verifikasi Dokumen (`/verifikasi/[uuid]`):**
- Tidak menggunakan `site_content_blocks` (ini transaksional, bukan CMS), melainkan query langsung ke `surat_dokumen` by `qr_uuid`.
- Menampilkan badge "Stempel Digital" (signature element §D2.3) dengan status: **Dokumen Sah** (hijau) atau **Tidak Ditemukan/Dicabut** (merah, `--color-siaga`).
- Menampilkan metadata non-sensitif saja: jenis surat, nomor surat, tanggal terbit, penandatangan — **tidak menampilkan isi lengkap surat** (privasi pemohon).
- Footer halaman ini dan semua halaman publik menampilkan `nomor_wa_resmi` beserta badge "Nomor WA Resmi Terverifikasi" (jika `wa_business_verified = true`), dengan peringatan singkat agar warga hanya percaya nomor tersebut untuk mencegah penipuan mengatasnamakan kantor desa.

---

## D5. Halaman 3 — Login Page

### D5.1 Struktur (mobile-first, single column selalu — login tidak butuh layout lebar)
```
┌───────────────────────┐
│                          │
│      [Logo Desa]           │  ← dari tenant_theme_config
│   Kantor Desa Virtual        │
│   {nama_desa dari settings}     │
│                                    │
│  ┌───────────────────────┐        │
│  │ [Input: NIK / Email]      │        │
│  │ [Input: Kata Sandi]         │        │
│  │ [ ] Ingat saya                 │        │
│  │ [Tombol: Masuk]                   │        │
│  │ Lupa kata sandi? →                   │        │
│  └───────────────────────┘        │
│                                    │
│  ── atau ──                          │
│  [Masuk dengan OTP WhatsApp]           │  ← selaras dengan verifikasi OTP di F2 (voting)
│                                    │
│  Belum punya akun? Daftar sebagai warga →│
└───────────────────────┘
```

### D5.2 Aturan desain
- Field & label **tidak hardcode teks Indonesia langsung di komponen** — diambil dari `i18n_strings` (mis. `auth.login.title`, `auth.login.nik_label`) supaya siap multi-bahasa (bahasa daerah/Inggris untuk desa wisata) tanpa ubah kode.
- Dua jalur login sesuai peran: **NIK+password** (warga & admin) dan **OTP WhatsApp** (warga, konsisten dengan mekanisme OTP yang sudah dipakai di alur voting F2) — bukan implementasi otentikasi terpisah.
- Redirect setelah login **berbasis peran** (bukan hardcode satu tujuan): warga → `/beranda-warga`, admin/perangkat desa → `/admin/dashboard`, Kades → `/admin/dashboard?highlight=tte-pending`.
- Pesan error login mengikuti prinsip "errors don't apologize, tidak vague" — mis. "NIK atau kata sandi tidak cocok. Coba lagi atau gunakan OTP WhatsApp." — bukan "Terjadi kesalahan."

---

## D6. Halaman 4 — Dashboard Admin: Pengaturan & Konfigurasi

Ini halaman yang **paling langsung menegakkan prinsip zero-hardcode** — di sinilah perangkat desa mengubah semua hal yang di halaman lain diambil dari config.

### D6.1 Struktur (mobile-first: sidebar jadi bottom-sheet/drawer di mobile)
```
Mobile (360-767px):                    Desktop (1024px+):
┌─────────────────┐                  ┌───┬─────────────────────┐
│ Header + ☰ menu    │                  │Sid│ Header (breadcrumb)    │
├─────────────────┤                  │ebr├─────────────────────┤
│                     │                  │ar │                          │
│  Konten Pengaturan     │                  │   │   Konten Pengaturan       │
│  (1 kolom, per-seksi)     │                  │   │   (grid 2 kolom form)      │
│                              │                  │   │                              │
│  [Drawer navigasi seksi        │                  │   │                              │
│   muncul saat ☰ ditekan]           │                  │   │                              │
└─────────────────┘                  └───┴─────────────────────┘
```

### D6.2 Seksi Pengaturan (tiap seksi = 1 route, bukan tab JS tersembunyi — tetap multi-page)

| Route | Konten |
|---|---|
| `/admin/pengaturan/identitas` | Nama desa, alamat kantor, kontak, jam layanan → `site_settings` |
| `/admin/pengaturan/tema` | Logo, favicon, warna primer/aksen (color picker dengan validasi kontras WCAG), preset font → `tenant_theme_config` |
| `/admin/pengaturan/navigasi` | CRUD menu header/footer, drag-to-reorder → `site_navigation` |
| `/admin/pengaturan/konten-beranda` | CRUD section beranda (tambah/hapus/urutkan/edit tiap blok) → `site_content_blocks` |
| `/admin/pengaturan/modul` | Toggle aktif/nonaktif tiap fitur (F1-F10) → `feature_flags`, dengan peringatan dampak (mis. matikan F2 akan menyembunyikan menu Usulan Kegiatan) |
| `/admin/pengaturan/pengguna` | Kelola akun admin/perangkat desa & peran (RBAC) |
| `/admin/pengaturan/jenis-surat` | CRUD `surat_jenis` — admin bisa tambah jenis surat baru tanpa deploy kode baru |
| `/admin/pengaturan/idm` | Lihat/override manual `idm_scoring_thresholds` jika ada revisi kuesioner tahun berjalan (lihat catatan implementasi di Bagian E terkait `PETA_DERIVATION_RULES_IDM.md`). Setiap indikator menampilkan label `sumber_data` (operasional/periodik_manual/eksternal); indikator non-operasional menampilkan tanggal update terakhir, bukan status "real-time" |
| `/admin/pengaturan/kepatuhan` | Generate & unduh file ekspor SISKEUDES/SIPADES per periode (`ekspor_kepatuhan`), wajib verifikasi admin sebelum status `diunduh` — lihat W7 dan rasional tambahan di Bagian E |

### D6.3 Pola form pengaturan (konsisten di semua seksi)
- Setiap form pengaturan: perubahan disimpan sebagai draft dulu jika berdampak publik luas (tema, navigasi) — tombol **"Terapkan Perubahan"** eksplisit, bukan auto-save diam-diam untuk hal yang tampil ke warga.
- Preview live di panel samping (desktop) / tab terpisah (mobile) sebelum "Terapkan" — supaya admin desa yang awam teknologi tidak salah publish.
- Validasi kontras warna otomatis saat pilih `warna_primer`/`warna_aksen` — tolak kombinasi yang gagal WCAG AA, dengan pesan jelas ("Kontras teks putih di atas warna ini terlalu rendah, coba warna lebih gelap").

### D6.4 Aksesibilitas & kualitas dasar (berlaku semua halaman)
- Fokus keyboard terlihat jelas (`:focus-visible` custom ring, bukan dihilangkan).
- `prefers-reduced-motion` dihormati — animasi stempel/watermark otomatis nonaktif.
- Kontras teks minimum WCAG AA di semua kombinasi token warna default.
- Semua form memiliki label eksplisit (bukan placeholder-as-label).

---

## D7. Halaman Modul Operasional F7–F10 (kesetaraan OpenSID)

| Route | Fungsi |
|---|---|
| `/admin/pertanahan` | Daftar `bidang_tanah`, filter jenis alas hak & status |
| `/admin/pertanahan/[id]` | Detail bidang tanah + riwayat `kepemilikan_bidang_tanah` (read-only, append-only) + form catat pengalihan |
| `/admin/anggaran` | CRUD `kegiatan_desa` per tahun anggaran (pilih `sub_bidang`+`rekening_anggaran`) dan input `apbdes_realisasi` per kegiatan — sumber data untuk kartu "Transparansi Anggaran" di beranda dan ekspor SISKEUDES (§D6.2) |
| `/admin/aset` | Daftar `aset_desa`, filter kategori & kondisi |
| `/admin/aset/verifikasi-draft` | Antrean draft aset dari `apbdes.realisasi.dicatat` (belanja modal) yang menunggu verifikasi admin |
| `/admin/pemetaan` | Kelola `wilayah_batas` (gambar/edit poligon dusun/RT/RW) |
| `/admin/pemetaan/laporan` | Antrean `titik_infrastruktur` status `dilaporkan` menunggu verifikasi |
| `/admin/agenda` | CRUD `agenda_kegiatan` jenis `umum`; entri `musdes`/`posyandu` tampil read-only (dibuat otomatis) |
| `/peta-desa` | **Publik** — peta dengan layer toggle: batas wilayah, tanah kas desa, titik infrastruktur terverifikasi, lokasi posyandu. Tidak pernah menampilkan `bidang_tanah` milik warga individu |
| `/lapor-infrastruktur` | **Publik** — form lapor warga (foto + lokasi + deskripsi), setara opsi 3 di menu WA (W6/W11) |
| `/kalender-desa` | **Publik** — agenda kegiatan, filter jenis, tombol langganan reminder WA (`agenda_subscriber`) |
| `/transparansi/aset-desa` | **Publik** — agregat nilai aset per kategori, bukan daftar rinci per unit |
| `/transparansi/tanah-kas-desa` | **Publik** — agregat luas & jumlah bidang tanah kas desa |

### D7.1 Prinsip privasi peta & transparansi
- Layer peta publik hanya menampilkan data yang statusnya sudah terverifikasi admin — tidak ada data mentah warga yang tampil langsung.
- Halaman transparansi aset/tanah selalu agregat, konsisten dengan prinsip privasi F4 (data kesehatan) — detail per unit hanya untuk admin login.

---

## D8. Struktur Routing (Next.js App Router — referensi)

```
app/
├── (public)/
│   ├── page.tsx                    ← Landing/Beranda (§D3)
│   ├── [slug]/page.tsx             ← Public Page generik (§D4), slug dari site_content_blocks
│   ├── verifikasi/[uuid]/page.tsx  ← Verifikasi dokumen (§D4, kasus khusus)
│   ├── peta-desa/page.tsx          ← §D7, layer wilayah_batas + titik_infrastruktur + tanah kas desa
│   ├── lapor-infrastruktur/page.tsx ← §D7
│   ├── kalender-desa/page.tsx      ← §D7
│   ├── transparansi/
│   │   ├── aset-desa/page.tsx      ← §D7
│   │   └── tanah-kas-desa/page.tsx ← §D7
│   └── layout.tsx                  ← Header+Footer dari site_navigation
├── login/page.tsx                  ← §D5, layout khusus tanpa header/footer publik
├── admin/
│   ├── layout.tsx                  ← Sidebar admin, dicek feature_flags & RBAC
│   ├── dashboard/page.tsx
│   ├── pertanahan/
│   │   ├── page.tsx                ← §D7
│   │   └── [id]/page.tsx           ← §D7
│   ├── aset/
│   │   ├── page.tsx                ← §D7
│   │   └── verifikasi-draft/page.tsx ← §D7
│   ├── pemetaan/
│   │   ├── page.tsx                ← §D7
│   │   └── laporan/page.tsx        ← §D7
│   ├── agenda/page.tsx             ← §D7
│   └── pengaturan/
│       ├── identitas/page.tsx
│       ├── tema/page.tsx
│       ├── navigasi/page.tsx
│       ├── konten-beranda/page.tsx
│       ├── modul/page.tsx
│       ├── pengguna/page.tsx
│       ├── jenis-surat/page.tsx
│       ├── idm/page.tsx
│       └── kepatuhan/page.tsx      ← §D6.2, ekspor SISKEUDES/SIPADES
```

---

# BAGIAN E — STATUS DOKUMEN, DEPENDENSI & CATATAN TERBUKA

Rujukan tunggal status dokumen pendukung dan checklist blocker yang harus dipantau sebelum implementasi dianggap tuntas.

## E1. Dokumen yang masih belum tersedia (blocker aktif)

| Dokumen | Dibutuhkan oleh | Dampak jika belum ada |
|---|---|---|
| `PETA_DERIVATION_RULES_IDM.md` | F3 (§A2), W3 (§B), `/admin/pengaturan/idm` (§D6.2) | **Blocker implementasi F3** — pemetaan event → formula skor per indikator belum ada. Tabel (`idm_skor_cache`, `idm_scoring_thresholds`) sudah siap, tapi logika kalkulasi belum bisa ditulis tanpa dokumen ini. |
| `idm_indicators.csv` | F3, seed tabel `idm_indicators` (§C7) | Jumlah pasti indikator ("127") **wajib diverifikasi manual**, bukan diasumsikan. Akan digenerate dari `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN` begitu file itu tersedia. |
| `ARSITEKTUR_SISTEM_TERINTEGRASI.md` | Beberapa rasional non-DDL lintas fitur (lihat §E2) | Rasional teknis ada, tapi belum didokumentasikan formal — tim tetap bisa implementasi dengan asumsi yang tertulis di masing-masing bagian terkait di dokumen ini, namun perlu direview ulang saat dokumen tersebut tersedia. |
| `KUESIONER_ID_2026_Lock.xlsx` (sheet `RUMUSAN`) | Sumber generate `idm_indicators.csv` | Prasyarat sebelum `idm_indicators.csv` bisa dibuat. |

## E2. Rasional spesifik yang menunggu `ARSITEKTUR_SISTEM_TERINTEGRASI.md`

Poin-poin berikut sudah punya keputusan desain sementara di dokumen ini (cukup untuk mulai implementasi), tapi rasional lengkapnya akan diformalkan saat dokumen arsitektur tersedia:

1. **Tiering WhatsApp** (F6, W6) — pembagian `info_instan` vs `transaksi`, jam proses admin vs jam terima 24 jam.
2. **Sizing worker bertahap** (A4, W3) — kapan 1 queue MVP harus dipecah jadi 6 queue per dimensi.
3. **Klasifikasi `sumber_data` indikator IDM** (§C7) — kriteria detail operasional vs periodik_manual vs eksternal.
4. **Alur ekspor kepatuhan** (W7, §C8, §D6.2) — detail format CSV/XML resmi Kemendagri per jenis ekspor.
5. **RBAC data kesehatan lintas-dusun** (W4, §C8) — sudah ada `posyandu_akses_log` dan pembatasan peran dasar, tapi kebijakan eskalasi lintas-dusun perlu diformalkan.
6. **Strategi offline-first kader Posyandu** (W4) — **belum terjawab di dokumen manapun dalam paket ini.** Alur W4 saat ini berasumsi backend selalu online; ini tetap jadi blocker arsitektur (bukan blocker skema) untuk kader yang bekerja tanpa sinyal di lapangan.

## E3. Keputusan Desain yang Sudah Final

- **Modul PBB (F5) dan APBDes** bersifat mandiri — seluruh `CREATE TABLE` tersedia lengkap di §C5 dan §C6, tidak bergantung pada berkas eksternal apa pun. Logika worker turunan (event → efek PADes/skor IDM) ditulis sebagai kode aplikasi terpisah, dengan struktur yang diturunkan langsung dari kolom `jenis_belanja`, event `pbb.tagihan.dibayar`, dan tabel `pades_pendapatan`/`idm_skor_cache`.
- **Penamaan tabel wilayah**: `wilayah_batas` adalah satu-satunya tabel wilayah (§C9) — tidak ada tabel wilayah kedua yang tumpang tindih.
- **Route `/admin/anggaran`** (§D7) menjadi halaman input resmi untuk `kegiatan_desa`/`apbdes_realisasi` (§C6), menjadi sumber data kartu "Transparansi Anggaran" di beranda dan ekspor SISKEUDES.

## E4. Checklist sebelum mulai coding (Session Starter ringkas)

- [ ] Verifikasi jumlah indikator IDM sebenarnya terhadap `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`, jangan asumsikan "127".
- [ ] Jalankan migrasi sesuai urutan dependensi §C11 (bukan urutan halaman dokumen).
- [ ] Pastikan skema pendukung frontend (§D1.2) masuk migrasi bersama skema domain.
- [ ] Tunda implementasi F3 penuh sampai `PETA_DERIVATION_RULES_IDM.md` dan `idm_indicators.csv` tersedia — tabel & worker skeleton bisa disiapkan lebih dulu, tapi formula skor per indikator menunggu dokumen tersebut.
- [ ] Tandai strategi offline-first Posyandu (E2 poin 6) sebagai item riset terbuka, bukan asumsi diam-diam bahwa backend selalu online.
