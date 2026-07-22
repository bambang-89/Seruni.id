# Seruni — Sistem Repository Unifikasi Informasi

Portal resmi Kantor Desa **Seruni Mumbul** (Kec. Pringgabaya, Kab. Lombok Timur,
Prov. NTB). Portal publik warga + panel admin CMS + integrasi Lovable Cloud
(Postgres, Auth, Storage, Edge Functions).

## Fitur utama

- **Portal publik** — profil desa, berita, agenda, pengumuman, galeri,
  statistik, APBDes transparan, cek PBB, marketplace UMKM, wisata, peta
  interaktif (Leaflet), langganan WhatsApp, pengaduan, verifikasi dokumen.
- **Admin CMS** — dashboard KPI + 25+ modul CRUD (fondasi, informasi,
  layanan, keuangan, pembangunan, kesehatan, sosial, potensi, kebencanaan,
  pemilu, audit).
- **Auth berbasis NIK** — hanya admin desa yang login. Warga bebas akses
  seluruh halaman publik.
- **PWA** — dapat dipasang ke home screen, offline shell.
- **SEO/OG dinamis** per rute + sitemap.xml + robots.txt.
- **Broadcast WhatsApp** via Edge Function (Fonnte, dukungan dry-run).

## Teknologi

Vite 5, React 18, TypeScript 5, Tailwind CSS v3, shadcn/ui, React Router 6,
React Helmet Async, Recharts, Leaflet, Lovable Cloud, vite-plugin-pwa.

## Pengembangan lokal

```sh
bun install
bun run dev      # http://localhost:8080
bun run build    # build produksi + generate sitemap
```

`predev`/`prebuild` menjalankan `scripts/generate-sitemap.ts` yang menulis
`public/sitemap.xml`. Perbarui daftar `entries` saat menambah/menghapus rute.

## Struktur folder

```text
src/
  seruni/
    Layout.tsx           Header + Footer + mega-menu
    HomePage.tsx         Beranda editorial
    pages.tsx            22 halaman publik (lazy-loaded)
    sections.tsx         Primitif editorial
    ui.tsx               EditorialLayout & helper UI
    data.ts              Data statis (identitas, menu, seed)
    PetaLeaflet.tsx      Peta interaktif
    lib/
      auth.tsx           AuthProvider (NIK -> email sintetik)
      queries.ts         Hooks Supabase
      upload.ts          Upload ke bucket seruni-media
      seo.tsx            <Seo /> react-helmet-async
    admin/
      AdminShell.tsx     Layout sidebar + guard peran admin
      LoginPage.tsx      Login NIK + password
      InitAdminPage.tsx  Inisialisasi admin pertama
      AdminPages.tsx     CRUD fondasi + informasi
      AdminOps.tsx       CRUD operasional + broadcast WA
scripts/
  generate-sitemap.ts    Generator sitemap XML
supabase/
  functions/wa-broadcast/  Edge Function Fonnte
public/
  manifest.webmanifest   (dibangun vite-plugin-pwa)
  sw.js                  (dibangun vite-plugin-pwa)
  pwa-192.png / pwa-512.png / apple-touch-icon.png
  robots.txt / sitemap.xml
```

## Panduan admin

1. Buka `/admin/init` sekali untuk membuat admin pertama (NIK + password).
2. Login berikutnya di `/admin/login`.
3. Sidebar dikelompokkan per domain (Fondasi, Informasi, Layanan, dst).
4. Upload gambar tersimpan di bucket privat `seruni-media` dan disajikan
   lewat Signed URL 10 tahun.
5. Broadcast WA di menu **Langganan WA**: pilih dusun/topik, kirim.
   Tanpa `FONNTE_TOKEN` fitur berjalan mode dry-run.

## PWA & performa

- Service worker (`/sw.js`) hanya terdaftar di build produksi & host
  non-preview. Navigasi memakai NetworkFirst (timeout 3s). Rute `/admin/*`
  dan `/~oauth` dikecualikan dari cache navigasi.
- Route publik & admin di-lazy load (React.lazy + Suspense). Bundle vendor
  dipecah: `vendor-react`, `vendor-charts`, `vendor-map`, `vendor-supabase`.
- Untuk memaksa unregister SW pada browser: buka aplikasi dengan `?sw=off`.

## Deploy

Publikasikan lewat tombol **Publish** di editor Lovable. Perubahan frontend
baru tayang setelah tombol *Update* dalam dialog Publish ditekan; perubahan
backend (Edge Function, migrasi) langsung tayang.

## Secret opsional

- `FONNTE_TOKEN` — token API Fonnte. Tanpa secret ini fitur broadcast WA
  berjalan mode dry-run (mencatat penerima tanpa mengirim pesan).