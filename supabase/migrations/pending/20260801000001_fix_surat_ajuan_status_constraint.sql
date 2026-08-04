-- ================================================================
-- MIGRATION: Fix surat_ajuan status constraint
-- Tanggal: 2026-08-01
-- Masalah: DB hanya mengizinkan menunggu/diproses/ditolak
--          Padahal UI menggunakan 5 status alur lengkap
-- ================================================================

-- Drop constraint lama yang terlalu ketat
ALTER TABLE public.surat_ajuan 
  DROP CONSTRAINT IF EXISTS surat_ajuan_status_check;

-- Tambah constraint baru sesuai alur UI:
-- Submit → Verifikasi → TTE → Kirim → Selesai (atau Ditolak)
ALTER TABLE public.surat_ajuan
  ADD CONSTRAINT surat_ajuan_status_check 
  CHECK (status IN (
    'menunggu',        -- Tab "Verifikasi"    : baru disubmit warga
    'diproses',        -- Backward compat lama
    'diverifikasi',    -- Tab "TTE"           : lolos verifikasi admin
    'ditandatangani',  -- Tab "Kirim"         : sudah ditandatangani
    'selesai',         -- Tab "Selesai"       : sudah dikirim ke warga
    'ditolak'          -- Tab "Ditolak"       : tidak lolos
  ));
