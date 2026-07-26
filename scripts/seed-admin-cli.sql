-- Seed Admin User Script
-- Run: npx supabase db query --linked -f scripts/seed-admin-cli.sql

BEGIN;

-- Create user_roles for existing auth user
INSERT INTO public.user_roles (user_id, role)
SELECT
  auth.users.id,
  'admin'
FROM auth.users
WHERE auth.users.email = 'nik-5203085405140001@admin.seruni.local'
ON CONFLICT DO NOTHING;

-- Update or insert admin_profiles for the new user
INSERT INTO public.admin_profiles (nik, nama, password_hash)
VALUES (
  '5203083004880003',
  'Bambang Nurdiansyah',
  'bcrypt_hash_placeholder'
)
ON CONFLICT (nik) DO UPDATE SET
  nama = 'Bambang Nurdiansyah';

COMMIT;
