-- Memenuhi instruksi Zero Tolerance: Hapus semua data dummy ujicoba pada sistem Surat
-- Hapus data surat ajuan dan data pengajuannya secara kaskade
TRUNCATE TABLE surat_ajuan_data CASCADE;
TRUNCATE TABLE surat_ajuan CASCADE;
-- Hapus data surat yang telah terbit (arsip)
TRUNCATE TABLE surat_terbit CASCADE;
