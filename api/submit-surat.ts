import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

function clean(s: unknown, max: number): string {
  return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max);
}

function isValidNik(nik: unknown): boolean {
  return typeof nik === "string" && /^\d{16}$/.test(nik);
}

function isValidKontak(kontak: unknown): boolean {
  if (!kontak) return true;
  return typeof kontak === "string" && kontak.length >= 8 && kontak.length <= 20 && /^[\d\s\-+()]+$/.test(kontak);
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !supabaseKey) {
    return res.status(500).json({ error: 'Missing Supabase configuration' });
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  const body = req.body || {};
  const nik = clean(body.nik, 16);
  const nama = clean(body.nama, 120);
  const kontak = clean(body.kontak, 20) || "-";
  const tenant_id = clean(body.tenant_id, 36);
  const jenis_surat_id = body.jenis_surat_id || null;
  const keperluan = clean(body.keperluan, 500);
  const lampiran = Array.isArray(body.lampiran) ? body.lampiran.slice(0, 10) : [];
  const data_dna = body.data_dna || null;
  const data_identitas = body.data_identitas || null;

  // Validate
  if (!isValidNik(nik)) return res.status(400).json({ error: 'NIK harus 16 digit angka' });
  if (!isValidKontak(kontak)) return res.status(400).json({ error: 'Format nomor kontak tidak valid' });
  if (!tenant_id || tenant_id.length < 10) return res.status(400).json({ error: 'tenant_id wajib diisi' });
  if (nama.length < 2) return res.status(400).json({ error: 'Nama minimal 2 karakter' });
  if (keperluan.length < 5) return res.status(400).json({ error: 'Keperluan minimal 5 karakter' });

  // Resolve effective tenant_id
  const fallbackTenantId = '00000000-0000-0000-0000-000000000001';
  let effectiveTenantId = fallbackTenantId;
  if (tenant_id !== fallbackTenantId) {
    const { data } = await supabase.from('tenants').select('id').eq('id', tenant_id).maybeSingle();
    if (data) effectiveTenantId = tenant_id;
  }

  // Generate nomor tiket
  const { data: nomor_tiket, error: tiketError } = await supabase.rpc('get_next_nomor_tiket', { p_prefix: 'SRT-' });
  if (tiketError || !nomor_tiket) {
    return res.status(500).json({ error: 'Failed to generate nomor tiket' });
  }

  // Use the RPC (SECURITY DEFINER = bypasses RLS)
  const { data: rpcResult, error: rpcError } = await supabase.rpc('submit_surat_ajuan', {
    p_tenant_id: effectiveTenantId,
    p_nomor_tiket: nomor_tiket,
    p_nik: nik,
    p_nama: nama,
    p_kontak: kontak || null,
    p_jenis_surat_id: jenis_surat_id,
    p_keperluan: keperluan,
    p_lampiran: lampiran as any,
    p_data_dna: data_dna as any,
    p_data_identitas: data_identitas as any,
  });

  if (rpcError) {
    return res.status(400).json({ error: rpcError.message });
  }

  return res.status(200).json({
    ok: true,
    nomor_tiket: rpcResult?.nomor_tiket || rpcResult?.data?.nomor_tiket,
    status: 'menunggu',
  });
}
