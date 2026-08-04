-- Migration to update site_settings and tenants for new Umum configuration

ALTER TABLE public.site_settings
ADD COLUMN IF NOT EXISTS website text,
ADD COLUMN IF NOT EXISTS kodepos text,
ADD COLUMN IF NOT EXISTS dusun text,
ADD COLUMN IF NOT EXISTS rt text;

ALTER TABLE public.tenants
ADD COLUMN IF NOT EXISTS logo_kabupaten_url text,
ADD COLUMN IF NOT EXISTS logo_provinsi_url text;

-- Create surat_template table
CREATE TABLE IF NOT EXISTS public.surat_template (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE,
    format_nomor text DEFAULT '[kode_surat]/[nomor]/KDS.SRMB/[bulan_romawi]/[tahun]',
    pejabat_nama text,
    pejabat_jabatan text,
    penutup_teks text DEFAULT 'Demikian Surat Keterangan ini dibuat dengan sebenarnya untuk dapat dipergunakan sebagaimana mestinya.',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    UNIQUE(tenant_id)
);
