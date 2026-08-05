import { useEffect, useState, useRef, type ReactNode } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "../lib/auth";
import { useTenantId } from "../lib/tenant";
import { useConfirm } from "../ui/ConfirmDialog";
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
import { StandaloneFormOverlay } from "../ui";
import { TableCrud, ImageField, VideoField, type Column } from "../components/TableCrud";
import { DropdownMenuItem, DropdownMenuSeparator } from "@/components/ui/dropdown-menu";
import { useQueryClient } from "@tanstack/react-query";
import { AdminPamong } from "./AdminPamong";

export function useSelectOptions(table: string, labelKey: string, valueKey = "id", filter?: (r: Record<string, unknown>) => boolean) {
  const [opts, setOpts] = useState<{ value: string; label: string }[]>([]);
  useEffect(() => {
    supabase.from(table as any).select("*").then(({ data }) => {
      const rows = (data || []) as unknown as Record<string, unknown>[];
      const filtered = filter ? rows.filter(filter) : rows;
      setOpts(filtered.map(r => ({ value: String(r[valueKey]), label: String(r[labelKey]) })));
    });
  }, [table, labelKey, valueKey, filter]);
  return opts;
}

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

const PIE_COLORS = ["#015967", "#FF9E20", "#0d7a8a", "#c97a12", "#33a3b3", "#a1560b"];

const rupiahShort = (n: number) => {
  if (n >= 1_000_000_000) return `Rp ${(n / 1_000_000_000).toFixed(2)} M`;
  if (n >= 1_000_000) return `Rp ${(n / 1_000_000).toFixed(1)} Jt`;
  return `Rp ${n.toLocaleString("id-ID")}`;
};

function KPI({ label, val, hint, to }: { label: string; val: string | number; hint?: string; to?: string }) {
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
}

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
      .then(({ data }) => data && setProfile(data));

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
        supabase.from("pbb_tagihan").select("pbb_terutang").eq("tahun", currentYear).eq("status_bayar", "lunas"),
        supabase.from("aduan_warga").select("kategori"),
        supabase.from("apbdes").select("kategori,anggaran,realista,jenis").eq("tahun", currentYear).eq("jenis", "belanja"),
        supabase.from("event_log").select("event_name,entitas,created_at").order("created_at", { ascending: false }).limit(8),
      ]);

      const pbbNominal = ((pbbSumRes.data) || []).reduce((a, r) => a + Number(r.pbb_terutang || 0), 0);

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
      ((aduanRows.data) || []).forEach((r) => kMap.set(r.kategori, (kMap.get(r.kategori) || 0) + 1));
      setAduanByKategori(Array.from(kMap.entries()).map(([name, value]) => ({ name, value })));

      const bMap = new Map<string, { anggaran: number; realisasi: number }>();
      ((apbdesRows.data) || []).forEach((r) => {
        const cur = bMap.get(r.kategori) || { anggaran: 0, realisasi: 0 };
        cur.anggaran += Number(r.anggaran || 0);
        cur.realisasi += Number(r.realista || 0);
        bMap.set(r.kategori, cur);
      });
      setApbdesBidang(
        Array.from(bMap.entries()).map(([name, v]) => ({
          name: name.replace(/^Bidang \d+ — /, ""),
          ...v,
        })),
      );

      setRecentEvents(events.data || []);
      setLoading(false);
    })();
  }, [user, currentYear]);

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


export function RelationSelect({
  relation,
  value,
  onChange,
  className,
  filterValue,
  requireAktif = true,
}: {
  relation: { table: string; labelCol: string; valueCol: string; filterBy?: string };
  value: string;
  onChange: (val: string) => void;
  className?: string;
  filterValue?: string;
  /** Set false for tables that don't have an 'aktif' column (e.g. wilayah_dusun, berita, agenda). Default true. */
  requireAktif?: boolean;
}) {
  const [opts, setOpts] = useState<{value: string, label: string}[]>([]);
  useEffect(() => {
    let q = supabase.from(relation.table as any).select(`${relation.labelCol},${relation.valueCol}`);
    if (requireAktif) q = q.eq("aktif", true);
    if (relation.filterBy && filterValue) {
      q = q.eq(relation.filterBy, filterValue);
    }
    q.then(({ data }) => {
      if (data) {
        setOpts(data.map((d: any) => ({
          value: d[relation.valueCol],
          label: d[relation.labelCol]
        })));
      }
    });
  }, [relation.table, relation.labelCol, relation.valueCol, relation.filterBy, filterValue, requireAktif]);

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



// ============ Agenda / Pengumuman / Galeri (via TableCrud) ============

export function SuratAjuanAdmin() {
  const jenisSuratOpts = useSelectOptions("surat_jenis", "nama");

  const handlePreview = (id: string) => {
    window.open(`/admin/surat-ajuan/preview/${id}`, "_blank");
  };

  return (
    <TableCrud
      table="surat_ajuan"
      title="Pengajuan Surat"
      desc="Modul pengelolaan pengajuan surat dari warga."
      orderBy="created_at"
      orderAsc={false}
      blank={{ 
        nomor_tiket: "", 
        nik: "", 
        nama: "", 
        kontak: "", 
        jenis_surat_id: "", 
        keperluan: "", 
        status: "menunggu" 
      } as any}
      columns={[
        { key: "nomor_tiket", label: "Nomor Tiket", readOnly: true },
        { key: "nik", label: "NIK Pemohon" },
        { key: "nama", label: "Nama Pemohon" },
        { key: "kontak", label: "Kontak" },
        { 
          key: "jenis_surat_id", 
          label: "Jenis Surat", 
          type: "select", 
          options: jenisSuratOpts,
          render: (r: any) => {
            const opt = jenisSuratOpts.find(o => o.value === r.jenis_surat_id);
            return opt ? opt.label : r.jenis_surat_id;
          }
        },
        { key: "keperluan", label: "Keperluan", type: "textarea" },
        { 
          key: "status", 
          label: "Status", 
          type: "select", 
          options: [
            { value: "Menunggu", label: "Menunggu" },
            { value: "Tandatangani", label: "Tandatangani" },
            { value: "Selesai", label: "Selesai" },
            { value: "Ditolak", label: "Ditolak" },
            { value: "Dibatalkan", label: "Dibatalkan" },
          ]
        },
        { key: "created_at", label: "Tgl Pengajuan", readOnly: true },
      ]}
      customActions={(r) => (
        <>
          <DropdownMenuSeparator />
          <DropdownMenuItem onClick={() => handlePreview(r.id)}>
            Verifikasi / Preview Surat
          </DropdownMenuItem>
        </>
      )}
    />
  );
}

export function SuratPersyaratanAdmin() {
  const jenisSuratOpts = useSelectOptions("surat_jenis", "nama");

  return (
    <TableCrud
      table="surat_persyaratan"
      title="Master Persyaratan Surat"
      desc="Kelola daftar persyaratan untuk masing-masing jenis surat."
      orderBy="created_at"
      blank={{ surat_jenis_id: "", nama_persyaratan: "" } as any}
      columns={[
        { 
          key: "surat_jenis_id", 
          label: "Jenis Surat", 
          type: "select", 
          options: jenisSuratOpts,
          render: (r: any) => {
            const opt = jenisSuratOpts.find(o => o.value === r.surat_jenis_id);
            return opt ? opt.label : r.surat_jenis_id;
          }
        },
        { key: "nama_persyaratan", label: "Nama Persyaratan" }
      ]}
    />
  );
}

// Dummy components for other missing routes
const ComingSoon = ({ title }: { title: string }) => (
  <div className="p-8">
    <PageTitle title={title} desc="Modul ini sedang dalam pengembangan." />
    <div className="bg-amber-50 border border-amber-200 text-amber-800 rounded-lg p-6 text-center">
      <h3 className="font-semibold text-lg mb-2">Segera Hadir</h3>
      <p>Fitur ini masih dalam tahap pengerjaan dan akan tersedia pada update berikutnya.</p>
    </div>
  </div>
);

export const PamongAdmin = AdminPamong;
export const LembagaAdmin = () => <ComingSoon title="Lembaga Desa" />;
export const BeritaAdmin = () => <ComingSoon title="Berita" />;
export const AgendaAdmin = () => <ComingSoon title="Agenda" />;
export const PengumumanAdmin = () => <ComingSoon title="Pengumuman" />;
export const GaleriAdmin = () => <ComingSoon title="Galeri" />;
export const BidangTanahAdmin = () => <ComingSoon title="Pertanahan" />;
export const InfrastrukturAdmin = () => <ComingSoon title="Infrastruktur" />;
export const KegiatanPembangunanAdmin = () => <ComingSoon title="Kegiatan Pembangunan" />;
export const PosyanduAdmin = () => <ComingSoon title="Posyandu" />;
export const StuntingAdmin = () => <ComingSoon title="Stunting" />;
export const BansosAdmin = () => <ComingSoon title="Bantuan Sosial" />;
export const PenerimaBansosAdmin = () => <ComingSoon title="Penerima Bansos" />;
export const BencanaAdmin = () => <ComingSoon title="Bencana" />;
export const AduanAdmin = () => <ComingSoon title="Aduan Warga" />;
export const DptAdmin = () => <ComingSoon title="DPT" />;
export function JenisSuratAdmin() {
  return (
    <TableCrud
      table="surat_jenis"
      title="Master Jenis Surat"
      desc="Kelola daftar jenis surat beserta format cetak HTML dinamisnya."
      orderBy="kode_surat"
      blank={{ kode_surat: "", kode_klasifikasi: "", nama: "", dna_field: "" } as any}
      columns={[
        { key: "kode_surat", label: "Kode Surat (Misal: 470)" },
        { key: "kode_klasifikasi", label: "Kode Klasifikasi" },
        { key: "nama", label: "Nama Surat" },
        { key: "dna_field", label: "Template HTML Dinamis", type: "richtext", hideInTable: true }
      ]}
    />
  );
}
export const SuratTerbitAdmin = () => <ComingSoon title="Surat Terbit" />;
export const CetakSuratTerbitAdmin = () => <ComingSoon title="Cetak Surat" />;
export const LanggananWaAdmin = () => <ComingSoon title="Langganan WA" />;
export const BroadcastAdmin = () => <ComingSoon title="Broadcast" />;
export const UmkmAdmin = () => <ComingSoon title="UMKM" />;
export const ProdukMarketplaceAdmin = () => <ComingSoon title="Produk" />;
export const WisataAdmin = () => <ComingSoon title="Wisata" />;
export const PbbAdmin = () => <ComingSoon title="PBB" />;
export const ApbdesAdmin = () => <ComingSoon title="APBDes" />;
export { SuratAjuanPreviewPage } from "./SuratAjuanPreviewPage";
export const BalitaAdmin = () => <ComingSoon title="Balita" />;
export const WaChatbotAdmin = () => <ComingSoon title="WA Chatbot" />;
export const EventLogAdmin = () => <ComingSoon title="Event Log" />;
