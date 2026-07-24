-- ============================================================
-- Migration: 20260724190003_create_penduduk_views_and_admin_rls.sql
-- Create penduduk_statistik + penduduk_per_dusun views
-- Add admin RLS policy with has_role for penduduk and keluarga
--
-- ROOT CAUSE:
-- - Views for statistik dashboard don't exist
-- - RLS policies need admin bypass via has_role()
--
-- Idempotent: DROP VIEW IF EXISTS + CREATE OR REPLACE
-- Admin policies: DROP IF EXISTS + CREATE (safe to re-run)
-- ============================================================

-- 1. penduduk_statistik view — aggregate statistics per tenant
DROP VIEW IF EXISTS public.penduduk_statistik;
CREATE VIEW public.penduduk_statistik AS
SELECT
  p.tenant_id,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup') AS jumlah_penduduk,
  COUNT(DISTINCT k.id) FILTER (WHERE k.id IS NOT NULL) AS jumlah_kk,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'L') AS laki_laki,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'P') AS perempuan,
  COUNT(DISTINCT p.dusun) FILTER (WHERE p.dusun IS NOT NULL) AS jumlah_dusun
FROM public.penduduk p
LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
WHERE p.status_hidup IN ('hidup', 'meninggal', 'pindah')
GROUP BY p.tenant_id;

-- 2. penduduk_per_dusun view — population breakdown by dusun
DROP VIEW IF EXISTS public.penduduk_per_dusun;
CREATE VIEW public.penduduk_per_dusun AS
SELECT
  p.tenant_id,
  p.dusun,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup') AS jumlah_penduduk,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'L') AS laki_laki,
  COUNT(*) FILTER (WHERE p.status_hidup = 'hidup' AND p.jenis_kelamin = 'P') AS perempuan,
  COUNT(DISTINCT k.id) FILTER (WHERE k.id IS NOT NULL) AS jumlah_kk
FROM public.penduduk p
LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
WHERE p.dusun IS NOT NULL
GROUP BY p.tenant_id, p.dusun;

-- 3. Grant SELECT on views to anon + authenticated
GRANT SELECT ON public.penduduk_statistik TO anon, authenticated;
GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;

-- 4. Admin RLS policy for penduduk — authenticated users with admin role bypass tenant isolation
DROP POLICY IF EXISTS "Admin full access to penduduk" ON public.penduduk;
CREATE POLICY "Admin full access to penduduk"
  ON public.penduduk FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- 5. Admin RLS policy for keluarga
DROP POLICY IF EXISTS "Admin full access to keluarga" ON public.keluarga;
CREATE POLICY "Admin full access to keluarga"
  ON public.keluarga FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));
