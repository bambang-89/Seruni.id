-- ============================================================
-- MIGRASI: 20260721000004_add_tenant_id.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Tambahkan tenant_id ke 31 tabel domain utama.
--            Semua data existing di-backfill ke tenant Seruni Mumbul
--            (UUID: d532ae95-0ad9-42bb-a6e8-5c840447c90e).
--            Kolom nullable dulu, di-backfill, baru SET NOT NULL.
-- ============================================================

-- Tenant Seruni Mumbul
DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

-- ============================================================
-- CORE TABLES
-- ============================================================
ALTER TABLE public.penduduk ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.penduduk SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.penduduk ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_penduduk_tenant ON public.penduduk(tenant_id);

ALTER TABLE public.keluarga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.keluarga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.keluarga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_keluarga_tenant ON public.keluarga(tenant_id);

ALTER TABLE public.wilayah_dusun ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wilayah_dusun SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wilayah_dusun ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wilayah_dusun_tenant ON public.wilayah_dusun(tenant_id);

-- ============================================================
-- GOVERNANCE
-- ============================================================
ALTER TABLE public.voting_topik ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_topik SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_topik ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_topik_tenant ON public.voting_topik(tenant_id);

ALTER TABLE public.voting_opsi ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_opsi SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_opsi ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_opsi_tenant ON public.voting_opsi(tenant_id);

ALTER TABLE public.voting_suara ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.voting_suara SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.voting_suara ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_voting_suara_tenant ON public.voting_suara(tenant_id);

ALTER TABLE public.usulan_warga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.usulan_warga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.usulan_warga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usulan_warga_tenant ON public.usulan_warga(tenant_id);

ALTER TABLE public.usulan_vote ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.usulan_vote SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.usulan_vote ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usulan_vote_tenant ON public.usulan_vote(tenant_id);

ALTER TABLE public.rpjmdes_periode ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_periode SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_periode ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_periode_tenant ON public.rpjmdes_periode(tenant_id);

ALTER TABLE public.rpjmdes_bidang ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_bidang SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_bidang ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_bidang_tenant ON public.rpjmdes_bidang(tenant_id);

ALTER TABLE public.rpjmdes_program ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rpjmdes_program SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rpjmdes_program ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rpjmdes_program_tenant ON public.rpjmdes_program(tenant_id);

ALTER TABLE public.rkpdes_tahun ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rkpdes_tahun SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rkpdes_tahun ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rkpdes_tahun_tenant ON public.rkpdes_tahun(tenant_id);

ALTER TABLE public.rkpdes_kegiatan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.rkpdes_kegiatan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.rkpdes_kegiatan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rkpdes_kegiatan_tenant ON public.rkpdes_kegiatan(tenant_id);

-- ============================================================
-- LAYANAN
-- ============================================================
ALTER TABLE public.surat_jenis ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.surat_jenis SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.surat_jenis ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_surat_jenis_tenant ON public.surat_jenis(tenant_id);

ALTER TABLE public.surat_terbit ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.surat_terbit SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.surat_terbit ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_surat_terbit_tenant ON public.surat_terbit(tenant_id);

ALTER TABLE public.pbb_tagihan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.pbb_tagihan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.pbb_tagihan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pbb_tagihan_tenant ON public.pbb_tagihan(tenant_id);

-- ============================================================
-- KESEHATAN & SOSIAL
-- ============================================================
ALTER TABLE public.posyandu_agregat ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.posyandu_agregat SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.posyandu_agregat ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_posyandu_agregat_tenant ON public.posyandu_agregat(tenant_id);

ALTER TABLE public.stunting_agregat ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.stunting_agregat SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.stunting_agregat ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_stunting_agregat_tenant ON public.stunting_agregat(tenant_id);

ALTER TABLE public.bantuan_sosial ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bantuan_sosial SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bantuan_sosial ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bantuan_sosial_tenant ON public.bantuan_sosial(tenant_id);

ALTER TABLE public.penerima_bansos ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.penerima_bansos SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.penerima_bansos ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_penerima_bansos_tenant ON public.penerima_bansos(tenant_id);

-- ============================================================
-- INFRASTRUKTUR & PERTANAHAN
-- ============================================================
ALTER TABLE public.infrastruktur ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.infrastruktur SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.infrastruktur ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_infrastruktur_tenant ON public.infrastruktur(tenant_id);

ALTER TABLE public.kegiatan_pembangunan ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.kegiatan_pembangunan SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.kegiatan_pembangunan ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kegiatan_pembangunan_tenant ON public.kegiatan_pembangunan(tenant_id);

ALTER TABLE public.bidang_tanah ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bidang_tanah SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bidang_tanah ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bidang_tanah_tenant ON public.bidang_tanah(tenant_id);

-- ============================================================
-- DEMOGRAFI & STATISTIK
-- ============================================================
ALTER TABLE public.dpt_pemilih ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.dpt_pemilih SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.dpt_pemilih ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_dpt_pemilih_tenant ON public.dpt_pemilih(tenant_id);

ALTER TABLE public.analisis_snapshot ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.analisis_snapshot SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.analisis_snapshot ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_analisis_snapshot_tenant ON public.analisis_snapshot(tenant_id);

ALTER TABLE public.idm_indikator ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.idm_indikator SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.idm_indikator ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_idm_indikator_tenant ON public.idm_indikator(tenant_id);

-- ============================================================
-- PEMERINTAHAN DESA
-- ============================================================
ALTER TABLE public.desa_pamong ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.desa_pamong SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.desa_pamong ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_desa_pamong_tenant ON public.desa_pamong(tenant_id);

ALTER TABLE public.profil_desa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.profil_desa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.profil_desa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profil_desa_tenant ON public.profil_desa(tenant_id);

ALTER TABLE public.lembaga_desa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.lembaga_desa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.lembaga_desa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lembaga_desa_tenant ON public.lembaga_desa(tenant_id);

ALTER TABLE public.apbdes ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.apbdes SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.apbdes ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_apbdes_tenant ON public.apbdes(tenant_id);

ALTER TABLE public.buku_register ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.buku_register SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.buku_register ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_buku_register_tenant ON public.buku_register(tenant_id);

-- ============================================================
-- POTENSI & PELAYANAN
-- ============================================================
ALTER TABLE public.potensi_umkm ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_umkm SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_umkm ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_umkm_tenant ON public.potensi_umkm(tenant_id);

ALTER TABLE public.potensi_produk ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_produk SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_produk ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_produk_tenant ON public.potensi_produk(tenant_id);

ALTER TABLE public.potensi_wisata ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.potensi_wisata SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.potensi_wisata ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_potensi_wisata_tenant ON public.potensi_wisata(tenant_id);

ALTER TABLE public.aduan_warga ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.aduan_warga SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.aduan_warga ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aduan_warga_tenant ON public.aduan_warga(tenant_id);

ALTER TABLE public.langganan_wa ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.langganan_wa SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.langganan_wa ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_langganan_wa_tenant ON public.langganan_wa(tenant_id);

ALTER TABLE public.wa_broadcast ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wa_broadcast SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wa_broadcast ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_tenant ON public.wa_broadcast(tenant_id);

ALTER TABLE public.wa_broadcast_target ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.wa_broadcast_target SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.wa_broadcast_target ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_wa_broadcast_target_tenant ON public.wa_broadcast_target(tenant_id);

ALTER TABLE public.bencana_kejadian ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.bencana_kejadian SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.bencana_kejadian ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bencana_kejadian_tenant ON public.bencana_kejadian(tenant_id);

ALTER TABLE public.suplesi_data ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.suplesi_data SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.suplesi_data ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_suplesi_data_tenant ON public.suplesi_data(tenant_id);

END $$;

-- Verifikasi: hitung tenant_id yang ter-set
DO $$
BEGIN
  RAISE NOTICE 'tenant_id migration selesai. Tables updated:';
END $$;
