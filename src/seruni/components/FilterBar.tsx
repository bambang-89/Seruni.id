import type { ReactNode } from "react";

const inputCls =
  "w-full border border-current/25 bg-transparent px-3 py-2 text-sm focus:outline-none focus:border-accent";

export function FilterBar({ children, onReset, hasilCount, totalCount }: {
  children: ReactNode;
  onReset?: () => void;
  hasilCount?: number;
  totalCount?: number;
}) {
  return (
    <div className="border border-current/15 bg-background/60 p-5 mb-8">
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">{children}</div>
      {(onReset || hasilCount !== undefined) && (
        <div className="mt-4 pt-4 border-t border-current/10 flex flex-wrap items-center justify-between gap-3 text-xs">
          <span className="opacity-70 tabular-nums">
            {hasilCount !== undefined && totalCount !== undefined
              ? `Menampilkan ${hasilCount} dari ${totalCount}`
              : ""}
          </span>
          {onReset && (
            <button
              type="button"
              onClick={onReset}
              className="font-display text-[10px] font-bold uppercase tracking-[0.28em] border border-current/30 px-3 py-1.5 hover:border-accent hover:text-accent transition-colors"
            >
              Reset filter
            </button>
          )}
        </div>
      )}
    </div>
  );
}

export function FilterField({ label, children }: { label: string; children: ReactNode }) {
  return (
    <label className="block">
      <span className="block font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-1.5">
        {label}
      </span>
      {children}
    </label>
  );
}

export function TextInput({
  value,
  onChange,
  placeholder,
  type = "text",
}: {
  value: string | number;
  onChange: (v: string) => void;
  placeholder?: string;
  type?: string;
}) {
  return (
    <input
      type={type}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      className={inputCls}
    />
  );
}

export function SelectInput({
  value,
  onChange,
  options,
  placeholder = "Semua",
}: {
  value: string;
  onChange: (v: string) => void;
  options: { value: string; label: string }[];
  placeholder?: string;
}) {
  return (
    <select value={value} onChange={(e) => onChange(e.target.value)} className={inputCls}>
      <option value="">{placeholder}</option>
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  );
}

export function OfflineBadge({ show }: { show: boolean }) {
  if (!show) return null;
  return (
    <div className="mb-6 border border-accent/60 bg-accent/10 px-4 py-3 text-xs flex items-center gap-3">
      <span className="inline-block w-2 h-2 bg-accent" aria-hidden />
      <span className="font-display font-semibold uppercase tracking-[0.22em] text-accent">
        Mode offline
      </span>
      <span className="opacity-80">
        Menampilkan data tersimpan di perangkat Anda. Beberapa gambar mungkin belum tersedia.
      </span>
    </div>
  );
}