import { useEffect, useRef, useState } from "react";
import { Link, NavLink, Outlet, useLocation } from "react-router-dom";
import { siteSettings as seedSettings, navigation } from "./data";
import logoDesa from "@/assets/logo-desa.png";
import { useOnlineStatus } from "./lib/useOnlineStatus";
import { useNavItems, useFooterColumns } from "./lib/siteCms";
import { useCmsStatus } from "./lib/cmsStatus";
import { usePreviewMode, exitPreview } from "./lib/preview";
import { useSiteSettings } from "./lib/zeroHardcode";
import { useTenant, useTenantSettings, TenantSwitcher } from "./lib/tenant";
import { supabase } from "@/integrations/supabase/client";

function OfflineBanner() {
  const online = useOnlineStatus();
  const { anyCache } = useCmsStatus();
  if (online && !anyCache) return null;
  const label = !online
    ? "Mode offline — menampilkan data tersimpan dari cache lokal"
    : "Sebagian konten disajikan dari cache lokal — muat ulang untuk data terbaru";
  return (
    <div
      role="status"
      className="fixed left-0 right-0 top-0 z-[60] bg-accent text-primary text-center text-xs font-display font-bold uppercase tracking-[0.24em] py-1.5 px-4 shadow"
    >
      {label}
    </div>
  );
}

function PreviewBar() {
  const on = usePreviewMode();
  if (!on) return null;
  return (
    <div
      role="status"
      className="fixed left-0 right-0 top-0 z-[70] bg-primary text-primary-foreground text-center text-xs font-display font-bold uppercase tracking-[0.24em] py-1.5 px-4 shadow flex items-center justify-center gap-4"
    >
      <span>
        Mode Pratinjau <span className="text-accent">Admin</span> — perubahan belum dipublish
      </span>
      <button
        onClick={() => {
          exitPreview();
          location.reload();
        }}
        className="underline decoration-accent underline-offset-2 hover:text-accent"
      >
        Keluar Pratinjau
      </button>
    </div>
  );
}

function Header() {
  const [open, setOpen] = useState(false);
  const [mobileExpand, setMobileExpand] = useState<string | null>(null);
  const [hover, setHover] = useState<string | null>(null);
  const loc = useLocation();
  const { data: settings } = useSiteSettings();
  const drawerRef = useRef<HTMLDivElement | null>(null);
  const toggleBtnRef = useRef<HTMLButtonElement | null>(null);
  const megaRef = useRef<HTMLDivElement | null>(null);
  const lastHoverTriggerRef = useRef<HTMLElement | null>(null);

  // Resolve site identity from DB (with seed fallback)
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const waNumber = settings?.nomor_wa_resmi ?? seedSettings.nomor_wa_resmi;
  const waDigits = waNumber.replace(/\D/g, "");
  const email = settings?.email ?? seedSettings.email;
  const address = settings?.alamat_kantor ?? seedSettings.alamat_kantor;
  const social = settings?.social_media ?? seedSettings.sosial;

  useEffect(() => {
    setOpen(false);
    setMobileExpand(null);
    setHover(null);
  }, [loc.pathname]);

  // Scroll lock + focus trap while mobile drawer is open
  useEffect(() => {
    if (!open) return;
    const prevOverflow = document.body.style.overflow;
    const prevPaddingRight = document.body.style.paddingRight;
    const scrollbar = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (scrollbar > 0) document.body.style.paddingRight = `${scrollbar}px`;

    const previouslyFocused = document.activeElement as HTMLElement | null;
    const getFocusable = () => {
      const root = drawerRef.current;
      if (!root) return [] as HTMLElement[];
      return Array.from(
        root.querySelectorAll<HTMLElement>(
          'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])',
        ),
      ).filter((el) => !el.hasAttribute("aria-hidden"));
    };
    const t = window.setTimeout(() => {
      const items = getFocusable();
      items[0]?.focus();
    }, 30);

    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        setOpen(false);
        toggleBtnRef.current?.focus();
        return;
      }
      if (e.key !== "Tab") return;
      const items = getFocusable();
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement as HTMLElement | null;
      if (e.shiftKey && active === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && active === last) {
        e.preventDefault();
        first.focus();
      }
    };
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("keydown", onKey);
      window.clearTimeout(t);
      document.body.style.overflow = prevOverflow;
      document.body.style.paddingRight = prevPaddingRight;
      previouslyFocused?.focus?.();
    };
  }, [open]);

  // Desktop mega-panel: scroll lock + focus trap + Escape to close
  useEffect(() => {
    if (!hover) return;
    const mq = window.matchMedia("(min-width: 768px)");
    if (!mq.matches) return;

    const prevOverflow = document.body.style.overflow;
    const prevPaddingRight = document.body.style.paddingRight;
    const scrollbar = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (scrollbar > 0) document.body.style.paddingRight = `${scrollbar}px`;

    const getFocusable = () => {
      const root = megaRef.current;
      if (!root) return [] as HTMLElement[];
      return Array.from(
        root.querySelectorAll<HTMLElement>(
          'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])',
        ),
      ).filter((el) => !el.hasAttribute("aria-hidden"));
    };

    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        setHover(null);
        lastHoverTriggerRef.current?.focus?.();
        return;
      }
      if (e.key !== "Tab") return;
      const items = getFocusable();
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement as HTMLElement | null;
      if (e.shiftKey && active === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && active === last) {
        e.preventDefault();
        first.focus();
      }
    };
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = prevOverflow;
      document.body.style.paddingRight = prevPaddingRight;
    };
  }, [hover]);

  const isHome = loc.pathname === "/";
  type NavChild = { label: string; href: string; desc?: string };
  type NavParent = { label: string; href: string; children: readonly NavChild[] };
  const cmsNav = useNavItems();
  const seedMega = navigation.filter(
    (n) => "children" in n && Array.isArray((n as { children?: unknown }).children),
  ) as unknown as NavParent[];
  const megaItems: NavParent[] =
    cmsNav.loaded && cmsNav.data.length
      ? cmsNav.data.map((p) => ({ label: p.label, href: p.href, children: p.children }))
      : seedMega;
  const flatNav: { label: string; href: string; children?: readonly NavChild[] }[] =
    cmsNav.loaded && cmsNav.data.length
      ? cmsNav.data.map((p) => ({
          label: p.label,
          href: p.href,
          children: p.children.length ? p.children : undefined,
        }))
      : (navigation as unknown as { label: string; href: string; children?: readonly NavChild[] }[]);

  return (
    <header
      className={`${isHome ? "absolute inset-x-0 top-0" : "sticky top-0 shadow-md"} ${
        isHome && !hover ? "bg-transparent" : "bg-primary shadow-xl"
      } z-50 text-primary-foreground transition-[background-color,box-shadow] duration-500 ease-out`}
      onMouseLeave={() => setHover(null)}
    >
      {/* Desktop top row */}
      <div className="relative">
        <div className="hidden md:grid grid-cols-[180px_1fr_auto] lg:grid-cols-[220px_1fr_auto] items-center gap-4 lg:gap-6 px-4 lg:px-6 py-3">
          {/* Left: Logo */}
          <Link
            to="/"
            aria-label={`Beranda ${siteName}`}
            className="group shrink-0 flex items-center justify-start"
          >
            <img
              src={logoDesa}
              alt={`Logo ${siteName}`}
              width={512}
              height={512}
              className="h-20 w-20 lg:h-24 lg:w-24 object-contain drop-shadow-lg transition-transform group-hover:scale-105"
            />
          </Link>

          {/* Center mega nav */}
          <nav aria-label="Navigasi utama" className="flex items-center justify-center gap-4 md:gap-6 lg:gap-10 xl:gap-12">
            {megaItems.map((item) => {
              const active = hover === item.label;
              const panelId = `mega-panel-${item.label.toLowerCase().replace(/\s+/g, "-")}`;
              return (
                <div
                  key={item.label}
                  className="relative"
                  onMouseEnter={() => setHover(item.label)}
                  onFocus={(e) => {
                    lastHoverTriggerRef.current = e.currentTarget.querySelector("a") as HTMLElement | null;
                    setHover(item.label);
                  }}
                >
                  <NavLink
                    to={item.href}
                    aria-haspopup="true"
                    aria-expanded={active}
                    aria-controls={panelId}
                    onMouseEnter={(e) => {
                      lastHoverTriggerRef.current = e.currentTarget as HTMLElement;
                    }}
                    onKeyDown={(e) => {
                      if (!active) return;
                      if (e.key === "Tab" && !e.shiftKey) {
                        const root = megaRef.current;
                        if (!root) return;
                        const first = root.querySelector<HTMLElement>(
                          'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])',
                        );
                        if (first) {
                          e.preventDefault();
                          first.focus();
                        }
                      }
                    }}
                    className={({ isActive }) =>
                      `relative py-2 font-display text-[13px] font-semibold uppercase tracking-[0.22em] transition-colors ${
                        active || isActive ? "text-primary-foreground" : "text-primary-foreground/90 hover:text-primary-foreground"
                      }`
                    }
                  >
                    {item.label}
                    <span
                      aria-hidden
                      className={`pointer-events-none absolute left-0 right-0 -bottom-1 h-[2px] bg-accent origin-left transition-transform duration-300 ${
                        active ? "scale-x-100" : "scale-x-0"
                      }`}
                    />
                  </NavLink>
                </div>
              );
            })}
          </nav>

          {/* Right: Login button */}
          <div className="shrink-0 flex items-center">
            <Link
              to="/admin/login"
              onMouseEnter={() => setHover(null)}
              className="inline-flex items-center gap-2 border border-accent bg-accent/10 text-accent px-5 py-2.5 font-display text-[12px] font-semibold uppercase tracking-[0.22em] hover:bg-accent hover:text-primary transition-colors"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
              Login Admin
            </Link>
          </div>
        </div>

        {/* Mobile top bar */}
        <div className="md:hidden bg-primary flex items-center justify-between px-4 py-3">
          <Link to="/" className="flex items-center gap-2">
            <img src={logoDesa} alt="" width={512} height={512} className="h-10 w-10 object-contain" />
            <span className="font-display text-sm font-semibold">{siteName}</span>
          </Link>
          <button
            type="button"
            ref={toggleBtnRef}
            className="p-2 rounded-md hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-accent"
            aria-label={open ? "Tutup menu" : "Buka menu"}
            aria-expanded={open}
            aria-controls="mobile-drawer"
            onClick={() => setOpen((v) => !v)}
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              {open ? (<><path d="M6 6l12 12" /><path d="M18 6L6 18" /></>) : (<><path d="M4 7h16" /><path d="M4 12h16" /><path d="M4 17h16" /></>)}
            </svg>
          </button>
        </div>

        {/* Desktop Mega panel — 3-column split: 20% brand · 60% submenu · 20% contact */}
        {hover && (
          <div
            id={`mega-panel-${hover.toLowerCase().replace(/\s+/g, "-")}`}
            ref={megaRef}
            role="region"
            aria-label={`Submenu ${hover}`}
            className="hidden md:block absolute inset-x-0 top-full bg-primary text-primary-foreground shadow-2xl border-t border-primary-foreground/15 animate-fade-in"
            onMouseEnter={() => setHover(hover)}
          >
            <div className="mx-auto max-w-[1400px] px-8 lg:px-12 py-12">
              {(() => {
                const parent = megaItems.find((m) => m.label === hover);
                if (!parent) return null;
                const half = Math.ceil(parent.children.length / 2);
                const colA = parent.children.slice(0, half);
                const colB = parent.children.slice(half);
                return (
                  <div className="grid grid-cols-10 gap-8">
                    {/* Kolom Kiri 20% — Logo + deskripsi */}
                    <div className="col-span-2 flex flex-col items-start gap-4 pr-4 border-r border-primary-foreground/15">
                      <img src={logoDesa} alt="" width={512} height={512} className="h-24 w-24 object-contain" />
                      <div>
                        <div className="text-[11px] uppercase tracking-[0.22em] text-accent font-display font-semibold mb-2">
                          {parent.label}
                        </div>
                        <p className="text-sm text-primary-foreground/80 leading-relaxed">
                          Jelajahi seluruh informasi seputar {parent.label.toLowerCase()} di {siteName}.
                        </p>
                        <Link
                          to={parent.href}
                          className="inline-block mt-3 font-display text-sm text-accent hover:underline"
                        >
                          Lihat semua →
                        </Link>
                      </div>
                    </div>

                    {/* Kolom Tengah 60% — submenu split 30/30 */}
                    <div className="col-span-6 grid grid-cols-2 gap-x-12 gap-y-7 content-start px-2">
                      {[colA, colB].flat().map((c, idx) => (
                        <Link
                          key={c.href}
                          to={c.href}
                          style={{ animation: `fade-in 0.35s ease-out ${60 + idx * 55}ms both` }}
                          className="group block border-l-2 border-transparent hover:border-accent pl-4 -ml-4 transition-all duration-300"
                        >
                          <div className="flex items-center gap-3">
                            <div className="font-display text-2xl lg:text-[26px] font-semibold text-primary-foreground group-hover:text-accent transition-all duration-300 leading-tight group-hover:translate-x-1">
                              {c.label}
                            </div>
                            <span
                              aria-hidden
                              className="text-accent opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-300"
                            >
                              →
                            </span>
                          </div>
                          {c.desc && (
                            <div className="mt-1.5 text-xs text-primary-foreground/65 group-hover:text-primary-foreground/85 leading-snug transition-colors">
                              {c.desc}
                            </div>
                          )}
                        </Link>
                      ))}
                    </div>

                    {/* Kolom Kanan 20% — Kontak + Sosial */}
                    <div className="col-span-2 pl-4 border-l border-primary-foreground/15">
                      <div className="text-[11px] uppercase tracking-[0.22em] text-accent font-display font-semibold mb-3">
                        Kontak Desa
                      </div>
                      <ul className="space-y-2 text-sm text-primary-foreground/80">
                        <li className="leading-snug">{address}</li>
                        <li>
                          <a href={`https://wa.me/${waDigits}`} className="hover:text-accent">
                            {waNumber}
                          </a>
                        </li>
                        <li>
                          <a href={`mailto:${email}`} className="hover:text-accent break-all">
                            {email}
                          </a>
                        </li>
                      </ul>
                      <div className="mt-4 flex items-center gap-3">
                        <a href={social.facebook} aria-label="Facebook" className="text-primary-foreground/85 hover:text-accent transition-colors">
                          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M22 12a10 10 0 10-11.6 9.9v-7H8v-2.9h2.4V9.8c0-2.4 1.4-3.7 3.6-3.7 1 0 2.1.2 2.1.2v2.3h-1.2c-1.2 0-1.5.7-1.5 1.5V12h2.6l-.4 2.9h-2.2v7A10 10 0 0022 12z"/></svg>
                        </a>
                        <a href={social.instagram} aria-label="Instagram" className="text-primary-foreground/85 hover:text-accent transition-colors">
                          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor"/></svg>
                        </a>
                        <a href={social.youtube} aria-label="YouTube" className="text-primary-foreground/85 hover:text-accent transition-colors">
                          <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M23 12s0-3.6-.5-5.3a2.8 2.8 0 00-2-2C18.9 4.2 12 4.2 12 4.2s-6.9 0-8.5.5a2.8 2.8 0 00-2 2C1 8.4 1 12 1 12s0 3.6.5 5.3a2.8 2.8 0 002 2c1.6.5 8.5.5 8.5.5s6.9 0 8.5-.5a2.8 2.8 0 002-2C23 15.6 23 12 23 12zM10 15.5V8.5l6 3.5-6 3.5z"/></svg>
                        </a>
                      </div>
                    </div>
                  </div>
                );
              })()}
            </div>
          </div>
        )}
      </div>

      {/* Mobile drawer */}
      {open && (
        <div
          id="mobile-drawer"
          ref={drawerRef}
          role="dialog"
          aria-modal="true"
          aria-label="Menu navigasi"
          className="md:hidden border-t border-white/10 bg-primary max-h-[calc(100vh-56px)] overflow-y-auto overscroll-contain animate-fade-in"
        >
          <nav aria-label="Navigasi mobile" className="max-w-7xl mx-auto px-4 py-2">
            {flatNav.map((item, i) => {
              const hasChildren = !!item.children && item.children.length > 0;
              const isOpen = mobileExpand === item.label;
              return (
                <div
                  key={item.label}
                  className="border-b border-white/10 last:border-0"
                  style={{ animation: `fade-in 0.3s ease-out ${40 + i * 40}ms both` }}
                >
                  {hasChildren ? (
                    <button
                      type="button"
                      className={`w-full flex items-center justify-between py-3.5 text-left font-display text-[13px] font-semibold uppercase tracking-[0.2em] transition-colors ${
                        isOpen ? "text-accent" : "text-primary-foreground hover:text-accent"
                      }`}
                      aria-expanded={isOpen}
                      onClick={() => setMobileExpand(isOpen ? null : item.label)}
                    >
                      <span>{item.label}</span>
                      <span
                        aria-hidden
                        className={`text-accent transition-transform duration-300 ${isOpen ? "rotate-180" : ""}`}
                      >
                        ▾
                      </span>
                    </button>
                  ) : (
                    <Link
                      to={item.href}
                      className="block py-3.5 font-display text-[13px] font-semibold uppercase tracking-[0.2em] text-primary-foreground hover:text-accent transition-colors"
                    >
                      {item.label}
                    </Link>
                  )}
                  {hasChildren && isOpen && (
                    <div className="pb-3 pl-1 space-y-1 overflow-hidden animate-accordion-down">
                      {item.children!.map((c, ci) => (
                        <Link
                          key={c.href}
                          to={c.href}
                          style={{ animation: `fade-in 0.3s ease-out ${60 + ci * 45}ms both` }}
                          className="group block border-l-2 border-white/10 hover:border-accent pl-3 py-2 transition-colors"
                        >
                          <div className="font-display text-base font-semibold text-primary-foreground group-hover:text-accent transition-colors">
                            {c.label}
                          </div>
                          {"desc" in c && c.desc && (
                            <div className="mt-0.5 text-[11px] leading-snug text-primary-foreground/60 group-hover:text-primary-foreground/80 transition-colors">
                              {c.desc}
                            </div>
                          )}
                        </Link>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
            <div className="pt-3 pb-2">
              <Link
                to="/admin/login"
                className="flex items-center justify-center gap-2 border border-accent bg-accent/10 text-accent px-4 py-3 font-display text-[12px] font-semibold uppercase tracking-[0.22em] hover:bg-accent hover:text-primary transition-colors"
              >
                Login Admin
              </Link>
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}

function Footer() {
  const { data: settings } = useSiteSettings();
  const { data: cols, loaded } = useFooterColumns();

  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const address = settings?.alamat_kantor ?? seedSettings.alamat_kantor;
  const social = settings?.social_media ?? seedSettings.sosial;

  return (
    <footer className="bg-[color:var(--color-primer-dark)] text-primary-foreground pt-14 pb-8">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-4 gap-8">
          <div className="md:col-span-2">
            <div className="flex items-center gap-3 mb-3">
              <span className="grid h-10 w-10 place-items-center rounded-full bg-accent text-primary font-display font-bold stempel-badge" style={{ color: "var(--color-aksen)" }}>
                <span className="text-[color:var(--color-primer-dark)]">SM</span>
              </span>
              <div>
                <div className="font-display text-lg font-semibold">{siteName}</div>
                <div className="text-xs text-primary-foreground/70">{seedSettings.wilayah}</div>
              </div>
            </div>
            <p className="text-sm text-primary-foreground/70 max-w-md">
              Portal resmi Kantor Desa Virtual — satu pintu untuk layanan, informasi, dan partisipasi warga.
            </p>
            <p className="mt-4 text-xs text-primary-foreground/60">{address}</p>
          </div>

          {(loaded && cols.length
            ? cols
            : [
                { id: "svc", judul: "Service Center", links: [
                  { label: "Aduan Warga", href: "/service-center" },
                  { label: "Verifikasi Dokumen", href: "/verifikasi" },
                  { label: "Langganan WA", href: "/langganan-wa" },
                ] },
                { id: "conn", judul: "Terhubung", links: [
                  { label: "Facebook", href: social.facebook },
                  { label: "Instagram", href: social.instagram },
                  { label: "YouTube", href: social.youtube },
                ] },
              ]).slice(0, 2).map((col) => (
            <div key={col.id}>
              <h4 className="font-display text-sm font-semibold uppercase tracking-wider text-accent mb-3">
                {col.judul}
              </h4>
              <ul className="space-y-2 text-sm">
                {col.links.map((l, i) => (
                  <li key={i}>
                    {l.href.startsWith("http") || l.href.startsWith("mailto:") || l.href.startsWith("tel:") ? (
                      <a href={l.href} className="hover:text-accent break-words">{l.label}</a>
                    ) : (
                      <Link to={l.href} className="hover:text-accent">{l.label}</Link>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-10 pt-6 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-primary-foreground/60">
          <div>© {new Date().getFullYear()} Pemerintah {siteName}. Semua hak dilindungi.</div>
          <div className="flex items-center gap-4">
            <span className="text-primary-foreground/50">
              Waspada penipuan — hanya percayai nomor WA resmi terverifikasi di atas.
            </span>
            <Link to="/admin/login" className="text-primary-foreground/60 hover:text-accent">Admin</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}

function ScrollToTop() {
  const { pathname, hash } = useLocation();
  useEffect(() => {
    if (hash) {
      const el = document.getElementById(hash.slice(1));
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "start" });
        return;
      }
    }
    window.scrollTo({ top: 0, behavior: "instant" as ScrollBehavior });
  }, [pathname, hash]);
  return null;
}

export default function Layout() {
  const { loading } = useTenant();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-muted-foreground text-sm">Memuat portal...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground">
      <PreviewBar />
      <OfflineBanner />
      <ScrollToTop />
      <Header />
      <main id="main" className="flex-1">
        <Outlet />
      </main>
      <Footer />
      <TenantSwitcher supabaseClient={supabase} />
    </div>
  );
}
