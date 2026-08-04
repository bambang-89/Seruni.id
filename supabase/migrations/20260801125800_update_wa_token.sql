-- Tambahkan kolom admin_phone jika belum ada (idempoten)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='tenants' AND column_name='admin_phone') THEN
        ALTER TABLE tenants ADD COLUMN admin_phone text;
    END IF;
END $$;

-- Update fonnte_token dan admin_phone sesuai spesifikasi
UPDATE tenants 
SET fonnte_token = 'qHpiCwHavyAN5vovnAr7',
    admin_phone = '087763170088'
WHERE id IS NOT NULL;
