-- ============================================================
-- MIGRASI: 001b_penduduk_event_columns.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Tambah kolom yang dibutuhkan trigger_publish_penduduk_event
--             pada migration 003_domain_events.sql
-- Urutan migrasi: SETELAH 001_auth.sql, SEBELUM 002_reference_tables.sql
-- ============================================================

-- Tambah kolom-kolom yang direferensikan trigger_publish_penduduk_event()
ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS bpjs_status TEXT,
  ADD COLUMN IF NOT EXISTS bpjs_nomor TEXT,
  ADD COLUMN IF NOT EXISTS rt VARCHAR(3),
  ADD COLUMN IF NOT EXISTS rw VARCHAR(3),
  ADD COLUMN IF NOT EXISTS nomor_hp TEXT,
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Set default updated_at trigger (PostgreSQL <16: wrap in DO block)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'penduduk_updated' AND tgrelid = 'public.penduduk'::regclass) THEN
    CREATE TRIGGER penduduk_updated
      BEFORE UPDATE ON public.penduduk
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

COMMENT ON COLUMN public.penduduk.bpjs_status IS 'Status kepesertaan BPJS: aktif, nonaktif, tidak_terdaftar';
COMMENT ON COLUMN public.penduduk.bpjs_nomor IS 'Nomor kartu BPJS Kesehatan';
COMMENT ON COLUMN public.penduduk.rt IS 'Nomor RT';
COMMENT ON COLUMN public.penduduk.rw IS 'Nomor RW';
COMMENT ON COLUMN public.penduduk.nomor_hp IS 'Nomor HP/WA aktif';
COMMENT ON COLUMN public.penduduk.created_by IS 'User yang membuat record ini';
COMMENT ON COLUMN public.penduduk.updated_by IS 'User yang terakhir update record ini';
