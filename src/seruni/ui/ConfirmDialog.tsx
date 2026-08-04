import React, { createContext, useCallback, useContext, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { Trash2, Globe, RotateCcw, Check, X, AlertTriangle } from "lucide-react";

// ─── Types ────────────────────────────────────────────────────────────────────

type ConfirmVariant = "danger" | "warning" | "info";

type ConfirmOptions = {
  title: string;
  message?: string;
  confirmText?: string;
  cancelText?: string;
  variant?: ConfirmVariant;
};

type PromptOptions = {
  title: string;
  message?: string;
  placeholder?: string;
  defaultValue?: string;
  confirmText?: string;
  cancelText?: string;
};

// ─── Context ───────────────────────────────────────────────────────────────────

type DialogContextValue = {
  confirm: (opts: ConfirmOptions) => Promise<boolean>;
  prompt: (opts: PromptOptions) => Promise<string | null>;
};

const DialogContext = createContext<DialogContextValue>({
  confirm: () => Promise.resolve(false),
  prompt: () => Promise.resolve(null),
});

// ─── Variant helpers ────────────────────────────────────────────────────────────

const VARIANT_META: Record<
  ConfirmVariant,
  { icon: React.ReactNode; iconBg: string; iconColor: string; btnClass: string }
> = {
  danger: {
    icon: <Trash2 size={28} />,
    iconBg: "bg-destructive/10",
    iconColor: "text-destructive",
    btnClass: "bg-destructive hover:bg-destructive/90",
  },
  warning: {
    icon: <Globe size={28} />,
    iconBg: "bg-accent/10",
    iconColor: "text-accent",
    btnClass: "bg-accent hover:bg-accent/90 text-primary",
  },
  info: {
    icon: <AlertTriangle size={28} />,
    iconBg: "bg-primary/10",
    iconColor: "text-primary",
    btnClass: "bg-primary hover:bg-primary/90 text-primary-foreground",
  },
};

const VARIANT_KEYWORDS: [string, ConfirmVariant][] = [
  ["hapus", "danger"],
  ["delete", "danger"],
  ["remove", "danger"],
  ["rollback", "warning"],
  ["publish", "warning"],
  ["broadcast", "warning"],
  ["pulihkan", "warning"],
  ["restore", "warning"],
  ["kirim", "info"],
  ["send", "info"],
];

function inferVariant(title: string): ConfirmVariant {
  const lower = title.toLowerCase();
  for (const [key, v] of VARIANT_KEYWORDS) {
    if (lower.includes(key)) return v;
  }
  return "info";
}

// ─── Message inference ─────────────────────────────────────────────────────────

const TITLE_MESSAGES: [RegExp, string][] = [
  [/hapus.*penduduk/i, "Data penduduk yang dipilih akan dihapus permanen dan tidak dapat dikembalikan."],
  [/hapus.*hero/i, "Konfigurasi hero ini akan dihapus dari sistem."],
  [/hapus.*jenis surat/i, "Jenis surat beserta semua field DNA-nya akan dihapus permanen."],
  [/hapus.*field/i, "Field ini akan dihapus dari sistem."],
  [/hapus.*surat/i, "Surat ini akan dihapus permanen dan tidak dapat dikembalikan."],
  [/hapus.*usulan/i, "Usulan ini akan dihapus. Tindakan ini tidak dapat dibatalkan."],
  [/hapus.*baris/i, "Baris ini akan dihapus dari tabel."],
  [/hapus.*menu/i, "Menu beserta semua submenu di bawahnya akan dihapus."],
  [/hapus.*footer/i, "Kolom footer ini akan dihapus."],
  [/hapus.*draft/i, "Draft ini akan dihapus permanen."],
  [/rollback.*publikasi/i, "Situs akan dikembalikan ke versi sebelumnya. Versi live saat ini menjadi draft."],
  [/rollback.*perubahan/i, "Perubahan saat ini akan dibatalkan."],
  [/pulihkan.*versi/i, "Versi yang dipilih akan dipulihkan sebagai versi aktif. Perubahan saat ini tersimpan sebagai versi baru."],
  [/pulihkan.*ke.*versi/i, "Versi yang dipilih akan dipulihkan."],
  [/kirim.*broadcast/i, "Pesan broadcast akan langsung dikirim ke semua target."],
  [/kirim.*ulang/i, "Pesan akan dikirim ulang ke target yang gagal atau tertunda."],
];

export function inferConfirmMessage(title: string): string | undefined {
  for (const [re, msg] of TITLE_MESSAGES) {
    if (re.test(title)) return msg;
  }
  return undefined;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

type PendingConfirm = ConfirmOptions & { resolve: (v: boolean) => void };
type PendingPrompt = Omit<PromptOptions, "confirmText" | "cancelText"> & {
  resolve: (v: string | null) => void;
};

export function ConfirmPromptProvider({ children }: { children: React.ReactNode }) {
  const [pendingConfirm, setPendingConfirm] = useState<PendingConfirm | null>(null);
  const [pendingPrompt, setPendingPrompt] = useState<PendingPrompt | null>(null);
  const promptInputRef = useRef<HTMLInputElement>(null);

  const confirm = useCallback((opts: ConfirmOptions): Promise<boolean> => {
    return new Promise((resolve) => {
      setPendingConfirm({ ...opts, resolve });
    });
  }, []);

  const prompt = useCallback((opts: PromptOptions): Promise<string | null> => {
    return new Promise((resolve) => {
      setPendingPrompt({ ...opts, resolve });
    });
  }, []);

  const handleConfirmOk = () => {
    pendingConfirm?.resolve(true);
    setPendingConfirm(null);
  };

  const handleConfirmCancel = () => {
    pendingConfirm?.resolve(false);
    setPendingConfirm(null);
  };

  const handlePromptOk = () => {
    const val = promptInputRef.current?.value ?? null;
    pendingPrompt?.resolve(val || null);
    setPendingPrompt(null);
  };

  const handlePromptCancel = () => {
    pendingPrompt?.resolve(null);
    setPendingPrompt(null);
  };

  const variant = pendingConfirm ? inferVariant(pendingConfirm.title) : "info";
  const meta = VARIANT_META[variant];
  const message = pendingConfirm?.message ?? inferConfirmMessage(pendingConfirm?.title ?? "");

  return (
    <DialogContext.Provider value={{ confirm, prompt }}>
      {children}

      {/* ── Confirm Dialog ── */}
      {pendingConfirm &&
        createPortal(
          <div className="fixed inset-0 z-[200] flex items-center justify-center p-4" role="dialog" aria-modal="true">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={handleConfirmCancel} />
            <div className="relative w-full max-w-sm bg-background rounded-2xl shadow-2xl border border-border overflow-hidden animate-dialog-in">
              <div className={`h-1.5 w-full ${meta.btnClass}`} style={{ borderRadius: "0.875rem 0.875rem 0 0" }} />

              <div className="px-6 pt-6 pb-2">
                <div className="flex items-start gap-4">
                  <div className={`shrink-0 w-14 h-14 rounded-2xl ${meta.iconBg} flex items-center justify-center ${meta.iconColor}`}>
                    {pendingConfirm.title.toLowerCase().includes("rollback") || pendingConfirm.title.toLowerCase().includes("pulihkan")
                      ? <RotateCcw size={28} />
                      : pendingConfirm.title.toLowerCase().includes("publish") || pendingConfirm.title.toLowerCase().includes("kirim")
                        ? <Globe size={28} />
                        : meta.icon}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h2 id="confirm-title" className="text-base font-bold leading-snug">{pendingConfirm.title}</h2>
                    {message && (
                      <p className="mt-1.5 text-sm text-muted-foreground leading-relaxed">{message}</p>
                    )}
                  </div>
                  <button
                    onClick={handleConfirmCancel}
                    className="shrink-0 w-8 h-8 rounded-lg flex items-center justify-center text-muted-foreground hover:bg-muted transition-colors -mr-1 -mt-1"
                    aria-label="Batal"
                  >
                    <X size={16} />
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 px-6 pb-6 pt-4">
                <button onClick={handleConfirmCancel} className="px-4 py-2 rounded-lg border border-border text-sm font-medium text-muted-foreground hover:bg-muted transition-colors flex items-center gap-1.5">
                  <X size={14} />{pendingConfirm.cancelText ?? "Batal"}
                </button>
                <button onClick={handleConfirmOk} className={`px-5 py-2 rounded-lg text-sm font-bold text-white transition-colors flex items-center gap-1.5 ${meta.btnClass}`}>
                  <Check size={14} />{pendingConfirm.confirmText ?? "Ya, Lanjutkan"}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}

      {/* ── Prompt Dialog ── */}
      {pendingPrompt &&
        createPortal(
          <div className="fixed inset-0 z-[200] flex items-center justify-center p-4" role="dialog" aria-modal="true">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={handlePromptCancel} />
            <div className="relative w-full max-w-sm bg-background rounded-2xl shadow-2xl border border-border overflow-hidden animate-dialog-in">
              <div className="h-1.5 w-full bg-accent" style={{ borderRadius: "0.875rem 0.875rem 0 0" }} />

              <div className="px-6 pt-6 pb-2">
                <div className="flex items-start gap-3">
                  <div className="shrink-0 w-12 h-12 rounded-2xl bg-accent/10 flex items-center justify-center text-accent">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                    </svg>
                  </div>
                  <div className="flex-1 min-w-0">
                    <h2 className="text-base font-bold leading-snug">{pendingPrompt.title}</h2>
                    {pendingPrompt.message && (
                      <p className="mt-1.5 text-sm text-muted-foreground">{pendingPrompt.message}</p>
                    )}
                  </div>
                </div>
              </div>

              <div className="px-6 pb-2">
                <input
                  ref={promptInputRef}
                  autoFocus
                  type="text"
                  className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-accent"
                  placeholder={pendingPrompt.placeholder}
                  defaultValue={pendingPrompt.defaultValue}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") handlePromptOk();
                    if (e.key === "Escape") handlePromptCancel();
                  }}
                />
              </div>

              <div className="flex items-center justify-end gap-2 px-6 pb-6 pt-4">
                <button onClick={handlePromptCancel} className="px-4 py-2 rounded-lg border border-border text-sm font-medium text-muted-foreground hover:bg-muted transition-colors">
                  {(pendingPrompt as any).cancelText ?? "Batal"}
                </button>
                <button onClick={handlePromptOk} className="px-5 py-2 rounded-lg text-sm font-bold bg-accent text-primary hover:bg-accent/90 transition-colors">
                  {(pendingPrompt as any).confirmText ?? "Kirim"}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}
    </DialogContext.Provider>
  );
}

// ─── Hook ─────────────────────────────────────────────────────────────────────

export function useConfirm() {
  const ctx = useContext(DialogContext);
  return ctx.confirm;
}

export function usePrompt() {
  const ctx = useContext(DialogContext);
  return ctx.prompt;
}
