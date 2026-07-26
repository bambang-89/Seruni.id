import { useEffect, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { TableCrud, type Column } from "./AdminPages";
import { useBroadcasts, useBroadcastTargets, useEventLog } from "../lib/queries";
import { SuratPreview, SuratPreviewModal } from "../components/SuratPreview";

const WORKFLOW = [
  { value: "draft", label: "Draft" },
  { value: "diajukan", label: "Diajukan" },
  { value: "diverifikasi", label: "Diverifikasi" },
  { value: "diproses", label: "Diproses" },
  { value: "selesai", label: "Selesai" },
  { value: "ditolak", label: "Ditolak" },
];
const SEVERITY = [
  { value: "ringan", label: "Ringan" },
  { value: "sedang", label: "Sedang" },
  { value: "berat", label: "Berat" },
  { value: "kritis", label: "Kritis" },
];
const POTENSI_STATUS = [
  { value: "publish", label: "Publish" },
  { value: "draft", label: "Draft" },
];

const today = () => new Date().toISOString().slice(0, 10);

// ============ DNA Field Editors ============
type DnaFieldDef = { field_name: string; label: string; tipe: string; grup: string; placeholder?: string; max_length?: number; wajib?: boolean; options?: unknown; help_text?: string };

// Edits DNA field VALUES (used in SuratTerbitAdmin)
function DnaFieldEditor({
  fields,
  values,
  onChange,
}: {
  fields: DnaFieldDef[];
  values: Record<string, unknown>;
  onChange: (updated: Record<string, unknown>) => void;
}) {
  const grouped: Record<string, DnaFieldDef[]> = {};
  fields.forEach((f) => {
    const g = f.grup || "Umum";
    if (!grouped[g]) grouped[g] = [];
    grouped[g].push(f);
  });

  return (
    <>
      {Object.entries(grouped).map(([grup, grpFields]) => (
        <fieldset key={grup} className="mb-4">
          <legend className="text-xs font-bold uppercase tracking-widest text-accent mb-2 block">{grup}</legend>
          <div className="grid sm:grid-cols-2 gap-3">
            {grpFields.map((field) => {
              const val = values[field.field_name] ?? "";
              const handleChange = (v: unknown) => onChange({ ...values, [field.field_name]: v });

              if (field.tipe === "textarea") {
                return (
                  <div key={field.field_name} className="sm:col-span-2">
                    <label className="text-xs">
                      <span className="block mb-1 font-medium">
                        {field.label}{field.wajib && <span className="text-red-500 ml-1">*</span>}
                      </span>
                      <textarea
                        value={String(val)}
                        onChange={(e) => handleChange(e.target.value)}
                        placeholder={field.placeholder}
                        rows={3}
                        className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        autoComplete="off"
                      />
                    </label>
                  </div>
                );
              }

              if (field.tipe === "select") {
                const opts = typeof field.options === "string"
                  ? field.options.split(",").map((s) => ({ value: s.trim(), label: s.trim() }))
                  : Array.isArray(field.options) ? field.options.map((o) => ({ value: String(o), label: String(o) })) : [];
                return (
                  <div key={field.field_name}>
                    <label className="text-xs">
                      <span className="block mb-1 font-medium">
                        {field.label}{field.wajib && <span className="text-red-500 ml-1">*</span>}
                      </span>
                      <select
                        value={String(val)}
                        onChange={(e) => handleChange(e.target.value)}
                        className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        autoComplete="off"
                      >
                        <option value="">— Pilih —</option>
                        {opts.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
                      </select>
                    </label>
                  </div>
                );
              }

              if (field.tipe === "number") {
                return (
                  <div key={field.field_name}>
                    <label className="text-xs">
                      <span className="block mb-1 font-medium">
                        {field.label}{field.wajib && <span className="text-red-500 ml-1">*</span>}
                      </span>
                      <input
                        type="number"
                        value={String(val)}
                        onChange={(e) => handleChange(e.target.value)}
                        className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        autoComplete="off"
                      />
                    </label>
                  </div>
                );
              }

              if (field.tipe === "date") {
                return (
                  <div key={field.field_name}>
                    <label className="text-xs">
                      <span className="block mb-1 font-medium">
                        {field.label}{field.wajib && <span className="text-red-500 ml-1">*</span>}
                      </span>
                      <input
                        type="date"
                        value={String(val)}
                        onChange={(e) => handleChange(e.target.value)}
                        className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        autoComplete="off"
                      />
                    </label>
                  </div>
                );
              }

              // Default: text input
              return (
                <div key={field.field_name}>
                  <label className="text-xs">
                    <span className="block mb-1 font-medium">
                      {field.label}{field.wajib && <span className="text-red-500 ml-1">*</span>}
                    </span>
                    <input
                      type="text"
                      value={String(val)}
                      onChange={(e) => handleChange(e.target.value)}
                      placeholder={field.placeholder}
                      maxLength={field.max_length}
                      className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                      autoComplete="off"
                    />
                  </label>
                </div>
              );
            })}
          </div>
        </fieldset>
      ))}
    </>
  );
}

// ============ 1. Pertanahan ============
export function BidangTanahAdmin() {
  return (
    <TableCrud
      table="bidang_tanah"
      title="Pertanahan — Bidang Tanah"
      desc="Data persil tanah desa. Sensitif, hanya admin."
      orderBy="tanggal_daftar"
      orderAsc={false}
      blank={{ nomor_persil: "", pemilik_nama: "", pemilik_nik: "", dusun: "", luas_m2: 0, penggunaan: "", status_hak: "", nomor_sertifikat: "", tanggal_daftar: today(), catatan: "" }}
      columns={[
        { key: "nomor_persil", label: "No. Persil" },
        { key: "pemilik_nama", label: "Pemilik" },
        { key: "pemilik_nik", label: "NIK", hideInTable: true },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "luas_m2", label: "Luas (m²)", type: "number", step: "0.01" },
        { key: "penggunaan", label: "Penggunaan", type: "relation", relation: { table: "ref_penggunaan_tanah", labelCol: "nama", valueCol: "nama" } },
        { key: "status_hak", label: "Status Hak", type: "relation", relation: { table: "ref_status_hak_tanah", labelCol: "nama", valueCol: "nama" } },
        { key: "nomor_sertifikat", label: "No. Sertifikat", hideInTable: true },
        { key: "tanggal_daftar", label: "Tgl Daftar", type: "date" },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 2. Infrastruktur ============
export function InfrastrukturAdmin() {
  return (
    <TableCrud
      table="infrastruktur"
      title="Pembangunan — Infrastruktur"
      desc="Aset infrastruktur desa yang tampil di halaman Pembangunan."
      orderBy="nama"
      orderAsc
      blank={{ nama: "", jenis: "", dusun: "", kondisi: "baik", tahun_bangun: null, tahun_perbaikan: null, volume: "", sumber_dana: "", keterangan: "" }}
      columns={[
        { key: "nama", label: "Nama Aset" },
        { key: "jenis", label: "Jenis", type: "relation", relation: { table: "ref_jenis_infrastruktur", labelCol: "nama", valueCol: "nama" } },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "kondisi", label: "Kondisi", type: "select", options: [
          { value: "baik", label: "Baik" },
          { value: "rusak-ringan", label: "Rusak Ringan" },
          { value: "rusak-berat", label: "Rusak Berat" },
        ]},
        { key: "tahun_bangun", label: "Th. Bangun", type: "number" },
        { key: "tahun_perbaikan", label: "Th. Perbaikan", type: "number", hideInTable: true },
        { key: "volume", label: "Volume", hideInTable: true },
        { key: "sumber_dana", label: "Sumber Dana", type: "relation", relation: { table: "ref_sumber_dana", labelCol: "nama", valueCol: "nama" } },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 3. Kegiatan Pembangunan ============
export function KegiatanPembangunanAdmin() {
  return (
    <TableCrud
      table="kegiatan_pembangunan"
      title="Pembangunan — Kegiatan"
      desc="Kegiatan pembangunan tahunan. Perubahan status tercatat di log."
      orderBy="tahun"
      orderAsc={false}
      blank={{ tahun: new Date().getFullYear(), bidang: "", nama_kegiatan: "", lokasi: "", volume: "", anggaran: 0, realisasi: 0, sumber_dana: "", status: "draft", tanggal_mulai: null, tanggal_selesai: null, keterangan: "" }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "bidang", label: "Bidang", type: "relation", relation: { table: "ref_bidang_pembangunan", labelCol: "nama", valueCol: "nama" } },
        { key: "nama_kegiatan", label: "Kegiatan" },
        { key: "lokasi", label: "Lokasi" },
        { key: "volume", label: "Volume", hideInTable: true },
        { key: "anggaran", label: "Anggaran", type: "number" },
        { key: "realisasi", label: "Realisasi", type: "number" },
        { key: "sumber_dana", label: "Sumber Dana", type: "relation", relation: { table: "ref_sumber_dana", labelCol: "nama", valueCol: "nama" } },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "tanggal_mulai", label: "Mulai", type: "date", hideInTable: true },
        { key: "tanggal_selesai", label: "Selesai", type: "date", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 4. Posyandu ============
export function PosyanduAdmin() {
  return (
    <TableCrud
      table="posyandu_agregat"
      title="Posyandu — Rekap Bulanan"
      desc="Agregat posyandu per dusun per bulan."
      orderBy="periode"
      orderAsc={false}
      blank={{ periode: today(), dusun: "", jumlah_balita: 0, hadir: 0, gizi_baik: 0, gizi_kurang: 0, imunisasi_lengkap: 0, ibu_hamil_dilayani: 0, catatan: "" }}
      columns={[
        { key: "periode", label: "Periode", type: "date" },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "jumlah_balita", label: "Balita", type: "number" },
        { key: "hadir", label: "Hadir", type: "number" },
        { key: "gizi_baik", label: "Gizi Baik", type: "number" },
        { key: "gizi_kurang", label: "Gizi Kurang", type: "number" },
        { key: "imunisasi_lengkap", label: "Imunisasi Lengkap", type: "number", hideInTable: true },
        { key: "ibu_hamil_dilayani", label: "Ibu Hamil Dilayani", type: "number", hideInTable: true },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 5. Stunting ============
export function StuntingAdmin() {
  return (
    <TableCrud
      table="stunting_agregat"
      title="Stunting — Rekap"
      desc="Agregat stunting per dusun per periode."
      orderBy="periode"
      orderAsc={false}
      blank={{ periode: today(), dusun: "", balita_diukur: 0, stunting: 0, wasting: 0, underweight: 0, intervensi: "" }}
      columns={[
        { key: "periode", label: "Periode", type: "date" },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "balita_diukur", label: "Diukur", type: "number" },
        { key: "stunting", label: "Stunting", type: "number" },
        { key: "wasting", label: "Wasting", type: "number" },
        { key: "underweight", label: "Underweight", type: "number" },
        { key: "intervensi", label: "Intervensi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 6. Bantuan Sosial (program) ============
export function BansosAdmin() {
  return (
    <TableCrud
      table="bantuan_sosial"
      title="Sosial — Program Bantuan"
      desc="Program bansos yang berjalan di desa."
      orderBy="kode"
      orderAsc
      blank={{ kode: "", nama: "", sumber: "", deskripsi: "", periode_mulai: null, periode_selesai: null, kuota: null, aktif: true }}
      columns={[
        { key: "kode", label: "Kode" },
        { key: "nama", label: "Nama Program" },
        { key: "sumber", label: "Sumber", type: "relation", relation: { table: "ref_sumber_dana", labelCol: "nama", valueCol: "nama" } },
        { key: "kuota", label: "Kuota", type: "number" },
        { key: "periode_mulai", label: "Mulai", type: "date" },
        { key: "periode_selesai", label: "Selesai", type: "date" },
        { key: "aktif", label: "Aktif", type: "checkbox" },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 6b. Penerima Bansos (nested pilih program) ============
export function PenerimaBansosAdmin() {
  const [programs, setPrograms] = useState<{ id: string; nama: string; kode: string }[]>([]);
  const [bansosId, setBansosId] = useState<string>("");
  useEffect(() => {
    supabase.from("bantuan_sosial").select("id,nama,kode").order("nama").then(({ data }) => {
      const list = (data as any) || [];
      setPrograms(list);
      if (list.length && !bansosId) setBansosId(list[0].id);
    });
  }, []);

  if (!programs.length) {
    return (
      <div className="rounded-xl bg-card border border-border p-6 text-sm text-muted-foreground">
        Belum ada program bantuan sosial. Tambahkan program terlebih dahulu di menu "Program Bansos".
      </div>
    );
  }

  return (
    <div>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <label className="text-sm font-medium">Program:</label>
        <select
          value={bansosId}
          onChange={(e) => setBansosId(e.target.value)}
          className="rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          {programs.map((p) => (
            <option key={p.id} value={p.id}>{p.kode} — {p.nama}</option>
          ))}
        </select>
      </div>
      {bansosId && (
        <PenerimaBansosTable key={bansosId} bansosId={bansosId} />
      )}
    </div>
  );
}

function PenerimaBansosTable({ bansosId }: { bansosId: string }) {
  return (
    <TableCrud
      table="penerima_bansos"
      title="Sosial — Penerima"
      desc="Daftar penerima bansos untuk program terpilih."
      orderBy="nama"
      orderAsc
      blank={{ bansos_id: bansosId, nik: "", nama: "", dusun: "", status: "terdaftar", tanggal_salur: null, nominal: null, catatan: "" }}
      columns={[
        { key: "nik", label: "NIK" },
        { key: "nama", label: "Nama", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "nama" } },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "status", label: "Status", type: "select", options: [
          { value: "terdaftar", label: "Terdaftar" },
          { value: "diverifikasi", label: "Diverifikasi" },
          { value: "disalurkan", label: "Disalurkan" },
          { value: "dibatalkan", label: "Dibatalkan" },
        ]},
        { key: "tanggal_salur", label: "Tgl Salur", type: "date" },
        { key: "nominal", label: "Nominal", type: "number", step: "0.01" },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 7. Bencana ============
export function BencanaAdmin() {
  return (
    <TableCrud
      table="bencana_kejadian"
      title="Bencana — Kejadian"
      desc="Catatan kejadian bencana di wilayah desa."
      orderBy="tanggal"
      orderAsc={false}
      blank={{ jenis: "", lokasi: "", dusun: "", tanggal: new Date().toISOString(), severity: "sedang", status: "diajukan", korban_jiwa: 0, korban_luka: 0, pengungsi: 0, kerugian_rp: 0, deskripsi: "", penanganan: "" }}
      columns={[
        { key: "jenis", label: "Jenis", type: "relation", relation: { table: "ref_jenis_bencana", labelCol: "nama", valueCol: "nama" } },
        { key: "lokasi", label: "Lokasi" },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "severity", label: "Severity", type: "select", options: SEVERITY },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "korban_jiwa", label: "Korban Jiwa", type: "number" },
        { key: "korban_luka", label: "Korban Luka", type: "number", hideInTable: true },
        { key: "pengungsi", label: "Pengungsi", type: "number", hideInTable: true },
        { key: "kerugian_rp", label: "Kerugian (Rp)", type: "number", step: "0.01", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "penanganan", label: "Penanganan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 8. Service Center — Aduan ============
export function AduanAdmin() {
  return (
    <TableCrud
      table="aduan_warga"
      title="Service Center — Aduan Warga"
      desc="Tiket aduan masuk. Tanggapi dan perbarui statusnya."
      orderBy="created_at"
      orderAsc={false}
      blank={{ nama_pelapor: "", kontak: "", kategori: "lainnya", judul: "", isi: "", lokasi: "", dusun: "", status: "diajukan", tanggapan: "" }}
      columns={[
        { key: "nomor_tiket", label: "No. Tiket", hideInTable: false, render: (r) => <span className="font-mono text-xs">{r.nomor_tiket}</span> },
        { key: "judul", label: "Judul" },
        { key: "nama_pelapor", label: "Pelapor" },
        { key: "kontak", label: "Kontak" },
        { key: "kategori", label: "Kategori", type: "relation", relation: { table: "ref_kategori_aduan", labelCol: "nama", valueCol: "nama" } },
        { key: "lokasi", label: "Lokasi", hideInTable: true },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "isi", label: "Isi Aduan", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "tanggapan", label: "Tanggapan Admin", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 9. Pemilu — DPT ============
export function DptAdmin() {
  return (
    <TableCrud
      table="dpt_pemilih"
      title="Pemilu — DPT"
      desc="Daftar Pemilih Tetap. Sensitif, akses admin saja."
      orderBy="nama"
      orderAsc
      blank={{ pemilu_kode: "", nik: "", nama: "", tempat_lahir: "", tanggal_lahir: null, jenis_kelamin: "L", dusun: "", rt: "", rw: "", tps: "", status: "aktif" }}
      columns={[
        { key: "pemilu_kode", label: "Kode Pemilu" },
        { key: "nik", label: "NIK" },
        { key: "nama", label: "Nama", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "nama" } },
        { key: "jenis_kelamin", label: "L/P", type: "select", options: [
          { value: "L", label: "Laki-laki" },
          { value: "P", label: "Perempuan" },
        ]},
        { key: "tempat_lahir", label: "Tempat Lahir", hideInTable: true },
        { key: "tanggal_lahir", label: "Tgl Lahir", type: "date", hideInTable: true },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "rt", label: "RT" },
        { key: "rw", label: "RW" },
        { key: "tps", label: "TPS" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "aktif", label: "Aktif" },
          { value: "tidak-aktif", label: "Tidak Aktif" },
          { value: "pindah", label: "Pindah" },
          { value: "meninggal", label: "Meninggal" },
        ]},
      ]}
    />
  );
}

// ============ 10. Jenis Surat ============
export function JenisSuratAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [dnaFields, setDnaFields] = useState<any[]>([]);
  const [loadingDna, setLoadingDna] = useState(false);

  const load = () => {
    setLoading(true);
    supabase.from("surat_jenis").select("*").order("kode_surat").then(({ data }) => {
      setRows(data || []);
      setLoading(false);
    });
  };

  useEffect(() => { load(); }, []);

  const loadDnaFields = async (jenisId: string) => {
    setLoadingDna(true);
    const { data } = await supabase
      .from("surat_jenis_dna")
      .select("*")
      .eq("jenis_surat_id", jenisId)
      .order("urutan");
    setDnaFields(data || []);
    setLoadingDna(false);
  };

  const openEdit = async (r: any) => {
    setDraft({ ...r });
    await loadDnaFields(r.id);
  };

  const openNew = () => {
    setDraft({ kode_surat: "", kode_klasifikasi: "", nama: "", aktif: true, urutan: 0 });
    setDnaFields([]);
  };

  const save = async () => {
    if (!draft) return;
    const { id, created_at, updated_at, ...payload } = draft;
    let result: any;

    if (id) {
      result = await supabase.from("surat_jenis").update(payload).eq("id", id);
    } else {
      result = await supabase.from("surat_jenis").insert(payload);
      if (result.data) {
        // Insert DNA fields with new jenis_surat_id
        const newId = result.data[0]?.id || result.data?.id;
        if (newId && dnaFields.length > 0) {
          const tenant_id = rows[0]?.tenant_id || "00000000-0000-0000-0000-000000000000";
          await supabase.from("surat_jenis_dna").insert(
            dnaFields.map((f: any) => ({
              ...f,
              id: undefined,
              jenis_surat_id: newId,
              tenant_id,
            }))
          );
        }
      }
    }

    if (result.error) {
      toast.error(result.error.message);
    } else {
      toast.success("Tersimpan.");
      setDraft(null);
      setDnaFields([]);
      load();
    }
  };

  const del = async (id: string) => {
    if (!confirm("Hapus jenis surat ini beserta DNA fields-nya?")) return;
    // Delete DNA fields first
    await supabase.from("surat_jenis_dna").delete().eq("jenis_surat_id", id);
    const { error } = await supabase.from("surat_jenis").delete().eq("id", id);
    if (error) {
      toast.error(error.message);
    } else {
      toast.success("Terhapus.");
      load();
    }
  };

  const saveDnaField = async (field: any) => {
    const { id, created_at, ...payload } = field;
    let result: any;

    if (id) {
      result = await supabase.from("surat_jenis_dna").update(payload).eq("id", id);
    } else {
      result = await supabase.from("surat_jenis_dna").insert({ ...payload, tenant_id: draft?.tenant_id || "00000000-0000-0000-0000-000000000000" });
    }

    if (result.error) {
      toast.error(result.error.message);
    } else {
      toast.success("Field DNA tersimpan.");
      if (draft?.id) await loadDnaFields(draft.id);
    }
  };

  const deleteDnaField = async (id: string) => {
    if (!confirm("Hapus field DNA ini?")) return;
    const { error } = await supabase.from("surat_jenis_dna").delete().eq("id", id);
    if (error) {
      toast.error(error.message);
    } else {
      toast.success("Field DNA dihapus.");
      if (draft?.id) await loadDnaFields(draft.id);
    }
  };

  const addDnaField = () => {
    setDnaFields([...dnaFields, {
      field_name: "",
      label: "",
      tipe: "text",
      placeholder: "",
      wajib: false,
      grup: "Umum",
      urutan: dnaFields.length + 1,
    }]);
  };

  const updateDnaField = (index: number, updates: any) => {
    const updated = [...dnaFields];
    updated[index] = { ...updated[index], ...updates };
    setDnaFields(updated);
  };

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Layanan — Jenis Surat</h1>
        <p className="text-sm text-muted-foreground mt-1">Katalog jenis surat (kode klasifikasi &amp; DNA).</p>
      </div>

      {/* Action Bar */}
      <div className="flex gap-2 mb-4">
        <button onClick={openNew} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90">
          + Tambah
        </button>
      </div>

      {/* Edit Form */}
      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <h3 className="font-display font-semibold mb-4">{draft.id ? "Edit" : "Tambah"} Jenis Surat</h3>

          <div className="grid sm:grid-cols-3 gap-4 mb-6">
            <div>
              <label className="block text-xs font-medium mb-1">Kode Surat *</label>
              <input value={draft.kode_surat || ""} onChange={(e) => setDraft({ ...draft, kode_surat: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="470.0" autoComplete="off" />
            </div>
            <div>
              <label className="block text-xs font-medium mb-1">Kode Klasifikasi *</label>
              <input value={draft.kode_klasifikasi || ""} onChange={(e) => setDraft({ ...draft, kode_klasifikasi: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="470" autoComplete="off" />
            </div>
            <div>
              <label className="block text-xs font-medium mb-1">Nama Surat *</label>
              <input value={draft.nama || ""} onChange={(e) => setDraft({ ...draft, nama: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Surat Keterangan" autoComplete="off" />
            </div>
            <div>
              <label className="block text-xs font-medium mb-1">Urutan</label>
              <input type="number" value={draft.urutan || 0} onChange={(e) => setDraft({ ...draft, urutan: parseInt(e.target.value) || 0 })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </div>
            <div>
              <label className="block text-xs font-medium mb-1">Status</label>
              <label className="inline-flex items-center gap-2 text-sm">
                <input type="checkbox" checked={draft.aktif ?? true} onChange={(e) => setDraft({ ...draft, aktif: e.target.checked })} />
                Aktif
              </label>
            </div>
          </div>

          {/* DNA Fields Section */}
          <div className="border-t pt-4 mt-4">
            <div className="flex justify-between items-center mb-3">
              <h4 className="font-semibold text-sm">📋 DNA Fields ({dnaFields.length})</h4>
              <button onClick={addDnaField} className="text-xs bg-secondary px-3 py-1 rounded hover:bg-secondary/80">
                + Tambah Field
              </button>
            </div>

            {loadingDna ? (
              <p className="text-sm text-muted-foreground">Memuat DNA fields...</p>
            ) : dnaFields.length === 0 && draft.id ? (
              <p className="text-sm text-muted-foreground italic">Belum ada DNA fields untuk jenis surat ini.</p>
            ) : (
              <div className="space-y-3">
                {dnaFields.map((field, idx) => (
                  <DnaFieldDefEditor
                    key={field.id || idx}
                    field={field}
                    onChange={(updates) => updateDnaField(idx, updates)}
                    onSave={() => saveDnaField(field)}
                    onDelete={field.id ? () => deleteDnaField(field.id) : undefined}
                  />
                ))}
              </div>
            )}
          </div>

          <div className="flex gap-2 mt-6">
            <button onClick={save} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90">
              Simpan
            </button>
            <button onClick={() => { setDraft(null); setDnaFields([]); }} className="rounded-md border border-border px-4 py-2 text-sm hover:bg-muted">
              Batal
            </button>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Kode</th>
              <th className="text-left px-4 py-3">Nama Surat</th>
              <th className="text-left px-4 py-3">Klasifikasi</th>
              <th className="text-center px-4 py-3">Urutan</th>
              <th className="text-center px-4 py-3">Aktif</th>
              <th className="px-4 py-3 w-40"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={6} className="px-4 py-6 text-center">Memuat...</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={6} className="px-4 py-6 text-center">Belum ada data.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 font-mono">{r.kode_surat}</td>
                <td className="px-4 py-3 font-medium">{r.nama}</td>
                <td className="px-4 py-3 text-muted-foreground">{r.kode_klasifikasi}</td>
                <td className="px-4 py-3 text-center">{r.urutan}</td>
                <td className="px-4 py-3 text-center">{r.aktif ? "✓" : "—"}</td>
                <td className="px-4 py-3 text-right space-x-2">
                  <button onClick={() => openEdit(r)} className="rounded-md border border-border px-3 py-1 text-xs hover:bg-muted">Edit</button>
                  <button onClick={() => r.id && del(r.id)} className="rounded-md border border-destructive/40 text-destructive px-3 py-1 text-xs hover:bg-destructive/10">Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

// DNA Field Definition Editor Component (for JenisSuratAdmin — defines field schemas)
function DnaFieldDefEditor({ field, onChange, onSave, onDelete }: {
  field: any;
  onChange: (updates: any) => void;
  onSave: () => void;
  onDelete?: () => void;
}) {
  const TIPE_OPTIONS = [
    { value: "text", label: "Teks" },
    { value: "textarea", label: "Teks Panjang" },
    { value: "number", label: "Angka" },
    { value: "date", label: "Tanggal" },
    { value: "select", label: "Pilihan" },
    { value: "checkbox", label: "Checkbox" },
    { value: "phone", label: "Telepon" },
    { value: "email", label: "Email" },
    { value: "file", label: "File Upload" },
  ];

  return (
    <div className="border rounded-lg p-3 bg-muted/30">
      <div className="grid sm:grid-cols-6 gap-2 mb-2">
        <input
          value={field.field_name || ""}
          onChange={(e) => onChange({ field_name: e.target.value })}
          placeholder="field_name"
          autoComplete="off"
          className="sm:col-span-2 rounded-md border border-input bg-background px-2 py-1 text-xs font-mono"
        />
        <input
          value={field.label || ""}
          onChange={(e) => onChange({ label: e.target.value })}
          placeholder="Label Field"
          autoComplete="off"
          className="sm:col-span-2 rounded-md border border-input bg-background px-2 py-1 text-xs"
        />
        <select
          value={field.tipe || "text"}
          onChange={(e) => onChange({ tipe: e.target.value })}
          autoComplete="off"
          className="sm:col-span-1 rounded-md border border-input bg-background px-2 py-1 text-xs"
        >
          {TIPE_OPTIONS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
        <div className="flex gap-1 sm:col-span-1">
          <label className="flex items-center gap-1 text-xs">
            <input type="checkbox" checked={field.wajib || false} onChange={(e) => onChange({ wajib: e.target.checked })} />
            Wajib
          </label>
        </div>
      </div>
      {field.tipe === "select" && (
        <input
          value={typeof field.options === "object" ? JSON.stringify(field.options) : field.options || ""}
          onChange={(e) => {
            const val = e.target.value;
            let parsed = val;
            try {
              if (val.startsWith("{") || val.startsWith("[")) {
                parsed = JSON.parse(val);
              }
            } catch (e) { /* ignore */ }
            onChange({ options: parsed });
          }}
          placeholder='Opsi CSV (Pria,Wanita) atau JSON ({"relation":{"table":"..."}})'
          autoComplete="off"
          className="w-full rounded-md border border-input bg-background px-2 py-1 text-xs mb-2"
        />
      )}
      <div className="flex gap-2 items-center">
        <input
          value={field.grup || ""}
          onChange={(e) => onChange({ grup: e.target.value })}
          placeholder="Grup"
          autoComplete="off"
          className="flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs"
        />
        <button onClick={onSave} className="rounded-md bg-primary text-primary-foreground px-3 py-1 text-xs hover:bg-primary/90">Simpan</button>
        {onDelete && (
          <button onClick={onDelete} className="rounded-md border border-destructive/40 text-destructive px-3 py-1 text-xs hover:bg-destructive/10">Hapus</button>
        )}
      </div>
    </div>
  );
}

// ============ 10b. Surat Terbit (verifikasi publik) ============
function _today() { return new Date().toISOString().slice(0, 10); }
function randKode() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let r = "";
  for (let i = 0; i < 8; i++) r += chars[Math.floor(Math.random() * chars.length)];
  return r;
}

export function SuratTerbitAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [draftAjuan, setDraftAjuan] = useState<any | null>(null);
  const [draftDna, setDraftDna] = useState<any | null>(null);
  const [draftDnaFields, setDraftDnaFields] = useState<any[]>([]);
  const [ajuanList, setAjuanList] = useState<any[]>([]);
  const [jenisSurat, setJenisSurat] = useState<any[]>([]);
  const [pamongList, setPamongList] = useState<any[]>([]);
  const [previewId, setPreviewId] = useState<string | null>(null);
  const [previewModalOpen, setPreviewModalOpen] = useState(false);

  const load = () => {
    setLoading(true);
    supabase.from("surat_terbit").select("*").order("tanggal_terbit", { ascending: false }).then(({ data }) => {
      setRows(data || []);
      setLoading(false);
    });
  };

  useEffect(() => {
    load();
    supabase.from("surat_ajuan").select("id, nomor_tiket, nik, nama, jenis_surat_id, keperluan, status").eq("status", "diproses").then(({ data }) => {
      setAjuanList(data || []);
    });
    supabase.from("surat_jenis").select("id, kode_surat, nama").eq("aktif", true).order("urutan").then(({ data }) => {
      setJenisSurat(data || []);
    });
    supabase.from("desa_pamong").select("id, nama, jabatan").order("urutan").then(({ data }) => {
      setPamongList(data || []);
    });
  }, []);

  const loadAjuanData = async (ajuan: any) => {
    const { data: dnaRows } = await supabase
      .from("surat_ajuan_data").select("*").eq("surat_ajuan_id", ajuan.id).maybeSingle();
    setDraftDna(dnaRows?.data_dna || {});
    if (ajuan.jenis_surat_id) {
      const { data: fields } = await supabase
        .from("surat_jenis_dna").select("*").eq("jenis_surat_id", ajuan.jenis_surat_id).order("urutan");
      setDraftDnaFields(fields || []);
    } else {
      setDraftDnaFields([]);
    }
  };

  const getJenis = (id: string) => jenisSurat.find((j) => j.id === id);

  const mulaiTerbit = async (ajuan: any) => {
    await loadAjuanData(ajuan);
    const jenis = getJenis(ajuan.jenis_surat_id);
    setDraftAjuan(ajuan);
    setDraft({
      id: null,
      nomor_surat: "",
      kode_verifikasi: randKode(),
      jenis_kode: jenis?.kode_surat || "",
      jenis_nama: jenis?.nama || "",
      pertaining: "",
      pemohon_nama: ajuan.nama,
      pemohon_nik: ajuan.nik,
      tanggal_terbit: _today(),
      berlaku_sampai: "",
      status: "berlaku",
      penandatangan: "",
      keterangan: ajuan.keperluan || "",
    });
  };

  const save = async (row: any) => {
    const payload = {
      ...row,
      tenant_id: row.tenant_id || (await supabase.from("tenants").select("id").limit(1).single()).data?.id,
    };
    let res: any;
    if (row.id) {
      res = await supabase.from("surat_terbit").update(payload).eq("id", row.id).select().single();
    } else {
      res = await supabase.from("surat_terbit").insert(payload).select().single();
    }
    if (res.error) return toast.error(res.error.message);
    const terbit = res.data;

    // Copy DNA data to surat_terbit_data
    if (draftDna && Object.keys(draftDna).length > 0) {
      await supabase.from("surat_terbit_data").insert({
        surat_terbit_id: terbit.id,
        data_dna: draftDna,
        tenant_id: payload.tenant_id,
      }).catch(() => { /* ignore */ });
    }

    // Update ajuan status to diterima + send WA notification
    if (draftAjuan?.id) {
      await supabase.from("surat_ajuan").update({ status: "diterima" }).eq("id", draftAjuan.id);
      setAjuanList((prev) => prev.filter((a) => a.id !== draftAjuan.id));
      // Trigger WA notification via edge function (fire-and-forget)
      (supabase.functions as any).invoke("notifikasi-status-surat", {
        body: { surat_ajuan_id: draftAjuan.id, status_baru: "diterima" },
      }).catch(() => { /* ignore */ });
    }

    toast.success("Surat diterbitkan!");
    setDraft(null);
    setDraftAjuan(null);
    setDraftDna(null);
    setDraftDnaFields([]);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus surat ini?")) return;
    const { error } = await supabase.from("surat_terbit").delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    load();
  };

  const statusBadge = (s: string) => {
    const colors: Record<string, string> = {
      berlaku: "bg-green-100 text-green-800",
      kadaluarsa: "bg-gray-100 text-gray-600",
      dicabut: "bg-red-100 text-red-700",
    };
    return <span className={`px-2 py-0.5 rounded text-xs font-medium ${colors[s] || "bg-gray-100"}`}>{s}</span>;
  };

  const PAMONG_OPTS = pamongList.map((p) => ({ value: p.nama, label: `${p.nama} — ${p.jabatan}` }));

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Layanan — Surat Terbit</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Terbitkan surat keterangan. Nomor &amp; kode verifikasi bisa dicek publik di halaman Verifikasi.
        </p>
      </div>

      {/* Antrian Ajuan Diproses */}
      {ajuanList.length > 0 && !draft && (
        <div className="mb-6 rounded-xl bg-green-50 border border-green-200 p-4">
          <h3 className="font-display text-xs font-bold uppercase tracking-widest text-green-700 mb-3">
            Antrian Terbit ({ajuanList.length})
          </h3>
          <p className="text-xs text-green-700 mb-3">Pengajuan berstatus &quot;Diproses&quot; siap diterbitkan.</p>
          <div className="flex flex-wrap gap-2">
            {ajuanList.map((a) => (
              <button
                key={a.id}
                onClick={() => mulaiTerbit(a)}
                className="rounded-md bg-white border border-green-300 px-3 py-2 text-xs hover:bg-green-100 text-left"
              >
                <span className="font-mono block">{a.nomor_tiket}</span>
                <span className="text-green-700 font-medium">{a.nama}</span>
                <span className="text-green-500 block">{a.nik}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Form Terbit */}
      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-display font-semibold">
              {draft.id ? "Edit" : "Terbitkan"} Surat{draftAjuan ? ` — ${draftAjuan.nomor_tiket}` : ""}
            </h3>
            <button onClick={() => { setDraft(null); setDraftAjuan(null); setDraftDna(null); setDraftDnaFields([]); }} className="text-sm text-muted-foreground hover:text-foreground">Tutup</button>
          </div>

          {draftAjuan && (
            <div className="mb-4 p-3 rounded-lg bg-muted/50 border border-border text-sm">
              <div className="font-medium">{draftAjuan.nama} ({draftAjuan.nik})</div>
              <div className="text-xs text-muted-foreground mt-1">
                Keperluan: {draftAjuan.keperluan || "—"}
              </div>
            </div>
          )}

          {draftDnaFields.length > 0 && (
            <div className="mb-4 rounded-lg bg-muted/30 border border-border p-4">
              <h4 className="font-display text-xs font-bold uppercase tracking-widest text-accent mb-3">Data dari Form Pengajuan (DNA)</h4>
              <DnaFieldEditor
                fields={draftDnaFields}
                values={draftDna || {}}
                onChange={(updated) => setDraftDna(updated)}
              />
            </div>
          )}

          <div className="grid sm:grid-cols-2 gap-3">
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nomor Surat</span>
              <input value={draft.nomor_surat || ""} onChange={(e) => setDraft({ ...draft, nomor_surat: e.target.value })} placeholder="470/001/SM/2026" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Kode Verifikasi</span>
              <input value={draft.kode_verifikasi || ""} onChange={(e) => setDraft({ ...draft, kode_verifikasi: e.target.value })} placeholder="SRN-XXXXXXXX" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Kode Jenis</span>
              <input value={draft.jenis_kode || ""} onChange={(e) => setDraft({ ...draft, jenis_kode: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nama Jenis Surat</span>
              <input value={draft.jenis_nama || ""} onChange={(e) => setDraft({ ...draft, jenis_nama: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs sm:col-span-2">
              <span className="block mb-1 font-medium">Perihal</span>
              <input value={draft.perihal || ""} onChange={(e) => setDraft({ ...draft, perihal: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nama Pemohon</span>
              <input value={draft.pemohon_nama || ""} onChange={(e) => setDraft({ ...draft, pemohon_nama: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">NIK Pemohon</span>
              <input value={draft.pemohon_nik || ""} onChange={(e) => setDraft({ ...draft, pemohon_nik: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Tanggal Terbit</span>
              <input type="date" value={draft.tanggal_terbit || ""} onChange={(e) => setDraft({ ...draft, tanggal_terbit: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Berlaku Sampai</span>
              <input type="date" value={draft.berlaku_sampai || ""} onChange={(e) => setDraft({ ...draft, berlaku_sampai: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Status</span>
              <select value={draft.status || "berlaku"} onChange={(e) => setDraft({ ...draft, status: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off">
                <option value="berlaku">Berlaku</option>
                <option value="kadaluarsa">Kadaluarsa</option>
                <option value="dicabut">Dicabut</option>
              </select>
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Ditandatangani Oleh</span>
              <select value={draft.penandatangan || ""} onChange={(e) => setDraft({ ...draft, penandatangan: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                <option value="">— Pilih —</option>
                {PAMONG_OPTS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            </label>
            <label className="text-xs sm:col-span-2">
              <span className="block mb-1 font-medium">Keterangan</span>
              <textarea rows={2} value={draft.keterangan || ""} onChange={(e) => setDraft({ ...draft, keterangan: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            <button onClick={() => save(draft)} className="rounded-md bg-green-600 text-white px-4 py-2 text-sm hover:bg-green-700 font-medium">
              {draft.id ? "Simpan Perubahan" : "Terbitkan Surat"}
            </button>
            <button onClick={() => { setDraft(null); setDraftAjuan(null); setDraftDna(null); setDraftDnaFields([]); }} className="rounded-md border border-border px-4 py-2 text-sm hover:bg-muted">Batal</button>
          </div>
        </div>
      )}

      {/* Daftar Surat Terbit */}
      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Nomor Surat</th>
              <th className="text-left px-4 py-3">Kode</th>
              <th className="text-left px-4 py-3">Jenis</th>
              <th className="text-left px-4 py-3">Pemohon</th>
              <th className="text-left px-4 py-3">Tgl Terbit</th>
              <th className="text-left px-4 py-3">Status</th>
              <th className="text-left px-4 py-3">Penandatangan</th>
              <th className="px-4 py-3 w-40"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Belum ada surat terbit.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 font-mono text-xs">{r.nomor_surat || "—"}</td>
                <td className="px-4 py-3 font-mono text-xs text-accent">{r.kode_verifikasi || "—"}</td>
                <td className="px-4 py-3 text-xs">{r.jenis_nama || "—"}</td>
                <td className="px-4 py-3">{r.pemohon_nama || "—"}</td>
                <td className="px-4 py-3 tabular-nums">{r.tanggal_terbit ? new Date(r.tanggal_terbit).toLocaleDateString("id-ID") : "—"}</td>
                <td className="px-4 py-3">{statusBadge(r.status)}</td>
                <td className="px-4 py-3 text-xs">{r.penandatangan || "—"}</td>
                <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                  <button onClick={() => { setPreviewId(r.id); setPreviewModalOpen(true); }} className="rounded-md border border-blue-200 text-blue-600 px-2 py-1 text-xs hover:bg-blue-50">Preview</button>
                  <button onClick={() => setDraft(r)} className="rounded-md border border-border px-2 py-1 text-xs hover:bg-muted">Edit</button>
                  <button onClick={() => del(r.id)} className="rounded-md border border-red-200 text-red-600 px-2 py-1 text-xs hover:bg-red-50">Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* PDF Preview Modal */}
      {previewModalOpen && previewId && (
        <SuratPreviewModal isOpen={previewModalOpen} onClose={() => { setPreviewModalOpen(false); setPreviewId(null); load(); }}>
          <SuratPreview
            suratId={previewId}
            onClose={() => { setPreviewModalOpen(false); setPreviewId(null); load(); }}
            onApprove={() => { setPreviewModalOpen(false); setPreviewId(null); load(); }}
          />
        </SuratPreviewModal>
      )}
    </>
  );
}

// ============ 12. Langganan WA ============
export function LanggananWaAdmin() {
  return (
    <>
      <div className="mb-4 text-xs text-muted-foreground">
        Kelola pelanggan notifikasi WhatsApp. Untuk mengirim pesan, buka menu <b>Broadcast WA</b>.
      </div>
      <TableCrud
      table="langganan_wa"
      title="Notifikasi — Langganan WA"
      desc="Warga yang berlangganan notifikasi WhatsApp. Ekspor untuk broadcast."
      orderBy="created_at"
      orderAsc={false}
      blank={{ nama: "", nomor_wa: "", dusun: "", topik: [], status: "aktif" }}
      columns={[
        { key: "nama", label: "Nama" },
        { key: "nomor_wa", label: "Nomor WA" },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "status", label: "Status", type: "select", options: [
          { value: "aktif", label: "Aktif" },
          { value: "nonaktif", label: "Nonaktif" },
        ]},
        { key: "topik", label: "Topik", hideInTable: true, render: (r: any) => Array.isArray(r.topik) ? r.topik.join(", ") : "-" },
      ]}
      />
    </>
  );
}

// ============ 13. PBB Tagihan ============
export function PbbAdmin() {
  const currentYear = new Date().getFullYear();
  return (
    <TableCrud
      table="pbb_tagihan"
      title="Pajak — PBB Tagihan"
      desc="Objek pajak PBB per tahun. Warga bisa mengecek NOP secara publik di halaman Layanan PBB."
      orderBy="nop"
      orderAsc
      blank={{ tahun: currentYear, nop: "", wajib_pajak_nama: "", wajib_pajak_nik: "", alamat_objek: "", dusun: "", luas_bumi_m2: 0, luas_bangunan_m2: 0, njop_bumi: 0, njop_bangunan: 0, pbb_terutang: 0, jatuh_tempo: `${currentYear}-09-30`, status_bayar: "belum_lunas", tanggal_bayar: null, metode_bayar: "", keterangan: "" }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "nop", label: "NOP" },
        { key: "wajib_pajak_nama", label: "Wajib Pajak", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "nama" } },
        { key: "wajib_pajak_nik", label: "NIK", hideInTable: true },
        { key: "alamat_objek", label: "Alamat Objek", hideInTable: true },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "luas_bumi_m2", label: "Luas Bumi (m²)", type: "number", step: "0.01", hideInTable: true },
        { key: "luas_bangunan_m2", label: "Luas Bangunan (m²)", type: "number", step: "0.01", hideInTable: true },
        { key: "njop_bumi", label: "NJOP Bumi", type: "number", step: "0.01", hideInTable: true },
        { key: "njop_bangunan", label: "NJOP Bangunan", type: "number", step: "0.01", hideInTable: true },
        { key: "pbb_terutang", label: "PBB Terutang", type: "number", step: "0.01" },
        { key: "jatuh_tempo", label: "Jatuh Tempo", type: "date" },
        { key: "status_bayar", label: "Status", type: "select", options: [
          { value: "belum_lunas", label: "Belum Lunas" },
          { value: "lunas", label: "Lunas" },
          { value: "menunggak", label: "Menunggak" },
        ]},
        { key: "tanggal_bayar", label: "Tgl Bayar", type: "date", hideInTable: true },
        { key: "metode_bayar", label: "Metode Bayar", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 14. APBDes ============
export function ApbdesAdmin() {
  const currentYear = new Date().getFullYear();
  return (
    <TableCrud
      table="apbdes"
      title="Keuangan — APBDes"
      desc="Rincian pendapatan, belanja, dan pembiayaan APBDes. Publik dapat melihat di halaman Transparansi Keuangan."
      orderBy="urutan"
      orderAsc
      blank={{ tahun: currentYear, jenis: "belanja", kategori: "", sub_kategori: "", uraian: "", anggaran: 0, realisasi: 0, sumber_dana: "", keterangan: "", urutan: 0 }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "jenis", label: "Jenis", type: "select", options: [
          { value: "pendapatan", label: "Pendapatan" },
          { value: "belanja", label: "Belanja" },
          { value: "pembiayaan", label: "Pembiayaan" },
        ]},
        { key: "kategori", label: "Kategori/Bidang", type: "relation", relation: { table: "ref_apbdes_kategori", labelCol: "nama", valueCol: "nama", filterBy: "jenis", filterField: "jenis" } },
        { key: "sub_kategori", label: "Sub Kategori", hideInTable: true },
        { key: "uraian", label: "Uraian" },
        { key: "anggaran", label: "Anggaran", type: "number", step: "0.01" },
        { key: "realisasi", label: "Realisasi", type: "number", step: "0.01" },
        { key: "sumber_dana", label: "Sumber Dana", type: "relation", relation: { table: "ref_sumber_dana", labelCol: "nama", valueCol: "nama" } },
        { key: "urutan", label: "Urutan", type: "number", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 11. Event Log (read only) ============
// ============ Phase 6B — Potensi UMKM / Produk / Wisata ============
export function UmkmAdmin() {
  return (
    <TableCrud
      table="potensi_umkm"
      title="Potensi — UMKM / BUMDes / Koperasi"
      desc="Lembaga & pelaku usaha desa yang tampil di halaman Potensi."
      orderBy="nama"
      orderAsc
      blank={{ tipe: "umkm", nama: "", pemilik: "", sektor: "", dusun: "", kontak: "", alamat: "", deskripsi: "", status: "publish" }}
      columns={[
        { key: "tipe", label: "Tipe", type: "relation", relation: { table: "ref_tipe_umkm", labelCol: "nama", valueCol: "nama" } },
        { key: "nama", label: "Nama" },
        { key: "pemilik", label: "Pemilik / Pengelola" },
        { key: "sektor", label: "Sektor", type: "relation", relation: { table: "ref_sektor_umkm", labelCol: "nama", valueCol: "nama" } },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "kontak", label: "Kontak", hideInTable: true },
        { key: "alamat", label: "Alamat", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
      ]}
    />
  );
}

export function ProdukMarketplaceAdmin() {
  return (
    <TableCrud
      table="potensi_produk"
      title="Potensi — Produk Marketplace"
      desc="Katalog produk yang tampil di halaman Marketplace."
      orderBy="created_at"
      orderAsc={false}
      blank={{ penjual_nama: "", nama: "", kategori: "", harga: 0, satuan: "", stok: 0, deskripsi: "", foto_url: "", featured: false, status: "publish" }}
      columns={[
        { key: "nama", label: "Produk" },
        { key: "penjual_nama", label: "Penjual" },
        { key: "kategori", label: "Kategori", type: "relation", relation: { table: "ref_produk_kategori", labelCol: "nama", valueCol: "nama" } },
        { key: "harga", label: "Harga", type: "number", step: "0.01" },
        { key: "satuan", label: "Satuan" },
        { key: "stok", label: "Stok", type: "number" },
        { key: "featured", label: "Unggulan", type: "checkbox" },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
        { key: "foto_url", label: "Foto Produk", type: "image", imageFolder: "produk", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

export function WisataAdmin() {
  return (
    <TableCrud
      table="potensi_wisata"
      title="Potensi — Destinasi Wisata"
      desc="Destinasi wisata yang tampil di halaman Potensi dan Peta Interaktif."
      orderBy="nama"
      orderAsc
      blank={{ nama: "", jenis: "bahari", dusun: "", deskripsi: "", latitude: null, longitude: null, foto_url: "", fasilitas: "", status: "publish" }}
      columns={[
        { key: "nama", label: "Nama" },
        { key: "jenis", label: "Jenis", type: "relation", relation: { table: "ref_jenis_wisata", labelCol: "nama", valueCol: "nama" } },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "latitude", label: "Latitude", type: "number", step: "0.000001" },
        { key: "longitude", label: "Longitude", type: "number", step: "0.000001" },
        { key: "fasilitas", label: "Fasilitas", hideInTable: true },
        { key: "foto_url", label: "Foto Destinasi", type: "image", imageFolder: "wisata", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
      ]}
    />
  );
}

export function EventLogAdmin() {
  const [entitas, setEntitas] = useState("");
  const [event, setEvent] = useState("");
  const [sejak, setSejak] = useState("");
  const { rows, loading, reload } = useEventLog({ entitas, event, sejak, limit: 300 });

  const eksporCsv = () => {
    const header = ["waktu", "event", "entitas", "entitas_id", "actor_nama", "actor_nik", "payload"];
    const lines = [header.join(",")].concat(
      rows.map((r) =>
        [
          new Date(r.created_at).toISOString(),
          r.event_name,
          r.entitas || "",
          r.entitas_id || "",
          r.actor_nama || "",
          r.actor_nik || "",
          `"${JSON.stringify(r.payload).replace(/"/g, '""')}"`,
        ].join(","),
      ),
    );
    const blob = new Blob([lines.join("\n")], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `event-log-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const badgeColor = (ev: string) => {
    if (ev.endsWith(".dihapus")) return "bg-red-100 text-red-800";
    if (ev.endsWith(".dipublish")) return "bg-emerald-100 text-emerald-800";
    if (ev.endsWith(".di_unpublish")) return "bg-amber-100 text-amber-800";
    if (ev.endsWith(".dibuat")) return "bg-sky-100 text-sky-800";
    return "bg-muted text-muted-foreground";
  };

  return (
    <>
      <div className="mb-6 flex items-end justify-between gap-4 flex-wrap">
        <div>
          <h1 className="font-display text-2xl font-bold">Event Log</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Jejak audit semua aksi admin (buat, ubah, hapus, publish/unpublish).
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={reload} className="rounded-md border border-border px-3 py-2 text-sm hover:bg-muted">Muat ulang</button>
          <button onClick={eksporCsv} className="rounded-md bg-primary text-primary-foreground px-3 py-2 text-sm hover:bg-primary/90">Ekspor CSV</button>
        </div>
      </div>

      <div className="mb-4 grid gap-3 sm:grid-cols-3 rounded-xl border border-border bg-card p-4">
        <label className="text-xs">
          <span className="block mb-1 font-medium">Entitas</span>
          <input value={entitas} onChange={(e) => setEntitas(e.target.value)} placeholder="mis. berita, aduan_warga" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
        </label>
        <label className="text-xs">
          <span className="block mb-1 font-medium">Event mengandung</span>
          <input value={event} onChange={(e) => setEvent(e.target.value)} placeholder="mis. dipublish, dihapus" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
        </label>
        <label className="text-xs">
          <span className="block mb-1 font-medium">Sejak</span>
          <input type="datetime-local" value={sejak} onChange={(e) => setSejak(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
        </label>
      </div>

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Waktu</th>
              <th className="text-left px-4 py-3">Event</th>
              <th className="text-left px-4 py-3">Entitas</th>
              <th className="text-left px-4 py-3">Pelaku</th>
              <th className="text-left px-4 py-3">Detail</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Belum ada aktivitas.</td></tr>}
            {rows.map((r) => {
              const diff = r.payload?.diff;
              return (
                <tr key={r.id} className="border-t border-border align-top">
                  <td className="px-4 py-3 tabular-nums whitespace-nowrap text-xs">{new Date(r.created_at).toLocaleString("id-ID")}</td>
                  <td className="px-4 py-3">
                    <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-mono ${badgeColor(r.event_name)}`}>{r.event_name}</span>
                  </td>
                  <td className="px-4 py-3 text-xs">
                    <div>{r.entitas}</div>
                    <div className="text-muted-foreground text-[10px] font-mono">{r.entitas_id?.slice(0, 8)}</div>
                  </td>
                  <td className="px-4 py-3 text-xs">
                    {r.actor_nama ? (
                      <>
                        <div className="font-medium">{r.actor_nama}</div>
                        {r.actor_nik && <div className="text-muted-foreground text-[10px] tabular-nums">NIK {r.actor_nik}</div>}
                      </>
                    ) : (
                      <span className="text-muted-foreground italic">sistem/warga</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-xs">
                    {diff && Object.keys(diff).length > 0 ? (
                      <ul className="space-y-1">
                        {Object.entries(diff).slice(0, 6).map(([k, v]: any) => (
                          <li key={k} className="font-mono text-[11px]">
                            <b>{k}</b>: <span className="text-red-600 line-through">{JSON.stringify(v.dari)}</span> → <span className="text-emerald-700">{JSON.stringify(v.ke)}</span>
                          </li>
                        ))}
                      </ul>
                    ) : r.payload?.pk ? (
                      <span className="font-mono text-[10px] text-muted-foreground">pk {String(r.payload.pk).slice(0, 8)}</span>
                    ) : (
                      <span className="font-mono text-[10px] text-muted-foreground">{JSON.stringify(r.payload).slice(0, 80)}</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ============ 15. Broadcast WA Dashboard ============

export function BroadcastAdmin() {
  const [reloadKey, setReloadKey] = useState(0);
  const { rows, loading } = useBroadcasts(reloadKey);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const badge = (s: string) => {
    const cls =
      s === "selesai" ? "bg-emerald-100 text-emerald-800" :
      s === "gagal" ? "bg-red-100 text-red-800" :
      s === "berjalan" ? "bg-sky-100 text-sky-800" :
      "bg-muted text-muted-foreground";
    return <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-medium uppercase ${cls}`}>{s}</span>;
  };

  return (
    <>
      <div className="mb-6 flex items-end justify-between gap-4 flex-wrap">
        <div>
          <h1 className="font-display text-2xl font-bold">Broadcast WhatsApp</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Riwayat pengiriman broadcast, status per target, dan kirim ulang untuk target gagal.
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setReloadKey((k) => k + 1)} className="rounded-md border border-border px-3 py-2 text-sm hover:bg-muted">Muat ulang</button>
          <button onClick={() => setShowForm((v) => !v)} className="rounded-md bg-primary text-primary-foreground px-3 py-2 text-sm hover:bg-primary/90">
            {showForm ? "Tutup form" : "Kirim broadcast baru"}
          </button>
        </div>
      </div>

      {showForm && <BroadcastForm onDone={() => { setShowForm(false); setReloadKey((k) => k + 1); }} />}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Waktu</th>
              <th className="text-left px-4 py-3">Pesan</th>
              <th className="text-left px-4 py-3">Filter</th>
              <th className="text-right px-4 py-3">Target</th>
              <th className="text-right px-4 py-3">Sukses</th>
              <th className="text-right px-4 py-3">Gagal</th>
              <th className="text-left px-4 py-3">Status</th>
              <th className="text-left px-4 py-3">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Belum ada broadcast.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border align-top">
                <td className="px-4 py-3 tabular-nums text-xs whitespace-nowrap">{new Date(r.created_at).toLocaleString("id-ID")}</td>
                <td className="px-4 py-3 text-xs max-w-[320px]">
                  {r.judul && <div className="font-medium">{r.judul}</div>}
                  <div className="text-muted-foreground line-clamp-2">{r.pesan}</div>
                  {r.dry_run && <span className="text-[10px] italic text-amber-700">mode uji</span>}
                </td>
                <td className="px-4 py-3 text-xs">
                  {r.dusun_filter && <div>Dusun: {r.dusun_filter}</div>}
                  {r.topik && <div>Topik: {r.topik}</div>}
                  {!r.dusun_filter && !r.topik && <span className="text-muted-foreground">Semua</span>}
                </td>
                <td className="px-4 py-3 text-right tabular-nums">{r.total_target}</td>
                <td className="px-4 py-3 text-right tabular-nums text-emerald-700">{r.total_sukses}</td>
                <td className="px-4 py-3 text-right tabular-nums text-red-700">{r.total_gagal}</td>
                <td className="px-4 py-3">{badge(r.status)}</td>
                <td className="px-4 py-3">
                  <button onClick={() => setSelectedId(r.id)} className="text-xs underline hover:text-primary">
                    Detail →
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {selectedId && <BroadcastDetail id={selectedId} onClose={() => setSelectedId(null)} onRefresh={() => setReloadKey((k) => k + 1)} />}
    </>
  );
}

function BroadcastForm({ onDone }: { onDone: () => void }) {
  const [judul, setJudul] = useState("");
  const [pesan, setPesan] = useState("");
  const [dusun, setDusun] = useState("");
  const [topik, setTopik] = useState("");
  const [busy, setBusy] = useState(false);

  const kirim = async () => {
    if (!pesan.trim()) return toast.error("Pesan wajib diisi.");
    if (!confirm("Kirim broadcast sekarang?")) return;
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("wa-broadcast", {
      body: { judul: judul || undefined, pesan, dusun: dusun || undefined, topik: topik || undefined },
    });
    setBusy(false);
    if (error) return toast.error(error.message);
    if (data?.dryRun) toast.info(`Mode uji: ${data.total} target tercatat (FONNTE_TOKEN belum diset).`);
    else toast.success(`Terkirim: ${data?.sukses ?? 0} dari ${data?.total ?? 0}.`);
    setJudul(""); setPesan(""); setDusun(""); setTopik("");
    onDone();
  };

  return (
    <div className="mb-6 rounded-xl bg-card border border-border p-5 space-y-3">
      <h2 className="font-display text-lg font-semibold">Broadcast baru</h2>
      <div className="grid sm:grid-cols-2 gap-3">
        <label className="text-xs"><span className="block mb-1">Judul internal (opsional)</span>
          <input value={judul} onChange={(e) => setJudul(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="mis. Info Musdes Juli" autoComplete="off" />
        </label>
        <label className="text-xs"><span className="block mb-1">Filter Dusun (opsional)</span>
          <input value={dusun} onChange={(e) => setDusun(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Kosongkan = semua dusun" autoComplete="off" />
        </label>
        <label className="text-xs sm:col-span-2"><span className="block mb-1">Filter Topik (opsional)</span>
          <input value={topik} onChange={(e) => setTopik(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="mis. Pengumuman Resmi, Info Bencana" autoComplete="off" />
        </label>
      </div>
      <label className="text-xs block"><span className="block mb-1">Isi Pesan</span>
        <textarea rows={4} value={pesan} onChange={(e) => setPesan(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Contoh: [Info Desa] Musdes Sabtu 20 Juli 09.00 di Kantor Desa." autoComplete="off" />
      </label>
      <button onClick={kirim} disabled={busy} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60">
        {busy ? "Mengirim…" : "Kirim sekarang"}
      </button>
    </div>
  );
}

function BroadcastDetail({ id, onClose, onRefresh }: { id: string; onClose: () => void; onRefresh: () => void }) {
  const [reloadKey, setReloadKey] = useState(0);
  const { rows, loading } = useBroadcastTargets(id, reloadKey);
  const [busy, setBusy] = useState(false);

  const gagalCount = rows.filter((r) => r.status === "gagal" || r.status === "pending").length;

  const retry = async () => {
    if (!confirm(`Kirim ulang ${gagalCount} target yang gagal/tertunda?`)) return;
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("wa-broadcast", {
      body: { action: "retry", broadcastId: id },
    });
    setBusy(false);
    if (error) return toast.error(error.message);
    toast.success(`Retry: sukses ${data?.sukses ?? 0}, gagal ${data?.gagal ?? 0}.`);
    setReloadKey((k) => k + 1);
    onRefresh();
  };

  const badge = (s: string) => {
    const cls =
      s === "sukses" ? "bg-emerald-100 text-emerald-800" :
      s === "gagal" ? "bg-red-100 text-red-800" :
      "bg-amber-100 text-amber-800";
    return <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-medium uppercase ${cls}`}>{s}</span>;
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-start justify-center p-4 sm:p-8 overflow-y-auto" role="dialog" aria-modal="true">
      <div className="bg-background border border-border w-full max-w-4xl shadow-2xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-border">
          <h2 className="font-display text-lg font-semibold">Detail Broadcast · {rows.length} target</h2>
          <div className="flex gap-2">
            {gagalCount > 0 && (
              <button onClick={retry} disabled={busy} className="rounded-md bg-primary text-primary-foreground px-3 py-1.5 text-sm hover:bg-primary/90 disabled:opacity-60">
                {busy ? "Mengirim…" : `Kirim ulang ${gagalCount} gagal`}
              </button>
            )}
            <button onClick={onClose} className="rounded-md border border-border px-3 py-1.5 text-sm hover:bg-muted">Tutup</button>
          </div>
        </div>
        <div className="max-h-[70vh] overflow-y-auto">
          <table className="w-full text-sm">
            <thead className="bg-muted sticky top-0">
              <tr>
                <th className="text-left px-4 py-2">Nomor</th>
                <th className="text-left px-4 py-2">Nama</th>
                <th className="text-left px-4 py-2">Dusun</th>
                <th className="text-left px-4 py-2">Status</th>
                <th className="text-right px-4 py-2">Percobaan</th>
                <th className="text-left px-4 py-2">Terkirim</th>
                <th className="text-left px-4 py-2">Error</th>
              </tr>
            </thead>
            <tbody>
              {loading && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
              {rows.map((t) => (
                <tr key={t.id} className="border-t border-border align-top">
                  <td className="px-4 py-2 tabular-nums text-xs">{t.nomor_tujuan}</td>
                  <td className="px-4 py-2 text-xs">{t.nama || "-"}</td>
                  <td className="px-4 py-2 text-xs">{t.dusun || "-"}</td>
                  <td className="px-4 py-2">{badge(t.status)}</td>
                  <td className="px-4 py-2 text-right tabular-nums text-xs">{t.attempt}</td>
                  <td className="px-4 py-2 text-xs">{t.sent_at ? new Date(t.sent_at).toLocaleString("id-ID") : "-"}</td>
                  <td className="px-4 py-2 text-xs text-red-700 max-w-[240px] break-words">{t.error_message || "-"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

// ============ 15. Surat Ajuan ============
export function SuratAjuanAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [dnaData, setDnaData] = useState<any | null>(null);
  const [dnaFields, setDnaFields] = useState<any[]>([]);
  const [jenisSurat, setJenisSurat] = useState<any[]>([]);

  const load = () => {
    setLoading(true);
    supabase.from("surat_ajuan").select("*").order("created_at", { ascending: false }).then(({ data }) => {
      setRows(data || []);
      setLoading(false);
    });
  };

  useEffect(() => {
    load();
    supabase.from("surat_jenis").select("id, kode_surat, nama").eq("aktif", true).order("urutan").then(({ data }) => {
      setJenisSurat(data || []);
    });
  }, []);

  const viewDna = async (row: any) => {
    setDraft(row);
    setDnaData(null);
    const { data: dnaRows } = await supabase
      .from("surat_ajuan_data").select("*").eq("surat_ajuan_id", row.id).maybeSingle();
    setDnaData(dnaRows?.data_dna || null);
    if (row.jenis_surat_id) {
      const { data: fields } = await supabase
        .from("surat_jenis_dna").select("*").eq("jenis_surat_id", row.jenis_surat_id).order("urutan");
      setDnaFields(fields || []);
    } else {
      setDnaFields([]);
    }
  };

  const getJenisName = (id: string | null) => {
    if (!id) return "—";
    const j = jenisSurat.find((s) => s.id === id);
    return j ? `${j.kode_surat} — ${j.nama}` : id;
  };

  const save = async (row: any) => {
    const prevStatus = row._prevStatus;
    const payload = {
      ...row,
      status: row.status || "diproses",
      diproses_pada: row.status === "diproses" ? new Date().toISOString() : row.diproses_pada,
    };
    delete payload._prevStatus;

    const { error } = row.id
      ? await supabase.from("surat_ajuan").update(payload).eq("id", row.id)
      : await supabase.from("surat_ajuan").insert(payload);
    if (error) return toast.error(error.message);

    // Kirim notifikasi WA saat status berubah
    if (row.id && prevStatus && prevStatus !== payload.status) {
      (supabase.functions as any).invoke("notifikasi-status-surat", {
        body: { surat_ajuan_id: row.id, status_baru: payload.status },
      }).catch(() => { /* non-fatal */ });
    }

    toast.success("Tersimpan.");
    setDraft(null);
    setDnaData(null);
    setDnaFields([]);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus pengajuan ini?")) return;
    const { error } = await supabase.from("surat_ajuan").delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    load();
  };

  const statusBadge = (s: string) => {
    const colors: Record<string, string> = {
      menunggu: "bg-yellow-100 text-yellow-800",
      diproses: "bg-blue-100 text-blue-800",
      diterima: "bg-green-100 text-green-800",
      ditolak: "bg-red-100 text-red-800",
      dibatalkan: "bg-gray-100 text-gray-800",
    };
    return <span className={`px-2 py-0.5 rounded text-xs font-medium ${colors[s] || "bg-gray-100"}`}>{s}</span>;
  };

  const STATUS_OPTS = [
    { value: "menunggu", label: "Menunggu" },
    { value: "diproses", label: "Diproses" },
    { value: "diterima", label: "Diterima" },
    { value: "ditolak", label: "Ditolak" },
    { value: "dibatalkan", label: "Dibatalkan" },
  ];

  return (
    <>
      <div className="mb-6">
        <h1 className="font-display text-2xl font-bold">Pengajuan Surat</h1>
        <p className="text-sm text-muted-foreground mt-1">Kelola pengajuan surat keterangan dari warga. Klik &quot;Lihat&quot; untuk melihat data DNA pemohon.</p>
      </div>

      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-display font-semibold">
              {draft.id ? "Edit / Lihat" : "Tambah"} — {draft.nomor_tiket}
            </h3>
            <button onClick={() => { setDraft(null); setDnaData(null); setDnaFields([]); }} className="text-sm text-muted-foreground hover:text-foreground">Tutup</button>
          </div>

          {/* DNA Data Display */}
          {dnaData && dnaFields.length > 0 && (
            <div className="mb-4 rounded-lg bg-muted/50 border border-border p-4">
              <h4 className="font-display text-xs font-bold uppercase tracking-widest text-accent mb-3">Data Pengajuan (DNA)</h4>
              <dl className="grid sm:grid-cols-2 gap-2 text-sm">
                {dnaFields.map((f) => {
                  const val = dnaData[f.field_name];
                  if (val === null || val === undefined || val === "") return null;
                  return (
                    <div key={f.field_name} className="border-b border-border/50 pb-1.5">
                      <dt className="text-xs text-muted-foreground font-medium">{f.label}</dt>
                      <dd className="mt-0.5 font-medium">{String(val)}</dd>
                    </div>
                  );
                })}
              </dl>
            </div>
          )}
          <div className="grid sm:grid-cols-2 gap-3">
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nama Pemohon</span>
              <input value={draft.nama || ""} onChange={(e) => setDraft({ ...draft, nama: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="name" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">NIK</span>
              <input value={draft.nik || ""} onChange={(e) => setDraft({ ...draft, nik: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Kontak (WA)</span>
              <input value={draft.kontak || ""} onChange={(e) => setDraft({ ...draft, kontak: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="tel" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Status</span>
              <select value={draft.status || "menunggu"} onChange={(e) => setDraft({ ...draft, status: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                {STATUS_OPTS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            </label>
            <label className="text-xs sm:col-span-2">
              <span className="block mb-1 font-medium">Keperluan</span>
              <textarea rows={3} value={draft.keperluan || ""} onChange={(e) => setDraft({ ...draft, keperluan: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs sm:col-span-2">
              <span className="block mb-1 font-medium">Keterangan Admin</span>
              <textarea rows={2} value={draft.keterangan || ""} onChange={(e) => setDraft({ ...draft, keterangan: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Catatan dari admin..." autoComplete="off" />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            <button onClick={() => save(draft)} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90">Simpan</button>
            {draft.status === "diproses" && (
              <button
                onClick={() => { setDraft(null); setDnaData(null); setDnaFields([]); toast.info("Buka menu Surat Terbit untuk menerbitkan surat."); }}
                className="rounded-md bg-green-600 text-white px-4 py-2 text-sm hover:bg-green-700"
              >
                Terbitkan Surat
              </button>
            )}
            <button onClick={() => { setDraft(null); setDnaData(null); setDnaFields([]); }} className="rounded-md border border-border px-4 py-2 text-sm hover:bg-muted">Batal</button>
          </div>
        </div>
      )}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">No. Tiket</th>
              <th className="text-left px-4 py-3">Tanggal</th>
              <th className="text-left px-4 py-3">Nama</th>
              <th className="text-left px-4 py-3">NIK</th>
              <th className="text-left px-4 py-3">Jenis</th>
              <th className="text-left px-4 py-3">Keperluan</th>
              <th className="text-left px-4 py-3">Status</th>
              <th className="px-4 py-3 w-48"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Belum ada pengajuan.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 font-mono text-xs">{r.nomor_tiket}</td>
                <td className="px-4 py-3">{new Date(r.created_at).toLocaleDateString("id-ID")}</td>
                <td className="px-4 py-3">{r.nama}</td>
                <td className="px-4 py-3 font-mono text-xs">{r.nik}</td>
                <td className="px-4 py-3 text-xs max-w-[160px] truncate">{getJenisName(r.jenis_surat_id)}</td>
                <td className="px-4 py-3 max-w-[200px] truncate">{r.keperluan}</td>
                <td className="px-4 py-3">{statusBadge(r.status)}</td>
                <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                  <button onClick={() => viewDna(r)} className="rounded-md border border-border px-2 py-1 text-xs hover:bg-muted">Lihat</button>
                  <button onClick={() => setDraft({ ...r, _prevStatus: r.status })} className="rounded-md border border-border px-2 py-1 text-xs hover:bg-muted">Edit</button>
                  <button onClick={() => del(r.id)} className="rounded-md border border-red-200 text-red-600 px-2 py-1 text-xs hover:bg-red-50">Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ============ 16. Balita Admin ============
export function BalitaAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<any | null>(null);
  const [dusunOpts, setDusunOpts] = useState<any[]>([]);

  const load = () => {
    setLoading(true);
    supabase.from("balita").select("*").order("nama").then(({ data }) => {
      setRows(data || []);
      setLoading(false);
    });
  };

  useEffect(() => {
    load();
    supabase.from("wilayah_dusun").select("nama").order("urutan").then(({ data }) => {
      setDusunOpts(data || []);
    });
  }, []);

  const save = async (row: any) => {
    const { id, created_at, updated_at, ...payload } = row;
    const { error } = id
      ? await supabase.from("balita").update(payload).eq("id", id)
      : await supabase.from("balita").insert(payload);
    if (error) return toast.error(error.message);
    toast.success("Tersimpan.");
    setDraft(null);
    load();
  };

  const del = async (id: string) => {
    if (!confirm("Hapus data ini?")) return;
    const { error } = await supabase.from("balita").delete().eq("id", id);
    if (error) return toast.error(error.message);
    toast.success("Terhapus.");
    load();
  };

  const JK_OPTS = [
    { value: "laki-laki", label: "Laki-laki" },
    { value: "perempuan", label: "Perempuan" },
  ];

  return (
    <>
      <div className="mb-6 flex justify-between items-start">
        <div>
          <h1 className="font-display text-2xl font-bold">Data Balita</h1>
          <p className="text-sm text-muted-foreground mt-1">Kelola data balita untuk monitoring posyandu.</p>
        </div>
        <button onClick={() => setDraft({ nama: "", tanggal_lahir: "", jenis_kelamin: "laki-laki", dusun: "", alamat: "" })} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90">+ Tambah</button>
      </div>

      {draft && (
        <div className="mb-6 rounded-xl bg-card border border-border p-5">
          <h3 className="font-display font-semibold mb-3">{draft.id ? "Edit" : "Tambah"} Balita</h3>
          <div className="grid sm:grid-cols-2 gap-3">
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nama Lengkap *</span>
              <input value={draft.nama || ""} onChange={(e) => setDraft({ ...draft, nama: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="name" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">NIK Anak</span>
              <input value={draft.nik_anak || ""} onChange={(e) => setDraft({ ...draft, nik_anak: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Tanggal Lahir *</span>
              <input type="date" value={draft.tanggal_lahir || ""} onChange={(e) => setDraft({ ...draft, tanggal_lahir: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="off" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Jenis Kelamin</span>
              <select value={draft.jenis_kelamin || "laki-laki"} onChange={(e) => setDraft({ ...draft, jenis_kelamin: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                {JK_OPTS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Nama Orang Tua</span>
              <input value={draft.nama_ortu || ""} onChange={(e) => setDraft({ ...draft, nama_ortu: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="name" />
            </label>
            <label className="text-xs">
              <span className="block mb-1 font-medium">Dusun</span>
              <select value={draft.dusun || ""} onChange={(e) => setDraft({ ...draft, dusun: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                <option value="">— pilih —</option>
                {dusunOpts.map((d) => <option key={d.nama} value={d.nama}>{d.nama}</option>)}
              </select>
            </label>
            <label className="text-xs sm:col-span-2">
              <span className="block mb-1 font-medium">Alamat Lengkap</span>
              <input value={draft.alamat || ""} onChange={(e) => setDraft({ ...draft, alamat: e.target.value })} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" autoComplete="street-address" />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            <button onClick={() => save(draft)} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:bg-primary/90">Simpan</button>
            <button onClick={() => setDraft(null)} className="rounded-md border border-border px-4 py-2 text-sm hover:bg-muted">Batal</button>
          </div>
        </div>
      )}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Nama</th>
              <th className="text-left px-4 py-3">JK</th>
              <th className="text-left px-4 py-3">Tanggal Lahir</th>
              <th className="text-left px-4 py-3">Usia</th>
              <th className="text-left px-4 py-3">Orang Tua</th>
              <th className="text-left px-4 py-3">Dusun</th>
              <th className="px-4 py-3 w-40"></th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Belum ada data balita.</td></tr>}
            {rows.map((r) => {
              const age = r.tanggal_lahir ? Math.floor((Date.now() - new Date(r.tanggal_lahir).getTime()) / (365.25 * 24 * 60 * 60 * 1000)) : "-";
              return (
                <tr key={r.id} className="border-t border-border">
                  <td className="px-4 py-3">{r.nama}</td>
                  <td className="px-4 py-3">{r.jenis_kelamin === "laki-laki" ? "L" : "P"}</td>
                  <td className="px-4 py-3">{r.tanggal_lahir ? new Date(r.tanggal_lahir).toLocaleDateString("id-ID") : "-"}</td>
                  <td className="px-4 py-3">{typeof age === "number" ? `${age} th` : age}</td>
                  <td className="px-4 py-3">{r.nama_ortu || "-"}</td>
                  <td className="px-4 py-3">{r.dusun || "-"}</td>
                  <td className="px-4 py-3 text-right whitespace-nowrap space-x-2">
                    <button onClick={() => setDraft(r)} className="rounded-md border border-border px-2 py-1 text-xs hover:bg-muted">Edit</button>
                    <button onClick={() => del(r.id)} className="rounded-md border border-red-200 text-red-600 px-2 py-1 text-xs hover:bg-red-50">Hapus</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ============ 17. WA Chatbot Monitor ============
export function WaChatbotAdmin() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const load = () => {
    setLoading(true);
    supabase.from("wa_chatbot_session").select("*").order("created_at", { ascending: false }).limit(100).then(({ data }) => {
      // Transform data untuk kompatibilitas UI
      const transformed = (data || []).map(r => ({
        ...r,
        // Gunakan kolom yang ada di database
        phone_number: r.phone_number || r.nomor_wa,
        intent: r.intent || r.last_menu || extractIntent(r.step_data),
        last_message: r.last_message || extractLastMessage(r.step_data),
        chat_status: r.chat_status || r.state,
      }));
      setRows(transformed);
      setLoading(false);
    });
  };

  useEffect(() => {
    load();
  }, []);

  // Helper untuk extract intent dari step_data JSONB
  const extractIntent = (stepData: any): string => {
    if (!stepData) return "-";
    if (typeof stepData === "string") {
      try { stepData = JSON.parse(stepData); } catch { return "-"; }
    }
    return stepData.intent || stepData.last_intent || "-";
  };

  // Helper untuk extract last message dari step_data JSONB
  const extractLastMessage = (stepData: any): string => {
    if (!stepData) return "-";
    if (typeof stepData === "string") {
      try { stepData = JSON.parse(stepData); } catch { return "-"; }
    }
    return stepData.last_message || stepData.input || "-";
  };

  const intentBadge = (intent: string) => {
    const colors: Record<string, string> = {
      warga: "bg-blue-100 text-blue-800",
      umum: "bg-gray-100 text-gray-800",
      bantuan: "bg-green-100 text-green-800",
      kegiatan: "bg-purple-100 text-purple-800",
      surat: "bg-yellow-100 text-yellow-800",
    };
    return <span className={`px-2 py-0.5 rounded text-xs font-medium ${colors[intent] || "bg-gray-100"}`}>{intent || "umum"}</span>;
  };

  const statusBadge = (status: string) => {
    const colors: Record<string, string> = {
      active: "bg-green-100 text-green-800",
      resolved: "bg-blue-100 text-blue-800",
      closed: "bg-gray-100 text-gray-800",
    };
    return <span className={`px-2 py-0.5 rounded text-xs font-medium ${colors[status] || "bg-gray-100"}`}>{status || "unknown"}</span>;
  };

  return (
    <>
      <div className="mb-6 flex justify-between items-start">
        <div>
          <h1 className="font-display text-2xl font-bold">WA Chatbot Monitor</h1>
          <p className="text-sm text-muted-foreground mt-1">Monitoring percakapan warga dengan chatbot WhatsApp.</p>
        </div>
        <button onClick={load} className="rounded-md border border-border px-4 py-2 text-sm hover:bg-muted">Muat ulang</button>
      </div>

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Waktu</th>
              <th className="text-left px-4 py-3">Nomor WA</th>
              <th className="text-left px-4 py-3">Intent</th>
              <th className="text-left px-4 py-3">Pesan Terakhir</th>
              <th className="text-left px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Belum ada percakapan.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border">
                <td className="px-4 py-3 text-xs">{new Date(r.created_at).toLocaleString("id-ID")}</td>
                <td className="px-4 py-3 font-mono text-xs">{r.phone_number || "-"}</td>
                <td className="px-4 py-3">{intentBadge(r.intent)}</td>
                <td className="px-4 py-3 max-w-[300px] truncate">{r.last_message || "-"}</td>
                <td className="px-4 py-3">{statusBadge(r.chat_status)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
