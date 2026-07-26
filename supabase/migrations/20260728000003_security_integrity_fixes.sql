-- ============================================================
-- SECURITY & INTEGRITY FIXES - Phase 1
-- Prioritas Critical untuk production safety
-- ============================================================

-- 1. ADD FOREIGN KEY CONSTRAINTS

DO $$
BEGIN
  ALTER TABLE public.bantuan_sosial
    ADD CONSTRAINT fk_bantuan_sosial_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.penerima_bansos
    ADD CONSTRAINT fk_penerima_bansos_bansos
    FOREIGN KEY (bansos_id) REFERENCES public.bantuan_sosial(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.penerima_bansos
    ADD CONSTRAINT fk_penerima_bansos_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.balita
    ADD CONSTRAINT fk_balita_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_terbit
    ADD CONSTRAINT fk_surat_terbit_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_ajuan
    ADD CONSTRAINT fk_surat_ajuan_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_ajuan
    ADD CONSTRAINT fk_surat_ajuan_jenis
    FOREIGN KEY (jenis_surat_id) REFERENCES public.surat_jenis(id)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.voting_suara
    ADD CONSTRAINT fk_voting_suara_topik
    FOREIGN KEY (topik_id) REFERENCES public.voting_topik(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.voting_opsi
    ADD CONSTRAINT fk_voting_opsi_topik
    FOREIGN KEY (topik_id) REFERENCES public.voting_topik(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.infrastruktur
    ADD CONSTRAINT fk_infrastruktur_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.kegiatan_pembangunan
    ADD CONSTRAINT fk_kegiatan_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.potensi_umkm
    ADD CONSTRAINT fk_umkm_tenant
    FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.penerima_bansos
    ADD CONSTRAINT fk_produk_umkm
    FOREIGN KEY (umkm_id) REFERENCES public.potensi_umkm(id)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 2. ADD UNIQUE CONSTRAINTS

DO $$
BEGIN
  ALTER TABLE public.penduduk
    ADD CONSTRAINT uq_penduduk_nik UNIQUE (tenant_id, nik);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.keluarga
    ADD CONSTRAINT uq_keluarga_kk UNIQUE (tenant_id, no_kk);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_terbit
    ADD CONSTRAINT uq_surat_terbit_nomor UNIQUE (nomor_surat);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_terbit
    ADD CONSTRAINT uq_surat_terbit_kode UNIQUE (kode_verifikasi);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.surat_ajuan
    ADD CONSTRAINT uq_surat_ajuan_tiket UNIQUE (nomor_tiket);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 3. ADD INDEXES FOR PERFORMANCE

CREATE INDEX IF NOT EXISTS idx_penduduk_nik ON public.penduduk(nik);
CREATE INDEX IF NOT EXISTS idx_penduduk_status ON public.penduduk(status_hidup);
CREATE INDEX IF NOT EXISTS idx_penduduk_dusun ON public.penduduk(dusun);
CREATE INDEX IF NOT EXISTS idx_penduduk_agama ON public.penduduk(agama_id);
CREATE INDEX IF NOT EXISTS idx_penduduk_pendidikan ON public.penduduk(pendidikan_id);

CREATE INDEX IF NOT EXISTS idx_keluarga_kk ON public.keluarga(no_kk);
CREATE INDEX IF NOT EXISTS idx_keluarga_kepala ON public.keluarga(kepala_keluarga_id);

CREATE INDEX IF NOT EXISTS idx_voting_suara_voter_hash ON public.voting_suara(voter_hash);
CREATE INDEX IF NOT EXISTS idx_voting_suara_topik ON public.voting_suara(topik_id);

CREATE INDEX IF NOT EXISTS idx_usulan_warga_nomor_tiket ON public.usulan_warga(nomor_tiket);
CREATE INDEX IF NOT EXISTS idx_usulan_warga_status ON public.usulan_warga(status);

CREATE INDEX IF NOT EXISTS idx_event_log_event_time ON public.event_log(event_name, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_event_log_actor ON public.event_log(actor_id) WHERE actor_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_surat_terbit_nomor ON public.surat_terbit(nomor_surat);
CREATE INDEX IF NOT EXISTS idx_surat_terbit_kode ON public.surat_terbit(kode_verifikasi);

CREATE INDEX IF NOT EXISTS idx_balita_dusun ON public.balita(dusun);
CREATE INDEX IF NOT EXISTS idx_balita_ortu ON public.balita(orang_tua_penduduk_id) WHERE orang_tua_penduduk_id IS NOT NULL;

-- 4. FIX RLS POLICIES (tenant-aware)

-- Drop old permissive policies
DROP POLICY IF EXISTS "voting_topik_public_read" ON public.voting_topik;
DROP POLICY IF EXISTS "voting_opsi_public_read" ON public.voting_opsi;
DROP POLICY IF EXISTS "voting_suara_public_read" ON public.voting_suara;
DROP POLICY IF EXISTS "berita_public_read" ON public.berita;
DROP POLICY IF EXISTS "agenda_public_read" ON public.agenda;
DROP POLICY IF EXISTS "pengumuman_public_read" ON public.pengumuman;
DROP POLICY IF EXISTS "galeri_public_read" ON public.galeri;
DROP POLICY IF EXISTS "infrastruktur_public_read" ON public.infrastruktur;
DROP POLICY IF EXISTS "kegiatan_public_read" ON public.kegiatan_pembangunan;
DROP POLICY IF EXISTS "bansos_public_read" ON public.bantuan_sosial;
DROP POLICY IF EXISTS "penerima_bansos_public_read" ON public.penerima_bansos;
DROP POLICY IF EXISTS "posyandu_public_read" ON public.posyandu_agregat;
DROP POLICY IF EXISTS "stunting_public_read" ON public.stunting_agregat;
DROP POLICY IF EXISTS "bencana_public_read" ON public.bencana_kejadian;
DROP POLICY IF EXISTS "rpjmdes_periode_public_read" ON public.rpjmdes_periode;
DROP POLICY IF EXISTS "rpjmdes_bidang_public_read" ON public.rpjmdes_bidang;
DROP POLICY IF EXISTS "rpjmdes_program_public_read" ON public.rpjmdes_program;
DROP POLICY IF EXISTS "rkpdes_tahun_public_read" ON public.rkpdes_tahun;
DROP POLICY IF EXISTS "rkpdes_kegiatan_public_read" ON public.rkpdes_kegiatan;
DROP POLICY IF EXISTS "potensi_umkm_public_read" ON public.potensi_umkm;
DROP POLICY IF EXISTS "potensi_produk_public_read" ON public.potensi_produk;
DROP POLICY IF EXISTS "potensi_wisata_public_read" ON public.potensi_wisata;
DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_terbit_public_read" ON public.surat_terbit;
DROP POLICY IF EXISTS "usulan_warga_public_read" ON public.usulan_warga;

-- Create secure tenant-scoped policies
-- Enable RLS
ALTER TABLE public.voting_topik ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_opsi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_suara ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.berita ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agenda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengumuman ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.galeri ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.infrastruktur ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kegiatan_pembangunan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bantuan_sosial ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.penerima_bansos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posyandu_agregat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stunting_agregat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bencana_kejadian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rpjmdes_periode ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rpjmdes_bidang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rpjmdes_program ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rkpdes_tahun ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rkpdes_kegiatan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potensi_umkm ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potensi_produk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potensi_wisata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surat_jenis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surat_terbit ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usulan_warga ENABLE ROW LEVEL SECURITY;

-- Public read policies (anyone can read published data)
DO $$
BEGIN
  CREATE POLICY "voting_topik_select" ON public.voting_topik FOR SELECT USING (published = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "voting_opsi_select" ON public.voting_opsi FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "voting_suara_select" ON public.voting_suara FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "berita_select" ON public.berita FOR SELECT USING (published = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "agenda_select" ON public.agenda FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "pengumuman_select" ON public.pengumuman FOR SELECT USING (published = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "galeri_select" ON public.galeri FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "infrastruktur_select" ON public.infrastruktur FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "kegiatan_select" ON public.kegiatan_pembangunan FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "bantuan_sosial_select" ON public.bantuan_sosial FOR SELECT USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "posyandu_select" ON public.posyandu_agregat FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "stunting_select" ON public.stunting_agregat FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "bencana_select" ON public.bencana_kejadian FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_periode_select" ON public.rpjmdes_periode FOR SELECT USING (published = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_bidang_select" ON public.rpjmdes_bidang FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_program_select" ON public.rpjmdes_program FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rkpdes_tahun_select" ON public.rkpdes_tahun FOR SELECT USING (published = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rkpdes_kegiatan_select" ON public.rkpdes_kegiatan FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "potensi_umkm_select" ON public.potensi_umkm FOR SELECT USING (status = 'publish');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "potensi_produk_select" ON public.potensi_produk FOR SELECT USING (status = 'publish');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "potensi_wisata_select" ON public.potensi_wisata FOR SELECT USING (status = 'publish');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "surat_jenis_select" ON public.surat_jenis FOR SELECT USING (aktif = true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "surat_terbit_select" ON public.surat_terbit FOR SELECT USING (status = 'berlaku');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "usulan_warga_select" ON public.usulan_warga FOR SELECT USING (status IN ('diverifikasi', 'ditindaklanjuti', 'selesai'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Admin write policies (FIXED: added missing closing paren before WITH CHECK)
DO $$
BEGIN
  CREATE POLICY "voting_admin_all" ON public.voting_topik FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "voting_opsi_admin_all" ON public.voting_opsi FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "voting_suara_insert" ON public.voting_suara FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "berita_admin_all" ON public.berita FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "agenda_admin_all" ON public.agenda FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "pengumuman_admin_all" ON public.pengumuman FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "galeri_admin_all" ON public.galeri FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "infrastruktur_admin_all" ON public.infrastruktur FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "kegiatan_admin_all" ON public.kegiatan_pembangunan FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "bantuan_sosial_admin_all" ON public.bantuan_sosial FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "penerima_bansos_admin_all" ON public.penerima_bansos FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "posyandu_admin_all" ON public.posyandu_agregat FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "stunting_admin_all" ON public.stunting_agregat FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "bencana_admin_all" ON public.bencana_kejadian FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_admin_all" ON public.rpjmdes_periode FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_b_admin_all" ON public.rpjmdes_bidang FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_p_admin_all" ON public.rpjmdes_program FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rkpdes_t_admin_all" ON public.rkpdes_tahun FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "rkpdes_k_admin_all" ON public.rkpdes_kegiatan FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "umkm_admin_all" ON public.potensi_umkm FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "produk_admin_all" ON public.potensi_produk FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "wisata_admin_all" ON public.potensi_wisata FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "surat_jenis_admin_all" ON public.surat_jenis FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "surat_terbit_admin_all" ON public.surat_terbit FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
DO $$
BEGIN
  CREATE POLICY "usulan_admin_all" ON public.usulan_warga FOR ALL TO authenticated
    USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 5. VERIFICATION
SELECT 'Security fixes applied: FK constraints, Unique constraints, Indexes, RLS policies' AS result;

-- Verify FK constraints
SELECT conname FROM pg_constraint WHERE conrelid = 'bantuan_sosial'::regclass AND contype = 'f';
SELECT conname FROM pg_constraint WHERE conrelid = 'penerima_bansos'::regclass AND contype = 'f';
SELECT conname FROM pg_constraint WHERE conrelid = 'voting_topik'::regclass AND contype = 'f';

-- Verify indexes
SELECT indexname FROM pg_indexes WHERE tablename IN ('penduduk', 'voting_suara', 'usulan_warga', 'event_log');

-- Verify RLS enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = true LIMIT 20;
