-- Fix surat_template schema mismatches to align with AdminTemplateSurat.tsx
-- Tanggal: 2026-08-06

ALTER TABLE public.surat_template 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS format_nomor VARCHAR(255) DEFAULT '[kode_surat]/[nomor]/[singkatan_kades].[singkatan_desa]/[bulan_romawi]/[tahun]',
ADD COLUMN IF NOT EXISTS pejabat_nama VARCHAR(255),
ADD COLUMN IF NOT EXISTS pejabat_jabatan VARCHAR(255) DEFAULT 'Kepala Desa',
ADD COLUMN IF NOT EXISTS penutup_teks TEXT DEFAULT 'Demikian Surat Keterangan ini dibuat dengan sebenarnya untuk dapat dipergunakan sebagaimana mestinya.';

DO $DO$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NOT NULL THEN
    UPDATE public.surat_template SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
  END IF;
END $DO$;
