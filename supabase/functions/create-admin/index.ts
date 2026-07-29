import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  let body: { nik?: string; nama?: string; password?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  const { nik, nama, password } = body;

  if (!nik || !nama || !password) {
    return json({ error: "nik, nama, dan password diperlukan" }, 400);
  }

  if (!/^\d{6,20}$/.test(nik)) {
    return json({ error: "NIK harus 6-20 digit angka" }, 400);
  }

  if (password.length < 8) {
    return json({ error: "Password minimal 8 karakter" }, 400);
  }

  const email = `nik-${nik.trim()}@admin.seruni.local`;

  // Cek apakah profile sudah ada
  const { data: existingProfile } = await supabase
    .from("admin_profiles")
    .select("id, nik, nama")
    .eq("nik", nik)
    .maybeSingle();

  if (existingProfile) {
    // Admin sudah ada
    return json({
      success: true,
      message: "Akun admin sudah ada",
      data: { nik: existingProfile.nik, nama: existingProfile.nama, status: "existing" }
    });
  }

  // Buat user auth baru
  const { data: newUser, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { nik, nama },
  });

  if (authError) {
    return json({ error: `Auth error: ${authError.message}` }, 400);
  }

  const userId = newUser.user!.id;

  // Buat admin_profiles
  await supabase.from("admin_profiles").upsert({
    id: userId,
    nik,
    nama,
  }, { onConflict: "id" });

  // Buat user_roles
  await supabase.from("user_roles").upsert({
    user_id: userId,
    role: "admin",
  }, { onConflict: "user_id,role" });

  // Buat user_peran
  await supabase.from("user_peran").upsert({
    user_id: userId,
    peran: "admin",
    aktif: true,
  }, { onConflict: "user_id,peran" });

  return json({
    success: true,
    message: "Akun admin berhasil dibuat",
    data: { nik, nama, email, status: "created" }
  });
});
