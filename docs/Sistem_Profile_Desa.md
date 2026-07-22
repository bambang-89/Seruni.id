# Sistem Profile Desa

Profil Desa = **Identitas & Konfigurasi Desa** (Single Source of Truth untuk tampilan publik, batas wilayah, perangkat & lembaga, serta pengaturan portal). Merujuk OpenSID (`tweb_desa`, `tweb_wil_clusterdesa`, `tweb_desa_pamong`, `tweb_grup`, `tweb_artikel`, `tweb_dokumen`) diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`).

## 1. Ringkasan Sistem Profile_Desa (On Point)

- **Peran:** `profil_desa` + `tenants` = _Single Source of Truth_ identitas desa (nama, kode, wilayah administrasi, sejarah, visi-misi, topografi).
- **Kanal:** Web admin (perangkat desa) untuk setup & publikasi; Portal Publik (read-only) untuk warga.
- **Wilayah:** Provinsi/Kabupaten/Kecamatan/Desa diisi dari **API Wilayah** (Kemendagri) saat onboarding → `kode_desa` otomatis; Dusun/RT/RW dikelola lokal di `wilayah_batas` (poligon, self-referencing `parent_id`).
- **Perangkat & Lembaga:** `desa_pamong` (FK `penduduk`) & `lembaga_desa` + `anggota_lembaga` — kolom lengkap (NIK, Nama, TTL, gender, Jabatan, No. SK, Tgl Pengangkatan, Tgl Berakhir, Foto) + **PageDetail** tiap perangkat/lembaga; lembaga bisa **ditambahkan bebas** (bukan cuma dari kategori) karena tiap desa berbeda. Terintegrasi ke TTE surat, IDM, peta.
- **Zero Hardcode:** Semua teks/tema/navigasi/section dari DB (`site_settings`, `tenant_theme_config`, `site_content_blocks`, `site_navigation`, `feature_flags`, `i18n_strings`) — ganti nama desa/logo tanpa redeploy.
- **Keamanan:** RBAC (admin CRUD, warga read-only); `kode_desa` immutable (kunci dari API); perubahan konten berstatus draft → "Terapkan Perubahan" eksplisit + preview.

## 2. Workflow lengkap sistem Profile_Desa Komplit

```
[Admin] Onboarding — Pilih Prov/Kab/Kec/Desa dari API Wilayah
        │  → auto-isi kode_desa, nama, alamat kantor (dari API)
        ▼
1. Isi Identitas & Tentang Desa (sejarah, visi, misi, deskripsi)
        │  → profil_desa (status: draft)
        ▼
2. Isi Topografi (luas, batas, ketinggian, curah hujan, orbitasi)
        │  → topografi_desa
        ▼
3. Kelola Wilayah Lokal — gambar poligon Dusun/RT/RW
        │  → wilayah_batas (parent_id: RT→RW→Dusun)
        ▼
4. Daftarkan Perangkat Desa (pilih dari penduduk by NIK → auto NIK, Nama, Tempat Lahir, Tgl Lahir, gender)
        │  → isi Jabatan, No. SK, Tgl Pengangkatan, Tgl Berakhir Jabatan, Foto
        │  → desa_pamong (FK penduduk_id, jabatan_id) + slug + page_detail (profil publik)
        ▼
5. Daftarkan Lembaga Desa — bisa TAMBAH LEMBAGA BARU (nama bebas, bukan cuma dari kategori)
        │  → isi profil lembaga (deskripsi, alamat, kontak, foto, slug + page_detail)
        │  → tambah Pengurus & Anggota (NIK, Nama, TTL, gender, Jabatan di lembaga, No. Anggota, Tgl Pengangkatan, Tgl Berakhir, Foto)
        │  → lembaga_desa + anggota_lembaga
        ▼
6. Atur Tampilan Publik (tema, nav, section, berita, dokumen)
        │  → site_settings, tenant_theme_config, site_content_blocks (draft)
        │  → artikel_desa, dokumen_desa, galeri_desa
        ▼
7. Preview → [Admin] "Terapkan Perubahan" ──► status PUBLISH
        │
        ▼
Portal Publik & Peta Desa menampilkan profil terkini (read-only)
```

**Aturan kritikal:**

- `kode_desa` **immutable** — di-lock dari API Wilayah saat onboarding, tidak bisa diedit manual (menjaga konsistensi subdomain & isolasi tenant).
- `wilayah_batas` self-referencing via `parent_id` — **satu-satunya** tabel wilayah; RT harus dalam RW, RW dalam Dusun (validasi jenis).
- `desa_pamong.penduduk_id` → `penduduk` (NIK unik); perangkat = calon penanda tangan TTE surat (`surat_dokumen.ttd_oleh_penduduk_id`).
- Perubahan konten publik (tema/nav/section) **wajib draft + preview + Terapkan** — bukan auto-save.
- Data sensitif perangkat (NIK penuh) hanya di admin; publik hanya nama & jabatan.
- `lembaga_desa.nama` **bebas diinput admin** (bukan terbatas `kategori_grup`) — tiap desa punya lembaga berbeda; `kategori_id` opsional untuk pengelompokan.
- Setiap `desa_pamong` & `lembaga_desa` punya `slug` + `page_detail` → halaman profil publik (PageDetail) read-only.

**Event & integrasi:**

| Event               | Sumber                                | Dampak ke modul lain                                                |
| ------------------- | ------------------------------------- | ------------------------------------------------------------------- |
| `profil.berubah`    | Edit identitas/tentang desa           | `site_content_blocks` (hero), statistik, footer portal              |
| `wilayah.berubah`   | Edit `wilayah_batas`                  | Peta publik (F9), agregat dusun/RT/RW (IDM, Posyandu)               |
| `perangkat.berubah` | CRUD `desa_pamong`                    | Daftar penanda tangan TTE (F1), IDM (indikator pemerintahan)        |
| `lembaga.berubah`   | CRUD `lembaga_desa`                   | Peta & direktori lembaga publik, surat keaktifan organisasi (220.0) |
| `konten.terbit`     | `artikel_desa`/`dokumen_desa` PUBLISH | Beranda section berita/pengumuman                                   |

## 3. Tabel Jenis Profile_Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)    | Ekuivalen OpenSID          | Kolom inti                                                                                                                                                                                                                                                             | Referensi FK                                                                             |
| ----------------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `tenants`         | `tweb_desa` (sebagian)     | `id`, `nama_desa`, `subdomain` (UQ), `kode_desa` (UQ, immutable), `kecamatan`, `kabupaten`, `provinsi`, `aktif`                                                                                                                                                        | — (root tenant)                                                                          |
| `profil_desa`     | `tweb_desa` (sejarah/visi) | `tenant_id` (PK), `sejarah`, `visi`, `misi`, `deskripsi`, `alamat_kantor`, `email`, `telepon`, `nama_kades`, `nama_sekdes`                                                                                                                                             | `tenant_id`→`tenants.id`                                                                 |
| `wilayah_batas`   | `tweb_wil_clusterdesa`     | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom` (POLYGON), `parent_id`                                                                                                                                                                                  | `parent_id`→`wilayah_batas.id` (self)                                                    |
| `topografi_desa`  | `tweb_desa` (luas/batas)   | `tenant_id` (PK), `luas_wilayah`, `batas_utara`/`selatan`/`timur`/`barat`, `ketinggian`, `curah_hujan`, `orbitasi`, `lintang`, `bujur`                                                                                                                                 | `tenant_id`→`tenants.id`                                                                 |
| `desa_pamong`     | `tweb_desa_pamong`         | `id`, `tenant_id`, `penduduk_id`, `jabatan_id`, `nik`, `nama_lengkap`, `tempat_lahir`, `tanggal_lahir`, `gender`, `no_sk`, `tgl_pengangkatan`, `tgl_berakhir`, `foto`, `slug` (PageDetail), `page_detail` (JSONB), `urut`, `status` (`aktif`/`nonaktif`), `ttd` (bool) | `penduduk_id`→`penduduk.id` (auto NIK/Nama/TTL/gender); `jabatan_id`→`jabatan_pamong.id` |
| `lembaga_desa`    | `tweb_grup`                | `id`, `tenant_id`, `slug` (UQ, PageDetail), `nama` (bebas), `kategori_id` (nullable), `deskripsi`, `alamat`, `kontak`, `foto`, `page_detail` (JSONB), `aktif`                                                                                                          | `kategori_id`→`kategori_grup.id` (opsional)                                              |
| `anggota_lembaga` | `tweb_anggota_grup`        | `id`, `lembaga_id`, `penduduk_id`, `nik`, `nama_lengkap`, `tempat_lahir`, `tanggal_lahir`, `gender`, `jabatan` (pengurus/anggota), `no_anggota`, `tgl_pengangkatan`, `tgl_berakhir`, `foto`, `keterangan`                                                              | `lembaga_id`→`lembaga_desa.id`; `penduduk_id`→`penduduk.id` (auto NIK/Nama/TTL/gender)   |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen OpenSID           | Kolom inti                                                                                                                                                                                                                                                              | Referensi FK                                                                                 |
| --------------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `site_settings`       | `config` desa               | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                                                                                                                                               | `tenant_id`→`tenants.id`                                                                     |
| `tenant_theme_config` | —                           | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                                                                                                                                       | `tenant_id`→`tenants.id`                                                                     |
| `site_content_blocks` | `tweb_artikel` (section)    | `id`, `tenant_id`, `halaman`, `tipe_blok` (`hero`/`statistik`/`berita`/`layanan`/`peta`/`testimoni`), `urutan`, `konten` (JSONB), `status` (`draft`/`publish`)                                                                                                          | `tenant_id`→`tenants.id`                                                                     |
| `site_navigation`     | —                           | `id`, `tenant_id`, `label`, `link`, `urutan`, `induk_id`                                                                                                                                                                                                                | `tenant_id`→`tenants.id`; `induk_id`→`site_navigation.id`                                    |
| `feature_flags`       | —                           | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                                                                                                                                                | `tenant_id`→`tenants.id`                                                                     |
| `i18n_strings`        | —                           | `id`, `tenant_id`, `key`, `locale`, `value`                                                                                                                                                                                                                             | `tenant_id`→`tenants.id`                                                                     |
| `jabatan_pamong`      | `ref_jabatan`               | `id`, `kode`, `nama` (Kades, Sekdes, Kaur, Kasi, Kadus, dll), `urutan`                                                                                                                                                                                                  | lookup                                                                                       |
| `kategori_grup`       | `tweb_grup_kategori`        | `id`, `nama` (PKK, BPD, Karang Taruna, LPMD, dll), `urutan`                                                                                                                                                                                                             | lookup                                                                                       |
| `artikel_desa`        | `tweb_artikel`              | `id`, `tenant_id`, `judul`, `isi` (HTML), `kategori` (`berita`/`pengumuman`), `tanggal`, `status` (`draft`/`publish`), `gambar`                                                                                                                                         | `tenant_id`→`tenants.id`                                                                     |
| `dokumen_desa`        | `tweb_dokumen`              | `id`, `tenant_id`, `nama`, `kategori`, `file_path`, `tanggal`, `status`                                                                                                                                                                                                 | `tenant_id`→`tenants.id`                                                                     |
| `galeri_desa`         | `tweb_gallery`/`tweb_album` | `id`, `tenant_id`, `album`, `judul`, `file_path`, `tanggal`                                                                                                                                                                                                             | `tenant_id`→`tenants.id`                                                                     |
| `pengaduan_desa`      | `tweb_pengaduan`            | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `kategori_id`→`pengaduan_kategori.id`, `subjek`, `isi`, `lokasi`, `bukti_path` (nullable), `prioritas` (`rendah`/`sedang`/`tinggi`/`kritis`), `status` (`baru`/`proses`/`selesai`), `tanggal`, `tgl_selesai` (nullable) | `tenant_id`→`tenants.id`; `penduduk_id`→`penduduk.id`; `kategori_id`→`pengaduan_kategori.id` |
| `ref_wilayah_api`     | API Kemendagri              | `kode` (PK), `nama`, `jenis` (`prov`/`kab`/`kec`/`desa`), `parent_kode`, `kode_pos`                                                                                                                                                                                     | `parent_kode`→`ref_wilayah_api.kode` (sync API)                                              |

### 3.3 Diagram integrasi

```
ref_wilayah_api (API Kemendagri)          tenants (kode_desa immutable)
        │ sinkron onboarding                    │ 1
        ▼                                        ▼
wilayah_batas (dusun/rt/rw, lokal) ──► profil_desa / topografi_desa
        │                                        │
        │                                        ▼
        │                              site_settings / tenant_theme_config
        │                                        │
        ▼                                        ▼
   peta publik (F9) ◄── desa_pamong ──► surat_dokumen (TTE) · IDM
        │                     │
        │                     ▼
        │              lembaga_desa + anggota_lembaga ──► direktori & surat 220.0
        ▼
site_content_blocks / artikel_desa / dokumen_desa ──► Beranda & Portal Publik
```

**Keterangan integrasi:** `tenants` mengunci identitas dari API Wilayah; `wilayah_batas` melengkapi batas hingga RT/RW untuk peta & agregat; `desa_pamong` menjembatani ke penanda tangan surat (F1) dan skor IDM; `lembaga_desa` mendukung direktori publik & surat keaktifan organisasi; `pengaduan_desa` (layanan aduan warga) diperkaya skemanya di Sistem Service Center (kategori & prioritas); seluruh tampilan publik dibentuk `site_*` + `i18n_strings` tanpa hardcode.

### 3.4 Halaman Detail (PageDetail) Perangkat & Lembaga

Setiap `desa_pamong` dan `lembaga_desa` memiliki `slug` unik + `page_detail` (JSONB) yang menampilkan profil publik **read-only**:

- **Perangkat Desa (PageDetail):** Nama Lengkap, Jabatan, Foto, No. SK, Tgl Pengangkatan, Tgl Berakhir Jabatan, ringkas tugas (`page_detail`).
- **Lembaga Desa (PageDetail):** Nama lembaga, deskripsi, alamat, kontak, Foto/logo, daftar Pengurus & Anggota (NIK disamarkan di publik), dokumen/kegiatan terkait.

> Publik hanya melihat metadata; NIK penuh & data sensitif anggota disembunyikan (privasi berlapis). PageDetail di-render dari `site_content_blocks` (tipe `profil`) tanpa hardcode.

**Integrasi tabel induk ↔ pendukung:**

```
penduduk (NIK, Nama, TTL, gender) ──┐
                                     ├─► desa_pamong (perangkat) ──► slug + page_detail
jabatan_pamong (lookup) ────────────┘              │
                                                    └─► surat_dokumen (TTE) · IDM · direktori publik

penduduk (NIK, Nama, TTL, gender) ──┐
                                     ├─► anggota_lembaga ──► lembaga_desa (nama bebas)
kategori_grup (opsional) ───────────┘                       │
                                                              └─► slug + page_detail ──► direktori & surat 220.0
```
