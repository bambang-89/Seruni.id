import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // Setup CORS
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase configuration');
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false
      }
    });
    const body = req.body;

    const nik = body.nik;
    const nama = body.nama;
    const kontak = body.kontak;
    const jenis_surat_id = body.jenis_surat_id;
    const keperluan = body.keperluan;
    const lampiran = body.lampiran || [];
    const data_dna = body.data_dna || null;
    const data_identitas_raw = body.data_identitas;

    // Get Tenant
    const { data: tenant } = await supabase.from('tenants').select('id').limit(1).maybeSingle();
    if (!tenant) {
      return res.status(500).json({ error: 'Tenant not found' });
    }

    // Get Next Nomor Tiket
    const { data: nomor_tiket, error: tiketError } = await supabase.rpc('get_next_nomor_tiket', { p_prefix: 'SRT-' });
    if (tiketError || !nomor_tiket) {
      return res.status(500).json({ error: 'Failed to generate nomor tiket' });
    }

    // Insert Surat Ajuan
    const { data: ins, error } = await supabase
      .from('surat_ajuan')
      .insert({
        tenant_id: tenant.id,
        nomor_tiket,
        nik,
        nama,
        kontak,
        jenis_surat_id: jenis_surat_id || null,
        keperluan,
        lampiran: Array.isArray(lampiran) ? lampiran : [],
        status: 'menunggu',
      })
      .select('id, nomor_tiket, status')
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    // Persist DNA data if provided
    if ((data_dna || data_identitas_raw) && typeof (data_dna || data_identitas_raw) === 'object') {
      await supabase
        .from('surat_ajuan_data')
        .insert({
          tenant_id: tenant.id,
          surat_ajuan_id: ins.id,
          data_dna: data_dna || {},
          data_identitas: data_identitas_raw || {},
        });
    }

    await supabase.from('event_log').insert({
      event_name: 'surat.diajukan',
      entitas: 'surat_ajuan',
      entitas_id: ins.id,
      payload: { nik, nomor_tiket },
    });

    return res.status(200).json({
      ok: true,
      nomor_tiket: ins.nomor_tiket,
      status: ins.status,
    });
  } catch (err: any) {
    return res.status(500).json({ error: err.message || 'Internal server error' });
  }
}
