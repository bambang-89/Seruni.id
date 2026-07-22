-- ============================================================
-- MIGRASI: 20260722000001_add_uuid_refs_and_missing_tables.sql
-- Tanggal: 2026-07-22
-- Deskripsi: Penuh-hampir kebutuhan PEDOMAN_MONOREPO:
--   1. UUID FK columns di penduduk (ref_agama_id, ref_pendidikan_id, dll.)
--   2. Tabel baru yang belum ada
--   3. Seed ref tables yang belum ada
-- ============================================================

-- ============================================================
-- BAGIAN 1: UUID Foreign Key di penduduk (penduduk FK cols)
-- ============================================================
-- Tambahkan kolom UUID FK ke reference tables
-- existing data tetap aman karena kolom baru nullable

ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS agama_id UUID REFERENCES ref_agama(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS pendidikan_id UUID REFERENCES ref_pendidikan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS pekerjaan_id UUID REFERENCES ref_pekerjaan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS status_perkawinan_id UUID REFERENCES ref_status_perkawinan(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS golongan_darah_id UUID REFERENCES ref_golongan_darah(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS warga_negara_id UUID REFERENCES ref_warga_negara(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS dusun_id UUID,  -- FK ke wilolos_batas (dibuat di bagian terpisah)
  ADD COLUMN IF NOT EXISTS rt_id UUID,
  ADD COLUMN IF NOT EXISTS rw_id UUID;

-- Sinkronisasi kolom UUID FK dari data TEXT existing (backfill otomatis)
DO $$
BEGIN
  -- Only backfill if reference tables exist
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ref_golong_darah') THEN
    UPDATE public.penduduk p SET
      agama_id = (SELECT id FROM ref_agama WHERE LOWER(nama) = LOWER(p.agama) LIMIT 1),
      pendidikan_id = (SELECT id FROM ref_pendidikan WHERE LOWER(nama) = LOWER(p.pendidikan) LIMIT 1),
      pekerjaan_id = (SELECT id FROM ref_pekerjaan WHERE LOWER(nama) = LOWER(p.pekerjaan) LIMIT 1),
      status_perkawinan_id = (SELECT id FROM ref_status_perkawinan WHERE LOWER(nama) = LOWER(p.status_kawin) LIMIT 1),
      golongan_darah_id = (SELECT id FROM ref_golong_darah WHERE LOWER(nama) = LOWER(golongan_darah) LIMIT 1);
    RAISE NOTICE 'Penduduk UUID FK backfill completed';
  ELSE
    RAISE NOTICE 'ref_golong_darah not found - skipping penduduk backfill. Run manually when ref tables are created.';
  END IF;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Penduduk backfill skipped or partial: %', SQLERRM;
END $$;

-- ============================================================
-- BAGIAN 2: Tabel domain yang belum ada
-- ============================================================

-- balita (fakta mentah Posyandu F4)
CREATE TABLE IF NOT EXISTS balita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama VARCHAR(150) NOT NULL,
  tanggal_lahir DATE NOT NULL,
  jenis_kelamin VARCHAR(1) CHECK (jenis_kelamin IN ('L','P')),
  orang_tua_penduduk_id UUID REFERENCES penduduk(id) ON DELETE SET NULL,
  dusun VARCHAR(100),
  rt VARCHAR(5), rw VARCHAR(5),
  alamat TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON balita TO authenticated;
GRANT ALL ON balita TO service_role;
ALTER TABLE balita ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: balita read" ON balita FOR SELECT USING (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: balita write" ON balita FOR INSERT WITH CHECK (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: balita update" ON balita FOR UPDATE USING (tenant_id = get_tenant_id());

-- posyandu_kunjungan (fakta mentah Posyandu F4)
CREATE TABLE IF NOT EXISTS posyandu_kunjungan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  balita_id UUID NOT NULL REFERENCES balita(id),
  kader_penduduk_id UUID REFERENCES penduduk(id),
  tanggal DATE NOT NULL,
  berat_kg NUMERIC(5,2),
  tinggi_cm NUMERIC(5,2),
  imunisasi VARCHAR(50)[],
  status_gizi VARCHAR(20) CHECK (status_gizi IN ('baik','kurang','buruk','lebih')),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON posyandu_kunjungan TO authenticated;
GRANT ALL ON posyandu_kunjungan TO service_role;
ALTER TABLE posyandu_kunjungan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: posyandu_kunjungan read" ON posyandu_kunjungan FOR SELECT USING (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: posyandu_kunjungan write" ON posyandu_kunjungan FOR INSERT WITH CHECK (tenant_id = get_tenant_id());
CREATE POLICY "Tenant isolation: posyandu_kunjungan update" ON posyandu_kunjungan FOR UPDATE USING (tenant_id = get_tenant_id());

-- bidang_kegiatan (global seed - sama semua tenant)
CREATE TABLE IF NOT EXISTS bidang_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(2) NOT NULL UNIQUE,
  nama VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON bidang_kegiatan TO authenticated;
GRANT ALL ON bidang_kegiatan TO service_role;
ALTER TABLE bidang_kegiatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read bidang_kegiatan" ON bidang_kegiatan FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage bidang_kegiatan" ON bidang_kegiatan FOR ALL TO service_role USING (true);

-- Seed bidang_kegiatan (Permendagri 20/2018 + IDM)
INSERT INTO bidang_kegiatan (kode, nama) VALUES
  ('1', 'Penyelenggaraan Pemerintahan Desa'),
  ('2', 'Pelaksanaan Pembangunan Desa'),
  ('3', 'Pembinaan Kemasyarakatan'),
  ('4', 'Pelayanan Kecamatan')
ON CONFLICT (kode) DO NOTHING;

-- rekening_anggaran (satu pintu - seed dari IDM/PERMENDES 7/2023 kode rekening)
CREATE TABLE IF NOT EXISTS rekening_anggaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(30) NOT NULL UNIQUE,
  nama VARCHAR(200) NOT NULL,
  jenis VARCHAR(15) NOT NULL CHECK (jenis IN ('pendapatan','belanja','pembiayaan')),
  bidang_id VARCHAR(2), -- ref ke bidang_kegiatan.kode
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON rekening_anggaran TO authenticated;
GRANT ALL ON rekening_anggaran TO service_role;
ALTER TABLE rekening_anggaran ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read rekening_anggaran" ON rekening_anggaran FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage rekening_anggaran" ON rekening_anggaran FOR ALL TO service_role USING (true);

-- Seed rekening_anggaran (subset umum)
INSERT INTO rekening_anggaran (kode, nama, jenis, bidang_id) VALUES
  ('4.01', 'Honorariat PTPD', 'belanja', '1'),
  ('5.01', 'Belanja Modal Tanah', 'belanja', '2'),
  ('5.02', 'Belanja Modal Gedung', 'belanja', '2'),
  ('6.01', 'Pembentukan cadreserta APBDes', 'pembiayaan', '4')
ON CONFLICT (kode) DO NOTHING;

-- notifikasi (inbox per user)
CREATE TABLE IF NOT EXISTS notifikasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  penerima_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  penerima_tipe VARCHAR(20) CHECK (penerima_tipe IN ('user','warga','perangkat')),
  penerima_id UUID,
  judul VARCHAR(200) NOT NULL,
  pesan TEXT NOT NULL,
  tautan TEXT,
  status_baca BOOLEAN NOT NULL DEFAULT false,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_notifikasi_penerima ON notifikasi(penerima_user_id, dibuat_pada DESC);
GRANT SELECT ON notifikasi TO authenticated;
GRANT INSERT ON notifikasi TO service_role;
GRANT UPDATE ON notifikasi TO authenticated;
ALTER TABLE notifikasi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant isolation: notifikasi read" ON notifikasi FOR SELECT TO authenticated USING (tenant_id = get_tenant_id() AND (penerima_user_id = auth.uid() OR auth.uid() IN (SELECT user_id FROM user_peran WHERE peran IN ('admin','kades','sekdes'))));
CREATE POLICY "Service manage notifikasi" ON notifikasi FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "notifikasi_update" ON notifikasi FOR UPDATE TO authenticated USING (penerima_user_id = auth.uid() OR auth.uid() IN (SELECT user_id FROM user_peran WHERE peran IN ('admin','kades','sekdes')));

-- outbox_pesan (antrian kirim pesan WA/SMS/email)
CREATE TABLE IF NOT EXISTS outbox_pesan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  notifikasi_id UUID REFERENCES notifikasi(id) ON DELETE SET NULL,
  channel VARCHAR(10) NOT NULL CHECK (channel IN ('wa','sms','email','push')),
  tujuan VARCHAR(200) NOT NULL,
  isi TEXT NOT NULL,
  status VARCHAR(15) NOT NULL DEFAULT 'antri' CHECK (status IN ('antri','dikirim','gagal','batal')),
  percobaan INT NOT NULL DEFAULT 0,
  error_message TEXT,
  dijadwalkan_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  dikirim_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_outbox_pesan_status ON outbox_pesan(status, dikirim_pada) WHERE status = 'antri';
GRANT SELECT ON outbox_pesan TO authenticated;
GRANT INSERT ON outbox_pesan TO service_role;
GRANT UPDATE ON outbox_pesan TO service_role;
ALTER TABLE outbox_pesan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service manage outbox_pesan" ON outbox_pesan FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service write outbox_pesan" ON outbox_pesan FOR INSERT TO service_role WITH CHECK (true);

-- otp_token (login Layanan Mandiri)
CREATE TABLE IF NOT EXISTS otp_token (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  penduduk_id UUID REFERENCES penduduk(id) ON DELETE CASCADE,
  tujuan VARCHAR(50) NOT NULL CHECK (tujuan IN ('login','verifikasi','reset_password')),
  kode_hash VARCHAR(255) NOT NULL,
  expired_at TIMESTAMPTZ NOT NULL,
  percobaan INT NOT NULL DEFAULT 0,
  digunakan BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_otp_token ON otp_token(tenant_id, kode_hash) WHERE digunakan = false;
GRANT SELECT ON otp_token TO authenticated;
GRANT INSERT ON otp_token TO service_role;
GRANT UPDATE ON otp_token TO service_role;
ALTER TABLE otp_token ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service manage otp_token" ON otp_token FOR ALL TO service_role USING (true);

-- wa_chat_session (WA chatbot state)
CREATE TABLE IF NOT EXISTS wa_chat_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  current_state VARCHAR(30) NOT NULL DEFAULT 'menu_utama',
  tier VARCHAR(15) NOT NULL DEFAULT 'transaksi' CHECK (tier IN ('info_instan','transaksi')),
  context_data JSONB NOT NULL DEFAULT '{}',
  current_entity_id UUID,
  current_entity_tipe VARCHAR(30),
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(tenant_id, nomor_hp)
);
-- Note: Partial index with now() removed - use query 'DELETE FROM wa_chat_session WHERE expires_at < now()' for cleanup
CREATE INDEX IF NOT EXISTS idx_wa_session_tenant ON wa_chat_session(tenant_id);
GRANT SELECT ON wa_chat_session TO authenticated;
GRANT ALL ON wa_chat_session TO service_role;
ALTER TABLE wa_chat_session ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read wa_chat_session" ON wa_chat_session FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service manage wa_chat_session" ON wa_chat_session FOR ALL TO service_role USING (true);

-- ============================================================
-- BAGIAN 3: Trigger penduduk UUID backfill (idempotent)
-- Trigger di penduduk sudah ada (trg_penduduk_publish_event) - hanya backfill UUID FK
-- ============================================================

-- Kolom trigger tidak perlu perubahan karena trigger TEXT-based sudah jalan
-- Berikut trigger backfill UUID FK saat data penduduk di-update manual
CREATE OR REPLACE FUNCTION backfill_penduduk_uuid_fk()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  UPDATE public.penduduk p SET
    agama_id = sub.id
  FROM ref_agama sub
  WHERE LOWER(sub.nama) = LOWER(p.agama)
    AND p.agama_id IS NULL;

  UPDATE public.penduduk p SET
    pendidikan_id = sub.id
  FROM ref_pendidikan sub
  WHERE LOWER(sub.nama) = LOWER(p.pendidikan)
    AND p.pendidikan_id IS NULL;
END;
$$;

-- ============================================================
-- BAGIAN 4: Verifikasi
-- ============================================================
SELECT 'Tables created:' as info, COUNT(*) as count
FROM information_schema.tables WHERE table_schema = 'public'
  AND table_name IN (
    'balita','posyandu_kunjungan','bidang_kegiatan','rekening_anggaran',
    'notifikasi','outbox_pesan','otp_token','wa_chat_session'
  );
