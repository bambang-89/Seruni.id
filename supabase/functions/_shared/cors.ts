// CORS Configuration with Domain Whitelist
// Only these domains are allowed to access edge functions

const ALLOWED_ORIGINS = [
  // Production domains
  "https://seruni-id.vercel.app",
  "https://www.seruni.id",
  "https://seruni.id",
  // Local development
  "http://localhost:3000",
  "http://localhost:5173",
  "http://127.0.0.1:3000",
  // Vercel preview deployments (wildcard pattern handled in handler)
].filter(Boolean);

export const corsHeaders = {
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-requested-with",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Max-Age": "86400",
};

export function getCorsHeaders(origin: string | null): Record<string, string> {
  // In production, validate origin strictly
  const env = Deno.env.get("ENVIRONMENT") || "production";

  if (env === "production") {
    // Strict mode: only allow specific domains
    if (origin && ALLOWED_ORIGINS.includes(origin)) {
      return {
        ...corsHeaders,
        "Access-Control-Allow-Origin": origin,
      };
    }
    // Block if not in whitelist
    return {
      ...corsHeaders,
      "Access-Control-Allow-Origin": "null",
    };
  } else {
    // Development: allow localhost
    return {
      ...corsHeaders,
      "Access-Control-Allow-Origin": origin || "*",
    };
  }
}

export function json(data: unknown, status = 200, origin: string | null = null) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...getCorsHeaders(origin),
      "Content-Type": "application/json",
      "X-Content-Type-Options": "nosniff",
      "X-Frame-Options": "DENY",
      "Cache-Control": "no-store",
    },
  });
}

export function errorJson(message: string, status = 400, origin: string | null = null) {
  return json({ error: message }, status, origin);
}

export async function voterHash(action: string, req: Request, extra = ""): Promise<string> {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() || "unknown";
  const ua = req.headers.get("user-agent") || "unknown";
  const secret = Deno.env.get("VOTER_HASH_SECRET") || "seruni-default-secret-change-me";
  const data = `${action}|${ip}|${ua}|${secret}${extra ? `|${extra}` : ""}`;
  const encoder = new TextEncoder();
  const keyData = encoder.encode(data);
  const hashBuffer = await crypto.subtle.digest("SHA-256", keyData);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
}

// UUID validation
export function isValidUUID(str: string): boolean {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
}

// Rate limit check using event_log
export async function checkRateLimit(
  supabase: any,
  fp: string,
  eventName: string,
  maxRequests: number,
  windowMs: number = 86400000 // 24 hours default
): Promise<{ allowed: boolean; remaining: number }> {
  const since = new Date(Date.now() - windowMs).toISOString();
  const { data, error } = await supabase
    .from("event_log")
    .select("id", { count: "exact" })
    .eq("event_name", eventName)
    .gte("created_at", since)
    .eq("payload->>fp", fp);

  if (error) {
    console.error("Rate limit check error:", error);
    return { allowed: true, remaining: maxRequests };
  }

  const count = data?.length || 0;
  return {
    allowed: count < maxRequests,
    remaining: Math.max(0, maxRequests - count),
  };
}
