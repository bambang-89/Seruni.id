
REVOKE EXECUTE ON FUNCTION public.snapshot_site_config() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.restore_site_version(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.publish_site_draft(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.rollback_site_draft(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.restore_site_version(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.publish_site_draft(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.rollback_site_draft(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.tutup_voting_manual(UUID, TEXT) TO authenticated;
