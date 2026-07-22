import { Link, useLocation } from "react-router-dom";
import { useEffect, type ReactNode } from "react";
import heroImg from "@/assets/hero-village.jpg";
import { ToneProvider, toneOf } from "./lib/tone";
import { usePageConfig } from "./lib/pageConfig";

export function formatTanggal(iso: string) {
  return new Date(iso).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" });
}

/**
 * SplitTitle — renders a title in the mandated two-pattern rule:
 *   • first word: Poppins, regular weight, current color (white/black), no italic
 *   • remaining words: sans-serif italic, amber accent color
 * Works for any title length; a single-word title just renders pattern 1.
 */
export function SplitTitle({
  text,
  className = "",
  italicRest = true,
}: {
  text: string;
  className?: string;
  /** Set false for hero titles that must stay non-italic entirely. */
  italicRest?: boolean;
}) {
  const parts = text.trim().split(/\s+/).filter(Boolean);
  useEffect(() => {
    if (import.meta.env.PROD) return;
    if (parts.length !== 2) {
      // eslint-disable-next-line no-console
      console.warn(
        `[seruni/title] Judul section wajib 2 kata (kata pertama regular + kata kedua italic amber). ` +
          `Judul "${text}" memiliki ${parts.length} kata — otomatis dipotong menjadi 2 kata pertama.`,
      );
    }
  }, [text, parts.length]);
  const truncated = parts.slice(0, 2);
  const first = truncated[0] ?? "";
  const rest = truncated[1] ?? "";
  return (
    <span className={className}>
      <span className="font-display font-normal not-italic">{first}</span>
      {rest && (
        <>
          {" "}
          <span
            className={`font-sans font-normal text-accent ${italicRest ? "italic" : "not-italic"}`}
          >
            {rest}
          </span>
        </>
      )}
    </span>
  );
}

export function SectionHeader({
  eyebrow,
  judul,
  deskripsi,
  href,
  invert = false,
}: {
  eyebrow: string;
  judul: string;
  deskripsi?: string;
  href?: string;
  invert?: boolean;
}) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-6 mb-12">
      <div className="max-w-3xl">
        <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-4">{eyebrow}</p>
        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight leading-[1.05]">
          <SplitTitle text={judul} />
        </h2>
        <div className={`mt-6 h-px w-full max-w-[520px] ${invert ? "bg-white/20" : "bg-current/20"}`} />
        {deskripsi && (
          <p className="mt-6 text-base sm:text-lg leading-relaxed opacity-80 max-w-2xl">{deskripsi}</p>
        )}
      </div>
      {href && (
        <Link
          to={href}
          className={`font-display text-[11px] font-bold uppercase tracking-[0.28em] border ${
            invert ? "border-white/40 text-white hover:border-accent hover:text-accent" : "border-current/30 hover:border-accent hover:text-accent"
          } px-5 py-2.5 transition-colors self-end`}
        >
          Selengkapnya
        </Link>
      )}
    </div>
  );
}

type WrapTone = "paper" | "neutral" | "navy" | "dark";
const wrapBg: Record<WrapTone, string> = {
  paper: "bg-background text-foreground",
  neutral: "bg-[#EAECF0] text-[#0F0E0E]",
  navy: "bg-primary text-primary-foreground",
  dark: "bg-[#0F0E0E] text-white",
};

export function SectionWrap({
  id,
  alt,
  tone,
  children,
}: {
  id?: string;
  /** legacy alias for tone="neutral" */
  alt?: boolean;
  tone?: WrapTone;
  children: ReactNode;
}) {
  const resolved: WrapTone = tone ?? (alt ? "neutral" : "paper");
  return (
    <ToneProvider tone={toneOf(resolved)} label={`SectionWrap:${resolved}`}>
      <section id={id} className={`${wrapBg[resolved]} py-16 sm:py-20 lg:py-24`}>
        <div className="mx-auto max-w-7xl px-6 sm:px-8 lg:px-12">{children}</div>
      </section>
    </ToneProvider>
  );
}

export function Crumbs({ items }: { items: { label: string; to?: string }[] }) {
  return (
    <nav aria-label="Breadcrumb" className="font-display text-[10px] uppercase tracking-[0.28em] text-primary-foreground/60">
      <ol className="flex flex-wrap items-center gap-2">
        {items.map((it, i) => (
          <li key={i} className="flex items-center gap-2">
            {it.to ? (
              <Link to={it.to} className="hover:text-accent transition-colors">
                {it.label}
              </Link>
            ) : (
              <span className="text-accent">{it.label}</span>
            )}
            {i < items.length - 1 && <span aria-hidden className="opacity-40">—</span>}
          </li>
        ))}
      </ol>
    </nav>
  );
}

export function PageHeader({
  eyebrow,
  judul,
  deskripsi,
  crumbs,
  image,
}: {
  eyebrow: string;
  judul: string;
  deskripsi?: string;
  crumbs: { label: string; to?: string }[];
  image?: string;
}) {
  const bg = image ?? heroImg;
  return (
    <ToneProvider tone="dark" label="PageHeader">
    <section className="relative isolate overflow-hidden bg-[#0F0E0E] text-white border-b border-white/10 min-h-[60vh] flex items-end">
      <img
        src={bg}
        alt=""
        aria-hidden
        className="absolute inset-0 h-full w-full object-cover"
        loading="eager"
        fetchPriority="high"
      />
      {/* Dark scrim so hero copy is always legible over any image */}
      <div aria-hidden className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/50 to-black/85" />
      <div aria-hidden className="absolute inset-x-0 top-0 h-40 bg-gradient-to-b from-black/80 to-transparent" />
      <div className="relative w-full mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 pt-[160px] pb-16 sm:pt-[200px] sm:pb-24">
        <Crumbs items={crumbs} />
        <p className="mt-10 font-display text-[11px] sm:text-xs font-bold uppercase tracking-[0.32em] text-accent">
          {eyebrow}
        </p>
        <div className="mt-4 w-12 h-px bg-accent" />
        <h1 className="mt-6 text-4xl sm:text-6xl lg:text-7xl font-bold tracking-tight leading-[0.95] max-w-4xl drop-shadow-lg">
          <SplitTitle text={judul} italicRest={false} />
        </h1>
        {deskripsi && (
          <p className="mt-8 text-base sm:text-lg text-white/85 max-w-2xl leading-relaxed">
            {deskripsi}
          </p>
        )}
      </div>
    </section>
    </ToneProvider>
  );
}

/**
 * EditorialLayout — shared page shell so every inner route inherits the
 * same typography, hairline dividers, and vertical rhythm automatically.
 * Wraps <PageHeader> and a semantic <main>; child sections should use
 * <SectionWrap> or the editorial primitives from ./sections.
 */
export function EditorialLayout({
  eyebrow,
  judul,
  deskripsi,
  crumbs,
  heroImage,
  route,
  children,
}: {
  eyebrow: string;
  judul: string;
  deskripsi?: string;
  crumbs: { label: string; to?: string }[];
  heroImage?: string;
  /** Route ini otomatis membaca page_config (hero image, eyebrow, judul override). */
  route?: string;
  children: ReactNode;
}) {
  const loc = useLocation();
  const effectiveRoute = route ?? loc.pathname;
  const cfg = usePageConfig(effectiveRoute);
  return (
    <>
      <PageHeader
        eyebrow={cfg?.eyebrow?.trim() || eyebrow}
        judul={cfg?.judul?.trim() || judul}
        deskripsi={cfg?.deskripsi ?? deskripsi}
        crumbs={crumbs}
        image={cfg?.hero_image_url || heroImage}
      />
      <main className="editorial-main [&>section+section]:border-t [&>section+section]:border-current/10">
        {children}
      </main>
    </>
  );
}

/** Editorial card — hairline border, no radius, no icon. */
export function EditorialCard({
  kicker,
  judul,
  meta,
  children,
  className = "",
}: {
  kicker?: string;
  judul?: string;
  meta?: ReactNode;
  children?: ReactNode;
  className?: string;
}) {
  return (
    <article className={`border border-current/15 p-5 sm:p-6 bg-transparent ${className}`}>
      {kicker && (
        <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-2">
          {kicker}
        </p>
      )}
      {judul && (
        <h3 className="font-display text-lg sm:text-xl font-semibold leading-snug">{judul}</h3>
      )}
      {meta && <div className="mt-2 text-xs opacity-70">{meta}</div>}
      {children && <div className="mt-3 text-sm leading-relaxed opacity-90">{children}</div>}
    </article>
  );
}

/** Sharp-cornered progress bar for editorial data pages. */
export function EditorialProgress({
  label,
  value,
  max = 100,
  suffix = "%",
}: {
  label: string;
  value: number;
  max?: number;
  suffix?: string;
}) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  return (
    <div>
      <div className="flex justify-between text-sm mb-1.5 font-display">
        <span>{label}</span>
        <span className="tabular-nums font-semibold text-accent">
          {value.toLocaleString("id-ID")}
          {suffix}
        </span>
      </div>
      <div className="h-[3px] w-full bg-current/10 overflow-hidden">
        <div className="h-full bg-accent" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}