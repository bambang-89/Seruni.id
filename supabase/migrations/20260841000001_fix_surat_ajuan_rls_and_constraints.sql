-- =============================================================
-- Migration: 20260841000001_fix_surat_ajuan_rls_and_constraints.sql
-- Tujuan:
--   1. Tambahkan RLS yang benar pada surat_ajuan agar admin bisa baca
--   2. Fix constraint kontak dari NOT NULL menjadi nullable
--   3. Pastikan surat_ajuan_data bisa dibaca oleh authenticated user
--   4. Grant anon INSERT via RPC (SECURITY DEFINER) tetap berjalan
-- =============================================================

-- ============================================================
-- FIX 1: Kontak bisa NULL (warga boleh tidak mengisi nomor HP)
-- ============================================================
ALTER TABLE public.surat_ajuan
  ALTER COLUMN kontak DROP NOT NULL;

-- ============================================================
-- FIX 2: Aktifkan RLS pada surat_ajuan dan tambahkan policies
-- ============================================================
ALTER TABLE public.surat_ajuan ENABLE ROW LEVEL SECURITY;

-- Anon TIDAK bisa langsung SELECT surat_ajuan (privasi warga)
-- Admin (authenticated + has_role admin) bisa baca semua di tenant-nya
DROP POLICY IF EXISTS "surat_ajuan_admin_read" ON public.surat_ajuan;
CREATE POLICY "surat_ajuan_admin_read"
  ON public.surat_ajuan FOR SELECT TO authenticated
  USING (
    tenant_id = public.get_tenant_id()
    OR public.has_role(auth.uid(), 'admin')
  );

-- Admin bisa update status
DROP POLICY IF EXISTS "surat_ajuan_admin_update" ON public.surat_ajuan;
CREATE POLICY "surat_ajuan_admin_update"
  ON public.surat_ajuan FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Grants
GRANT SELECT ON public.surat_ajuan TO authenticated;
GRANT UPDATE ON public.surat_ajuan TO authenticated;

-- ============================================================
-- FIX 3: Pastikan surat_ajuan_data bisa dibaca oleh authenticated
-- (sudah ada dari migration sebelumnya, tapi pastikan policy ada)
-- ============================================================
ALTER TABLE public.surat_ajuan_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "surat_ajuan_data_public_read" ON public.surat_ajuan_data;
CREATE POLICY "surat_ajuan_data_public_read"
  ON public.surat_ajuan_data FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "surat_ajuan_data_admin_write" ON public.surat_ajuan_data;
CREATE POLICY "surat_ajuan_data_admin_write"
  ON public.surat_ajuan_data FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

GRANT SELECT ON public.surat_ajuan_data TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.surat_ajuan_data TO authenticated;

-- ============================================================
-- FIX 4: Pastikan data_identitas column ada di surat_ajuan_data
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'surat_ajuan_data'
      AND column_name = 'data_identitas'
  ) THEN
    ALTER TABLE public.surat_ajuan_data
      ADD COLUMN data_identitas JSONB NOT NULL DEFAULT '{}'::jsonb;
    RAISE NOTICE 'Column data_identitas added to surat_ajuan_data';
  ELSE
    RAISE NOTICE 'Column data_identitas already exists in surat_ajuan_data';
  END IF;
END $$;

-- ============================================================
-- FIX 5: Update RPC submit_surat_ajuan agar kontak bisa NULL
-- (sudah nullable setelah FIX 1, tapi perbarui COALESCE)
-- ============================================================
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
SECURITY DEFINER -- Bypass RLS untuk insert dari anon user
AS $$
DECLARE
  v_surat_id UUID;
BEGIN
  -- Validasi NIK 16 digit
  IF p_nik IS NULL OR length(p_nik) <> 16 OR p_nik !~ '^\d{16}$' THEN
    RAISE EXCEPTION 'NIK harus 16 digit angka';
  END IF;

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
    NULLIF(TRIM(COALESCE(p_kontak, '')), ''), -- kontak nullable
    p_jenis_surat_id,
    p_keperluan,
    COALESCE(p_lampiran, '[]'::JSONB),
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
    )
    ON CONFLICT (surat_ajuan_id) DO UPDATE
      SET data_dna = EXCLUDED.data_dna,
          data_identitas = EXCLUDED.data_identitas,
          updated_at = NOW();
  END IF;

  -- Insert log (graceful - jika event_log tidak ada, skip)
  BEGIN
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
  EXCEPTION WHEN OTHERS THEN
    NULL; -- Jangan gagalkan submit hanya karena log gagal
  END;

  RETURN jsonb_build_object(
    'id', v_surat_id,
    'nomor_tiket', p_nomor_tiket
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_surat_ajuan(UUID, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, JSONB, JSONB, JSONB) TO anon, authenticated;
