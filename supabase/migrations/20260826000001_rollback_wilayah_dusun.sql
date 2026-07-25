-- Rollback: Remove 7 incorrectly added dusun entries
-- Only 4 valid dusun remain: Mandar, Sasak, Dames, Brangtapen Asri
DELETE FROM public.wilayah_dusun WHERE nama IN (
  'Seruni Barat',
  'Mumbul Utara',
  'Seruni Timur',
  'Mumbul Selatan',
  'Seruni Mumbul',
  'Seruni Selatan',
  'Seruni Utara'
);
