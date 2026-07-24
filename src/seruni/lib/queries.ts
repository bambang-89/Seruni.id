import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
  profilDesa as profilDesaSeed,
  strukturPamong as pamongSeed,
  wilayahDusun as dusunSeed,
  lembagaDesa as lembagaSeed,
  beritaTerbaru as beritaSeed,
  agendaMendatang as agendaSeed,
  pengumumanResmi as pengumumanSeed,
  galeriDetail as galeriSeed,
} from "../data";
import { useTenantId } from "./tenant";

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
export type Agenda = { id?: string; slug: string; jenis: string; judul: string; tanggal: string; waktu: string; lokasi: string; penyelenggara: string; deskripsi: string };
export type Pengumuman = { id?: string; nomor: string; tanggal: string; judul: string; ringkasan: string };
export type Galeri = { id?: string; judul: string; emoji: string; album: string; tanggal: string; urutan: number; foto_url?: string | null };

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
  logo_favicon_url: string | null;
  foto_profil_url: string | null;
  foto_panorama_url: string | null;
  video_url: string | null;
  tahun_bentuk: number | null;
  luas_wilayah: number | null;
  koordinat_lat: number | null;
  koordinat_lng: number | null;
  slogan: string | null;
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
  const [data, setData] = useState<ProfilDesa>(profilDesaSeed);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase
      .from("profil_desa")
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
  const [data, setData] = useState<Pamong[]>(pamongSeed as Pamong[]);
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
  const [data, setData] = useState<Dusun[]>(dusunSeed as Dusun[]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("wilayah_dusun").select("*").order("urutan");
    if (tenantId) q = q.eq("tenant_id", tenantId);
    q.then(({ data: r }) => {
      if (r?.length) setData(r.map((x) => ({ ...x, luas_ha: Number(x.luas_ha) })) as Dusun[]);
      setLoading(false);
    });
  }, [tenantId]);
  return { data, loading };
}

export function useLembaga() {
  const [data, setData] = useState<Lembaga[]>(lembagaSeed as Lembaga[]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("lembaga_desa").select("*").order("urutan").then(({ data: r }) => {
      if (r?.length) setData(r as Lembaga[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

export async function fetchPendudukByNik(nik: string) {
  if (!nik || nik.length !== 16) return null;
  const { data } = await supabase.from("penduduk").select("*").eq("nik", nik).maybeSingle();
  return data;
}

// ===================== Surat Identitas Autofill =====================

export type IdentitasData = {
  nik: string;
  nama: string;
  tempat_lahir: string;
  tanggal_lahir: string; // ISO date string
  jenis_kelamin: string; // "Laki-laki" | "Perempuan"
  pekerjaan: string;
  kewarganegaraan: string;
  alamat_lengkap: string;
  nomor_hp?: string;
};

const BULAN_INDO = [
  "Januari", "Februari", "Maret", "April", "Mei", "Juni",
  "Juli", "Agustus", "September", "Oktober", "November", "Desember",
];

export function formatTanggalLahir(tanggal: string, tempat: string): string {
  if (!tanggal) return tempat || "-";
  try {
    const d = new Date(tanggal + "T00:00:00");
    const day = d.getUTCDate();
    const month = BULAN_INDO[d.getUTCMonth()];
    const year = d.getUTCFullYear();
    return `${tempat || "-"}, ${day} ${month} ${year}`;
  } catch {
    return tempat || "-";
  }
}

export function composeAlamat(
  dusun: unknown,
  rt: unknown,
  rw: unknown,
  kecamatan: unknown,
  kabupaten: unknown,
  provinsi: unknown,
): string {
  const v = (val: unknown) => (val == null ? "-" : String(val).trim() || "-");
  const parts = [
    v(dusun) !== "-" ? `Dusun ${v(dusun)}` : null,
    v(rt) !== "-" || v(rw) !== "-" ? `RT ${v(rt)}/RW ${v(rw)}` : null,
    v(kecamatan) !== "-" ? `Kec. ${v(kecamatan)}` : null,
    v(kabupaten) !== "-" ? `Kab. ${v(kabupaten)}` : null,
    v(provinsi) !== "-" ? v(provinsi) : null,
  ].filter(Boolean) as string[];
  return parts.join(", ") || "-";
}

export async function fetchKewarganegaraan(warga_negara_id: unknown): Promise<string> {
  if (!warga_negara_id) return "WNI";
  try {
    const { data } = await supabase
      .from("ref_warga_negara")
      .select("nama")
      .eq("id", warga_negara_id)
      .maybeSingle();
    return (data as { nama: string } | null)?.nama ?? "WNI";
  } catch {
    return "WNI";
  }
}

export function useBerita(opts: { publishedOnly?: boolean } = { publishedOnly: true }) {
  const [data, setData] = useState<Berita[]>(beritaSeed.map((b) => ({ ...b, published: true })) as Berita[]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("berita").select("*").order("tanggal", { ascending: false });
    if (opts.publishedOnly) q = q.eq("published", true);
    q.then(({ data: r }) => {
      if (r?.length) setData(r.map((x) => ({ ...x, isi: (x.isi as string[]) || [] })) as Berita[]);
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
        const fallback = beritaSeed.find((b) => b.slug === slug);
        if (fallback) setData({ ...fallback, published: true } as Berita);
      }
      setLoading(false);
    });
  }, [slug]);
  return { data, loading };
}

export function useAgenda() {
  const [data, setData] = useState<Agenda[]>(agendaSeed as Agenda[]);
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
  const [data, setData] = useState<Pengumuman[]>(pengumumanSeed as Pengumuman[]);
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
  const [data, setData] = useState<Galeri[]>(galeriSeed as Galeri[]);
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
    supabase
      .from("hero_slider")
      .select("*")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r, error }) => {
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
    supabase
      .from("identitas_desa")
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

    let query = supabase
      .from("dokumen_upload")
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

export type PotensiUmkm = { id: string; tipe: string; nama: string; pemilik: string | null; sektor: string | null; dusun: string | null; kontak: string | null; alamat: string | null; deskripsi: string | null; status: string };
export type PotensiProduk = { id: string; umkm_id: string | null; penjual_nama: string; nama: string; kategori: string | null; harga: number | null; satuan: string | null; stok: number | null; deskripsi: string | null; foto_url: string | null; featured: boolean; status: string };
export type PotensiWisata = { id: string; nama: string; jenis: string; dusun: string | null; deskripsi: string | null; latitude: number | null; longitude: number | null; foto_url: string | null; fasilitas: string | null; status: string };

export function usePotensiUmkm(tipe?: string) {
  const [data, setData] = useState<PotensiUmkm[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("potensi_umkm").select("*").eq("status", "publish").order("nama");
    if (tipe) q = q.eq("tipe", tipe);
    q.then(({ data: r }) => {
      setData((r && Array.isArray(r)) ? r : []);
      setLoading(false);
    }).catch(() => {
      setData([]);
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
    }).catch(() => {
      setData([]);
      setLoading(false);
    });
  }, [opts.featuredOnly]);
  return { data, loading };
}

export function usePotensiWisata() {
  const [data, setData] = useState<PotensiWisata[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("potensi_wisata").select("*").eq("status", "publish").order("nama").then(({ data: r }) => {
      const safeData = (r && Array.isArray(r)) ? r : [];
      setData((safeData as Record<string, unknown>[]).map((x) => ({
        ...x,
        latitude: x.latitude == null ? null : Number(x.latitude),
        longitude: x.longitude == null ? null : Number(x.longitude),
      })) as unknown as PotensiWisata[]);
      setLoading(false);
    }).catch(() => {
      setData([]);
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
  }, [filter.entitas, filter.event, filter.sejak, filter.limit, reloadKey]);
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
  useEffect(() => {
    setLoading(true);
    supabase
      .from("wa_broadcast")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(100)
      .then(({ data }) => {
        setRows(((data as unknown) || []) as WaBroadcast[]);
        setLoading(false);
      });
  }, [reloadKey]);
  return { rows, loading };
}

export function useBroadcastTargets(broadcastId: string | null, reloadKey = 0) {
  const [rows, setRows] = useState<WaBroadcastTarget[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!broadcastId) {
      setRows([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    supabase
      .from("wa_broadcast_target")
      .select("*")
      .eq("broadcast_id", broadcastId)
      .order("created_at")
      .then(({ data }) => {
        setRows(((data as unknown) || []) as WaBroadcastTarget[]);
        setLoading(false);
      });
  }, [broadcastId, reloadKey]);
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
};

export function useStatistikDesa() {
  const tenantId = useTenantId();
  const [data, setData] = useState<StatistikDesa>({
    jumlah_penduduk: 6842,
    jumlah_kk: 1937,
    jumlah_dusun: 6,
    luas_wilayah_km2: 12.4,
    laki_laki: 3421,
    perempuan: 3421,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Hitung dari wilayah_dusun
    Promise.all([
      supabase.from("wilayah_dusun").select("kk, jiwa, luas_ha"),
      supabase.from("dashboard_agregat").select("metrik_key, metrik_value").eq("kategori", "penduduk"),
    ]).then(([dusunRes, aggRes]) => {
      if (dusunRes.data && dusunRes.data.length > 0) {
        const dusun = dusunRes.data;
        const totalKk = dusun.reduce((sum, d) => sum + (d.kk || 0), 0);
        const totalJiwa = dusun.reduce((sum, d) => sum + (d.jiwa || 0), 0);
        const totalLuas = dusun.reduce((sum, d) => sum + Number(d.luas_ha || 0), 0);

        // Cari data jenis_kelamin dari dashboard_agregat
        let lakiLaki = 0, perempuan = 0;
        if (aggRes.data) {
          aggRes.data.forEach((row) => {
            if (row.metrik_key === 'laki_laki') lakiLaki = Number(row.metrik_value);
            if (row.metrik_key === 'perempuan') perempuan = Number(row.metrik_value);
          });
        }

        setData({
          jumlah_penduduk: totalJiwa || 6842,
          jumlah_kk: totalKk || 1937,
          jumlah_dusun: dusun.length || 6,
          luas_wilayah_km2: Number((totalLuas / 100).toFixed(2)) || 12.4, // konversi ha ke km2
          laki_laki: lakiLaki || Math.floor(totalJiwa / 2),
          perempuan: perempuan || Math.floor(totalJiwa / 2),
        });
      }
      setLoading(false);
    });
  }, []);

  return { data, loading };
}

export type IdmData = {
  status: string;
  skor_total: number;
  dimensi: Array<{ nama: string; skor: number }>;
};

export function useIdmData() {
  const [data, setData] = useState<IdmData>({
    status: "Berkembang",
    skor_total: 0.7412,
    dimensi: [
      { nama: "Kesehatan", skor: 4.2 },
      { nama: "Pendidikan", skor: 4.5 },
      { nama: "Modal Sosial", skor: 3.8 },
      { nama: "Permukiman", skor: 4.1 },
      { nama: "Ekonomi", skor: 3.6 },
      { nama: "Ekologi", skor: 4.4 },
    ],
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
            status: r.status || "Berkembang",
            skor_total: Number(r.total_skor) || 0.74,
            dimensi: [
              { nama: "Kesehatan", skor: Number(dimensiScores.Kesehatan || 0.84) * 5 },
              { nama: "Pendidikan", skor: Number(dimensiScores.Pendidikan || 0.90) * 5 },
              { nama: "Modal Sosial", skor: Number(dimensiScores["Modal Sosial"] || 0.76) * 5 },
              { nama: "Permukiman", skor: Number(dimensiScores.Permukiman || 0.82) * 5 },
              { nama: "Ekonomi", skor: Number(dimensiScores.Ekonomi || 0.72) * 5 },
              { nama: "Ekologi", skor: Number(dimensiScores.Ekologi || 0.88) * 5 },
            ],
          });
        }
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export type PembangunanData = {
  progres_fisik_avg: number;
  anggaran_terserap_pct: number;
  aset_baru: number;
  kegiatan_aktif: Array<{ nama: string; progres: number }>;
};

export function usePembangunanData() {
  const [data, setData] = useState<PembangunanData>({
    progres_fisik_avg: 64,
    anggaran_terserap_pct: 58,
    aset_baru: 14,
    kegiatan_aktif: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("kegiatan_pembangunan")
      .select("nama_kegiatan, anggaran, realisasi, status")
      .eq("tahun", 2026)
      .in("status", ["diproses", "diverifikasi"])
      .then(({ data: r }) => {
        if (r && r.length > 0) {
          const totalAnggaran = r.reduce((sum, k) => sum + Number(k.anggaran || 0), 0);
          const totalRealisasi = r.reduce((sum, k) => sum + Number(k.realisasi || 0), 0);

          setData({
            progres_fisik_avg: totalAnggaran > 0 ? Math.round((totalRealisasi / totalAnggaran) * 100) : 64,
            anggaran_terserap_pct: totalAnggaran > 0 ? Math.round((totalRealisasi / totalAnggaran) * 100) : 58,
            aset_baru: r.length,
            kegiatan_aktif: r.slice(0, 5).map((k) => ({
              nama: k.nama_kegiatan,
              progres: Number(k.anggaran) > 0 ? Math.round((Number(k.realisasi || 0) / Number(k.anggaran)) * 100) : 0,
            })),
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
    total_usulan: 47,
    partisipasi_voting: 1284,
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
  id: string; kode: string; nama: string; sumber: string; deskripsi: string | null;
  periode_mulai: string | null; periode_selesai: string | null; kuota: number | null; aktif: boolean;
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

export function usePenerimaBansos(bansosId?: string) {
  const [data, setData] = useState<PenerimaBansos[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    if (!bansosId) { setData([]); setLoading(false); return; }
    supabase.from("penerima_bansos").select("*").eq("bansos_id", bansosId).order("nama")
      .then(({ data: r }) => { setData(((r as unknown) || []) as PenerimaBansos[]); setLoading(false); });
  }, [bansosId]);
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
    if (bulan) q = q.eq("bulan", bulan);
    q.then(({ data: r }) => { setData(((r as unknown) || []) as StuntingAgregat[]); setLoading(false); });
  }, [bulan]);
  return { data, loading };
}

export function usePosyanduAgregat(bulan?: string) {
  const [data, setData] = useState<PosyanduAgregat[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    let q = supabase.from("posyandu_agregat").select("*").order("dusun");
    if (bulan) q = q.eq("bulan", bulan);
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
    if (status) q = q.eq("status", status);
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
    // surat_jenis is public data — RLS policy (aktif=true) handles security.
    // Tenant ID filter removed: fallback tenant UUID != DB tenant UUID → 0 rows.
    q.then(({ data, error }) => {
      if (error) console.error("useSuratJenis error:", error);
      setData((data || []) as SuratJenis[]);
      setLoading(false);
    });
  }, [aktifOnly]);
  return { data, loading };
}

export type LayananStat = {
  jenis_layanan: string; count_bulan_ini: number; count_bulan_lalu: number;
};

export function useLayananStatistik() {
  const [data, setData] = useState<LayananStat[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("layanan_statistik").select("*").then(({ data }) => {
      setData((data || []) as LayananStat[]);
      setLoading(false);
    });
  }, []);
  return { data, loading };
}

export type AduanKategori = { id: string; kode: string; nama: string };

export function useAduanKategori() {
  const [data, setData] = useState<AduanKategori[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    supabase.from("ref_aduan_kategori").select("*").eq("aktif", true).order("urutan")
      .then(({ data }) => { setData((data || []) as AduanKategori[]); setLoading(false); });
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
    supabase
      .from("surat_jenis_dna")
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
    supabase
      .from("surat_ajuan")
      .select("*")
      .order("created_at", { ascending: false })
      .then(({ data }) => { setData((data || []) as SuratAjuanRow[]); setLoading(false); });
  }, []);
  return { data, loading };
}