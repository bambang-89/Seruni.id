# Sistem Pembangunan Desa

Sistem Pembangunan Desa mengelola **perencanaan & eksekusi fisik desa** (musrenbang → kegiatan → serah terima) sebagai _Single Source of Truth_ infrastruktur desa. Merujuk OpenSID (`tweb_pembangunan`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **satu kegiatan → teranggarkan (APBDes) → jadi aset (F8) → naikkan skor IDM Dimensi 1**, tanpa dual-entry.

## 1. Ringkasan Sistem Pembangunan (On Point)

- **Peran:** `usulan_pembangunan` (musrenbang) + `pembangunan` (kegiatan fisik) + `pembangunan_dokumentasi` + `pembangunan_peserta` = _Single Source of Truth_ pembangunan desa.
- **Kanal:** Web admin (TPK/sekretariat) input usulan & realisasi; warga usul via **Layanan Mandiri**; Portal Publik read-only (progrs & peta).
- **Siklus:** Musrenbang → `usulan_pembangunan` (diverifikasi) → masuk `pembangunan` (APBDes) → progres `pembangunan_dokumentasi` → selesai → `aset_desa` (F8) otomatis.
- **Sumber Dana:** `sumber_dana` (APBDes, DLL, Swadaya, Bansos Prov).
- **Integrasi IDM:** `pembangunan.selesai` → **Dimensi 1 (Infrastruktur)** & `dashboard_agregat`.
- **Zero Hardcode:** Nama kegiatan, label status, teks dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Pembangunan Komplit

```
[A] MUSRENBANG (usulan)
    penduduk/warga (via Layanan Mandiri) → usulan_pembangunan (judul, dusun_id, volume, prioritas)
        │  verifikasi TPK/desa
        ▼
[B] PENETAPAN & ANGGARAN
    usulan_pembangunan (disetujui) → pembangunan (sumber_dana_id, angaran, pelaksana)
        │  → apbdes_realisasi (Sistem Keuangan) auto-draft
        ▼
[C] PELAKSANAAN
    pembangunan_dokumentasi (foto progres, %, tanggal) berkala
        │  → notifikasi WA ke warga (info_instan)
        ▼
[D] SELESAI & SERAH TERIMA
    pembangunan.status = selesai → aset_desa (F8) auto (jika belanja modal)
        │  → event pembangunan.selesai
        ▼
[E] EVENT PROPAGATION (worker)
    pembangunan.selesai ──► idm_skor_cache (Dimensi 1 Infrastruktur)
                       ├─► dashboard_agregat (pembangunan per dusun)
                       ├─► Administrasi_Umum (register buku pembangunan)
                       ▼
    Sistem Informasi (berita) · Peta (F9) titik pembangunan
```

**Aturan Kritikal:**

- `pembangunan.sumber_dana_id` → `sumber_dana`; anggaran wajib sinkron `apbdes_realisasi` (tidak input ganda).
- `pembangunan` selesai → `aset_desa` otomatis bila jenis belanja modal (via event, bukan input manual).
- `usulan_pembangunan` unik per (`dusun_id`, `judul`, `periode`) — cegah duplikat.
- `pembangunan.selesai` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                   | Sumber       | Dampak                                                                                      |
| ----------------------- | ------------ | ------------------------------------------------------------------------------------------- |
| `pembangunan.diusulkan` | Musrenbang   | Masuk usulan, agregat kebutuhan dusun                                                       |
| `pembangunan.disetujui` | Penetapan    | Draft `apbdes_realisasi` (Keuangan), `sumber_dana`                                          |
| `pembangunan.selesai`   | Serah terima | `idm_skor_cache` (Dimensi 1), `aset_desa` (F8), `Administrasi_Umum`, `Informasi`, Peta (F9) |

## 3. Tabel Jenis Pembangunan Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)            | Ekuivalen OpenSID           | Kolom inti                                                                                                                                                                                                                                                                                        | Referensi FK                                                                                          |
| ------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `usulan_pembangunan`      | `tweb_pembangunan` (usulan) | `id`, `tenant_id`, `penduduk_id`→`penduduk.id` (pengusul), `dusun_id`→`wilayah_batas.id`, `judul`, `volume`, `prioritas`, `status` (`diajukan`/`diverifikasi`/`disetujui`/`ditolak`), `periode`                                                                                                   | `penduduk_id`→`penduduk.id`; `dusun_id`→`wilayah_batas.id`                                            |
| `pembangunan`             | `tweb_pembangunan`          | `id`, `tenant_id`, `usulan_id`→`usulan_pembangunan.id` (nullable), `dusun_id`→`wilayah_batas.id`, `nama_kegiatan`, `volume`, `satuan`, `sumber_dana_id`→`sumber_dana.id`, `angaran`, `pelaksana`, `waktu_mulai`, `waktu_selesai`, `status` (`rencana`/`berjalan`/`selesai`/`batal`), `lat`, `lng` | `usulan_id`→`usulan_pembangunan.id`; `dusun_id`→`wilayah_batas.id`; `sumber_dana_id`→`sumber_dana.id` |
| `pembangunan_dokumentasi` | Dokumentasi progres         | `id`, `tenant_id`, `pembangunan_id`→`pembangunan.id`, `tanggal`, `persen_progres`, `foto_path`, `keterangan`                                                                                                                                                                                      | `pembangunan_id`→`pembangunan.id`                                                                     |
| `pembangunan_peserta`     | Penerima manfaat            | `id`, `tenant_id`, `pembangunan_id`→`pembangunan.id`, `dusun_id`→`wilayah_batas.id`, `jumlah_kk`, `keterangan`                                                                                                                                                                                    | `pembangunan_id`→`pembangunan.id`; `dusun_id`→`wilayah_batas.id`                                      |
| `sumber_dana`             | Lookup sumber               | `id`, `tenant_id`, `kode`, `nama` (APBDes/DLL/Swadaya/Bansos Prov), `urutan`, `aktif`                                                                                                                                                                                                             | `tenant_id`→`tenants.id`                                                                              |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen            | Kolom inti                                                                                                                                  | Referensi FK                                              |
| --------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `domain_events`       | Event Bus            | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                               | `tenant_id`→`tenants.id`                                  |
| `wilayah_batas`       | Wilayah              | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                                                                 | `parent_id`→`wilayah_batas.id` (self)                     |
| `apbdes_realisasi`    | Sistem Keuangan      | `id`, `tenant_id`, `pembangunan_id`→`pembangunan.id` (nullable), `kode_rekening`, `nilai`, `status`                                         | `pembangunan_id`→`pembangunan.id`                         |
| `aset_desa`           | Sistem Keuangan (F8) | `id`, `tenant_id`, `pembangunan_id`→`pembangunan.id` (nullable), `nama`, `kondisi`, `nilai`, `bidang_tanah_id` (nullable)                   | `pembangunan_id`→`pembangunan.id`                         |
| `idm_skor_cache`      | Sistem IDM           | `id`, `tenant_id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`                                                               | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM      | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`pembangunan`), `metrik_key`, `metrik_value`, `periode`                     | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `site_content_blocks` | CMS Section          | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status`                              | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul         | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                    | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI              | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                 | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema                 | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                           | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas            | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                   | `tenant_id`→`tenants.id`                                  |
| `pembangunan_log`     | Log Audit            | `id`, `tenant_id`, `entity` (`usulan_pembangunan`/`pembangunan`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk (via Layanan Mandiri) ──► usulan_pembangunan (musrenbang)
                                        │  disetujui
                                        ▼
pembangunan (kegiatan fisik) ──► apbdes_realisasi (Keuangan, auto-draft)
        │  sumber_dana_id → sumber_dana
        │  pembangunan_dokumentasi (progres) → notifikasi WA
        │  pembangunan_peserta (penerima manfaat)
        ▼  status = selesai
domain_events: pembangunan.selesai
        │ worker
        ├─► aset_desa (F8, jika belanja modal)
        ├─► idm_skor_cache (Dimensi 1 Infrastruktur)
        ├─► dashboard_agregat (per dusun)
        ├─► Administrasi_Umum (register buku pembangunan)
        ▼  Sistem Informasi (berita) · Peta (F9) titik pembangunan
```

**Keterangan integrasi:** `usulan_pembangunan` (musrenbang, dari warga via Layanan Mandiri) → `pembangunan` (fisik) terhubung ke `apbdes_realisasi` (Sistem Keuangan) & `sumber_dana`; saat selesai → `aset_desa` (F8) otomatis + `idm_skor_cache` (Dimensi 1 Infrastruktur) + `dashboard_agregat` + `Administrasi_Umum` (register) + `Sistem Informasi` (berita) + Peta (F9). Seluruh tampilan dibentuk `site*\*`+`i18n_strings` tanpa hardcode.
