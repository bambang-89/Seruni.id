export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export async function voterHash(salt: string, req: Request, extra = ""): Promise<string> {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0].trim() || req.headers.get("cf-connecting-ip") || "0.0.0.0";
  const ua = req.headers.get("user-agent") || "unknown";
  const material = `${salt}::${ip}::${ua}::${extra}`;
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(material));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}