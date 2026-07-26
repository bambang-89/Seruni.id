-- Missing RPC functions for Seruni.id

-- 1. submit_usulan (submit warga suggestion)
CREATE OR REPLACE FUNCTION public.submit_usulan(
  p_judul TEXT,
  p_deskripsi TEXT,
  p_dusun TEXT,
  p_nama TEXT,
  p_kontak TEXT,
  p_kategori TEXT DEFAULT 'infrastruktur',
  p_lokasi TEXT DEFAULT NULL,
  p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO public.usulan_warga (
    tenant_id, judul, deskripsi, dusun, nama, kontak,
    kategori, lokasi, status, vote_count
  ) VALUES (
    COALESCE(p_tenant_id, (SELECT id FROM tenants LIMIT 1)),
    p_judul, p_deskripsi, p_dusun, p_nama, p_kontak,
    p_kategori, p_lokasi, 'diajukan', 0
  ) RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'status', 'submitted');
END;
$$;

-- 2. vote_usulan (voting on suggestion)
CREATE OR REPLACE FUNCTION public.vote_usulan(
  p_usulan_id UUID,
  p_dusun TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.usulan_vote (usulan_id, voter_hash, dusun)
  VALUES (p_usulan_id, encode(gen_random_bytes(16), 'hex'), COALESCE(p_dusun, 'anonim'));

  UPDATE public.usulan_warga
  SET vote_count = vote_count + 1
  WHERE id = p_usulan_id;

  RETURN jsonb_build_object('voted', true);
END;
$$;

-- 3. submit_aduan (complaint submission)
CREATE OR REPLACE FUNCTION public.submit_aduan(
  p_judul TEXT,
  p_isi TEXT,
  p_kategori TEXT,
  p_nama TEXT,
  p_kontak TEXT,
  p_lokasi TEXT DEFAULT NULL,
  p_dusun TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
  v_nomor TEXT;
BEGIN
  INSERT INTO public.aduan_warga (
    tenant_id, judul, isi, kategori, nama_pelapor, kontak, lokasi, dusun, status
  ) VALUES (
    (SELECT id FROM tenants LIMIT 1),
    p_judul, p_isi, p_kategori, p_nama, p_kontak, p_lokasi, p_dusun, 'diajukan'
  ) RETURNING id, nomor_tiket INTO v_id, v_nomor;

  RETURN jsonb_build_object('id', v_id, 'nomor_tiket', v_nomor, 'status', 'submitted');
END;
$$;

-- 4. vote_topik (voting on voting_topik)
CREATE OR REPLACE FUNCTION public.vote_topik(
  p_topik_id UUID,
  p_opsi_id UUID,
  p_dusun TEXT DEFAULT NULL,
  p_single_choice BOOLEAN DEFAULT true
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_hash TEXT;
BEGIN
  v_hash := encode(gen_random_bytes(16), 'hex');

  IF p_single_choice THEN
    DELETE FROM voting_suara WHERE topik_id = p_topik_id;
  END IF;

  INSERT INTO voting_suara (topik_id, opsi_id, voter_hash, dusun)
  VALUES (p_topik_id, p_opsi_id, v_hash, COALESCE(p_dusun, 'anonim'));

  -- sync counts
  UPDATE voting_opsi o SET jumlah_suara = (
    SELECT count(*)::int FROM voting_suara WHERE opsi_id = o.id
  ) WHERE o.topik_id = p_topik_id;

  UPDATE voting_topik t SET total_suara = (
    SELECT count(*)::int FROM voting_suara WHERE topik_id = t.id
  ) WHERE t.id = p_topik_id;

  RETURN jsonb_build_object('voted', true, 'hash', v_hash);
END;
$$;

-- 5. submit_surat (surat request)
CREATE OR REPLACE FUNCTION public.submit_surat(
  p_jenis_surat TEXT,
  p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
  v_nomor TEXT;
BEGIN
  v_nomor := 'SRV-' || to_char(NOW(), 'YYYYMMDD') || '-' || encode(gen_random_bytes(4), 'hex');
  INSERT INTO public.surat_terbit (
    tenant_id, jenis, status, nomor
  ) VALUES (
    COALESCE(p_tenant_id, (SELECT id FROM tenants LIMIT 1)),
    p_jenis_surat, 'diajukan', v_nomor
  ) RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'nomor', v_nomor, 'status', 'submitted');
END;
$$;

-- 6. wa_broadcast (queue WA message)
CREATE OR REPLACE FUNCTION public.wa_broadcast(
  p_judul TEXT,
  p_pesan TEXT,
  p_topik TEXT DEFAULT 'broadcast',
  p_dusun_filter TEXT DEFAULT NULL,
  p_action TEXT DEFAULT 'send',
  p_broadcast_id UUID DEFAULT NULL,
  p_target_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF p_action = 'retry' AND p_target_id IS NOT NULL THEN
    UPDATE wa_broadcast_target
    SET attempt = attempt + 1, status = 'antre', error_message = NULL
    WHERE id = p_target_id;
    RETURN jsonb_build_object('retried', true, 'target_id', p_target_id);
  END IF;

  IF p_action = 'send' AND p_broadcast_id IS NOT NULL THEN
    RETURN jsonb_build_object('queued', true, 'broadcast_id', p_broadcast_id);
  END IF;

  RETURN jsonb_build_object('queued', true);
END;
$$;
