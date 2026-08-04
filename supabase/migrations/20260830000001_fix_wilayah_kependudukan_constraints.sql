-- ============================================================
-- Migration: Fix Wilayah & Kependudukan Foreign Key Constraints
-- Zero Tolerance Goal: Ensure no orphan data, ON DELETE RESTRICT
-- ============================================================

-- 1. Add Geographical Cascading Foreign Keys with ON DELETE RESTRICT
ALTER TABLE public.ref_kabupaten DROP CONSTRAINT IF EXISTS fk_kabupaten_provinsi;
ALTER TABLE public.ref_kabupaten 
  ADD CONSTRAINT fk_kabupaten_provinsi FOREIGN KEY (kode_provinsi) REFERENCES public.ref_provinsi(kode) ON DELETE RESTRICT;

ALTER TABLE public.ref_kecamatan DROP CONSTRAINT IF EXISTS fk_kecamatan_kabupaten;
ALTER TABLE public.ref_kecamatan 
  ADD CONSTRAINT fk_kecamatan_kabupaten FOREIGN KEY (kode_kabupaten) REFERENCES public.ref_kabupaten(kode) ON DELETE RESTRICT;

ALTER TABLE public.ref_desa DROP CONSTRAINT IF EXISTS fk_desa_kecamatan;
ALTER TABLE public.ref_desa 
  ADD CONSTRAINT fk_desa_kecamatan FOREIGN KEY (kode_kecamatan) REFERENCES public.ref_kecamatan(kode) ON DELETE RESTRICT;


-- 2. Update Penduduk Foreign Keys to include ON DELETE RESTRICT
DO $$ BEGIN ALTER TABLE public.penduduk DROP CONSTRAINT IF EXISTS fk_penduduk_provinsi; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE public.penduduk DROP CONSTRAINT IF EXISTS fk_penduduk_kabupaten; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE public.penduduk DROP CONSTRAINT IF EXISTS fk_penduduk_kecamatan; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE public.penduduk DROP CONSTRAINT IF EXISTS fk_penduduk_desa; EXCEPTION WHEN OTHERS THEN NULL; END $$;

ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_provinsi
  FOREIGN KEY (provinsi_id) REFERENCES public.ref_provinsi(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_kabupaten
  FOREIGN KEY (kabupaten_id) REFERENCES public.ref_kabupaten(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_kecamatan
  FOREIGN KEY (kecamatan_id) REFERENCES public.ref_kecamatan(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE public.penduduk ADD CONSTRAINT fk_penduduk_desa
  FOREIGN KEY (desa_id) REFERENCES public.ref_desa(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


