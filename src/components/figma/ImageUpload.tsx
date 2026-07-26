import { useState, useCallback } from 'react';
import { supabase } from '@/integrations/supabase/client';

interface ImageUploadProps {
  bucket: string;
  path?: string;
  onUpload: (url: string) => void;
  onError?: (error: string) => void;
  accept?: string;
  maxSizeMB?: number;
  className?: string;
  currentUrl?: string | null;
  placeholder?: string;
}

export function ImageUpload({
  bucket,
  path,
  onUpload,
  onError,
  accept = 'image/*',
  maxSizeMB = 5,
  className = '',
  currentUrl,
  placeholder,
}: ImageUploadProps) {
  const [uploading, setUploading] = useState(false);
  const [preview, setPreview] = useState<string | null>(currentUrl || null);
  const [error, setError] = useState<string | null>(null);

  const handleUpload = useCallback(async (file: File) => {
    if (file.size > maxSizeMB * 1024 * 1024) {
      const msg = `File terlalu besar. Maksimal ${maxSizeMB}MB`;
      setError(msg);
      onError?.(msg);
      return;
    }

    setUploading(true);
    setError(null);

    try {
      // Generate unique filename
      const ext = file.name.split('.').pop();
      const filename = `${Date.now()}-${Math.random().toString(36).substring(2)}.${ext}`;
      const filePath = path ? `${path}/${filename}` : filename;

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadError) {
        throw uploadError;
      }

      // Get public URL
      const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(filePath);

      if (urlData?.publicUrl) {
        setPreview(urlData.publicUrl);
        onUpload(urlData.publicUrl);
      }
    } catch (err: any) {
      const msg = err.message || 'Gagal upload gambar';
      setError(msg);
      onError?.(msg);
    } finally {
      setUploading(false);
    }
  }, [bucket, path, maxSizeMB, onUpload, onError]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleUpload(file);
    }
  };

  const handleDelete = useCallback(async () => {
    if (!preview) return;

    try {
      // Extract path from URL
      const url = new URL(preview);
      const pathParts = url.pathname.split('/');
      const filePath = pathParts.slice(pathParts.indexOf(bucket) + 1).join('/');

      const { error: deleteError } = await supabase.storage
        .from(bucket)
        .remove([filePath]);

      if (deleteError) {
        console.error('Delete error:', deleteError);
      }

      setPreview(null);
      onUpload('');
    } catch (err) {
      console.error('Delete failed:', err);
    }
  }, [preview, bucket, onUpload]);

  return (
    <div className={`space-y-2 ${className}`}>
      {/* Preview */}
      {preview && (
        <div className="relative inline-block">
          <img
            src={preview}
            alt="Preview"
            className="w-full max-h-48 object-contain rounded-lg border bg-muted"
          />
          <button
            type="button"
            onClick={handleDelete}
            className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-xs font-bold hover:bg-red-600"
          >
            ×
          </button>
        </div>
      )}

      {/* Placeholder */}
      {!preview && (
        <div className="w-full h-32 border-2 border-dashed border-muted-foreground/25 rounded-lg flex items-center justify-center bg-muted/50">
          <span className="text-muted-foreground text-sm">
            {placeholder || 'Belum ada gambar'}
          </span>
        </div>
      )}

      {/* Upload button */}
      <label className="cursor-pointer">
        <input
          type="file"
          accept={accept}
          onChange={handleFileChange}
          className="hidden"
          disabled={uploading}
        />
        <div className="flex items-center justify-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50">
          {uploading ? (
            <>
              <span className="animate-spin">⏳</span>
              <span>Mengupload...</span>
            </>
          ) : (
            <>
              <span>📷</span>
              <span>{preview ? 'Ganti Gambar' : 'Pilih Gambar'}</span>
            </>
          )}
        </div>
      </label>

      {/* Error */}
      {error && (
        <p className="text-sm text-red-500">{error}</p>
      )}

      {/* Size hint */}
      <p className="text-xs text-muted-foreground">
        Maksimal {maxSizeMB}MB. Format: JPG, PNG, WebP
      </p>
    </div>
  );
}

/**
 * Simple image display with fallback
 * Uses ImageWithFallback but with Supabase Storage support
 */
export function SupabaseImage({
  src,
  alt,
  bucket,
  path,
  fallback,
  className,
  ...props
}: {
  src?: string | null;
  alt: string;
  bucket?: string;
  path?: string;
  fallback?: string;
  className?: string;
} & React.ImgHTMLAttributes<HTMLImageElement>) {
  const [imgSrc, setImgSrc] = useState(src || fallback);
  const [hasError, setHasError] = useState(false);

  // Get public URL if using storage path
  const getImageUrl = useCallback((input: string) => {
    // If it's already a full URL, return as is
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }
    // If it's a storage path
    if (bucket && path) {
      return `${import.meta.env.VITE_SUPABASE_URL}/storage/v1/object/public/${bucket}/${path}`;
    }
    return input;
  }, [bucket, path]);

  const handleError = () => {
    if (!hasError && fallback) {
      setHasError(true);
      setImgSrc(fallback);
    }
  };

  return (
    <img
      src={imgSrc}
      alt={alt}
      className={className}
      onError={handleError}
      loading="lazy"
      {...props}
    />
  );
}
