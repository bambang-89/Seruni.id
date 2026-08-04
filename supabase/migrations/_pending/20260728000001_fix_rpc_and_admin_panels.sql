-- ============================================================
-- FIX: RPC Syntax Errors & Missing Admin Panels
-- ============================================================

-- 1. FIX submit_usulan RPC - missing closing parenthesis
CREATE OR REPLACE FUNCTION public.submit_usulan(
  p_judul TEXT,
  p_deskripsi TEXT,
  p_dusun TEXT,
  p_nama TEXT,
  p_kontak TEXT,
  p_kategori TEXT DEFAULT 'infrastruktur',
  p_lokasi TEXT DEFAULT NULL,
  p_foto_url TEXT DEFAULT NULL,
  p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
  v_nomor TEXT;
  v_tenant UUID;
BEGIN
  -- Get tenant
  v_tenant := COALESCE(p_tenant_id, (SELECT id FROM tenants LIMIT 1));

  -- Generate nomor tiket
  v_nomor := 'USL-' || to_char(NOW(), 'YYYYMM') || '-' || encode(gen_random_bytes(2), 'hex');

  INSERT INTO public.usulan_warga (
    tenant_id, judul, deskripsi, dusun, nama, kontak,
    kategori, lokasi, foto_url, status, vote_count, nomor_tiket
  ) VALUES (
    v_tenant,
    p_judul, p_deskripsi, p_dusun, p_nama, p_kontak,
    p_kategori, p_lokasi, p_foto_url, 'diajukan', 0, v_nomor
  ) ON CONFLICT (nomor_tiket) DO NOTHING RETURNING id INTO v_id

  RETURN jsonb_build_object('id', v_id, 'nomor_tiket', v_nomor, 'status', 'submitted');
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_usulan TO anon, authenticated;

-- 2. FIX submit_surat RPC - missing closing parenthesis
CREATE OR REPLACE FUNCTION public.submit_surat(
  p_jenis_surat TEXT,
  p_pemohon_nama TEXT,
  p_pemohon_nik TEXT DEFAULT NULL,
  p_perihal TEXT DEFAULT NULL,
  p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
  v_nomor TEXT;
  v_kode TEXT;
BEGIN
  -- Generate nomor surat
  v_nomor := '470/' || to_char(NOW(), 'YYMM') || '/SM/' || to_char(NOW(), 'YYYY');
  v_kode := 'SRN-' || encode(gen_random_bytes(4), 'hex');

  INSERT INTO public.surat_terbit (
    tenant_id, jenis_kode, jenis_nama, nomor_surat, kode_verifikasi,
    pemohon_nama, pemohon_nik, perihal, status, tanggal_terbit
  ) VALUES (
    COALESCE(p_tenant_id, (SELECT id FROM tenants LIMIT 1)),
    p_jenis_surat, p_jenis_surat,
    v_nomor, v_kode,
    p_pemohon_nama, p_pemohon_nik, COALESCE(p_perihal, p_jenis_surat),
    'diajukan', CURRENT_DATE
  ) RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'nomor_surat', v_nomor, 'kode_verifikasi', v_kode, 'status', 'submitted');
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_surat TO anon, authenticated;

-- 3. FIX infrastruktur table - add missing columns
ALTER TABLE public.infrastruktur
  ADD COLUMN IF NOT EXISTS tahun_bangun INT,
  ADD COLUMN IF NOT EXISTS tahun_perbaikan INT,
  ADD COLUMN IF NOT EXISTS volume TEXT,
  ADD COLUMN IF NOT EXISTS sumber_dana TEXT;

-- Update column comments
COMMENT ON COLUMN public.infrastruktur.tahun_bangun IS 'Tahun infrastruktur dibangun';
COMMENT ON COLUMN public.infrastruktur.tahun_perbaikan IS 'Tahun infrastruktur terakhir diperbaiki';
COMMENT ON COLUMN public.infrastruktur.volume IS 'Volume pekerjaan (contoh: 100m x 3m)';
COMMENT ON COLUMN public.infrastruktur.sumber_dana IS 'Sumber dana (APBDes/Dana Desa/Hibah dll)';

-- 4. Create admin panel tables for monitoring

-- balita management table (individual child data)
CREATE TABLE IF NOT EXISTS public.balita_admin (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  nik_anak TEXT,
  nama TEXT NOT NULL,
  tanggal_lahir DATE NOT NULL,
  jenis_kelamin TEXT CHECK (jenis_kelamin IN ('laki-laki', 'perempuan')),
  nama_ortu TEXT,
  Burnett TEXT,
  Rt TEXT,
  Rw TEXT,
  alamat TEXT,
  berat_badan DECIMAL(5,2),
  tinggi_badan DECIMAL(5,2),
  status_gizi TEXT CHECK (status_gizi IN ('baik', 'kurang', 'buruk', 'overweight')),
  imunisasi_lengkap BOOLEAN DEFAULT false,
  catatan TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.balita_admin TO authenticated;
GRANT ALL ON public.balita_admin TO service_role;
ALTER TABLE public.balita_admin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "balita_admin_all" ON public.balita_admin FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER trg_balita_admin_updated BEFORE UPDATE ON public.balita_admin
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- wa_chatbot_session monitoring
CREATE TABLE IF NOT EXISTS public.wa_chatbot_admin (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id TEXT NOT NULL,
  phone_number TEXT,
  message TEXT,
  response TEXT,
  intent TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wa_chatbot_admin_session ON public.wa_chatbot_admin(session_id);
CREATE INDEX IF NOT EXISTS idx_wa_chatbot_admin_created ON public.wa_chatbot_admin(created_at DESC);

GRANT SELECT ON public.wa_chatbot_admin TO authenticated;
GRANT ALL ON public.wa_chatbot_admin TO service_role;
ALTER TABLE public.wa_chatbot_admin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "wa_chatbot_admin_read" ON public.wa_chatbot_admin FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- notification log for monitoring
CREATE TABLE IF NOT EXISTS public.notifikasi_admin (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  jenis TEXT NOT NULL,
  judul TEXT NOT NULL,
  pesan TEXT NOT NULL,
  target_role TEXT,
  status TEXT DEFAULT 'pending',
  dibaca BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE ON public.notifikasi_admin TO authenticated;
GRANT ALL ON public.notifikasi_admin TO service_role;
ALTER TABLE public.notifikasi_admin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notifikasi_admin_all" ON public.notifikasi_admin FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Verification
SELECT 'Fix migration complete' AS result;
