-- ============================================================
-- MIGRASI: 20260828000001_page_hero_config.sql
-- Tanggal: 2026-08-28
-- Deskripsi: Membuat tabel page_hero_config untuk manajemen Hero image/video dan teks
-- ============================================================

CREATE TABLE IF NOT EXISTS page_hero_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    page_route VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    subtitle TEXT,
    image_path TEXT,
    video_path TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(tenant_id, page_route)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_page_hero_config_tenant ON page_hero_config(tenant_id);
CREATE INDEX IF NOT EXISTS idx_page_hero_config_route ON page_hero_config(page_route);

-- Trigger updated_at (use set_updated_at which already exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'page_hero_config_updated' AND tgrelid = 'public.page_hero_config'::regclass) THEN
        CREATE TRIGGER page_hero_config_updated
        BEFORE UPDATE ON page_hero_config
        FOR EACH ROW
        EXECUTE FUNCTION public.set_updated_at();
    END IF;
END $$;

-- Enable RLS
ALTER TABLE page_hero_config ENABLE ROW LEVEL SECURITY;

-- Policy: Admin can do anything (use has_role(UUID,TEXT) which will be created by 20260830000000)
-- For now, use inline logic with user_peran table
DO $$
BEGIN
  CREATE POLICY "Admin dapat mengelola page_hero_config" ON public.page_hero_config
    FOR ALL
    USING (
      EXISTS (
        SELECT 1 FROM public.user_peran
        WHERE user_id = auth.uid()
          AND peran = 'admin'
          AND tenant_id = page_hero_config.tenant_id
      )
    )
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM public.user_peran
        WHERE user_id = auth.uid()
          AND peran = 'admin'
          AND tenant_id = page_hero_config.tenant_id
      )
    );
EXCEPTION WHEN OTHERS THEN
  -- Policy may already exist from a previous run attempt
  RAISE NOTICE 'Policy creation skipped: %', SQLERRM;
END $$;

-- Policy: Public (anon/authenticated) can read active configs
DO $$
BEGIN
  CREATE POLICY "Publik dapat melihat page_hero_config" ON public.page_hero_config
    FOR SELECT
    USING (is_active = true);
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Policy creation skipped: %', SQLERRM;
END $$;

-- Add to replication publication if not exists
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE page_hero_config;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
