import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { readCache, writeCache, setCmsSource } from "./cmsStatus";
import { readPagePreview } from "./preview";

export type SectionTitle = {
  key: string;
  kicker: string;
  judul: string;
  deskripsi?: string;
};

export type PageConfig = {
  route: string;
  nama: string;
  eyebrow: string;
  judul: string;
  deskripsi: string | null;
  hero_image_url: string | null;
  section_titles: SectionTitle[];
};

// Cache per-route so tabs across many <SectionHeader>s share one fetch.
const cache = new Map<string, PageConfig | null>();
const listeners = new Map<string, Set<(v: PageConfig | null) => void>>();

async function fetchOne(route: string) {
  try {
    const { data, error } = await (supabase as any)
      .from("page_config")
      .select("*")
      .eq("route", route)
      .maybeSingle();
    if (error) throw error;
    const v = (data as PageConfig | null) ?? null;
    cache.set(route, v);
    if (v) writeCache(`page:${route}`, v);
    setCmsSource(`page:${route}`, "network");
    listeners.get(route)?.forEach((cb) => cb(v));
    return v;
  } catch {
    // network failure — leave whatever is in cache, mark source
    const cached = readCache<PageConfig>(`page:${route}`);
    if (cached) {
      cache.set(route, cached);
      setCmsSource(`page:${route}`, "cache");
      listeners.get(route)?.forEach((cb) => cb(cached));
      return cached;
    }
    setCmsSource(`page:${route}`, "seed");
    return null;
  }
}

export function usePageConfig(route?: string | null) {
  const initial = (): PageConfig | null => {
    if (!route) return null;
    const pv = readPagePreview<PageConfig>(route);
    if (pv) {
      cache.set(route, pv);
      setCmsSource(`page:${route}`, "preview");
      return pv;
    }
    if (cache.has(route)) return cache.get(route) ?? null;
    const c = readCache<PageConfig>(`page:${route}`);
    if (c) {
      cache.set(route, c);
      setCmsSource(`page:${route}`, "cache");
      return c;
    }
    return null;
  };
  const [data, setData] = useState<PageConfig | null>(initial);
  useEffect(() => {
    if (!route) return;
    const pv = readPagePreview<PageConfig>(route);
    if (pv) {
      setCmsSource(`page:${route}`, "preview");
      setData(pv);
      return; // never overwrite preview with network in this session
    }
    if (cache.has(route)) setData(cache.get(route) ?? null);
    fetchOne(route).then(setData);
    let set = listeners.get(route);
    if (!set) {
      set = new Set();
      listeners.set(route, set);
    }
    set.add(setData);
    return () => {
      set!.delete(setData);
    };
  }, [route]);
  return data;
}

/** Lookup a specific editable section title override (by key). */
export function useSectionTitle(route: string | undefined, key: string) {
  const cfg = usePageConfig(route);
  return cfg?.section_titles?.find((s) => s.key === key) ?? null;
}

export function invalidatePageConfig(route?: string) {
  if (route) {
    cache.delete(route);
    fetchOne(route);
  } else {
    cache.clear();
  }
}