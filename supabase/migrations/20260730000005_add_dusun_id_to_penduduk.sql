---

-- Create dusun_id in penduduk
ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS dusun_id UUID REFERENCES public.ref_dusun(id);

-- Backfill dusun_id based on dusun name match
UPDATE public.penduduk p
SET dusun_id = rd.id
FROM public.ref_dusun rd
WHERE lower(p.dusun) = lower(rd.nama)
  AND p.dusun_id IS NULL;

-- Check result
SELECT 
  (SELECT COUNT(*) FROM public.penduduk WHERE dusun_id IS NOT NULL) as with_dusun_id,
  (SELECT COUNT(*) FROM public.penduduk WHERE dusun_id IS NULL AND dusun IS NOT NULL) as still_null,
  (SELECT COUNT(*) FROM public.penduduk WHERE dusun IS NULL) as no_dusun_text;

