import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";

const inp = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary";
const btnPri = "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60";
const btnSec = "rounded-md border border-border bg-background px-3 py-1.5 text-sm hover:bg-muted";
const btnDanger = "rounded-md border border-destructive/40 text-destructive bg-background px-3 py-1.5 text-sm hover:bg-destructive/10";

const ENTITAS = [
  { value: "page_config", label: "Halaman & Hero" },
  { value: "nav_item", label: "Menu Navbar" },
  { value: "footer_column", label: "Kolom Footer" },
];
const STATUS_LABEL: Record<string, string> = {
  draft: "Draft", review: "Menunggu Review", published: "Terpublikasi",
  rolled_back: "Rollback", rejected: "Ditolak",
};

// ============ Site Drafts ============
type Draft = {
  id: string; entitas: string; entitas_id: string | null;
  action: string; payload: any; status: string; catatan: string | null;
  actor_id: string | null; reviewer_id: string | null;
  reviewed_at: string | null; published_at: string | null;
  created_at: string; updated_at: string;
};

function useDrafts(status: string, entitas: string, reloadKey: number) {
  const [rows, setRows] = useState<Draft[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    setLoading(true);
    let q = (supabase.from("site_draft" as any) as any).select("*").order("created_at", { ascending: false });
    if (status) q = q.eq("status", status);
    if (entitas) q = q.eq("entitas", entitas);
    q.then(({ data }: any) => { setRows((data || []) as Draft[]); setLoading(false); });
  }, [status, entitas, reloadKey]);
  return { rows, loading };
}

function DiffPreview({ draft }: { draft: Draft }) {
  const [live, setLive] = useState<any | null>(null);
  useEffect(() => {
    if (!draft.entitas_id) { setLive(null); return; }
    (supabase.from(draft.entitas as any) as any).select("*").eq("id", draft.entitas_id).maybeSingle()
      .then(({ data }: any) => setLive(data));
  }, [draft.entitas, draft.entitas_id]);
  const keys = Array.from(new Set([...Object.keys(draft.payload || {}), ...Object.keys(live || {})]))
    .filter((k) => !["id","created_at","updated_at"].includes(k));
  return (
    <div className="mt-3 border border-border rounded-md overflow-hidden">
      <div className="bg-muted px-3 py-2 text-xs font-medium">Perbandingan draft vs live</div>
      <table className="w-full text-xs">
        <thead className="bg-muted/60">
          <tr>
            <th className="text-left px-3 py-1.5 w-40">Kolom</th>
            <th className="text-left px-3 py-1.5">Live</th>
            <th className="text-left px-3 py-1.5">Draft</th>
          </tr>
        </thead>
        <tbody>
          {keys.map((k) => {
            const l = live?.[k];
            const d = (draft.payload || {})[k];
            const changed = JSON.stringify(l) !== JSON.stringify(d);
            return (
              <tr key={k} className={`border-t border-border ${changed ? "bg-accent/10" : ""}`}>
                <td className="px-3 py-1.5 font-medium">{k}</td>
                <td className="px-3 py-1.5 whitespace-pre-wrap break-all opacity-80">{l === null || l === undefined ? "—" : typeof l === "string" ? l : JSON.stringify(l)}</td>
                <td className="px-3 py-1.5 whitespace-pre-wrap break-all">{d === undefined ? "—" : typeof d === "string" ? d : JSON.stringify(d)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

export function SiteDraftAdmin() {
  const [statusF, setStatusF] = useState("");
  const [entF, setEntF] = useState("");
  const [reload, setReload] = useState(0);
  const { rows, loading } = useDrafts(statusF, entF, reload);
  const [openId, setOpenId] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const setStatus = async (id: string, next: string, extra: Record<string, any> = {}) => {
    setBusyId(id);
    const { error } = await (supabase.from("site_draft" as any) as any).update({ status: next, ...extra }).eq("id", id);
    setBusyId(null);
    if (error) return toast.error(error.message);
    toast.success("Status diperbarui.");
    setReload((k) => k + 1);
  };

  const publish = async (id: string) => {
    setBusyId(id);
    const { error } = await (supabase.rpc as any)("publish_site_draft", { _draft_id: id });
    setBusyId(null);
    if (error) return toast.error(error.message);
    toast.success("Draft dipublikasikan.");
    setReload((k) => k + 1);
  };

  const rollback = async (id: string) => {
    if (!confirm("Rollback publikasi ini ke versi sebelumnya?")) return;
    setBusyId(id);
    const { error } = await (supabase.rpc as any)("rollback_site_draft", { _draft_id: id });
    setBusyId(null);
    if (error) return toast.error(error.message);
    toast.success("Rollback berhasil.");
    setReload((k) => k + 1);
  };

  const hapus = async (id: string) => {
    if (!confirm("Hapus draft ini?")) return;
    const { error } = await (supabase.from("site_draft" as any) as any).delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    setReload((k) => k + 1);
  };

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Draft Situs</h1>
        <p className="text-sm text-muted-foreground mt-1">Alur bertahap: draft → review → publish → rollback.</p>
      </div>
      <div className="flex flex-wrap gap-3 mb-4">
        <label className="text-sm">
          <span className="block text-xs mb-1">Status</span>
          <select value={statusF} onChange={(e) => setStatusF(e.target.value)} className={inp}>
            <option value="">Semua</option>
            {Object.entries(STATUS_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
        </label>
        <label className="text-sm">
          <span className="block text-xs mb-1">Entitas</span>
          <select value={entF} onChange={(e) => setEntF(e.target.value)} className={inp}>
            <option value="">Semua</option>
            {ENTITAS.map((e) => <option key={e.value} value={e.value}>{e.label}</option>)}
          </select>
        </label>
        <div className="ml-auto self-end">
          <NewDraftButton onCreated={() => setReload((k) => k + 1)} />
        </div>
      </div>

      <div className="space-y-3">
        {loading && <p className="text-muted-foreground">Memuat…</p>}
        {!loading && !rows.length && <p className="text-muted-foreground">Belum ada draft.</p>}
        {rows.map((d) => {
          const open = openId === d.id;
          const ent = ENTITAS.find((e) => e.value === d.entitas)?.label || d.entitas;
          return (
            <div key={d.id} className="rounded-xl bg-card border border-border p-4">
              <div className="flex flex-wrap items-baseline justify-between gap-3">
                <div>
                  <div className="text-xs text-muted-foreground">{ent} · {d.action} · {STATUS_LABEL[d.status] || d.status}</div>
                  <div className="font-display font-semibold mt-0.5">
                    {(d.payload?.judul || d.payload?.label || d.payload?.route || d.entitas_id || "Draft baru")}
                  </div>
                  <div className="text-xs text-muted-foreground mt-1">
                    Dibuat {new Date(d.created_at).toLocaleString("id-ID")}
                    {d.reviewed_at && ` · Direview ${new Date(d.reviewed_at).toLocaleString("id-ID")}`}
                    {d.published_at && ` · Publish ${new Date(d.published_at).toLocaleString("id-ID")}`}
                  </div>
                  {d.catatan && <div className="text-xs mt-1 opacity-80">Catatan: {d.catatan}</div>}
                </div>
                <div className="flex flex-wrap gap-2">
                  {d.status === "draft" && (
                    <button disabled={busyId === d.id} onClick={() => setStatus(d.id, "review")} className={btnSec}>Ajukan Review</button>
                  )}
                  {d.status === "review" && (
                    <>
                      <button disabled={busyId === d.id} onClick={() => setStatus(d.id, "draft")} className={btnSec}>Kembalikan</button>
                      <button disabled={busyId === d.id} onClick={() => setStatus(d.id, "rejected", { reviewed_at: new Date().toISOString() })} className={btnDanger}>Tolak</button>
                      <button disabled={busyId === d.id} onClick={() => publish(d.id)} className={btnPri}>Publish</button>
                    </>
                  )}
                  {d.status === "published" && (
                    <button disabled={busyId === d.id} onClick={() => rollback(d.id)} className={btnDanger}>Rollback</button>
                  )}
                  <button onClick={() => setOpenId(open ? null : d.id)} className={btnSec}>{open ? "Tutup" : "Detail"}</button>
                  {["draft","rejected","rolled_back"].includes(d.status) && (
                    <button onClick={() => hapus(d.id)} className={btnDanger}>Hapus</button>
                  )}
                </div>
              </div>
              {open && <DiffPreview draft={d} />}
            </div>
          );
        })}
      </div>
    </>
  );
}

function NewDraftButton({ onCreated }: { onCreated: () => void }) {
  const [open, setOpen] = useState(false);
  const [entitas, setEntitas] = useState("page_config");
  const [entitasId, setEntitasId] = useState("");
  const [rows, setRows] = useState<any[]>([]);
  const [payloadText, setPayloadText] = useState("{}");
  const [catatan, setCatatan] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    setEntitasId("");
    (supabase.from(entitas as any) as any).select("*").order("updated_at", { ascending: false })
      .then(({ data }: any) => setRows(data || []));
  }, [entitas]);

  useEffect(() => {
    if (!entitasId) { setPayloadText("{}"); return; }
    const r = rows.find((x) => x.id === entitasId);
    if (r) {
      const { id, created_at, updated_at, ...rest } = r;
      setPayloadText(JSON.stringify(rest, null, 2));
    }
  }, [entitasId, rows]);

  const create = async () => {
    let payload: any;
    try { payload = JSON.parse(payloadText); } catch { return toast.error("Payload bukan JSON valid."); }
    setBusy(true);
    const { error } = await (supabase.from("site_draft" as any) as any).insert({
      entitas, entitas_id: entitasId || null, action: entitasId ? "update" : "create",
      payload, catatan, status: "draft",
    });
    setBusy(false);
    if (error) return toast.error(error.message);
    toast.success("Draft dibuat.");
    setOpen(false); onCreated();
  };

  if (!open) return <button onClick={() => setOpen(true)} className={btnPri}>+ Draft Baru</button>;

  const rowLabel = (r: any) => r.judul || r.label || r.route || r.nama || r.id;

  return (
    <div className="mt-3 w-full rounded-xl bg-card border border-border p-4">
      <div className="grid sm:grid-cols-2 gap-3">
        <label className="text-sm">
          <span className="block text-xs mb-1">Entitas</span>
          <select value={entitas} onChange={(e) => setEntitas(e.target.value)} className={inp}>
            {ENTITAS.map((e) => <option key={e.value} value={e.value}>{e.label}</option>)}
          </select>
        </label>
        <label className="text-sm">
          <span className="block text-xs mb-1">Target (kosongkan untuk buat baru)</span>
          <select value={entitasId} onChange={(e) => setEntitasId(e.target.value)} className={inp}>
            <option value="">— buat baru —</option>
            {rows.map((r) => <option key={r.id} value={r.id}>{rowLabel(r)}</option>)}
          </select>
        </label>
      </div>
      <label className="block text-sm mt-3">
        <span className="block text-xs mb-1">Payload (JSON)</span>
        <textarea rows={8} value={payloadText} onChange={(e) => setPayloadText(e.target.value)} className={inp + " font-mono text-xs"} />
      </label>
      <label className="block text-sm mt-3">
        <span className="block text-xs mb-1">Catatan</span>
        <input value={catatan} onChange={(e) => setCatatan(e.target.value)} className={inp} placeholder="Deskripsi singkat perubahan" />
      </label>
      <div className="mt-3 flex gap-2">
        <button disabled={busy} onClick={create} className={btnPri}>Simpan Draft</button>
        <button onClick={() => setOpen(false)} className={btnSec}>Batal</button>
      </div>
    </div>
  );
}

// ============ Version history ============
export function SiteVersionAdmin() {
  const [entitas, setEntitas] = useState("page_config");
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(0);

  useEffect(() => {
    setLoading(true);
    (supabase.from("site_version" as any) as any).select("*").eq("entitas", entitas)
      .order("created_at", { ascending: false }).limit(500)
      .then(({ data }: any) => { setRows(data || []); setLoading(false); });
  }, [entitas, reload]);

  const restore = async (id: string) => {
    if (!confirm("Pulihkan ke versi ini? Perubahan saat ini akan tetap tersimpan sebagai versi baru.")) return;
    const { error } = await (supabase.rpc as any)("restore_site_version", { _version_id: id });
    if (error) return toast.error(error.message);
    toast.success("Versi dipulihkan.");
    setReload((k) => k + 1);
  };

  const grouped = useMemo(() => {
    const g: Record<string, any[]> = {};
    rows.forEach((r) => { (g[r.entitas_id] ||= []).push(r); });
    return g;
  }, [rows]);

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Riwayat Versi</h1>
        <p className="text-sm text-muted-foreground mt-1">Snapshot setiap perubahan pada halaman, navbar, dan footer. Pilih versi untuk dipulihkan.</p>
      </div>
      <div className="mb-4">
        <label className="text-sm">
          <span className="block text-xs mb-1">Entitas</span>
          <select value={entitas} onChange={(e) => setEntitas(e.target.value)} className={inp + " max-w-xs"}>
            {ENTITAS.map((e) => <option key={e.value} value={e.value}>{e.label}</option>)}
          </select>
        </label>
      </div>
      {loading ? <p className="text-muted-foreground">Memuat…</p> : (
        <div className="space-y-6">
          {Object.entries(grouped).map(([entId, list]) => (
            <div key={entId} className="rounded-xl bg-card border border-border overflow-hidden">
              <div className="bg-muted px-4 py-2 text-sm font-medium">
                {list[0]?.snapshot?.judul || list[0]?.snapshot?.label || list[0]?.snapshot?.route || entId}
              </div>
              <table className="w-full text-sm">
                <thead className="bg-muted/60">
                  <tr>
                    <th className="text-left px-3 py-2 w-16">v</th>
                    <th className="text-left px-3 py-2">Waktu</th>
                    <th className="text-left px-3 py-2">Aksi</th>
                    <th className="px-3 py-2"></th>
                  </tr>
                </thead>
                <tbody>
                  {list.map((v: any) => (
                    <tr key={v.id} className="border-t border-border">
                      <td className="px-3 py-2 tabular-nums">{v.versi}</td>
                      <td className="px-3 py-2">{new Date(v.created_at).toLocaleString("id-ID")}</td>
                      <td className="px-3 py-2 text-xs opacity-70">{v.note || "—"}</td>
                      <td className="px-3 py-2 text-right">
                        <button onClick={() => restore(v.id)} className={btnSec}>Pulihkan</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ))}
          {!Object.keys(grouped).length && <p className="text-muted-foreground">Belum ada snapshot.</p>}
        </div>
      )}
    </>
  );
}

// ============ Voting closure ============
export function VotingClosureAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(0);
  const [ringkasan, setRingkasan] = useState<Record<string, string>>({});
  const [busyId, setBusyId] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    (supabase.from("voting_topik" as any) as any).select("*").order("created_at", { ascending: false })
      .then(({ data }: any) => { setRows(data || []); setLoading(false); });
  }, [reload]);

  const tutup = async (id: string) => {
    setBusyId(id);
    const { error } = await (supabase.rpc as any)("tutup_voting_manual", { _topik_id: id, _ringkasan: ringkasan[id] || "" });
    setBusyId(null);
    if (error) return toast.error(error.message);
    toast.success("Voting ditutup & hasil dipublikasi.");
    setReload((k) => k + 1);
  };

  const simpanRingkasan = async (id: string) => {
    setBusyId(id);
    const { error } = await (supabase.from("voting_topik" as any) as any)
      .update({ hasil_ringkasan: ringkasan[id] || "", hasil_dipublikasi: true, hasil_dipublikasi_pada: new Date().toISOString() })
      .eq("id", id);
    setBusyId(null);
    if (error) return toast.error(error.message);
    toast.success("Ringkasan disimpan.");
    setReload((k) => k + 1);
  };

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Penutupan Voting</h1>
        <p className="text-sm text-muted-foreground mt-1">Voting akan otomatis ditutup 5 menit setelah tanggal berakhir. Anda juga bisa menutup manual dan menuliskan ringkasan alasan.</p>
      </div>
      {loading ? <p className="text-muted-foreground">Memuat…</p> : (
        <div className="space-y-3">
          {rows.map((r) => (
            <div key={r.id} className="rounded-xl bg-card border border-border p-4">
              <div className="flex flex-wrap items-baseline justify-between gap-3">
                <div>
                  <div className="font-display font-semibold">{r.judul}</div>
                  <div className="text-xs text-muted-foreground mt-1">
                    Status: {r.status} · Total suara: {r.total_suara}
                    {r.selesai && ` · Berakhir ${new Date(r.selesai).toLocaleString("id-ID")}`}
                    {r.hasil_dipublikasi && ` · Hasil dipublikasi ${r.hasil_dipublikasi_pada ? new Date(r.hasil_dipublikasi_pada).toLocaleString("id-ID") : ""}`}
                  </div>
                </div>
                <div className="flex gap-2">
                  {r.status !== "ditutup" && (
                    <button disabled={busyId === r.id} onClick={() => tutup(r.id)} className={btnPri}>Tutup & Publikasi Hasil</button>
                  )}
                  {r.status === "ditutup" && (
                    <button disabled={busyId === r.id} onClick={() => simpanRingkasan(r.id)} className={btnSec}>Simpan Ringkasan</button>
                  )}
                </div>
              </div>
              <textarea
                rows={3}
                placeholder="Ringkasan alasan pemenang / catatan hasil (tampil publik)"
                defaultValue={r.hasil_ringkasan || ""}
                onChange={(e) => setRingkasan({ ...ringkasan, [r.id]: e.target.value })}
                className={inp + " mt-3 text-sm"}
              />
            </div>
          ))}
          {!rows.length && <p className="text-muted-foreground">Belum ada topik voting.</p>}
        </div>
      )}
    </>
  );
}