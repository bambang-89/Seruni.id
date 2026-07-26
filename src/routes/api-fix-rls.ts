// API route to apply RLS fix — one-time use, then delete
import type { APIRoute } from 'vite'
import { createClient } from '@supabase/supabase-js'

export const POST: APIRoute = async ({ request }) => {
  const auth = request.headers.get('Authorization')
  if (auth !== 'Bearer apply-rls-fix-now') {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  const supabase = createClient(
    process.env.VITE_SUPABASE_URL || '',
    process.env.SUPABASE_SERVICE_ROLE_KEY || ''
  )

  const stmts = [
    `DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON public.surat_jenis`,
    `DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis`,
    `DROP POLICY IF EXISTS "surat_jenis_select" ON public.surat_jenis`,
    `CREATE POLICY "surat_jenis_public_read" ON public.surat_jenis FOR SELECT TO anon, authenticated USING (aktif = true)`,
    `GRANT SELECT ON public.surat_jenis TO anon`,
    `GRANT SELECT ON public.surat_jenis TO authenticated`,
    `DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON public.surat_jenis`,
    `DROP POLICY IF EXISTS "surat_jenis_admin_write" ON public.surat_jenis`,
    `CREATE POLICY "surat_jenis_admin_write" ON public.surat_jenis FOR ALL TO authenticated USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id())`,
    `DROP POLICY IF EXISTS "surat_jenis_dna_public_read" ON public.surat_jenis_dna`,
    `DROP POLICY IF EXISTS "surat_jenis_dna_select" ON public.surat_jenis_dna`,
    `CREATE POLICY "surat_jenis_dna_public_read" ON public.surat_jenis_dna FOR SELECT TO anon, authenticated USING (true)`,
    `GRANT SELECT ON public.surat_jenis_dna TO anon`,
    `GRANT SELECT ON public.surat_jenis_dna TO authenticated`,
    `DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna`,
    `CREATE POLICY "surat_jenis_dna_admin_write" ON public.surat_jenis_dna FOR ALL TO authenticated USING (tenant_id = get_tenant_id()) WITH CHECK (tenant_id = get_tenant_id())`,
  ]

  const results = []
  for (const sql of stmts) {
    const { error } = await supabase.rpc('exec', { sql_text: sql }).catch(() => ({ error: { message: 'RPC not available, trying direct' } }))
    if (error) {
      // Try direct query
      const { error: err2 } = await (supabase as any).from('*').select('*').limit(0).catch(() => ({ error: null }))
      results.push({ sql: sql.substring(0, 60), status: 'skipped', note: 'RPC unavailable' })
    } else {
      results.push({ sql: sql.substring(0, 60), status: 'ok' })
    }
  }

  return new Response(JSON.stringify({ 
    message: 'RLS fix API — use Supabase SQL Editor instead. SQL:', 
    stmts 
  }), { headers: { 'Content-Type': 'application/json' } })
}
