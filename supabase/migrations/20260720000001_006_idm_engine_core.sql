-- ============================================================
-- MIGRASI: 20260720000001_006_idm_engine_core.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tabel inti IDM Scoring Engine + seed indicators
--
-- Referensi: docs/Sistem_IDM_Desa.md
-- Priority MVP: 6 dimensi, ~30 indicators (dari 127 total)
--
-- Prinsip:
-- - idm_indicators = seed-only (sama semua tenant)
-- - idm_skor_cache = HANYA ditulis worker (bukan admin)
-- - idm_status_desa = klasifikasi akhir (dibaca portal)
-- ============================================================

-- ============================================================
-- 1. IDM INDICATORS (Seed Kuesioner)
--    Sama untuk semua tenant (OpenSID/IDM Kemendes compliant)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dimensi_no INT NOT NULL CHECK (dimensi_no BETWEEN 1 AND 6),
  dimensi_nama VARCHAR(100) NOT NULL,
  subdimensi_kode VARCHAR(20),
  subdimensi_nama VARCHAR(100),
  indikator_no VARCHAR(20) NOT NULL,
  indikator_nama TEXT NOT NULL,
  indikator_skor_max INT NOT NULL DEFAULT 5,
  sub_indikator_no VARCHAR(20),
  sub_indikator_nama TEXT,
  sub_skor_max INT DEFAULT 5,
  sumber_data VARCHAR(30) NOT NULL CHECK (sumber_data IN ('operasional', 'periodik_manual', 'eksternal')),
  kode_rekening VARCHAR(50),
  rekomendasi_intervensi TEXT,
  unidade TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index untuk lookup cepat per dimensi
CREATE INDEX IF NOT EXISTS idx_idm_indicators_dimensi ON idm_indicators(dimensi_no, dimensi_nama);
CREATE INDEX IF NOT EXISTS idx_idm_indicators_sumber ON idm_indicators(sumber_data);

GRANT SELECT ON idm_indicators TO authenticated, anon;
GRANT ALL ON idm_indicators TO service_role;
ALTER TABLE idm_indicators ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_indicators public read" ON idm_indicators FOR SELECT TO authenticated USING (is_active = true);

-- ============================================================
-- 2. IDM SCORING THRESHOLDS (Ambang Nilai per Skor)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_scoring_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id) ON DELETE CASCADE,
  skor_level INT NOT NULL CHECK (skor_level BETWEEN 1 AND 5),
  nilai_ambang_bawah NUMERIC NOT NULL,
  nilai_ambang_atas NUMERIC NOT NULL,
  deskripsi_kondisi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(indikator_id, skor_level)
);

CREATE INDEX IF NOT EXISTS idx_idm_thresholds_indikator ON idm_scoring_thresholds(indikator_id);

GRANT SELECT ON idm_scoring_thresholds TO authenticated, anon;
GRANT ALL ON idm_scoring_thresholds TO service_role;
ALTER TABLE idm_scoring_thresholds ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_thresholds public read" ON idm_scoring_thresholds FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 3. IDM SKOR CACHE (HANYA ditulis Worker)
--    Tenant-specific, per-indikator
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_skor_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id) ON DELETE CASCADE,
  indikator_kode VARCHAR(50) NOT NULL, -- e.g. "D1-I1" atau "KESEHATAN_APM"
  dimensi_no INT NOT NULL,
  dimensi_nama VARCHAR(100) NOT NULL,
  skor NUMERIC(3,2) NOT NULL CHECK (skor BETWEEN 0 AND 1), -- 0.00 - 1.00 (normalize dari 1-5)
  nilai_agregat NUMERIC NOT NULL DEFAULT 0,
  sumber_data VARCHAR(30) NOT NULL,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, indikator_kode)
);

CREATE INDEX IF NOT EXISTS idx_idm_skor_cache_tenant ON idm_skor_cache(tenant_id);
CREATE INDEX IF NOT EXISTS idx_idm_skor_cache_dimensi ON idm_skor_cache(tenant_id, dimensi_no);

GRANT SELECT ON idm_skor_cache TO authenticated, anon;
GRANT ALL ON idm_skor_cache TO service_role;
ALTER TABLE idm_skor_cache ENABLE ROW LEVEL SECURITY;
-- HANYA service_role yang bisa INSERT/UPDATE (worker-only)
CREATE POLICY "idm_skor_cache worker only" ON idm_skor_cache
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 4. IDM STATUS DESA (Klasifikasi Akhir)
--    - Total skor = rata-rata 6 dimensi
--    - Status = mandiri / maju / berkembang / tertinggal / sangat_tertinggal
-- ============================================================

ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_scores JSONB NOT NULL DEFAULT '{}';
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_1 NUMERIC(5,4) DEFAULT 0; -- Sosial
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_2 NUMERIC(5,4) DEFAULT 0; -- Ekonomi
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_3 NUMERIC(5,4) DEFAULT 0; -- Lingkungan
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_4 NUMERIC(5,4) DEFAULT 0; -- Infrastruktur
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_5 NUMERIC(5,4) DEFAULT 0; -- Tata Kelola
ALTER TABLE idm_status_desa ADD COLUMN IF NOT EXISTS
  dimensi_skor_6 NUMERIC(5,4) DEFAULT 0; -- Teknologi

-- Drop old dimensi_scores if exists, recreate as proper JSONB
DO $$
BEGIN
  -- Add column if not exists (alternative syntax)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'idm_status_desa' AND column_name = 'dimensi_skor_1') THEN
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_1 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_2 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_3 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_4 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_5 NUMERIC(5,4) DEFAULT 0;
    ALTER TABLE idm_status_desa ADD COLUMN dimensi_skor_6 NUMERIC(5,4) DEFAULT 0;
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

COMMENT ON TABLE idm_status_desa IS 'Klasifikasi akhir desa - SINGLE SOURCE OF TRUTH untuk skor IDM. HANYA ditulis oleh IDM worker, bukan admin.';

-- ============================================================
-- 5. IDM LOG (Audit Trail - Append Only)
-- ============================================================

CREATE TABLE IF NOT EXISTS idm_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_kode VARCHAR(50) NOT NULL,
  skor_lama NUMERIC(3,2),
  skor_baru NUMERIC(3,2) NOT NULL,
  nilai_agregat_lama NUMERIC,
  nilai_agregat_baru NUMERIC NOT NULL,
  sumber_event VARCHAR(100),
  aktor_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_idm_log_tenant ON idm_log(tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_idm_log_indikator ON idm_log(tenant_id, indikator_kode, created_at DESC);

GRANT SELECT ON idm_log TO authenticated;
GRANT INSERT ON idm_log TO service_role;
GRANT ALL ON idm_log TO service_role;
ALTER TABLE idm_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm_log append only" ON idm_log
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "idm_log admin read" ON idm_log
  FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 6. USULAN KEGIATAN DRAFT OTOMATIS
--    Dibuat worker saat skor < ambang tertentu
-- ============================================================

CREATE TABLE IF NOT EXISTS usulan_kegiatan_draft_otomatis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  kategori VARCHAR(50) NOT NULL DEFAULT 'pembangunan',
  sumber_pemicu VARCHAR(100) NOT NULL, -- event_type yang memicu
  sumber_ref_id UUID, -- entity_id yang memicu
  indikator_kode VARCHAR(50), -- indikator yang skor rendah
  kode_rekening_saran VARCHAR(50),
  judul_saran TEXT NOT NULL,
  deskripsi_saran TEXT,
  estimasi_anggaran BIGINT,
  lokasi_saran TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'menunggu_review' CHECK (status IN ('menunggu_review', 'diadopsi', 'diabaikan')),
  reviewer_id UUID,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_usulan_draft_tenant ON usulan_kegiatan_draft_otomatis(tenant_id);
CREATE INDEX IF NOT EXISTS idx_usulan_draft_status ON usulan_kegiatan_draft_otomatis(status);

GRANT SELECT, INSERT, UPDATE ON usulan_kegiatan_draft_otomatis TO authenticated;
GRANT ALL ON usulan_kegiatan_draft_otomatis TO service_role;
ALTER TABLE usulan_kegiatan_draft_otomatis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "usulan_draft admin read write" ON usulan_kegiatan_draft_otomatis
  FOR ALL TO authenticated USING (true);
CREATE POLICY "usulan_draft worker insert" ON usulan_kegiatan_draft_otomatis
  FOR INSERT TO service_role WITH CHECK (true);

-- ============================================================
-- 7. PADES PENDAPATAN (PADes otomatis dari PBB)
--    Dimensi 5 - Tata Kelola Keuangan
-- ============================================================

CREATE TABLE IF NOT EXISTS pades_pendapatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  tahun INT NOT NULL,
  sumber VARCHAR(50) NOT NULL, -- 'pbb' / 'retribusi' / 'bumd' / 'lainnya'
  jenis_pendapatan VARCHAR(100),
  nilai BIGINT NOT NULL DEFAULT 0, -- dalam rupiah
  sumber_ref_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pades_pendapatan_tenant_tahun ON pades_pendapatan(tenant_id, tahun);

GRANT SELECT, INSERT ON pades_pendapatan TO authenticated;
GRANT ALL ON pades_pendapatan TO service_role;
ALTER TABLE pades_pendapatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pades admin select" ON pades_pendapatan
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "pades admin insert" ON pades_pendapatan
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "pades worker all" ON pades_pendapatan
  FOR ALL TO service_role USING (true);

-- ============================================================
-- 8. WILAYAH BATAS (Granularitas Agregat)
--    Untuk agregasi per dusun/RT/RW
-- ============================================================

CREATE TABLE IF NOT EXISTS wilayah_batas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES wilayah_batas(id) ON DELETE SET NULL,
  jenis VARCHAR(20) NOT NULL CHECK (jenis IN ('desa', 'dusun', 'rw', 'rt')),
  kode VARCHAR(20),
  nama VARCHAR(100) NOT NULL,
  boundary_json JSONB, -- Simpan koordinat batas wilayah
  luas_m2 NUMERIC,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wilayah_batas_tenant ON wilayah_batas(tenant_id);
CREATE INDEX IF NOT EXISTS idx_wilayah_batas_parent ON wilayah_batas(parent_id);
CREATE INDEX IF NOT EXISTS idx_wilayah_batas_jenis ON wilayah_batas(jenis);

GRANT SELECT, INSERT, UPDATE ON wilayah_batas TO authenticated;
GRANT ALL ON wilayah_batas TO service_role;
ALTER TABLE wilayah_batas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "wilayah_batas admin all" ON wilayah_batas
  FOR ALL TO authenticated USING (true);

-- ============================================================
-- 9. SEED: IDM Indicators MVP (30 indicators dari 6 dimensi)
--    Sesuai Permendes 21/2020 & 7/2023
-- ============================================================

-- Dimensi 1: Sosial (Pendidikan, Kesehatan, dll)
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(1, 'Sosial', '1a', 'Pendidikan', 'D1-I1', 'Angka Partisipasi Murni (APM)', 5, 'operasional', '5.1.02.01', 'Bangun PAUD/perluas akses pendidikan'),
(1, 'Sosial', '1a', 'Pendidikan', 'D1-I2', 'Rasio guru-guru tersertifikasi', 5, 'periodik_manual', '5.1.02.02', 'Sertifikasi guru'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I3', 'Cakupan BPJS Kesehatan', 5, 'operasional', '5.1.05.01', 'Pendaftaran BPJS peserta baru'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I4', 'Cakupan Imunisasi Balita', 5, 'operasional', '5.1.05.02', 'Kampanye imunisasi'),
(1, 'Sosial', '1b', 'Kesehatan', 'D1-I5', 'Prevalensi Stunting', 5, 'operasional', '5.1.05.03', 'Intervensi gizi'),
(1, 'Sosial', '1c', 'Kesejahteraan', 'D1-I6', 'Cakupan Bantuan Sosial', 5, 'operasional', '5.1.06.01', 'Verifikasi DTKS'),
(1, 'Sosial', '1c', 'Kesejahteraan', 'D1-I7', 'Rasio Ketimpangan (Gini)', 5, 'eksternal', NULL, 'Program pemberdayaan ekonomi')
ON CONFLICT DO NOTHING;

-- Dimensi 2: Ekonomi
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(2, 'Ekonomi', '2a', 'PADes', 'D2-I1', 'PADes per Kapita', 5, 'operasional', '4.1.01', 'Peningkatan sumber PADes'),
(2, 'Ekonomi', '2a', 'PADes', 'D2-I2', 'Pertumbuhan PADes YoY', 5, 'operasional', '4.1.01', 'Diversifikasi sumber PADes'),
(2, 'Ekonomi', '2b', 'Keragaman Ekonomi', 'D2-I3', 'Jumlah Sektor Ekonomi Aktif', 5, 'operasional', '5.2.02.01', 'Pengembangan UMKM'),
(2, 'Ekonomi', '2b', 'Keragaman Ekonomi', 'D2-I4', 'Akses Pasar/Commerce', 5, 'operasional', '5.2.02.02', 'Digitalisasi pemasaran'),
(2, 'Ekonomi', '2c', 'Ketenagakerjaan', 'D2-I5', 'Tingkat Pengangguran', 5, 'operasional', '5.2.03.01', 'Pelatihan kerja'),
(2, 'Ekonomi', '2c', 'Ketenagakerjaan', 'D2-I6', 'Usaha Mikro aktif', 5, 'operasional', '5.2.03.02', 'Pendampingan UMKM')
ON CONFLICT DO NOTHING;

-- Dimensi 3: Lingkungan
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(3, 'Lingkungan', '3a', 'LP2B', 'D3-I1', 'Luas Lahan Pertanian Terpelihara', 5, 'periodik_manual', '5.3.01.01', 'Rehabilitasi lahan'),
(3, 'Lingkungan', '3b', 'Sanitasi', 'D3-I2', 'Cakupan Sanitasi Layak', 5, 'operasional', '5.3.02.01', 'Bangunan MCK Komunal'),
(3, 'Lingkungan', '3b', 'Sanitasi', 'D3-I3', 'Akses Air Bersih Layak', 5, 'operasional', '5.3.02.02', 'Sumber air bersih'),
(3, 'Lingkungan', '3c', 'Mitigasi', 'D3-I4', 'Kesiapan Mitigasi Bencana', 5, 'periodik_manual', '5.3.03.01', 'Pembuatan peta rawan bencana'),
(3, 'Lingkungan', '3c', 'Mitigasi', 'D3-I5', 'Pengelolaan Sampah', 5, 'operasional', '5.3.03.02', 'Bank sampah / TPS')
ON CONFLICT DO NOTHING;

-- Dimensi 4: Infrastruktur & Pelayanan Dasar
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(4, 'Infrastruktur', '4a', 'Jalan', 'D4-I1', 'Kondisi Jalan Desa', 5, 'periodik_manual', '5.4.01.01', 'Pembangunan/rehabilitasi jalan'),
(4, 'Infrastruktur', '4a', 'Jalan', 'D4-I2', 'Akses Jalan ke Pusat Desa', 5, 'periodik_manual', '5.4.01.02', 'Pembukaan jalan'),
(4, 'Infrastruktur', '4b', 'Kesehatan', 'D4-I3', 'Jarak ke Fasilitas Kesehatan', 5, 'operasional', '5.4.02.01', 'Pembangunan poskesdes'),
(4, 'Infrastruktur', '4b', 'Kesehatan', 'D4-I4', 'Aktivitas Posyandu', 5, 'operasional', '5.4.02.02', 'Penguatan Posyandu'),
(4, 'Infrastruktur', '4c', 'Pendidikan', 'D4-I5', 'Akses PAUD/SD', 5, 'operasional', '5.4.03.01', 'Transportasi siswa'),
(4, 'Infrastruktur', '4c', 'Pendidikan', 'D4-I6', 'Ruang Kelas Layak', 5, 'periodik_manual', '5.4.03.02', ' Rehabilitasi ruang kelas')
ON CONFLICT DO NOTHING;

-- Dimensi 5: Tata Kelola Pemerintahan Desa
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(5, 'Tata Kelola', '5a', 'Musdes', 'D5-I1', 'Frekuensi Musdes/Tahunan', 5, 'operasional', '5.5.01.01', 'Peningkatan kapasitas musdes'),
(5, 'Tata Kelola', '5a', 'Musdes', 'D5-I2', 'Partisipasi Musdes', 5, 'operasional', '5.5.01.02', 'Sosialisasi musdes'),
(5, 'Tata Kelola', '5b', 'Keuangan', 'D5-I3', 'Capaian APBDes', 5, 'operasional', '5.5.02.01', 'Optimalisasi belanja'),
(5, 'Tata Kelola', '5b', 'Keuangan', 'D5-I4', 'Transparansi Keuangan', 5, 'operasional', '5.5.02.02', 'Publikasi APBDes'),
(5, 'Tata Kelola', '5c', 'Kelembagaan', 'D5-I5', 'Kelembagaan Desa', 5, 'operasional', '5.5.03.01', 'Pembentukan lembaga'),
(5, 'Tata Kelola', '5c', 'Kelembagaan', 'D5-I6', 'TTE (Tanda Tangan Elektronik)', 5, 'operasional', '5.5.03.02', 'Sertifikasi TTE')
ON CONFLICT DO NOTHING;

-- Dimensi 6: Teknologi & Inovasi
INSERT INTO idm_indicators (dimensi_no, dimensi_nama, subdimensi_kode, subdimensi_nama, indikator_no, indikator_nama, indikator_skor_max, sumber_data, kode_rekening, rekomendasi_intervensi) VALUES
(6, 'Teknologi', '6a', 'Pelayanan', 'D6-I1', 'Layanan Digital Tersedia', 5, 'operasional', '6.1.01.01', 'Pengembangan sistem'),
(6, 'Teknologi', '6a', 'Pelayanan', 'D6-I2', 'Persentase Surat Digital', 5, 'operasional', '6.1.01.02', 'Digitalisasi layanan surat'),
(6, 'Teknologi', '6b', 'Inovasi', 'D6-I3', 'Inovasi Desa', 5, 'periodik_manual', '6.1.02.01', 'Kompetisi inovasi'),
(6, 'Teknologi', '6b', 'Inovasi', 'D6-I4', 'Pemanfaatan Data', 5, 'operasional', '6.1.02.02', 'Dashboard data desa'),
(6, 'Teknologi', '6c', 'Konektivitas', 'D6-I5', 'Akses Internet', 5, 'eksternal', NULL, 'Kemitraan provider'),
(6, 'Teknologi', '6c', 'Konektivitas', 'D6-I6', 'Device Rasio', 5, 'periodik_manual', '6.1.03.01', 'Penyediaan device')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 10. Seed: Scoring Thresholds (Placeholder)
--    Thresholds akan di-tune berdasarkan data empiris
-- ============================================================

-- Insert thresholds untuk BPJS (D1-I3) sebagai contoh
INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 1, 0, 0.5, 'Cakupan < 50%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 2, 0.5, 0.7, 'Cakupan 50-70%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 3, 0.7, 0.85, 'Cakupan 70-85%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 4, 0.85, 0.95, 'Cakupan 85-95%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

INSERT INTO idm_scoring_thresholds (indikator_id, skor_level, nilai_ambang_bawah, nilai_ambang_atas, deskripsi_kondisi)
SELECT id, 5, 0.95, 1.0, 'Cakupan > 95%'
FROM idm_indicators WHERE indikator_no = 'D1-I3'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. Helper Function: Get IDM Indicator Score
-- ============================================================

CREATE OR REPLACE FUNCTION get_idm_skor(
  p_indikator_kode VARCHAR,
  p_nilai_agregat NUMERIC
)
RETURNS NUMERIC(3,2)
LANGUAGE plpgsql
AS $$
DECLARE
  v_skor NUMERIC(3,2);
  v_indikator RECORD;
BEGIN
  -- Ambil info indikator
  SELECT dimensi_no, indikator_skor_max INTO v_indikator
  FROM idm_indicators
  WHERE indikator_no = p_indikator_kode AND is_active = true;

  IF NOT FOUND THEN
    RETURN 0.5; -- Default jika indikator tidak ditemukan
  END IF;

  -- Cari threshold yang cocok
  SELECT skor_level::NUMERIC / v_indikator.indikator_skor_max INTO v_skor
  FROM idm_scoring_thresholds th
  JOIN idm_indicators ind ON ind.id = th.indikator_id
  WHERE ind.indikator_no = p_indikator_kode
    AND p_nilai_agregat >= th.nilai_ambang_bawah
    AND p_nilai_agregat < th.nilai_ambang_atas
  LIMIT 1;

  IF v_skor IS NULL THEN
    -- Fallback: normalize langsung dari max
    v_skor := LEAST(1.0, GREATEST(0.0, p_nilai_agregat));
  END IF;

  RETURN ROUND(v_skor::NUMERIC, 2);
END;
$$;

COMMENT ON FUNCTION get_idm_skor IS
'Calculate IDM indicator score from aggregate value.
Returns 0.00-1.00 (normalized from 1-5 scale).
Usage: SELECT get_idm_skor(''D1-I3'', 0.92)';

-- ============================================================
-- 12. View: IDM Dashboard Summary (untuk Portal Publik)
-- ============================================================

CREATE OR REPLACE VIEW idm_dashboard_summary AS
SELECT
  sd.tenant_id,
  sd.total_skor,
  sd.status,
  sd.dihitung_pada,
  sd.dimensi_skor_1,
  sd.dimensi_skor_2,
  sd.dimensi_skor_3,
  sd.dimensi_skor_4,
  sd.dimensi_skor_5,
  sd.dimensi_skor_6,
  CASE
    WHEN sd.status = 'mandiri' THEN '🏆'
    WHEN sd.status = 'maju' THEN '⭐'
    WHEN sd.status = 'berkembang' THEN '📈'
    WHEN sd.status = 'tertinggal' THEN '📉'
    ELSE '⚠️'
  END AS status_emoji,
  -- Ambil indikator yang skor rendah untuk rekomendasi
  (
    SELECT json_agg(json_build_object(
      'indikator', sc.indikator_kode,
      'skor', sc.skor,
      'dimensi', sc.dimensi_nama
    ) ORDER BY sc.skor)
    FROM idm_skor_cache sc
    WHERE sc.tenant_id = sd.tenant_id
      AND sc.skor < 0.6
    LIMIT 5
  ) AS prioritas_perbaikan
FROM idm_status_desa sd;

GRANT SELECT ON idm_dashboard_summary TO authenticated, anon;

-- ============================================================
-- 13. Notification: Low Score Alert
-- ============================================================

CREATE OR REPLACE FUNCTION notify_idm_low_score()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_tenant_id UUID;
  v_indikator_kode VARCHAR;
  v_skor NUMERIC;
BEGIN
  -- Jika skor turun di bawah 0.5, emit event
  IF NEW.skor < 0.5 AND (OLD.skor IS NULL OR OLD.skor >= 0.5) THEN
    -- Emit domain event untuk WA broadcast / notifikasi
    PERFORM publish_event(
      'idm.skor.rendah',
      'idm_skor_cache',
      NEW.id,
      jsonb_build_object(
        'tenant_id', NEW.tenant_id,
        'indikator', NEW.indikator_kode,
        'dimensi', NEW.dimensi_nama,
        'skor', NEW.skor
      ),
      NULL
    );

    -- Insert draft usulan otomatis
    INSERT INTO usulan_kegiatan_draft_otomatis (
      tenant_id, kategori, sumber_pemicu, sumber_ref_id,
      indikator_kode, kode_rekening_saran, judul_saran,
      deskripsi_saran, status
    )
    SELECT
      NEW.tenant_id,
      'pembangunan',
      'idm.skor.rendah',
      NEW.id,
      NEW.indikator_kode,
      ind.kode_rekening,
      'Draft Otomatis: ' || ind.indikator_nama,
      'Skor rendah (' || NEW.skor || '). Rekomendasi: ' || COALESCE(ind.rekomendasi_intervensi, '-'),
      'menunggu_review'
    FROM idm_indicators ind
    WHERE ind.indikator_no = NEW.indikator_kode;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_idm_low_score_alert ON idm_skor_cache;
CREATE TRIGGER trg_idm_low_score_alert
  AFTER INSERT OR UPDATE ON idm_skor_cache
  FOR EACH ROW EXECUTE FUNCTION notify_idm_low_score();

-- ============================================================
-- DONE
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE 'IDM Engine Core migration completed. 30 indicators seeded across 6 dimensions.';
END $$;
