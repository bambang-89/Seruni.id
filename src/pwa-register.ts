// Guarded service worker registration. Registers ONLY in production browser
// contexts and never inside Lovable preview/dev, iframes, or with ?sw=off.

const UNREGISTER_PATHS = ["/sw.js"];

async function unregisterMatching() {
  if (!("serviceWorker" in navigator)) return;
  try {
    const regs = await navigator.serviceWorker.getRegistrations();
    await Promise.all(
      regs
        .filter((r) => {
          const url = r.active?.scriptURL || r.installing?.scriptURL || r.waiting?.scriptURL || "";
          return UNREGISTER_PATHS.some((p) => url.endsWith(p));
        })
        .map((r) => r.unregister()),
    );
  } catch {
    /* ignore */
  }
}

function isRefusedContext(): boolean {
  if (!import.meta.env.PROD) return true;
  if (typeof window === "undefined") return true;
  if (window.top !== window.self) return true;
  const host = window.location.hostname;
  if (host.startsWith("id-preview--") || host.startsWith("preview--")) return true;
  if (host === "lovableproject.com" || host.endsWith(".lovableproject.com")) return true;
  if (host === "lovableproject-dev.com" || host.endsWith(".lovableproject-dev.com")) return true;
  if (host === "beta.lovable.dev" || host.endsWith(".beta.lovable.dev")) return true;
  const params = new URLSearchParams(window.location.search);
  if (params.get("sw") === "off") return true;
  return false;
}

export function registerPWA() {
  if (isRefusedContext()) {
    void unregisterMatching();
    return;
  }
  if (!("serviceWorker" in navigator)) return;
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js").catch(() => {
      /* silent */
    });
  });
}