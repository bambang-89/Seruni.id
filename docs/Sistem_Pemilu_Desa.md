# Sistem Pemilu Desa

Sistem Pemilu Desa mengelola **Daftar Pemilih Tetap (DPT) & pemilihan** (Pilkades/Pilpres/Pileg) sebagai _Single Source of Truth_ pemilu desa. Merujuk OpenSID (`tweb_dpt`/`tweb_pemilihan`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **DPT terikat `penduduk` (eligible) → hasil → partisipasi IDM**, tanpa duplikasi.

## 1. Ringkasan Sistem Pemilu (On Point)

- **Peran:** `dpt` + `pemilihan` + `pemilihan_suara` = _Single Source of Truth_ pemilu desa & DPT.
- **Kanal:** Web admin (PPK/PPS desa) input DPT & hasil; Portal read-only (hasil & partisipasi).
- **DPT:** `dpt.penduduk_id` → `penduduk` (eligible: usia ≥17, bukan TNI/Polri, status HIDUP).
- **Integrasi:** `pemilihan` (Pilkades/Pilpres/Pileg) → **Informasi** (hasil), **IDM** (partisipasi); reuse `dpt` untuk validasi pemilih di voting musdes (F2, Sistem Keuangan).
- **Zero Hardcode:** Jenis pemilihan, label status, teks dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Pemilu Komplit

```
[A] SUSUN DPT
    penduduk (eligible: usia≥17, bukan TNI/Polri, status HIDUP) → dpt (tps, status)
        ▼
[B] BUAT PEMILIHAN
    pemilihan (jenis, tanggal, wilayah) → daftar TPS
        ▼
[C] PENGHITUNGAN
    pemilihan_suara (pemilihan_id, tps, calon, jumlah) → rekap
        │  → notifikasi WA (info_instan)
        ▼
[D] EVENT PROPAGATION (worker)
    pemilihan.selesai ──► dashboard_agregat (partisipasi)
                      ├─► idm_skor_cache (partisipasi masyarakat)
                      ▼
    Sistem Informasi (pengumuman hasil)
```

**Aturan Kritikal:**

- `dpt.penduduk_id` → `penduduk` (NIK unik); eligible by status & usia (tidak input manual daftar).
- `pemilihan_suara` unik per (`pemilihan_id`, `tps`, `calon`) — cegah hitung ganda.
- `pemilihan.selesai` → `dashboard_agregat` & `idm_skor_cache` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event               | Sumber | Dampak                                                           |
| ------------------- | ------ | ---------------------------------------------------------------- |
| `pemilihan.dibuat`  | Admin  | Agenda, notifikasi warga (Sistem Notifikasi)                     |
| `pemilihan.selesai` | Hitung | `dashboard_agregat` (partisipasi), `idm_skor_cache`, `Informasi` |
| `dpt.berubah`       | Update | Rekap DPT, validasi pemilih voting musdes (F2)                   |

## 3. Tabel Jenis Pemilu Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)    | Ekuivalen OpenSID | Kolom inti                                                                                                                                                          | Referensi FK                    |
| ----------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `dpt`             | `tweb_dpt`        | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `tps`, `status` (`aktif`/`nonaktif`), `keterangan`                                                                  | `penduduk_id`→`penduduk.id`     |
| `pemilihan`       | `tweb_pemilihan`  | `id`, `tenant_id`, `jenis` (`pilkades`/`pilpres`/`pileg`/`lainnya`), `nama`, `tanggal`, `wilayah_id`→`wilayah_batas.id`, `status` (`draft`/`berlangsung`/`selesai`) | `wilayah_id`→`wilayah_batas.id` |
| `pemilihan_suara` | Hasil suara       | `id`, `tenant_id`, `pemilihan_id`→`pemilihan.id`, `tps`, `calon` (teks), `jumlah`, `sah`/`tidak_sah`                                                                | `pemilihan_id`→`pemilihan.id`   |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen         | Kolom inti                                                                                                                                   | Referensi FK                                              |
| --------------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `penduduk`            | Core Registry     | `id`, `nik`, `nama`, `tgl_lahir`, `status_dasar` (eligible DPT)                                                                              | `tenant_id`→`tenants.id`                                  |
| `wilayah_batas`       | Wilayah           | `id`, `tenant_id`, `jenis`, `nama`, `geom`, `parent_id`                                                                                      | `parent_id`→`wilayah_batas.id` (self)                     |
| `dashboard_agregat`   | Info Grafis IDM   | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`pemilu`), `metrik_key`, `metrik_value`, `periode`                           | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `idm_skor_cache`      | Sistem IDM        | `id`, `tenant_id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`                                                                | `tenant_id`→`tenants.id`                                  |
| `domain_events`       | Event Bus         | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                | `tenant_id`→`tenants.id`                                  |
| `notifikasi`          | Sistem Notifikasi | `id`, `tenant_id`, `penerima_tipe`, `penerima_id`, `judul`, `pesan`, `status_baca`, `tautan`                                                 | `tenant_id`→`tenants.id`                                  |
| `site_content_blocks` | CMS Section       | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                              | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul      | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                     | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI           | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                  | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema              | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                            | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas         | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                    | `tenant_id`→`tenants.id`                                  |
| `pemilu_log`          | Log Audit         | `id`, `tenant_id`, `entity` (`dpt`/`pemilihan`/`pemilihan_suara`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, eligible) ──► dpt (tps, status)
        │
        ▼
pemilihan (pilkades/pilpres/pileg) ──► pemilihan_suara (per TPS/calon)
        │                                      │
        │                                      ▼
        │                              domain_events: pemilihan.selesai
        │                                      │ worker
        │                                      ├─► dashboard_agregat (partisipasi)
        │                                      ├─► idm_skor_cache (partisipasi masyarakat)
        │                                      ▼
        ▼                              Sistem Informasi (pengumuman hasil)
```

**Keterangan integrasi:** `dpt` terikat `penduduk` (Sistem Penduduk, Core Registry) tanpa duplikasi identitas; eligible otomatis by status & usia. `pemilihan` (Pilkades/Pilpres/Pileg) menghasilkan `pemilihan_suara` yang via event menyuplai `dashboard_agregat` (partisipasi) & `idm_skor_cache`, serta dipublikasikan via `Sistem Informasi`. DPT dapat reuse untuk validasi pemilih di voting musdes (F2, Sistem Keuangan). Seluruh tampilan dibentuk `site_*`+`i18n_strings` tanpa hardcode.
