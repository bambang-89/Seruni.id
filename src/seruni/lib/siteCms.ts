import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { readCache, writeCache, setCmsSource } from "./cmsStatus";
import { readNavPreview, readFooterPreview } from "./preview";

export type NavItemRow = {
  id: string;
  parent_id: string | null;
  label: string;
  href: string;
  deskripsi: string | null;
  urutan: number;
  aktif: boolean;
};

export type NavParent = {
  id: string;
  label: string;
  href: string;
  children: { id: string; label: string; href: string; desc?: string }[];
};

export function useNavItems(): { data: NavParent[]; loaded: boolean } {
  const [rows, setRows] = useState<NavItemRow[] | null>(() => {
    const pv = readNavPreview<NavItemRow[]>();
    if (pv) {
      setCmsSource("nav", "preview");
      return pv;
    }
    const c = readCache<NavItemRow[]>("nav");
    if (c) {
      setCmsSource("nav", "cache");
      return c;
    }
    return null;
  });
  useEffect(() => {
    const pv = readNavPreview<NavItemRow[]>();
    if (pv) {
      setCmsSource("nav", "preview");
      setRows(pv);
      return;
    }
    (supabase as any)
      .from("nav_item")
      .select("*")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data, error }: any) => {
        if (error || !data) {
          const cached = readCache<NavItemRow[]>("nav");
          if (cached) {
            setCmsSource("nav", "cache");
            setRows(cached);
          } else {
            setCmsSource("nav", "seed");
            setRows([]);
          }
          return;
        }
        setCmsSource("nav", "network");
        writeCache("nav", data as NavItemRow[]);
        setRows(data as NavItemRow[]);
      });
  }, []);
  if (!rows) return { data: [], loaded: false };
  const parents = rows
    .filter((r) => !r.parent_id)
    .sort((a, b) => a.urutan - b.urutan)
    .map((p) => ({
      id: p.id,
      label: p.label,
      href: p.href,
      children: rows
        .filter((c) => c.parent_id === p.id)
        .sort((a, b) => a.urutan - b.urutan)
        .map((c) => ({ id: c.id, label: c.label, href: c.href, desc: c.deskripsi ?? undefined })),
    }));
  return { data: parents, loaded: true };
}

export type FooterCol = {
  id: string;
  judul: string;
  urutan: number;
  aktif: boolean;
  links: { label: string; href: string }[];
};

export function useFooterColumns(): { data: FooterCol[]; loaded: boolean } {
  const [rows, setRows] = useState<FooterCol[] | null>(() => {
    const pv = readFooterPreview<FooterCol[]>();
    if (pv) {
      setCmsSource("footer", "preview");
      return pv;
    }
    const c = readCache<FooterCol[]>("footer");
    if (c) {
      setCmsSource("footer", "cache");
      return c;
    }
    return null;
  });
  useEffect(() => {
    const pv = readFooterPreview<FooterCol[]>();
    if (pv) {
      setCmsSource("footer", "preview");
      setRows(pv);
      return;
    }
    (supabase as any)
      .from("footer_column")
      .select("*")
      .eq("aktif", true)
      .order("urutan")
      .then(({ data, error }: any) => {
        if (error || !data) {
          const cached = readCache<FooterCol[]>("footer");
          if (cached) {
            setCmsSource("footer", "cache");
            setRows(cached);
          } else {
            setCmsSource("footer", "seed");
            setRows([]);
          }
          return;
        }
        setCmsSource("footer", "network");
        writeCache("footer", data as FooterCol[]);
        setRows(data as FooterCol[]);
      });
  }, []);
  return { data: rows ?? [], loaded: rows !== null };
}