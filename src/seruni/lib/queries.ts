import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import type { SupabaseClient } from '@supabase/supabase-js';
import { useTenantId } from "./tenant";

// Untyped client for tables not in the Database type definition.
// The typed `supabase` (above) only knows tables listed in Database.
// Use `raw` for dynamic table access — avoids per-call `as any`.
export const raw = supabase as unknown as SupabaseClient;

export type ProfilDesa = {
  sejarah: string[];
  visi: string;
  misi: string[];
  gambar_hero_url?: string | null;
  gambar_logo_url?: string | null;
  video_url?: string | null;
};
export type Pamong = {
  id?: string;
  nama: string;
  jabatan: string;
  periode?: string | null;
  urutan: number;
  foto_url?: string | null;
  foto_selfie_url?: string | null;
  nip?: string | null;
  email?: string | null;
  no_hp?: string | null;
};
export type Dusun = { id?: string; nama: string; kk: number; jiwa: number; luas_ha: number; urutan: number; latitude?: number | string | null; longitude?: number | string | null };
export type Lembaga = { id?: string; nama: string; ketua: string; jumlah_anggota: number; urutan: number };

export type Berita = {
  id?: string;
  slug: string;
  kategori: string;
  judul: string;
  ringkasan: string;
  isi: string[];
  penulis: string;
  tanggal: string;
  published: boolean;
  cover_url?: string | null;
  gambar_url?: string | null;
  gambar_gallery?: string[] | null;
  gambar_alt?: string | null;
};
export type Agenda = {
  id?: string;
  slug: string;
  jenis: string;
  judul: string;
  tanggal: string;
  waktu?: string | null;
  lokasi?: string | null;
  penyelenggara?: string | null;
  foto_url?: string | null;
  deskripsi?: string | null;
};
export type Pengumuman = {
  id?: string;
  nomor: string;
  tanggal: string;
  judul: string;
  ringkasan?: string | null;
  foto_url?: string | null;
  deskripsi?: string | null;
  lampiran_url?: string | null;
};
export type Galeri = {
  id?: string;
  judul: string;
  emoji: string;
  album: string;
  tanggal: string;
  urutan: number;
  foto_url?: string | null;
  video_url?: string | null;
  fotografer?: string | null;
  sumber?: string | null;
  deskripsi?: string | null;
};

export type HeroSlider = {
  id: string;
  judul: string;
  sub_judul?: string | null;
  deskripsi?: string | null;
  gambar_url: string;
  gambar_mobile_url?: string | null;
  tombol_teks?: string | null;
  tombol_url?: string | null;
  urutan: number;
  aktif: boolean;
};

export type IdentitasDesa = {
  id: string;
  nama_desa: string;
  kabupaten: string | null;
  kecamatan: string | null;
  provinsi: string | null;
  kode_pos: string | null;
  logo_url: string | null;
  slogan: string | null;
  video_url: string | null;
  tahun_bentuk: number | null;
  luas_wilayah: number | null;
  koordinat_lat: number | null;
  koordinat_lng: number | null;
  zoom_level: number | null;
};

export type DokumenUpload = {
  id: string;
  entity_type: string;
  entity_id: string | null;
  kategori: string;
  nama_file: string;
  nama_asli: string;
  tipe_file: string;
  ukuran_file: number;
  storage_path: string;
  storage_url: string | null;
  is_utama: boolean;
  created_at: string;
};

export function useProfilDesa() {
  const [data, setData] = useState<ProfilDesa>({ sejarah: [], visi: "", misi: [] });
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("profil_desa")
      .select("sejarah,visi,misi,gambar_hero_url,gambar_logo_url,video_url")
      .eq("singleton", true)
      .maybeSingle()
      .then(({ data: r }) => {
        if (r) setData({
          sejarah: r.sejarah as string[],
          visi: r.visi,
          misi: r.misi as string[],
          gambar_hero_url: r.gambar_hero_url,
          gambar_logo_url: r.gambar_logo_url,
          video_url: r.video_url,
        });
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function usePamong() {
  const tenantId = useTenantId();
  const [data, setData] = useState<Pamong[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("desa_pamong").select("*").order("urutan");
    if (tenantId) q = q.eq("tenant_id", tenantId);
    q.then(({ data: r }) => {
      if (r?.length) setData(r as Pamong[]);
      setLoading(false);
    });
  }, [tenantId]);
  return { data, loading };
}

export function useDusun() {
  const tenantId = useTenantId();
  const [data, setData] = useState<Dusun[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("wilayah_dusun").select("*").order("urutan");
    if (tenantId) q = q.eq("tenant_id", tenantId);
    q.then(({ data: r }) => {
      if (r?.length) setData(r.map((x: any) => ({ ...x, luas_ha: Number(x.luas_ha) })) as Dusun[]);
      setLoading(false);
    });
  }, [tenantId]);
  return { data, loading };
}

export function useLembaga() {
  const [data, setData] = useState<Lembaga[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("lembaga_desa").select("*").order("urutan").then(({ data: r }) => {
      if (r?.length) setData(r as Lembaga[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}
// ===================== Surat Identitas Autofill =====================

export type IdentitasData = {
  nik: string;
  nama: string;
  tempat_lahir: string;
  tanggal_lahir: string; // ISO date string
  jenis_kelamin: string; // "Laki-laki" | "Perempuan"
  agama: string;
  pendidikan: string;
  pekerjaan: string;
  status_kawin: string;
  kewarganegaraan: string;
  alamat_lengkap: string; // includes alamat rumah + composeAlamat output
  dusun?: string;
  rt?: string;
  rw?: string;
  kabupaten?: string;
  provinsi?: string;
  no_kk: string;
  nomor_hp?: string;
};

const BULAN_INDO = [
  "Januari", "Februari", "Maret", "April", "Mei", "Juni",
  "Juli", "Agustus", "September", "Oktober", "November", "Desember",
];
export function formatTanggalLahir(tanggal: string, tempat: string): string {
  if (!tanggal) return tempat || "-";
  try {
    const parts = tanggal.split("T")[0].split("-");
    if (parts.length === 3) {
      // If it looks like YYYY-MM-DD
      if (parts[0].length === 4) {
        const year = parts[0];
        const month = parts[1];
        const day = parts[2];
        return `${tempat || "-"}, ${day}-${month}-${year}`;
      } else if (parts[2].length === 4) {
        // If it looks like DD-MM-YYYY
        const day = parts[0];
        const month = parts[1];
        const year = parts[2];
        return `${tempat || "-"}, ${day}-${month}-${year}`;
      }
    }
    // Fallback using Date parser
    const d = new Date(tanggal);
    if (!isNaN(d.getTime())) {
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const year = d.getFullYear();
      return `${tempat || "-"}, ${day}-${month}-${year}`;
    }
  } catch (err) {
    console.error(err);
  }
  return `${tempat || "-"}, ${tanggal}`;
}

export function composeAlamat(
  alamat: unknown,
  dusun: unknown,
  rt: unknown,
  rw: unknown,
  kecamatan: unknown,
  kabupaten: unknown,
  provinsi: unknown,
): string {
  const v = (val: unknown) => (val == null ? "" : String(val).trim());
  const parts = [
    v(alamat) || null,
    v(dusun) ? `Dusun ${v(dusun)}` : null,
    v(rt) || v(rw) ? `RT ${v(rt)}/RW ${v(rw)}` : null,
    v(kecamatan) ? `Kec. ${v(kecamatan)}` : null,
    v(kabupaten) ? `Kab. ${v(kabupaten)}` : null,
    v(provinsi) || null,
  ].filter(Boolean) as string[];
  return parts.join(", ") || "-";
}

export async function fetchKewarganegaraan(warga_negara_id: unknown): Promise<string> {
  if (!warga_negara_id) return "WNI";
  try {
    const { data } = await raw
      .from("ref_warga_negara")
      .select("nama")
      .eq("id", warga_negara_id as string)
      .maybeSingle();
    return (data as { nama: string } | null)?.nama ?? "WNI";
  } catch {
    return "WNI";
  }
}

export function useBerita(opts: { publishedOnly?: boolean } = { publishedOnly: true }) {
  const [data, setData] = useState<Berita[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("berita").select("*").order("tanggal", { ascending: false });
    if (opts.publishedOnly) q = q.eq("published", true);
    q.then(({ data: r }) => {
      if (r?.length) setData(r.map((x: any) => ({ ...x, isi: (x.isi as string[]) || [] })) as Berita[]);
      setLoading(false);
    });
  }, [opts.publishedOnly]);
  return { data, loading };
}

export function useBeritaBySlug(slug?: string) {
  const [data, setData] = useState<Berita | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!slug) { setLoading(false); return; }
    supabase.from("berita").select("*").eq("slug", slug).eq("published", true).maybeSingle().then(({ data: r }) => {
      if (r) setData({ ...r, isi: (r.isi as string[]) || [] } as Berita);
      else {
        setData(null);
      }
      setLoading(false);
    });
  }, [slug]);
  return { data, loading };
}

export function useAgenda() {
  const [data, setData] = useState<Agenda[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("agenda").select("*").order("tanggal").then(({ data: r }) => {
      if (r?.length) setData(r as Agenda[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

export function usePengumuman() {
  const [data, setData] = useState<Pengumuman[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("pengumuman").select("*").order("tanggal", { ascending: false }).then(({ data: r }) => {
      if (r?.length) setData(r as Pengumuman[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

export function useGaleri() {
  const [data, setData] = useState<Galeri[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("galeri").select("*").order("urutan").then(({ data: r }) => {
      if (r?.length) setData(r as Galeri[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

// ===================== Image-based queries =====================

export function useHeroSlider() {
  const [data, setData] = useState<HeroSlider[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("hero_slider")
      .select("*")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r?.length) {
          setData(r as HeroSlider[]);
        }
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useIdentitasDesa() {
  const [data, setData] = useState<IdentitasDesa | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("identitas_desa")
      .select("*")
      .eq("singleton", true)
      .maybeSingle()
      .then(({ data: r }) => {
        if (r) setData(r as IdentitasDesa);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useDokumenUpload(
  entityType: string,
  entityId: string,
  kategori?: string
) {
  const [data, setData] = useState<DokumenUpload[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!entityId) {
      setData([]);
      setLoading(false);
      return;
    }

    let query = supabase.from("dokumen_upload")
      .select("*")
      .eq("entity_type", entityType)
      .eq("entity_id", entityId);

    if (kategori) {
      query = query.eq("kategori", kategori);
    }

    query.then(({ data: r }) => {
      if (r?.length) {
        setData(r as DokumenUpload[]);
      }
      setLoading(false);
    });
  }, [entityType, entityId, kategori]);

  return { data, loading };
}

// ===================== Phase 6B: Potensi, Marketplace, Wisata =====================

export type PotensiUmkm = {
  id: string;
  tipe: string;
  nama: string;
  pemilik: string | null;
  sektor: string | null;
  dusun: string | null;
  kontak_penjual: string | null;
  kontak?: string | null;
  alamat: string | null;
  deskripsi: string | null;
  foto_url: string | null;
  verified: boolean;
  status: string;
};
export type PotensiProduk = {
  id: string;
  umkm_id: string | null;
  penjual_nama: string;
  nama: string;
  kategori: string | null;
  harga: number | null;
  satuan: string | null;
  stok: number | null;
  deskripsi: string | null;
  foto_url: string | null;
  kontak_penjual: string | null;
  verified: boolean;
  featured: boolean;
  status: string;
};
export type PotensiWisata = {
  id: string;
  tipe?: string;
  nama: string;
  jenis: string;
  dusun: string | null;
  alamat: string | null;
  deskripsi: string | null;
  latitude: number | null;
  longitude: number | null;
  foto_url: string | null;
  fasilitas: string | null;
  status: string;
};

export function usePotensiUmkm(tipe?: string) {
  const [data, setData] = useState<PotensiUmkm[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("potensi_umkm").select("*").eq("status", "publish").order("nama");
    if (tipe) q = q.eq("tipe", tipe);
    q.then(({ data: r }) => {
      setData((r && Array.isArray(r)) ? (r as unknown as PotensiUmkm[]) : []);
      setLoading(false);
    });
  }, [tipe]);
  return { data, loading };
}

export function usePotensiProduk(opts: { featuredOnly?: boolean } = {}) {
  const [data, setData] = useState<PotensiProduk[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("potensi_produk").select("*").eq("status", "publish").order("created_at", { ascending: false });
    if (opts.featuredOnly) q = q.eq("featured", true);
    q.then(({ data: r }) => {
      const safeData = (r && Array.isArray(r)) ? r : [];
      setData((safeData as Record<string, unknown>[]).map((x) => ({ ...x, harga: x.harga == null ? null : Number(x.harga) })) as unknown as PotensiProduk[]);
      setLoading(false);
    });
  }, [opts.featuredOnly]);
  return { data, loading };
}

export function usePotensiWisata() {
  const [data, setData] = useState<PotensiWisata[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("potensi_wisata").select("*").eq("status", "publish").order("nama").then(({ data: r }: any) => {
      const safeData = (r && Array.isArray(r)) ? r : [];
      setData((safeData as Record<string, unknown>[]).map((x) => ({
        ...x,
        latitude: x.latitude == null ? null : Number(x.latitude),
        longitude: x.longitude == null ? null : Number(x.longitude),
      })) as unknown as PotensiWisata[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

// ===================== Phase 6C: APBDes & PBB =====================

export type ApbdesRow = {
  id: string;
  tahun: number;
  jenis: "pendapatan" | "belanja" | "pembiayaan";
  kategori: string;
  sub_kategori: string | null;
  uraian: string;
  anggaran: number;
  realisasi: number;
  sumber_dana: string | null;
  urutan: number | null;
};

export function useApbdes(tahun: number) {
  const [data, setData] = useState<ApbdesRow[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    setLoading(true);
    supabase
      .from("apbdes")
      .select("*")
      .eq("tahun", tahun)
      .order("jenis")
      .order("urutan")
      .then(({ data: r }) => {
        setData(
          ((Array.isArray(r) ? r : []) as Record<string, unknown>[]).map((x) => ({
            ...x,
            anggaran: Number(x.anggaran ?? 0),
            realisasi: Number(x.realisasi ?? 0),
          })) as unknown as ApbdesRow[],
        );
        setLoading(false);
      });
  }, [tahun]);
  return { data, loading };
}

export function useApbdesYears() {
  const [years, setYears] = useState<number[]>([]);
  useEffect(() => {
    supabase.from("apbdes").select("tahun").then(({ data: r }) => {
      const set = new Set<number>();
      (r || []).forEach((x) => set.add(x.tahun));
      setYears(Array.from(set).sort((a, b) => b - a));
    });
  }, []);
  return years;
}

// ===================== Phase 9: Event Log & WA Broadcast =====================

export type EventLogRow = {
  id: string;
  event_name: string;
  entitas: string | null;
  entitas_id: string | null;
  payload: unknown;
  actor_id: string | null;
  created_at: string;
  actor_nama?: string | null;
  actor_nik?: string | null;
};

export function useEventLog(filter: { entitas?: string; event?: string; sejak?: string; limit?: number }) {
  const [rows, setRows] = useState<EventLogRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);
  const tenantId = useTenantId();
  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      let q = supabase
        .from("event_log")
        .select("*")
        .order("created_at", { ascending: false })
        .limit(filter.limit ?? 200);
      if (filter.entitas) q = q.eq("entitas", filter.entitas);
      if (tenantId) q = q.eq("tenant_id", tenantId);
      if (filter.event) q = q.ilike("event_name", `%${filter.event}%`);
      if (filter.sejak) q = q.gte("created_at", filter.sejak);
      const { data } = await q;
      const list = ((data as unknown) || []) as EventLogRow[];

      // Batch fetch all actor profiles at once (fix N+1 query)
      const actorIds = Array.from(new Set(list.map((r) => r.actor_id).filter(Boolean))) as string[];
      const profiles: Record<string, { nama: string; nik: string }> = {};
      if (actorIds.length) {
        const { data: pr } = await supabase.from("admin_profiles").select("id,nama,nik").in("id", actorIds);
        ((pr as unknown as { id: string; nama: string; nik: string }[]) || []).forEach((p) => (profiles[p.id] = { nama: p.nama, nik: p.nik }));
      }
      if (cancelled) return;
      setRows(
        list.map((r) => ({
          ...r,
          actor_nama: r.actor_id ? profiles[r.actor_id]?.nama ?? null : null,
          actor_nik: r.actor_id ? profiles[r.actor_id]?.nik ?? null : null,
        })),
      );
      setLoading(false);
    })();
    return () => {
      cancelled = true;
    };
  }, [filter.entitas, filter.event, filter.sejak, filter.limit, reloadKey, tenantId]);
  return { rows, loading, reload };
}

export type WaBroadcast = {
  id: string;
  judul: string | null;
  pesan: string;
  topik: string | null;
  dusun_filter: string | null;
  dry_run: boolean;
  status: string;
  total_target: number;
  total_sukses: number;
  total_gagal: number;
  dibuat_oleh: string | null;
  created_at: string;
  updated_at: string;
};

export type WaBroadcastTarget = {
  id: string;
  broadcast_id: string;
  nomor_tujuan: string;
  nama: string | null;
  dusun: string | null;
  status: string;
  error_message: string | null;
  attempt: number;
  sent_at: string | null;
  created_at: string;
};

export function useBroadcasts(reloadKey = 0) {
  const [rows, setRows] = useState<WaBroadcast[]>([]);
  const [loading, setLoading] = useState(true);
  const tenantId = useTenantId();
  useEffect(() => {
    setLoading(true);
    let q = supabase
      .from("wa_broadcast")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(100);
      if (tenantId) q = q.eq("tenant_id", tenantId);
      q.then(({ data }) => {
        setRows(((data as unknown) || []) as WaBroadcast[]);
        setLoading(false);
      });
  }, [reloadKey, tenantId]);
  return { rows, loading };
}

export function useBroadcastTargets(broadcastId: string | null, reloadKey = 0) {
  const [rows, setRows] = useState<WaBroadcastTarget[]>([]);
  const [loading, setLoading] = useState(true);
  const tenantId = useTenantId();
  useEffect(() => {
    if (!broadcastId) {
      setRows([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    let q = supabase
      .from("wa_broadcast_target")
      .select("*")
      .eq("broadcast_id", broadcastId);
      if (tenantId) q = q.eq("tenant_id", tenantId);
      q.then(({ data }) => {
        setRows(((data as unknown) || []) as WaBroadcastTarget[]);
        setLoading(false);
      });
  }, [broadcastId, reloadKey, tenantId]);
  return { rows, loading };
}

// ===================== Phase 11: Perencanaan, Usulan, Voting =====================

export type RpjmdesPeriode = { id: string; nama: string; tahun_mulai: number; tahun_selesai: number; visi: string | null; misi: string[]; status: string; published: boolean };
export type RpjmdesBidang = { id: string; periode_id: string; kode: string; nama: string; deskripsi: string | null; urutan: number };
export type RpjmdesProgram = { id: string; bidang_id: string; nama: string; indikator: string | null; target: string | null; sumber_dana: string | null; tahun_mulai: number | null; tahun_selesai: number | null; anggaran_indikatif: number; urutan: number };

export function useRpjmdesAktif() {
  const [periode, setPeriode] = useState<RpjmdesPeriode | null>(null);
  const [bidang, setBidang] = useState<RpjmdesBidang[]>([]);
  const [program, setProgram] = useState<RpjmdesProgram[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    (async () => {
      setLoading(true);
      const { data: pers } = await supabase
        .from("rpjmdes_periode").select("*").eq("published", true)
        .order("tahun_mulai", { ascending: false }).limit(1);
      const p = (pers?.[0] as unknown as Record<string, unknown> & { id: string; misi: string[] }) || null;
      if (!p) { setLoading(false); return; }
      setPeriode({ ...p, misi: (p.misi as string[]) || [] } as unknown as RpjmdesPeriode);
      const { data: bs } = await supabase.from("rpjmdes_bidang").select("*").eq("periode_id", p.id).order("urutan");
      setBidang((bs as unknown as RpjmdesBidang[]) || []);
      const ids = ((bs as unknown as RpjmdesBidang[]) || []).map((b) => b.id);
      if (ids.length) {
        const { data: pr } = await supabase.from("rpjmdes_program").select("*").in("bidang_id", ids).order("urutan");
        setProgram(((pr as unknown as Record<string, unknown>[]) || []).map((x) => ({ ...x, anggaran_indikatif: Number(x.anggaran_indikatif ?? 0) })) as unknown as RpjmdesProgram[]);
      }
      setLoading(false);
    })();
  }, []);
  return { periode, bidang, program, loading };
}

export type RkpdesTahun = { id: string; tahun: number; tgl_musdes: string | null; catatan: string | null; published: boolean };
export type RkpdesKegiatan = { id: string; tahun_id: string; nama: string; lokasi: string | null; dusun: string | null; volume: string | null; satuan: string | null; anggaran: number; sumber_dana: string | null; pelaksana: string | null; waktu: string | null; status_realisasi: string; progress_pct: number; bidang_id: string | null; urutan: number };

export function useRkpdesTahunList() {
  const [tahun, setTahun] = useState<RkpdesTahun[]>([]);
  useEffect(() => {
    supabase.from("rkpdes_tahun").select("*").eq("published", true).order("tahun", { ascending: false })
      .then(({ data }) => setTahun(((data as unknown) || []) as RkpdesTahun[]));
  }, []);
  return tahun;
}

export function useRkpdesKegiatan(tahunId: string | null) {
  const [rows, setRows] = useState<RkpdesKegiatan[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!tahunId) { setRows([]); setLoading(false); return; }
    setLoading(true);
    supabase.from("rkpdes_kegiatan").select("*").eq("tahun_id", tahunId).order("urutan")
      .then(({ data }) => {
        setRows(((data as unknown as Record<string, unknown>[]) || []).map((x) => ({ ...x, anggaran: Number(x.anggaran ?? 0), progress_pct: Number(x.progress_pct ?? 0) })) as unknown as RkpdesKegiatan[]);
        setLoading(false);
      });
  }, [tahunId]);
  return { rows, loading };
}

export type UsulanWarga = {
  id: string; nomor_tiket: string; nama: string; kontak: string | null; dusun: string | null;
  kategori: string; judul: string; deskripsi: string; lokasi: string | null; foto_url: string | null;
  status: string; tanggapan: string | null; vote_count: number; created_at: string; updated_at: string;
};

export function useUsulanPublik(reloadKey = 0) {
  const [rows, setRows] = useState<UsulanWarga[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    setLoading(true);
    supabase.from("usulan_warga").select("*")
      .in("status", ["diverifikasi", "ditindaklanjuti", "selesai"])
      .order("vote_count", { ascending: false }).limit(200)
      .then(({ data }) => {
        setRows((data || []) as UsulanWarga[]);
        setLoading(false);
      });
  }, [reloadKey]);
  return { rows, loading };
}

export type VotingTopik = { id: string; judul: string; deskripsi: string | null; mulai: string | null; selesai: string | null; single_choice: boolean; status: string; published: boolean; total_suara: number };
export type VotingHasil = {
  hasil_pemenang_id: string | null;
  hasil_ringkasan: string | null;
  hasil_dipublikasi: boolean;
  hasil_dipublikasi_pada: string | null;
};
export type VotingOpsi = { id: string; topik_id: string; label: string; deskripsi: string | null; urutan: number; jumlah_suara: number };

export function useVotingTopikList(reloadKey = 0) {
  const [rows, setRows] = useState<VotingTopik[]>([]);
  useEffect(() => {
    supabase.from("voting_topik").select("*").eq("published", true)
      .order("created_at", { ascending: false })
      .then(({ data }) => setRows(((data as unknown) || []) as VotingTopik[]));
  }, [reloadKey]);
  return rows;
}

export function useVotingOpsi(topikId: string | null, reloadKey = 0) {
  const [rows, setRows] = useState<VotingOpsi[]>([]);
  useEffect(() => {
    if (!topikId) { setRows([]); return; }
    supabase.from("voting_opsi").select("*").eq("topik_id", topikId).order("urutan")
      .then(({ data }) => setRows(((data as unknown) || []) as VotingOpsi[]));
  }, [topikId, reloadKey]);
  return rows;
}

// ============================================================
// NEW: Homepage Data Hooks (replace hardcoded data)
// ============================================================

export type StatistikDesa = {
  jumlah_penduduk: number;
  jumlah_kk: number;
  jumlah_dusun: number;
  luas_wilayah_km2: number;
  laki_laki: number;
  perempuan: number;
  per_umur: { label: string; nilai: number }[];
  per_pekerjaan: { label: string; nilai: number }[];
  per_pendidikan: { label: string; nilai: number }[];
};

export function useStatistikDesa() {
  const tenantId = useTenantId();
  const ACTIVE_TENANT = "d532ae95-0ad9-42bb-a6e8-5c840447c90e";
  const [data, setData] = useState<StatistikDesa>({
    jumlah_penduduk: 0,
    jumlah_kk: 0,
    jumlah_dusun: 0,
    luas_wilayah_km2: 0,
    laki_laki: 0,
    perempuan: 0,
    per_umur: [],
    per_pekerjaan: [],
    per_pendidikan: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!tenantId) { setLoading(false); return; }
    const effectiveTenant = tenantId !== "00000000-0000-0000-0000-000000000001"
      ? tenantId
      : ACTIVE_TENANT;

    if (!effectiveTenant) { setLoading(false); return; }

    // raw client bypasses RLS; add tenant_id filter for correctness
    Promise.all([
      supabase.from("wilayah_dusun").select("kk, jiwa, luas_ha").eq("tenant_id", effectiveTenant),
      supabase.from("penduduk").select("jenis_kelamin, tanggal_lahir, pekerjaan, pendidikan").eq("tenant_id", effectiveTenant).eq("status_hidup", "hidup"),
    ]).then(([dusunRes, pendudukRes]) => {
      if (dusunRes.error) console.warn("wilayah_dusun query error:", dusunRes.error.message);
      if (pendudukRes.error) console.warn("penduduk query error:", pendudukRes.error.message);
      const penduduk = pendudukRes.data || [];
      const dusun = dusunRes.data || [];

      let lakiLaki = 0;
      let perempuan = 0;
      const UMUR_BUCKETS = [
        { max: 5, label: "0-5" },
        { max: 12, label: "6-12" },
        { max: 18, label: "13-18" },
        { max: 25, label: "19-25" },
        { max: 35, label: "26-35" },
        { max: 45, label: "36-45" },
        { max: 55, label: "46-55" },
        { max: 65, label: "56-65" },
        { max: Infinity, label: ">65" },
      ];
      const umurCounts: Record<string, number> = {};
      const pekerjaanCounts: Record<string, number> = {};
      const pendidikanCounts: Record<string, number> = {};
      
      const currentYear = new Date().getFullYear();

      for (const p of penduduk) {
        const jk = String(p.jenis_kelamin || "").toUpperCase();
        if (jk === "L" || jk === "LAKI-LAKI" || jk === "MALE" || jk === "1") lakiLaki++;
        else if (jk === "P" || jk === "PEREMPUAN" || jk === "FEMALE" || jk === "2") perempuan++;

        let umr = 0;
        if (p.tanggal_lahir) {
          const birthYear = new Date(p.tanggal_lahir).getFullYear();
          if (!isNaN(birthYear)) umr = currentYear - birthYear;
        }
        for (const b of UMUR_BUCKETS) {
          if (umr <= b.max) { umurCounts[b.label] = (umurCounts[b.label] || 0) + 1; break; }
        }
        const pk = String(p.pekerjaan || "-").trim();
        if (pk && pk !== "-") pekerjaanCounts[pk] = (pekerjaanCounts[pk] || 0) + 1;
        const pd = String(p.pendidikan || "-").trim();
        if (pd && pd !== "-") pendidikanCounts[pd] = (pendidikanCounts[pd] || 0) + 1;
      }

      const totalKk = dusun.reduce((sum, d) => sum + (d.kk || 0), 0);
      const totalJiwa = dusun.reduce((sum, d) => sum + (d.jiwa || 0), 0);
      const totalLuas = dusun.reduce((sum, d) => sum + Number(d.luas_ha || 0), 0);

      setData({
        jumlah_penduduk: totalJiwa || penduduk.length,
        jumlah_kk: totalKk,
        jumlah_dusun: dusun.length,
        luas_wilayah_km2: Number((totalLuas / 100).toFixed(2)),
        laki_laki: lakiLaki,
        perempuan: perempuan,
        per_umur: Object.entries(umurCounts).map(([label, nilai]) => ({ label, nilai })).sort((a, b) => a.label.localeCompare(b.label)),
        per_pekerjaan: Object.entries(pekerjaanCounts).map(([label, nilai]) => ({ label, nilai })).sort((a, b) => b.nilai - a.nilai).slice(0, 15),
        per_pendidikan: Object.entries(pendidikanCounts).map(([label, nilai]) => ({ label, nilai })).sort((a, b) => b.nilai - a.nilai).slice(0, 10),
      });
      setLoading(false);
    });
  }, [tenantId]);

  return { data, loading };
}

export type IdmData = {
  status: string;
  skor_total: number;
  dimensi: Array<{ nama: string; skor: number }>;
};

export function useIdmData() {
  const [data, setData] = useState<IdmData>({
    status: "-",
    skor_total: 0,
    dimensi: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.from("idm_status_desa").select("*").limit(1).single()
      .then(({ data: r }) => {
        if (r) {
          const dimensiScores = typeof r.dimensi_scores === 'string'
            ? JSON.parse(r.dimensi_scores)
            : (r.dimensi_scores || {});

          setData({
            status: r.status || "-",
            skor_total: Number(r.total_skor) || 0,
            dimensi: [
              { nama: "Kesehatan", skor: Number(dimensiScores.Kesehatan || 0) * 5 },
              { nama: "Pendidikan", skor: Number(dimensiScores.Pendidikan || 0) * 5 },
              { nama: "Modal Sosial", skor: Number(dimensiScores["Modal Sosial"] || 0) * 5 },
              { nama: "Permukiman", skor: Number(dimensiScores.Permukiman || 0) * 5 },
              { nama: "Ekonomi", skor: Number(dimensiScores.Ekonomi || 0) * 5 },
              { nama: "Ekologi", skor: Number(dimensiScores.Ekologi || 0) * 5 },
            ],
          });
        }
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export type PembangunanData = {
  totalAnggaran: number;
  totalRealisasi: number;
  dataKegiatan: Array<{ id: string; nama: string; progres: number }>;
  progres_fisik_avg: number;
  anggaran_terserap_pct: number;
  aset_baru: number;
  kegiatan_aktif: Array<{ id: string; nama: string; progres: number }>;
};

export function usePembangunanData() {
  const [data, setData] = useState<PembangunanData>({
    totalAnggaran: 0,
    totalRealisasi: 0,
    dataKegiatan: [],
    progres_fisik_avg: 0,
    anggaran_terserap_pct: 0,
    aset_baru: 0,
    kegiatan_aktif: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.from("kegiatan_pembangunan")
      .select("id, nama_kegiatan, anggaran, realisasi, status")
      .eq("tahun", 2026)
      .in("status", ["diproses", "diverifikasi"])
      .then(({ data: r }) => {
        if (r && r.length > 0) {
          const totalAnggaran = r.reduce((sum: number, k: any) => sum + Number(k.anggaran || 0), 0);
          const totalRealisasi = r.reduce((sum: number, k: any) => sum + Number(k.realisasi || 0), 0);
          const progresAvg = totalAnggaran > 0 ? Math.round((totalRealisasi / totalAnggaran) * 100) : 0;
          const dk = r.map((k: any) => ({
            id: k.id || k.nama_kegiatan,
            nama: k.nama_kegiatan,
            progres: Number(k.anggaran) > 0 ? Math.round((Number(k.realisasi || 0) / Number(k.anggaran)) * 100) : 0,
          }));

          setData({
            totalAnggaran,
            totalRealisasi,
            dataKegiatan: dk,
            progres_fisik_avg: progresAvg,
            anggaran_terserap_pct: progresAvg,
            aset_baru: 0,
            kegiatan_aktif: dk,
          });
        }
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export type UsulanStats = {
  total_usulan: number;
  partisipasi_voting: number;
  top10: Array<{ judul: string; suara: number }>;
};

export function useUsulanStats() {
  const [data, setData] = useState<UsulanStats>({
    total_usulan: 0,
    partisipasi_voting: 0,
    top10: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      supabase.from("usulan_warga").select("id, judul, vote_count").in("status", ["diverifikasi", "ditindaklanjuti", "selesai"]),
      supabase.from("usulan_vote").select("id"),
    ]).then((results: unknown[]) => {
      const [usulanRes, voteRes] = results as [
        { data: { id: string; judul: string; vote_count: number | null }[] | null },
        { data: { id: string }[] | null }
      ];
      if (usulanRes.data) {
        const sorted = [...usulanRes.data].sort((a, b) => (b.vote_count || 0) - (a.vote_count || 0));
        setData({
          total_usulan: usulanRes.data.length,
          partisipasi_voting: voteRes.data?.length || 0,
          top10: sorted.slice(0, 10).map((u) => ({
            judul: u.judul || u.id,
            suara: u.vote_count || 0,
          })),
        });
      }
      setLoading(false);
    });
  }, []);

  return { data, loading };
}

// ===================== Bansos =====================

export type BantuanSosial = {
  id: string; kode: string; nama: string; sumber: string | null; deskripsi: string | null;
  periode_mulai: string | null; periode_selesai: string | null; kuota: number | null;
  aktif: boolean | number | null;
};

export type PenerimaBansos = {
  id: string; bansos_id: string; nik: string | null; nama: string | null;
  dusun: string | null; status: string; nominal: number | null; catatan: string | null;
};

export function useBantuanSosial() {
  const [data, setData] = useState<BantuanSosial[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("bantuan_sosial").select("*").eq("aktif", true).order("nama")
      .then(({ data: r }) => { setData(((r as unknown) || []) as BantuanSosial[]); setLoading(false); });
  }, []);
  return { data, loading };
}

export interface PenerimaBansosOptions {
  search?: string;
  dusun?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

export function usePenerimaBansos(bansosId?: string, opts: PenerimaBansosOptions = {}) {
  const { search = "", dusun = "", status = "", page = 0, pageSize = 20 } = opts;
  const [data, setData] = useState<PenerimaBansos[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!bansosId) { setData([]); setTotal(0); setLoading(false); return; }
    let q = supabase
      .from("penerima_bansos")
      .select("*", { count: "exact" })
      .eq("bansos_id", bansosId)
      .order("nama");

    if (search) {
      q = q.or(`nama.ilike.%${search}%,nik.ilike.%${search}%`);
    }
    if (dusun) {
      q = q.eq("dusun", dusun);
    }
    if (status) {
      q = q.eq("status", status);
    }

    q = q.range(page * pageSize, (page + 1) * pageSize - 1);

    q.then(({ data: r, count }) => {
      setData((r as unknown as PenerimaBansos[]) || []);
      setTotal(count || 0);
      setLoading(false);
    });
  }, [bansosId, search, dusun, status, page, pageSize]);

  return { data, loading, total };
}

export function usePenerimaBansosStats(bansosId?: string) {
  const [stats, setStats] = useState({ total: 0, aktif: 0, nonaktif: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!bansosId) { setStats({ total: 0, aktif: 0, nonaktif: 0 }); setLoading(false); return; }
    supabase
      .from("penerima_bansos")
      .select("status", { count: "exact", head: true })
      .eq("bansos_id", bansosId)
      .then(({ count: totalCount }: any) => {
        supabase
          .from("penerima_bansos")
          .select("status", { count: "exact", head: true })
          .eq("bansos_id", bansosId)
          .neq("status", "dibatalkan")
          .then(({ count: aktifCount }: any) => {
            setStats({
              total: totalCount || 0,
              aktif: aktifCount || 0,
              nonaktif: (totalCount || 0) - (aktifCount || 0),
            });
            setLoading(false);
          });
      });
  }, [bansosId]);

  return { stats, loading };
}

export type PendudukDetail = {
  id: string; nik: string | null; nama: string | null; jenis_kelamin: string | null;
  tempat_lahir: string | null; tanggal_lahir: string | null; agama: string | null;
  pendidikan: string | null; pekerjaan: string | null; status_kawin: string | null;
  hubungan_kk: string | null; keluarga_id: string | null; dusun: string | null;
  rt: string | null; rw: string | null; alamat: string | null;
  bpjs_status: string | null; bpjs_nomor: string | null; nomor_hp: string | null;
  foto_url: string | null; status_hidup: string | null; catatan: string | null;
};

export function usePendudukById(id?: string) {
  const [data, setData] = useState<PendudukDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("penduduk").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as unknown as PendudukDetail) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export type KeluargaDetail = {
  id: string; no_kk: string | null; kepala_nama: string | null; alamat: string | null;
  dusun: string | null; rt: string | null; rw: string | null; status_kk: string | null;
};

export function useKeluargaById(id?: string) {
  const [data, setData] = useState<KeluargaDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("keluarga").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as unknown as KeluargaDetail) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// ===================== Stunting & Posyandu =====================

export type StuntingAgregat = {
  id: string; dusun: string; bulan: string; periode: string;
  balita_diukur: number; stunting: number; wasting: number; underweight: number;
  intervensi: string | null;
};

export type PosyanduAgregat = {
  id: string; dusun: string; bulan: string; periode: string;
  jumlah_balita: number; hadir: number; gizi_baik: number; gizi_kurang: number;
  gizi_buruk: number; imunisasi_lengkap: number;
  ibu_hamil_dilayani: number; ibu_menyusui: number; catatan: string | null;
};

export function useStuntingAgregat(bulan?: string) {
  const [data, setData] = useState<StuntingAgregat[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("stunting_agregat").select("*").order("dusun");
    if (bulan) q = (q as any).eq("bulan", bulan);
    q.then(({ data: r }) => { setData(((r as unknown) || []) as StuntingAgregat[]); setLoading(false); });
  }, [bulan]);
  return { data, loading };
}

export function usePosyanduAgregat(bulan?: string) {
  const [data, setData] = useState<PosyanduAgregat[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("posyandu_agregat").select("*").order("dusun");
    if (bulan) q = (q as any).eq("bulan", bulan);
    q.then(({ data: r }) => { setData(((r as unknown) || []) as PosyanduAgregat[]); setLoading(false); });
  }, [bulan]);
  return { data, loading };
}

export type Balita = {
  id: string; nama: string; tanggal_lahir: string; jenis_kelamin: string;
  dusun: string | null; rt: string | null; rw: string | null; alamat: string | null;
  orang_tua_penduduk_id: string | null;
};

export function useBalita(dusun?: string) {
  const [data, setData] = useState<Balita[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("balita").select("*").order("nama");
    if (dusun) q = q.eq("dusun", dusun);
    q.then(({ data: r }) => { setData(((r as unknown) || []) as Balita[]); setLoading(false); });
  }, [dusun]);
  return { data, loading };
}

// ===================== Bencana =====================

export type BencanaKejadian = {
  id: string; jenis: string; lokasi: string; dusun: string | null; tanggal: string;
  severity: string; status: string; korban_jiwa: number; pengungsi: number;
  kerugian_rp: number | null; deskripsi: string | null; penanganan: string | null;
};

export function useBencanaKejadian(status?: string) {
  const [data, setData] = useState<BencanaKejadian[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("bencana_kejadian").select("*").order("tanggal", { ascending: false });
    if (status) q = q.eq("status", status as any);
    q.then(({ data: r }) => { setData(((r as unknown) || []) as BencanaKejadian[]); setLoading(false); });
  }, [status]);
  return { data, loading };
}

// ===================== Surat & Layanan =====================

export type SuratJenis = {
  id: string; kode_surat: string; nama: string; aktif: boolean; urutan: number;
};

export function useSuratJenis(aktifOnly = true) {
  const [data, setData] = useState<SuratJenis[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("surat_jenis").select("*").order("urutan");
    if (aktifOnly) q = q.eq("aktif", true);
    // surat_jenis is public data â€” RLS policy (aktif=true) handles security.
    // Tenant ID filter removed: fallback tenant UUID != DB tenant UUID â†’ 0 rows.
    q.then(({ data, error }) => {
      if (error) console.error("useSuratJenis error:", error);
      setData((data || []) as SuratJenis[]);
      setLoading(false);
    });
  }, [aktifOnly]);
  return { data, loading };
}

export type LayananStat = {
  jenis_layanan: string;
  count_bulan_ini: number;
  count_bulan_lalu: number;
};

export function useLayananStatistik(jenis?: string) {
  const [data, setData] = useState<LayananStat[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("layanan_statistik").select("*");
    if (jenis) q = q.eq("jenis_layanan", jenis);
    q.then(({ data }) => {
      setData((data || []) as LayananStat[]);
      setLoading(false);
    });
  }, [jenis]);
  return { data, loading };
}

export function useLayananStatBulanIni(jenis?: string) {
  const { data } = useLayananStatistik(jenis);
  if (!data || data.length === 0) return 0;
  const latest = data[0];
  return latest.count_bulan_ini ?? 0;
}

export type RefOption = { id: string; kode: string; nama: string };

export function useAduanKategori() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_kategori_aduan").select("*").eq("aktif", true).order("urutan")
      .then(({ data, error }) => {
        if (error) console.error("useAduanKategori error:", error);
        setData((data || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useRefTopikLangganan() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_topik_langganan").select("*").eq("aktif", true).order("urutan")
      .then(({ data: r, error }) => {
        if (error) console.error("useRefTopikLangganan error:", error);
        setData((r || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useKategoriUsulan() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_kategori_usulan").select("*").eq("aktif", true).order("urutan")
      .then(({ data, error }) => {
        if (error) console.error("useKategoriUsulan error:", error);
        setData((data || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useTipeUmkm() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_tipe_umkm").select("*").eq("aktif", true).order("urutan")
      .then(({ data, error }) => {
        if (error) console.error("useTipeUmkm error:", error);
        setData((data || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useJenisWisata() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_jenis_wisata").select("*").eq("aktif", true).order("urutan")
      .then(({ data, error }) => {
        if (error) console.error("useJenisWisata error:", error);
        setData((data || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useSumberDana() {
  const [data, setData] = useState<RefOption[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_sumber_dana").select("*").eq("aktif", true).order("urutan")
      .then(({ data, error }) => {
        if (error) console.error("useSumberDana error:", error);
        setData((data || []) as RefOption[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

// ===================== Surat DNA Dynamic Fields =====================

export type SuratDNAField = {
  id: string;
  tenant_id: string;
  jenis_surat_id: string;
  kode_surat: string;
  field_name: string;
  label: string;
  tipe: 'text' | 'textarea' | 'number' | 'date' | 'select' | 'checkbox' | 'file' | 'phone' | 'email';
  placeholder: string | null;
  help_text: string | null;
  options: string[] | null;
  default_value: string | null;
  validation_pattern: string | null;
  min_length: number | null;
  max_length: number | null;
  min_value: number | null;
  max_value: number | null;
  wajib: boolean;
  grup: string | null;
  urutan: number;
  tampil_di_cetak: boolean;
  label_cetak: string | null;
};

export function useSuratDNAFields(jenisSuratId: string | null) {
  const [data, setData] = useState<SuratDNAField[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!jenisSuratId) { setData([]); setLoading(false); return; }
    supabase.from("surat_jenis_dna")
      .select("*")
      .eq("jenis_surat_id", jenisSuratId)
      .order("urutan")
      .then(({ data }) => { setData((data || []) as SuratDNAField[]); setLoading(false); });
  }, [jenisSuratId]);
  return { data, loading };
}

export type SuratAjuanRow = {
  id: string;
  tenant_id: string;
  nomor_tiket: string;
  nik: string;
  nama: string;
  kontak: string;
  jenis_surat_id: string | null;
  keperluan: string;
  lampiran: string[];
  status: 'menunggu' | 'diproses' | 'diterima' | 'ditolak' | 'dibatalkan';
  keterangan: string | null;
  admin_id: string | null;
  diproses_pada: string | null;
  template_id: string | null;
  preview_url: string | null;
  status_preview: string | null;
  created_at: string;
  updated_at: string;
};

export function useSuratAjuanList() {
  const [data, setData] = useState<SuratAjuanRow[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("surat_ajuan")
      .select("*")
      .order("created_at", { ascending: false })
      .then(({ data }) => { setData((data || []) as SuratAjuanRow[]); setLoading(false); });
  }, []);
  return { data, loading };
}
// ===================== ById Query Hooks (detail pages) =====================
// Each hook fetches ONE row by UUID primary key. Used by detail/view pages.

// Balita
export type BalitaDetail = {
  id: string;
  nama: string;
  tanggal_lahir: string;
  jenis_kelamin: string;
  nik_anak?: string | null;
  nama_ortu?: string | null;
  dusun: string | null;
  rt: string | null;
  rw: string | null;
  alamat: string | null;
  orang_tua_penduduk_id: string | null;
};
export function useBalitaById(id?: string) {
  const [data, setData] = useState<BalitaDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("balita").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => { setData((r as unknown as BalitaDetail) || null); setLoading(false); });
  }, [id]);
  return { data, loading };
}

// Bidang Tanah
export type BidangTanahDetail = {
  id: string;
  no_sertifikat: string | null;
  jenis_sertifikat: string | null;
  nama_pemegang: string | null;
  nik_pemegang: string | null;
  alamat_pemegang: string | null;
  luas_m2: number | null;
  lokasi: string | null;
  dusun: string | null;
  rt: string | null;
  rw: string | null;
  koordinat_lat: number | null;
  koordinat_lng: number | null;
  dokumen_url: string | null;
  gambar_url: string | null;
  gambar_lampiran: string[] | null;
  status: string | null;
  keterangan: string | null;
};
export function useBidangTanahById(id?: string) {
  const [data, setData] = useState<BidangTanahDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("bidang_tanah").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) {
          const rec = r as Record<string, unknown>;
          setData({
            ...r,
            luas_m2: Number(rec['luas_m2'] ?? 0),
            koordinat_lat: Number(rec['koordinat_lat'] ?? 0),
            koordinat_lng: Number(rec['koordinat_lng'] ?? 0),
            gambar_lampiran: (rec['gambar_lampiran'] as string[] | null) ?? null,
          } as unknown as BidangTanahDetail);
        } else { setData(null); }
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// Infrastruktur
export type InfrastrukturDetail = {
  id: string;
  nama: string | null;
  jenis: string | null;
  lokasi: string | null;
  dusun: string | null;
  rt: string | null;
  rw: string | null;
  koordinat_lat: number | null;
  koordinat_lng: number | null;
  kondisi: string | null;
  tahun_bangun: number | null;
  tahun_perbaikan: number | null;
  volume: string | null;
  sumber_dana: string | null;
  keterangan: string | null;
};
export function useInfrastrukturById(id?: string) {
  const [data, setData] = useState<InfrastrukturDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("infrastruktur").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) {
          const rec = r as Record<string, unknown>;
          setData({
            ...r,
            koordinat_lat: Number(rec['koordinat_lat'] ?? 0) || null,
            koordinat_lng: Number(rec['koordinat_lng'] ?? 0) || null,
          } as unknown as InfrastrukturDetail);
        } else { setData(null); }
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// Bencana
export type BencanaDetail = {
  id: string;
  jenis: string | null;
  lokasi: string | null;
  dusun: string | null;
  tanggal: string | null;
  severity: string | null;
  status: string | null;
  korban_jiwa: number | null;
  pengungsi: number | null;
  kerugian_rp: number | null;
  deskripsi: string | null;
  penanganan: string | null;
};
export function useBencanaById(id?: string) {
  const [data, setData] = useState<BencanaDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("bencana_kejadian").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? { ...r, korban_jiwa: Number(r.korban_jiwa ?? 0), pengungsi: Number(r.pengungsi ?? 0), kerugian_rp: Number(r.kerugian_rp ?? 0) } as unknown as BencanaDetail : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// Usulan Warga
export type UsulanWargaDetail = {
  id: string;
  nomor_tiket: string | null;
  nama: string | null;
  kontak: string | null;
  dusun: string | null;
  kategori: string | null;
  judul: string | null;
  deskripsi: string | null;
  lokasi: string | null;
  foto_url: string | null;
  status: string | null;
  tanggapan: string | null;
  vote_count: number | null;
  created_at: string | null;
};
export function useUsulanWargaById(id?: string) {
  const [data, setData] = useState<UsulanWargaDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("usulan_warga").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => { setData((r as unknown as UsulanWargaDetail) || null); setLoading(false); });
  }, [id]);
  return { data, loading };
}

// Voting Topik (full detail with opsi)
export type VotingTopikDetail = {
  id: string;
  judul: string | null;
  deskripsi: string | null;
  mulai: string | null;
  selesai: string | null;
  single_choice: boolean | null;
  status: string | null;
  published: boolean | null;
  total_suara: number | null;
};
export function useVotingTopikById(id?: string) {
  const [data, setData] = useState<VotingTopikDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("voting_topik").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => { setData((r as unknown as VotingTopikDetail) || null); setLoading(false); });
  }, [id]);
  return { data, loading };
}

// PBB Tagihan
export type PbbTagihanDetail = {
  id: string;
  tahun: number | null;
  nop: string | null;
  wajib_pajak_nama: string | null;
  wajib_pajak_nik: string | null;
  wajib_pajak_alamat: string | null;
  alamat_objek: string | null;
  dusun: string | null;
  luas_bumi_m2: number | null;
  luas_bangunan_m2: number | null;
  njop_bumi: number | null;
  njop_bangunan: number | null;
  njop_total: number | null;
  pbb_terutang: number | null;
  jatuh_tempo: string | null;
  status_bayar: string | null;
  tanggal_bayar: string | null;
  metode_bayar: string | null;
  keterangan: string | null;
};
export function usePbbTagihanById(id?: string) {
  const [data, setData] = useState<PbbTagihanDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("pbb_tagihan").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) {
          const rec = r as Record<string, unknown>;
          setData({
            ...r,
            tahun: rec.tahun as number | null,
            luas_bumi_m2: Number(rec.luas_bumi_m2 ?? 0),
            luas_bangunan_m2: Number(rec.luas_bangunan_m2 ?? 0),
            njop_bumi: Number(rec.njop_bumi ?? 0),
            njop_bangunan: Number(rec.njop_bangunan ?? 0),
            njop_total: Number((rec.njop_bumi ?? 0)) + Number((rec.njop_bangunan ?? 0)),
            pbb_terutang: Number(rec.pbb_terutang ?? 0),
          } as unknown as PbbTagihanDetail);
        } else { setData(null); }
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// Surat Terbit
export type SuratTerbitDetail = {
  id: string;
  nomor_surat: string | null;
  jenis_surat_id: string | null;
  nik: string | null;
  nama: string | null;
  tanggal_terbit: string | null;
  keperluan: string | null;
  status: string | null;
  preview_url: string | null;
  qr_code_url?: string | null;
  ttd_oleh?: string | null;
  ttd_nama?: string | null;
  ttd_nip?: string | null;
};
export function useSuratTerbitById(id?: string) {
  const [data, setData] = useState<SuratTerbitDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("surat_terbit").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => { setData((r as unknown as SuratTerbitDetail) || null); setLoading(false); });
  }, [id]);
  return { data, loading };
}

// RPJMDes Bidang
export function useRpjmdesBidangById(id?: string) {
  const [data, setData] = useState<RpjmdesBidang | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("rpjmdes_bidang").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => { setData((r as unknown as RpjmdesBidang) || null); setLoading(false); });
  }, [id]);
  return { data, loading };
}

// RPJMDes Program
export function useRpjmdesProgramById(id?: string) {
  const [data, setData] = useState<RpjmdesProgram | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("rpjmdes_program").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) setData({ ...r, anggaran_indikatif: Number(r.anggaran_indikatif ?? 0) } as unknown as RpjmdesProgram);
        else setData(null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

// RKPDes Kegiatan
export function useRkpdesKegiatanById(id?: string) {
  const [data, setData] = useState<RkpdesKegiatan | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("rkpdes_kegiatan").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) setData({ ...r, anggaran: Number(r.anggaran ?? 0), progress_pct: Number(r.progress_pct ?? 0) } as unknown as RkpdesKegiatan);
        else setData(null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useAgendaById(id?: string) {
  const [data, setData] = useState<Agenda | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("agenda").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as Agenda) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useGaleriById(id?: string) {
  const [data, setData] = useState<Galeri | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("galeri").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as Galeri) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function usePengumumanById(id?: string) {
  const [data, setData] = useState<Pengumuman | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("pengumuman").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as Pengumuman) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function usePosyanduById(id?: string) {
  const [data, setData] = useState<PosyanduAgregat | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("posyandu_agregat").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as PosyanduAgregat : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useStuntingById(id?: string) {
  const [data, setData] = useState<StuntingAgregat | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("stunting_agregat").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as StuntingAgregat : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useUmkmById(id?: string) {
  const [data, setData] = useState<PotensiUmkm | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("potensi_umkm").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as PotensiUmkm : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useProdukById(id?: string) {
  const [data, setData] = useState<PotensiProduk | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("potensi_produk").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as PotensiProduk : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useWisataById(id?: string) {
  const [data, setData] = useState<PotensiWisata | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("potensi_wisata").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as PotensiWisata : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export type PembangunanDetail = {
  id: string;
  tenant_id?: string;
  tahun: number;
  bidang: string;
  nama_kegiatan: string;
  judul?: string | null;
  lokasi: string | null;
  volume: string | null;
  anggaran: number;
  sumber_dana: string | null;
  sumber?: string | null;
  status: string;
  tanggal_mulai: string | null;
  tanggal_selesai: string | null;
  keterangan: string | null;
  foto_url: string | null;
  gambar_dokumentasi: string[] | null;
  progress_persen: number | null;
  created_at: string;
  updated_at?: string;
};
export function usePembangunanById(id?: string) {
  const [data, setData] = useState<PembangunanDetail | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("kegiatan_pembangunan").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        if (r) {
          setData({
            ...r,
            gambar_dokumentasi: (r as Record<string, unknown>)['gambar_dokumentasi'] as string[] | null ?? null,
          } as unknown as PembangunanDetail);
        } else {
          setData(null);
        }
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export function useBansosById(id?: string) {
  const [data, setData] = useState<BantuanSosial | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("bantuan_sosial").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as BantuanSosial) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export type AduanWarga = {
  id: string;
  tenant_id?: string;
  nomor_tiket: string;
  nama_pelapor: string;
  kontak: string;
  kategori: string;
  judul: string;
  isi: string;
  lokasi: string | null;
  lampiran_url: string | null;
  status: string;
  tanggapan: string | null;
  ditanggapi_pada: string | null;
  tanggal: string | null;
  created_at: string;
  updated_at?: string;
};

export function useAduanById(id?: string) {
  const [data, setData] = useState<AduanWarga | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("aduan_warga").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData(r ? r as unknown as AduanWarga : null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export type IdmIndikator = {
  id: string;
  tenant_id?: string;
  tahun: number;
  dimensi: string;
  indikator: string;
  nilai: number;
  skor: number;
  sumber: string | null;
  keterangan: string | null;
  published: boolean;
  created_at: string;
  updated_at?: string;
};

export function useIdmIndikatorById(id?: string) {
  const [data, setData] = useState<IdmIndikator | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!id) { setData(null); setLoading(false); return; }
    supabase.from("idm_indikator").select("*").eq("id", id).maybeSingle()
      .then(({ data: r }) => {
        setData((r as IdmIndikator) || null);
        setLoading(false);
      });
  }, [id]);
  return { data, loading };
}

export async function fetchPendudukByNik(nik: string) {
  if (!nik || nik.length !== 16) return null;
  const { data } = await supabase.rpc("find_penduduk_by_nik", { p_nik: nik }).maybeSingle();
  return data;
}

export function useAutofillPenduduk(nik: string, onFound: (data: NonNullable<Awaited<ReturnType<typeof fetchPendudukByNik>>>) => void) {
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    if (!nik || nik.length !== 16) return;
    const t = setTimeout(async () => {
      setLoading(true);
      const data = await fetchPendudukByNik(nik);
      if (data) onFound(data);
      setLoading(false);
    }, 500);
    return () => clearTimeout(t);
  }, [nik, onFound]);
  return { loading };
}
export interface PageHeroConfig {
  id: string;
  tenant_id: string;
  page_route: string;
  title: string | null;
  subtitle: string | null;
  image_path: string | null;
  video_path: string | null;
  is_active: boolean;
}

export function useInfrastrukturList() {
  const [data, setData] = useState<InfrastrukturDetail[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("infrastruktur").select("*").order("nama")
      .then(({ data: r }) => {
        setData((r || []).map((row: Record<string, unknown>) => ({
          ...row,
          koordinat_lat: Number(row['koordinat_lat'] ?? 0) || null,
          koordinat_lng: Number(row['koordinat_lng'] ?? 0) || null,
        })) as unknown as InfrastrukturDetail[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useBidangTanahList() {
  const [data, setData] = useState<BidangTanahDetail[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("bidang_tanah").select("*").order("no_sertifikat")
      .then(({ data: r }) => {
        setData((r || []).map((row: Record<string, unknown>) => ({
          ...row,
          luas_m2: Number(row['luas_m2'] ?? 0),
          koordinat_lat: Number(row['koordinat_lat'] ?? 0),
          koordinat_lng: Number(row['koordinat_lng'] ?? 0),
          gambar_lampiran: (row['gambar_lampiran'] as string[] | null) ?? null,
        })) as unknown as BidangTanahDetail[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function usePbbTagihanList() {
  const [data, setData] = useState<PbbTagihanDetail[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("pbb_tagihan").select("*").order("tahun", { ascending: false }).order("wajib_pajak_nama")
      .then(({ data: r }) => {
        setData((r || []).map((row: Record<string, unknown>) => ({
          ...row,
          tahun: row.tahun as number | null,
          luas_bumi_m2: Number(row['luas_bumi_m2'] ?? 0),
          luas_bangunan_m2: Number(row['luas_bangunan_m2'] ?? 0),
          njop_bumi: Number(row['njop_bumi'] ?? 0),
          njop_bangunan: Number(row['njop_bangunan'] ?? 0),
          njop_total: Number(row['njop_bumi'] ?? 0) + Number(row['njop_bangunan'] ?? 0),
          pbb_terutang: Number(row['pbb_terutang'] ?? 0),
        })) as unknown as PbbTagihanDetail[]);
        setLoading(false);
      });
  }, []);
  return { data, loading };
}

export function useSuratTerbitList() {
  const [data, setData] = useState<SuratTerbitDetail[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("surat_terbit").select("*").order("tanggal_terbit", { ascending: false })
      .then(({ data: r }) => { setData((r as unknown as SuratTerbitDetail[]) || []); setLoading(false); });
  }, []);
  return { data, loading };
}

export function usePageHeroConfig(route: string) {
  const tenantId = useTenantId();
  const [data, setData] = useState<PageHeroConfig | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {

    let mounted = true;
    async function load() {
      const { data: rows } = await supabase.from('page_hero_config')
        .select('*')
        .eq('page_route', route)
        .eq('is_active', true)
        .eq('tenant_id', tenantId || undefined);
      const row = rows?.find((r) => r.tenant_id === tenantId) || rows?.find((r) => !r.tenant_id) || null;
      if (mounted) {
        setData(row as PageHeroConfig | null);
        setLoading(false);
      }
    }
    load();
    return () => { mounted = false; };
  }, [tenantId, route]);
  return { data, loading };
}
