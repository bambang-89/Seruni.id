-- ============================================================
-- SEED: dashboard_agregat
-- Seed data agregat untuk dashboard portal
-- Tenant: d532ae95-0ad9-42bb-a6e8-5c840447c90e
-- Idempotent: INSERT ... ON CONFLICT DO NOTHING
-- ============================================================

INSERT INTO dashboard_agregat (tenant_id, kategori, metrik_key, metrik_value, periode)
VALUES
  -- Penduduk
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'total_penduduk', 1247, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'jumlah_kk', 389, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'laki_laki', 612, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'perempuan', 635, '2026-06-30'),
  -- Kesehatan
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'balita_gizi_baik', 87, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'balita_stunting', 4, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'kades_terlayani', 156, '2026-06-30'),
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'kesehatan', 'ibu_hamil_terdaftar', 12, '2026-06-30')
ON CONFLICT (kategori, metrik_key, periode) DO NOTHING;
