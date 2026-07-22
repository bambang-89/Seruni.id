
-- ================= Phase 6C: PBB & APBDes =================

-- PBB Tagihan
CREATE TABLE public.pbb_tagihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  nop TEXT NOT NULL,
  wajib_pajak_nama TEXT NOT NULL,
  wajib_pajak_nik TEXT,
  alamat_objek TEXT,
  dusun TEXT,
  luas_bumi_m2 NUMERIC(12,2) DEFAULT 0,
  luas_bangunan_m2 NUMERIC(12,2) DEFAULT 0,
  njop_bumi NUMERIC(14,2) DEFAULT 0,
  njop_bangunan NUMERIC(14,2) DEFAULT 0,
  pbb_terutang NUMERIC(14,2) NOT NULL DEFAULT 0,
  jatuh_tempo DATE,
  status_bayar TEXT NOT NULL DEFAULT 'belum_lunas',
  tanggal_bayar DATE,
  metode_bayar TEXT,
  keterangan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tahun, nop)
);
GRANT SELECT ON public.pbb_tagihan TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pbb_tagihan TO authenticated;
GRANT ALL ON public.pbb_tagihan TO service_role;
ALTER TABLE public.pbb_tagihan ENABLE ROW LEVEL SECURITY;
-- Publik: hanya lookup terarah (di app pakai .eq nop). Kita expose SELECT publik agar RPC/query bekerja tanpa auth.
CREATE POLICY "pbb_public_read" ON public.pbb_tagihan FOR SELECT USING (true);
CREATE POLICY "pbb_admin_write" ON public.pbb_tagihan FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_pbb_updated BEFORE UPDATE ON public.pbb_tagihan
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX pbb_nop_idx ON public.pbb_tagihan (nop);
CREATE INDEX pbb_tahun_idx ON public.pbb_tagihan (tahun);

-- APBDes
CREATE TABLE public.apbdes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tahun INT NOT NULL,
  jenis TEXT NOT NULL CHECK (jenis IN ('pendapatan','belanja','pembiayaan')),
  kategori TEXT NOT NULL,
  sub_kategori TEXT,
  uraian TEXT NOT NULL,
  anggaran NUMERIC(16,2) NOT NULL DEFAULT 0,
  realisasi NUMERIC(16,2) NOT NULL DEFAULT 0,
  sumber_dana TEXT,
  keterangan TEXT,
  urutan INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.apbdes TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.apbdes TO authenticated;
GRANT ALL ON public.apbdes TO service_role;
ALTER TABLE public.apbdes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "apbdes_public_read" ON public.apbdes FOR SELECT USING (true);
CREATE POLICY "apbdes_admin_write" ON public.apbdes FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE TRIGGER trg_apbdes_updated BEFORE UPDATE ON public.apbdes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE INDEX apbdes_tahun_idx ON public.apbdes (tahun);

-- RPC lookup PBB (aman untuk publik: tidak expose tabel penuh via API, opsional)
CREATE OR REPLACE FUNCTION public.cek_pbb(_tahun INT, _nop TEXT)
RETURNS TABLE (
  tahun INT, nop TEXT, wajib_pajak_nama TEXT, alamat_objek TEXT, dusun TEXT,
  pbb_terutang NUMERIC, jatuh_tempo DATE, status_bayar TEXT, tanggal_bayar DATE
) LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT p.tahun, p.nop, p.wajib_pajak_nama, p.alamat_objek, p.dusun,
         p.pbb_terutang, p.jatuh_tempo, p.status_bayar, p.tanggal_bayar
  FROM public.pbb_tagihan p
  WHERE p.tahun = _tahun AND lower(trim(p.nop)) = lower(trim(_nop))
  LIMIT 1;
$$;

-- Seed APBDes 2026
INSERT INTO public.apbdes (tahun,jenis,kategori,uraian,anggaran,realisasi,sumber_dana,urutan) VALUES
(2026,'pendapatan','Pendapatan Transfer','Dana Desa (DD)',1250000000,812000000,'APBN',1),
(2026,'pendapatan','Pendapatan Transfer','Alokasi Dana Desa (ADD)',680000000,442000000,'APBD Kab',2),
(2026,'pendapatan','Pendapatan Transfer','Bagi Hasil Pajak & Retribusi',95000000,58000000,'APBD Kab',3),
(2026,'pendapatan','Pendapatan Asli Desa','Hasil Usaha BUMDes',75000000,41500000,'PADes',4),
(2026,'pendapatan','Pendapatan Lain','Bantuan Provinsi',120000000,60000000,'APBD Prov',5),
(2026,'belanja','Bidang 1 — Penyelenggaraan Pemerintahan','Penghasilan Tetap & Tunjangan Pamong',420000000,245000000,'ADD',10),
(2026,'belanja','Bidang 1 — Penyelenggaraan Pemerintahan','Operasional Kantor Desa',95000000,52000000,'ADD',11),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Pengerasan Jalan Poros Karang Baru',480000000,374400000,'DD',20),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Rehabilitasi Posyandu Melati',85000000,42500000,'DD',21),
(2026,'belanja','Bidang 2 — Pelaksanaan Pembangunan','Drainase Dusun Presak',210000000,84000000,'DD',22),
(2026,'belanja','Bidang 3 — Pembinaan Kemasyarakatan','Kegiatan PKK & Karang Taruna',48000000,26500000,'ADD',30),
(2026,'belanja','Bidang 3 — Pembinaan Kemasyarakatan','Bulan Bakti Gotong Royong',22000000,22000000,'ADD',31),
(2026,'belanja','Bidang 4 — Pemberdayaan Masyarakat','Pelatihan Pengolahan Hasil Pertanian',65000000,32000000,'DD',40),
(2026,'belanja','Bidang 4 — Pemberdayaan Masyarakat','Bantuan Modal BUMDes',75000000,75000000,'DD',41),
(2026,'belanja','Bidang 5 — Penanggulangan Bencana & Mendesak','Cadangan Kebencanaan',60000000,12000000,'DD',50),
(2026,'pembiayaan','Penerimaan Pembiayaan','SILPA Tahun Sebelumnya',180000000,180000000,'SILPA',60),
(2026,'pembiayaan','Pengeluaran Pembiayaan','Penyertaan Modal BUMDes',75000000,75000000,'PADes',61);

-- Seed PBB dummy
INSERT INTO public.pbb_tagihan (tahun,nop,wajib_pajak_nama,alamat_objek,dusun,luas_bumi_m2,luas_bangunan_m2,njop_bumi,njop_bangunan,pbb_terutang,jatuh_tempo,status_bayar) VALUES
(2026,'52.03.140.007.001-0001.0','H. Ahmad Saputra','Dusun Karang Baru RT 04 RW 02','Karang Baru',400,120,80000000,60000000,187500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0002.0','Ni Wayan Sari','Dusun Presak RT 02 RW 01','Presak',350,90,63000000,42000000,131250,'2026-09-30','lunas'),
(2026,'52.03.140.007.001-0003.0','Lalu Muhammad Zaini','Dusun Seruni Utara RT 01 RW 03','Seruni Utara',500,150,100000000,90000000,237500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0004.0','Baiq Nurhayati','Dusun Mumbul RT 03 RW 02','Mumbul',280,72,50400000,28800000,98500,'2026-09-30','belum_lunas'),
(2026,'52.03.140.007.001-0005.0','I Ketut Wirya','Dusun Karang Baru RT 05 RW 02','Karang Baru',600,180,120000000,108000000,285000,'2026-09-30','lunas');
