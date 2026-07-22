// ============================================================
// EVENT PROCESSOR — Supabase Edge Function
// Dipanggil via cron (pg_cron) atau manual trigger
// Fungsi: proses domain_events → update dashboard_agregat + idm_status_desa
// Prinsip: idempotent — pakai UPSERT
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
// EVENT TYPE → HANDLER MAPPING
// ============================================================

interface EventPayload {
  tenant_id?: string;
  [key: string]: unknown;
}

interface ProcessedEvent {
  eventType: string;
  tenantId: string | null;
  payload: EventPayload;
}

// Kategori event yang perlu recompute agregat
const KATEGORI_KEPENDUDUKAN = [
  "penduduk.dibuat",
  "penduduk.data.berubah",
  "penduduk.status.berubah",
  "keluarga.dibuat",
  "keluarga.status.berubah",
  "keluarga.data.berubah",
];

const KATEGORI_KESEHATAN = [
  "posyandu.kunjungan.dicatat",
  "posyandu.balita.terindikasi_gizi_buruk",
  "bansos.program.dibuat",
  "bansos.program.status.berubah",
];

const KATEGORI_PEMBANGUNAN = [
  "apbdes.disahkan",
  "apbdes.anggaran.berubah_signifikan",
  "musdes.kegiatan.ditambahkan",
  "musdes.kegiatan.disahkan",
  "infrastruktur.dilaporkan",
  "infrastruktur.diverifikasi",
  "bidang_tanah.didaftarkan",
  "bidang_tanah.disahkan",
];

const KATEGORI_SURAT = [
  "surat.diajukan",
  "surat.diverifikasi",
  "surat.ditolak",
  "surat.ditandatangani",
  "surat.diterbitkan",
  "surat.dikirim",
];

const KATEGORI_VOTING = [
  "voting.suara.ditambahkan",
  "voting.terhubung",
  "voting.ditutup",
];

const KATEGORI_USULAN = [
  "usulan.diajukan",
  "usulan.lolos_verifikasi",
  "usulan.ditolak",
  "usulan.ditetapkan_rkpdes",
  "usulan.vote.bertambah",
];

// ============================================================
// AGGREGATE COMPUTATION FUNCTIONS
// ============================================================

async function recomputeDashboardAgregat(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
  periode: string,
  kategori?: string,
) {
  const today = new Date().toISOString();
  const entries: Array<{
    tenant_id: string;
    wilayah_id: string | null;
    kategori: string;
    metrik_key: string;
    metrik_value: number;
    periode: string;
    dihitung_pada: string;
  }> = [];

  // 1. Kependudukan — selalu recompute jika perlu
  if (!kategori || kategori === "kependudukan") {
    const { count: totalAktif } = await sb
      .from("penduduk")
      .select("*", { count: "exact", head: true })
      .eq("status_hidup", "aktif");

    const { count: totalKK } = await sb
      .from("keluarga")
      .select("*", { count: "exact", head: true })
      .eq("status_kk", "aktif");

    const { data: wilayah } = await sb
      .from("wilayah_dusun")
      .select("nama, kk, jiwa");

    const { data: statAgama } = await sb
      .from("penduduk")
      .select("agama")
      .eq("status_hidup", "aktif");

    // Agregat by agama
    const agamaMap: Record<string, number> = {};
    for (const p of statAgama ?? []) {
      const agama = (p.agama as string) ?? "tidak_terjawab";
      agamaMap[agama] = (agamaMap[agama] ?? 0) + 1;
    }

    entries.push(
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "kependudukan",
        metrik_key: "jumlah_penduduk_aktif",
        metrik_value: totalAktif ?? 0,
        periode,
        dihitung_pada: today,
      },
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "kependudukan",
        metrik_key: "jumlah_kk_aktif",
        metrik_value: totalKK ?? 0,
        periode,
        dihitung_pada: today,
      },
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "kependudukan",
        metrik_key: "jumlah_jiwa",
        metrik_value: (wilayah ?? []).reduce((s, d) => s + (d.jiwa ?? 0), 0),
        periode,
        dihitung_pada: today,
      },
    );

    // Per-agama
    for (const [agama, jumlah] of Object.entries(agamaMap)) {
      entries.push({
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "kependudukan",
        metrik_key: `agama_${agama}`,
        metrik_value: jumlah,
        periode,
        dihitung_pada: today,
      });
    }
  }

  // 2. Kesehatan — recompute posyandu
  if (!kategori || kategori === "kesehatan") {
    const bulanIni = new Date().toISOString().slice(0, 7);
    const { data: posyandu } = await sb
      .from("posyandu_agregat")
      .select("jumlah_bayi, jumlah_balita, jumlah_ibu_hamil, jumlah_gizi_buruk")
      .eq("bulan", bulanIni)
      .limit(1);

    if (posyandu?.length) {
      const p = posyandu[0];
      entries.push(
        {
          tenant_id: tenantId,
          wilayah_id: null,
          kategori: "kesehatan",
          metrik_key: "jumlah_bayi",
          metrik_value: p.jumlah_bayi ?? 0,
          periode,
          dihitung_pada: today,
        },
        {
          tenant_id: tenantId,
          wilayah_id: null,
          kategori: "kesehatan",
          metrik_key: "jumlah_balita",
          metrik_value: p.jumlah_balita ?? 0,
          periode,
          dihitung_pada: today,
        },
        {
          tenant_id: tenantId,
          wilayah_id: null,
          kategori: "kesehatan",
          metrik_key: "jumlah_balita_gizi_buruk",
          metrik_value: p.jumlah_gizi_buruk ?? 0,
          periode,
          dihitung_pada: today,
        },
        {
          tenant_id: tenantId,
          wilayah_id: null,
          kategori: "kesehatan",
          metrik_key: "jumlah_ibu_hamil",
          metrik_value: p.jumlah_ibu_hamil ?? 0,
          periode,
          dihitung_pada: today,
        },
      );
    }

    // Bantuan sosial
    const { count: totalBansos } = await sb
      .from("bantuan_sosial")
      .select("*", { count: "exact", head: true });

    entries.push({
      tenant_id: tenantId,
      wilayah_id: null,
      kategori: "kesehatan",
      metrik_key: "jumlah_program_bansos",
      metrik_value: totalBansos ?? 0,
      periode,
      dihitung_pada: today,
    });
  }

  // 3. Pembangunan — recompute APBDes
  if (!kategori || kategori === "pembangunan") {
    const tahunIni = new Date().getFullYear().toString();
    const { data: apbdes } = await sb
      .from("apbdes")
      .select("total_anggaran, sumber_dana")
      .eq("tahun", tahunIni)
      .limit(1);

    if (apbdes?.length) {
      entries.push({
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "pembangunan",
        metrik_key: "total_apbdes",
        metrik_value: apbdes[0].total_anggaran ?? 0,
        periode,
        dihitung_pada: today,
      });
    }

    // Infrastruktur
    const { count: totalInfra } = await sb
      .from("infrastruktur")
      .select("*", { count: "exact", head: true })
      .eq("status", "terverifikasi");

    entries.push({
      tenant_id: tenantId,
      wilayah_id: null,
      kategori: "pembangunan",
      metrik_key: "infrastruktur_terverifikasi",
      metrik_value: totalInfra ?? 0,
      periode,
      dihitung_pada: today,
    });
  }

  // 4. Surat — hitung statistik
  if (!kategori || kategori === "surat") {
    const bulanIni = new Date().toISOString().slice(0, 7);
    const { count: totalSurat } = await sb
      .from("surat_terbit")
      .select("*", { count: "exact", head: true })
      .ilike("created_at", `${bulanIni}%`);

    const { count: suratDiterima } = await sb
      .from("surat_terbit")
      .select("*", { count: "exact", head: true })
      .eq("status", "diterbitkan")
      .ilike("created_at", `${bulanIni}%`);

    entries.push(
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "layanan",
        metrik_key: "surat_bulan_ini",
        metrik_value: totalSurat ?? 0,
        periode,
        dihitung_pada: today,
      },
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "layanan",
        metrik_key: "surat_diterbitkan_bulan_ini",
        metrik_value: suratDiterima ?? 0,
        periode,
        dihitung_pada: today,
      },
    );
  }

  // 5. Voting/Partisipasi — vote counts
  if (!kategori || kategori === "partisipasi") {
    const { count: totalVoting } = await sb
      .from("voting_topik")
      .select("*", { count: "exact", head: true })
      .eq("status", "aktif");

    const { count: totalSuara } = await sb
      .from("voting_suara")
      .select("*", { count: "exact", head: true });

    entries.push(
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "partisipasi",
        metrik_key: "voting_aktif",
        metrik_value: totalVoting ?? 0,
        periode,
        dihitung_pada: today,
      },
      {
        tenant_id: tenantId,
        wilayah_id: null,
        kategori: "partisipasi",
        metrik_key: "total_suara_voting",
        metrik_value: totalSuara ?? 0,
        periode,
        dihitung_pada: today,
      },
    );

    // Usulan
    const { count: totalUsulan } = await sb
      .from("usulan_warga")
      .select("*", { count: "exact", head: true })
      .eq("status", "terverifikasi");

    entries.push({
      tenant_id: tenantId,
      wilayah_id: null,
      kategori: "partisipasi",
      metrik_key: "usulan_terverifikasi",
      metrik_value: totalUsulan ?? 0,
      periode,
      dihitung_pada: today,
    });
  }

  // Upsert all entries
  for (const entry of entries) {
    await sb
      .from("dashboard_agregat")
      .upsert(entry, {
        onConflict: "tenant_id,wilayah_id,kategori,metrik_key,periode",
      });
  }

  return entries.length;
}

// ============================================================
// IDM SCORING ENGINE (Placeholder — tunggu PETA_DERIVATION_RULES_IDM.md)
// ============================================================

async function recomputeIdmStatus(
  sb: ReturnType<typeof createClient>,
  tenantId: string,
) {
  const today = new Date().toISOString();
  const periode = new Date().toISOString().slice(0, 7);

  // Ambil agregat yang dibutuhkan untuk IDM
  const { data: agregat } = await sb
    .from("dashboard_agregat")
    .select("kategori, metrik_key, metrik_value")
    .eq("tenant_id", tenantId)
    .eq("periode", periode);

  const map: Record<string, number> = {};
  for (const a of agregat ?? []) {
    const key = `${a.kategori}:${a.metrik_key}`;
    map[key] = a.metrik_value ?? 0;
  }

  // Hitung dimensi skor (placeholder — perlu PETA_DERIVATION_RULES_IDM.md)
  // Untuk sekarang, hitung berdasarkan data yang ada

  const dimensiScores: Record<string, number> = {
    kesehatan: 0,
    pendidikan: 0,
    modal_sosial: 0,
    permukiman: 0,
    ekonomi: 0,
    ekologi: 0,
  };

  // IKS (Indeks Kesehatan Society) — placeholder
  const totalPopulasi = map["kependudukan:jumlah_penduduk_aktif"] ?? 1;
  const balitaGiziBuruk = map["kesehatan:jumlah_balita_gizi_buruk"] ?? 0;
  const bansosCount = map["kesehatan:jumlah_program_bansos"] ?? 0;

  // Skor kesehatan: 0-1, makin banyak bansos makin baik
  dimensiScores.kesehatan = Math.min(1, (bansosCount / 10) * 0.5 + 0.5);

  // Pendidikan — placeholder (butuh data pendidikan dari penduduk)
  dimensiScores.pendidikan = 0.7; // Placeholder

  // Modal Sosial — dari voting/partisipasi
  const votingAktif = map["partisipasi:voting_aktif"] ?? 0;
  const suaraVoting = map["partisipasi:total_suara_voting"] ?? 0;
  dimensiScores.modal_sosial =
    totalPopulasi > 0
      ? Math.min(1, (suaraVoting / totalPopulasi) * 0.5 + votingAktif * 0.1 + 0.3)
      : 0.5;

  // Ekonomi — dari APBDes
  const totalApbdes = map["pembangunan:total_apbdes"] ?? 0;
  dimensiScores.ekonomi = Math.min(1, (totalApbdes / 10000000000) * 0.3 + 0.5); // 10M baseline

  // Permukiman — dari infrastruktur
  const infraVerified = map["pembangunan:infrastruktur_terverifikasi"] ?? 0;
  dimensiScores.permukiman = Math.min(1, (infraVerified / 50) * 0.4 + 0.4);

  // Ekologi — placeholder
  dimensiScores.ekologi = 0.75;

  // Total skor = rata-rata dimensi
  const totalSkor =
    Object.values(dimensiScores).reduce((a, b) => a + b, 0) /
    Object.keys(dimensiScores).length;

  // Klasifikasi
  const klasifikasi =
    totalSkor >= 0.8
      ? "mandiri"
      : totalSkor >= 0.6
        ? "maju"
        : totalSkor >= 0.5
          ? "berkembang"
          : "tertinggal";

  await sb
    .from("idm_status_desa")
    .upsert(
      {
        tenant_id: tenantId,
        total_skor: Math.round(totalSkor * 1000) / 1000,
        status: klasifikasi,
        dimensi_scores: dimensiScores,
        dihitung_pada: today,
      },
      { onConflict: "tenant_id" },
    );

  return { skor: totalSkor, klasifikasi, dimensiScores };
}

// ============================================================
// EVENT PROCESSOR — Main Loop
// ============================================================

async function processEvents(
  sb: ReturnType<typeof createClient>,
  events: Array<{ id: string; tenant_id: string | null; event_type: string; payload: EventPayload }>,
) {
  const results = {
    agregatUpdated: 0,
    idmUpdated: 0,
    errors: [] as string[],
  };

  // Group by tenant
  const byTenant = new Map<string, ProcessedEvent[]>();
  for (const e of events) {
    const tenantId = e.tenant_id ?? "default";
    if (!byTenant.has(tenantId)) {
      byTenant.set(tenantId, []);
    }
    byTenant.get(tenantId)!.push({
      eventType: e.event_type,
      tenantId,
      payload: e.payload,
    });
  }

  const periode = new Date().toISOString().slice(0, 7);

  // Proses per tenant
  for (const [tenantId, tenantEvents] of byTenant) {
    try {
      // Tentukan kategori yang perlu recompute
      const allEventTypes = tenantEvents.map((e) => e.eventType);

      let kategori: string | undefined;

      // Optimasi: recompute hanya kategori yang terpengaruh
      if (allEventTypes.some((t) => KATEGORI_KEPENDUDUKAN.includes(t))) {
        kategori = "kependudukan";
      } else if (allEventTypes.some((t) => KATEGORI_KESEHATAN.includes(t))) {
        kategori = "kesehatan";
      } else if (allEventTypes.some((t) => KATEGORI_PEMBANGUNAN.includes(t))) {
        kategori = "pembangunan";
      } else if (allEventTypes.some((t) => KATEGORI_SURAT.includes(t))) {
        kategori = "surat";
      } else if (allEventTypes.some((t) => KATEGORI_VOTING.includes(t) || KATEGORI_USULAN.includes(t))) {
        kategori = "partisipasi";
      }

      // Recompute agregat
      const count = await recomputeDashboardAgregat(sb, tenantId, periode, kategori);
      results.agregatUpdated += count;

      // Recompute IDM setiap ada event kependudukan atau kesehatan
      if (allEventTypes.some((t) =>
        KATEGORI_KEPENDUDUKAN.includes(t) ||
        KATEGORI_KESEHATAN.includes(t) ||
        KATEGORI_PEMBANGUNAN.includes(t)
      )) {
        await recomputeIdmStatus(sb, tenantId);
        results.idmUpdated++;
      }
    } catch (err) {
      results.errors.push(`${tenantId}: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  return results;
}

// ============================================================
// MAIN HANDLER
// ============================================================

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const sb = createClient(supabaseUrl, serviceKey);

  // Ambil event yang belum diproses (max 50 per run)
  const { data: events, error: fetchErr } = await sb
    .from("domain_events")
    .select("id, tenant_id, event_type, payload")
    .is("processed_at", null)
    .order("created_at", { ascending: true })
    .limit(50);

  if (fetchErr) {
    console.error("event-processor fetch error:", fetchErr);
    return errorJson("Gagal mengambil events: " + fetchErr.message, 500);
  }

  if (!events?.length) {
    return json({ processed: 0, message: "Tidak ada event pending" });
  }

  // Proses events
  const results = await processEvents(sb, events);

  // Tandai semua event sudah diproses
  const ids = events.map((e) => e.id);
  await sb
    .from("domain_events")
    .update({ processed_at: new Date().toISOString() })
    .in("id", ids);

  return json({
    processed: events.length,
    results,
    timestamp: new Date().toISOString(),
  });
});
