import { createContext, useContext, useEffect, type ReactNode } from "react";

export type Tone = "light" | "dark";

const ToneCtx = createContext<Tone>("light");

export function useTone() {
  return useContext(ToneCtx);
}

/**
 * ToneProvider wraps a region with a light/dark tone context.
 * In development it warns whenever a child region declares the SAME tone as
 * its parent (terang-di-terang atau gelap-di-gelap) — one of the design
 * rules of the Seruni portal. Production stays silent.
 */
export function ToneProvider({
  tone,
  label,
  children,
}: {
  tone: Tone;
  label?: string;
  children: ReactNode;
}) {
  const parent = useContext(ToneCtx);
  useEffect(() => {
    if (import.meta.env.PROD) return;
    if (parent === tone) {
      // eslint-disable-next-line no-console
      console.warn(
        `[seruni/contrast] Konflik tone "${tone}" bersarang di dalam "${parent}"` +
          (label ? ` (${label})` : "") +
          ". Aturan desain: harus terang di atas gelap atau sebaliknya.",
      );
    }
  }, [parent, tone, label]);
  return <ToneCtx.Provider value={tone}>{children}</ToneCtx.Provider>;
}

/** Map band tone keyword → contrast category. */
export function toneOf(name: "paper" | "neutral" | "navy" | "dark" | "accent"): Tone {
  if (name === "navy" || name === "dark") return "dark";
  return "light";
}