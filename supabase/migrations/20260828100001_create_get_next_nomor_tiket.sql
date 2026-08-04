-- =============================================================
-- FIX CRITICAL BUG-1: Definisikan fungsi RPC get_next_nomor_tiket
-- Fungsi ini digunakan oleh:
--   1. api/submit-surat.ts (Vercel Edge)
--   2. supabase/functions/submit-surat/index.ts (Supabase Edge)
-- Tabel surat_tiket_seq sudah dibuat di 20260728000002_create_surat_tiket_seq.sql
-- =============================================================

-- Pastikan tabel surat_tiket_seq ada (idempotent)
CREATE TABLE IF NOT EXISTS public.surat_tiket_seq (
  prefix       TEXT NOT NULL,
  tahun_bulan  TEXT NOT NULL,
  seq          INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (prefix, tahun_bulan)
);

-- Pastikan row default ada untuk SRT-
INSERT INTO public.surat_tiket_seq (prefix, tahun_bulan, seq)
VALUES ('SRT-', to_char(now(), 'YYYYMM'), 0)
ON CONFLICT (prefix, tahun_bulan) DO NOTHING;

-- Buat atau ganti fungsi get_next_nomor_tiket
-- Format output: SRT-202607-0001 (prefix + tahun bulan + 4 digit seq)
CREATE OR REPLACE FUNCTION public.get_next_nomor_tiket(
  p_prefix TEXT DEFAULT 'SRT-'
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tahun_bulan TEXT;
  v_seq         INTEGER;
  v_nomor       TEXT;
BEGIN
  -- Format tahun-bulan saat ini
  v_tahun_bulan := to_char(now() AT TIME ZONE 'Asia/Makassar', 'YYYYMM');

  -- Pastikan row ada untuk kombinasi prefix + tahun_bulan ini
  INSERT INTO public.surat_tiket_seq (prefix, tahun_bulan, seq)
  VALUES (p_prefix, v_tahun_bulan, 0)
  ON CONFLICT (prefix, tahun_bulan) DO NOTHING;

  -- Atomically increment dan ambil nilai baru
  UPDATE public.surat_tiket_seq
  SET    seq = seq + 1
  WHERE  prefix      = p_prefix
    AND  tahun_bulan = v_tahun_bulan
  RETURNING seq INTO v_seq;

  -- Format: SRT-202607-0001
  v_nomor := p_prefix || v_tahun_bulan || '-' || lpad(v_seq::TEXT, 4, '0');

  RETURN v_nomor;
END;
$$;

-- Berikan akses execute kepada semua role yang dibutuhkan
GRANT EXECUTE ON FUNCTION public.get_next_nomor_tiket(TEXT)
  TO anon, authenticated, service_role;

-- Verifikasi fungsi bekerja (sanity check — tidak akan di-commit sebagai data)
DO $$
DECLARE v_test TEXT;
BEGIN
  SELECT public.get_next_nomor_tiket('TEST-') INTO v_test;
  IF v_test IS NULL THEN
    RAISE EXCEPTION 'get_next_nomor_tiket returned NULL — fungsi tidak berfungsi!';
  END IF;
  RAISE NOTICE 'get_next_nomor_tiket OK: %', v_test;
  -- Rollback test data agar seq tidak terbuang (reset seq test)
  DELETE FROM public.surat_tiket_seq WHERE prefix = 'TEST-';
END $$;
