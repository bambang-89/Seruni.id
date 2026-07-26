-- ============================================================
-- Seed: admin_profiles, user_peran, dpt_pemilih, voting_suara, usulan_vote
-- ============================================================
DO $$
DECLARE
  v_tid UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
  v_user_id UUID := 'f1fabb8f-9aef-4e3b-8874-42158f93e558';
  v_topik1 UUID := 'a631c5d3-3293-4d55-9f93-0396639bf973';
  v_topik2 UUID := 'ee44013f-373f-4024-ae0e-afe4d54b62b9';
  v_opsi_jalan UUID := '0bd5d793-14ce-403d-b441-854e8b81464b';
  v_opsi_air UUID := 'b37b922a-c816-454e-be9c-0e63232881fc';
  v_opsi_poskesdes UUID := '2bef6477-9f65-44fd-a1f8-d321b8977931';
  v_opsi_paud UUID := '60cb15c6-637c-47df-bc3e-37f6e753bc33';
  v_opsi_mandar UUID := '66602758-1859-4f92-a7a9-10503ca34c2a';
  v_opsi_sasak UUID := '82e162ef-5d87-4cb3-9e70-cfab952d7c41';
  v_opsi_pasar UUID := '805f48e4-a062-4b48-842f-bd6b71d2a26e';
  v_dusun_mandar UUID := '6a3e9435-b0ab-420b-91a3-ac9aee413738';
  v_dusun_sasak UUID := '2af89e2d-f185-446b-8bee-872e8e8eaaed';
  v_dusun_dames UUID := '2af89e2d-f185-446b-8bee-872e8e8eaaed';
  v_dusun_brang UUID := '7baebe3c-f345-4d3a-87a8-2544caa99807';
BEGIN

  -- ============================================================
  -- 1. admin_profiles
  -- ============================================================
  -- hanya user yang ada di auth.users
  INSERT INTO admin_profiles (id, nik, nama)
  SELECT
    u.id,
    '5203085405140001',
    'Bambang Susilo'
  FROM auth.users u WHERE u.email = 'bambang30488@gmail.com'
  ON CONFLICT (id) DO NOTHING;

  RAISE NOTICE 'admin_profiles done';

  -- ============================================================
  -- 2. user_peran
  -- ============================================================
  INSERT INTO user_peran (user_id, peran, dusun_id, aktif)
  VALUES
    (v_user_id, 'admin', NULL, true),
    (v_user_id, 'kades', NULL, true),
    (v_user_id, 'sekdes', NULL, true)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'user_peran done';

  -- ============================================================
  -- 3. dpt_pemilih
  -- ============================================================

  DROP TRIGGER IF EXISTS trg_audit_dpt_pemilih ON dpt_pemilih;
  DROP TRIGGER IF EXISTS trg_dpt_updated ON dpt_pemilih;
  DELETE FROM dpt_pemilih;

  INSERT INTO dpt_pemilih (tenant_id, nik, nama, tempat_lahir, tanggal_lahir, jenis_kelamin, dusun, rt, rw, tps, pemilu_kode, status)
  SELECT
    v_tid,
    p.nik,
    p.nama,
    COALESCE(p.tempat_lahir, 'Lombok Timur'),
    p.tanggal_lahir,
    p.jenis_kelamin,
    p.dusun,
    COALESCE(p.rt, '01'),
    COALESCE(p.rw, '01'),
    'TPS 01',
    'PILKADA 2024',
    'aktif'
  FROM penduduk p
  WHERE p.tanggal_lahir IS NOT NULL
    AND p.tanggal_lahir <= CURRENT_DATE - INTERVAL '17 years'
    AND (p.status_hidup IS NULL OR p.status_hidup = 'hidup')
  LIMIT 500;

  RAISE NOTICE 'dpt_pemilih done';

  -- ============================================================
  -- 4. voting_suara
  -- ============================================================

  DROP TRIGGER IF EXISTS enforce_append_only_voting_suara ON voting_suara;
  DROP TRIGGER IF EXISTS trg_voting_suara_publish_event ON voting_suara;
  DROP TRIGGER IF EXISTS trg_voting_sync ON voting_suara;
  DELETE FROM voting_suara;

  -- Topik 1: Prioritas Pembangunan Burnett 2027 (4 opsi)
  INSERT INTO voting_suara (tenant_id, topik_id, opsi_id, voter_hash, dusun, created_at)
  VALUES
    (v_tid, v_topik1, v_opsi_jalan, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik1, v_opsi_jalan, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik1, v_opsi_jalan, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik1, v_opsi_air, encode(sha256(random()::text::bytea), 'hex'), 'Sasak', NOW()),
    (v_tid, v_topik1, v_opsi_air, encode(sha256(random()::text::bytea), 'hex'), 'Sasak', NOW()),
    (v_tid, v_topik1, v_opsi_poskesdes, encode(sha256(random()::text::bytea), 'hex'), 'Brangtapen Asri', NOW()),
    (v_tid, v_topik1, v_opsi_poskesdes, encode(sha256(random()::text::bytea), 'hex'), 'Brangtapen Asri', NOW()),
    (v_tid, v_topik1, v_opsi_paud, encode(sha256(random()::text::bytea), 'hex'), 'Dames', NOW()),
    (v_tid, v_topik1, v_opsi_paud, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik1, v_opsi_jalan, encode(sha256(random()::text::bytea), 'hex'), 'Sasak', NOW());

  -- Topik 2: Lokasi MCK Umum (3 opsi)
  INSERT INTO voting_suara (tenant_id, topik_id, opsi_id, voter_hash, dusun, created_at)
  VALUES
    (v_tid, v_topik2, v_opsi_mandar, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik2, v_opsi_mandar, encode(sha256(random()::text::bytea), 'hex'), 'Mandar', NOW()),
    (v_tid, v_topik2, v_opsi_sasak, encode(sha256(random()::text::bytea), 'hex'), 'Sasak', NOW()),
    (v_tid, v_topik2, v_opsi_pasar, encode(sha256(random()::text::bytea), 'hex'), 'Brangtapen Asri', NOW()),
    (v_tid, v_topik2, v_opsi_sasak, encode(sha256(random()::text::bytea), 'hex'), 'Dames', NOW());

  RAISE NOTICE 'voting_suara done';

  -- ============================================================
  -- 5. usulan_vote
  -- ============================================================

  DROP TRIGGER IF EXISTS enforce_append_only_usulan_vote ON usulan_vote;
  DROP TRIGGER IF EXISTS trg_usulan_vote_publish_event ON usulan_vote;
  DROP TRIGGER IF EXISTS trg_usulan_vote_sync ON usulan_vote;
  DELETE FROM usulan_vote;

  INSERT INTO usulan_vote (tenant_id, usulan_id, voter_hash, dusun, created_at)
  SELECT v_tid, u.id, encode(sha256(random()::text::bytea), 'hex'), u.dusun,
         NOW() - (random() * interval '30 days')
  FROM (
    SELECT id, dusun FROM usulan_warga LIMIT 12
  ) u
  CROSS JOIN generate_series(1, 5);

  RAISE NOTICE 'usulan_vote done';

END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'admin_profiles: ' || count(*) FROM admin_profiles
UNION ALL
SELECT 'user_peran: ' || count(*) FROM user_peran
UNION ALL
SELECT 'dpt_pemilih: ' || count(*) FROM dpt_pemilih
UNION ALL
SELECT 'voting_suara: ' || count(*) FROM voting_suara
UNION ALL
SELECT 'usulan_vote: ' || count(*) FROM usulan_vote;
