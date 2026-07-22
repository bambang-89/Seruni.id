import { Link } from "react-router-dom";
import type { ReactNode } from "react";
import { SplitTitle } from "./ui";
import { ToneProvider, toneOf } from "./lib/tone";

/**
 * Editorial section primitives (v1 "Editorial Portal").
 * Rules: no rounded corners, no icons, no emoji. Typography + image + hairline.
 */

type BandTone = "dark" | "navy" | "neutral" | "paper";

const bandBg: Record<BandTone, string> = {
  dark: "bg-[#0F0E0E] text-white",
  navy: "bg-primary text-primary-foreground",
  neutral: "bg-[#EAECF0] text-[#0F0E0E]",
  paper: "bg-background text-foreground",
};

export function Band({
  id,
  tone = "paper",
  className = "",
  children,
}: {
  id?: string;
  tone?: BandTone;
  className?: string;
  children: ReactNode;
}) {
  return (
    <ToneProvider tone={toneOf(tone)} label={`Band:${tone}`}>
      <section id={id} className={`${bandBg[tone]} py-16 sm:py-20 lg:py-24 ${className}`}>
        <div className="mx-auto max-w-7xl px-6 sm:px-8 lg:px-12">{children}</div>
      </section>
    </ToneProvider>
  );
}

/** Kicker + big italic display title with hairline underline, editorial style. */
export function EditorialTitle({
  kicker,
  judul,
  href,
  hrefLabel = "Selengkapnya",
  align = "left",
  invert = false,
}: {
  kicker: string;
  judul: string;
  href?: string;
  hrefLabel?: string;
  align?: "left" | "between";
  invert?: boolean;
}) {
  const kickerCls = invert ? "text-accent" : "text-accent";
  const lineCls = invert ? "bg-white/20" : "bg-current/20";
  return (
    <div className={`mb-12 sm:mb-14 ${align === "between" ? "flex flex-wrap items-end justify-between gap-6" : ""}`}>
      <div className="max-w-3xl">
        <p className={`font-display text-[11px] sm:text-xs font-bold uppercase tracking-[0.28em] ${kickerCls} mb-4`}>
          {kicker}
        </p>
        <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight leading-[1.05] ${invert ? "text-white" : "text-current"}`}>
          <SplitTitle text={judul} />
        </h2>
        <div className={`mt-6 h-px w-full max-w-[520px] ${lineCls}`} />
      </div>
      {href && (
        <Link
          to={href}
          className={`font-display text-[11px] font-bold uppercase tracking-[0.28em] border ${
            invert ? "border-white/40 text-white hover:border-accent hover:text-accent" : "border-current/30 hover:border-accent hover:text-accent"
          } px-5 py-2.5 transition-colors self-end`}
        >
          {hrefLabel}
        </Link>
      )}
    </div>
  );
}

/** Navy intro band with orange left border + oversized light paragraph. */
export function IntroBand({ children }: { children: ReactNode }) {
  return (
    <Band tone="navy">
      <div className="border-l-2 border-accent pl-6 sm:pl-8 max-w-4xl">
        <p className="font-display text-xl sm:text-2xl lg:text-3xl font-light leading-snug text-primary-foreground">
          {children}
        </p>
      </div>
    </Band>
  );
}

/** Full-bleed editorial split: image + text. Flip direction with `reverse`. */
export function EditorialSplit({
  kicker,
  judul,
  children,
  image,
  imageAlt,
  reverse = false,
  tone = "neutral",
  href,
  hrefLabel = "Baca",
}: {
  kicker: string;
  judul: string;
  children: ReactNode;
  image: string;
  imageAlt: string;
  reverse?: boolean;
  tone?: BandTone;
  href?: string;
  hrefLabel?: string;
}) {
  return (
    <Band tone={tone}>
      <div className={`grid lg:grid-cols-2 gap-10 lg:gap-16 items-start ${reverse ? "lg:[&>*:first-child]:order-2" : ""}`}>
        <div className="relative overflow-hidden">
          <img
            src={image}
            alt={imageAlt}
            loading="lazy"
            className="block w-full aspect-[4/5] object-cover"
          />
        </div>
        <div className="lg:pt-6">
          <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-4">
            {kicker}
          </p>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight leading-[1.05]">
            {judul}
          </h2>
          <div className="mt-8 space-y-5 text-base sm:text-lg leading-relaxed opacity-90">{children}</div>
          {href && (
            <div className="mt-10 pt-6 border-t border-current/20">
              <Link
                to={href}
                className="inline-flex items-center gap-4 font-display text-[11px] font-bold uppercase tracking-[0.28em]"
              >
                <span>{hrefLabel}</span>
                <span aria-hidden className="block w-14 border-b border-current" />
              </Link>
            </div>
          )}
        </div>
      </div>
    </Band>
  );
}

/** Stats band — grid of oversized numerals with hairline dividers. */
export function StatsBand({
  kicker,
  items,
  tone = "navy",
}: {
  kicker?: string;
  items: { nilai: string; label: string; highlight?: boolean }[];
  tone?: BandTone;
}) {
  return (
    <Band tone={tone} className="border-y border-white/5">
      {kicker && (
        <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-10">
          {kicker}
        </p>
      )}
      {/* Hairline grid using gap+background — safe on every breakpoint, no overlap. */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
        {items.map((s) => (
          <div key={s.label} className={`${bandBg[tone]} px-5 sm:px-6 py-8 sm:py-10`}>
            <span
              className={`block font-display text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight leading-none tabular-nums mb-3 ${
                s.highlight ? "italic text-accent" : ""
              }`}
            >
              {s.nilai}
            </span>
            <span className="font-display text-[10px] sm:text-[11px] font-bold uppercase tracking-[0.22em] opacity-70">
              {s.label}
            </span>
          </div>
        ))}
      </div>
    </Band>
  );
}

/** Numbered editorial list (01/02/03 style). */
export function NumberedList({
  items,
  tone = "navy",
}: {
  items: { kategori: string; judul: string; href?: string; meta?: string }[];
  tone?: BandTone;
}) {
  return (
    <div className={`${bandBg[tone]} py-14 sm:py-16 px-6 sm:px-10 lg:px-14`}>
      <ul className="space-y-8">
        {items.map((it, i) => {
          const num = String(i + 1).padStart(2, "0");
          const Wrapper: React.ElementType = it.href ? Link : "div";
          const props = it.href ? { to: it.href } : {};
          return (
            <li key={i}>
              <Wrapper {...props} className="group flex gap-6 sm:gap-10">
                <span className="font-display text-3xl sm:text-4xl font-light opacity-25 tabular-nums leading-none pt-1">
                  {num}
                </span>
                <div className="flex-1 min-w-0">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                    {it.kategori}
                    {it.meta && <span className="opacity-60"> · {it.meta}</span>}
                  </span>
                  <p className="mt-2 font-display text-lg sm:text-xl font-semibold leading-snug group-hover:text-accent transition-colors">
                    {it.judul}
                  </p>
                </div>
              </Wrapper>
              {i < items.length - 1 && <div className="mt-8 h-px w-full bg-current/10" />}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

/** Featured editorial card — hero image + kicker + title + bordered CTA. */
export function FeaturedCard({
  image,
  imageAlt,
  kicker,
  meta,
  judul,
  ringkasan,
  href,
  cta = "Baca",
  invert = false,
}: {
  image: string;
  imageAlt: string;
  kicker: string;
  meta?: string;
  judul: string;
  ringkasan?: string;
  href: string;
  cta?: string;
  invert?: boolean;
}) {
  return (
    <Link to={href} className="group block">
      <div className="overflow-hidden mb-6">
        <img
          src={image}
          alt={imageAlt}
          loading="lazy"
          className="block w-full aspect-video object-cover transition-transform duration-500 group-hover:scale-[1.03]"
        />
      </div>
      <p className="font-display text-[10px] sm:text-[11px] font-bold uppercase tracking-[0.28em] text-accent">
        {kicker}
        {meta && <span className={`ml-2 opacity-70 ${invert ? "text-white/70" : ""}`}>· {meta}</span>}
      </p>
      <h3 className="mt-3 font-display text-2xl sm:text-3xl font-bold tracking-tight leading-[1.1] group-hover:text-accent transition-colors">
        {judul}
      </h3>
      {ringkasan && (
        <p className={`mt-3 text-sm sm:text-base leading-relaxed ${invert ? "text-white/70" : "text-current/70"} line-clamp-3`}>
          {ringkasan}
        </p>
      )}
      <span
        className={`mt-6 inline-block font-display text-[11px] font-bold uppercase tracking-[0.28em] border ${
          invert ? "border-white/40" : "border-current/40"
        } px-5 py-2.5 group-hover:border-accent group-hover:text-accent transition-colors`}
      >
        {cta}
      </span>
    </Link>
  );
}

/** Editorial category tile grid (Wesley-style Layanan blocks). */
export function TileGrid({
  items,
}: {
  items: { kicker: string; judul: string; href: string; tone: "navy" | "neutral" | "dark" | "accent" }[];
}) {
  const toneBg = {
    navy: "bg-primary text-primary-foreground",
    neutral: "bg-[#EAECF0] text-[#0F0E0E]",
    dark: "bg-[#0F0E0E] text-white",
    accent: "bg-accent text-[#0F0E0E]",
  };
  return (
    <div className="grid grid-cols-2 gap-px bg-current/10">
      {items.map((t) => (
        <Link
          key={t.href}
          to={t.href}
          className={`${toneBg[t.tone]} aspect-square p-6 sm:p-8 flex flex-col justify-between group transition-colors hover:bg-accent hover:text-[#0F0E0E]`}
        >
          <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] opacity-70 group-hover:opacity-100">
            {t.kicker}
          </span>
          <h4 className="font-display text-xl sm:text-2xl font-bold uppercase leading-[0.95] tracking-tight">
            {t.judul}
          </h4>
        </Link>
      ))}
    </div>
  );
}

/** Quote band with portrait — kepala desa etc. */
export function QuoteBand({
  quote,
  nama,
  jabatan,
  image,
  imageAlt,
}: {
  quote: string;
  nama: string;
  jabatan: string;
  image?: string;
  imageAlt?: string;
}) {
  return (
    <Band tone="dark">
      <div className="grid lg:grid-cols-[1fr_auto] gap-10 lg:gap-16 items-end">
        <div className="max-w-3xl">
          <div className="w-12 h-px bg-accent mb-8" />
          <blockquote className="font-display text-2xl sm:text-3xl lg:text-4xl font-light leading-[1.2] italic">
            "{quote}"
          </blockquote>
          <div className="mt-8 pt-6 border-t border-white/15 flex items-center gap-6">
            {image && (
              <img src={image} alt={imageAlt ?? nama} className="block h-16 w-16 object-cover grayscale" loading="lazy" />
            )}
            <div>
              <div className="font-display text-sm font-bold uppercase tracking-[0.2em]">{nama}</div>
              <div className="font-display text-[10px] font-semibold uppercase tracking-[0.28em] text-accent mt-1">{jabatan}</div>
            </div>
          </div>
        </div>
      </div>
    </Band>
  );
}