import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function run() {
  const nik = "9999999999999999";
  const nama = "Test Admin";
  const email = `nik-${nik}@admin.seruni.local`;
  const password = "Serunimumbul88"; 

  console.log("Creating new user:", email);
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
  
  console.log("Created successfully", newUser);
}
run();
