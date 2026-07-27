-- Migration: Add ref_topik_langganan table for WA subscription topics
-- This replaces hardcoded topic options in LanggananWaPage

CREATE TABLE IF NOT EXISTS public.ref_topik_langganan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  nama VARCHAR(100) NOT NULL,
  emoji VARCHAR(10),
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_ref_topik_langganan_updated
  BEFORE UPDATE ON public.ref_topik_langganan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX idx_ref_topik_langganan_tenant ON public.ref_topik_langganan(tenant_id, aktif, urutan);

GRANT SELECT ON public.ref_topik_langganan TO anon, authenticated;
GRANT ALL ON public.ref_topik_langganan TO service_role;

ALTER TABLE public.ref_topik_langganan ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  CREATE POLICY "Public read ref_topik_langganan" ON public.ref_topik_langganan
    FOR SELECT TO anon, authenticated USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  CREATE POLICY "Admin write ref_topik_langganan" ON public.ref_topik_langganan
    FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin'))
    WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Seed default topics (no tenant_id = global defaults)
INSERT INTO public.ref_topik_langganan (nama, emoji, urutan, aktif) VALUES
  ('Agenda & Musdes', '📅', 1, true),
  ('Pengumuman Resmi', '📢', 2, true),
  ('Berita Desa', '📰', 3, true),
  ('Info Bencana', '⚠️', 4, true),
  ('Layanan & PBB', '📋', 5, true)
ON CONFLICT DO NOTHING;
