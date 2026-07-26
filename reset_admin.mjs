import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function run() {
  const nik = "5203083004880003";
  const nama = "Bambang Nurdiansyah";
  const email = `nik-${nik}@admin.seruni.local`;
  const password = "Serunimumbul88"; 

  console.log("Looking for existing user:", email);
  
  const { data: p } = await supabase.from('admin_profiles').select('*').eq('nik', nik);
  if (p && p.length > 0) {
     const id = p[0].id;
     console.log('Cleaning up existing profile id:', id);
     await supabase.from('user_roles').delete().eq('user_id', id);
     await supabase.from('user_peran').delete().eq('user_id', id);
     await supabase.from('admin_profiles').delete().eq('id', id);
     
     await supabase.auth.admin.deleteUser(id);
  }
  
  const { data: users } = await supabase.auth.admin.listUsers();
  const existingUser = users.users.find(u => u.email === email);
  if (existingUser) {
    console.log('User still exists in auth, deleting:', existingUser.id);
    await supabase.auth.admin.deleteUser(existingUser.id);
  }
  
  console.log("Creating new user...");
  const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { nik, nama },
  });

  if (createError) {
    console.error("Create err:", createError);
    return;
  }
  
  const userId = newUser.user.id;

  console.log("Ensuring profile, role, and peran exist for:", userId);

  await supabase.from("admin_profiles").upsert({
    id: userId,
    nik: nik,
    nama: nama,
  }, { onConflict: "nik" });

  await supabase.from("user_roles").upsert({
    user_id: userId,
    role: "admin",
  }, { onConflict: "user_id,role" });

  await supabase.from("user_peran").upsert({
    user_id: userId,
    peran: "admin",
    aktif: true,
  }, { onConflict: "user_id,peran" });

  console.log("Done! User is now full admin.");
}

run();
