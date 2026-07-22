import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import { ImageField } from "./AdminPages";
import { invalidatePageConfig } from "../lib/pageConfig";
import { stashPagePreview, stashNavPreview, stashFooterPreview, openPreview } from "../lib/preview";

const inp =
  "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/40";
const btnPri =
  "inline-flex items-center gap-2 rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:opacity-90 disabled:opacity-50";
const btnSec = "inline-flex items-center gap-2 rounded-md border border-input px-3 py-2 text-sm hover:bg-muted";
const btnDanger = "inline-flex items-center gap-2 rounded-md border border-destructive text-destructive px-3 py-2 text-sm hover:bg-destructive hover:text-destructive-foreground";

function Header({ title, sub }: { title: string; sub?: string }) {
  return (
    <div className="mb-6">
      <div className="text-[11px] font-display uppercase tracking-[0.28em] text-accent">Situs Publik</div>
      <h1 className="mt-1 font-display text-2xl sm:text-3xl font-bold">{title}</h1>
      {sub && <p className="text-sm text-muted-foreground mt-2 max-w-2xl">{sub}</p>}
    </div>
  );
}

// =========================================================================
// PAGE CONFIG — per rute publik: hero + judul section
// =========================================================================

type SectionTitle = { key: string; kicker: string; judul: string; deskripsi?: string };
type PageRow = {
  route: string;
  nama: string;
  eyebrow: string;
  judul: string;
  deskripsi: string | null;
  hero_image_url: string | null;
  section_titles: SectionTitle[];
};

export function PageConfigAdmin() {
  const [rows, setRows] = useState<PageRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [selRoute, setSelRoute] = useState<string | null>(null);
  const [draft, setDraft] = useState<PageRow | null>(null);
  const [filter, setFilter] = useState("");

  const reload = async () => {
    setLoading(true);
    const { data } = await (supabase as any).from("page_config").select("*").order("route");
    setRows(((data as any[]) ?? []).map((r) => ({ ...r, section_titles: r.section_titles ?? [] })) as PageRow[]);
    setLoading(false);
  };
  useEffect(() => {
    reload();
  }, []);

  const shown = useMemo(
    () => rows.filter((r) => (r.route + r.nama).toLowerCase().includes(filter.toLowerCase())),
    [rows, filter],
  );

  useEffect(() => {
    if (!selRoute) return setDraft(null);
    const r = rows.find((x) => x.route === selRoute);
    setDraft(r ? { ...r, section_titles: [...r.section_titles] } : null);
  }, [selRoute, rows]);

  const validateTitle = (s: string) => {
    const parts = s.trim().split(/\s+/).filter(Boolean);
    if (parts.length !== 2) return "Judul wajib 2 kata (kata 1 regular + kata 2 italic amber).";
    return null;
  };

  const save = async () => {
    if (!draft) return;
    const err = validateTitle(draft.judul);
    if (err) return toast.error(err);
    for (const s of draft.section_titles) {
      const e = validateTitle(s.judul);
      if (e) return toast.error(`Section "${s.key || "?"}": ${e}`);
    }
    const { error } = await (supabase as any).from("page_config").update({
      eyebrow: draft.eyebrow,
      judul: draft.judul,
      deskripsi: draft.deskripsi,
      hero_image_url: draft.hero_image_url,
      section_titles: draft.section_titles,
    }).eq("route", draft.route);
    if (error) return toast.error(error.message);
    toast.success("Halaman diperbarui.");
    invalidatePageConfig(draft.route);
    reload();
  };

  return (
    <div>
      <Header
        title="Halaman Publik"
        sub="Atur hero (eyebrow, judul, deskripsi, foto) dan judul-judul section untuk setiap rute publik. Judul wajib 2 kata."
      />
      <div className="grid lg:grid-cols-[280px_1fr] gap-6">
        <aside className="bg-card border border-border rounded-xl overflow-hidden">
          <div className="p-3 border-b border-border">
            <input placeholder="Cari rute…" value={filter} onChange={(e) => setFilter(e.target.value)} className={inp} />
          </div>
          <ul className="max-h-[70vh] overflow-y-auto text-sm">
            {loading && <li className="p-4 text-muted-foreground">Memuat…</li>}
            {shown.map((r) => (
              <li key={r.route}>
                <button
                  onClick={() => setSelRoute(r.route)}
                  className={`w-full text-left px-4 py-2.5 border-b border-border/60 hover:bg-muted ${selRoute === r.route ? "bg-muted" : ""}`}
                >
                  <div className="font-medium">{r.nama}</div>
                  <div className="text-[11px] text-muted-foreground font-mono">{r.route}</div>
                </button>
              </li>
            ))}
          </ul>
        </aside>

        <section>
          {!draft ? (
            <div className="bg-card border border-border rounded-xl p-8 text-muted-foreground">
              Pilih halaman dari daftar untuk mulai mengedit.
            </div>
          ) : (
            <div className="space-y-6">
              <div className="bg-card border border-border rounded-xl p-5 space-y-4">
                <div className="text-[11px] uppercase tracking-widest text-muted-foreground font-display">
                  Rute: <span className="font-mono">{draft.route}</span>
                </div>
                <div className="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Eyebrow</label>
                    <input value={draft.eyebrow} onChange={(e) => setDraft({ ...draft, eyebrow: e.target.value })} className={inp} />
                  </div>
                  <div>
                    <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                      Judul Hero (2 kata)
                    </label>
                    <input value={draft.judul} onChange={(e) => setDraft({ ...draft, judul: e.target.value })} className={inp} />
                  </div>
                </div>
                <div>
                  <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Deskripsi</label>
                  <textarea rows={2} value={draft.deskripsi ?? ""} onChange={(e) => setDraft({ ...draft, deskripsi: e.target.value })} className={inp} />
                </div>
                <div>
                  <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Foto Hero</label>
                  <ImageField
                    value={draft.hero_image_url ?? ""}
                    folder={`page-hero${draft.route.replace(/\//g, "-")}`}
                    onChange={(url) => setDraft({ ...draft, hero_image_url: url || null })}
                  />
                </div>
              </div>

              <div className="bg-card border border-border rounded-xl p-5 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-display font-semibold">Judul Section</div>
                    <div className="text-xs text-muted-foreground">Override judul-judul section pada halaman ini. Judul wajib 2 kata.</div>
                  </div>
                  <button
                    className={btnSec}
                    onClick={() =>
                      setDraft({
                        ...draft,
                        section_titles: [...draft.section_titles, { key: "", kicker: "", judul: "", deskripsi: "" }],
                      })
                    }
                  >
                    + Tambah
                  </button>
                </div>
                {draft.section_titles.length === 0 && (
                  <div className="text-sm text-muted-foreground">Belum ada override section.</div>
                )}
                {draft.section_titles.map((s, idx) => (
                  <div key={idx} className="border border-border rounded-md p-3 grid sm:grid-cols-[140px_140px_1fr_auto] gap-3 items-start">
                    <input
                      placeholder="key"
                      value={s.key}
                      onChange={(e) => {
                        const arr = [...draft.section_titles];
                        arr[idx] = { ...s, key: e.target.value };
                        setDraft({ ...draft, section_titles: arr });
                      }}
                      className={inp}
                    />
                    <input
                      placeholder="kicker"
                      value={s.kicker}
                      onChange={(e) => {
                        const arr = [...draft.section_titles];
                        arr[idx] = { ...s, kicker: e.target.value };
                        setDraft({ ...draft, section_titles: arr });
                      }}
                      className={inp}
                    />
                    <div className="space-y-2">
                      <input
                        placeholder="Judul (2 kata)"
                        value={s.judul}
                        onChange={(e) => {
                          const arr = [...draft.section_titles];
                          arr[idx] = { ...s, judul: e.target.value };
                          setDraft({ ...draft, section_titles: arr });
                        }}
                        className={inp}
                      />
                      <textarea
                        rows={1}
                        placeholder="Deskripsi (opsional)"
                        value={s.deskripsi ?? ""}
                        onChange={(e) => {
                          const arr = [...draft.section_titles];
                          arr[idx] = { ...s, deskripsi: e.target.value };
                          setDraft({ ...draft, section_titles: arr });
                        }}
                        className={inp}
                      />
                    </div>
                    <button
                      className={btnDanger}
                      onClick={() => {
                        const arr = draft.section_titles.filter((_, i) => i !== idx);
                        setDraft({ ...draft, section_titles: arr });
                      }}
                    >
                      Hapus
                    </button>
                  </div>
                ))}
              </div>

              <div className="flex gap-2">
                <button onClick={save} className={btnPri}>Simpan Perubahan</button>
                <button
                  onClick={() => {
                    const err = validateTitle(draft.judul);
                    if (err) return toast.error(err);
                    stashPagePreview(draft.route, draft);
                    toast.success("Draft dimuat ke pratinjau.");
                    openPreview(draft.route);
                  }}
                  className={btnSec}
                  title="Buka rute publik di tab baru dengan perubahan yang belum disimpan"
                >
                  Pratinjau di Frontend
                </button>
                <button
                  onClick={() => {
                    const r = rows.find((x) => x.route === draft.route);
                    setDraft(r ? { ...r, section_titles: [...r.section_titles] } : null);
                  }}
                  className={btnSec}
                >
                  Reset
                </button>
              </div>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

// =========================================================================
// NAV ITEMS
// =========================================================================

type NavRow = {
  id: string;
  parent_id: string | null;
  label: string;
  href: string;
  deskripsi: string | null;
  urutan: number;
  aktif: boolean;
};

export function NavAdmin() {
  const [rows, setRows] = useState<NavRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<Partial<NavRow> | null>(null);

  const reload = async () => {
    setLoading(true);
    const { data } = await (supabase as any).from("nav_item").select("*").order("parent_id").order("urutan");
    setRows(((data as any[]) ?? []) as NavRow[]);
    setLoading(false);
  };
  useEffect(() => {
    reload();
  }, []);

  const parents = rows.filter((r) => !r.parent_id).sort((a, b) => a.urutan - b.urutan);
  const childrenOf = (id: string) => rows.filter((r) => r.parent_id === id).sort((a, b) => a.urutan - b.urutan);

  const save = async () => {
    if (!draft || !draft.label || !draft.href) return toast.error("Label & href wajib diisi.");
    const payload = {
      parent_id: draft.parent_id ?? null,
      label: draft.label,
      href: draft.href,
      deskripsi: draft.deskripsi ?? null,
      urutan: draft.urutan ?? 0,
      aktif: draft.aktif ?? true,
    };
    const q = draft.id
      ? (supabase as any).from("nav_item").update(payload).eq("id", draft.id)
      : (supabase as any).from("nav_item").insert(payload);
    const { error } = await q;
    if (error) return toast.error(error.message);
    toast.success("Menu tersimpan.");
    setDraft(null);
    reload();
  };
  const del = async (id: string) => {
    if (!confirm("Hapus menu ini? Submenu di bawahnya juga akan terhapus.")) return;
    const { error } = await (supabase as any).from("nav_item").delete().eq("id", id);
    if (error) return toast.error(error.message);
    reload();
  };

  return (
    <div>
      <Header title="Menu Navbar" sub="Kelola menu utama dan submenu navbar publik. Aturan: 1 kata per label." />
      <div className="mb-4 flex gap-2">
        <button
          className={btnPri}
          onClick={() => setDraft({ label: "", href: "/", parent_id: null, urutan: parents.length + 1, aktif: true })}
        >
          + Menu Utama
        </button>
        <button
          className={btnSec}
          onClick={() => {
            // Preview live table (current snapshot including any unsaved draft merged in)
            let preview: NavRow[] = rows.filter((r) => r.aktif);
            if (draft && draft.label && draft.href) {
              const merged = { ...draft, id: draft.id ?? `preview-${Date.now()}` } as NavRow;
              preview = draft.id ? preview.map((r) => (r.id === draft.id ? merged : r)) : [...preview, merged];
            }
            stashNavPreview(preview);
            toast.success("Snapshot menu dimuat ke pratinjau.");
            openPreview("/");
          }}
        >
          Pratinjau di Frontend
        </button>
      </div>

      {draft && (
        <div className="mb-6 bg-card border border-border rounded-xl p-5 space-y-3">
          <div className="text-xs uppercase tracking-widest text-accent font-display">
            {draft.id ? "Edit" : "Baru"} · {draft.parent_id ? "Submenu" : "Menu utama"}
          </div>
          <div className="grid sm:grid-cols-2 gap-3">
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Parent</label>
              <select
                value={draft.parent_id ?? ""}
                onChange={(e) => setDraft({ ...draft, parent_id: e.target.value || null })}
                className={inp}
              >
                <option value="">— (menu utama) —</option>
                {parents.map((p) => (
                  <option key={p.id} value={p.id}>{p.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Urutan</label>
              <input
                type="number"
                value={draft.urutan ?? 0}
                onChange={(e) => setDraft({ ...draft, urutan: Number(e.target.value) })}
                className={inp}
              />
            </div>
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Label (1 kata)</label>
              <input value={draft.label ?? ""} onChange={(e) => setDraft({ ...draft, label: e.target.value })} className={inp} />
            </div>
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Href</label>
              <input value={draft.href ?? ""} onChange={(e) => setDraft({ ...draft, href: e.target.value })} className={inp} />
            </div>
            <div className="sm:col-span-2">
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Deskripsi submenu (opsional)</label>
              <input value={draft.deskripsi ?? ""} onChange={(e) => setDraft({ ...draft, deskripsi: e.target.value })} className={inp} />
            </div>
            <label className="inline-flex items-center gap-2 text-sm">
              <input type="checkbox" checked={draft.aktif ?? true} onChange={(e) => setDraft({ ...draft, aktif: e.target.checked })} />
              Aktif
            </label>
          </div>
          <div className="flex gap-2">
            <button onClick={save} className={btnPri}>Simpan</button>
            <button onClick={() => setDraft(null)} className={btnSec}>Batal</button>
          </div>
        </div>
      )}

      <div className="bg-card border border-border rounded-xl divide-y divide-border">
        {loading && <div className="p-6 text-muted-foreground">Memuat…</div>}
        {parents.map((p) => (
          <div key={p.id} className="p-4">
            <div className="flex items-center justify-between gap-4">
              <div>
                <div className="font-display font-semibold">{p.label} <span className="text-xs text-muted-foreground font-mono ml-2">{p.href}</span></div>
                <div className="text-xs text-muted-foreground">Urutan {p.urutan} · {p.aktif ? "aktif" : "nonaktif"}</div>
              </div>
              <div className="flex gap-2 shrink-0">
                <button className={btnSec} onClick={() => setDraft({ label: "", href: "/", parent_id: p.id, urutan: childrenOf(p.id).length + 1, aktif: true })}>+ Sub</button>
                <button className={btnSec} onClick={() => setDraft(p)}>Edit</button>
                <button className={btnDanger} onClick={() => del(p.id)}>Hapus</button>
              </div>
            </div>
            {childrenOf(p.id).length > 0 && (
              <ul className="mt-3 pl-4 border-l border-border space-y-1.5">
                {childrenOf(p.id).map((c) => (
                  <li key={c.id} className="flex items-center justify-between gap-4 py-1.5">
                    <div>
                      <div className="text-sm font-medium">{c.label} <span className="text-xs text-muted-foreground font-mono ml-2">{c.href}</span></div>
                      {c.deskripsi && <div className="text-xs text-muted-foreground">{c.deskripsi}</div>}
                    </div>
                    <div className="flex gap-2 shrink-0">
                      <button className={btnSec} onClick={() => setDraft(c)}>Edit</button>
                      <button className={btnDanger} onClick={() => del(c.id)}>Hapus</button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

// =========================================================================
// FOOTER COLUMNS
// =========================================================================

type FooterRow = {
  id: string;
  judul: string;
  urutan: number;
  aktif: boolean;
  links: { label: string; href: string }[];
};

export function FooterAdmin() {
  const [rows, setRows] = useState<FooterRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<FooterRow | null>(null);

  const reload = async () => {
    setLoading(true);
    const { data } = await (supabase as any).from("footer_column").select("*").order("urutan");
    setRows(((data as any[]) ?? []).map((r) => ({ ...r, links: r.links ?? [] })) as FooterRow[]);
    setLoading(false);
  };
  useEffect(() => {
    reload();
  }, []);

  const save = async () => {
    if (!draft) return;
    if (!draft.judul.trim()) return toast.error("Judul kolom wajib diisi.");
    const payload = { judul: draft.judul, urutan: draft.urutan, aktif: draft.aktif, links: draft.links };
    const q = draft.id
      ? (supabase as any).from("footer_column").update(payload).eq("id", draft.id)
      : (supabase as any).from("footer_column").insert(payload);
    const { error } = await q;
    if (error) return toast.error(error.message);
    toast.success("Kolom footer tersimpan.");
    setDraft(null);
    reload();
  };
  const del = async (id: string) => {
    if (!confirm("Hapus kolom footer ini?")) return;
    const { error } = await (supabase as any).from("footer_column").delete().eq("id", id);
    if (error) return toast.error(error.message);
    reload();
  };

  return (
    <div>
      <Header title="Kolom Footer" sub="Atur kolom-kolom pada footer publik dan daftar tautannya." />
      <div className="mb-4 flex gap-2">
        <button
          className={btnPri}
          onClick={() =>
            setDraft({ id: "", judul: "", urutan: rows.length + 1, aktif: true, links: [{ label: "", href: "" }] })
          }
        >
          + Kolom Baru
        </button>
        <button
          className={btnSec}
          onClick={() => {
            let preview: FooterRow[] = rows.filter((r) => r.aktif);
            if (draft && draft.judul) {
              const merged = { ...draft, id: draft.id || `preview-${Date.now()}` } as FooterRow;
              preview = draft.id ? preview.map((r) => (r.id === draft.id ? merged : r)) : [...preview, merged];
            }
            stashFooterPreview(preview);
            toast.success("Snapshot footer dimuat ke pratinjau.");
            openPreview("/");
          }}
        >
          Pratinjau di Frontend
        </button>
      </div>

      {draft && (
        <div className="mb-6 bg-card border border-border rounded-xl p-5 space-y-3">
          <div className="grid sm:grid-cols-[1fr_100px_auto] gap-3 items-end">
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Judul Kolom</label>
              <input value={draft.judul} onChange={(e) => setDraft({ ...draft, judul: e.target.value })} className={inp} />
            </div>
            <div>
              <label className="text-xs uppercase tracking-wider text-muted-foreground">Urutan</label>
              <input type="number" value={draft.urutan} onChange={(e) => setDraft({ ...draft, urutan: Number(e.target.value) })} className={inp} />
            </div>
            <label className="inline-flex items-center gap-2 text-sm pb-2">
              <input type="checkbox" checked={draft.aktif} onChange={(e) => setDraft({ ...draft, aktif: e.target.checked })} />
              Aktif
            </label>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <div className="text-xs uppercase tracking-wider text-muted-foreground">Tautan</div>
              <button
                className={btnSec}
                onClick={() => setDraft({ ...draft, links: [...draft.links, { label: "", href: "" }] })}
              >
                + Tautan
              </button>
            </div>
            {draft.links.map((l, i) => (
              <div key={i} className="grid sm:grid-cols-[1fr_2fr_auto] gap-2">
                <input
                  placeholder="Label"
                  value={l.label}
                  onChange={(e) => {
                    const arr = [...draft.links];
                    arr[i] = { ...l, label: e.target.value };
                    setDraft({ ...draft, links: arr });
                  }}
                  className={inp}
                />
                <input
                  placeholder="/href atau https://…"
                  value={l.href}
                  onChange={(e) => {
                    const arr = [...draft.links];
                    arr[i] = { ...l, href: e.target.value };
                    setDraft({ ...draft, links: arr });
                  }}
                  className={inp}
                />
                <button
                  className={btnDanger}
                  onClick={() => setDraft({ ...draft, links: draft.links.filter((_, x) => x !== i) })}
                >
                  Hapus
                </button>
              </div>
            ))}
          </div>

          <div className="flex gap-2">
            <button onClick={save} className={btnPri}>Simpan</button>
            <button onClick={() => setDraft(null)} className={btnSec}>Batal</button>
          </div>
        </div>
      )}

      <div className="bg-card border border-border rounded-xl divide-y divide-border">
        {loading && <div className="p-6 text-muted-foreground">Memuat…</div>}
        {rows.map((r) => (
          <div key={r.id} className="p-4">
            <div className="flex items-center justify-between gap-4">
              <div>
                <div className="font-display font-semibold">{r.judul}</div>
                <div className="text-xs text-muted-foreground">Urutan {r.urutan} · {r.aktif ? "aktif" : "nonaktif"} · {r.links.length} tautan</div>
              </div>
              <div className="flex gap-2 shrink-0">
                <button className={btnSec} onClick={() => setDraft({ ...r, links: [...r.links] })}>Edit</button>
                <button className={btnDanger} onClick={() => del(r.id)}>Hapus</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// =========================================================================
// DRAFT QUEUE — Workflow: draft → review → approved → published
// =========================================================================

type DraftQueueRow = {
  id: string;
  tenant_id: string | null;
  entitas: string;
  entitas_id: string | null;
  action: string;
  payload: Record<string, unknown>;
  status: string;
  catatan: string | null;
  actor_id: string | null;
  actor_nama: string | null;
  reviewer_id: string | null;
  reviewer_nama: string | null;
  reviewed_at: string | null;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  status_label: string;
};

export function DraftQueueAdmin() {
  const [rows, setRows] = useState<DraftQueueRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>("all");

  const reload = async () => {
    setLoading(true);
    const { data } = await (supabase as any)
      .from("draft_queue")
      .select("*")
      .order("updated_at", { ascending: false })
      .limit(50);
    setRows((data ?? []) as DraftQueueRow[]);
    setLoading(false);
  };

  useEffect(() => {
    reload();
  }, []);

  const filteredRows = filter === "all"
    ? rows
    : rows.filter((r) => r.status === filter);

  const pendingCount = rows.filter((r) => r.status === "review").length;

  const submitForReview = async (id: string) => {
    const { error } = await (supabase as any)
      .rpc("submit_draft_for_review", { _draft_id: id });
    if (error) return toast.error(error.message);
    toast.success("Draft diajukan untuk review.");
    reload();
  };

  const approve = async (id: string) => {
    const { error } = await (supabase as any)
      .rpc("approve_draft", { _draft_id: id });
    if (error) return toast.error(error.message);
    toast.success("Draft disetujui!");
    reload();
  };

  const reject = async (id: string) => {
    const catatan = prompt("Alasan penolakan:");
    if (!catatan) return;
    const { error } = await (supabase as any)
      .rpc("reject_draft", { _draft_id: id, _catatan: catatan });
    if (error) return toast.error(error.message);
    toast.success("Draft ditolak.");
    reload();
  };

  const publish = async (id: string) => {
    if (!confirm("Publish draft ini ke live site?")) return;
    const { error } = await (supabase as any)
      .rpc("publish_site_draft", { _draft_id: id });
    if (error) return toast.error(error.message);
    toast.success("Draft dipublish!");
    reload();
  };

  const rollback = async (id: string) => {
    if (!confirm("Rollback perubahan ini?")) return;
    const { error } = await (supabase as any)
      .rpc("rollback_site_draft", { _draft_id: id });
    if (error) return toast.error(error.message);
    toast.success("Di-rollback ke versi sebelumnya.");
    reload();
  };

  const getStatusBadge = (status: string) => {
    const styles: Record<string, string> = {
      draft: "bg-gray-100 text-gray-700",
      review: "bg-yellow-100 text-yellow-800",
      approved: "bg-blue-100 text-blue-800",
      published: "bg-green-100 text-green-800",
      rejected: "bg-red-100 text-red-800",
      rolled_back: "bg-purple-100 text-purple-800",
    };
    return (
      <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${styles[status] || "bg-gray-100"}`}>
        {status}
      </span>
    );
  };

  const getActionBadge = (action: string) => {
    const styles: Record<string, string> = {
      create: "bg-green-50 text-green-700",
      update: "bg-blue-50 text-blue-700",
      delete: "bg-red-50 text-red-700",
    };
    return (
      <span className={`px-2 py-0.5 rounded text-xs font-medium ${styles[action] || ""}`}>
        {action}
      </span>
    );
  };

  return (
    <div>
      <Header
        title="Draft Queue"
        sub="Workflow: Draft → Review → Approved → Published. Semua perubahan konten harus melalui proses review."
      />

      {pendingCount > 0 && (
        <div className="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded-xl">
          <div className="flex items-center gap-2 text-yellow-800">
            <span className="text-lg">👀</span>
            <span className="font-medium">{pendingCount} draft menunggu review</span>
          </div>
        </div>
      )}

      <div className="mb-4 flex gap-2 flex-wrap">
        {["all", "review", "approved", "published", "draft", "rejected"].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-3 py-1.5 rounded-md text-sm ${
              filter === f
                ? "bg-primary text-primary-foreground"
                : "bg-card border border-border hover:bg-muted"
            }`}
          >
            {f === "all" ? "Semua" : f.charAt(0).toUpperCase() + f.slice(1)}
            {f !== "all" && rows.filter((r) => r.status === f).length > 0 && (
              <span className="ml-1.5 px-1.5 py-0.5 bg-white/20 rounded text-xs">
                {rows.filter((r) => r.status === f).length}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-muted-foreground">Memuat…</div>
        ) : filteredRows.length === 0 ? (
          <div className="p-8 text-center text-muted-foreground">Tidak ada draft</div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-muted/50 border-b border-border">
              <tr>
                <th className="px-4 py-3 text-left font-medium">Status</th>
                <th className="px-4 py-3 text-left font-medium">Entitas</th>
                <th className="px-4 py-3 text-left font-medium">Aksi</th>
                <th className="px-4 py-3 text-left font-medium">Pembuat</th>
                <th className="px-4 py-3 text-left font-medium">Catatan</th>
                <th className="px-4 py-3 text-left font-medium">Updated</th>
                <th className="px-4 py-3 text-right font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {filteredRows.map((row) => (
                <tr key={row.id} className="hover:bg-muted/30">
                  <td className="px-4 py-3">{getStatusBadge(row.status)}</td>
                  <td className="px-4 py-3">
                    <div className="font-medium capitalize">{row.entitas.replace(/_/g, " ")}</div>
                    {row.entitas_id && (
                      <div className="text-xs text-muted-foreground font-mono">
                        {row.entitas_id.slice(0, 8)}…
                      </div>
                    )}
                  </td>
                  <td className="px-4 py-3">{getActionBadge(row.action)}</td>
                  <td className="px-4 py-3">
                    <div>{row.actor_nama || "System"}</div>
                    <div className="text-xs text-muted-foreground">
                      {new Date(row.created_at).toLocaleDateString("id-ID")}
                    </div>
                  </td>
                  <td className="px-4 py-3 max-w-[200px]">
                    <div className="truncate text-xs">{row.catatan || "—"}</div>
                  </td>
                  <td className="px-4 py-3 text-xs text-muted-foreground">
                    {new Date(row.updated_at).toLocaleString("id-ID", {
                      day: "2-digit",
                      month: "short",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex gap-1 justify-end">
                      {row.status === "draft" && (
                        <button
                          onClick={() => submitForReview(row.id)}
                          className="px-2 py-1 text-xs bg-blue-50 text-blue-700 rounded hover:bg-blue-100"
                        >
                          Ajukan
                        </button>
                      )}
                      {row.status === "review" && (
                        <>
                          <button
                            onClick={() => approve(row.id)}
                            className="px-2 py-1 text-xs bg-green-50 text-green-700 rounded hover:bg-green-100"
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => reject(row.id)}
                            className="px-2 py-1 text-xs bg-red-50 text-red-700 rounded hover:bg-red-100"
                          >
                            Tolak
                          </button>
                        </>
                      )}
                      {row.status === "approved" && (
                        <button
                          onClick={() => publish(row.id)}
                          className="px-2 py-1 text-xs bg-primary text-primary-foreground rounded hover:opacity-90"
                        >
                          Publish
                        </button>
                      )}
                      {row.status === "published" && (
                        <button
                          onClick={() => rollback(row.id)}
                          className="px-2 py-1 text-xs bg-purple-50 text-purple-700 rounded hover:bg-purple-100"
                        >
                          Rollback
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

// =========================================================================
// VERSION HISTORY
// =========================================================================

type VersionRow = {
  id: string;
  entitas: string;
  entitas_id: string;
  versi: number;
  snapshot: Record<string, unknown>;
  note: string | null;
  actor_id: string | null;
  created_at: string;
};

export function VersionHistoryAdmin() {
  const [rows, setRows] = useState<VersionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>("");

  const reload = async () => {
    setLoading(true);
    const { data } = await (supabase as any)
      .from("site_version")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(100);
    setRows((data ?? []) as VersionRow[]);
    setLoading(false);
  };

  useEffect(() => {
    reload();
  }, []);

  const filteredRows = filter
    ? rows.filter((r) => r.entitas === filter)
    : rows;

  const restore = async (versionId: string) => {
    if (!confirm("Pulihkan versi ini?")) return;
    const { error } = await (supabase as any)
      .rpc("restore_site_version", { _version_id: versionId });
    if (error) return toast.error(error.message);
    toast.success("Versi dipulihkan.");
    reload();
  };

  return (
    <div>
      <Header
        title="Riwayat Versi"
        sub="Lihat dan pulihkan versi sebelumnya dari page_config, nav, dan footer."
      />

      <div className="mb-4 flex gap-2">
        {["", "page_config", "nav_item", "footer_column"].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-3 py-1.5 rounded-md text-sm ${
              filter === f
                ? "bg-primary text-primary-foreground"
                : "bg-card border border-border hover:bg-muted"
            }`}
          >
            {f ? f.replace(/_/g, " ") : "Semua"}
          </button>
        ))}
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-muted-foreground">Memuat…</div>
        ) : (
          <div className="divide-y divide-border">
            {filteredRows.map((row) => (
              <div key={row.id} className="p-4 flex items-start justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-medium capitalize">{row.entitas.replace(/_/g, " ")}</span>
                    <span className="px-2 py-0.5 bg-muted rounded text-xs">v{row.versi}</span>
                    <span className="text-xs text-muted-foreground">{row.note || "update"}</span>
                  </div>
                  <div className="text-xs text-muted-foreground mt-1">
                    {new Date(row.created_at).toLocaleString("id-ID")}
                  </div>
                  {row.snapshot && (
                    <details className="mt-2">
                      <summary className="text-xs text-accent cursor-pointer">Lihat snapshot</summary>
                      <pre className="mt-1 p-2 bg-muted rounded text-xs overflow-auto max-w-lg">
                        {JSON.stringify(row.snapshot, null, 2).slice(0, 300)}…
                      </pre>
                    </details>
                  )}
                </div>
                <button
                  onClick={() => restore(row.id)}
                  className="btnSec text-xs shrink-0"
                >
                  Pulihkan
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
