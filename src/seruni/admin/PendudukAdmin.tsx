import { useEffect, useState, useRef } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { PageTitle } from "./AdminPages";
import { ImageField } from "./AdminPages";
import { useTenantId } from "../lib/tenant";
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
  provinsi_id: string;
  kabupaten_id: string;
  kecamatan_id: string;
  desa_id: string;
  dusun_id: string;
  rw: string;
  rt: string;
  alamat: string;
  foto_url: string;
  status_hidup: string;
  catatan: string;
};

type Option = { value: string; label: string };

// ===================== Wilayah Cascade Select =====================
function WilayahSelect({ label, value, onChange, options, placeholder = "— pilih —" }: {
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

// ===================== Ref Relation Select =====================
function RefSelect({ label, value, onChange, table, valueCol, labelCol, placeholder = "— pilih —" }: {
  label: string; value: string; onChange: (v: string) => void;
  table: string; valueCol: string; labelCol: string; placeholder?: string;
}) {
  const [opts, setOpts] = useState<Option[]>([]);
  useEffect(() => {
    supabase.from(table).select(`${valueCol},${labelCol}`).eq("aktif", true).then(({ data }) => {
      if (data) {
        const sorted = [...data].sort((a: any, b: any) => String(a[labelCol]).localeCompare(String(b[labelCol])));
        setOpts(sorted.map((d: any) => ({ value: String(d[valueCol]), label: String(d[labelCol]) })));
      }
    });
  }, [table, valueCol, labelCol]);

  return (
    <div>
      <label className="block text-xs font-medium mb-1">{label}</label>
      <select value={value} onChange={e => onChange(e.target.value)} className={inp} autoComplete="off">
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
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [nikError, setNikError] = useState<string | null>(null);
  const [nikLoading, setNikLoading] = useState(false);
  const nikDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const tenantId = useTenantId();
  const pageSize = 50;
  const fileInputRef = useRef<HTMLInputElement>(null);

  const exportCSV = async () => {
    toast.loading("Menyiapkan data eksport...", { id: "export-csv" });
    const { data, error } = await supabase.from("penduduk").select("*");
    if (error) {
      toast.error(error.message, { id: "export-csv" });
      return;
    }
    if (!data || data.length === 0) {
      toast.error("Tidak ada data untuk dieksport", { id: "export-csv" });
      return;
    }
    
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
        const rows = results.data as any[];
        if (rows.length === 0) {
          toast.error("File CSV kosong", { id: "import-csv" });
          return;
        }
        
        try {
          // Find existing NIKs to map to IDs for smart upsert
          const niks = rows.map(r => String(r.nik)).filter(Boolean);
          const { data: existing } = await supabase
            .from("penduduk")
            .select("id, nik")
            .in("nik", niks);
            
          const nikToId = new Map(existing?.map(e => [e.nik, e.id]));
          
          const payload = rows.map((r: any) => {
            const processed = { ...r };
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
          
          toast.success(`Import berhasil (${rows.length} data diproses)`, { id: "import-csv" });
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

  // Ref data caches
  const [agamaOpts, setAgamaOpts] = useState<Option[]>([]);
  const [pendidikanOpts, setPendidikanOpts] = useState<Option[]>([]);
  const [pekerjaanOpts, setPekerjaanOpts] = useState<Option[]>([]);
  const [statusKawinOpts, setStatusKawinOpts] = useState<Option[]>([]);
  const [hubunganKkOpts, setHubunganKkOpts] = useState<Option[]>([]);
  const [kkOpts, setKkOpts] = useState<Option[]>([]);
  const [dusunOpts, setDusunOpts] = useState<Option[]>([]);

  // Wilayah cascade state
  const [provinsiOpts, setProvinsiOpts] = useState<Option[]>([]);
  const [kabupatenOpts, setKabupatenOpts] = useState<Option[]>([]);
  const [kecamatanOpts, setKecamatanOpts] = useState<Option[]>([]);
  const [desaOpts, setDesaOpts] = useState<Option[]>([]);

  useEffect(() => {
    // Load ref tables
    const loadRefs = async () => {
      const [ag, pd, pk, sk, hk, kk, ds, prov] = await Promise.all([
        supabase.from("ref_agama").select("kode,nama").order("urutan"),
        supabase.from("ref_pendidikan").select("nama,nama").order("urutan"),
        supabase.from("ref_pekerjaan").select("nama,nama").order("urutan"),
        supabase.from("ref_status_perkawinan").select("kode,nama").order("urutan"),
        supabase.from("ref_hubungan_keluarga").select("nama,nama").order("urutan"),
        supabase.from("keluarga").select("id,no_kk").order("no_kk"),
        supabase.from("ref_dusun").select("id,nama").order("urutan"),
        supabase.from("ref_provinsi").select("id,nama").order("urutan"),
      ]);
      setAgamaOpts(ag.data?.map((r: any) => ({ value: r.kode, label: r.nama })) ?? []);
      setPendidikanOpts(pd.data?.map((r: any) => ({ value: r.nama, label: r.nama })) ?? []);
      setPekerjaanOpts(pk.data?.map((r: any) => ({ value: r.nama, label: r.nama })) ?? []);
      setStatusKawinOpts(sk.data?.map((r: any) => ({ value: r.kode, label: r.nama })) ?? []);
      setHubunganKkOpts(hk.data?.map((r: any) => ({ value: r.nama, label: r.nama })) ?? []);
      setKkOpts(kk.data?.map((r: any) => ({ value: r.id, label: r.no_kk })) ?? []);
      setDusunOpts(ds.data?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []);
      setProvinsiOpts(prov.data?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []);
    };
    loadRefs();
  }, []);

  const load = () => {
    setLoading(true);
    let q = supabase.from("penduduk").select("*", { count: "exact" }).order("nama");
    if (search) q = q.ilike("nama", `%${search}%`);
    q = q.range((page - 1) * pageSize, page * pageSize - 1);
    q.then(({ data, count }: any) => {
      setRows(data || []);
      setTotalCount(count || 0);
      setLoading(false);
    });
  };

  useEffect(() => { load(); }, [search, page]);

  const blankRow = (): PendudukRow => ({
    nik: "", nama: "", jenis_kelamin: "L", tempat_lahir: "", tanggal_lahir: "",
    agama: "", pendidikan: "", pekerjaan: "", status_kawin: "", hubungan_kk: "",
    keluarga_id: "", provinsi_id: "", kabupaten_id: "", kecamatan_id: "",desa_id: "",
    dusun_id: "", rw: "", rt: "", alamat: "", foto_url: "", status_hidup: "hidup", catatan: "",
  });

  // Cascade: when provinsi changes, load kabupaten
  useEffect(() => {
    if (!draft?.provinsi_id) { setKabupatenOpts([]); setKecamatanOpts([]); setDesaOpts([]); return; }
    const prov = provinsiOpts.find(p => p.value === draft.provinsi_id);
    if (!prov) return;
    const provKode = prov.label === "Nusa Tenggara Barat" ? "52" : "";
    if (!provKode) return;
    supabase.from("ref_kabupaten").select("id,nama").eq("kode_provinsi", provKode).order("nama")
      .then(({ data }) => setKabupatenOpts(data?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
  }, [draft?.provinsi_id]);

  // Cascade: when kabupaten changes, load kecamatan
  useEffect(() => {
    if (!draft?.kabupaten_id) { setKecamatanOpts([]); setDesaOpts([]); return; }
    const kab = kabupatenOpts.find(k => k.value === draft.kabupaten_id);
    if (!kab) return;
    // Extract kode from label (e.g., "Lombok Timur" -> find by name)
    supabase.from("ref_kabupaten").select("kode").eq("id", kab.value).maybeSingle()
      .then(({ data }) => {
        if (data) {
          supabase.from("ref_kecamatan").select("id,nama").eq("kode_kabupaten", data.kode).order("nama")
            .then(({ data: d }) => setKecamatanOpts(d?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
        }
      });
  }, [draft?.kabupaten_id]);

  // Cascade: when kecamatan changes, load desa
  useEffect(() => {
    if (!draft?.kecamatan_id) { setDesaOpts([]); return; }
    const kec = kecamatanOpts.find(k => k.value === draft.kecamatan_id);
    if (!kec) return;
    supabase.from("ref_kecamatan").select("kode").eq("id", kec.value).maybeSingle()
      .then(({ data }) => {
        if (data) {
          supabase.from("ref_desa").select("id,nama").eq("kode_kecamatan", data.kode).order("nama")
            .then(({ data: d }) => setDesaOpts(d?.map((r: any) => ({ value: r.id, label: r.nama })) ?? []));
        }
      });
  }, [draft?.kecamatan_id]);

  const save = async (row: PendudukRow) => {
    const { id, ...payload } = row;
    if (!payload.nik || !/^\d{16}$/.test(payload.nik)) {
      setNikError("NIK harus 16 digit angka");
      return;
    }
    if (!payload.nama?.trim()) {
      toast.error("Nama harus diisi");
      return;
    }
    if (tenantId) payload.tenant_id = tenantId;
    const q = id
      ? supabase.update(payload).eq("id", id)
      : supabase.insert(payload);
    const { error } = await q;
    if (error) { toast.error(error.message); return; }
    toast.success("Tersimpan.");
    setDraft(null);
    setNikError(null);
    setPage(1);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus data penduduk ini?")) return;
    const { error } = await supabase.delete().eq("id", id);
    if (error) { toast.error(error.message); return; }
    toast.success("Terhapus.");
    load();
  };

  // NIK autofill — lookup by NIK, fill all fields
  const handleNikChange = (nik: string) => {
    setDraft((prev: any) => ({ ...prev, nik }));
    setNikError(null);
    setNikLoading(false);
    if (nikDebounceRef.current) clearTimeout(nikDebounceRef.current);
    if (/^\d{16}$/.test(nik)) {
      nikDebounceRef.current = setTimeout(async () => {
        setNikLoading(true);
        const { data: p } = await supabase.from("penduduk").select("*").eq("nik", nik).maybeSingle();
        if (!p) { setNikLoading(false); return; }
        const next: PendudukRow = {
          id: p.id,
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
          provinsi_id: p.provinsi_id || "",
          kabupaten_id: p.kabupaten_id || "",
          kecamatan_id: p.kecamatan_id || "",
          desa_id: p.desa_id || "",
          dusun_id: p.dusun_id || "",
          rw: p.rw || "",
          rt: p.rt || "",
          alamat: p.alamat || "",
          foto_url: p.foto_url || "",
          status_hidup: p.status_hidup || "hidup",
          catatan: p.catatan || "",
        };
        setDraft(next);
        setNikLoading(false);
        toast.success("Data ditemukan — field otomatis terisi.");
      }, 500);
    }
  };

  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));

  const FormFields = ({ row }: { row: PendudukRow }) => (
    <div className="grid sm:grid-cols-2 gap-3">
      {/* NIK */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">NIK (16 digit)</label>
        <input
          type="text"
          value={row.nik}
          maxLength={16}
          onChange={e => handleNikChange(e.target.value)}
          className={inp}
          placeholder="Ketik 16 digit NIK..."
          autoComplete="off"
        />
        {nikError && <p className="text-xs text-red-500 mt-1">{nikError}</p>}
        {nikLoading && <p className="text-xs text-blue-500 mt-1">Mencari data penduduk...</p>}
      </div>

      {/* Nama */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Nama Lengkap</label>
        <input value={row.nama} onChange={e => setDraft({ ...row, nama: e.target.value })} className={inp} autoComplete="off" />
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
        <input value={row.tempat_lahir} onChange={e => setDraft({ ...row, tempat_lahir: e.target.value })} className={inp} autoComplete="off" />
      </div>
      <div>
        <label className="block text-xs font-medium mb-1">Tanggal Lahir</label>
        <input type="date" value={row.tanggal_lahir} onChange={e => setDraft({ ...row, tanggal_lahir: e.target.value })} className={inp} autoComplete="off" />
      </div>

      {/* Ref dropdowns */}
      <RefSelect label="Agama" value={row.agama} onChange={v => setDraft({ ...row, agama: v })} table="ref_agama" valueCol="kode" labelCol="nama" />
      <RefSelect label="Pendidikan" value={row.pendidikan} onChange={v => setDraft({ ...row, pendidikan: v })} table="ref_pendidikan" valueCol="nama" labelCol="nama" />
      <RefSelect label="Pekerjaan" value={row.pekerjaan} onChange={v => setDraft({ ...row, pekerjaan: v })} table="ref_pekerjaan" valueCol="nama" labelCol="nama" />
      <RefSelect label="Status Kawin" value={row.status_kawin} onChange={v => setDraft({ ...row, status_kawin: v })} table="ref_status_perkawinan" valueCol="kode" labelCol="nama" />
      <RefSelect label="Hubungan dengan KK" value={row.hubungan_kk} onChange={v => setDraft({ ...row, hubungan_kk: v })} table="ref_hubungan_keluarga" valueCol="nama" labelCol="nama" />
      <RefSelect label="Kartu Keluarga" value={row.keluarga_id} onChange={v => setDraft({ ...row, keluarga_id: v })} table="keluarga" valueCol="id" labelCol="no_kk" />

      {/* Wilayah Cascade */}
      <div className="sm:col-span-2 border-t pt-3 mt-1">
        <p className="text-xs font-semibold mb-2 text-muted-foreground">WILAYAH</p>
        <div className="grid sm:grid-cols-3 gap-3">
          <WilayahSelect label="Provinsi" value={row.provinsi_id} onChange={v => setDraft({ ...row, provinsi_id: v, kabupaten_id: "", kecamatan_id: "", desa_id: "" })} options={provinsiOpts} />
          <WilayahSelect label="Kabupaten" value={row.kabupaten_id} onChange={v => setDraft({ ...row, kabupaten_id: v, kecamatan_id: "", desa_id: "" })} options={kabupatenOpts} />
          <WilayahSelect label="Kecamatan" value={row.kecamatan_id} onChange={v => setDraft({ ...row, kecamatan_id: v, desa_id: "" })} options={kecamatanOpts} />
          <WilayahSelect label="Desa/Kelurahan" value={row.desa_id} onChange={v => setDraft({ ...row, desa_id: v })} options={desaOpts} />
          <RefSelect label="Dusun" value={row.dusun_id} onChange={v => setDraft({ ...row, dusun_id: v })} table="ref_dusun" valueCol="id" labelCol="nama" />
          <div className="flex gap-2">
            <div className="flex-1">
              <label className="block text-xs font-medium mb-1">RT</label>
              <input value={row.rt} onChange={e => setDraft({ ...row, rt: e.target.value })} className={inp} placeholder="001" autoComplete="off" />
            </div>
            <div className="flex-1">
              <label className="block text-xs font-medium mb-1">RW</label>
              <input value={row.rw} onChange={e => setDraft({ ...row, rw: e.target.value })} className={inp} placeholder="001" autoComplete="off" />
            </div>
          </div>
        </div>
      </div>

      {/* Alamat */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Alamat Lengkap</label>
        <textarea rows={2} value={row.alamat} onChange={e => setDraft({ ...row, alamat: e.target.value })} className={inp} placeholder="Jl. ... No. ..." autoComplete="off" />
      </div>

      {/* Foto + Status */}
      <div className="sm:col-span-2">
        <label className="block text-xs font-medium mb-1">Foto Penduduk</label>
        <ImageField value={row.foto_url || ""} folder="penduduk" onChange={url => setDraft({ ...row, foto_url: url })} />
      </div>
      <div>
        <label className="block text-xs font-medium mb-1">Status</label>
        <select value={row.status_hidup} onChange={e => setDraft({ ...row, status_hidup: e.target.value })} className={inp} autoComplete="off">
          <option value="hidup">Hidup</option>
          <option value="meninggal">Meninggal</option>
          <option value="pindah">Pindah</option>
        </select>
      </div>
      <div>
        <label className="block text-xs font-medium mb-1">Catatan</label>
        <input value={row.catatan} onChange={e => setDraft({ ...row, catatan: e.target.value })} className={inp} autoComplete="off" />
      </div>
    </div>
  );

  return (
    <>
      <PageTitle title="Penduduk" desc="Data warga desa (NIK unik). Menjadi rujukan modul surat, bansos, pemilu, dan analisis." />

      <div className="flex flex-wrap gap-2 justify-between items-center mb-4">
        <div className="flex gap-2 items-center">
          <input type="search" placeholder="Cari nama..." value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} className="rounded-md border border-input bg-background px-3 py-2 text-sm w-48" autoComplete="off" />
          <span className="text-xs text-muted-foreground">{totalCount} data</span>
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
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <h3 className="font-display font-semibold mb-3">{draft.id ? "Edit" : "Tambah"} Penduduk</h3>
          <FormFields row={draft} />
          <div className="mt-4 flex gap-2">
            <button onClick={() => save(draft)} className={btnPri}>Simpan</button>
            <button onClick={() => { setDraft(null); setNikError(null); }} className={btnSec}>Batal</button>
          </div>
        </div>
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
            {rows.map((r: any) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 font-mono text-xs">{r.nik}</td>
                <td className="px-4 py-3">{r.nama}</td>
                <td className="px-4 py-3">{r.jenis_kelamin}</td>
                <td className="px-4 py-3">{r.dusun || "—"}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-0.5 rounded text-xs ${r.status_hidup === 'hidup' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                    {r.status_hidup}
                  </span>
                </td>
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

export function KeluargaAdmin() {
  return null; // delegated to AdminOps
}
