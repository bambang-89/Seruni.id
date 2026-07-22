import { useEffect, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { TableCrud } from "./AdminPages";

const inp = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary";
const btnPri = "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60";
const btnSec = "rounded-md border border-border bg-background px-3 py-1.5 text-sm hover:bg-muted";

// -------- RPJMDes Periode --------
export function RpjmdesPeriodeAdmin() {
  return (
    <TableCrud
      table="rpjmdes_periode"
      title="RPJMDes — Periode"
      desc="Periode Rencana Pembangunan Jangka Menengah Desa."
      orderBy="tahun_mulai"
      orderAsc={false}
      blank={{ nama: "", tahun_mulai: 2024, tahun_selesai: 2030, visi: "", misi: [], status: "draft", published: false } as any}
      columns={[
        { key: "nama", label: "Nama Periode" },
        { key: "tahun_mulai", label: "Tahun Mulai", type: "number" },
        { key: "tahun_selesai", label: "Tahun Selesai", type: "number" },
        { key: "visi", label: "Visi", type: "textarea" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "draft", label: "Draft" },
          { value: "aktif", label: "Aktif" },
          { value: "selesai", label: "Selesai" },
        ]},
        { key: "published", label: "Publish", type: "checkbox" },
      ]}
    />
  );
}

// -------- RPJMDes Bidang --------
function useSelectOptions(table: string, labelKey: string, valueKey = "id", filter?: (r: any) => boolean) {
  const [opts, setOpts] = useState<{ value: string; label: string }[]>([]);
  useEffect(() => {
    (supabase.from(table as any) as any).select("*").then(({ data }: any) => {
      const rows = (data || []).filter((r: any) => (filter ? filter(r) : true));
      setOpts(rows.map((r: any) => ({ value: r[valueKey], label: r[labelKey] })));
    });
  }, [table]);
  return opts;
}

export function RpjmdesBidangAdmin() {
  const periodeOpts = useSelectOptions("rpjmdes_periode", "nama");
  return (
    <TableCrud
      table="rpjmdes_bidang"
      title="RPJMDes — Bidang"
      desc="Bidang prioritas per periode RPJMDes."
      orderBy="urutan"
      blank={{ periode_id: "", kode: "", nama: "", deskripsi: "", urutan: 0 } as any}
      columns={[
        { key: "periode_id", label: "Periode", type: "select", options: periodeOpts },
        { key: "kode", label: "Kode" },
        { key: "nama", label: "Nama Bidang" },
        { key: "deskripsi", label: "Deskripsi", type: "textarea" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

export function RpjmdesProgramAdmin() {
  const bidangOpts = useSelectOptions("rpjmdes_bidang", "nama");
  return (
    <TableCrud
      table="rpjmdes_program"
      title="RPJMDes — Program"
      desc="Program pembangunan di setiap bidang RPJMDes."
      orderBy="urutan"
      blank={{ bidang_id: "", nama: "", indikator: "", target: "", sumber_dana: "", tahun_mulai: null, tahun_selesai: null, anggaran_indikatif: 0, urutan: 0 } as any}
      columns={[
        { key: "bidang_id", label: "Bidang", type: "select", options: bidangOpts },
        { key: "nama", label: "Nama Program" },
        { key: "indikator", label: "Indikator", type: "textarea" },
        { key: "target", label: "Target" },
        { key: "sumber_dana", label: "Sumber Dana" },
        { key: "tahun_mulai", label: "Tahun Mulai", type: "number" },
        { key: "tahun_selesai", label: "Tahun Selesai", type: "number" },
        { key: "anggaran_indikatif", label: "Anggaran (Rp)", type: "number" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

export function RkpdesTahunAdmin() {
  return (
    <TableCrud
      table="rkpdes_tahun"
      title="RKPDes — Tahun"
      desc="Tahun anggaran RKPDes."
      orderBy="tahun"
      orderAsc={false}
      blank={{ tahun: new Date().getFullYear(), tgl_musdes: null, catatan: "", published: false } as any}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "tgl_musdes", label: "Tanggal Musdes", type: "date" },
        { key: "catatan", label: "Catatan", type: "textarea" },
        { key: "published", label: "Publish", type: "checkbox" },
      ]}
    />
  );
}

export function RkpdesKegiatanAdmin() {
  const tahunOpts = useSelectOptions("rkpdes_tahun", "tahun");
  const bidangOpts = useSelectOptions("rpjmdes_bidang", "nama");
  return (
    <TableCrud
      table="rkpdes_kegiatan"
      title="RKPDes — Kegiatan"
      desc="Kegiatan tahunan RKPDes beserta anggaran dan realisasi."
      orderBy="urutan"
      blank={{
        tahun_id: "", bidang_id: null, nama: "", lokasi: "", dusun: "", volume: "", satuan: "",
        anggaran: 0, sumber_dana: "", pelaksana: "", waktu: "", status_realisasi: "rencana", progress_pct: 0, urutan: 0,
      } as any}
      columns={[
        { key: "tahun_id", label: "Tahun", type: "select", options: tahunOpts },
        { key: "bidang_id", label: "Bidang (opsional)", type: "select", options: [{ value: "", label: "— tidak dipilih —" }, ...bidangOpts] },
        { key: "nama", label: "Nama Kegiatan" },
        { key: "lokasi", label: "Lokasi" },
        { key: "dusun", label: "Dusun" },
        { key: "volume", label: "Volume" },
        { key: "satuan", label: "Satuan" },
        { key: "anggaran", label: "Anggaran (Rp)", type: "number" },
        { key: "sumber_dana", label: "Sumber Dana" },
        { key: "pelaksana", label: "Pelaksana" },
        { key: "waktu", label: "Waktu" },
        { key: "status_realisasi", label: "Status", type: "select", options: [
          { value: "rencana", label: "Rencana" },
          { value: "berjalan", label: "Berjalan" },
          { value: "selesai", label: "Selesai" },
          { value: "tertunda", label: "Tertunda" },
          { value: "batal", label: "Batal" },
        ]},
        { key: "progress_pct", label: "Progres %", type: "number" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

// -------- Usulan Warga (moderasi) --------
export function UsulanAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusF, setStatusF] = useState("");
  const [editing, setEditing] = useState<any | null>(null);

  const load = () => {
    setLoading(true);
    let q = (supabase.from("usulan_warga" as any) as any).select("*").order("created_at", { ascending: false });
    if (statusF) q = q.eq("status", statusF);
    q.then(({ data }: any) => { setRows(data || []); setLoading(false); });
  };
  useEffect(load, [statusF]);

  const save = async () => {
    if (!editing) return;
    const { id, status, tanggapan } = editing;
    const { error } = await (supabase.from("usulan_warga" as any) as any)
      .update({ status, tanggapan }).eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Tersimpan.");
    setEditing(null); load();
  };

  const hapus = async (id: string) => {
    if (!confirm("Hapus usulan ini?")) return;
    const { error } = await (supabase.from("usulan_warga" as any) as any).delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus."); load();
  };

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Usulan Warga</h1>
        <p className="text-sm text-muted-foreground mt-1">Moderasi usulan pembangunan dari warga.</p>
      </div>
      <div className="mb-4 flex gap-3 items-end">
        <label className="text-sm">
          <span className="block text-xs mb-1">Filter Status</span>
          <select value={statusF} onChange={(e) => setStatusF(e.target.value)} className={inp}>
            <option value="">Semua</option>
            {["baru","diverifikasi","ditindaklanjuti","selesai","ditolak"].map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
      </div>

      {editing && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <div className="text-xs text-muted-foreground mb-2">
            {editing.nomor_tiket} · {editing.kategori} · {editing.dusun || "—"} · dari {editing.nama}
          </div>
          <div className="font-display font-semibold mb-2">{editing.judul}</div>
          <p className="text-sm whitespace-pre-line mb-4 opacity-85">{editing.deskripsi}</p>
          {editing.foto_url && <img src={editing.foto_url} alt="" className="h-40 object-cover mb-4 border border-border" />}
          <div className="grid sm:grid-cols-2 gap-3">
            <label className="text-sm">
              <span className="block text-xs mb-1">Status</span>
              <select value={editing.status} onChange={(e) => setEditing({ ...editing, status: e.target.value })} className={inp}>
                {["baru","diverifikasi","ditindaklanjuti","selesai","ditolak"].map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </label>
            <label className="text-sm sm:col-span-2">
              <span className="block text-xs mb-1">Tanggapan Desa</span>
              <textarea rows={4} value={editing.tanggapan || ""} onChange={(e) => setEditing({ ...editing, tanggapan: e.target.value })} className={inp} />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            <button onClick={save} className={btnPri}>Simpan</button>
            <button onClick={() => setEditing(null)} className={btnSec}>Batal</button>
          </div>
        </div>
      )}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Tiket</th>
              <th className="text-left px-4 py-3">Judul</th>
              <th className="text-left px-4 py-3">Kategori</th>
              <th className="text-left px-4 py-3">Dusun</th>
              <th className="text-left px-4 py-3">Status</th>
              <th className="text-right px-4 py-3">Dukungan</th>
              <th className="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && !rows.length && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Belum ada usulan.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 font-mono text-xs">{r.nomor_tiket}</td>
                <td className="px-4 py-3">{r.judul}</td>
                <td className="px-4 py-3">{r.kategori}</td>
                <td className="px-4 py-3">{r.dusun || "—"}</td>
                <td className="px-4 py-3">{r.status}</td>
                <td className="px-4 py-3 text-right tabular-nums">{r.vote_count}</td>
                <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                  <button onClick={() => setEditing(r)} className={btnSec}>Tinjau</button>
                  <button onClick={() => hapus(r.id)} className="rounded-md border border-destructive/40 text-destructive px-3 py-1.5 text-sm hover:bg-destructive/10">Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

export function VotingTopikAdmin() {
  return (
    <TableCrud
      table="voting_topik"
      title="Voting — Topik"
      desc="Topik voting resmi desa."
      orderBy="created_at"
      orderAsc={false}
      blank={{ judul: "", deskripsi: "", mulai: null, selesai: null, single_choice: true, status: "draft", published: false } as any}
      columns={[
        { key: "judul", label: "Judul" },
        { key: "deskripsi", label: "Deskripsi", type: "textarea" },
        { key: "mulai", label: "Mulai", type: "date" },
        { key: "selesai", label: "Selesai", type: "date" },
        { key: "single_choice", label: "Satu Pilihan", type: "checkbox" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "draft", label: "Draft" },
          { value: "aktif", label: "Aktif" },
          { value: "ditutup", label: "Ditutup" },
        ]},
        { key: "published", label: "Publish", type: "checkbox" },
      ]}
    />
  );
}

export function VotingOpsiAdmin() {
  const topikOpts = useSelectOptions("voting_topik", "judul");
  return (
    <TableCrud
      table="voting_opsi"
      title="Voting — Opsi"
      desc="Opsi jawaban untuk tiap topik voting."
      orderBy="urutan"
      blank={{ topik_id: "", label: "", deskripsi: "", urutan: 0 } as any}
      columns={[
        { key: "topik_id", label: "Topik", type: "select", options: topikOpts },
        { key: "label", label: "Label Opsi" },
        { key: "deskripsi", label: "Deskripsi", type: "textarea" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}