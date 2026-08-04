CREATE OR REPLACE FUNCTION public.pamong_generate_qr()
RETURNS TRIGGER AS $$
BEGIN
  -- Jika qr_code_url kosong, otomatis generate dengan identitas pamong
  IF NEW.qr_code_url IS NULL OR NEW.qr_code_url = '' THEN
    NEW.qr_code_url := 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' || 
      REPLACE('Pejabat: ' || NEW.nama || ' - ' || NEW.jabatan, ' ', '%20');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_pamong_generate_qr ON public.desa_pamong;

CREATE TRIGGER trigger_pamong_generate_qr
BEFORE INSERT OR UPDATE ON public.desa_pamong
FOR EACH ROW
EXECUTE FUNCTION public.pamong_generate_qr();

-- Update yang sudah ada
UPDATE public.desa_pamong SET qr_code_url = '' WHERE qr_code_url IS NULL;
UPDATE public.desa_pamong SET qr_code_url = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' || REPLACE('Pejabat: ' || nama || ' - ' || jabatan, ' ', '%20') WHERE qr_code_url = '';
