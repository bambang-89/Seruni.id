import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// API endpoint untuk admin membaca surat_ajuan dengan data_identitas
// Menggunakan service role key untuk bypass RLS

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,POST');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !supabaseKey) {
    return res.status(500).json({ error: 'Missing Supabase configuration' });
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  const { id, tenant_id, limit = '50', offset = '0' } = req.query;

  try {
    if (id) {
      // Fetch single surat with full detail including data_identitas
      const { data, error } = await supabase
        .from('surat_ajuan')
        .select('*, surat_jenis(nama, kode_klasifikasi, dna_field), surat_ajuan_data(data_dna, data_identitas)')
        .eq('id', id as string)
        .single();

      if (error) return res.status(404).json({ error: error.message });
      return res.status(200).json({ data });
    } else {
      // Fetch list
      let query = supabase
        .from('surat_ajuan')
        .select('*, surat_jenis(nama, kode_klasifikasi)')
        .order('created_at', { ascending: false })
        .limit(parseInt(limit as string))
        .range(parseInt(offset as string), parseInt(offset as string) + parseInt(limit as string) - 1);

      if (tenant_id) {
        query = query.eq('tenant_id', tenant_id as string);
      }

      const { data, error } = await query;
      if (error) return res.status(500).json({ error: error.message });
      return res.status(200).json({ data: data || [] });
    }
  } catch (err: any) {
    return res.status(500).json({ error: err.message });
  }
}
