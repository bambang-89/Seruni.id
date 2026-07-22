-- ============================================================
-- MIGRASI: 004_multi_tenancy.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Multi-tenancy foundation - tenants table dan tenant_id
-- Prinsip: Setiap tabel domain punya tenant_id untuk isolasi data
-- Urutan migrasi: setelah 003_domain_events.sql
-- Catatan: Dilakukan bertahap untuk menghindari breaking changes
-- ============================================================

-- 1. Tenants Table (Master Desa)
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_desa VARCHAR(150) NOT NULL,
  subdomain VARCHAR(63) UNIQUE,
  kode_desa VARCHAR(13) UNIQUE, -- kode desa 13 digit Kemendes
  kecamatan VARCHAR(100),
  kabupaten VARCHAR(100),
  provinsi VARCHAR(100),
  logo_url TEXT,
  favicon_url TEXT,
  warna_primer VARCHAR(7) DEFAULT '#1F4D3D',
  warna_aksen VARCHAR(7) DEFAULT '#C9A227',
  aktif BOOLEAN NOT NULL DEFAULT true,
  settings JSONB DEFAULT '{}', -- konfigurasi tambahan per tenant
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tenants_updated' AND tgrelid = 'public.tenants'::regclass) THEN
    CREATE TRIGGER tenants_updated BEFORE UPDATE ON tenants
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON tenants TO authenticated;
GRANT ALL ON tenants TO service_role;
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read tenants" ON tenants FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage tenants" ON tenants FOR ALL TO service_role USING (true);

-- Seed tenant default untuk Seruni Mumbul
INSERT INTO tenants (nama_desa, subdomain, kode_desa, kecamatan, kabupaten, provinsi, warna_primer, warna_aksen)
VALUES (
  'Seruni Mumbul',
  'seruni',
  '5204011001', -- contoh kode desa
  'Pringgabaya',
  'Lombok Timur',
  'Nusa Tenggara Barat',
  '#1F4D3D',
  '#C9A227'
)
ON CONFLICT (subdomain) DO NOTHING;

-- 2. Site Settings (Zero-Hardcode - Konfigurasi Per Tenant)
CREATE TABLE IF NOT EXISTS site_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nama_resmi VARCHAR(200) NOT NULL,
  tagline VARCHAR(300),
  alamat_kantor TEXT,
  telepon VARCHAR(20),
  email VARCHAR(100),
  jam_layanan VARCHAR(100),
  nomor_wa_resmi VARCHAR(20),
  wa_business_verified BOOLEAN DEFAULT false,
  social_media JSONB DEFAULT '{}', -- {facebook, instagram, youtube, tiktok}
  maps_embed_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'site_settings_updated' AND tgrelid = 'public.site_settings'::regclass) THEN
    CREATE TRIGGER site_settings_updated BEFORE UPDATE ON site_settings
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON site_settings TO anon, authenticated;
GRANT ALL ON site_settings TO service_role;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read site_settings" ON site_settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage site_settings" ON site_settings FOR ALL TO service_role USING (true);

-- Seed site settings untuk tenant default
INSERT INTO site_settings (tenant_id, nama_resmi, tagline, alamat_kantor, jam_layanan, nomor_wa_resmi, wa_business_verified)
SELECT
  id,
  'Desa Seruni Mumbul',
  'Satu Data Desa. Pelayanan Terbuka. Warga Terhubung.',
  'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
  'Senin–Jumat · 08.00–15.00 WITA',
  '+6281200000000',
  true
FROM tenants
WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id) DO NOTHING;

-- 3. Site Navigation (Zero-Hardcode - Menu Dinamis)
CREATE TABLE IF NOT EXISTS site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  posisi VARCHAR(10) NOT NULL CHECK (posisi IN ('header', 'footer')),
  label VARCHAR(60) NOT NULL,
  href TEXT NOT NULL,
  icon VARCHAR(50), -- icon name (lucide atau heroicons)
  parent_id UUID REFERENCES site_navigation(id) ON DELETE CASCADE,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_site_navigation_tenant_posisi
  ON site_navigation(tenant_id, posisi, urutan)
  WHERE aktif = true;

GRANT SELECT ON site_navigation TO anon, authenticated;
GRANT ALL ON site_navigation TO service_role;
ALTER TABLE site_navigation ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read site_navigation" ON site_navigation FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage site_navigation" ON site_navigation FOR ALL TO service_role USING (true);

-- Seed navigation default
INSERT INTO site_navigation (tenant_id, posisi, label, href, urutan)
SELECT id, 'header', 'Profil', '/profil-desa', 1 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Informasi', '/berita', 2 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Layanan', '/layanan', 3 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Data', '/statistik', 4 FROM tenants WHERE subdomain = 'seruni'
UNION ALL
SELECT id, 'header', 'Potensi', '/potensi-desa', 5 FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT DO NOTHING;

-- 4. Feature Flags (Modul Aktif/Nonaktif)
CREATE TABLE IF NOT EXISTS feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  fitur_kode VARCHAR(30) NOT NULL, -- 'F1_SURAT', 'F2_USULAN', dst.
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, fitur_kode)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'feature_flags_updated' AND tgrelid = 'public.feature_flags'::regclass) THEN
    CREATE TRIGGER feature_flags_updated BEFORE UPDATE ON feature_flags
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

GRANT SELECT ON feature_flags TO authenticated;
GRANT ALL ON feature_flags TO service_role;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read feature_flags" ON feature_flags FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage feature_flags" ON feature_flags FOR ALL TO service_role USING (true);

-- Seed feature flags default (semua aktif)
INSERT INTO feature_flags (tenant_id, fitur_kode, aktif)
SELECT id, 'F0_REGISTRASI', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F1_SURAT', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F2_USULAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F3_IDM', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F4_POSYANDU', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F5_PBB', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F6_WA_CHATBOT', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F7_PERTANAHAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F8_ASET', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F9_PEMETAAN', true FROM tenants WHERE subdomain = 'seruni'
UNION ALL SELECT id, 'F10_STATISTIK', true FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id, fitur_kode) DO NOTHING;

-- 7. Helper: Get current tenant from request
CREATE OR REPLACE FUNCTION get_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    current_setting('app.current_tenant_id', true)::uuid,
    (SELECT id FROM tenants WHERE subdomain = 'seruni' LIMIT 1)
  );
$$;

-- 8. Helper: Check if feature is enabled for tenant
CREATE OR REPLACE FUNCTION is_feature_enabled(p_tenant_id UUID, p_fitur_kode VARCHAR)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT aktif FROM feature_flags
     WHERE tenant_id = p_tenant_id AND fitur_kode = p_fitur_kode),
    true
  );
$$;

-- 9. Dashboard Agregat Table (Fakta Turunan - HANYA worker yang tulis)
CREATE TABLE IF NOT EXISTS dashboard_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  wilayah_id UUID, -- nullable untuk agregat level desa
  kategori VARCHAR(40) NOT NULL, -- 'kependudukan', 'kesehatan', 'keuangan', dst.
  metrik_key VARCHAR(60) NOT NULL, -- 'jumlah_penduduk', 'cakupan_imunisasi', dst.
  metrik_value NUMERIC NOT NULL,
  periode VARCHAR(20) NOT NULL, -- '2026-Q1', '2026-Tahun', dst.
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, wilayah_id, kategori, metrik_key, periode)
);

CREATE INDEX IF NOT EXISTS idx_dashboard_agregat_tenant
  ON dashboard_agregat(tenant_id, kategori, periode);

GRANT SELECT ON dashboard_agregat TO authenticated;
GRANT ALL ON dashboard_agregat TO service_role;
ALTER TABLE dashboard_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read dashboard_agregat" ON dashboard_agregat FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage dashboard_agregat" ON dashboard_agregat FOR ALL TO service_role USING (true);

-- 10. IDM Status Desa (Fakta Turunan - HANYA worker yang tulis)
CREATE TABLE IF NOT EXISTS idm_status_desa (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id) ON DELETE CASCADE,
  total_skor NUMERIC(5,4) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL, -- 'mandiri', 'maju', 'berkembang', 'tertinggal', 'sangat_tertinggal'
  dimensi_scores JSONB DEFAULT '{}', -- {"kesehatan": 4.2, "pendidikan": 4.5, ...}
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON idm_status_desa TO authenticated;
GRANT ALL ON idm_status_desa TO service_role;
ALTER TABLE idm_status_desa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read idm_status_desa" ON idm_status_desa FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage idm_status_desa" ON idm_status_desa FOR ALL TO service_role USING (true);

-- Seed IDM status default
INSERT INTO idm_status_desa (tenant_id, total_skor, status, dimensi_scores)
SELECT id, 0.7412, 'berkembang',
  '{"kesehatan": 4.2, "pendidikan": 4.5, "modal_sosial": 3.8, "permukiman": 4.1, "ekonomi": 3.6, "ekologi": 4.4}'
FROM tenants WHERE subdomain = 'seruni'
ON CONFLICT (tenant_id) DO NOTHING;

-- 11. Helper: Get site navigation for public
CREATE OR REPLACE FUNCTION get_site_navigation(p_tenant_id UUID, p_posisi VARCHAR)
RETURNS TABLE (
  id UUID,
  label VARCHAR,
  href TEXT,
  icon VARCHAR,
  parent_id UUID,
  urutan INT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id, label, href, icon, parent_id, urutan
  FROM site_navigation
  WHERE tenant_id = p_tenant_id
    AND posisi = p_posisi
    AND aktif = true
  ORDER BY urutan;
$$;

COMMENT ON FUNCTION get_site_navigation IS
'Get active navigation items for a tenant. Returns items ordered by urutan.
Usage: SELECT * FROM get_site_navigation(get_tenant_id(), ''header'')';

-- 12. Helper: Get enabled features for tenant
CREATE OR REPLACE FUNCTION get_enabled_features(p_tenant_id UUID)
RETURNS TABLE (fitur_kode VARCHAR, aktif BOOLEAN)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT fitur_kode, aktif
  FROM feature_flags
  WHERE tenant_id = p_tenant_id;
$$;

COMMENT ON FUNCTION get_enabled_features IS
'Get all feature flags for a tenant.
Usage: SELECT * FROM get_enabled_features(get_tenant_id())';
