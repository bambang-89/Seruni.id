-- ============================================================
-- Migration: 20260841000002_admin_surat_rpc.sql
-- Tujuan:
--   Membuat RPC yang memungkinkan admin membaca surat_ajuan + data
--   TANPA memerlukan RLS change di surat_ajuan table
--   Solusi: SECURITY DEFINER bypass RLS untuk admin panel
-- ============================================================

-- Buat RPC untuk admin membaca surat_ajuan dengan data_identitas
CREATE OR REPLACE FUNCTION public.admin_get_surat_ajuan(
  p_tenant_id UUID DEFAULT NULL,
  p_id UUID DEFAULT NULL,
  p_limit INT DEFAULT 50,
  p_offset INT DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Bypass RLS
AS $$
DECLARE
  v_result JSONB;
BEGIN
  IF p_id IS NOT NULL THEN
    -- Query single surat with full detail
    SELECT jsonb_build_object(
      'data', jsonb_agg(row_to_json(t.*))
    ) INTO v_result
    FROM (
      SELECT
        sa.*,
        row_to_json(sj.*) AS surat_jenis,
        row_to_json(sad.*) AS surat_ajuan_data
      FROM public.surat_ajuan sa
      LEFT JOIN public.surat_jenis sj ON sj.id = sa.jenis_surat_id
      LEFT JOIN public.surat_ajuan_data sad ON sad.surat_ajuan_id = sa.id
      WHERE sa.id = p_id
    ) t;
  ELSE
    -- Query list
    SELECT jsonb_build_object(
      'data', jsonb_agg(row_to_json(t.*))
    ) INTO v_result
    FROM (
      SELECT
        sa.id,
        sa.nomor_tiket,
        sa.nik,
        sa.nama,
        sa.kontak,
        sa.keperluan,
        sa.status,
        sa.created_at,
        sa.updated_at,
        sa.tenant_id,
        sa.jenis_surat_id,
        row_to_json(sj.*) AS surat_jenis
      FROM public.surat_ajuan sa
      LEFT JOIN public.surat_jenis sj ON sj.id = sa.jenis_surat_id
      WHERE (p_tenant_id IS NULL OR sa.tenant_id = p_tenant_id)
      ORDER BY sa.created_at DESC
      LIMIT p_limit OFFSET p_offset
    ) t;
  END IF;

  RETURN COALESCE(v_result, '{"data":[]}'::JSONB);
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_get_surat_ajuan(UUID, UUID, INT, INT) TO authenticated;

-- Juga fix: kontak nullable
ALTER TABLE public.surat_ajuan ALTER COLUMN kontak DROP NOT NULL;

-- Update RPC submit_surat_ajuan untuk handle kontak nullable
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
SECURITY DEFINER
AS $$
DECLARE
  v_surat_id UUID;
BEGIN
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
    NULLIF(TRIM(COALESCE(p_kontak, '')), ''),
    p_jenis_surat_id,
    p_keperluan,
    COALESCE(p_lampiran, '[]'::JSONB),
    'menunggu',
    NOW()
  ) RETURNING id INTO v_surat_id;

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
    )
    ON CONFLICT (surat_ajuan_id) DO UPDATE
      SET data_dna = EXCLUDED.data_dna,
          data_identitas = EXCLUDED.data_identitas,
          updated_at = NOW();
  END IF;

  BEGIN
    INSERT INTO public.event_log (event_name, entitas, entitas_id, payload)
    VALUES ('surat.diajukan', 'surat_ajuan', v_surat_id,
      jsonb_build_object('nik', p_nik, 'nomor_tiket', p_nomor_tiket));
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  RETURN jsonb_build_object('id', v_surat_id, 'nomor_tiket', p_nomor_tiket);
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_surat_ajuan(UUID, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, JSONB, JSONB, JSONB) TO anon, authenticated;

-- Pastikan data_identitas column ada
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'surat_ajuan_data' AND column_name = 'data_identitas'
  ) THEN
    ALTER TABLE public.surat_ajuan_data ADD COLUMN data_identitas JSONB NOT NULL DEFAULT '{}'::jsonb;
  END IF;
END $$;

-- Enable RLS dan buat policies untuk admin authenticated
ALTER TABLE public.surat_ajuan ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "surat_ajuan_admin_read" ON public.surat_ajuan;
  CREATE POLICY "surat_ajuan_admin_read"
    ON public.surat_ajuan FOR SELECT TO authenticated
    USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  DROP POLICY IF EXISTS "surat_ajuan_admin_write" ON public.surat_ajuan;
  CREATE POLICY "surat_ajuan_admin_write"
    ON public.surat_ajuan FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

GRANT SELECT, UPDATE, DELETE ON public.surat_ajuan TO authenticated;

-- surat_ajuan_data policies
ALTER TABLE public.surat_ajuan_data ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  DROP POLICY IF EXISTS "surat_ajuan_data_admin_read" ON public.surat_ajuan_data;
  CREATE POLICY "surat_ajuan_data_admin_read"
    ON public.surat_ajuan_data FOR SELECT TO authenticated
    USING (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

GRANT SELECT ON public.surat_ajuan_data TO authenticated;
