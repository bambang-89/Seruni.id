-- Alter ref_kecamatan and ref_desa to accommodate 7 and 10 character codes from Kemendagri API

ALTER TABLE public.ref_kecamatan ALTER COLUMN kode TYPE VARCHAR(10);
ALTER TABLE public.ref_desa ALTER COLUMN kode_kecamatan TYPE VARCHAR(10);
