// Edge function to mark old migrations as applied
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? 'https://smngqdpbmgcdbmkiuviq.supabase.co'
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

Deno.serve(async (req) => {
  const { migrations } = await req.json()

  const results = []
  for (const migration of migrations) {
    const { error } = await supabase
      .from('supabase_migrations.schema_migrations')
      .upsert({ version: migration, name: migration + '.sql' }, { onConflict: 'version' })

    results.push({ migration, status: error ? 'error' : 'ok', error: error?.message })
  }

  return Response.json({ results })
})
