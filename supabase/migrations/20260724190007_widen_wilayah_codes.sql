-- Migration: 20260724190007_widen_wilayah_codes.sql
-- Widens kode columns to handle 7-digit district / 10-digit village codes from KEMENDAGRI 2024+
-- Idempotent — safe to run on top of existing data
DO $outer$
BEGIN

  -- Widen ref_kecamatan.kode (6 → 10 chars)
  ALTER TABLE public.ref_kecamatan ALTER COLUMN kode TYPE VARCHAR(10);
  -- Seed correct Lombok Timur districts (regency 5203)
  INSERT INTO public.ref_kecamatan (kode, kode_kabupaten, nama, urutan, aktif)
  VALUES
    ('5203010', '5203', 'Keruak', 1, true),
    ('5203011', '5203', 'Jerowaru', 2, true),
    ('5203020', '5203', 'Sakra', 3, true),
    ('5203021', '5203', 'Sakra Barat', 4, true),
    ('5203022', '5203', 'Sakra Timur', 5, true),
    ('5203030', '5203', 'Terara', 6, true),
    ('5203031', '5203', 'Montong Gading', 7, true),
    ('5203040', '5203', 'Sikur', 8, true),
    ('5203050', '5203', 'Masbagik', 9, true),
    ('5203051', '5203', 'Pringgasela', 10, true),
    ('5203060', '5203', 'Sukamulia', 11, true),
    ('5203061', '5203', 'Suralaga', 12, true),
    ('5203070', '5203', 'Selong', 13, true),
    ('5203071', '5203', 'Labuhan Haji', 14, true),
    ('5203080', '5203', 'Pringgabaya', 15, true),
    ('5203081', '5203', 'Suela', 16, true),
    ('5203090', '5203', 'Aikmel', 17, true),
    ('5203091', '5203', 'Wanasaba', 18, true),
    ('5203092', '5203', 'Sembalun', 19, true),
    ('5203100', '5203', 'Sambelia', 20, true)
  ON CONFLICT (kode) DO NOTHING;

  -- Widen ref_desa.kode (10 → 13 chars for 10-digit village codes)
  ALTER TABLE public.ref_desa ALTER COLUMN kode TYPE VARCHAR(13);

  -- Seed correct Lombok Timur regency (5203)
  INSERT INTO public.ref_kabupaten (kode, kode_provinsi, nama, ibukota, jenis, urutan, aktif)
  VALUES ('5203', '52', 'Lombok Timur', 'Selong', 'Kabupaten', 1, true)
  ON CONFLICT (kode) DO NOTHING;

  RAISE NOTICE 'Wilayah codes widened and Lombok Timur seeded.';
END $outer$;
