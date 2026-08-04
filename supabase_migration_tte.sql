-- ================================================================
-- SERUNI.ID — SQL Migration Lengkap
-- Jalankan di: Supabase Dashboard → SQL Editor → New Query → Run
-- ================================================================

-- 1. Tambah kolom yang mungkin belum ada di site_settings
ALTER TABLE site_settings
  ADD COLUMN IF NOT EXISTS kodepos         TEXT,
  ADD COLUMN IF NOT EXISTS dusun           TEXT,
  ADD COLUMN IF NOT EXISTS rt              TEXT,
  ADD COLUMN IF NOT EXISTS singkatan_desa  TEXT,
  ADD COLUMN IF NOT EXISTS singkatan_kades TEXT,
  ADD COLUMN IF NOT EXISTS jam_layanan     TEXT,
  ADD COLUMN IF NOT EXISTS nomor_wa_resmi  TEXT,
  ADD COLUMN IF NOT EXISTS maps_embed_url  TEXT,
  ADD COLUMN IF NOT EXISTS social_media    JSONB DEFAULT '{}'::jsonb;

-- 2. Tambah kolom gambar di tabel tenants
ALTER TABLE tenants
  ADD COLUMN IF NOT EXISTS logo_kabupaten_url TEXT,
  ADD COLUMN IF NOT EXISTS logo_provinsi_url  TEXT,
  ADD COLUMN IF NOT EXISTS favicon_url        TEXT;

-- 3. Buat tabel tte_signatures untuk verifikasi QR Code surat
CREATE TABLE IF NOT EXISTS public.tte_signatures (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    surat_id       UUID NOT NULL REFERENCES public.surat_terbit(id) ON DELETE CASCADE,
    tipe           TEXT NOT NULL DEFAULT 'sederhana',
    status         TEXT NOT NULL DEFAULT 'signed',
    signed_by      TEXT NOT NULL,
    signer_role    TEXT NOT NULL,
    signed_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    signature_hash TEXT NOT NULL,
    qr_code_url    TEXT,
    metadata       JSONB DEFAULT '{}'::jsonb
);

-- 4. RLS untuk tte_signatures
ALTER TABLE public.tte_signatures ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'tte_signatures' AND policyname = 'public_read_tte'
  ) THEN
    CREATE POLICY "public_read_tte"
    ON public.tte_signatures FOR SELECT TO public USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'tte_signatures' AND policyname = 'auth_insert_tte'
  ) THEN
    CREATE POLICY "auth_insert_tte"
    ON public.tte_signatures FOR INSERT TO authenticated WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'tte_signatures' AND policyname = 'auth_update_tte'
  ) THEN
    CREATE POLICY "auth_update_tte"
    ON public.tte_signatures FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
  END IF;
END$$;

-- 5. Pastikan bucket seruni-media bersifat public
UPDATE storage.buckets SET public = true WHERE id = 'seruni-media';

-- ================================================================
-- SELESAI — Refresh halaman Supabase untuk memverifikasi
-- ================================================================
