-- ============================================================
-- MIGRASI: 20260728000001_find_penduduk_by_nik.sql
-- Tanggal: 2026-07-28
-- Deskripsi: RPC function untuk lookup NIK tanpa RLS filter
--            Digunakan oleh form publik (Surat Ajuan, Suplesi)
--            SECURITY DEFINER agar bypass tenant isolation RLS
-- ============================================================

DROP FUNCTION IF EXISTS public.find_penduduk_by_nik(TEXT);

CREATE OR REPLACE FUNCTION public.find_penduduk_by_nik(p_nik TEXT)
RETURNS TABLE (
  id UUID,
  nik TEXT,
  nama TEXT,
  tempat_lahir TEXT,
  tanggal_lahir DATE,
  jenis_kelamin TEXT,
  agama TEXT,
  pendidikan TEXT,
  pekerjaan TEXT,
  status_kawin TEXT,
  hubungan_kk TEXT,
  warga_negara_id UUID,
  dusun TEXT,
  alamat TEXT,
  rt VARCHAR(3),
  rw VARCHAR(3),
  kecamatan TEXT,
  kabupaten TEXT,
  provinsi TEXT,
  nomor_hp TEXT,
  status_hidup TEXT,
  keluarga_id UUID,
  no_kk TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.nik,
    p.nama,
    p.tempat_lahir,
    p.tanggal_lahir,
    p.jenis_kelamin,
    p.agama,
    p.pendidikan,
    p.pekerjaan,
    p.status_kawin,
    p.hubungan_kk,
    p.warga_negara_id,
    p.dusun,
    p.alamat,
    p.rt,
    p.rw,
    p.kecamatan,
    p.kabupaten,
    p.provinsi,
    p.nomor_hp,
    p.status_hidup,
    p.keluarga_id,
    k.no_kk
  FROM public.penduduk p
  LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
  WHERE p.nik = p_nik
  LIMIT 1;
END;
$$;

-- Allow all roles to execute this function
GRANT EXECUTE ON FUNCTION public.find_penduduk_by_nik(TEXT) TO anon, authenticated, service_role;
