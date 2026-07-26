-- Migration: 20260804000002_add_pamong_ttd_qr.sql
-- Adds QR code and signature image columns to desa_pamong table

-- Add columns for TTE (Tanda Tangan Elektronik) support
ALTER TABLE public.desa_pamong
    ADD COLUMN IF NOT EXISTS qr_code_url TEXT,
    ADD COLUMN IF NOT EXISTS ttd_image_url TEXT,
    ADD COLUMN IF NOT EXISTS nip VARCHAR(50),
    ADD COLUMN IF NOT EXISTS aktif BOOLEAN NOT NULL DEFAULT true;

-- Add comment for documentation
COMMENT ON COLUMN public.desa_pamong.qr_code_url IS 'URL QR Code untuk verifikasi tanda tangan elektronik';
COMMENT ON COLUMN public.desa_pamong.ttd_image_url IS 'URL Gambar tanda tangan pejabat';
COMMENT ON COLUMN public.desa_pamong.nip IS 'NIP pejabat';
COMMENT ON COLUMN public.desa_pamong.aktif IS 'Apakah pamong masih aktif menjabat';

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_desa_pamong_aktif ON public.desa_pamong(aktif) WHERE aktif = true;
CREATE INDEX IF NOT EXISTS idx_desa_pamong_jabatan ON public.desa_pamong(jabatan);
