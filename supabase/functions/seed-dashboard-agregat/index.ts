import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? 'https://smngqdpbmgcdbmkiuviq.supabase.co'
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

const TID = 'd532ae95-0ad9-42bb-a6e8-5c840447c90e'

Deno.serve(async () => {
  const rows = [
    { tenant_id: TID, kategori: 'penduduk', metrik_key: 'total_penduduk', metrik_value: 1247, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'penduduk', metrik_key: 'jumlah_kk', metrik_value: 389, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'penduduk', metrik_key: 'laki_laki', metrik_value: 612, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'penduduk', metrik_key: 'perempuan', metrik_value: 635, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'kesehatan', metrik_key: 'balita_gizi_baik', metrik_value: 87, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'kesehatan', metrik_key: 'balita_stunting', metrik_value: 4, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'kesehatan', metrik_key: 'kades_terlayani', metrik_value: 156, periode: '2026-06-30' },
    { tenant_id: TID, kategori: 'kesehatan', metrik_key: 'ibu_hamil_terdaftar', metrik_value: 12, periode: '2026-06-30' },
  ]

  const results = []
  for (const row of rows) {
    const { error } = await supabase.from('dashboard_agregat').insert(row)
    results.push({ key: row.metrik_key, error: error?.message })
  }

  return Response.json({ success: true, results })
})
