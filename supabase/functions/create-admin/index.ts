import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { json as sharedJson, getCorsHeaders } from "../_shared/cors.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

function json(data: unknown, status = 200, origin: string | null = null) {
  return sharedJson(data, status, origin);
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: getCorsHeaders(origin) });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405, origin);
  }

  let body: { nik?: string; nama?: string; password?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400, origin);
  }

  const { nik, nama, password } = body;

  if (!nik || !nama || !password) {
    return json({ error: "nik, nama, dan password diperlukan" }, 400, origin);
  }

  if (!/^\d{6,20}$/.test(nik)) {
    return json({ error: "NIK harus 6-20 digit angka" }, 400, origin);
  }

  if (password.length < 8) {
    return json({ error: "Password minimal 8 karakter" }, 400, origin);
  }

  const email = `nik-${nik.trim()}@admin.seruni.local`;

  const { data: existingProfile } = await supabase
    .from("admin_profiles")
    .select("id, nik, nama")
    .eq("nik", nik)
    .maybeSingle();

  if (existingProfile) {
    return json({
      success: true,
      message: "Akun admin sudah ada",
      data: { nik: existingProfile.nik, nama: existingProfile.nama, status: "existing" }
    }, 200, origin);
  }

  const { data: newUser, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { nik, nama },
  });

  if (authError) {
    return json({ error: `Auth error: ${authError.message}` }, 400, origin);
  }

  const userId = newUser.user!.id;

  await supabase.from("admin_profiles").upsert({
    id: userId,
    nik,
    nama,
  }, { onConflict: "id" });

  await supabase.from("user_roles").upsert({
    user_id: userId,
    role: "admin",
  }, { onConflict: "user_id,role" });

  await supabase.from("user_peran").upsert({
    user_id: userId,
    peran: "admin",
    aktif: true,
  }, { onConflict: "user_id,peran" });

  return json({
    success: true,
    message: "Akun admin berhasil dibuat",
    data: { nik, nama, email, status: "created" }
  }, 200, origin);
});