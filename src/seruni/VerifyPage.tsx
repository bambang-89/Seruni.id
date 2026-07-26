/**
 * TTE Verification Page
 * Public page for verifying electronic signatures on surat
 */

import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '@/integrations/supabase/client';
import { useIdentitasDesa } from '@/seruni/lib/queries';

interface SignatureInfo {
  id: string;
  surat_id: string;
  tipe: 'sederhana' | 'bsre' | 'esign';
  status: string;
  signed_by: string;
  signer_role: string;
  signed_at: string;
  signature_hash: string;
  qr_code_url: string | null;
  metadata: Record<string, unknown>;
}

interface VerifiedData {
  surat: {
    id: string;
    nomor_surat: string;
    jenis: string;
    tanggal_terbit: string;
  };
  signature: SignatureInfo;
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  return date.toLocaleDateString('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatStatus(status: string): { label: string; color: string; icon: string } {
  switch (status) {
    case 'signed':
      return { label: 'Tertanda Tangan', color: 'text-green-600 bg-green-50 border-green-200', icon: '✓' };
    case 'verified':
      return { label: 'Terverifikasi', color: 'text-blue-600 bg-blue-50 border-blue-200', icon: '✓' };
    case 'expired':
      return { label: 'Kadaluarsa', color: 'text-yellow-600 bg-yellow-50 border-yellow-200', icon: '!' };
    case 'rejected':
      return { label: 'Ditolak', color: 'text-red-600 bg-red-50 border-red-200', icon: '✗' };
    default:
      return { label: status, color: 'text-gray-600 bg-gray-50 border-gray-200', icon: '?' };
  }
}

function formatTipe(tipe: string): string {
  switch (tipe) {
    case 'sederhana':
      return 'Tanda Tangan Sederhana';
    case 'bsre':
      return 'BSRE (eSign)';
    case 'esign':
      return 'Tanda Tangan Elektronik';
    default:
      return tipe;
  }
}

export default function VerifyPage() {
  const [searchParams] = useSearchParams();
  const signatureId = searchParams.get('id');
  const { data: identitas } = useIdentitasDesa();

  const [loading, setLoading] = useState(true);
  const [verified, setVerified] = useState<VerifiedData | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (signatureId) {
      loadSignature();
    } else {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [signatureId]);

  const loadSignature = async () => {
    if (!signatureId) return;

    setLoading(true);
    setError(null);

    try {
      // Get signature info
      const { data: sig, error: sigError } = await (supabase as any)
        .from('tte_signatures')
        .select('*')
        .eq('id', signatureId)
        .single();

      if (sigError || !sig) {
        setError('Tanda tangan elektronik tidak ditemukan. Pastikan ID yang Anda masukkan benar.');
        setLoading(false);
        return;
      }

      // Get surat info
      const { data: surat } = await (supabase as any)
        .from('surat_terbit')
        .select('id, nomor_surat, jenis:jenis_nama, tanggal_terbit')
        .eq('id', sig.surat_id)
        .single();

      if (!surat) {
        setError('Data surat tidak ditemukan.');
        setLoading(false);
        return;
      }

      // Check signature validity
      const isExpired = new Date(sig.signed_at) < new Date(Date.now() - 365 * 24 * 60 * 60 * 1000);

      setVerified({
        surat: surat as VerifiedData['surat'],
        signature: {
          ...sig,
          status: isExpired ? 'expired' : sig.status,
        } as SignatureInfo,
      });
    } catch (err) {
      console.error('Verify error:', err);
      setError('Terjadi kesalahan saat memverifikasi. Silakan coba lagi.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="flex items-center gap-4">
            {identitas?.logo_url && (
              <img
                src={identitas.logo_url}
                alt="Logo"
                className="w-12 h-12 object-contain"
              />
            )}
            <div>
              <h1 className="font-display text-lg font-bold text-accent">
                {identitas?.nama_desa || 'Desa Seruni Mumbul'}
              </h1>
              <p className="text-sm opacity-60">
                Verifikasi Tanda Tangan Elektronik
              </p>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="p-6 border-b">
            <h2 className="font-display text-xl font-semibold">Verifikasi Dokumen</h2>
            <p className="text-sm opacity-60 mt-1">
              Masukkan ID tanda tangan elektronik yang tertera di dokumen Anda.
            </p>
          </div>

          <div className="p-6">
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <div className="animate-spin w-8 h-8 border-4 border-primary border-t-transparent rounded-full" />
              </div>
            ) : error ? (
              <div className="text-center py-12">
                <div className="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                  <span className="text-3xl">✗</span>
                </div>
                <h3 className="text-lg font-semibold text-red-600 mb-2">
                  Verifikasi Gagal
                </h3>
                <p className="text-gray-600">{error}</p>
              </div>
            ) : verified ? (
              <div className="space-y-6">
                {/* Status Badge */}
                <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-full border ${formatStatus(verified.signature.status).color}`}>
                  <span>{formatStatus(verified.signature.status).icon}</span>
                  <span className="font-semibold">{formatStatus(verified.signature.status).label}</span>
                </div>

                {/* Document Info */}
                <div className="border rounded-lg p-4">
                  <h3 className="font-display text-sm font-bold uppercase tracking-wider text-accent mb-4">
                    Informasi Dokumen
                  </h3>
                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <p className="text-xs opacity-60">Jenis Surat</p>
                      <p className="font-semibold">{verified.surat.jenis}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">Nomor Surat</p>
                      <p className="font-mono font-semibold">{verified.surat.nomor_surat}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">Tanggal Terbit</p>
                      <p>{formatDate(verified.surat.tanggal_terbit)}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">ID Tanda Tangan</p>
                      <p className="font-mono text-sm">{verified.signature.id}</p>
                    </div>
                  </div>
                </div>

                {/* Signature Info */}
                <div className="border rounded-lg p-4">
                  <h3 className="font-display text-sm font-bold uppercase tracking-wider text-accent mb-4">
                    Informasi Tanda Tangan
                  </h3>
                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <p className="text-xs opacity-60">Ditandatangani oleh</p>
                      <p className="font-semibold">{verified.signature.signed_by}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">Jabatan</p>
                      <p>{verified.signature.signer_role}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">Tipe Tanda Tangan</p>
                      <p>{formatTipe(verified.signature.tipe)}</p>
                    </div>
                    <div>
                      <p className="text-xs opacity-60">Waktu Tanda Tangan</p>
                      <p>{formatDate(verified.signature.signed_at)}</p>
                    </div>
                  </div>

                  {/* QR Code */}
                  {verified.signature.qr_code_url && (
                    <div className="mt-4 pt-4 border-t">
                      <p className="text-xs opacity-60 mb-2">QR Code Verifikasi</p>
                      <img
                        src={verified.signature.qr_code_url}
                        alt="QR Code"
                        className="w-24 h-24"
                      />
                    </div>
                  )}
                </div>

                {/* Hash Info */}
                {verified.signature.signature_hash && (
                  <div className="border rounded-lg p-4">
                    <h3 className="font-display text-sm font-bold uppercase tracking-wider text-accent mb-2">
                      Hash Dokumen
                    </h3>
                    <p className="font-mono text-xs break-all text-gray-600">
                      {verified.signature.signature_hash}
                    </p>
                    <p className="text-xs opacity-60 mt-2">
                      Hash digunakan untuk memastikan dokumen tidak dimodifikasi setelah ditandatangani.
                    </p>
                  </div>
                )}

                {/* Success Message */}
                {verified.signature.status === 'signed' || verified.signature.status === 'verified' ? (
                  <div className="bg-green-50 border border-green-200 rounded-lg p-4 text-green-800">
                    <p className="font-semibold">✓ Dokumen Valid</p>
                    <p className="text-sm mt-1">
                      Dokumen ini telah ditandatangani secara elektronik oleh{' '}
                      <strong>{verified.signature.signed_by}</strong> pada{' '}
                      {formatDate(verified.signature.signed_at)}.
                    </p>
                  </div>
                ) : null}
              </div>
            ) : (
              <div className="text-center py-12 text-gray-500">
                <p>Masukkan ID tanda tangan untuk memulai verifikasi.</p>
              </div>
            )}
          </div>
        </div>

        {/* Footer Info */}
        <div className="mt-6 text-center text-sm opacity-60">
          <p>
            Untuk informasi lebih lanjut, silakan hubungi{' '}
            <a href="mailto:serunimumbul@gmail.com" className="text-accent hover:underline">
              Kantor Desa Seruni Mumbul
            </a>
          </p>
        </div>
      </main>
    </div>
  );
}
