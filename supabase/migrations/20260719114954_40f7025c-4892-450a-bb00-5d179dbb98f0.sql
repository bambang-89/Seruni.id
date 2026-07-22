
-- Tighten anon insert policy so it isn't a bare USING (true)
DROP POLICY IF EXISTS "aduan_public_insert" ON public.aduan_warga;
DROP POLICY IF EXISTS "aduan_public_insert_auth" ON public.aduan_warga;

CREATE POLICY "aduan_public_insert" ON public.aduan_warga FOR INSERT TO anon
  WITH CHECK (
    char_length(trim(nama_pelapor)) BETWEEN 2 AND 120
    AND char_length(trim(kontak)) BETWEEN 4 AND 60
    AND char_length(trim(judul)) BETWEEN 4 AND 160
    AND char_length(trim(isi)) BETWEEN 10 AND 4000
    AND status = 'diajukan'
  );

CREATE POLICY "aduan_auth_insert" ON public.aduan_warga FOR INSERT TO authenticated
  WITH CHECK (
    char_length(trim(nama_pelapor)) BETWEEN 2 AND 120
    AND char_length(trim(kontak)) BETWEEN 4 AND 60
    AND char_length(trim(judul)) BETWEEN 4 AND 160
    AND char_length(trim(isi)) BETWEEN 10 AND 4000
  );

-- Lock down SECURITY DEFINER trigger function so it can't be invoked from Data API
REVOKE EXECUTE ON FUNCTION public.log_status_change() FROM PUBLIC, anon, authenticated;
