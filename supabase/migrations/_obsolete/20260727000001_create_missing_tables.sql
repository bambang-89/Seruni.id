-- ============================================================
-- MIGRASI: 20260727000001_create_missing_tables.sql
-- Tanggal: 2026-07-27
-- Deskripsi: Buat 3 tabel baru: dashboard_agregat, layanan_statistik,
--            ref_aduan_kategori untuk konsistensi DB vs frontend.
--            Idempotent: aman dijalankan berulang.
-- Tenant UUID Seruni Mumbul: d532ae95-0ad9-42bb-a6e8-5c840447c90e
-- ============================================================

DO $$
BEGIN

-- ============================================================
-- 1. dashboard_agregat
--    Menyimpan metrik agregat dashboard (jumlah penduduk, kesehatan, dll)
--    per kategori, key, dan periode.
-- ============================================================

CREATE TABLE IF NOT EXISTS dashboard_agregat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    kategori VARCHAR(50) NOT NULL,
    metrik_key VARCHAR(100) NOT NULL,
    metrik_value NUMERIC NOT NULL DEFAULT 0,
    periode DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (kategori, metrik_key, periode)
);

GRANT SELECT ON dashboard_agregat TO authenticated, anon;
GRANT ALL ON dashboard_agregat TO service_role;
ALTER TABLE dashboard_agregat ENABLE ROW LEVEL SECURITY;

-- Tenant isolation policies
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dashboard_agregat read" ON dashboard_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: dashboard_agregat read" ON dashboard_agregat FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dashboard_agregat write" ON dashboard_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: dashboard_agregat write" ON dashboard_agregat FOR ALL USING (tenant_id = get_tenant_id())';

-- Public read policy (dashboard is public info)
DROP POLICY IF EXISTS "dashboard_agregat_public_read" ON dashboard_agregat;
CREATE POLICY "dashboard_agregat_public_read" ON dashboard_agregat FOR SELECT TO authenticated USING (true);
GRANT SELECT ON dashboard_agregat TO anon;

-- Index for fast dashboard queries
CREATE INDEX IF NOT EXISTS idx_dashboard_agregat_tenant_periode ON dashboard_agregat(tenant_id, periode DESC);
CREATE INDEX IF NOT EXISTS idx_dashboard_agregat_kategori ON dashboard_agregat(kategori, metrik_key);

-- ============================================================
-- 2. layanan_statistik
--    Statistik pengajuan layanan per jenis dan periode (bulan).
-- ============================================================

CREATE TABLE IF NOT EXISTS layanan_statistik (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    jenis_layanan VARCHAR(50) NOT NULL,
    periode VARCHAR(20) NOT NULL,
    jumlah_ajuan INTEGER NOT NULL DEFAULT 0,
    jumlah_proses INTEGER NOT NULL DEFAULT 0,
    jumlah_selesai INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, jenis_layanan, periode)
);

GRANT SELECT ON layanan_statistik TO authenticated, anon;
GRANT ALL ON layanan_statistik TO service_role;
ALTER TABLE layanan_statistik ENABLE ROW LEVEL SECURITY;

-- Tenant isolation policies
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: layanan_statistik read" ON layanan_statistik';
EXECUTE 'CREATE POLICY "Tenant isolation: layanan_statistik read" ON layanan_statistik FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: layanan_statistik write" ON layanan_statistik';
EXECUTE 'CREATE POLICY "Tenant isolation: layanan_statistik write" ON layanan_statistik FOR ALL USING (tenant_id = get_tenant_id())';

-- Public read policy
DROP POLICY IF EXISTS "layanan_statistik_public_read" ON layanan_statistik;
CREATE POLICY "layanan_statistik_public_read" ON layanan_statistik FOR SELECT TO authenticated USING (true);
GRANT SELECT ON layanan_statistik TO anon;

-- Index
CREATE INDEX IF NOT EXISTS idx_layanan_statistik_tenant_periode ON layanan_statistik(tenant_id, periode DESC);
CREATE INDEX IF NOT EXISTS idx_layanan_statistik_jenis ON layanan_statistik(jenis_layanan);

-- ============================================================
-- 3. ref_aduan_kategori
--    Tabel referensi kategori aduan (global seed, sama semua tenant).
--    Referensi: wire_services migration sudah membuat tabel ini --
--    tapi kita buat ulang dengan IF NOT EXISTS untuk idempotensi.
-- ============================================================

CREATE TABLE IF NOT EXISTS ref_aduan_kategori (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama VARCHAR(100) NOT NULL,
    kode VARCHAR(30) NOT NULL UNIQUE,
    aktif BOOLEAN NOT NULL DEFAULT true,
    urutan INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON ref_aduan_kategori TO authenticated, anon;
GRANT ALL ON ref_aduan_kategori TO service_role;
ALTER TABLE ref_aduan_kategori ENABLE ROW LEVEL SECURITY;

-- Public read policy (reference table)
DROP POLICY IF EXISTS "ref_aduan_kategori_public_read" ON ref_aduan_kategori;
CREATE POLICY "ref_aduan_kategori_public_read" ON ref_aduan_kategori FOR SELECT TO authenticated USING (true);
GRANT SELECT ON ref_aduan_kategori TO anon;

-- Index
CREATE INDEX IF NOT EXISTS idx_ref_aduan_kategori_urutan ON ref_aduan_kategori(urutan) WHERE aktif = true;

RAISE NOTICE 'Tables dashboard_agregat, layanan_statistik, ref_aduan_kategori created successfully.';

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error creating tables (may already exist): %', SQLERRM;
END $$;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Seed dashboard_agregat: 8 rows of real-ish data for Seruni Mumbul
-- Tenant UUID: d532ae95-0ad9-42bb-a6e8-5c840447c90e

INSERT INTO dashboard_agregat (tenant_id, kategori, metrik_key, metrik_value, periode) VALUES
  -- Penduduk (periode: latest data)
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'total_penduduk', 1247, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'jumlah_kk', 389, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'laki_laki', 612, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'perempuan', 635, '2026-06-30'),
  -- Kesehatan
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'balita_gizi_baik', 87, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'balita_stunting', 4, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'kades_terlayani', 156, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'ibus_hamil_terdaftar', 12, '2026-06-30')
ON CONFLICT (kategori, metrik_key, periode) DO NOTHING;

-- Seed layanan_statistik: 12 rows (4 services x 3 months)
-- Services: surat, bansos, infrastruktur, voting

INSERT INTO layanan_statistik (tenant_id, jenis_layanan, periode, jumlah_ajuan, jumlah_proses, jumlah_selesai) VALUES
  -- Surat (Surat Keterangan, dll)
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-04', 34, 12, 22),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-05', 41, 8, 33),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'surat', '2026-06', 38, 14, 24),
  -- Bantuan Sosial
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-04', 18, 6, 12),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-05', 22, 9, 13),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'bansos', '2026-06', 15, 4, 11),
  -- Infrastruktur
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'infrastruktur', '2026-04', 5, 2, 3),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'infrastruktur', '2026-05', 7, 3, 4),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'infrastruktur', '2026-06', 6, 5, 1),
  -- Voting / Partisipasi
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'voting', '2026-04', 0, 0, 0),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'voting', '2026-05', 0, 0, 0),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'voting', '2026-06', 89, 0, 89)
ON CONFLICT (tenant_id, jenis_layanan, periode) DO NOTHING;

-- Seed ref_aduan_kategori: 6 kategori
INSERT INTO ref_aduan_kategori (kode, nama, aktif, urutan) VALUES
  ('infrastruktur', 'Infrastruktur & Jalan', true, 1),
  ('pelayanan', 'Pelayanan Desa', true, 2),
  ('lingkungan', 'Lingkungan & Sanitasi', true, 3),
  ('sosial', 'Sosial & Kesejahteraan', true, 4),
  ('keamanan', 'Keamanan & Ketertiban', true, 5),
  ('lainnya', 'Lainnya', true, 6)
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'dashboard_agregat rows:' as info, COUNT(*) as count FROM dashboard_agregat WHERE tenant_id = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
SELECT 'layanan_statistik rows:' as info, COUNT(*) as count FROM layanan_statistik WHERE tenant_id = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
SELECT 'ref_aduan_kategori rows:' as info, COUNT(*) as count FROM ref_aduan_kategori;
