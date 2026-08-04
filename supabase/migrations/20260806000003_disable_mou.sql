-- Nonaktifkan MoU/PKS karena tidak cocok dilayani di portal publik
-- Tanggal: 2026-08-06

UPDATE public.surat_jenis SET aktif = false WHERE kode_surat = '140.4';
