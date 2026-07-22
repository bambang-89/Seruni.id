-- ============================================================
-- MIGRASI: 20260720000004_009_wa_chatbot_tables.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tabel untuk WA Chatbot session dan conversation
-- ============================================================

-- ============================================================
-- 1. WA Chatbot Session
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(100) NOT NULL UNIQUE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nomor_wa VARCHAR(20) NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_nik VARCHAR(16),
  state VARCHAR(50) NOT NULL DEFAULT 'main_menu',
  last_menu INT,
  step_data JSONB DEFAULT '{}',
  ip_address INET,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_session_nomor ON wa_chatbot_session(nomor_wa, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_session_tenant ON wa_chatbot_session(tenant_id, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_session_expires ON wa_chatbot_session(expires_at);

GRANT SELECT, INSERT, UPDATE ON wa_chatbot_session TO authenticated, service_role;
GRANT ALL ON wa_chatbot_session TO service_role;
ALTER TABLE wa_chatbot_session ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_session all for auth" ON wa_chatbot_session
  FOR ALL TO authenticated USING (true);
CREATE POLICY "wa_session service all" ON wa_chatbot_session
  FOR ALL TO service_role USING (true);

-- Trigger untuk updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS wa_chatbot_session_updated ON wa_chatbot_session;
CREATE TRIGGER wa_chatbot_session_updated
  BEFORE UPDATE ON wa_chatbot_session
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 2. WA Chatbot Conversation
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_conversation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(100) REFERENCES wa_chatbot_session(session_id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nomor_wa VARCHAR(20) NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  direction VARCHAR(10) NOT NULL CHECK (direction IN ('incoming', 'outgoing')),
  message TEXT NOT NULL,
  parsed_intent VARCHAR(50),
  parsed_entities JSONB,
  sent_status VARCHAR(20) CHECK (sent_status IN ('pending', 'sukses', 'gagal')),
  sent_response JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_conv_session ON wa_chatbot_conversation(session_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_conv_nomor ON wa_chatbot_conversation(nomor_wa, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wa_conv_period ON wa_chatbot_conversation(created_at DESC);

GRANT SELECT, INSERT ON wa_chatbot_conversation TO authenticated, service_role;
GRANT ALL ON wa_chatbot_conversation TO service_role;
ALTER TABLE wa_chatbot_conversation ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_conv select for auth" ON wa_chatbot_conversation
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "wa_conv insert for auth" ON wa_chatbot_conversation
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "wa_conv service all" ON wa_chatbot_conversation
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 3. WA Chatbot Menu Config (customizable menu)
-- ============================================================

CREATE TABLE IF NOT EXISTS wa_chatbot_menu (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  parent_key VARCHAR(20),
  menu_key VARCHAR(20) NOT NULL,
  label VARCHAR(100) NOT NULL,
  emoji VARCHAR(10),
  action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('menu', 'function', 'url', 'phone')),
  action_value TEXT,
  urutan INT DEFAULT 0,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_menu_tenant ON wa_chatbot_menu(tenant_id, parent_key, urutan);

GRANT SELECT, INSERT, UPDATE ON wa_chatbot_menu TO authenticated;
GRANT ALL ON wa_chatbot_menu TO service_role;
ALTER TABLE wa_chatbot_menu ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wa_menu all for auth" ON wa_chatbot_menu
  FOR ALL TO authenticated USING (true);
CREATE POLICY "wa_menu service all" ON wa_chatbot_menu
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 4. Seed default menu
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;

  IF v_tenant_id IS NOT NULL THEN
    -- Insert default main menu items
    INSERT INTO wa_chatbot_menu (tenant_id, parent_key, menu_key, label, emoji, action_type, action_value, urutan) VALUES
    (v_tenant_id, NULL, '1', 'Cek Status Surat', '📋', 'menu', 'surat', 1),
    (v_tenant_id, NULL, '2', 'Cek Tagihan PBB', '💰', 'menu', 'pbb', 2),
    (v_tenant_id, NULL, '3', 'Voting Aktif', '🗳️', 'menu', 'voting', 3),
    (v_tenant_id, NULL, '4', 'Bantuan Sosial', '🎁', 'menu', 'bansos', 4),
    (v_tenant_id, NULL, '5', 'Cek Data Diri', '👤', 'menu', 'data_diri', 5),
    (v_tenant_id, NULL, '6', 'Info Desa', 'ℹ️', 'menu', 'info', 6),
    (v_tenant_id, NULL, '7', 'Hubungi Admin', '📞', 'phone', NULL, 7),
    (v_tenant_id, NULL, '0', 'Menu Utama', '🏠', 'menu', 'main', 0)
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================================
-- 5. Analytics: Session stats
-- ============================================================

CREATE OR REPLACE VIEW wa_chatbot_stats AS
SELECT
  tenant_id,
  DATE(created_at) AS tanggal,
  COUNT(DISTINCT session_id) AS total_session,
  COUNT(*) FILTER (WHERE direction = 'incoming') AS total_pesan_masuk,
  COUNT(*) FILTER (WHERE direction = 'outgoing') AS total_pesan_keluar,
  COUNT(*) FILTER (WHERE sent_status = 'gagal') AS total_gagal,
  COUNT(DISTINCT nomor_wa) AS total_pengguna_unik
FROM wa_chatbot_conversation
GROUP BY tenant_id, DATE(created_at)
ORDER BY tanggal DESC;

GRANT SELECT ON wa_chatbot_stats TO authenticated;

DO $$
BEGIN
  RAISE NOTICE 'WA Chatbot tables migration completed.';
END $$;
