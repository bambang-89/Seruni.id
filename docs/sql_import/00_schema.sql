-- ============================================
-- SCHEMA: DATABASE TABLES FOR SERUNI
-- Run this FIRST before importing data
-- ============================================

-- ============================================
-- KELUARGA TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.keluarga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  no_kk TEXT NOT NULL UNIQUE,
  kepala_nama TEXT,
  alamat TEXT,
  dusun TEXT,
  rt TEXT,
  rw TEXT,
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- PENDUDUK TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.penduduk (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nik TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  jenis_kelamin TEXT CHECK (jenis_kelamin IN ('L','P')),
  tempat_lahir TEXT,
  tanggal_lahir DATE,
  agama TEXT,
  pendidikan TEXT,
  pekerjaan TEXT,
  status_perkawinan TEXT,
  hubungan_kk TEXT,
  keluarga_id UUID REFERENCES public.keluarga(id) ON DELETE SET NULL,
  dusun TEXT,
  alamat TEXT,
  foto_url TEXT,
  status_hidup TEXT NOT NULL DEFAULT 'hidup' CHECK (status_hidup IN ('hidup','meninggal','pindah')),
  catatan TEXT,
  kewarganegaraan TEXT DEFAULT 'Indonesia',
  nama_ibu TEXT,
  nama_bapak TEXT,
  gol_darah TEXT,
  bpjs_kesehatan BOOLEAN,
  bpjs_ketenagakerjaan BOOLEAN,
  bansos BOOLEAN,
  kondisi_fisik TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_penduduk_dusun ON public.penduduk(dusun);
CREATE INDEX IF NOT EXISTS idx_penduduk_keluarga ON public.penduduk(keluarga_id);
CREATE INDEX IF NOT EXISTS idx_penduduk_status ON public.penduduk(status_hidup);
CREATE INDEX IF NOT EXISTS idx_penduduk_jk ON public.penduduk(jenis_kelamin);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER keluarga_updated_at
  BEFORE UPDATE ON public.keluarga
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER penduduk_updated_at
  BEFORE UPDATE ON public.penduduk
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================
-- GRANTS
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.keluarga TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.penduduk TO authenticated;
GRANT ALL ON public.keluarga TO service_role;
GRANT ALL ON public.penduduk TO service_role;

-- ============================================
-- RLS POLICIES
-- ============================================
ALTER TABLE public.keluarga ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.penduduk ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "keluarga admin all" ON public.keluarga;
CREATE POLICY "keluarga admin all" ON public.keluarga FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

DROP POLICY IF EXISTS "penduduk admin all" ON public.penduduk;
CREATE POLICY "penduduk admin all" ON public.penduduk FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ============================================
-- VIEWS FOR STATISTICS
-- ============================================
CREATE OR REPLACE VIEW public.penduduk_statistik AS
SELECT
  COUNT(*) FILTER (WHERE status_hidup='hidup') AS total,
  COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L') AS laki,
  COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P') AS perempuan,
  COUNT(DISTINCT keluarga_id) FILTER (WHERE status_hidup='hidup') AS kk,
  COUNT(DISTINCT dusun) FILTER (WHERE status_hidup='hidup' AND dusun IS NOT NULL) AS dusun
FROM public.penduduk;

CREATE OR REPLACE VIEW public.penduduk_per_dusun AS
SELECT
  dusun,
  COUNT(*) FILTER (WHERE status_hidup='hidup') AS jumlah,
  COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L') AS laki,
  COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P') AS perempuan
FROM public.penduduk
WHERE dusun IS NOT NULL
GROUP BY dusun
ORDER BY dusun;

GRANT SELECT ON public.penduduk_statistik TO anon, authenticated;
GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;

-- ============================================
-- VERIFY
-- ============================================
SELECT 'Schema created successfully!' AS status;
