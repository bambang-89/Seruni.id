import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { EditorialLayout, EditorialCard, EditorialProgress, SectionWrap, formatTanggal } from "./ui";
import { EditorialTitle, StatsBand } from "./sections";
import { Seo } from "./lib/seo";
import { useDusun } from "./lib/queries";
import {
  useRpjmdesAktif,
  useRkpdesTahunList,
  useRkpdesKegiatan,
  useUsulanPublik,
  useVotingTopikList,
  useVotingOpsi,
  type UsulanWarga,
  type VotingTopik,
} from "./lib/queries";
import { uploadImage } from "./lib/upload";

const inp = "mt-1 w-full border border-current/25 bg-transparent px-3 py-2 text-sm focus:outline-none focus:border-accent";
const btnPri = "inline-flex items-center gap-3 border border-accent bg-accent text-primary px-5 py-2.5 font-display text-[11px] font-bold uppercase tracking-[0.28em] hover:bg-accent/85 transition-colors disabled:opacity-50";
const btnSec = "inline-flex items-center gap-3 border border-current/40 px-5 py-2.5 font-display text-[11px] font-bold uppercase tracking-[0.28em] hover:border-accent hover:text-accent transition-colors";

const rupiah = (n: number) => "Rp " + n.toLocaleString("id-ID");

const KATEGORI = [
  { value: "infrastruktur", label: "Infrastruktur" },
  { value: "ekonomi", label: "Ekonomi" },
  { value: "sosial", label: "Sosial" },
  { value: "pendidikan", label: "Pendidikan" },
  { value: "kesehatan", label: "Kesehatan" },
  { value: "lingkungan", label: "Lingkungan" },
  { value: "pemerintahan", label: "Pemerintahan" },
  { value: "lainnya", label: "Lainnya" },
];

// =========================== RPJMDes ===========================
export function RPJMDesPage() {
  const { periode, bidang, program, loading } = useRpjmdesAktif();
  const [bidangFilter, setBidangFilter] = useState<string>("");

  const totalAnggaran = program.reduce((s, p) => s + (p.anggaran_indikatif || 0), 0);
  const filteredProg = bidangFilter ? program.filter((p) => p.bidang_id === bidangFilter) : program;

  return (
    <EditorialLayout
      eyebrow="Perencanaan Desa"
      judul="RPJMDes Desa"
      deskripsi="Rencana Pembangunan Jangka Menengah Desa: visi, misi, bidang, dan program lintas tahun."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Perencanaan" }, { label: "RPJMDes" }]}
    >
      <Seo title="RPJMDes" description="Visi, misi, dan program pembangunan jangka menengah desa." path="/perencanaan/rpjmdes" />
      {loading ? (
        <SectionWrap><p className="opacity-60">Memuat…</p></SectionWrap>
      ) : !periode ? (
        <SectionWrap><p className="opacity-70">Belum ada RPJMDes yang dipublikasikan.</p></SectionWrap>
      ) : (
        <>
          <StatsBand
            tone="dark"
            items={[
              { nilai: `${periode.tahun_mulai}–${periode.tahun_selesai}`, label: "Periode", highlight: true },
              { nilai: String(bidang.length), label: "Bidang" },
              { nilai: String(program.length), label: "Program" },
              { nilai: rupiah(totalAnggaran), label: "Anggaran Indikatif" },
            ]}
          />
          <SectionWrap>
            <EditorialTitle kicker={periode.nama} judul="Visi Misi" />
            <p className="text-lg leading-relaxed opacity-90 mb-6">{periode.visi}</p>
            <ol className="space-y-3">
              {periode.misi.map((m, i) => (
                <li key={i} className="grid grid-cols-[48px_1fr] gap-4 border-b border-current/15 pb-3">
                  <span className="font-display text-2xl font-light opacity-30 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
                  <span className="leading-relaxed">{m}</span>
                </li>
              ))}
            </ol>
          </SectionWrap>
          <SectionWrap>
            <EditorialTitle kicker="Bidang" judul="Prioritas Pembangunan" />
            <div className="grid md:grid-cols-2 gap-4 mb-8">
              {bidang.map((b) => (
                <button
                  key={b.id}
                  onClick={() => setBidangFilter(bidangFilter === b.id ? "" : b.id)}
                  className={`text-left border p-5 transition-colors ${bidangFilter === b.id ? "border-accent bg-accent/10" : "border-current/20 hover:border-accent"}`}
                >
                  <div className="font-display text-[10px] uppercase tracking-widest opacity-60">{b.kode}</div>
                  <div className="font-display font-semibold text-lg mt-1">{b.nama}</div>
                  {b.deskripsi && <p className="text-sm opacity-75 mt-2">{b.deskripsi}</p>}
                </button>
              ))}
            </div>
          </SectionWrap>
          <SectionWrap>
            <div className="flex items-baseline justify-between mb-4">
              <EditorialTitle kicker="Program" judul={bidangFilter ? "Program Bidang" : "Semua Program"} />
              {bidangFilter && <button onClick={() => setBidangFilter("")} className="text-xs underline opacity-70">Reset filter</button>}
            </div>
            <div className="overflow-x-auto border border-current/15">
              <table className="w-full text-sm">
                <thead className="bg-current/5">
                  <tr>
                    <th className="text-left px-4 py-3 font-display">Program</th>
                    <th className="text-left px-4 py-3 font-display">Indikator / Target</th>
                    <th className="text-left px-4 py-3 font-display">Sumber Dana</th>
                    <th className="text-left px-4 py-3 font-display">Tahun</th>
                    <th className="text-right px-4 py-3 font-display">Anggaran</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredProg.map((p) => (
                    <tr key={p.id} className="border-t border-current/10">
                      <td className="px-4 py-3 font-medium">{p.nama}</td>
                      <td className="px-4 py-3 opacity-80">{[p.indikator, p.target].filter(Boolean).join(" — ")}</td>
                      <td className="px-4 py-3 opacity-80">{p.sumber_dana || "—"}</td>
                      <td className="px-4 py-3 opacity-80 whitespace-nowrap">{p.tahun_mulai || "—"}{p.tahun_selesai ? `–${p.tahun_selesai}` : ""}</td>
                      <td className="px-4 py-3 text-right tabular-nums">{rupiah(p.anggaran_indikatif)}</td>
                    </tr>
                  ))}
                  {!filteredProg.length && (
                    <tr><td colSpan={5} className="px-4 py-6 text-center opacity-60">Belum ada program.</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </SectionWrap>
        </>
      )}
    </EditorialLayout>
  );
}

// =========================== RKPDes ===========================
export function RKPDesPage() {
  const tahunList = useRkpdesTahunList();
  const [tahunId, setTahunId] = useState<string | null>(null);
  useEffect(() => { if (!tahunId && tahunList.length) setTahunId(tahunList[0].id); }, [tahunList, tahunId]);
  const { rows, loading } = useRkpdesKegiatan(tahunId);
  const [statusF, setStatusF] = useState("");
  const [dusunF, setDusunF] = useState("");
  const filtered = rows.filter((r) =>
    (!statusF || r.status_realisasi === statusF) &&
    (!dusunF || (r.dusun || "").toLowerCase().includes(dusunF.toLowerCase()))
  );
  const totalAnggaran = filtered.reduce((s, r) => s + r.anggaran, 0);
  const progresRata = filtered.length ? Math.round(filtered.reduce((s, r) => s + r.progress_pct, 0) / filtered.length) : 0;

  return (
    <EditorialLayout
      eyebrow="Perencanaan Desa"
      judul="RKPDes Tahunan"
      deskripsi="Rencana Kerja Pemerintah Desa: kegiatan, anggaran, dan progres realisasi per tahun."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Perencanaan" }, { label: "RKPDes" }]}
    >
      <Seo title="RKPDes" description="Kegiatan, anggaran, dan realisasi RKPDes." path="/perencanaan/rkpdes" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: tahunList[0]?.tahun.toString() ?? "—", label: "Tahun Aktif", highlight: true },
          { nilai: String(filtered.length), label: "Kegiatan" },
          { nilai: rupiah(totalAnggaran), label: "Total Anggaran" },
          { nilai: `${progresRata}%`, label: "Rata-rata Progres" },
        ]}
      />
      <SectionWrap>
        <div className="flex flex-wrap gap-3 items-end mb-6">
          <label className="text-sm">
            <span className="block text-[10px] uppercase tracking-widest opacity-60 mb-1">Tahun</span>
            <select value={tahunId ?? ""} onChange={(e) => setTahunId(e.target.value)} className={inp}>
              {tahunList.map((t) => <option key={t.id} value={t.id}>{t.tahun}</option>)}
            </select>
          </label>
          <label className="text-sm">
            <span className="block text-[10px] uppercase tracking-widest opacity-60 mb-1">Status</span>
            <select value={statusF} onChange={(e) => setStatusF(e.target.value)} className={inp}>
              <option value="">Semua</option>
              <option value="rencana">Rencana</option>
              <option value="berjalan">Berjalan</option>
              <option value="selesai">Selesai</option>
              <option value="tertunda">Tertunda</option>
              <option value="batal">Batal</option>
            </select>
          </label>
          <label className="text-sm">
            <span className="block text-[10px] uppercase tracking-widest opacity-60 mb-1">Dusun</span>
            <input value={dusunF} onChange={(e) => setDusunF(e.target.value)} className={inp} placeholder="Cari dusun…" />
          </label>
        </div>

        {loading ? <p className="opacity-60">Memuat…</p> : (
          <ul className="space-y-6">
            {filtered.map((k) => (
              <li key={k.id} className="border-b border-current/15 pb-6">
                <div className="flex flex-wrap items-baseline justify-between gap-3 mb-2">
                  <div>
                    <div className="font-display font-semibold text-lg">{k.nama}</div>
                    <div className="text-xs opacity-70 mt-1">
                      {[k.dusun, k.lokasi, k.waktu].filter(Boolean).join(" · ")}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-display tabular-nums">{rupiah(k.anggaran)}</div>
                    <div className="text-[10px] uppercase tracking-widest opacity-60">{k.sumber_dana || "—"} · {k.status_realisasi}</div>
                  </div>
                </div>
                <EditorialProgress label="Progres realisasi" value={k.progress_pct} max={100} suffix="%" />
              </li>
            ))}
            {!filtered.length && <li className="opacity-60">Tidak ada kegiatan yang cocok dengan filter.</li>}
          </ul>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// =========================== Usulan Warga ===========================

function UsulanForm({ onSubmitted }: { onSubmitted: (tiket: string) => void }) {
  const { data: dusunList } = useDusun();
  const [busy, setBusy] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [form, setForm] = useState({
    nama: "", kontak: "", dusun: "", kategori: "infrastruktur",
    judul: "", deskripsi: "", lokasi: "", foto_url: "",
  });

  const onFile = async (f: File | null) => {
    if (!f) return;
    setUploading(true);
    try {
      const url = await uploadImage("usulan", f);
      setForm((s) => ({ ...s, foto_url: url }));
      toast.success("Foto terunggah.");
    } catch (e: any) { toast.error(e.message || "Gagal upload."); }
    finally { setUploading(false); }
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.nama.trim().length < 2) return toast.error("Nama wajib diisi.");
    if (form.judul.trim().length < 5) return toast.error("Judul minimal 5 karakter.");
    if (form.deskripsi.trim().length < 10) return toast.error("Deskripsi terlalu pendek.");
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("submit-usulan", { body: form });
    setBusy(false);
    if (error || (data as any)?.error) {
      toast.error((data as any)?.error || error?.message || "Gagal mengirim usulan.");
      return;
    }
    const tiket = (data as any).nomor_tiket as string;
    toast.success(`Usulan terkirim. Nomor tiket: ${tiket}`);
    onSubmitted(tiket);
    setForm({ nama: "", kontak: "", dusun: "", kategori: "infrastruktur", judul: "", deskripsi: "", lokasi: "", foto_url: "" });
  };

  return (
    <form onSubmit={submit} className="grid md:grid-cols-2 gap-4">
      <label className="text-sm md:col-span-1">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Nama <span className="text-accent">*</span></span>
        <input required maxLength={120} value={form.nama} onChange={(e) => setForm({ ...form, nama: e.target.value })} className={inp} />
      </label>
      <label className="text-sm">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Kontak (HP/Email)</span>
        <input maxLength={60} value={form.kontak} onChange={(e) => setForm({ ...form, kontak: e.target.value })} className={inp} placeholder="opsional" />
      </label>
      <label className="text-sm">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Dusun</span>
        <select value={form.dusun} onChange={(e) => setForm({ ...form, dusun: e.target.value })} className={inp}>
          <option value="">— pilih —</option>
          {dusunList.map((d) => <option key={d.nama} value={d.nama}>{d.nama}</option>)}
        </select>
      </label>
      <label className="text-sm">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Kategori <span className="text-accent">*</span></span>
        <select required value={form.kategori} onChange={(e) => setForm({ ...form, kategori: e.target.value })} className={inp}>
          {KATEGORI.map((k) => <option key={k.value} value={k.value}>{k.label}</option>)}
        </select>
      </label>
      <label className="text-sm md:col-span-2">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Judul <span className="text-accent">*</span></span>
        <input required maxLength={160} value={form.judul} onChange={(e) => setForm({ ...form, judul: e.target.value })} className={inp} placeholder="Ringkas usulan Anda" />
      </label>
      <label className="text-sm md:col-span-2">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Deskripsi <span className="text-accent">*</span></span>
        <textarea required maxLength={4000} rows={5} value={form.deskripsi} onChange={(e) => setForm({ ...form, deskripsi: e.target.value })} className={inp} />
      </label>
      <label className="text-sm">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Lokasi</span>
        <input maxLength={200} value={form.lokasi} onChange={(e) => setForm({ ...form, lokasi: e.target.value })} className={inp} placeholder="Titik/patokan lokasi" />
      </label>
      <label className="text-sm">
        <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Foto (opsional)</span>
        <input type="file" accept="image/*" onChange={(e) => onFile(e.target.files?.[0] || null)} disabled={uploading} className="text-xs mt-2" />
        {form.foto_url && <img src={form.foto_url} alt="preview" className="mt-2 h-24 object-cover border border-current/20" />}
      </label>
      <div className="md:col-span-2 flex flex-wrap items-center gap-3 pt-2">
        <button type="submit" disabled={busy || uploading} className={btnPri}>{busy ? "Mengirim…" : "Kirim Usulan"}</button>
        <span className="text-xs opacity-70">Usulan akan tampil publik setelah diverifikasi admin desa.</span>
      </div>
    </form>
  );
}

function UsulanCard({ u, onVoted }: { u: UsulanWarga; onVoted: () => void }) {
  const [busy, setBusy] = useState(false);
  const [voted, setVoted] = useState<boolean>(() => {
    if (typeof window === "undefined") return false;
    return !!localStorage.getItem(`voted:usulan:${u.id}`);
  });
  const dukung = async () => {
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("vote-usulan", { body: { usulan_id: u.id, dusun: u.dusun } });
    setBusy(false);
    if (error || (data as any)?.error) {
      const msg = (data as any)?.error || error?.message || "Gagal";
      if ((data as any)?.already) { setVoted(true); localStorage.setItem(`voted:usulan:${u.id}`, "1"); }
      toast.error(msg);
      return;
    }
    localStorage.setItem(`voted:usulan:${u.id}`, "1");
    setVoted(true);
    toast.success("Dukungan tercatat.");
    onVoted();
  };
  return (
    <EditorialCard>
      <div className="flex flex-wrap items-baseline justify-between gap-3">
        <div>
          <div className="text-[10px] uppercase tracking-widest opacity-60">{u.kategori} · {u.dusun || "—"} · {u.nomor_tiket}</div>
          <div className="font-display font-semibold text-lg mt-1">{u.judul}</div>
        </div>
        <div className="text-right">
          <div className="font-display text-3xl tabular-nums">{u.vote_count}</div>
          <div className="text-[10px] uppercase tracking-widest opacity-60">dukungan</div>
        </div>
      </div>
      <p className="text-sm opacity-85 mt-3 whitespace-pre-line line-clamp-4">{u.deskripsi}</p>
      {u.tanggapan && (
        <div className="mt-3 border-l-2 border-accent pl-3 text-xs opacity-80">
          <div className="font-display uppercase tracking-widest text-[10px] text-accent mb-1">Tanggapan Desa</div>
          {u.tanggapan}
        </div>
      )}
      <div className="mt-4 flex items-center gap-3">
        <button disabled={busy || voted || u.status === "selesai"} onClick={dukung} className={btnPri}>
          {voted ? "Sudah didukung" : busy ? "Menyimpan…" : "Dukung"}
        </button>
        <span className="text-[10px] uppercase tracking-widest opacity-60">Status: {u.status}</span>
      </div>
    </EditorialCard>
  );
}

function LacakTiket() {
  const [nomor, setNomor] = useState("");
  const [hasil, setHasil] = useState<UsulanWarga | null>(null);
  const [notFound, setNotFound] = useState(false);
  const cari = async (e: React.FormEvent) => {
    e.preventDefault();
    setNotFound(false); setHasil(null);
    const { data } = await supabase.from("usulan_warga").select("*").ilike("nomor_tiket", nomor.trim()).maybeSingle();
    if (!data) setNotFound(true);
    else setHasil(data as any);
  };
  return (
    <div>
      <form onSubmit={cari} className="flex flex-wrap gap-3 items-end">
        <label className="text-sm flex-1 min-w-[220px]">
          <span className="block text-[10px] uppercase tracking-widest opacity-70 mb-1">Nomor Tiket</span>
          <input value={nomor} onChange={(e) => setNomor(e.target.value)} className={inp} placeholder="USL-YYYYMM-XXXX" />
        </label>
        <button type="submit" className={btnSec}>Lacak</button>
      </form>
      {notFound && <p className="mt-3 text-sm opacity-70">Tiket tidak ditemukan.</p>}
      {hasil && (
        <div className="mt-4 border border-current/20 p-4 text-sm">
          <div className="font-display font-semibold">{hasil.judul}</div>
          <div className="text-[10px] uppercase tracking-widest opacity-60 mt-1">{hasil.nomor_tiket} · {hasil.kategori} · Status: {hasil.status}</div>
          <p className="opacity-85 mt-2">{hasil.deskripsi}</p>
          {hasil.tanggapan && (
            <div className="mt-3 border-l-2 border-accent pl-3">
              <div className="font-display uppercase tracking-widest text-[10px] text-accent mb-1">Tanggapan Desa</div>
              {hasil.tanggapan}
            </div>
          )}
          <div className="text-[10px] uppercase tracking-widest opacity-50 mt-3">Dukungan: {hasil.vote_count} · Terakhir diperbarui {formatTanggal(hasil.updated_at)}</div>
        </div>
      )}
    </div>
  );
}

export function UsulanPage() {
  const [reloadKey, setReloadKey] = useState(0);
  const { rows, loading } = useUsulanPublik(reloadKey);
  const [kat, setKat] = useState("");
  const [dus, setDus] = useState("");
  const [q, setQ] = useState("");
  const filtered = rows.filter((r) =>
    (!kat || r.kategori === kat) &&
    (!dus || (r.dusun || "").toLowerCase().includes(dus.toLowerCase())) &&
    (!q || `${r.judul} ${r.deskripsi}`.toLowerCase().includes(q.toLowerCase()))
  );
  const totalDukungan = rows.reduce((s, r) => s + r.vote_count, 0);

  return (
    <EditorialLayout
      eyebrow="Partisipasi Warga"
      judul="Usulan Warga"
      deskripsi="Ajukan usulan pembangunan, pantau statusnya, dan dukung usulan warga lain."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Partisipasi" }, { label: "Usulan" }]}
    >
      <Seo title="Usulan Warga" description="Ajukan & dukung usulan pembangunan warga desa." path="/partisipasi/usulan" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: String(rows.length), label: "Usulan Terverifikasi", highlight: true },
          { nilai: totalDukungan.toLocaleString("id-ID"), label: "Total Dukungan" },
          { nilai: String(KATEGORI.length), label: "Kategori" },
          { nilai: "Terbuka", label: "Status Portal" },
        ]}
      />

      <SectionWrap>
        <EditorialTitle kicker="Formulir" judul="Kirim Usulan" />
        <UsulanForm onSubmitted={() => setReloadKey((k) => k + 1)} />
      </SectionWrap>

      <SectionWrap>
        <EditorialTitle kicker="Pelacakan" judul="Lacak Tiket" />
        <LacakTiket />
      </SectionWrap>

      <SectionWrap>
        <div className="flex items-baseline justify-between mb-4">
          <EditorialTitle kicker="Publik" judul="Usulan Warga" />
          <button onClick={() => setReloadKey((k) => k + 1)} className="text-xs underline opacity-70">Muat ulang</button>
        </div>
        <div className="flex flex-wrap gap-3 mb-4">
          <select value={kat} onChange={(e) => setKat(e.target.value)} className={inp + " max-w-[200px]"}>
            <option value="">Semua kategori</option>
            {KATEGORI.map((k) => <option key={k.value} value={k.value}>{k.label}</option>)}
          </select>
          <input value={dus} onChange={(e) => setDus(e.target.value)} placeholder="Dusun…" className={inp + " max-w-[200px]"} />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Cari kata kunci…" className={inp + " flex-1 min-w-[220px]"} />
        </div>
        {loading ? <p className="opacity-60">Memuat…</p> : (
          <div className="grid md:grid-cols-2 gap-5">
            {filtered.map((u) => <UsulanCard key={u.id} u={u} onVoted={() => setReloadKey((k) => k + 1)} />)}
            {!filtered.length && <p className="opacity-60">Belum ada usulan yang cocok.</p>}
          </div>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// =========================== Voting Resmi ===========================

function VotingCard({ topik, onVoted }: { topik: VotingTopik; onVoted: () => void }) {
  const [reload, setReload] = useState(0);
  const opsi = useVotingOpsi(topik.id, reload);
  const [busy, setBusy] = useState(false);
  const [voted, setVoted] = useState<boolean>(() => {
    if (typeof window === "undefined") return false;
    return !!localStorage.getItem(`voted:topik:${topik.id}`);
  });
  const total = opsi.reduce((s, o) => s + o.jumlah_suara, 0);
  const now = Date.now();
  const mulai = topik.mulai ? new Date(topik.mulai).getTime() : null;
  const selesai = topik.selesai ? new Date(topik.selesai).getTime() : null;
  const belumMulai = mulai && mulai > now;
  const sudahTutup = (selesai && selesai < now) || topik.status === "ditutup";
  const t = topik as unknown as VotingTopik & Partial<import("./lib/queries").VotingHasil>;
  const hasil = sudahTutup && t.hasil_dipublikasi;
  const pemenang = hasil ? opsi.find((o) => o.id === t.hasil_pemenang_id) : null;
  const pemenangPct = pemenang && total ? Math.round((pemenang.jumlah_suara / total) * 100) : 0;

  const pilih = async (opsiId: string) => {
    if (voted || belumMulai || sudahTutup) return;
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("vote-topik", { body: { topik_id: topik.id, opsi_id: opsiId } });
    setBusy(false);
    if (error || (data as any)?.error) {
      const msg = (data as any)?.error || error?.message || "Gagal";
      if ((data as any)?.already) { setVoted(true); localStorage.setItem(`voted:topik:${topik.id}`, "1"); }
      toast.error(msg);
      return;
    }
    localStorage.setItem(`voted:topik:${topik.id}`, "1");
    setVoted(true);
    setReload((k) => k + 1);
    onVoted();
    toast.success("Suara Anda tercatat.");
  };

  return (
    <EditorialCard>
      <div className="flex flex-wrap items-baseline justify-between gap-3">
        <div>
          <div className="font-display font-semibold text-lg">{topik.judul}</div>
          <div className="text-[10px] uppercase tracking-widest opacity-60 mt-1">
            {belumMulai ? "Belum dimulai" : sudahTutup ? "Sudah ditutup" : "Berjalan"}
            {topik.selesai && ` · Berakhir ${formatTanggal(topik.selesai)}`}
          </div>
        </div>
        <div className="text-right">
          <div className="font-display text-2xl tabular-nums">{total.toLocaleString("id-ID")}</div>
          <div className="text-[10px] uppercase tracking-widest opacity-60">suara total</div>
        </div>
      </div>
      {topik.deskripsi && <p className="text-sm opacity-85 mt-2">{topik.deskripsi}</p>}
      {hasil && pemenang && (
        <div className="mt-4 border-l-4 border-accent bg-accent/10 p-4">
          <div className="font-display text-[10px] uppercase tracking-widest text-accent">Hasil Resmi · dipublikasi {formatTanggal(t.hasil_dipublikasi_pada || "")}</div>
          <div className="font-display text-xl font-semibold mt-1">Pemenang: {pemenang.label}</div>
          <div className="text-sm mt-1">{pemenang.jumlah_suara} suara ({pemenangPct}%)</div>
          {t.hasil_ringkasan && (
            <p className="text-sm mt-2 opacity-90 whitespace-pre-line">{t.hasil_ringkasan}</p>
          )}
        </div>
      )}
      <ul className="mt-4 space-y-3">
        {opsi.map((o) => {
          const pct = total ? Math.round((o.jumlah_suara / total) * 100) : 0;
          const isWinner = hasil && pemenang && o.id === pemenang.id;
          return (
            <li key={o.id} className={`border p-3 ${isWinner ? "border-accent bg-accent/5" : "border-current/15"}`}>
              <div className="flex items-baseline justify-between gap-3">
                <div>
                  <div className="font-display font-semibold">
                    {o.label}{isWinner && <span className="ml-2 text-[10px] uppercase tracking-widest text-accent">· pemenang</span>}
                  </div>
                  {o.deskripsi && <div className="text-xs opacity-70 mt-1">{o.deskripsi}</div>}
                </div>
                <div className="text-right">
                  <div className="tabular-nums font-display">{o.jumlah_suara} <span className="text-xs opacity-60">({pct}%)</span></div>
                </div>
              </div>
              <div className="mt-2 h-1.5 bg-current/10">
                <div className="h-full bg-accent transition-all" style={{ width: `${pct}%` }} />
              </div>
              {!sudahTutup && <div className="mt-3">
                <button
                  disabled={busy || voted || !!belumMulai || !!sudahTutup}
                  onClick={() => pilih(o.id)}
                  className={btnSec + " w-full justify-center"}
                >
                  {voted ? "Anda sudah memilih" : belumMulai ? "Belum dimulai" : sudahTutup ? "Voting ditutup" : `Pilih ${o.label}`}
                </button>
              </div>}
            </li>
          );
        })}
        {!opsi.length && <li className="opacity-60">Belum ada opsi.</li>}
      </ul>
    </EditorialCard>
  );
}

export function VotingPage() {
  const [reload, setReload] = useState(0);
  const rows = useVotingTopikList(reload);
  const aktif = rows.filter((t) => t.status === "aktif");
  const ditutup = rows.filter((t) => t.status !== "aktif");
  return (
    <EditorialLayout
      eyebrow="Partisipasi Warga"
      judul="Voting Resmi"
      deskripsi="Ambil bagian dalam voting resmi desa untuk pengambilan keputusan bersama."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Partisipasi" }, { label: "Voting" }]}
    >
      <Seo title="Voting Resmi" description="Voting resmi warga desa." path="/partisipasi/voting" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: String(aktif.length), label: "Voting Aktif", highlight: true },
          { nilai: String(rows.length), label: "Total Topik" },
          { nilai: rows.reduce((s, r) => s + r.total_suara, 0).toLocaleString("id-ID"), label: "Suara Terkumpul" },
          { nilai: "1 perangkat", label: "1 suara / topik" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Aktif" judul="Voting Berjalan" />
        {aktif.length ? (
          <div className="grid md:grid-cols-2 gap-5">
            {aktif.map((t) => <VotingCard key={t.id} topik={t} onVoted={() => setReload((k) => k + 1)} />)}
          </div>
        ) : <p className="opacity-70">Belum ada voting yang aktif.</p>}
      </SectionWrap>
      {ditutup.length > 0 && (
        <SectionWrap>
          <EditorialTitle kicker="Arsip" judul="Voting Lampau" />
          <div className="grid md:grid-cols-2 gap-5">
            {ditutup.map((t) => <VotingCard key={t.id} topik={t} onVoted={() => setReload((k) => k + 1)} />)}
          </div>
        </SectionWrap>
      )}
    </EditorialLayout>
  );
}

// =========================== Rekap Perencanaan ===========================
export function RekapPage() {
  const { periode, bidang, program, loading: loadingRp } = useRpjmdesAktif();
  const tahunList = useRkpdesTahunList();
  const [tahunId, setTahunId] = useState<string | null>(null);
  useEffect(() => { if (!tahunId && tahunList.length) setTahunId(tahunList[0].id); }, [tahunList, tahunId]);
  const { rows: kegiatan, loading: loadingKg } = useRkpdesKegiatan(tahunId);

  const bidangMap = useMemo(() => Object.fromEntries(bidang.map((b) => [b.id, b])), [bidang]);

  // Per bidang: total anggaran RPJMDes vs terserap RKPDes, progres rata-rata
  const rekapBidang = bidang.map((b) => {
    const prog = program.filter((p) => p.bidang_id === b.id);
    const anggaranRp = prog.reduce((s, p) => s + p.anggaran_indikatif, 0);
    const keg = kegiatan.filter((k) => k.bidang_id === b.id);
    const anggaranKg = keg.reduce((s, k) => s + k.anggaran, 0);
    const progres = keg.length ? Math.round(keg.reduce((s, k) => s + k.progress_pct, 0) / keg.length) : 0;
    const selesai = keg.filter((k) => k.status_realisasi === "selesai").length;
    return { bidang: b, program: prog, kegiatan: keg, anggaranRp, anggaranKg, progres, selesai };
  });

  const totRp = rekapBidang.reduce((s, r) => s + r.anggaranRp, 0);
  const totKg = rekapBidang.reduce((s, r) => s + r.anggaranKg, 0);
  const totKegiatan = kegiatan.length;
  const totSelesai = kegiatan.filter((k) => k.status_realisasi === "selesai").length;
  const progresRata = totKegiatan ? Math.round(kegiatan.reduce((s, k) => s + k.progress_pct, 0) / totKegiatan) : 0;
  const serapan = totRp ? Math.round((totKg / totRp) * 100) : 0;

  return (
    <EditorialLayout
      eyebrow="Perencanaan Desa"
      judul="Rekap RPJMDes & RKPDes"
      deskripsi="Rekap otomatis progres implementasi RPJMDes dari kegiatan RKPDes per tahun."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Perencanaan" }, { label: "Rekap" }]}
    >
      <Seo title="Rekap RPJMDes & RKPDes" description="Rekap implementasi RPJMDes dan RKPDes desa." path="/perencanaan/rekap" />
      {loadingRp ? (
        <SectionWrap><p className="opacity-60">Memuat…</p></SectionWrap>
      ) : !periode ? (
        <SectionWrap><p className="opacity-70">Belum ada RPJMDes yang dipublikasikan.</p></SectionWrap>
      ) : (
        <>
          <StatsBand
            tone="dark"
            items={[
              { nilai: `${periode.tahun_mulai}–${periode.tahun_selesai}`, label: "Periode RPJMDes", highlight: true },
              { nilai: `${totKegiatan}`, label: "Kegiatan RKPDes" },
              { nilai: `${totSelesai}/${totKegiatan}`, label: "Selesai" },
              { nilai: `${serapan}%`, label: "Serapan Anggaran" },
            ]}
          />
          <SectionWrap>
            <div className="flex flex-wrap items-baseline justify-between gap-3 mb-4">
              <EditorialTitle kicker="Ringkasan" judul="Progres Bidang" />
              <label className="text-sm">
                <span className="text-[10px] uppercase tracking-widest opacity-60 mr-2">Tahun RKPDes</span>
                <select value={tahunId ?? ""} onChange={(e) => setTahunId(e.target.value)} className={inp + " inline-block w-auto"}>
                  {tahunList.map((t) => <option key={t.id} value={t.id}>{t.tahun}</option>)}
                </select>
              </label>
            </div>
            <div className="mb-6">
              <EditorialProgress label={`Progres seluruh kegiatan tahun ${tahunList.find((t) => t.id === tahunId)?.tahun ?? ""}`} value={progresRata} max={100} suffix="%" />
            </div>
            <div className="grid md:grid-cols-2 gap-5">
              {rekapBidang.map((r) => (
                <EditorialCard key={r.bidang.id} kicker={r.bidang.kode} judul={r.bidang.nama}>
                  <div className="grid grid-cols-3 gap-3 text-center border-y border-current/15 py-3 my-2">
                    <div>
                      <div className="font-display text-xl tabular-nums">{r.program.length}</div>
                      <div className="text-[10px] uppercase tracking-widest opacity-60">Program</div>
                    </div>
                    <div>
                      <div className="font-display text-xl tabular-nums">{r.kegiatan.length}</div>
                      <div className="text-[10px] uppercase tracking-widest opacity-60">Kegiatan</div>
                    </div>
                    <div>
                      <div className="font-display text-xl tabular-nums text-accent">{r.progres}%</div>
                      <div className="text-[10px] uppercase tracking-widest opacity-60">Progres</div>
                    </div>
                  </div>
                  <EditorialProgress label="Realisasi rata-rata" value={r.progres} max={100} suffix="%" />
                  <div className="text-xs opacity-75 mt-3">
                    Anggaran RKPDes {rupiah(r.anggaranKg)} dari indikatif RPJMDes {rupiah(r.anggaranRp)}
                  </div>
                </EditorialCard>
              ))}
            </div>
          </SectionWrap>

          <SectionWrap>
            <EditorialTitle kicker="Terhubung" judul="Program RPJMDes" />
            <p className="text-sm opacity-70 mb-4">Kegiatan RKPDes yang berkontribusi pada tiap program (tahun {tahunList.find((t) => t.id === tahunId)?.tahun ?? "—"}).</p>
            {loadingKg ? <p className="opacity-60">Memuat kegiatan…</p> : (
              <div className="space-y-6">
                {program.map((p) => {
                  const b = bidangMap[p.bidang_id];
                  const kegForBidang = kegiatan.filter((k) => k.bidang_id === p.bidang_id);
                  return (
                    <div key={p.id} className="border border-current/15 p-5">
                      <div className="text-[10px] uppercase tracking-widest opacity-60">{b?.nama} · {p.sumber_dana || "—"}</div>
                      <div className="font-display font-semibold text-lg mt-1">{p.nama}</div>
                      {p.indikator && <div className="text-sm opacity-80 mt-1">Indikator: {p.indikator}{p.target ? ` · ${p.target}` : ""}</div>}
                      <div className="text-xs opacity-60 mt-1">Anggaran indikatif: {rupiah(p.anggaran_indikatif)}</div>
                      {kegForBidang.length ? (
                        <ul className="mt-3 space-y-2">
                          {kegForBidang.map((k) => (
                            <li key={k.id} className="grid grid-cols-[1fr_auto] gap-3 text-sm border-t border-current/10 pt-2">
                              <div>
                                <div className="font-medium">{k.nama}</div>
                                <div className="text-xs opacity-70">{[k.dusun, k.lokasi, k.status_realisasi].filter(Boolean).join(" · ")}</div>
                              </div>
                              <div className="text-right whitespace-nowrap">
                                <div className="tabular-nums">{rupiah(k.anggaran)}</div>
                                <div className="text-xs text-accent tabular-nums">{k.progress_pct}%</div>
                              </div>
                            </li>
                          ))}
                        </ul>
                      ) : (
                        <p className="text-xs opacity-60 mt-3">Belum ada kegiatan RKPDes yang terhubung tahun ini.</p>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </SectionWrap>
        </>
      )}
    </EditorialLayout>
  );
}