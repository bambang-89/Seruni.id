-- ============================================================
-- MIGRATION: 20260805000006_drop_unused_tables.sql
-- Tanggal: 2026-08-05
-- Deskripsi: Menghapus tabel yang tidak relevan dan tidak digunakan
-- ============================================================

DROP TABLE IF EXISTS public.bansos_penerima CASCADE;
DROP TABLE IF EXISTS public.ref_upload_preferences_seed CASCADE;
