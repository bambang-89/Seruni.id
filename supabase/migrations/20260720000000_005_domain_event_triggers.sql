-- ============================================================
-- MIGRASI: 20260720000000_005_domain_event_triggers.sql
-- Tanggal: 2026-07-20
-- Deskripsi: Lengkapi event triggers untuk domain_tables yang BELUM emit
--             ke domain_events. Priority tables untuk "Satu Input, Banyak Dampak".
--
-- Gap yang diaddress:
-- - surat_terbit → domain_events (surat.* events)
-- - voting_suara → domain_events (voting.* events)
-- - keluarga → domain_events (keluarga.* events)
-- - posyandu_agregat → domain_events (posyandu.* events)
-- - apbdes → domain_events (apbdes.* events)
-- - bidang_tanah → domain_events (bidang_tanah.* events)
-- - bantuan_sosial → domain_events (bansos.* events)
--
-- Urutan migrasi: setelah 004_multi_tenancy.sql, 003_domain_events.sql
-- ============================================================

-- ============================================================
-- 1. SURAT_TERBIT — Emit surat.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_surat_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'jenis', NEW.jenis,
      'nomor_surat', NEW.nomor_surat,
      'penduduk_id', NEW.penduduk_id,
      'status', NEW.status
    );
    PERFORM publish_event('surat.diajukan', 'surat_terbit', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Status transitions
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'surat.diverifikasi';
        WHEN 'ditolak' THEN
          v_event_type := 'surat.ditolak';
        WHEN 'ditandatangani' THEN
          v_event_type := 'surat.ditandatangani';
        WHEN 'diterbitkan' THEN
          v_event_type := 'surat.diterbitkan';
        WHEN 'dikirim' THEN
          v_event_type := 'surat.dikirim';
        ELSE
          v_event_type := 'surat.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'nomor_surat', NEW.nomor_surat
      );
      PERFORM publish_event(v_event_type, 'surat_terbit', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain
    IF OLD.nomor_surat IS DISTINCT FROM NEW.nomor_surat
       OR OLD.penduduk_id IS DISTINCT FROM NEW.penduduk_id THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nomor_surat', jsonb_build_array(OLD.nomor_surat, NEW.nomor_surat)
        )
      );
      PERFORM publish_event('surat.data.berubah', 'surat_terbit', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Drop existing trigger if any (idempotent)
DROP TRIGGER IF EXISTS trg_surat_terbit_publish_event ON public.surat_terbit;
CREATE TRIGGER trg_surat_terbit_publish_event
  AFTER INSERT OR UPDATE ON public.surat_terbit
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_surat_event();

-- ============================================================
-- 2. VOTING_SUARA — Emit voting.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_voting_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'topik_id', NEW.topik_id,
      'opsi_id', NEW.opsi_id,
      'penduduk_id', NEW.penduduk_id,
      'voting_token', NEW.voting_token
    );
    PERFORM publish_event('voting.suara.ditambahkan', 'voting_suara', NEW.id, v_payload, NEW.penduduk_id);

    -- Also emit to voting_topik untuk sync counter
    v_payload := jsonb_build_object(
      'suara_id', NEW.id,
      'topik_id', NEW.topik_id
    );
    PERFORM publish_event('voting.terhubung', 'voting_suara', NEW.id, v_payload, NEW.penduduk_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_voting_suara_publish_event ON public.voting_suara;
CREATE TRIGGER trg_voting_suara_publish_event
  AFTER INSERT ON public.voting_suara
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_voting_event();

-- ============================================================
-- 3. KELUARGA — Emit keluarga.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_keluarga_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'no_kk', NEW.no_kk,
      'kepala_nama', NEW.kepala_nama,
      'dusun', NEW.dusun,
      'rt', NEW.rt,
      'rw', NEW.rw
    );
    PERFORM publish_event('keluarga.dibuat', 'keluarga', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status_kk IS DISTINCT FROM NEW.status_kk THEN
      v_payload := jsonb_build_object(
        'status_lama', OLD.status_kk,
        'status_baru', NEW.status_kk
      );
      PERFORM publish_event('keluarga.status.berubah', 'keluarga', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan data lain
    IF OLD.nomor_kk IS DISTINCT FROM NEW.nomor_kk
       OR OLD.kepala_keluarga IS DISTINCT FROM NEW.kepala_keluarga
       OR OLD.dusun IS DISTINCT FROM NEW.dusun
       OR OLD.rt IS DISTINCT FROM NEW.rt
       OR OLD.rw IS DISTINCT FROM NEW.rw THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nomor_kk', jsonb_build_array(OLD.nomor_kk, NEW.nomor_kk),
          'kepala_keluarga', jsonb_build_array(OLD.kepala_keluarga, NEW.kepala_keluarga)
        )
      );
      PERFORM publish_event('keluarga.data.berubah', 'keluarga', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_keluarga_publish_event ON public.keluarga;
CREATE TRIGGER trg_keluarga_publish_event
  AFTER INSERT OR UPDATE ON public.keluarga
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_keluarga_event();

-- ============================================================
-- 4. POSYANDU_AGREGAT — Emit posyandu.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_posyandu_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'bulan', NEW.bulan,
      'jumlah_bayi', NEW.jumlah_bayi,
      'jumlah_balita', NEW.jumlah_balita,
      'jumlah_ibu_hamil', NEW.jumlah_ibu_hamil,
      'jumlah_ibu_menyusui', NEW.jumlah_ibu_menyusui,
      'kunjugan_lebih_dari_sekali', NEW.kunjugan_lebih_dari_sekali
    );
    PERFORM publish_event('posyandu.kunjungan.dicatat', 'posyandu_agregat', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    -- Deteksi balita terindikasi gizi buruk
    IF NEW.jumlah_gizi_buruk > OLD.jumlah_gizi_buruk THEN
      v_payload := jsonb_build_object(
        'bulan', NEW.bulan,
        'jumlah_gizi_buruk', NEW.jumlah_gizi_buruk,
        'penambahan', NEW.jumlah_gizi_buruk - OLD.jumlah_gizi_buruk
      );
      PERFORM publish_event('posyandu.balita.terindikasi_gizi_buruk', 'posyandu_agregat', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_posyandu_agregat_publish_event ON public.posyandu_agregat;
CREATE TRIGGER trg_posyandu_agregat_publish_event
  AFTER INSERT OR UPDATE ON public.posyandu_agregat
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_posyandu_event();

-- ============================================================
-- 5. APBDES — Emit apbdes.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_apbdes_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'tahun', NEW.tahun,
      'sumber_dana', NEW.sumber_dana,
      'total_anggaran', NEW.total_anggaran
    );
    PERFORM publish_event('apbdes.dibuat', 'apbdes', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'apbdes.disahkan';
      ELSE
        v_event_type := 'apbdes.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'tahun', NEW.tahun,
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'apbdes', NEW.id, v_payload, NEW.updated_by);
    END IF;

    -- Perubahan anggaran signifikan (>10%)
    IF OLD.total_anggaran IS DISTINCT FROM NEW.total_anggaran THEN
      IF NEW.total_anggaran > 0 AND OLD.total_anggaran > 0 THEN
        IF ABS(NEW.total_anggaran - OLD.total_anggaran) / OLD.total_anggaran > 0.1 THEN
          v_payload := jsonb_build_object(
            'tahun', NEW.tahun,
            'anggaran_lama', OLD.total_anggaran,
            'anggaran_baru', NEW.total_anggaran
          );
          PERFORM publish_event('apbdes.anggaran.berubah_signifikan', 'apbdes', NEW.id, v_payload, NEW.updated_by);
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_apbdes_publish_event ON public.apbdes;
CREATE TRIGGER trg_apbdes_publish_event
  AFTER INSERT OR UPDATE ON public.apbdes
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_apbdes_event();

-- ============================================================
-- 6. BIDANG_TANAH — Emit bidang_tanah.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_bidang_tanah_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nomor_sertifikat', NEW.nomor_sertifikat,
      'jenis_tanah', NEW.jenis_tanah,
      'luas_m2', NEW.luas_m2,
      'lokasi', NEW.lokasi
    );
    PERFORM publish_event('bidang_tanah.didaftarkan', 'bidang_tanah', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status_sertifikat IS DISTINCT FROM NEW.status_sertifikat THEN
      CASE NEW.status_sertifikat
        WHEN 'tersertifikasi' THEN
          v_event_type := 'bidang_tanah.disahkan';
        WHEN 'dialihkan' THEN
          v_event_type := 'bidang_tanah.dialihkan';
        ELSE
          v_event_type := 'bidang_tanah.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status_sertifikat,
        'status_baru', NEW.status_sertifikat
      );
      PERFORM publish_event(v_event_type, 'bidang_tanah', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bidang_tanah_publish_event ON public.bidang_tanah;
CREATE TRIGGER trg_bidang_tanah_publish_event
  AFTER INSERT OR UPDATE ON public.bidang_tanah
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_bidang_tanah_event();

-- ============================================================
-- 7. BANTUAN_SOSIAL — Emit bansos.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_bansos_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_program', NEW.nama_program,
      'jenis_bantuan', NEW.jenis_bantuan,
      'sumber_dana', NEW.sumber_dana,
      'tahun', NEW.tahun
    );
    PERFORM publish_event('bansos.program.dibuat', 'bantuan_sosial', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      v_payload := jsonb_build_object(
        'nama_program', NEW.nama_program,
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event('bansos.program.status.berubah', 'bantuan_sosial', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bantuan_sosial_publish_event ON public.bantuan_sosial;
CREATE TRIGGER trg_bantuan_sosial_publish_event
  AFTER INSERT OR UPDATE ON public.bantuan_sosial
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_bansos_event();

-- ============================================================
-- 8. USULAN_WARGA — Emit usulan.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_usulan_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'judul', NEW.judul,
      'kategori', NEW.kategori,
      'lokasi', NEW.lokasi,
      'estimasi_anggaran', NEW.estimasi_anggaran,
      'pemohon_id', NEW.pemohon_id
    );
    PERFORM publish_event('usulan.diajukan', 'usulan_warga', NEW.id, v_payload, NEW.pemohon_id);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'usulan.lolos_verifikasi';
        WHEN 'ditolak' THEN
          v_event_type := 'usulan.ditolak';
        WHEN 'ditetapkan_rkpdes' THEN
          v_event_type := 'usulan.ditetapkan_rkpdes';
        ELSE
          v_event_type := 'usulan.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'judul', NEW.judul
      );
      PERFORM publish_event(v_event_type, 'usulan_warga', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usulan_warga_publish_event ON public.usulan_warga;
CREATE TRIGGER trg_usulan_warga_publish_event
  AFTER INSERT OR UPDATE ON public.usulan_warga
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_usulan_event();

-- ============================================================
-- 9. USULAN_VOTE — Emit usulan.vote.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_usulan_vote_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'usulan_id', NEW.usulan_id,
      'penduduk_id', NEW.penduduk_id,
      'suara', NEW.suara
    );
    PERFORM publish_event('usulan.vote.bertambah', 'usulan_vote', NEW.id, v_payload, NEW.penduduk_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usulan_vote_publish_event ON public.usulan_vote;
CREATE TRIGGER trg_usulan_vote_publish_event
  AFTER INSERT ON public.usulan_vote
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_usulan_vote_event();

-- ============================================================
-- 10. PBB_TAGIHAN — Emit pbb.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_pbb_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nop', NEW.nop,
      'njop', NEW.njop,
      'tagihan', NEW.tagihan,
      'tahun', NEW.tahun
    );
    PERFORM publish_event('pbb.objek_pajak.didaftarkan', 'pbb_tagihan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.nop IS DISTINCT FROM NEW.nop
       OR OLD.njop IS DISTINCT FROM NEW.njop
       OR OLD.alamat_objek IS DISTINCT FROM NEW.alamat_objek THEN
      v_payload := jsonb_build_object(
        'changes', jsonb_build_object(
          'nop', jsonb_build_array(OLD.nop, NEW.nop),
          'njop', jsonb_build_array(OLD.njop, NEW.njop)
        )
      );
      PERFORM publish_event('pbb.objek_pajak.berubah', 'pbb_tagihan', NEW.id, v_payload, NEW.updated_by);
    END IF;

    IF OLD.status_pembayaran IS DISTINCT FROM NEW.status_pembayaran THEN
      IF NEW.status_pembayaran = 'lunas' THEN
        v_event_type := 'pbb.tagihan.dibayar';
      ELSE
        v_event_type := 'pbb.tagihan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'tahun', NEW.tahun,
        'status_lama', OLD.status_pembayaran,
        'status_baru', NEW.status_pembayaran,
        'tagihan', NEW.tagihan
      );
      PERFORM publish_event(v_event_type, 'pbb_tagihan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_pbb_tagihan_publish_event ON public.pbb_tagihan;
CREATE TRIGGER trg_pbb_tagihan_publish_event
  AFTER INSERT OR UPDATE ON public.pbb_tagihan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_pbb_event();

-- ============================================================
-- 11. INFRASTRUKTUR — Emit infrastruktur.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_infrastruktur_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama', NEW.nama,
      'jenis', NEW.jenis,
      'lokasi', NEW.lokasi,
      'pengaju_id', NEW.pengaju_id
    );
    PERFORM publish_event('infrastruktur.dilaporkan', 'infrastruktur', NEW.id, v_payload, NEW.pengaju_id);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      CASE NEW.status
        WHEN 'terverifikasi' THEN
          v_event_type := 'infrastruktur.diverifikasi';
        WHEN 'disetujui' THEN
          v_event_type := 'infrastruktur.disetujui';
        WHEN 'ditolak' THEN
          v_event_type := 'infrastruktur.ditolak';
        ELSE
          v_event_type := 'infrastruktur.status.berubah';
      END CASE;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'infrastruktur', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_infrastruktur_publish_event ON public.infrastruktur;
CREATE TRIGGER trg_infrastruktur_publish_event
  AFTER INSERT OR UPDATE ON public.infrastruktur
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_infrastruktur_event();

-- ============================================================
-- 12. KEGIATAN_PEMBANGUNAN — Emit musdes.* events
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_kegiatan_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_kegiatan', NEW.nama_kegiatan,
      'lokasi', NEW.lokasi,
      'anggaran', NEW.anggaran,
      'sumber_dana', NEW.sumber_dana
    );
    PERFORM publish_event('musdes.kegiatan.ditambahkan', 'kegiatan_pembangunan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'musdes.kegiatan.disahkan';
      ELSE
        v_event_type := 'musdes.kegiatan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status,
        'nama_kegiatan', NEW.nama_kegiatan
      );
      PERFORM publish_event(v_event_type, 'kegiatan_pembangunan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_kegiatan_pembangunan_publish_event ON public.kegiatan_pembangunan;
CREATE TRIGGER trg_kegiatan_pembangunan_publish_event
  AFTER INSERT OR UPDATE ON public.kegiatan_pembangunan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_kegiatan_event();

-- ============================================================
-- 13. ADUAN_WARGA — Events sudah ada (trg_aduan_event)
--    tapi kita perlu extend untuk lebih detail
-- ============================================================

-- Trigger yang sudah ada sudah cukup untuk now
-- Comment: trg_aduan_event sudah dibuat di migration sebelumnya

-- ============================================================
-- 14. RKPDES_KEGIATAN — Emit ke domain_events untuk sync
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_publish_rkpdes_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_type VARCHAR(100);
  v_payload JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_payload := jsonb_build_object(
      'nama_kegiatan', NEW.nama_kegiatan,
      'tahun', NEW.tahun,
      'anggaran', NEW.anggaran
    );
    PERFORM publish_event('rkpdes.kegiatan.diajukan', 'rkpdes_kegiatan', NEW.id, v_payload, NEW.created_by);

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      IF NEW.status = 'disahkan' THEN
        v_event_type := 'rkpdes.kegiatan.disahkan';
      ELSE
        v_event_type := 'rkpdes.kegiatan.status.berubah';
      END IF;

      v_payload := jsonb_build_object(
        'status_lama', OLD.status,
        'status_baru', NEW.status
      );
      PERFORM publish_event(v_event_type, 'rkpdes_kegiatan', NEW.id, v_payload, NEW.updated_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_rkpdes_kegiatan_publish_event ON public.rkpdes_kegiatan;
CREATE TRIGGER trg_rkpdes_kegiatan_publish_event
  AFTER INSERT OR UPDATE ON public.rkpdes_kegiatan
  FOR EACH ROW EXECUTE FUNCTION trigger_publish_rkpdes_event();

-- ============================================================
-- 15. Update event_type enum dengan event baru
-- ============================================================

DO $$
BEGIN
  -- Tambah event types yang belum ada
  -- Enum tidak bisa di-alter di PostgreSQL, jadi kita skip
  -- dan cukup gunakan VARCHAR untuk event_type di domain_events
  -- (sudah didefinisikan sebagai VARCHAR di 003_domain_events.sql)
  RAISE NOTICE 'Event types extension not needed - using VARCHAR for flexibility';
END $$;

-- ============================================================
-- 16. Tambahan: Emit tenant_id di semua event
--    (jika belum ada di function publish_event)
-- ============================================================

-- Update publish_event untuk include tenant_id dari context
CREATE OR REPLACE FUNCTION publish_event(
  p_event_type VARCHAR,
  p_entity_type VARCHAR,
  p_entity_id UUID,
  p_payload JSONB DEFAULT '{}',
  p_aktor_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
  v_tenant_id UUID;
BEGIN
  -- Try to get tenant_id from auth.jwt() or app settings
  BEGIN
    v_tenant_id := current_setting('app.current_tenant_id', true)::UUID;
  EXCEPTION WHEN OTHERS THEN
    v_tenant_id := NULL;
  END;

  -- If still null, try to infer from entity (for entities with tenant_id)
  IF v_tenant_id IS NULL THEN
    BEGIN
      EXECUTE format('SELECT tenant_id FROM public.%I WHERE id = %L', p_entity_type, p_entity_id)
      INTO v_tenant_id;
    EXCEPTION WHEN OTHERS THEN
      v_tenant_id := NULL;
    END;
  END IF;

  INSERT INTO domain_events (tenant_id, event_type, entity_type, entity_id, payload, aktor_id)
  VALUES (v_tenant_id, p_event_type, p_entity_type, p_entity_id, p_payload, p_aktor_id)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION publish_event IS
'Publish a domain event with automatic tenant_id resolution.
Returns event ID. Usage: SELECT publish_event(''penduduk.dibuat'', ''penduduk'', entity_uuid, ''{"nik":"..."}''::jsonb, auth.uid())';

-- ============================================================
-- 17. Add event counters untuk analytics cepat
-- ============================================================

DO $$
BEGIN
  -- Add counters untuk dashboard (optional enhancement)
  -- Bisa di-trigger manual atau via cron

  RAISE NOTICE 'Domain event triggers migration completed successfully';
END $$;
