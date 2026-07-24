-- ============================================================
-- Migration: 20260724181238_add_data_identitas_to_surat_ajuan_data.sql
-- Adds data_identitas JSONB column to surat_ajuan_data table
--
-- Required by: Task 3 of surat-identitas-autofill feature
-- The submit-surat edge function now persists data_identitas
-- alongside data_dna to this column.
-- ============================================================

-- Only run if the column doesn't exist
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
