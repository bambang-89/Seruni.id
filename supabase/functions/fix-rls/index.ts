import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const handler = async (req: Request): Promise<Response> => {
  const url = new URL(req.url)
  const secret = url.searchParams.get('secret')
  
  if (secret !== Deno.env.get('ADMIN_SECRET')) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { 
      status: 401, headers: { 'Content-Type': 'application/json' } 
    })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const sql = `
    DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON public.surat_jenis;
    DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
    DROP POLICY IF EXISTS "surat_jenis_select" ON public.surat_jenis;
    CREATE POLICY "surat_jenis_public_read" ON public.surat_jenis FOR SELECT TO anon, authenticated USING (aktif = true);
    GRANT SELECT ON public.surat_jenis TO anon;
    GRANT SELECT ON public.surat_jenis TO authenticated;
    DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON public.surat_jenis;
    DROP POLICY IF EXISTS "surat_jenis_admin_write" ON public.surat_jenis;
    CREATE POLICY "surat_jenis_admin_write" ON public.surat_jenis FOR ALL TO authenticated USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id());
    DROP POLICY IF EXISTS "surat_jenis_dna_public_read" ON public.surat_jenis_dna;
    DROP POLICY IF EXISTS "surat_jenis_dna_select" ON public.surat_jenis_dna;
    CREATE POLICY "surat_jenis_dna_public_read" ON public.surat_jenis_dna FOR SELECT TO anon, authenticated USING (true);
    GRANT SELECT ON public.surat_jenis_dna TO anon;
    GRANT SELECT ON public.surat_jenis_dna TO authenticated;
    DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna;
    CREATE POLICY "surat_jenas_dna_admin_write" ON public.surat_jenis_dna FOR ALL TO authenticated USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id());
  `

  const statements = sql.split(';').filter(s => s.trim())
  const results = []
  
  for (const stmt of statements) {
    if (!stmt.trim()) continue
    const { error } = await supabase.rpc('exec', { query: stmt.trim() }).single()
    results.push({ stmt: stmt.trim().substring(0, 50), error: error?.message || 'OK' })
  }

  return new Response(JSON.stringify({ results }), {
    headers: { 'Content-Type': 'application/json' }
  })
}

Deno.serve(handler)
