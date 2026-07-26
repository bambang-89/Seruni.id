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

-- ============================================================
-- SEED: Distribusi Demografis
-- Seed data distribusi untuk StatistikPendudukPage
-- Kelompok Umur, Pekerjaan, dan Pendidikan
-- ============================================================

INSERT INTO dashboard_agregat (tenant_id, kategori, metrik_key, metrik_value, periode)
VALUES
  -- Distribusi berdasarkan Umur
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'per_umur',
   '[
     {"label":"0-4 tahun","nilai":89},
     {"label":"5-9 tahun","nilai":102},
     {"label":"10-14 tahun","nilai":98},
     {"label":"15-19 tahun","nilai":94},
     {"label":"20-24 tahun","nilai":103},
     {"label":"25-29 tahun","nilai":112},
     {"label":"30-34 tahun","nilai":118},
     {"label":"35-39 tahun","nilai":105},
     {"label":"40-44 tahun","nilai":97},
     {"label":"45-49 tahun","nilai":89},
     {"label":"50-54 tahun","nilai":76},
     {"label":"55-59 tahun","nilai":68},
     {"label":"60+ tahun","nilai":96}
   ]'::jsonb,
   '2026-06-30'),
  -- Distribusi berdasarkan Pekerjaan
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'per_pekerjaan',
   '[
     {"label":"Petani","nilai":312},
     {"label":"Buruh","nilai":198},
     {"label":"Pedagang","nilai":87},
     {"label":"Guru/Tenaga Pendidik","nilai":34},
     {"label":"PNS/TNI/Polri","nilai":29},
     {"label":"Wiraswasta","nilai":156},
     {"label":"Ibu Rumah Tangga","nilai":245},
     {"label":"Pelajar/Mahasiswa","nilai":112},
     {"label":"Pensiunan","nilai":18},
     {"label":"Lainnya","nilai":56}
   ]'::jsonb,
   '2026-06-30'),
  -- Distribusi berdasarkan Pendidikan
  ('d532ae95-0ad9-42bb-a6e8-5c840447c90e', 'penduduk', 'per_pendidikan',
   '[
     {"label":"Belum Sekolah","nilai":142},
     {"label":"SD/Sederajat","nilai":398},
     {"label":"SMP/Sederajat","nilai":312},
     {"label":"SMA/Sederajat","nilai":267},
     {"label":"Diploma","nilai":42},
     {"label":"Sarjana","nilai":76},
     {"label":"Pascasarjana","nilai":10}
   ]'::jsonb,
   '2026-06-30')
ON CONFLICT (kategori, metrik_key, periode) DO NOTHING;
