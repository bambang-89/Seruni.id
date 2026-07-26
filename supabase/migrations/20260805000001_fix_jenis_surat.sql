-- ============================================================
-- MIGRATION: 20260805000001_fix_jenis_surat.sql
-- Tanggal: 2026-08-05
-- Deskripsi:
--   Perbaikan menyeluruh jenis surat dan DNA:
--   1. Nonaktifkan surat tidak relevan (bukan tupoksi)
--   2. Gabung surat duplikat
--   3. Update DNA fields
-- ============================================================

DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants LIMIT 1;
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant not found!';
  END IF;

  RAISE NOTICE '=== FIX JENIS SURAT MIGRATION STARTED ===';

  -- ============================================================
  -- STEP 1: NONAKTIFKAN SURAT YANG BUKAN TUPOKSI DESA
  -- ============================================================
  RAISE NOTICE 'Step 1: Deactivating non-relevant surat types...';

  -- Bukan tupoksi Kantor Desa
  UPDATE public.surat_jenis SET aktif = false
  WHERE kode_surat IN (
    '441.1',  -- Surat Pengantar Bebas Nark0ba (BNN/POLRI)
    '471.1',  -- SK untuk Paspor (Kantor Imigrasi)
    '471.2',  -- SK Cal0n TKI/PMI (Kemnaker)
    '650.2',  -- Surat Pengantar IMB/PBG (Dinas PU)
    '456.0',  -- SK Naik Haji/Umrah (Kantor Kemenag)
    '466.0'   -- Izin Penggalangan Dana (Kemensos/OJK)
  );

  -- ============================================================
  -- STEP 2: NONAKTIFKAN SURAT INTERNAL DESA
  -- ============================================================
  RAISE NOTICE 'Step 2: Deactivating internal-only surat types...';

  -- Surat internal yang tidak untuk warga
  UPDATE public.surat_jenis SET aktif = false
  WHERE kode_surat IN (
    '80.0',   -- Surat Undangan Rapat
    '90.0',   -- Surat Tugas Perangkat
    '890.0',  -- Izin Cuti Perangkat
    '141.0',  -- SK Kepala Desa
    '60.0',   -- Nota Dinas
    '50.0',   -- Laporan Pelaksanaan
    '30.7'    -- Berita Acara Serah Terima
  );

  -- ============================================================
  -- STEP 3: GABUNG SURAT DUPLIKAT (Update kode_klasifikasi)
  -- ============================================================
  RAISE NOTICE 'Step 3: Merging duplicate surat types...';

  -- 474.1 -> Gabung ke 474.0 (SK Bukan Penduduk Setempat = SK Domisili)
  UPDATE public.surat_jenis SET aktif = false WHERE kode_surat = '474.1';

  -- 474.2 -> Gabung ke 474.0 (SK KK Sementara = SK Domisili + keperluan)
  UPDATE public.surat_jenis SET aktif = false WHERE kode_surat = '474.2';

  -- 475.1, 475.2, 475.3 -> Gabung ke 475.0 (sama dengan SK Pindah)
  UPDATE public.surat_jenis SET aktif = false WHERE kode_surat IN ('475.1', '475.2', '475.3');

  -- 510.1, 510.2 -> Gabung ke 510.0 (SKU dengan catatan)
  UPDATE public.surat_jenis SET aktif = false WHERE kode_surat IN ('510.1', '510.2');

  -- ============================================================
  -- STEP 4: UPDATE NAMA UNTUK CLARITY
  -- ============================================================
  RAISE NOTICE 'Step 4: Updating surat names for clarity...';

  -- Update nama untuk surat yang masih aktif
  UPDATE public.surat_jenis SET nama = 'Surat Keterangan Domisili (SKD)'
  WHERE kode_surat = '474.0' AND aktif = true;

  UPDATE public.surat_jenis SET nama = 'Surat Keterangan Pindah Domisili'
  WHERE kode_surat = '475.0' AND aktif = true;

  UPDATE public.surat_jenis SET nama = 'Surat Keterangan Kelahiran (N-1)'
  WHERE kode_surat = '477.3' AND aktif = true;

  UPDATE public.surat_jenis SET nama = 'Surat Keterangan Kematian (N-2)'
  WHERE kode_surat = '477.4' AND aktif = true;

  -- ============================================================
  -- STEP 5: DELETE DNA FIELDS YANG TIDAK RELEVAN
  -- ============================================================
  RAISE NOTICE 'Step 5: Cleaning up irrelevant DNA fields...';

  -- Hapus DNA fields untuk surat yang sudah di-nonaktifkan
  DELETE FROM public.surat_jenis_dna
  WHERE jenis_surat_id IN (
    SELECT id FROM public.surat_jenis WHERE aktif = false
  );

  RAISE NOTICE '=== FIX JENIS SURAT MIGRATION COMPLETED ===';
END $$;

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT
  CASE WHEN aktif = true THEN 'AKTIF' ELSE 'NONAKTIF' END as status,
  count(*) as jumlah,
  string_agg(nama, ', ') as contoh
FROM public.surat_jenis
GROUP BY aktif
ORDER BY aktif DESC;

-- Count DNA fields per jenis surat yang aktif
SELECT
  sj.kode_surat,
  sj.nama,
  count(sjd.id) as dna_fields
FROM public.surat_jenis sj
LEFT JOIN public.surat_jenis_dna sjd ON sjd.jenis_surat_id = sj.id
WHERE sj.aktif = true
GROUP BY sj.kode_surat, sj.nama
ORDER BY sj.kode_surat;
