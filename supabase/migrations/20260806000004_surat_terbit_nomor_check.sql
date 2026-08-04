-- Constraint cek nomor_surat wajib jika status terbit
-- Tanggal: 2026-08-06

ALTER TABLE public.surat_terbit
ADD CONSTRAINT check_nomor_surat_terbit 
CHECK (
  (status NOT IN ('berlaku', 'kadaluarsa', 'dicabut')) OR (nomor_surat IS NOT NULL AND nomor_surat <> '')
);
