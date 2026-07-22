**Diturunkan dari `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md`** — dokumen ini adalah pecahan sinkron yang memperluas §D5 (Login) dan §D6 (Dashboard Admin) sekaligus menambahkan modul **Pengelolaan Database System** yang belum ada di spesifikasi induk. Jika ada perbedaan di masa depan, `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md` yang berlaku.

---

# DESAIN LOGIN & DASHBOARD ADMIN — PUSAT KONFIGURASI & PENGELOLAAN DATABASE

Dokumen ini mendesain **halaman Login** dan **Dashboard Admin** sebagai _Single Control Plane_ (pusat kendali tunggal) untuk **seluruh** pengaturan, konfigurasi, dan pengelolaan sistem — mulai dari identitas visual, navigasi, konten, hak akses (RBAC), fitur modul, hingga **pengelolaan database system** (eksplorasi skema, pembuatan/perubahan tabel, kolom, indeks, relasi, serta peramban & edit data) langsung dari antarmuka web tanpa menyentuh kode atau SQL manual di terminal.

---

## 0. Tiga Prinsip Wajib (reuse dari §D0)

1. **Multi-Page, bukan SPA.** Login, dashboard, dan tiap seksi pengaturan adalah route server-rendered sendiri (`app/login/page.tsx`, `app/admin/dashboard/page.tsx`, `app/admin/pengaturan/*`, `app/admin/database/*`). Navigasi = full page load (RSC streaming).
2. **Mobile-First.** Semua breakpoint dari 360px ke atas; layout desktop adalah penambahan.
3. **Zero Hardcode.** Tidak ada teks, warna, menu, atau struktur yang ditulis tetap di komponen. Semua dari `tenant_theme_config`, `site_navigation`, `site_content_blocks`, `feature_flags`, `i18n_strings`, dan tabel konfigurasi lainnya.

### 0.1 Design Token (reuse §D2)

| Token                 | Hex       | Peran                                 |
| --------------------- | --------- | ------------------------------------- |
| `--color-primer`      | `#1A3263` | Header, tombol utama, identitas resmi |
| `--color-primer-dark` | `#0F0E0E` | Mode gelap, footer, teks utama        |
| `--color-aksen`       | `#FF9E20` | CTA, status positif, stempel digital  |
| `--color-netral-100`  | `#EAECF0` | Background terang, kartu, surface     |
| `--color-netral-300`  | `#BFC9D1` | Border, divider, placeholder          |
| `--color-netral-900`  | `#0F0E0E` | Teks utama, heading                   |

Font: **Poppins** (display) + **Helvetica** (body/data). Font surat tetap **Arial** via `tenant_theme_config.font_surat`.

---

## 1. HALAMAN LOGIN (ekspansi §D5)

### 1.1 Struktur (mobile-first, single column)

```
┌───────────────────────────────┐
│                                 │
│        [Logo Desa]              │  ← tenant_theme_config.logo_url
│     Kantor Desa Virtual         │
│     {nama_desa}                 │  ← site_settings.nama_resmi
│                                 │
│  ┌─────────────────────────┐   │
│  │ [Input: NIK / Email]     │   │
│  │ [Input: Kata Sandi]      │   │
│  │ [ ] Ingat saya           │   │
│  │ [Tombol: Masuk]          │   │
│  │ Lupa kata sandi? →       │   │
│  └─────────────────────────┘   │
│                                 │
│  ── atau ──                      │
│  [Masuk dengan OTP WhatsApp]    │  ← konsisten OTP F2
│                                 │
│  Belum punya akun? Daftar →     │
└───────────────────────────────┘
```

### 1.2 Dua jalur otentikasi (berbasis peran, bukan sistem terpisah)

| Jalur                | Untuk                              | Mekanisme                                                                                               |
| -------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **NIK + Kata Sandi** | Warga & admin/perangkat desa       | `pengguna.password_hash` (argon2id); warga dari `penduduk_mandiri`, admin dari `pengguna`↔`desa_pamong` |
| **OTP WhatsApp**     | Warga (konsisten dengan voting F2) | `wa_otp_session` → kode 6 digit → `penduduk.nomor_hp` terverifikasi                                     |

### 1.3 Aturan desain & keamanan

- **Label & teks dari `i18n_strings`** (`auth.login.title`, `auth.login.nik_label`, `auth.login.password_label`) — siap multi-bahasa tanpa ubah kode.
- **Redirect berbasis peran** (tidak hardcode satu tujuan):
  - Warga → `/beranda-warga`
  - Admin/perangkat desa → `/admin/dashboard`
  - Kades → `/admin/dashboard?highlight=tte-pending`
  - Superadmin platform → `/admin/dashboard?section=database`
- **Pesan error eksplisit, tidak vague**: `"NIK atau kata sandi tidak cocok. Coba lagi atau gunakan OTP WhatsApp."` — bukan `"Terjadi kesalahan."`
- **Brute-force guard**: lock 5 gagal → cooldown 15 menit + notifikasi WA ke nomor terdaftar.
- **Session**: cookie `HttpOnly` + `SameSite=Lax`, durasi dari `site_settings.session_timeout_menit` (default 480). "Ingat saya" → perpanjang 7 hari.
- **Audit**: setiap login gagal & berhasil dicatat di `pengaturan_log` (entity=`auth`, aksi=`login`, `aktor_id`, IP, user-agent).
- **Aksesibilitas**: `:focus-visible` ring, `prefers-reduced-motion` dihormati, label eksplisit (bukan placeholder-as-label), kontras WCAG AA.

---

## 2. DASHBOARD ADMIN — PUSAT KENDALI (ekspansi §D6)

### 2.1 Layout

```
Mobile (360–767px):                 Desktop (1024px+):
┌──────────────────┐                ┌────┬──────────────────────────┐
│ Header + ☰ menu  │                │Nav│ Header (breadcrumb)        │
├──────────────────┤                │bar│ ────────────────────────── │
│                    │                │   │                            │
│  Konten Dashboard  │                │   │   Konten Dashboard          │
│  (1 kolom)         │                │   │   (grid 2–3 kolom)          │
│                    │                │   │                            │
│ [Drawer seksi]     │                │   │                            │
└──────────────────┘                └────┴──────────────────────────┘
```

Sidebar admin (`app/admin/layout.tsx`) dirender dari `site_navigation` posisi=`admin` (CRUD di §3.4) — **bukan array hardcode**. Setiap item dicek `feature_flags` & RBAC sebelum render.

### 2.2 Beranda Dashboard (`/admin/dashboard`)

Kartu ringkasan (data dari `dashboard_agregat` + `domain_events`):

| Kartu                                                      | Sumber                              | Aksi                    |
| ---------------------------------------------------------- | ----------------------------------- | ----------------------- |
| Ringkasan operasional (surat pending, usulan, tagihan PBB) | `dashboard_agregat`                 | Link ke modul           |
| Skor IDM terkini + tren                                    | `idm_status_desa`, `idm_skor_cache` | `/admin/pengaturan/idm` |
| TTE menunggu (Kades)                                       | `surat_dokumen` status              | Highlight               |
| Aktivitas terbaru (event feed)                             | `domain_events` (10 terakhir)       | Detail                  |
| Kesehatan sistem & DB                                      | `db_migration_log`, `db_query_log`  | `/admin/database`       |
| Pengaturan cepat                                           | shortcut ke seksi §3                | —                       |

---

## 3. PUSAT PENGATURAN & KONFIGURASI (SEMUA LEWAT DASHBOARD)

Setiap seksi = **1 route sendiri** (multi-page), bukan tab JS tersembunyi. Pola form konsisten: simpan sebagai **draft** untuk perubahan berdampak publik → tombol **"Terapkan Perubahan"** eksplisit → **preview live** sebelum terap → audit ke `pengaturan_log`.

| Route                              | Konten                                                                                   | Tabel target                               |
| ---------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------ |
| `/admin/pengaturan/identitas`      | Nama desa, alamat, kontak, jam layanan, nomor WA resmi                                   | `site_settings`                            |
| `/admin/pengaturan/tema`           | Logo, favicon, warna primer/aksen (color picker + validasi kontras WCAG AA), preset font | `tenant_theme_config`                      |
| `/admin/pengaturan/navigasi`       | CRUD menu header/footer + admin, drag-to-reorder                                         | `site_navigation`                          |
| `/admin/pengaturan/konten-beranda` | CRUD section beranda (tambah/hapus/urutkan/edit blok)                                    | `site_content_blocks`                      |
| `/admin/pengaturan/modul`          | Toggle F1–F10 + modul pendukung, peringatan dampak                                       | `feature_flags`                            |
| `/admin/pengaturan/pengguna`       | Kelola akun admin & peran (RBAC)                                                         | `pengguna`, `peran`                        |
| `/admin/pengaturan/jenis-surat`    | CRUD jenis surat (template field)                                                        | `surat_jenis`                              |
| `/admin/pengaturan/idm`            | Override `idm_scoring_thresholds`, label `sumber_data`                                   | `idm_scoring_thresholds`, `idm_indicators` |
| `/admin/pengaturan/kepatuhan`      | Generate & unduh ekspor SISKEUDES/SIPADES                                                | `ekspor_kepatuhan`                         |
| `/admin/pengaturan/bahasa`         | Edit `i18n_strings` (label UI multi-bahasa)                                              | `i18n_strings`                             |
| `/admin/pengaturan/integrasi`      | Webhook, API key, koneksi WA Business                                                    | `site_integrations`                        |
| `/admin/pengaturan/notifikasi`     | Aturan notifikasi & reminder WA                                                          | `notifikasi_rule`                          |
| `/admin/media`                     | Media Library: unggah & kelola gambar/foto (crop, alt text)                              | `media_aset`                               |

### 3.1 Validasi & keamanan form

- Color picker menolak kombinasi gagal WCAG AA dengan pesan: _"Kontras teks putih di atas warna ini terlalu rendah, coba warna lebih gelap."_
- Perubahan `site_navigation`/`site_content_blocks`/`tenant_theme_config` → draft + preview, baru "Terapkan".
- Setiap simpan → `pengaturan_log` (entity, entity_id, aksi, field_lama JSONB, field_baru JSONB, aktor_id).

### 3.2 Media Library — Pusat Unggah Gambar/Foto

Agar tampilan website beragam (sesuai refactoring kolom gambar di `SKEMA_DATABASE_ERD.md` §C26), semua gambar diunggah & dikelola dari satu tempat: **Media Library** (`/admin/media`), bukan upload tersebar per form.

- **Upload & edit**: drag-drop banyak file, validasi tipe `image/webp|jpeg|png` & video `video/mp4`, max 2 MB, resize otomatis ke lebar ≤1600px (WebP), isi `alt_text` (aksesibilitas/SEO).
- **Sumber**: `media_aset` (lihat §C26.1). Setiap tabel hanya menyimpan URL (`foto_url`/`sampul_url`/`simbol_url`) yang merujuk ke `file_path` media.
- **Picker**: di semua form yang punya kolom gambar (profil desa, sektor ekonomi, pariwisata, aset, kegiatan, pembangunan, usulan, agenda, bencana, bidang tanah, objek pajak, call center, pengguna), admin memilih dari Media Library (bukan upload ulang).
- **Audit**: setiap unggah/hapus → `pengaturan_log` (entity=`media`) + event `media.diunggah` ke `domain_events`.
- **RBAC**: `admin_desa` & `superadmin` bisa unggah; warga tidak.

| Route                 | Fungsi                                                 |
| --------------------- | ------------------------------------------------------ |
| `/admin/media`        | Grid Media Library, upload, crop, edit alt_text, hapus |
| `/admin/media/picker` | Modal picker (dipanggil dari form kolom gambar)        |

---

## 4. PENGELOLAAN DATABASE SYSTEM (MODUL BARU — INTRI UTAMA)

> **Tujuan:** Perangkat desa/superadmin dapat **mengelola struktur & isi database langsung dari dashboard** — melihat skema, membuat/mengubah **tabel, kolom, indeks, relasi (FK)**, menjalankan **query terkendali**, meramban & mengedit data per baris, serta mengimpor/mengekspor — tanpa SQL manual di terminal. Semua operasi **teraudit** dan **terbatas RBAC**.

### 4.1 Prinsip keamanan & RBAC

- **Hanya `peran = superadmin` (atau `admin_desa` dengan flag `boleh_kelola_db`)** yang bisa akses `/admin/database/*`. Dicek di server, bukan disembunyikan CSS.
- **Tabel sistem inti dilindungi** (`tenants`, `penduduk`, `pengguna`, `domain_events`, `pengaturan_log`, tabel keuangan/fiskal): hanya **read + export**, tidak bisa drop/alter struktur dari UI (cegah kerusakan integritas). Daftar proteksi dari `db_table_meta.is_protected`.
- **Operasi destruktif** (DROP TABLE/COLUMN, TRUNCATE, DELETE tanpa WHERE) wajib **konfirmasi dua langkah + alasan** dan mencatat snapshot sebelum eksekusi.
- **Query console** default **read-only** (`SELECT`); mode tulis butuh toggle + validasi parser (dilarang `DROP DATABASE`, `ALTER ROLE`, `COPY PROGRAM`, komentar bertingkat berbahaya).
- Semua DDL/DML dari UI → dibungkus sebagai **migration** tercatat di `db_migration_log` (reversible bila memungkinkan).

### 4.2 Struktur route

| Route                               | Fungsi                                                                            |
| ----------------------------------- | --------------------------------------------------------------------------------- |
| `/admin/database`                   | Beranda: daftar tabel, statistik baris, kesehatan indeks, link cepat              |
| `/admin/database/schema`            | **Schema Explorer** — pohon tabel → kolom, tipe, NOT NULL, default, PK/FK, indeks |
| `/admin/database/tabel/[nama]`      | **Table Manager** — lihat struktur, tambah/hapus kolom, indeks, FK, constraint    |
| `/admin/database/tabel/[nama]/data` | **Data Browser** — tabel paginasi, filter, edit/insert/delete baris (audit)       |
| `/admin/database/buat-tabel`        | **Create Table Wizard** — buat tabel bisnis kustom lewat UI (tanpa SQL)           |
| `/admin/database/query`             | **Query Console** — editor SQL read-only + mode tulis terkendali                  |
| `/admin/database/migrasi`           | Riwayat migration & rollback                                                      |
| `/admin/database/impor-ekspor`      | Import CSV/JSON, ekspor tabel/query ke CSV/SQL                                    |

### 4.3 Schema Explorer (wireframe)

```
┌──────────────────────────────────────────────┐
│ SCHEMA EXPLORER            [Cari tabel…]       │
├──────────────┬───────────────────────────────┤
│ tenants      │ Kolom            Tipe     Null │
│ penduduk     │ ───────────────  ───────  ──── │
│ pengguna  ▸  │ id               UUID     PK   │
│ surat_jenis  │ tenant_id        UUID     FK→  │
│ ...          │ nama_jenis       VARCHAR  -    │
│              │ template_field[] TEXT[]   -    │
│              │ Indeks: idx_pengguna_tenant    │
│              │ FK: peran_id → peran.id        │
└──────────────┴───────────────────────────────┘
```

Data diambil dari introspeksi `information_schema` yang di-cache di `db_schema_cache` (di-refresh tombol "Segarkan Skema").

### 4.4 Table Manager & Create Table Wizard

Admin dapat:

- **Buat tabel kustom** (mis. `data_karang_taruna`) via wizard: isi nama tabel, tambah kolom (nama, tipe: TEXT/INT/NUMERIC/BOOL/DATE/UUID/JSONB/TIMESTAMPTZ, NOT NULL, default, PK, unique), tambah indeks, tambah FK ke tabel lain.
- **Tambah/hapus kolom** pada tabel kustom (dan kolom non-inti pada tabel standar bila diizinkan `db_table_meta.allow_alter`).
- **Tambah indeks / FK / constraint** via form, bukan SQL.
- Setiap aksi → `db_migration_log` + `pengaturan_log` (entity=`db_table`).

```sql
-- Contoh DDL yang dihasilkan wizard (otomatis, bukan ditulis user):
CREATE TABLE data_karang_taruna (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama VARCHAR(150) NOT NULL,
  jumlah_anggota INT DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_karang_taruna_tenant ON data_karang_taruna(tenant_id);
```

### 4.5 Data Browser (CRUD per baris, teraudit)

- Tabel paginasi (50 baris/halaman), filter by kolom, sort, pencarian.
- **Insert/Edit/Delete** baris → untuk tabel append-only (`surat_log_status`, `kepemilikan_*`) hanya insert; untuk tabel kustom bebas CRUD.
- Setiap write → `pengaturan_log` (entity=`db_row`, entity_id, aksi, field_lama/baru) + (bila relevan) `domain_events` agar worker rekalkulasi agregat.
- **Soft-delete**: tabel dengan `db_table_meta.soft_delete=true` menggunakan kolom `deleted_at`而非 `DELETE` fisik.

### 4.6 Query Console (terkendali)

```
┌──────────────────────────────────────────────┐
│ QUERY CONSOLE                                 │
│ [Mode: Read-only ▸]  [Jalankan]  [Ekspor CSV] │
│ ┌──────────────────────────────────────────┐ │
│ │ SELECT nama, jumlah_anggota               │ │
│ │ FROM data_karang_taruna                   │ │
│ │ WHERE tenant_id = current_tenant()        │ │
│ │   AND aktif = true LIMIT 100;             │ │
│ └──────────────────────────────────────────┘ │
│ Hasil: 12 baris · 84 ms                      │
└──────────────────────────────────────────────┘
```

- Parser memvalidasi: hanya `SELECT` di mode read-only; mode tulis mengizinkan `INSERT/UPDATE/DELETE` **dengan `WHERE tenant_id = current_tenant()` wajib** (isolasi multi-tenant dijamin). Dilarang `DROP/ALTER DATABASE/ROLE`, `COPY PROGRAM`, `pg_*` katalog mutasi.
- Tiap eksekusi → `db_query_log` (tenant_id, aktor_id, mode, query_hash, baris_terpengaruh, durasi_ms, status).

### 4.7 Impor / Ekspor

- **Impor**: upload CSV/JSON → mapping kolom otomatis → preview → validasi (tipe, FK, `tenant_id` disuntikkan) → insert batch (audit per batch).
- **Ekspor**: pilih tabel/query → unduh CSV atau SQL `INSERT` (untuk backup/restore antar-tenant).

### 4.8 Skema tabel pendukung modul database

Sesuai konvensi: `UUID PK`, `tenant_id` (untuk data per-desa), snake_case, JSONB, append-only untuk log.

```sql
-- Cache hasil introspeksi information_schema (di-refresh on demand)
CREATE TABLE db_schema_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  table_name VARCHAR(100) NOT NULL,
  columns JSONB NOT NULL,          -- [{name,type,not_null,default,pk,unique,fk→}]
  indexes JSONB NOT NULL DEFAULT '[]'::jsonb,
  refreshed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, table_name)
);

-- Metadata & perlindungan tiap tabel (UI-driven, bukan hardcode)
CREATE TABLE db_table_meta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  table_name VARCHAR(100) NOT NULL UNIQUE,
  display_name VARCHAR(120) NOT NULL,
  icon VARCHAR(40) DEFAULT 'table',
  group_name VARCHAR(60) DEFAULT 'Lainnya',
  is_protected BOOLEAN NOT NULL DEFAULT false,   -- true: core system, read/export only
  allow_alter BOOLEAN NOT NULL DEFAULT false,    -- boleh tambah/hapus kolom non-inti
  soft_delete BOOLEAN NOT NULL DEFAULT false,
  created_via_ui BOOLEAN NOT NULL DEFAULT false, -- true: tabel kustom dari wizard
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, table_name)
);

-- Log setiap migration DDL yang dihasilkan UI (reversible bila memungkinkan)
CREATE TABLE db_migration_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama_migration VARCHAR(160) NOT NULL,
  ddl_up TEXT NOT NULL,
  ddl_down TEXT,                    -- nullable bila irreversibel
  status VARCHAR(20) NOT NULL CHECK (status IN ('applied','rolled_back','failed')),
  aktor_id UUID REFERENCES pengguna(id),
  alasan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Audit setiap eksekusi query console
CREATE TABLE db_query_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  aktor_id UUID REFERENCES pengguna(id),
  mode VARCHAR(10) NOT NULL CHECK (mode IN ('read','write')),
  query_hash CHAR(64) NOT NULL,
  query_text TEXT NOT NULL,
  baris_terpengaruh INT NOT NULL DEFAULT 0,
  durasi_ms INT NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('success','blocked','error')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Log setiap edit baris via Data Browser (append-only)
CREATE TABLE db_row_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  table_name VARCHAR(100) NOT NULL,
  row_id UUID NOT NULL,
  aksi VARCHAR(10) NOT NULL CHECK (aksi IN ('insert','update','delete','soft_delete')),
  field_lama JSONB,
  field_baru JSONB,
  aktor_id UUID REFERENCES pengguna(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

> Catatan: `db_schema_cache`, `db_migration_log`, `db_query_log`, `db_row_log` bersifat **global per tenant** (data diisolasi `tenant_id`). `db_table_meta` memungkinkan admin menamai & mengelompokkan tabel tanpa hardcode di kode.

### 4.9 Integrasi event

| Event                 | Sumber        | Dampak                                                                                      |
| --------------------- | ------------- | ------------------------------------------------------------------------------------------- |
| `db.tabel.dibuat`     | Table Wizard  | `db_table_meta` + `db_migration_log` + `pengaturan_log`                                     |
| `db.kolom.diubah`     | Table Manager | Re-introspeksi `db_schema_cache`                                                            |
| `db.baris.diubah`     | Data Browser  | `db_row_log` + (bila fakta mentah) `domain_events` → worker rekalkulasi `dashboard_agregat` |
| `db.query.dijalankan` | Query Console | `db_query_log` (audit)                                                                      |

---

## 5. STRUKTUR ROUTING LENGKAP (Next.js App Router)

```
app/
├── login/page.tsx                      ← §1, layout khusus tanpa header/footer publik
├── admin/
│   ├── layout.tsx                      ← Sidebar dari site_navigation(posisi='admin'), cek RBAC+feature_flags
│   ├── dashboard/page.tsx              ← §2.2
│   ├── media/                          ← §3.2 Media Library
│   │   ├── page.tsx                    ← grid Media Library
│   │   └── picker/page.tsx             ← modal picker (dipanggil form kolom gambar)
│   ├── pengaturan/
│   │   ├── identitas/page.tsx          ← §3
│   │   ├── tema/page.tsx
│   │   ├── navigasi/page.tsx
│   │   ├── konten-beranda/page.tsx
│   │   ├── modul/page.tsx
│   │   ├── pengguna/page.tsx
│   │   ├── jenis-surat/page.tsx
│   │   ├── idm/page.tsx
│   │   ├── kepatuhan/page.tsx
│   │   ├── bahasa/page.tsx
│   │   ├── integrasi/page.tsx
│   │   └── notifikasi/page.tsx
│   └── database/                       ← §4 (MODUL BARU)
│       ├── page.tsx                    ← beranda DB
│       ├── schema/page.tsx             ← Schema Explorer
│       ├── tabel/[nama]/page.tsx       ← Table Manager
│       ├── tabel/[nama]/data/page.tsx  ← Data Browser
│       ├── buat-tabel/page.tsx         ← Create Table Wizard
│       ├── query/page.tsx              ← Query Console
│       ├── migrasi/page.tsx
│       └── impor-ekspor/page.tsx
```

---

## 6. KESIMPULAN

Dengan desain ini, **Login** mengamankan akses berbasis peran, dan **Dashboard Admin** menjadi satu-satunya pintu untuk **seluruh** konfigurasi sistem: identitas, tema, navigasi, konten, fitur, RBAC, bahasa, integrasi, notifikasi, **Media Library (pusat gambar/foto)** — **serta pengelolaan database system** (skema, tabel, kolom, indeks, relasi, data, query, migrasi, impor/ekspor) yang sebelumnya tidak tercakup. Semua operasi mengikuti prinsip _zero-hardcode_, _mobile-first_, _multi-page_, audit penuh (`pengaturan_log`, `db_*_log`, `domain_events`), dan isolasi multi-tenant (`tenant_id`), sehingga perangkat desa dapat mengelola sistem end-to-end tanpa menyentuh kode. Kolom gambar/foto pada modul terkait (lihat `SKEMA_DATABASE_ERD.md` §C26) diisi lewat Media Library sehingga tampilan portal publik menjadi lebih beragam & variatif.
