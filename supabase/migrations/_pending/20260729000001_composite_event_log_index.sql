-- Composite index for rate-limit queries on event_log
-- Covers: WHERE event_name = 'usulan_warga.dibuat_publik' AND created_at >= ? AND payload->>'fp' = ? AND tenant_id = ?
-- Covers: WHERE event_name = 'surat.diajukan' AND created_at >= ? AND payload->>'fp' = ? AND tenant_id = ?

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_log_rate_limit
  ON event_log (event_name, created_at, (payload->>'fp'), tenant_id)
  WHERE event_name IN ('usulan_warga.dibuat_publik', 'surat.diajukan');

COMMENT ON INDEX idx_event_log_rate_limit IS
  'Accelerates rate-limit lookups in submit-surat and submit-usulan edge functions.
   Partial index only covers active rate-limited event names to minimize size.';
