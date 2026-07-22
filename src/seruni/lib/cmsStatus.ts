// Last-good cache + status subscription for public CMS payloads (page_config,
// nav_item, footer_column). Backed by localStorage so a cold-start offline
// visit still renders the site with a clear "cache lokal" badge.

import { useEffect, useState } from "react";

export type CmsSource = "network" | "cache" | "preview" | "seed" | "loading";

type StatusMap = Record<string, CmsSource>;
let status: StatusMap = {};
const subs = new Set<(s: StatusMap) => void>();

export function setCmsSource(key: string, src: CmsSource) {
  if (status[key] === src) return;
  status = { ...status, [key]: src };
  subs.forEach((cb) => cb(status));
}

export function useCmsStatus() {
  const [s, setS] = useState<StatusMap>(status);
  useEffect(() => {
    subs.add(setS);
    return () => {
      subs.delete(setS);
    };
  }, []);
  // aggregate: any cached / any preview
  const anyPreview = Object.values(s).some((v) => v === "preview");
  const anyCache = Object.values(s).some((v) => v === "cache");
  return { status: s, anyPreview, anyCache };
}

// ---------- localStorage last-good cache ----------
const LS_PREFIX = "seruni:cms:v1:";

export function readCache<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(LS_PREFIX + key);
    if (!raw) return null;
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export function writeCache<T>(key: string, value: T) {
  try {
    localStorage.setItem(LS_PREFIX + key, JSON.stringify(value));
  } catch {
    /* quota — ignore */
  }
}