-- ============================================================
-- MIGRATION: Create Missing Tables
-- Date: 2026-07-23
-- Purpose: Add tables referenced in admin but not yet created
-- ============================================================

BEGIN;

-- ============================================================
-- 1. APOTEK DESA
-- ============================================================
CREATE TABLE IF NOT EXISTS public.apotek_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  alamat TEXT,
  telepon TEXT,
  jadwal TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.apotek_desa TO anon, authenticated;
GRANT ALL ON public.apotek_desa TO service_role;
ALTER TABLE public.apotek_desa ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read apotek_desa" ON public.apotek_desa FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER apotek_desa_updated
    BEFORE UPDATE ON public.apotek_desa
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 2. APOTEK OBAT (Stock Obat)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.apotek_obat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nama_obat TEXT NOT NULL,
  kategori TEXT DEFAULT 'Umum',
  satuan TEXT DEFAULT 'tablet',
  stok INT DEFAULT 0,
  harga NUMERIC(12,0) DEFAULT 0,
  expired DATE,
  supplier TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.apotek_obat TO anon, authenticated;
GRANT ALL ON public.apotek_obat TO service_role;
ALTER TABLE public.apotek_obat ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read apotek_obat" ON public.apotek_obat FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER apotek_obat_updated
    BEFORE UPDATE ON public.apotek_obat
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 3. APOTEK RESEP
-- ============================================================
CREATE TABLE IF NOT EXISTS public.apotek_resep (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nomor_resep TEXT NOT NULL,
  tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
  pasien_nama TEXT NOT NULL,
  pasien_alamat TEXT,
  diagnosa TEXT,
  dokter TEXT,
  obat_list JSONB DEFAULT '[]'::jsonb,
  total_harga NUMERIC(12,0) DEFAULT 0,
  status TEXT DEFAULT 'proses' CHECK (status IN ('proses', 'selesai', 'batal')),
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.apotek_resep TO anon, authenticated;
GRANT ALL ON public.apotek_resep TO service_role;
ALTER TABLE public.apotek_resep ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read apotek_resep" ON public.apotek_resep FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER apotek_resep_updated
    BEFORE UPDATE ON public.apotek_resep
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 4. PERPUSTAKAAN DESA
-- ============================================================
CREATE TABLE IF NOT EXISTS public.perpustakaan_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  alamat TEXT,
  telepon TEXT,
  jam_buka TEXT DEFAULT '08:00-16:00',
  jumblah_anggota INT DEFAULT 0,
  koleksi_buku INT DEFAULT 0,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.perpustakaan_desa TO anon, authenticated;
GRANT ALL ON public.perpustakaan_desa TO service_role;
ALTER TABLE public.perpustakaan_desa ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read perpustakaan_desa" ON public.perpustakaan_desa FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER perpustakaan_desa_updated
    BEFORE UPDATE ON public.perpustakaan_desa
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 5. BUKU PERPUSTAKAAN
-- ============================================================
CREATE TABLE IF NOT EXISTS public.buku_perpustakaan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  judul TEXT NOT NULL,
  pengarang TEXT,
  isbn TEXT,
  penerbit TEXT,
  tahun_terbit INT,
  kategori TEXT DEFAULT 'Umum',
  rak TEXT,
  stok INT DEFAULT 1,
  deskripsi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.buku_perpustakaan TO anon, authenticated;
GRANT ALL ON public.buku_perpustakaan TO service_role;
ALTER TABLE public.buku_perpustakaan ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read buku_perpustakaan" ON public.buku_perpustakaan FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER buku_perpustakaan_updated
    BEFORE UPDATE ON public.buku_perpustakaan
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 6. PEMILIHAN (Data Pemilihan Kepala Desa)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.pemilihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  judul TEXT NOT NULL,
  periode TEXT,
  tanggal_pemilihan DATE,
  status TEXT DEFAULT 'rencana' CHECK (status IN ('rencana', 'pendaftaran', 'penetapan', 'pemungutan', 'penghitungan', 'selesai', 'batal')),
  jumlah_dpt INT DEFAULT 0,
  partisipasi INT DEFAULT 0,
  suara_sah INT DEFAULT 0,
  suara_tidak_sah INT DEFAULT 0,
  pemenang_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.pemilihan TO anon, authenticated;
GRANT ALL ON public.pemilihan TO service_role;
ALTER TABLE public.pemilihan ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read pemilihan" ON public.pemilihan FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER pemilihan_updated
    BEFORE UPDATE ON public.pemilihan
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 7. CALON KEPALA DESA
-- ============================================================
CREATE TABLE IF NOT EXISTS public.calon_kades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  pemilihan_id UUID REFERENCES pemilihan(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  nik TEXT,
  nomor_urut INT,
  foto_url TEXT,
  visi TEXT,
  misi TEXT,
  program_unggulan TEXT,
  suara_total INT DEFAULT 0,
  status TEXT DEFAULT 'daftar' CHECK (status IN ('daftar', 'lolos', 'menang', 'kalah')),
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.calon_kades TO anon, authenticated;
GRANT ALL ON public.calon_kades TO service_role;
ALTER TABLE public.calon_kades ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read calon_kades" ON public.calon_kades FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER calon_kades_updated
    BEFORE UPDATE ON public.calon_kades
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 8. IDM SCORING LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS public.idm_scoring_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_id UUID REFERENCES idm_indikator(id) ON DELETE SET NULL,
  skor_lama NUMERIC(5,4),
  skor_baru NUMERIC(5,4) NOT NULL,
  kategori TEXT,
  sub_indikator TEXT,
  nilai_aktual NUMERIC,
  sumber_data TEXT,
  catatan TEXT,
  calculated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.idm_scoring_log TO anon, authenticated;
GRANT ALL ON public.idm_scoring_log TO service_role;

-- ============================================================
-- 9. PBB PEMBAYARAN
-- ============================================================
CREATE TABLE IF NOT EXISTS public.pbb_pembayaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  tagihan_id UUID REFERENCES pbb_tagihan(id) ON DELETE CASCADE,
  tahun_pajak INT NOT NULL,
  jumlah_bayar NUMERIC(12,0) NOT NULL,
  tanggal_bayar DATE NOT NULL,
  metode_bayar TEXT DEFAULT 'tunai' CHECK (metode_bayar IN ('tunai', 'transfer', 'debit')),
  bank_tujuan TEXT,
  nomor_sts TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.pbb_pembayaran TO anon, authenticated;
GRANT ALL ON public.pbb_pembayaran TO service_role;

-- ============================================================
-- 10. BANSOS PENERIMA (Detail Penerima Bansos)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.bansos_penerima (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  bantuan_id UUID REFERENCES bantuan_sosial(id) ON DELETE CASCADE,
  penduduk_id UUID REFERENCES penduduk(id) ON DELETE SET NULL,
  keluarga_id UUID REFERENCES keluarga(id) ON DELETE SET NULL,
  dusun TEXT,
  status TEXT DEFAULT 'terdaftar' CHECK (status IN ('terdaftar', 'terverifikasi', 'diterima', 'ditolak')),
  tanggal_daftar DATE,
  tanggal_terima DATE,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.bansos_penerima TO anon, authenticated;
GRANT ALL ON public.bansos_penerima TO service_role;
ALTER TABLE public.bansos_penerima ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read bansos_penerima" ON public.bansos_penerima FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER bansos_penerima_updated
    BEFORE UPDATE ON public.bansos_penerima
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 11. POSYANDU BALITA (Detail Data Balita)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.posyandu_balita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  posyandu_id UUID REFERENCES posyandu_agregat(id) ON DELETE SET NULL,
  nama TEXT NOT NULL,
  nik TEXT,
  jenis_kelamin TEXT CHECK (jenis_kelamin IN ('L', 'P')),
  tanggal_lahir DATE NOT NULL,
  berat_badan NUMERIC(5,2),
  tinggi_badan NUMERIC(5,1),
  lingkar_kepala NUMERIC(5,1),
  status_gizi TEXT,
  z_score NUMERIC(5,2),
  imunisasi TEXT,
  vitamin TEXT,
  kelas_bayi TEXT,
  nama_ortu TEXT,
  alamat TEXT,
  dusun TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.posyandu_balita TO anon, authenticated;
GRANT ALL ON public.posyandu_balita TO service_role;
ALTER TABLE public.posyandu_balita ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read posyandu_balita" ON public.posyandu_balita FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER posyandu_balita_updated
    BEFORE UPDATE ON public.posyandu_balita
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 12. BENCANA BANTUAN
-- ============================================================
CREATE TABLE IF NOT EXISTS public.bencana_bantuan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  kejadian_id UUID REFERENCES bencana_kejadian(id) ON DELETE CASCADE,
  jenis_bantuan TEXT NOT NULL,
  sumber TEXT,
  jumlah INT DEFAULT 1,
  satuan TEXT DEFAULT 'paket',
  penerima TEXT,
  lokasi TEXT,
  tanggal DATE,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.bencana_bantuan TO anon, authenticated;
GRANT ALL ON public.bencana_bantuan TO service_role;
ALTER TABLE public.bencana_bantuan ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read bencana_bantuan" ON public.bencana_bantuan FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER bencana_bantuan_updated
    BEFORE UPDATE ON public.bencana_bantuan
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 13. AUDIT LOG (Comprehensive Audit Trail)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
  user_id UUID,
  username TEXT,
  aksi TEXT NOT NULL CHECK (aksi IN ('CREATE', 'READ', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'EXPORT', 'IMPORT')),
  tabel TEXT,
  record_id UUID,
  data_lama JSONB,
  data_baru JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_tenant ON public.audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON public.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_tabel ON public.audit_log(tabel);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON public.audit_log(created_at DESC);

GRANT SELECT ON public.audit_log TO authenticated;
GRANT ALL ON public.audit_log TO service_role;

-- ============================================================
-- 14. USER PROFILES (Extended Profile)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
  nik TEXT UNIQUE,
  nama TEXT,
  email TEXT,
  telepon TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'operator', 'kades', 'user')),
  aktif BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.user_profiles TO anon, authenticated;
GRANT ALL ON public.user_profiles TO service_role;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  CREATE POLICY "Public read user_profiles" ON public.user_profiles FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE TRIGGER user_profiles_updated
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- 15. SEED DATA MINIMAL
-- ============================================================

-- Get tenant ID
DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;

  IF v_tenant_id IS NOT NULL THEN
    -- Seed apotek_desa
    INSERT INTO public.apotek_desa (tenant_id, nama, alamat, jadwal, keterangan)
    VALUES (v_tenant_id, 'Apotek Desa Seruni Mumbul', 'Kantor Desa Seruni Mumbul', 'Senin-Sabtu 08:00-16:00', 'Apotek umum desa')
    ON CONFLICT DO NOTHING;

    -- Seed perpustakaan_desa
    INSERT INTO public.perpustakaan_desa (tenant_id, nama, alamat, jam_buka, keterangan)
    VALUES (v_tenant_id, 'Perpustakaan Desa Seruni Mumbul', 'Kantor Desa Seruni Mumbul', 'Senin-Sabtu 08:00-15:00', 'Perpustakaan umum desa')
    ON CONFLICT DO NOTHING;

    -- Seed apotek_obat sample
    INSERT INTO public.apotek_obat (tenant_id, nama_obat, kategori, satuan, stok, harga, keterangan)
    VALUES
      (v_tenant_id, 'Paracetamol 500mg', 'Obat Demam', 'tablet', 500, 100, 'Obat penurun demam'),
      (v_tenant_id, 'Amoxicillin 500mg', 'Antibiotik', 'kapsul', 200, 250, 'Antibiotik umum'),
      (v_tenant_id, 'OBH Combi', 'Obat Batuk', 'botol', 50, 15000, 'Obat batuk flu'),
      (v_tenant_id, 'Minyak Kayu Putih', 'Obat Luar', 'botol', 30, 12000, 'Minyak gosok')
    ON CONFLICT DO NOTHING;

    -- Seed buku sample
    INSERT INTO public.buku_perpustakaan (tenant_id, judul, pengarang, kategori, rak, stok)
    VALUES
      (v_tenant_id, 'Pengantar Pemerintahan Desa', 'Kementerian Dalam Negeri', 'Politik', 'A-1', 3),
      (v_tenant_id, 'Pedoman APBDes', 'Kemendagri', 'Keuangan', 'B-2', 5),
      (v_tenant_id, 'Kesehatan Ibu dan Anak', 'WHO', 'Kesehatan', 'C-3', 4)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Seed data inserted for new tables';
  END IF;
END $$;

COMMIT;

-- ============================================================
-- SUMMARY
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRATION COMPLETE: Missing Tables Created';
  RAISE NOTICE '========================================';
END $$;
