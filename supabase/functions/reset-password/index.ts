import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, serviceRoleKey);

import { getCorsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  // Handle CORS preflight
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: getCorsHeaders(origin) });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
    );
  }

  try {
    const { nik, password } = await req.json();

    if (!nik || !password) {
      return new Response(
        JSON.stringify({ error: "nik dan password diperlukan" }),
        { status: 400, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
      );
    }

    // Find user by metadata nik
    const { data: authUsers } = await supabase.auth.admin.listUsers();
    const user = authUsers?.users.find(
      (u) => u.user_metadata?.nik === nik || u.email === `nik-${nik}@admin.seruni.local`
    );

    if (!user) {
      return new Response(
        JSON.stringify({
          error: "User tidak ditemukan",
          hint: "Buat user dulu via Supabase Dashboard"
        }),
        { status: 404, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
      );
    }

    // Update password
    const { data, error } = await supabase.auth.admin.updateUserById(
      user.id,
      { password: password }
    );

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Password berhasil di-reset",
        data: {
          nik: nik,
          user_id: user.id,
          email: user.email
        }
      }),
      { status: 200, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...getCorsHeaders(origin), "Content-Type": "application/json" } }
    );
  }
});
