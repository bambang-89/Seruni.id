import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

const STATUS_LABELS: Record<string, string> = {
  menunggu: 'Menunggu Verifikasi',
  diproses: 'Sedang Diproses',
  diterima: 'Diterima',
  ditolak: 'Ditolak',
  dibatalkan: 'Dibatalkan',
  ditandatangani: 'Ditandatangani',
};

const STATUS_COLORS: Record<string, string> = {
  menunggu: 'yellow',
  diproses: 'blue',
  diterima: 'green',
  ditolak: 'red',
  dibatalkan: 'gray',
  ditandatangani: 'green',
};

function json(res: VercelResponse, data: unknown, status = 200) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  return res.status(status).json(data);
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'OPTIONS') {
    return res.status(200)
      .setHeader('Access-Control-Allow-Origin', '*')
      .setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      .setHeader('Access-Control-Allow-Headers', 'Content-Type')
      .end();
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    return json(res, { error: 'Missing Supabase configuration' }, 500);
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  // GET /api/lacak-surat?ticket=SRT-YYYYMM-NNNN
  if (req.method === 'GET') {
    const ticket = String(req.query.ticket || req.query.nomor_tiket || '').trim().toUpperCase();

    if (!ticket || ticket.length < 5) {
      return json(res, { error: 'Nomor tiket wajib diisi' }, 400);
    }

    // Look up by nomor_tiket
    const { data: ajuan, error } = await supabase
      .from('surat_ajuan')
      .select(`
        id,
        nomor_tiket,
        nik,
        nama,
        kontak,
        jenis_surat_id,
        keperluan,
        status,
        lampiran,
        created_at,
        updated_at,
        surat_jenis:nama
      `)
      .eq('nomor_tiket', ticket)
      .maybeSingle();

    if (error) {
      return json(res, { error: 'Gagal mencari data: ' + error.message }, 500);
    }

    if (!ajuan) {
      return json(res, { error: 'Tiket tidak ditemukan. Pastikan nomor tiket benar.' }, 404);
    }

    // Check for published surat (surat_terbit)
    const { data: terbit } = await supabase
      .from('surat_terbit')
      .select('id, nomor_surat, status, qr_url, created_at')
      .eq('surat_ajuan_id', ajuan.id)
      .maybeSingle();

    // Get jenis surat name
    let jenisNama = 'Surat';
    if (ajuan.jenis_surat_id) {
      const { data: js } = await supabase
        .from('surat_jenis')
        .select('nama')
        .eq('id', ajuan.jenis_surat_id)
        .maybeSingle();
      if (js) jenisNama = js.nama;
    }

    return json(res, {
      ditemukan: true,
      nomor_tiket: ajuan.nomor_tiket,
      nama: ajuan.nama,
      nik_masked: ajuan.nik ? ajuan.nik.slice(0, 6) + '******' + ajuan.nik.slice(-4) : null,
      kontak: ajuan.kontak ? `*${ajuan.kontak.slice(-4)}` : null,
      jenis_surat: jenisNama,
      keperluan: ajuan.keperluan,
      status: ajuan.status,
      status_label: STATUS_LABELS[ajuan.status] || ajuan.status,
      status_color: STATUS_COLORS[ajuan.status] || 'gray',
      tanggal_ajuan: ajuan.created_at,
      tanggal_update: ajuan.updated_at,
      lampiran_count: Array.isArray(ajuan.lampiran) ? ajuan.lampiran.length : 0,
      surat_terbit: terbit ? {
        nomor_surat: terbit.nomor_surat,
        status: terbit.status,
        qr_url: terbit.qr_url,
        tanggal_diterbitkan: terbit.created_at,
      } : null,
    });
  }

  return json(res, { error: 'Method not allowed' }, 405);
}
