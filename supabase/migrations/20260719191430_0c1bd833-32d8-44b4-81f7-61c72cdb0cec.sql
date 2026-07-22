
-- ================= ENUMS =================
DO $$ BEGIN
  CREATE TYPE public.rpjmdes_status AS ENUM ('draft','aktif','selesai');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.usulan_status AS ENUM ('baru','diverifikasi','ditindaklanjuti','selesai','ditolak');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.usulan_kategori AS ENUM ('infrastruktur','ekonomi','sosial','pendidikan','kesehatan','lingkungan','pemerintahan','lainnya');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.voting_status AS ENUM ('draft','aktif','ditutup');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.realisasi_status AS ENUM ('rencana','berjalan','selesai','tertunda','batal');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ================= RPJMDes =================
CREATE TABLE public.rpjmdes_periode (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama TEXT NOT NULL,
  tahun_mulai INT NOT NULL,
  tahun_selesai INT NOT NULL,
  visi TEXT,
  misi JSONB NOT NULL DEFAULT '[]'::jsonb,
  status public.rpjmdes_status NOT NULL DEFAULT 'draft',
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.rpjmdes_periode TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_periode TO authenticated;
GRANT ALL ON public.rpjmdes_periode TO service_role;
ALTER TABLE public.rpjmdes_periode ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat periode terbit" ON public.rpjmdes_periode FOR SELECT USING (published = true);
CREATE POLICY "admin kelola periode" ON public.rpjmdes_periode FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rpjmdes_bidang (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode_id UUID NOT NULL REFERENCES public.rpjmdes_periode(id) ON DELETE CASCADE,
  kode TEXT NOT NULL,
  nama TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rpjmdes_bidang(periode_id);
GRANT SELECT ON public.rpjmdes_bidang TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_bidang TO authenticated;
GRANT ALL ON public.rpjmdes_bidang TO service_role;
ALTER TABLE public.rpjmdes_bidang ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat bidang" ON public.rpjmdes_bidang FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.rpjmdes_periode p WHERE p.id = periode_id AND p.published = true)
);
CREATE POLICY "admin kelola bidang" ON public.rpjmdes_bidang FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rpjmdes_program (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_id UUID NOT NULL REFERENCES public.rpjmdes_bidang(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  indikator TEXT,
  target TEXT,
  sumber_dana TEXT,
  tahun_mulai INT,
  tahun_selesai INT,
  anggaran_indikatif NUMERIC(18,2) NOT NULL DEFAULT 0,
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rpjmdes_program(bidang_id);
GRANT SELECT ON public.rpjmdes_program TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rpjmdes_program TO authenticated;
GRANT ALL ON public.rpjmdes_program TO service_role;
ALTER TABLE public.rpjmdes_program ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat program" ON public.rpjmdes_program FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.rpjmdes_bidang b JOIN public.rpjmdes_periode p ON p.id = b.periode_id
    WHERE b.id = bidang_id AND p.published = true
  )
);
CREATE POLICY "admin kelola program" ON public.rpjmdes_program FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ================= RKPDes =================
CREATE TABLE public.rkpdes_tahun (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  periode_id UUID REFERENCES public.rpjmdes_periode(id) ON DELETE SET NULL,
  tahun INT NOT NULL UNIQUE,
  tgl_musdes DATE,
  catatan TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.rkpdes_tahun TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rkpdes_tahun TO authenticated;
GRANT ALL ON public.rkpdes_tahun TO service_role;
ALTER TABLE public.rkpdes_tahun ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat rkpdes terbit" ON public.rkpdes_tahun FOR SELECT USING (published = true);
CREATE POLICY "admin kelola rkpdes" ON public.rkpdes_tahun FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.rkpdes_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun_id UUID NOT NULL REFERENCES public.rkpdes_tahun(id) ON DELETE CASCADE,
  bidang_id UUID REFERENCES public.rpjmdes_bidang(id) ON DELETE SET NULL,
  program_id UUID REFERENCES public.rpjmdes_program(id) ON DELETE SET NULL,
  nama TEXT NOT NULL,
  lokasi TEXT,
  dusun TEXT,
  volume TEXT,
  satuan TEXT,
  anggaran NUMERIC(18,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  pelaksana TEXT,
  waktu TEXT,
  status_realisasi public.realisasi_status NOT NULL DEFAULT 'rencana',
  progress_pct INT NOT NULL DEFAULT 0 CHECK (progress_pct BETWEEN 0 AND 100),
  urutan INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.rkpdes_kegiatan(tahun_id);
GRANT SELECT ON public.rkpdes_kegiatan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rkpdes_kegiatan TO authenticated;
GRANT ALL ON public.rkpdes_kegiatan TO service_role;
ALTER TABLE public.rkpdes_kegiatan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat kegiatan terbit" ON public.rkpdes_kegiatan FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.rkpdes_tahun t WHERE t.id = tahun_id AND t.published = true)
);
CREATE POLICY "admin kelola kegiatan rkpdes" ON public.rkpdes_kegiatan FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- ================= USULAN WARGA =================
CREATE SEQUENCE IF NOT EXISTS public.usulan_seq;

CREATE TABLE public.usulan_warga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nomor_tiket TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL CHECK (char_length(nama) BETWEEN 2 AND 120),
  kontak TEXT CHECK (kontak IS NULL OR char_length(kontak) <= 60),
  dusun TEXT,
  kategori public.usulan_kategori NOT NULL,
  judul TEXT NOT NULL CHECK (char_length(judul) BETWEEN 5 AND 160),
  deskripsi TEXT NOT NULL CHECK (char_length(deskripsi) BETWEEN 10 AND 4000),
  lokasi TEXT,
  foto_url TEXT,
  status public.usulan_status NOT NULL DEFAULT 'baru',
  tanggapan TEXT,
  target_rkpdes_id UUID REFERENCES public.rkpdes_tahun(id) ON DELETE SET NULL,
  vote_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.usulan_warga(status);
CREATE INDEX ON public.usulan_warga(kategori);
GRANT SELECT ON public.usulan_warga TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.usulan_warga TO authenticated;
GRANT ALL ON public.usulan_warga TO service_role;
ALTER TABLE public.usulan_warga ENABLE ROW LEVEL SECURITY;
-- publik hanya melihat usulan yang sudah diverifikasi (moderasi)
CREATE POLICY "publik lihat usulan moderasi" ON public.usulan_warga FOR SELECT USING (
  status IN ('diverifikasi','ditindaklanjuti','selesai')
);
CREATE POLICY "admin kelola usulan" ON public.usulan_warga FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
-- INSERT publik dilakukan lewat edge function (service_role), tidak lewat client.

CREATE TABLE public.usulan_vote (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usulan_id UUID NOT NULL REFERENCES public.usulan_warga(id) ON DELETE CASCADE,
  voter_hash TEXT NOT NULL,
  dusun TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (usulan_id, voter_hash)
);
CREATE INDEX ON public.usulan_vote(usulan_id);
GRANT SELECT ON public.usulan_vote TO anon;
GRANT SELECT ON public.usulan_vote TO authenticated;
GRANT ALL ON public.usulan_vote TO service_role;
ALTER TABLE public.usulan_vote ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat vote usulan" ON public.usulan_vote FOR SELECT USING (true);
CREATE POLICY "admin kelola vote usulan" ON public.usulan_vote FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- Trigger untuk sinkronkan vote_count di usulan_warga
CREATE OR REPLACE FUNCTION public.sync_usulan_vote_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.usulan_warga SET vote_count = vote_count + 1, updated_at = now() WHERE id = NEW.usulan_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.usulan_warga SET vote_count = GREATEST(vote_count - 1, 0), updated_at = now() WHERE id = OLD.usulan_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END; $$;
CREATE TRIGGER trg_usulan_vote_sync
AFTER INSERT OR DELETE ON public.usulan_vote
FOR EACH ROW EXECUTE FUNCTION public.sync_usulan_vote_count();

-- ================= VOTING RESMI =================
CREATE TABLE public.voting_topik (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  deskripsi TEXT,
  mulai TIMESTAMPTZ,
  selesai TIMESTAMPTZ,
  single_choice BOOLEAN NOT NULL DEFAULT true,
  status public.voting_status NOT NULL DEFAULT 'draft',
  published BOOLEAN NOT NULL DEFAULT false,
  total_suara INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.voting_topik TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.voting_topik TO authenticated;
GRANT ALL ON public.voting_topik TO service_role;
ALTER TABLE public.voting_topik ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat voting terbit" ON public.voting_topik FOR SELECT USING (published = true);
CREATE POLICY "admin kelola voting" ON public.voting_topik FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.voting_opsi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topik_id UUID NOT NULL REFERENCES public.voting_topik(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  deskripsi TEXT,
  urutan INT NOT NULL DEFAULT 0,
  jumlah_suara INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON public.voting_opsi(topik_id);
GRANT SELECT ON public.voting_opsi TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.voting_opsi TO authenticated;
GRANT ALL ON public.voting_opsi TO service_role;
ALTER TABLE public.voting_opsi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat opsi terbit" ON public.voting_opsi FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.voting_topik t WHERE t.id = topik_id AND t.published = true)
);
CREATE POLICY "admin kelola opsi voting" ON public.voting_opsi FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE TABLE public.voting_suara (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topik_id UUID NOT NULL REFERENCES public.voting_topik(id) ON DELETE CASCADE,
  opsi_id UUID NOT NULL REFERENCES public.voting_opsi(id) ON DELETE CASCADE,
  voter_hash TEXT NOT NULL,
  dusun TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (topik_id, voter_hash)
);
CREATE INDEX ON public.voting_suara(topik_id);
GRANT SELECT ON public.voting_suara TO anon;
GRANT SELECT ON public.voting_suara TO authenticated;
GRANT ALL ON public.voting_suara TO service_role;
ALTER TABLE public.voting_suara ENABLE ROW LEVEL SECURITY;
CREATE POLICY "publik lihat suara agregat" ON public.voting_suara FOR SELECT USING (true);
CREATE POLICY "admin kelola suara voting" ON public.voting_suara FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

CREATE OR REPLACE FUNCTION public.sync_voting_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.voting_opsi SET jumlah_suara = jumlah_suara + 1, updated_at = now() WHERE id = NEW.opsi_id;
    UPDATE public.voting_topik SET total_suara = total_suara + 1, updated_at = now() WHERE id = NEW.topik_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.voting_opsi SET jumlah_suara = GREATEST(jumlah_suara - 1, 0), updated_at = now() WHERE id = OLD.opsi_id;
    UPDATE public.voting_topik SET total_suara = GREATEST(total_suara - 1, 0), updated_at = now() WHERE id = OLD.topik_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END; $$;
CREATE TRIGGER trg_voting_sync
AFTER INSERT OR DELETE ON public.voting_suara
FOR EACH ROW EXECUTE FUNCTION public.sync_voting_count();

-- ================= Triggers updated_at + audit =================
CREATE TRIGGER upd_rpjmdes_periode BEFORE UPDATE ON public.rpjmdes_periode FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rpjmdes_bidang BEFORE UPDATE ON public.rpjmdes_bidang FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rpjmdes_program BEFORE UPDATE ON public.rpjmdes_program FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rkpdes_tahun BEFORE UPDATE ON public.rkpdes_tahun FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_rkpdes_kegiatan BEFORE UPDATE ON public.rkpdes_kegiatan FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_usulan_warga BEFORE UPDATE ON public.usulan_warga FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_voting_topik BEFORE UPDATE ON public.voting_topik FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER upd_voting_opsi BEFORE UPDATE ON public.voting_opsi FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER audit_rpjmdes_periode AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_periode FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rpjmdes_bidang  AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_bidang  FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rpjmdes_program AFTER INSERT OR UPDATE OR DELETE ON public.rpjmdes_program FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rkpdes_tahun    AFTER INSERT OR UPDATE OR DELETE ON public.rkpdes_tahun    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_rkpdes_kegiatan AFTER INSERT OR UPDATE OR DELETE ON public.rkpdes_kegiatan FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_usulan_warga    AFTER INSERT OR UPDATE OR DELETE ON public.usulan_warga    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_voting_topik    AFTER INSERT OR UPDATE OR DELETE ON public.voting_topik    FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
CREATE TRIGGER audit_voting_opsi     AFTER INSERT OR UPDATE OR DELETE ON public.voting_opsi     FOR EACH ROW EXECUTE FUNCTION public.log_admin_activity();
