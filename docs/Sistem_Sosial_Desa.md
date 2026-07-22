# Sistem Sosial Desa

Sistem Sosial Desa mengelola **Bantuan Sosial (Bansos)** sebagai _Single Source of Truth_ data penerima (KPM — Keluarga Penerima Manfaat). Merujuk OpenSID (`tweb_bantuan`/`tweb_keluarga_bantuan`), **SIKS-NG** (Sistem Informasi Kesejahteraan Sosial – Next Generation / DTKS Kemsos) & Sistem Dinas Sosial, diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **1 KPM menampilkan status & jenis bansos yang diterima** dari satu layar, tanpa duplikasi.

## 1. Ringkasan Sistem Sosial (On Point)

- **Peran:** `kpm` + `bansos_penerima` = _Single Source of Truth_ penerima bansos. `kpm` terhubung ke `keluarga`/`penduduk` (Core Registry) sebagai KK penerima.
- **Kanal:** Web admin (operator sosial) catat & verifikasi; impor berkala dari **SIKS-NG/DTKS** (eksternal); Portal Publik read-only (statistik agregat, privasi berlapis).
- **1 KPM View:** Tiap KPM menampilkan semua `bansos_penerima` (jenis program: PKH/BPNT/BST/BLT DD/BLT BBM, status: aktif/nonaktif/ganda/tidak_valid, periode, jumlah) dalam satu halaman — termasuk status kepesertaan **BPJS PBI**-nya.
- **Program:** `bansos_program` (master jenis bantuan) — PKH, BPNT, BST, BLT Dana Desa, BLT BBM, Bantuan Lainnya; sumber dari SIKS-NG & usulan desa.
- **BPJS Kesehatan:** Kepesertaan warga (`bpjs_peserta`) — jenis PBI (terhubung KPM/bansos), PBPU, PPU, BP; KPM penerima bansos → PBI otomatis. `penduduk.bpjs.berubah` → indikator kesehatan IDM.
- **Integrasi IDM:** `bansos.penerima.dicatat` → worker rekalkulasi **Dimensi Sosial** (kesejahteraan, ketimpangan) + `dashboard_agregat`; KPM miskin ekstrem → draft usulan penanganan.
- **Zero Hardcode:** Nama program, label status, teks dashboard dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Sosial Komplit

```
[A] PENDAFTARAN KPM (fakta mentah)
    keluarga (Core Registry, no_kk) ──► kpm (no_kk, kategori: miskin/rentan/beresiko, status_dtks)
        │  impor SIKS-NG/DTKS (eksternal, berkala) → update kpm & bansos_penerima
        ▼
[B] PENETAPAN PENERIMA & BPJS
    bansos_program (pilih jenis) × kpm → bansos_penerima (periode, status, jumlah, no_rekening/token)
        │  KPM penerima bansos → auto daftar BPJS PBI (bpjs_peserta, jenis=PBI, no_peserta)
        │  verifikasi admin (cek ganda/tidak_valid ala SIKS-NG)
        ▼
[C] PENYALURAN
    bansos_penyaluran (penerima_id, tanggal, jumlah, kanal: bank/e-warong/lama/tunai, bukti)
        │  → notifikasi WA ke KPM (info_instan)
        ▼
[D] EVENT PROPAGATION (worker)
    bansos.penerima.dicatat ──► rekalkulasi idm_skor_cache (Dimensi Sosial)
                             ├─► dashboard_agregat (cakupan bansos per dusun)
                             ├─► jika KPM miskin ekstrem → draft usulan penanganan (W2)
                             ▼
[E] LAYANAN TURUNAN
    1-KPM View (status + jenis bansos) · Surat bansos (465.0/465.1/465.5/465.6) auto-fill
    Administrasi_Umum: register bansos auto-sync · Sistem Informasi: berita penyaluran
```

**Aturan Kritikal:**

- `kpm.keluarga_id` / `kpm.kepala_penduduk_id` → `keluarga`/`penduduk` (NIK unik) — tidak input ulang identitas KPM.
- `bansos_penerima` unik per (`kpm_id`, `bansos_program_id`, `periode`) — cegah penerima ganda dalam periode sama.
- Status `ganda`/`tidak_valid` (ala SIKS-NG) → tidak disalurkan, wajib verifikasi admin.
- `bansos.penerima.dicatat` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).
- Impor SIKS-NG bersifat `eksternal` (bukan event operasional) — dashboard wajib tampilkan tanggal update terakhir.

**Event & integrasi:**

| Event                       | Sumber             | Dampak                                                                     |
| --------------------------- | ------------------ | -------------------------------------------------------------------------- |
| `bansos.penerima.dicatat`   | Penetapan penerima | Skor IDM Dimensi Sosial, `dashboard_agregat`, draft usulan (jika ekstrem)  |
| `bansos.penyaluran.dicatat` | Penyaluran         | Notifikasi WA KPM, `agenda_kegiatan` penyaluran, berita (Sistem Informasi) |
| `kpm.dicatat` / `dtks.sync` | Registrasi/impor   | Eligibilitas surat 465.x, agregat kesejahteraan desa                       |
| `penduduk.status.berubah`   | Core Registry      | Eligibilitas KPM (mati/pindah → nonaktif otomatis)                         |
| `penduduk.bpjs.berubah`     | Update status BPJS | IDM indikator kesehatan (cakupan BPJS), 1-KPM View (status PBI)            |

## 3. Tabel Jenis Sosial Desa (OpenSID + SIKS-NG + Dinsos)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)      | Ekuivalen (OpenSID/SIKS-NG)    | Kolom inti                                                                                                                                                                                                                                | Referensi FK                                                                                   |
| ------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `kpm`               | `tweb_keluarga_bantuan` / DTKS | `id`, `tenant_id`, `keluarga_id`→`keluarga.id`, `kepala_penduduk_id`→`penduduk.id`, `no_kk`, `nama_kpm`, `dusun_id`→`wilayah_batas.id`, `kategori` (`miskin`/`rentan`/`beresiko`), `status_dtks` (`valid`/`ganda`/`tidak_valid`), `aktif` | `keluarga_id`→`keluarga.id`; `kepala_penduduk_id`→`penduduk.id`; `dusun_id`→`wilayah_batas.id` |
| `bansos_program`    | Program Kemensos / Desa        | `id`, `tenant_id`, `kode` (UQ), `nama` (PKH/BPNT/BST/BLT DD/BLT BBM/Lainnya), `sumber` (`siks_ng`/`desa`), `periode_default`, `nilai_default`                                                                                             | lookup                                                                                         |
| `bansos_penerima`   | Penerima per KPM               | `id`, `tenant_id`, `kpm_id`→`kpm.id`, `bansos_program_id`→`bansos_program.id`, `periode`, `status` (`aktif`/`nonaktif`/`ganda`/`tidak_valid`), `jumlah`, `no_rekening`/`token`, `UNIQUE(kpm_id, bansos_program_id, periode)`              | `kpm_id`→`kpm.id`; `bansos_program_id`→`bansos_program.id`                                     |
| `bansos_penyaluran` | Penyaluran                     | `id`, `tenant_id`, `bansos_penerima_id`→`bansos_penerima.id`, `tanggal`, `jumlah`, `kanal` (`bank`/`e-warong`/`lama`/`tunai`), `bukti_path`, `dicatat_oleh`                                                                               | `bansos_penerima_id`→`bansos_penerima.id`                                                      |
| `bpjs_peserta`      | Kepesertaan BPJS Kesehatan     | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `kpm_id`→`kpm.id` (nullable), `no_peserta`, `jenis` (`PBI`/`PBPU`/`PPU`/`BP`), `kelas` (`1`/`2`/`3`), `status` (`aktif`/`nonaktif`), `tgl_mulai`, `tgl_berakhir`                          | `penduduk_id`→`penduduk.id`; `kpm_id`→`kpm.id`                                                 |
| `dtks_import`       | SIKS-NG (eksternal)            | `id`, `tenant_id`, `periode_import`, `jumlah_kpm`, `sumber` (`siks_ng`), `tanggal_import`, `status` (`draft`/`diterapkan`)                                                                                                                | `tenant_id`→`tenants.id`                                                                       |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen       | Kolom inti                                                                                                                                    | Referensi FK                                              |
| --------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `domain_events`       | Event Bus       | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                 | `tenant_id`→`tenants.id`                                  |
| `keluarga`            | Core Registry   | `id`, `no_kk`, `nik_kepala`, `alamat`, `dusun`, `rt`, `rw` (referensi KPM)                                                                    | `tenant_id`→`tenants.id`                                  |
| `penduduk`            | Core Registry   | `id`, `nik`, `nama`, `status_dasar` (referensi kepala KPM)                                                                                    | `tenant_id`→`tenants.id`                                  |
| `wilayah_batas`       | Wilayah         | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                                                                   | `parent_id`→`wilayah_batas.id` (self)                     |
| `agenda_kegiatan`     | Agenda (F10)    | `id`, `tenant_id`, `judul`, `jenis` (`umum`), `dibuat_otomatis` (bool), `tanggal_mulai`, `lokasi`                                             | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`sosial`), `metrik_key`, `metrik_value`, `periode`                            | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `site_content_blocks` | CMS Section     | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status`                                | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul    | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                      | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI         | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                   | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema            | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                             | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas       | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                     | `tenant_id`→`tenants.id`                                  |
| `sosial_log`          | Log Audit       | `id`, `tenant_id`, `entity` (`kpm`/`bansos_penerima`/`penyaluran`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk / keluarga (Core Registry, NIK/no_kk) ──┬─► kpm (Keluarga Penerima Manfaat)
                                                 │        ├─► bpjs_peserta (PBI/PBPU/PPU/BP) — KPM penerima → PBI otomatis
                                                 │        │ 1 KPM ──► banyak bansos_penerima
                                                 │        │       (jenis + status per periode)
                                                 │        ▼
                                                 │  dtks_import (SIKS-NG, eksternal) ──► update kpm & bansos_penerima
                                                 │        │
                                                 │        ▼
                                                 │  bansos_penerima ──► bansos_penyaluran (bank/e-warong/lama/tunai)
                                                 │        │                    │ notifikasi WA KPM
                                                 │        ▼                    ▼
                                                 │  domain_events: bansos.penerima.dicatat   agenda_kegiatan (penyaluran)
                                                 │        │ worker                      │
                                                 │        ├─► idm_skor_cache (Dimensi Sosial)  Sistem Informasi (berita)
                                                 │        ├─► dashboard_agregat (sosial)
                                                 │        ├─► bpjs_peserta → penduduk.bpjs.berubah → IDM kesehatan
                                                 │        └─► draft usulan (jika ekstrem) ──► Sistem Keuangan (W2)
                                                 ▼
                              Surat bansos (465.0/465.1/465.5/465.6) auto-fill · Administrasi_Umum (register bansos)
```

**Keterangan integrasi:** `kpm` menjembatani ke `keluarga`/`penduduk` (Sistem Penduduk, Core Registry) tanpa duplikasi identitas; `bansos_penerima` menghubungkan KPM ke `bansos_program` sehingga **1 KPM menampilkan semua status & jenis bansos** dalam satu view. `bpjs_peserta` terhubung ke `penduduk`/`kpm` (KPM penerima bansos → PBI otomatis) dan memicu `penduduk.bpjs.berubah` → IDM kesehatan, sehingga 1-KPM View juga menampilkan status kepesertaan BPJS. Impor `dtks_import` dari SIKS-NG/DTKS menjaga keselarasan dengan Dinsos. Event `bansos.penerima.dicatat` menyuplai `idm_skor_cache` (Dimensi Sosial), `dashboard_agregat`, dan draft usulan ke Sistem Keuangan; surat bansos (Sistem Surat) & register Administrasi_Umum auto-fill dari data ini. Seluruh tampilan dibentuk `site*\*`+`i18n_strings` (zero hardcode).
