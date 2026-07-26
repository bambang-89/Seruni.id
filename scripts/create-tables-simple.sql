-- Simple migration: Create missing tables only
-- Run: Paste to Supabase SQL Editor

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
  status TEXT DEFAULT 'proses',
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

CREATE TABLE IF NOT EXISTS public.pemilihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  judul TEXT NOT NULL,
  periode TEXT,
  tanggal_pemilihan DATE,
  status TEXT DEFAULT 'rencana',
  jumlah_dpt INT DEFAULT 0,
  partisipasi INT DEFAULT 0,
  suara_sah INT DEFAULT 0,
  suara_tidak_sah INT DEFAULT 0,
  pemenang_id UUID,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.calon_kades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  pemilihan_id UUID,
  nama TEXT NOT NULL,
  nik TEXT,
  nomor_urut INT,
  foto_url TEXT,
  visi TEXT,
  misi TEXT,
  program_unggulan TEXT,
  suara_total INT DEFAULT 0,
  status TEXT DEFAULT 'daftar',
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.idm_scoring_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  indikator_id UUID,
  skor_lama NUMERIC(5,4),
  skor_baru NUMERIC(5,4) NOT NULL,
  kategori TEXT,
  sub_indikator TEXT,
  nilai_aktual NUMERIC,
  sumber_data TEXT,
  catatteknis TEXT,
  calculated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.pbb_pembayaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  tagihan_id UUID,
  tahun_pajak INT NOT NULL,
  jumlah_bayar NUMERIC(12,0) NOT NULL,
  tanggal_bayar DATE NOT NULL,
  metode_bayar TEXT DEFAULT 'tunai',
  bank_tujuan TEXT,
  nomor_sts TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bansos_penerima (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  bantuan_id UUID,
  penduduk_id UUID,
  keluarga_id UUID,
  dusun TEXT,
  status TEXT DEFAULT 'terdaftar',
  tanggal_daftar DATE,
  tanggal_terima DATE,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.posyandu_balita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  posyandu_id UUID,
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

CREATE TABLE IF NOT EXISTS public.bencana_bantuan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  kejadian_id UUID,
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

CREATE TABLE IF NOT EXISTS public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID,
  user_id UUID,
  username TEXT,
  aksi TEXT NOT NULL,
  tabel TEXT,
  record_id UUID,
  data_lama JSONB,
  data_baru JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY,
  tenant_id UUID,
  nik TEXT UNIQUE,
  nama TEXT,
  email TEXT,
  telepon TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  aktif BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create indexes for audit_log
CREATE INDEX IF NOT EXISTS idx_audit_log_tenant ON public.audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON public.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_tabel ON public.audit_log(tabel);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON public.audit_log(created_at DESC);

-- Enable RLS
ALTER TABLE public.apotek_desa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apotek_obat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apotek_resep ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perpustakaan_desa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buku_perpustakaan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pemilihan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calon_kades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.idm_scoring_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pbb_pembayaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bansos_penerima ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posyandu_balita ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bencana_bantuan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Grants
GRANT SELECT ON public.apotek_desa TO anon, authenticated;
GRANT SELECT ON public.apotek_obat TO anon, authenticated;
GRANT SELECT ON public.apotek_resep TO anon, authenticated;
GRANT SELECT ON public.perpustakaan_desa TO anon, authenticated;
GRANT SELECT ON public.buku_perpustakaan TO anon, authenticated;
GRANT SELECT ON public.pemilihan TO anon, authenticated;
GRANT SELECT ON public.calon_kades TO anon, authenticated;
GRANT SELECT ON public.idm_scoring_log TO anon, authenticated;
GRANT SELECT ON public.pbb_pembayaran TO anon, authenticated;
GRANT SELECT ON public.bansos_penerima TO anon, authenticated;
GRANT SELECT ON public.posyandu_balita TO anon, authenticated;
GRANT SELECT ON public.bencana_bantuan TO anon, authenticated;
GRANT SELECT ON public.audit_log TO authenticated;
GRANT SELECT ON public.user_profiles TO anon, authenticated;

GRANT ALL ON public.apotek_desa TO service_role;
GRANT ALL ON public.apotek_obat TO service_role;
GRANT ALL ON public.apotek_resep TO service_role;
GRANT ALL ON public.perpustakaan_desa TO service_role;
GRANT ALL ON public.buku_perpustakaan TO service_role;
GRANT ALL ON public.pemilihan TO service_role;
GRANT ALL ON public.calon_kades TO service_role;
GRANT ALL ON public.idm_scoring_log TO service_role;
GRANT ALL ON public.pbb_pembayaran TO service_role;
GRANT ALL ON public.bansos_penerima TO service_role;
GRANT ALL ON public.posyandu_balita TO service_role;
GRANT ALL ON public.bencana_bantuan TO service_role;
GRANT ALL ON public.audit_log TO service_role;
GRANT ALL ON public.user_profiles TO service_role;

SELECT 'Tables created successfully!' as result;
