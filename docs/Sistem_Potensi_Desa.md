# Sistem Potensi Desa

Sistem Potensi Desa mengelola kekuatan ekonomi & wisata desa: **Marketplace** (BUMDes, Koperasi Desa Merah Putih, UMKM), **Perekonomian** (Pertanian, Perikanan, Industri, Perdagangan, Layanan Jasa), dan **Pariwisata** (Perairan, Pegunungan, Budaya, dll). Diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven) merujuk OpenSID (`tweb_penduduk` pemilik UMKM, `tweb_grup` lembaga ekonomi) + ekstensi marketplace Seruni - Sistem Repository Unifikasi Informasi.

## 1. Ringkasan Sistem Potensi Desa (On Point)

- **Peran:** `bumdes` + `koperasi_desa` + `umkm` + `produk_marketplace` + `sektor_ekonomi` + `pariwisata` = _Single Source of Truth_ potensi ekonomi & wisata desa.
- **Kanal:** Web admin (perangkat/BUMDes) kelola & publish; Portal Publik (read-only) + WA untuk warga belanja/lihat potensi.
- **Marketplace:** Profil lembaga (BUMDes/Koperasi) + produk; UMKM tampilkan produk — semua via `produk_marketplace` (status draft→publish).
- **Perekonomian:** Tabel sektor bisa ditambah (Pertanian, Perikanan, Industri, Perdagangan, Layanan Jasa, dll) — sumber skor IDM ekonomi.
- **Pariwisata:** Jenis & nama wisata bisa ditambah (Perairan "Denda Seruni", Pegunungan, dll) — terintegrasi peta (`wilayah_batas`).
- **Keamanan:** RBAC (admin/BUMDes CRUD, warga read-only); `draft` → preview → `publish`; audit `potensi_log` (append-only).

## 2. Workflow lengkap sistem Potensi Desa Komplit

```
[Admin/BUMDes] 1. Daftarkan BUMDes & Koperasi Desa Merah Putih
        │  → bumdes / koperasi_desa (profil lembaga, kontak, logo)
        │  → link ke lembaga_desa (Sistem Profile_Desa) agar muncul di direktori + PageDetail
        ▼
2. Daftarkan UMKM (pilih pemilik by NIK dari penduduk)
        │  → umkm (nama_usaha, sektor, profil)
        ▼
3. Tambah Produk Marketplace
        │  → produk_marketplace (penjual: bumdes/koperasi/umkm, nama, kategori, harga, stok, foto)
        │  → status: DRAFT → preview → PUBLISH
        ▼
4. Katalog Perekonomian — tambah sektor (Pertanian/Perikanan/Industri/Perdagangan/Layanan Jasa, dll)
        │  → sektor_ekonomi (jenis, nama, nilai, tahun, lokasi)
        ▼
5. Katalog Pariwisata — tambah jenis & nama (Perairan "Denda Seruni", Pegunungan, dll)
        │  → pariwisata (jenis, nama, deskripsi, lokasi/geom, foto)
        ▼
6. Tampilkan di Portal — section Marketplace, Ekonomi, Wisata (site_content_blocks)
        │  → pariwisata terpasang di peta (wilayah_batas, F9)
        ▼
Publik: belanja marketplace · lihat ekonomi desa · eksplor wisata (peta)
```

**Aturan kritikal:**

- `produk_marketplace` wajib `draft` → **preview** → `publish` (sama dengan Sistem Informasi).
- `bumdes`/`koperasi_desa` **wajib link** ke `lembaga_desa` → profil muncul di direktori lembaga & PageDetail (Sistem Profile_Desa).
- `umkm.pemilik_penduduk_id` → `penduduk` (NIK unik, Core Registry Sistem Penduduk) — tidak input ulang identitas.
- `pariwisata` wajib punya `dusun_id`/`geom` → tampil di peta publik (F9); privasi: hanya titik wisata, bukan rumah warga.
- `sektor_ekonomi` menjadi sumber turunan skor IDM Dimensi Ekonomi & `dashboard_agregat`.

**Event & integrasi:**

| Event                               | Sumber                 | Dampak                                      |
| ----------------------------------- | ---------------------- | ------------------------------------------- |
| `bumdes.dibuat` / `koperasi.dibuat` | Daftar lembaga ekonomi | Link `lembaga_desa`, direktori & PageDetail |
| `umkm.dibuat`                       | Daftar UMKM            | Profil publik, statistik wirausaha desa     |
| `potensi.produk.terbit`             | Publish produk         | Section Marketplace Beranda, notifikasi WA  |
| `potensi.wisata.terbit`             | Publish wisata         | Peta publik (F9), section Wisata            |
| `ekonomi.sektor.dicatat`            | Katalog sektor         | Skor IDM ekonomi, `dashboard_agregat`       |

## 3. Tabel Jenis Potensi Desa (OpenSID + Potensi Desa)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)       | Ekuivalen OpenSID         | Kolom inti                                                                                                                                                                               | Referensi FK                                                                     |
| -------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `bumdes`             | `tweb_grup` (BUMDes)      | `id`, `tenant_id`, `lembaga_id` (nullable), `nama`, `slug` (UQ), `profil` (JSONB), `kontak`, `alamat`, `logo`, `status` (`aktif`/`nonaktif`)                                             | `lembaga_id`→`lembaga_desa.id`                                                   |
| `koperasi_desa`      | `tweb_grup` (Koperasi)    | `id`, `tenant_id`, `lembaga_id` (nullable), `nama`, `slug` (UQ), `profil` (JSONB), `kontak`, `alamat`, `logo`, `status`                                                                  | `lembaga_id`→`lembaga_desa.id`                                                   |
| `umkm`               | `tweb_penduduk` (pemilik) | `id`, `tenant_id`, `nama_usaha`, `pemilik_penduduk_id`, `slug`, `profil` (JSONB), `kontak`, `alamat`, `sektor_id` (nullable), `status`                                                   | `pemilik_penduduk_id`→`penduduk.id`; `sektor_id`→`jenis_sektor.id`               |
| `produk_marketplace` | Marketplace               | `id`, `tenant_id`, `penjual_tipe` (`bumdes`/`koperasi`/`umkm`), `penjual_id`, `nama_produk`, `kategori_id`, `harga`, `satuan`, `stok`, `deskripsi`, `foto`, `status` (`draft`/`publish`) | `kategori_id`→`kategori_produk.id`; `penjual_id`→`bumdes`/`koperasi_desa`/`umkm` |
| `sektor_ekonomi`     | Data Ekonomi              | `id`, `tenant_id`, `jenis_id`, `nama`, `keterangan`, `nilai`, `tahun`, `dusun_id` (nullable)                                                                                             | `jenis_id`→`jenis_sektor.id`; `dusun_id`→`wilayah_batas.id`                      |
| `pariwisata`         | Potensi Wisata            | `id`, `tenant_id`, `jenis_id`, `nama` (mis. Denda Seruni), `deskripsi`, `lokasi`, `dusun_id`, `geom` (POINT), `foto`, `kategori_id`                                                      | `jenis_id`→`jenis_wisata.id`; `dusun_id`→`wilayah_batas.id`                      |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen            | Kolom inti                                                                                                                          | Referensi FK                                              |
| --------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `kategori_produk`     | Kategori Produk      | `id`, `nama` (makanan, kerajinan, pertanian, dll), `urutan`                                                                         | lookup                                                    |
| `jenis_sektor`        | Jenis Sektor Ekonomi | `id`, `kode`, `nama` (Pertanian, Perikanan, Industri, Perdagangan, Layanan Jasa, dll), `urutan`                                     | lookup                                                    |
| `jenis_wisata`        | Jenis Wisata         | `id`, `kode`, `nama` (Perairan, Pegunungan, Budaya, Buatan, dll), `urutan`                                                          | lookup                                                    |
| `site_content_blocks` | CMS Section          | `id`, `tenant_id`, `halaman`, `tipe_blok` (`marketplace`/`ekonomi`/`wisata`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status` | `tenant_id`→`tenants.id`                                  |
| `site_navigation`     | Menu                 | `id`, `tenant_id`, `label`, `link`, `urutan`, `induk_id`                                                                            | `tenant_id`→`tenants.id`; `induk_id`→`site_navigation.id` |
| `feature_flags`       | Toggle Modul         | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                            | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI              | `id`, `tenant_id`, `key`, `locale`, `value`                                                                                         | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema                 | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                   | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas            | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                           | `tenant_id`→`tenants.id`                                  |
| `potensi_log`         | Log Audit            | `id`, `tenant_id`, `entity` (`bumdes`/`koperasi`/`umkm`/`produk`/`sektor`/`wisata`), `entity_id`, `aksi`, `aktor_id`, `created_at`  | `tenant_id`→`tenants.id`                                  |
| `domain_events`       | Event Bus            | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                       | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, NIK) ──► umkm (pemilik)
                                    │
lembaga_desa (Sistem Profile_Desa) ──► bumdes / koperasi_desa (profil + PageDetail)
                                    │
                                    └─► produk_marketplace (penjual: bumdes/koperasi/umkm)
                                            │
                                            ▼
                                  site_content_blocks (section Marketplace) · WA notifikasi

sektor_ekonomi (jenis: Pertanian/Perikanan/Industri/Perdagangan/Layanan Jasa)
        │  → IDM ekonomi · dashboard_agregat
        ▼
pariwisata (jenis: Perairan "Denda Seruni"/Pegunungan/Budaya) ──► wilayah_batas (geom, F9 peta)
        │
        ▼
domain_events ──► potensi_log (audit) · Beranda & Portal Publik
```

**Keterangan integrasi:** `bumdes`/`koperasi_desa` terhubung ke `lembaga_desa` (Sistem Profile*Desa) sehingga profil & PageDetail konsisten; `umkm` terhubung ke `penduduk` (Sistem Penduduk, Core Registry) tanpa duplikasi identitas; `produk_marketplace` mengalir ke section Marketplace beranda via `site_content_blocks`; `sektor_ekonomi` menyuplai skor IDM ekonomi & `dashboard_agregat`; `pariwisata` terpasang di peta (`wilayah_batas`, F9). Seluruh tampilan dibentuk `site*\*`+`i18n_strings` tanpa hardcode.
