Deno.serve(async (req: Request) => {
  const { version } = await req.json()

  const host = Deno.env.get('POSTGRES_HOST') || 'db.smngqdpbmgcdbmkiuviq.supabase.co'
  const port = parseInt(Deno.env.get('POSTGRES_PORT') || '5432')
  const dbname = Deno.env.get('POSTGRES_DB') || 'postgres'
  const user = 'postgres'
  const password = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

  // Use postgres.js - much lighter than pg
  const postgres = await import('https://deno.land/x/postgres@v0.19.3/mod.js')
  const client = await postgres.connect({
    hostname: host,
    port,
    username: user,
    password,
    database: dbname,
    tls: { enabled: true },
  })

  try {
    await client.queryObject(
      'INSERT INTO supabase_migrations.schema_migrations (version) VALUES ($1) ON CONFLICT (version) DO NOTHING',
      [version]
    )
    return Response.json({ success: true, version })
  } finally {
    await client.end()
  }
})
