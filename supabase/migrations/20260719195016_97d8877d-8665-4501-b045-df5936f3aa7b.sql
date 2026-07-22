
-- 1) Restrict pbb_tagihan: drop public read, add admin-only read (cek_pbb RPC still works via SECURITY DEFINER)
DROP POLICY IF EXISTS pbb_public_read ON public.pbb_tagihan;

-- 2) Drop public read on vote/suara tables (aggregates live on parent tables)
DROP POLICY IF EXISTS "publik lihat vote usulan" ON public.usulan_vote;
DROP POLICY IF EXISTS "publik lihat suara agregat" ON public.voting_suara;

-- 3) Revoke EXECUTE on SECURITY DEFINER trigger + admin-only functions from anon/authenticated/PUBLIC.
-- Keep public RPCs (has_role used by RLS, lacak_aduan, verifikasi_surat, cek_pbb) executable.
DO $$
DECLARE fn TEXT;
BEGIN
  FOREACH fn IN ARRAY ARRAY[
    'handle_new_admin_signup()',
    'set_updated_at()',
    'log_status_change()',
    'sync_usulan_vote_count()',
    'sync_voting_count()',
    'auto_close_expired_voting()',
    'snapshot_site_config()',
    'rollback_site_draft(uuid)',
    'restore_site_version(uuid)',
    'log_admin_activity()',
    'publish_site_draft(uuid)',
    'tutup_voting_manual(uuid, text)'
  ] LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION public.%s FROM PUBLIC, anon, authenticated;', fn);
    EXECUTE format('GRANT EXECUTE ON FUNCTION public.%s TO service_role;', fn);
  END LOOP;
END $$;
