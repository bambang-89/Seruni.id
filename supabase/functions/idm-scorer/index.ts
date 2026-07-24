// ============================================================
// IDM SCORER — Supabase Edge Function
// Worker untuk menghitung skor IDM dari data operasional
// Dipanggil via: pg_cron (scheduled) atau manual trigger
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ============================================================
// INDICATOR COMPUTATION (OPTIMIZED — pre-fetched data + batch upsert)
// ============================================================

interface PrecomputedCounts {
  totalPopulasi: number;
  bpjsAktif: number;
  bansos: number;
  penerima: number;
  umkm: number;
  tpst: number;
  voting: number;
  suara: number;
}

async function precomputeCounts(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
): Promise<PrecomputedCounts> {
  const counts: PrecomputedCounts = {
    totalPopulasi: 0,
    bpjsAktif: 0,
    bansos: 0,
    penerima: 0,
    umkm: 0,
    tpst: 0,
    voting: 0,
    suara: 0,
  };

  // Fetch all counts from penduduk in a single query
  const { data: pendudukData } = await sb
    .from("penduduk")
    .select("bpjs_kesehatan")
    .eq("tenant_id", tenantId)
    .eq("status_hidup", "aktif");

  if (pendudukData) {
    counts.totalPopulasi = pendudukData.length;
    counts.bpjsAktif = pendudukData.filter((r: any) => r.bpjs_kesehatan === true).length;
  }

  // Remaining independent counts can run in parallel
  const [bansosResult, penerimaResult, umkmResult, tpstResult, votingResult, suaraResult] = await Promise.all([
    sb.from("bantuan_sosial").select("*", { count: "exact", head: true }).eq("tenant_id", tenantId).eq("aktif", true),
    sb.from("penerima_bansos").select("*", { count: "exact", head: true }).eq("tenant_id", tenantId),
    sb.from("potensi_umkm").select("*", { count: "exact", head: true }).eq("tenant_id", tenantId).eq("status", "publish"),
    sb.from("infrastruktur").select("*", { count: "exact", head: true }).eq("tenant_id", tenantId).ilike("jenis", "%sampah%"),
    sb.from("voting_topik").select("*", { count: "exact", head: true }).eq("tenant_id", tenantId).eq("status", "ditutup"),
    sb.from("voting_suara").select("*", { count: "exact", head: true }),
  ]);

  counts.bansos = bansosResult.count ?? 0;
  counts.penerima = penerimaResult.count ?? 0;
  counts.umkm = umkmResult.count ?? 0;
  counts.tpst = tpstResult.count ?? 0;
  counts.voting = votingResult.count ?? 0;
  counts.suara = suaraResult.count ?? 0;

  return counts;
}

async function computeIndikator(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
  indikator: {
    indikator_no: string;
    dimensi_no: number;
    dimensi_nama: string;
    sumber_data: string;
  },
  precomputed: PrecomputedCounts,
  bulanIni: string,
  tahunIni: string,
): Promise<{ skor: number; nilai_agregat: number } | null> {
  const { indikator_no } = indikator;
  const { totalPopulasi, bpjsAktif, bansos, penerima, umkm, tpst, voting, suara } = precomputed;

  try {
    switch (indikator_no) {
      // D1-I3: Cakupan BPJS Kesehatan (uses precomputed counts)
      case "D1-I3": {
        const nilaiAgregat = totalPopulasi > 0 ? bpjsAktif / totalPopulasi : 0;
        return { skor: Math.round(Math.min(1, nilaiAgregat) * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // D1-I4: Cakupan Imunisasi
      case "D1-I4": {
        const { data: posyandu } = await sb
          .from("posyandu_agregat")
          .select("jumlah_balita, imunisasi_lengkap")
          .eq("periode", bulanIni)
          .limit(1);

        if (posyandu?.length && posyandu[0].jumlah_balita > 0) {
          const nilaiAgregat = posyandu[0].imunisasi_lengkap / posyandu[0].jumlah_balita;
          return { skor: Math.round(Math.min(1, nilaiAgregat) * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
        }
        return { skor: 0.5, nilai_agregat: 0 };
      }

      // D1-I5: Prevalensi Stunting (inverse)
      case "D1-I5": {
        const { data: stunting } = await sb
          .from("stunting_agregat")
          .select("balita_diukur, stunting")
          .eq("periode", bulanIni)
          .limit(1);

        if (stunting?.length && stunting[0].balita_diukur > 0) {
          const nilaiAgregat = 1 - (stunting[0].stunting / stunting[0].balita_diukur);
          return { skor: Math.round(Math.min(1, Math.max(0, nilaiAgregat)) * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
        }
        return { skor: 0.7, nilai_agregat: 0.3 };
      }

      // D1-I6: Cakupan Bantuan Sosial (uses precomputed counts)
      case "D1-I6": {
        const nilaiAgregat = totalPopulasi > 0 && bansos > 0
          ? Math.min(1, penerima / totalPopulasi)
          : 0;
        return { skor: Math.round(Math.min(1, nilaiAgregat) * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // D2-I1: PADes per Kapita (uses precomputed population, fetches apbdes separately)
      case "D2-I1": {
        const { data: apbdes } = await sb
          .from("apbdes")
          .select("anggaran")
          .eq("tenant_id", tenantId)
          .eq("tahun", tahunIni)
          .eq("jenis", "pendapatan")
          .single();

        if (apbdes && totalPopulasi > 0) {
          const pades = Number(apbdes.anggaran ?? 0);
          const nilaiAgregat = Math.min(1, pades / totalPopulasi / 10000);
          return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
        }
        return { skor: 0.3, nilai_agregat: 0.3 };
      }

      // D2-I3: Jumlah UMKM Aktif (uses precomputed count)
      case "D2-I3": {
        const nilaiAgregat = Math.min(1, umkm / 100);
        return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // D3-I5: Pengelolaan Sampah (uses precomputed count)
      case "D3-I5": {
        const nilaiAgregat = Math.min(1, tpst / 5);
        return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // D4-I3: Aktivitas Posyandu (frekuensi)
      case "D4-I3": {
        const { data: posyanduList } = await sb
          .from("posyandu_agregat")
          .select("id")
          .eq("periode", bulanIni);

        const nilaiAgregat = Math.min(1, (posyanduList?.length ?? 0) * 0.8);
        return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // D5-I2: Partisipasi Voting (uses precomputed counts)
      case "D5-I2": {
        if (totalPopulasi > 0) {
          const nilaiAgregat = voting > 0
            ? Math.min(1, suara / totalPopulasi)
            : 0.3;
          return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
        }
        return { skor: 0.3, nilai_agregat: 0.3 };
      }

      // D5-I5: Kelembagaan Desa
      case "D5-I5": {
        const { count: lembaga } = await sb
          .from("lembaga_desa")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId);

        const nilaiAgregat = Math.min(1, (lembaga ?? 0) / 10);
        return { skor: Math.round(nilaiAgregat * 100) / 100, nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000 };
      }

      // Default: placeholder score
      default:
        return { skor: 0.5, nilai_agregat: 0.5 };
    }
  } catch (err) {
    console.error(`Error computing ${indikator_no}:`, err);
    return null;
  }
}

// ============================================================
// MAIN SCORER
// ============================================================

async function runIdmScorer(sb: ReturnType<typeof createClient>, tenantId: string) {
  const errors: string[] = [];

  // 1. Ambil semua indikator aktif
  const { data: indicators, error: indError } = await sb
    .from("idm_indicators")
    .select("*")
    .eq("is_active", true);

  if (indError || !indicators?.length) {
    errors.push(`Gagal ambil indicators: ${indError?.message}`);
    return { tenantId, skorCount: 0, dimensiScores: {}, totalSkor: 0, status: "error", errors };
  }

  // 2. Precompute shared counts once per tenant
  const bulanIni = new Date().toISOString().slice(0, 7);
  const tahunIni = new Date().getFullYear().toString();
  const precomputed = await precomputeCounts(sb, tenantId);

  // 3. Compute score per indikator (no upsert yet)
  const allScores: any[] = [];
  for (const indicator of indicators) {
    const result = await computeIndikator(sb, tenantId, indicator, precomputed, bulanIni, tahunIni);
    if (result) {
      scores.push({ dimensi_no: indicator.dimensi_no, skor: result.skor });
      allScores.push({
        tenant_id: tenantId,
        indikator_kode: indicator.indikator_no,
        dimensi_no: indicator.dimensi_no,
        dimensi_nama: indicator.dimensi_nama,
        skor: result.skor,
        nilai_agregat: result.nilai_agregat,
        sumber_data: indicator.sumber_data,
        dihitung_pada: new Date().toISOString(),
      });
    }
  }

  // 4. Batch upsert all scores at once
  if (allScores.length > 0) {
    await sb.from("idm_skor_cache").upsert(allScores, { onConflict: "tenant_id,indikator_kode" });
  }

  // 5. Compute dimensi scores
  const dimensiMap: Record<number, number[]> = {};
  for (const s of scores) {
    if (!dimensiMap[s.dimensi_no]) dimensiMap[s.dimensi_no] = [];
    dimensiMap[s.dimensi_no].push(s.skor);
  }

  const dimensiScores: Record<number, number> = {};
  for (const [d, skorList] of Object.entries(dimensiMap)) {
    dimensiScores[Number(d)] = Math.round((skorList.reduce((a, b) => a + b, 0) / skorList.length) * 1000) / 1000;
  }

  // 6. Compute total skor
  const dimensiValues = Object.values(dimensiScores);
  const totalSkor = dimensiValues.length > 0
    ? Math.round((dimensiValues.reduce((a, b) => a + b, 0) / dimensiValues.length) * 1000) / 1000
    : 0;

  // 7. Tentukan status
  const status = totalSkor >= 0.8 ? "mandiri"
    : totalSkor >= 0.6 ? "maju"
    : totalSkor >= 0.5 ? "berkembang"
    : totalSkor >= 0.3 ? "tertinggal"
    : "sangat_tertinggal";

  // 8. Upsert idm_status_desa
  await sb.from("idm_status_desa").upsert(
    {
      tenant_id: tenantId,
      total_skor: totalSkor,
      status,
      dimensi_scores: dimensiScores,
      dimensi_skor_1: dimensiScores[1] ?? 0,
      dimensi_skor_2: dimensiScores[2] ?? 0,
      dimensi_skor_3: dimensiScores[3] ?? 0,
      dimensi_skor_4: dimensiScores[4] ?? 0,
      dimensi_skor_5: dimensiScores[5] ?? 0,
      dimensi_skor_6: dimensiScores[6] ?? 0,
      dihitung_pada: new Date().toISOString(),
    },
    { onConflict: "tenant_id" },
  );

  return { tenantId, skorCount: scores.length, dimensiScores, totalSkor, status, errors };
}

// ============================================================
// HANDLER
// ============================================================

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const sb = createClient(supabaseUrl, serviceKey);

  const body = await req.json().catch(() => ({}));
  let tenantId: string | null = body.tenant_id || null;

  if (!tenantId) {
    const { data: tenants } = await sb.from("tenants").select("id");
    if (!tenants?.length) {
      return json({ message: "Tidak ada tenant", processed: 0 });
    }

    const results = await Promise.all(tenants.map((t: any) => runIdmScorer(sb, t.id)));
    return json({ processed: tenants.length, results, timestamp: new Date().toISOString() });
  }

  const result = await runIdmScorer(sb, tenantId);
  return json({ ...result, timestamp: new Date().toISOString() });
});
