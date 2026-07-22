import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { EditorialLayout, SectionWrap } from "./ui";
import { EditorialTitle, StatsBand } from "./sections";
import { Seo } from "./lib/seo";

const inp = "w-full border border-current/25 bg-transparent px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-accent";
const btn = "bg-accent text-primary px-5 py-2.5 text-sm font-semibold hover:opacity-90 disabled:opacity-60";

// ================= Statistik Penduduk (live view) =================
export function StatistikPendudukLivePage() {
  const [agg, setAgg] = useState<any | null>(null);
  const [perDusun, setPerDusun] = useState<any[]>([]);
  useEffect(() => {
    (async () => {
      const [a, d] = await Promise.all([
        (supabase as any).from("penduduk_statistik").select("*").maybeSingle(),
        (supabase as any).from("penduduk_per_dusun").select("*"),
      ]);
      setAgg(a.data); setPerDusun(d.data || []);
    })();
  }, []);
  const total = Number(agg?.total ?? 0);
  const maxDusun = Math.max(1, ...perDusun.map((r) => Number(r.jumlah)));
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Statistik Penduduk"
      deskripsi="Agregat data warga desa yang dihitung langsung dari registri penduduk."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Penduduk" }]}
    >
      <Seo title="Statistik Penduduk" description="Distribusi penduduk per dusun & jenis kelamin." path="/statistik/penduduk" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: total.toLocaleString("id-ID"), label: "Total Jiwa", highlight: true },
          { nilai: Number(agg?.kk ?? 0).toLocaleString("id-ID"), label: "Kepala Keluarga" },
          { nilai: Number(agg?.laki ?? 0).toLocaleString("id-ID"), label: "Laki-laki" },
          { nilai: Number(agg?.perempuan ?? 0).toLocaleString("id-ID"), label: "Perempuan" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Distribusi" judul="Per Dusun" />
        {!perDusun.length && <p className="text-sm opacity-70">Belum ada data penduduk yang terinput.</p>}
        <ul className="space-y-4">
          {perDusun.map((r) => (
            <li key={r.dusun}>
              <div className="flex justify-between text-sm mb-1">
                <span className="font-medium">{r.dusun}</span>
                <span className="tabular-nums">{Number(r.jumlah).toLocaleString("id-ID")} jiwa · L {r.laki} / P {r.perempuan}</span>
              </div>
              <div className="h-[3px] bg-current/10 overflow-hidden">
                <div className="h-full bg-accent" style={{ width: `${(Number(r.jumlah) / maxDusun) * 100}%` }} />
              </div>
            </li>
          ))}
        </ul>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ================= IDM live =================
export function IDMLivePage() {
  const [rows, setRows] = useState<any[]>([]);
  useEffect(() => {
    (supabase as any).from("idm_indikator").select("*")
      .eq("published", true).order("tahun", { ascending: false }).order("dimensi")
      .then(({ data }: any) => setRows(data || []));
  }, []);
  const tahunTerbaru = rows[0]?.tahun ?? new Date().getFullYear();
  const kini = rows.filter((r) => r.tahun === tahunTerbaru);
  const perDim = useMemo(() => {
    const g: Record<string, any[]> = {};
    kini.forEach((r) => { (g[r.dimensi] ||= []).push(r); });
    return g;
  }, [kini]);
  const skorRata = (arr: any[]) => arr.length ? arr.reduce((a, r) => a + Number(r.skor || 0), 0) / arr.length : 0;
  const skorTotal = kini.length ? kini.reduce((a, r) => a + Number(r.skor || 0), 0) / kini.length : 0;
  const status = skorTotal >= 0.815 ? "Mandiri" : skorTotal >= 0.707 ? "Maju" : skorTotal >= 0.599 ? "Berkembang" : skorTotal >= 0.491 ? "Tertinggal" : "Sangat Tertinggal";
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Status IDM"
      deskripsi="Indeks Desa Membangun dihitung dari tiga dimensi: sosial, ekonomi, dan ekologi."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "IDM" }]}
    >
      <Seo title="Status IDM" description="Skor & rincian IDM per dimensi." path="/status-idm" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: skorTotal.toFixed(4), label: `Skor IDM ${tahunTerbaru}`, highlight: true },
          { nilai: status, label: "Status Desa" },
          { nilai: String(Object.keys(perDim).length || 0), label: "Dimensi" },
          { nilai: String(kini.length), label: "Indikator" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Rincian" judul="Per Dimensi" />
        {!kini.length && <p className="text-sm opacity-70">Belum ada indikator IDM yang dipublikasikan.</p>}
        <div className="grid md:grid-cols-3 gap-px bg-current/15">
          {Object.entries(perDim).map(([dim, arr]) => (
            <div key={dim} className="bg-background p-6">
              <div className="font-display font-semibold">{dim}</div>
              <div className="mt-2 font-display text-4xl font-bold italic text-accent tabular-nums">{skorRata(arr).toFixed(4)}</div>
              <ul className="mt-4 space-y-2 text-xs opacity-80">
                {arr.map((r) => (
                  <li key={r.id} className="flex justify-between gap-4">
                    <span className="truncate">{r.indikator}</span>
                    <span className="tabular-nums">{Number(r.skor || 0).toFixed(3)}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ================= Analisis publik =================
export function AnalisisPage() {
  const [rows, setRows] = useState<any[]>([]);
  useEffect(() => {
    (supabase as any).from("analisis_snapshot").select("*")
      .eq("published", true).order("tahun", { ascending: false })
      .then(({ data }: any) => setRows(data || []));
  }, []);
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Analisis Desa"
      deskripsi="Ringkasan hasil analisis lintas indikator desa berdasarkan data terkini."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Analisis" }]}
    >
      <Seo title="Analisis Desa" description="Snapshot indikator lintas kategori." path="/analisis" />
      <SectionWrap>
        {!rows.length && <p className="text-sm opacity-70">Belum ada analisis yang dipublikasikan.</p>}
        <div className="grid md:grid-cols-2 gap-px bg-current/15">
          {rows.map((r) => (
            <article key={r.id} className="bg-background p-6">
              <div className="text-[10px] uppercase tracking-widest text-accent">{r.kategori} · {r.tahun}</div>
              <h3 className="mt-2 font-display text-xl font-bold">{r.judul}</h3>
              {r.ringkasan && <p className="mt-3 text-sm opacity-85 whitespace-pre-line">{r.ringkasan}</p>}
            </article>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ================= Suplesi Data (public form) =================
export function SuplesiPage() {
  const [form, setForm] = useState({ nik: "", nama: "", kontak: "", jenis: "koreksi_data", deskripsi: "", lampiran_url: "" });
  const [loading, setLoading] = useState(false);
  const [tiket, setTiket] = useState<string | null>(null);
  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const { data, error } = await (supabase as any).functions.invoke("submit-suplesi", { body: form });
    setLoading(false);
    if (error || data?.error) return toast.error(data?.error || error?.message || "Gagal mengirim.");
    setTiket(data.nomor_tiket);
    toast.success("Pengajuan terkirim.");
    setForm({ nik: "", nama: "", kontak: "", jenis: "koreksi_data", deskripsi: "", lampiran_url: "" });
  };
  return (
    <EditorialLayout
      eyebrow="Layanan Warga"
      judul="Suplesi Data"
      deskripsi="Ajukan pembetulan atau pemutakhiran data kependudukan Anda. Petugas akan memverifikasi dan menindaklanjuti."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Layanan", to: "/layanan" }, { label: "Suplesi Data" }]}
    >
      <Seo title="Suplesi Data" description="Pembetulan & pemutakhiran data warga." path="/layanan/suplesi" />
      <SectionWrap>
        <div className="grid md:grid-cols-2 gap-10">
          <div>
            <EditorialTitle kicker="Formulir" judul="Ajukan Pembetulan" />
            {tiket && (
              <div className="mb-6 border border-accent/50 p-4">
                <div className="text-xs uppercase tracking-widest text-accent">Nomor Tiket</div>
                <div className="font-mono text-lg font-bold">{tiket}</div>
                <p className="text-xs mt-1 opacity-75">Simpan nomor ini untuk konfirmasi kepada petugas.</p>
              </div>
            )}
            <form onSubmit={submit} className="space-y-3">
              <label className="block text-sm"><span className="block text-xs mb-1">Nama Lengkap</span>
                <input required value={form.nama} onChange={(e) => setForm({ ...form, nama: e.target.value })} className={inp} /></label>
              <label className="block text-sm"><span className="block text-xs mb-1">NIK (opsional)</span>
                <input value={form.nik} onChange={(e) => setForm({ ...form, nik: e.target.value })} className={inp} /></label>
              <label className="block text-sm"><span className="block text-xs mb-1">Kontak (WA/HP)</span>
                <input value={form.kontak} onChange={(e) => setForm({ ...form, kontak: e.target.value })} className={inp} /></label>
              <label className="block text-sm"><span className="block text-xs mb-1">Jenis Pengajuan</span>
                <select value={form.jenis} onChange={(e) => setForm({ ...form, jenis: e.target.value })} className={inp}>
                  <option value="koreksi_data">Koreksi Data</option>
                  <option value="pindah_datang">Pindah Datang</option>
                  <option value="pindah_keluar">Pindah Keluar</option>
                  <option value="kelahiran">Laporan Kelahiran</option>
                  <option value="kematian">Laporan Kematian</option>
                  <option value="lainnya">Lainnya</option>
                </select></label>
              <label className="block text-sm"><span className="block text-xs mb-1">Uraian</span>
                <textarea required rows={5} value={form.deskripsi} onChange={(e) => setForm({ ...form, deskripsi: e.target.value })} className={inp} /></label>
              <label className="block text-sm"><span className="block text-xs mb-1">Lampiran (URL foto/scan, opsional)</span>
                <input value={form.lampiran_url} onChange={(e) => setForm({ ...form, lampiran_url: e.target.value })} className={inp} /></label>
              <button disabled={loading} className={btn}>{loading ? "Mengirim…" : "Kirim Pengajuan"}</button>
            </form>
          </div>
          <div className="text-sm space-y-4 opacity-90">
            <EditorialTitle kicker="Panduan" judul="Alur Suplesi" />
            <ol className="list-decimal pl-5 space-y-2">
              <li>Isi formulir dengan data valid & sertakan lampiran bila perlu.</li>
              <li>Petugas memverifikasi pengajuan Anda dalam 1–3 hari kerja.</li>
              <li>Kami menghubungi Anda melalui kontak yang tertera untuk klarifikasi bila dibutuhkan.</li>
              <li>Status akhir (disetujui / ditolak / selesai) akan diinformasikan beserta alasannya.</li>
            </ol>
          </div>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}