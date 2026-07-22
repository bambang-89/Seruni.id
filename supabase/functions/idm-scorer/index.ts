// ============================================================
// IDM SCORER — Supabase Edge Function
// Worker untuk menghitung skor IDM dari data operasional
// Dipanggil via: pg_cron (scheduled) atau manual trigger
// Fungsi:
//   1. Ambil data operasional dari tabel domain
//   2. Hitung skor per indikator (formula dari idm_indicators)
//   3. UPSERT ke idm_skor_cache
//   4. Recompute idm_status_desa
//   5. Generate draft usulan jika skor rendah
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders } from "npm:@supabase/supabase-js@2/cors";

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

function errorJson(message: string, status = 400) {
  return json({ error: message }, status);
}

// ============================================================
// TYPES
// ============================================================

interface IndicatorScore {
  indikator_kode: string;
  dimensi_no: number;
  dimensi_nama: string;
  skor: number;
  nilai_agregat: number;
  sumber_data: string;
}

interface DimensiScores {
  [dimensi: number]: number;
}

interface ScorerResult {
  tenantId: string;
  skorCount: number;
  dimensiScores: DimensiScores;
  totalSkor: number;
  status: string;
  errors: string[];
}

// ============================================================
// INDICATOR COMPUTATION FUNCTIONS
// ============================================================

async function computeIndikator(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
  indikator: {
    indikator_no: string;
    dimensi_no: number;
    dimensi_nama: string;
    sumber_data: string;
  },
): Promise<IndicatorScore | null> {
  const { indikator_no, dimensi_no, dimensi_nama, sumber_data } = indikator;

  let nilaiAgregat = 0;

  try {
    switch (indikator_no) {
      // Dimensi 1: Sosial - Kesehatan
      case "D1-I3": {
        // Cakupan BPJS Kesehatan
        const { count: totalAktif } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif");

        const { count: bpjsAktif } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif")
          .eq("bpjs_status", "aktif");

        nilaiAgregat =
          totalAktif && totalAktif > 0 ? (bpjsAktif ?? 0) / totalAktif : 0;
        break;
      }

      case "D1-I4": {
        // Cakupan Imunisasi (dari posyandu)
        const bulanIni = new Date().toISOString().slice(0, 7);
        const { data: posyandu } = await sb
          .from("posyandu_agregat")
          .select("jumlah_balita, imunisasi_lengkap")
          .eq("bulan", bulanIni)
          .limit(1);

        if (posyandu?.length) {
          nilaiAgregat = posyandu[0].jumlah_balita > 0
            ? (posyandu[0].imunisasi_lengkap ?? 0) / posyandu[0].jumlah_balita
            : 0;
        }
        break;
      }

      case "D1-I5": {
        // Prevalensi Stunting (inverse - makin tinggi makin buruk)
        const bulanIni = new Date().toISOString().slice(0, 7);
        const { data: stunting } = await sb
          .from("stunting_agregat")
          .select("jumlah_balita, jumlah_stunting")
          .eq("bulan", bulanIni)
          .limit(1);

        if (stunting?.length) {
          // Inverse: 1 - (stunting / total), makin tinggi makin baik
          nilaiAgregat = stunting[0].jumlah_balita > 0
            ? 1 - (stunting[0].jumlah_stunting ?? 0) / stunting[0].jumlah_balita
            : 1;
        }
        break;
      }

      case "D1-I6": {
        // Cakupan Bantuan Sosial
        const { count: bansos } = await sb
          .from("bantuan_sosial")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status", "aktif");

        const { count: penerima } = await sb
          .from("penerima_bansos")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId);

        const { count: totalPopulasi } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif");

        nilaiAgregat = totalPopulasi && totalPopulasi > 0 && bansos && bansos > 0
          ? Math.min(1, (penerima ?? 0) / totalPopulasi)
          : 0;
        break;
      }

      // Dimensi 2: Ekonomi
      case "D2-I1":
      case "D2-I2": {
        // PADes per Kapita (dari APBDes)
        const tahunIni = new Date().getFullYear().toString();
        const { data: apbdes } = await sb
          .from("apbdes")
          .select("total_anggaran, pendapatan_total")
          .eq("tenant_id", tenantId)
          .eq("tahun", tahunIni)
          .single();

        const { count: totalPopulasi } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif");

        if (apbdes && totalPopulasi && totalPopulasi > 0) {
          const pades = apbdes.pendapatan_total ?? apbdes.total_anggaran ?? 0;
          if (indikator_no === "D2-I1") {
            nilaiAgregat = pades / totalPopulasi / 10000; // Normalize
          } else {
            nilaiAgregat = Math.min(1, pades / 100000000); // YoY proxy
          }
        }
        break;
      }

      case "D2-I3": {
        // Jumlah Sektor Ekonomi Aktif (UMKM)
        const { count: umkm } = await sb
          .from("potensi_umkm")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status", "aktif");

        nilaiAgregat = Math.min(1, (umkm ?? 0) / 100); // Normalize: 100 UMKM = skor max
        break;
      }

      case "D2-I5": {
        // Tingkat Pengangguran (inverse)
        // Proxy: penduduk usia produktif yang tidak ada pekerjaan
        const { count: total } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif");

        const { count: punyaPekerjaan } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif")
          .not("pekerjaan", "eq", "");

        if (total && total > 0) {
          nilaiAgregat = 1 - ((total - (punyaPekerjaan ?? 0)) / total);
        }
        break;
      }

      case "D2-I6": {
        // Usaha Mikro Aktif
        const { count: umkm } = await sb
          .from("potensi_umkm")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status", "aktif");

        nilaiAgregat = Math.min(1, (umkm ?? 0) / 50);
        break;
      }

      // Dimensi 3: Lingkungan
      case "D3-I2": {
        // Sanitasi Layak (placeholder - butuh data sanitation survey)
        nilaiAgregat = 0.7; // Placeholder
        break;
      }

      case "D3-I3": {
        // Air Bersih Layak (placeholder)
        nilaiAgregat = 0.75; // Placeholder
        break;
      }

      case "D3-I5": {
        // Pengelolaan Sampah (dari infrastruktur/lingkungan)
        const { count: tpst } = await sb
          .from("infrastruktur")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .ilike("jenis", "%sampah%");

        nilaiAgregat = Math.min(1, (tpst ?? 0) / 5);
        break;
      }

      // Dimensi 4: Infrastruktur & Pelayanan
      case "D4-I3": {
        // Aktivitas Posyandu (frekuensi)
        const bulanIni = new Date().toISOString().slice(0, 7);
        const { count: kunjungan } = await sb
          .from("posyandu_agregat")
          .select("*", { count: "exact", head: true })
          .eq("bulan", bulanIni);

        // Minimal 1x per bulan = skor 0.8
        nilaiAgregat = Math.min(1, ((kunjungan ?? 0) * 0.8));
        break;
      }

      case "D4-I4": {
        // Aktivitas Posyandu (cakupan)
        const bulanIni = new Date().toISOString().slice(0, 7);
        const { data: posyandu } = await sb
          .from("posyandu_agregat")
          .select("jumlah_balita, kunjungan_lebih_dari_sekali")
          .eq("bulan", bulanIni)
          .limit(1);

        if (posyandu?.length) {
          nilaiAgregat = posyandu[0].jumlah_balita > 0
            ? Math.min(1, (posyandu[0].kunjungan_lebih_dari_sekali ?? 0) / posyandu[0].jumlah_balita)
            : 0;
        }
        break;
      }

      // Dimensi 5: Tata Kelola
      case "D5-I1": {
        // Frekuensi Musdes (minimal 1x per tahun = skor 0.5)
        const tahunIni = new Date().getFullYear().toString();
        const { count: musdes } = await sb
          .from("kegiatan_pembangunan")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .ilike("nama_kegiatan", "%musdes%")
          .ilike("tahun", `%${tahunIni}%`);

        nilaiAgregat = Math.min(1, (musdes ?? 0) * 0.5);
        break;
      }

      case "D5-I2": {
        // Partisipasi Musdes (dari voting)
        const { count: voting } = await sb
          .from("voting_topik")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status", "ditutup");

        const { count: suara } = await sb
          .from("voting_suara")
          .select("*", { count: "exact", head: true });

        const { count: totalPopulasi } = await sb
          .from("penduduk")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status_hidup", "aktif");

        if (totalPopulasi && totalPopulasi > 0 && voting && voting > 0) {
          nilaiAgregat = Math.min(1, (suara ?? 0) / totalPopulasi);
        }
        break;
      }

      case "D5-I3": {
        // Capaian APBDes
        const tahunIni = new Date().getFullYear().toString();
        const { data: apbdes } = await sb
          .from("apbdes")
          .select("total_anggaran, total_realisasi")
          .eq("tenant_id", tenantId)
          .eq("tahun", tahunIni)
          .single();

        if (apbdes && apbdes.total_anggaran > 0) {
          nilaiAgregat = (apbdes.total_realisasi ?? 0) / apbdes.total_anggaran;
        }
        break;
      }

      case "D5-I4": {
        // Transparansi Keuangan (dari berita/pengumuman APBDes)
        const tahunIni = new Date().getFullYear().toString();
        const { count: publikasi } = await sb
          .from("berita")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .ilike("judul", "%apbdes%")
          .ilike("created_at", `%${tahunIni}%`);

        nilaiAgregat = Math.min(1, (publikasi ?? 0) * 0.2);
        break;
      }

      case "D5-I5": {
        // Kelembagaan Desa
        const { count: lembaga } = await sb
          .from("lembaga_desa")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("status", "aktif");

        // Minimal 5 lembaga = skor 0.8
        nilaiAgregat = Math.min(1, (lembaga ?? 0) / 10);
        break;
      }

      // Dimensi 6: Teknologi
      case "D6-I2": {
        // Persentase Surat Digital
        const bulanIni = new Date().toISOString().slice(0, 7);
        const { count: totalSurat } = await sb
          .from("surat_terbit")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .ilike("created_at", `${bulanIni}%`);

        const { count: suratDigital } = await sb
          .from("surat_terbit")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("jenis", "surat_digital")
          .ilike("created_at", `${bulanIni}%`);

        nilaiAgregat = totalSurat && totalSurat > 0
          ? (suratDigital ?? 0) / totalSurat
          : 0;
        break;
      }

      case "D6-I4": {
        // Pemanfaatan Data (dari analisis_snapshot published)
        const { count: analisis } = await sb
          .from("analisis_snapshot")
          .select("*", { count: "exact", head: true })
          .eq("tenant_id", tenantId)
          .eq("published", true);

        nilaiAgregat = Math.min(1, (analisis ?? 0) / 12); // 12 analisis per tahun
        break;
      }

      // Default: placeholder
      default:
        nilaiAgregat = 0.5;
    }
  } catch (err) {
    console.error(`Error computing ${indikator_no}:`, err);
    return null;
  }

  // Normalize skor (0-1)
  const skor = Math.min(1, Math.max(0, nilaiAgregat));

  return {
    indikator_kode: indikator_no,
    dimensi_no,
    dimensi_nama,
    skor: Math.round(skor * 100) / 100,
    nilai_agregat: Math.round(nilaiAgregat * 1000) / 1000,
    sumber_data,
  };
}

// ============================================================
// MAIN SCORER
// ============================================================

async function runIdmScorer(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
): Promise<ScorerResult> {
  const result: ScorerResult = {
    tenantId,
    skorCount: 0,
    dimensiScores: {},
    totalSkor: 0,
    status: "tidak_klasifikasi",
    errors: [],
  };

  // 1. Ambil semua indikator aktif
  const { data: indicators, error: indError } = await sb
    .from("idm_indicators")
    .select("*")
    .eq("is_active", true);

  if (indError || !indicators?.length) {
    result.errors.push(`Gagal ambil indicators: ${indError?.message}`);
    return result;
  }

  // 2. Compute score per indikator
  const scores: IndicatorScore[] = [];
  for (const indicator of indicators) {
    const score = await computeIndikator(sb, tenantId, indicator);
    if (score) {
      scores.push(score);
    }
  }

  // 3. Upsert ke idm_skor_cache
  for (const score of scores) {
    const { error: upsertError } = await sb
      .from("idm_skor_cache")
      .upsert(
        {
          tenant_id: tenantId,
          indikator_id: null, // We'll use indikator_kode instead
          indikator_kode: score.indikator_kode,
          dimensi_no: score.dimensi_no,
          dimensi_nama: score.dimensi_nama,
          skor: score.skor,
          nilai_agregat: score.nilai_agregat,
          sumber_data: score.sumber_data,
          dihitung_pada: new Date().toISOString(),
        },
        {
          onConflict: "tenant_id,indikator_kode",
        },
      );

    if (upsertError) {
      result.errors.push(`Upsert ${score.indikator_kode}: ${upsertError.message}`);
    } else {
      result.skorCount++;
    }
  }

  // 4. Compute dimensi scores (rata-rata per dimensi)
  const dimensiMap: Record<number, number[]> = {};
  for (const s of scores) {
    if (!dimensiMap[s.dimensi_no]) {
      dimensiMap[s.dimensi_no] = [];
    }
    dimensiMap[s.dimensi_no].push(s.skor);
  }

  for (const [dimensi, skorList] of Object.entries(dimensiMap)) {
    const avgSkor = skorList.reduce((a, b) => a + b, 0) / skorList.length;
    result.dimensiScores[Number(dimensi)] = Math.round(avgSkor * 1000) / 1000;
  }

  // 5. Compute total skor (rata-rata 6 dimensi)
  const dimensiValues = Object.values(result.dimensiScores);
  if (dimensiValues.length > 0) {
    result.totalSkor = Math.round(
      (dimensiValues.reduce((a, b) => a + b, 0) / dimensiValues.length) * 1000,
    ) / 1000;
  }

  // 6. Tentukan status
  result.status =
    result.totalSkor >= 0.8
      ? "mandiri"
      : result.totalSkor >= 0.6
        ? "maju"
        : result.totalSkor >= 0.5
          ? "berkembang"
          : result.totalSkor >= 0.3
            ? "tertinggal"
            : "sangat_tertinggal";

  // 7. Upsert idm_status_desa
  await sb.from("idm_status_desa").upsert(
    {
      tenant_id: tenantId,
      total_skor: result.totalSkor,
      status: result.status,
      dimensi_scores: result.dimensiScores,
      dimensi_skor_1: result.dimensiScores[1] ?? 0,
      dimensi_skor_2: result.dimensiScores[2] ?? 0,
      dimensi_skor_3: result.dimensiScores[3] ?? 0,
      dimensi_skor_4: result.dimensiScores[4] ?? 0,
      dimensi_skor_5: result.dimensiScores[5] ?? 0,
      dimensi_skor_6: result.dimensiScores[6] ?? 0,
      dihitung_pada: new Date().toISOString(),
    },
    { onConflict: "tenant_id" },
  );

  // 8. Generate draft usulan untuk skor rendah
  for (const score of scores) {
    if (score.skor < 0.5 && score.sumber_data === "operasional") {
      const { data: indicator } = await sb
        .from("idm_indicators")
        .select("indikator_nama, kode_rekening, rekomendasi_intervensi")
        .eq("indikator_no", score.indikator_kode)
        .single();

      if (indicator) {
        await sb.from("usulan_kegiatan_draft_otomatis").insert({
          tenant_id: tenantId,
          kategori: "pembangunan",
          sumber_pemicu: "idm.skor.rendah",
          indikator_kode: score.indikator_kode,
          kode_rekening_saran: indicator.kode_rekening,
          judul_saran: `Draft Otomatis: ${indicator.indikator_nama}`,
          deskripsi_saran: `Skor rendah (${score.skor}). Rekomendasi: ${indicator.rekomendasi_intervensi ?? "Perlu intervensi"}.`,
          status: "menunggu_review",
        });
      }
    }
  }

  return result;
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

  let tenantId: string | null = null;

  // Parse body
  const body = await req.json().catch(() => ({}));
  if (body.tenant_id) {
    tenantId = body.tenant_id;
  }

  // Ambil semua tenant jika tidak spesifik
  if (!tenantId) {
    const { data: tenants, error: tenantError } = await sb
      .from("tenants")
      .select("id");

    if (tenantError) {
      return errorJson("Gagal ambil tenants: " + tenantError.message, 500);
    }

    if (!tenants?.length) {
      return json({ message: "Tidak ada tenant", processed: 0 });
    }

    const results = [];
    for (const t of tenants) {
      const result = await runIdmScorer(sb, t.id);
      results.push(result);
    }

    return json({
      processed: tenants.length,
      results,
      timestamp: new Date().toISOString(),
    });
  }

  // Proses satu tenant
  const result = await runIdmScorer(sb, tenantId);
  return json({
    ...result,
    timestamp: new Date().toISOString(),
  });
});
