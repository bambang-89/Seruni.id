import { supabase } from "@/integrations/supabase/client";

interface FonntePayload {
  target: string; // Nomor WhatsApp (bisa dipisah koma)
  message: string;
  url?: string;
  filename?: string;
}

/**
 * Mengirim pesan WhatsApp menggunakan API Fonnte.
 */
export async function sendFonnteMessage(tenantId: string, payload: FonntePayload): Promise<{ success: boolean; error?: string }> {
  try {
    // 1. Ambil token dari site_settings (prioritas) atau tenants (fallback)
    let token: string | null = null;

    const { data: siteData } = await supabase
      .from("site_settings")
      .select("fonnte_token")
      .eq("tenant_id", tenantId)
      .maybeSingle();

    token = siteData?.fonnte_token || null;

    // Fallback ke tenants
    if (!token) {
      const { data: tenantData } = await supabase
        .from("tenants")
        .select("fonnte_token")
        .eq("id", tenantId)
        .maybeSingle();
      token = tenantData?.fonnte_token || null;
    }

    // Fallback ke env variables
    if (!token) {
      token = import.meta.env.VITE_FONNTE_TOKEN;
    }
    
    if (!token) {
      console.warn("Token Fonnte belum dikonfigurasi di database atau environment variables.");
      return { success: false, error: "Token Fonnte belum dikonfigurasi." };
    }

    // 2. Siapkan FormData untuk Fonnte API
    const formData = new FormData();
    formData.append("target", payload.target);
    formData.append("message", payload.message);
    
    if (payload.url) formData.append("url", payload.url);
    if (payload.filename) formData.append("filename", payload.filename);

    // 3. Kirim request ke Fonnte
    const res = await fetch("https://api.fonnte.com/send", {
      method: "POST",
      headers: {
        Authorization: token,
      },
      body: formData,
    });

    const result = await res.json();

    if (result.status) {
      return { success: true };
    } else {
      console.error("Fonnte API Error:", result.reason);
      return { success: false, error: result.reason || "Gagal mengirim pesan via Fonnte." };
    }
  } catch (error: any) {
    console.error("Exception in sendFonnteMessage:", error);
    return { success: false, error: error.message || "Terjadi kesalahan internal." };
  }
}
