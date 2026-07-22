#!/bin/bash
# Deploy script untuk Supabase migrations dan edge functions
# Usage: ./scripts/deploy.sh

set -e

PROJECT_REF="smngqdpbmgcdbmkiuviq"  # Replace with your project ref
SUPABASE_URL="https://$PROJECT_REF.supabase.co"

echo "=== Seruni.id Deployment Script ==="
echo "Project: $PROJECT_REF"
echo ""

# Check for Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo "⚠️ Supabase CLI not found"
    echo "   Install: npm install -g supabase"
    echo "   Or use: npx supabase"
    SUPABASE_CMD="npx supabase"
else
    SUPABASE_CMD="supabase"
fi

# Check for Deno
if ! command -v deno &> /dev/null; then
    echo "⚠️ Deno not found"
    echo "   Install: https://deno.land/#installation"
    exit 1
fi

echo "1. Pushing migrations..."
# Push migrations to remote
# $SUPABASE_CMD migration push 2>/dev/null || \
echo "   Run manually: supabase migration push"
echo ""

echo "2. Listing pending migrations..."
$SUPABASE_CMD migration list 2>/dev/null || echo "   (manual check required)"
echo ""

echo "3. Checking edge functions..."
echo "   Edge functions to deploy:"
echo "   - event-processor"
echo "   - idm-scorer"
echo "   - wa-chatbot"
echo ""

echo "4. Deploy edge functions manually:"
echo ""
echo "   # Install Supabase CLI first"
echo "   npm install -g supabase"
echo ""
echo "   # Login"
echo "   supabase login"
echo ""
echo "   # Link project"
echo "   supabase link --project-ref $PROJECT_REF"
echo ""
echo "   # Deploy all functions"
echo "   supabase functions deploy"
echo ""
echo "   # Or deploy specific function"
echo "   supabase functions deploy event-processor"
echo "   supabase functions deploy idm-scorer"
echo "   supabase functions deploy wa-chatbot"
echo ""

echo "5. Environment variables needed:"
echo "   FONNTE_TOKEN=<your-fonnte-token>"
echo "   SUPABASE_URL=$SUPABASE_URL"
echo "   Set these in Supabase dashboard: Settings > Edge Functions"
echo ""

echo "=== Deployment Instructions ==="
echo ""
echo "To deploy:"
echo "1. Install Supabase CLI: npm install -g supabase"
echo "2. supabase login"
echo "3. supabase link --project-ref $PROJECT_REF"
echo "4. supabase migration push"
echo "5. supabase functions deploy"
echo ""
echo "Or use Supabase Dashboard:"
echo "https://supabase.com/dashboard/project/$PROJECT_REF/migrations"
echo ""
