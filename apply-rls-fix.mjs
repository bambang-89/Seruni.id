// Apply RLS fix using pg package
import pg from 'pg';
const { Client } = pg;

const RLS_SQL = `
-- ============================================================
-- Fix RLS: surat_jenis public read
-- ============================================================
DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_public_read" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_select" ON public.surat_jenis;

CREATE POLICY "surat_jenis_public_read"
  ON public.surat_jenis
  FOR SELECT TO anon, authenticated
  USING (aktif = true);

GRANT SELECT ON public.surat_jenis TO anon;
GRANT SELECT ON public.surat_jenis TO authenticated;

-- Admin write: tenant isolation
DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON public.surat_jenis;
DROP POLICY IF EXISTS "surat_jenis_admin_write" ON public.surat_jenis;

CREATE POLICY "surat_jenis_admin_write"
  ON public.surat_jenis
  FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id())
  WITH CHECK (tenant_id = get_tenant_id());

-- ============================================================
-- Fix RLS: surat_jenis_dna public read
-- ============================================================
DROP POLICY IF EXISTS "surat_jenis_dna_public_read" ON public.surat_jenis_dna;
DROP POLICY IF EXISTS "surat_jenis_dna_select" ON public.surat_jenis_dna;

CREATE POLICY "surat_jenis_dna_public_read"
  ON public.surat_jenis_dna
  FOR SELECT TO anon, authenticated USING (true);

GRANT SELECT ON public.surat_jenis_dna TO anon;
GRANT SELECT ON public.surat_jenis_dna TO authenticated;

DROP POLICY IF EXISTS "surat_jenis_dna_admin_write" ON public.surat_jenis_dna;

CREATE POLICY "surat_jenis_dna_admin_write"
  ON public.surat_jenis_dna
  FOR ALL TO authenticated
  USING (tenant_id = get_tenant_id())
  WITH CHECK (tenant_id = get_tenant_id());
`;

async function main() {
  console.log('Connecting to Supabase PostgreSQL...');

  const client = new Client({
    host: 'db.smngqdpbmgcdbmkiuviq.supabase.co',
    port: 5432,
    database: 'postgres',
    user: 'postgres',
    password: 'Serunimumbul-88',
    ssl: { rejectUnauthorized: false },
    timeout: 15000,
    family: 6, // Force IPv6
  });

  try {
    await client.connect();
    console.log('Connected!');

    // Execute each statement
    const statements = RLS_SQL.split(';').filter(s => s.trim() && !s.trim().startsWith('--'));

    for (const stmt of statements) {
      const sql = stmt.trim();
      if (!sql) continue;
      try {
        await client.query(sql);
        console.log('OK:', sql.substring(0, 80));
      } catch (err) {
        console.error('ERR:', sql.substring(0, 80), '->', err.message);
      }
    }

    // Verify
    const { rows } = await client.query(`
      SELECT policyname, cmd, roles, qual::text
      FROM pg_policy
      WHERE polrelid = 'surat_jenis'::regclass
    `);
    console.log('\n=== surat_jenis policies after fix ===');
    rows.forEach(r => console.log(`  ${r.cmd} ${r.roles} -> ${r.policyname}`));

    await client.end();
    console.log('\nDone!');
  } catch (err) {
    console.error('Connection failed:', err.message);
    await client.end().catch(() => {});
  }
}

main();
