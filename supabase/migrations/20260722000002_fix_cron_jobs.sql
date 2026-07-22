-- ============================================================
-- MIGRASI: Fix pg_cron - use Supabase dashboard scheduling
-- Tanggal: 2026-07-22
-- Deskripsi: Replace net.http_post dengan alternatif yang compatible
--            dengan Supabase serverless environment
-- ============================================================

-- ============================================================
-- ALTERNATIF 1: Gunakan Supabase Edge Function untuk cron
-- yang bisa dipanggil via pg_cron secara internal
-- ============================================================

-- Hapus job lama yang pakai net.http_post
DO $$
BEGIN
  PERFORM cron.unschedule('event-processor-every-5min');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- EVENT TRIGGER: langsung update agregat saat ada perubahan
-- Tanpa perlu cron external call
-- ============================================================

-- Function untuk recompute agregat langsung dari trigger
CREATE OR REPLACE FUNCTION trigger_recompute_dashboard_agregat()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
  v_periode TEXT;
  v_today TIMESTAMPTZ;
BEGIN
  v_today := NOW();
  v_periode := TO_CHAR(v_today, 'YYYY-MM');

  -- Get tenant_id dari record yang berubah
  IF TG_OP = 'INSERT' THEN
    v_tenant_id := NEW.tenant_id;
  ELSIF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
    v_tenant_id := OLD.tenant_id;
  ELSE
    RETURN NEW;
  END IF;

  IF v_tenant_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Recompute kependudukan agregat
  IF TG_TABLE_NAME IN ('penduduk', 'keluarga') THEN
    PERFORM recompute_kependudukan_agregat(v_tenant_id, v_periode, v_today);
  END IF;

  RETURN NEW;
END;
$$;

-- Function helper untuk recompute agregat kependudukan
CREATE OR REPLACE FUNCTION recompute_kependudukan_agregat(
  p_tenant_id UUID,
  p_periode TEXT,
  p_dihitung_pada TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total_aktif INTEGER;
  v_total_kk INTEGER;
  v_jumlah_jiwa INTEGER;
BEGIN
  -- Count penduduk aktif
  SELECT COUNT(*) INTO v_total_aktif
  FROM penduduk
  WHERE tenant_id = p_tenant_id
    AND status_hidup = 'aktif';

  -- Count keluarga aktif
  SELECT COUNT(*) INTO v_total_kk
  FROM keluarga
  WHERE tenant_id = p_tenant_id
    AND status_kk = 'aktif';

  -- Count jumlah jiwa dari wilayah dusun
  SELECT COALESCE(SUM(jiwa), 0) INTO v_jumlah_jiwa
  FROM wilayah_dusun
  WHERE tenant_id = p_tenant_id;

  -- Upsert agregat
  INSERT INTO dashboard_agregat (tenant_id, wilayah_id, kategori, metrik_key, metrik_value, periode, dihitung_pada)
  VALUES
    (p_tenant_id, NULL, 'kependudukan', 'jumlah_penduduk_aktif', v_total_aktif, p_periode, p_dihitung_pada),
    (p_tenant_id, NULL, 'kependudukan', 'jumlah_kk_aktif', v_total_kk, p_periode, p_dihitung_pada),
    (p_tenant_id, NULL, 'kependudukan', 'jumlah_jiwa', v_jumlah_jiwa, p_periode, p_dihitung_pada)
  ON CONFLICT (tenant_id, wilayah_id, kategori, metrik_key, periode)
  DO UPDATE SET
    metrik_value = EXCLUDED.metrik_value,
    dihitung_pada = EXCLUDED.dihitung_pada;
END;
$$;

-- ============================================================
-- CRON JOB: Cleanup old events (tanpa http_post)
-- ============================================================

-- Hapus job lama
DO $$
BEGIN
  PERFORM cron.unschedule('event-cleanup-old-events');
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Job cleanup: Mark events lama sebagai processed
-- (Tidak perlu http_post karena tidak memanggil external service)
SELECT cron.schedule(
  'cleanup-old-events',
  '0 3 * * *',  -- 3 AM setiap hari
  $$
  UPDATE domain_events
  SET processed_at = NOW()
  WHERE processed_at IS NULL
    AND created_at < NOW() - INTERVAL '30 days'
    AND event_type IN (
      'penduduk.bpjs.berubah',
      'infrastruktur.dilaporkan',
      'posyandu.kunjungan.dicatat'
    )
  $$
);

-- ============================================================
-- CRON JOB: Daily IDM recompute
-- ============================================================

SELECT cron.schedule(
  'daily-idm-recompute',
  '0 4 * * *',  -- 4 AM setiap hari
  $$
  -- Insert event untuk trigger IDM recompute
  INSERT INTO domain_events (tenant_id, event_type, entity_type, entity_id, payload)
  SELECT
    id as tenant_id,
    'system.daily_idm_recompute' as event_type,
    'tenants' as entity_type,
    id as entity_id,
    '{"source":"cron"}'::jsonb as payload
  FROM tenants
  WHERE aktif = true
  ON CONFLICT DO NOTHING
  $$
);

-- ============================================================
-- CRON JOB: Weekly dashboard refresh
-- ============================================================

SELECT cron.schedule(
  'weekly-dashboard-refresh',
  '0 5 * * 1',  -- 5 AM setiap Senin
  $$
  INSERT INTO domain_events (tenant_id, event_type, entity_type, entity_id, payload)
  SELECT
    id as tenant_id,
    'system.weekly_refresh' as event_type,
    'tenants' as entity_type,
    id as entity_id,
    '{"source":"cron","action":"refresh_all"}'::jsonb as payload
  FROM tenants
  WHERE aktif = true
  ON CONFLICT DO NOTHING
  $$
);

-- ============================================================
-- VERIFIKASI: Tampilkan semua job aktif
-- ============================================================

-- List active cron jobs
-- SELECT jobname, schedule, command FROM cron.job WHERE active = true;

COMMENT ON FUNCTION trigger_recompute_dashboard_agregat IS
'Trigger untuk auto-recompute dashboard_agregat saat penduduk/keluarga berubah';

COMMENT ON FUNCTION recompute_kependudukan_agregat IS
'Helper function untuk recompute agregat kependudukan';
