import { supabase } from "@/integrations/supabase/client";

const BUCKET = "seruni-media";
// ~10 tahun; cukup untuk URL "permanen" pada bucket privat + policy anon SELECT.
const SIGN_EXPIRY = 60 * 60 * 24 * 365 * 10;

function safeName(file: File) {
  const ext = file.name.split(".").pop()?.toLowerCase() || "bin";
  const base = crypto.randomUUID();
  return `${base}.${ext}`;
}

export async function uploadImage(folder: string, file: File): Promise<string> {
  if (!file.type.startsWith("image/")) throw new Error("File harus berupa gambar.");
  if (file.size > 5 * 1024 * 1024) throw new Error("Ukuran gambar maksimal 5MB.");

  const path = `${folder}/${safeName(file)}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: "31536000",
    upsert: false,
    contentType: file.type,
  });
  if (error) throw error;

  const { data, error: signErr } = await supabase.storage
    .from(BUCKET)
    .createSignedUrl(path, SIGN_EXPIRY);
  if (signErr || !data?.signedUrl) throw signErr || new Error("Gagal membuat URL.");
  return data.signedUrl;
}