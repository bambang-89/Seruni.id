import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

function json(res: VercelResponse, data: unknown, status = 200) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  return res.status(status).json(data);
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Origin', '*').end();
  }
  if (req.method !== 'POST') {
    return json(res, { error: 'Method not allowed' }, 405);
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    return json(res, { error: 'Missing Supabase configuration' }, 500);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  const body = req.body || {};
  const nik = String(body.nik || '').trim();
  const nama = String(body.nama || '').trim();
  const password = String(body.password || '');

  if (!/^\d{6,20}$/.test(nik)) {
    return json(res, { error: 'NIK harus 6-20 digit angka' }, 400);
  }
  if (password.length < 8) {
    return json(res, { error: 'Password minimal 8 karakter' }, 400);
  }
  if (!nama || nama.length < 2) {
    return json(res, { error: 'Nama minimal 2 karakter' }, 400);
  }

  const email = `nik-${nik}@admin.seruni.local`;

  // Check if profile already exists
  const { data: existingProfile } = await supabase
    .from('admin_profiles')
    .select('id, nik, nama')
    .eq('nik', nik)
    .maybeSingle();

  if (existingProfile) {
    // Profile exists — update auth user password using profile's UUID
    await supabase.auth.admin.updateUserById(existingProfile.id, { password });
    return json(res, {
      success: true,
      message: 'Password admin di-reset',
      data: { nik: existingProfile.nik, nama: existingProfile.nama, email, status: 'updated' }
    });
  }

  // Profile doesn't exist — check if auth user exists by email
  const { data: authData } = await supabase.auth.admin.listUsers() as unknown as { data: { users?: Array<{ id: string; email?: string }> } };
  const existingAuthUser = authData?.users?.find((u: { email?: string }) => u.email === email);

  if (existingAuthUser) {
    // Auth user exists but profile doesn't — recreate profile and update password
    await supabase.auth.admin.updateUserById(existingAuthUser.id, { password });
    await supabase.from('admin_profiles').upsert({ id: existingAuthUser.id, nik, nama }, { onConflict: 'id' });
    await supabase.from('user_roles').upsert({ user_id: existingAuthUser.id, role: 'admin' }, { onConflict: 'user_id,role' });
    await supabase.from('user_peran').upsert({ user_id: existingAuthUser.id, peran: 'admin', aktif: true }, { onConflict: 'user_id,peran' });
    return json(res, {
      success: true,
      message: 'Akun admin dipulihkan, password di-reset',
      data: { nik, nama, email, status: 'recovered' }
    });
  }

  // Neither exists — create fresh

  // Create auth user
  const { data: newUser, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { nik, nama },
  });

  if (authError) {
    return json(res, { error: `Auth error: ${authError.message}` }, 400);
  }

  const userId = newUser.user!.id;

  // Create profile and roles
  await supabase.from('admin_profiles').upsert({ id: userId, nik, nama }, { onConflict: 'id' });
  await supabase.from('user_roles').upsert({ user_id: userId, role: 'admin' }, { onConflict: 'user_id,role' });
  await supabase.from('user_peran').upsert({ user_id: userId, peran: 'admin', aktif: true }, { onConflict: 'user_id,peran' });

  return json(res, {
    success: true,
    message: 'Akun admin berhasil dibuat',
    data: { nik, nama, email, status: 'created' }
  });
}
