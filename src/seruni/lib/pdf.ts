/**
 * PDF Generation Service for Surat
 * Server-side PDF generation for official documents
 */

import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import type { SuratPreviewData } from '@/seruni/components/SuratPreview';
import { addQRCodeToPDF } from './tte';

export interface PDFOptions {
  format?: 'A4' | 'Letter';
  orientation?: 'portrait' | 'landscape';
  margin?: { top: number; right: number; bottom: number; left: number };
  quality?: number;
}

const DEFAULT_OPTIONS: Required<PDFOptions> = {
  format: 'A4',
  orientation: 'portrait',
  margin: { top: 20, right: 20, bottom: 20, left: 20 },
  quality: 2,
};

/**
 * Generate PDF from HTML element using html2canvas + jsPDF
 */
export async function generatePDFFromElement(
  element: HTMLElement,
  filename: string,
  options: PDFOptions = {}
): Promise<Blob> {
  const opts = { ...DEFAULT_OPTIONS, ...options };

  // Capture HTML as canvas
  const canvas = await html2canvas(element, {
    scale: opts.quality,
    useCORS: true,
    logging: false,
    backgroundColor: '#ffffff',
  });

  // Calculate PDF dimensions
  const imgData = canvas.toDataURL('image/png');
  const imgWidth = canvas.width;
  const imgHeight = canvas.height;

  // A4 dimensions in mm
  const pdfWidth = opts.format === 'A4' ? 210 : 215.9;
  const pdfHeight = opts.format === 'A4' ? 297 : 279.4;

  // Calculate ratio to fit image in PDF
  const ratio = Math.min(
    (pdfWidth - opts.margin.left - opts.margin.right) / imgWidth,
    (pdfHeight - opts.margin.top - opts.margin.bottom) / imgHeight
  );

  const finalWidth = imgWidth * ratio;
  const finalHeight = imgHeight * ratio;

  // Create PDF
  const pdf = new jsPDF({
    orientation: opts.orientation,
    unit: 'mm',
    format: opts.format === 'A4' ? 'a4' : 'letter',
  });

  // Center horizontally if content is narrower than page
  const xOffset = opts.margin.left + (pdfWidth - opts.margin.left - opts.margin.right - finalWidth) / 2;

  pdf.addImage(imgData, 'PNG', xOffset, opts.margin.top, finalWidth, finalHeight);

  return pdf.output('blob');
}

/**
 * Generate PDF from structured surat data
 */
export async function generatePDFFromData(
  data: SuratPreviewData,
  options: PDFOptions = {}
): Promise<Blob> {
  const opts = { ...DEFAULT_OPTIONS, ...options };

  const pdf = new jsPDF({
    orientation: opts.orientation,
    unit: 'mm',
    format: opts.format === 'A4' ? 'a4' : 'letter',
  });

  const pageWidth = pdf.internal.pageSize.getWidth();
  const pageHeight = pdf.internal.pageSize.getHeight();
  const contentWidth = pageWidth - opts.margin.left - opts.margin.right;
  let y = opts.margin.top;

  // Helper to add text with line wrapping
  const addText = (text: string, fontSize: number, isBold: boolean = false, align: 'left' | 'center' | 'right' = 'left') => {
    pdf.setFontSize(fontSize);
    pdf.setFont('helvetica', isBold ? 'bold' : 'normal');

    const lines = pdf.splitTextToSize(text, contentWidth);

    lines.forEach((line: string) => {
      if (y > pageHeight - opts.margin.bottom - 10) {
        pdf.addPage();
        y = opts.margin.top;
      }

      let x = opts.margin.left;
      if (align === 'center') x = pageWidth / 2;
      if (align === 'right') x = pageWidth - opts.margin.right;

      pdf.text(line, x, y, { align });
      y += fontSize * 0.4;
    });

    y += 2; // Small spacing
  };

  // Helper: check page break
  const checkY = (needed: number = 15) => {
    if (y > pageHeight - opts.margin.bottom - needed) {
      pdf.addPage();
      y = opts.margin.top;
    }
  };

  // === KOP HEADER ===
  const { template: tmpl, penduduk, dnaFields = [], dnaValues = {}, lampiran = [] } = data;

  // Logo placeholders (left and right)
  const logoSize = 15;
  const logoY = y;

  if (tmpl.kop.logo_kiri_url) {
    try {
      pdf.addImage(tmpl.kop.logo_kiri_url, 'PNG', opts.margin.left, logoY, logoSize, logoSize);
    } catch {
      // Skip if image fails to load
    }
  }

  if (tmpl.kop.logo_kanan_url) {
    try {
      pdf.addImage(tmpl.kop.logo_kanan_url, 'PNG', pageWidth - opts.margin.right - logoSize, logoY, logoSize, logoSize);
    } catch {
      // Skip if image fails to load
    }
  }

  // Institution names (centered)
  const centerX = pageWidth / 2;
  y = logoY + 3;
  addText(tmpl.kop.instansi || '', 10, true, 'center');
  addText(tmpl.kop.sub_instansi || '', 9, false, 'center');
  addText(tmpl.kop.nama_desa || '', 12, true, 'center');
  addText(tmpl.kop.alamat || '', 8, false, 'center');

  y += 5;

  // Border line
  if (tmpl.header.border_bottom_enabled) {
    pdf.setLineWidth(tmpl.header.border_bottom_width * 0.5);
    pdf.line(opts.margin.left, y, pageWidth - opts.margin.right, y);
    y += 8;
  }

  // === NOMOR SURAT ===
  addText(`Nomor: ${data.nomor_surat || 'Draft'}`, 10);
  const lampiranText = lampiran.length > 0 ? String(lampiran.length) : '-';
  addText(`Lampiran: ${lampiranText}`, 10);
  addText(`Perihal: ${data.data.perihal || data.jenis_surat}`, 10);

  y += 10;

  // === KEPADA ===
  addText(tmpl.tujuan_teks || 'Kepada Yth.', 10);
  addText(penduduk?.nama || '[Nama Pemohon]', 10, true);
  addText('di -', 10);
  addText('  Tempat', 10);

  y += 10;

  // === BODY ===
  addText(tmpl.pembuka_teks || 'Dengan hormat,', 10);
  y += 3;
  addText((tmpl.pengantar_teks || 'Berdasarkan permohonan dari pihak yang bersangkutan, bersama ini kami sampaikan [jenis_surat] atas nama:').replace('[jenis_surat]', data.jenis_surat), 10);

  y += 5;

  // Data pemohon table
  if (penduduk) {
    const tableData = [
      ['Nama', penduduk.nama],
      ['NIK', penduduk.nik],
      ['Tempat/Tgl Lahir', `${penduduk.tempat_lahir || '-'}, ${formatDate(penduduk.tanggal_lahir)}`],
      ['Jenis Kelamin', penduduk.jenis_kelamin || '-'],
      ['Alamat', penduduk.alamat || '-'],
      ['Pekerjaan', penduduk.pekerjaan || '-'],
      ['Agama', penduduk.agama || '-'],
      ['Status Perkawinan', penduduk.status_kawin || '-'],
    ];

    tableData.forEach(([label, value]) => {
      checkY(7);
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'bold');
      pdf.text(`${label}:`, opts.margin.left + 5, y);
      pdf.setFont('helvetica', 'normal');
      pdf.text(value, opts.margin.left + 40, y);
      y += 5;
    });
  }

  // === DNA FIELDS (render per grup) ===
  if (dnaFields.length > 0) {
    y += 5;
    checkY(8);

    // Group fields by grup
    const groups: Record<string, typeof dnaFields> = {};
    for (const f of dnaFields) {
      const g = f.grup || 'Keterangan';
      if (!groups[g]) groups[g] = [];
      groups[g].push(f);
    }

    for (const [grup, fields] of Object.entries(groups)) {
      checkY(8);
      // Section header (bold)
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'bold');
      pdf.text(grup, opts.margin.left, y);
      y += 5;

      for (const field of fields) {
        const val = dnaValues[field.field_name];
        if (val === null || val === undefined || val === '') continue;

        checkY(7);
        pdf.setFontSize(10);
        pdf.setFont('helvetica', 'bold');
        pdf.text(`${field.label}:`, opts.margin.left + 5, y);
        pdf.setFont('helvetica', 'normal');
        const valStr = Array.isArray(val) ? val.join(', ') : String(val);
        const valLines = pdf.splitTextToSize(valStr, contentWidth - 45);
        pdf.text(valLines, opts.margin.left + 45, y);
        y += valLines.length * 5 + 2;
      }
      y += 3;
    }
  }

  // === LAMPIRAN ===
  if (lampiran.length > 0) {
    y += 5;
    checkY(8);
    pdf.setFontSize(10);
    pdf.setFont('helvetica', 'bold');
    pdf.text('Lampiran:', opts.margin.left, y);
    y += 5;
    pdf.setFont('helvetica', 'normal');
    lampiran.forEach((_, i) => {
      checkY(6);
      pdf.text(`${i + 1}.`, opts.margin.left + 5, y);
      y += 5;
    });
  }

  // Isi surat
  y += 5;
  const isiSurat = data.data.isi || 'Surat keterangan ini dibuat untuk keperluan administrasi desa.';
  checkY(8);
  addText(isiSurat, 10);

  y += 5;

  // Penutup
  checkY(8);
  addText('Demikian surat keterangan ini dibuat dengan sebenarnya dan agar dapat digunakan sebagaimana mestinya.', 10);

  y += 15;

  // === TANDA TANGAN ===
  const ttdX = pageWidth - opts.margin.right - 60;
  const ttdY = y;

  checkY(40);
  pdf.setFontSize(10);
  pdf.text(formatDateLong(data.tanggal_surat), ttdX, ttdY);
  pdf.text(`${tmpl.footer.ttd_kanan_judul},`, ttdX, ttdY + 10);

  // Signature image if available
  const ttdImageUrl = tmpl.footer.ttd_image_url || data.data.ttd_image_url;
  if (ttdImageUrl) {
    try {
      pdf.addImage(ttdImageUrl, 'PNG', ttdX - 5, ttdY + 15, 50, 20);
    } catch {
      pdf.text('(................................)', ttdX, ttdY + 20);
    }
  } else {
    pdf.text('(................................)', ttdX, ttdY + 20);
  }

  y = ttdY + 40;
  pdf.setFont('helvetica', 'bold');
  const ttdNama = tmpl.footer.ttd_nama || data.data.ttd_nama || '(Nama Kades)';
  pdf.text(ttdNama, ttdX, y);

  const ttdNip = tmpl.footer.ttd_nip || data.data.ttd_nip;
  if (ttdNip) {
    y += 5;
    pdf.setFont('helvetica', 'normal');
    pdf.text(`NIP. ${ttdNip}`, ttdX, y);
  }

  // QR Code from pamong
  if (tmpl.footer.ttd_kanan_enabled) {
    const documentId = data.surat_id || 'draft';
    const documentHash = 'none'; // Will be real hash when integrated
    // e.g. https://seruni.id/layanan/verify/xyz
    const verificationUrl = window.location.origin + '/layanan/verify/' + documentId;
    
    try {
      await addQRCodeToPDF(pdf, documentId, documentHash, verificationUrl, {
        x: pageWidth - opts.margin.right - 20,
        y: pageHeight - opts.margin.bottom - 25,
        size: 20
      });
    } catch (qrErr) {
      console.warn('Failed to generate QR code on PDF:', qrErr);
    }
  }

  return pdf.output('blob');
}

/**
 * Download PDF as file
 */
export function downloadPDF(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

/**
 * Upload PDF to Supabase storage
 */
export async function uploadPDFToStorage(
  blob: Blob,
  path: string,
  supabaseClient: any
): Promise<string | null> {
  try {
    const { data, error } = await supabaseClient.storage
      .from('seruni-media')
      .upload(path, blob, {
        contentType: 'application/pdf',
        upsert: true,
      });

    if (error) {
      console.error('Upload PDF failed:', error);
      return null;
    }

    const { data: urlData } = supabaseClient.storage
      .from('seruni-media')
      .getPublicUrl(data.path);

    return urlData.publicUrl;
  } catch (err) {
    console.error('Upload PDF error:', err);
    return null;
  }
}

// === Helper Functions ===

function formatDate(dateStr: string): string {
  if (!dateStr) return '-';
  const date = new Date(dateStr);
  return date.toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

function formatDateLong(dateStr: string): string {
  return formatDate(dateStr);
}
