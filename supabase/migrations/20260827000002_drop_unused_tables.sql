-- Drop unused/obsolete tables and views
-- Uses separate DROP TABLE/VIEW IF EXISTS to handle items that might be either

-- Analytics (views)
DROP VIEW IF EXISTS public.analytics_page_stats CASCADE;
DROP VIEW IF EXISTS public.analytics_daily_stats CASCADE;
DROP VIEW IF EXISTS public.wa_chatbot_stats CASCADE;
DROP VIEW IF EXISTS public.idm_dashboard_summary CASCADE;
DROP VIEW IF EXISTS public.recent_activity CASCADE;

-- Analytics (tables)
DROP TABLE IF EXISTS public.analytics_sessions CASCADE;
DROP TABLE IF EXISTS public.otp_token CASCADE;

-- Reference tables
DROP TABLE IF EXISTS public.ref_kategori_bansos CASCADE;
DROP TABLE IF EXISTS public.ref_rt CASCADE;
DROP TABLE IF EXISTS public.ref_rt_rw CASCADE;
DROP TABLE IF EXISTS public.ref_rw CASCADE;
DROP TABLE IF EXISTS public.ref_upload_preferences CASCADE;
DROP TABLE IF EXISTS public.ref_tipe_keluarga CASCADE;
DROP TABLE IF EXISTS public.ref_aduan_kategori CASCADE;

-- Operational tables
DROP TABLE IF EXISTS public.surat_tiket_seq CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.outbox_pesan CASCADE;
DROP TABLE IF EXISTS public.pemilihan CASCADE;

-- Domain tables
DROP TABLE IF EXISTS public.bencana_bantuan CASCADE;
DROP TABLE IF EXISTS public.apotek_resep CASCADE;
DROP TABLE IF EXISTS public.apotek_desa CASCADE;
DROP TABLE IF EXISTS public.apotek_obat CASCADE;
DROP TABLE IF EXISTS public.dokumen_desa CASCADE;
DROP TABLE IF EXISTS public.perpustakaan_desa CASCADE;
DROP TABLE IF EXISTS public.buku_perpustakaan CASCADE;
DROP TABLE IF EXISTS public.calon_kades CASCADE;
DROP TABLE IF EXISTS public.rekening_anggaran CASCADE;
DROP TABLE IF EXISTS public.potensi_desa CASCADE;
DROP TABLE IF EXISTS public.posyandu_balita CASCADE;
DROP TABLE IF EXISTS public.pbb_pembayaran CASCADE;
DROP TABLE IF EXISTS public.bidang_kegiatan CASCADE;
DROP TABLE IF EXISTS public.wa_chat_session CASCADE;
DROP TABLE IF EXISTS public.idm_scoring_log CASCADE;
