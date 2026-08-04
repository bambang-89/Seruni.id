import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).end();

  const { nomor, kode } = req.query as { nomor?: string; kode?: string };

  if (!nomor || !kode) {
    return res.status(400).json({ error: 'nomor and kode are required' });
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !supabaseKey) {
    return res.status(500).json({ error: 'Missing Supabase configuration' });
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  const { data, error } = await supabase
    .from('surat_terbit')
    .select('nomor_surat, jenis_kode, jenis_nama, assunto, pemohon_nama, tanggal_terbit, berlaku_sampai, status, penandatangan, kode_verifikasi')
    .eq('nomor_surat', String(nomor).trim())
    .single();

  if (error || !data) {
    return res.status(404).json({ notfound: true });
  }

  // Verify kode matches (case-insensitive)
  if ((data.kode_verifikasi || '').toLowerCase() !== String(kode).trim().toLowerCase()) {
    return res.status(404).json({ notfound: true });
  }

  return res.status(200).json(data);
}
