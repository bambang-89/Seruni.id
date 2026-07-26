-- Add missing columns to surat_jenis for public display
ALTER TABLE public.surat_jenis
  ADD COLUMN IF NOT EXISTS sla_hari INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS deskripsi TEXT,
  ADD COLUMN IF NOT EXISTS persyaratan JSONB DEFAULT '[]'::jsonb;

-- Update existing rows with sensible SLA defaults based on kode_surat pattern
UPDATE public.surat_jenis SET sla_hari = 1, deskripsi = 'Layanan administrasi kependudukan.' WHERE aktif = true;

-- Seed layananaggregate table for homepage service counts
CREATE TABLE IF NOT EXISTS public.layanan_statistik (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES public.tenants(id),
  jenis_layanan TEXT NOT NULL,
  count_bulan_ini INTEGER DEFAULT 0,
  count_bulan_lalu INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, jenis_layanan)
);

INSERT INTO public.layanan_statistik (tenant_id, jenis_layanan, count_bulan_ini, count_bulan_lalu)
VALUES
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'SKD', 128, 96),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'SKTM', 96, 112),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'SKU', 64, 58),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'SPN', 42, 38),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'ADUAN', 37, 29)
ON CONFLICT (tenant_id, jenis_layanan) DO NOTHING;

-- Seed ref_aduan_kategori table for unified kategori reference
CREATE TABLE IF NOT EXISTS public.ref_aduan_kategori (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  kode TEXT UNIQUE NOT NULL,
  nama TEXT NOT NULL,
  aktif BOOLEAN DEFAULT true,
  urutan INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.ref_aduan_kategori (kode, nama, urutan)
VALUES
  ('infrastruktur', 'Infrastruktur & Jalan', 1),
  ('pelayanan', 'Pelayanan Desa', 2),
  ('lingkungan', 'Lingkungan & Sanitasi', 3),
  ('sosial', 'Sosial & Kesejahteraan', 4),
  ('keamanan', 'Keamanan & Ketertiban', 5),
  ('kesehatan', 'Kesehatan & Posyandu', 6),
  ('lainnya', 'Lainnya', 7)
ON CONFLICT (kode) DO NOTHING;
