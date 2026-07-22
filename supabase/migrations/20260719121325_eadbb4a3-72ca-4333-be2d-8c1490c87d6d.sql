
-- Phase 6A: Kanal Warga

-- 1) Langganan WA
CREATE TABLE public.langganan_wa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama text NOT NULL,
  nomor_wa text NOT NULL,
  dusun text,
  topik text[] NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'aktif',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (nomor_wa)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.langganan_wa TO authenticated;
GRANT INSERT ON public.langganan_wa TO anon;
GRANT ALL ON public.langganan_wa TO service_role;
ALTER TABLE public.langganan_wa ENABLE ROW LEVEL SECURITY;
CREATE POLICY langganan_admin_all ON public.langganan_wa FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY langganan_public_insert ON public.langganan_wa FOR INSERT TO anon
  WITH CHECK (
    char_length(trim(nama)) BETWEEN 2 AND 120
    AND char_length(trim(nomor_wa)) BETWEEN 8 AND 20
    AND status = 'aktif'
  );
CREATE TRIGGER trg_langganan_updated BEFORE UPDATE ON public.langganan_wa
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2) Surat Terbit (untuk verifikasi publik)
CREATE TABLE public.surat_terbit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_surat text NOT NULL UNIQUE,
  kode_verifikasi text NOT NULL,
  jenis_kode text NOT NULL,
  jenis_nama text NOT NULL,
  perihal text NOT NULL,
  pemohon_nama text NOT NULL,
  pemohon_nik text,
  tanggal_terbit date NOT NULL DEFAULT current_date,
  berlaku_sampai date,
  status text NOT NULL DEFAULT 'berlaku',
  penandatangan text,
  keterangan text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_terbit TO authenticated;
GRANT ALL ON public.surat_terbit TO service_role;
ALTER TABLE public.surat_terbit ENABLE ROW LEVEL SECURITY;
CREATE POLICY surat_terbit_admin_all ON public.surat_terbit FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_surat_terbit_updated BEFORE UPDATE ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3) RPC: verifikasi surat publik
CREATE OR REPLACE FUNCTION public.verifikasi_surat(_nomor text, _kode text)
RETURNS TABLE (
  nomor_surat text, jenis_kode text, jenis_nama text, perihal text,
  pemohon_nama text, tanggal_terbit date, berlaku_sampai date,
  status text, penandatangan text
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT s.nomor_surat, s.jenis_kode, s.jenis_nama, s.perihal,
         s.pemohon_nama, s.tanggal_terbit, s.berlaku_sampai,
         s.status, s.penandatangan
  FROM public.surat_terbit s
  WHERE lower(trim(s.nomor_surat)) = lower(trim(_nomor))
    AND lower(trim(s.kode_verifikasi)) = lower(trim(_kode))
  LIMIT 1;
$$;
GRANT EXECUTE ON FUNCTION public.verifikasi_surat(text,text) TO anon, authenticated;

-- 4) RPC: tracking aduan publik (tanpa expose data pelapor lain)
CREATE OR REPLACE FUNCTION public.lacak_aduan(_nomor_tiket text)
RETURNS TABLE (
  nomor_tiket text, judul text, kategori aduan_kategori,
  status workflow_status, tanggapan text,
  created_at timestamptz, updated_at timestamptz
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT a.nomor_tiket, a.judul, a.kategori, a.status, a.tanggapan,
         a.created_at, a.updated_at
  FROM public.aduan_warga a
  WHERE lower(trim(a.nomor_tiket)) = lower(trim(_nomor_tiket))
  LIMIT 1;
$$;
GRANT EXECUTE ON FUNCTION public.lacak_aduan(text) TO anon, authenticated;

-- 5) Seed contoh surat untuk demo verifikasi
INSERT INTO public.surat_terbit (nomor_surat, kode_verifikasi, jenis_kode, jenis_nama, perihal, pemohon_nama, pemohon_nik, tanggal_terbit, berlaku_sampai, status, penandatangan)
VALUES
 ('470/001/SM/2026', 'SRN-DEMO-001', 'SKD', 'Surat Keterangan Domisili', 'Keterangan Domisili untuk keperluan administrasi', 'Ahmad Susanto', '5201010101010001', current_date - 5, current_date + 180, 'berlaku', 'Kepala Desa Seruni Mumbul'),
 ('474/002/SM/2026', 'SRN-DEMO-002', 'SKU', 'Surat Keterangan Usaha', 'Keterangan Usaha warung sembako', 'Siti Rahmawati', '5201010202020002', current_date - 30, current_date + 335, 'berlaku', 'Kepala Desa Seruni Mumbul');
