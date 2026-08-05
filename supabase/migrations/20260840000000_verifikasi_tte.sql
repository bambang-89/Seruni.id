-- 1. Create table surat_persyaratan
CREATE TABLE IF NOT EXISTS public.surat_persyaratan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    surat_jenis_id UUID NOT NULL REFERENCES public.surat_jenis(id) ON DELETE CASCADE,
    nama_persyaratan TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.surat_persyaratan ENABLE ROW LEVEL SECURITY;

-- Create Policies for Admin
CREATE POLICY "Admin dapat melihat persyaratan" ON public.surat_persyaratan
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pengguna 
            WHERE pengguna.id = auth.uid() 
            AND pengguna.tenant_id = surat_persyaratan.tenant_id
        )
    );

CREATE POLICY "Admin dapat mengelola persyaratan" ON public.surat_persyaratan
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.pengguna 
            WHERE pengguna.id = auth.uid() 
            AND pengguna.peran = 'admin' 
            AND pengguna.tenant_id = surat_persyaratan.tenant_id
        )
    );

-- Trigger updated_at
CREATE TRIGGER set_updated_at_surat_persyaratan
BEFORE UPDATE ON public.surat_persyaratan
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- 2. Alter table surat_ajuan
ALTER TABLE public.surat_ajuan
ADD COLUMN IF NOT EXISTS keterangan_penolakan TEXT;
