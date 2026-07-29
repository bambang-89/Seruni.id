-- Migration: Fix surat and penduduk for warga submissions
-- Problem: FK constraint on surat_ajuan.nik blocks inserts when penduduk is empty
-- Problem: Multiple migrations created conflicting CHECK constraints on penduduk.jenis_kelamin
-- Problem: submit_surat_ajuan RPC doesn't pass tenant_id to event_log
-- Solution: Drop ALL conflicting constraints and add one permissive constraint

BEGIN;

-- 1. Drop the FK constraint on surat_ajuan.nik (enforced at app level instead)
ALTER TABLE public.surat_ajuan DROP CONSTRAINT IF EXISTS fk_surat_ajuan_nik_penduduk;

-- 2. Drop ALL conflicting CHECK constraints on penduduk.jenis_kelamin
-- (multiple migrations created different constraints with incompatible values)
DO $$
DECLARE
  _conname TEXT;
BEGIN
  FOR _conname IN
    SELECT conname FROM pg_constraint
    WHERE conrelid = 'public.penduduk'::regclass
      AND contype = 'c'
      AND conname LIKE 'penduduk_jenis_kelamin%'
  LOOP
    EXECUTE format('ALTER TABLE public.penduduk DROP CONSTRAINT IF EXISTS %I', _conname);
    RAISE NOTICE 'Dropped constraint: %', _conname;
  END LOOP;
END;
$$;

-- 3. Add one permissive check constraint that allows common Indonesian gender values
ALTER TABLE public.penduduk ADD CONSTRAINT penduduk_jenis_kelamin_valid
  CHECK (jenis_kelamin IS NULL OR jenis_kelamin IN ('L', 'P', 'Laki-laki', 'Perempuan', 'LAKI-LAKI', 'PEREMPUAN', 'Male', 'Female', '1', '2', ''));

-- 4. Fix submit_surat_ajuan RPC to include tenant_id in event_log
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
    tenant_id, nomor_tiket, nik, nama, kontak, jenis_surat_id,
    keperluan, lampiran, status, created_at
  ) VALUES (
    p_tenant_id, p_nomor_tiket, p_nik, p_nama, p_kontak, p_jenis_surat_id,
    p_keperluan, p_lampiran, 'menunggu', NOW()
  ) RETURNING id INTO v_surat_id;

  IF p_data_dna IS NOT NULL OR p_data_identitas IS NOT NULL THEN
    INSERT INTO public.surat_ajuan_data (
      tenant_id, surat_ajuan_id, data_dna, data_identitas
    ) VALUES (
      p_tenant_id, v_surat_id,
      COALESCE(p_data_dna, '{}'::JSONB),
      COALESCE(p_data_identitas, '{}'::JSONB)
    );
  END IF;

  -- Insert log WITH tenant_id
  INSERT INTO public.event_log (
    tenant_id, event_name, entitas, entitas_id, payload
  ) VALUES (
    p_tenant_id,
    'surat.diajukan',
    'surat_ajuan',
    v_surat_id,
    jsonb_build_object('nik', p_nik, 'nomor_tiket', p_nomor_tiket)
  );

  RETURN jsonb_build_object('id', v_surat_id, 'nomor_tiket', p_nomor_tiket);
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_surat_ajuan(UUID, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, JSONB, JSONB, JSONB) TO anon, authenticated;

COMMIT;
