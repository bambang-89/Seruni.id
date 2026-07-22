# Sistem Stunting Desa

Sistem Stunting Desa mengelola **pemantauan stunting & gizi** sebagai _Single Source of Truth_ status gizi balita. Merujuk OpenSID (`tweb_stunting`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Terhubung erat ke **Sistem Posyandu** (`balita`/`posyandu_kunjungan`). Kunci: **status stunting dievaluasi otomatis dari kunjungan posyandu** (bb/tb), bukan input bebas.

## 1. Ringkasan Sistem Stunting (On Point)

- **Peran:** `stunting_anak` + `stunting_intervensi` + `stunting_rekap` = _Single Source of Truth_ pemantauan stunting & gizi.
- **Kanal:** Web admin (kader posyandu) catat dari `posyandu_kunjungan`; Portal read-only (statistik).
- **Evaluasi:** `stunting_anak.balita_id` → `balita` (Posyandu); status dihitung dari bb/u, tb/u, bb/tb (ambang WHO).
- **Integrasi:** `posyandu.kunjungan.dicatat` → evaluasi stunting → `stunting_anak`; → **Sosial** (bansos gizi/PBI), **IDM** (kesehatan), **Informasi**.
- **Zero Hardcode:** Label status, teks notifikasi dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Stunting Komplit

```
[A] KUNJUNGAN POSYANDU
    balita (Posyandu) → posyandu_kunjungan (bb, tb, lingkar, imunisasi)
        │  hitung bb/u, tb/u, bb/tb → status stunting (ambang WHO)
        ▼
[B] EVALUASI & CATAT
    stunting_anak (balita_id, status_stunting, bb_u, tb_u, bb_tb, intervensi_aktif)
        │  jika stunting → buat stunting_intervensi (gizi, vitamin, rujukan)
        ▼
[C] INTERVENSI
    stunting_intervensi (jenis, jadwal, hasil) berkala
        │  → notifikasi WA ke ortu (info_instan)
        ▼
[D] EVENT PROPAGATION (worker)
    stunting.dievaluasi ──► idm_skor_cache (kesehatan)
                       ├─► dashboard_agregat (stunting per dusun)
                       ├─► Sosial (bansos gizi / PBI otomatis)
                       ▼
    Sistem Informasi (pengumuman gizi) · Surat rujukan (auto-fill)
```

**Aturan Kritikal:**

- `stunting_anak.balita_id` → `balita` (Posyandu); tidak input ulang identitas balita.
- Status stunting **dihitung** dari `posyandu_kunjungan` (bb/tb) — tidak input manual bebas.
- `stunting_intervensi` append-only; perubahan = entri baru.
- `stunting.dievaluasi` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                         | Sumber   | Dampak                                                                    |
| ----------------------------- | -------- | ------------------------------------------------------------------------- |
| `posyandu.kunjungan.dicatat`  | Posyandu | Evaluasi stunting otomatis → `stunting_anak`                              |
| `stunting.dievaluasi`         | Kader    | `idm_skor_cache` (kesehatan), `dashboard_agregat`, `Sosial` (bansos gizi) |
| `stunting.intervensi.dicatat` | Kader    | Notifikasi ortu, Surat rujukan (Sistem Surat)                             |

## 3. Tabel Jenis Stunting Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen OpenSID | Kolom inti                                                                                                                                                | Referensi FK                          |
| --------------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `stunting_anak`       | `tweb_stunting`   | `id`, `tenant_id`, `balita_id`→`balita.id`, `status_stunting` (`ya`/`tidak`/`risiko`), `bb_u`, `tb_u`, `bb_tb`, `intervensi_aktif` (bool), `dicatat_oleh` | `balita_id`→`balita.id`               |
| `stunting_intervensi` | Intervensi gizi   | `id`, `tenant_id`, `stunting_anak_id`→`stunting_anak.id`, `jenis` (`gizi`/`vitamin`/`rujukan`), `jadwal`, `hasil`, `status` (`berjalan`/`selesai`)        | `stunting_anak_id`→`stunting_anak.id` |
| `stunting_rekap`      | Rekap per dusun   | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `periode`, `jumlah_balita`, `jumlah_stunting`, `persen`                                               | `wilayah_id`→`wilayah_batas.id`       |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen         | Kolom inti                                                                                                                                     | Referensi FK                                                    |
| --------------------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `balita`              | Sistem Posyandu   | `id`, `tenant_id`, `ortu_penduduk_id`→`penduduk.id`, `nama`, `tgl_lahir`, `status_gizi`                                                        | `ortu_penduduk_id`→`penduduk.id`                                |
| `posyandu_kunjungan`  | Sistem Posyandu   | `id`, `tenant_id`, `balita_id`→`balita.id`, `bb`, `tb`, `lingkar`, `imunisasi`, `tanggal`                                                      | `balita_id`→`balita.id`                                         |
| `penduduk`            | Core Registry     | `id`, `nik`, `nama`, `status_dasar` (ortu)                                                                                                     | `tenant_id`→`tenants.id`                                        |
| `wilayah_batas`       | Wilayah           | `id`, `tenant_id`, `jenis`, `nama`, `geom`, `parent_id`                                                                                        | `parent_id`→`wilayah_batas.id` (self)                           |
| `kpm`                 | Sistem Sosial     | `id`, `tenant_id`, `keluarga_id`→`keluarga.id`, `kepala_penduduk_id`→`penduduk.id`, `no_kk`, `nama_kpm`                                        | `keluarga_id`→`keluarga.id`; `kepala_penduduk_id`→`penduduk.id` |
| `idm_skor_cache`      | Sistem IDM        | `id`, `tenant_id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`                                                                  | `tenant_id`→`tenants.id`                                        |
| `dashboard_agregat`   | Info Grafis IDM   | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`stunting`), `metrik_key`, `metrik_value`, `periode`                           | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id`       |
| `domain_events`       | Event Bus         | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                  | `tenant_id`→`tenants.id`                                        |
| `notifikasi`          | Sistem Notifikasi | `id`, `tenant_id`, `penerima_tipe`, `penerima_id`, `judul`, `pesan`, `status_baca`, `tautan`                                                   | `tenant_id`→`tenants.id`                                        |
| `site_content_blocks` | CMS Section       | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                                | `tenant_id`→`tenants.id`                                        |
| `feature_flags`       | Toggle Modul      | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                       | `tenant_id`→`tenants.id`                                        |
| `i18n_strings`        | Teks UI           | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                    | `tenant_id`→`tenants.id`                                        |
| `tenant_theme_config` | Tema              | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                              | `tenant_id`→`tenants.id`                                        |
| `site_settings`       | Identitas         | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                      | `tenant_id`→`tenants.id`                                        |
| `stunting_log`        | Log Audit         | `id`, `tenant_id`, `entity` (`stunting_anak`/`stunting_intervensi`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                        |

### 3.3 Diagram integrasi

```
balita (Posyandu) ──► posyandu_kunjungan (bb/tb/lingkar, imunisasi)
        │                │  hitung bb/u, tb/u, bb/tb
        │                ▼
        │         stunting_anak (status_stunting, intervensi_aktif)
        │                │  jika stunting
        │                ▼
        │         stunting_intervensi (gizi/vitamin/rujukan) → notifikasi ortu
        │                │
        │                ▼
        │         domain_events: stunting.dievaluasi
        │                │ worker
        │                ├─► idm_skor_cache (kesehatan)
        │                ├─► dashboard_agregat (per dusun)
        │                ├─► Sosial (bansos gizi / PBI otomatis)
        │                ▼
        ▼  Sistem Informasi (pengumuman gizi) · Surat rujukan (auto-fill)
```

**Keterangan integrasi:** `stunting_anak` terhubung ke `balita` (Sistem Posyandu) tanpa duplikasi identitas; dievaluasi otomatis dari `posyandu_kunjungan` (bb/tb). Intervensi gizi memicu `Sosial` (bansos gizi / PBI otomatis), `idm_skor_cache` (kesehatan), `dashboard_agregat`, `Sistem Informasi` (pengumuman), dan Surat rujukan (auto-fill). Seluruh tampilan dibentuk `site_*`+`i18n_strings` tanpa hardcode.
