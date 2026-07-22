# Sistem PBB Desa

Dokumentasi sistem **PBB (Pajak Bumi & Bangunan) Desa** Seruni - Sistem Repository Unifikasi Informasi — merujuk project **PeTax** (D:\PeTax): informasi Objek Pajak & Wajib Pajak, pemetaan berbasis lokasi dalam zona tertentu, pembayaran via QRCode, dan update status pembayaran. Terintegrasi ke Sistem Penduduk, Keuangan, IDM, Profile Desa, dan Peta (F9).

---

## 1. Ringkasan Sistem PBB Desa (On Point)

- **Peran:** `objek_pajak` + `wajib_pajak` + `pbb_tagihan` = _Single Source of Truth_ data PBB. Tagihan menempel ke objek (bukan orang), histori kepemilikan **append-only** (`tanggal_selesai`, tidak pernah di-overwrite).
- **Objek & Wajib Pajak:** `wajib_pajak` terhubung ke `penduduk` (Core Registry) bila warga desa; `is_luar_desa=true` untuk non-warga. `kepemilikan_objek` mencatat persentase (bisa >1 pemilik).
- **Pemetaan Zona:** `objek_pajak_lokasi` (lat/long, luas, kelas NJOP) dipetakan ke **zona** (`zona_pbb` lookup: Zona A/B/C/per-dusun) dan ke `wilayah_batas` (dusun/RT/RW) untuk agregat & tampilan peta publik (F9).
- **Pembayaran QRCode:** Tiap `pbb_tagihan` generate token → halaman `/pbb/bayar/{token}` ber-QR (warga scan di web/WA). Pembayaran dicatat di `pbb_pembayaran` → `status_bayar` di-update (`belum_bayar`→`sebagian`→`lunas`).
- **Update Status:** Perubahan `status_bayar` → `pbb.tagihan.dibayar` (saat `lunas`) → worker auto-`INSERT pades_pendapatan` + rekalkulasi skor IDM (47.a PADes, 22 Ekonomi jika `jenis_usaha`).
- **Zero Hardcode:** Label zona, teks halaman bayar, navigasi dari `site_content_blocks`, `i18n_strings`, `feature_flags`.
- **Penyempurnaan (tambahan):** (a) Auto-PADes tanpa input manual; (b) Zonasi untuk pemetaan & targeting; (c) QR payment + notifikasi WA (`info_instan`); (d) Draft usulan infrastruktur otomatis bila akses jalan objek buruk (W5); (e) Total NJOP desa jadi basis skor Dimensi Ekonomi IDM.

---

## 2. Workflow Lengkap Sistem PBB Desa Komplit

```
[A] PENDAFTARAN (fakta mentah)
    wajib_pajak (← penduduk atau is_luar_desa)
        │ 1:N
        ▼
    kepemilikan_objek (persentase, tanggal_mulai, tanggal_selesai=null)
        │ N:1
        ▼
    objek_pajak (nop UNIQUE, status aktif/nonaktif/sengketa, jenis_usaha, nilai_njop_total)
        │ 1:N
        ├─► objek_pajak_lokasi (lat/long, luas, kelas_njop, zona_id → zona_pbb)
        ├─► objek_pajak_penghuni (penyewa/pesuruh)
        └─► pbb_tagihan (tahun_pajak, jumlah_pokok, denda, status_bayar, snapshot_wajib_pajak_utama)
        ▼
[B] PEMETAAN ZONA (F9)
    objek_pajak_lokasi.zona_id → zona_pbb → wilayah_batas (dusun/RT/RW)
        │ tampil di peta publik (titik objek pajak)
        ▼
[C] PEMBAYARAN (QRCode)
    pbb_tagihan → generate token → /pbb/bayar/{token} (QR)
        │ warga scan (web/WA) → bayar
        ▼
    pbb_pembayaran (insert, metode, jumlah) → UPDATE pbb_tagihan.status_bayar
        │ status_bayar = 'lunas'
        ▼
[D] EVENT PROPAGATION (worker)
    pbb.tagihan.dibayar ──► INSERT pades_pendapatan (sumber pbb)
                         ├─► rekalkulasi idm_skor_cache (47.a PADes, 22 Ekonomi jika jenis_usaha)
                         ├─► update total NJOP desa (skor Dimensi Ekonomi)
                         └─► jika akses jalan objek buruk → draft usulan infrastruktur (menunggu_review)
        ▼
[E] DASHBOARD / LAPORAN
    pbb_tagihan + pades_pendapatan → Sistem Keuangan (APBDes) + IDM + ekspor kepatuhan
```

**Aturan Kritikal:**

- `kepemilikan_objek` & `objek_pajak_penghuni` **append-only** — tutup baris lama (`tanggal_selesai`), insert baru; tidak overwrite.
- `nilai_njop_total` = turunan `SUM(objek_pajak_lokasi.nilai_njop_per_m2 * luas)`, di-refresh worker (bukan input manual).
- `status_bayar` hanya berubah lewat `pbb_pembayaran` tervalidasi; `lunas` memicu event (tidak di-set manual sembarangan).
- `snapshot_wajib_pajak_utama_id` di-lock saat tagihan terbit (pemilik mayoritas saat itu).
- `pbb.tagihan.dibayar` → `pades_pendapatan` & `idm_skor_cache` **HANYA worker** (fakta turunan).
- Migrasi urut (§C11): `wajib_pajak` → `objek_pajak` → `objek_pajak_lokasi` → `kepemilikan_objek` → `pbb_tagihan` → `pbb_pembayaran` → `zona_pbb`.

---

## 3. Tabel Jenis PBB Desa

### 3.1 Tabel Induk

| Tabel                  | Fungsi                          | Kolom Kunci                                                                                                                                                                                                                             | Relasi                                                                              |
| ---------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `wajib_pajak`          | Data pemilik pajak              | `id`, `tenant_id`, `penduduk_id`→`penduduk.id` (nullable), `nik`, `nama`, `alamat_domisili`, `is_luar_desa`                                                                                                                             | `penduduk_id`→`penduduk.id`                                                         |
| `objek_pajak`          | Data objek (NOP)                | `id`, `tenant_id`, `nop` (UNIQUE), `bidang_tanah_id`→`bidang_tanah.id`, `status` (`aktif`/`nonaktif`/`sengketa`), `jenis_usaha`, `nilai_njop_total`                                                                                     | `bidang_tanah_id`→`bidang_tanah.id`                                                 |
| `objek_pajak_lokasi`   | Titik & nilai NJOP              | `id`, `objek_pajak_id`, `jenis_lokasi` (`tanah`/`bangunan`), `latitude`, `longitude`, `luas_m2`, `kelas_njop`, `nilai_njop_per_m2`, `zona_id`→`zona_pbb.id`                                                                             | `objek_pajak_id`→`objek_pajak.id`, `zona_id`→`zona_pbb.id`                          |
| `objek_pajak_penghuni` | Penghuni objek                  | `id`, `objek_pajak_id`, `nama_penghuni`, `jenis_penghuni` (`penyewa`/`pesuruh`/`lainnya`), `tanggal_mulai`, `tanggal_selesai` (null=aktif)                                                                                              | `objek_pajak_id`→`objek_pajak.id`                                                   |
| `kepemilikan_objek`    | Kepemilikan (append-only)       | `id`, `wajib_pajak_id`, `objek_pajak_id`, `persentase_kepemilikan`, `tanggal_mulai`, `tanggal_selesai` (null=aktif)                                                                                                                     | `wajib_pajak_id`→`wajib_pajak.id`, `objek_pajak_id`→`objek_pajak.id`                |
| `pbb_tagihan`          | Tagihan per tahun               | `id`, `tenant_id`, `objek_pajak_id`, `tahun_pajak`, `jumlah_pokok`, `denda`, `status_bayar` (`belum_bayar`/`sebagian`/`lunas`), `snapshot_wajib_pajak_utama_id`, `tanggal_bayar`, `token_bayar`, UNIQUE(`objek_pajak_id`,`tahun_pajak`) | `objek_pajak_id`→`objek_pajak.id`, `snapshot_wajib_pajak_utama_id`→`wajib_pajak.id` |
| `pbb_pembayaran`       | Log pembayaran (QR)             | `id`, `tenant_id`, `pbb_tagihan_id`, `jumlah_bayar`, `metode` (`qris`/`transfer`/`tunai`), `tanggal_bayar`, `keterangan`                                                                                                                | `pbb_tagihan_id`→`pbb_tagihan.id`                                                   |
| `zona_pbb`             | Zonasi pemetaan (penyempurnaan) | `id`, `tenant_id`, `kode_zona`, `nama_zona`, `wilayah_id`→`wilayah_batas.id` (null=lintas)                                                                                                                                              | `wilayah_id`→`wilayah_batas.id`                                                     |
| `pades_pendapatan`     | PADes otomatis (Dimensi 5 IDM)  | `id`, `tenant_id`, `tahun`, `sumber` (`pbb`), `nilai`, `pbb_tagihan_id`                                                                                                                                                                 | `pbb_tagihan_id`→`pbb_tagihan.id`                                                   |

### 3.2 Tabel Pendukung

| Tabel                 | Fungsi                                     | Kolom Kunci                                                                                                 | Relasi                            |
| --------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `domain_events`       | Log event pemicu worker                    | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`               | `tenant_id`→`tenants.id`          |
| `wilayah_batas`       | Zona & agregat dusun/RT/RW                 | `id`, `parent_id` (self), `jenis`, `nama`, `geom`                                                           | self-ref `parent_id`              |
| `bidang_tanah`        | Fakta luas & lokasi tanah tunggal (F7)     | `id`, `tenant_id`, `luas`, `geom`, `status`                                                                 | `tenant_id`→`tenants.id`          |
| `site_content_blocks` | Halaman bayar & label zona (zero hardcode) | `id`, `tenant_id`, `halaman`, `tipe_blok` (`layanan`/`peta`/`berita`), `urutan`, `konten` (JSONB), `status` | `tenant_id`→`tenants.id`          |
| `feature_flags`       | Toggle QR payment / zonasi                 | `id`, `tenant_id`, `flag_key`, `enabled`                                                                    | `tenant_id`→`tenants.id`          |
| `i18n_strings`        | Label status & zona                        | `id`, `tenant_id`, `locale`, `key`, `value`                                                                 | `tenant_id`→`tenants.id`          |
| `site_settings`       | Pengaturan tampilan                        | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`   | `tenant_id`→`tenants.id`          |
| `tenant_theme_config` | Tema halaman bayar                         | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                           | `tenant_id`→`tenants.id`          |
| `pbb_log`             | Audit perubahan status (append-only)       | `id`, `tenant_id`, `pbb_tagihan_id`, `status_lama`, `status_baru`, `aktor_id`, `waktu`                      | `pbb_tagihan_id`→`pbb_tagihan.id` |

### 3.3 Diagram Integrasi

```
   penduduk (Core Registry) ──┐
                              ▼
   wajib_pajak ──N:N── kepemilikan_objek ──► objek_pajak (nop)
                              │                    │ 1:N
                              │                    ├─► objek_pajak_lokasi (lat/long, kelas NJOP)
                              │                    │        │ zona_id
                              │                    │        ▼
                              │                    │   zona_pbb ──► wilayah_batas (dusun/RT/RW) ──► Peta (F9)
                              │                    ├─► objek_pajak_penghuni
                              │                    └─► pbb_tagihan (token QR)
                              │                              │ status_bayar
                              │                              ▼
                              │                    pbb_pembayaran (QRIS/transfer/tunai)
                              │                              │ lunas
                              │                              ▼
                              │                    domain_events: pbb.tagihan.dibayar
                              │                              │ worker
                              │                              ├─► pades_pendapatan ──► Sistem Keuangan (APBDes)
                              │                              ├─► idm_skor_cache (47.a, 22) ──► Sistem IDM
                              │                              └─► draft usulan infrastruktur (jika akses buruk)
                              ▼
                   bidang_tanah (F7) ◄── objek_pajak.bidang_tanah_id (fakta luas tunggal)
```

**Keterangan integrasi:** `wajib_pajak` menjembatani ke `penduduk` (Sistem Penduduk, Core Registry) tanpa duplikasi identitas; `objek_pajak` terhubung ke `bidang_tanah` (Sistem Pertanahan F7) sebagai fakta luas tunggal; `objek_pajak_lokasi`+`zona_pbb`+`wilayah_batas` menyuplai peta publik (F9) & agregat dusun; `pbb_tagihan`+`pbb_pembayaran` mengalir ke `pades_pendapatan` (Sistem Keuangan) dan `idm_skor_cache` (Sistem IDM) via Event Propagation; seluruh tampilan dibentuk `site_*`+`i18n_strings` (zero hardcode).
