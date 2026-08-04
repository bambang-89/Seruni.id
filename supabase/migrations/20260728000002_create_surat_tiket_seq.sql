-- Fix CRITICAL: Create missing surat_tiket_seq table
-- The RPC function get_next_nomor_tiket uses this table but it doesn't exist,
-- causing all surat ajuan submissions to fail with "Gagal menghasilkan nomor tiket"

CREATE TABLE IF NOT EXISTS public.surat_tiket_seq (
  prefix        TEXT        NOT NULL,
  tahun_bulan  TEXT        NOT NULL,
  seq          INTEGER     NOT NULL DEFAULT 0,
  PRIMARY KEY (prefix, tahun_bulan)
);

-- Initialize with default prefixes used by the system
INSERT INTO public.surat_tiket_seq (prefix, tahun_bulan, seq) VALUES
  ('SRT-', to_char(now(), 'YYYYMM'), 0)
ON CONFLICT (prefix, tahun_bulan) DO NOTHING;
