-- ============================================================
-- MIGRASI: 20260721000005_rls_tenant_policies.sql
-- Tanggal: 2026-07-21
-- Deskripsi: Tambahkan RLS policies tenant isolation ke 40 tabel.
--            service_role bypass semua RLS.
-- ============================================================

DO $$
BEGIN

-- ============================================================
-- CORE TABLES
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk read" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk read" ON penduduk FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk write" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk write" ON penduduk FOR UPDATE USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk insert" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk insert" ON penduduk FOR INSERT WITH CHECK (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penduduk delete" ON penduduk';
EXECUTE 'CREATE POLICY "Tenant isolation: penduduk delete" ON penduduk FOR DELETE USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: keluarga read" ON keluarga';
EXECUTE 'CREATE POLICY "Tenant isolation: keluarga read" ON keluarga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: keluarga write" ON keluarga';
EXECUTE 'CREATE POLICY "Tenant isolation: keluarga write" ON keluarga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wilayah_dusun read" ON wilayah_dusun';
EXECUTE 'CREATE POLICY "Tenant isolation: wilayah_dusun read" ON wilayah_dusun FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wilayah_dusun write" ON wilayah_dusun';
EXECUTE 'CREATE POLICY "Tenant isolation: wilayah_dusun write" ON wilayah_dusun FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- GOVERNANCE
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_topik read" ON voting_topik';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_topik read" ON voting_topik FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_topik write" ON voting_topik';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_topik write" ON voting_topik FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_opsi read" ON voting_opsi';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_opsi read" ON voting_opsi FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_opsi write" ON voting_opsi';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_opsi write" ON voting_opsi FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_suara read" ON voting_suara';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_suara read" ON voting_suara FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: voting_suara write" ON voting_suara';
EXECUTE 'CREATE POLICY "Tenant isolation: voting_suara write" ON voting_suara FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_warga read" ON usulan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_warga read" ON usulan_warga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_warga write" ON usulan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_warga write" ON usulan_warga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_vote read" ON usulan_vote';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_vote read" ON usulan_vote FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: usulan_vote write" ON usulan_vote';
EXECUTE 'CREATE POLICY "Tenant isolation: usulan_vote write" ON usulan_vote FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_periode read" ON rpjmdes_periode';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_periode read" ON rpjmdes_periode FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_periode write" ON rpjmdes_periode';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_periode write" ON rpjmdes_periode FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_bidang read" ON rpjmdes_bidang';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_bidang read" ON rpjmdes_bidang FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_bidang write" ON rpjmdes_bidang';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_bidang write" ON rpjmdes_bidang FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_program read" ON rpjmdes_program';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_program read" ON rpjmdes_program FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rpjmdes_program write" ON rpjmdes_program';
EXECUTE 'CREATE POLICY "Tenant isolation: rpjmdes_program write" ON rpjmdes_program FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_tahun read" ON rkpdes_tahun';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_tahun read" ON rkpdes_tahun FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_tahun write" ON rkpdes_tahun';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_tahun write" ON rkpdes_tahun FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_kegiatan read" ON rkpdes_kegiatan';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_kegiatan read" ON rkpdes_kegiatan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: rkpdes_kegiatan write" ON rkpdes_kegiatan';
EXECUTE 'CREATE POLICY "Tenant isolation: rkpdes_kegiatan write" ON rkpdes_kegiatan FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- LAYANAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_jenis read" ON surat_jenis';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_jenis read" ON surat_jenis FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_jenis write" ON surat_jenis';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_jenis write" ON surat_jenis FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_terbit read" ON surat_terbit';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_terbit read" ON surat_terbit FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: surat_terbit write" ON surat_terbit';
EXECUTE 'CREATE POLICY "Tenant isolation: surat_terbit write" ON surat_terbit FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: pbb_tagihan read" ON pbb_tagihan';
EXECUTE 'CREATE POLICY "Tenant isolation: pbb_tagihan read" ON pbb_tagihan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: pbb_tagihan write" ON pbb_tagihan';
EXECUTE 'CREATE POLICY "Tenant isolation: pbb_tagihan write" ON pbb_tagihan FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- KESEHATAN & SOSIAL
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: posyandu_agregat read" ON posyandu_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: posyandu_agregat read" ON posyandu_agregat FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: posyandu_agregat write" ON posyandu_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: posyandu_agregat write" ON posyandu_agregat FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: stunting_agregat read" ON stunting_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: stunting_agregat read" ON stunting_agregat FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: stunting_agregat write" ON stunting_agregat';
EXECUTE 'CREATE POLICY "Tenant isolation: stunting_agregat write" ON stunting_agregat FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bantuan_sosial read" ON bantuan_sosial';
EXECUTE 'CREATE POLICY "Tenant isolation: bantuan_sosial read" ON bantuan_sosial FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bantuan_sosial write" ON bantuan_sosial';
EXECUTE 'CREATE POLICY "Tenant isolation: bantuan_sosial write" ON bantuan_sosial FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penerima_bansos read" ON penerima_bansos';
EXECUTE 'CREATE POLICY "Tenant isolation: penerima_bansos read" ON penerima_bansos FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: penerima_bansos write" ON penerima_bansos';
EXECUTE 'CREATE POLICY "Tenant isolation: penerima_bansos write" ON penerima_bansos FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- INFRASTRUKTUR & PERTANAHAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: infrastruktur read" ON infrastruktur';
EXECUTE 'CREATE POLICY "Tenant isolation: infrastruktur read" ON infrastruktur FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: infrastruktur write" ON infrastruktur';
EXECUTE 'CREATE POLICY "Tenant isolation: infrastruktur write" ON infrastruktur FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: kegiatan_pembangunan read" ON kegiatan_pembangunan';
EXECUTE 'CREATE POLICY "Tenant isolation: kegiatan_pembangunan read" ON kegiatan_pembangunan FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: kegiatan_pembangunan write" ON kegiatan_pembangunan';
EXECUTE 'CREATE POLICY "Tenant isolation: kegiatan_pembangunan write" ON kegiatan_pembangunan FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bidang_tanah read" ON bidang_tanah';
EXECUTE 'CREATE POLICY "Tenant isolation: bidang_tanah read" ON bidang_tanah FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bidang_tanah write" ON bidang_tanah';
EXECUTE 'CREATE POLICY "Tenant isolation: bidang_tanah write" ON bidang_tanah FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- DEMOGRAFI & STATISTIK
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dpt_pemilih read" ON dpt_pemilih';
EXECUTE 'CREATE POLICY "Tenant isolation: dpt_pemilih read" ON dpt_pemilih FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: dpt_pemilih write" ON dpt_pemilih';
EXECUTE 'CREATE POLICY "Tenant isolation: dpt_pemilih write" ON dpt_pemilih FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: analisis_snapshot read" ON analisis_snapshot';
EXECUTE 'CREATE POLICY "Tenant isolation: analisis_snapshot read" ON analisis_snapshot FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: analisis_snapshot write" ON analisis_snapshot';
EXECUTE 'CREATE POLICY "Tenant isolation: analisis_snapshot write" ON analisis_snapshot FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: idm_indikator read" ON idm_indikator';
EXECUTE 'CREATE POLICY "Tenant isolation: idm_indikator read" ON idm_indikator FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: idm_indikator write" ON idm_indikator';
EXECUTE 'CREATE POLICY "Tenant isolation: idm_indikator write" ON idm_indikator FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- PEMERINTAHAN DESA
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: desa_pamong read" ON desa_pamong';
EXECUTE 'CREATE POLICY "Tenant isolation: desa_pamong read" ON desa_pamong FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: desa_pamong write" ON desa_pamong';
EXECUTE 'CREATE POLICY "Tenant isolation: desa_pamong write" ON desa_pamong FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: profil_desa read" ON profil_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: profil_desa read" ON profil_desa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: profil_desa write" ON profil_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: profil_desa write" ON profil_desa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: lembaga_desa read" ON lembaga_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: lembaga_desa read" ON lembaga_desa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: lembaga_desa write" ON lembaga_desa';
EXECUTE 'CREATE POLICY "Tenant isolation: lembaga_desa write" ON lembaga_desa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: apbdes read" ON apbdes';
EXECUTE 'CREATE POLICY "Tenant isolation: apbdes read" ON apbdes FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: apbdes write" ON apbdes';
EXECUTE 'CREATE POLICY "Tenant isolation: apbdes write" ON apbdes FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: buku_register read" ON buku_register';
EXECUTE 'CREATE POLICY "Tenant isolation: buku_register read" ON buku_register FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: buku_register write" ON buku_register';
EXECUTE 'CREATE POLICY "Tenant isolation: buku_register write" ON buku_register FOR ALL USING (tenant_id = get_tenant_id())';

-- ============================================================
-- POTENSI & PELAYANAN
-- ============================================================
EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_umkm read" ON potensi_umkm';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_umkm read" ON potensi_umkm FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_umkm write" ON potensi_umkm';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_umkm write" ON potensi_umkm FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_produk read" ON potensi_produk';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_produk read" ON potensi_produk FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_produk write" ON potensi_produk';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_produk write" ON potensi_produk FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_wisata read" ON potensi_wisata';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_wisata read" ON potensi_wisata FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: potensi_wisata write" ON potensi_wisata';
EXECUTE 'CREATE POLICY "Tenant isolation: potensi_wisata write" ON potensi_wisata FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: aduan_warga read" ON aduan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: aduan_warga read" ON aduan_warga FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: aduan_warga write" ON aduan_warga';
EXECUTE 'CREATE POLICY "Tenant isolation: aduan_warga write" ON aduan_warga FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: langganan_wa read" ON langganan_wa';
EXECUTE 'CREATE POLICY "Tenant isolation: langganan_wa read" ON langganan_wa FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: langganan_wa write" ON langganan_wa';
EXECUTE 'CREATE POLICY "Tenant isolation: langganan_wa write" ON langganan_wa FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast read" ON wa_broadcast';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast read" ON wa_broadcast FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast write" ON wa_broadcast';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast write" ON wa_broadcast FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast_target read" ON wa_broadcast_target';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast_target read" ON wa_broadcast_target FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: wa_broadcast_target write" ON wa_broadcast_target';
EXECUTE 'CREATE POLICY "Tenant isolation: wa_broadcast_target write" ON wa_broadcast_target FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bencana_kejadian read" ON bencana_kejadian';
EXECUTE 'CREATE POLICY "Tenant isolation: bencana_kejadian read" ON bencana_kejadian FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: bencana_kejadian write" ON bencana_kejadian';
EXECUTE 'CREATE POLICY "Tenant isolation: bencana_kejadian write" ON bencana_kejadian FOR ALL USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: suplesi_data read" ON suplesi_data';
EXECUTE 'CREATE POLICY "Tenant isolation: suplesi_data read" ON suplesi_data FOR SELECT USING (tenant_id = get_tenant_id())';

EXECUTE 'DROP POLICY IF EXISTS "Tenant isolation: suplesi_data write" ON suplesi_data';
EXECUTE 'CREATE POLICY "Tenant isolation: suplesi_data write" ON suplesi_data FOR ALL USING (tenant_id = get_tenant_id())';

RAISE NOTICE 'RLS tenant isolation policies applied successfully.';

END $$;

-- Verifikasi
SELECT tablename, COUNT(*) FILTER (WHERE policyname LIKE 'Tenant isolation%') as rls_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;
