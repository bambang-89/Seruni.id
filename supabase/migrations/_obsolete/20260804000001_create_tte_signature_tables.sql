-- Migration: 20260804000001_create_tte_signature_tables.sql
-- Creates tables for TTE (Tanda Tangan Elektronik) signature tracking

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- TTE Signature tracking table
CREATE TABLE IF NOT EXISTS tte_signatures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    surat_id UUID REFERENCES surat_terbit(id) ON DELETE CASCADE,
    surat_ajuan_id UUID REFERENCES surat_ajuan(id) ON DELETE SET NULL,

    -- Signature type and status
    tipe VARCHAR(20) NOT NULL DEFAULT 'sederhana' CHECK (tipe IN ('sederhana', 'bsre', 'esign')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'signed', 'verified', 'expired', 'rejected')),

    -- Signer information
    signed_by VARCHAR(255) NOT NULL,
    signer_role VARCHAR(100),
    signer_nip VARCHAR(50),
    signed_at TIMESTAMPTZ,

    -- Signature data
    signature_hash VARCHAR(128),
    certificate_id VARCHAR(255),
    ttd_image_url TEXT,

    -- Document URLs
    original_pdf_url TEXT,
    signed_pdf_url TEXT,
    qr_code_url TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Audit columns
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),

    -- Constraints
    CONSTRAINT unique_surat_signature UNIQUE (surat_id)
);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_tte_signatures_surat ON tte_signatures(surat_id);
CREATE INDEX IF NOT EXISTS idx_tte_signatures_status ON tte_signatures(status);
CREATE INDEX IF NOT EXISTS idx_tte_signatures_tenant ON tte_signatures(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tte_signatures_signed_at ON tte_signatures(signed_at);

-- Add RLS policies for tte_signatures
ALTER TABLE tte_signatures ENABLE ROW LEVEL SECURITY;

-- Admin users can view and manage all signatures
CREATE POLICY "Admin can view all tte_signatures"
    ON tte_signatures FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role = 'admin'::public.app_role
        )
    );

CREATE POLICY "Admin can insert tte_signatures"
    ON tte_signatures FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role = 'admin'::public.app_role
        )
    );

CREATE POLICY "Admin can update tte_signatures"
    ON tte_signatures FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role = 'admin'::public.app_role
        )
    );

-- Tenant-scoped policies
CREATE POLICY "Users can view own tenant signatures"
    ON tte_signatures FOR SELECT
    TO authenticated
    USING (tenant_id = get_tenant_id());

-- Add columns to surat_terbit for TTE integration
ALTER TABLE surat_terbit
    ADD COLUMN IF NOT EXISTS tte_signature_id UUID REFERENCES tte_signatures(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS signed_pdf_url TEXT,
    ADD COLUMN IF NOT EXISTS qr_code_url TEXT,
    ADD COLUMN IF NOT EXISTS signed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS signed_by VARCHAR(255);

-- Add columns to surat_ajuan for TTE tracking
ALTER TABLE surat_ajuan
    ADD COLUMN IF NOT EXISTS tte_signature_id UUID REFERENCES tte_signatures(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS tte_status VARCHAR(20) DEFAULT 'pending' CHECK (tte_status IN ('pending', 'requested', 'signed', 'verified', 'expired', 'rejected')),
    ADD COLUMN IF NOT EXISTS tte_requested_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS tte_signed_at TIMESTAMPTZ;

-- Add trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tte_signatures_updated_at
    BEFORE UPDATE ON tte_signatures
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to verify TTE signature
CREATE OR REPLACE FUNCTION verify_tte_signature(
    p_signature_id UUID,
    p_document_hash VARCHAR(128)
)
RETURNS TABLE (
    valid BOOLEAN,
    signature_hash VARCHAR(128),
    signed_at TIMESTAMPTZ,
    signed_by VARCHAR(255),
    certificate_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_sig tte_signatures%ROWTYPE;
    v_days_valid INTEGER := 365;
BEGIN
    SELECT * INTO v_sig FROM tte_signatures WHERE id = p_signature_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE,
            NULL::VARCHAR,
            NULL::TIMESTAMPTZ,
            NULL::VARCHAR,
            FALSE,
            'Signature not found'::TEXT;
        RETURN;
    END IF;

    IF v_sig.status = 'rejected' THEN
        RETURN QUERY SELECT
            FALSE,
            v_sig.signature_hash,
            v_sig.signed_at,
            v_sig.signed_by,
            FALSE,
            'Signature has been rejected'::TEXT;
        RETURN;
    END IF;

    IF v_sig.status = 'expired' OR v_sig.signed_at < NOW() - (v_days_valid || ' days')::INTERVAL THEN
        RETURN QUERY SELECT
            FALSE,
            v_sig.signature_hash,
            v_sig.signed_at,
            v_sig.signed_by,
            FALSE,
            'Signature has expired'::TEXT;
        RETURN;
    END IF;

    IF p_document_hash IS NOT NULL AND v_sig.signature_hash IS NOT NULL AND p_document_hash != v_sig.signature_hash THEN
        RETURN QUERY SELECT
            FALSE,
            v_sig.signature_hash,
            v_sig.signed_at,
            v_sig.signed_by,
            FALSE,
            'Document hash mismatch - document may have been modified'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT
        TRUE,
        v_sig.signature_hash,
        v_sig.signed_at,
        v_sig.signed_by,
        TRUE,
        'Document verified successfully'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON tte_signatures TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

COMMENT ON TABLE tte_signatures IS 'Tracks electronic signature (TTE) for surat';
COMMENT ON COLUMN tte_signatures.tipe IS 'Signature type: sederhana (simple image), bsre (BSRE eSign), esign (third-party)';
COMMENT ON COLUMN tte_signatures.status IS 'Signature status: pending, signed, verified, expired, rejected';
