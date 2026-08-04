import ws from "ws";
import { createClient } from "@supabase/supabase-js";

const PROJECT_ID = "smngqdpbmgcdbmkiuviq";
const SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ";

// Try Supabase Management API first
const SQL = `
ALTER TABLE public.penduduk
  ADD COLUMN IF NOT EXISTS dusun_id UUID REFERENCES public.ref_dusun(id) ON DELETE SET NULL;

ALTER TABLE public.keluarga
  ADD COLUMN IF NOT EXISTS kepala_penduduk_id UUID REFERENCES public.penduduk(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_penduduk_dusun_id  ON public.penduduk(dusun_id);
CREATE INDEX IF NOT EXISTS idx_keluarga_kepala_id ON public.keluarga(kepala_penduduk_id);

UPDATE public.penduduk p
SET dusun_id = rd.id
FROM public.ref_dusun rd
WHERE lower(p.dusun) = lower(rd.nama)
  AND p.dusun_id IS NULL;
`;

console.log("Applying migration via Management API...");
const res = await fetch(`https://api.supabase.com/v1/projects/${PROJECT_ID}/database/query`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${SERVICE_KEY}`
  },
  body: JSON.stringify({ query: SQL })
});
const data = await res.json();
console.log("Status:", res.status);
console.log("Response:", JSON.stringify(data).slice(0, 500));

if (res.status !== 200) {
  // Fallback: try via pg REST exec
  console.log("\nFallback: trying via Supabase RPC...");
  const sb = createClient(`https://${PROJECT_ID}.supabase.co`, SERVICE_KEY, { realtime: { transport: ws } });
  
  // Split and run each statement
  const statements = SQL.split(";").map(s => s.trim()).filter(s => s.length > 10);
  for (const stmt of statements) {
    console.log("Running:", stmt.slice(0, 60) + "...");
    const { data: d, error } = await sb.rpc("exec_sql", { sql: stmt }).catch(() => ({ error: "rpc not available" }));
    if (error) console.log("  Error:", typeof error === "string" ? error : JSON.stringify(error).slice(0, 100));
    else console.log("  OK");
  }
}
