-- Tambahkan konfigurasi singkatan kepala desa dan desa ke tabel site_settings
ALTER TABLE public.site_settings
ADD COLUMN IF NOT EXISTS singkatan_desa text,
ADD COLUMN IF NOT EXISTS singkatan_kades text;
