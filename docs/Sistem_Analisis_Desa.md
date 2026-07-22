# Sistem Analisis Desa

Sistem Analisis Desa mengelola **analisis kategorik** (kemiskinan, partisipasi, dll) sebagai _Single Source of Truth_ analitik desa. Merujuk OpenSID (`tweb_analisis`/`tweb_analisis_pertanyaan`/`tweb_analisis_respon`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **respon terikat `penduduk` → hasil dihitung → `dashboard_agregat` → IDM**, tanpa hardcode.

## 1. Ringkasan Sistem Analisis (On Point)

- **Peran:** `analisis` + `analisis_pertanyaan` + `analisis_respon` + `analisis_hasil` = _Single Source of Truth_ analisis kategorik.
- **Kanal:** Web admin (analis desa) buat analisis & input respon; Portal read-only (hasil).
- **Subjek:** `penduduk`/`keluarga` (Core Registry) sebagai responden.
- **Integrasi:** `analisis_respon` → `analisis_hasil` → `dashboard_agregat` → **IDM** (indikator terkait).
- **Zero Hardcode:** Pertanyaan, kategori, teks dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Analisis Komplit

```
[A] BUAT ANALISIS
    analisis (kategori: kemiskinan/partisipasi) → analisis_pertanyaan (indikator)
        ▼
[B] INPUT RESPON
    penduduk → analisis_respon (penduduk_id, pertanyaan_id, jawaban)
        ▼
[C] HITUNG HASIL
    analisis_hasil (agregat per kategori/pertanyaan)
        │  → dashboard_agregat
        ▼
[D] EVENT PROPAGATION (worker)
    analisis.selesai ──► idm_skor_cache (indikator terkait)
                      └─► dashboard_agregat (hasil per dusun)
```

**Aturan Kritikal:**

- `analisis_respon.penduduk_id` → `penduduk` (NIK unik) — tidak input ulang identitas.
- `analisis_hasil` **dihitung** dari respon (fakta), bukan diisi manual.
- `analisis.selesai` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                     | Sumber       | Dampak                                            |
| ------------------------- | ------------ | ------------------------------------------------- |
| `analisis.respon.dicatat` | Input respon | Update `analisis_hasil`, `dashboard_agregat`      |
| `analisis.selesai`        | Hitung       | `idm_skor_cache` (indikator), `dashboard_agregat` |

## 3. Tabel Jenis Analisis Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen OpenSID          | Kolom inti                                                                                                                                 | Referensi FK                                                                                       |
| --------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| `analisis`            | `tweb_analisis`            | `id`, `tenant_id`, `nama`, `kategori` (`kemiskinan`/`partisipasi`), `subjek` (`penduduk`/`keluarga`), `status` (`draft`/`aktif`/`selesai`) | `tenant_id`→`tenants.id`                                                                           |
| `analisis_pertanyaan` | `tweb_analisis_pertanyaan` | `id`, `tenant_id`, `analisis_id`→`analisis.id`, `teks`, `tipe` (`pilihan`/`teks`), `urutan`                                                | `analisis_id`→`analisis.id`                                                                        |
| `analisis_respon`     | `tweb_analisis_respon`     | `id`, `tenant_id`, `analisis_id`→`analisis.id`, `pertanyaan_id`→`analisis_pertanyaan.id`, `penduduk_id`→`penduduk.id`, `jawaban`           | `analisis_id`→`analisis.id`; `pertanyaan_id`→`analisis_pertanyaan.id`; `penduduk_id`→`penduduk.id` |
| `analisis_hasil`      | `tweb_analisis_hasil`      | `id`, `tenant_id`, `analisis_id`→`analisis.id`, `pertanyaan_id`→`analisis_pertanyaan.id`, `kategori_jawaban`, `jumlah`, `persen`           | `analisis_id`→`analisis.id`; `pertanyaan_id`→`analisis_pertanyaan.id`                              |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen       | Kolom inti                                                                                                                            | Referensi FK                                              |
| --------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `penduduk`            | Core Registry   | `id`, `nik`, `nama`, `status_dasar` (responden)                                                                                       | `tenant_id`→`tenants.id`                                  |
| `keluarga`            | Core Registry   | `id`, `no_kk`, `nik_kepala`, `alamat`, `dusun`, `rt`, `rw`                                                                            | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`analisis`), `metrik_key`, `metrik_value`, `periode`                  | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `idm_skor_cache`      | Sistem IDM      | `id`, `tenant_id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`                                                         | `tenant_id`→`tenants.id`                                  |
| `domain_events`       | Event Bus       | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                         | `tenant_id`→`tenants.id`                                  |
| `site_content_blocks` | CMS Section     | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                       | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul    | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                              | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI         | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                           | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema            | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                     | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas       | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                             | `tenant_id`→`tenants.id`                                  |
| `analisis_log`        | Log Audit       | `id`, `tenant_id`, `entity` (`analisis`/`analisis_respon`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk / keluarga (Core Registry) ──► analisis_respon (penduduk_id, pertanyaan_id, jawaban)
        │                                      │
        │  analisis (pertanyaan) ──► analisis_pertanyaan
        │                                      ▼
        │                              analisis_hasil (agregat per kategori)
        │                                      │
        │                                      ▼
        │                              domain_events: analisis.selesai
        │                                      │ worker
        │                                      ├─► idm_skor_cache (indikator terkait)
        │                                      └─► dashboard_agregat (hasil per dusun)
        ▼
Sistem Informasi (publikasi hasil analisis)
```

**Keterangan integrasi:** `analisis_respon` terikat `penduduk`/`keluarga` (Core Registry) tanpa duplikasi identitas; `analisis_hasil` dihitung dari respon → `dashboard_agregat` → `idm_skor_cache` (indikator analitik). Hasil dipublikasikan via `Sistem Informasi`. Seluruh tampilan dibentuk `site_*`+`i18n_strings` tanpa hardcode.
