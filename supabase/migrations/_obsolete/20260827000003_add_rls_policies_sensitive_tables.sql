-- ============================================================
-- MIGRASI: 20260827000003_add_rls_policies_sensitive_tables.sql
-- Tanggal: 2026-08-27
-- Deskripsi: CRITICAL fix — add RLS SELECT/INSERT/UPDATE/DELETE policies
--            for tables that were missing them.
--
-- PROBLEM: perpustakaan_desa, buku_perpustakaan, pemilihan, calon_kades,
-- pbb_pembayaran, posyandu_balita, bencana_bantuan, user_profiles
-- had no RLS policies. This means authenticated users could access
-- ANY tenant's data in these tables without tenant isolation.
--
-- FIX: Enable RLS and add tenant-isolated policies for all listed tables.
--
-- PUBLIC TABLES (berita, agenda, pengumuman, galeri):
-- - NO SELECT policy (anyone can read public content)
-- - INSERT/UPDATE/DELETE only with matching tenant_id
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. perpustakaan_desa — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.perpustakaan_desa ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "perpustakaan_desa_tenant_select" ON public.perpustakaan_desa;
CREATE POLICY "perpustakaan_desa_tenant_select" ON public.perpustakaan_desa
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "perpustakaan_desa_tenant_insert" ON public.perpustakaan_desa;
CREATE POLICY "perpustakaan_desa_tenant_insert" ON public.perpustakaan_desa
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "perpustakaan_desa_tenant_update" ON public.perpustakaan_desa;
CREATE POLICY "perpustakaan_desa_tenant_update" ON public.perpustakaan_desa
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "perpustakaan_desa_tenant_delete" ON public.perpustakaan_desa;
CREATE POLICY "perpustakaan_desa_tenant_delete" ON public.perpustakaan_desa
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 2. buku_perpustakaan — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.buku_perpustakaan ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "buku_perpustakaan_tenant_select" ON public.buku_perpustakaan;
CREATE POLICY "buku_perpustakaan_tenant_select" ON public.buku_perpustakaan
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "buku_perpustakaan_tenant_insert" ON public.buku_perpustakaan;
CREATE POLICY "buku_perpustakaan_tenant_insert" ON public.buku_perpustakaan
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "buku_perpustakaan_tenant_update" ON public.buku_perpustakaan;
CREATE POLICY "buku_perpustakaan_tenant_update" ON public.buku_perpustakaan
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "buku_perpustakaan_tenant_delete" ON public.buku_perpustakaan;
CREATE POLICY "buku_perpustakaan_tenant_delete" ON public.buku_perpustakaan
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 3. pemilihan — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.pemilihan ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pemilihan_tenant_select" ON public.pemilihan;
CREATE POLICY "pemilihan_tenant_select" ON public.pemilihan
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pemilihan_tenant_insert" ON public.pemilihan;
CREATE POLICY "pemilihan_tenant_insert" ON public.pemilihan
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pemilihan_tenant_update" ON public.pemilihan;
CREATE POLICY "pemilihan_tenant_update" ON public.pemilihan
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pemilihan_tenant_delete" ON public.pemilihan;
CREATE POLICY "pemilihan_tenant_delete" ON public.pemilihan
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 4. calon_kades — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.calon_kades ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "calon_kades_tenant_select" ON public.calon_kades;
CREATE POLICY "calon_kades_tenant_select" ON public.calon_kades
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "calon_kades_tenant_insert" ON public.calon_kades;
CREATE POLICY "calon_kades_tenant_insert" ON public.calon_kades
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "calon_kades_tenant_update" ON public.calon_kades;
CREATE POLICY "calon_kades_tenant_update" ON public.calon_kades
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "calon_kades_tenant_delete" ON public.calon_kades;
CREATE POLICY "calon_kades_tenant_delete" ON public.calon_kades
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 5. pbb_pembayaran — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.pbb_pembayaran ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pbb_pembayaran_tenant_select" ON public.pbb_pembayaran;
CREATE POLICY "pbb_pembayaran_tenant_select" ON public.pbb_pembayaran
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pbb_pembayaran_tenant_insert" ON public.pbb_pembayaran;
CREATE POLICY "pbb_pembayaran_tenant_insert" ON public.pbb_pembayaran
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pbb_pembayaran_tenant_update" ON public.pbb_pembayaran;
CREATE POLICY "pbb_pembayaran_tenant_update" ON public.pbb_pembayaran
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pbb_pembayaran_tenant_delete" ON public.pbb_pembayaran;
CREATE POLICY "pbb_pembayaran_tenant_delete" ON public.pbb_pembayaran
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 6. posyandu_balita — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.posyandu_balita ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "posyandu_balita_tenant_select" ON public.posyandu_balita;
CREATE POLICY "posyandu_balita_tenant_select" ON public.posyandu_balita
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "posyandu_balita_tenant_insert" ON public.posyandu_balita;
CREATE POLICY "posyandu_balita_tenant_insert" ON public.posyandu_balita
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "posyandu_balita_tenant_update" ON public.posyandu_balita;
CREATE POLICY "posyandu_balita_tenant_update" ON public.posyandu_balita
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "posyandu_balita_tenant_delete" ON public.posyandu_balita;
CREATE POLICY "posyandu_balita_tenant_delete" ON public.posyandu_balita
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 7. bencana_bantuan — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.bencana_bantuan ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bencana_bantuan_tenant_select" ON public.bencana_bantuan;
CREATE POLICY "bencana_bantuan_tenant_select" ON public.bencana_bantuan
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "bencana_bantuan_tenant_insert" ON public.bencana_bantuan;
CREATE POLICY "bencana_bantuan_tenant_insert" ON public.bencana_bantuan
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "bencana_bantuan_tenant_update" ON public.bencana_bantuan;
CREATE POLICY "bencana_bantuan_tenant_update" ON public.bencana_bantuan
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "bencana_bantuan_tenant_delete" ON public.bencana_bantuan;
CREATE POLICY "bencana_bantuan_tenant_delete" ON public.bencana_bantuan
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 8. user_profiles — RLS policies
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_profiles_tenant_select" ON public.user_profiles;
CREATE POLICY "user_profiles_tenant_select" ON public.user_profiles
  FOR SELECT USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "user_profiles_tenant_insert" ON public.user_profiles;
CREATE POLICY "user_profiles_tenant_insert" ON public.user_profiles
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "user_profiles_tenant_update" ON public.user_profiles;
CREATE POLICY "user_profiles_tenant_update" ON public.user_profiles
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "user_profiles_tenant_delete" ON public.user_profiles;
CREATE POLICY "user_profiles_tenant_delete" ON public.user_profiles
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 9. berita — INSERT/UPDATE/DELETE only (public SELECT)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.berita ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "berita_tenant_insert" ON public.berita;
CREATE POLICY "berita_tenant_insert" ON public.berita
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "berita_tenant_update" ON public.berita;
CREATE POLICY "berita_tenant_update" ON public.berita
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "berita_tenant_delete" ON public.berita;
CREATE POLICY "berita_tenant_delete" ON public.berita
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 10. agenda — INSERT/UPDATE/DELETE only (public SELECT)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "agenda_tenant_insert" ON public.agenda;
CREATE POLICY "agenda_tenant_insert" ON public.agenda
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "agenda_tenant_update" ON public.agenda;
CREATE POLICY "agenda_tenant_update" ON public.agenda
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "agenda_tenant_delete" ON public.agenda;
CREATE POLICY "agenda_tenant_delete" ON public.agenda
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 11. pengumuman — INSERT/UPDATE/DELETE only (public SELECT)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.pengumuman ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pengumuman_tenant_insert" ON public.pengumuman;
CREATE POLICY "pengumuman_tenant_insert" ON public.pengumuman
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pengumuman_tenant_update" ON public.pengumuman;
CREATE POLICY "pengumuman_tenant_update" ON public.pengumuman
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "pengumuman_tenant_delete" ON public.pengumuman;
CREATE POLICY "pengumuman_tenant_delete" ON public.pengumuman
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- 12. galeri — INSERT/UPDATE/DELETE only (public SELECT)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.galeri ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "galeri_tenant_insert" ON public.galeri;
CREATE POLICY "galeri_tenant_insert" ON public.galeri
  FOR INSERT WITH CHECK (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "galeri_tenant_update" ON public.galeri;
CREATE POLICY "galeri_tenant_update" ON public.galeri
  FOR UPDATE USING (tenant_filter(tenant_id));

DROP POLICY IF EXISTS "galeri_tenant_delete" ON public.galeri;
CREATE POLICY "galeri_tenant_delete" ON public.galeri
  FOR DELETE USING (tenant_filter(tenant_id));

-- ─────────────────────────────────────────────────────────────
-- Verification query (run in Supabase SQL editor):
--
-- SELECT tablename, rowsecurity, polname, polcmd
-- FROM pg_tables t
-- JOIN pg_policy p ON p.polrelid = t.tablename::regclass
-- WHERE schemaname = 'public'
--   AND tablename IN (
--     'perpustakaan_desa','buku_perpustakaan','pemilihan','calon_kades',
--     'pbb_pembayaran','posyandu_balita','bencana_bantuan','user_profiles',
--     'berita','agenda','pengumuman','galeri'
--   )
-- ORDER BY tablename, polcmd;
-- ─────────────────────────────────────────────────────────────
