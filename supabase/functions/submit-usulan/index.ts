// Public endpoint: warga menyampaikan usulan.
// Rate limited: 5/day per device.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json, voterHash, isValidUUID, checkRateLimit } from "../_shared/cors.ts";

const KATEGORI = new Set(["infrastruktur","ekonomi","sosial","pendidikan","kesehatan","lingkungan","pemerintahan","lainnya"]);

function clean(s: unknown, max: number): string {
  return String(s ?? "").replace(/\s+/g, " ").trim().slice(0, max);
}

// NIK validation for Indonesian citizen ID (16 digits)
function isValidNIK(nik: string): boolean {
  if (!/^\d{16}$/.test(nik)) return false;
  // Province code (1st 2 digits)
  const prov = parseInt(nik.substring(0, 2));
  if (prov < 1 || prov > 96) return false;
  // City/code (3rd-4th digits)
  const city = parseInt(nik.substring(2, 4));
  if (city < 1) return false;
  // District code (5th-6th digits)
  const dist = parseInt(nik.substring(4, 6));
  if (dist < 1) return false;
  // Date of birth (7th-12th digits - DDMMYY format)
  const dd = parseInt(nik.substring(6, 8));
  const mm = parseInt(nik.substring(8, 10));
  const yy = parseInt(nik.substring(10, 12));
  if (dd < 1 || dd > 31 || mm < 1 || mm > 12) return false;
  return true;
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => ({}));
  const nik = clean(body.nik, 16);
  const nama = clean(body.nama, 120);
  const kontak = clean(body.kontak, 60);
  const dusun = clean(body.dusun, 80);
  const kategori = clean(body.kategori, 40).toLowerCase();
  const judul = clean(body.judul, 160);
  const deskripsi = clean(body.deskripsi, 4000);
  const lokasi = clean(body.lokasi, 200);
  const foto_url = clean(body.foto_url, 500);

  // Enhanced validation
  if (!isValidNIK(nik)) return json({ error: "NIK harus 16 digit angka" }, 400, origin);
  if (nama.length < 2) return json({ error: "Nama minimal 2 karakter" }, 400, origin);
  if (judul.length < 5) return json({ error: "Judul minimal 5 karakter" }, 400, origin);
  if (deskripsi.length < 10) return json({ error: "Deskripsi terlalu pendek" }, 400, origin);
  if (!KATEGORI.has(kategori)) return json({ error: "Kategori tidak valid" }, 400, origin);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Rate limit: 5 per day
  const fp = await voterHash("usulan-submit", req);
  const rateLimit = await checkRateLimit(supabase, fp, "usulan_warga.dibuat_publik", 5, 86400000);
  if (!rateLimit.allowed) {
    return json({ error: "Batas usulan harian tercapai. Coba lagi besok." }, 429, origin);
  }

  // Get tenant
  const { data: tenant } = await supabase.from("tenants").select("id").limit(1).maybeSingle();
  if (!tenant) return json({ error: "Konfigurasi tenant tidak ditemukan" }, 500, origin);

  // Generate nomor tiket
  const now = new Date();
  const ym = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
  const prefix = `USL-${ym}-`;
  const { data: last } = await supabase
    .from("usulan_warga")
    .select("nomor_tiket")
    .like("nomor_tiket", `${prefix}%`)
    .order("nomor_tiket", { ascending: false })
    .limit(1);
  const nextSeq = last?.[0]?.nomor_tiket
    ? parseInt((last[0].nomor_tiket as string).split("-").pop() || "0", 10) + 1
    : 1;
  const nomor_tiket = `${prefix}${String(nextSeq).padStart(4, "0")}`;

  const { data: ins, error } = await supabase.from("usulan_warga").insert({
    tenant_id: tenant.id,
    nomor_tiket, nama, kontak: kontak || null, dusun: dusun || null,
    kategori, judul, deskripsi, lokasi: lokasi || null, foto_url: foto_url || null,
    status: "baru",
  }).select("id, nomor_tiket, status").single();
  if (error) return json({ error: error.message }, 400, origin);

  await supabase.from("event_log").insert({
    event_name: "usulan_warga.dibuat_publik",
    entitas: "usulan_warga",
    entitas_id: ins.id,
    payload: { fp, kategori, dusun, nomor_tiket },
  });

  return json({ ok: true, nomor_tiket: ins.nomor_tiket, status: ins.status, rate_limit: rateLimit }, 200, origin);
});
