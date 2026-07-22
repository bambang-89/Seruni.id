# Sistem Pertanahan Desa (F7)

Sistem Pertanahan Desa mengelola **fakta luas & lokasi tanah** sebagai satu-satunya sumber kebenaran untuk PBB, aset, dan peta desa. Merujuk OpenSID (`tweb_bidang_tanah`, `tweb_tanah_kas_desa`, `tweb_tanah_desa`, `tweb_mutasi_tanah`) diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven, append-only). Kunci: **satu tabel `bidang_tanah` untuk luas & geometri**, modul lain (PBB, Aset) mereferensi, tidak menduplikasi.

## 1. Ringkasan Sistem Pertanahan (On Point)

- **Peran:** `bidang_tanah` = _Single Source of Truth_ luas & lokasi tanah (POLYGON). Histori kepemilikan **append-only** (`kepemilikan_bidang_tanah`, `tanggal_selesai`, tidak overwrite).
- **Klasifikasi:** `tanah_kas_desa` & `tanah_desa` = persil khusus (auto-sync ke Buku Tanah di Sistem Administrasi Umum).
- **Kanal:** Web admin (perangkat desa) catat & verifikasi; read-only untuk publik via Peta (F9).
- **Integrasi:** `objek_pajak.bidang_tanah_id` (PBB), `aset_desa.bidang_tanah_id` (Keuangan F8), Buku Tanah (Administrasi Umum), skor IDM (Lingkungan/Ekonomi), Peta publik (F9).
- **Keamanan:** Append-only (`pertanahan_log`); mutasi tanah memicu event, bukan edit langsung fakta lama.

## 2. Workflow Lengkap Sistem Pertanahan Komplit

```
[A] DAFTAR BIDANG TANAH (fakta mentah)
    bidang_tanah (geom POLYGON, luas, status aktif/nonaktif/sengketa, jenis)
        │ 1:N
        ▼
    kepemilikan_bidang_tanah (persentase, tanggal_mulai, tanggal_selesai=null)
        │
        ▼
[B] KLASIFIKASI PERSIL
    tanah_kas_desa / tanah_desa (no_persil, luas, lokasi, peruntukan) → link bidang_tanah_id
        │
        ▼
[C] MUTASI / ALIH MEDIASI
    bidang_tanah.dialihkan → worker:
        ├─ tutup kepemilikan_bidang_tanah lama (tanggal_selesai)
        ├─ INSERT baris baru (pemilik terkini)
        ├─ auto-sync ke PBB (kepemilikan_objek) & Administrasi_Umum (Buku Tanah)
        ▼
[D] PEMETAAN (F9)
    bidang_tanah.geom → Peta publik (titik/batas tanah, privasi: hanya batas, bukan pemilik)
        │
        ▼
[E] IDM & DASHBOARD
    luas LP2B → skor Dimensi Lingkungan; total NJOP → skor Dimensi Ekonomi
```

**Aturan Kritikal:**

- `kepemilikan_bidang_tanah` **append-only** — tutup baris lama (`tanggal_selesai`), insert baru; tidak overwrite.
- `bidang_tanah` adalah fakta luas tunggal: PBB (`objek_pajak.bidang_tanah_id`) & Aset (`aset_desa.bidang_tanah_id`) **mereferensi**, tidak menduplikasi luas/geom.
- Mutasi tanah (`bidang_tanah.dialihkan`) memicu event → worker sinkron ke PBB & Administrasi Umum (tidak input manual ganda).
- `tanah_kas_desa`/`tanah_desa` hanya klasifikasi persil; data geometri tetap di `bidang_tanah`.

**Event & integrasi:**

| Event                    | Sumber              | Dampak ke modul lain                                               |
| ------------------------ | ------------------- | ------------------------------------------------------------------ |
| `bidang_tanah.dialihkan` | Mutasi kepemilikan  | PBB (`kepemilikan_objek`), Administrasi Umum (Buku Tanah Kas/Desa) |
| `tanah.dicatat`          | Daftar bidang tanah | Peta (F9), agregat wilayah, skor IDM Lingkungan                    |
| `tanah.peruntukan.ubah`  | Edit peruntukan     | IDM Dimensi Ekonomi (NJOP), Rencana tata ruang                     |

## 3. Tabel Jenis Pertanahan (OpenSID + Seruni - Sistem Repository Unifikasi Informasi)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)             | Ekuivalen OpenSID     | Kolom inti                                                                                                                                          | Referensi FK                                                     |
| -------------------------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `bidang_tanah`             | `tweb_bidang_tanah`   | `id`, `tenant_id`, `luas`, `geom` (POLYGON), `status` (`aktif`/`nonaktif`/`sengketa`), `jenis` (`tanah_kas_desa`/`tanah_desa`/`umum`), `keterangan` | `tenant_id`→`tenants.id`                                         |
| `kepemilikan_bidang_tanah` | `tweb_mutasi_tanah`   | `id`, `bidang_tanah_id`, `penduduk_id` (nullable), `persentase_kepemilikan`, `tanggal_mulai`, `tanggal_selesai` (null=aktif)                        | `bidang_tanah_id`→`bidang_tanah.id`; `penduduk_id`→`penduduk.id` |
| `tanah_kas_desa`           | `tweb_tanah_kas_desa` | `id`, `tenant_id`, `no_persil`, `luas_m2`, `lokasi`, `peruntukan`, `bidang_tanah_id`                                                                | `bidang_tanah_id`→`bidang_tanah.id`                              |
| `tanah_desa`               | `tweb_tanah_desa`     | `id`, `tenant_id`, `no_persil`, `luas_m2`, `lokasi`, `peruntukan`, `bidang_tanah_id`                                                                | `bidang_tanah_id`→`bidang_tanah.id`                              |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen              | Kolom inti                                                                                                | Referensi FK                                                  |
| --------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `domain_events`       | Event Bus              | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`             | `tenant_id`→`tenants.id`                                      |
| `wilayah_batas`       | `tweb_wil_clusterdesa` | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                               | `parent_id`→`wilayah_batas.id` (self)                         |
| `site_content_blocks` | CMS Section            | `id`, `tenant_id`, `halaman`, `tipe_blok` (`peta`/`layanan`), `urutan`, `konten` (JSONB), `status`        | `tenant_id`→`tenants.id`                                      |
| `feature_flags`       | Toggle Modul           | `id`, `tenant_id`, `flag_key`, `enabled`                                                                  | `tenant_id`→`tenants.id`                                      |
| `i18n_strings`        | Teks UI                | `id`, `tenant_id`, `locale`, `key`, `value`                                                               | `tenant_id`→`tenants.id`                                      |
| `tenant_theme_config` | Tema                   | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                         | `tenant_id`→`tenants.id`                                      |
| `site_settings`       | Identitas              | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified` | `tenant_id`→`tenants.id`                                      |
| `pertanahan_log`      | Log Audit              | `id`, `tenant_id`, `bidang_tanah_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at`        | `tenant_id`→`tenants.id`; `bidang_tanah_id`→`bidang_tanah.id` |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, NIK) ──► kepemilikan_bidang_tanah
                                     │
                                     ▼
bidang_tanah (geom, luas — fakta tunggal)
   │ 1:1 / 1:N
   ├─► tanah_kas_desa / tanah_desa (persil klasifikasi)
   ├─► objek_pajak (PBB: bidang_tanah_id) ──► pbb_tagihan → pades_pendapatan (Keuangan/IDM)
   ├─► aset_desa (Keuangan F8: bidang_tanah_id)
   ├─► wilayah_batas (F9 Peta) · agregat dusun
   └─► register_buku (Administrasi Umum: Buku Tanah Kas/Desa, ref_id→bidang_tanah.id)
         │
         ▼
domain_events: bidang_tanah.dialihkan ──► pertanahan_log (audit) · worker sinkron PBB & Adm.Umum
```

**Keterangan integrasi:** `bidang_tanah` adalah sumber luas & lokasi tunggal; `kepemilikan_bidang_tanah` mencatat histori pemilik secara append-only. PBB (`objek_pajak`), Keuangan (`aset_desa`), Administrasi Umum (Buku Tanah), dan Peta (F9) **mereferensi** `bidang_tanah` tanpa duplikasi geometri. Mutasi memicu `domain_events` → worker menyinkronkan kepemilikan PBB & entri Buku Tanah. Skor IDM (Lingkungan via LP2B, Ekonomi via NJOP) diturunkan dari agregat `bidang_tanah`. Seluruh tampilan dibentuk `site_*`+`i18n_strings` (zero hardcode).
