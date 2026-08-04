import { useEffect, useState, useRef, useCallback } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { raw } from "../lib/queries";
import { PageTitle } from "./AdminPages";
import { ImageField } from "../components/TableCrud";
import { StandaloneFormOverlay } from "../ui";
import { useTenantId } from "../lib/tenant";
import { useConfirm } from "../ui/ConfirmDialog";
import Papa from "papaparse";

const inp = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary";
const btnPri = "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60";
const btnSec = "rounded-md border border-border bg-background px-3 py-1.5 text-sm hover:bg-muted";
const btnDanger = "rounded-md border border-destructive/40 text-destructive bg-background px-3 py-1.5 text-sm hover:bg-destructive/10";

type PendudukRow = {
  id?: string;
  nik: string;
  nama: string;
  jenis_kelamin: string;
  tempat_lahir: string;
  tanggal_lahir: string;
  agama: string;
  pendidikan: string;
  pekerjaan: string;
  status_kawin: string;
  hubungan_kk: string;
  keluarga_id: string;
  dusun: string;
  rt: string;
  rw: string;
  alamat: string;
  foto_url: string;
  status_hidup: string;
  catatan: string;
  nomor_hp: string;
  // UUID FK — populated when a ref match is found
  agama_id?: string;
  pendidikan_id?: string;
  pekerjaan_id?: string;
  status_perkawinan_id?: string;
  provinsi_id?: string;
  kabupaten_id?: string;
  kecamatan_id?: string;
  desa_id?: string;
  dusun_id?: string;
};

type Option = { value: string; label: string };

// ===================== Generic Ref Select (by label, with ID back-fill) =====================
// Stores label text as value so it matches existing data.
// When a match is found by label, also populates the _id FK field.
function RefSelect({
  label,
  value,
  onChange,
  table,
  valueCol,
  labelCol,
  placeholder = "— pilih —",
  onIdFound,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  table: string;
  valueCol: string;
  labelCol: string;
  placeholder?: string;
  onIdFound?: (id: string) => void;
}) {
  const [opts, setOpts] = useState<Option[]>([]);
  useEffect(() => {
    raw.from(table).select(`${valueCol},${labelCol}`).eq("aktif", true).then(({ data }: any) => {
      if (data) {
        const sorted = [...data].sort((a: any, b: any) => String(a[labelCol] || "").localeCompare(String(b[labelCol] || "")));
        setOpts(sorted.map((d: any) => ({
          value: String(d[labelCol] ?? ""),
          label: String(d[labelCol] ?? ""),
        })));
      }
    });
  }, [table, valueCol, labelCol]);

  const handleChange = (v: string) => {
    onChange(v);
    if (onIdFound) onIdFound(v);
  };

  return (
    <div>
      <label className="block text-xs font-medium mb-1">{label}</label>
      <select value={value} onChange={e => handleChange(e.target.value)} className={inp} autoComplete="off">
        <option value="">{placeholder}</option>
        {opts.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
    </div>
  );
}

// ===================== Wilayah Cascade Select =====================
function WilayahSelect({
  label, value, onChange, options, placeholder = "— pilih —"
}: {
  label: string; value: string; onChange: (v: string) => void;
  options: Option[]; placeholder?: string;
}) {
  return (
    <div>
      <label className="block text-xs font-medium mb-1">{label}</label>
      <select value={value} onChange={e => onChange(e.target.value)} className={inp} autoComplete="off">
        <option value="">{placeholder}</option>
        {options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
    </div>
  );
}

// ===================== RtRw Select =====================
function RtRwSelect({
  label, value, onChange, table, dusunId, placeholder = "— pilih —"
}: {
  label: string; value: string; onChange: (v: string) => void;
  table: string; dusunId?: string; placeholder?: string;
}) {
  const [opts, setOpts] = useState<Option[]>([]);
  useEffect(() => {
    if (!dusunId) { setOpts([]); return; }
    raw.from(table).select("nomor").eq("dusun_id", dusunId).then(({ data }: any) => {
      if (data) {
        const sorted = [...data].sort((a: any, b: any) => String(a.nomor || "").localeCompare(String(b.nomor || "")));
        setOpts(sorted.map((d: any) => ({
          value: String(d.nomor ?? ""),
          label: String(d.nomor ?? ""),
        })));
      }
    });
  }, [table, dusunId]);

  return (
    <div>
      <label className="block text-xs font-medium mb-1">{label}</label>
      <select value={value} onChange={e => onChange(e.target.value)} className={inp} autoComplete="off" disabled={!dusunId}>
        <option value="">{placeholder}</option>
        {opts.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
    </div>
  );
}

// ===================== Main PendudukAdmin Component =====================
export function PendudukAdmin() {
  const [rows, setRows] = useState<PendudukRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<PendudukRow | null>(null);
  const [search, setSearch] = useState("");
  const [filterDusun, setFilterDusun] = useState("");
  const [filterJk, setFilterJk] = useState("");
  const [filterStatus, setFilterStatus] = useState("");
  const [page, setPage] = useState(1);
  const confirm = useConfirm();
  const [totalCount, setTotalCount] = useState(0);
  const [nikError, setNikError] = useState<string | null>(null);
  const [nikLoading, setNikLoading] = useState(false);
  const nikDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const tenantId = useTenantId();
  const pageSize = 50;
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Ref data caches (for display)
  const [dusunNameMap, setDusunNameMap] = useState<Map<string, string>>(new Map());

  // Load dusun names for table display
  useEffect(() => {
    raw.from("ref_dusun").select("id,nama").eq("aktif", true).eq("tenant_id", tenantId).then(({ data }: any) => {
      if (data) {
        const m = new Map<string, string>();
        data.forEach((r: any) => m.set(r.id, r.nama));
        setDusunNameMap(m);
      }
    });
  }, [tenantId]);

  const exportCSV = async () => {
    toast.loading("Menyiapkan data eksport...", { id: "export-csv" });
    const { data, error } = await supabase.from("penduduk").select("*").eq("tenant_id", tenantId || "");
    if (error) { toast.error(error.message, { id: "export-csv" }); return; }
    if (!data || data.length === 0) { toast.error("Tidak ada data untuk dieksport", { id: "export-csv" }); return; }
    const csv = Papa.unparse(data);
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", `penduduk_eksport_${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    toast.success("Eksport berhasil", { id: "export-csv" });
  };

  const importCSV = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    toast.loading("Memproses file...", { id: "import-csv" });
    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: async (results) => {
        const csvRows = results.data as Record<string, unknown>[];
        if (csvRows.length === 0) { toast.error("File CSV kosong", { id: "import-csv" }); return; }
        try {
          const errors = [];
          for (let i = 0; i < csvRows.length; i++) {
             const row: any = csvRows[i];
             if (!row.nik || String(row.nik).length !== 16) errors.push(`Baris ${i + 2}: NIK harus 16 digit.`);
             if (!row.nama || String(row.nama).trim().length === 0) errors.push(`Baris ${i + 2}: Nama wajib diisi.`);
             if (!row.jenis_kelamin || !['L','P'].includes(String(row.jenis_kelamin).toUpperCase())) errors.push(`Baris ${i + 2}: Jenis kelamin harus L/P.`);
          }
          if (errors.length > 0) {
            toast.error(`Terdapat ${errors.length} baris tidak valid. Lihat console log.`, { id: "import-csv", duration: 5000 });
            console.error("CSV Import Validation Errors:", errors);
            return;
          }

          const niks = csvRows.map((r: any) => String(r.nik)).filter(Boolean);
          const { data: existing } = await supabase.from("penduduk").select("id, nik").eq("tenant_id", tenantId || "").in("nik", niks);
          const nikToId = new Map(existing?.map((e: any) => [e.nik, e.id]) ?? []);
          const payload = csvRows.map((r: any) => {
            const processed: any = { ...r };
            if (tenantId) processed.tenant_id = tenantId;
            if (processed.nik && nikToId.has(String(processed.nik))) {
              processed.id = nikToId.get(String(processed.nik));
            } else {
              delete processed.id;
            }
            return processed;
          });
          const { error } = await supabase.from("penduduk").upsert(payload);
          if (error) throw error;
          toast.success(`Import berhasil (${csvRows.length} data diproses)`, { id: "import-csv" });
          load();
        } catch (err: any) {
          toast.error(`Import gagal: ${err.message}`, { id: "import-csv" });
        } finally {
          if (fileInputRef.current) fileInputRef.current.value = "";
        }
      },
      error: (err) => {
        toast.error(`Gagal membaca file: ${err.message}`, { id: "import-csv" });
        if (fileInputRef.current) fileInputRef.current.value = "";
      }
    });
  };

  // Wilayah cascade state
  const [provinsiOpts, setProvinsiOpts] = useState<Option[]>([]);
  const [kabupatenOpts, setKabupatenOpts] = useState<Option[]>([]);
  const [kecamatanOpts, setKecamatanOpts] = useState<Option[]>([]);
  const [desaOpts, setDesaOpts] = useState<Option[]>([]);

  useEffect(() => {
    // Load provinsi (fixed: query by active flag or just all)
    raw.from("ref_provinsi").select("id,nama").order("nama")
      .then(({ data }: any) => setProvinsiOpts(data?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
  }, []);

  // Cascade: provinsi → kabupaten (by kode_provinsi prefix)
  useEffect(() => {
    if (!draft?.provinsi_id) { setKabupatenOpts([]); setKecamatanOpts([]); setDesaOpts([]); return; }
    const prov = provinsiOpts.find(p => p.value === draft.provinsi_id);
    if (!prov) return;
    raw.from("ref_provinsi").select("kode").eq("id", prov.value).maybeSingle()
      .then(({ data: pData }: any) => {
        if (pData?.kode) {
          raw.from("ref_kabupaten").select("id,nama").eq("kode_provinsi", pData.kode).order("nama")
            .then(({ data: kb }: any) => setKabupatenOpts(kb?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
        }
      });
  }, [draft?.provinsi_id, provinsiOpts]);

  // Cascade: kabupaten → kecamatan (by kode_kabupaten)
  useEffect(() => {
    if (!draft?.kabupaten_id) { setKecamatanOpts([]); setDesaOpts([]); return; }
    raw.from("ref_kabupaten").select("kode").eq("id", draft.kabupaten_id).maybeSingle()
      .then(({ data: kb }: any) => {
        if (kb?.kode) {
          raw.from("ref_kecamatan").select("id,nama").eq("kode_kabupaten", kb.kode).order("nama")
            .then(({ data: kec }: any) => setKecamatanOpts(kec?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
        }
      });
  }, [draft?.kabupaten_id]);

  // Cascade: kecamatan → desa (by kode_kecamatan)
  useEffect(() => {
    if (!draft?.kecamatan_id) { setDesaOpts([]); return; }
    raw.from("ref_kecamatan").select("kode").eq("id", draft.kecamatan_id).maybeSingle()
      .then(({ data: kec }: any) => {
        if (kec?.kode) {
          raw.from("ref_desa").select("id,nama").eq("kode_kecamatan", kec.kode).order("nama")
            .then(({ data: ds }: any) => setDesaOpts(ds?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
        }
      });
  }, [draft?.kecamatan_id]);

  const load = useCallback(() => {
    setLoading(true);
    let q = supabase.from("penduduk").select("*", { count: "exact" }).eq("tenant_id", tenantId || "").order("nama");
    if (search) {
      if (/^\d+$/.test(search)) {
        q = q.ilike("nik", `%${search}%`);
      } else {
        q = q.ilike("nama", `%${search}%`);
      }
    }
    if (filterDusun) q = q.eq("dusun", filterDusun);
    if (filterJk) q = q.eq("jenis_kelamin", filterJk);
    if (filterStatus) q = q.eq("status_hidup", filterStatus);
    
    q = q.range((page - 1) * pageSize, page * pageSize - 1);
    q.then(({ data, count }: any) => {
      setRows(data || []);
      setTotalCount(count || 0);
      setLoading(false);
    });
  }, [search, page, tenantId, filterDusun, filterJk, filterStatus]);

  useEffect(() => { load(); }, [load]);

  const blankRow = (): PendudukRow => ({
    nik: "", nama: "", jenis_kelamin: "L", tempat_lahir: "", tanggal_lahir: "",
    agama: "", pendidikan: "", pekerjaan: "", status_kawin: "", hubungan_kk: "",
    keluarga_id: "", dusun: "", rt: "", rw: "", alamat: "", foto_url: "",
    status_hidup: "hidup", catatan: "", nomor_hp: "",
  });

  const save = async (row: PendudukRow) => {
    const { id, agama_id, pendidikan_id, pekerjaan_id, status_perkawinan_id, provinsi_id, kabupaten_id, kecamatan_id, desa_id, dusun_id, ...payload } = row;
    if (!payload.nik || !/^\d{16}$/.test(payload.nik)) {
      setNikError("NIK harus 16 digit angka");
      return;
    }
    if (!payload.nama?.trim()) {
      toast.error("Nama harus diisi");
      return;
    }
    if (tenantId) (payload as Record<string, unknown>).tenant_id = tenantId;
    // Convert empty string → null for all UUID FK columns (Postgres rejects "" for uuid type)
    const uuidOrNull = (v: string | undefined) => (v && v.trim() !== "" ? v : null);
    (payload as Record<string, unknown>).agama_id = uuidOrNull(agama_id);
    (payload as Record<string, unknown>).pendidikan_id = uuidOrNull(pendidikan_id);
    (payload as Record<string, unknown>).pekerjaan_id = uuidOrNull(pekerjaan_id);
    (payload as Record<string, unknown>).status_perkawinan_id = uuidOrNull(status_perkawinan_id);
    (payload as Record<string, unknown>).provinsi_id = uuidOrNull(provinsi_id);
    (payload as Record<string, unknown>).kabupaten_id = uuidOrNull(kabupaten_id);
    (payload as Record<string, unknown>).kecamatan_id = uuidOrNull(kecamatan_id);
    (payload as Record<string, unknown>).desa_id = uuidOrNull(desa_id);
    (payload as Record<string, unknown>).dusun_id = uuidOrNull(dusun_id);
    // keluarga_id is also UUID — convert "" → null
    if ((payload as Record<string, unknown>).keluarga_id === "") (payload as Record<string, unknown>).keluarga_id = null;

    const q = id
      ? supabase.from("penduduk").update(payload).eq("id", id!)
      : supabase.from("penduduk").insert(payload as any);
    const { error } = await q;
    if (error) { toast.error(error.message); return; }
    toast.success("Tersimpan.");
    setDraft(null);
    setNikError(null);
    setPage(1);
    load();
  };

  const del = async (id: string) => {
    if (!(await confirm({ title: "Hapus data penduduk ini?" }))) return;
    const { error } = await supabase.from("penduduk").delete().eq("id", id);
    if (error) { toast.error(error.message); return; }
    toast.success("Terhapus.");
    load();
  };

  // NIK autofill — only if editing a NEW row (no id), lookup by NIK and fill fields
  const handleNikChange = (nik: string) => {
    setDraft((prev: any) => ({ ...prev, nik }));
    setNikError(null);
    setNikLoading(false);
    if (nikDebounceRef.current) clearTimeout(nikDebounceRef.current);
    if (/^\d{16}$/.test(nik)) {
      nikDebounceRef.current = setTimeout(async () => {
        setNikLoading(true);
        const { data: pData } = await supabase.from("penduduk").select("*").eq("tenant_id", tenantId || "").eq("nik", nik).maybeSingle();
        const p = pData as Record<string, unknown>;
        if (!p) { setNikLoading(false); return; }
        // Existing NIK found — only auto-fill if this is a NEW row (no id yet)
        setDraft((prev: any) => {
          if (prev?.id) {
            // Editing existing — just show success, don't overwrite
            toast.success("NIK ditemukan — data sudah terisi dari mode edit.", { duration: 3000 });
            return prev;
          }
          // New row — ask confirmation before overwrite
          toast.success("Data ditemukan. Field akan terisi otomatis.", { duration: 2000 });
          return {
            ...prev,
            nik: p.nik,
            nama: p.nama || "",
            jenis_kelamin: p.jenis_kelamin || "L",
            tempat_lahir: p.tempat_lahir || "",
            tanggal_lahir: p.tanggal_lahir || "",
            agama: p.agama || "",
            pendidikan: p.pendidikan || "",
            pekerjaan: p.pekerjaan || "",
            status_kawin: p.status_kawin || "",
            hubungan_kk: p.hubungan_kk || "",
            keluarga_id: p.keluarga_id || "",
            dusun: p.dusun || "",
            rt: p.rt || "",
            rw: p.rw || "",
            alamat: p.alamat || "",
            foto_url: p.foto_url || "",
            status_hidup: p.status_hidup || "hidup",
            catatan: p.catatan || "",
            nomor_hp: p.nomor_hp || "",
            // FK UUID fields — populate if available
            agama_id: p.agama_id || undefined,
            pendidikan_id: p.pendidikan_id || undefined,
            pekerjaan_id: p.pekerjaan_id || undefined,
            status_perkawinan_id: p.status_perkawinan_id || undefined,
            provinsi_id: p.provinsi_id || "",
            kabupaten_id: p.kabupaten_id || "",
            kecamatan_id: p.kecamatan_id || "",
            desa_id: p.desa_id || "",
            dusun_id: p.dusun_id || "",
          };
        });
        setNikLoading(false);
      }, 500);
    }
  };

  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));

  const renderFormFields = (row: PendudukRow) => (
    <div className="grid sm:grid-cols-2 gap-3">
      {/* NIK */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">NIK (16 digit) <span className="text-red-500">*</span></label>
        <input
          type="text"
          value={row.nik}
          maxLength={16}
          inputMode="numeric"
          onChange={e => handleNikChange(e.target.value.replace(/\D/g, ""))}
          className={inp}
          placeholder="Ketik 16 digit NIK..."
          autoComplete="off"
        />
        {nikError && <p className="text-xs text-red-500 mt-1">{nikError}</p>}
        {nikLoading && <p className="text-xs text-blue-500 mt-1">Mencari data penduduk...</p>}
        {!nikLoading && row.nik.length > 0 && row.nik.length < 16 && (
          <p className="text-xs text-muted-foreground mt-1">Sisa {16 - row.nik.length} digit</p>
        )}
      </div>

      {/* Nama */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Nama Lengkap <span className="text-red-500">*</span></label>
        <input value={row.nama} onChange={e => setDraft({ ...row, nama: e.target.value })} className={inp} placeholder="Nama sesuai KTP" autoComplete="off" />
      </div>

      {/* Gender + TTL */}
      <div>
        <label className="block text-xs font-medium mb-1">Jenis Kelamin</label>
        <select value={row.jenis_kelamin} onChange={e => setDraft({ ...row, jenis_kelamin: e.target.value })} className={inp} autoComplete="off">
          <option value="L">Laki-laki</option>
          <option value="P">Perempuan</option>
        </select>
      </div>
      <div>
        <label className="block text-xs font-medium mb-1">Tempat Lahir</label>
        <input value={row.tempat_lahir} onChange={e => setDraft({ ...row, tempat_lahir: e.target.value })} className={inp} placeholder="Kota/Kabupaten lahir" autoComplete="off" />
      </div>
      <div>
        <label className="block text-xs font-medium mb-1">Tanggal Lahir</label>
        <input type="date" value={row.tanggal_lahir} onChange={e => setDraft({ ...row, tanggal_lahir: e.target.value })} className={inp} autoComplete="off" />
      </div>

      {/* Ref dropdowns — by label, back-fill UUID when match found */}
      <RefSelect label="Agama" value={row.agama} onChange={v => setDraft({ ...row, agama: v })} table="ref_agama" valueCol="kode" labelCol="nama"
        onIdFound={(label) => {
          raw.from("ref_agama").select("id,nama").eq("nama", label).maybeSingle()
            .then(({ data: d }: any) => { if (d?.id) setDraft((prev: any) => ({ ...prev, agama_id: d.id })); });
        }}
      />
      <RefSelect label="Pendidikan" value={row.pendidikan} onChange={v => setDraft({ ...row, pendidikan: v })} table="ref_pendidikan" valueCol="nama" labelCol="nama"
        onIdFound={(label) => {
          raw.from("ref_pendidikan").select("id,nama").eq("nama", label).maybeSingle()
            .then(({ data: d }: any) => { if (d?.id) setDraft((prev: any) => ({ ...prev, pendidikan_id: d.id })); });
        }}
      />
      <RefSelect label="Pekerjaan" value={row.pekerjaan} onChange={v => setDraft({ ...row, pekerjaan: v })} table="ref_pekerjaan" valueCol="nama" labelCol="nama"
        onIdFound={(label) => {
          raw.from("ref_pekerjaan").select("id,nama").eq("nama", label).maybeSingle()
            .then(({ data: d }: any) => { if (d?.id) setDraft((prev: any) => ({ ...prev, pekerjaan_id: d.id })); });
        }}
      />
      <RefSelect label="Status Perkawinan" value={row.status_kawin} onChange={v => setDraft({ ...row, status_kawin: v })} table="ref_status_perkawinan" valueCol="kode" labelCol="nama"
        onIdFound={(label) => {
          raw.from("ref_status_perkawinan").select("id,nama").eq("nama", label).maybeSingle()
            .then(({ data: d }: any) => { if (d?.id) setDraft((prev: any) => ({ ...prev, status_perkawinan_id: d.id })); });
        }}
      />
      <RefSelect label="Hubungan dengan KK" value={row.hubungan_kk} onChange={v => setDraft({ ...row, hubungan_kk: v })} table="ref_hubungan_keluarga" valueCol="nama" labelCol="nama" />
      <RefSelect label="Nomor Kartu Keluarga (KK)" value={row.keluarga_id} onChange={v => setDraft({ ...row, keluarga_id: v })} table="keluarga" valueCol="id" labelCol="no_kk" placeholder="— pilih KK —" />

      {/* Alamat */}
      <div className="sm:col-span-2 border-t pt-3 mt-1">
        <p className="text-xs font-semibold mb-2 text-muted-foreground">WILAYAH &amp; ALAMAT</p>
        <div className="grid sm:grid-cols-3 gap-3">
          <WilayahSelect label="Provinsi" value={row.provinsi_id || ""} onChange={v => setDraft({ ...row, provinsi_id: v, kabupaten_id: "", kecamatan_id: "", desa_id: "" })} options={provinsiOpts} />
          <WilayahSelect label="Kabupaten/Kota" value={row.kabupaten_id || ""} onChange={v => setDraft({ ...row, kabupaten_id: v, kecamatan_id: "", desa_id: "" })} options={kabupatenOpts} />
          <WilayahSelect label="Kecamatan" value={row.kecamatan_id || ""} onChange={v => setDraft({ ...row, kecamatan_id: v, desa_id: "" })} options={kecamatanOpts} />
          <WilayahSelect label="Desa/Kelurahan" value={row.desa_id || ""} onChange={v => setDraft({ ...row, desa_id: v })} options={desaOpts} />
          <RefSelect label="Dusun" value={row.dusun || ""} onChange={v => setDraft({ ...row, dusun: v })} table="ref_dusun" valueCol="id" labelCol="nama"
            onIdFound={(label) => {
              raw.from("ref_dusun").select("id,nama").eq("nama", label).maybeSingle()
                .then(({ data: d }: any) => { if (d?.id) setDraft((prev: any) => ({ ...prev, dusun_id: d.id })); });
            }}
          />
          <div className="flex gap-2">
            <div className="flex-1">
              <RtRwSelect label="RT" value={row.rt || ""} onChange={v => setDraft({ ...row, rt: v })} table="ref_rt" dusunId={row.dusun_id} />
            </div>
            <div className="flex-1">
              <RtRwSelect label="RW" value={row.rw || ""} onChange={v => setDraft({ ...row, rw: v })} table="ref_rw" dusunId={row.dusun_id} />
            </div>
          </div>
        </div>
      </div>

      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Alamat Lengkap</label>
        <textarea rows={2} value={row.alamat} onChange={e => setDraft({ ...row, alamat: e.target.value })} className={inp} placeholder="Jl. ... No. ..." autoComplete="off" />
      </div>

      {/* Kontak */}
      <div>
        <label className="block text-xs font-medium mb-1">Nomor HP / WhatsApp</label>
        <input type="tel" value={row.nomor_hp} onChange={e => setDraft({ ...row, nomor_hp: e.target.value })} className={inp} placeholder="08xxxxxxxxxx" autoComplete="off" />
      </div>

      {/* Status + Catatan */}
      <div>
        <label className="block text-xs font-medium mb-1">Status</label>
        <select value={row.status_hidup} onChange={e => setDraft({ ...row, status_hidup: e.target.value })} className={inp} autoComplete="off">
          <option value="hidup">Hidup</option>
          <option value="meninggal">Meninggal</option>
          <option value="pindah">Pindah</option>
        </select>
      </div>
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Catatan</label>
        <input value={row.catatan} onChange={e => setDraft({ ...row, catatan: e.target.value })} className={inp} placeholder="Catatan opsional..." autoComplete="off" />
      </div>

      {/* Foto */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Foto Penduduk</label>
        <ImageField value={row.foto_url || ""} folder="penduduk" onChange={(url: string) => setDraft({ ...row, foto_url: url })} />
      </div>
    </div>
  );

  return (
    <>
      <PageTitle title="Penduduk" desc="Data warga desa (NIK unik). Menjadi rujukan modul surat, bansos, pemilu, dan analisis." />

      <div className="flex flex-wrap gap-2 justify-between items-center mb-4">
        <div className="flex gap-2 items-center flex-wrap">
          <input type="search" placeholder="Cari NIK/Nama..." value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} className="rounded-md border border-input bg-background px-3 py-2 text-sm w-48" autoComplete="off" />
          <select value={filterJk} onChange={e => { setFilterJk(e.target.value); setPage(1); }} className="rounded-md border border-input bg-background px-3 py-2 text-sm">
            <option value="">Semua JK</option>
            <option value="L">Laki-laki</option>
            <option value="P">Perempuan</option>
          </select>
          <select value={filterStatus} onChange={e => { setFilterStatus(e.target.value); setPage(1); }} className="rounded-md border border-input bg-background px-3 py-2 text-sm">
            <option value="">Semua Status</option>
            <option value="hidup">Hidup</option>
            <option value="meninggal">Meninggal</option>
            <option value="pindah">Pindah</option>
          </select>
          {Array.from(dusunNameMap.values()).length > 0 && (
            <select value={filterDusun} onChange={e => { setFilterDusun(e.target.value); setPage(1); }} className="rounded-md border border-input bg-background px-3 py-2 text-sm">
              <option value="">Semua Dusun</option>
              {Array.from(dusunNameMap.values()).map(d => (
                <option key={d} value={d}>{d}</option>
              ))}
            </select>
          )}
          <span className="text-xs text-muted-foreground ml-2">{totalCount} data</span>
        </div>
        <div className="flex gap-2">
          <button onClick={exportCSV} className={btnSec}>Eksport CSV</button>
          <input type="file" accept=".csv" ref={fileInputRef} onChange={importCSV} className="hidden" />
          <button onClick={() => fileInputRef.current?.click()} className={btnSec}>Import CSV</button>
          <button onClick={() => setDraft(blankRow())} className={btnPri}>+ Tambah Penduduk</button>
        </div>
      </div>

      {/* Form Overlay */}
      {draft && (
        <StandaloneFormOverlay title={`${draft.id ? "Edit" : "Tambah"} Penduduk`} onClose={() => { setDraft(null); setNikError(null); }}>
          <div className="space-y-4">
            {renderFormFields(draft)}
            <div className="flex justify-end gap-3 pt-4 border-t border-current/10 mt-6">
              <button onClick={() => { setDraft(null); setNikError(null); }} className="px-4 py-2 text-sm bg-secondary text-secondary-foreground rounded-lg hover:opacity-90">Batal</button>
              <button onClick={() => save(draft)} className="px-4 py-2 text-sm bg-primary text-primary-foreground rounded-lg hover:opacity-90">Simpan</button>
            </div>
          </div>
        </StandaloneFormOverlay>
      )}

      {/* Table */}
      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3 font-display font-semibold">NIK</th>
              <th className="text-left px-4 py-3 font-display font-semibold">Nama</th>
              <th className="text-left px-4 py-3 font-display font-semibold">JK</th>
              <th className="text-left px-4 py-3 font-display font-semibold">Dusun</th>
              <th className="text-left px-4 py-3 font-display font-semibold">Status</th>
              <th className="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={6} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={6} className="px-4 py-6 text-center text-muted-foreground">Belum ada data.</td></tr>}
            {rows.map((r: any) => {
              const dusunName = dusunNameMap.get(r.dusun_id) || r.dusun || "—";
              return (
                <tr key={r.id} className="border-t border-border">
                  <td className="px-4 py-3 font-mono text-xs">{r.nik}</td>
                  <td className="px-4 py-3">{r.nama}</td>
                  <td className="px-4 py-3">{r.jenis_kelamin}</td>
                  <td className="px-4 py-3">{dusunName}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded text-xs ${r.status_hidup === 'hidup' ? 'bg-green-100 text-green-700' : r.status_hidup === 'meninggal' ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700'}`}>
                      {r.status_hidup}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                    <button onClick={() => setDraft({
                      id: r.id,
                      nik: r.nik || "",
                      nama: r.nama || "",
                      jenis_kelamin: r.jenis_kelamin || "L",
                      tempat_lahir: r.tempat_lahir || "",
                      tanggal_lahir: r.tanggal_lahir || "",
                      agama: r.agama || "",
                      pendidikan: r.pendidikan || "",
                      pekerjaan: r.pekerjaan || "",
                      status_kawin: r.status_kawin || "",
                      hubungan_kk: r.hubungan_kk || "",
                      keluarga_id: r.keluarga_id || "",
                      dusun: r.dusun || "",
                      rt: r.rt || "",
                      rw: r.rw || "",
                      alamat: r.alamat || "",
                      foto_url: r.foto_url || "",
                      status_hidup: r.status_hidup || "hidup",
                      catatan: r.catatan || "",
                      nomor_hp: r.nomor_hp || "",
                      agama_id: r.agama_id,
                      pendidikan_id: r.pendidikan_id,
                      pekerjaan_id: r.pekerjaan_id,
                      status_perkawinan_id: r.status_perkawinan_id,
                      provinsi_id: r.provinsi_id || "",
                      kabupaten_id: r.kabupaten_id || "",
                      kecamatan_id: r.kecamatan_id || "",
                      desa_id: r.desa_id || "",
                      dusun_id: r.dusun_id,
                    })} className={btnSec}>Edit</button>
                    <button onClick={() => r.id && del(r.id)} className={btnDanger}>Hapus</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-end gap-1 mt-4">
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


