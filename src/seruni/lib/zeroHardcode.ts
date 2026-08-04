// ============================================================
// ZERO-HARDCODE HOOKS
// Semua data diambil dari database, bukan hardcode
// Prinsip: Tidak ada teks/warna/menu di kode komponen
// ============================================================

import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

// ============================================================
// Site Settings Hook
// ============================================================

export interface SiteSettings {
  id: string;
  tenant_id: string;
  nama_resmi: string;
  wilayah?: string; // computed from tenant info
  tagline: string | null;
  alamat_kantor: string | null;
  telepon: string | null;
  telepon_darurat?: string; // dari settings JSON
  email: string | null;
  website: string | null;
  kodepos: string | null;
  jam_layanan: string | null;
  nomor_wa_resmi: string | null;
  wa_business_verified: boolean;
  // Wilayah detail
  dusun: string | null;
  rt: string | null;
  // Singkatan untuk nomor surat (dari site_settings)
  singkatan_desa: string | null;
  singkatan_kades: string | null;
  // Token Fonnte WA (dari site_settings)
  fonnte_token: string | null;
  social_media: {
    facebook?: string;
    instagram?: string;
    youtube?: string;
    tiktok?: string;
    twitter?: string;
  };
  maps_embed_url: string | null;
}

export function useSiteSettings() {
  const [data, setData] = useState<SiteSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    supabase
      .from("site_settings")
      .select("*")
      .limit(1)
      .single()
      .then(({ data: r, error: e }) => {
        if (e) {
          setError(e.message);
          // Fallback to static data
          setData(getDefaultSiteSettings());
        } else if (r) {
          setData({
            ...r,
            social_media: typeof r.social_media === 'string'
              ? JSON.parse(r.social_media as unknown as string)
              : (r.social_media as unknown as SiteSettings['social_media']) || {},
          } as any);
        }
        setLoading(false);
      });
  }, []);

  return { data, loading, error };
}

function getDefaultSiteSettings(): SiteSettings {
  return {
    id: "",
    tenant_id: "",
    nama_resmi: "",
    tagline: "",
    alamat_kantor: "",
    telepon: "",
    email: "",
    website: null,
    kodepos: null,
    jam_layanan: "",
    nomor_wa_resmi: "",
    wa_business_verified: false,
    dusun: null,
    rt: null,
    singkatan_desa: null,
    singkatan_kades: null,
    fonnte_token: null,
    social_media: {
      facebook: "",
      instagram: "",
      youtube: "",
      tiktok: "",
      twitter: "",
    },
    maps_embed_url: null,
  };
}

// ============================================================
// Navigation Hook
// ============================================================

export interface NavItem {
  id: string;
  label: string;
  href: string;
  icon: string | null;
  parent_id: string | null;
  urutan: number;
  children?: NavItem[];
}

export interface NavigationData {
  header: NavItem[];
  footer: NavItem[];
}

export function useNavigation() {
  const [data, setData] = useState<NavigationData>({ header: [], footer: [] });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      supabase
        .from("site_navigation")
        .select("*")
        .eq("posisi", "header")
        .eq("aktif", true)
        .order("urutan"),
      supabase
        .from("site_navigation")
        .select("*")
        .eq("posisi", "footer")
        .eq("aktif", true)
        .order("urutan"),
    ]).then(([headerRes, footerRes]) => {
      const buildTree = (items: typeof headerRes.data): NavItem[] => {
        if (!items) return [];
        const map = new Map<string, NavItem>();
        const roots: NavItem[] = [];

        items.forEach((item) => {
          map.set(item.id, { ...item, children: [] });
        });

        map.forEach((item) => {
          if (item.parent_id && map.has(item.parent_id)) {
            map.get(item.parent_id)!.children!.push(item);
          } else {
            roots.push(item);
          }
        });

        return roots;
      };

      setData({
        header: buildTree(headerRes.data),
        footer: buildTree(footerRes.data),
      });
      setLoading(false);
    });
  }, []);

  return { data, loading };
}

// ============================================================
// Feature Flags Hook
// ============================================================

export interface FeatureFlags {
  F0_REGISTRASI: boolean;
  F1_SURAT: boolean;
  F2_USULAN: boolean;
  F3_IDM: boolean;
  F4_POSYANDU: boolean;
  F5_PBB: boolean;
  F6_WA_CHATBOT: boolean;
  F7_PERTANAHAN: boolean;
  F8_ASET: boolean;
  F9_PEMETAAN: boolean;
  F10_STATISTIK: boolean;
}

export function useFeatureFlags() {
  const [flags, setFlags] = useState<FeatureFlags>({
    F0_REGISTRASI: true,
    F1_SURAT: true,
    F2_USULAN: true,
    F3_IDM: true,
    F4_POSYANDU: true,
    F5_PBB: true,
    F6_WA_CHATBOT: true,
    F7_PERTANAHAN: true,
    F8_ASET: true,
    F9_PEMETAAN: true,
    F10_STATISTIK: true,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("feature_flags")
      .select("fitur_kode, aktif")
      .then(({ data: r }) => {
        if (r && r.length > 0) {
          const newFlags = { ...flags };
          r.forEach((row) => {
            const key = row.fitur_kode as keyof FeatureFlags;
            if (key in newFlags) {
              (newFlags as Record<string, boolean>)[key] = row.aktif;
            }
          });
          setFlags(newFlags);
        }
        setLoading(false);
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { flags, loading };
}

// ============================================================
// Reference Tables Hooks
// ============================================================

export function useRefAgama() {
  const [data, setData] = useState<Array<{ id: string; kode: string; nama: string }>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("ref_agama")
      .select("id, kode, nama")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r) setData(r);
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export function useRefPendidikan() {
  const [data, setData] = useState<Array<{ id: string; kode: string; nama: string; jenjang: string | null }>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("ref_pendidikan")
      .select("id, kode, nama, jenjang")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r) setData(r);
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export function useRefPekerjaan() {
  const [data, setData] = useState<Array<{ id: string; kode: string; nama: string; kategori: string | null }>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("ref_pekerjaan")
      .select("id, kode, nama, kategori")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r) setData(r);
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export function useRefStatusPerkawinan() {
  const [data, setData] = useState<Array<{ id: string; kode: string; nama: string }>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("ref_status_perkawinan")
      .select("id, kode, nama")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r) setData(r);
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

export function useRefGolonganDarah() {
  const [data, setData] = useState<Array<{ id: string; kode: string; nama: string }>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("ref_golongan_darah")
      .select("id, kode, nama")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data: r }) => {
        if (r) setData(r);
        setLoading(false);
      });
  }, []);

  return { data, loading };
}

// ============================================================
// IDM Status Hook
// ============================================================

export interface IdmStatus {
  total_skor: number;
  status: string;
  dimensi_scores: {
    kesehatan: number;
    pendidikan: number;
    modal_sosial: number;
    permukiman: number;
    ekonomi: number;
    ekologi: number;
  };
  dihitung_pada: string;
}

export function useIdmStatus() {
  const [data, setData] = useState<IdmStatus | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("idm_status_desa")
      .select("*")
      .limit(1)
      .single()
      .then(({ data: r }) => {
        if (r) {
          setData({
            total_skor: r.total_skor,
            status: r.status,
            dimensi_scores: typeof r.dimensi_scores === 'string'
              ? JSON.parse(r.dimensi_scores as unknown as string)
              : (r.dimensi_scores as unknown as IdmStatus['dimensi_scores']) || {},
            dihitung_pada: r.dihitung_pada,
          });
        }
        setLoading(false);
      });
  }, []);

  return { data, loading };
}
