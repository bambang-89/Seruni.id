import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, serviceRoleKey);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // List all users
    const { data: users, error } = await supabase.auth.admin.listUsers();

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check for our admin user
    const adminUser = users?.users.find(
      (u) => u.email === "nik-5203083004880003@admin.seruni.local"
    );

    if (!adminUser) {
      // Create the user
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: "nik-5203083004880003@admin.seruni.local",
        password: "Seruni88",
        email_confirm: true,
        user_metadata: {
          nik: "5203083004880003",
          nama: "Bambang Nurdiansyah"
        },
      });

      if (createError) {
        return new Response(
          JSON.stringify({ error: createError.message }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Link to admin_profiles
      if (newUser.user) {
        await supabase.from("admin_profiles").upsert({
          id: newUser.user.id,
          nik: "5203083004880003",
          nama: "Bambang Nurdiansyah",
        }, { onConflict: "nik" });

        await supabase.from("user_roles").upsert({
          user_id: newUser.user.id,
          role: "admin",
        }, { onConflict: "user_id,role" });

        await supabase.from("user_peran").upsert({
          user_id: newUser.user.id,
          peran: "admin",
          aktif: true,
        }, { onConflict: "user_id,peran" });
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: "Admin berhasil dibuat!",
          user: {
            id: newUser.user!.id,
            email: newUser.user!.email,
            nik: newUser.user!.user_metadata?.nik,
            nama: newUser.user!.user_metadata?.nama,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Admin sudah ada!",
        user: {
          id: adminUser.id,
          email: adminUser.email,
          nik: adminUser.user_metadata?.nik,
          nama: adminUser.user_metadata?.nama,
        },
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
