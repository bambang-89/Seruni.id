# Desain: Detail Page Bansos + Penerima Bansos

**Tanggal:** 2026-07-27
**Status:** Draft

---

## 1. Ringkasan

Membangun detail page untuk program Bantuan Sosial dan halaman kelola penerima bansos. Warga bisa lihat detail program dan siapa aja yang terima bantuan (transparansi penuh). Admin bisa kelola data penerima dengan search, filter, dan CRUD.

---

## 2. Struktur Halaman

### 3 Route

| Route | Akses | Fungsi |
|-------|-------|--------|
| `/bansos` | Publik | List semua program bansos (sudah ada) |
| `/bansos/:id` | Publik | Detail program + ringkasan stats + daftar penerima |
| `/admin/bansos-penerima` | Admin | Kelola penerima bansos (nested pilih program) |

### Flow Navigasi

1. Warga buka `/bansos` → klik kartu program
2. Masuk ke `/bansos/:id` → lihat detail program + ringkasan + tabel penerima
3. Admin di `/admin/bansos` → klik "Kelola Penerima" → `/admin/bansos-penerima`

---

## 3. Halaman Publik: `/bansos/:id`

### Layout

Single page, scroll-driven, standalone (tanpa navbar/hero).

```
┌──────────────────────────────────────┐
│ [← Kembali]              (sticky)    │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ BADGE: KODE PROGRAM              │ │
│ │ NAMA PROGRAM BANSOS              │ │
│ │ Sumber · [AKTIF] badge           │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ┌────────┐ ┌────────┐ ┌──────────┐  │
│ │ KUOTA  │ │NOMINAL │ │ PERIODE  │  │
│ │   50   │ │900.000 │ │2026 s/d  │  │
│ │penerima│ │ /orgn  │ │  2026    │  │
│ └────────┘ └────────┘ └──────────┘  │
│                                      │
│ Deskripsi program bansos...          │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ SEBARAN PENERIMA PER DUSUN       │ │
│ │ (horizontal bar chart)            │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ── DAFTAR PENERIMA ─────────────────│
│ [🔍 Cari nama/NK] [Dusun ▼]        │
│ ┌──────────────────────────────────┐ │
│ │ Nama     │Kontak│ Dinas │Nominal │ │
│ │ Ahmad Z. │ ████ │ Mandar│900.000 │ │
│ │ Siti A.  │ ████ │ Mandar│900.000 │ │
│ └──────────────────────────────────┘ │
│ [← Prev]  1 / 3  [Next →]           │
└──────────────────────────────────────┘
```

### Sections

#### 3.1 Header Card
- Badge kode program (accent color, uppercase, monospace font)
- Nama program (display font, besar)
- Sumber dana + status aktif badge (hijau = aktif, abu = nonaktif)

#### 3.2 Stats Row
3 cards dalam grid:
- **Kuota** — angka besar, label "Penerima"
- **Nominal** — format `Rp 900.000` per orang
- **Periode** — `Jan 2026 s/d Des 2026`

#### 3.3 Deskripsi
- Teks deskripsi program dari database
- Jika kosong, tampilkan placeholder "Deskripsi belum tersedia"

#### 3.4 Chart Sebaran per burnett
- Horizontal bar chart menggunakan Recharts
- Sumbu Y: nama burnett
- Sumbu X: jumlah penerima
- Tampilkan hanya jika ada data penerima
- Jika tidak ada data, tampilkan placeholder "Data sebaran belum tersedia"

#### 3.5 Tabel Daftar Penerima
- **Columns:** Nama, Kontak (████), burnett, Nominal, Status
- **Kontak** — tampilkan `████████` (masked, 8 karakter)
- **Nama** — plain text
- **Nominal** — format IDR
- **Status** — badge: Aktif (hijau), Diverifikasi (biru), Disalurkan (ungu), Dibatalkan (abu)
- **Pagination** — 20 per halaman
- **Search** — text input, search nama/NIK (NIK tampil di tooltip saat hover)
- **Filter** — dropdown burnett
- Jika tidak ada penerima, tampilkan "Belum ada data penerima"

---

## 4. Halaman Admin: `/admin/bansos-penerima`

### Layout

Menggunakan existing `PenerimaBansosAdmin` component yang sudah ada, dengan upgrade:

```
┌───────────────────────────────────────────────┐
│ Program: [Dropdown pilih program]             │
│                                               │
│ ┌────────┐ ┌────────┐ ┌────────┐             │
│ │ Total  │ │ Aktif  │ │Nonaktif│             │
│ │  50    │ │  45    │ │   5    │             │
│ └────────┘ └────────┘ └────────┘             │
│                                               │
│ [🔍 Cari...] [Dusun ▼]  [+ Tambah Penerima]  │
│ ┌────────────────────────────────────────┐   │
│ │ □ │ Nama        │ burnett  │ NK      │   │
│ │ □ │ Ahmad Z.    │ Mandar   │ 3201..  │   │
│ │ □ │ Siti Aminah │ Mandar   │ 3201..  │   │
│ └────────────────────────────────────────┘   │
│ [← Prev] Halaman 1/3 [Next →]                │
│ [Hapus Terpilih] [Export CSV]                │
└───────────────────────────────────────────────┘
```

### Fitur

- **Dropdown program** — pilih program bansos dulu
- **Stats header** — total, aktif, nonaktif (dari query agregat)
- **CRUD** — Tambah, Edit (inline atau modal), Hapus (single + bulk)
- **NIK visible** — admin lihat NIK lengkap, warga publik lihat masked
- **Export CSV** — download daftar penerima program aktif
- **Pagination** — 20 per halaman
- **Bulk actions** — checkbox + hapus massal
- **Search** — cari nama/NIK
- **Filter** — dropdown burnett

### Schema Fix

Kolom `tanggal_salur` di `PenerimaBansosTable` (AdminOps.tsx:384) perlu dicek ada di database atau perlu dibuat migration.

---

## 5. Data Source

Semua data dari Supabase. Tidak ada hardcode.

### Tables

- `bantuan_sosial` — info program (kode, nama, sumber, deskripsi, periode_mulai, periode_selesai, kuota, aktif)
- `penerima_bansos` — data penerima (bansos_id, nik, nama, burnett, status, nominal, catatan)

### Hooks

#### `usePenerimaBansos(bansosId, options?)`
```typescript
interface Options {
  search?: string;      // ilike nama atau nik
  dusun?: string;       // filter burnett
  status?: string;      // filter status
  page?: number;        // pagination (default 0)
  pageSize?: number;    // items per page (default 20)
}
```

#### `usePenerimaBansosStats(bansosId)`
```typescript
// returns: { total: number, aktif: number, nonaktif: number }
```

#### `useBansosById(id)`
Sudah ada di queries.ts (line 1473). Tidak perlu perubahan.

---

## 6. Komponen UI

### Komponen baru (di pages.tsx atau file terpisah)
- `BansosDetailPage` — redesign dari yang sudah ada
- Helper components: status badge, nominal formatter, pagination

### Komponen reusable
- `StandaloneLayout` — sudah ada, dipakai untuk wrapper
- Tailwind typography dari theme project
- Recharts untuk bar chart

---

## 7. Technical Notes

### File yang berubah
1. `src/seruni/lib/queries.ts` — upgrade `usePenerimaBansos`, tambah `usePenerimaBansosStats`
2. `src/seruni/pages.tsx` — redesain `BansosDetailPage` + tambah `useBansosById` atau perbaikan
3. `src/seruni/admin/AdminOps.tsx` — upgrade `PenerimaBansosAdmin` dengan stats + search/filter

### Checklist sebelum implementasi
- [ ] Cek kolom `tanggal_salur` ada di `penerima_bansos` atau buat migration
- [ ] Cek `tanggal_salur` di `blank` state AdminOps.tsx line 372
- [ ] Pastikan RLS policies izinkan public read `penerima_bansos` (sudah ada: admin all + tenant isolation)

### SEO/Metadata
- Title: `[Nama Program] — Bantuan Sosial Desa`
- Description: ringkasan program + jumlah penerima

---

## 8. Urutan Implementasi

1. **Upgrade queries.ts** — `usePenerimaBansos` + `usePenerimaBansosStats`
2. **Redesain BansosDetailPage** — struktur baru dengan stats + chart + tabel
3. **Tambah route** — tidak perlu, `/bansos/:id` sudah ada
4. **Upgrade PenerimaBansosAdmin** — stats header + search/filter + export
5. **Fix schema** — jika `tanggal_salur` tidak ada, buat migration
