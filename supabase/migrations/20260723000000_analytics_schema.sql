-- Analytics Events Table
-- Stores page views and custom events

CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    event VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL DEFAULT 'page_view', -- page_view, click, form_submit, error
    path VARCHAR(500),
    referrer VARCHAR(1000),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    session_id VARCHAR(100),
    user_agent TEXT,
    screen_width INTEGER,
    screen_height INTEGER,
    ip_hash VARCHAR(64), -- Hashed IP for privacy
    properties JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for fast queries
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_events_path ON analytics_events(path);
CREATE INDEX IF NOT EXISTS idx_analytics_events_tenant ON analytics_events(tenant_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event ON analytics_events(event);

-- RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Public can insert, only admin can read
DO $$
BEGIN
  CREATE POLICY "Anyone can insert analytics" ON analytics_events
      FOR INSERT TO anon, authenticated WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  CREATE POLICY "Only admin can read analytics" ON analytics_events
      FOR SELECT TO authenticated
      USING (auth.jwt() ->> 'role' = 'admin');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Page statistics view
CREATE OR REPLACE VIEW analytics_page_stats AS
SELECT
    path,
    COUNT(*) as page_views,
    COUNT(DISTINCT session_id) as unique_sessions,
    COUNT(DISTINCT user_id) as unique_users,
    MIN(created_at) as first_view,
    MAX(created_at) as last_view
FROM analytics_events
WHERE event_type = 'page_view'
GROUP BY path
ORDER BY page_views DESC;

-- Daily statistics
CREATE OR REPLACE VIEW analytics_daily_stats AS
SELECT
    DATE(created_at) as date,
    COUNT(*) as total_events,
    COUNT(DISTINCT session_id) as sessions,
    COUNT(DISTINCT user_id) as users,
    COUNT(DISTINCT path) as pages_viewed
FROM analytics_events
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Retention tracking (optional)
CREATE TABLE IF NOT EXISTS analytics_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(100) NOT NULL UNIQUE,
    tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    ended_at TIMESTAMPTZ,
    pages_viewed INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    device_type VARCHAR(50),
    browser VARCHAR(100),
    os VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_session ON analytics_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_analytics_sessions_user ON analytics_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_sessions_started ON analytics_sessions(started_at DESC);
