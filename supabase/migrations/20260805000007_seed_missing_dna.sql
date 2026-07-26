-- ============================================================
-- SEED DNA FIELDS - Missing Fields for SKCK
-- Tanggal: 2026-08-05
-- ============================================================

DO $$
DECLARE v_tenant_id UUID; v_jenis UUID;
BEGIN SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;

-- 300.0 Surat Pengantar SKCK (Restored)
SELECT id INTO v_jenis FROM public.surat_jenis WHERE kode_surat = '300.0' LIMIT 1;
IF v_jenis IS NOT NULL THEN
  INSERT INTO public.surat_jenis_dna (tenant_id, jenis_surat_id, kode_surat, field_name, label, tipe, placeholder, wajib, grup, urutan, help_text)
  VALUES 
    (v_tenant_id, v_jenis, '300.0', 'ciri_fisik', 'Ciri Fisik', 'textarea', 'Tinggi: ... cm, Rambut: ..., Kulit: ..., dll', true, 'Fisik', 1, NULL),
    (v_tenant_id, v_jenis, '300.0', 'alamat_tinggal', 'Alamat Tempat Tinggal', 'textarea', '', true, 'Alamat', 10, NULL),
    (v_tenant_id, v_jenis, '300.0', 'dusun', 'Dusun', 'text', '', true, 'Alamat', 11, NULL),
    (v_tenant_id, v_jenis, '300.0', 'keperluan', 'Keperluan SKCK', 'textarea', '', true, 'Keperluan', 20, 'Contoh: Melamar kerja, Membuat paspor, dll'),
    (v_tenant_id, v_jenis, '300.0', 'riwayat_pidana', 'Riwayat Pidana', 'textarea', 'Tidak ada / Jelaskan jika ada', true, 'Riwayat', 30, NULL)
  ON CONFLICT (jenis_surat_id, field_name) DO NOTHING;
END IF;

END $$;
