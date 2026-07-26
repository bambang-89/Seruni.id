-- DNA Fields Seed (Part 1)
DO $$
DECLARE v_tenant_id UUID; v_jenis UUID;
BEGIN SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

-- 474.0 SK Domisili
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '474.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan)
  VALUES (v_tenant_id, v_jenis, '474.0', 'alamat_domisili', 'Alamat Domisili', 'textarea', '', true, 'Domisili', 1),
         (v_tenant_id, v_jenis, '474.0', 'dusun', 'Dusun', 'text', '', true, 'Domisili', 2),
         (v_tenant_id, v_jenis, '474.0', 'rt_rw', 'RT/RW', 'text', '', true, 'Domisili', 3),
         (v_tenant_id, v_jenis, '474.0', 'keperluan', 'Keperluan', 'textarea', '', true, 'Keperluan', 10)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;
END $$;
