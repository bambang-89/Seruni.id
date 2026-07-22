# DESAIN FRONTEND — Kantor Desa Virtual (DESAKU)
Multi-Page Architecture · Mobile-First · Zero Hardcode · Referensi presisi untuk Claude Code

---

## 0. Tiga Prinsip Wajib

1. **Multi-Page, bukan SPA.** Setiap halaman punya route server-rendered sendiri (Next.js App Router `app/(public)/page.tsx`, `app/login/page.tsx`, `app/admin/pengaturan/page.tsx`, dst). Navigasi antar-halaman adalah *full page load* yang dioptimalkan (RSC streaming), bukan client-side router tunggal yang menyamar jadi banyak "halaman". Ini penting untuk SEO portal publik & performa di HP low-end warga desa.
2. **Mobile-First.** Semua breakpoint didesain dari 360px ke atas. Layout desktop adalah *penambahan*, bukan penyusutan dari desktop.
3. **Zero Hardcode.** Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen. Semua berasal dari config/database (lihat §1). Mengganti nama desa, logo, warna tema, atau urutan section beranda **tidak boleh butuh redeploy kode**.

---

## 1. Arsitektur "Zero Hardcode"

### 1.1 Sumber kebenaran konten
```
tenant_theme_config      → warna, logo, favicon, font pilihan (dari 2-3 preset resmi)
site_content_blocks      → isi tiap section beranda (tipe, urutan, JSON konten)
site_navigation          → menu header/footer, urutan, label, link (internal/eksternal)
site_settings            → nama resmi desa, alamat kantor, jam layanan, kontak, nomor WA resmi terverifikasi
feature_flags            → modul mana yang aktif per tenant (F1-F6 bisa dinyalakan/dimatikan)
i18n_strings             → semua label UI (default id-ID, siap tambah bahasa daerah/EN)
```

### 1.2 Skema pendukung (ringkas)
```sql
CREATE TABLE tenant_theme_config (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  logo_url TEXT, favicon_url TEXT,
  warna_primer VARCHAR(7), warna_aksen VARCHAR(7), warna_netral VARCHAR(7),
  preset_font VARCHAR(30) NOT NULL DEFAULT 'default'  -- lihat §2.2, terbatas preset resmi
);

CREATE TABLE site_content_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  halaman VARCHAR(30) NOT NULL,        -- 'beranda', 'profil-desa', dst
  tipe_blok VARCHAR(30) NOT NULL,      -- 'hero','statistik','berita','layanan_unggulan','peta','testimoni'
  urutan INT NOT NULL,
  konten JSONB NOT NULL,               -- struktur bebas sesuai tipe_blok, divalidasi Zod schema per tipe
  aktif BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  posisi VARCHAR(10) NOT NULL CHECK (posisi IN ('header','footer')),
  label VARCHAR(60) NOT NULL, href TEXT NOT NULL,
  urutan INT NOT NULL, parent_id UUID REFERENCES site_navigation(id)  -- dukung submenu
);

CREATE TABLE feature_flags (
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  fitur_kode VARCHAR(30) NOT NULL,     -- 'F1_SURAT','F2_USULAN','F5_PBB', dst
  aktif BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fitur_kode)
);

-- Tambahan sintesis: nomor WA resmi terverifikasi pada site_settings
ALTER TABLE site_settings
  ADD COLUMN nomor_wa_resmi VARCHAR(20),
  ADD COLUMN wa_business_verified BOOLEAN NOT NULL DEFAULT false;
```

### 1.3 Aturan render
- Setiap komponen section (`<HeroBlock>`, `<StatistikBlock>`, dst) menerima **props dari `konten` JSONB**, tervalidasi skema Zod per tipe — bukan menerima teks langsung ditulis di JSX.
- Navigasi header/footer di-render dari query `site_navigation`, bukan array tetap di komponen `<Header>`.
- Modul yang `feature_flags.aktif = false` **tidak muncul** di navigasi maupun dashboard admin — dicek di layer server sebelum render, bukan disembunyikan pakai CSS.
- Warna & font hanya boleh diambil dari `tenant_theme_config`, diinjeksikan sebagai CSS variable di root layout (`--color-primer`, `--color-aksen`, dst) — komponen tidak pernah menulis hex/nama warna langsung.

---

## 2. Design Token System

### 2.1 Palet Warna (default preset — tenant boleh override primer/aksen dalam batas kontras aksesibilitas)

| Token | Hex | Peran |
|---|---|---|
| `--color-primer` | `#1F4D3D` (hijau tua sawah) | Header, tombol utama, identitas resmi |
| `--color-primer-dark` | `#12231C` | Mode gelap, footer |
| `--color-aksen` | `#C9A227` (emas padi) | Highlight, status positif, elemen tanda tangan/stempel |
| `--color-siaga` | `#A63D40` (merah bata pudar) | Status urgent/tolak, dipakai sangat terbatas |
| `--color-netral-100` | `#F6F3EA` (kertas) | Background terang |
| `--color-netral-900` | `#1C1C1A` | Teks utama |

**Kenapa bukan palet cream+terracotta generik**: warna diambil dari elemen fisik nyata dunia desa — hijau sawah, emas padi, merah bata — bukan palet AI-generik. Terracotta (`#D97757`-ish) sengaja dihindari.

### 2.2 Tipografi

| Peran | Font | Alasan |
|---|---|---|
| Display (H1/Hero) | **Fraunces** (slab-serif, kontras tinggi) | Berkarakter seperti huruf pada kop surat/prasasti resmi, bukan sans generik |
| Body | **Inter** atau **Plus Jakarta Sans** | Netral, keterbacaan tinggi di layar kecil |
| Data/Utility (NOP, kode surat, tabel) | **JetBrains Mono** | Membedakan data terstruktur (nomor objek pajak, nomor surat) dari teks naratif — penting di dashboard admin |

Preset font di `tenant_theme_config.preset_font` dibatasi 2-3 kombinasi resmi (bukan bebas pilih font apapun) supaya konsistensi visual antar-desa tetap terjaga.

### 2.3 Signature Element — "Stempel Digital"

Elemen unik yang mengikat identitas produk ini ke subjeknya: **badge melingkar bergaya stempel/cap resmi desa**, dipakai konsisten di:
- Halaman verifikasi surat (`/verifikasi/{uuid}`) — animasi ringan "cap menempel" saat halaman verifikasi berhasil.
- Badge status IDM di dashboard publik (mis. lingkaran skor dengan tepi bertekstur seperti stempel).
- Watermark tipis pola garis radial (meniru guilloche pada stempel resmi) di background hero, sangat halus (opacity ≤4%), bukan dekorasi mencolok.

Ini satu-satunya tempat "keberanian visual" dipakai — bagian lain tetap tenang dan disiplin.

### 2.4 Breakpoint (Mobile-First)

| Breakpoint | Lebar | Prioritas layout |
|---|---|---|
| Base (default, tanpa prefix) | 360px+ | 1 kolom, navigasi hamburger, hero full-viewport-height |
| `sm:` | 640px+ | Grid 2 kolom untuk kartu section |
| `md:` | 768px+ | Navigasi header horizontal muncul |
| `lg:` | 1024px+ | Grid 3-4 kolom, sidebar dashboard admin muncul permanen |
| `xl:` | 1280px+ | Max-width content container aktif |

---

## 3. Halaman 1 — Landing Page / Beranda

### 3.1 Struktur (top to bottom)
```
┌─────────────────────────────────────┐
│ HEADER (sticky)                       │
│ [Logo+Nama Desa]      [☰ mobile]      │  ← desktop: menu horizontal dari site_navigation
├─────────────────────────────────────┤
│                                         │
│         HERO — FULL VIEWPORT           │  ← 100dvh, TANPA CTA (sesuai brief)
│                                         │
│   [Headline dari content_blocks]        │
│   [Sub-headline]                          │
│   [Watermark stempel radial, opacity~4%]   │
│                                              │
│              ↓ scroll indicator                │
├─────────────────────────────────────┤
│ SECTION: Statistik Desa Real-Time      │  ← dari idm_status_desa & dashboard_agregat
│ (jumlah penduduk, status IDM, dst)      │     BUKAN angka statis di kode
├─────────────────────────────────────┤
│ SECTION: Layanan Unggulan               │  ← kartu per fitur AKTIF (feature_flags)
│ [Surat Online] [Usulan Kegiatan]          │     kartu tidak render jika modul nonaktif
│ [Info Kesehatan] [PBB Online]               │
├─────────────────────────────────────┤
│ SECTION: Berita & Pengumuman Terkini      │  ← dari tabel berita_desa (CMS ringan)
├─────────────────────────────────────┤
│ SECTION: Peta Sebaran & Profil Wilayah      │  ← embed peta dusun, dari data GIS objek desa
├─────────────────────────────────────┤
│ SECTION: Transparansi Anggaran (ringkas)      │ ← grafik ringkas realisasi APBDes
├─────────────────────────────────────┤
│ FOOTER                                          │
│ [Kontak] [Jam Layanan] [Menu footer dari nav]     │
│ [Link Verifikasi Dokumen] [Media Sosial]            │
└─────────────────────────────────────┘
```

### 3.2 Catatan implementasi Hero (tanpa CTA)
- Hero murni sebagai *tesis visual*: menegaskan identitas desa (nama, tagline dari `site_content_blocks` tipe `hero`), tanpa tombol aksi — sesuai permintaan eksplisit "No CTA". Ajakan bertindak dipindah ke section "Layanan Unggulan" di bawahnya, bukan dipaksakan di hero.
- Elemen di hero: nama resmi desa + kecamatan/kabupaten (dari `site_settings`), satu kalimat identitas singkat (dari `content_blocks`), watermark stempel radial halus, dan indikator scroll (bukan tombol).
- Tinggi hero: `min-h-[100dvh]` (bukan `100vh`, agar akurat di mobile browser dengan address bar dinamis).

### 3.3 Mobile-first behaviour
- Header mobile: logo + hamburger, menu full-screen overlay saat dibuka (bukan dropdown sempit).
- Section "Layanan Unggulan": mobile 1 kolom stack vertikal, `sm:` 2 kolom, `lg:` 4 kolom.
- Statistik desa: mobile carousel swipe horizontal, desktop grid statis.

---

## 4. Halaman 2 — Public Page (template generik)

Dipakai untuk semua halaman statis/dinamis publik: Profil Desa, Struktur Organisasi, Berita detail, halaman Verifikasi Dokumen, halaman Status IDM publik, dsb. **Satu template, konten dari `site_content_blocks` dengan `halaman` berbeda** — bukan halaman terpisah yang dihardcode per topik.

```
┌─────────────────────────────────────┐
│ HEADER (sama seperti beranda)          │
├─────────────────────────────────────┤
│ Breadcrumb (dinamis dari route)          │
├─────────────────────────────────────┤
│ Judul Halaman (dari site_content_blocks)   │
│ Konten Blok 1..N (render sesuai tipe_blok)    │
│   - teks kaya (rich text dari CMS)               │
│   - tabel data (mis. struktur organisasi)          │
│   - kartu berita terkait                              │
├─────────────────────────────────────┤
│ FOOTER                                                  │
└─────────────────────────────────────┘
```

**Kasus khusus — Halaman Verifikasi Dokumen (`/verifikasi/[uuid]`):**
- Tidak menggunakan `site_content_blocks` (ini transaksional, bukan CMS), melainkan query langsung ke `surat_dokumen` by `qr_uuid`.
- Menampilkan badge "Stempel Digital" (signature element §2.3) dengan status: **Dokumen Sah** (hijau) atau **Tidak Ditemukan/Dicabut** (merah, `--color-siaga`).
- Menampilkan metadata non-sensitif saja: jenis surat, nomor surat, tanggal terbit, penandatangan — **tidak menampilkan isi lengkap surat** (privasi pemohon).
- Footer halaman ini dan semua halaman publik menampilkan `nomor_wa_resmi` beserta badge "Nomor WA Resmi Terverifikasi" (jika `wa_business_verified = true`), dengan peringatan singkat agar warga hanya percaya nomor tersebut untuk mencegah penipuan mengatasnamakan kantor desa.

---

## 5. Halaman 3 — Login Page

### 5.1 Struktur (mobile-first, single column selalu — login tidak butuh layout lebar)
```
┌───────────────────────┐
│                          │
│      [Logo Desa]           │  ← dari tenant_theme_config
│   Kantor Desa Virtual        │
│   {nama_desa dari settings}     │
│                                    │
│  ┌───────────────────────┐        │
│  │ [Input: NIK / Email]      │        │
│  │ [Input: Kata Sandi]         │        │
│  │ [ ] Ingat saya                 │        │
│  │ [Tombol: Masuk]                   │        │
│  │ Lupa kata sandi? →                   │        │
│  └───────────────────────┘        │
│                                    │
│  ── atau ──                          │
│  [Masuk dengan OTP WhatsApp]           │  ← selaras dengan verifikasi OTP di F2 (voting)
│                                    │
│  Belum punya akun? Daftar sebagai warga →│
└───────────────────────┘
```

### 5.2 Aturan desain
- Field & label **tidak hardcode teks Indonesia langsung di komponen** — diambil dari `i18n_strings` (mis. `auth.login.title`, `auth.login.nik_label`) supaya siap multi-bahasa (bahasa daerah/Inggris untuk desa wisata) tanpa ubah kode.
- Dua jalur login sesuai peran: **NIK+password** (warga & admin) dan **OTP WhatsApp** (warga, konsisten dengan mekanisme OTP yang sudah dipakai di alur voting F2) — bukan implementasi otentikasi terpisah.
- Redirect setelah login **berbasis peran** (bukan hardcode satu tujuan): warga → `/beranda-warga`, admin/perangkat desa → `/admin/dashboard`, Kades → `/admin/dashboard?highlight=tte-pending`.
- Pesan error login mengikuti prinsip "errors don't apologize, tidak vague" — mis. "NIK atau kata sandi tidak cocok. Coba lagi atau gunakan OTP WhatsApp." — bukan "Terjadi kesalahan."

---

## 6. Halaman 4 — Dashboard Admin: Pengaturan & Konfigurasi

Ini halaman yang **paling langsung menegakkan prinsip zero-hardcode** — di sinilah perangkat desa mengubah semua hal yang di halaman lain diambil dari config.

### 6.1 Struktur (mobile-first: sidebar jadi bottom-sheet/drawer di mobile)
```
Mobile (360-767px):                    Desktop (1024px+):
┌─────────────────┐                  ┌───┬─────────────────────┐
│ Header + ☰ menu    │                  │Sid│ Header (breadcrumb)    │
├─────────────────┤                  │ebr├─────────────────────┤
│                     │                  │ar │                          │
│  Konten Pengaturan     │                  │   │   Konten Pengaturan       │
│  (1 kolom, per-seksi)     │                  │   │   (grid 2 kolom form)      │
│                              │                  │   │                              │
│  [Drawer navigasi seksi        │                  │   │                              │
│   muncul saat ☰ ditekan]           │                  │   │                              │
└─────────────────┘                  └───┴─────────────────────┘
```

### 6.2 Seksi Pengaturan (tiap seksi = 1 route, bukan tab JS tersembunyi — tetap multi-page)

| Route | Konten |
|---|---|
| `/admin/pengaturan/identitas` | Nama desa, alamat kantor, kontak, jam layanan → `site_settings` |
| `/admin/pengaturan/tema` | Logo, favicon, warna primer/aksen (color picker dengan validasi kontras WCAG), preset font → `tenant_theme_config` |
| `/admin/pengaturan/navigasi` | CRUD menu header/footer, drag-to-reorder → `site_navigation` |
| `/admin/pengaturan/konten-beranda` | CRUD section beranda (tambah/hapus/urutkan/edit tiap blok) → `site_content_blocks` |
| `/admin/pengaturan/modul` | Toggle aktif/nonaktif tiap fitur (F1-F6) → `feature_flags`, dengan peringatan dampak (mis. matikan F2 akan menyembunyikan menu Usulan Kegiatan) |
| `/admin/pengaturan/pengguna` | Kelola akun admin/perangkat desa & peran (RBAC) |
| `/admin/pengaturan/jenis-surat` | CRUD `surat_jenis` — admin bisa tambah jenis surat baru tanpa deploy kode baru |
| `/admin/pengaturan/idm` | Lihat/override manual `idm_scoring_thresholds` jika ada revisi kuesioner tahun berjalan (lihat catatan implementasi di `PETA_DERIVATION_RULES_IDM.md`). Setiap indikator menampilkan label `sumber_data` (operasional/periodik_manual/eksternal); indikator non-operasional menampilkan tanggal update terakhir, bukan status "real-time" |
| `/admin/pengaturan/kepatuhan` | Generate & unduh file ekspor SISKEUDES/SIPADES per periode (`ekspor_kepatuhan`), wajib verifikasi admin sebelum status `diunduh` — lihat `ARSITEKTUR_SISTEM_TERINTEGRASI.md §4` |

### 6.3 Pola form pengaturan (konsisten di semua seksi)
- Setiap form pengaturan: perubahan disimpan sebagai draft dulu jika berdampak publik luas (tema, navigasi) — tombol **"Terapkan Perubahan"** eksplisit, bukan auto-save diam-diam untuk hal yang tampil ke warga.
- Preview live di panel samping (desktop) / tab terpisah (mobile) sebelum "Terapkan" — supaya admin desa yang awam teknologi tidak salah publish.
- Validasi kontras warna otomatis saat pilih `warna_primer`/`warna_aksen` — tolak kombinasi yang gagal WCAG AA, dengan pesan jelas ("Kontras teks putih di atas warna ini terlalu rendah, coba warna lebih gelap").

### 6.4 Aksesibilitas & kualitas dasar (berlaku semua 4 halaman)
- Fokus keyboard terlihat jelas (`:focus-visible` custom ring, bukan dihilangkan).
- `prefers-reduced-motion` dihormati — animasi stempel/watermark otomatis nonaktif.
- Kontras teks minimum WCAG AA di semua kombinasi token warna default.
- Semua form memiliki label eksplisit (bukan placeholder-as-label).

---

## 7. Struktur Routing (Next.js App Router — referensi)

```
app/
├── (public)/
│   ├── page.tsx                    ← Landing/Beranda (§3)
│   ├── [slug]/page.tsx             ← Public Page generik (§4), slug dari site_content_blocks
│   ├── verifikasi/[uuid]/page.tsx  ← Verifikasi dokumen (§4, kasus khusus)
│   └── layout.tsx                  ← Header+Footer dari site_navigation
├── login/page.tsx                  ← §5, layout khusus tanpa header/footer publik
├── admin/
│   ├── layout.tsx                  ← Sidebar admin, dicek feature_flags & RBAC
│   ├── dashboard/page.tsx
│   └── pengaturan/
│       ├── identitas/page.tsx
│       ├── tema/page.tsx
│       ├── navigasi/page.tsx
│       ├── konten-beranda/page.tsx
│       ├── modul/page.tsx
│       ├── pengguna/page.tsx
│       ├── jenis-surat/page.tsx
│       ├── idm/page.tsx
│       └── kepatuhan/page.tsx      ← §6.2, ekspor SISKEUDES/SIPADES
```

---

## 8. Referensi Dokumen Terkait
- `PRD_KANTOR_DESA_VIRTUAL.md` — kebutuhan produk 6 fitur andalan
- `WORKFLOW_KANTOR_DESA_VIRTUAL.md` — alur proses yang ditampilkan halaman-halaman ini
- `SKEMA_DATABASE_ERD.md` — skema data domain (surat, usulan, PBB, IDM)
- Skema pendukung frontend (`tenant_theme_config`, `site_content_blocks`, `site_navigation`, `feature_flags`, `i18n_strings`) didefinisikan di §1.2 dokumen ini — perlu ditambahkan ke migrasi database bersama skema domain yang sudah ada
- `ARSITEKTUR_SISTEM_TERINTEGRASI.md` — rasional tambahan nomor WA resmi terverifikasi, label `sumber_data` di halaman IDM, halaman baru `/admin/pengaturan/kepatuhan`
