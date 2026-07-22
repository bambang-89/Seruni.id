# Sistem Suplesi Desa

Sistem Suplesi Desa mengelola **data tambahan fleksibel per penduduk** (tanpa alter Core Registry) sebagai _Single Source of Truth_ suplemen data. Merujuk OpenSID (`tweb_suplemen`/`tweb_suplemen_terdata`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Terhubung ke **Sistem Penduduk** (`penduduk`). Kunci: **grup data tambahan → isi per penduduk di kolom JSONB**, skema `penduduk` tetap utuh.

## 1. Ringkasan Sistem Suplesi (On Point)

- **Peran:** `suplemen` + `suplemen_anggota` = _Single Source of Truth_ data tambahan fleksibel per penduduk.
- **Kanal:** Web admin (perangkat) buat grup suplemen & isi data per penduduk; Portal read-only (jika publik).
- **Contoh:** "Penyandang Disabilitas", "Penerima Raskin", "Kelompok Tani", "Peserta KB".
- **Integrasi:** `suplemen_anggota.penduduk_id` → `penduduk`; data JSONB fleksibel; → `dashboard_agregat`; → **Analisis**.
- **Zero Hardcode:** Nama grup, field dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Suplesi Komplit

```
[A] BUAT GRUP SUPLEMEN
    suplemen (nama, keterangan) — mis. "Penyandang Disabilitas"
        ▼
[B] ISI DATA ANGGOTA
    penduduk → suplemen_anggota (suplemen_id, data JSONB)
        ▼
[C] AGREGASI
    suplemen_anggota → dashboard_agregat (jumlah per suplemen)
        ▼
[D] EVENT PROPAGATION (worker)
    suplemen.anggota.ditambah ──► dashboard_agregat
                            └─► Analisis (filter responden)
```

**Aturan Kritikal:**

- `suplemen_anggota.penduduk_id` → `penduduk` (NIK unik); tidak duplikasi identitas.
- Data fleksibel di kolom **JSONB** (tidak alter tabel `penduduk`).
- `suplemen.anggota.ditambah` → `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                       | Sumber        | Dampak                                             |
| --------------------------- | ------------- | -------------------------------------------------- |
| `suplemen.anggota.ditambah` | Isi data      | `dashboard_agregat`, `Analisis` (filter responden) |
| `penduduk.status.berubah`   | Core Registry | Re-evaluasi keanggotaan (mis. mati → nonaktif)     |

## 3. Tabel Jenis Suplesi Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)     | Ekuivalen OpenSID       | Kolom inti                                                                                                                 | Referensi FK                                             |
| ------------------ | ----------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `suplemen`         | `tweb_suplemen`         | `id`, `tenant_id`, `nama`, `keterangan`, `aktif`                                                                           | `tenant_id`→`tenants.id`                                 |
| `suplemen_anggota` | `tweb_suplemen_terdata` | `id`, `tenant_id`, `suplemen_id`→`suplemen.id`, `penduduk_id`→`penduduk.id`, `data` (JSONB), `status` (`aktif`/`nonaktif`) | `suplemen_id`→`suplemen.id`; `penduduk_id`→`penduduk.id` |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen       | Kolom inti                                                                                                                             | Referensi FK                                              |
| --------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `penduduk`            | Core Registry   | `id`, `nik`, `nama`, `status_dasar` (anggota)                                                                                          | `tenant_id`→`tenants.id`                                  |
| `keluarga`            | Core Registry   | `id`, `no_kk`, `nik_kepala`, `alamat`, `dusun`, `rt`, `rw`                                                                             | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`suplemen`), `metrik_key`, `metrik_value`, `periode`                   | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `analisis`            | Sistem Analisis | `id`, `tenant_id`, `nama`, `kategori`, `subjek`, `status`                                                                              | `tenant_id`→`tenants.id`                                  |
| `domain_events`       | Event Bus       | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                          | `tenant_id`→`tenants.id`                                  |
| `site_content_blocks` | CMS Section     | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                        | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul    | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                               | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI         | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                            | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema            | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                      | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas       | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                              | `tenant_id`→`tenants.id`                                  |
| `suplemen_log`        | Log Audit       | `id`, `tenant_id`, `entity` (`suplemen`/`suplemen_anggota`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, NIK) ──► suplemen_anggota (data JSONB)
        │                                │  suplemen_id → suplemen
        │                                ▼
        │                        domain_events: suplemen.anggota.ditambah
        │                                │ worker
        │                                ├─► dashboard_agregat (jumlah per suplemen)
        │                                └─► Analisis (filter responden suplemen)
        ▼
Sistem Informasi (publikasi kelompok, privasi berlapis)
```

**Keterangan integrasi:** `suplemen_anggota` terikat `penduduk` (Sistem Penduduk, Core Registry) tanpa alter skema `penduduk`; data fleksibel disimpan di kolom JSONB. Penambahan anggota memicu `dashboard_agregat` & dapat difilter sebagai responden di `Sistem Analisis`. Seluruh tampilan dibentuk `site_*`+`i18n_strings` tanpa hardcode; privasi berlapis (data sensitif hanya di admin).
