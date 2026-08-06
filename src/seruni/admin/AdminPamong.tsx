/**
 * AdminPamong.tsx
 * Sistem Manajemen Data Pamong / Perangkat Desa
 */

import React, { useEffect, useState, useRef, useCallback } from "react";
import { supabase } from "@/integrations/supabase/client";
import { raw } from "@/seruni/lib/queries";
import { useTenantId } from "../lib/tenant";
import { uploadFile } from "../lib/upload";
import { toast } from "sonner";
import {
  Plus, Pencil, Trash2, Search, Grid3X3, TableProperties,
  Upload, User, ChevronUp, ChevronDown, Download, GripVertical,
  ToggleLeft, ToggleRight, X, Save, Eye, EyeOff,
} from "lucide-react";

interface Pamong {
  id: string;
  tenant_id: string;
  nama: string;
  jabatan: string;
  nip?: string | null;
  periode?: string | null;
  urutan: number;
  foto_url?: string | null;
  ttd_image_url?: string | null;
  qr_code_url?: string | null;
  aktif: boolean;
  created_at?: string;
  updated_at?: string;
}

const BLANK_PAMONG = {
  nama: "", jabatan: "", nip: "", periode: "",
  urutan: 0, foto_url: null, ttd_image_url: null, qr_code_url: null, aktif: true,
};

function toPublicUrl(path: string | null | undefined): string {
  if (!path) return "";
  if (path.startsWith("http")) return path;
  return supabase.storage.from("seruni-media").getPublicUrl(path).data.publicUrl;
}

function AvatarPlaceholder({ nama }: { nama: string }) {
  const initials = nama.split(" ").slice(0, 2).map((w: string) => w[0]?.toUpperCase() ?? "").join("");
  return (
    <div className="w-full h-full bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center text-white font-bold text-lg rounded-full">
      {initials || <User className="w-7 h-7" />}
    </div>
  );
}

function StatusBadge({ aktif }: { aktif: boolean }) {
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold ${aktif ? "bg-emerald-100 text-emerald-700" : "bg-gray-100 text-gray-500"}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${aktif ? "bg-emerald-500" : "bg-gray-400"}`} />
      {aktif ? "Aktif" : "Non-aktif"}
    </span>
  );
}

function UploadBtn({ label, value, onChange, kategori }: { label: string; value?: string | null; onChange: (url: string) => void; kategori: string }) {
  const ref = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    try {
      const result = await uploadFile(file, { entityType: "pamong", kategori: kategori as any });
      if (result?.url) { onChange(result.url); toast.success(`${label} diunggah`); }
      else toast.error(result?.error ?? "Gagal mengunggah");
    } finally { setUploading(false); if (ref.current) ref.current.value = ""; }
  };
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide">{label}</label>
      <div className="flex items-center gap-2">
        {value ? <img src={toPublicUrl(value)} alt={label} className="h-12 w-12 object-cover rounded border" /> : <div className="h-12 w-12 rounded border bg-gray-50 flex items-center justify-center"><Upload className="w-4 h-4 text-gray-300" /></div>}
        <button type="button" onClick={() => ref.current?.click()} disabled={uploading} className="text-xs px-3 py-1.5 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50 flex items-center gap-1">
          {uploading ? "Mengunggah..." : <><Upload className="w-3 h-3" /> {value ? "Ganti" : "Unggah"}</>}
        </button>
        {value && <button type="button" onClick={() => onChange("")} className="text-xs text-red-500 hover:underline">Hapus</button>}
      </div>
      <input ref={ref} type="file" accept="image/*" className="hidden" onChange={handleChange} />
    </div>
  );
}

function PamongModal({ data, onClose, onSave, jabatanList, tenantId }: { data: Partial<Pamong> | null; onClose: () => void; onSave: (p: Partial<Pamong>) => Promise<void>; jabatanList: string[]; tenantId: string }) {
  const isNew = !data?.id;
  const [form, setForm] = useState<Partial<Pamong>>(data ?? { ...BLANK_PAMONG, tenant_id: tenantId });
  const [busy, setBusy] = useState(false);
  const [customJabatan, setCustomJabatan] = useState(!jabatanList.includes(data?.jabatan ?? "") && !!data?.jabatan);
  const set = (key: keyof Pamong, val: unknown) => setForm(prev => ({ ...prev, [key]: val }));
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.nama?.trim()) return toast.error("Nama wajib diisi");
    if (!form.jabatan?.trim()) return toast.error("Jabatan wajib diisi");
    setBusy(true);
    try { await onSave(form); } finally { setBusy(false); }
  };
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b sticky top-0 bg-white z-10">
          <div>
            <h2 className="text-lg font-bold">{isNew ? "Tambah Pamong" : "Edit Pamong"}</h2>
            <p className="text-sm text-gray-500">Data perangkat / pamong desa</p>
          </div>
          <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-100"><X className="w-5 h-5" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          <div className="flex gap-4">
            <div className="flex-shrink-0">
              <div className="w-20 h-20 rounded-full overflow-hidden border-2 border-gray-200 bg-gray-50 cursor-pointer" onClick={() => document.getElementById("foto-up")?.click()}>
                {form.foto_url ? <img src={toPublicUrl(form.foto_url)} alt="Foto" className="w-full h-full object-cover" /> : <AvatarPlaceholder nama={form.nama ?? ""} />}
              </div>
              <p className="mt-1 text-xs text-emerald-600 hover:underline text-center cursor-pointer" onClick={() => document.getElementById("foto-up")?.click()}>Ganti foto</p>
              <input id="foto-up" type="file" accept="image/*" className="hidden" onChange={async (e) => { const f = e.target.files?.[0]; if (!f) return; const r = await uploadFile(f, { entityType: "pamong", kategori: "foto" as any }); if (r?.url) set("foto_url", r.url); e.target.value = ""; }} />
            </div>
            <div className="flex-1 space-y-3">
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Nama Lengkap <span className="text-red-500">*</span></label>
                <input type="text" value={form.nama ?? ""} onChange={e => set("nama", e.target.value)} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="Nama lengkap" />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">NIP / NIK</label>
                <input type="text" value={form.nip ?? ""} onChange={e => set("nip", e.target.value)} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="Nomor NIP atau NIK" />
              </div>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Jabatan <span className="text-red-500">*</span></label>
              {customJabatan ? (
                <div className="flex gap-2">
                  <input type="text" value={form.jabatan ?? ""} onChange={e => set("jabatan", e.target.value)} className="flex-1 border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="Tulis jabatan" autoFocus />
                  <button type="button" onClick={() => setCustomJabatan(false)} className="text-xs text-gray-500 border rounded-lg px-2">Pilih</button>
                </div>
              ) : (
                <div className="flex gap-2">
                  <select value={form.jabatan ?? ""} onChange={e => set("jabatan", e.target.value)} className="flex-1 border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">
                    <option value="">-- Pilih Jabatan --</option>
                    {jabatanList.map(j => <option key={j} value={j}>{j}</option>)}
                  </select>
                  <button type="button" onClick={() => { setCustomJabatan(true); set("jabatan", ""); }} className="text-xs text-gray-500 border rounded-lg px-2">+Baru</button>
                </div>
              )}
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Periode</label>
              <input type="text" value={form.periode ?? ""} onChange={e => set("periode", e.target.value)} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="Contoh: 2021 - 2027" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Urutan Tampil</label>
              <input type="number" value={form.urutan ?? 0} onChange={e => set("urutan", parseInt(e.target.value) || 0)} min={0} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Status</label>
              <button type="button" onClick={() => set("aktif", !form.aktif)} className={`flex items-center gap-2 px-3 py-2 rounded-lg border text-sm font-medium transition-colors w-full ${form.aktif ? "border-emerald-300 bg-emerald-50 text-emerald-700" : "border-gray-300 bg-gray-50 text-gray-500"}`}>
                {form.aktif ? <ToggleRight className="w-5 h-5" /> : <ToggleLeft className="w-5 h-5" />}
                {form.aktif ? "Aktif" : "Non-aktif"}
              </button>
            </div>
          </div>
          <div className="border rounded-xl p-4 bg-gray-50 space-y-4">
            <h3 className="text-sm font-semibold text-gray-700">Berkas Penandatanganan <span className="text-xs font-normal text-gray-400">(untuk TTE / surat resmi)</span></h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UploadBtn label="Gambar Tanda Tangan" value={form.ttd_image_url} onChange={url => set("ttd_image_url", url || null)} kategori="ttd" />
              <UploadBtn label="QR Code Verifikasi" value={form.qr_code_url} onChange={url => set("qr_code_url", url || null)} kategori="qr" />
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2 border-t">
            <button type="button" onClick={onClose} className="px-4 py-2 border rounded-lg text-sm hover:bg-gray-50">Batal</button>
            <button type="submit" disabled={busy} className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-sm font-semibold disabled:opacity-50 flex items-center gap-2">
              {busy ? "Menyimpan..." : <><Save className="w-4 h-4" /> Simpan</>}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function PamongCard({ item, onEdit, onDelete, onToggle, onMoveUp, onMoveDown, isFirst, isLast }: { item: Pamong; onEdit: () => void; onDelete: () => void; onToggle: () => void; onMoveUp: () => void; onMoveDown: () => void; isFirst: boolean; isLast: boolean }) {
  const fotoUrl = toPublicUrl(item.foto_url);
  return (
    <div className={`relative bg-white rounded-2xl border shadow-sm hover:shadow-md transition-all group ${!item.aktif ? "opacity-60" : ""}`}>
      <div className={`absolute top-3 right-3 w-2.5 h-2.5 rounded-full ${item.aktif ? "bg-emerald-400" : "bg-gray-300"}`} title={item.aktif ? "Aktif" : "Non-aktif"} />
      <div className="absolute top-3 left-3 flex flex-col gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
        <button onClick={onMoveUp} disabled={isFirst} className="p-0.5 rounded hover:bg-gray-100 disabled:opacity-30"><ChevronUp className="w-3.5 h-3.5 text-gray-500" /></button>
        <button onClick={onMoveDown} disabled={isLast} className="p-0.5 rounded hover:bg-gray-100 disabled:opacity-30"><ChevronDown className="w-3.5 h-3.5 text-gray-500" /></button>
      </div>
      <div className="p-5 flex flex-col items-center text-center">
        <div className="w-20 h-20 rounded-full overflow-hidden border-2 border-gray-100 bg-gray-50 mb-3 flex-shrink-0">
          {fotoUrl ? <img src={fotoUrl} alt={item.nama} className="w-full h-full object-cover" /> : <AvatarPlaceholder nama={item.nama} />}
        </div>
        <h3 className="font-bold text-gray-900 text-sm leading-tight">{item.nama}</h3>
        <p className="text-xs text-emerald-600 font-medium mt-0.5">{item.jabatan}</p>
        {item.nip && <p className="text-xs text-gray-400 mt-0.5">NIP: {item.nip}</p>}
        {item.periode && <p className="text-xs text-gray-400">Periode: {item.periode}</p>}
        <div className="mt-2"><StatusBadge aktif={item.aktif} /></div>
        {(item.ttd_image_url || item.qr_code_url) && (
          <div className="mt-2 flex gap-1 justify-center">
            {item.ttd_image_url && <span className="text-[10px] bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded-full border border-blue-100">TTD</span>}
            {item.qr_code_url && <span className="text-[10px] bg-purple-50 text-purple-600 px-1.5 py-0.5 rounded-full border border-purple-100">QR</span>}
          </div>
        )}
      </div>
      <div className="border-t px-3 py-2 flex justify-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
        <button onClick={onToggle} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-500" title={item.aktif ? "Nonaktifkan" : "Aktifkan"}>{item.aktif ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}</button>
        <button onClick={onEdit} className="p-1.5 rounded-lg hover:bg-emerald-50 text-emerald-600"><Pencil className="w-4 h-4" /></button>
        <button onClick={onDelete} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 className="w-4 h-4" /></button>
      </div>
    </div>
  );
}

export function AdminPamong() {
  const tenantId = useTenantId();
  const [list, setList] = useState<Pamong[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [filterJabatan, setFilterJabatan] = useState("");
  const [filterAktif, setFilterAktif] = useState<"" | "aktif" | "nonaktif">("");
  const [view, setView] = useState<"grid" | "table">("grid");
  const [modal, setModal] = useState<Partial<Pamong> | null | false>(false);
  const [deleteTarget, setDeleteTarget] = useState<Pamong | null>(null);

  const fetchData = useCallback(async () => {
    if (!tenantId) return;
    setLoading(true);
    try {
      const { data, error } = await raw.from("desa_pamong").select("*").eq("tenant_id", tenantId).order("urutan", { ascending: true });
      if (error) throw error;
      setList((data as Pamong[]) ?? []);
    } catch (e: any) { toast.error("Gagal memuat: " + e.message); }
    finally { setLoading(false); }
  }, [tenantId]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const jabatanList = [...new Set(list.map(p => p.jabatan).filter(Boolean))].sort();
  const filtered = list.filter(p => {
    const q = search.toLowerCase();
    return (!q || p.nama.toLowerCase().includes(q) || p.jabatan.toLowerCase().includes(q) || (p.nip ?? "").toLowerCase().includes(q))
      && (!filterJabatan || p.jabatan === filterJabatan)
      && (filterAktif === "" || (filterAktif === "aktif" ? p.aktif : !p.aktif));
  });

  const handleSave = async (form: Partial<Pamong>) => {
    if (!tenantId) return;
    const payload = { ...form, tenant_id: tenantId, nip: form.nip || null, periode: form.periode || null, foto_url: form.foto_url || null, ttd_image_url: form.ttd_image_url || null, qr_code_url: form.qr_code_url || null, updated_at: new Date().toISOString() };
    if (form.id) {
      const { error } = await raw.from("desa_pamong").update(payload).eq("id", form.id);
      if (error) throw error;
      toast.success("Berhasil diperbarui");
    } else {
      const maxUrutan = list.length > 0 ? Math.max(...list.map(p => p.urutan)) + 1 : 1;
      const { error } = await raw.from("desa_pamong").insert({ ...payload, urutan: form.urutan || maxUrutan });
      if (error) throw error;
      toast.success("Pamong ditambahkan");
    }
    setModal(false);
    fetchData();
  };

  const handleToggle = async (item: Pamong) => {
    const { error } = await raw.from("desa_pamong").update({ aktif: !item.aktif, updated_at: new Date().toISOString() }).eq("id", item.id);
    if (error) { toast.error("Gagal: " + error.message); return; }
    setList(prev => prev.map(p => p.id === item.id ? { ...p, aktif: !p.aktif } : p));
    toast.success(`${item.nama} ${!item.aktif ? "diaktifkan" : "dinonaktifkan"}`);
  };

  const handleDelete = async (item: Pamong) => {
    const { error } = await raw.from("desa_pamong").delete().eq("id", item.id);
    if (error) { toast.error("Gagal: " + error.message); return; }
    setList(prev => prev.filter(p => p.id !== item.id));
    toast.success("Berhasil dihapus");
    setDeleteTarget(null);
  };

  const handleMove = async (id: string, direction: "up" | "down") => {
    const idx = list.findIndex(p => p.id === id);
    if (idx < 0) return;
    const swapIdx = direction === "up" ? idx - 1 : idx + 1;
    if (swapIdx < 0 || swapIdx >= list.length) return;
    const newList = [...list];
    const a = { ...newList[idx] }; const b = { ...newList[swapIdx] };
    const tmp = a.urutan; a.urutan = b.urutan; b.urutan = tmp;
    newList[idx] = b; newList[swapIdx] = a;
    setList(newList);
    await Promise.all([raw.from("desa_pamong").update({ urutan: a.urutan }).eq("id", a.id), raw.from("desa_pamong").update({ urutan: b.urutan }).eq("id", b.id)]);
  };

  const exportCsv = () => {
    const headers = ["Nama", "Jabatan", "NIP", "Periode", "Urutan", "Status"];
    const rows = filtered.map(p => [p.nama, p.jabatan, p.nip ?? "", p.periode ?? "", p.urutan, p.aktif ? "Aktif" : "Non-aktif"]);
    const csv = [headers, ...rows].map(r => r.map(v => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
    const a = document.createElement("a"); a.href = URL.createObjectURL(new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" }));
    a.download = "pamong-desa.csv"; a.click();
  };

  const aktifCount = list.filter(p => p.aktif).length;

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Perangkat / Pamong Desa</h1>
          <p className="text-sm text-gray-500 mt-0.5">Kelola data struktur pamong desa — terkoneksi langsung dengan database</p>
          {!loading && (
            <div className="flex gap-3 mt-2">
              <span className="text-xs bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-full px-2 py-0.5">{aktifCount} Aktif</span>
              <span className="text-xs bg-gray-50 text-gray-500 border border-gray-200 rounded-full px-2 py-0.5">{list.length - aktifCount} Non-aktif</span>
              <span className="text-xs bg-blue-50 text-blue-700 border border-blue-200 rounded-full px-2 py-0.5">{jabatanList.length} Jabatan</span>
            </div>
          )}
        </div>
        <div className="flex gap-2 flex-shrink-0">
          <button onClick={exportCsv} className="flex items-center gap-1.5 px-3 py-2 border rounded-lg text-sm hover:bg-gray-50"><Download className="w-4 h-4" /> Ekspor</button>
          <button onClick={() => setModal({ ...BLANK_PAMONG, tenant_id: tenantId as string })} className="flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-sm font-semibold">
            <Plus className="w-4 h-4" /> Tambah Pamong
          </button>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row gap-3 mb-5">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input type="text" value={search} onChange={e => setSearch(e.target.value)} placeholder="Cari nama, jabatan, atau NIP..." className="w-full pl-9 pr-4 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500" />
        </div>
        <select value={filterJabatan} onChange={e => setFilterJabatan(e.target.value)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white">
          <option value="">Semua Jabatan</option>
          {jabatanList.map(j => <option key={j} value={j}>{j}</option>)}
        </select>
        <select value={filterAktif} onChange={e => setFilterAktif(e.target.value as any)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white">
          <option value="">Semua Status</option>
          <option value="aktif">Aktif</option>
          <option value="nonaktif">Non-aktif</option>
        </select>
        <div className="flex border rounded-lg overflow-hidden">
          <button onClick={() => setView("grid")} className={`px-3 py-2 text-sm ${view === "grid" ? "bg-emerald-600 text-white" : "hover:bg-gray-50 text-gray-600"}`}><Grid3X3 className="w-4 h-4" /></button>
          <button onClick={() => setView("table")} className={`px-3 py-2 text-sm ${view === "table" ? "bg-emerald-600 text-white" : "hover:bg-gray-50 text-gray-600"}`}><TableProperties className="w-4 h-4" /></button>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20"><div className="w-8 h-8 border-4 border-emerald-300 border-t-emerald-600 rounded-full animate-spin" /></div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 bg-gray-50 rounded-2xl border-2 border-dashed border-gray-200">
          <User className="w-12 h-12 text-gray-300 mx-auto mb-3" />
          <h3 className="font-semibold text-gray-500">{list.length === 0 ? "Belum ada data pamong" : "Tidak ada hasil pencarian"}</h3>
          <p className="text-sm text-gray-400 mt-1">{list.length === 0 ? 'Klik "Tambah Pamong" untuk memulai' : "Coba ubah kata kunci atau filter"}</p>
          {list.length === 0 && <button onClick={() => setModal({ ...BLANK_PAMONG, tenant_id: tenantId as string })} className="mt-4 px-4 py-2 bg-emerald-600 text-white rounded-lg text-sm font-semibold hover:bg-emerald-700"><Plus className="w-4 h-4 inline mr-1" />Tambah Pamong Pertama</button>}
        </div>
      ) : view === "grid" ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
          {filtered.map((item, idx) => <PamongCard key={item.id} item={item} onEdit={() => setModal(item)} onDelete={() => setDeleteTarget(item)} onToggle={() => handleToggle(item)} onMoveUp={() => handleMove(item.id, "up")} onMoveDown={() => handleMove(item.id, "down")} isFirst={idx === 0} isLast={idx === filtered.length - 1} />)}
        </div>
      ) : (
        <div className="overflow-x-auto border rounded-xl">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b">
              <tr>
                {["#", "Nama", "Jabatan", "NIP", "Periode", "Status", "TTD", "Aksi"].map(h => <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">{h}</th>)}
              </tr>
            </thead>
            <tbody className="divide-y">
              {filtered.map((item, idx) => (
                <tr key={item.id} className={`hover:bg-gray-50 ${!item.aktif ? "opacity-60" : ""}`}>
                  <td className="px-4 py-3 text-gray-400 text-xs"><div className="flex items-center gap-1"><GripVertical className="w-3.5 h-3.5 text-gray-300" />{item.urutan}</div></td>
                  <td className="px-4 py-3"><div className="flex items-center gap-3"><div className="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 bg-gray-100">{item.foto_url ? <img src={toPublicUrl(item.foto_url)} alt={item.nama} className="w-full h-full object-cover" /> : <AvatarPlaceholder nama={item.nama} />}</div><span className="font-medium text-gray-900">{item.nama}</span></div></td>
                  <td className="px-4 py-3 text-emerald-600 font-medium">{item.jabatan}</td>
                  <td className="px-4 py-3 text-gray-500 font-mono text-xs">{item.nip || "-"}</td>
                  <td className="px-4 py-3 text-gray-500 text-xs">{item.periode || "-"}</td>
                  <td className="px-4 py-3"><StatusBadge aktif={item.aktif} /></td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      {item.ttd_image_url && <span className="text-[10px] bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded-full border border-blue-100">TTD</span>}
                      {item.qr_code_url && <span className="text-[10px] bg-purple-50 text-purple-600 px-1.5 py-0.5 rounded-full border border-purple-100">QR</span>}
                      {!item.ttd_image_url && !item.qr_code_url && <span className="text-gray-300 text-xs">-</span>}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex justify-end gap-1">
                      <button onClick={() => handleMove(item.id, "up")} disabled={idx === 0} className="p-1.5 rounded hover:bg-gray-100 disabled:opacity-30 text-gray-400"><ChevronUp className="w-3.5 h-3.5" /></button>
                      <button onClick={() => handleMove(item.id, "down")} disabled={idx === filtered.length - 1} className="p-1.5 rounded hover:bg-gray-100 disabled:opacity-30 text-gray-400"><ChevronDown className="w-3.5 h-3.5" /></button>
                      <button onClick={() => handleToggle(item)} className="p-1.5 rounded hover:bg-gray-100 text-gray-400">{item.aktif ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}</button>
                      <button onClick={() => setModal(item)} className="p-1.5 rounded hover:bg-emerald-50 text-emerald-600"><Pencil className="w-3.5 h-3.5" /></button>
                      <button onClick={() => setDeleteTarget(item)} className="p-1.5 rounded hover:bg-red-50 text-red-500"><Trash2 className="w-3.5 h-3.5" /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 bg-gray-50 border-t text-xs text-gray-500">Menampilkan {filtered.length} dari {list.length} data</div>
        </div>
      )}

      {modal !== false && <PamongModal data={modal} onClose={() => setModal(false)} onSave={handleSave} jabatanList={jabatanList} tenantId={tenantId as string} />}

      {deleteTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-sm">
            <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4"><Trash2 className="w-6 h-6 text-red-500" /></div>
            <h3 className="text-lg font-bold text-center">Hapus Pamong?</h3>
            <p className="text-sm text-gray-500 text-center mt-1">Data <strong>{deleteTarget.nama}</strong> ({deleteTarget.jabatan}) akan dihapus permanen.</p>
            <div className="flex gap-3 mt-6">
              <button onClick={() => setDeleteTarget(null)} className="flex-1 py-2 border rounded-lg text-sm hover:bg-gray-50">Batal</button>
              <button onClick={() => handleDelete(deleteTarget)} className="flex-1 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg text-sm font-semibold">Hapus</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
