-- ============================================================
-- FIX RLS PUBLIC ACCESS (Idempotent — safe to run multiple times)
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql
--
-- Root causes:
-- 1. has_role() function needs GRANT EXECUTE TO anon
-- 2. site_settings: policy "TO authenticated" blocks anon
-- 3. idm_status_desa: no public read policy
-- 4. Tables using has_role() fail for anon due to missing GRANT
-- ============================================================

-- 1. Allow anon to execute has_role() function
GRANT EXECUTE ON FUNCTION public.has_role(UUID, public.app_role) TO anon;

-- 2. site_settings — replace existing policy with public read
DROP POLICY IF EXISTS "Public read site_settings" ON public.site_settings;
DROP POLICY IF EXISTS "Service can manage site_settings" ON public.site_settings;
CREATE POLICY "Public read site_settings"
  ON public.site_settings FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Service can manage site_settings"
  ON public.site_settings FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id());
GRANT SELECT ON public.site_settings TO anon;

-- 3. idm_status_desa — add public read policy
DROP POLICY IF EXISTS "idm_status_desa_public_read" ON public.idm_status_desa;
CREATE POLICY "idm_status_desa_public_read"
  ON public.idm_status_desa FOR SELECT TO anon, authenticated USING (true);
GRANT SELECT ON public.idm_status_desa TO anon;

-- 4. berita — replace existing policies with public read
DROP POLICY IF EXISTS "Public read berita" ON public.berita;
DROP POLICY IF EXISTS "Admin write berita" ON public.berita;
CREATE POLICY "Public read berita"
  ON public.berita FOR SELECT TO anon, authenticated
  USING (published = true OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admin write berita"
  ON public.berita FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.berita TO anon;

-- 5. surat_jenis — public read (aktif=true only)
DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_select" ON public.surat_jenis;
CREATE POLICY "surat_jenis_public_read"
  ON public.surat_jenis FOR SELECT TO anon, authenticated USING (aktif = true);
GRANT SELECT ON public.surat_jenis TO anon;

DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_admin_write" ON public.surat_jenis;
CREATE POLICY "surat_jenis_admin_write"
  ON public.surat_jenis FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id());

-- 6. surat_jenis_dna — public read
DROP POLICY IF EXISTS "surat_jenis_dna_public_read" ON public.surat_jenis_dna;
DROP POLICY IF EXISTS "surat_jenis_dna_select" ON public.surat_jenis_dna;
DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna;
DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna;
CREATE POLICY "surat_jenis_dna_public_read"
  ON public.surat_jenis_dna FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "surat_jenis_dna_admin_write"
  ON public.surat_jenis_dna FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id());
GRANT SELECT ON public.surat_jenis_dna TO anon;

-- 7. potensi_umkm — public read (status='publish')
DROP POLICY IF EXISTS "Anyone can view published umkm" ON public.potensi_umkm;
CREATE POLICY "Anyone can view published umkm"
  ON public.potensi_umkm FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_umkm TO anon;

-- 8. potensi_produk — public read (status='publish')
DROP POLICY IF EXISTS "Anyone can view published produk" ON public.potensi_produk;
CREATE POLICY "Anyone can view published produk"
  ON public.potensi_produk FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_produk TO anon;

-- 9. potensi_wisata — public read (status='publish')
DROP POLICY IF EXISTS "Anyone can view published wisata" ON public.potensi_wisata;
CREATE POLICY "Anyone can view published wisata"
  ON public.potensi_wisata FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_wisata TO anon;

-- 10. usulan_warga — public read (verified status only)
DROP POLICY IF EXISTS "Anyone can view verified usulan" ON public.usulan_warga;
CREATE POLICY "Anyone can view verified usulan"
  ON public.usulan_warga FOR SELECT TO anon, authenticated
  USING (status IN ('diverifikasi', 'ditindaklanjuti', 'selesai')
         OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.usulan_warga TO anon;

-- 11. usulan_vote — public read
DROP POLICY IF EXISTS "Anyone can view votes" ON public.usulan_vote;
CREATE POLICY "Anyone can view votes"
  ON public.usulan_vote FOR SELECT TO anon, authenticated USING (true);
GRANT SELECT ON public.usulan_vote TO anon;
