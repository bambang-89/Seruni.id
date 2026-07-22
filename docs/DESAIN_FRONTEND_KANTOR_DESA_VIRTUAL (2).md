**Diturunkan dari `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md`** — dokumen ini adalah pecahan sinkron, bukan sumber independen. Jika ada perbedaan di masa depan, `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md` yang berlaku. Status dependensi & blocker: lihat lampiran Bagian E di `PRD_KANTOR_DESA_VIRTUAL.md`.

---

# BAGIAN D — DESAIN FRONTEND

Multi-Page Architecture · Mobile-First · Zero Hardcode · Referensi presisi untuk Claude Code.

## D0. Tiga Prinsip Wajib

1. **Multi-Page, bukan SPA.** Setiap halaman punya route server-rendered sendiri (Next.js App Router `app/(public)/page.tsx`, `app/login/page.tsx`, `app/admin/pengaturan/page.tsx`, dst). Navigasi antar-halaman adalah _full page load_ yang dioptimalkan (RSC streaming), bukan client-side router tunggal yang menyamar jadi banyak "halaman". Ini penting untuk SEO portal publik & performa di HP low-end warga desa.
2. **Mobile-First.** Semua breakpoint didesain dari 360px ke atas. Layout desktop adalah _penambahan_, bukan penyusutan dari desktop.
3. **Zero Hardcode.** Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen. Semua berasal dari config/database (lihat §D1). Mengganti nama desa, logo, warna tema, atau urutan section beranda **tidak boleh butuh redeploy kode**.

---

## D1. Arsitektur "Zero Hardcode"

### D1.1 Sumber kebenaran konten

```
tenant_theme_config      → warna (primer/aksen/netral), logo, favicon, font (Poppins/Helvetica), font_surat (Arial)
site_content_blocks      → isi tiap section beranda (tipe, urutan, JSON konten)
site_navigation          → menu header/footer, urutan, label, link (internal/eksternal)
site_settings            → nama resmi desa, alamat kantor, jam layanan, kontak, nomor WA resmi terverifikasi
feature_flags            → modul mana yang aktif per tenant (F1-F10 + modul pendukung bisa dinyalakan/dimatikan)
i18n_strings             → semua label UI (default id-ID, siap tambah bahasa daerah/EN)
dashboard_agregat        → statistik real-time desa (diisi worker dari seluruh modul)
peta_objek               → titik/layer peta desa (diisi event dari seluruh modul)
```

### D1.2 Skema pendukung (ringkas)

```sql
CREATE TABLE tenant_theme_config (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  logo_url TEXT, favicon_url TEXT,
  warna_primer VARCHAR(7) NOT NULL DEFAULT '#1A3263',
  warna_primer_dark VARCHAR(7) NOT NULL DEFAULT '#0F0E0E',
  warna_aksen VARCHAR(7) NOT NULL DEFAULT '#FF9E20',
  warna_netral_100 VARCHAR(7) NOT NULL DEFAULT '#EAECF0',
  warna_netral_300 VARCHAR(7) NOT NULL DEFAULT '#BFC9D1',
  warna_netral_900 VARCHAR(7) NOT NULL DEFAULT '#0F0E0E',
  font_surat VARCHAR(20) NOT NULL DEFAULT 'Arial',  -- font dokumen surat (tetap Arial Regular)
  preset_font VARCHAR(30) NOT NULL DEFAULT 'poppins_helvetica'  -- lihat §D2.2
);

CREATE TABLE site_content_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  halaman VARCHAR(30) NOT NULL,        -- 'beranda', 'profil-desa', dst
  tipe_blok VARCHAR(30) NOT NULL,      -- 'hero','tentang_desa','statistik','grafik_idm','grafik_pembangunan',
                                       --  'grafik_perencanaan','pengumuman','berita','layanan_terlaris','marketplace',
                                       --  'potensi_desa','galeri','form_aduan','peta','testimoni','widget_modul'
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
  fitur_kode VARCHAR(30) NOT NULL,     -- 'F1_SURAT','F2_USULAN', ..., 'MODUL_PEMBANGUNAN','MODUL_BENCANA', dst
  aktif BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fitur_kode)
);

-- Nomor WA resmi terverifikasi pada site_settings
ALTER TABLE site_settings
  ADD COLUMN nomor_wa_resmi VARCHAR(20),
  ADD COLUMN wa_business_verified BOOLEAN NOT NULL DEFAULT false;
```

### D1.3 Aturan render

- Setiap komponen section (`<HeroBlock>`, `<StatistikBlock>`, `<WidgetModulBlock>`, dst) menerima **props dari `konten` JSONB**, tervalidasi skema Zod per tipe — bukan menerima teks langsung ditulis di JSX.
- Navigasi header/footer di-render dari query `site_navigation`, bukan array tetap di komponen `<Header>`.
- Modul yang `feature_flags.aktif = false` **tidak muncul** di navigasi maupun dashboard admin — dicek di layer server sebelum render, bukan disembunyikan pakai CSS.
- Warna & font hanya boleh diambil dari `tenant_theme_config`, diinjeksikan sebagai CSS variable di root layout (`--color-primer`, `--color-aksen`, dst) — komponen tidak pernah menulis hex/nama warna langsung.
- **Statistik & peta di beranda/portal diambil dari `dashboard_agregat` & `peta_objek`** (worker), bukan angka hardcode di komponen.

---

## D2. Design Token System

### D2.1 Palet Warna (default preset — tenant boleh override primer/aksen dalam batas kontras aksesibilitas)

| Token                 | Hex                    | Peran                                                                   |
| --------------------- | ---------------------- | ----------------------------------------------------------------------- |
| `--color-primer`      | `#1A3263` (biru tua)   | Header, tombol utama, identitas resmi, link aktif                       |
| `--color-primer-dark` | `#0F0E0E` (near-black) | Mode gelap, footer, teks utama                                          |
| `--color-aksen`       | `#FF9E20` (oranye)     | Highlight, CTA, status positif, elemen tanda tangan/stempel             |
| `--color-siaga`       | `#FF9E20` (oranye)     | Status urgent/tolak — reuse aksen (palet terbatas 5 warna, tanpa merah) |
| `--color-netral-100`  | `#EAECF0` (abu terang) | Background terang, kartu, surface                                       |
| `--color-netral-300`  | `#BFC9D1` (abu medium) | Border, divider, surface sekunder, placeholder                          |
| `--color-netral-900`  | `#0F0E0E` (near-black) | Teks utama, heading gelap                                               |

**Palet resmi (5 warna tetap):** `#1A3263` (biru brand), `#FF9E20` (aksen oranye), `#EAECF0` & `#BFC9D1` (netral abu-abu), `#0F0E0E` (near-black). Biru tua memberi kesan otoritatif/kepemerintahan; oranye sebagai aksen hangat untuk CTA & stempel; abu-abu netral menjaga keterbacaan. Kontras `primer`/`netral-900` vs `netral-100` memenuhi WCAG AA.

### D2.2 Tipografi

| Peran                                 | Font                                  | Alasan                                                                              |
| ------------------------------------- | ------------------------------------- | ----------------------------------------------------------------------------------- |
| Display (H1/Hero, Judul, Brand)       | **Poppins** (600/700)                 | Modern, bersih, kontras baik di layar kecil maupun hero                             |
| Body (teks naratif, UI, menu)         | **Helvetica** (400/500)               | Netral, keterbacaan tinggi, tampil konsisten di berbagai perangkat                  |
| Data/Utility (NOP, kode surat, tabel) | **Helvetica** (dengan `tabular-nums`) | Angka terstruktur (NOP, nomor surat) sejajar; tetap di font utama untuk konsistensi |

**Template Surat (dokumen resmi):** jenis font **Arial Regular** (fixed, bukan dari preset tema) — dipakai pada body & kop surat (`surat_dokumen`) agar kompatibel dengan standar dokumen pemerintahan & hasil cetak/PDF. Diatur via `tenant_theme_config.font_surat` (default `'Arial'`), tidak ikut preset `preset_font`.

Preset font di `tenant_theme_config.preset_font` dibatasi kombinasi resmi **Poppins + Helvetica** (bukan bebas pilih font apapun) supaya konsistensi visual antar-desa tetap terjaga.

### D2.3 Signature Element — "Stempel Digital"

Elemen unik yang mengikat identitas produk ini ke subjeknya: **badge melingkar bergaya stempel/cap resmi desa**, dipakai konsisten di:

- Halaman verifikasi surat (`/verifikasi/{uuid}`) — animasi ringan "cap menempel" saat halaman verifikasi berhasil.
- Badge status IDM di dashboard publik (mis. lingkaran skor dengan tepi bertekstur seperti stempel).
- Watermark tipis pola garis radial (meniru guilloche pada stempel resmi) di background hero, sangat halus (opacity ≤4%), bukan dekorasi mencolok.

Ini satu-satunya tempat "keberanian visual" dipakai — bagian lain tetap tenang dan disiplin.

### D2.4 Breakpoint (Mobile-First)

| Breakpoint                   | Lebar   | Prioritas layout                                        |
| ---------------------------- | ------- | ------------------------------------------------------- |
| Base (default, tanpa prefix) | 360px+  | 1 kolom, navigasi hamburger, hero full-viewport-height  |
| `sm:`                        | 640px+  | Grid 2 kolom untuk kartu section                        |
| `md:`                        | 768px+  | Navigasi header horizontal muncul                       |
| `lg:`                        | 1024px+ | Grid 3-4 kolom, sidebar dashboard admin muncul permanen |
| `xl:`                        | 1280px+ | Max-width content container aktif                       |

---

## D2.5 Navbar & Menu Dropdown Berkategori

Navbar menggunakan **menu berkategori dengan dropdown** agar tombol dropdown benar-benar berfungsi sebagai navigasi (bukan dekorasi). Struktur diambil dari `site_navigation` yang mendukung `parent_id` (submenu). Admin mengelola lewat `/admin/pengaturan/navigasi` (CRUD + drag-to-reorder).

### D2.5.1 Kategori default (reference tree)

| Kategori (parent) | Sub-menu (children)   | Route tujuan                            |
| ----------------- | --------------------- | --------------------------------------- |
| Beranda           | —                     | `/`                                     |
| Profil Desa       | Tentang Desa          | `/profil-desa`                          |
|                   | Perangkat & Lembaga   | `/profil-desa` (slug perangkat/lembaga) |
|                   | Struktur Organisasi   | `/profil-desa` (slug struktur)          |
|                   | Status IDM            | `/status-idm`                           |
|                   | Statistik Desa        | `/statistik-desa`                       |
|                   | Peta Desa             | `/peta-desa`                            |
| Layanan           | Surat Online          | `/beranda-warga` (ajukan surat)         |
|                   | Layanan Mandiri       | `/beranda-warga`                        |
|                   | PBB Online            | `/beranda-warga` (tagihan)              |
|                   | Aduan & Call Center   | `/service-center`                       |
|                   | Usulan & Voting       | `/perencanaan`                          |
|                   | Verifikasi Dokumen    | `/verifikasi`                           |
| Pembangunan       | Grafik Pembangunan    | `/pembangunan`                          |
|                   | Grafik Perencanaan    | `/perencanaan`                          |
|                   | Transparansi Anggaran | `/transparansi/anggaran`                |
|                   | Lapor Infrastruktur   | `/lapor-infrastruktur`                  |
| Ekonomi & Potensi | Marketplace           | `/marketplace`                          |
|                   | Potensi Desa          | `/potensi-desa`                         |
|                   | UMKM & BUMDes         | `/potensi-desa`                         |
| Informasi         | Berita                | `/berita`                               |
|                   | Pengumuman & Agenda   | `/kalender-desa`                        |
|                   | Galeri                | `/galeri`                               |
| Kontak            | Service Center        | `/service-center`                       |
|                   | Media Sosial          | link eksternal (dari `site_settings`)   |

### D2.5.2 Aturan render navbar

- **Top-level** = baris `parent_id IS NULL`; **children** = `parent_id = <id kategori>`, diurutkan `urutan`.
- **Desktop (`md:`+):** setiap kategori adalah elemen dropdown yang membuka daftar children saat **hover DAN fokus keyboard** (aksesibel, `:focus-visible`) — dropdown berfungsi sebagai menu navigasi sungguhan.
- **Mobile (base–`sm`):** kategori jadi akordeon di overlay hamburger (tap kategori → expand sub-menu).
- Item yang menunjuk ke modul `feature_flags.aktif = false` **tidak dirender** — dicek di server sebelum kirim props navbar.
- Label & urutan 100% dari `site_navigation` (zero hardcode) — ganti urutan/kategori tanpa redeploy.

---

## D3. Halaman 1 — Landing Page / Beranda

### D3.1 Struktur (top to bottom)

Navbar menggunakan **menu berkategori dengan dropdown** (lihat §D2.5) — setiap kategori membuka sub-menu berisi cuplikan halaman publik terkait. Sketsa di bawah, katalog lengkap section di §D3.2.

```
┌─────────────────────────────────────┐
│ HEADER (sticky, kategori dropdown)    │
│ [Logo+Nama Desa]  Beranda | Profil ▾ │
│ | Layanan ▾ | Pembangunan ▾ | Ekonomi│
│ ▾ | Informasi ▾ | Kontak   [☰ mobile]│
├─────────────────────────────────────┤
│                                         │
│         HERO — FULL VIEWPORT           │  ← 100dvh, TANPA CTA
│   [Headline] [Sub-headline]            │
│   [Watermark stempel radial ~4%] [↓]   │
├─────────────────────────────────────┤
│ S1  Tentang Desa (cuplikan)            │
│ S2  Grafik IDM (badge + 6 dimensi)     │
│ S3  Pengumuman / Agenda / Jadwal       │
│ S4  Berita Update (terbaru)            │
│ S5  Layanan Terlaris (top fitur)       │
│ S6  Marketplace (terlaris/terbaru)     │
│ S7  Grafik Pembangunan                 │
│ S8  Grafik Perencanaan (Top 10 Voting) │
│ S9  Potensi Desa                       │
│ S10 Galeri (foto/video)                │
│ S11 Form Aduan (langsung)              │
│ S12 Peta Sebaran & Profil Wilayah      │
├─────────────────────────────────────┤
│ FOOTER                                  │
│ [Tentang Desa][Service Center: WA/tlp] │
│ [Media Sosial][Jam Layanan][Verifikasi]│
└─────────────────────────────────────┘
```

### D3.2 Katalog Section Beranda (S1–S12) — Cuplikan Halaman Publik

Setiap section menampilkan **cuplikan (snippet) informatif, solutif, dan fungsional** dari halaman publik terkait, bukan sekadar teks statis. Semua data dari `dashboard_agregat` / tabel modul (worker), **tanpa hardcode**.

| #   | Section                           | Cuplikan yang ditampilkan                                                                                                                                                    | Sumber data                                                         | Tautan                |
| --- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------- |
| S1  | **Tentang Desa**                  | 2–3 kalimat sejarah/visi-misi + kartu mini topografi (luas, jumlah dusun, orbitasi) + tombol "Selengkapnya"                                                                  | `profil_desa`, `topografi_desa`, `wilayah_batas`                    | `/profil-desa`        |
| S2  | **Grafik IDM**                    | Badge status desa (mandiri→sangat_tertinggal) + 6 kartu dimensi (skor 1–5, aksen stempel) + mini-tren 12 bulan                                                               | `idm_status_desa`, `idm_skor_cache`, `dashboard_agregat`            | `/status-idm`         |
| S3  | **Pengumuman / Agenda / Jadwal**  | Carousel 3–5 agenda mendatang (jenis, tanggal, lokasi) + tombol "Langganan WA" (`agenda_subscriber`)                                                                         | `agenda_kegiatan`                                                   | `/kalender-desa`      |
| S4  | **Berita Update**                 | Grid 3 berita terbaru (judul, kategori, ringkasan, tanggal, thumbnail)                                                                                                       | `artikel_desa` (status=publish)                                     | `/berita`             |
| S5  | **Layanan Terlaris**              | Kartu top-N layanan by volume transaksi (Surat, PBB, Aduan, Usulan) — ikon + jumlah bulan berjalan                                                                           | `feature_flags` + log transaksi modul                               | masing-masing layanan |
| S6  | **Marketplace**                   | 2 baris: "Terlaris" (rating/terjual) + "Terbaru" (produk baru); tiap kartu: foto, nama, harga, penjual                                                                       | `produk_marketplace` (status=publish)                               | `/marketplace`        |
| S7  | **Grafik Pembangunan**            | Chart progres fisik kegiatan (%), total anggaran terserap, jumlah aset terbentuk + daftar 3 kegiatan aktif                                                                   | `pembangunan`, `apbdes_realisasi`, `aset_desa`, `dashboard_agregat` | `/pembangunan`        |
| S8  | **Grafik Perencanaan**            | Kartu: jumlah Usulan masuk, partisipasi Voting + **Bar Chart Top 10 Usulan dengan dukungan tertinggi**                                                                       | `usulan_kegiatan`, `usulan_votes`                                   | `/perencanaan`        |
| S9  | **Potensi Desa**                  | Sektor ekonomi unggulan (Pertanian/Perikanan/UMKM/dst, nilai) + 2 pariwisata unggulan + logo BUMDes/Koperasi                                                                 | `sektor_ekonomi`, `pariwisata`, `bumdes`                            | `/potensi-desa`       |
| S10 | **Galeri**                        | Grid 6 foto/video kegiatan desa (lightbox)                                                                                                                                   | `galeri_desa`                                                       | `/galeri`             |
| S11 | **Form Aduan**                    | Form ringkas langsung di beranda: pilih kategori (POSBANKU/INFRASTRUKTUR/KAMTIBMAS/KEDARURATAN/ULASAN), isi, lokasi, lampiran → submit → eskalasi otomatis ke Service Center | `pengaduan_desa`, `call_center_desa`                                | `/service-center`     |
| S12 | **Peta Sebaran & Profil Wilayah** | Embed peta dengan toggle layer (wilayah, aset, pbb, bencana, pariwisata, layanan) — klik titik → popup info                                                                  | `peta_objek`, `wilayah_batas`                                       | `/peta-desa`          |

**Footer (selalu tampil):** kolom "Tentang Desa" (ringkas), **Service Center** (nomor WA resmi terverifikasi + telepon darurat dari `call_center_desa`/`site_settings`), **Media Sosial** (link FB/IG/YT dari `site_settings`), Jam Layanan, Menu footer (dari `site_navigation` posisi=footer), dan Link Verifikasi Dokumen (`/verifikasi`).

### D3.3 Catatan implementasi Hero (tanpa CTA)

- Hero murni sebagai _tesis visual_: menegaskan identitas desa (nama, tagline dari `site_content_blocks` tipe `hero`), tanpa tombol aksi — sesuai permintaan eksplisit "No CTA". Ajakan bertindak dipindah ke section "Layanan Terlaris" (S5) di bawahnya, bukan dipaksakan di hero.
- Elemen di hero: nama resmi desa + kecamatan/kabupaten (dari `site_settings`), satu kalimat identitas singkat (dari `content_blocks`), watermark stempel radial halus, dan indikator scroll (bukan tombol).
- Tinggi hero: `min-h-[100dvh]` (bukan `100vh`, agar akurat di mobile browser dengan address bar dinamis).

### D3.4 Mobile-first behaviour

- **Navbar dropdown (desktop `md:`+):** kategori horizontal; hover/fokus keyboard membuka dropdown sub-menu (bukan full page). Setiap item sub-menu adalah link nyata ke halaman publik — dropdown berfungsi sebagai navigasi.
- **Navbar mobile (base–`sm`):** logo + hamburger; klik membuka overlay full-screen dengan **akordeon kategori** (tap kategori → expand sub-menu). Bukan dropdown sempit.
- Section S5/S6/S7/S8/S9/S10: mobile 1 kolom stack vertikal, `sm:` 2 kolom, `lg:` 3–4 kolom.
- Grafik (S2/S7/S8): mobile carousel swipe horizontal, desktop grid statis.
- **Semua section hanya dirender jika `feature_flags` modul terkait `aktif`** — tidak ada section/kartu kosong untuk modul yang dimatikan (mis. S6 Marketplace hanya jika modul Potensi aktif).

### D3.5 Kolom Gambar/Foto (refactoring tampilan — lihat `SKEMA_DATABASE_ERD.md` §C26)

Agar tampilan website lebih beragam & variatif, modul terkait kini punya kolom gambar (`foto_url`/`sampul_url`/`simbol_url`) yang **diisi lewat Media Library** (`/admin/media`), tidak di-hardcode.

- **Beranda & Profil**: `profil_desa.sampul_url` → hero/cover beranda & profil desa (selain `tenant_theme_config.logo`).
- **Potensi & Marketplace**: `sektor_ekonomi.foto_url`, `pariwisata.foto_url` → thumbnail produk/wisata di S6/S9.
- **Transparansi**: `aset_desa.foto_url`, `kegiatan_desa.foto_url` → kartu di S7 Grafik Pembangunan & transparansi anggaran.
- **Perencanaan**: `usulan_kegiatan.foto_url`, `usulan_pembangunan.foto_url` → kartu voting & usulan.
- **Kalender & Bencana**: `agenda_kegiatan.foto_url`, `bencana_kejadian.foto_url` → banner agenda & popup peta bencana.
- **Peta**: `peta_layer.simbol_url` + `foto_url` dari `peta_objek` (join `ref_tabel`+`ref_id`) → ikon & popup foto.
- **Render**: semua `<img loading="lazy">` dengan `alt` dari `media_aset.alt_text`; fallback ke placeholder netral jika kosong (tidak ada gambar rusak).

---

## D4. Halaman 2 — Public Page (template generik)

Dipakai untuk semua halaman statis/dinamis publik: Profil Desa, Struktur Organisasi, Berita detail, halaman Verifikasi Dokumen, halaman Status IDM publik, halaman Statistik Desa, dsb. **Satu template, konten dari `site_content_blocks` dengan `halaman` berbeda** — bukan halaman terpisah yang dihardcode per topik.

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
│   - WIDGET STATISTIK (dari dashboard_agregat)         │
│   - PETA (dari peta_objek, filter layer)              │
├─────────────────────────────────────┤
│ FOOTER                                                  │
└─────────────────────────────────────┘
```

**Kasus khusus — Halaman Verifikasi Dokumen (`/verifikasi/[uuid]`):**

- Tidak menggunakan `site_content_blocks` (ini transaksional, bukan CMS), melainkan query langsung ke `surat_dokumen` by `qr_uuid`.
- Menampilkan badge "Stempel Digital" (signature element §D2.3) dengan status: **Dokumen Sah** (hijau) atau **Tidak Ditemukan/Dicabut** (merah, `--color-siaga`).
- Menampilkan metadata non-sensitif saja: jenis surat, nomor surat, tanggal terbit, penandatangan — **tidak menampilkan isi lengkap surat** (privasi pemohon).
- Footer halaman ini dan semua halaman publik menampilkan `nomor_wa_resmi` beserta badge "Nomor WA Resmi Terverifikasi" (jika `wa_business_verified = true`), dengan peringatan singkat agar warga hanya percaya nomor tersebut untuk mencegah penipuan mengatasnamakan kantor desa.

**Kasus khusus — Halaman Status IDM Publik (`/status-idm`):**

- Membaca `idm_status_desa` (badge status: mandiri→sangat_tertinggal) + `dashboard_agregat` (breakdown per dusun/RT/RW, tren waktu).
- Setiap indikator menampilkan label `sumber_data`; indikator non-operasional menampilkan tanggal update terakhir.

**Kasus khusus — Halaman Statistik Desa (`/statistik-desa`):**

- Grid kartu dari `dashboard_agregat` (kategori: kependudukan, kesehatan, sosial, ekonomi, infrastruktur, stunting, pembangunan, bencana, pemilu, analisis, suplesi, aduan) — semua diisi worker, tanpa hardcode.

---

## D5. Halaman 3 — Login Page

### D5.1 Struktur (mobile-first, single column selalu — login tidak butuh layout lebar)

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

### D5.2 Aturan desain

- Field & label **tidak hardcode teks Indonesia langsung di komponen** — diambil dari `i18n_strings` (mis. `auth.login.title`, `auth.login.nik_label`) supaya siap multi-bahasa (bahasa daerah/Inggris untuk desa wisata) tanpa ubah kode.
- Dua jalur login sesuai peran: **NIK+password** (warga & admin) dan **OTP WhatsApp** (warga, konsisten dengan mekanisme OTP yang sudah dipakai di alur voting F2 & verifikasi Penduduk) — bukan implementasi otentikasi terpisah.
- Redirect setelah login **berbasis peran** (bukan hardcode satu tujuan): warga → `/beranda-warga`, admin/perangkat desa → `/admin/dashboard`, Kades → `/admin/dashboard?highlight=tte-pending`.
- Pesan error login mengikuti prinsip "errors don't apologize, tidak vague" — mis. "NIK atau kata sandi tidak cocok. Coba lagi atau gunakan OTP WhatsApp." — bukan "Terjadi kesalahan."

---

## D6. Halaman 4 — Dashboard Admin: Pengaturan & Konfigurasi

Ini halaman yang **paling langsung menegakkan prinsip zero-hardcode** — di sinilah perangkat desa mengubah semua hal yang di halaman lain diambil dari config.

### D6.1 Struktur (mobile-first: sidebar jadi bottom-sheet/drawer di mobile)

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

### D6.2 Seksi Pengaturan (tiap seksi = 1 route, bukan tab JS tersembunyi — tetap multi-page)

| Route                              | Konten                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `/admin/pengaturan/identitas`      | Nama desa, alamat kantor, kontak, jam layanan → `site_settings`                                                    |
| `/admin/pengaturan/tema`           | Logo, favicon, warna primer/aksen (color picker dengan validasi kontras WCAG), preset font → `tenant_theme_config` |
| `/admin/pengaturan/navigasi`       | CRUD menu header/footer, drag-to-reorder → `site_navigation`                                                       |
| `/admin/pengaturan/konten-beranda` | CRUD section beranda (tambah/hapus/urutkan/edit tiap blok) → `site_content_blocks`                                 |
| `/admin/pengaturan/modul`          | Toggle aktif/nonaktif tiap fitur (F1-F10 + modul pendukung) → `feature_flags`, dengan peringatan dampak            |
| `/admin/pengaturan/pengguna`       | Kelola akun admin/perangkat desa & peran (RBAC) → `pengguna`, `peran`                                              |
| `/admin/pengaturan/jenis-surat`    | CRUD `surat_jenis` — admin bisa tambah jenis surat baru tanpa deploy kode baru                                     |
| `/admin/pengaturan/idm`            | Lihat/override manual `idm_scoring_thresholds` jika ada revisi kuesioner tahun berjalan                            |
| `/admin/pengaturan/kepatuhan`      | Generate & unduh file ekspor SISKEUDES/SIPADES per periode (`ekspor_kepatuhan`)                                    |
| `/admin/pengaturan/sinkronisasi`   | Kelola `sinkronisasi_job` & `sinkronisasi_mapping` (OpenDK/Kemendagri/IDM)                                         |
| `/admin/pengaturan/notifikasi`     | Kelola `notifikasi_template` (teks pesan WA/SMS/email, zero hardcode)                                              |

### D6.3 Pola form pengaturan (konsisten di semua seksi)

- Setiap form pengaturan: perubahan disimpan sebagai draft dulu jika berdampak publik luas (tema, navigasi) — tombol **"Terapkan Perubahan"** eksplisit, bukan auto-save diam-diam untuk hal yang tampil ke warga.
- Preview live di panel samping (desktop) / tab terpisah (mobile) sebelum "Terapkan" — supaya admin desa yang awam teknologi tidak salah publish.
- Validasi kontras warna otomatis saat pilih `warna_primer`/`warna_aksen` — tolak kombinasi yang gagal WCAG AA, dengan pesan jelas.

### D6.4 Aksesibilitas & kualitas dasar (berlaku semua halaman)

- Fokus keyboard terlihat jelas (`:focus-visible` custom ring, bukan dihilangkan).
- `prefers-reduced-motion` dihormati — animasi stempel/watermark otomatis nonaktif.
- Kontras teks minimum WCAG AA di semua kombinasi token warna default.
- Semua form memiliki label eksplisit (bukan placeholder-as-label).

---

## D7. Halaman Modul Operasional (kesetaraan OpenSID + modul pendukung)

| Route                          | Fungsi                                                                                                                                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/admin/pertanahan`            | Daftar `bidang_tanah`, filter jenis alas hak & status                                                                                                                                                  |
| `/admin/pertanahan/[id]`       | Detail bidang tanah + riwayat `kepemilikan_bidang_tanah` (read-only, append-only) + form catat pengalihan                                                                                              |
| `/admin/anggaran`              | CRUD `kegiatan_desa` per tahun anggaran + input `apbdes_realisasi` — sumber kartu "Transparansi Anggaran" & ekspor SISKEUDES                                                                           |
| `/admin/aset`                  | Daftar `aset_desa`, filter kategori & kondisi                                                                                                                                                          |
| `/admin/aset/verifikasi-draft` | Antrean draft aset dari `apbdes.realisasi.dicatat` (belanja modal) yang menunggu verifikasi admin                                                                                                      |
| `/admin/pemetaan`              | Kelola `wilayah_batas` (gambar/edit poligon dusun/RT/RW) + `peta_layer`/`peta_objek`                                                                                                                   |
| `/admin/pemetaan/laporan`      | Antrean `titik_infrastruktur` status `dilaporkan` menunggu verifikasi                                                                                                                                  |
| `/admin/agenda`                | CRUD `agenda_kegiatan` jenis `umum`; entri `musdes`/`posyandu`/`pemilu`/`bencana` tampil read-only (dibuat otomatis)                                                                                   |
| `/peta-desa`                   | **Publik** — peta dengan layer toggle: batas wilayah, tanah kas desa, titik infrastruktur, titik bencana, pariwisata, lokasi objek pajak. Tidak pernah menampilkan `bidang_tanah` milik warga individu |
| `/lapor-infrastruktur`         | **Publik** — form lapor warga (foto + lokasi + deskripsi)                                                                                                                                              |
| `/kalender-desa`               | **Publik** — agenda kegiatan, filter jenis, tombol langganan reminder WA (`agenda_subscriber` by nomor_hp + jenis_agenda[])                                                                            |
| `/transparansi/aset-desa`      | **Publik** — agregat nilai aset per kategori                                                                                                                                                           |
| `/transparansi/tanah-kas-desa` | **Publik** — agregat luas & jumlah bidang tanah kas desa                                                                                                                                               |
| `/admin/pembangunan`           | Daftar `usulan_pembangunan` (musrenbang) & `pembangunan` (kegiatan fisik) + `pembangunan_dokumentasi` progres                                                                                          |
| `/admin/pembangunan/[id]`      | Detail kegiatan + progres % + link `aset_desa` (jika selesai) + `apbdes_realisasi`                                                                                                                     |
| `/admin/stunting`              | Daftar `stunting_anak` (dari `posyandu_kunjungan`) + `stunting_intervensi` + `stunting_rekap` per dusun                                                                                                |
| `/admin/sosial`                | Daftar `kpm`, `bansos_program`, `bansos_penerima`, `bpjs_peserta`, impor `dtks_import` (SIKS-NG)                                                                                                       |
| `/admin/analisis`              | CRUD `analisis`, `analisis_pertanyaan`, input `analisis_respon`, lihat `analisis_hasil`                                                                                                                |
| `/admin/suplesi`               | CRUD `suplemen` & `suplemen_anggota` (data JSONB fleksibel per penduduk)                                                                                                                               |
| `/admin/pemilu`                | CRUD `dpt` (eligible), `pemilihan`, input `pemilihan_suara`, rekap partisipasi                                                                                                                         |
| `/admin/bencana`               | Kelola `bencana_kategori`, `bencana_titik`, pantau `bencana_prakiraan` (BMKG realtime), `bencana_kejadian`, `bencana_alert`                                                                            |
| `/admin/service-center`        | Daftar `pengaduan_desa` (filter `pengaduan_kategori`), `pengaduan_penanganan`, `call_center_desa`                                                                                                      |
| `/admin/notifikasi`            | Lihat `notifikasi` & `outbox_pesan` (log pengiriman WA/SMS/email/push)                                                                                                                                 |
| `/admin/layanan-mandiri`       | Kelola `penduduk_mandiri`, lihat `mandiri_ajuan` & `mandiri_track` warga                                                                                                                               |
| `/admin/sinkronisasi`          | Monitor `sinkronisasi_job`, `sinkronisasi_mapping`, `sinkronisasi_log`                                                                                                                                 |

### D7.1 Prinsip privasi peta & transparansi

- Layer peta publik hanya menampilkan data yang statusnya sudah terverifikasi admin — tidak ada data mentah warga yang tampil langsung.
- Halaman transparansi aset/tanah selalu agregat, konsisten dengan prinsip privasi F4 (data kesehatan) — detail per unit hanya untuk admin login.
- `peta_objek` adalah representasi tunggal semua geom; tiap modul menyimpan geom di tabelnya sendiri dan mereplikasi via event (`ref_tabel`+`ref_id`), sehingga tidak ada duplikasi geometri.

---

## D8. Struktur Routing (Next.js App Router — referensi)

```
app/
├── (public)/
│   ├── page.tsx                    ← Landing/Beranda (§D3)
│   ├── [slug]/page.tsx             ← Public Page generik (§D4), slug dari site_content_blocks
│   ├── profil-desa/page.tsx        ← §D4, Tentang Desa + perangkat/lembaga (slug site_content_blocks)
│   ├── berita/page.tsx             ← §D4, daftar artikel_desa (publish)
│   ├── galeri/page.tsx             ← §D4, galeri_desa
│   ├── marketplace/page.tsx        ← §D7, produk_marketplace (publish)
│   ├── potensi-desa/page.tsx       ← §D7, sektor_ekonomi + pariwisata
│   ├── pembangunan/page.tsx        ← §D7, grafik progres pembangunan + aset
│   ├── perencanaan/page.tsx        ← §D7, usulan + voting + Top 10 voting
│   ├── service-center/page.tsx     ← §D7, pengaduan + call_center_desa
│   ├── verifikasi/[uuid]/page.tsx  ← Verifikasi dokumen (§D4, kasus khusus)
│   ├── status-idm/page.tsx         ← §D4, badge status IDM + dashboard_agregat
│   ├── statistik-desa/page.tsx     ← §D4, grid kartu dari dashboard_agregat
│   ├── peta-desa/page.tsx          ← §D7, layer wilayah_batas + peta_objek
│   ├── lapor-infrastruktur/page.tsx ← §D7
│   ├── kalender-desa/page.tsx      ← §D7
│   ├── transparansi/
│   │   ├── aset-desa/page.tsx      ← §D7
│   │   ├── anggaran/page.tsx       ← §D7, realisasi APBDes (grafik transparansi)
│   │   └── tanah-kas-desa/page.tsx ← §D7
│   └── layout.tsx                  ← Header+Footer dari site_navigation
├── login/page.tsx                  ← §D5, layout khusus tanpa header/footer publik
├── beranda-warga/page.tsx          ← Dashboard warga (Layanan Mandiri): ajukan surat, track aduan/bansos
├── admin/
│   ├── layout.tsx                  ← Sidebar admin, dicek feature_flags & RBAC
│   ├── dashboard/page.tsx          ← Ringkasan semua modul (widget dari dashboard_agregat)
│   ├── pertanahan/
│   │   ├── page.tsx                ← §D7
│   │   └── [id]/page.tsx           ← §D7
│   ├── anggaran/page.tsx           ← §D7
│   ├── aset/
│   │   ├── page.tsx                ← §D7
│   │   └── verifikasi-draft/page.tsx ← §D7
│   ├── pemetaan/
│   │   ├── page.tsx                ← §D7
│   │   └── laporan/page.tsx        ← §D7
│   ├── agenda/page.tsx             ← §D7
│   ├── pembangunan/
│   │   ├── page.tsx                ← §D7
│   │   └── [id]/page.tsx           ← §D7
│   ├── stunting/page.tsx           ← §D7
│   ├── sosial/page.tsx             ← §D7
│   ├── analisis/page.tsx           ← §D7
│   ├── suplesi/page.tsx            ← §D7
│   ├── pemilu/page.tsx             ← §D7
│   ├── bencana/page.tsx            ← §D7
│   ├── service-center/page.tsx     ← §D7
│   ├── notifikasi/page.tsx         ← §D7
│   ├── layanan-mandiri/page.tsx    ← §D7
│   ├── sinkronisasi/page.tsx       ← §D7
│   └── pengaturan/
│       ├── identitas/page.tsx
│       ├── tema/page.tsx
│       ├── navigasi/page.tsx
│       ├── konten-beranda/page.tsx
│       ├── modul/page.tsx
│       ├── pengguna/page.tsx
│       ├── jenis-surat/page.tsx
│       ├── idm/page.tsx
│       ├── kepatuhan/page.tsx      ← §D6.2, ekspor SISKEUDES/SIPADES
│       ├── sinkronisasi/page.tsx
│       └── notifikasi/page.tsx
```

---

## D9. Alur Data & Event Propagation (1 Data Masuk → Kumulatif → Kesimpulan)

Desain frontend harus mencerminkan arsitektur **Event Propagation Layer**: setiap input di modul mana pun tidak berhenti di modul tersebut, melainkan memicu `domain_events` → worker (BullMQ) → fakta turunan yang dibaca Sistem Informasi & Sistem IDM. **Ini jaminan "1 data masuk memengaruhi seluruh data sistem secara kumulatif."**

```
[INPUT WARGA/PERANGKAT]                 [FAKTA TURUNAN — HANYA WORKER]
─────────────────────────              ─────────────────────────────────
penduduk / keluarga                      domain_events (append-only)
  │                                       │  BullMQ worker (idempoten UPSERT)
  ├─ surat_pengajuan ──────────────┐     ▼
  ├─ usulan_pembangunan ───────────┤   idm_skor_cache (skor per indikator, 6 Dimensi)
  ├─ posyandu_kunjungan ───────────┤   idm_status_desa (status desa: mandiri→sangat_tertinggal)
  ├─ pbb_tagihan ──────────────────┤   dashboard_agregat (KV: semua metrik)
  ├─ apbdes_realisasi ─────────────┤   pades_pendapatan · aset_desa (draft) · usulan draft
  ├─ kpm / bansos_penerima ────────┤        │
  ├─ stunting_anak ────────────────┤        ▼
  ├─ pembangunan.selesai ──────────┤   ┌────────────────────────────────────┐
  ├─ pengaduan_desa ───────────────┤   │  KESIMPULAN (dibaca frontend)        │
  ├─ bencana.alert ────────────────┤   │  • Sistem Informasi (portal publik)  │
  ├─ pemilihan.selesai ────────────┘   │    - Statistik Real-Time (dashboard_agregat)
  └─ analisis.selesai ─────────────────│    - Peta (peta_objek)                │
                                        │    - Berita/Agenda/Pengumuman          │
                                        │  • Sistem IDM (Dashboard Kades)        │
                                        │    - Badge status + Info Grafis        │
                                        └────────────────────────────────────┘
        │ tiap perubahan → INSERT domain_events (processed_at = NULL)
        └──────────────────────────────────────────────────────────────────────►
```

**Aturan render frontend terkait event:**

- **Tidak ada halaman yang menghitung agregat sendiri** — semua kartu statistik/Info Grafis query `dashboard_agregat` & `idm_skor_cache` (materialized view), bukan aggregate dari fakta mentah di browser.
- **Tidak ada hardcode skor/status** — badge IDM & kartu statistik di-render dari nilai `idm_status_desa`/`dashboard_agregat` terbaru.
- **Realtime tanpa refresh manual**: worker menulis fakta turunan; halaman publik/admin menggunakan revalidasi berkala (ISR) atau subscription ringan — bukan polling fakta mentah.
- **Feedback langsung ke warga**: event penting (`bencana.alert`, `pengaduan.dibuat`, `bansos.penyaluran.dicatat`, `pemilihan.selesai`) → `notifikasi` + `outbox_pesan` (WA/SMS/email/push) via Sistem Notifikasi, sehingga warga dapat info otomatis.

---

## D10. Dashboard Warga & Kades (Konsumsi Kesimpulan)

**Dashboard Warga (`/beranda-warga`):** di-render dari `penduduk_mandiri` (scope `penduduk_id`/`keluarga_id`):

- Status surat diajukan (`mandiri_ajuan` → `surat_pengajuan`).
- Track aduan (`mandiri_track` → `pengaduan_desa`).
- Bansos keluarga (`kpm`/`bansos_penerima`) + status BPJS (`bpjs_peserta`).
- Notifikasi pribadi (`notifikasi` where `penerima_id` = warga).

**Dashboard Kades (`/admin/dashboard`):** di-render dari `dashboard_agregat` + `idm_status_desa` + antrean TTE:

- Badge status IDM (mandiri→sangat_tertinggal) + tren 6 Dimensi.
- Kartu ringkasan: kependudukan, kesehatan/stunting, sosial/bansos, ekonomi/PADes, infrastruktur/pembangunan, bencana, partisipasi pemilu, aduan.
- Rekomendasi arah pembangunan (indikator skor rendah → `usulan_kegiatan_draft_otomatis`).
- Antrean TTE surat & draft aset menunggu verifikasi.

Kedua dashboard **zero-hardcode**: judul section, label, dan urutan dari `site_content_blocks`/`i18n_strings`; modul yang nonaktif (`feature_flags`) tidak muncul.

---

> **Catatan integrasi Bagian C:** skema pendukung frontend zero-hardcode (`tenant_theme_config`, `site_content_blocks`, `site_navigation`, `feature_flags`, `i18n_strings`, `site_settings`) dan seluruh tabel domain (termasuk modul pendukung: Pembangunan, Pemetaan, Notifikasi, Layanan Mandiri, Pengaturan, Sinkronisasi, Stunting, Analisis, Suplesi, Pemilu, Service Center, Bencana) didefinisikan lengkap di **`SKEMA_DATABASE_ERD.md`** (§C1–§C25). Urutan migrasi ada di §C11. Alur event → kesimpulan ada di §C7.1 dan §D9 di atas.
