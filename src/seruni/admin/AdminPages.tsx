import { useEffect, useState, useRef, type ReactNode } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "../lib/auth";
import { useTenantId } from "../lib/tenant";
import { Link } from "react-router-dom";
import { uploadFile } from "../lib/upload";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";

export function PageTitle({ title, desc }: { title: string; desc?: string }) {
  return (
    <div className="mb-6">
      <h1 className="font-display text-2xl font-bold text-foreground">{title}</h1>
      {desc && <p className="text-sm text-muted-foreground mt-1">{desc}</p>}
    </div>
  );
}

const btnPri = "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60";
const btnSec = "rounded-md border border-border bg-background px-3 py-1.5 text-sm hover:bg-muted";
const btnDanger = "rounded-md border border-destructive/40 text-destructive bg-background px-3 py-1.5 text-sm hover:bg-destructive/10";
const inp = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary";

// ============ Reusable Input Components with proper autocomplete ============
function FInput({
  label,
  value,
  onChange,
  type = "text",
  step,
  placeholder,
  autoComplete,
  className = "",
  required,
  readOnly,
}: {
  label?: string;
  value: string | number;
  onChange: (v: string) => void;
  type?: "text" | "number" | "date" | "email" | "tel";
  step?: string;
  placeholder?: string;
  autoComplete?: string;
  className?: string;
  required?: boolean;
  readOnly?: boolean;
}) {
  const cls = `w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary ${className}`;
  return (
    <label className="block text-xs font-medium mb-1">
      {label && <span className="block mb-1 font-medium">{label}{required ? " *" : ""}</span>}
      <input
        type={type}
        step={step}
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        autoComplete={autoComplete ?? "off"}
        className={cls}
        required={required}
        readOnly={readOnly}
      />
    </label>
  );
}

function FSelect({
  label,
  value,
  onChange,
  options,
  placeholder = "— pilih —",
  autoComplete,
  className = "",
  required,
}: {
  label?: string;
  value: string;
  onChange: (v: string) => void;
  options: { value: string; label: string }[];
  placeholder?: string;
  autoComplete?: string;
  className?: string;
  required?: boolean;
}) {
  return (
    <label className="block text-xs font-medium mb-1">
      {label && <span className="block mb-1 font-medium">{label}{required ? " *" : ""}</span>}
      <select
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        autoComplete={autoComplete ?? "off"}
        className={`w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary ${className}`}
        required={required}
      >
        <option value="">{placeholder}</option>
        {options.map((o) => (
          <option key={o.value} value={o.value}>{o.label}</option>
        ))}
      </select>
    </label>
  );
}

function FTextarea({
  label,
  value,
  onChange,
  placeholder,
  rows = 3,
  className = "",
}: {
  label?: string;
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  rows?: number;
  className?: string;
}) {
  return (
    <label className="block text-xs font-medium mb-1">
      {label && <span className="block mb-1 font-medium">{label}</span>}
      <textarea
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        rows={rows}
        autoComplete="off"
        className={`w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary ${className}`}
      />
    </label>
  );
}
const inpAuto = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary autocomplete-[off]";

// ============ Dashboard ============
export function AdminDashboard() {
  const { user } = useAuth();
  const [profile, setProfile] = useState<{ nama: string; nik: string } | null>(null);
  const [loading, setLoading] = useState(true);
  const [kpi, setKpi] = useState({
    pamong: 0, dusun: 0, lembaga: 0,
    berita: 0, agenda: 0, pengumuman: 0,
    aduanTotal: 0, aduanBaru: 0, aduanSelesai: 0,
    suratTerbit: 0, umkm: 0, wisata: 0,
    pbbTotal: 0, pbbLunas: 0, pbbNominal: 0,
  });
  const [aduanByKategori, setAduanByKategori] = useState<{ name: string; value: number }[]>([]);
  const [apbdesBidang, setApbdesBidang] = useState<{ name: string; anggaran: number; realisasi: number }[]>([]);
  const [recentEvents, setRecentEvents] = useState<any[]>([]);
  const currentYear = new Date().getFullYear();

  useEffect(() => {
    if (!user) return;
    supabase.from("admin_profiles").select("nama,nik").eq("id", user.id).maybeSingle()
      .then(({ data }) => data && setProfile(data as any));

    (async () => {
      const head = (t: string, filters?: (q: any) => any) => {
        let q: any = (supabase.from(t as any) as any).select("*", { count: "exact", head: true });
        if (filters) q = filters(q);
        return q;
      };
      const [
        pamong, dusun, lembaga,
        berita, agenda, pengumuman,
        aduanTotal, aduanBaru, aduanSelesai,
        suratTerbit, umkm, wisata,
        pbbAll, pbbLunas, pbbSumRes,
        aduanRows, apbdesRows, events,
      ] = await Promise.all([
        head("desa_pamong"),
        head("wilayah_dusun"),
        head("lembaga_desa"),
        head("berita"),
        head("agenda"),
        head("pengumuman"),
        head("aduan_warga"),
        head("aduan_warga", (q) => q.eq("status", "diajukan")),
        head("aduan_warga", (q) => q.eq("status", "selesai")),
        head("surat_terbit"),
        head("potensi_umkm"),
        head("potensi_wisata"),
        head("pbb_tagihan", (q) => q.eq("tahun", currentYear)),
        head("pbb_tagihan", (q) => q.eq("tahun", currentYear).eq("status_bayar", "lunas")),
        (supabase.from("pbb_tagihan" as any) as any).select("pbb_terutang").eq("tahun", currentYear).eq("status_bayar", "lunas"),
        (supabase.from("aduan_warga" as any) as any).select("kategori"),
        (supabase.from("apbdes" as any) as any).select("kategori,anggaran,realisasi,jenis").eq("tahun", currentYear).eq("jenis", "belanja"),
        (supabase.from("event_log" as any) as any).select("event_name,entitas,created_at").order("created_at", { ascending: false }).limit(8),
      ]);

      const pbbNominal = ((pbbSumRes.data as any[]) || []).reduce((a, r) => a + Number(r.pbb_terutang || 0), 0);

      setKpi({
        pamong: pamong.count ?? 0,
        dusun: dusun.count ?? 0,
        lembaga: lembaga.count ?? 0,
        berita: berita.count ?? 0,
        agenda: agenda.count ?? 0,
        pengumuman: pengumuman.count ?? 0,
        aduanTotal: aduanTotal.count ?? 0,
        aduanBaru: aduanBaru.count ?? 0,
        aduanSelesai: aduanSelesai.count ?? 0,
        suratTerbit: suratTerbit.count ?? 0,
        umkm: umkm.count ?? 0,
        wisata: wisata.count ?? 0,
        pbbTotal: pbbAll.count ?? 0,
        pbbLunas: pbbLunas.count ?? 0,
        pbbNominal,
      });

      const kMap = new Map<string, number>();
      ((aduanRows.data as any[]) || []).forEach((r) => kMap.set(r.kategori, (kMap.get(r.kategori) || 0) + 1));
      setAduanByKategori(Array.from(kMap.entries()).map(([name, value]) => ({ name, value })));

      const bMap = new Map<string, { anggaran: number; realisasi: number }>();
      ((apbdesRows.data as any[]) || []).forEach((r) => {
        const cur = bMap.get(r.kategori) || { anggaran: 0, realisasi: 0 };
        cur.anggaran += Number(r.anggaran || 0);
        cur.realisasi += Number(r.realisasi || 0);
        bMap.set(r.kategori, cur);
      });
      setApbdesBidang(
        Array.from(bMap.entries()).map(([name, v]) => ({
          name: name.replace(/^Bidang \d+ — /, ""),
          ...v,
        })),
      );

      setRecentEvents((events.data as any[]) || []);
      setLoading(false);
    })();
  }, [user, currentYear]);

  const KPI = ({ label, val, hint, to }: { label: string; val: string | number; hint?: string; to?: string }) => {
    const body = (
      <>
        <div className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{label}</div>
        <div className="mt-2 font-display text-3xl font-bold text-primary tabular-nums leading-none">{val}</div>
        {hint && <div className="mt-2 text-xs text-muted-foreground">{hint}</div>}
      </>
    );
    return to ? (
      <Link to={to} className="block bg-card border border-border p-5 hover:border-primary transition-colors">{body}</Link>
    ) : (
      <div className="bg-card border border-border p-5">{body}</div>
    );
  };

  const rupiahShort = (n: number) => {
    if (n >= 1_000_000_000) return `Rp ${(n / 1_000_000_000).toFixed(2)} M`;
    if (n >= 1_000_000) return `Rp ${(n / 1_000_000).toFixed(1)} Jt`;
    return `Rp ${n.toLocaleString("id-ID")}`;
  };

  const PIE_COLORS = ["#015967", "#FF9E20", "#0d7a8a", "#c97a12", "#33a3b3", "#a1560b"];

  return (
    <>
      <PageTitle title={`Selamat datang, ${profile?.nama || "Admin"}`} desc={`Panel analitik operasional desa · ${currentYear}`} />

      {loading ? (
        <p className="text-sm text-muted-foreground">Memuat metrik…</p>
      ) : (
        <>
          {/* KPI Warga & Layanan */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <KPI label="Aduan Baru" val={kpi.aduanBaru} hint={`Total ${kpi.aduanTotal} · Selesai ${kpi.aduanSelesai}`} to="/admin/aduan" />
            <KPI label="Surat Terbit" val={kpi.suratTerbit} to="/admin/surat-terbit" />
            <KPI label="PBB Lunas" val={`${kpi.pbbLunas}/${kpi.pbbTotal}`} hint={rupiahShort(kpi.pbbNominal) + " terkumpul"} to="/admin/pbb" />
            <KPI label="Konten Terbit" val={kpi.berita + kpi.pengumuman} hint={`${kpi.berita} berita · ${kpi.pengumuman} pengumuman`} to="/admin/berita" />
          </div>

          {/* KPI Fondasi */}
          <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
            <KPI label="Perangkat Desa" val={kpi.pamong} to="/admin/struktur" />
            <KPI label="Dusun" val={kpi.dusun} to="/admin/wilayah" />
            <KPI label="Lembaga" val={kpi.lembaga} to="/admin/lembaga" />
            <KPI label="UMKM & Wisata" val={kpi.umkm + kpi.wisata} hint={`${kpi.umkm} UMKM · ${kpi.wisata} destinasi`} to="/admin/umkm" />
          </div>

          {/* Chart row */}
          <div className="mt-8 grid lg:grid-cols-2 gap-4">
            <section className="bg-card border border-border p-5">
              <div className="flex items-baseline justify-between mb-4">
                <h2 className="font-display font-semibold">Serapan APBDes {currentYear}</h2>
                <Link to="/admin/apbdes" className="text-xs text-primary hover:underline">Kelola →</Link>
              </div>
              {apbdesBidang.length === 0 ? (
                <p className="text-sm text-muted-foreground">Belum ada data APBDes.</p>
              ) : (
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart data={apbdesBidang} margin={{ top: 5, right: 8, left: 0, bottom: 40 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                    <XAxis dataKey="name" tick={{ fontSize: 10 }} angle={-20} textAnchor="end" interval={0} height={60} />
                    <YAxis tick={{ fontSize: 10 }} tickFormatter={(v) => `${(v / 1_000_000).toFixed(0)}jt`} />
                    <Tooltip formatter={(v: any) => rupiahShort(Number(v))} />
                    <Legend wrapperStyle={{ fontSize: 11 }} />
                    <Bar dataKey="anggaran" fill="#015967" name="Anggaran" />
                    <Bar dataKey="realisasi" fill="#FF9E20" name="Realisasi" />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </section>

            <section className="bg-card border border-border p-5">
              <div className="flex items-baseline justify-between mb-4">
                <h2 className="font-display font-semibold">Aduan per Kategori</h2>
                <Link to="/admin/aduan" className="text-xs text-primary hover:underline">Kelola →</Link>
              </div>
              {aduanByKategori.length === 0 ? (
                <p className="text-sm text-muted-foreground">Belum ada aduan.</p>
              ) : (
                <ResponsiveContainer width="100%" height={260}>
                  <PieChart>
                    <Pie data={aduanByKategori} dataKey="value" nameKey="name" outerRadius={90} label={{ fontSize: 10 }}>
                      {aduanByKategori.map((_, i) => (
                        <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                    <Legend wrapperStyle={{ fontSize: 11 }} />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </section>
          </div>

          {/* Recent activity */}
          <section className="mt-8 bg-card border border-border p-5">
            <div className="flex items-baseline justify-between mb-4">
              <h2 className="font-display font-semibold">Aktivitas Terbaru</h2>
              <Link to="/admin/event-log" className="text-xs text-primary hover:underline">Lihat Semua →</Link>
            </div>
            {recentEvents.length === 0 ? (
              <p className="text-sm text-muted-foreground">Belum ada aktivitas.</p>
            ) : (
              <ul className="divide-y divide-border">
                {recentEvents.map((e, i) => (
                  <li key={i} className="py-2.5 flex items-baseline justify-between gap-4 text-sm">
                    <div>
                      <span className="font-mono text-xs text-primary">{e.event_name}</span>
                      <span className="ml-2 text-muted-foreground text-xs">{e.entitas}</span>
                    </div>
                    <time className="text-xs text-muted-foreground tabular-nums whitespace-nowrap">
                      {new Date(e.created_at).toLocaleString("id-ID")}
                    </time>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </>
      )}
    </>
  );
}

// ============ Profil Desa ============
export function ProfilDesaAdmin() {
  const [visi, setVisi] = useState("");
  const [misi, setMisi] = useState<string[]>([""]);
  const [sejarah, setSejarah] = useState<string[]>([""]);
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const tenantId = useTenantId();

  useEffect(() => {
    supabase.from("profil_desa").select("*").eq("singleton", true).maybeSingle().then(({ data }) => {
      if (data) {
        setVisi(data.visi);
        setMisi((data.misi as string[]) || [""]);
        setSejarah((data.sejarah as string[]) || [""]);
      }
      setLoading(false);
    });
  }, []);

  const save = async () => {
    setBusy(true);
    const payload: Record<string, any> = {
      singleton: true,
      visi: visi.trim(),
      misi: misi.map((s) => s.trim()).filter(Boolean),
      sejarah: sejarah.map((s) => s.trim()).filter(Boolean),
    };
    // Auto-inject tenant_id for INSERT (upsert path: only inject if no existing row for this tenant)
    if (tenantId && !payload.tenant_id) {
      payload.tenant_id = tenantId;
    }
    const { error } = await supabase.from("profil_desa").upsert(payload, { onConflict: "singleton" });
    setBusy(false);
    if (error) toast.error(error.message);
    else toast.success("Profil desa tersimpan.");
  };

  if (loading) return <div className="text-muted-foreground">Memuat…</div>;

  return (
    <>
      <PageTitle title="Profil Desa" desc="Kelola sejarah, visi, dan misi desa." />
      <div className="space-y-6">
        <section className="rounded-xl bg-card border border-border p-5">
          <h2 className="font-display font-semibold mb-3">Visi</h2>
          <textarea value={visi} onChange={(e) => setVisi(e.target.value)} rows={3} maxLength={500} className={inp} autoComplete="off" />
        </section>

        <ListEditor
          title="Misi"
          items={misi}
          setItems={setMisi}
          placeholder="Kalimat misi…"
          multiline
        />
        <ListEditor
          title="Sejarah (per paragraf)"
          items={sejarah}
          setItems={setSejarah}
          placeholder="Paragraf sejarah…"
          multiline
        />

        <button onClick={save} disabled={busy} className={btnPri}>{busy ? "Menyimpan…" : "Simpan Perubahan"}</button>
      </div>
    </>
  );
}

function ListEditor({ title, items, setItems, placeholder, multiline }: { title: string; items: string[]; setItems: (v: string[]) => void; placeholder: string; multiline?: boolean }) {
  return (
    <section className="rounded-xl bg-card border border-border p-5">
      <h2 className="font-display font-semibold mb-3">{title}</h2>
      <div className="space-y-2">
        {items.map((v, i) => (
          <div key={i} className="flex gap-2 items-start">
            <span className="mt-2 text-xs text-muted-foreground tabular-nums w-6">{i + 1}.</span>
            {multiline ? (
              <textarea value={v} onChange={(e) => setItems(items.map((x, j) => j === i ? e.target.value : x))} rows={2} className={inp} placeholder={placeholder} autoComplete="off" />
            ) : (
              <input value={v} onChange={(e) => setItems(items.map((x, j) => j === i ? e.target.value : x))} className={inp} placeholder={placeholder} autoComplete="off" />
            )}
            <button type="button" onClick={() => setItems(items.filter((_, j) => j !== i))} className={btnDanger}>Hapus</button>
          </div>
        ))}
        <button type="button" onClick={() => setItems([...items, ""])} className={btnSec}>+ Tambah baris</button>
      </div>
    </section>
  );
}

// ============ Generic Table CRUD ============
export type Column = {
  key: string;
  label: string;
  type?: "text" | "number" | "date" | "textarea" | "checkbox" | "select" | "image" | "video" | "relation";
  step?: string;
  hideInTable?: boolean;
  options?: { value: string; label: string }[];
  relation?: { table: string; labelCol: string; valueCol: string; filterBy?: string; filterField?: string };
  imageFolder?: string;
  render?: (row: any) => ReactNode;
};

export function RelationSelect({
  relation,
  value,
  onChange,
  className,
  filterValue,
}: {
  relation: { table: string; labelCol: string; valueCol: string; filterBy?: string };
  value: string;
  onChange: (val: string) => void;
  className?: string;
  filterValue?: string;
}) {
  const [opts, setOpts] = useState<{value: string, label: string}[]>([]);
  useEffect(() => {
    const q = supabase.from(relation.table as any).select(`${relation.labelCol},${relation.valueCol}`).eq("aktif", true);
    if (relation.filterBy && filterValue) {
      q.eq(relation.filterBy, filterValue);
    }
    q.then(({ data }) => {
      if (data) {
        setOpts(data.map((d: any) => ({
          value: d[relation.valueCol],
          label: d[relation.labelCol]
        })));
      }
    });
  }, [relation.table, relation.labelCol, relation.valueCol, relation.filterBy, filterValue]);

  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className={className}
    >
      <option value="">— pilih —</option>
      {opts.map(o => (
        <option key={o.value} value={o.value}>{o.label}</option>
      ))}
    </select>
  );
}

// Confirmation dialog component
function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = "Hapus",
  onConfirm,
  onCancel,
}: {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-background rounded-xl shadow-2xl max-w-sm w-full mx-4 p-6">
        <h3 className="text-lg font-semibold mb-2">{title}</h3>
        <p className="text-muted-foreground text-sm mb-6">{message}</p>
        <div className="flex gap-3 justify-end">
          <button
            onClick={onCancel}
            className="px-4 py-2 rounded-lg border border-border text-sm hover:bg-muted"
          >
            Batal
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 rounded-lg bg-destructive text-destructive-foreground text-sm hover:bg-destructive/90"
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}

export function TableCrud({
  table, columns, blank, title, desc,
  orderBy = "urutan", orderAsc = true,
  pageSize = 50,
}: {
  table: string;
  columns: Column[];
  blank: Record<string, any>;
  title: string;
  desc: string;
  orderBy?: string;
  orderAsc?: boolean;
  pageSize?: number;
}) {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [nikError, setNikError] = useState<string | null>(null);
  const [nikLoading, setNikLoading] = useState(false);
  const tenantId = useTenantId();
  const nikDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const load = () => {
    setLoading(true);
    let q = (supabase.from(table as any) as any).select("*", { count: "exact" }).order(orderBy, { ascending: orderAsc });
    if (search) {
      // Basic search on first text column
      const searchCol = columns.find(c => c.type !== "number" && c.type !== "checkbox" && c.type !== "date" && c.type !== "select" && c.type !== "image");
      if (searchCol) q = q.ilike(searchCol.key, `%${search}%`);
    }
    q = q.range((page - 1) * pageSize, page * pageSize - 1);
    q.then(({ data, count }: any) => {
      setRows(data || []);
      setTotalCount(count || 0);
      setLoading(false);
    });
  };

  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => { load(); }, [table, orderBy, orderAsc, search, page]);

  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const filteredRows = search ? rows : rows; // Already filtered by Supabase

  const save = async (row: any) => {
    const { id, ...payload } = row;
    // NIK validation: must be exactly 16 digits
    const nikCol = columns.find(c => c.key === "nik" || c.label.toLowerCase().includes("nik"));
    if (nikCol && payload.nik && !/^\d{16}$/.test(String(payload.nik))) {
      setNikError("NIK harus 16 digit angka");
      return;
    }
    // Auto-inject tenant_id for tables that need it
    const tenantTables = ["penduduk", "keluarga", "surat_ajuan", "berita", "aduan_warga", "usulan_warga", "apbdes", "kegiatan_pembangunan", "agenda", "pengumuman", "galeri", "page_hero_config", "desa_pamong", "wilayah_dusun", "lembaga_desa", "hero_slider", "nav_items", "footer_columns"];
    if (tenantTables.includes(table) && !payload.tenant_id && tenantId) {
      payload.tenant_id = tenantId;
    }
    const q = id
      ? (supabase.from(table as any) as any).update(payload).eq("id", id)
      : (supabase.from(table as any) as any).insert(payload);
    const { error } = await q;
    if (error) return toast.error(error.message);
    toast.success("Tersimpan.");
    setDraft(null);
    setNikError(null);
    setPage(1);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus baris ini?")) return;
    const { error } = await (supabase.from(table as any) as any).delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    load();
  };

  // CSV Export
  const exportCsv = () => {
    const header = columns.filter(c => !c.hideInTable).map(c => c.label).join(",");
    const csvRows = filteredRows.map(r =>
      columns.filter(c => !c.hideInTable).map(c => {
        const val = r[c.key];
        if (val === null || val === undefined) return "";
        const str = String(val);
        return str.includes(",") || str.includes('"') || str.includes("\n")
          ? `"${str.replace(/"/g, '""')}"`
          : str;
      }).join(",")
    );
    const csv = [header, ...csvRows].join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${table}-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success("Export CSV berhasil");
  };

  // CSV Import
  const importCsv = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = async (ev) => {
      const text = ev.target?.result as string;
      const lines = text.split("\n").filter(l => l.trim());
      if (lines.length < 2) return toast.error("Format CSV tidak valid");
      const headers = lines[0].split(",").map(h => h.trim().replace(/^"|"$/g, ""));
      const dataRows = lines.slice(1);
      let imported = 0, failed = 0;
      for (const line of dataRows) {
        const values = line.split(",").map(v => v.trim().replace(/^"|"$/g, "").replace(/""/g, '"'));
        const row: any = {};
        headers.forEach((h, i) => {
          const col = columns.find(c => c.label === h);
          if (col) row[col.key] = values[i] || null;
        });
        if (Object.keys(row).length > 0) {
          // Auto-inject tenant_id for known multi-tenant tables during CSV import
          const tenantTables = ["penduduk", "keluarga", "surat_ajuan", "berita", "aduan_warga", "usulan_warga", "apbdes", "kegiatan_pembangunan", "agenda", "pengumuman", "galeri"];
          if (tenantTables.includes(table) && tenantId && !row.tenant_id) {
            row.tenant_id = tenantId;
          }
          const { error } = await (supabase.from(table as any) as any).insert(row);
          if (error) failed++; else imported++;
        }
      }
      toast.success(`Impor selesai: ${imported} berhasil, ${failed} gagal`);
      setPage(1);
      load();
    };
    reader.readAsText(file);
    e.target.value = "";
  };

  return (
    <>
      <PageTitle title={title} desc={desc} />
      <div className="flex flex-wrap gap-2 justify-between items-center mb-4">
        <div className="flex gap-2 items-center">
          <input
            type="search"
            placeholder="Cari..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="rounded-md border border-input bg-background px-3 py-2 text-sm w-48"
            autoComplete="off"
          />
          <span className="text-xs text-muted-foreground">{totalCount} data</span>
        </div>
        <div className="flex gap-2">
          <label className="cursor-pointer rounded-md border border-border bg-background px-3 py-2 text-sm hover:bg-muted">
            <span>Import CSV</span>
            <input type="file" accept=".csv" className="hidden" onChange={importCsv} />
          </label>
          <button onClick={exportCsv} className="rounded-md border border-border bg-background px-3 py-2 text-sm hover:bg-muted">Export CSV</button>
          <button onClick={() => setDraft({ ...blank })} className={btnPri}>+ Tambah</button>
        </div>
      </div>

      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <h3 className="font-display font-semibold mb-3">{draft.id ? "Edit" : "Tambah"} Baris</h3>
          <div className="grid sm:grid-cols-2 gap-3">
            {columns.map((c) => (
              <div key={String(c.key)} className={c.type === "textarea" ? "sm:col-span-2" : ""}>
                {c.type === "textarea" ? (
                  <label className="block text-xs font-medium mb-1">
                    <span className="block mb-1 font-medium">{c.label}</span>
                    <textarea
                      rows={4}
                      value={(draft[c.key] ?? "") as string}
                      onChange={(e) => setDraft({ ...draft, [c.key]: e.target.value })}
                      className={inp}
                      autoComplete="off"
                    />
                  </label>
                ) : c.type === "checkbox" ? (
                  <label className="inline-flex items-center gap-2 text-sm mt-6">
                    <input
                      type="checkbox"
                      checked={Boolean(draft[c.key])}
                      onChange={(e) => setDraft({ ...draft, [c.key]: e.target.checked })}
                    />
                    Aktif
                  </label>
                ) : c.type === "select" ? (
                  <label className="block text-xs font-medium mb-1">
                    <span className="block mb-1 font-medium">{c.label}</span>
                    <select
                      value={(draft[c.key] ?? "") as string}
                      onChange={(e) => setDraft({ ...draft, [c.key]: e.target.value })}
                      className={inp}
                      autoComplete="off"
                    >
                      <option value="" disabled>— pilih —</option>
                      {(c.options ?? []).map((o) => (
                        <option key={o.value} value={o.value}>{o.label}</option>
                      ))}
                    </select>
                  </label>
                ) : c.type === "relation" && c.relation ? (
                  <label className="block text-xs font-medium mb-1">
                    <span className="block mb-1 font-medium">{c.label}</span>
                    <RelationSelect
                      relation={c.relation}
                      value={(draft[c.key] ?? "") as string}
                      onChange={(val) => setDraft({ ...draft, [c.key]: val })}
                      className={inp}
                      filterValue={c.relation?.filterField ? (draft[c.relation.filterField] as string) : undefined}
                    />
                  </label>
                ) : c.type === "image" ? (
                  <label className="block text-xs font-medium mb-1">
                    <span className="block mb-1 font-medium">{c.label}</span>
                    <ImageField
                      value={(draft[c.key] as string) || ""}
                      folder={c.imageFolder || table}
                      onChange={(url) => setDraft({ ...draft, [c.key]: url })}
                    />
                  </label>
                ) : c.type === "video" ? (
                  <label className="block text-xs font-medium mb-1">
                    <span className="block mb-1 font-medium">{c.label}</span>
                    <VideoField
                      value={(draft[c.key] as string) || ""}
                      folder={c.imageFolder || table}
                      onChange={(url) => setDraft({ ...draft, [c.key]: url })}
                    />
                  </label>
                ) : (
                  <div>
                    {(() => {
                      const isNikField = c.key === "nik" || c.label.toLowerCase().includes("nik");
                      const isNamaField = /nama/i.test(c.label);
                      const isAlamatField = /alamat/i.test(c.label);
                      const isEmailField = /email/i.test(c.label);
                      const isTeleponField = /telepon|telp|kontak|nomor.?wa|hp/i.test(c.label);
                      const isTanggalField = /tanggal|tgl/i.test(c.label);

                      const autoComplete = isNikField ? "off"
                        : isNamaField ? "name"
                        : isAlamatField ? "street-address"
                        : isEmailField ? "email"
                        : isTeleponField ? "tel"
                        : isTanggalField ? "off"
                        : isNamaField ? "name"
                        : "off";

                      return (
                        <label className="block text-xs font-medium mb-1">
                          <span className="block mb-1 font-medium">{c.label}</span>
                          <input
                            type={c.type === "number" ? "number" : isTeleponField ? "tel" : isEmailField ? "email" : "text"}
                            step={c.step}
                            value={(draft[c.key] ?? "") as string | number}
                            onChange={(e) => {
                              const raw = e.target.value;
                              const val = c.type === "number" ? (raw === "" ? 0 : Number(raw)) : raw;
                              setDraft({ ...draft, [c.key]: val });
                              if (isNikField) {
                                setNikError(null);
                                setNikLoading(false);
                                if (nikDebounceRef.current) clearTimeout(nikDebounceRef.current);
                                if (/^\d{16}$/.test(raw)) {
                                  nikDebounceRef.current = setTimeout(async () => {
                                    setNikLoading(true);
                                    const { data: p } = await (supabase.from("penduduk") as any)
                                      .select("*").eq("nik", raw).maybeSingle();
                                    if (!p) { setNikLoading(false); return; }
                                    const genderMap: Record<string, string> = { L: "L", P: "P" };
                                    const next: Record<string, unknown> = { ...draft };

                                    for (const k of ["nama", "tempat_lahir", "tanggal_lahir", "alamat"]) {
                                      if (p[k] !== undefined && p[k] !== null) next[k] = p[k];
                                    }
                                    next.jenis_kelamin = genderMap[p.jenis_kelamin] ?? p.jenis_kelamin ?? "L";
                                    next.keluarga_id = p.keluarga_id ?? null;

                                    if (p.agama) {
                                      const { data: ref } = await (supabase.from("ref_agama") as any)
                                        .select("kode").ilike("nama", String(p.agama)).maybeSingle();
                                      next.agama = ref?.kode ?? String(p.agama);
                                    }
                                    if (p.pendidikan) {
                                      const { data: ref } = await (supabase.from("ref_pendidikan") as any)
                                        .select("nama").ilike("nama", String(p.pendidikan)).maybeSingle();
                                      if (ref?.nama) next.pendidikan = ref.nama;
                                    }
                                    if (p.pekerjaan) {
                                      const { data: ref } = await (supabase.from("ref_pekerjaan") as any)
                                        .select("nama").ilike("nama", String(p.pekerjaan)).maybeSingle();
                                      if (ref?.nama) next.pekerjaan = ref.nama;
                                    }
                                    if (p.status_kawin) {
                                      const { data: ref } = await (supabase.from("ref_status_perkawinan") as any)
                                        .select("kode").ilike("nama", String(p.status_kawin)).maybeSingle();
                                      next.status_kawin = ref?.kode ?? String(p.status_kawin);
                                    }
                                    if (p.hubungan_kk) {
                                      const { data: ref } = await (supabase.from("ref_hubungan_keluarga") as any)
                                        .select("nama").ilike("nama", String(p.hubungan_kk)).maybeSingle();
                                      if (ref?.nama) next.hubungan_kk = ref.nama;
                                    }

                                    setNikLoading(false);
                                    setDraft(next);
                                    toast.success("Data ditemukan — field otomatis terisi.");
                                  }, 500);
                                }
                              }
                            }}
                            autoComplete={autoComplete}
                            className={inp}
                          />
                          {isNikField && (nikError || nikLoading) && (
                            <p className="text-xs mt-1">{nikLoading ? <span className="text-blue-500">Mencari data penduduk...</span> : <span className="text-red-500">{nikError}</span>}</p>
                          )}
                        </label>
                      );
                    })()}
                  </div>
                )}
              </div>
            ))}
          </div>
          <div className="mt-4 flex gap-2">
            <button onClick={() => save(draft)} className={btnPri}>Simpan</button>
            <button onClick={() => { setDraft(null); setNikError(null); }} className={btnSec}>Batal</button>
          </div>
        </div>
      )}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              {columns.filter((c) => !c.hideInTable).map((c) => (
                <th key={String(c.key)} className="text-left px-4 py-3 font-display font-semibold">{c.label}</th>
              ))}
              <th className="px-4 py-3 w-40"></th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr><td colSpan={columns.length + 1} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>
            )}
            {!loading && rows.length === 0 && (
              <tr><td colSpan={columns.length + 1} className="px-4 py-6 text-center text-muted-foreground">Belum ada data.</td></tr>
            )}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                {columns.filter((c) => !c.hideInTable).map((c) => (
                  <td key={String(c.key)} className="px-4 py-3">
                    {c.render ? c.render(r) : c.type === "checkbox" ? (r[c.key] ? "✓" : "—") : String(r[c.key] ?? "")}
                  </td>
                ))}
                <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                  <button onClick={() => setDraft(r)} className={btnSec}>Edit</button>
                  <button onClick={() => r.id && del(r.id)} className={btnDanger}>Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center gap-1 mt-4">
          <button onClick={() => setPage(1)} disabled={page === 1} className="px-3 py-1 rounded border text-sm disabled:opacity-50">«</button>
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="px-3 py-1 rounded border text-sm disabled:opacity-50">‹</button>
          <span className="px-3 py-1 text-sm">Halaman {page} dari {totalPages}</span>
          <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="px-3 py-1 rounded border text-sm disabled:opacity-50">›</button>
          <button onClick={() => setPage(totalPages)} disabled={page === totalPages} className="px-3 py-1 rounded border text-sm disabled:opacity-50">»</button>
        </div>
      )}
    </>
  );
}

export function ImageField({ value, folder, onChange }: { value: string; folder: string; onChange: (url: string) => void }) {
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState<string>(value || "");

  const onFile = async (f: File | null) => {
    if (!f) return;
    setBusy(true);
    try {
      // Show preview immediately while uploading
      const reader = new FileReader();
      reader.onload = (e) => setPreview(e.target?.result as string || "");
      reader.readAsDataURL(f);

      const result = await uploadFile(f, {
        entityType: 'lainnya',
        kategori: 'foto_galeri',
      } as any);
      if (result.success && result.url) {
        onChange(result.url);
        toast.success("Foto berhasil diunggah ke penyimpanan internal.");
      } else {
        toast.error(result.error || "Gagal upload.");
      }
    } catch (e: any) {
      toast.error(e.message || "Gagal upload.");
    } finally {
      setBusy(false);
    }
  };

  const handleRemove = () => {
    setPreview("");
    onChange("");
  };

  return (
    <div className="space-y-2">
      {/* Preview Image */}
      {(preview || value) && (
        <div className="relative">
          <img
            src={preview || value}
            alt="preview"
            className="h-32 w-full object-cover border border-border rounded-md"
          />
          <div className="absolute top-2 right-2">
            <span className="bg-green-500 text-white text-xs px-2 py-1 rounded">
              ✓ Internal
            </span>
          </div>
        </div>
      )}

      {/* Upload Button */}
      <div className="flex items-center gap-3">
        <label className="cursor-pointer inline-flex items-center gap-2 rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90 disabled:opacity-50">
          {busy ? "Mengunggah..." : "📁 Pilih File dari Device"}
          <input
            type="file"
            accept="image/*"
            disabled={busy}
            onChange={(e) => onFile(e.target.files?.[0] || null)}
            className="hidden"
          />
        </label>
        {(value || preview) && (
          <button type="button" onClick={handleRemove} className={btnDanger}>
            Hapus
          </button>
        )}
      </div>

      {/* Info */}
      <p className="text-xs text-muted-foreground">
        <span className="font-medium">📱 Penyimpanan Internal</span> — Gambar disimpan di server aplikasi, bukan URL eksternal.
      </p>

      {/* Show current URL if exists (read-only) */}
      {value && (
        <div className="text-xs text-muted-foreground truncate">
          Path: {value.split('/').pop() || value}
        </div>
      )}
    </div>
  );
}

export function PamongAdmin() {
  return (
    <TableCrud
      table="desa_pamong"
      title="Struktur Pamong Desa"
      desc="Perangkat pemerintahan desa yang tampil di halaman Struktur."
      blank={{ nama: "", jabatan: "", periode: "", urutan: 0, foto_url: "", nip: "", aktif: true, qr_code_url: "", ttd_image_url: "" } as any}
      columns={[
        { key: "nama", label: "Nama" },
        { key: "jabatan", label: "Jabatan" },
        { key: "nip", label: "NIP" },
        { key: "periode", label: "Periode" },
        { key: "urutan", label: "Urutan", type: "number" },
        { key: "aktif", label: "Aktif", type: "checkbox" },
        { key: "foto_url", label: "Foto Pamong", type: "image", imageFolder: "pamong", hideInTable: true },
        { key: "ttd_image_url", label: "Tanda Tangan", type: "image", imageFolder: "pamong/ttd", hideInTable: true },
        { key: "qr_code_url", label: "QR Code Verifikasi", type: "image", imageFolder: "pamong/qr", hideInTable: true },
      ]}
    />
  );
}

export function DusunAdmin() {
  return (
    <TableCrud
      table="wilayah_dusun"
      title="Wilayah Dusun"
      desc="Daftar dusun yang tampil di halaman Wilayah."
      blank={{ nama: "", kk: 0, jiwa: 0, luas_ha: 0, urutan: 0 } as any}
      columns={[
        { key: "nama", label: "Nama Dusun" },
        { key: "kk", label: "KK", type: "number" },
        { key: "jiwa", label: "Jiwa", type: "number" },
        { key: "luas_ha", label: "Luas (ha)", type: "number", step: "0.01" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

export function LembagaAdmin() {
  return (
    <TableCrud
      table="lembaga_desa"
      title="Lembaga Desa"
      desc="Lembaga kemasyarakatan yang tampil di halaman Lembaga."
      blank={{ nama: "", ketua: "", jumlah_anggota: 0, urutan: 0 } as any}
      columns={[
        { key: "nama", label: "Nama Lembaga" },
        { key: "ketua", label: "Ketua" },
        { key: "jumlah_anggota", label: "Jumlah Anggota", type: "number" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

// ============ Berita ============
export function BeritaAdmin() {
  return (
    <BeritaCrud />
  );
}

function BeritaCrud() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [isiText, setIsiText] = useState("");
  const tenantId = useTenantId();

  const load = () => {
    setLoading(true);
    supabase.from("berita").select("*").order("tanggal", { ascending: false }).then(({ data }) => {
      setRows(data || []);
      setLoading(false);
    });
  };
  useEffect(load, []);

  const openNew = () => {
    setDraft({ slug: "", kategori: "Umum", judul: "", ringkasan: "", isi: [], penulis: "", tanggal: new Date().toISOString().slice(0, 10), published: true, cover_url: "" });
    setIsiText("");
  };
  const openEdit = (r: any) => {
    setDraft(r);
    setIsiText(((r.isi as string[]) || []).join("\n\n"));
  };

  const save = async () => {
    const payload: Record<string, any> = { ...draft, isi: isiText.split(/\n\n+/).map((s) => s.trim()).filter(Boolean) };
    // Auto-inject tenant_id on INSERT
    if (!payload.id && tenantId && !payload.tenant_id) {
      payload.tenant_id = tenantId;
    }
    const { id, ...rest } = payload;
    const q = id ? (supabase.from("berita") as any).update(rest as any).eq("id", id) : (supabase.from("berita") as any).insert(rest as any);
    const { error } = await q;
    if (error) return toast.error(error.message);
    toast.success("Tersimpan.");
    setDraft(null);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus berita ini?")) return;
    const { error } = await supabase.from("berita").delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    load();
  };

  return (
    <>
      <PageTitle title="Berita Desa" desc="Artikel yang tampil di halaman Berita publik." />
      <div className="flex justify-end mb-4">
        <button onClick={openNew} className={btnPri}>+ Tambah Berita</button>
      </div>
      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5 space-y-3">
          <h3 className="font-display font-semibold">{draft.id ? "Edit" : "Tambah"} Berita</h3>
          <div className="grid sm:grid-cols-2 gap-3">
            <div><label className="block text-xs mb-1">Judul</label><input className={inp} value={draft.judul} onChange={(e) => setDraft({ ...draft, judul: e.target.value })} autoComplete="off" /></div>
            <div><label className="block text-xs mb-1">Slug (URL)</label><input className={inp} value={draft.slug} onChange={(e) => setDraft({ ...draft, slug: e.target.value })} placeholder="contoh: pengerasan-jalan" autoComplete="off" /></div>
            <div><label className="block text-xs mb-1">Kategori</label><input className={inp} value={draft.kategori} onChange={(e) => setDraft({ ...draft, kategori: e.target.value })} autoComplete="off" /></div>
            <div><label className="block text-xs mb-1">Tanggal</label><input type="date" className={inp} value={draft.tanggal} onChange={(e) => setDraft({ ...draft, tanggal: e.target.value })} autoComplete="off" /></div>
            <div><label className="block text-xs mb-1">Penulis</label><input className={inp} value={draft.penulis} onChange={(e) => setDraft({ ...draft, penulis: e.target.value })} autoComplete="off" /></div>
            <div className="flex items-end"><label className="inline-flex items-center gap-2 text-sm"><input type="checkbox" checked={draft.published} onChange={(e) => setDraft({ ...draft, published: e.target.checked })} /> Publikasikan</label></div>
          </div>
          <div><label className="block text-xs mb-1">Ringkasan</label><textarea rows={2} className={inp} value={draft.ringkasan} onChange={(e) => setDraft({ ...draft, ringkasan: e.target.value })} autoComplete="off" /></div>
          <div>
            <label className="block text-xs mb-1">Foto Sampul (Cover)</label>
            <ImageField
              value={draft.cover_url || ""}
              folder="berita"
              onChange={(url) => setDraft({ ...draft, cover_url: url })}
            />
          </div>
          <div><label className="block text-xs mb-1">Isi (pisahkan paragraf dengan baris kosong)</label><textarea rows={10} className={inp} value={isiText} onChange={(e) => setIsiText(e.target.value)} autoComplete="off" /></div>
          <div className="flex gap-2"><button onClick={save} className={btnPri}>Simpan</button><button onClick={() => setDraft(null)} className={btnSec}>Batal</button></div>
        </div>
      )}
      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted"><tr><th className="text-left px-4 py-3">Tanggal</th><th className="text-left px-4 py-3">Judul</th><th className="text-left px-4 py-3">Kategori</th><th className="text-left px-4 py-3">Status</th><th className="w-40"></th></tr></thead>
          <tbody>
            {loading && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Belum ada data.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 tabular-nums">{r.tanggal}</td>
                <td className="px-4 py-3 font-medium">{r.judul}</td>
                <td className="px-4 py-3">{r.kategori}</td>
                <td className="px-4 py-3">{r.published ? <span className="text-primary">Terbit</span> : <span className="text-muted-foreground">Draf</span>}</td>
                <td className="px-4 py-3 text-right space-x-2"><button onClick={() => openEdit(r)} className={btnSec}>Edit</button><button onClick={() => del(r.id)} className={btnDanger}>Hapus</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ============ Agenda / Pengumuman / Galeri (via TableCrud) ============
export function AgendaAdmin() {
  return (
    <TableCrud
      table="agenda"
      title="Agenda & Kalender"
      desc="Jadwal kegiatan desa yang tampil di halaman Kalender."
      orderBy="tanggal"
      orderAsc
      blank={{ slug: "", jenis: "Kegiatan", judul: "", tanggal: new Date().toISOString().slice(0, 10), waktu: "", lokasi: "", penyelenggara: "", deskripsi: "" } as any}
      columns={[
        { key: "judul" as any, label: "Judul" },
        { key: "slug" as any, label: "Slug" },
        { key: "jenis" as any, label: "Jenis" },
        { key: "tanggal" as any, label: "Tanggal", type: "date" },
        { key: "waktu" as any, label: "Waktu" },
        { key: "lokasi" as any, label: "Lokasi" },
        { key: "penyelenggara" as any, label: "Penyelenggara" },
        { key: "deskripsi" as any, label: "Deskripsi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

export function PengumumanAdmin() {
  return (
    <TableCrud
      table="pengumuman"
      title="Pengumuman Resmi"
      desc="Pengumuman bernomor register yang tampil di halaman Pengumuman."
      orderBy="tanggal"
      orderAsc={false}
      blank={{ nomor: "", tanggal: new Date().toISOString().slice(0, 10), judul: "", ringkasan: "" } as any}
      columns={[
        { key: "nomor" as any, label: "Nomor Register" },
        { key: "tanggal" as any, label: "Tanggal", type: "date" },
        { key: "judul" as any, label: "Judul" },
        { key: "ringkasan" as any, label: "Ringkasan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

export function GaleriAdmin() {
  return (
    <TableCrud
      table="galeri"
      title="Galeri"
      desc="Foto kegiatan desa yang tampil di halaman Galeri."
      orderBy="urutan"
      orderAsc
      blank={{ judul: "", emoji: "📷", album: "Umum", tanggal: new Date().toISOString().slice(0, 10), urutan: 0, foto_url: "" } as any}
      columns={[
        { key: "judul" as any, label: "Judul" },
        { key: "album" as any, label: "Album" },
        { key: "tanggal" as any, label: "Tanggal", type: "date" },
        { key: "urutan" as any, label: "Urutan", type: "number" },
        { key: "foto_url" as any, label: "Foto", type: "image", imageFolder: "galeri", hideInTable: true },
        { key: "emoji" as any, label: "Emoji (fallback)", hideInTable: true },
      ]}
    />
  );
}
export function VideoField({ value, folder, onChange }: { value: string; folder: string; onChange: (url: string) => void }) {
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState<string>(value || "");

  const onFile = async (f: File | null) => {
    if (!f) return;
    setBusy(true);
    try {
      const result = await uploadFile(f, {
        entityType: 'lainnya',
        kategori: 'foto_galeri',
      } as any);
      if (result.success && result.url) {
        setPreview(result.url);
        onChange(result.url);
        toast.success("Video berhasil diunggah ke penyimpanan internal.");
      } else {
        toast.error("Gagal unggah video.");
      }
    } catch (e: any) {
      toast.error(e.message || "Gagal unggah video.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="space-y-3">
      {preview ? (
        <video src={preview} controls className="w-full h-auto max-h-48 object-cover rounded shadow" />
      ) : (
        <div className="w-full h-32 bg-secondary flex items-center justify-center rounded text-sm text-muted-foreground border border-dashed">
          Tidak ada video
        </div>
      )}
      <div className="flex items-center gap-3">
        <input
          type="file"
          accept="video/mp4,video/webm"
          className="text-xs"
          onChange={(e) => onFile(e.target.files?.[0] || null)}
          disabled={busy}
        />
        {busy && <span className="text-xs text-muted-foreground">Mengunggah...</span>}
      </div>
    </div>
  );
}
