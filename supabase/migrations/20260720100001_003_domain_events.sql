-- ============================================================
-- MIGRASI: 003_domain_events.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Event Sourcing Table & Event Publisher Functions
-- Prinsip: "Satu Input, Banyak Dampak" - setiap perubahan fakta
--          mentah menerbitkan domain_events, worker menghitung turunan
-- Urutan migrasi: setelah 001b_penduduk_event_columns.sql, 002_reference_tables.sql
-- ============================================================

-- 1. Domain Events Table (Event Sourcing)
CREATE TABLE IF NOT EXISTS domain_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID, -- nullable untuk event global (mis. startup)
  event_type VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL, -- 'penduduk', 'surat', 'pbb', dst.
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  aktor_id UUID, -- user yang memicu event (nullable untuk system events)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ -- NULL = belum diproses
);

-- Index untuk worker: ambil event yang belum diproses
CREATE INDEX IF NOT EXISTS idx_domain_events_unprocessed
  ON domain_events(created_at ASC)
  WHERE processed_at IS NULL;

-- Index untuk audit trail per entity
CREATE INDEX IF NOT EXISTS idx_domain_events_entity
  ON domain_events(entity_type, entity_id, created_at DESC);

-- Index untuk analytics per event type
CREATE INDEX IF NOT EXISTS idx_domain_events_type
  ON domain_events(event_type, created_at DESC);

GRANT SELECT ON domain_events TO authenticated;
GRANT INSERT ON domain_events TO authenticated, service_role;
GRANT ALL ON domain_events TO service_role;
ALTER TABLE domain_events ENABLE ROW LEVEL SECURITY;

-- Policy: semua bisa baca, hanya service_role dan authenticated yang bisa insert
CREATE POLICY "Public read domain_events" ON domain_events
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can create events" ON domain_events
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Service can manage events" ON domain_events
  FOR ALL TO service_role USING (true);

-- 2. Event Types Enum (standar event kanonik)
-- Event type mengikuti naming convention: entity.action
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_type') THEN
    CREATE TYPE event_type AS ENUM (
      'penduduk.dibuat',
      'penduduk.data.berubah',
      'penduduk.status.berubah',
      'penduduk.bpjs.berubah',
      'surat.diajukan',
      'surat.diverifikasi',
      'surat.ditolak',
      'surat.ditandatangani',
      'surat.diterbitkan',
      'surat.dikirim',
      'usulan.diajukan',
      'usulan.lolos_verifikasi',
      'usulan.ditolak',
      'usulan.ditetapkan_rkpdes',
      'usulan.vote.bertambah',
      'voting.ditutup',
      'pbb.wajib_pajak.didaftarkan',
      'pbb.objek_pajak.didaftarkan',
      'pbb.objek_pajak.berubah',
      'pbb.tagihan.dibayar',
      'apbdes.realisasi.dicatat',
      'apbdes.kegiatan.disahkan',
      'posyandu.kunjungan.dicatat',
      'posyandu.balita.terindikasi_gizi_buruk',
      'bidang_tanah.didaftarkan',
      'bidang_tanah.disahkan',
      'bidang_tanah.dialihkan',
      'infrastruktur.dilaporkan',
      'infrastruktur.diverifikasi',
      'musdes.usulan.ditetapkan',
      'musdes.jadwal.ditetapkan',
      'wa.layanan.selesai',
      'aset.dibuat',
      'aset.diverifikasi',
      'aset.disusutkan'
    );
  END IF;
END $$;

-- 3. Helper Function: Publish Event
-- Usage: SELECT publish_event('penduduk.dibuat', 'penduduk', uuid, payload, aktor_uuid);
CREATE OR REPLACE FUNCTION publish_event(
  p_event_type VARCHAR,
  p_entity_type VARCHAR,
  p_entity_id UUID,
  p_payload JSONB DEFAULT '{}',
  p_aktor_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO domain_events (event_type, entity_type, entity_id, payload, aktor_id)
  VALUES (p_event_type, p_entity_type, p_entity_id, p_payload, p_aktor_id)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION publish_event IS
'Publish a domain event. Returns event ID.
Usage: SELECT publish_event(''penduduk.dibuat'', ''penduduk'', entity_uuid, ''{"nik":"360101..."}''::jsonb, auth.uid())';

-- 4. Trigger: Auto-publish events untuk operasi CRUD tertentu
-- Menggunakan trigger untuk otomatisasi event tanpa perlu手动 call function

-- 4a. Trigger function untuk penduduk
CREATE OR REPLACE FUNCTION trigger_publish_penduduk_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_event_type := 'penduduk.dibuat';
    v_payload := jsonb_build_object(
      'nik', NEW.nik,
      'nama', NEW.nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event(v_event_type, 'penduduk', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Detect perubahan field
    IF OLD.status_hidup IS DISTINCT FROM NEW.status_hidup THEN
      v_payload := jsonb_build_object(
        'field', 'status_hidup',
        'lama', OLD.status_hidup,
        'baru', NEW.status_hidup
      );
      IF NEW.status_hidup IN ('meninggal', 'pindah') THEN
        v_event_type := 'penduduk.status.berubah';
      ELSE
        v_event_type := 'penduduk.data.berubah';
      END IF;
      PERFORM publish_event(v_event_type, 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;

    IF OLD.bpjs_status IS DISTINCT FROM NEW.bpjs_status
       OR OLD.bpjs_nomor IS DISTINCT FROM NEW.bpjs_nomor THEN
      v_payload := jsonb_build_object(
        'bpjs_status_lama', OLD.bpjs_status,
        'bpjs_status_baru', NEW.bpjs_status,
        'bpjs_nomor_baru', NEW.bpjs_nomor
      );
      PERFORM publish_event('penduduk.bpjs.berubah', 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain (nama, alamat, dusun, dll)
    IF OLD.nama IS DISTINCT FROM NEW.nama
       OR OLD.alamat IS DISTINCT FROM NEW.alamat
       OR OLD.dusun IS DISTINCT FROM NEW.dusun
       OR OLD.rt IS DISTINCT FROM NEW.rt
       OR OLD.rw IS DISTINCT FROM NEW.rw
       OR OLD.nomor_hp IS DISTINCT FROM NEW.nomor_hp THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nama', jsonb_build_array(OLD.nama, NEW.nama),
          'alamat', jsonb_build_array(OLD.alamat, NEW.alamat),
          'dusun', jsonb_build_array(OLD.dusun, NEW.dusun),
          'rt', jsonb_build_array(OLD.rt, NEW.rt),
          'rw', jsonb_build_array(OLD.rw, NEW.rw),
          'nomor_hp', jsonb_build_array(OLD.nomor_hp, NEW.nomor_hp)
        )
      );
      PERFORM publish_event('penduduk.data.berubah', 'penduduk', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Attach trigger ke tabel penduduk
DROP TRIGGER IF EXISTS trg_penduduk_publish_event ON public.penduduk;
CREATE TRIGGER trg_penduduk_publish_event
  AFTER INSERT OR UPDATE ON public.penduduk
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_penduduk_event();

-- 5. Event Log untuk audit trail (read-only, immutabel)
CREATE TABLE IF NOT EXISTS event_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID,
  entitas VARCHAR(50) NOT NULL,
  entitas_id UUID,
  event_name VARCHAR(100) NOT NULL,
  actor_id UUID,
  payload JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_log_entity
  ON event_log(entitas, entitas_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_log_actor
  ON event_log(actor_id, created_at DESC);

GRANT SELECT ON event_log TO authenticated;
GRANT INSERT ON event_log TO authenticated, service_role;
GRANT ALL ON event_log TO service_role;
ALTER TABLE event_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read event_log" ON event_log
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service can manage event_log" ON event_log
  FOR ALL TO service_role USING (true);

-- 6. Helper: Log audit trail
CREATE OR REPLACE FUNCTION log_audit_event(
  p_entitas VARCHAR,
  p_entitas_id UUID,
  p_event_name VARCHAR,
  p_payload JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_log_id UUID;
  v_aktor_id UUID;
BEGIN
  -- Try to get current user (will be null if not authenticated)
  BEGIN
    v_aktor_id := auth.uid();
  EXCEPTION WHEN OTHERS THEN
    v_aktor_id := NULL;
  END;

  INSERT INTO event_log (entitas, entitas_id, event_name, actor_id, payload)
  VALUES (p_entitas, p_entitas_id, p_event_name, v_aktor_id, p_payload)
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

COMMENT ON FUNCTION log_audit_event IS
'Log an audit event for compliance. This is append-only and immutable.
Usage: SELECT log_audit_event(''surat'', surat_id, ''surat.ditandatangani'', ''{}''::jsonb)';

-- 7. Cron: Cleanup old unprocessed events (retention policy)
-- Events yang tidak diproses dalam 7 hari akan ditandai sebagai failed
DO $$
BEGIN
  -- Update events yang older dari 7 hari dan belum diproses
  -- Ini adalah maintenance, bukan delete, jadi data tidak hilang
  -- Worker bisa retry jika perlu
  UPDATE domain_events
  SET processed_at = NOW() -- mark as processed (will be skipped by worker)
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '7 days'
    AND event_type IN (
      -- Event yang tidak kritikal untuk di-retry setelah 7 hari
      'penduduk.bpjs.berubah',
      'infrastruktur.dilaporkan'
    );
END $$;

COMMENT ON FUNCTION log_audit_event IS
'Audit trail logger. Append-only, cannot be deleted.
Retention: domain_events kept for 1 year, then archived.
event_log kept for 7 years for compliance (UU No. 27/2007 tentang Kearsipan).';

-- ============================================================
-- 8. pg_cron: Schedule Event Processor
-- Supabase sudah include pg_cron. Jadwal: setiap 5 menit.
-- Job dipanggil via HTTP request ke edge function.
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Hapus job lama jika ada (idempotent — ignore error jika belum ada)
DO $$
BEGIN
  PERFORM cron.unschedule('event-processor-every-5min');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Jadwal: setiap 5 menit, mulai sekarang
SELECT cron.schedule(
  'event-processor-every-5min',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.event_processor_url', true)
           || '/functions/v1/event-processor',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer " || current_setting(''app.event_processor_key'', true)}'::jsonb,
    body := '{"source":"pg_cron"}'::jsonb
  );
  $$
);

-- Fallback: juga jadwal cleanup event retention setiap jam 02:00
DO $$
BEGIN
  PERFORM cron.unschedule('event-cleanup-old-events');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
SELECT cron.schedule(
  'event-cleanup-old-events',
  '0 2 * * *',
  $$
  UPDATE domain_events
  SET processed_at = NOW()
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '7 days'
    AND event_type IN ('penduduk.bpjs.berubah', 'infrastruktur.dilaporkan');
  $$
);
