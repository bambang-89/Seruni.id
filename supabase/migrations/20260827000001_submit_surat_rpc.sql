-- Migration: 20260827000001_submit_surat_rpc.sql

CREATE OR REPLACE FUNCTION public.submit_surat_ajuan(
  p_tenant_id UUID,
  p_nomor_tiket TEXT,
  p_nik TEXT,
  p_nama TEXT,
  p_kontak TEXT,
  p_jenis_surat_id UUID,
  p_keperluan TEXT,
  p_lampiran JSONB,
  p_data_dna JSONB,
  p_data_identitas JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Crucial for bypassing RLS to insert on behalf of anonymous users
AS $$
DECLARE
  v_surat_id UUID;
BEGIN
  -- Insert ke surat_ajuan
  INSERT INTO public.surat_ajuan (
    tenant_id,
    nomor_tiket,
    nik,
    nama,
    kontak,
    jenis_surat_id,
    keperluan,
    lampiran,
    status,
    created_at
  ) VALUES (
    p_tenant_id,
    p_nomor_tiket,
    p_nik,
    p_nama,
    p_kontak,
    p_jenis_surat_id,
    p_keperluan,
    p_lampiran,
    'menunggu',
    NOW()
  ) RETURNING id INTO v_surat_id;

  -- Insert ke surat_ajuan_data jika ada
  IF p_data_dna IS NOT NULL OR p_data_identitas IS NOT NULL THEN
    INSERT INTO public.surat_ajuan_data (
      tenant_id,
      surat_ajuan_id,
      data_dna,
      data_identitas
    ) VALUES (
      p_tenant_id,
      v_surat_id,
      COALESCE(p_data_dna, '{}'::JSONB),
      COALESCE(p_data_identitas, '{}'::JSONB)
    );
  END IF;

  -- Insert log
  INSERT INTO public.event_log (
    event_name,
    entitas,
    entitas_id,
    payload
  ) VALUES (
    'surat.diajukan',
    'surat_ajuan',
    v_surat_id,
    jsonb_build_object('nik', p_nik, 'nomor_tiket', p_nomor_tiket)
  );

  RETURN jsonb_build_object(
    'id', v_surat_id,
    'nomor_tiket', p_nomor_tiket
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_surat_ajuan(UUID, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, JSONB, JSONB, JSONB) TO anon, authenticated;
