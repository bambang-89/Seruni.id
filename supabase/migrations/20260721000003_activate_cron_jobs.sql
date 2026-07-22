-- ============================================================
-- MIGRASI: 20260721000003_activate_cron_jobs.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Aktifkan pg_cron jobs untuk event processor
--            + set app settings agar cron job bisa akses edge function
-- ============================================================

-- Set app settings untuk event processor cron (dibaca oleh cron job body)
DO $$
BEGIN
  -- Set hanya jika belum ada (avoid overwrite)
  IF current_setting('app.event_processor_url', true) IS NULL
     OR current_setting('app.event_processor_url', true) = '' THEN
    PERFORM set_config('app.event_processor_url', 'https://smngqdpbmgcdbmkiuviq.supabase.co', true);
  END IF;
  IF current_setting('app.event_processor_key', true) IS NULL
     OR current_setting('app.event_processor_key', true) = '' THEN
    PERFORM set_config('app.event_processor_key',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg',
      true);
  END IF;
END $$;

-- Pastikan pg_cron extension aktif
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Hapus job lama jika ada (idempotent)
DO $$
BEGIN
  PERFORM cron.unschedule('event-processor-every-5min');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Job 1: Event processor setiap 5 menit
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

-- Hapus job cleanup lama jika ada
DO $$
BEGIN
  PERFORM cron.unschedule('event-cleanup-old-events');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Job 2: Cleanup old events setiap jam 02:00
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

-- Verifikasi: tampilkan semua job aktif
SELECT jobname, schedule, command FROM cron.job;
