
CREATE TABLE public.keluarga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  no_kk TEXT NOT NULL UNIQUE,
  kepala_nama TEXT, alamat TEXT, dusun TEXT, rt TEXT, rw TEXT, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.keluarga TO authenticated;
GRANT ALL ON public.keluarga TO service_role;
ALTER TABLE public.keluarga ENABLE ROW LEVEL SECURITY;
CREATE POLICY "keluarga admin all" ON public.keluarga FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER keluarga_updated_at BEFORE UPDATE ON public.keluarga FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER keluarga_audit AFTER INSERT OR UPDATE OR DELETE ON public.keluarga FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.penduduk (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nik TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  jenis_kelamin TEXT CHECK (jenis_kelamin IN ('L','P')),
  tempat_lahir TEXT, tanggal_lahir DATE,
  agama TEXT, pendidikan TEXT, pekerjaan TEXT, status_kawin TEXT, hubungan_kk TEXT,
  keluarga_id UUID REFERENCES public.keluarga(id) ON DELETE SET NULL,
  dusun TEXT, alamat TEXT, foto_url TEXT,
  status_hidup TEXT NOT NULL DEFAULT 'hidup' CHECK (status_hidup IN ('hidup','meninggal','pindah')),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.penduduk TO authenticated;
GRANT ALL ON public.penduduk TO service_role;
ALTER TABLE public.penduduk ENABLE ROW LEVEL SECURITY;
CREATE POLICY "penduduk admin all" ON public.penduduk FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE INDEX penduduk_dusun_idx ON public.penduduk(dusun);
CREATE INDEX penduduk_keluarga_idx ON public.penduduk(keluarga_id);
CREATE TRIGGER penduduk_updated_at BEFORE UPDATE ON public.penduduk FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER penduduk_audit AFTER INSERT OR UPDATE OR DELETE ON public.penduduk FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.buku_register (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jenis_buku TEXT NOT NULL, nomor TEXT, tanggal DATE,
  uraian TEXT, pihak TEXT, lampiran_url TEXT, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.buku_register TO authenticated;
GRANT ALL ON public.buku_register TO service_role;
ALTER TABLE public.buku_register ENABLE ROW LEVEL SECURITY;
CREATE POLICY "buku_register admin all" ON public.buku_register FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER buku_register_updated_at BEFORE UPDATE ON public.buku_register FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER buku_register_audit AFTER INSERT OR UPDATE OR DELETE ON public.buku_register FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.idm_indikator (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL, dimensi TEXT NOT NULL, indikator TEXT NOT NULL,
  nilai NUMERIC, skor NUMERIC, sumber TEXT, keterangan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.idm_indikator TO authenticated;
GRANT SELECT ON public.idm_indikator TO anon;
GRANT ALL ON public.idm_indikator TO service_role;
ALTER TABLE public.idm_indikator ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idm public read" ON public.idm_indikator FOR SELECT USING (published = true);
CREATE POLICY "idm admin all" ON public.idm_indikator FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER idm_updated_at BEFORE UPDATE ON public.idm_indikator FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER idm_audit AFTER INSERT OR UPDATE OR DELETE ON public.idm_indikator FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.analisis_snapshot (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kategori TEXT NOT NULL, judul TEXT NOT NULL, tahun INT,
  nilai_json JSONB NOT NULL DEFAULT '{}'::jsonb, ringkasan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.analisis_snapshot TO authenticated;
GRANT SELECT ON public.analisis_snapshot TO anon;
GRANT ALL ON public.analisis_snapshot TO service_role;
ALTER TABLE public.analisis_snapshot ENABLE ROW LEVEL SECURITY;
CREATE POLICY "analisis public read" ON public.analisis_snapshot FOR SELECT USING (published = true);
CREATE POLICY "analisis admin all" ON public.analisis_snapshot FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER analisis_updated_at BEFORE UPDATE ON public.analisis_snapshot FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER analisis_audit AFTER INSERT OR UPDATE OR DELETE ON public.analisis_snapshot FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.sinkron_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target TEXT NOT NULL,
  arah TEXT NOT NULL DEFAULT 'keluar' CHECK (arah IN ('keluar','masuk')),
  status TEXT NOT NULL DEFAULT 'antre' CHECK (status IN ('antre','berhasil','gagal')),
  jumlah INT DEFAULT 0, pesan TEXT, payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sinkron_log TO authenticated;
GRANT ALL ON public.sinkron_log TO service_role;
ALTER TABLE public.sinkron_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sinkron admin all" ON public.sinkron_log FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER sinkron_updated_at BEFORE UPDATE ON public.sinkron_log FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.suplesi_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE DEFAULT ('SPL-' || to_char(now(),'YYYYMM') || '-' || lpad((floor(random()*10000))::text, 4, '0')),
  nik TEXT, nama TEXT, kontak TEXT,
  jenis TEXT NOT NULL, deskripsi TEXT NOT NULL, lampiran_url TEXT,
  status TEXT NOT NULL DEFAULT 'baru' CHECK (status IN ('baru','diverifikasi','disetujui','ditolak','selesai')),
  tanggapan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.suplesi_data TO authenticated;
GRANT ALL ON public.suplesi_data TO service_role;
ALTER TABLE public.suplesi_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "suplesi admin all" ON public.suplesi_data FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER suplesi_updated_at BEFORE UPDATE ON public.suplesi_data FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER suplesi_audit AFTER INSERT OR UPDATE OR DELETE ON public.suplesi_data FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();

CREATE TABLE public.notif_otp (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kanal TEXT NOT NULL CHECK (kanal IN ('wa','sms','email')),
  tujuan TEXT NOT NULL, kode_hash TEXT NOT NULL,
  kadaluarsa TIMESTAMPTZ NOT NULL,
  terpakai BOOLEAN NOT NULL DEFAULT false, percobaan INT NOT NULL DEFAULT 0,
  konteks TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT ALL ON public.notif_otp TO service_role;
ALTER TABLE public.notif_otp ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE VIEW public.penduduk_statistik AS
  SELECT
    COUNT(*) FILTER (WHERE status_hidup='hidup')                            AS total,
    COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L')      AS laki,
    COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P')      AS perempuan,
    COUNT(DISTINCT keluarga_id) FILTER (WHERE status_hidup='hidup')         AS kk,
    COUNT(DISTINCT dusun) FILTER (WHERE status_hidup='hidup' AND dusun IS NOT NULL) AS dusun
  FROM public.penduduk;
GRANT SELECT ON public.penduduk_statistik TO anon, authenticated;

CREATE OR REPLACE VIEW public.penduduk_per_dusun AS
  SELECT dusun,
         COUNT(*) FILTER (WHERE status_hidup='hidup') AS jumlah,
         COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='L') AS laki,
         COUNT(*) FILTER (WHERE status_hidup='hidup' AND jenis_kelamin='P') AS perempuan
  FROM public.penduduk WHERE dusun IS NOT NULL GROUP BY dusun ORDER BY dusun;
GRANT SELECT ON public.penduduk_per_dusun TO anon, authenticated;
