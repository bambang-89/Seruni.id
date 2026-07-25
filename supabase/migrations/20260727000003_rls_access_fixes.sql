-- ============================================================
-- 20260727000003_rls_access_fixes.sql
-- ============================================================

-- TTE verification public read
DO $$
BEGIN
  CREATE POLICY "tte_signatures_public_read" ON public.tte_signatures FOR SELECT USING (status = 'signed');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  CREATE POLICY "surat_terbit_public_read" ON public.surat_terbit FOR SELECT USING (status = 'signed');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- usulan_vote public read
DO $$
BEGIN
  CREATE POLICY "usulan_vote_public_read" ON public.usulan_vote FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- posyandu_kunjungan public read
DO $$
BEGIN
  CREATE POLICY "posyandu_kunjungan_public_read" ON public.posyandu_kunjungan FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
