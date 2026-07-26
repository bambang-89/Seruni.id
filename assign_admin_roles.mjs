import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function run() {
  const nik = "5203083004880003";
  const nama = "Bambang Nurdiansyah";
  const email = `nik-${nik}@admin.seruni.local`;

  // We find the user by paging, or just try to get it
  // Since listUsers might be paginated, let's use listUsers but check all pages if needed,
  // or we can just fetch the id by signing in! No, we can query auth.users if we have the SQL access, but we don't.
  
  // Wait, let's just get the user id by calling listUsers (hopefully it's recent so it shows up on page 1)
  const { data: users, error: listErr } = await supabase.auth.admin.listUsers({ perPage: 1000 });
  
  const existingUser = users.users.find(u => u.email === email);
  if (!existingUser) {
     console.log("Could not find user in list.");
     return;
  }
  
  const userId = existingUser.id;

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
