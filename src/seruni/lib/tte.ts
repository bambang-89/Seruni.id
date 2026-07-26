/**
 * TTE (Tanda Tangan Elektronik) Integration Module
 *
 * Supports:
 * - Simple signature image upload (for development)
 * - BSRE (eSign) integration for certified signatures
 * - QR code generation for document verification
 */

import { jsPDF } from 'jspdf';

// TTE Types
export type TTETipe = 'sederhana' | 'bsre' | 'esign';
export type TTETStatus = 'pending' | 'signed' | 'verified' | 'expired' | 'rejected';

export interface TTESignature {
  id: string;
  surat_id: string;
  tipe: TTETipe;
  status: TTETStatus;
  signed_by: string;
  signed_at: string;
  signature_hash: string;
  certificate_id?: string;
  ttd_image_url?: string;
  qr_code_url?: string;
  metadata?: Record<string, any>;
}

export interface TTESignRequest {
  surat_id: string;
  tipe: TTETipe;
  document_hash: string;
  signer_name: string;
  signer_nip?: string;
  signer_role: string;
}

export interface TTEVerifyResult {
  valid: boolean;
  signature_hash: string;
  signed_at: string;
  signed_by: string;
  certificate_valid?: boolean;
  message?: string;
}

// ==================== BSRE/eSign Integration ====================

export interface BSREConfig {
  apiUrl: string;
  apiKey: string;
  callbackUrl?: string;
}

const BSRE_API_URL = 'https://api-esign.bsre.id'; // BSRE official API

/**
 * Generate document hash for signing
 */
export async function generateDocumentHash(blob: Blob): Promise<string> {
  const arrayBuffer = await blob.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Sign document with BSRE eSign
 */
export async function signWithBSRE(
  pdfBlob: Blob,
  signerName: string,
  signerNIP: string,
  config: BSREConfig
): Promise<{ signedPdfBlob: Blob; signatureId: string }> {
  // Step 1: Upload document to BSRE
  const formData = new FormData();
  formData.append('file', pdfBlob, 'document.pdf');
  formData.append('nik', signerNIP);
  formData.append('passphrase', ''); // Optional passphrase
  formData.append('tanggal', new Date().toISOString().split('T')[0]);
  formData.append('keterangan', `Dokumen ditandatangani secara elektronik`);

  const uploadResponse = await fetch(`${config.apiUrl}/v2.0/sign-doc/upload`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${config.apiKey}`,
    },
    body: formData,
  });

  if (!uploadResponse.ok) {
    throw new Error(`BSRE upload failed: ${uploadResponse.status}`);
  }

  const uploadResult = await uploadResponse.json();
  const documentId = uploadResult.data?.document_id;

  if (!documentId) {
    throw new Error('Failed to get document ID from BSRE');
  }

  // Step 2: Request signature
  const signResponse = await fetch(`${config.apiUrl}/v2.0/sign-doc/request`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${config.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      document_id: documentId,
      nik: signerNIP,
      passphrase: '',
      ttd: 'gambar',
      image抗日: true, // Include signature image
      halaman: 'last', // Sign on last page
      koordinat_x: 140,
      koordinat_y: 240,
      lebar: 30,
      tinggi: 15,
    }),
  });

  if (!signResponse.ok) {
    throw new Error(`BSRE sign request failed: ${signResponse.status}`);
  }

  const signResult = await signResponse.json();
  const signatureId = signResult.data?.signature_id;

  // Step 3: Download signed document
  const downloadResponse = await fetch(`${config.apiUrl}/v2.0/sign-doc/download/${signatureId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${config.apiKey}`,
    },
  });

  if (!downloadResponse.ok) {
    throw new Error(`BSRE download failed: ${downloadResponse.status}`);
  }

  const signedBlob = await downloadResponse.blob();

  return { signedPdfBlob: signedBlob, signatureId };
}

// ==================== Simple Signature (Development) ====================

export interface SimpleSignatureConfig {
  x: number;  // X coordinate in mm
  y: number;  // Y coordinate in mm
  width: number;
  height: number;
  page: 'first' | 'last' | number;
}

/**
 * Add simple signature image to PDF
 */
export function addSimpleSignatureToPDF(
  pdf: jsPDF,
  signatureImageUrl: string,
  config: SimpleSignatureConfig
): Promise<void> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      try {
        pdf.addImage(
          signatureImageUrl,
          'PNG',
          config.x,
          config.y,
          config.width,
          config.height
        );
        resolve();
      } catch (err) {
        reject(err);
      }
    };
    img.onerror = () => reject(new Error('Failed to load signature image'));
    img.src = signatureImageUrl;
  });
}

/**
 * Add signature line with name and title
 */
export function addSignatureBlock(
  pdf: jsPDF,
  x: number,
  y: number,
  signerName: string,
  signerTitle: string,
  nip?: string
) {
  pdf.setFontSize(10);

  // Title
  pdf.text(signerTitle, x, y);
  pdf.text(signerName, x, y + 10);

  if (nip) {
    pdf.text(`NIP. ${nip}`, x, y + 15);
  }
}

// ==================== QR Code Generation ====================

export interface QRCodeConfig {
  x: number;
  y: number;
  size: number;
}

/**
 * Generate QR code for document verification
 * Uses a simple approach - in production, use a proper QR library
 */
export async function generateVerificationQR(
  documentId: string,
  documentHash: string,
  verificationUrl: string
): Promise<string> {
  // QR data contains verification URL and document hash
  const qrData = `${verificationUrl}?id=${documentId}&hash=${documentHash}`;

  // Use an external QR code API (for production, use local library)
  // This creates a data URL for the QR code image
  const qrApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrData)}`;

  try {
    const response = await fetch(qrApiUrl);
    const blob = await response.blob();
    return await blobToBase64(blob);
  } catch (err) {
    console.error('QR generation failed:', err);
    return '';
  }
}

/**
 * Add QR code to PDF
 */
export async function addQRCodeToPDF(
  pdf: jsPDF,
  documentId: string,
  documentHash: string,
  verificationUrl: string,
  config: QRCodeConfig
): Promise<void> {
  const qrDataUrl = await generateVerificationQR(documentId, documentHash, verificationUrl);

  if (qrDataUrl) {
    pdf.addImage(qrDataUrl, 'PNG', config.x, config.y, config.size, config.size);
  }
}

// ==================== Document Verification ====================

/**
 * Verify signed document
 */
export async function verifySignature(
  documentHash: string,
  signatureHash: string,
  signatureTime: string
): Promise<TTEVerifyResult> {
  // Check if document hash matches
  const hashValid = documentHash === signatureHash;

  // Check if signature is not expired (365 days default)
  const signedDate = new Date(signatureTime);
  const now = new Date();
  const daysSinceSigned = (now.getTime() - signedDate.getTime()) / (1000 * 60 * 60 * 24);
  const notExpired = daysSinceSigned < 365;

  return {
    valid: hashValid && notExpired,
    signature_hash: signatureHash,
    signed_at: signatureTime,
    signed_by: 'Verified Signer',
    certificate_valid: hashValid,
    message: !hashValid
      ? 'Document hash mismatch - document may have been modified'
      : !notExpired
        ? 'Signature has expired'
        : 'Document verified successfully',
  };
}

// ==================== Helper Functions ====================

function blobToBase64(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

/**
 * Create signature placeholder for unsigned documents
 */
export function createSignaturePlaceholder(pdf: jsPDF, x: number, y: number, width: number = 50) {
  pdf.setDrawColor(200, 200, 200);
  pdf.setLineDashPattern([2, 2], 0);
  pdf.line(x, y, x + width, y);
  pdf.setLineDashPattern([], 0);
}

// ==================== TTE Service for Supabase Edge Functions ====================

export interface TTEServiceConfig {
  supabaseUrl: string;
  supabaseKey: string;
  bsreConfig?: BSREConfig;
  verificationBaseUrl: string;
}

export class TTEService {
  private config: TTEServiceConfig;

  constructor(config: TTEServiceConfig) {
    this.config = config;
  }

  /**
   * Initialize TTE signing process
   */
  async initSigning(
    suratId: string,
    documentHash: string,
    signerInfo: { nama: string; nip?: string; role: string }
  ): Promise<TTESignature> {
    // Create TTE record in database
    const response = await fetch(`${this.config.supabaseUrl}/rest/v1/tte_signatures`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': this.config.supabaseKey,
        'Authorization': `Bearer ${this.config.supabaseKey}`,
      },
      body: JSON.stringify({
        surat_id: suratId,
        tipe: this.config.bsreConfig ? 'bsre' : 'sederhana',
        status: 'pending',
        signed_by: signerInfo.nama,
        signature_hash: documentHash,
        certificate_id: null,
        ttd_image_url: null,
        qr_code_url: null,
        metadata: {
          signer_role: signerInfo.role,
          signer_nip: signerInfo.nip,
          created_at: new Date().toISOString(),
        },
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to create TTE signature record');
    }

    return response.json();
  }

  /**
   * Complete TTE signing
   */
  async completeSigning(
    signatureId: string,
    signedPdfUrl: string,
    signatureImageUrl?: string,
    certificateId?: string
  ): Promise<void> {
    const qrUrl = await generateVerificationQR(
      signatureId,
      '', // Will be updated
      `${this.config.verificationBaseUrl}/verify/${signatureId}`
    );

    await fetch(`${this.config.supabaseUrl}/rest/v1/tte_signatures?id=eq.${signatureId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'apikey': this.config.supabaseKey,
        'Authorization': `Bearer ${this.config.supabaseKey}`,
      },
      body: JSON.stringify({
        status: 'signed',
        signed_at: new Date().toISOString(),
        ttd_image_url: signatureImageUrl,
        qr_code_url: qrUrl,
        certificate_id: certificateId,
        signed_pdf_url: signedPdfUrl,
      }),
    });
  }
}
