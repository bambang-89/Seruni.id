/**
 * Upload System - Device Storage
 * Upload foto/dokumen dari device ke Supabase Storage
 * Menggunakan base64 encoding untuk transfer aman
 */

import { supabase } from "@/integrations/supabase/client";

// ============================================================
// TYPES
// ============================================================

export type UploadKategori =
  | 'foto_ktp'
  | 'foto_kk'
  | 'foto_selfie_ktp'
  | 'akta_lahir'
  | 'akta_nikah'
  | 'dokumen_pendukung'
  | 'dokumen_sertifikat'
  | 'foto_profil'
  | 'foto_galeri'
  | 'foto_kegiatan'
  | 'foto_produk'
  | 'foto_pamong'
  | 'ttd_image'
  | 'qr_code'
  | 'lainnya';

export type EntityType =
  | 'surat_ajuan'
  | 'penduduk'
  | 'bidang_tanah'
  | 'kegiatan'
  | 'umkm'
  | 'profil_desa'
  | 'pamong'
  | 'berita'
  | 'galeri'
  | 'lainnya';

export interface UploadOptions {
  entityType: EntityType;
  entityId?: string;
  kategori: UploadKategori;
  maxSizeMB?: number;
  allowedTypes?: string[];
}

export interface UploadResult {
  success: boolean;
  id?: string;
  storagePath?: string;
  url?: string;
  error?: string;
}

export interface UploadPreferences {
  kategori: UploadKategori;
  folderPath: string;
  maxSizeMB: number;
  allowedTypes: string[];
  isRequired: boolean;
  deskripsi: string;
}

// ============================================================
// CONSTANTS
// ============================================================

const BUCKET = 'seruni-media';

export const UPLOAD_PREFERENCES: Record<UploadKategori, UploadPreferences> = {
  foto_ktp: {
    kategori: 'foto_ktp',
    folderPath: 'surat/ktp',
    maxSizeMB: 5,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: true,
    deskripsi: 'Foto KTP pemohon (harus jelas, bukan fotokopi)',
  },
  foto_kk: {
    kategori: 'foto_kk',
    folderPath: 'surat/kk',
    maxSizeMB: 5,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Kartu Keluarga',
  },
  foto_selfie_ktp: {
    kategori: 'foto_selfie_ktp',
    folderPath: 'surat/selfie',
    maxSizeMB: 5,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: true,
    deskripsi: 'Foto selfie dengan memegang KTP asli',
  },
  akta_lahir: {
    kategori: 'akta_lahir',
    folderPath: 'surat/akta',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    isRequired: false,
    deskripsi: 'Akta Kelahiran',
  },
  akta_nikah: {
    kategori: 'akta_nikah',
    folderPath: 'surat/akta',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    isRequired: false,
    deskripsi: 'Akta Nikah / Buku Nikah',
  },
  dokumen_pendukung: {
    kategori: 'dokumen_pendukung',
    folderPath: 'surat/pendukung',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    isRequired: false,
    deskripsi: 'Dokumen pendukung lainnya',
  },
  dokumen_sertifikat: {
    kategori: 'dokumen_sertifikat',
    folderPath: 'sertifikat',
    maxSizeMB: 15,
    allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    isRequired: false,
    deskripsi: 'Dokumen Sertifikat Tanah',
  },
  foto_profil: {
    kategori: 'foto_profil',
    folderPath: 'profil',
    maxSizeMB: 2,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Profil',
  },
  foto_galeri: {
    kategori: 'foto_galeri',
    folderPath: 'galeri',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Galeri Kegiatan',
  },
  foto_kegiatan: {
    kategori: 'foto_kegiatan',
    folderPath: 'kegiatan',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Dokumentasi Kegiatan',
  },
  foto_produk: {
    kategori: 'foto_produk',
    folderPath: 'produk',
    maxSizeMB: 5,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Produk UMKM',
  },
  foto_pamong: {
    kategori: 'foto_pamong',
    folderPath: 'pamong/foto',
    maxSizeMB: 5,
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
    isRequired: false,
    deskripsi: 'Foto Perangkat Desa',
  },
  ttd_image: {
    kategori: 'ttd_image',
    folderPath: 'pamong/ttd',
    maxSizeMB: 2,
    allowedTypes: ['image/png', 'image/jpeg', 'image/webp'],
    isRequired: false,
    deskripsi: 'Gambar Tanda Tangan',
  },
  qr_code: {
    kategori: 'qr_code',
    folderPath: 'pamong/qr',
    maxSizeMB: 1,
    allowedTypes: ['image/png', 'image/jpeg', 'image/webp'],
    isRequired: false,
    deskripsi: 'QR Code Verifikasi',
  },
  lainnya: {
    kategori: 'lainnya',
    folderPath: 'lainnya',
    maxSizeMB: 10,
    allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
    isRequired: false,
    deskripsi: 'Dokumen lainnya',
  },
};

// ============================================================
// UTILITY FUNCTIONS
// ============================================================

/**
 * Convert File to Base64
 */
function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      // Remove data URL prefix to get pure base64
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

/**
 * Validate file before upload
 */
function validateFile(file: File, prefs: UploadPreferences): string | null {
  // Check size
  if (file.size > prefs.maxSizeMB * 1024 * 1024) {
    return `File terlalu besar. Maksimal ${prefs.maxSizeMB}MB.`;
  }

  // Check type
  if (!prefs.allowedTypes.includes(file.type)) {
    return `Tipe file tidak didukung. Gunakan: ${prefs.allowedTypes.map(t => t.split('/')[1]).join(', ')}`;
  }

  return null;
}

/**
 * Generate unique filename
 */
function generateFileName(file: File): string {
  const ext = file.name.split('.').pop()?.toLowerCase() || 'bin';
  const uuid = crypto.randomUUID();
  const timestamp = Date.now();
  return `${timestamp}-${uuid}.${ext}`;
}

// ============================================================
// UPLOAD FUNCTIONS
// ============================================================

/**
 * Upload single file from device to Supabase Storage
 */
export async function uploadFile(
  file: File,
  options: UploadOptions
): Promise<UploadResult> {
  const prefs = UPLOAD_PREFERENCES[options.kategori];

  // Validate
  const error = validateFile(file, prefs);
  if (error) {
    return { success: false, error };
  }

  try {
    // Generate unique filename
    const fileName = generateFileName(file);
    const storagePath = `${options.entityType}/${options.kategori}/${fileName}`;

    // Upload to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from(BUCKET)
      .upload(storagePath, file, {
        cacheControl: '31536000', // 1 year
        upsert: false,
        contentType: file.type,
      });

    if (uploadError) {
      console.error('Upload error:', uploadError);
      return { success: false, error: uploadError.message };
    }

    // Get public URL
    const { data: urlData } = supabase.storage
      .from(BUCKET)
      .getPublicUrl(storagePath);

    return {
      success: true,
      storagePath,
      url: urlData.publicUrl,
    };
  } catch (err: any) {
    console.error('Upload failed:', err);
    return { success: false, error: err.message || 'Upload gagal' };
  }
}

/**
 * Upload multiple files
 */
export async function uploadMultipleFiles(
  files: File[],
  options: UploadOptions
): Promise<UploadResult[]> {
  const results: UploadResult[] = [];

  for (const file of files) {
    const result = await uploadFile(file, options);
    results.push(result);
  }

  return results;
}

/**
 * Delete file from storage
 */
export async function deleteFile(storagePath: string): Promise<boolean> {
  try {
    const { error } = await supabase.storage.from(BUCKET).remove([storagePath]);

    if (error) {
      console.error('Delete error:', error);
      return false;
    }

    return true;
  } catch (err) {
    console.error('Delete failed:', err);
    return false;
  }
}

/**
 * Get document records for an entity
 */
export async function getDokumenForEntity(
  entityType: EntityType,
  entityId: string,
  kategori?: UploadKategori
) {
  let query = supabase
    .from('dokumen_upload' as any)
    .select('*')
    .eq('entity_type', entityType)
    .eq('entity_id', entityId);

  if (kategori) {
    query = query.eq('kategori', kategori);
  }

  const { data, error } = await query;

  if (error) {
    console.error('Get dokumen error:', error);
    return [];
  }

  return data || [];
}

/**
 * Save dokumen_upload record
 */
export async function saveDokumenRecord(params: {
  entityType: EntityType;
  entityId: string;
  kategori: UploadKategori;
  storagePath: string;
  storageUrl: string;
  namaFile: string;
  namaAsli: string;
  tipeFile: string;
  ukuranFile: number;
}) {
  const { data, error } = await supabase
    .from('dokumen_upload' as any)
    .insert({
      entity_type: params.entityType,
      entity_id: params.entityId,
      kategori: params.kategori,
      storage_path: params.storagePath,
      storage_url: params.storageUrl,
      nama_file: params.namaFile,
      nama_asli: params.namaAsli,
      tipe_file: params.tipeFile,
      ukuran_file: params.ukuranFile,
    })
    .select()
    .single();

  if (error) {
    console.error('Save dokumen error:', error);
    return null;
  }

  return data;
}

/**
 * Delete dokumen record and file
 */
export async function deleteDokumen(dokumenId: string): Promise<boolean> {
  try {
    // Get record first
    const { data: record, error: getError } = await supabase
      .from('dokumen_upload' as any)
      .select('storage_path')
      .eq('id', dokumenId)
      .single();

    if (getError || !record) {
      console.error('Get record error:', getError);
      return false;
    }

    // Delete from storage
    await deleteFile((record as any).storage_path);

    // Delete record
    const { error: deleteError } = await supabase
      .from('dokumen_upload' as any)
      .delete()
      .eq('id', dokumenId);

    if (deleteError) {
      console.error('Delete record error:', deleteError);
      return false;
    }

    return true;
  } catch (err) {
    console.error('Delete dokumen failed:', err);
    return false;
  }
}

// ============================================================
// REACT HOOK
// ============================================================

import { useState, useCallback } from 'react';

interface UseUploadReturn {
  uploading: boolean;
  progress: number;
  error: string | null;
  upload: (file: File, options: UploadOptions) => Promise<UploadResult>;
  uploadMultiple: (files: File[], options: UploadOptions) => Promise<UploadResult[]>;
  deleteFile: (storagePath: string) => Promise<boolean>;
  reset: () => void;
}

export function useUpload(): UseUploadReturn {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const upload = useCallback(async (file: File, options: UploadOptions) => {
    setUploading(true);
    setProgress(0);
    setError(null);

    try {
      setProgress(30);
      const result = await uploadFile(file, options);

      setProgress(100);

      if (!result.success) {
        setError(result.error || 'Upload gagal');
      }

      return result;
    } finally {
      setUploading(false);
    }
  }, []);

  const uploadMultiple = useCallback(async (
    files: File[],
    options: UploadOptions
  ) => {
    setUploading(true);
    setProgress(0);
    setError(null);

    try {
      const results: UploadResult[] = [];

      for (let i = 0; i < files.length; i++) {
        setProgress(Math.round((i / files.length) * 100));
        const result = await uploadFile(files[i], options);
        results.push(result);
      }

      setProgress(100);
      return results;
    } finally {
      setUploading(false);
    }
  }, []);

  const deleteFileHandler = useCallback(async (storagePath: string) => {
    return deleteFile(storagePath);
  }, []);

  const reset = useCallback(() => {
    setUploading(false);
    setProgress(0);
    setError(null);
  }, []);

  return {
    uploading,
    progress,
    error,
    upload,
    uploadMultiple,
    deleteFile: deleteFileHandler,
    reset,
  };
}
