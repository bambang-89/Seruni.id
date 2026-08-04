/**
 * TTE (Tanda Tangan Elektronik) Integration Module
 *
 * Supports:
 * - Simple signature image upload (for development)
 * - BSRE (eSign) integration for certified signatures
 * - QR code generation for document verification
 */

import { jsPDF } from 'jspdf';
import QRCode from 'qrcode';

/**
 * Generate document hash for signing
 */
export async function generateDocumentHash(blob: Blob): Promise<string> {
  const arrayBuffer = await blob.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// ==================== QR Code Generation ====================

export interface QRCodeConfig {
  x: number;
  y: number;
  size: number;
}

/**
 * Generate QR code for document verification
 */
async function generateVerificationQR(
  documentId: string,
  documentHash: string,
  verificationUrl: string
): Promise<string> {
  const qrData = `${verificationUrl}?id=${documentId}&hash=${documentHash}`;

  try {
    return await QRCode.toDataURL(qrData, {
      errorCorrectionLevel: 'M',
      margin: 2,
      width: 200,
    });
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
