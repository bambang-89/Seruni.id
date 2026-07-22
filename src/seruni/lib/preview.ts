// Admin "preview mode" — stash draft page_config / nav / footer in sessionStorage
// and let public hooks pick them up instead of live database rows.
// Preview is per-tab (sessionStorage) and can also be triggered via ?preview=1.

import { useEffect, useState } from "react";

const SS = () => (typeof window === "undefined" ? null : window.sessionStorage);
const FLAG = "seruni:preview:on";
const PAGE = (route: string) => `seruni:preview:page:${route}`;
const NAV = "seruni:preview:nav";
const FOOT = "seruni:preview:footer";

const listeners = new Set<() => void>();
function ping() {
  listeners.forEach((cb) => cb());
}

export function isPreviewMode(): boolean {
  const s = SS();
  if (!s) return false;
  if (s.getItem(FLAG) === "1") return true;
  if (typeof location !== "undefined" && new URLSearchParams(location.search).get("preview") === "1") {
    s.setItem(FLAG, "1");
    return true;
  }
  return false;
}

export function usePreviewMode() {
  const [on, setOn] = useState<boolean>(isPreviewMode());
  useEffect(() => {
    const cb = () => setOn(isPreviewMode());
    listeners.add(cb);
    return () => {
      listeners.delete(cb);
    };
  }, []);
  return on;
}

export function exitPreview() {
  const s = SS();
  if (!s) return;
  s.removeItem(FLAG);
  // Sweep any stashed drafts so a later ?preview=1 starts clean.
  Object.keys(s)
    .filter((k) => k.startsWith("seruni:preview:"))
    .forEach((k) => s.removeItem(k));
  ping();
}

// ---- page_config ----
export function stashPagePreview(route: string, payload: unknown) {
  const s = SS();
  if (!s) return;
  s.setItem(FLAG, "1");
  s.setItem(PAGE(route), JSON.stringify(payload));
  ping();
}
export function readPagePreview<T>(route: string): T | null {
  const s = SS();
  if (!s || !isPreviewMode()) return null;
  const raw = s.getItem(PAGE(route));
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

// ---- nav / footer ----
export function stashNavPreview(rows: unknown) {
  const s = SS();
  if (!s) return;
  s.setItem(FLAG, "1");
  s.setItem(NAV, JSON.stringify(rows));
  ping();
}
export function readNavPreview<T>(): T | null {
  const s = SS();
  if (!s || !isPreviewMode()) return null;
  const raw = s.getItem(NAV);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export function stashFooterPreview(rows: unknown) {
  const s = SS();
  if (!s) return;
  s.setItem(FLAG, "1");
  s.setItem(FOOT, JSON.stringify(rows));
  ping();
}
export function readFooterPreview<T>(): T | null {
  const s = SS();
  if (!s || !isPreviewMode()) return null;
  const raw = s.getItem(FOOT);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export function openPreview(path = "/") {
  const url = path + (path.includes("?") ? "&" : "?") + "preview=1";
  window.open(url, "_blank", "noopener");
}