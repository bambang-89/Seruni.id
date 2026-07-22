-- Harden cek_pbb: require NIK as second factor and mask PII in public output
DROP FUNCTION IF EXISTS public.cek_pbb(integer, text);

CREATE OR REPLACE FUNCTION public.cek_pbb(_tahun integer, _nop text, _nik text)
RETURNS TABLE(
  tahun integer,
  nop text,
  pbb_terutang numeric,
  jatuh_tempo date,
  status_bayar text,
  tanggal_bayar date
)
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT p.tahun, p.nop, p.pbb_terutang, p.jatuh_tempo, p.status_bayar, p.tanggal_bayar
  FROM public.pbb_tagihan p
  WHERE p.tahun = _tahun
    AND lower(trim(p.nop)) = lower(trim(_nop))
    AND p.wajib_pajak_nik IS NOT NULL
    AND regexp_replace(coalesce(p.wajib_pajak_nik,''), '\s', '', 'g') = regexp_replace(coalesce(_nik,''), '\s', '', 'g')
  LIMIT 1;
$function$;

REVOKE ALL ON FUNCTION public.cek_pbb(integer, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cek_pbb(integer, text, text) TO anon, authenticated;