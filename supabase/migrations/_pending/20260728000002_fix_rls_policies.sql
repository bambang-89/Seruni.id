-- ============================================================
-- FIX: RLS Policies for Public Read Access
-- ============================================================

-- Drop existing restrictive policies and create permissive ones

-- berita: public read
DROP POLICY IF EXISTS "berita_public_read" ON public.berita;
DO $$
BEGIN
  CREATE POLICY "berita_public_read" ON public.berita FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.berita TO anon;

-- agenda: public read
DROP POLICY IF EXISTS "agenda_public_read" ON public.agenda;
DO $$
BEGIN
  CREATE POLICY "agenda_public_read" ON public.agenda FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.agenda TO anon;

-- pengumuman: public read
DROP POLICY IF EXISTS "pengumuman_public_read" ON public.pengumuman;
DO $$
BEGIN
  CREATE POLICY "pengumuman_public_read" ON public.pengumuman FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.pengumuman TO anon;

-- galeri: public read
DROP POLICY IF EXISTS "galeri_public_read" ON public.galeri;
DO $$
BEGIN
  CREATE POLICY "galeri_public_read" ON public.galeri FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.galeri TO anon;

-- infrastruktur: public read
DROP POLICY IF EXISTS "infrastruktur_public_read" ON public.infrastruktur;
DO $$
BEGIN
  CREATE POLICY "infrastruktur_public_read" ON public.infrastruktur FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.infrastruktur TO anon;

-- kegiatan_pembangunan: public read
DROP POLICY IF EXISTS "kegiatan_public_read" ON public.kegiatan_pembangunan;
DO $$
BEGIN
  CREATE POLICY "kegiatan_public_read" ON public.kegiatan_pembangunan FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.kegiatan_pembangunan TO anon;

-- bantuan_sosial: public read
DROP POLICY IF EXISTS "bansos_public_read" ON public.bantuan_sosial;
DO $$
BEGIN
  CREATE POLICY "bansos_public_read" ON public.bantuan_sosial FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.bantuan_sosial TO anon;

-- penerima_bansos: public read
DROP POLICY IF EXISTS "penerima_bansos_public_read" ON public.penerima_bansos;
DO $$
BEGIN
  CREATE POLICY "penerima_bansos_public_read" ON public.penerima_bansos FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.penerima_bansos TO anon;

-- posyandu_agregat: public read
DROP POLICY IF EXISTS "posyandu_public_read" ON public.posyandu_agregat;
DO $$
BEGIN
  CREATE POLICY "posyandu_public_read" ON public.posyandu_agregat FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.posyandu_agregat TO anon;

-- stunting_agregat: public read
DROP POLICY IF EXISTS "stunting_public_read" ON public.stunting_agregat;
DO $$
BEGIN
  CREATE POLICY "stunting_public_read" ON public.stunting_agregat FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.stunting_agregat TO anon;

-- bencana_kejadian: public read
DROP POLICY IF EXISTS "bencana_public_read" ON public.bencana_kejadian;
DO $$
BEGIN
  CREATE POLICY "bencana_public_read" ON public.bencana_kejadian FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.bencana_kejadian TO anon;

-- voting_topik: public read
DROP POLICY IF EXISTS "voting_topik_public_read" ON public.voting_topik;
DO $$
BEGIN
  CREATE POLICY "voting_topik_public_read" ON public.voting_topik FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.voting_topik TO anon;

-- voting_opsi: public read
DROP POLICY IF EXISTS "voting_opsi_public_read" ON public.voting_opsi;
DO $$
BEGIN
  CREATE POLICY "voting_opsi_public_read" ON public.voting_opsi FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.voting_opsi TO anon;

-- voting_suara: public read (for vote checking)
DROP POLICY IF EXISTS "voting_suara_public_read" ON public.voting_suara;
DO $$
BEGIN
  CREATE POLICY "voting_suara_public_read" ON public.voting_suara FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.voting_suara TO anon;

--wa_broadcast: public read
DROP POLICY IF EXISTS "wa_broadcast_public_read" ON public.wa_broadcast;
DO $$
BEGIN
  CREATE POLICY "wa_broadcast_public_read" ON public.wa_broadcast FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.wa_broadcast TO anon;

--wa_broadcast_target: public read
DROP POLICY IF EXISTS "wa_broadcast_target_public_read" ON public.wa_broadcast_target;
DO $$
BEGIN
  CREATE POLICY "wa_broadcast_target_public_read" ON public.wa_broadcast_target FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.wa_broadcast_target TO anon;

-- langganan_wa: public read
DROP POLICY IF EXISTS "langganan_wa_public_read" ON public.langganan_wa;
DO $$
BEGIN
  CREATE POLICY "langganan_wa_public_read" ON public.langganan_wa FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.langganan_wa TO anon;

-- rpjmdes_periode: public read
DROP POLICY IF EXISTS "rpjmdes_periode_public_read" ON public.rpjmdes_periode;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_periode_public_read" ON public.rpjmdes_periode FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.rpjmdes_periode TO anon;

-- rpjmdes_bidang: public read
DROP POLICY IF EXISTS "rpjmdes_bidang_public_read" ON public.rpjmdes_bidang;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_bidang_public_read" ON public.rpjmdes_bidang FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.rpjmdes_bidang TO anon;

-- rpjmdes_program: public read
DROP POLICY IF EXISTS "rpjmdes_program_public_read" ON public.rpjmdes_program;
DO $$
BEGIN
  CREATE POLICY "rpjmdes_program_public_read" ON public.rpjmdes_program FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.rpjmdes_program TO anon;

-- rkpdes_tahun: public read
DROP POLICY IF EXISTS "rkpdes_tahun_public_read" ON public.rkpdes_tahun;
DO $$
BEGIN
  CREATE POLICY "rkpdes_tahun_public_read" ON public.rkpdes_tahun FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.rkpdes_tahun TO anon;

-- rkpdes_kegiatan: public read
DROP POLICY IF EXISTS "rkpdes_kegiatan_public_read" ON public.rkpdes_kegiatan;
DO $$
BEGIN
  CREATE POLICY "rkpdes_kegiatan_public_read" ON public.rkpdes_kegiatan FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.rkpdes_kegiatan TO anon;

-- potensi_umkm: public read
DROP POLICY IF EXISTS "potensi_umkm_public_read" ON public.potensi_umkm;
DO $$
BEGIN
  CREATE POLICY "potensi_umkm_public_read" ON public.potensi_umkm FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.potensi_umkm TO anon;

-- potensi_produk: public read
DROP POLICY IF EXISTS "potensi_produk_public_read" ON public.potensi_produk;
DO $$
BEGIN
  CREATE POLICY "potensi_produk_public_read" ON public.potensi_produk FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.potensi_produk TO anon;

-- potensi_wisata: public read
DROP POLICY IF EXISTS "potensi_wisata_public_read" ON public.potensi_wisata;
DO $$
BEGIN
  CREATE POLICY "potensi_wisata_public_read" ON public.potensi_wisata FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.potensi_wisata TO anon;

-- surat_jenis: public read
DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
DO $$
BEGIN
  CREATE POLICY "surat_jenis_public_read" ON public.surat_jenis FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.surat_jenis TO anon;

-- surat_terbit: public read
DROP POLICY IF EXISTS "surat_terbit_public_read" ON public.surat_terbit;
DO $$
BEGIN
  CREATE POLICY "surat_terbit_public_read" ON public.surat_terbit FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.surat_terbit TO anon;

--usulan_warga: public read
DROP POLICY IF EXISTS "usulan_warga_public_read" ON public.usulan_warga;
DO $$
BEGIN
  CREATE POLICY "usulan_warga_public_read" ON public.usulan_warga FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.usulan_warga TO anon;

--wa_chatbot_session: public read
DROP POLICY IF EXISTS "wa_chatbot_session_public_read" ON public.wa_chatbot_session;
DO $$
BEGIN
  CREATE POLICY "wa_chatbot_session_public_read" ON public.wa_chatbot_session FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.wa_chatbot_session TO anon;

--idm_status_desa: public read
DROP POLICY IF EXISTS "idm_status_desa_public_read" ON public.idm_status_desa;
DO $$
BEGIN
  CREATE POLICY "idm_status_desa_public_read" ON public.idm_status_desa FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.idm_status_desa TO anon;

--idm_skor_cache: public read
DROP POLICY IF EXISTS "idm_skor_cache_public_read" ON public.idm_skor_cache;
DO $$
BEGIN
  CREATE POLICY "idm_skor_cache_public_read" ON public.idm_skor_cache FOR SELECT USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
GRANT SELECT ON public.idm_skor_cache TO anon;

SELECT 'RLS policies fixed for public read access' AS result;
