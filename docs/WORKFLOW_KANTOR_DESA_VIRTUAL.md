# WORKFLOW — Kantor Desa Virtual (DESAKU)
Referensi alur proses & state machine untuk implementasi Claude Code

---

## W1. Alur Surat Online (TTE/QR)

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

## W2. Alur Usulan Kegiatan → RKPDes → Voting

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

## W3. Alur Mesin Skoring IDM (Event-Driven)

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
Jalankan derivation rule terkait (lihat PETA_DERIVATION_RULES_IDM.md)
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

## W4. Alur Data Kesehatan (Posyandu)

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

**Aturan kritikal (RBAC & audit — tambahan sintesis):**
- Setiap akses ke data individu balita (bukan agregat) dicatat di `posyandu_akses_log` — siapa, peran apa, kapan.
- Akses data individu dibatasi ke peran `kader` (dusun terkait saja, bukan lintas dusun) dan `admin_kesehatan`. Kades hanya melihat agregat dashboard, kecuali eskalasi kasus gizi buruk yang sudah masuk `usulan_kegiatan_draft_otomatis`.

---

## W5. Alur PBB — Pendaftaran Objek hingga Pembayaran

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

## W6. Alur WhatsApp Chatbot untuk Surat

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
Bot: "Pilih layanan: 1) Cek info & status (instan)  2) Ajukan surat/usulan"
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

## W8. Alur Ekspor Kepatuhan (SISKEUDES/SIPADES) — tambahan sintesis

```
[Admin] Pilih periode & jenis ekspor (siskeudes/sipades)
        │
        ▼
[Sistem] Tarik data dari fakta turunan terkait
        ├── siskeudes ← apbdes_realisasi, pades_pendapatan
        └── sipades   ← pbb_objek_pajak, objek_pajak_lokasi
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
- Ekspor tidak boleh dijalankan otomatis tanpa verifikasi admin (`status: draft` wajib direview sebelum `diunduh`) — konsisten dengan prinsip tidak ada aksi kritikal tanpa persetujuan manusia (lihat W3).

---

## W7. Ringkasan Peta Event Lintas-Modul

| Event | Diterbitkan oleh | Konsumen (efek turunan) |
|---|---|---|
| `penduduk.status.berubah` | Core Registry | Semua rasio IDM berbasis populasi, eligibilitas surat, daftar pemilih voting |
| `posyandu.kunjungan.dicatat` | Modul Kesehatan | Skor 7.b, dashboard kesehatan, draft usulan gizi |
| `surat.diterbitkan` | Modul Surat | Skor 45.b, arsip, notifikasi WA |
| `usulan.vote.bertambah` | Modul Voting | Ranking RKPDes |
| `musdes.usulan.ditetapkan` | Modul Voting/Musdes | Skor 46, draft APBDes |
| `pbb.tagihan.dibayar` | Modul PBB | PADes, skor 47.a, skor 22 (jika usaha) |
| `pbb.objek_pajak.didaftarkan` | Modul PBB | Total NJOP, draft usulan infrastruktur |
| `apbdes.realisasi.dicatat` | Modul Keuangan | Skor Dimensi Tata Kelola Keuangan |
| `wa.layanan.selesai` | WA Chatbot | Skor 45.c/d (kanal pelayanan) |
