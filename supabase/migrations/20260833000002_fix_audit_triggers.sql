CREATE OR REPLACE FUNCTION public.enforce_append_only_surat()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Log UPDATE as audit
  INSERT INTO audit_surat_terbit (
    tenant_id, surat_id, aksi, nomor_surat, jenis,
    status_lama, status_baru, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    NEW.nomor_surat, NEW.jenis_nama,
    OLD.status, NEW.status,
    jsonb_build_object(
      'old', to_jsonb(OLD),
      'new', to_jsonb(NEW)
    ),
    COALESCE(NEW.updated_by, auth.uid())
  );

  -- Log to generic audit
  PERFORM log_audit(
    'surat_terbit',
    NEW.id,
    TG_OP,
    to_jsonb(OLD),
    to_jsonb(NEW),
    'Surat ' || COALESCE(NEW.nomor_surat, NEW.id::text) || ' - Status: ' || COALESCE(NEW.status, 'unknown')
  );

  -- Prevent UPDATE/DELETE on certain fields after published
  IF OLD.status = 'diterbitkan' AND TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION 'Surat yang sudah diterbitkan tidak dapat diubah! Hubungi administrator untuk koreksi.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_surat_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_surat_terbit (
    tenant_id, surat_id, aksi, nomor_surat, jenis, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    NEW.id, 'INSERT',
    NEW.nomor_surat, NEW.jenis_nama,
    to_jsonb(NEW),
    COALESCE(NEW.created_by, auth.uid())
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_append_only_voting_suara()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_voting (
    tenant_id, suara_id, aksi, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    auth.uid()
  );

  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    RAISE EXCEPTION 'Suara voting tidak dapat diubah atau dihapus! Satu warga = satu suara.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_append_only_voting_topik()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_voting (
    tenant_id, topik_id, aksi, payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    NEW.id, TG_OP,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    auth.uid()
  );

  -- Prevent status change from 'ditutup' to anything else
  IF OLD.status = 'ditutup' AND NEW.status != 'ditutup' THEN
    RAISE EXCEPTION 'Voting yang sudah ditutup tidak dapat dibuka kembali!';
  END IF;

  -- Prevent delete of closed voting
  IF OLD.status = 'ditutup' AND TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Voting yang sudah ditutup tidak dapat dihapus!';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_append_only_usulan_vote()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    RAISE EXCEPTION 'Vote pada usulan tidak dapat diubah atau dihapus!';
  END IF;

  -- Log INSERT
  INSERT INTO audit_trail (
    tenant_id, entitas, entitas_id, aksi, payload_baru, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    'usulan_vote',
    NEW.id,
    'INSERT',
    to_jsonb(NEW),
    auth.uid()
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_append_only_apbdes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_keuangan (
    tenant_id, apbdes_id, aksi, tahun,
    sumber_dana_lama, sumber_dana_baru,
    anggaran_lama, anggaran_baru,
    payload, actor_id
  ) VALUES (
    COALESCE(NEW.tenant_id, OLD.tenant_id, (SELECT id FROM tenants LIMIT 1)),
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    COALESCE(NEW.tahun, OLD.tahun),
    OLD.sumber_dana, NEW.sumber_dana,
    OLD.total_anggaran, NEW.total_anggaran,
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
    COALESCE(NEW.updated_by, OLD.created_by, auth.uid())
  );

  -- Log to generic audit
  PERFORM log_audit(
    'apbdes',
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    to_jsonb(OLD),
    to_jsonb(NEW),
    'APBDes tahun ' || COALESCE(NEW.tahun::TEXT, OLD.tahun::TEXT)
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_append_only_bidang_tanah()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    -- Convert to soft delete
    UPDATE public.bidang_tanah
    SET status_sertifikat = 'dialihkan',
        updated_at = now()
    WHERE id = OLD.id;

    PERFORM log_audit(
      'bidang_tanah',
      OLD.id,
      'SOFT_DELETE',
      to_jsonb(OLD),
      NULL,
      'Bidang tanah dialihkan (soft delete)'
    );

    RETURN NULL; -- Don't actually delete
  END IF;

  -- Log update
  PERFORM log_audit(
    'bidang_tanah',
    NEW.id,
    'UPDATE',
    to_jsonb(OLD),
    to_jsonb(NEW),
    'Bidang tanah ' || COALESCE(NEW.nomor_sertifikat, NEW.id::text)
  );

  -- Prevent changes to certified land
  IF OLD.status_sertifikat = 'tersertifikasi' AND NEW.status_sertifikat != OLD.status_sertifikat THEN
    RAISE EXCEPTION 'Tanah yang sudah tersertifikasi tidak dapat mengubah status!';
  END IF;

  RETURN NEW;
END;
$$;

