import React, { useState, useEffect, useRef, ReactNode } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger, DropdownMenuSeparator, DropdownMenuLabel } from "@/components/ui/dropdown-menu";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { MoreHorizontal, Plus, Search, FileDown, FileUp, Inbox, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "../lib/tenant";
import { useConfirm } from "../ui/ConfirmDialog";
import { RelationSelect } from "../admin/AdminPages"; 

import { uploadFile } from "../lib/upload";
export function RelationLabel({ relation, value }: { relation: any, value: string }) {
  const { data, isLoading } = useQuery({
    queryKey: ["relation-label", relation.table, value],
    queryFn: async () => {
      if (!value) return "";
      const { data, error } = await (supabase as any).from(relation.table).select(relation.labelCol).eq(relation.valueCol, value).maybeSingle();
      if (error || !data) return value;
      return String(data[relation.labelCol]);
    },
    enabled: !!value,
    staleTime: 60000,
  });
  if (isLoading) return <span className="text-muted-foreground animate-pulse">...</span>;
  return <span>{data || value}</span>;
}

export const ImageField = ({ value, folder, onChange }: any) => {
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState<string>(value || "");

  // Sync preview bila value prop berubah dari luar (misal: data load dari DB)
  React.useEffect(() => { setPreview(value || ""); }, [value]);

  const onFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setBusy(true);
    toast.info("Mengunggah gambar...");
    try {
      const result = await uploadFile(f, {
        entityType: "lainnya",
        kategori: folder || "lainnya",
      } as any);
      if (result.success && result.url) {
        setPreview(result.url);
        onChange(result.url);
        toast.success("Gambar berhasil diunggah");
      } else {
        toast.error(result.error || "Gagal unggah gambar");
      }
    } catch (err: any) {
      toast.error(err.message || "Terjadi kesalahan");
    } finally {
      setBusy(false);
    }
  };
  const handleRemove = () => { setPreview(""); onChange(""); };
  return (
    <div className="space-y-2">
      {preview ? (
        <div className="relative group rounded border overflow-hidden w-full max-w-[200px] aspect-video">
          <img src={preview.startsWith('http') || preview.startsWith('data:') ? preview : supabase.storage.from('seruni-media').getPublicUrl(preview).data.publicUrl} alt="Preview" className="w-full h-full object-cover bg-muted" />
          <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
            <Button variant="destructive" size="sm" type="button" onClick={handleRemove}>Hapus</Button>
          </div>
        </div>
      ) : (
        <div className="flex items-center gap-2">
          <input type="file" accept="image/*" onChange={onFile} disabled={busy} className="text-sm flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 file:bg-primary file:text-primary-foreground file:border-0 file:rounded file:px-2 file:py-1 file:mr-2 file:text-sm file:cursor-pointer" />
          {busy && <Loader2 className="w-4 h-4 animate-spin text-muted-foreground shrink-0" />}
        </div>
      )}
    </div>
  );
};

export const VideoField = ({ value, folder, onChange }: any) => {
  const [busy, setBusy] = useState(false);
  const onFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setBusy(true);
    toast.info("Mengunggah video...");
    try {
      const result = await uploadFile(f, {
        entityType: "lainnya",
        kategori: folder || "lainnya",
      } as any);
      if (result.success && result.url) {
        onChange(result.url);
        toast.success("Video berhasil diunggah");
      } else {
        toast.error(result.error || "Gagal unggah video");
      }
    } catch (err: any) {
      toast.error(err.message || "Terjadi kesalahan");
    } finally {
      setBusy(false);
    }
  };
  return (
    <div className="space-y-2">
      {value ? (
        <div className="relative group rounded border overflow-hidden w-full max-w-[300px] aspect-video">
          <video src={value.startsWith('http') || value.startsWith('data:') ? value : supabase.storage.from('seruni-media').getPublicUrl(value).data.publicUrl} controls className="w-full h-full object-cover bg-black" />
          <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity z-10">
            <Button variant="destructive" size="sm" type="button" onClick={() => onChange("")}>Hapus</Button>
          </div>
        </div>
      ) : (
        <div className="flex items-center gap-2">
          <input type="file" accept="video/mp4,video/webm" onChange={onFile} disabled={busy} className="text-sm flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 file:bg-primary file:text-primary-foreground file:border-0 file:rounded file:px-2 file:py-1 file:mr-2 file:text-sm file:cursor-pointer" />
          {busy && <Loader2 className="w-4 h-4 animate-spin text-muted-foreground shrink-0" />}
        </div>
      )}
    </div>
  );
};

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

export function TableCrud({
  table, columns, blank, title, desc,
  orderBy = "urutan", orderAsc = true,
  pageSize = 50,
  customActions,
}: {
  table: string;
  columns: Column[];
  blank: Record<string, any>;
  title: string;
  desc: string;
  orderBy?: string;
  orderAsc?: boolean;
  pageSize?: number;
  customActions?: (row: any) => ReactNode;
}) {
  const [draft, setDraft] = useState<any | null>(null);
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [nikError, setNikError] = useState<string | null>(null);
  const [nikLoading, setNikLoading] = useState(false);
  
  const tenantId = useTenantId();
  const confirm = useConfirm();
  const queryClient = useQueryClient();
  const nikDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const tenantTables = ["penduduk","keluarga","surat_ajuan","berita","aduan_warga","usulan_warga","apbdes","kegiatan_pembangunan","agenda","pengumuman","galeri","page_hero_config","desa_pamong","wilayah_dusun","lembaga_desa","hero_slider","nav_items","footer_columns","rpjmdes_periode","rpjmdes_bidang","rpjmdes_program","rkpdes_tahun","rkpdes_kegiatan","bidang_tanah","infrastruktur","posyandu_agregat","stunting_agregat","bantuan_sosial","penerima_bansos","bencana_kejadian","dpt_pemilih","surat_jenis","langganan_wa","pbb_tagihan","balita","potensi_umkm","potensi_produk","potensi_wisata","voting_topik","voting_opsi"];

  const { data, isLoading } = useQuery({
    queryKey: [table, { tenantId, search, page, orderBy, orderAsc }],
    queryFn: async () => {
      let q = (supabase as any).from(table).select("*", { count: "exact" }).order(orderBy, { ascending: orderAsc });
      if (tenantTables.includes(table)) q = q.eq("tenant_id", tenantId || "");
      if (search) {
        const searchCol = columns.find(c => c.type !== "number" && c.type !== "checkbox" && c.type !== "date" && c.type !== "select" && c.type !== "image");
        if (searchCol) q = q.ilike(searchCol.key, `%${search}%`);
      }
      q = q.range((page - 1) * pageSize, page * pageSize - 1);
      const { data, count, error } = await q;
      if (error) throw error;
      return { rows: data || [], total: count || 0 };
    },
  });

  const { rows, total: totalCount } = data || { rows: [], total: 0 };
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));

  const saveMutation = useMutation({
    mutationFn: async (row: any) => {
      const { id, ...payload } = row;
      const nikCol = columns.find(c => c.key === "nik" || c.label.toLowerCase().includes("nik"));
      if (nikCol && payload.nik && !/^\d{16}$/.test(String(payload.nik))) {
        throw new Error("NIK harus 16 digit angka");
      }
      if (tenantTables.includes(table) && !payload.tenant_id && tenantId) {
        payload.tenant_id = tenantId;
      }
      let q = id
        ? (supabase as any).from(table).update(payload).eq("id", id)
        : (supabase as any).from(table).insert(payload);
      if (id && tenantTables.includes(table)) q = q.eq("tenant_id", tenantId || "");
      const { error } = await q;
      if (error) throw error;
      return true;
    },
    onSuccess: () => {
      toast.success("Tersimpan.");
      setDraft(null);
      setNikError(null);
      queryClient.invalidateQueries({ queryKey: [table] });
    },
    onError: (err: any) => toast.error(err.message || "Gagal menyimpan")
  });

  const delMutation = useMutation({
    mutationFn: async (id: string) => {
      let q = (supabase as any).from(table).delete().eq("id", id);
      if (tenantTables.includes(table)) q = q.eq("tenant_id", tenantId || "");
      const { error } = await q;
      if (error) throw error;
      return true;
    },
    onSuccess: () => {
      toast.success("Terhapus.");
      queryClient.invalidateQueries({ queryKey: [table] });
    },
    onError: (err: any) => toast.error(err.message || "Gagal menghapus")
  });

  const save = (row: any) => saveMutation.mutate(row);
  const del = async (id: string) => {
    if (await confirm({ title: "Hapus baris ini?" })) delMutation.mutate(id);
  };

  const exportCsv = () => {
    const header = columns.filter(c => !c.hideInTable).map(c => c.label).join(",");
    const csvRows = rows.map((r: any) =>
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
          if (tenantTables.includes(table) && tenantId && !row.tenant_id) {
            row.tenant_id = tenantId;
          }
          const { error } = await (supabase as any).from(table).insert(row);
          if (error) failed++; else imported++;
        }
      }
      toast.success(`Impor selesai: ${imported} berhasil, ${failed} gagal`);
      queryClient.invalidateQueries({ queryKey: [table] });
    };
    reader.readAsText(file);
    e.target.value = "";
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">{title}</h2>
          <p className="text-sm text-muted-foreground">{desc}</p>
        </div>
        <div className="flex items-center gap-2">
          <label className="cursor-pointer">
            <Button variant="outline" size="sm" asChild>
              <span><FileUp className="w-4 h-4 mr-2" /> Import CSV</span>
            </Button>
            <input type="file" accept=".csv" className="hidden" onChange={importCsv} />
          </label>
          <Button variant="outline" size="sm" onClick={exportCsv}>
            <FileDown className="w-4 h-4 mr-2" /> Export CSV
          </Button>
          <Button size="sm" onClick={() => { setDraft({ ...blank }); setNikError(null); }}>
            <Plus className="w-4 h-4 mr-2" /> Tambah Baru
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader className="py-4 border-b border-border">
          <div className="flex items-center justify-between">
            <div className="relative w-64">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder="Cari data..."
                value={search}
                onChange={(e) => { setSearch(e.target.value); setPage(1); }}
                className="pl-9 h-9 bg-background"
              />
            </div>
            <div className="text-sm text-muted-foreground font-medium">
              Total: {totalCount} baris
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0 overflow-x-auto">
          <Table>
            <TableHeader className="bg-muted/50 sticky top-0 z-10 shadow-sm backdrop-blur-sm">
              <TableRow>
                {columns.filter((c) => !c.hideInTable).map((c) => (
                  <TableHead key={String(c.key)} className="font-semibold text-foreground/80 whitespace-nowrap">{c.label}</TableHead>
                ))}
                <TableHead className="w-[100px] text-right font-semibold text-foreground/80">Aksi</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i}>
                    {columns.filter((c) => !c.hideInTable).map((c, j) => (
                      <TableCell key={j} className="py-4">
                        <Skeleton className="h-5 w-full max-w-[200px]" />
                      </TableCell>
                    ))}
                    <TableCell className="py-4">
                      <Skeleton className="h-8 w-8 rounded-md ml-auto" />
                    </TableCell>
                  </TableRow>
                ))
              ) : rows.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={columns.length + 1} className="h-64 text-center">
                    <div className="flex flex-col items-center justify-center text-muted-foreground space-y-3">
                      <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center">
                        <Inbox className="w-6 h-6 opacity-50" />
                      </div>
                      <p className="text-base font-medium">Belum ada data</p>
                      <p className="text-sm opacity-70">Tambahkan data baru untuk melihat daftar di sini.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                rows.map((r: any) => (
                  <TableRow key={r.id} className="group hover:bg-muted/30 transition-colors">
                    {columns.filter((c) => !c.hideInTable).map((c) => (
                      <TableCell key={String(c.key)} className="py-3 px-4 align-middle">
                        {c.render ? c.render(r) : c.key === "status" ? (
                          <Badge variant={r[c.key]?.toLowerCase() === "menunggu" ? "destructive" : r[c.key]?.toLowerCase() === "diproses" ? "default" : "secondary"}>
                            {String(r[c.key] ?? "-")}
                          </Badge>
                        ) : c.type === "checkbox" ? (
                          r[c.key] ? <Badge variant="outline" className="bg-primary/10 text-primary border-primary/20">Ya</Badge> : <span className="text-muted-foreground">—</span>
                        ) : c.type === "image" ? (
                          r[c.key] ? <img src={String(r[c.key])} alt="" className="h-10 w-16 object-cover rounded border bg-muted" /> : <span className="text-muted-foreground opacity-50 text-xs">—</span>
                        ) : c.type === "video" ? (
                          r[c.key] ? <div className="h-10 w-16 bg-black rounded border flex items-center justify-center"><span className="text-[10px] text-white">Video</span></div> : <span className="text-muted-foreground opacity-50 text-xs">—</span>
                        ) : c.type === "relation" && c.relation ? (
                          <RelationLabel relation={c.relation} value={r[c.key] as string} />
                        ) : (
                          <span className="line-clamp-2 max-w-md">{String(r[c.key] ?? "")}</span>
                        )}
                      </TableCell>
                    ))}
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Aksi</DropdownMenuLabel>
                          <DropdownMenuItem onClick={() => { setDraft(r); setNikError(null); }}>
                            Edit
                          </DropdownMenuItem>
                          {customActions && customActions(r)}
                          <DropdownMenuSeparator />
                          <DropdownMenuItem className="text-destructive focus:text-destructive" onClick={() => r.id && del(r.id)}>
                            Hapus
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {totalPages > 1 && (
        <div className="flex justify-center gap-2 mt-4">
          <Button variant="outline" size="sm" disabled={page === 1} onClick={() => setPage(p => p - 1)}>Prev</Button>
          <div className="flex items-center px-4 text-sm font-medium">Halaman {page} / {totalPages}</div>
          <Button variant="outline" size="sm" disabled={page >= totalPages} onClick={() => setPage(p => p + 1)}>Next</Button>
        </div>
      )}

      {/* Form Dialog */}
      <Dialog open={!!draft} onOpenChange={(o) => { if (!o) { setDraft(null); setNikError(null); } }}>
        <DialogContent className="max-w-2xl max-h-[90vh] flex flex-col p-0 gap-0 overflow-hidden">
          <DialogHeader className="px-6 py-4 border-b border-border shrink-0 bg-muted/20">
            <DialogTitle className="text-xl">{draft?.id ? "Edit" : "Tambah"} Data</DialogTitle>
          </DialogHeader>
          <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
            <div className="grid sm:grid-cols-2 gap-x-6 gap-y-5">
              {draft && columns.map((c) => (
                  <div key={String(c.key)} className={c.type === "textarea" ? "sm:col-span-2" : ""}>
                    {c.type === "textarea" ? (
                      <div className="space-y-2">
                        <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                        <textarea
                          rows={4}
                          value={(draft[c.key] ?? "") as string}
                          onChange={(e) => setDraft({ ...draft, [c.key]: e.target.value })}
                          className="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 transition-shadow"
                          autoComplete="off"
                        />
                      </div>
                    ) : c.type === "checkbox" ? (
                      <div className="flex items-center space-x-3 mt-6 p-3 border border-border rounded-md bg-muted/10">
                        <input
                          type="checkbox"
                          checked={Boolean(draft[c.key])}
                          onChange={(e) => setDraft({ ...draft, [c.key]: e.target.checked })}
                          className="h-4 w-4 rounded border-primary text-primary focus:ring-primary transition-shadow"
                        />
                        <label className="text-sm font-medium leading-none cursor-pointer">Aktif</label>
                      </div>
                    ) : c.type === "select" ? (
                      <div className="space-y-2">
                        <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                        <select
                          value={(draft[c.key] ?? "") as string}
                          onChange={(e) => setDraft({ ...draft, [c.key]: e.target.value })}
                          className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 transition-shadow"
                          autoComplete="off"
                        >
                          <option value="" disabled>— pilih —</option>
                          {(c.options ?? []).map((o) => (
                            <option key={o.value} value={o.value}>{o.label}</option>
                          ))}
                        </select>
                      </div>
                    ) : c.type === "relation" && c.relation ? (
                      <div className="space-y-2">
                        <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                        <RelationSelect
                          relation={c.relation}
                          value={(draft[c.key] ?? "") as string}
                          onChange={(val) => setDraft({ ...draft, [c.key]: val })}
                          className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 transition-shadow"
                          filterValue={c.relation?.filterField ? (draft[c.relation.filterField] as string) : undefined}
                        />
                      </div>
                    ) : c.type === "image" ? (
                      <div className="space-y-2">
                        <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                        <ImageField
                          value={(draft[c.key] as string) || ""}
                          folder={c.imageFolder || table}
                          onChange={(url: string) => setDraft({ ...draft, [c.key]: url })}
                        />
                      </div>
                    ) : c.type === "video" ? (
                      <div className="space-y-2">
                        <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                        <VideoField
                          value={(draft[c.key] as string) || ""}
                          folder={c.imageFolder || table}
                          onChange={(url: string) => setDraft({ ...draft, [c.key]: url })}
                        />
                      </div>
                    ) : (
                      <div>
                        {(() => {
                          const isNikField = c.key === "nik" || c.label.toLowerCase().includes("nik");
                          const isEmailField = /email/i.test(c.label);
                          const isTeleponField = /telepon|telp|kontak|nomor.?wa|hp/i.test(c.label);
                          const isError = isNikField && nikError;
                          return (
                            <div className="space-y-2">
                              <label className="text-sm font-semibold tracking-tight">{c.label}</label>
                              <Input
                                type={c.type === "number" ? "number" : isTeleponField ? "tel" : isEmailField ? "email" : "text"}
                                step={c.step}
                                value={(draft[c.key] ?? "") as string | number}
                                className={isError ? "border-destructive focus-visible:ring-destructive" : "focus-visible:ring-primary transition-shadow"}
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
                                        setNikLoading(false);
                                        setDraft(next);
                                      }, 500);
                                    }
                                  }
                                }}
                              />
                              {isNikField && (nikError || nikLoading) && (
                                <p className="text-[0.8rem] mt-1 font-medium animate-in fade-in slide-in-from-top-1">
                                  {nikLoading ? <span className="text-blue-500">Mencari data penduduk...</span> : <span className="text-destructive">{nikError}</span>}
                                </p>
                              )}
                            </div>
                          );
                        })()}
                      </div>
                    )}
                  </div>
                ))}
            </div>
          </div>
          <DialogFooter className="px-6 py-4 border-t border-border bg-muted/20 shrink-0">
            <Button variant="outline" onClick={() => { setDraft(null); setNikError(null); }}>Batal</Button>
            <Button onClick={() => save(draft)} disabled={saveMutation.isPending} className="min-w-[120px]">
              {saveMutation.isPending ? <Loader2 className="w-4 h-4 animate-spin mr-2" /> : null}
              {saveMutation.isPending ? "Menyimpan..." : "Simpan"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
