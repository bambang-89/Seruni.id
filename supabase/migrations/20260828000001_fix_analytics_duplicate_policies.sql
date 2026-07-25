-- ============================================================
-- FIX: Analytics Schema Duplicate Policy Error
-- The original migration uses CREATE POLICY without DROP POLICY IF EXISTS,
-- causing errors on re-run. This makes the policies idempotent.
-- ============================================================

-- Drop existing analytics_events policies before re-creating
DROP POLICY IF EXISTS "Anyone can insert analytics" ON public.analytics_events;
DROP POLICY IF EXISTS "Only admin can read analytics" ON public.analytics_events;

-- Re-create analytics_events policies
CREATE POLICY "Anyone can insert analytics" ON public.analytics_events
    FOR INSERT TO anon, authenticated WITH CHECK (true);

CREATE POLICY "Only admin can read analytics" ON public.analytics_events
    FOR SELECT TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

GRANT SELECT ON public.analytics_events TO authenticated;

-- Also add RLS and policies for analytics_sessions
ALTER TABLE public.analytics_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can insert analytics_sessions" ON public.analytics_sessions;
CREATE POLICY "Anyone can insert analytics_sessions" ON public.analytics_sessions
    FOR INSERT TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Only admin can read analytics_sessions" ON public.analytics_sessions;
CREATE POLICY "Only admin can read analytics_sessions" ON public.analytics_sessions
    FOR SELECT TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

GRANT SELECT ON public.analytics_sessions TO authenticated;
GRANT INSERT ON public.analytics_sessions TO anon, authenticated;
