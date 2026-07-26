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

-- Trigger updated_at
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'page_hero_config_updated' AND tgrelid = 'public.page_hero_config'::regclass) THEN
        CREATE TRIGGER page_hero_config_updated
        BEFORE UPDATE ON page_hero_config
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Enable RLS
ALTER TABLE page_hero_config ENABLE ROW LEVEL SECURITY;

-- Policy: Admin can do anything
CREATE POLICY "Admin dapat mengelola page_hero_config"
    ON page_hero_config
    FOR ALL
    USING (
        auth.uid() IN (SELECT id FROM users WHERE tenant_id = page_hero_config.tenant_id AND peran = 'admin')
    );

-- Policy: Public (anon/authenticated) can read active configs
CREATE POLICY "Publik dapat melihat page_hero_config"
    ON page_hero_config
    FOR SELECT
    USING (is_active = true);

-- Add to replication publication if not exists (for realtime/sync)
DO $$
BEGIN
    -- Only if we need to sync it to clients (optional, but good for CMS)
    ALTER PUBLICATION supabase_realtime ADD TABLE page_hero_config;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
