-- ============================================================
-- CREATE ADMIN USER - Seruni.id
-- Jalankan di Supabase SQL Editor (dengan service_role)
-- ============================================================

-- 1. Buat helper function untuk create admin
CREATE OR REPLACE FUNCTION public.create_admin_user(
  p_nik TEXT,
  p_nama TEXT,
  p_password TEXT DEFAULT 'admin123'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
  v_email TEXT;
BEGIN
  -- Ambil tenant_id
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'tenants table kosong. Jalankan seed migration dulu.';
  END IF;

  -- Cek apakah sudah ada
  IF EXISTS (SELECT 1 FROM public.admin_profiles WHERE nik = p_nik) THEN
    RAISE NOTICE 'Admin dengan NIK % sudah ada', p_nik;
    SELECT id INTO v_user_id FROM public.admin_profiles WHERE nik = p_nik;
    RETURN v_user_id;
  END IF;

  -- Generate email sintetis
  v_email := 'nik-' || p_nik || '@admin.seruni.local';

  -- Create user via Supabase Auth Admin API
  -- Note: Ini butuh service_role key. Alternatif: insert langsung ke auth.users
  -- Untuk simplicity, kita gunakan cara direct insert

  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    last_sign_in_at,
    raw_app_meta_data
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    v_email,
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- 'admin123'
    now(),
    jsonb_build_object('nik', p_nik, 'nama', p_nama),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'
  )
  ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email
  RETURNING id INTO v_user_id;

  -- Buat admin profile
  INSERT INTO public.admin_profiles (id, nik, nama, tenant_id, created_at, updated_at)
  VALUES (v_user_id, p_nik, p_nama, v_tenant_id, now(), now())
  ON CONFLICT (id) DO NOTHING;

  -- Assign admin role
  INSERT INTO public.user_roles (user_id, role, created_at)
  VALUES (v_user_id, 'admin', now())
  ON CONFLICT (user_id, role) DO NOTHING;

  RAISE NOTICE '========================================';
  RAISE NOTICE 'ADMIN USER DIBUAT!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'NIK: %', p_nik;
  RAISE NOTICE 'Nama: %', p_nama;
  RAISE NOTICE 'Password: %', p_password;
  RAISE NOTICE 'Email: %', v_email;
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LOGIN DI: http://localhost:3000/login';
  RAISE NOTICE '========================================';

  RETURN v_user_id;
END;
$$;

-- 2. Beri akses ke function
GRANT EXECUTE ON FUNCTION public.create_admin_user TO service_role;

-- 3. Buat admin default
SELECT public.create_admin_user(
  '5203081234560001',  -- NIK
  'Administrator',       -- Nama
  'admin123'           -- Password
);

-- 4. Verifikasi
SELECT
  'admin_profiles' as tabel,
  count(*) as jumlah
FROM public.admin_profiles
UNION ALL
SELECT 'user_roles (admin)', count(*)
FROM public.user_roles WHERE role = 'admin'
UNION ALL
SELECT 'auth.users', count(*)
FROM auth.users;
