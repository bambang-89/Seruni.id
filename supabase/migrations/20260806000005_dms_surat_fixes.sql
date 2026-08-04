-- =========================================================================================
-- MIGRATION: Fix DMS (Document Management System) for Surat
-- Tanggal: 2026-08-06
-- Tujuan:  - Mencegah hard delete pada tabel surat_ajuan dan surat_terbit
--          - Menambahkan status 'dibatalkan' pada surat_ajuan
--          - Menambahkan status 'dicabut' pada surat_terbit
-- =========================================================================================

BEGIN;

-- 1. Tambah status 'dibatalkan' ke surat_ajuan (update constraint)
ALTER TABLE public.surat_ajuan 
  DROP CONSTRAINT IF EXISTS surat_ajuan_status_check;

ALTER TABLE public.surat_ajuan
  ADD CONSTRAINT surat_ajuan_status_check 
  CHECK (status IN (
    'menunggu',       
    'diproses',       
    'diverifikasi',   
    'ditandatangani', 
    'selesai',        
    'ditolak',
    'dibatalkan'      -- <-- STATUS BARU: Dibatalkan admin sebelum diterbitkan
  ));


-- 2. Tambah status 'dicabut' ke surat_terbit (jika ada check constraint)
-- Catatan: jika tidak ada constraint, maka langsung bisa diupdate.
-- Biasanya surat_terbit status: 'berlaku', 'kadaluarsa', 'dicabut'
ALTER TABLE public.surat_terbit
  DROP CONSTRAINT IF EXISTS surat_terbit_status_check;

ALTER TABLE public.surat_terbit
  ADD CONSTRAINT surat_terbit_status_check
  CHECK (status IN (
    'berlaku', 
    'kadaluarsa', 
    'dicabut'         -- <-- STATUS BARU: Dicabut setelah diterbitkan
  ));


-- 3. Trigger Function untuk mencegah Hard Delete
CREATE OR REPLACE FUNCTION public.prevent_hard_delete_fn()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Hard delete is not allowed for this table (%). Use soft delete by updating the status instead.', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

-- 4. Apply Trigger ke surat_ajuan
DROP TRIGGER IF EXISTS prevent_hard_delete_surat_ajuan ON public.surat_ajuan;
CREATE TRIGGER prevent_hard_delete_surat_ajuan
BEFORE DELETE ON public.surat_ajuan
FOR EACH ROW
EXECUTE FUNCTION public.prevent_hard_delete_fn();

-- 5. Apply Trigger ke surat_terbit
DROP TRIGGER IF EXISTS prevent_hard_delete_surat_terbit ON public.surat_terbit;
CREATE TRIGGER prevent_hard_delete_surat_terbit
BEFORE DELETE ON public.surat_terbit
FOR EACH ROW
EXECUTE FUNCTION public.prevent_hard_delete_fn();

-- 6. Update lacak_surat RPC to return specific info if dicabut
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
    WHEN 'diverifikasi' THEN 'Diverifikasi'
    WHEN 'diterima'   THEN 'Diterima'
    WHEN 'ditolak'     THEN 'Ditolak'
    WHEN 'dibatalkan'  THEN 'Dibatalkan'
    WHEN 'ditandatangani' THEN 'Ditandatangani'
    ELSE initcap(COALESCE(ajuan_cte.status, 'unknown'))
  END AS status_label,
  CASE ajuan_cte.status
    WHEN 'menunggu'      THEN 'yellow'
    WHEN 'diproses'       THEN 'blue'
    WHEN 'diverifikasi'   THEN 'blue'
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


COMMIT;
