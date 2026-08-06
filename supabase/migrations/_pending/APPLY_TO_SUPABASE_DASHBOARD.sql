-- ============================================================
-- JALANKAN SQL INI DI SUPABASE DASHBOARD > SQL EDITOR
-- URL: https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql
-- 
-- Migration: Fix surat_ajuan RLS + kontak nullable + admin read
-- ============================================================

-- 1. Fix kontak: hilangkan NOT NULL constraint
ALTER TABLE public.surat_ajuan ALTER COLUMN kontak DROP NOT NULL;

-- 2. Pastikan data_identitas column ada di surat_ajuan_data
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'surat_ajuan_data' AND column_name = 'data_identitas'
  ) THEN
    ALTER TABLE public.surat_ajuan_data ADD COLUMN data_identitas JSONB NOT NULL DEFAULT '{}'::jsonb;
    RAISE NOTICE 'Column data_identitas added';
  ELSE
    RAISE NOTICE 'Column data_identitas already exists';
  END IF;
END $$;

-- 3. Enable RLS pada surat_ajuan (jika belum)
ALTER TABLE public.surat_ajuan ENABLE ROW LEVEL SECURITY;

-- 4. Buat policy: admin authenticated dapat membaca semua surat_ajuan
DROP POLICY IF EXISTS "surat_ajuan_admin_read" ON public.surat_ajuan;
CREATE POLICY "surat_ajuan_admin_read"
  ON public.surat_ajuan FOR SELECT TO authenticated
  USING (true);

-- 5. Buat policy: admin authenticated dapat update surat_ajuan
DROP POLICY IF EXISTS "surat_ajuan_admin_write" ON public.surat_ajuan;
CREATE POLICY "surat_ajuan_admin_write"
  ON public.surat_ajuan FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

-- 6. Grant access
GRANT SELECT, UPDATE, DELETE ON public.surat_ajuan TO authenticated;

-- 7. Enable RLS pada surat_ajuan_data
ALTER TABLE public.surat_ajuan_data ENABLE ROW LEVEL SECURITY;

-- 8. surat_ajuan_data: authenticated bisa baca semua
DROP POLICY IF EXISTS "surat_ajuan_data_admin_read" ON public.surat_ajuan_data;
CREATE POLICY "surat_ajuan_data_admin_read"
  ON public.surat_ajuan_data FOR SELECT TO authenticated
  USING (true);

GRANT SELECT ON public.surat_ajuan_data TO authenticated;

-- 9. Update RPC submit_surat_ajuan: kontak nullable, data_identitas disimpan
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
    tenant_id, nomor_tiket, nik, nama, kontak,
    jenis_surat_id, keperluan, lampiran, status, created_at
  ) VALUES (
    p_tenant_id, p_nomor_tiket, p_nik, p_nama,
    NULLIF(TRIM(COALESCE(p_kontak, '')), ''),
    p_jenis_surat_id, p_keperluan,
    COALESCE(p_lampiran, '[]'::JSONB),
    'menunggu', NOW()
  ) RETURNING id INTO v_surat_id;

  IF p_data_dna IS NOT NULL OR p_data_identitas IS NOT NULL THEN
    INSERT INTO public.surat_ajuan_data (
      tenant_id, surat_ajuan_id, data_dna, data_identitas
    ) VALUES (
      p_tenant_id, v_surat_id,
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

-- Verifikasi
SELECT 
  'surat_ajuan kontak nullable: ' || (is_nullable = 'YES')::text AS check1
FROM information_schema.columns 
WHERE table_name = 'surat_ajuan' AND column_name = 'kontak';

SELECT 
  'surat_ajuan_data has data_identitas: ' || COUNT(*)::text AS check2
FROM information_schema.columns 
WHERE table_name = 'surat_ajuan_data' AND column_name = 'data_identitas';
