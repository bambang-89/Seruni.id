-- Cek semua data yang diperlukan untuk import
SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'penduduk' ORDER BY ordinal_position;
SELECT * FROM tenants LIMIT 3;
SELECT tgname, pg_get_functiondef(tgfunc) FROM pg_trigger t JOIN pg_proc p ON t.tgfoid = p.oid WHERE tgname = 'trg_keluarga_publish_event';
