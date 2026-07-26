/**
 * Surat Preview Component
 * Preview surat dengan template sebelum di approve/reject
 * Supports PDF generation and TTE (Tanda Tangan Elektronik)
 */

import { useState, useEffect, useRef, useCallback } from 'react';
import { toast } from 'sonner';
import { supabase } from '@/integrations/supabase/client';
import { useIdentitasDesa } from '@/seruni/lib/queries';
import { generatePDFFromElement, generatePDFFromData, downloadPDF } from '@/seruni/lib/pdf';
import { generateDocumentHash, addQRCodeToPDF } from '@/seruni/lib/tte';

export type SuratDNAFieldDef = {
  field_name: string;
  label: string;
  tipe: string;
  grup: string;
};

export type SuratPreviewData = {
  surat_id: string;
  nomor_surat: string;
  jenis_surat: string;
  tanggal_surat: string;
  tanggal_cetak: string;
  /** DNA field definitions + values for PDF rendering */
  dnaFields?: SuratDNAFieldDef[];
  dnaValues?: Record<string, unknown>;
  /** Lampiran list for PDF */
  lampiran?: string[];

  penduduk?: {
    nama: string;
    nik: string;
    tempat_lahir: string;
    tanggal_lahir: string;
    jenis_kelamin: string;
    alamat: string;
    pekerjaan: string;
    agama: string;
    status_kawin: string;
    no_kk: string;
    foto_url?: string;
  };

  template: {
    kop: {
      logo_kiri_url?: string;
      logo_kanan_url?: string;
      instansi: string;
      sub_instansi: string;
      nama_desa: string;
      alamat: string;
    };
    header: {
      height: number;
      background_color: string;
      border_bottom_enabled: boolean;
      border_bottom_style: string;
      border_bottom_width: number;
    };
    footer: {
      ttd_kanan_enabled: boolean;
      ttd_kanan_judul: string;
      ttd_nama?: string;
      ttd_nip?: string;
      ttd_image_url?: string | null;
      qr_code_url?: string | null;
      pamong_id?: string | null;
    };
  };

  // Isi surat (from surat_terbit or surat_ajuan)
  data: Record<string, any>;
};

interface SuratPreviewProps {
  suratId: string;
  templateId?: string;
  data?: Record<string, any>;
  onApprove?: () => void;
  onReject?: (reason: string) => void;
  onClose?: () => void;
}

export function SuratPreview({
  suratId,
  templateId,
  data,
  onApprove,
  onReject,
  onClose,
}: SuratPreviewProps) {
  const { data: identitas } = useIdentitasDesa();
  const [previewData, setPreviewData] = useState<SuratPreviewData | null>(null);
  const [loading, setLoading] = useState(true);
  const [showRejectForm, setShowRejectForm] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [generatingPDF, setGeneratingPDF] = useState(false);
  const [signingTTE, setSigningTTE] = useState(false);
  const printRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadPreview();
  }, [loadPreview]);

  const loadPreview = useCallback(async () => {
    setLoading(true);
    try {
      // Get surat_terbit data
      const { data: surat } = await supabase
        .from('surat_terbit')
        .select(`
          *,
          penduduk:penduduk_id (
            nama, nik, tempat_lahir, tanggal_lahir, jenis_kelamin,
            alamat, pekerjaan, agama, status_kawin, foto_url,
            keluarga:keluarga_id (no_kk, alamat)
          )
        `)
        .eq('id', suratId)
        .single();

      if (surat) {
        // Get DNA data from surat_terbit_data
        let dnaValues: Record<string, unknown> = {};
        let dnaFields: SuratDNAFieldDef[] = [];
        if (surat.jenis_surat_id) {
          const [{ data: dnaRow }, { data: fields }] = await Promise.all([
            supabase.from('surat_terbit_data').select('data_dna').eq('surat_terbit_id', suratId).maybeSingle(),
            supabase.from('surat_jenis_dna').select('field_name, label, tipe, grup').eq('jenis_surat_id', surat.jenis_surat_id).order('urutan'),
          ]);
          dnaValues = dnaRow?.data_dna || {};
          dnaFields = (fields || []).map((f: any) => ({ field_name: f.field_name, label: f.label, tipe: f.tipe, grup: f.grup }));
        }

        // Get template
        let template = null;
        if (templateId) {
          const { data: t } = await supabase
            .from('surat_template')
            .select('*')
            .eq('id', templateId)
            .single();
          template = t;
        } else {
          // Get default template
          const { data: t } = await supabase
            .from('surat_template')
            .select('*')
            .eq('is_default', true)
            .single();
          template = t;
        }

        // Get pamong (penanda tangan) data
        let pamongData = null;
        const ttdOleh = surat.ttd_oleh || 'Kepala Desa';
        const { data: pamongRows } = await supabase
          .from('desa_pamong')
          .select('*')
          .eq('jabatan', ttdOleh)
          .eq('aktif', true)
          .limit(1);
        if (pamongRows && pamongRows.length > 0) {
          pamongData = pamongRows[0];
        } else {
          // Fallback: get first active pamong with ttd capability
          const { data: fallbackPamong } = await supabase
            .from('desa_pamong')
            .select('*')
            .eq('aktif', true)
            .order('urutan', { ascending: true })
            .limit(1);
          pamongData = fallbackPamong?.[0] || null;
        }

        setPreviewData({
          surat_id: surat.id,
          nomor_surat: surat.nomor_surat || 'Draft',
          jenis_surat: surat.jenis || surat.jenis_nama || '',
          tanggal_surat: surat.tanggal_terbit || new Date().toISOString(),
          tanggal_cetak: new Date().toISOString(),
          penduduk: surat.penduduk ? {
            nama: surat.penduduk.nama,
            nik: surat.penduduk.nik,
            tempat_lahir: surat.penduduk.tempat_lahir,
            tanggal_lahir: surat.penduduk.tanggal_lahir,
            jenis_kelamin: surat.penduduk.jenis_kelamin,
            alamat: surat.penduduk.alamat || surat.penduduk.keluarga?.alamat,
            pekerjaan: surat.penduduk.pekerjaan,
            agama: surat.penduduk.agama,
            status_kawin: surat.penduduk.status_kawin,
            no_kk: surat.penduduk.keluarga?.no_kk,
            foto_url: surat.penduduk.foto_url,
          } : undefined,
          dnaFields,
          dnaValues,
          lampiran: Array.isArray(surat.lampiran) ? surat.lampiran : [],
          template: {
            kop: template ? {
              logo_kiri_url: template.logo_kiri_url,
              logo_kanan_url: template.logo_kanan_url,
              instansi: template.judul_instansi_text,
              sub_instansi: template.sub_judul_instansi_text,
              nama_desa: template.nama_desa_text,
              alamat: template.alamat_desa_text,
            } : {
              logo_kiri_url: identitas?.logo_url,
              logo_kanan_url: identitas?.logo_url,
              instansi: 'PEMERINTAH KABUPATEN LOMBOK TIMUR',
              sub_instansi: 'KECAMATAN PRINGGABAYA',
              nama_desa: 'DESA SERUNI MUMBUL',
              alamat: 'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
            },
            header: {
              height: template?.header_height || 100,
              background_color: template?.header_background_color || '#FFFFFF',
              border_bottom_enabled: template?.header_border_bottom_enabled ?? true,
              border_bottom_style: template?.header_border_bottom_style || 'solid',
              border_bottom_width: template?.header_border_bottom_width || 2,
            },
            footer: {
              ttd_kanan_enabled: template?.footer_ttd_kanan_enabled ?? true,
              ttd_kanan_judul: template?.footer_ttd_kanan_judul || 'Kepala Desa',
              ttd_nama: pamongData?.nama || surat.ttd_nama || '..................',
              ttd_nip: pamongData?.nip || surat.ttd_nip || '',
              ttd_image_url: pamongData?.ttd_image_url || null,
              qr_code_url: pamongData?.qr_code_url || null,
              pamong_id: pamongData?.id || null,
            },
          },
          data: { ...data, ...surat },
        });
      }
    } catch (err) {
      console.error('Load preview failed:', err);
    } finally {
      setLoading(false);
    }
  }, [suratId, templateId, data, identitas]);

  const handlePrint = () => {
    const printContent = printRef.current;
    if (!printContent) return;

    const printWindow = window.open('', '_blank');
    if (!printWindow) return;

    printWindow.document.write(`
      <html>
        <head>
          <title>${previewData?.jenis_surat || 'Surat'}</title>
          <style>
            @page { size: A4; margin: 0; }
            body {
              font-family: 'Times New Roman', serif;
              font-size: 12pt;
              line-height: 1.5;
              margin: 0;
              padding: 0;
            }
            .kop { text-align: center; }
            .garis { border-bottom: 2px solid #000; margin: 0; }
            .nomor { margin: 20px 0 10px; }
            .body { margin: 20px 40px; text-align: justify; }
            .footer { margin-top: 40px; text-align: center; }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);
    printWindow.document.close();
    printWindow.print();
  };

  const handleReject = async () => {
    if (!rejectReason.trim()) return;

    try {
      const { error } = await supabase
        .from('surat_terbit')
        .update({
          status_preview: 'rejected',
          rejected_reason: rejectReason,
          updated_at: new Date().toISOString(),
        })
        .eq('id', suratId);

      if (!error) {
        onReject?.(rejectReason);
      }
    } catch (err) {
      console.error('Reject failed:', err);
    }
  };

  const handleApprove = async () => {
    try {
      const { error } = await supabase
        .from('surat_terbit')
        .update({
          status_preview: 'approved',
          approved_by: (await supabase.auth.getUser()).data.user?.id,
          approved_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', suratId);

      if (!error) {
        onApprove?.();
      }
    } catch (err) {
      console.error('Approve failed:', err);
    }
  };

  // Generate PDF from current preview
  const handleGeneratePDF = useCallback(async () => {
    if (!printRef.current || !previewData) return;

    setGeneratingPDF(true);
    try {
      const blob = await generatePDFFromElement(
        printRef.current,
        `${previewData.jenis_surat}_${previewData.nomor_surat}.pdf`
      );
      downloadPDF(blob, `${previewData.jenis_surat}_${previewData.nomor_surat}.pdf`);
    } catch (err) {
      console.error('PDF generation failed:', err);
    } finally {
      setGeneratingPDF(false);
    }
  }, [previewData]);

  // Generate and download PDF
  const handleDownloadPDF = useCallback(async () => {
    if (!previewData) return;

    setGeneratingPDF(true);
    try {
      const blob = generatePDFFromData(previewData);
      downloadPDF(blob, `${previewData.jenis_surat}_${previewData.nomor_surat}.pdf`);
    } catch (err) {
      console.error('PDF generation failed:', err);
    } finally {
      setGeneratingPDF(false);
    }
  }, [previewData]);

  // Request TTE signature (placeholder - integrates with server-side BSRE)
  const handleRequestTTE = useCallback(async () => {
    if (!previewData || !printRef.current) return;

    setSigningTTE(true);
    try {
      // Generate PDF from preview element first, then hash it
      const pdfBlob = await generatePDFFromElement(
        printRef.current,
        `${previewData.jenis_surat}_${previewData.nomor_surat}.pdf`
      );
      const docHash = await generateDocumentHash(pdfBlob);

      // Call Supabase Edge Function for TTE
      const { data, error } = await (supabase.functions as any).invoke('tte-sign', {
        body: {
          surat_id: suratId,
          document_hash: docHash,
          signer_name: previewData.data.ttd_nama || 'Kepala Desa Seruni Mumbul',
          signer_nip: previewData.template.footer.ttd_nip || undefined,
          signer_role: previewData.template.footer.ttd_kanan_judul || 'Kepala Desa',
        },
      });

      if (error || !data?.ok) {
        throw new Error(error?.message || 'TTE signing failed');
      }

      // Update surat with signed PDF URL
      await supabase
        .from('surat_terbit')
        .update({
          tte_signature_id: data.signature_id,
          signed_pdf_url: data.signed_pdf_url,
          status_preview: 'signed',
        })
        .eq('id', suratId);

      toast.success('Surat berhasil ditandatangani secara elektronik');
      onApprove?.();
    } catch (err: any) {
      console.error('TTE signing failed:', err);
      toast.error(err?.message || 'TTE signing failed');
    } finally {
      setSigningTTE(false);
    }
  }, [previewData, suratId, onApprove]);

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="text-center">
          <div className="animate-spin w-8 h-8 border-4 border-primary border-t-transparent rounded-full mx-auto mb-4" />
          <p>Memuat preview...</p>
        </div>
      </div>
    );
  }

  if (!previewData) {
    return (
      <div className="p-8 text-center text-gray-500">
        Preview tidak tersedia
      </div>
    );
  }

  const formatTanggal = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('id-ID', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  };

  const { template: tmpl, penduduk } = previewData;

  return (
    <div className="flex flex-col h-full">
      {/* Toolbar */}
      <div className="flex items-center justify-between p-4 border-b bg-gray-50">
        <h3 className="font-semibold">Preview Surat</h3>
        <div className="flex gap-2">
          <button
            onClick={handlePrint}
            className="px-4 py-2 border rounded-md hover:bg-gray-100 text-sm"
          >
            🖨️ Cetak
          </button>
          <button
            onClick={handleDownloadPDF}
            disabled={generatingPDF}
            className="px-4 py-2 border rounded-md hover:bg-gray-100 text-sm disabled:opacity-50"
          >
            {generatingPDF ? '⏳...' : '📄 PDF'}
          </button>
          <button
            onClick={onClose}
            className="px-4 py-2 border rounded-md hover:bg-gray-100 text-sm"
          >
            ✕ Tutup
          </button>
        </div>
      </div>

      {/* Preview Content */}
      <div className="flex-1 overflow-auto bg-gray-100 p-4">
        <div className="max-w-[210mm] mx-auto bg-white shadow-lg">
          <div ref={printRef} className="p-4" style={{ minHeight: '297mm' }}>
            {/* KOP Header */}
            <div className="kop">
              <div className="flex items-center justify-center gap-4 mb-2">
                {tmpl.kop.logo_kiri_url && (
                  <img
                    src={tmpl.kop.logo_kiri_url}
                    alt="Logo"
                    className="w-16 h-16 object-contain"
                  />
                )}
                <div>
                  <p className="font-bold text-sm">{tmpl.kop.instansi}</p>
                  <p className="text-xs">{tmpl.kop.sub_instansi}</p>
                  <p className="text-base font-bold">{tmpl.kop.nama_desa}</p>
                </div>
                {tmpl.kop.logo_kanan_url && (
                  <img
                    src={tmpl.kop.logo_kanan_url}
                    alt="Logo"
                    className="w-16 h-16 object-contain"
                  />
                )}
              </div>
              <p className="text-xs text-center">{tmpl.kop.alamat}</p>
            </div>

            {/* Garis */}
            {tmpl.header.border_bottom_enabled && (
              <div
                className="garis"
                style={{
                  borderBottomWidth: tmpl.header.border_bottom_width,
                  borderBottomStyle: tmpl.header.border_bottom_style,
                  borderBottomColor: '#000',
                }}
              />
            )}

            {/* Nomor Surat */}
            <div className="nomor">
              <p>Nomor: {previewData.nomor_surat}</p>
              <p>Lampiran: {previewData.lampiran && previewData.lampiran.length > 0 ? String(previewData.lampiran.length) : '-'}</p>
              <p>Perihal: {previewData.data.perihal || previewData.jenis_surat}</p>
            </div>

            {/* Kepada */}
            <div className="mb-4">
              <p>Kepada Yth.</p>
              <p className="font-bold ml-4">
                {penduduk?.nama || '[Nama Pemohon]'}
              </p>
              <p className="ml-4">di -</p>
              <p className="ml-8">Tempat</p>
            </div>

            {/* Body Surat */}
            <div className="body">
              <p className="mb-4">Dengan hormat,</p>
              <p className="mb-4 text-indent">
                Bersama ini kami sampaikan {previewData.jenis_surat} atas nama:
              </p>

              {/* Data Pemohon */}
              <div className="ml-8 mb-4">
                {penduduk ? (
                  <table className="w-full">
                    <tbody>
                      <tr>
                        <td className="pr-4">Nama</td>
                        <td>: {penduduk.nama}</td>
                      </tr>
                      <tr>
                        <td>NIK</td>
                        <td>: {penduduk.nik}</td>
                      </tr>
                      <tr>
                        <td>Tempat/Tgl Lahir</td>
                        <td>: {penduduk.tempat_lahir}, {penduduk.tanggal_lahir}</td>
                      </tr>
                      <tr>
                        <td>Jenis Kelamin</td>
                        <td>: {penduduk.jenis_kelamin}</td>
                      </tr>
                      <tr>
                        <td>Alamat</td>
                        <td>: {penduduk.alamat}</td>
                      </tr>
                      <tr>
                        <td>Pekerjaan</td>
                        <td>: {penduduk.pekerjaan || '-'}</td>
                      </tr>
                      <tr>
                        <td>Agama</td>
                        <td>: {penduduk.agama || '-'}</td>
                      </tr>
                    </tbody>
                  </table>
                ) : (
                  <p className="text-gray-400 italic">
                    Data penduduk tidak tersedia
                  </p>
                )}
              </div>

              {/* DNA Fields */}
              {previewData.dnaFields && previewData.dnaFields.length > 0 && (
                <div className="ml-8 mb-4">
                  {(() => {
                    const groups: Record<string, typeof previewData.dnaFields> = {};
                    previewData.dnaFields.forEach((f) => {
                      const g = f.grup || 'Keterangan';
                      if (!groups[g]) groups[g] = [];
                      groups[g].push(f);
                    });
                    return Object.entries(groups).map(([grup, fields]) => (
                      <div key={grup} className="mb-3">
                        <p className="font-bold text-sm mb-1">{grup}</p>
                        <table className="w-full">
                          <tbody>
                            {fields.map((f) => {
                              const val = previewData.dnaValues?.[f.field_name];
                              if (val === null || val === undefined || val === '') return null;
                              return (
                                <tr key={f.field_name}>
                                  <td className="pr-4">{f.label}</td>
                                  <td>: {Array.isArray(val) ? val.join(', ') : String(val)}</td>
                                </tr>
                              );
                            })}
                          </tbody>
                        </table>
                      </div>
                    ));
                  })()}
                </div>
              )}

              {/* Isi Surat */}
              <p className="mb-4 text-indent">
                {previewData.data.isi || 'Isi surat akan ditampilkan di sini...'}
              </p>

              {/* Penutup */}
              <p className="mb-4">
               Demikian surat keterangan ini dibuat dengan sebenarnya dan agar dapat
                digunakan sebagaimana mestinya.
              </p>
            </div>

            {/* Footer - Tanda Tangan */}
            <div className="footer flex justify-end">
              <div className="text-center mr-8">
                <p>{formatTanggal(previewData.tanggal_surat)}</p>
                <p>{tmpl.footer.ttd_kanan_judul},</p>

                {/* Tanda Tangan Image atau placeholder */}
                {tmpl.footer.ttd_image_url ? (
                  <img
                    src={tmpl.footer.ttd_image_url}
                    alt="Tanda Tangan"
                    className="h-12 mx-auto object-contain"
                  />
                ) : (
                  <div className="h-12" /> /* Space for signature */
                )}

                <p className="font-bold underline mt-1">
                  {tmpl.footer.ttd_nama || previewData.data.ttd_nama || '(Nama Kades)'}
                </p>
                {tmpl.footer.ttd_nip && (
                  <p>NIP. {tmpl.footer.ttd_nip}</p>
                )}
              </div>
            </div>

            {/* QR Code untuk Verifikasi */}
            {tmpl.footer.ttd_kanan_enabled && tmpl.footer.qr_code_url && (
              <div className="absolute bottom-4 right-4 w-20 h-20">
                <img
                  src={tmpl.footer.qr_code_url}
                  alt="QR Verifikasi"
                  className="w-full h-full object-contain"
                />
                <p className="text-[8px] text-center mt-1 text-gray-400">Scan untuk verifikasi</p>
              </div>
            )}

            {/* QR placeholder if no QR URL */}
            {tmpl.footer.ttd_kanan_enabled && !tmpl.footer.qr_code_url && (
              <div className="absolute bottom-4 right-4 w-20 h-20 border border-dashed border-gray-300 flex items-center justify-center text-xs text-gray-400">
                QR<br/>Belum ada
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="p-4 border-t bg-gray-50">
        {showRejectForm ? (
          <div className="space-y-3">
            <textarea
              value={rejectReason}
              onChange={e => setRejectReason(e.target.value)}
              placeholder="Alasan penolakan..."
              className="w-full border rounded-md p-2 text-sm"
              rows={3}
              autoComplete="off"
            />
            <div className="flex gap-2">
              <button
                onClick={handleReject}
                disabled={!rejectReason.trim()}
                className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 disabled:opacity-50"
              >
                Konfirmasi Tolak
              </button>
              <button
                onClick={() => setShowRejectForm(false)}
                className="px-4 py-2 border rounded-md hover:bg-gray-100"
              >
                Batal
              </button>
            </div>
          </div>
        ) : (
          <div className="flex gap-2 justify-end">
            <button
              onClick={() => setShowRejectForm(true)}
              className="px-4 py-2 border border-red-500 text-red-500 rounded-md hover:bg-red-50"
            >
              ❌ Tolak
            </button>
            <button
              onClick={handleRequestTTE}
              disabled={signingTTE}
              className="px-4 py-2 border border-blue-500 text-blue-500 rounded-md hover:bg-blue-50 disabled:opacity-50"
            >
              🔏 TTE
            </button>
            <button
              onClick={handleApprove}
              className="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600"
            >
              ✓ Approve & Terbitkan
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

/**
 * Simple Preview Modal
 */
export function SuratPreviewModal({
  isOpen,
  onClose,
  children,
}: {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
}) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
      />
      <div className="relative bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
        {children}
      </div>
    </div>
  );
}
