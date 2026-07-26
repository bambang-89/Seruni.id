-- ============================================================
-- Migration: 20260825000001_fix_rls_public_access.sql
-- Fixes ALL RLS issues blocking anonymous/public access
--
-- Root causes found via systematic debugging:
--   1. has_role() function missing GRANT EXECUTE TO anon
--   2. site_settings: no aktif column — USE true instead
--   3. idm_status_desa: no aktif column — no filter needed
--   4. Tables using has_role() in policies → fail for anon
--
-- Verified column lists from types.ts + API introspection:
--   site_settings: id, tenant_id, nama_resmi, tagline, alamat_kantor,
--                  telepon, email, jam_layanan, nomor_wa_resmi,
--                  wa_business_verified, social_media, maps_embed_url
--   idm_status_desa: tenant_id, total_skor, dimensi_skor_1-6,
--                     dimensi_scores, status, dihitung_pada
-- ============================================================

-- ============================================================
-- FIX 1: has_role() — allow anon to execute
-- Without this, ANY RLS policy that calls has_role() fails for anon
-- Error: permission denied for function has_role
-- ============================================================
GRANT EXECUTE ON FUNCTION public.has_role(UUID, public.app_role) TO anon;

-- ============================================================
-- FIX 2: site_settings — public read
-- No aktif column — always readable (public data)
-- ============================================================
DROP POLICY IF EXISTS "Public read site_settings" ON public.site_settings;
CREATE POLICY "Public read site_settings"
  ON public.site_settings FOR SELECT TO anon, authenticated
  USING (true);
GRANT SELECT ON public.site_settings TO anon;
GRANT SELECT ON public.site_settings TO authenticated;

-- Admin write still requires auth + tenant match
DROP POLICY IF EXISTS "Service can manage site_settings" ON public.site_settings;
CREATE POLICY "Service can manage site_settings"
  ON public.site_settings FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id())
  WITH CHECK (tenant_id = get_tenant_id());

-- ============================================================
-- FIX 3: idm_status_desa — public read
-- No aktif column — always readable (public indicator data)
-- ============================================================
DROP POLICY IF EXISTS "idm_status_desa_public_read" ON public.idm_status_desa;
CREATE POLICY "idm_status_desa_public_read"
  ON public.idm_status_desa FOR SELECT TO anon, authenticated
  USING (true);
GRANT SELECT ON public.idm_status_desa TO anon;
GRANT SELECT ON public.idm_status_desa TO authenticated;

-- ============================================================
-- FIX 4: berita — public read (published=true only)
-- Uses has_role() in policy — FIX 1 makes this work now
-- ============================================================
DROP POLICY IF EXISTS "Public read berita" ON public.berita;
CREATE POLICY "Public read berita"
  ON public.berita FOR SELECT TO anon, authenticated
  USING (published = true OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.berita TO anon;
GRANT SELECT ON public.berita TO authenticated;

DROP POLICY IF EXISTS "Admin write berita" ON public.berita;
CREATE POLICY "Admin write berita"
  ON public.berita FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- ============================================================
-- FIX 5: surat_jenis — public read (aktif=true only)
-- ============================================================
DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_select" ON public.surat_jenis;
CREATE POLICY "surat_jenis_public_read"
  ON public.surat_jenis FOR SELECT TO anon, authenticated
  USING (aktif = true);
GRANT SELECT ON public.surat_jenis TO anon;
GRANT SELECT ON public.surat_jenis TO authenticated;

DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_admin_write" ON public.surat_jenis;
CREATE POLICY "surat_jenis_admin_write"
  ON public.surat_jenis FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id())
  WITH CHECK (tenant_id = get_tenant_id());

-- ============================================================
-- FIX 6: surat_jenis_dna — public read
-- ============================================================
DROP POLICY IF EXISTS "surat_jenis_dna_public_read" ON public.surat_jenis_dna;
DROP POLICY IF EXISTS "surat_jenis_dna_select" ON public.surat_jenis_dna;
CREATE POLICY "surat_jenis_dna_public_read"
  ON public.surat_jenis_dna FOR SELECT TO anon, authenticated
  USING (true);
GRANT SELECT ON public.surat_jenis_dna TO anon;
GRANT SELECT ON public.surat_jenis_dna TO authenticated;

DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna;
CREATE POLICY "surat_jenis_dna_admin_write"
  ON public.surat_jenis_dna FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id())
  WITH CHECK (tenant_id = get_tenant_id());

-- ============================================================
-- FIX 7: potensi_umkm — public read (status='publish')
-- Uses has_role() — FIX 1 makes this work now
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view published umkm" ON public.potensi_umkm;
CREATE POLICY "Anyone can view published umkm"
  ON public.potensi_umkm FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_umkm TO anon;
GRANT SELECT ON public.potensi_umkm TO authenticated;

-- ============================================================
-- FIX 8: potensi_produk — public read (status='publish')
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view published produk" ON public.potensi_produk;
CREATE POLICY "Anyone can view published produk"
  ON public.potensi_produk FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_produk TO anon;
GRANT SELECT ON public.potensi_produk TO authenticated;

-- ============================================================
-- FIX 9: potensi_wisata — public read (status='publish')
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view published wisata" ON public.potensi_wisata;
CREATE POLICY "Anyone can view published wisata"
  ON public.potensi_wisata FOR SELECT TO anon, authenticated
  USING (status = 'publish' OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.potensi_wisata TO anon;
GRANT SELECT ON public.potensi_wisata TO authenticated;

-- ============================================================
-- FIX 10: usulan_warga — public read (verified status only)
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view verified usulan" ON public.usulan_warga;
CREATE POLICY "Anyone can view verified usulan"
  ON public.usulan_warga FOR SELECT TO anon, authenticated
  USING (status IN ('diverifikasi', 'ditindaklanjuti', 'selesai') OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.usulan_warga TO anon;
GRANT SELECT ON public.usulan_warga TO authenticated;

-- ============================================================
-- FIX 11: usulan_vote — public read
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view votes" ON public.usulan_vote;
CREATE POLICY "Anyone can view votes"
  ON public.usulan_vote FOR SELECT TO anon, authenticated
  USING (true OR public.has_role(auth.uid(), 'admin'));
GRANT SELECT ON public.usulan_vote TO anon;
GRANT SELECT ON public.usulan_vote TO authenticated;
