-- Migration: 20260725000001_widen_desa_kode.sql
-- Widen ref_desa.kode to VARCHAR(13) to support 10-digit KEMENDAGRI village codes
ALTER TABLE public.ref_desa ALTER COLUMN kode TYPE VARCHAR(13);
