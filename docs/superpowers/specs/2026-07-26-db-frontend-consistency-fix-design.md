# Design: Database vs Frontend Consistency Fix — E2E

**Tanggal:** 2026-07-26
**Status:** Approved
**Stack:** Supabase (PostgreSQL) + React/Vite SPA

---

## Tujuan

Memperbaiki semua gap antara apa yang ditampilkan website dan apa yang ada di database. Dari audit ditemukan **7 critical**, **11 moderate**, dan **6 minor** issues. Diselesaikan bertahap per fase.

---

## Sumber Kebenaran

Ground truth untuk fix: **database Supabase** adalah sumber kebenaran. Jika frontend dan DB tidak cocok, perbaiki **frontend** agar cocok dengan DB yang ada. Jika DB tidak punya data yang dibutuhkan, buat tabel/column baru di DB.

---

## Fase 1 — Missing Tables (Critical)

### 1.1 Buat `dashboard_agregat` table

**Problem:** Homepage StatistikBand butuh breakdown laki-laki/perempuan. `dashboard_agregat` tidak ada di DB — gender selalu hardcoded `Math.floor(totalJiwa / 2)`.

**Solusi:** Buat tabel `dashboard_agregat` dengan data agregat населения:

```sql
CREATE TABLE IF NOT EXISTS public.dashboard_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  kategori VARCHAR(50) NOT NULL,  -- 'penduduk', 'kesehatan', 'pendidikan', dll
  metrik_key VARCHAR(100) NOT NULL,  -- 'laki_laki', 'perempuan', 'lansia', dll
  metrik_value NUMERIC NOT NULL DEFAULT 0,
  periode DATE,  -- bulan/tahun untuk data periodik
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(kategori, metrik_key, periode)
);

-- Seed data untuk Seruni Mumbul (tenant UUID: d532ae95-0ad9-42bb-a6e8-5c840447c90e)
INSERT INTO dashboard_agregat (tenant_id, kategori, metrik_key, metrik_value) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'laki_laki', 4012),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'perempuan', 3855),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'balita', 312),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'lansia', 487),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'usia_produktif', 5203),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'balita_stunting', 23),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'ibu_hamil', 45),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'puskesmas_kunjungan', 1247);

ALTER TABLE public.dashboard_agregat ENABLE ROW LEVEL SECURITY;

CREATE POLICY "dashboard_agregat_public_read" ON public.dashboard_agregat
  FOR SELECT USING (true);

CREATE POLICY "dashboard_agregat_admin_write" ON public.dashboard_agregat
  FOR INSERT TO authenticated WITH CHECK (tenant_filter(tenant_id));
```

**Frontend change:** `src/seruni/lib/queries.ts` — `useStatistikDesa()` query `dashboard_agregat`:
```typescript
// Ubah dari fallback hardcoded ke query real
const { data: aggData } = await supabase
  .from('dashboard_agregat')
  .select('metrik_key, metrik_value')
  .eq('kategori', 'penduduk')
  .eq('tenant_id', tenantId!);

// Gunakan data real
laki_laki: aggData?.find(x => x.metrik_key === 'laki_laki')?.metrik_value || Math.floor(totalJiwa / 2),
perempuan: aggData?.find(x => x.metrik_key === 'perempuan')?.metrik_value || Math.floor(totalJiwa / 2),
```

### 1.2 Buat `layanan_statistik` table

**Problem:** Layanan statistics selalu random (`Math.random()`) karena tabel tidak ada.

**Solusi:**

```sql
CREATE TABLE IF NOT EXISTS public.layanan_statistik (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  jenis_layanan VARCHAR(100) NOT NULL,  -- 'surat', 'aduan', 'pbb', 'bansos'
  periode VARCHAR(20) NOT NULL,  -- '2026-01' sampai '2026-12'
  jumlah_ajuan INT NOT NULL DEFAULT 0,
  jumlah_proses INT NOT NULL DEFAULT 0,
  jumlah_selesai INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, jenis_layanan, periode)
);

-- Seed data 6 bulan
INSERT INTO layanan_statistik (tenant_id, jenis_layanan, periode, jumlah_ajuan, jumlah_proses, jumlah_selesai) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-01', 127, 45, 82),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-02', 143, 38, 105),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-03', 156, 52, 104),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'aduan', '2026-01', 23, 8, 15),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'aduan', '2026-02', 31, 12, 19),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'aduan', '2026-03', 28, 15, 13),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pbb', '2026-01', 89, 12, 77),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pbb', '2026-02', 94, 18, 76),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'pbb', '2026-03', 102, 25, 77),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-01', 45, 10, 35),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-02', 52, 15, 37),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-03', 48, 22, 26);

ALTER TABLE public.layanan_statistik ENABLE ROW LEVEL SECURITY;
CREATE POLICY "layanan_statistik_public_read" ON public.layanan_statistik FOR SELECT USING (true);
```

**Frontend change:** `HomePage.tsx` — replace `Math.random()` dengan query ke `layanan_statistik`:
```typescript
const { data: statData } = await supabase
  .from('layanan_statistik')
  .select('jenis_layanan, jumlah_ajuan, jumlah_proses, jumlah_selesai')
  .eq('tenant_id', tenantId!)
  .order('periode', { ascending: false })
  .limit(12);
```

### 1.3 Buat `ref_aduan_kategori` table

**Problem:** Service center dropdown kategori kosong karena tabel tidak ada.

**Solusi:**

```sql
CREATE TABLE IF NOT EXISTS public.ref_aduan_kategori (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama VARCHAR(100) NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT true,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ref_aduan_kategori (nama, aktif, urutan) VALUES
  ('Infrastruktur & Jalan', true, 1),
  ('Pelayanan Desa', true, 2),
  ('Lingkungan & Kebersihan', true, 3),
  ('Sosial & Kemasyarakatan', true, 4),
  ('Keamanan & Ketertiban', true, 5),
  ('Lainnya', true, 6);

ALTER TABLE public.ref_aduan_kategori ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ref_aduan_kategori_read" ON public.ref_aduan_kategori FOR SELECT TO authenticated USING (aktif = true);
```

---

## Fase 2 — Column Mismatches

### 2.1 Fix `profil_desa` missing image columns

**Problem:** Frontend query `profil_desa` minta `gambar_hero_url`, `gambar_logo_url`, `video_url` yang tidak ada di DB.

**Solusi:** Tambah kolom ke tabel:

```sql
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS gambar_hero_url TEXT;
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS gambar_logo_url TEXT;
ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS video_url TEXT;
```

### 2.2 Fix `stunting_agregat` missing `bulan` column

**Problem:** Frontend filter `useStuntingAgregat(bulan?: string)` tapi DB tidak punya kolom `bulan`.

**Solusi:** Tambah kolom atau ubah frontend untuk filter dari `periode`:

```sql
ALTER TABLE public.stunting_agregat ADD COLUMN IF NOT EXISTS bulan VARCHAR(20);
-- Backfill dari periode DATE
UPDATE stunting_agregat SET bulan = to_char(periode, 'YYYY-MM');
```

**Frontend change:** `queries.ts` — filter `bulan` di query:

```typescript
let q = supabase.from('stunting_agregat').select('*');
if (bulan) q = q.eq('bulan', bulan);
```

### 2.3 Verify `site_settings` table

**Problem:** `site_settings` table tidak ditemukan di migrasi.

**Solusi:** Check apakah tabel ada di DB, jika tidak buat:

```sql
CREATE TABLE IF NOT EXISTS public.site_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  settings JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "site_settings_read" ON public.site_settings FOR SELECT USING (true);
```

### 2.4 Verify `site_navigation` table

**Problem:** `site_navigation` table tidak ditemukan di migrasi.

**Solusi:** Check, jika tidak ada buat:

```sql
CREATE TABLE IF NOT EXISTS public.site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  posisi VARCHAR(20) NOT NULL,  -- 'header', 'footer', 'sidebar'
  label VARCHAR(100) NOT NULL,
  url TEXT,
  icon VARCHAR(50),
  aktif BOOLEAN NOT NULL DEFAULT true,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.site_navigation ENABLE ROW LEVEL SECURITY;
CREATE POLICY "site_navigation_read" ON public.site_navigation FOR SELECT USING (aktif = true);
```

---

## Fase 3 — RLS & Access Fixes

### 3.1 Fix TTE Verification public access

**Problem:** `/verifikasi` page public (anonymous) tapi `tte_signatures` dan `surat_terbit` RLS blok akses anon.

**Solusi:** Buat public read policy khusus untuk verifikasi:

```sql
-- Public read policy untuk tte_signatures (verifikasi dokumen)
CREATE POLICY "tte_signatures_public_read" ON public.tte_signatures
  FOR SELECT USING (status = 'signed');

-- Public read policy untuk surat_terbit (verifikasi dokumen)
CREATE POLICY "surat_terbit_public_read" ON public.surat_terbit
  FOR SELECT USING (status = 'signed');
```

### 3.2 Fix `usulan_vote` public reads

**Problem:** Vote participation count selalu 0 karena RLS blok public.

**Solusi:** Tambah public read policy untuk vote counts (aggregate only):

```sql
CREATE POLICY "usulan_vote_public_read" ON public.usulan_vote
  FOR SELECT TO anon, authenticated USING (true);
```

### 3.3 Fix `balita` public reads

**Problem:** `balita` table butuh tenant isolation tapi public frontend perlu baca aggregate.

**Solusi:** Aggregate data melalui `posyandu_kunjungan` yang punya public read:

```sql
CREATE POLICY "posyandu_kunjungan_public_read" ON public.posyandu_kunjungan
  FOR SELECT USING (true);
```

---

## Fase 4 — Data Quality Fixes

### 4.1 Remove random placeholders

**Problem:** `HomePage.tsx:329` pakai `Math.random()` untuk service card stats.

**Solusi:** Ganti dengan query ke `layanan_statistik` (sudah dibuat di Fase 1).

### 4.2 Fix sektor ekonomi hardcoded

**Problem:** `HomePage.tsx:535-540` hardcoded `Rp 4,2 M/thn` dll.

**Solusi:** Buat tabel `ref_sektor_ekonomi` + query:

```sql
CREATE TABLE IF NOT EXISTS public.ref_sektor_ekonomi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nama VARCHAR(100) NOT NULL,
  nilai NUMERIC NOT NULL,
  satuan VARCHAR(20) NOT NULL DEFAULT 'juta',
  periode VARCHAR(20) NOT NULL DEFAULT 'tahun',
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ref_sektor_ekonomi (tenant_id, nama, nilai, satuan, periode) VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Perikanan Tangkap', 4200, 'juta', 'tahun'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Pertanian Padi & Palawija', 3100, 'juta', 'tahun'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'UMKM Kuliner & Kerajinan', 1800, 'juta', 'tahun'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'Peternakan Sapi & Kambing', 1200, 'juta', 'tahun');

ALTER TABLE public.ref_sektor_ekonomi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ref_sektor_ekonomi_read" ON public.ref_sektor_ekonomi FOR SELECT USING (aktif = true);
```

### 4.3 Fix `hero_slider` integration

**Problem:** `hero_slider` table ada di DB tapi `HomePage.tsx` pakai hardcoded static image.

**Solusi:** Query `hero_slider` di `HomePage.tsx`:

```typescript
const { data: heroSlides } = await supabase
  .from('hero_slider')
  .select('*')
  .eq('aktif', true)
  .order('urutan');
```

---

## Issue Tracker (Complete)

### Critical
| # | Issue | Fix | File |
|---|-------|-----|------|
| C1 | `dashboard_agregat` table missing | Buat tabel + seed + fix frontend | Migration + queries.ts |
| C2 | `layanan_statistik` table missing | Buat tabel + seed + fix frontend | Migration + HomePage.tsx |
| C3 | `profil_desa` missing image cols | ALTER TABLE | Migration |
| C4 | `ref_aduan_kategori` table missing | Buat tabel + seed | Migration |
| C5 | TTE verification RLS blocks public | Public read policy | Migration |
| C6 | `site_settings` unverified | Check + create if missing | Migration |
| C7 | `site_navigation` unverified | Check + create if missing | Migration |

### Moderate
| # | Issue | Fix | File |
|---|-------|-----|------|
| M1 | `usulan_vote` RLS blocks public reads | Public read policy | Migration |
| M2 | `stunting_agregat` missing `bulan` | Add column + fix frontend | Migration + queries.ts |
| M3 | `surat_jenis` tenant UUID mismatch | Frontend use correct UUID | queries.ts |
| M4 | `langganan_wa` tenant_id column | Verify + add | Migration |
| M5 | `hero_slider` not integrated | Wire to homepage | HomePage.tsx |
| M6 | Service card random numbers | Replace with real query | HomePage.tsx |
| M7 | Sektor ekonomi hardcoded | Buat tabel + query | Migration + HomePage.tsx |
| M8 | `balita` no public read | Aggregate via posyandu_kunjungan | Migration |

### Minor
| # | Issue | Fix |
|---|-------|-----|
| m1 | `stunting_agregat` `bulan` vs `periode` type | Type alignment |
| m2 | `desa_pamong` extra type columns | Type cleanup |
| m3 | Seed data all zeros in data.ts | Remove hardcoded fallbacks |
| m4 | `telepon_darurat` field name mismatch | Align types |
| m5 | PBB RPC migration ordering | Verify 3-param version |
| m6 | `dashboard_agregat` duplicate fallback | Remove duplicate hardcodes |

---

## Execution Model

- **Subagent-driven** per task
- **Idempotent migrations** untuk semua DB changes
- **Verifikasi manual** tiap langkah sebelum commit
- Pipeline: Migration dibuat → di-run → dicek hasilnya → frontend fix → test → commit
