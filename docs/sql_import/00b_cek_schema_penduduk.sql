-- Cek schema penduduk dan tenants
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'penduduk'
ORDER BY ordinal_position;

-- Cek tenants
SELECT * FROM tenants LIMIT 3;

-- Cek apakah trigger keluarga masih bermasalah
SELECT tgname, tgrelid::regclass FROM pg_trigger WHERE tgname LIKE '%keluarga%';
