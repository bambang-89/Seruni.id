# MIGRASI KE SUPABASE - LANGKAH-LANGKAH

## Prerequisites
- Akun Supabase (supabase.com)
- Project sudah dibuat

## Langkah 1: Buat Database Schema

1. Buka https://supabase.com/dashboard/project/smmngqdpbmgcdbmkiuviq/sql

2. Copy-paste isi file `docs/supabase_migration_all.sql` ke SQL Editor

3. Klik **RUN** untuk execute semua schema

## Langkah 2: Import Data Penduduk

1. Buka SQL Editor lagi

2. Copy-paste isi file `docs/sql_import/00_schema.sql` → RUN

3. Copy-paste isi file `docs/sql_import/01_keluarga.sql` → RUN

4. Untuk setiap file `02_penduduk_XXX.sql` (001-017):
   - Copy-paste → RUN
   - Tunggu sampai selesai sebelum next

5. Copy-paste isi file `docs/sql_import/99_verify.sql` → RUN

## Langkah 3: Verifikasi

Setelah semua SQL dijalankan, cek hasilnya:

```sql
-- Statistik Penduduk
SELECT * FROM public.penduduk_statistik;

-- Per-Dusun
SELECT * FROM public.penduduk_per_dusun;
```

Harus menghasilkan:
- Total penduduk: ~8,027
- Total KK: ~2,475
- 4 dusun

## Langkah 4: Update Environment

File `.env` dan `next-app/.env.local` sudah diupdate dengan credentials baru.

## Troubleshooting

### Error: "relation does not exist"
Schema belum di-run. Pastikan jalankan `supabase_migration_all.sql` dulu.

### Error: "permission denied"
Cek apakah sudah login ke Supabase Dashboard yang benar.

### Error: timeout saat import data
Jalankan file penduduk dalam batch kecil (bukan 1 file besar).

## File yang Dibutuhkan

```
docs/
├── supabase_migration_all.sql    <- Schema lengkap (JALANKAN PERTAMA)
└── sql_import/
    ├── 00_schema.sql             <- Schema keluarga & penduduk
    ├── 01_keluarga.sql          <- 2,475 KK
    ├── 02_penduduk_001.sql      <- Batch 1 (1-500)
    ├── 02_penduduk_002.sql      <- Batch 2 (501-1000)
    ├── ... (sampai 017)
    ├── 02_penduduk_017.sql      <- Batch 17 (8001-8027)
    └── 99_verify.sql             <- Verifikasi
```
