# Sistem Informasi Desa

Sistem Informasi Desa = **Portal Publik** gaya news-portal (rujukan: Viva.co.id) yang menyajikan Berita, Agenda Desa, Galeri, dan Produk Hukum. Diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, zero-hardcode, event-driven). Semua konten berstatus `draft` → `publish` dengan preview sebelum tayang. **Sistem ini adalah lapisan presentasi akhir (kesimpulan) yang membaca `dashboard_agregat` dari seluruh modul operasional** — statistik real-time, peta, dan pengumuman otomatis mengalir ke sini tanpa input manual.

## 1. Ringkasan Sistem Informasi (On Point)

- **Peran:** `artikel_desa` + `agenda_kegiatan` + `galeri_desa` + `produk_hukum` = _Single Source of Truth_ konten publik desa.
- **Kanal:** Web admin (perangkat desa) untuk publish; Portal Publik (read-only) + WA reminder untuk warga.
- **Berita:** Kategori relevan (Pengumuman, Pembangunan, Sosial, Ekonomi, Kesehatan, Pendidikan, dll) — terintegrasi ke section Beranda.
- **Agenda Desa:** Kalender event (manual admin + otomatis dari Musdes/Posyandu/Pemilihan/Bencana); warga bisa langganan reminder WA.
- **Galeri:** Album kegiatan desa (foto/video) — tampilan visual beranda.
- **Produk Hukum:** Preview + Download; jenis SK/Perdes/Perkades/lainnya; sumber Desa/Kabupaten/Provinsi/Pusat — transparansi hukum.
- **Statistik Real-Time:** Membaca `dashboard_agregat` (dari Pembangunan, Stunting, Sosial/Bansos, Bencana, Pemilu, Analisis, Suplesi, PBB, Posyandu, Potensi) — **bukan angka hardcode**.
- **Keamanan:** RBAC (admin CRUD, warga read-only); `draft` → preview → `publish`; audit `informasi_log` (append-only).

## 2. Workflow lengkap sistem Informasi Komplit

```
[Admin] Publish BERITA
        │  → artikel_desa (status: DRAFT)
        │  → pilih kategori_berita, tulis isi (HTML), unggah gambar
        ▼
   Preview → [Admin] "Terbitkan" ──► status: PUBLISH
        │
        ▼
[Admin] Buat AGENDA DESA
        │  → agenda_kegiatan (jenis: umum / musdes / posyandu / pemilu / bencana)
        │  → musdes & posyandu & pemilihan & bencana otomatis (dibuat_otomatis=true)
        │  → warga subscribe reminder WA → agenda_subscriber (by nomor_hp + jenis_agenda[])
        ▼
[Admin] Unggah GALERI
        │  → galeri_desa (pilih album_galeri, judul, file)
        ▼
[Admin] Unggah PRODUK HUKUM
        │  → produk_hukum (jenis, nomor, tahun, tentang, sumber: desa/kab/prov/pusat)
        │  → wajib ada preview_path (lihat dulu) + file_path (download)
        ▼
   Preview → [Admin] "Terbitkan" ──► status: PUBLISH
        │
        ▼
Portal Publik: Beranda (section berita/agenda/galeri/STATISTIK REAL-TIME/peta) · /berita · /agenda-desa
· /galeri · /produk-hukum (preview → download) · /statistik-desa · /peta-desa
```

**Aturan kritikal:**

- Semua konten wajib `draft` → **preview** → `publish` — tidak ada publish tanpa preview (mencegah salah tayang).
- `produk_hukum` wajib punya `preview_path` (viewer PDF) dan `file_path` (download); warga lihat preview dulu, download terpisah.
- `sumber` produk hukum harus eksplisit (desa/kabupaten/provinsi/pusat) — transparansi asal dokumen.
- Agenda otomatis (Musdes/Posyandu/Pemilihan/Bencana) tampil read-only di admin; hanya `umum` yang bisa diedit admin.
- **Statistik di Beranda/Statistik Desa diambil dari `dashboard_agregat`** (worker, fakta turunan) — tidak ada angka statis di kode.
- Data sensitif (NIK, identitas individu) dilarang di konten publik.

**Event & integrasi:**

| Event                       | Sumber               | Dampak                                              |
| --------------------------- | -------------------- | --------------------------------------------------- |
| `informasi.berita.terbit`   | Publish artikel      | Section Berita Beranda, notifikasi WA (info_instan) |
| `agenda.dibuat`             | Buat agenda          | Kalender Desa, reminder ke `agenda_subscriber`      |
| `galeri.terbit`             | Publish galeri       | Section Galeri Beranda                              |
| `produk_hukum.terbit`       | Publish produk hukum | Halaman Transparansi Hukum, arsip peraturan         |
| `musdes.usulan.ditetapkan`  | Modul Voting         | Auto-insert agenda musdes (F2→F10)                  |
| `pembangunan.selesai`       | Sistem Pembangunan   | Berita progres & titik peta pembangunan             |
| `bansos.penyaluran.dicatat` | Sistem Sosial        | Berita penyaluran bansos                            |
| `stunting.dievaluasi`       | Sistem Stunting      | Pengumuman gizi & peta titik rawan stunting         |
| `pemilihan.selesai`         | Sistem Pemilu        | Pengumuman hasil & partisipasi                      |
| `bencana.alert`             | Sistem Bencana       | Perintah siaga/evakuasi + peta titik bencana        |
| `pariwisata.diterbitkan`    | Sistem Potensi       | Section Potensi/ Wisata Beranda                     |
| `analisis.selesai`          | Sistem Analisis      | Publikasi hasil analisis desa                       |

## 3. Tabel Jenis Informasi (Viva.co.id style + Seruni - Sistem Repository Unifikasi Informasi)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)          | Ekuivalen Portal   | Kolom inti                                                                                                                                                                                 | Referensi FK                          |
| ----------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------- |
| `artikel_desa`          | Berita (Viva)      | `id`, `tenant_id`, `judul`, `isi` (HTML), `kategori_id`, `tanggal`, `status` (`draft`/`publish`), `gambar`, `penulis`, `dilihat`                                                           | `kategori_id`→`kategori_berita.id`    |
| `kategori_berita`       | Kategori Berita    | `id`, `nama` (Pengumuman, Pembangunan, Sosial, Ekonomi, Kesehatan, Pendidikan, Olahraga, dll), `urutan`, `aktif`                                                                           | lookup                                |
| `agenda_kegiatan`       | Agenda/Kalender    | `id`, `tenant_id`, `judul`, `deskripsi`, `tanggal_mulai`, `tanggal_selesai`, `lokasi`, `jenis` (`umum`/`musdes`/`posyandu`/`pemilu`/`bencana`), `dibuat_otomatis` (bool)                   | `tenant_id`→`tenants.id`              |
| `galeri_desa`           | Galeri             | `id`, `tenant_id`, `album_id`, `judul`, `file_path`, `tipe` (`foto`/`video`), `tanggal`, `deskripsi`                                                                                       | `album_id`→`album_galeri.id`          |
| `album_galeri`          | Album              | `id`, `tenant_id`, `nama`, `urutan`, `aktif`                                                                                                                                               | lookup                                |
| `produk_hukum`          | Produk Hukum       | `id`, `tenant_id`, `jenis_id`, `nomor`, `tahun`, `tentang` (judul), `sumber` (`desa`/`kabupaten`/`provinsi`/`pusat`), `preview_path`, `file_path`, `tanggal`, `status` (`draft`/`publish`) | `jenis_id`→`kategori_produk_hukum.id` |
| `kategori_produk_hukum` | Jenis Produk Hukum | `id`, `nama` (Perdes, Perkades, SK Kades, Surat Edaran, Instruksi, lainnya), `urutan`                                                                                                      | lookup                                |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen Portal | Kolom inti                                                                                                                                       | Referensi FK                                              |
| --------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------- |
| `site_content_blocks` | CMS Section      | `id`, `tenant_id`, `halaman`, `tipe_blok` (`hero`/`statistik`/`berita`/`agenda`/`galeri`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status` | `tenant_id`→`tenants.id`                                  |
| `site_navigation`     | Menu             | `id`, `tenant_id`, `label`, `link`, `urutan`, `induk_id`                                                                                         | `tenant_id`→`tenants.id`; `induk_id`→`site_navigation.id` |
| `feature_flags`       | Toggle Modul     | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                         | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI          | `id`, `tenant_id`, `key`, `locale`, `value`                                                                                                      | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema             | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas        | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                        | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM  | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori`, `metrik_key`, `metrik_value`, `periode`                                          | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `peta_objek`          | GIS (F9)         | `id`, `tenant_id`, `layer_id`→`peta_layer.id`, `ref_tabel`, `ref_id`, `nama`, `geom`, `keterangan`                                               | `layer_id`→`peta_layer.id`                                |
| `informasi_log`       | Log Audit        | `id`, `tenant_id`, `entity` (`artikel`/`agenda`/`galeri`/`produk_hukum`), `entity_id`, `aksi`, `aktor_id`, `created_at`                          | `tenant_id`→`tenants.id`                                  |
| `domain_events`       | Event Bus        | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                    | `tenant_id`→`tenants.id`                                  |

> **Catatan `agenda_subscriber`:** berlangganan reminder WA berbasis `nomor_hp` + `jenis_agenda[]` (bukan per `agenda_id`), PK `(tenant_id, nomor_hp)` — konsisten dengan `SKEMA_DATABASE_ERD.md` §C9. Event `agenda.dibuat` mengirim WA ke subscriber yang cocok jenis_agenda-nya.

### 3.3 Diagram integrasi

```
site_settings / tenant_theme_config / site_navigation / i18n_strings / feature_flags
        │  (konfigurasi zero-hardcode)
        ▼
site_content_blocks (section Beranda) ◄──┬── artikel_desa (Berita, by kategori_berita)
                                         ├── agenda_kegiatan (Agenda, + agenda_subscriber WA by jenis_agenda[])
                                         ├── galeri_desa (Galeri, by album_galeri)
                                         ├── produk_hukum (Hukum, by kategori_produk_hukum)
                                         ├── dashboard_agregat (STATISTIK REAL-TIME dari semua modul)
                                         └── peta_objek (PETA sebaran dari semua modul)
                              │
              domain_events ──► informasi_log (audit) · notifikasi WA
```

**Keterangan integrasi:** Seluruh tampilan publik dibentuk `site_*` + `i18n_strings` tanpa hardcode; keempat jenis konten (Berita, Agenda, Galeri, Produk Hukum) mengalir ke section Beranda via `site_content_blocks` dan memicu `domain_events` → notifikasi WA (`info_instan`) serta audit `informasi_log`. **Statistik Real-Time dan Peta di Portal dibaca dari `dashboard_agregat` & `peta_objek`** yang diisi worker dari seluruh modul (Pembangunan, Stunting, Sosial/Bansos, Bencana, Pemilu, Analisis, Suplesi, PBB, Posyandu, Potensi, Peta) — sehingga **satu data masuk di modul mana pun langsung tercermin di kesimpulan portal publik**. Agenda otomatis terisi dari Musdes/Posyandu/Pemilihan/Bencana (F2→F10), menjaga portal sebagai lapisan presentasi tunggal di atas fakta operasional desa.
