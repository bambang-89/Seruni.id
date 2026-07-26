-- Migration: Add 7 missing dusun to wilayah_dusun
-- These dusun exist in penduduk table but are missing from wilayah_dusun.
-- jiwa and kk set to 0 (unknown) - admin can update later.

INSERT INTO public.wilayah_dusun (id, nama, jiwa, kk, tenant_id, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'Seruni Barat',     0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Mumbul Utara',     0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Seruni Timur',     0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Mumbul Selatan',   0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Seruni Mumbul',    0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Seruni Selatan',   0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now()),
  (gen_random_uuid(), 'Seruni Utara',     0, 0, 'd532ae95-0ad9-42bb-a6e8-5c840447c90e', now(), now())
ON CONFLICT DO NOTHING;
