-- ============================================================
-- MIGRASI: 20260826000001_add_tenant_id_remaining_tables.sql
-- Tanggal: 2026-08-26
-- Deskripsi: Tambahkan tenant_id ke 8 tabel yang belum punya kolom tersebut.
--            5 tabel lain (perpustakaan_desa, buku_perpustakaan, pemilihan,
--            posyandu_balita, bencana_bantuan) sudah punya kolom dari
--            migration sebelumnya -- tetap di-include dengan IF NOT EXISTS
--            untuk konsistensi dan index creation.
--            Semua data existing di-backfill ke tenant Seruni Mumbul
--            (UUID: d532ae95-0ad9-42bb-a6e8-5c840447c90e).
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN

-- ============================================================
-- KONTEN (berita, agenda, pengumuman, galeri) -- 4 tabel BARU
-- ============================================================

-- berita
ALTER TABLE public.berita ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.berita SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.berita ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_berita_tenant ON public.berita(tenant_id);

-- agenda
ALTER TABLE public.agenda ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.agenda SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.agenda ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_agenda_tenant ON public.agenda(tenant_id);

-- pengumuman
ALTER TABLE public.pengumuman ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.pengumuman SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.pengumuman ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pengumuman_tenant ON public.pengumuman(tenant_id);

-- galeri
ALTER TABLE public.galeri ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.galeri SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.galeri ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_galeri_tenant ON public.galeri(tenant_id);

-- ============================================================
-- IDM
-- ============================================================

-- idm_scoring_log
ALTER TABLE public.idm_scoring_log ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.idm_scoring_log SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.idm_scoring_log ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_idm_scoring_log_tenant ON public.idm_scoring_log(tenant_id);

-- ============================================================
-- PERPUSTAKAAN (perpustakaan_desa, buku_perpustakaan) -- SUDAH ADA, index only
-- ============================================================

-- perpustakaan_desa (kolom sudah ada, buat index)
CREATE INDEX IF NOT EXISTS idx_perpustakaan_desa_tenant ON public.perpustakaan_desa(tenant_id);

-- buku_perpustakaan (kolom sudah ada, buat index)
CREATE INDEX IF NOT EXISTS idx_buku_perpustakaan_tenant ON public.buku_perpustakaan(tenant_id);

-- ============================================================
-- PEMILIHAN (pemilihan, calon_kades) -- pemilihan SUDAH ADA
-- ============================================================

-- pemilihan (kolom sudah ada, buat index)
CREATE INDEX IF NOT EXISTS idx_pemilihan_tenant ON public.pemilihan(tenant_id);

-- calon_kades (BARU)
ALTER TABLE public.calon_kades ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.calon_kades SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.calon_kades ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_calon_kades_tenant ON public.calon_kades(tenant_id);

-- ============================================================
-- POSYANDU (posyandu_balita) -- SUDAH ADA
-- ============================================================

-- posyandu_balita (kolom sudah ada, buat index)
CREATE INDEX IF NOT EXISTS idx_posyandu_balita_tenant ON public.posyandu_balita(tenant_id);

-- ============================================================
-- PBB
-- ============================================================

-- pbb_pembayaran (BARU)
ALTER TABLE public.pbb_pembayaran ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.pbb_pembayaran SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.pbb_pembayaran ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_pbb_pembayaran_tenant ON public.pbb_pembayaran(tenant_id);

-- ============================================================
-- BENCANA (bencana_bantuan) -- SUDAH ADA
-- ============================================================

-- bencana_bantuan (kolom sudah ada, buat index)
CREATE INDEX IF NOT EXISTS idx_bencana_bantuan_tenant ON public.bencana_bantuan(tenant_id);

-- ============================================================
-- AUTH (user_profiles)
-- ============================================================

-- user_profiles (BARU)
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS tenant_id UUID;
UPDATE public.user_profiles SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
ALTER TABLE public.user_profiles ALTER COLUMN tenant_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_profiles_tenant ON public.user_profiles(tenant_id);

END $$;
