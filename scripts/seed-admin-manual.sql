-- ============================================================
-- SEED ADMIN USER
-- Run: Paste to Supabase SQL Editor
-- ============================================================

BEGIN;

-- Variables
DO $$
DECLARE
  v_nik TEXT := '5203083004880003';
  v_nama TEXT := 'Bambang Nurdiansyah';
  v_email TEXT := 'bambang30488@gmail.com';
  v_password TEXT := 'Serunimumbul88';
  v_penduduk_id UUID;
  v_user_id UUID;
BEGIN

  -- Get penduduk_id from NIK
  SELECT id INTO v_penduduk_id FROM penduduk WHERE nik = v_nik;
  RAISE NOTICE 'Penduduk ID: %', v_penduduk_id;

  -- If penduduk exists, use its ID as user_id, otherwise generate new
  IF v_penduduk_id IS NOT NULL THEN
    v_user_id := v_penduduk_id;
  ELSE
    v_user_id := gen_random_uuid();
  END IF;

  RAISE NOTICE 'User ID will be: %', v_user_id;

  -- Note: We cannot create auth.users directly via SQL
  -- This must be done via Supabase Dashboard > Authentication > Users
  -- Or via the admin console

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'ADMIN SEED INSTRUCTIONS';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '1. Go to Supabase Dashboard > Authentication > Users';
  RAISE NOTICE '2. Click "Add User"';
  RAISE NOTICE '3. Enter:';
  RAISE NOTICE '   Email: %', v_email;
  RAISE NOTICE '   Password: %', v_password;
  RAISE NOTICE '4. Click Create User';
  RAISE NOTICE '5. Copy the user ID from the created user';
  RAISE NOTICE '';
  RAISE NOTICE 'Or use this SQL after creating the user:';
  RAISE NOTICE '';
  RAISE NOTICE '-- After creating user in Dashboard, run:';
  RAISE NOTICE '-- INSERT INTO user_roles (user_id, role) VALUES (''user_id_here'', ''admin'');';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';

END $$;

-- For admin_profiles table (if exists)
-- INSERT INTO admin_profiles (nik, nama, password_hash)
-- VALUES ('5203083004880003', 'Bambang Nurdiansyah', 'placeholder')
-- ON CONFLICT (nik) DO UPDATE SET nama = 'Bambang Nurdiansyah';

COMMIT;
