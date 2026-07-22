import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, serviceRoleKey);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    const { nik, nama, password } = await req.json();

    if (!nik || !nama || !password) {
      return new Response(
        JSON.stringify({ error: "nik, nama, dan password diperlukan" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Cek apakah NIK sudah ada
    const { data: existingProfile } = await supabase
      .from("admin_profiles")
      .select("id, nik, nama")
      .eq("nik", nik)
      .single();

    let userId: string;

    if (existingProfile) {
      // Admin sudah ada, cek apakah user auth juga ada
      const { data: authUsers } = await supabase.auth.admin.listUsers();
      const existingUser = authUsers?.users.find(
        (u) => u.id === existingProfile.id
      );

      if (existingUser) {
        return new Response(
          JSON.stringify({
            success: true,
            message: "Akun admin sudah ada",
            data: {
              nik: nik,
              nama: existingProfile.nama,
              status: "existing"
            }
          }),
          { status: 200, headers: { "Content-Type": "application/json" } }
        );
      } else {
        // Profile ada tapi auth user hilang, buat user baru
        const { data: newUser, error: authError } = await supabase.auth.admin.createUser({
          email: `nik-${nik}@admin.seruni.local`,
          password: password,
          email_confirm: true,
          user_metadata: { nik, nama },
        });

        if (authError) {
          return new Response(
            JSON.stringify({ error: authError.message }),
            { status: 400, headers: { "Content-Type": "application/json" } }
          );
        }

        userId = newUser.user!.id;
      }
    } else {
      // Admin belum ada, buat baru
      // 1. Buat user di auth.users
      const { data: newUser, error: authError } = await supabase.auth.admin.createUser({
        email: `nik-${nik}@admin.seruni.local`,
        password: password,
        email_confirm: true,
        user_metadata: { nik, nama },
      });

      if (authError) {
        return new Response(
          JSON.stringify({ error: authError.message }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      userId = newUser.user!.id;

      // 2. Buat admin_profiles
      const { error: profileError } = await supabase
        .from("admin_profiles")
        .insert({
          id: userId,
          nik: nik,
          nama: nama,
        });

      if (profileError) {
        console.error("Profile error:", profileError);
      }

      // 3. Buat user_roles
      await supabase.from("user_roles").insert({
        user_id: userId,
        role: "admin",
      });

      // 4. Buat user_peran
      await supabase.from("user_peran").insert({
        user_id: userId,
        peran: "admin",
        aktif: true,
      });
    }

    // Return sukses TANPA email
    return new Response(
      JSON.stringify({
        success: true,
        message: "Akun admin berhasil dibuat",
        data: {
          nik: nik,
          nama: nama,
          status: existingProfile ? "existing" : "created"
        }
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
