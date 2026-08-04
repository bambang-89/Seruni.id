-- Create lacak_surat RPC function for direct Supabase query (bypasses Vercel proxy)
CREATE OR REPLACE FUNCTION public.lacak_surat(_nomor_tiket text)
RETURNS TABLE(
  ditemukan boolean,
  nomor_tiket text,
  nama text,
  nik_masked text,
  kontak text,
  jenis_surat text,
  keperluan text,
  status text,
  status_label text,
  status_color text,
  tanggal_ajuan timestamptz,
  tanggal_update timestamptz,
  surat_terbit_nomor text,
  surat_terbit_status text,
  surat_terbit_qr_url text,
  surat_terbit_tanggal text
)
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
WITH ajuan_cte AS (
  SELECT
    a.nomor_tiket,
    a.nama,
    a.nik,
    a.kontak,
    a.status,
    a.keperluan,
    a.created_at,
    a.updated_at,
    j.nama AS jenis_surat_nama
  FROM public.surat_ajuan a
  LEFT JOIN public.surat_jenis j ON j.id = a.jenis_surat_id
  WHERE lower(trim(a.nomor_tiket)) = lower(trim(_nomor_tiket)))
SELECT
  CASE WHEN (SELECT count(*) FROM ajuan_cte) > 0 THEN true ELSE false END AS ditemukan,
  ajuan_cte.nomor_tiket,
  ajuan_cte.nama,
  CASE WHEN ajuan_cte.nik IS NOT NULL
       THEN substring(ajuan_cte.nik, 1, 6) || '******' || substring(ajuan_cte.nik, length(ajuan_cte.nik)-3, 4)
       ELSE NULL
  END AS nik_masked,
  CASE WHEN ajuan_cte.kontak IS NOT NULL
       THEN '*' || substring(ajuan_cte.kontak, length(ajuan_cte.kontak)-3, 4)
       ELSE NULL
  END AS kontak,
  COALESCE(ajuan_cte.jenis_surat_nama, 'Surat Keterangan') AS jenis_surat,
  ajuan_cte.keperluan,
  ajuan_cte.status,
  CASE ajuan_cte.status
    WHEN 'menunggu'   THEN 'Menunggu Verifikasi'
    WHEN 'diproses'    THEN 'Sedang Diproses'
    WHEN 'diterima'   THEN 'Diterima'
    WHEN 'ditolak'     THEN 'Ditolak'
    WHEN 'dibatalkan'  THEN 'Dibatalkan'
    WHEN 'ditandatangani' THEN 'Ditandatangani'
    ELSE initcap(COALESCE(ajuan_cte.status, 'unknown'))
  END AS status_label,
  CASE ajuan_cte.status
    WHEN 'menunggu'      THEN 'yellow'
    WHEN 'diproses'       THEN 'blue'
    WHEN 'diterima'      THEN 'green'
    WHEN 'ditolak'       THEN 'red'
    WHEN 'dibatalkan'    THEN 'gray'
    WHEN 'ditandatangani' THEN 'green'
    ELSE 'gray'
  END AS status_color,
  ajuan_cte.created_at AS tanggal_ajuan,
  ajuan_cte.updated_at AS tanggal_update,
  t.nomor_surat AS surat_terbit_nomor,
  t.status AS surat_terbit_status,
  t.qr_code_url AS surat_terbit_qr_url,
  t.tanggal_terbit AS surat_terbit_tanggal
FROM ajuan_cte
LEFT JOIN public.surat_terbit t ON
  t.pemohon_nik = ajuan_cte.nik
  AND t.jenis_nama = ajuan_cte.jenis_surat_nama
ORDER BY t.created_at DESC NULLS LAST
LIMIT 1;
$$;
