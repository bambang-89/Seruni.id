# Panduan Migrasi Database Supabase — Seruni.id

## Prerequisites

- Akses ke [Supabase Dashboard](https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql)
- Role: `service_role` atau `postgres` (untuk migrasi schema)
- Buat backup sebelum menjalankan migrasi besar

---

## Langkah 1: Cek Status Migrasi Saat Ini

Jalankan query ini di SQL Editor untuk melihat apakah `tenant_id` sudah ada di tabel `penduduk`:

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'penduduk'
  AND table_schema = 'public'
ORDER BY ordinal_position;
```

Bandingkan hasilnya dengan kolom yang diharapkan:

| Kolom | Tipe | Wajib |
|---|---|---|
| id | uuid | ✓ |
| nik | text | ✓ |
| nama | text | ✓ |
| jenis_kelamin | text | ✓ |
| tempat_lahir | text | ✓ |
| tanggal_lahir | date | ✓ |
| agama | text | ✓ |
| pendidikan | text | ✓ |
| pekerjaan | text | ✓ |
| status_kawin | text | ✓ |
| hubungan_kk | text | ✓ |
| keluarga_id | uuid | ✓ |
| dusun | text | ✓ |
| alamat | text | ✓ |
| foto_url | text | ✓ |
| status_hidup | text | ✓ |
| catatan | text | ✓ |
| created_at | timestamptz | ✓ |
| updated_at | timestamptz | ✓ |
| bpjs_status | text | ✓ |
| bpjs_nomor | text | ✓ |
| rt | varchar | ✓ |
| rw | varchar | ✓ |
| nomor_hp | text | ✓ |
| created_by | uuid | ✓ |
| updated_by | uuid | ✓ |
| **tenant_id** | **uuid** | **✓ PENTING** |

---

## Langkah 2: Tambah Kolom `tenant_id` (Jika Belum Ada)

```sql
-- ============================================================
-- MIGRASI: 20260721000004_add_tenant_id.sql
-- Copy dari: supabase/migrations/20260721000004_add_tenant_id.sql
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

-- CORE TABLES
ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.penduduk SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.penduduk ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_penduduk_tenant ON public.penduduk(tenant_id);

ALTER TABLE public.keluarga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.keluarga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.keluarga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_keluarga_tenant ON public.keluarga(tenant_id);

-- (file lengkapnya di supabase/migrations/20260721000004_add_tenant_id.sql
--  yang menambahkan tenant_id ke 31 tabel)

END $$;
```

---

## Langkah 3: Cek Apakah Seed Sudah Jalan

```sql
-- Cek apakah data sudah ada
SELECT 'Keluarga' as jenis, count(*) as jumlah FROM public.keluarga
UNION ALL SELECT 'Penduduk', count(*) FROM public.penduduk
UNION ALL SELECT 'Laki-laki', count(*) FROM public.penduduk WHERE jenis_kelamin = 'L'
UNION ALL SELECT 'Perempuan', count(*) FROM public.penduduk WHERE jenis_kelamin = 'P';
```

**Jika jumlah Penduduk > 0** → Seed sudah jalan. Skip ke Langkah 5.

**Jika jumlah Penduduk = 0** → Seed belum jalan. Lanjut ke Langkah 4.

---

## Langkah 4: Jalankan Seed Migration

Jalankan file ini di SQL Editor (satu per satu):

```
1. supabase/migrations/20260722000009_seed_penduduk.sql
   → Seed 33 penduduk + 7 keluarga (profil seed)

2. supabase/migrations/20260721000001_seed_lengkap.sql
   → Seed 4 wilayah dusun, 85 jenis surat, data RPJMDes, RKPDes

3. supabase/migrations/20260723000001_seed_data_hardcoded.sql
   → Seed pamong desa, berita, media, IDM status
```

---

## Langkah 5: Import Data Penduduk dari Excel/CSV

File-file di `docs/sql_import/` berisi data penduduk lengkap (~700+ warga).

**Pilih salah satu metode:**

### Metode A: Jalankan Satu-Satu di SQL Editor

```sql
-- Copy isi file docs/sql_import/02_penduduk_001.sql ke SQL Editor
-- Jalankan
-- Ulangi untuk file 002, 003, ... sampai 017
```

### Metode B: Import via CSV ke Tabel Temporary

1. Buka file Excel/CSV original
2. Export ke format CSV UTF-8
3. Di Supabase Dashboard → Table Editor → `penduduk` → Import CSV
4. Pastikan kolom cocok dengan schema

### Metode C: Gabungkan Semua File Import

```bash
# Gabungkan semua file import jadi satu (di terminal/bash)
cat docs/sql_import/02_penduduk_*.sql | grep -v "^--" | grep -v "^$" > /tmp/all_penduduk.sql
```

---

## Langkah 6: Verifikasi

```sql
-- Statistik penduduk
SELECT
  count(*) as total_penduduk,
  count(distinct keluarga_id) as total_keluarga,
  count(distinct dusun) as total_dusun
FROM public.penduduk WHERE status_hidup = 'hidup';

-- Cek dusun
SELECT dusun, count(*) as jumlah FROM public.penduduk
WHERE status_hidup = 'hidup'
GROUP BY dusun ORDER BY dusun;

-- CekKK kosong (penduduk tanpa keluarga_id)
SELECT count(*) FROM public.penduduk WHERE keluarga_id IS NULL;
```

**Hasil yang diharapkan:**
- Total penduduk: ~500+ jiwa
- Total keluarga: ~100+ KK
- Total dusun: 4 (Mandar, Sasak, Dames, Brangtapen Asri)

---

## Troubleshooting

### Error: column "tenant_id" does not exist
Jalankan `supabase/migrations/20260721000004_add_tenant_id.sql` terlebih dahulu.

### Error: column "gol_darah_id" does not exist
Hapus kolom `gol_darah_id` dari INSERT statement (kolom ini tidak ada di schema). File `docs/sql_import/` sudah diperbaiki.

### Error: duplicate key value violates unique constraint on "nik"
Data sudah ada. Skip insert tersebut atau gunakan `ON CONFLICT (nik) DO NOTHING`.

### Error: insert or update on table "penduduk" violates row level security
Jalankan dengan role `service_role` atau matikan RLS sementara:

```sql
ALTER TABLE public.penduduk DISABLE ROW LEVEL SECURITY;
-- jalankan import --
ALTER TABLE public.penduduk ENABLE ROW LEVEL SECURITY;
```

---

## Urutan File Migrasi Lengkap

| Urutan | File | Fungsi |
|---|---|---|
| 1 | `20260719193922_*` | Schema dasar (penduduk, keluarga, dll) |
| 2 | `20260720100002_004_multi_tenancy.sql` | Buat tabel `tenants` |
| 3 | `20260721000004_add_tenant_id.sql` | Tambah tenant_id ke 31 tabel |
| 4 | `20260721000005_rls_tenant_policies.sql` | RLS policies per tenant |
| 5 | `20260722000009_seed_penduduk.sql` | Seed penduduk dasar |
| 6 | `20260721000001_seed_lengkap.sql` | Seed data lengkap |
| 7 | `20260723000001_seed_data_hardcoded.sql` | Seed pamong, berita |
| 8 | `docs/sql_import/02_penduduk_*.sql` | Import data penduduk besar |

---

## Catatan Penting

1. **Jangan jalankan seed 2x** — gunakan `ON CONFLICT ... DO NOTHING` atau cek keberadaan data terlebih dahulu
2. **Data penduduk di `docs/sql_import/`** lebih lengkap (~700+ jiwa) vs seed migration (~33 jiwa)
3. **Multi-tenancy**: semua data di-backfill ke tenant UUID `d532ae95-0ad9-42bb-a6e8-5c840447c90e` (Desa Seruni Mumbul)
