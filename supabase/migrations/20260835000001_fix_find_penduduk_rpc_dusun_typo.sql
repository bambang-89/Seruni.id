-- ============================================================
-- MIGRASI: 20260835000001_fix_find_penduduk_rpc_dusun_typo.sql
-- Deskripsi: Fix typo wilolos_batas -> ref_dusun di RPC find_penduduk_by_nik
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
  nomor_hp TEXT,
  status_hidup TEXT,
  keluarga_id UUID,
  no_kk TEXT,
  provinsi TEXT,
  kabupaten TEXT,
  kecamatan TEXT,
  desa TEXT,
  provinsi_id UUID,
  kabupaten_id UUID,
  kecamatan_id UUID,
  desa_id UUID,
  dusun_id UUID
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
    COALESCE(ra.nama, p.agama) AS agama,
    COALESCE(rpend.nama, p.pendidikan) AS pendidikan,
    COALESCE(rpek.nama, p.pekerjaan) AS pekerjaan,
    COALESCE(rsp.nama, p.status_kawin) AS status_kawin,
    p.hubungan_kk,
    p.warga_negara_id,
    COALESCE(rd.nama, p.dusun) AS dusun,
    p.alamat,
    p.rt,
    p.rw,
    p.nomor_hp,
    p.status_hidup,
    p.keluarga_id,
    k.no_kk,
    rprov.nama AS provinsi,
    rkab.nama AS kabupaten,
    rkec.nama AS kecamatan,
    rdesa.nama AS desa,
    p.provinsi_id,
    p.kabupaten_id,
    p.kecamatan_id,
    p.desa_id,
    p.dusun_id
  FROM public.penduduk p
  LEFT JOIN public.keluarga k ON k.id = p.keluarga_id
  LEFT JOIN public.ref_agama ra ON ra.id = p.agama_id
  LEFT JOIN public.ref_pendidikan rpend ON rpend.id = p.pendidikan_id
  LEFT JOIN public.ref_pekerjaan rpek ON rpek.id = p.pekerjaan_id
  LEFT JOIN public.ref_status_perkawinan rsp ON rsp.id = p.status_perkawinan_id
  LEFT JOIN public.ref_provinsi rprov ON rprov.id = p.provinsi_id
  LEFT JOIN public.ref_kabupaten rkab ON rkab.id = p.kabupaten_id
  LEFT JOIN public.ref_kecamatan rkec ON rkec.id = p.kecamatan_id
  LEFT JOIN public.ref_desa rdesa ON rdesa.id = p.desa_id
  LEFT JOIN public.ref_dusun rd ON rd.id = p.dusun_id
  WHERE p.nik = p_nik
  LIMIT 1;
END;
$$;

GRANT EXECUTE ON FUNCTION public.find_penduduk_by_nik(TEXT) TO anon, authenticated, service_role;
