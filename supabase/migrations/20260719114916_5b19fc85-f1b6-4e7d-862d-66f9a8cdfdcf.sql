
-- ==== ENUMS ====
DO $$ BEGIN
  CREATE TYPE public.workflow_status AS ENUM ('draft','diajukan','diverifikasi','diproses','selesai','ditolak','dibatalkan');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.bencana_severity AS ENUM ('rendah','sedang','tinggi','darurat');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.aduan_kategori AS ENUM ('infrastruktur','pelayanan','lingkungan','sosial','keamanan','lainnya');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Reuse updated_at trigger (public.set_updated_at already exists)

-- ==== 1. surat_jenis (master surat, publik read) ====
CREATE TABLE public.surat_jenis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode_surat TEXT NOT NULL UNIQUE,
  kode_klasifikasi TEXT NOT NULL,
  nama TEXT NOT NULL,
  dna_field TEXT,
  aktif BOOLEAN NOT NULL DEFAULT true,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.surat_jenis TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.surat_jenis TO authenticated;
GRANT ALL ON public.surat_jenis TO service_role;
ALTER TABLE public.surat_jenis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "surat_jenis_public_read" ON public.surat_jenis FOR SELECT USING (true);
CREATE POLICY "surat_jenis_admin_write" ON public.surat_jenis FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_surat_jenis_updated BEFORE UPDATE ON public.surat_jenis
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 2. event_log (workflow audit) ====
CREATE TABLE public.event_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  entitas TEXT NOT NULL,
  entitas_id UUID,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_event_log_entitas ON public.event_log(entitas, entitas_id);
CREATE INDEX idx_event_log_created ON public.event_log(created_at DESC);
GRANT SELECT, INSERT ON public.event_log TO authenticated;
GRANT ALL ON public.event_log TO service_role;
ALTER TABLE public.event_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "event_log_admin_read" ON public.event_log FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(),'admin'));
CREATE POLICY "event_log_admin_insert" ON public.event_log FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ==== 3. bidang_tanah (privasi, admin only) ====
CREATE TABLE public.bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_persil TEXT NOT NULL UNIQUE,
  pemilik_nama TEXT NOT NULL,
  pemilik_nik TEXT,
  dusun TEXT,
  luas_m2 NUMERIC(12,2) NOT NULL,
  penggunaan TEXT,
  status_hak TEXT,
  nomor_sertifikat TEXT,
  tanggal_daftar DATE NOT NULL DEFAULT CURRENT_DATE,
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bidang_tanah TO authenticated;
GRANT ALL ON public.bidang_tanah TO service_role;
ALTER TABLE public.bidang_tanah ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bidang_tanah_admin_all" ON public.bidang_tanah FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bidang_tanah_updated BEFORE UPDATE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 4. infrastruktur (publik read) ====
CREATE TABLE public.infrastruktur (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  jenis TEXT NOT NULL,
  dusun TEXT,
  kondisi TEXT NOT NULL DEFAULT 'baik',
  tahun_bangun INT,
  tahun_perbaikan INT,
  volume TEXT,
  sumber_dana TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.infrastruktur TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.infrastruktur TO authenticated;
GRANT ALL ON public.infrastruktur TO service_role;
ALTER TABLE public.infrastruktur ENABLE ROW LEVEL SECURITY;
CREATE POLICY "infrastruktur_public_read" ON public.infrastruktur FOR SELECT USING (true);
CREATE POLICY "infrastruktur_admin_write" ON public.infrastruktur FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_infrastruktur_updated BEFORE UPDATE ON public.infrastruktur
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 5. kegiatan_pembangunan (APBDes, publik read) ====
CREATE TABLE public.kegiatan_pembangunan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  bidang TEXT NOT NULL,
  nama_kegiatan TEXT NOT NULL,
  lokasi TEXT,
  volume TEXT,
  anggaran NUMERIC(15,2) NOT NULL DEFAULT 0,
  realisasi NUMERIC(15,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  status public.workflow_status NOT NULL DEFAULT 'draft',
  tanggal_mulai DATE,
  tanggal_selesai DATE,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_kegiatan_tahun ON public.kegiatan_pembangunan(tahun DESC);
GRANT SELECT ON public.kegiatan_pembangunan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kegiatan_pembangunan TO authenticated;
GRANT ALL ON public.kegiatan_pembangunan TO service_role;
ALTER TABLE public.kegiatan_pembangunan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "kegiatan_public_read" ON public.kegiatan_pembangunan FOR SELECT USING (true);
CREATE POLICY "kegiatan_admin_write" ON public.kegiatan_pembangunan FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_kegiatan_updated BEFORE UPDATE ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 6. posyandu_agregat (agregat, publik) ====
CREATE TABLE public.posyandu_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode DATE NOT NULL,
  dusun TEXT NOT NULL,
  jumlah_balita INT NOT NULL DEFAULT 0,
  hadir INT NOT NULL DEFAULT 0,
  gizi_baik INT NOT NULL DEFAULT 0,
  gizi_kurang INT NOT NULL DEFAULT 0,
  imunisasi_lengkap INT NOT NULL DEFAULT 0,
  ibu_hamil_dilayani INT NOT NULL DEFAULT 0,
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(periode, dusun)
);
GRANT SELECT ON public.posyandu_agregat TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.posyandu_agregat TO authenticated;
GRANT ALL ON public.posyandu_agregat TO service_role;
ALTER TABLE public.posyandu_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posyandu_public_read" ON public.posyandu_agregat FOR SELECT USING (true);
CREATE POLICY "posyandu_admin_write" ON public.posyandu_agregat FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_posyandu_updated BEFORE UPDATE ON public.posyandu_agregat
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 7. stunting_agregat (publik) ====
CREATE TABLE public.stunting_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode DATE NOT NULL,
  dusun TEXT NOT NULL,
  balita_diukur INT NOT NULL DEFAULT 0,
  stunting INT NOT NULL DEFAULT 0,
  wasting INT NOT NULL DEFAULT 0,
  underweight INT NOT NULL DEFAULT 0,
  intervensi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(periode, dusun)
);
GRANT SELECT ON public.stunting_agregat TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stunting_agregat TO authenticated;
GRANT ALL ON public.stunting_agregat TO service_role;
ALTER TABLE public.stunting_agregat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stunting_public_read" ON public.stunting_agregat FOR SELECT USING (true);
CREATE POLICY "stunting_admin_write" ON public.stunting_agregat FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_stunting_updated BEFORE UPDATE ON public.stunting_agregat
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 8. bantuan_sosial (master jenis, publik) ====
CREATE TABLE public.bantuan_sosial (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  sumber TEXT NOT NULL,
  deskripsi TEXT,
  periode_mulai DATE,
  periode_selesai DATE,
  kuota INT,
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.bantuan_sosial TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bantuan_sosial TO authenticated;
GRANT ALL ON public.bantuan_sosial TO service_role;
ALTER TABLE public.bantuan_sosial ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bansos_public_read" ON public.bantuan_sosial FOR SELECT USING (true);
CREATE POLICY "bansos_admin_write" ON public.bantuan_sosial FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bansos_updated BEFORE UPDATE ON public.bantuan_sosial
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 9. penerima_bansos (privasi, admin only) ====
CREATE TABLE public.penerima_bansos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bansos_id UUID NOT NULL REFERENCES public.bantuan_sosial(id) ON DELETE CASCADE,
  nik TEXT NOT NULL,
  nama TEXT NOT NULL,
  dusun TEXT,
  status TEXT NOT NULL DEFAULT 'terdaftar',
  tanggal_salur DATE,
  nominal NUMERIC(15,2),
  catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(bansos_id, nik)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.penerima_bansos TO authenticated;
GRANT ALL ON public.penerima_bansos TO service_role;
ALTER TABLE public.penerima_bansos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "penerima_bansos_admin_all" ON public.penerima_bansos FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_penerima_bansos_updated BEFORE UPDATE ON public.penerima_bansos
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 10. bencana_kejadian (publik) ====
CREATE TABLE public.bencana_kejadian (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jenis TEXT NOT NULL,
  lokasi TEXT NOT NULL,
  dusun TEXT,
  tanggal TIMESTAMPTZ NOT NULL DEFAULT now(),
  severity public.bencana_severity NOT NULL DEFAULT 'sedang',
  status public.workflow_status NOT NULL DEFAULT 'diajukan',
  korban_jiwa INT NOT NULL DEFAULT 0,
  korban_luka INT NOT NULL DEFAULT 0,
  pengungsi INT NOT NULL DEFAULT 0,
  kerugian_rp NUMERIC(15,2) DEFAULT 0,
  deskripsi TEXT,
  penanganan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_bencana_tanggal ON public.bencana_kejadian(tanggal DESC);
GRANT SELECT ON public.bencana_kejadian TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bencana_kejadian TO authenticated;
GRANT ALL ON public.bencana_kejadian TO service_role;
ALTER TABLE public.bencana_kejadian ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bencana_public_read" ON public.bencana_kejadian FOR SELECT USING (true);
CREATE POLICY "bencana_admin_write" ON public.bencana_kejadian FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_bencana_updated BEFORE UPDATE ON public.bencana_kejadian
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 11. aduan_warga (warga insert, admin proses) ====
CREATE TABLE public.aduan_warga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE DEFAULT ('ADN-' || to_char(now(),'YYYYMMDD') || '-' || substr(md5(random()::text),1,6)),
  nama_pelapor TEXT NOT NULL,
  kontak TEXT NOT NULL,
  kategori public.aduan_kategori NOT NULL DEFAULT 'lainnya',
  judul TEXT NOT NULL,
  isi TEXT NOT NULL,
  lokasi TEXT,
  lampiran_url TEXT,
  status public.workflow_status NOT NULL DEFAULT 'diajukan',
  tanggapan TEXT,
  ditanggapi_oleh UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ditanggapi_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_aduan_status ON public.aduan_warga(status);
CREATE INDEX idx_aduan_created ON public.aduan_warga(created_at DESC);
GRANT INSERT ON public.aduan_warga TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.aduan_warga TO authenticated;
GRANT ALL ON public.aduan_warga TO service_role;
ALTER TABLE public.aduan_warga ENABLE ROW LEVEL SECURITY;
CREATE POLICY "aduan_public_insert" ON public.aduan_warga FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "aduan_public_insert_auth" ON public.aduan_warga FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "aduan_admin_all" ON public.aduan_warga FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_aduan_updated BEFORE UPDATE ON public.aduan_warga
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== 12. dpt_pemilih (privasi, admin only) ====
CREATE TABLE public.dpt_pemilih (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nik TEXT NOT NULL,
  nama TEXT NOT NULL,
  tempat_lahir TEXT,
  tanggal_lahir DATE,
  jenis_kelamin TEXT,
  dusun TEXT,
  rt TEXT,
  rw TEXT,
  tps TEXT,
  pemilu_kode TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'aktif',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(pemilu_kode, nik)
);
CREATE INDEX idx_dpt_tps ON public.dpt_pemilih(pemilu_kode, tps);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dpt_pemilih TO authenticated;
GRANT ALL ON public.dpt_pemilih TO service_role;
ALTER TABLE public.dpt_pemilih ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dpt_admin_all" ON public.dpt_pemilih FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_dpt_updated BEFORE UPDATE ON public.dpt_pemilih
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ==== Workflow event helper (append to event_log on status change) ====
CREATE OR REPLACE FUNCTION public.log_status_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (TG_TABLE_NAME || '.status.diubah', TG_TABLE_NAME, NEW.id,
      jsonb_build_object('dari', OLD.status, 'ke', NEW.status), auth.uid());
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO public.event_log(event_name, entitas, entitas_id, payload, actor_id)
    VALUES (TG_TABLE_NAME || '.dibuat', TG_TABLE_NAME, NEW.id,
      jsonb_build_object('status', NEW.status), auth.uid());
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER trg_aduan_event AFTER INSERT OR UPDATE OF status ON public.aduan_warga
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
CREATE TRIGGER trg_bencana_event AFTER INSERT OR UPDATE OF status ON public.bencana_kejadian
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
CREATE TRIGGER trg_kegiatan_event AFTER INSERT OR UPDATE OF status ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
