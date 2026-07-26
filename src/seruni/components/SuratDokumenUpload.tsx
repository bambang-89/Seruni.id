/**
 * Document Upload Component for Surat (Surat Ajuan)
 * Upload foto selfie, KTP, KK, dan dokumen pendukung
 */

import { useState, useCallback } from 'react';
import React from 'react';
import { useUpload, UPLOAD_PREFERENCES, type UploadKategori, type UploadResult } from '@/seruni/lib/upload';
import { ImageWithFallback } from '@/components/figma/ImageWithFallback';

interface DokumenSurat {
  id?: string;
  url: string;
  namaFile: string;
  kategori: UploadKategori;
  isVerified?: boolean;
}

interface SuratDokumenUploadProps {
  entityId?: string;
  onDocumentsChange?: (docs: DokumenSurat[]) => void;
  initialDocuments?: DokumenSurat[];
  showAllFields?: boolean;
}

interface UploadFieldProps {
  kategori: UploadKategori;
  label: string;
  description?: string;
  value?: DokumenSurat;
  onChange?: (doc: DokumenSurat | null) => void;
  disabled?: boolean;
}

/**
 * Single upload field component
 */
export function UploadField({
  kategori,
  label,
  description,
  value,
  onChange,
  disabled,
}: UploadFieldProps) {
  const { upload, deleteFile: deleteDokumen, uploading, progress } = useUpload();
  const [preview, setPreview] = useState<string | null>(value?.url || null);
  const [error, setError] = useState<string | null>(null);
  const inputRef = React.useRef<HTMLInputElement>(null);

  const prefs = UPLOAD_PREFERENCES[kategori];

  const handleFileSelect = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setError(null);

    const result = await upload(file, {
      entityType: 'surat_ajuan',
      entityId: '',
      kategori,
    });

    if (result.success && result.url) {
      setPreview(result.url);
      onChange?.({
        url: result.url,
        namaFile: file.name,
        kategori,
      });
    } else {
      setError(result.error || 'Upload gagal');
    }
  }, [upload, kategori, onChange]);

  const handleDelete = useCallback(async () => {
    if (value?.id) {
      await deleteDokumen(value.id);
    }
    setPreview(null);
    onChange?.(null);
  }, [value, deleteDokumen, onChange]);

  const handleTakePhoto = useCallback(() => {
    if (inputRef.current) {
      inputRef.current.setAttribute('capture', 'environment');
      inputRef.current.click();
    }
  }, []);

  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium">
        {label}
        {prefs.isRequired && <span className="text-red-500 ml-1">*</span>}
      </label>

      {description && (
        <p className="text-xs text-muted-foreground">{description}</p>
      )}

      {/* Preview */}
      {preview ? (
        <div className="relative inline-block">
          <ImageWithFallback
            src={preview}
            alt={label}
            className="w-full max-h-48 object-contain rounded-lg border bg-muted"
          />
          {!disabled && (
            <button
              type="button"
              onClick={handleDelete}
              className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-xs font-bold hover:bg-red-600 flex items-center justify-center"
            >
              ×
            </button>
          )}
          {value?.isVerified && (
            <span className="absolute -bottom-2 -right-2 bg-green-500 text-white text-xs px-2 py-0.5 rounded-full">
              ✓
            </span>
          )}
        </div>
      ) : (
        <div className="border-2 border-dashed border-muted-foreground/25 rounded-lg p-4 text-center bg-muted/30">
          <span className="text-muted-foreground text-sm">
            {prefs.deskripsi}
          </span>
        </div>
      )}

      {/* Upload buttons */}
      {!disabled && (
        <div className="flex gap-2">
          <label className="flex-1 cursor-pointer">
            <input
              ref={inputRef}
              type="file"
              accept={prefs.allowedTypes.join(',')}
              onChange={handleFileSelect}
              className="hidden"
              disabled={uploading}
            />
            <div className="flex items-center justify-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50 text-sm">
              {uploading ? (
                <>
                  <span className="animate-spin">⏳</span>
                  <span>{progress}%</span>
                </>
              ) : (
                <>
                  <span>📁</span>
                  <span>Pilih File</span>
                </>
              )}
            </div>
          </label>

          {/* Camera button for mobile */}
          <button
            type="button"
            onClick={handleTakePhoto}
            className="px-4 py-2 border rounded-md hover:bg-muted disabled:opacity-50 text-sm"
            disabled={uploading}
          >
            📷 Kamera
          </button>
        </div>
      )}

      {/* Error */}
      {error && (
        <p className="text-sm text-red-500">{error}</p>
      )}

      {/* Size hint */}
      <p className="text-xs text-muted-foreground">
        Maksimal {prefs.maxSizeMB}MB. Format: {prefs.allowedTypes.map(t => t.split('/')[1].toUpperCase()).join(', ')}
      </p>
    </div>
  );
}

/**
 * Complete document upload form for surat ajuan
 */
export function SuratDokumenUpload({
  entityId,
  onDocumentsChange,
  initialDocuments = [],
  showAllFields = false,
}: SuratDokumenUploadProps) {
  const [documents, setDocuments] = useState<DokumenSurat[]>(initialDocuments);

  const handleDocumentChange = useCallback((
    kategori: UploadKategori,
    doc: DokumenSurat | null
  ) => {
    setDocuments(prev => {
      const filtered = prev.filter(d => d.kategori !== kategori);
      const updated = doc ? [...filtered, doc] : filtered;

      // Call parent callback
      onDocumentsChange?.(updated);

      return updated;
    });
  }, [onDocumentsChange]);

  const getDocument = (kategori: UploadKategori) =>
    documents.find(d => d.kategori === kategori);

  const isComplete = () => {
    const ktp = getDocument('foto_ktp');
    const selfie = getDocument('foto_selfie_ktp');
    return !!(ktp && selfie);
  };

  return (
    <div className="space-y-6">
      <div className="border-b pb-4">
        <h3 className="font-semibold text-lg">Dokumen Pendukung</h3>
        <p className="text-sm text-muted-foreground">
          Upload dokumen yang diperlukan untuk pengajuan surat
        </p>
      </div>

      {/* Required documents */}
      <div className="grid gap-6 md:grid-cols-2">
        <UploadField
          kategori="foto_ktp"
          label="Foto KTP"
          description="Foto KTP asli (bukan fotokopi, harus jelas)"
          value={getDocument('foto_ktp')}
          onChange={(doc) => handleDocumentChange('foto_ktp', doc)}
        />

        <UploadField
          kategori="foto_selfie_ktp"
          label="Foto Selfie dengan KTP"
          description="Foto selfie memegang KTP asli"
          value={getDocument('foto_selfie_ktp')}
          onChange={(doc) => handleDocumentChange('foto_selfie_ktp', doc)}
        />
      </div>

      {/* Optional documents */}
      {showAllFields && (
        <>
          <div className="border-t pt-4">
            <h4 className="font-medium text-muted-foreground">Dokumen Tambahan (Opsional)</h4>
          </div>

          <div className="grid gap-6 md:grid-cols-2">
            <UploadField
              kategori="foto_kk"
              label="Foto Kartu Keluarga"
              description="Foto KK asli (jika tersedia)"
              value={getDocument('foto_kk')}
              onChange={(doc) => handleDocumentChange('foto_kk', doc)}
            />

            <UploadField
              kategori="akta_lahir"
              label="Akta Kelahiran"
              description="Scan/foto akta kelahiran (jika ada)"
              value={getDocument('akta_lahir')}
              onChange={(doc) => handleDocumentChange('akta_lahir', doc)}
            />
          </div>

          <div className="grid gap-6 md:grid-cols-2">
            <UploadField
              kategori="akta_nikah"
              label="Akta Nikah / Buku Nikah"
              description="Scan/foto akta nikah (jika ada)"
              value={getDocument('akta_nikah')}
              onChange={(doc) => handleDocumentChange('akta_nikah', doc)}
            />

            <UploadField
              kategori="dokumen_pendukung"
              label="Dokumen Pendukung Lainnya"
              description="Sertifikat, izin, atau dokumen pendukung lainnya"
              value={getDocument('dokumen_pendukung')}
              onChange={(doc) => handleDocumentChange('dokumen_pendukung', doc)}
            />
          </div>
        </>
      )}

      {/* Status */}
      <div className="flex items-center gap-2 text-sm">
        {isComplete() ? (
          <>
            <span className="text-green-600">✓</span>
            <span className="text-green-600">Dokumen lengkap</span>
          </>
        ) : (
          <>
            <span className="text-amber-600">⚠</span>
            <span className="text-amber-600">
              Dokumen belum lengkap (wajib: KTP & Selfie)
            </span>
          </>
        )}
      </div>
    </div>
  );
}

/**
 * Simple document preview component
 */
export function DokumenPreview({
  documents,
  onDelete,
}: {
  documents: DokumenSurat[];
  onDelete?: (kategori: UploadKategori) => void;
}) {
  if (documents.length === 0) {
    return (
      <div className="text-center py-8 text-muted-foreground">
        <span className="text-4xl mb-2 block">📄</span>
        <p>Belum ada dokumen diupload</p>
      </div>
    );
  }

  return (
    <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-4">
      {documents.map((doc) => (
        <div key={doc.kategori} className="relative group">
          <ImageWithFallback
            src={doc.url}
            alt={doc.namaFile}
            className="w-full h-32 object-cover rounded-lg border"
          />
          <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center">
            <span className="text-white text-xs text-center px-2">
              {UPLOAD_PREFERENCES[doc.kategori]?.deskripsi || doc.kategori}
            </span>
          </div>
          {onDelete && (
            <button
              type="button"
              onClick={() => onDelete(doc.kategori)}
              className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-xs font-bold opacity-0 group-hover:opacity-100 transition-opacity"
            >
              ×
            </button>
          )}
          {doc.isVerified && (
            <span className="absolute bottom-2 left-2 bg-green-500 text-white text-xs px-2 py-0.5 rounded-full">
              ✓
            </span>
          )}
        </div>
      ))}
    </div>
  );
}

