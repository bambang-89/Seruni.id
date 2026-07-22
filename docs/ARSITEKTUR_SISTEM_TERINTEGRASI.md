# ARSITEKTUR SISTEM TERINTEGRASI — Kantor Desa Virtual (DESAKU)
Dokumen sintesis · Menyempurnakan 4 dokumen sumber (`PRD`, `SKEMA_DATABASE_ERD`, `WORKFLOW`, `DESAIN_FRONTEND`) berdasarkan analisis dan diskusi lanjutan
Status: Blueprint tambahan — melengkapi, bukan menggantikan dokumen sumber

---

## 0. Kedudukan Dokumen Ini

Dokumen sumber (`sidesa-id.zip`) sudah solid pada level fondasi: PRD mendefinisikan 6 fitur andalan, ERD mendefinisikan skema data, WORKFLOW mendefinisikan state machine, dan DESAIN_FRONTEND mendefinisikan lapisan presentasi zero-hardcode. Rantai hubungannya:

```
PRD (kenapa) → SKEMA_DATABASE_ERD (apa datanya) → WORKFLOW (bagaimana alurnya) → DESAIN_FRONTEND (bagaimana tampil)
                              │
                              └── disatukan oleh Event Propagation Layer (domain_events → worker → idm_skor_cache)
```

Dokumen ini **tidak mengubah** rantai itu. Dokumen ini menutup lima celah yang muncul dari analisis dan diskusi lanjutan: (1) kanal WhatsApp yang masih diperlakukan sebagai satu alur monolitik, (2) sizing worker yang berpotensi over-engineered untuk skala satu desa, (3) klaim "127 indikator real-time" yang belum diverifikasi terhadap kenyataan bahwa tidak semua indikator IDM bisa didekati dari data operasional, (4) ketiadaan jalur ekspor ke sistem resmi Kemendagri, (5) tata kelola data sensitif (kesehatan individu) yang belum eksplisit soal retensi dan akses.

Referensi dokumen sumber yang **masih belum tersedia** dan dibutuhkan sebelum implementasi F3 dan F5 bisa dianggap final: `PETA_DERIVATION_RULES_IDM.md`, `idm_indicators.csv`, `pbb.schema.ts`, `pbb-derivation.worker.ts`.

---

## 1. Kanal WhatsApp sebagai Layanan Penuh (Model PANDAWA/CHIKA)

### 1.1 Prinsip
WhatsApp bukan kanal notifikasi tambahan bagi F1/F6 — ia setara dengan portal web sebagai kanal transaksi utama, mengikuti preseden nasional BPJS Kesehatan (PANDAWA + CHIKA, terintegrasi sejak April 2024 dalam satu nomor resmi). Preseden itu mengajarkan tiga hal yang wajib direplikasi, bukan hanya "pakai WA":

1. **Tiering info-instan vs transaksi-terverifikasi** — cek status, cek jadwal, cek info desa dijawab instan tanpa antre proses admin; pengajuan surat/perubahan data diproses lewat state machine dengan jam kerja jelas.
2. **Jam terima 24 jam, jam proses jam kerja** — pesan bisa masuk kapan saja, tapi ekspektasi warga soal kapan diproses harus eksplisit di setiap respons bot, bukan diam-diam.
3. **Satu nomor resmi terverifikasi (centang hijau WhatsApp Business)** — dipublikasikan di semua kanal resmi (web, papan pengumuman fisik, surat fisik) untuk mencegah penipuan mengatasnamakan kantor desa.

### 1.2 Perluasan skema — `wa_layanan_tier`
Menambah satu kolom klasifikasi ke `wa_chat_session` yang sudah ada di `SKEMA_DATABASE_ERD.md §3`, bukan tabel baru:

```sql
ALTER TABLE wa_chat_session
  ADD COLUMN tier VARCHAR(15) NOT NULL DEFAULT 'transaksi'
    CHECK (tier IN ('info_instan', 'transaksi'));
```

- `info_instan`: dijawab langsung dari `idm_status_desa`, `dashboard_agregat`, `site_content_blocks`, atau status surat by NIK (read-only) — tidak membuka `surat_pengajuan` baru, tidak butuh OTP, tidak masuk antrean admin.
- `transaksi`: mengikuti state machine penuh W1/W2/W6 di `WORKFLOW_KANTOR_DESA_VIRTUAL.md`, wajib OTP untuk aksi yang mengubah data (submit surat, vote usulan).

### 1.3 Menu bot — pemisahan eksplisit
```
Bot: "Pilih layanan:
 1) Cek info & status (instan)   → tier: info_instan
 2) Ajukan surat / usulan          → tier: transaksi (lanjut ke W6 seperti sudah didefinisikan)"
```
Respons `info_instan` menyertakan disclaimer jam proses jika warga mencoba mengajukan transaksi di luar jam kerja: *"Pesan Anda sudah tersimpan. Verifikasi akan diproses admin pada jam kerja (Senin–Jumat, 08.00–15.00 WITA)."* — pola kalimat ini konsisten dengan `errors don't apologize, tidak vague` yang sudah jadi aturan desain login (`DESAIN_FRONTEND §5.2`).

### 1.4 Anti-penyalahgunaan nomor resmi
Tambahan field di `site_settings` (sudah ada di `DESAIN_FRONTEND_KANTOR_DESA_VIRTUAL.md §1.1`):
```sql
ALTER TABLE site_settings
  ADD COLUMN nomor_wa_resmi VARCHAR(20),
  ADD COLUMN wa_business_verified BOOLEAN NOT NULL DEFAULT false;
```
Nomor ini ditampilkan di footer setiap halaman publik dan di halaman verifikasi surat (`/verifikasi/{uuid}`), dengan peringatan standar: warga hanya boleh percaya nomor bercentang hijau tersebut.

### 1.5 Fallback kanal
Karena warga desa kemungkinan besar tidak akan memasang aplikasi kedua, fallback bukan "app mobile terpisah" tapi dua jalur yang sudah eksis di arsitektur: portal web (kanal setara sesuai prinsip §3.5 PRD) dan datang langsung ke kantor desa. Tidak perlu infrastruktur baru — cukup dipastikan kedua jalur ini didokumentasikan ke warga sebagai alternatif resmi bila WA bermasalah.

---

## 2. Sizing Event Propagation Layer — Bertahap, Bukan 6 Queue Sejak Awal

### 2.1 Masalah
`PRD_KANTOR_DESA_VIRTUAL.md §4` mensyaratkan "queue terpisah per dimensi IDM (6 queue) agar rekalkulasi tidak saling memblokir". Untuk satu tenant berskala desa (~7.800 jiwa, volume event harian yang realistis rendah), 6 worker proses hidup permanen adalah biaya operasional yang tidak sepadan dengan manfaat isolasinya di tahap awal.

### 2.2 Rekomendasi — model bertahap
**Fase MVP (1 tenant / sedikit tenant):**
```
1 BullMQ worker, 1 queue `idm-events`
  → job payload menyertakan `dimensi_no` (1-6)
  → job priority: dimensi dengan threshold pelanggaran → priority tinggi
  → concurrency: 3-5 job paralel (cukup untuk volume 1 desa)
```
**Fase Scale (multi-tenant, volume tinggi):**
```
Split queue per dimensi HANYA jika worker tunggal mulai menunjukkan lag terukur
  (metrik: waktu_dari_event_ke_processed_at > threshold, mis. >30 detik)
```
Prinsip pemisahan fakta mentah/turunan (`SKEMA_DATABASE_ERD.md §7`) dan sifat idempotent worker (`WORKFLOW W3`) tetap dipertahankan penuh — yang berubah hanya jumlah proses fisik, bukan model data atau kontrak event.

---

## 3. Klasifikasi Indikator IDM — Hybrid, Bukan 127 Real-Time Seragam

### 3.1 Masalah
Tidak semua dari 127 sub-indikator IDM Kemendes bisa didekati dari fakta operasional harian sistem ini. Sebagian butuh data yang sifatnya periodik/eksternal (survei lapangan, data BPS, sensus). Mengklaim semuanya "real-time" tanpa verifikasi terhadap `idm_indicators.csv` berisiko menghasilkan skor yang tampak presisi tapi sebagian isinya statis/usang berkedok otomatis.

### 3.2 Rekomendasi — tambahkan kolom klasifikasi ke `idm_indicators`
```sql
ALTER TABLE idm_indicators
  ADD COLUMN sumber_data VARCHAR(20) NOT NULL DEFAULT 'operasional'
    CHECK (sumber_data IN ('operasional', 'periodik_manual', 'eksternal'));
```
- `operasional`: dihitung otomatis dari `domain_events` sesuai `WORKFLOW W3` — ini yang benar-benar real-time.
- `periodik_manual`: diinput admin secara berkala (mis. tahunan) lewat `/admin/pengaturan/idm` (`DESAIN_FRONTEND §6.2`) — sistem menampilkan "Terakhir diperbarui: [tanggal]", bukan berpura-pura real-time.
- `eksternal`: ditarik dari sumber luar (BPS, Kemendes SDGs dashboard) lewat impor berkala, bukan event internal.

Dashboard publik dan admin **wajib menampilkan label sumber data per indikator**, bukan hanya angka — ini konsisten dengan prinsip auditability yang sudah ada di `PRD §4`.

### 3.3 Prasyarat implementasi
Klasifikasi ini tidak bisa dituntaskan tanpa `idm_indicators.csv` dan `PETA_DERIVATION_RULES_IDM.md` yang direferensikan tapi belum tersedia. Rekomendasi: audit ke-127 indikator terhadap tiga kategori di atas sebagai langkah pertama sebelum coding worker derivation dimulai.

---

## 4. Jalur Interoperabilitas Resmi (Siskeudes / SIPADES)

### 4.1 Masalah
`PRD §1.3` sudah eksplisit menyatakan sistem ini bukan pengganti SISKEUDES/SIPADES, hanya pelengkap — tapi tidak ada mekanisme ekspor konkret di ERD/WORKFLOW manapun. Tanpa ini, desa tetap input dobel ke sistem resmi, yaitu persis masalah yang katanya mau dihilangkan produk ini (prinsip "satu input, banyak dampak" jadi tidak berlaku untuk kewajiban pelaporan resmi).

### 4.2 Rekomendasi — modul ekspor sebagai turunan, bukan integrasi langsung
```sql
CREATE TABLE ekspor_kepatuhan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_ekspor VARCHAR(30) NOT NULL CHECK (jenis_ekspor IN ('siskeudes','sipades')),
  periode VARCHAR(20) NOT NULL,          -- mis. '2026-Q3'
  file_path TEXT NOT NULL,               -- format resmi (CSV/XML sesuai spesifikasi Kemendagri)
  status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','diverifikasi_admin','diunduh')),
  dihasilkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
Data sumber ekspor SISKEUDES ditarik dari `apbdes_realisasi`/`pades_pendapatan` (sudah ada sebagai fakta turunan di `SKEMA_DATABASE_ERD.md §7`); ekspor SIPADES dari `pbb_objek_pajak`/`objek_pajak_lokasi`. Prinsipnya tetap satu arah: sistem ini menghasilkan file siap-impor untuk diunggah manual ke portal resmi Kemendagri — bukan integrasi API langsung, karena SISKEUDES/SIPADES tidak menyediakan API publik yang bisa diandalkan untuk ini.

---

## 5. Tata Kelola Data Kesehatan Individu (Perluasan F4/W4)

### 5.1 Masalah
`WORKFLOW W4` sudah benar dari sisi prinsip (data individu balita tidak pernah publik), tapi belum menjawab: siapa saja yang boleh melihat data individu selain kader & admin, dan berapa lama retensinya. Untuk data kesehatan anak, ini area yang biasanya dituntut lebih eksplisit saat audit kepatuhan UU PDP No.27/2022.

### 5.2 Rekomendasi — RBAC eksplisit + kebijakan retensi
```sql
CREATE TABLE posyandu_akses_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kunjungan_id UUID NOT NULL REFERENCES posyandu_kunjungan(id),
  diakses_oleh UUID NOT NULL,     -- FK ke akun admin/kader
  peran_pengakses VARCHAR(20) NOT NULL CHECK (peran_pengakses IN ('kader','admin_kesehatan','kades')),
  diakses_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
- Akses data individu balita dibatasi ke peran `kader` (dusun terkait saja, bukan lintas dusun) dan `admin_kesehatan` — Kades hanya melihat agregat dashboard, kecuali eskalasi kasus gizi buruk yang memang sudah memicu `usulan_kegiatan_draft_otomatis` (W4).
- Setiap akses ke data individu tercatat di `posyandu_akses_log` — memenuhi prinsip auditability yang sudah jadi kebutuhan non-fungsional di `PRD §4` untuk transaksi kritikal, diperluas ke data sensitif.
- Kebijakan retensi: disarankan mengikuti masa aktif kepesertaan Posyandu (balita hingga usia 5 tahun) + periode arsip sesuai pedoman kearsipan desa yang berlaku, dikonfirmasi ke regulasi teknis kesehatan yang relevan sebelum di-hardcode sebagai angka pasti.

---

## 6. Peta Kesiapan Implementasi

| Area | Status di dokumen sumber | Tambahan dari dokumen ini | Prasyarat sebelum coding |
|---|---|---|---|
| Kanal WA | Alur transaksi lengkap (W6) | Tiering info/transaksi, jam proses, nomor terverifikasi | — siap |
| Event Propagation | Model 6 queue sejak awal | Model bertahap: 1 queue → split saat perlu | — siap |
| Skoring IDM | Klaim 127 indikator real-time | Klasifikasi 3 sumber data per indikator | `idm_indicators.csv`, `PETA_DERIVATION_RULES_IDM.md` |
| PBB | ERD lengkap, DDL final di `pbb.schema.ts` | — (tidak diaudit, file belum tersedia) | `pbb.schema.ts`, `pbb-derivation.worker.ts` |
| Kepatuhan pelaporan | Dinyatakan non-tujuan tapi tanpa jalur | Modul `ekspor_kepatuhan` | Format resmi SISKEUDES/SIPADES terbaru |
| Data kesehatan | Prinsip privasi ada, RBAC belum rinci | RBAC + log akses + kebijakan retensi | Konfirmasi regulasi retensi data kesehatan anak |

---

## 7. Referensi

- `PRD_KANTOR_DESA_VIRTUAL.md` — kebutuhan produk & 6 fitur andalan
- `SKEMA_DATABASE_ERD.md` — skema data domain lengkap
- `WORKFLOW_KANTOR_DESA_VIRTUAL.md` — alur proses & state machine
- `DESAIN_FRONTEND_KANTOR_DESA_VIRTUAL.md` — arsitektur zero-hardcode & halaman
- Dokumen ini (`ARSITEKTUR_SISTEM_TERINTEGRASI.md`) — sintesis analisis, melengkapi lima area di atas
- Masih dibutuhkan: `PETA_DERIVATION_RULES_IDM.md`, `idm_indicators.csv`, `pbb.schema.ts`, `pbb-derivation.worker.ts`
