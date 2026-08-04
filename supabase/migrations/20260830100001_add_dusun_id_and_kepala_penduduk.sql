-- Migration: Add dusun_id to penduduk, kepala_penduduk_id to keluarga
-- Needed for full relational integrity with ref_dusun

-- 1. Add dusun_id FK to penduduk
ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS dusun_id UUID REFERENCES public.ref_dusun(id) ON DELETE SET NULL;

-- 2. Add kepala_penduduk_id FK to keluarga
ALTER TABLE public.keluarga
  ADD COLUMN IF NOT EXISTS kepala_penduduk_id UUID REFERENCES public.penduduk(id) ON DELETE SET NULL;

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_penduduk_dusun_id  ON public.penduduk(dusun_id);
CREATE INDEX IF NOT EXISTS idx_keluarga_kepala_id ON public.keluarga(kepala_penduduk_id);

-- 4. Backfill dusun_id for existing rows (match by name)
UPDATE public.penduduk p
SET dusun_id = rd.id
FROM public.ref_dusun rd
WHERE lower(p.dusun) = lower(rd.nama)
  AND p.dusun_id IS NULL;
