# Deployment Guide — Seruni.id

## Prerequisites

1. **Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Deno** (for edge functions)
   ```bash
   # Windows (PowerShell)
   iwr https://deno.land/install.ps1 -gs | iex

   # or
   choco install deno
   ```

3. **Login to Supabase**
   ```bash
   supabase login
   ```

## Step 1: Link Project

```bash
cd E:/Seruni.id
supabase link --project-ref smngqdpbmgcdbmkiuviq
```

## Step 2: Push Migrations

### Option A: Using Supabase CLI
```bash
supabase migration push
```

### Option B: Manual via Dashboard
1. Buka https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/migrations
2. Copy-paste content dari file migration:
   - `20260720000000_005_domain_event_triggers.sql`
   - `20260720000001_006_idm_engine_core.sql`
   - `20260720000002_007_cms_draft_workflow.sql`
   - `20260720000003_008_append_only_audit_trail.sql`
   - `20260720000004_009_wa_chatbot_tables.sql`

## Step 3: Deploy Edge Functions

### Deploy All
```bash
supabase functions deploy
```

### Deploy Specific Functions
```bash
supabase functions deploy event-processor
supabase functions deploy idm-scorer
supabase functions deploy wa-chatbot
```

### Set Environment Variables
Di Supabase Dashboard → Settings → Edge Functions → Secrets:

| Secret | Value | Description |
|--------|-------|-------------|
| `FONNTE_TOKEN` | `your-token` | Fonnte API token for WA |
| `EVENT_PROCESSOR_KEY` | `auto-generated` | For pg_cron authentication |

## Step 4: Configure Fonnte Webhook

1. Buka https://fonnte.com/dashboard
2. Setting → Webhook
3. URL: `https://smngqdpbmgcdbmkiuviq.supabase.co/functions/v1/wa-chatbot`
4. Enable webhook

## Migration Order

Run in this order:

1. **005_domain_event_triggers.sql**
   - Creates 15 trigger functions
   - Updates `publish_event()` function
   - ⚠️ No data loss

2. **006_idm_engine_core.sql**
   - Creates IDM tables (idm_indicators, idm_skor_cache, dll.)
   - Seeds 30 indicators across 6 dimensions
   - ⚠️ No data loss

3. **007_cms_draft_workflow.sql**
   - Adds tenant_id to site_draft
   - Creates workflow functions
   - ⚠️ No data loss

4. **008_append_only_audit_trail.sql**
   - Creates audit tables
   - Adds append-only triggers
   - ⚠️ READ CAREFULLY:
     - Updates/DELETEs on voting_suara will be BLOCKED
     - Updates on published surat will be BLOCKED
     - Updates on closed voting will be BLOCKED

5. **009_wa_chatbot_tables.sql**
   - Creates chatbot session tables
   - ⚠️ No data loss

## Verification

### Check Triggers
```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;
```

### Check Edge Functions
```bash
curl https://smngqdpbmgcdbmkiuviq.supabase.co/functions/v1/event-processor \
  -H "Authorization: Bearer <your-anon-key>"
```

### Check IDM Indicators
```sql
SELECT dimensi_nama, COUNT(*) as count
FROM idm_indicators
GROUP BY dimensi_nama;
```

## Rollback

### Migration Rollback
```bash
# Revert last migration
supabase migration revert

# Or manually delete in reverse order:
# 1. DROP TRIGGER IF EXISTS ... ON ...
# 2. DROP FUNCTION IF EXISTS ...
# 3. DROP TABLE IF EXISTS ...
```

### Emergency: Disable Append-Only
```sql
-- Disable audit triggers temporarily
DROP TRIGGER IF EXISTS enforce_append_only_surat ON surat_terbit;
DROP TRIGGER IF EXISTS enforce_append_only_voting_suara ON voting_suara;
DROP TRIGGER IF EXISTS enforce_append_only_voting_topik ON voting_topik;
```

## New Admin Pages

After deployment, new admin routes available:

| Route | Description |
|-------|-------------|
| `/admin/site/draft-queue` | CMS Draft Queue Workflow |
| `/admin/site/version-history` | Version History & Restore |

## Troubleshooting

### "Function already exists" error
```sql
DROP FUNCTION IF EXISTS publish_event(...);
-- Then re-run migration
```

### "Trigger already exists" error
```sql
DROP TRIGGER IF EXISTS trigger_name ON table_name;
-- Then re-run migration
```

### Edge function 500 error
Check function logs:
```bash
supabase functions logs event-processor
```

### WA Chatbot not responding
1. Verify Fonnte webhook URL
2. Check `wa_chatbot_session` table has data
3. Verify `FONNTE_TOKEN` secret is set
