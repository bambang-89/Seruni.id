import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "./lib/tenant";
import { Share2, Facebook, Twitter, MessageCircle } from "lucide-react";
import {
  EditorialLayout,
  SectionWrap,
  EditorialCard,
  EditorialProgress,
  formatTanggal,
} from "./ui";
import { EditorialTitle, StatsBand, NumberedList } from "./sections";
import {
  useProfilDesa,
  usePamong,
  useDusun,
  useLembaga,
  useBerita,
  useBeritaBySlug,
  useAgenda,
  usePengumuman,
  useGaleri,
  usePotensiUmkm,
  usePotensiProduk,
  usePotensiWisata,
  useApbdes,
  useApbdesYears,
  useStatistikDesa,
  useIdmData,
  usePembangunanData,
  useUsulanStats,
  useBantuanSosial,
  useStuntingAgregat,
  usePosyanduAgregat,
  useBalita,
  useBencanaKejadian,
  useSuratJenis,
  useLayananStatistik,
  useAduanKategori,
  useAgendaById,
  useGaleriById,
  usePengumumanById,
  usePosyanduById,
  useStuntingById,
  useUmkmById,
  useProdukById,
  useWisataById,
  usePembangunanById,
  useBansosById,
  useAduanById,
  useIdmIndikatorById,
  useAutofillPenduduk,
  Galeri,
  PotensiUmkm,
  PotensiWisata,
  PembangunanDetail,
  PotensiProduk,
  BantuanSosial,
  AduanWarga,
  IdmIndikator,
} from "./lib/queries";
import { PetaLeaflet } from "./PetaLeaflet";
import { Seo } from "./lib/seo";
import { FilterBar, FilterField, TextInput, SelectInput, OfflineBadge } from "./components/FilterBar";
import { useOnlineStatus } from "./lib/useOnlineStatus";
import { useSiteSettings } from "./lib/zeroHardcode";

// -------------------------------------------------------------
// Shared editorial helpers used across inner pages.
// No rounded corners. No icons. Typography + hairline dividers.
// -------------------------------------------------------------

const inputCls =
  "mt-1 w-full border border-current/25 bg-transparent px-3 py-2 text-sm focus:outline-none focus:border-accent";
const btnPrimary =
  "inline-flex items-center gap-3 border border-accent bg-accent/10 text-accent px-6 py-3 font-display text-[11px] font-bold uppercase tracking-[0.28em] hover:bg-accent hover:text-primary transition-colors";

function BarList({ items, unit = "" }: { items: { label: string; nilai: number }[]; unit?: string }) {
  const max = Math.max(...items.map((i) => i.nilai));
  return (
    <ul className="space-y-4">
      {items.map((i) => (
        <li key={i.label}>
          <EditorialProgress label={i.label} value={i.nilai} max={max} suffix={unit} />
        </li>
      ))}
    </ul>
  );
}

// ============================ Profil Desa ============================

export function ProfilDesaPage() {
  const { data: profilDesa } = useProfilDesa();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? "Desa Seruni";
  return (
    <EditorialLayout
      eyebrow="Profil Desa"
      judul="Sejarah, Visi, dan Misi"
      deskripsi={`Kenali ${siteName} — dari sejarah pemekaran hingga arah pembangunan ke depan.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Profil Desa" }]}
    >
      <Seo title="Profil Desa" description={`Sejarah, visi, dan misi ${siteName}, ${settings?.wilayah ?? ""}.`} path="/profil-desa" />
      <SectionWrap>
        <div className="grid lg:grid-cols-3 gap-10 lg:gap-14">
          <article className="lg:col-span-2">
            <EditorialTitle sectionKey="sejarah-perjalanan-desa" kicker="Sejarah" judul="Perjalanan Desa" />
            <div className="space-y-5 text-base leading-relaxed opacity-90">
              {profilDesa.sejarah.map((p, i) => (<p key={i}>{p}</p>))}
            </div>
          </article>
          <aside className="space-y-10">
            <div className="border-l-2 border-accent pl-6">
              <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Visi</p>
              <p className="mt-3 font-display text-lg italic leading-snug">{profilDesa.visi}</p>
            </div>
            <div className="border-t border-current/15 pt-6">
              <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4">Misi</p>
              <ol className="space-y-3 text-sm opacity-90">
                {profilDesa.misi.map((m, i) => (
                  <li key={i} className="grid grid-cols-[36px_1fr] gap-3">
                    <span className="font-display text-lg font-light opacity-40 tabular-nums">
                      {String(i + 1).padStart(2, "0")}
                    </span>
                    <span>{m}</span>
                  </li>
                ))}
              </ol>
            </div>
          </aside>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function StrukturPage() {
  const { data: strukturPamong } = usePamong();
  return (
    <EditorialLayout
      eyebrow="Profil Desa"
      judul="Struktur Organisasi Pemerintahan Desa"
      deskripsi="Susunan perangkat desa periode 2024–2030 berdasarkan Peraturan Desa Nomor 03/2024."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Profil Desa", to: "/profil-desa" }, { label: "Struktur" }]}
    >
      <Seo title="Struktur Organisasi Pemerintahan Desa" description="Susunan perangkat Desa Seruni Mumbul periode 2024–2030." path="/profil-desa/struktur" />
      <SectionWrap>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
          {strukturPamong.map((p, i) => (
            <div key={p.nama} className="bg-background p-6 sm:p-8">
              {p.foto_url && (
                <div className="mb-4 -mx-6 -mt-6 sm:-mx-8 sm:-mt-8 aspect-[4/3] overflow-hidden border-b border-current/15">
                  <img src={p.foto_url} alt={p.nama} className="w-full h-full object-cover" loading="lazy" />
                </div>
              )}
              <span className="font-display text-3xl font-light opacity-25 tabular-nums">
                {String(i + 1).padStart(2, "0")}
              </span>
              <div className="mt-4 font-display text-lg font-semibold leading-snug">{p.nama}</div>
              <div className="mt-1 font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent">
                {p.jabatan}
              </div>
              {p.periode && (
                <div className="mt-3 pt-3 border-t border-current/15 text-xs opacity-70">Periode {p.periode}</div>
              )}
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function WilayahPage() {
  const { data: wilayahDusun } = useDusun();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? "Desa Seruni";
  const totalKK = wilayahDusun.reduce((a, d) => a + d.kk, 0);
  const totalJiwa = wilayahDusun.reduce((a, d) => a + d.jiwa, 0);
  const totalLuas = wilayahDusun.reduce((a, d) => a + d.luas_ha, 0);
  return (
    <EditorialLayout
      eyebrow="Profil Desa"
      judul="Wilayah & Topografi"
      deskripsi={`Desa ${siteName} terbagi menjadi 6 dusun, dengan wilayah pesisir di sisi timur dan kaki bukit Rinjani di sisi barat.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Profil Desa", to: "/profil-desa" }, { label: "Wilayah" }]}
    >
      <Seo title="Wilayah & Topografi" description="Data dusun, luas, KK, dan jiwa Desa Seruni Mumbul." path="/profil-desa/wilayah" />
      <SectionWrap>
        <div className="overflow-x-auto border border-current/15">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-current/15">
                <th className="text-left px-5 py-4 font-display text-[11px] font-bold uppercase tracking-[0.22em]">Nama Dusun</th>
                <th className="text-right px-5 py-4 font-display text-[11px] font-bold uppercase tracking-[0.22em]">KK</th>
                <th className="text-right px-5 py-4 font-display text-[11px] font-bold uppercase tracking-[0.22em]">Jiwa</th>
                <th className="text-right px-5 py-4 font-display text-[11px] font-bold uppercase tracking-[0.22em]">Luas (ha)</th>
              </tr>
            </thead>
            <tbody>
              {wilayahDusun.map((d) => (
                <tr key={d.nama} className="border-b border-current/10">
                  <td className="px-5 py-4 font-display font-semibold">{d.nama}</td>
                  <td className="px-5 py-4 text-right tabular-nums">{d.kk.toLocaleString("id-ID")}</td>
                  <td className="px-5 py-4 text-right tabular-nums">{d.jiwa.toLocaleString("id-ID")}</td>
                  <td className="px-5 py-4 text-right tabular-nums">{d.luas_ha.toLocaleString("id-ID")}</td>
                </tr>
              ))}
              <tr className="border-t-2 border-current/40 font-display font-semibold">
                <td className="px-5 py-4 uppercase tracking-[0.2em] text-[11px] text-accent">Total</td>
                <td className="px-5 py-4 text-right tabular-nums">{totalKK.toLocaleString("id-ID")}</td>
                <td className="px-5 py-4 text-right tabular-nums">{totalJiwa.toLocaleString("id-ID")}</td>
                <td className="px-5 py-4 text-right tabular-nums">{totalLuas.toLocaleString("id-ID")}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function LembagaPage() {
  const { data: lembagaDesa } = useLembaga();
  return (
    <EditorialLayout
      eyebrow="Profil Desa"
      judul="Lembaga Kemasyarakatan Desa"
      deskripsi="Enam lembaga aktif menjadi mitra pemerintah desa dalam pelayanan dan pemberdayaan warga."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Profil Desa", to: "/profil-desa" }, { label: "Lembaga" }]}
    >
      <Seo title="Lembaga Kemasyarakatan Desa" description="BPD, LPM, PKK, Karang Taruna, dan lembaga kemasyarakatan lainnya." path="/profil-desa/lembaga" />
      <SectionWrap>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
          {lembagaDesa.map((l, i) => (
            <div key={l.nama} className="bg-background p-6 sm:p-8">
              <span className="font-display text-3xl font-light opacity-25 tabular-nums">
                {String(i + 1).padStart(2, "0")}
              </span>
              <h3 className="mt-4 font-display text-lg font-semibold leading-snug">{l.nama}</h3>
              <dl className="mt-4 pt-4 border-t border-current/15 space-y-2 text-sm opacity-90">
                <div className="flex justify-between gap-4">
                  <dt className="opacity-60">Ketua</dt>
                  <dd className="font-medium text-right">{l.ketua}</dd>
                </div>
                <div className="flex justify-between gap-4">
                  <dt className="opacity-60">Anggota</dt>
                  <dd className="tabular-nums">{l.jumlah_anggota} orang</dd>
                </div>
              </dl>
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Informasi ============================

export function BeritaListPage() {
  const { data: beritaTerbaru } = useBerita();
  const headline = beritaTerbaru[0];
  const others = beritaTerbaru.slice(1);
  const terpopuler = [...beritaTerbaru].reverse().slice(0, 5);

  return (
    <div className="bg-background text-foreground min-h-screen">
      <Seo title="Berita Desa" description="Kabar terbaru pembangunan, kesehatan, ekonomi, dan sosial Desa Seruni Mumbul." path="/berita" />
      <main className="max-w-[1200px] mx-auto px-4 sm:px-6 pt-32 pb-16">
        <header className="mb-10 border-b-2 border-accent pb-4">
          <h1 className="font-display text-3xl sm:text-4xl font-bold uppercase tracking-widest">Berita Terkini</h1>
        </header>
      <SectionWrap>
        <div className="grid lg:grid-cols-[1fr_320px] gap-10 items-start">
          {/* Main Content */}
          <div className="space-y-10 min-w-0">
            {headline && (
              <Link to={`/berita/${headline.slug}`} className="group block">
                <div className="relative aspect-[16/9] sm:aspect-[21/9] bg-primary text-primary-foreground mb-4 overflow-hidden">
                  {headline.cover_url ? (
                    <img src={headline.cover_url} alt={headline.judul} className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                  ) : (
                    <div className="stempel-watermark absolute inset-0" style={{ color: "#fff" }} aria-hidden />
                  )}
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 via-black/50 to-transparent p-4 sm:p-8 pt-20">
                    <span className="inline-block bg-accent text-accent-foreground px-2 py-1 text-xs font-bold uppercase tracking-wider mb-2 sm:mb-3">
                      {headline.kategori}
                    </span>
                    <h2 className="text-xl sm:text-3xl lg:text-4xl font-bold text-white leading-[1.2] group-hover:text-accent transition-colors">
                      {headline.judul}
                    </h2>
                    <time className="block mt-2 sm:mt-3 text-xs sm:text-sm text-white/80 tabular-nums">
                      {formatTanggal(headline.tanggal)}
                    </time>
                  </div>
                </div>
              </Link>
            )}

            <div className="flex flex-col gap-6">
              {others.map((b) => (
                <Link key={b.slug} to={`/berita/${b.slug}`} className="group flex gap-4 sm:gap-6 border-b border-current/15 pb-6">
                  <div className="w-1/3 sm:w-56 shrink-0 relative aspect-[4/3] sm:aspect-[16/10] bg-muted overflow-hidden">
                    {b.cover_url ? (
                      <img src={b.cover_url} alt={b.judul} loading="lazy" className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
                    ) : (
                      <div className="stempel-watermark absolute inset-0" aria-hidden />
                    )}
                  </div>
                  <div className="flex-1 min-w-0 py-1">
                    <span className="text-accent text-[10px] sm:text-xs font-bold uppercase tracking-widest">{b.kategori}</span>
                    <h3 className="mt-1 sm:mt-2 font-display text-base sm:text-xl font-semibold leading-snug group-hover:text-accent transition-colors line-clamp-3 sm:line-clamp-2">
                      {b.judul}
                    </h3>
                    <p className="mt-2 text-sm leading-relaxed opacity-75 line-clamp-2 hidden md:block">{b.ringkasan}</p>
                    <time className="block mt-3 font-display text-[9px] sm:text-[10px] font-bold uppercase tracking-widest opacity-60 tabular-nums">
                      {formatTanggal(b.tanggal)}
                    </time>
                  </div>
                </Link>
              ))}
            </div>
          </div>

          {/* Sidebar */}
          <aside className="sticky top-24 space-y-8">
            <div className="border border-current/15 p-5">
              <h3 className="font-display text-lg font-bold border-b-2 border-accent pb-2 mb-4 uppercase tracking-widest">
                Terpopuler
              </h3>
              <ul className="space-y-4 divide-y divide-current/10">
                {terpopuler.map((b, i) => (
                  <li key={b.slug} className="pt-4 first:pt-0">
                    <Link to={`/berita/${b.slug}`} className="group flex gap-3">
                      <span className="text-4xl font-display font-bold text-accent/30 leading-none tabular-nums -mt-1">
                        {i + 1}
                      </span>
                      <div>
                        <h4 className="font-semibold leading-snug group-hover:text-accent line-clamp-2 text-sm">{b.judul}</h4>
                        <time className="block mt-1 font-display text-[9px] font-bold uppercase tracking-widest opacity-60">{formatTanggal(b.tanggal)}</time>
                      </div>
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          </aside>
        </div>
      </SectionWrap>
      </main>
    </div>
  );
}

export function BeritaDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const { data: b, loading } = useBeritaBySlug(slug);
  const { data: semuaBerita } = useBerita();
  
  if (loading) {
    return (
      <div className="bg-background text-foreground min-h-screen py-24 px-6 max-w-4xl mx-auto">
        <p className="opacity-60">Sedang memuat…</p>
      </div>
    );
  }
  if (!b) {
    return (
      <div className="bg-background text-foreground min-h-screen py-24 px-6 max-w-4xl mx-auto text-center">
        <h1 className="text-2xl font-bold mb-6">Berita tidak ditemukan</h1>
        <Link to="/berita" className="inline-flex items-center justify-center h-12 px-6 font-display font-bold text-sm tracking-[0.2em] uppercase bg-primary text-primary-foreground hover:bg-accent hover:text-accent-foreground transition-colors">
          Kembali ke daftar berita
        </Link>
      </div>
    );
  }

  const beritaTerkait = semuaBerita.filter(x => x.slug !== slug).slice(0, 4);

  return (
    <div className="bg-background text-foreground selection:bg-accent selection:text-accent-foreground pb-20">
      <Seo
        title={b.judul}
        description={b.ringkasan}
        path={`/berita/${b.slug}`}
        type="article"
        image={b.cover_url || undefined}
        jsonLd={{
          "@context": "https://schema.org",
          "@type": "NewsArticle",
          headline: b.judul,
          datePublished: b.tanggal,
          author: { "@type": "Person", name: b.penulis },
          image: b.cover_url || undefined,
          articleSection: b.kategori,
          publisher: { "@type": "Organization", name: "Kantor Desa Seruni Mumbul" },
        }}
      />
      
      <div className="max-w-[1200px] mx-auto px-4 sm:px-6 pt-8 pb-12 lg:pt-12">
        {/* Breadcrumb */}
        <nav className="flex items-center gap-2 text-xs sm:text-sm font-medium opacity-60 mb-8 overflow-x-auto whitespace-nowrap scrollbar-hide">
          <Link to="/" className="hover:text-accent hover:opacity-100 transition-colors">Beranda</Link>
          <span className="opacity-40">/</span>
          <Link to="/berita" className="hover:text-accent hover:opacity-100 transition-colors">Berita</Link>
          <span className="opacity-40">/</span>
          <span className="text-accent opacity-100">{b.kategori}</span>
        </nav>

        <div className="grid lg:grid-cols-[1fr_320px] gap-10 lg:gap-16 items-start">
          {/* Main Article */}
          <article className="min-w-0">
            <header className="mb-8">
              <span className="inline-block bg-accent/10 text-accent px-3 py-1 text-xs font-bold uppercase tracking-wider mb-4 border border-accent/20">
                {b.kategori}
              </span>
              <h1 className="font-display text-2xl sm:text-4xl lg:text-5xl font-bold leading-[1.2] sm:leading-[1.1] mb-6">
                {b.judul}
              </h1>
              
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 py-4 border-y border-current/15">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-accent text-accent-foreground flex items-center justify-center font-bold text-lg">
                    {(b.penulis || "Admin").charAt(0)}
                  </div>
                  <div>
                    <div className="font-bold text-sm">Oleh <span className="text-accent">{b.penulis || "Admin"}</span></div>
                    <time className="text-xs opacity-60 tabular-nums">Diperbarui {formatTanggal(b.tanggal)}</time>
                  </div>
                </div>
                
                {/* Share Buttons */}
                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold uppercase tracking-widest mr-2 opacity-60 hidden sm:inline">Bagikan</span>
                  <button className="w-9 h-9 rounded-full bg-muted flex items-center justify-center hover:bg-accent hover:text-accent-foreground transition-colors" title="Bagikan ke Facebook">
                    <Facebook size={16} />
                  </button>
                  <button className="w-9 h-9 rounded-full bg-muted flex items-center justify-center hover:bg-accent hover:text-accent-foreground transition-colors" title="Bagikan ke Twitter">
                    <Twitter size={16} />
                  </button>
                  <button className="w-9 h-9 rounded-full bg-muted flex items-center justify-center hover:bg-[#25D366] hover:text-white transition-colors" title="Bagikan ke WhatsApp">
                    <MessageCircle size={16} />
                  </button>
                  <button className="w-9 h-9 rounded-full bg-muted flex items-center justify-center hover:bg-primary hover:text-primary-foreground transition-colors" title="Salin Tautan">
                    <Share2 size={16} />
                  </button>
                </div>
              </div>
            </header>

            {b.cover_url && (
              <figure className="mb-10">
                <img src={b.cover_url} alt={b.judul} className="w-full aspect-[16/9] object-cover bg-muted" />
                <figcaption className="mt-3 text-xs opacity-60 text-center italic">Ilustrasi: {b.judul}</figcaption>
              </figure>
            )}

            <div className="prose prose-lg sm:prose-xl max-w-none text-foreground/90 prose-headings:font-display prose-headings:font-bold prose-a:text-accent hover:prose-a:text-accent/80 prose-img:rounded-none leading-relaxed">
              <p className="text-lg sm:text-xl font-medium !leading-relaxed font-display italic border-l-4 border-accent pl-5 sm:pl-6 mb-8">{b.ringkasan}</p>
              
              {(Array.isArray(b.isi) ? b.isi : typeof b.isi === "string" ? [b.isi] : []).map((p, i) => {
                // Inject "Baca Juga" block after 2nd paragraph
                if (i === 2 && beritaTerkait.length > 0) {
                  return (
                    <div key={`baca-juga-${i}`}>
                      <div className="my-8 p-5 sm:p-6 bg-accent/5 border-l-4 border-accent">
                        <h4 className="font-bold text-accent uppercase text-xs tracking-widest mb-3">Baca Juga</h4>
                        <Link to={`/berita/${beritaTerkait[0].slug}`} className="font-display font-semibold text-lg sm:text-xl hover:text-accent transition-colors block leading-snug">
                          {beritaTerkait[0].judul}
                        </Link>
                      </div>
                      <p>{String(p)}</p>
                    </div>
                  )
                }
                return <p key={i}>{String(p)}</p>
              })}
            </div>

            {/* Tags / Topik Terkait */}
            <div className="mt-12 pt-8 border-t border-current/15">
              <h3 className="text-sm font-bold uppercase tracking-widest mb-4">Topik Terkait</h3>
              <div className="flex flex-wrap gap-2">
                {['Desa', b.kategori, 'Informasi Publik', 'Terbaru'].map(tag => (
                  <span key={tag} className="px-3 py-1 border border-current/20 text-xs sm:text-sm hover:bg-accent hover:text-accent-foreground hover:border-accent transition-colors cursor-pointer">
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          </article>

          {/* Sidebar */}
          <aside className="sticky top-24 space-y-8 mt-12 lg:mt-0">
            <div className="border border-current/15 p-5">
              <h3 className="font-display text-lg font-bold border-b-2 border-accent pb-2 mb-4 uppercase tracking-widest">
                Berita Terpopuler
              </h3>
              <ul className="space-y-4 divide-y divide-current/10">
                {semuaBerita.slice(0, 5).map((tb, i) => (
                  <li key={tb.slug} className="pt-4 first:pt-0">
                    <Link to={`/berita/${tb.slug}`} className="group flex gap-3">
                      <span className="text-4xl font-display font-bold text-accent/30 leading-none tabular-nums -mt-1">
                        {i + 1}
                      </span>
                      <div>
                        <h4 className="font-semibold leading-snug group-hover:text-accent line-clamp-2 text-sm">{tb.judul}</h4>
                      </div>
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
            
            {/* Iklan / Banner Placeholder */}
            <div className="aspect-[300/250] bg-muted border border-current/15 flex flex-col items-center justify-center p-6 text-center">
              <span className="text-xs uppercase tracking-widest opacity-40 font-bold mb-2">Space Iklan</span>
              <span className="text-sm font-medium opacity-60">Dukung Pembangunan Desa Seruni Mumbul</span>
            </div>
          </aside>
        </div>
      </div>
    </div>
  );
}

export function KalenderPage() {
  const { data: agendaMendatang } = useAgenda();
  return (
    <EditorialLayout
      eyebrow="Informasi"
      judul="Agenda & Kalender Desa"
      deskripsi="Jadwal Musdes, Posyandu, gotong royong, dan sosialisasi program pemerintah desa."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Kalender" }]}
    >
      <Seo title="Agenda & Kalender Desa" description="Jadwal Musdes, Posyandu, gotong royong, dan kegiatan resmi desa." path="/kalender-desa" />
      <SectionWrap>
        <ul className="divide-y divide-current/15 border-y border-current/15">
          {agendaMendatang.map((a) => (
            <li key={a.slug}>
              <Link to={`/agenda/${a.id}`} className="py-8 grid sm:grid-cols-[120px_1fr] gap-6 sm:gap-10 items-start hover:bg-muted/20 transition-colors">
                <div className="border-l-2 border-accent pl-4">
                  <div className="font-display text-5xl font-bold tabular-nums leading-none">
                    {new Date(a.tanggal).getDate()}
                  </div>
                  <div className="mt-2 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                    {new Date(a.tanggal).toLocaleDateString("id-ID", { month: "long" })}
                  </div>
                </div>
                <div>
                  <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{a.jenis}</div>
                  <h3 className="mt-2 font-display text-xl sm:text-2xl font-semibold leading-snug">{a.judul}</h3>
                  <dl className="mt-4 grid sm:grid-cols-3 gap-x-6 gap-y-2 text-sm opacity-90">
                    <div><dt className="opacity-60 inline">Waktu · </dt><dd className="inline">{a.waktu}</dd></div>
                    <div><dt className="opacity-60 inline">Lokasi · </dt><dd className="inline">{a.lokasi}</dd></div>
                    <div><dt className="opacity-60 inline">Oleh · </dt><dd className="inline">{a.penyelenggara}</dd></div>
                  </dl>
                  <p className="mt-4 text-sm leading-relaxed opacity-80 max-w-3xl">{a.deskripsi}</p>
                </div>
              </Link>
            </li>
          ))}
        </ul>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function GaleriPage() {
  const { data: galeriDetail } = useGaleri();
  return (
    <EditorialLayout
      eyebrow="Informasi"
      judul="Galeri Foto & Video"
      deskripsi="Dokumentasi kegiatan desa dalam satu tahun terakhir, dikurasi per album."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Galeri" }]}
    >
      <Seo title="Galeri Foto & Video" description="Dokumentasi kegiatan Desa Seruni Mumbul dalam satu tahun terakhir." path="/galeri" />
      <SectionWrap>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-px bg-current/15">
          {galeriDetail.map((g) => (
            <Link to={`/galeri/${g.id}`} key={g.judul} className="group relative aspect-square bg-primary text-primary-foreground overflow-hidden block">
              {g.foto_url ? (
                <img src={g.foto_url} alt={g.judul} loading="lazy" className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" />
              ) : (
                <div className="stempel-watermark absolute inset-0" style={{ color: "#fff" }} aria-hidden />
              )}
              <figcaption className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-[#0F0E0E] to-transparent p-4">
                <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{g.album}</div>
                <div className="mt-1 font-display text-sm font-semibold truncate">{g.judul}</div>
                <div className="text-[10px] opacity-70 tabular-nums mt-0.5">{formatTanggal(g.tanggal)}</div>
              </figcaption>
            </Link>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function PengumumanPage() {
  const { data: pengumumanResmi } = usePengumuman();
  return (
    <EditorialLayout
      eyebrow="Informasi"
      judul="Pengumuman Resmi"
      deskripsi="Pengumuman resmi bernomor register dari Kantor Desa Seruni Mumbul."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Pengumuman" }]}
    >
      <Seo title="Pengumuman Resmi" description="Pengumuman bernomor register dari Pemerintah Desa Seruni Mumbul." path="/pengumuman" />
      <SectionWrap>
        <ul className="divide-y divide-current/15 border-y border-current/15">
          {pengumumanResmi.map((p) => (
            <li key={p.nomor}>
              <Link to={`/pengumuman/${p.id}`} className="py-6 grid sm:grid-cols-[220px_1fr] gap-4 sm:gap-10 hover:bg-muted/20 transition-colors">
                <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                  <div>No. {p.nomor}</div>
                  <time className="block mt-1 opacity-70 tabular-nums">{formatTanggal(p.tanggal)}</time>
                </div>
                <div>
                  <h3 className="font-display text-lg font-semibold leading-snug">{p.judul}</h3>
                  <p className="mt-2 text-sm opacity-80 leading-relaxed">{p.ringkasan}</p>
                </div>
              </Link>
            </li>
          ))}
        </ul>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Layanan ============================

const KODE_TO_LAYANAN: Record<string, string> = {
  F1: "surat",
  F5: "pbb",
  SC: "aduan",
  BS: "bansos",
};

function getLayananJenis(kode: string): string {
  const prefix = kode.split("_")[0] || "";
  return KODE_TO_LAYANAN[prefix] ?? "surat";
}

export function LayananPage() {
  const { data: suratList } = useSuratJenis();
  const { data: statList } = useLayananStatistik();
  const suratCount = suratList.length;

  // Build a lookup: jenis_layanan -> count_bulan_ini
  const statMap = new Map<string, number>();
  for (const s of statList ?? []) {
    if (!statMap.has(s.jenis_layanan)) {
      statMap.set(s.jenis_layanan, s.count_bulan_ini ?? 0);
    }
  }

  const catalog = [
    { to: "/layanan/surat", kicker: "Administrasi", judul: "Ajukan Surat Online", desc: `${suratCount} jenis surat, TTE & QR verifikasi, SLA 1–5 hari kerja.` },
    { to: "/layanan/pbb", kicker: "Pajak", judul: "Cek & Bayar PBB", desc: "Cek tagihan berdasarkan NOP atau NIK, bayar via QRIS/VA." },
    { to: "/service-center", kicker: "Aspirasi", judul: "Pengaduan Warga", desc: "Laporkan infrastruktur, keamanan, kedaruratan, atau kritik layanan." },
    { to: "/verifikasi", kicker: "Legalitas", judul: "Verifikasi Dokumen", desc: "Cek keaslian surat desa dengan nomor & kode QR." },
  ];
  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Katalog Layanan Warga"
      deskripsi="Ajukan permohonan online. Pantau status & unduh dokumen ber-QR verifikasi tanpa antre di kantor desa."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Layanan" }]}
    >
      <Seo title="Katalog Layanan Warga" description="Layanan surat, PBB, pengaduan, dan verifikasi dokumen Desa Seruni Mumbul." path="/layanan" />
      <SectionWrap>
        <div className="grid sm:grid-cols-2 gap-px bg-current/15">
          {catalog.map((c, i) => (
            <Link key={c.to} to={c.to} className="group bg-background p-8 sm:p-10 flex flex-col justify-between min-h-[220px] hover:bg-primary hover:text-primary-foreground transition-colors">
              <span className="font-display text-3xl font-light opacity-25 tabular-nums group-hover:text-accent group-hover:opacity-100">
                {String(i + 1).padStart(2, "0")}
              </span>
              <div>
                <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{c.kicker}</p>
                <h3 className="mt-2 font-display text-2xl font-semibold leading-tight">{c.judul}</h3>
                <p className="mt-3 text-sm leading-relaxed opacity-75">{c.desc}</p>
              </div>
            </Link>
          ))}
        </div>
      </SectionWrap>
      <SectionWrap alt>
        <EditorialTitle sectionKey="bulan-ini-layanan-terlaris" kicker="Bulan Ini" judul="Layanan Terlaris" />
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
          {suratList.slice(0, 4).map((l) => {
            const statKey = getLayananJenis(l.kode_surat);
            const count = statMap.get(statKey) ?? 0;
            return (
              <div key={l.nama} className="bg-[#EAECF0] p-6">
                <div className="font-display text-4xl font-bold tabular-nums text-accent leading-none">
                  {count > 0 ? count.toLocaleString("id-ID") : "—"}
                </div>
                <div className="mt-2 font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-60">
                  permohonan bulan ini
                </div>
                <div className="mt-4 pt-4 border-t border-current/15 font-display text-sm font-semibold">
                  {l.nama}
                </div>
              </div>
            );
          })}
          {suratList.length === 0 && (
            <div className="sm:col-span-2 lg:col-span-4 p-6 text-sm opacity-60">
              Data layanan belum tersedia.
            </div>
          )}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function LayananSuratPage() {
  const { data: surat } = useSuratJenis();
  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Ajukan Surat Online"
      deskripsi={`${surat.length} jenis surat resmi desa, semua bernomor auto-generate dan dilengkapi QR verifikasi.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Layanan", to: "/layanan" }, { label: "Surat" }]}
    >
      <SectionWrap>
        <div className="grid md:grid-cols-2 gap-px bg-current/15">
          {(surat || []).map((s) => (
            <div key={s.id} className="bg-background p-6 sm:p-8 flex flex-col gap-4">
              <div className="flex items-start justify-between gap-4">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Kode {s.kode_surat}</span>
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-70">SLA 1–5 hari kerja</span>
              </div>
              <h3 className="font-display text-xl font-semibold leading-snug">{s.nama}</h3>
              <Link to={`/layanan/surat/${s.id}`} className={`${btnPrimary} justify-center mt-auto`}>
                Ajukan Sekarang
              </Link>
            </div>
          ))}
        </div>
        <p className="mt-6 text-xs opacity-60">Login warga & pengajuan lengkap tersedia pada Phase 6 (Sistem Layanan Mandiri).</p>
      </SectionWrap>
    </EditorialLayout>
  );
}

interface PbbTagihan {
  tahun: number | string;
  nop: string;
  pbb_terutang: number | string;
  jatuh_tempo?: string;
  status_bayar: string;
  tanggal_bayar?: string;
}

export function LayananPBBPage() {
  const currentYear = new Date().getFullYear();
  const [nop, setNop] = useState("");
  const [nik, setNik] = useState("");
  const [tahun, setTahun] = useState<number>(currentYear);
  const [hasil, setHasil] = useState<PbbTagihan | null>(null);
  const [loading, setLoading] = useState(false);
  const [notFound, setNotFound] = useState(false);

  async function cariPbb(e: React.FormEvent) {
    e.preventDefault();
    const clean = nop.trim();
    const cleanNik = nik.replace(/\s/g, "");
    if (clean.length < 6) return toast.error("Masukkan NOP yang valid");
    if (!/^\d{16}$/.test(cleanNik)) return toast.error("Masukkan NIK Wajib Pajak (16 digit) sebagai verifikasi");
    setLoading(true);
    setHasil(null);
    setNotFound(false);
    const { data, error } = await supabase.rpc("cek_pbb", { _tahun: tahun, _nop: clean, _nik: cleanNik });
    setLoading(false);
    if (error) return toast.error(error.message);
    const row = Array.isArray(data) ? data[0] : data;
    if (!row) { setNotFound(true); return; }
    setHasil(row);
  }

  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Cek Tagihan PBB"
      deskripsi="Cek tagihan PBB berdasarkan Nomor Objek Pajak (NOP) dan tahun pajak. Data ditarik langsung dari basis data desa."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Layanan", to: "/layanan" }, { label: "PBB" }]}
    >
      <Seo title="Cek Tagihan PBB" description="Cek status tagihan Pajak Bumi dan Bangunan (PBB) berdasarkan NOP." path="/layanan/pbb" />
      <SectionWrap>
        <form className="max-w-2xl border border-current/20 p-6 sm:p-8 grid gap-5" onSubmit={cariPbb}>
          <div className="grid sm:grid-cols-[1fr_140px] gap-4">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor Objek Pajak</span>
              <input value={nop} onChange={(e) => setNop(e.target.value)} maxLength={40} autoComplete="off" placeholder="52.03.140.007.001-0001.0" className={`${inputCls} font-mono`} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Tahun</span>
              <input type="number" min={2020} max={2100} value={tahun} onChange={(e) => setTahun(Number(e.target.value))} autoComplete="off" className={`${inputCls} tabular-nums`} />
            </label>
          </div>
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">NIK Wajib Pajak</span>
            <input value={nik} onChange={(e) => setNik(e.target.value.replace(/\D/g,""))} maxLength={16} minLength={16} pattern="\d{16}" autoComplete="off" inputMode="numeric" placeholder="16 digit NIK sesuai SPPT" className={`${inputCls} font-mono tabular-nums`} />
            <span className="mt-1 block text-[11px] opacity-60">NIK diperlukan sebagai verifikasi agar data tagihan tidak dapat ditelusuri dari NOP saja.</span>
          </label>
          <button type="submit" disabled={loading} className={`${btnPrimary} justify-center disabled:opacity-60`}>
            {loading ? "Mencari…" : "Cek Tagihan"}
          </button>
        </form>
        {notFound && (
          <div className="mt-6 max-w-2xl border border-current/20 p-6 text-sm opacity-75">
            Tagihan tidak ditemukan. Pastikan NOP, tahun, dan NIK Wajib Pajak sesuai dengan SPPT, atau hubungi kantor desa.
          </div>
        )}
        {hasil && (
          <div className="mt-8 max-w-2xl bg-primary text-primary-foreground p-6 sm:p-8">
            <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Hasil Pencarian</div>
            <dl className="mt-4 grid sm:grid-cols-2 gap-y-3 gap-x-6 text-sm">
              <div><dt className="opacity-60 text-xs uppercase tracking-wider">Tahun</dt><dd className="font-mono mt-0.5 tabular-nums">{hasil.tahun}</dd></div>
              <div><dt className="opacity-60 text-xs uppercase tracking-wider">NOP</dt><dd className="font-mono mt-0.5">{hasil.nop}</dd></div>
              <div className="sm:col-span-2 pt-4 border-t border-white/15">
                <dt className="opacity-60 text-xs uppercase tracking-wider">Tagihan</dt>
                <dd className="mt-1 font-display text-4xl font-bold tabular-nums italic text-accent">Rp {Number(hasil.pbb_terutang).toLocaleString("id-ID")}</dd>
              </div>
              <div><dt className="opacity-60 text-xs uppercase tracking-wider">Jatuh Tempo</dt><dd className="mt-0.5 tabular-nums">{hasil.jatuh_tempo ? formatTanggal(hasil.jatuh_tempo) : "-"}</dd></div>
              <div>
                <dt className="opacity-60 text-xs uppercase tracking-wider">Status</dt>
                <dd className={`mt-0.5 font-display text-sm font-bold uppercase tracking-widest ${hasil.status_bayar === "lunas" ? "text-accent" : "text-white"}`}>
                  {hasil.status_bayar === "lunas" ? `Lunas${hasil.tanggal_bayar ? " · " + formatTanggal(hasil.tanggal_bayar) : ""}` : "Belum Lunas"}
                </dd>
              </div>
            </dl>
            {hasil.status_bayar !== "lunas" && (
              <div className="mt-6 border-t border-white/15 pt-6 text-xs opacity-70">
                Pembayaran dapat dilakukan melalui QRIS, Virtual Account, atau langsung ke Kantor Desa. Kanal pembayaran online akan diaktifkan pada rilis berikutnya.
              </div>
            )}
          </div>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

export function ServiceCenterPage() {
  const { data: settings } = useSiteSettings();
  const [mode, setMode] = useState<"kirim" | "lacak">("kirim");
  const [kategori, setKategori] = useState<string>("");
  const { data: kategoriList } = useAduanKategori();
  const { data: dusunList } = useDusun();
  const [nik, setNik] = useState("");
  const [nama, setNama] = useState("");
  const [kontak, setKontak] = useState("");
  const [judul, setJudul] = useState("");
  const [lokasi, setLokasi] = useState("");
  const [isi, setIsi] = useState("");
  interface LacakHasil {
    status?: string;
    judul?: string;
    nomor_tiket?: string;
    kategori?: string;
    created_at?: string;
    updated_at?: string;
    tanggapan?: string;
    notfound?: boolean;
  }

  const [loading, setLoading] = useState(false);
  const [tiket, setTiket] = useState<string | null>(null);
  const [lacakNo, setLacakNo] = useState("");
  const [lacakHasil, setLacakHasil] = useState<LacakHasil | null>(null);
  const [lacakLoading, setLacakLoading] = useState(false);

  useAutofillPenduduk(nik, (d) => {
    setNama(d.nama);
    if (d.nomor_hp) setKontak(d.nomor_hp);
  });

  async function submitAduan(e: React.FormEvent) {
    e.preventDefault();
    if (nama.trim().length < 2) return toast.error("Nama minimal 2 karakter");
    if (nik && nik.trim().length !== 16) return toast.error("NIK harus 16 digit angka");
    if (kontak.trim().length < 4) return toast.error("Kontak tidak valid");
    if (judul.trim().length < 4) return toast.error("Judul minimal 4 karakter");
    if (isi.trim().length < 10) return toast.error("Uraian minimal 10 karakter");
    setLoading(true);
    // Call edge function submit-aduan
    const { data, error } = await supabase.functions.invoke("submit-aduan", {
      body: {
        nama: nama.trim(),
        kontak: kontak.trim(),
        kategori: kategori || "lainnya",
        judul: judul.trim(),
        deskripsi: isi.trim(),
        lokasi: lokasi.trim() || undefined,
      }
    });

    setLoading(false);
    if (error || !data?.ok) return toast.error(error?.message || data?.error || "Gagal mengirim aduan");
    setTiket(data.nomor_tiket);
    toast.success("Aduan terkirim");
  }

  async function lacak(e: React.FormEvent) {
    e.preventDefault();
    if (!lacakNo.trim()) return;
    setLacakLoading(true);
    const { data, error } = await supabase.rpc("lacak_aduan", { _nomor_tiket: lacakNo.trim() });
    setLacakLoading(false);
    if (error) return toast.error(error.message);
    const row = Array.isArray(data) ? data[0] : data;
    if (!row) { setLacakHasil({ notfound: true }); return; }
    setLacakHasil(row);
  }

  return (
    <EditorialLayout
      eyebrow="Service Center"
      judul="Pengaduan Warga & Kontak Kantor Desa"
      deskripsi="Sampaikan aduan atau pertanyaan. Tim Service Center memproses tiket 1×24 jam pada hari kerja."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Service Center" }]}
    >
      <SectionWrap>
        <div className="mb-8 flex gap-px bg-current/15 w-fit">
          {(["kirim", "lacak"] as const).map((m) => (
            <button
              key={m}
              type="button"
              onClick={() => setMode(m)}
              className={`px-6 py-3 font-display text-[11px] font-bold uppercase tracking-[0.28em] bg-background transition-colors ${mode === m ? "text-accent border-b-2 border-accent" : "opacity-60 hover:opacity-100"}`}
            >
              {m === "kirim" ? "Kirim Aduan" : "Lacak Tiket"}
            </button>
          ))}
        </div>

        <div className="grid lg:grid-cols-[1fr_320px] gap-10 items-start">
          {mode === "kirim" && tiket ? (
            <div className="border-l-2 border-accent pl-6 py-6">
              <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Berhasil</div>
              <div className="mt-2 font-display text-2xl font-semibold italic">Aduan diterima</div>
              <p className="mt-3 text-sm opacity-80">Simpan nomor tiket untuk melacak status.</p>
              <div className="mt-4 font-mono text-lg text-accent">{tiket}</div>
              <div className="flex gap-3 mt-6">
                <button type="button" onClick={() => { setTiket(null); setNama(""); setKontak(""); setJudul(""); setIsi(""); setLokasi(""); }} className={btnPrimary}>Kirim lagi</button>
                <button type="button" onClick={() => { setMode("lacak"); setLacakNo(tiket); }} className={btnPrimary}>Lacak tiket ini</button>
              </div>
            </div>
          ) : mode === "kirim" ? (
            <form className="grid gap-5 border border-current/20 p-6 sm:p-8" onSubmit={submitAduan}>
              <div className="grid sm:grid-cols-2 gap-5">
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Kategori</span>
                  <select value={kategori} onChange={(e) => setKategori(e.target.value)} autoComplete="off" className={inputCls}>
                    {kategoriList?.map((k) => (<option key={k.nama} value={k.nama}>{k.nama}</option>))}
                  </select>
                </label>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Lokasi (Dusun)</span>
                  <select value={lokasi} onChange={(e) => setLokasi(e.target.value)} autoComplete="off" className={inputCls}>
                    <option value="">— pilih —</option>
                    {dusunList.map((d) => (<option key={d.nama} value={d.nama}>{d.nama}</option>))}
                  </select>
                </label>
              </div>
              <div className="grid sm:grid-cols-2 gap-5">
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">NIK (opsional)</span>
                  <input value={nik} onChange={(e) => setNik(e.target.value.replace(/\D/g,""))} maxLength={16} minLength={16} pattern="\d{16}" autoComplete="off" inputMode="numeric" placeholder="16 digit NIK" className={inputCls} />
                </label>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nama Pelapor <span className="text-accent">*</span></span>
                  <input required value={nama} onChange={(e) => setNama(e.target.value)} maxLength={120} autoComplete="name" className={inputCls} />
                </label>
              </div>
              <div className="grid sm:grid-cols-2 gap-5">
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor WhatsApp / Telepon <span className="text-accent">*</span></span>
                  <input required value={kontak} onChange={(e) => setKontak(e.target.value)} type="tel" maxLength={60} autoComplete="tel" placeholder="08xxxxxxxxxx" className={inputCls} />
                </label>
              </div>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Judul Aduan</span>
                <input required value={judul} onChange={(e) => setJudul(e.target.value)} maxLength={160} autoComplete="off" className={inputCls} />
              </label>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Uraian Aduan</span>
                <textarea required rows={5} value={isi} onChange={(e) => setIsi(e.target.value)} maxLength={4000} autoComplete="off" placeholder="Ceritakan kejadian, kapan terjadi, dan dampaknya." className={inputCls} />
              </label>
              <button disabled={loading} type="submit" className={`${btnPrimary} justify-self-start disabled:opacity-50`}>{loading ? "Mengirim…" : "Kirim Aduan"}</button>
            </form>
          ) : (
            <div className="grid gap-6">
              <form className="grid gap-5 border border-current/20 p-6 sm:p-8" onSubmit={lacak}>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor Tiket</span>
                  <input required value={lacakNo} onChange={(e) => setLacakNo(e.target.value)} autoComplete="off" placeholder="ADN-2026-XXXXXX" className={`${inputCls} font-mono`} />
                </label>
                <button disabled={lacakLoading} type="submit" className={`${btnPrimary} justify-self-start disabled:opacity-50`}>{lacakLoading ? "Mencari…" : "Cek Status"}</button>
              </form>
              {lacakHasil?.notfound && (
                <div className="border-l-2 border-current/40 pl-6 py-4 text-sm opacity-75">Nomor tiket tidak ditemukan.</div>
              )}
              {lacakHasil && !lacakHasil.notfound && (
                <div className="border border-accent p-6 sm:p-8">
                  <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Status: {lacakHasil.status}</div>
                  <div className="mt-2 font-display text-2xl font-semibold italic">{lacakHasil.judul}</div>
                  <dl className="mt-6 pt-6 border-t border-current/15 text-sm grid sm:grid-cols-2 gap-y-3 gap-x-6">
                    <div><dt className="opacity-60 text-xs uppercase tracking-wider">Tiket</dt><dd className="font-mono mt-0.5">{lacakHasil.nomor_tiket}</dd></div>
                    <div><dt className="opacity-60 text-xs uppercase tracking-wider">Kategori</dt><dd className="mt-0.5">{lacakHasil.kategori}</dd></div>
                    <div><dt className="opacity-60 text-xs uppercase tracking-wider">Diajukan</dt><dd className="mt-0.5 tabular-nums">{formatTanggal(lacakHasil.created_at)}</dd></div>
                    <div><dt className="opacity-60 text-xs uppercase tracking-wider">Diperbarui</dt><dd className="mt-0.5 tabular-nums">{formatTanggal(lacakHasil.updated_at)}</dd></div>
                  </dl>
                  {lacakHasil.tanggapan && (
                    <div className="mt-6 pt-6 border-t border-current/15">
                      <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Tanggapan Admin</div>
                      <p className="mt-2 text-sm leading-relaxed">{lacakHasil.tanggapan}</p>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          <aside className="bg-primary text-primary-foreground p-6 sm:p-8 space-y-4 border border-primary">
            <h3 className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Kontak Resmi</h3>
            <div className="text-sm">
              <div className="opacity-60 text-xs uppercase tracking-wider">WhatsApp Resmi</div>
              <a href={`https://wa.me/${(settings?.nomor_wa_resmi ?? "08123456789").replace(/\D/g, "")}`} className="font-medium hover:text-accent">{settings?.nomor_wa_resmi ?? "08123456789"}</a>
              {(settings?.wa_business_verified ?? false) && (<div className="text-[10px] font-bold uppercase tracking-[0.22em] text-accent mt-1">Terverifikasi</div>)}
            </div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Telepon Darurat</div><div className="font-medium tabular-nums">{settings?.telepon_darurat ?? "112"}</div></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Email</div><a href={`mailto:${settings?.email ?? "info@desa.go.id"}`} className="font-medium hover:text-accent break-all">{settings?.email ?? "info@desa.go.id"}</a></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Jam Layanan</div><div>{settings?.jam_layanan ?? "08:00 - 15:00"}</div></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Alamat</div><div>{settings?.alamat_kantor ?? "Kantor Desa"}</div></div>
          </aside>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function VerifikasiPage() {
  const [nomor, setNomor] = useState("");
  const [kode, setKode] = useState("");
  const [tteId, setTteId] = useState("");
  const [tab, setTab] = useState<'nomor' | 'tte'>('nomor');
  interface VerifikasiSurat {
    perihal?: string;
    nomor_surat?: string;
    jenis_nama?: string;
    pemohon_nama?: string;
    tanggal_terbit?: string;
    berlaku_sampai?: string;
    status?: string;
    penandatangan?: string;
    notfound?: boolean;
  }

  interface TteSignature {
    id?: string;
    status?: string;
    surat?: {
      jenis?: string;
      nomor_surat?: string;
      tanggal_terbit?: string;
      keperluan?: string;
    } | null;
    pamong?: {
      id?: string;
      nama?: string;
      jabatan?: string;
      nip?: string;
      foto_url?: string;
      ttd_image_url?: string;
      qr_code_url?: string;
      periode?: string;
    } | null;
    pamong_id?: string;
    signed_by?: string;
    signer_role?: string;
    tipe?: string;
    signed_at?: string;
    qr_code_url?: string;
    signature_hash?: string;
    notfound?: boolean;
  }

  const [loading, setLoading] = useState(false);
  const [hasil, setHasil] = useState<VerifikasiSurat | null>(null);
  const [tteHasil, setTteHasil] = useState<TteSignature | null>(null);

  async function cek(e: React.FormEvent) {
    e.preventDefault();
    if (!nomor.trim() || !kode.trim()) return toast.error("Nomor & kode wajib diisi");
    setLoading(true);
    const { data, error } = await supabase.rpc("verifikasi_surat", { _nomor: nomor.trim(), _kode: kode.trim() });
    setLoading(false);
    if (error) return toast.error(error.message);
    const row = Array.isArray(data) ? data[0] : data;
    setHasil((row as VerifikasiSurat) ?? { notfound: true });
  }

  interface SupabaseBypass {
    from: (name: string) => {
      select: (columns: string) => {
        eq: (column: string, value: string) => {
          single: () => Promise<{ data: Record<string, unknown> | null; error: { message: string } | null }>;
        };
      };
    };
  }

  async function cekTTE(e: React.FormEvent) {
    e.preventDefault();
    if (!tteId.trim()) return toast.error("ID TTE wajib diisi");
    setLoading(true);
    setTteHasil(null);

    try {
      // Get signature info
      const { data: sig, error: sigError } = await (supabase as unknown as SupabaseBypass)
        .from('tte_signatures')
        .select('*')
        .eq('id', tteId.trim())
        .single();

      if (sigError || !sig) {
        setTteHasil({ notfound: true });
        setLoading(false);
        return;
      }

      // Get surat info
      const { data: surat } = await (supabase as unknown as SupabaseBypass)
        .from('surat_terbit')
        .select('id, nomor_surat, jenis:jenis_nama, tanggal_terbit, keperluan:keterangan')
        .eq('id', (sig.surat_id as string) || '')
        .single();

      // Get pamong (penanda tangan) info if pamong_id exists
      let pamongInfo = null;
      if (sig.pamong_id) {
        const { data: pamong } = await (supabase as unknown as SupabaseBypass)
          .from('desa_pamong')
          .select('*')
          .eq('id', sig.pamong_id as string)
          .single();
        pamongInfo = pamong;
      }

      // Check expiry
      const isExpired = new Date(sig.signed_at as string) < new Date(Date.now() - 365 * 24 * 60 * 60 * 1000);

      setTteHasil({
        ...sig,
        status: isExpired ? 'expired' : (sig.status as string),
        surat: (surat as TteSignature['surat']) || null,
        pamong: pamongInfo,
      });
    } catch (err) {
      console.error('TTE verify error:', err);
      setTteHasil({ notfound: true });
    } finally {
      setLoading(false);
    }
  }

  function formatTteStatus(status: string) {
    switch (status) {
      case 'signed': return { label: 'Tertanda Tangan', color: 'text-green-600 bg-green-50', icon: '✓' };
      case 'verified': return { label: 'Terverifikasi', color: 'text-blue-600 bg-blue-50', icon: '✓' };
      case 'expired': return { label: 'Kadaluarsa', color: 'text-yellow-600 bg-yellow-50', icon: '!' };
      case 'rejected': return { label: 'Ditolak', color: 'text-red-600 bg-red-50', icon: '✕' };
      default: return { label: status, color: 'text-gray-600 bg-gray-50', icon: '?' };
    }
  }

  function formatTipe(tipe: string) {
    switch (tipe) {
      case 'sederhana': return 'Tanda Tangan Sederhana';
      case 'bsre': return 'BSRE (eSign)';
      case 'esign': return 'Tanda Tangan Elektronik';
      default: return tipe;
    }
  }

  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Verifikasi Dokumen"
      deskripsi="Cek keaslian surat desa dan tanda tangan elektronik."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Verifikasi" }]}
    >
      <Seo title="Verifikasi Dokumen Surat" description="Cek keaslian surat resmi Desa Seruni Mumbul dengan nomor & kode verifikasi." path="/verifikasi" />
      <SectionWrap>
        {/* Tab Switcher */}
        <div className="flex border-b border-current/20 mb-6">
          <button
            onClick={() => setTab('nomor')}
            className={`px-6 py-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] transition-colors ${
              tab === 'nomor' ? 'border-b-2 border-accent text-accent' : 'text-muted-foreground'
            }`}
          >
            Verifikasi Nomor Surat
          </button>
          <button
            onClick={() => setTab('tte')}
            className={`px-6 py-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] transition-colors ${
              tab === 'tte' ? 'border-b-2 border-accent text-accent' : 'text-muted-foreground'
            }`}
          >
            Verifikasi TTE
          </button>
        </div>

        {/* Tab: Nomor Surat */}
        {tab === 'nomor' && (
          <>
            <form className="max-w-xl border border-current/20 p-6 sm:p-8 grid gap-5" onSubmit={cek}>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor Surat</span>
                <input value={nomor} onChange={(e) => setNomor(e.target.value)} autoComplete="off" placeholder="470/001/SM/2026" className={`${inputCls} font-mono`} />
              </label>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Kode Verifikasi</span>
                <input value={kode} onChange={(e) => setKode(e.target.value)} autoComplete="off" placeholder="SRN-DEMO-001" className={`${inputCls} font-mono`} />
              </label>
              <button disabled={loading} type="submit" className={`${btnPrimary} justify-center disabled:opacity-50`}>{loading ? "Memeriksa…" : "Verifikasi"}</button>
              <p className="text-xs opacity-60">Demo: coba <span className="font-mono">470/001/SM/2026</span> + <span className="font-mono">SRN-DEMO-001</span>.</p>
            </form>
            {hasil?.notfound && (
              <div className="mt-8 max-w-xl border border-current/30 p-6 sm:p-8">
                <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] opacity-60">Tidak Ditemukan</div>
                <div className="mt-3 font-display text-2xl font-semibold italic">Surat tidak dapat diverifikasi</div>
                <p className="mt-3 text-sm opacity-70">Periksa kembali nomor & kode verifikasi.</p>
              </div>
            )}
            {hasil && !hasil.notfound && (
              <div className="mt-8 max-w-xl border border-accent p-6 sm:p-8">
                <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                  Sah & Terverifikasi
                </div>
                <div className="mt-3 font-display text-2xl font-semibold italic">{hasil.perihal}</div>
                <dl className="mt-6 pt-6 border-t border-current/15 text-sm grid sm:grid-cols-2 gap-y-3 gap-x-6">
                  <div><dt className="opacity-60 text-xs uppercase tracking-wider">Nomor</dt><dd className="font-mono mt-0.5">{hasil.nomor_surat}</dd></div>
                  <div><dt className="opacity-60 text-xs uppercase tracking-wider">Jenis</dt><dd className="mt-0.5">{hasil.jenis_nama}</dd></div>
                  <div><dt className="opacity-60 text-xs uppercase tracking-wider">Atas Nama</dt><dd className="mt-0.5">{hasil.pemohon_nama}</dd></div>
                  <div><dt className="opacity-60 text-xs uppercase tracking-wider">Tanggal Terbit</dt><dd className="mt-0.5 tabular-nums">{formatTanggal(hasil.tanggal_terbit)}</dd></div>
                  {hasil.berlaku_sampai && <div><dt className="opacity-60 text-xs uppercase tracking-wider">Berlaku Sampai</dt><dd className="mt-0.5 tabular-nums">{formatTanggal(hasil.berlaku_sampai)}</dd></div>}
                  <div><dt className="opacity-60 text-xs uppercase tracking-wider">Status</dt><dd className="mt-0.5">{hasil.status}</dd></div>
                  {hasil.penandatangan && <div className="sm:col-span-2"><dt className="opacity-60 text-xs uppercase tracking-wider">Ditandatangani</dt><dd className="mt-0.5">{hasil.penandatangan}</dd></div>}
                </dl>
              </div>
            )}
          </>
        )}

        {/* Tab: TTE Verification */}
        {tab === 'tte' && (
          <>
            <form className="max-w-xl border border-current/20 p-6 sm:p-8 grid gap-5" onSubmit={cekTTE}>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">ID Tanda Tangan Elektronik</span>
                <input value={tteId} onChange={(e) => setTteId(e.target.value)} autoComplete="off" placeholder="Masukkan ID TTE (UUID)" className={`${inputCls} font-mono`} />
              </label>
              <p className="text-xs opacity-60">
                ID TTE terdapat di dokumen surat yang sudah ditandatangani secara elektronik.
              </p>
              <button disabled={loading} type="submit" className={`${btnPrimary} justify-center disabled:opacity-50`}>
                {loading ? "Memeriksa…" : "Verifikasi TTE"}
              </button>
            </form>

            {tteHasil?.notfound && (
              <div className="mt-8 max-w-xl border border-current/30 p-6 sm:p-8">
                <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] opacity-60">Tidak Ditemukan</div>
                <div className="mt-3 font-display text-2xl font-semibold italic">TTE tidak dapat diverifikasi</div>
                <p className="mt-3 text-sm opacity-70">Pastikan ID TTE yang Anda masukkan benar.</p>
              </div>
            )}

            {tteHasil && !tteHasil.notfound && (
              <div className="mt-8 max-w-xl space-y-4">
                {/* Status Badge */}
                <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-full border ${formatTteStatus(tteHasil.status).color}`}>
                  <span>{formatTteStatus(tteHasil.status).icon}</span>
                  <span className="font-semibold">{formatTteStatus(tteHasil.status).label}</span>
                </div>

                {/* Profil Pejabat (jika ada data pamong) */}
                {tteHasil.pamong && (
                  <div className="border border-accent p-6 sm:p-8">
                    <div className="flex items-start gap-6">
                      {/* Foto */}
                      {tteHasil.pamong.foto_url ? (
                        <img
                          src={tteHasil.pamong.foto_url}
                          alt={tteHasil.pamong.nama}
                          className="w-24 h-24 rounded-full object-cover border-2 border-accent"
                        />
                      ) : (
                        <div className="w-24 h-24 rounded-full bg-muted flex items-center justify-center text-3xl">
                          👤
                        </div>
                      )}

                      {/* Info Pejabat */}
                      <div className="flex-1">
                        <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-1">
                          Pejabat Penanda Tangan
                        </div>
                        <h3 className="font-display text-xl font-bold">{tteHasil.pamong.nama}</h3>
                        <p className="text-lg font-semibold text-accent">{tteHasil.pamong.jabatan}</p>
                        {tteHasil.pamong.nip && (
                          <p className="text-sm opacity-70">NIP. {tteHasil.pamong.nip}</p>
                        )}
                        {tteHasil.pamong.periode && (
                          <p className="text-sm opacity-70">Periode: {tteHasil.pamong.periode}</p>
                        )}
                      </div>
                    </div>
                  </div>
                )}

                {/* Document Info - Arsip Registrasi */}
                <div className="border border-current/20 p-6 sm:p-8">
                  <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4">
                    📁 Informasi Arsip Registrasi
                  </div>
                  <dl className="grid sm:grid-cols-2 gap-4 text-sm">
                    <div><dt className="opacity-60 text-xs">Jenis Surat</dt><dd className="font-semibold mt-0.5">{tteHasil.surat?.jenis || '-'}</dd></div>
                    <div><dt className="opacity-60 text-xs">Nomor Surat</dt><dd className="font-mono mt-0.5">{tteHasil.surat?.nomor_surat || '-'}</dd></div>
                    <div><dt className="opacity-60 text-xs">Tanggal Terbit</dt><dd className="mt-0.5">{tteHasil.surat ? formatTanggal(tteHasil.surat.tanggal_terbit) : '-'}</dd></div>
                    <div><dt className="opacity-60 text-xs">ID Dokumen</dt><dd className="font-mono text-xs mt-0.5">{tteHasil.id}</dd></div>
                    {tteHasil.surat?.keperluan && (
                      <div className="sm:col-span-2"><dt className="opacity-60 text-xs">Keperluan</dt><dd className="mt-0.5">{tteHasil.surat.keperluan}</dd></div>
                    )}
                  </dl>
                </div>

                {/* Tanda Tangan Info */}
                <div className="border border-current/20 p-6 sm:p-8">
                  <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4">
                    Informasi Tanda Tangan
                  </div>
                  <dl className="grid sm:grid-cols-2 gap-4 text-sm">
                    <div><dt className="opacity-60 text-xs">Ditandatangani oleh</dt><dd className="font-semibold mt-0.5">{tteHasil.signed_by}</dd></div>
                    <div><dt className="opacity-60 text-xs">Jabatan</dt><dd className="mt-0.5">{tteHasil.signer_role || '-'}</dd></div>
                    <div><dt className="opacity-60 text-xs">Tipe TTE</dt><dd className="mt-0.5">{formatTipe(tteHasil.tipe)}</dd></div>
                    <div><dt className="opacity-60 text-xs">Waktu Tanda Tangan</dt><dd className="mt-0.5">{formatTanggal(tteHasil.signed_at)}</dd></div>
                  </dl>

                  {/* QR Code Verification */}
                  {tteHasil.qr_code_url && (
                    <div className="mt-4 pt-4 border-t flex items-center gap-4">
                      <img src={tteHasil.qr_code_url} alt="QR" className="w-20 h-20" />
                      <div>
                        <p className="text-sm font-semibold">QR Code Verifikasi</p>
                        <p className="text-xs opacity-60">Scan QR ini di dokumen fisik untuk verifikasi</p>
                      </div>
                    </div>
                  )}
                </div>

                {/* Hash */}
                {tteHasil.signature_hash && (
                  <div className="border border-current/20 p-6 sm:p-8">
                    <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-2">
                      Hash Dokumen
                    </div>
                    <p className="font-mono text-xs break-all text-muted-foreground">
                      {tteHasil.signature_hash}
                    </p>
                    <p className="text-xs opacity-60 mt-2">
                      Hash digunakan untuk memastikan dokumen tidak dimodifikasi setelah ditandatangani.
                    </p>
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Data & Statistik ============================

export function StatistikHubPage() {
  const cards = [
    { to: "/status-idm", kicker: "Indeks", judul: "Status IDM", desc: "Skor 6 dimensi & status desa." },
    { to: "/statistik/penduduk", kicker: "Demografi", judul: "Statistik Penduduk", desc: "Jiwa, umur, pekerjaan, pendidikan." },
    { to: "/pembangunan", kicker: "Anggaran", judul: "APBDes & Pembangunan", desc: "Realisasi kegiatan & anggaran." },
    { to: "/perencanaan", kicker: "Musrenbang", judul: "Perencanaan (Voting)", desc: "Usulan warga & partisipasi." },
    { to: "/keuangan", kicker: "Transparansi", judul: "Keuangan APBDes", desc: "Rincian pendapatan, belanja, & pembiayaan." },
    { to: "/bansos", kicker: "Kesejahteraan", judul: "Bantuan Sosial", desc: "Program & penerima bansos." },
    { to: "/stunting", kicker: "Gizi", judul: "Monitoring Stunting", desc: "Data balita & intervensi gizi." },
    { to: "/bencana", kicker: "Kebencanaan", judul: "Bencana & Risiko", desc: "Kejadian & mitigasi bencana." },
  ];
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Data Terbuka Desa"
      deskripsi="Semua data agregat desa, diperbarui dari sistem satu data."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik" }]}
    >
      <SectionWrap>
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
          {cards.map((c, i) => (
            <Link key={c.to} to={c.to} className="group bg-background p-6 sm:p-8 min-h-[220px] flex flex-col justify-between hover:bg-primary hover:text-primary-foreground transition-colors">
              <span className="font-display text-3xl font-light opacity-25 tabular-nums group-hover:text-accent group-hover:opacity-100">
                {String(i + 1).padStart(2, "0")}
              </span>
              <div>
                <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{c.kicker}</p>
                <div className="mt-2 font-display text-xl font-semibold leading-snug">{c.judul}</div>
                <p className="mt-2 text-sm opacity-75 leading-relaxed">{c.desc}</p>
              </div>
            </Link>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function StatusIDMPage() {
  const { data: idmData } = useIdmData();
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Status Indeks Desa Membangun"
      deskripsi="Skor IDM dihitung dari 6 dimensi: kesehatan, pendidikan, modal sosial, permukiman, ekonomi, dan ekologi."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "IDM" }]}
    >
      <StatsBand
        kicker="Skor Agregat"
        tone="dark"
        items={[
          { nilai: idmData?.skor_total?.toFixed(4) ?? '—', label: "Skor Total IDM", highlight: true },
          { nilai: idmData?.status ?? '—', label: "Status Desa" },
          { nilai: String(idmData?.dimensi?.length ?? 0), label: "Dimensi Dinilai" },
          { nilai: "5.0", label: "Skor Maksimum" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="enam-dimensi-rincian-per-dimensi" kicker="Enam Dimensi" judul="Rincian per Dimensi" />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
          {(idmData?.dimensi || []).map((d, i) => (
            <div key={d.nama} className="bg-background p-6">
              <span className="font-display text-2xl font-light opacity-25 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
              <div className="mt-3 font-display font-semibold leading-snug">{d.nama}</div>
              <div className="mt-4 flex items-baseline gap-2">
                <span className="font-display text-4xl font-bold italic text-accent tabular-nums">{d.skor.toFixed(1)}</span>
                <span className="text-xs opacity-60">/ 5.0</span>
              </div>
              <div className="mt-3 h-[3px] w-full bg-current/10 overflow-hidden">
                <div className="h-full bg-accent" style={{ width: `${(d.skor / 5) * 100}%` }} />
              </div>
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function StatistikPendudukPage() {
  const { data: statistik } = useStatistikDesa();
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Statistik Penduduk"
      deskripsi={`Total ${(statistik?.jumlah_penduduk || 0).toLocaleString("id-ID")} jiwa dalam ${(statistik?.jumlah_kk || 0).toLocaleString("id-ID")} KK, tersebar di ${statistik?.jumlah_dusun || 0} dusun.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Penduduk" }]}
    >
      <Seo title="Statistik Penduduk" description="Distribusi penduduk berdasarkan usia, mata pencaharian, dan pendidikan." path="/statistik/penduduk" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: (statistik?.jumlah_penduduk || 0).toLocaleString("id-ID"), label: "Total Jiwa", highlight: true },
          { nilai: (statistik?.jumlah_kk || 0).toLocaleString("id-ID"), label: "Kepala Keluarga" },
          { nilai: String(statistik?.jumlah_dusun || 0), label: "Dusun" },
          { nilai: String((statistik?.per_umur?.length || 0) + (statistik?.per_pekerjaan?.length || 0) + (statistik?.per_pendidikan?.length || 0)), label: "Data Distribusi" },
        ]}
      />
      <SectionWrap>
        <div className="grid md:grid-cols-2 gap-10 lg:gap-14">
          {[
            { j: "Jenis Kelamin", d: [
                { label: "Laki-laki", nilai: statistik?.laki_laki || 0 },
                { label: "Perempuan", nilai: statistik?.perempuan || 0 },
            ] },
            { j: "Kelompok Umur", d: statistik?.per_umur || [] },
            { j: "Pekerjaan", d: statistik?.per_pekerjaan || [] },
            { j: "Pendidikan", d: statistik?.per_pendidikan || [] },
          ].map((g) => (
            <div key={g.j}>
              <EditorialTitle sectionKey="distribusi" kicker="Distribusi" judul={g.j} />
              {g.d.length > 0 ? (
                <BarList items={g.d} />
              ) : (
                <div className="text-sm opacity-50 italic">Data belum tersedia</div>
              )}
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function PembangunanPage() {
  const { data: pembangunanData } = usePembangunanData();
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="APBDes & Pembangunan"
      deskripsi="Realisasi kegiatan pembangunan desa dan penyerapan anggaran APBDes 2026."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Pembangunan" }]}
    >
      <Seo title="APBDes & Pembangunan" description="Progres kegiatan pembangunan Desa Seruni Mumbul berjalan." path="/pembangunan" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: `${pembangunanData?.progres_fisik_avg ?? 0}%`, label: "Progres Fisik Rata-Rata", highlight: true },
          { nilai: `${pembangunanData?.anggaran_terserap_pct ?? 0}%`, label: "Anggaran Terserap" },
          { nilai: String(pembangunanData?.aset_baru ?? 0), label: "Aset Baru Terbentuk" },
          { nilai: String(pembangunanData?.kegiatan_aktif?.length ?? 0), label: "Kegiatan Aktif" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="realisasi-2026-kegiatan-aktif" kicker="Realisasi 2026" judul="Kegiatan Aktif" />
        <ul className="space-y-6">
          {(pembangunanData?.kegiatan_aktif ?? []).map((k) => (
            <li key={k.nama}>
              <Link to={`/pembangunan/${(k as any).id}`} className="block hover:bg-muted/20 transition-colors">
                <EditorialProgress label={k.nama} value={k.progres} />
              </Link>
            </li>
          ))}
        </ul>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function PerencanaanPage() {
  const { data: usulanData } = useUsulanStats();
  return (
    <EditorialLayout
      eyebrow="Data & Statistik"
      judul="Perencanaan & Voting Usulan"
      deskripsi={`${usulanData?.total_usulan ?? 0} usulan warga terkumpul, dengan ${(usulanData?.partisipasi_voting ?? 0).toLocaleString("id-ID")} suara pada periode Musrenbang 2027.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Perencanaan" }]}
    >
      <Seo title="Perencanaan & Voting Usulan" description="RKPDes, usulan Musdes, dan prioritas pembangunan tahun berjalan." path="/perencanaan" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: (usulanData?.total_usulan ?? 0).toLocaleString("id-ID"), label: "Total Usulan", highlight: true },
          { nilai: (usulanData?.partisipasi_voting ?? 0).toLocaleString("id-ID"), label: "Suara Partisipasi" },
          { nilai: String((usulanData?.top10?.length ?? 0)), label: "Top Peringkat" },
          { nilai: "2027", label: "Periode Musrenbang" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="top-10-usulan-warga-terpilih" kicker="Top 10" judul="Usulan Warga Terpilih" />
        <ul className="space-y-6">
          {(usulanData.top10 || []).map((u, i) => (
            <li key={u.judul} className="grid grid-cols-[48px_1fr] gap-5 border-b border-current/15 pb-6">
              <span className="font-display text-3xl font-light opacity-25 tabular-nums leading-none">{String(i + 1).padStart(2, "0")}</span>
              <EditorialProgress label={u.judul} value={u.suara} max={Math.max(...(usulanData.top10 || []).map((x) => x.suara))} suffix=" suara" />
            </li>
          ))}
        </ul>
        <p className="mt-6 text-xs opacity-60">Voting warga dengan verifikasi OTP WhatsApp tersedia pada Phase 4 (Modul Usulan F2).</p>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Potensi & Marketplace & Peta ============================

export function PotensiPage() {
  const { data: umkm } = usePotensiUmkm();
  const { data: wisata } = usePotensiWisata();
  const { data: dusunList } = useDusun();
  const online = useOnlineStatus();
  const [q, setQ] = useState("");
  const [sektor, setSektor] = useState("");
  const [dusun, setDusun] = useState("");

  const bumdes = umkm.filter((u) => u.tipe === "bumdes" || u.tipe === "koperasi");
  const bumdesUtama = bumdes[0];
  const usahaAll = umkm.filter((u) => u.tipe === "umkm");
  const usaha = usahaAll.filter((u) => {
    const kw = q.trim().toLowerCase();
    if (kw && !`${u.nama} ${u.deskripsi || ""} ${u.pemilik || ""}`.toLowerCase().includes(kw)) return false;
    if (sektor && (u.sektor || "").toLowerCase() !== sektor.toLowerCase()) return false;
    if (dusun && (u.dusun || "") !== dusun) return false;
    return true;
  });
  const sektorOpsi = Array.from(new Set(usahaAll.map((u) => u.sektor).filter(Boolean))) as string[];
  const dusunOpsi = dusunList.map((d) => d.nama);
  const resetFilter = () => { setQ(""); setSektor(""); setDusun(""); };

  return (
    <EditorialLayout
      eyebrow="Potensi"
      judul="Potensi Ekonomi, Pariwisata, dan BUMDes"
      deskripsi="Sumber daya unggulan Desa Seruni Mumbul yang menjadi motor pertumbuhan warga."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Potensi" }]}
    >
      <Seo title="Potensi Desa" description="UMKM, BUMDes, koperasi, dan destinasi wisata Desa Seruni Mumbul." path="/potensi-desa" />
      <SectionWrap id="ekonomi">
        <EditorialTitle sectionKey="umkm-usaha-warga" kicker="UMKM" judul="Usaha Warga" />
        <OfflineBadge show={!online} />
        <FilterBar onReset={resetFilter} hasilCount={usaha.length} totalCount={usahaAll.length}>
          <FilterField label="Cari"><TextInput value={q} onChange={setQ} placeholder="Nama usaha, pemilik…" /></FilterField>
          <FilterField label="Sektor"><SelectInput value={sektor} onChange={setSektor} options={sektorOpsi.map((s) => ({ value: s, label: s }))} /></FilterField>
          <FilterField label="Dusun"><SelectInput value={dusun} onChange={setDusun} options={dusunOpsi.map((s) => ({ value: s, label: s }))} /></FilterField>
        </FilterBar>
        {usaha.length === 0 ? (
          <p className="text-sm opacity-60">Tidak ada usaha yang cocok dengan filter Anda.</p>
        ) : (
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
            {usaha.map((u, i) => (
              <article key={u.id} className="bg-background p-6 hover:bg-muted/20 transition-colors">
                <Link to={`/umkm/${u.id}`} className="block">
                  <span className="font-display text-2xl font-light opacity-25 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
                  <div className="mt-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{u.sektor || "Usaha"}</div>
                  <h3 className="mt-1 font-display text-lg font-semibold leading-snug">{u.nama}</h3>
                  {u.pemilik && <div className="mt-1 text-xs opacity-70">Pemilik: {u.pemilik}</div>}
                  {u.dusun && <div className="text-xs opacity-70">Dusun {u.dusun}</div>}
                  {u.deskripsi && <p className="mt-3 text-sm leading-relaxed opacity-80">{u.deskripsi}</p>}
                  {u.kontak && <div className="mt-3 pt-3 border-t border-current/15 text-xs tabular-nums">{u.kontak}</div>}
                </Link>
              </article>
            ))}
          </div>
        )}
      </SectionWrap>
      <SectionWrap id="pariwisata" alt>
        <EditorialTitle sectionKey="destinasi-pariwisata-desa" kicker="Destinasi" judul="Pariwisata Desa" />
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
          {wisata.map((p, i) => (
            <article key={p.id} className="bg-[#EAECF0] p-6 hover:bg-muted/20 transition-colors">
              <Link to={`/wisata/${p.id}`} className="block">
                <span className="font-display text-2xl font-light opacity-25 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
                <div className="mt-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{p.jenis}</div>
                <h3 className="mt-1 font-display text-xl font-semibold leading-snug">{p.nama}</h3>
                {p.dusun && <div className="text-xs opacity-70 mt-1">Dusun {p.dusun}</div>}
                {p.deskripsi && <p className="mt-3 text-sm leading-relaxed opacity-80">{p.deskripsi}</p>}
                {p.fasilitas && <div className="mt-3 pt-3 border-t border-current/15 text-xs opacity-70">Fasilitas: {p.fasilitas}</div>}
              </Link>
            </article>
          ))}
          {wisata.length === 0 && <p className="p-6 text-sm opacity-60">Belum ada destinasi terdaftar.</p>}
        </div>
        <div className="mt-6 flex justify-end">
          <Link to="/peta-desa" className={btnPrimary}>Lihat di Peta Desa</Link>
        </div>
      </SectionWrap>
      <section id="bumdes" className="bg-primary text-primary-foreground relative overflow-hidden">
        <div className="stempel-watermark absolute inset-0" style={{ color: "#fff" }} aria-hidden />
        <div className="relative mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 py-16 sm:py-20 lg:py-24">
          <div className="grid lg:grid-cols-[1fr_auto] gap-10 items-end border-l-2 border-accent pl-6 sm:pl-10">
            <div>
              <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{bumdesUtama?.tipe === "koperasi" ? "Koperasi" : "BUMDes"}</div>
              <h2 className="mt-3 font-display text-4xl sm:text-5xl lg:text-6xl font-bold italic tracking-tight leading-[1.05]">{bumdesUtama?.nama || "Badan Usaha Milik Desa"}</h2>
              <p className="mt-6 max-w-2xl text-base leading-relaxed opacity-80">
                {bumdesUtama?.deskripsi || "Belum ada informasi deskripsi BUMDes."}
              </p>
              {bumdes.length > 1 && (
                <ul className="mt-8 grid sm:grid-cols-2 gap-px bg-white/15 border-t border-b border-white/20">
                  {bumdes.slice(1).map((b) => (
                    <li key={b.id} className="bg-primary/60 p-5">
                      <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{b.tipe}</div>
                      <div className="mt-1 font-display font-semibold">{b.nama}</div>
                      {b.deskripsi && <p className="mt-2 text-xs opacity-75 leading-relaxed">{b.deskripsi}</p>}
                    </li>
                  ))}
                </ul>
              )}
            </div>
            <Link to="/marketplace" className={btnPrimary}>Kunjungi Marketplace</Link>
          </div>
        </div>
      </section>
    </EditorialLayout>
  );
}

export function MarketplacePage() {
  const { data: produk } = usePotensiProduk();
  const online = useOnlineStatus();
  const [q, setQ] = useState("");
  const [kategori, setKategori] = useState("");
  const [minHarga, setMinHarga] = useState("");
  const [maxHarga, setMaxHarga] = useState("");
  const [onlyFeatured, setOnlyFeatured] = useState(false);

  const kategoriOpsi = Array.from(new Set(produk.map((p) => p.kategori).filter(Boolean))) as string[];
  const filtered = produk.filter((p) => {
    const kw = q.trim().toLowerCase();
    if (kw && !`${p.nama} ${p.penjual_nama} ${p.deskripsi || ""}`.toLowerCase().includes(kw)) return false;
    if (kategori && (p.kategori || "") !== kategori) return false;
    if (onlyFeatured && !p.featured) return false;
    const min = Number(minHarga) || 0;
    const max = Number(maxHarga) || Infinity;
    if (p.harga != null && (p.harga < min || p.harga > max)) return false;
    return true;
  });
  const featured = filtered.filter((p) => p.featured);
  const terbaru = filtered.filter((p) => !p.featured);
  const fmtIDR = (n: number | null) => n == null ? "-" : new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(n);
  const reset = () => { setQ(""); setKategori(""); setMinHarga(""); setMaxHarga(""); setOnlyFeatured(false); };

  return (
    <EditorialLayout
      eyebrow="Potensi"
      judul="Marketplace Desa"
      deskripsi="Produk UMKM warga Seruni Mumbul, dikelola BUMDes Bina Seruni Mandiri."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Marketplace" }]}
    >
      <Seo title="Marketplace Desa" description="Katalog produk UMKM Desa Seruni Mumbul." path="/marketplace" />
      <SectionWrap>
        <OfflineBadge show={!online} />
        <FilterBar onReset={reset} hasilCount={filtered.length} totalCount={produk.length}>
          <FilterField label="Cari"><TextInput value={q} onChange={setQ} placeholder="Nama produk, penjual…" /></FilterField>
          <FilterField label="Kategori"><SelectInput value={kategori} onChange={setKategori} options={kategoriOpsi.map((k) => ({ value: k, label: k }))} /></FilterField>
          <FilterField label="Harga (Rp)">
            <div className="flex gap-2">
              <TextInput value={minHarga} onChange={setMinHarga} placeholder="Min" type="number" />
              <TextInput value={maxHarga} onChange={setMaxHarga} placeholder="Max" type="number" />
            </div>
          </FilterField>
          <FilterField label="Kurasi">
            <label className="flex items-center gap-2 text-sm py-2">
              <input type="checkbox" checked={onlyFeatured} onChange={(e) => setOnlyFeatured(e.target.checked)} className="accent-[var(--color-primer)]" />
              Hanya produk unggulan
            </label>
          </FilterField>
        </FilterBar>
        {filtered.length === 0 && (
          <p className="text-sm opacity-60">Tidak ada produk yang cocok. Coba longgarkan filter.</p>
        )}
      </SectionWrap>
      {[
        { key: "unggulan", label: "Unggulan", items: featured },
        { key: "terbaru", label: "Terbaru", items: terbaru },
      ].filter((g) => g.items.length > 0).map((grup, gi) => (
        <SectionWrap key={grup.key} alt={gi % 2 === 1}>
          <EditorialTitle sectionKey="produk" kicker="Produk" judul={grup.label} />
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
              {grup.items.map((p) => (
                <article key={p.id} className={`${gi % 2 === 1 ? "bg-[#EAECF0]" : "bg-background"} p-5`}>
                  <Link to={`/produk/${p.id}`} className="block hover:opacity-80 transition-opacity">
                    <div className="aspect-square bg-primary/5 border border-current/10 mb-4 overflow-hidden">
                      {p.foto_url ? <img src={p.foto_url} alt={p.nama} className="w-full h-full object-cover" loading="lazy" /> : null}
                    </div>
                    <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{p.kategori || "Produk"}</div>
                    <div className="mt-1 font-display font-semibold leading-snug">{p.nama}</div>
                    <div className="text-xs opacity-60 truncate mt-1">{p.penjual_nama}</div>
                    {p.deskripsi && <p className="mt-2 text-xs opacity-70 leading-relaxed line-clamp-2">{p.deskripsi}</p>}
                    <div className="mt-3 pt-3 border-t border-current/15 flex items-baseline justify-between gap-2">
                      <span className="font-display font-bold italic text-accent tabular-nums">{fmtIDR(p.harga)}</span>
                      {p.satuan && <span className="text-[10px] opacity-60 uppercase tracking-wider">/ {p.satuan}</span>}
                    </div>
                    {p.stok != null && <div className="mt-1 text-[10px] opacity-60 uppercase tracking-wider">Stok: {p.stok}</div>}
                  </Link>
                </article>
              ))}
            </div>
        </SectionWrap>
      ))}
    </EditorialLayout>
  );
}

export function PetaPage() {
  const { data: wisata } = usePotensiWisata();
  const { data: dusun } = useDusun();
  const online = useOnlineStatus();
  const [q, setQ] = useState("");
  const [jenis, setJenis] = useState("");
  const [layer, setLayer] = useState<Record<string, boolean>>({ wisata: true, dusun: true });
  const jenisOpsi = Array.from(new Set(wisata.map((w) => w.jenis))).filter(Boolean);
  const wisataFiltered = wisata.filter((w) => {
    const kw = q.trim().toLowerCase();
    if (kw && !`${w.nama} ${w.deskripsi || ""}`.toLowerCase().includes(kw)) return false;
    if (jenis && w.jenis !== jenis) return false;
    return true;
  });
  const points = [
    ...(layer.wisata ? wisataFiltered.filter((w) => w.latitude != null && w.longitude != null).map((w) => ({
      id: w.id, nama: w.nama, jenis: `Wisata ${w.jenis}`, deskripsi: w.deskripsi, latitude: w.latitude!, longitude: w.longitude!,
    })) : []),
    ...(layer.dusun ? dusun.filter((d) => d.latitude != null && d.longitude != null).map((d) => ({
      id: d.id || d.nama, nama: `Dusun ${d.nama}`, jenis: "Batas Dusun", deskripsi: `${d.kk} KK · ${d.jiwa} jiwa · ${d.luas_ha} ha`, latitude: Number(d.latitude), longitude: Number(d.longitude),
    })) : []),
  ];
  return (
    <EditorialLayout
      eyebrow="Peta Desa"
      judul="Peta Interaktif Desa"
      deskripsi="Sebaran wilayah, aset, layanan publik, zona rawan bencana, dan destinasi wisata."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Peta" }]}
    >
      <Seo title="Peta Interaktif Desa" description="Layer wilayah, dusun, dan destinasi wisata Desa Seruni Mumbul." path="/peta-desa" />
      <SectionWrap>
        <OfflineBadge show={!online} />
        <FilterBar hasilCount={wisataFiltered.length} totalCount={wisata.length} onReset={() => { setQ(""); setJenis(""); }}>
          <FilterField label="Cari destinasi"><TextInput value={q} onChange={setQ} placeholder="Nama destinasi…" /></FilterField>
          <FilterField label="Jenis"><SelectInput value={jenis} onChange={setJenis} options={jenisOpsi.map((j) => ({ value: j, label: j }))} /></FilterField>
        </FilterBar>
        <div className="grid lg:grid-cols-[280px_1fr] gap-px bg-current/15 border border-current/15">
          <aside className="bg-background p-6">
            <h3 className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4">Layer Peta</h3>
            <ul className="space-y-3">
              <li className="flex items-center gap-3 text-sm">
                <input type="checkbox" checked={layer.wisata} onChange={(e) => setLayer((s) => ({ ...s, wisata: e.target.checked }))} className="accent-[var(--color-primer)]" />
                <span>Destinasi Wisata <span className="opacity-60">({wisataFiltered.length})</span></span>
              </li>
              <li className="flex items-center gap-3 text-sm">
                <input type="checkbox" checked={layer.dusun} onChange={(e) => setLayer((s) => ({ ...s, dusun: e.target.checked }))} className="accent-[var(--color-primer)]" />
                <span>Titik Dusun <span className="opacity-60">({dusun.filter((d) => d.latitude != null).length})</span></span>
              </li>
            </ul>
            <p className="mt-6 pt-4 border-t border-current/15 text-xs opacity-60 leading-relaxed">
              Data bidang tanah warga tidak ditampilkan publik demi privasi (§7.8.1).
            </p>
            <p className="mt-3 text-[10px] opacity-50 leading-relaxed">Peta dasar © OpenStreetMap contributors.</p>
          </aside>
          <div className="relative bg-background">
            <PetaLeaflet points={points} />
          </div>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Utility pages ============================

export function LanggananWaPage() {
  const TOPIK = ["Agenda & Musdes", "Pengumuman Resmi", "Berita Desa", "Info Bencana", "Layanan & PBB"];
  const { data: dusunList } = useDusun();
  const [nama, setNama] = useState("");
  const [nomor, setNomor] = useState("");
  const tenantId = useTenantId();
  const [dusun, setDusun] = useState("");
  const [topik, setTopik] = useState<string[]>(TOPIK);
  const [loading, setLoading] = useState(false);
  const [terkirim, setTerkirim] = useState(false);

  function toggle(t: string) {
    setTopik((cur) => cur.includes(t) ? cur.filter((x) => x !== t) : [...cur, t]);
  }
  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (nama.trim().length < 2) return toast.error("Nama minimal 2 karakter");
    const clean = nomor.replace(/\D/g, "");
    if (clean.length < 8 || clean.length > 20) return toast.error("Nomor WA tidak valid");
    setLoading(true);
    const { error } = await supabase.from("langganan_wa").insert({
      tenant_id: tenantId!,
      nama: nama.trim(),
      nomor_wa: clean,
      dusun: dusun.trim() || null,
      topik,
      status: "aktif",
    });
    setLoading(false);
    if (error) {
      if (error.code === "23505") return toast.error("Nomor sudah terdaftar");
      return toast.error(error.message);
    }
    setTerkirim(true);
    toast.success("Langganan aktif");
  }
  return (
    <EditorialLayout
      eyebrow="Notifikasi"
      judul="Langganan Notifikasi WhatsApp"
      deskripsi="Dapatkan pemberitahuan agenda, pengumuman, dan berita desa langsung ke WhatsApp Anda."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Langganan WA" }]}
    >
      <Seo title="Langganan Notifikasi WhatsApp" description="Daftar untuk menerima notifikasi resmi Desa Seruni Mumbul via WhatsApp." path="/langganan-wa" />
      <SectionWrap>
        {terkirim ? (
          <div className="max-w-lg border-l-2 border-accent pl-6 py-4">
            <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Berhasil</div>
            <div className="mt-2 font-display text-2xl font-semibold italic">Langganan aktif</div>
            <p className="mt-3 text-sm opacity-80">Nomor {nomor} telah terdaftar. Pesan pertama akan dikirim saat ada pengumuman baru.</p>
          </div>
        ) : (
          <form className="max-w-lg border border-current/20 p-6 sm:p-8 grid gap-5" onSubmit={submit}>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nama Lengkap</span>
              <input required value={nama} onChange={(e) => setNama(e.target.value)} maxLength={120} type="text" autoComplete="name" className={inputCls} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor WhatsApp</span>
              <input required value={nomor} onChange={(e) => setNomor(e.target.value)} type="tel" autoComplete="tel" placeholder="08xxxxxxxxxx" className={inputCls} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Dusun (opsional)</span>
              <select value={dusun} onChange={(e) => setDusun(e.target.value)} autoComplete="off" className={inputCls}>
                <option value="">— pilih —</option>
                {dusunList.map((d) => (<option key={d.nama} value={d.nama}>{d.nama}</option>))}
              </select>
            </label>
            <fieldset className="text-sm">
              <legend className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-3">Kategori Notifikasi</legend>
              <div className="grid sm:grid-cols-2 gap-2.5">
                {TOPIK.map((k) => (
                  <label key={k} className="flex items-center gap-2">
                    <input type="checkbox" checked={topik.includes(k)} onChange={() => toggle(k)} className="accent-[var(--color-primer)]" /> <span>{k}</span>
                  </label>
                ))}
              </div>
            </fieldset>
            <button disabled={loading} type="submit" className={`${btnPrimary} justify-self-start disabled:opacity-50`}>{loading ? "Mendaftarkan…" : "Daftar Sekarang"}</button>
          </form>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Keuangan (APBDes) ============================

const fmtRp = (n: number) => "Rp " + n.toLocaleString("id-ID");
const fmtPct = (n: number) => (n * 100).toFixed(1) + "%";

export function KeuanganPage() {
  const years = useApbdesYears();
  const [tahun, setTahun] = useState<number>(new Date().getFullYear());
  const activeYear = years.includes(tahun) ? tahun : years[0] ?? tahun;
  const { data, loading } = useApbdes(activeYear);

  const pendapatan = data.filter((d) => d.jenis === "pendapatan");
  const belanja = data.filter((d) => d.jenis === "belanja");
  const pembiayaan = data.filter((d) => d.jenis === "pembiayaan");

  const sum = (rows: typeof data, key: "anggaran" | "realisasi") =>
    rows.reduce((a, r) => a + Number(r[key] || 0), 0);

  const pendAng = sum(pendapatan, "anggaran");
  const pendReal = sum(pendapatan, "realisasi");
  const belAng = sum(belanja, "anggaran");
  const belReal = sum(belanja, "realisasi");

  // Kelompokkan belanja per kategori (bidang)
  const bidangMap = new Map<string, { anggaran: number; realisasi: number }>();
  belanja.forEach((b) => {
    const cur = bidangMap.get(b.kategori) || { anggaran: 0, realisasi: 0 };
    cur.anggaran += b.anggaran;
    cur.realisasi += b.realisasi;
    bidangMap.set(b.kategori, cur);
  });
  const bidangList = Array.from(bidangMap.entries()).map(([k, v]) => ({ kategori: k, ...v }));

  return (
    <EditorialLayout
      eyebrow="Transparansi"
      judul={`Keuangan Desa — APBDes ${activeYear}`}
      deskripsi="Rincian pendapatan, belanja, dan pembiayaan Desa Seruni Mumbul yang bersumber dari APBDes."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Keuangan" }]}
    >
      <SectionWrap>
        <div className="flex flex-wrap items-center gap-3 mb-6">
          <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Tahun Anggaran</span>
          <div className="flex flex-wrap gap-2">
            {(years.length ? years : [activeYear]).map((y) => (
              <button
                key={y}
                onClick={() => setTahun(y)}
                className={`px-4 py-2 border font-display text-xs font-bold tabular-nums tracking-wider ${
                  y === activeYear ? "border-accent bg-accent text-primary" : "border-current/25 hover:border-accent"
                }`}
              >
                {y}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <p className="text-sm opacity-60">Memuat data anggaran…</p>
        ) : data.length === 0 ? (
          <p className="text-sm opacity-60">Data APBDes tahun {activeYear} belum tersedia.</p>
        ) : (
          <>
            <StatsBand
              tone="dark"
              items={[
                { nilai: fmtRp(pendAng), label: "Pagu Pendapatan", highlight: true },
                { nilai: fmtRp(belAng), label: "Pagu Belanja" },
                { nilai: fmtPct(belAng ? belReal / belAng : 0), label: "Realisasi Belanja" },
                { nilai: fmtPct(pendAng ? pendReal / pendAng : 0), label: "Realisasi Pendapatan" },
              ]}
            />

            <div className="mt-16">
              <EditorialTitle kicker="Pendapatan" judul={`Pendapatan Desa ${activeYear}`} />
              <ApbdesTable rows={pendapatan} totalA={pendAng} totalR={pendReal} />
            </div>

            <div className="mt-16">
              <EditorialTitle sectionKey="belanja-per-bidang-serapan-anggaran-per-bidang" kicker="Belanja per Bidang" judul="Serapan Anggaran per Bidang" />
              <ul className="space-y-6 mt-6">
                {bidangList.map((b) => (
                  <li key={b.kategori}>
                    <EditorialProgress
                      label={b.kategori}
                      value={b.realisasi}
                      max={b.anggaran || 1}
                      suffix={` · ${fmtRp(b.realisasi)} / ${fmtRp(b.anggaran)}`}
                    />
                  </li>
                ))}
              </ul>
            </div>

            <div className="mt-16">
              <EditorialTitle kicker="Belanja" judul={`Rincian Belanja ${activeYear}`} />
              <ApbdesTable rows={belanja} totalA={belAng} totalR={belReal} showKategori />
            </div>

            {pembiayaan.length > 0 && (
              <div className="mt-16">
                <EditorialTitle kicker="Pembiayaan" judul={`Pembiayaan ${activeYear}`} />
                <ApbdesTable rows={pembiayaan} totalA={sum(pembiayaan, "anggaran")} totalR={sum(pembiayaan, "realisasi")} showKategori />
              </div>
            )}

            <p className="mt-10 text-xs opacity-60">
              Sumber: Sistem Informasi Keuangan Desa (Siskeudes). Data diperbarui berkala oleh admin desa.
            </p>
          </>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

function ApbdesTable({
  rows,
  totalA,
  totalR,
  showKategori,
}: {
  rows: { id: string; kategori: string; uraian: string; anggaran: number; realisasi: number; sumber_dana: string | null }[];
  totalA: number;
  totalR: number;
  showKategori?: boolean;
}) {
  return (
    <div className="mt-6 overflow-x-auto border border-current/15">
      <table className="w-full text-sm">
        <thead className="bg-primary text-primary-foreground">
          <tr>
            {showKategori && <th className="text-left px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">Bidang</th>}
            <th className="text-left px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">Uraian</th>
            <th className="text-left px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">Sumber</th>
            <th className="text-right px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">Anggaran</th>
            <th className="text-right px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">Realisasi</th>
            <th className="text-right px-4 py-3 font-display text-[10px] font-bold uppercase tracking-widest">%</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => {
            const pct = r.anggaran ? (r.realisasi / r.anggaran) * 100 : 0;
            return (
              <tr key={r.id} className="border-t border-current/10 align-top">
                {showKategori && <td className="px-4 py-3 text-xs opacity-70">{r.kategori}</td>}
                <td className="px-4 py-3">{r.uraian}</td>
                <td className="px-4 py-3 text-xs opacity-70">{r.sumber_dana || "-"}</td>
                <td className="px-4 py-3 text-right tabular-nums">{fmtRp(r.anggaran)}</td>
                <td className="px-4 py-3 text-right tabular-nums">{fmtRp(r.realisasi)}</td>
                <td className="px-4 py-3 text-right tabular-nums font-display font-bold">{pct.toFixed(0)}%</td>
              </tr>
            );
          })}
          <tr className="border-t-2 border-current/40 bg-current/5">
            {showKategori && <td className="px-4 py-3" />}
            <td className="px-4 py-3 font-display font-bold" colSpan={2}>TOTAL</td>
            <td className="px-4 py-3 text-right tabular-nums font-display font-bold">{fmtRp(totalA)}</td>
            <td className="px-4 py-3 text-right tabular-nums font-display font-bold">{fmtRp(totalR)}</td>
            <td className="px-4 py-3 text-right tabular-nums font-display font-bold">
              {totalA ? Math.round((totalR / totalA) * 100) : 0}%
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

// ============================ Bansos Page ============================

export function BansosPage() {
  const { data: bansos } = useBantuanSosial();
  return (
    <EditorialLayout
      eyebrow="Kesejahteraan"
      judul="Bantuan Sosial"
      deskripsi="Program bantuan sosial yang berjalan di Desa Seruni Mumbul."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Bansos" }]}
    >
      <Seo title="Bantuan Sosial" description="Program bantuan sosial desa." path="/bansos" />
      <SectionWrap>
        {(!bansos || bansos.length === 0) ? (
          <p className="text-muted-foreground py-8 text-center">Belum ada program bantuan sosial.</p>
        ) : (
          <div className="grid gap-px bg-current/15">
            {bansos.map((b) => (
              <Link to={`/bansos/${b.id}`} key={b.id} className="block bg-background p-6 sm:p-8 hover:bg-muted/20 transition-colors">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <p className="font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">{b.kode}</p>
                    <h3 className="mt-1 font-display text-xl font-semibold">{b.nama}</h3>
                    <p className="mt-1 text-sm opacity-75">{b.sumber}</p>
                  </div>
                  <span className={`shrink-0 font-display text-[10px] font-bold uppercase tracking-[0.22em] px-3 py-1 ${b.aktif ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    {b.aktif ? 'Aktif' : 'Tidak Aktif'}
                  </span>
                </div>
                {b.deskripsi && <p className="mt-3 text-sm opacity-75">{b.deskripsi}</p>}
                {b.periode_mulai && (
                  <p className="mt-3 text-xs opacity-60">Periode: {b.periode_mulai} {b.periode_selesai ? `s/d ${b.periode_selesai}` : ''}</p>
                )}
                {b.kuota && <p className="mt-1 text-xs opacity-60">Kuota: {b.kuota} penerima</p>}
              </Link>
            ))}
          </div>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Stunting Page ============================

export function StuntingPage() {
  const { data: stunting } = useStuntingAgregat();
  const { data: posyandu } = usePosyanduAgregat();

  const totalBalita = stunting?.reduce((s, r) => s + r.balita_diukur, 0) ?? 0;
  const totalStunting = stunting?.reduce((s, r) => s + r.stunting, 0) ?? 0;
  const totalWasting = stunting?.reduce((s, r) => s + r.wasting, 0) ?? 0;
  const totalUnderweight = stunting?.reduce((s, r) => s + r.underweight, 0) ?? 0;
  const pct = totalBalita > 0 ? ((totalStunting / totalBalita) * 100).toFixed(1) : '0';

  return (
    <EditorialLayout
      eyebrow="Gizi & Kesehatan"
      judul="Monitoring Stunting & Gizi"
      deskripsi="Data hasil pengukuran balita dan intervensi gizi di posyandu."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Stunting" }]}
    >
      <Seo title="Monitoring Stunting" description="Data balita dan gizi Desa Seruni Mumbul." path="/stunting" />
      <StatsBand
        kicker="Agregat"
        tone="neutral"
        items={[
          { nilai: String(totalBalita), label: "Balita Diukur" },
          { nilai: `${pct}%`, label: "Prevalensi Stunting" },
          { nilai: String(totalStunting), label: "Stunting" },
          { nilai: String(totalWasting), label: "Wasting" },
          { nilai: String(totalUnderweight), label: "Underweight" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="per-burnett-rincian-per-wilayah" kicker="Per Burnett" judul="Rincian per Wilayah" />
        {(!stunting || stunting.length === 0) ? (
          <p className="text-muted-foreground py-8 text-center">Belum ada data pengukuran.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-current/15">
                  <th className="py-3 text-left font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Burnett</th>
                  <th className="py-3 text-right font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Diukur</th>
                  <th className="py-3 text-right font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Stunting</th>
                  <th className="py-3 text-right font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Wasting</th>
                  <th className="py-3 text-right font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Underweight</th>
                  <th className="py-3 text-left font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent">Intervensi</th>
                </tr>
              </thead>
              <tbody>
                {stunting.map((r) => (
                  <tr key={r.id} className="border-b border-current/10 hover:bg-muted/20 transition-colors cursor-pointer">
                    <td className="py-3 font-semibold"><Link to={`/stunting/${r.id}`} className="hover:text-accent">{r.dusun}</Link></td>
                    <td className="py-3 text-right tabular-nums">{r.balita_diukur}</td>
                    <td className="py-3 text-right tabular-nums text-red-600">{r.stunting}</td>
                    <td className="py-3 text-right tabular-nums text-amber-600">{r.wasting}</td>
                    <td className="py-3 text-right tabular-nums text-amber-600">{r.underweight}</td>
                    <td className="py-3 text-xs opacity-75">{r.intervensi ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </SectionWrap>
      {posyandu && posyandu.length > 0 && (
        <SectionWrap alt>
          <EditorialTitle sectionKey="posyandu-cakupan-layanan" kicker="Posyandu" judul="Cakupan Layanan" />
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
            {[
              { label: "Balita", val: posyandu.reduce((s, r) => s + r.jumlah_balita, 0) },
              { label: "Hadir", val: posyandu.reduce((s, r) => s + r.hadir, 0) },
              { label: "Imunisasi Lengkap", val: posyandu.reduce((s, r) => s + r.imunisasi_lengkap, 0) },
              { label: "Gizi Baik", val: posyandu.reduce((s, r) => s + r.gizi_baik, 0) },
              { label: "Ibu Hamil", val: posyandu.reduce((s, r) => s + r.ibu_hamil_dilayani, 0) },
            ].map((m) => (
              <div key={m.label} className="bg-background p-4 text-center border border-current/10">
                <div className="font-display text-3xl font-bold tabular-nums text-accent">{m.val}</div>
                <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-60">{m.label}</div>
              </div>
            ))}
          </div>
        </SectionWrap>
      )}
    </EditorialLayout>
  );
}

// ============================ Bencana Page ============================

export function BencanaPage() {
  const { data: bencana } = useBencanaKejadian();

  const stats = [
    { label: "Total Kejadian", val: bencana?.length ?? 0 },
    { label: "Aktif", val: bencana?.filter(b => b.status === 'diproses').length ?? 0 },
    { label: "Selesai", val: bencana?.filter(b => b.status === 'selesai').length ?? 0 },
    { label: "Korban Jiwa", val: bencana?.reduce((s, b) => s + b.korban_jiwa, 0) ?? 0 },
  ];

  const severityColor: Record<string, string> = {
    rendah: 'bg-green-100 text-green-700',
    Rendah: 'bg-green-100 text-green-700',
    sedang: 'bg-yellow-100 text-yellow-700',
    Sedang: 'bg-yellow-100 text-yellow-700',
    tinggi: 'bg-orange-100 text-orange-700',
    Tinggi: 'bg-orange-100 text-orange-700',
    darurat: 'bg-red-100 text-red-700',
    Darurat: 'bg-red-100 text-red-700',
  };

  return (
    <EditorialLayout
      eyebrow="Kebencanaan"
      judul="Bencana & Mitigasi"
      deskripsi="Riwayat kejadian bencana dan upaya mitigasi di Desa Seruni Mumbul."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Bencana" }]}
    >
      <Seo title="Bencana & Mitigasi" description="Kejadian bencana dan mitigasi desa." path="/bencana" />
      <StatsBand
        kicker="Rekap"
        tone="neutral"
        items={stats.map(s => ({ nilai: String(s.val), label: s.label }))}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="riwayat-kejadian-bencana" kicker="Riwayat" judul="Kejadian Bencana" />
        {(!bencana || bencana.length === 0) ? (
          <p className="text-muted-foreground py-8 text-center">Belum ada data kejadian bencana.</p>
        ) : (
          <div className="grid gap-px bg-current/15">
            {bencana.map((b) => (
              <div key={b.id} className="bg-background p-6">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3">
                      <h3 className="font-display text-lg font-semibold">{b.jenis.charAt(0).toUpperCase() + b.jenis.slice(1)}</h3>
                      <span className={`shrink-0 font-display text-[10px] font-bold uppercase tracking-[0.22em] px-2 py-0.5 ${severityColor[b.severity] ?? 'bg-gray-100 text-gray-600'}`}>
                        {b.severity}
                      </span>
                    </div>
                    <p className="mt-1 text-sm opacity-75">{b.lokasi}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <p className="font-display text-sm opacity-60">{b.tanggal}</p>
                    <p className="font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent mt-1">{b.status}</p>
                  </div>
                </div>
                {b.deskripsi && <p className="mt-3 text-sm opacity-75">{b.deskripsi}</p>}
                {b.penanganan && (
                  <div className="mt-3 pt-3 border-t border-current/10">
                    <p className="font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-60">Penanganan</p>
                    <p className="mt-1 text-sm">{b.penanganan}</p>
                  </div>
                )}
                {(b.korban_jiwa > 0 || b.pengungsi > 0) && (
                  <div className="mt-2 flex gap-4 text-xs opacity-75">
                    {b.korban_jiwa > 0 && <span>Korban jiwa: {b.korban_jiwa}</span>}
                    {b.pengungsi > 0 && <span>Pengungsi: {b.pengungsi}</span>}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Posyandu Detail Page ============================

export function PosyanduPage() {
  const { data: posyandu } = usePosyanduAgregat();
  const { data: stunting } = useStuntingAgregat();

  const totalBalita = posyandu?.reduce((s, r) => s + r.jumlah_balita, 0) ?? 0;
  const totalHadir = posyandu?.reduce((s, r) => s + r.hadir, 0) ?? 0;

  return (
    <EditorialLayout
      eyebrow="Kesehatan"
      judul="Posyandu & Balita"
      deskripsi="Data balita dan kegiatan posyandu di Desa Seruni Mumbul."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Posyandu" }]}
    >
      <Seo title="Posyandu" description="Data balita dan kegiatan posyandu." path="/posyandu" />
      <StatsBand
        kicker="Agregat"
        tone="neutral"
        items={[
          { nilai: String(totalBalita), label: "Balita Terdaftar" },
          { nilai: String(totalHadir), label: "Hadir Bulan Ini" },
          { nilai: String(posyandu?.length ?? 0), label: "Burnett Aktif" },
          { nilai: String(stunting?.length ?? 0), label: "Data Pengukuran" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle sectionKey="cakupan-kehadiran-per-burnett" kicker="Cakupan" judul="Kehadiran per Burnett" />
        {(!posyandu || posyandu.length === 0) ? (
          <p className="text-muted-foreground py-8 text-center">Belum ada data posyandu.</p>
        ) : (
          <div className="space-y-4">
            {posyandu.map((p) => {
              const pct = p.jumlah_balita > 0 ? Math.round((p.hadir / p.jumlah_balita) * 100) : 0;
              return (
                <div key={p.id} className="border border-current/15 p-5 hover:bg-muted/20 transition-colors">
                  <Link to={`/posyandu/${p.id}`} className="block">
                    <div className="flex items-center justify-between mb-3">
                      <h4 className="font-display text-base font-semibold">{p.dusun}</h4>
                      <span className="font-display text-sm opacity-75">{pct}% hadir</span>
                    </div>
                    <div className="w-full bg-current/10 h-2 rounded-full">
                      <div className="bg-accent h-2 rounded-full transition-all" style={{ width: `${pct}%` }} />
                    </div>
                    <div className="mt-3 grid grid-cols-3 sm:grid-cols-6 gap-2 text-xs">
                      <div><span className="opacity-60">Balita:</span> <b>{p.jumlah_balita}</b></div>
                      <div><span className="opacity-60">Hadir:</span> <b>{p.hadir}</b></div>
                      <div><span className="opacity-60">Gizi Baik:</span> <b>{p.gizi_baik}</b></div>
                      <div><span className="opacity-60">Gizi Kurang:</span> <b>{p.gizi_kurang}</b></div>
                      <div><span className="opacity-60">Imunisasi:</span> <b>{p.imunisasi_lengkap}</b></div>
                      <div><span className="opacity-60">Ibu Hamil:</span> <b>{p.ibu_hamil_dilayani}</b></div>
                    </div>
                    {p.catatan && <p className="mt-2 text-xs opacity-60 italic">{p.catatan}</p>}
                  </Link>
                </div>
              );
            })}
          </div>
        )}
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================================================
// Detail page components (minimal, no EditorialLayout wrapper)
// ============================================================

function LoadingState() {
  return <div className="min-h-screen flex items-center justify-center"><p className="opacity-60">Memuat…</p></div>;
}
function NotFoundState() {
  return <div className="min-h-screen flex items-center justify-center"><p className="opacity-60">Data tidak ditemukan</p></div>;
}

export function AgendaDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useAgendaById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const imageUrl = data.foto_url || null;
  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/kalender-desa" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Agenda
        </Link>

        {/* Hero image */}
        {imageUrl && (
          <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm mb-8">
            {}
            <img src={imageUrl} alt={data.judul} className="w-full aspect-video object-cover" />
          </div>
        )}

        {/* Header zone */}
        <div className="space-y-3">
          <div className="flex items-center gap-3 flex-wrap">
            {data.jenis && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                {data.jenis}
              </span>
            )}
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.judul}
          </h1>
        </div>

        {/* Meta info row */}
        <div className="mt-5 flex flex-wrap gap-y-2 gap-x-6 text-sm text-foreground/60">
          {data.tanggal && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd" /></svg>
              <span>{formatTanggal(data.tanggal)}</span>
            </div>
          )}
          {data.waktu && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm.75-13a.75.75 0 00-1.5 0v5c0 .414.336.75.75.75h4a.75.75 0 000-1.5h-3.25V5z" clipRule="evenodd" /></svg>
              <span>{data.waktu}</span>
            </div>
          )}
          {data.lokasi && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
              <span>{data.lokasi}</span>
            </div>
          )}
          {data.penyelenggara && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" /></svg>
              <span>{data.penyelenggara}</span>
            </div>
          )}
        </div>

        {/* Divider */}
        <div className="mt-8 border-t border-current/15" />

        {/* Description */}
        {data.deskripsi && (
          <div className="mt-8">
            <h2 className="font-display text-sm font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Deskripsi</h2>
            <div className="prose prose-sm max-w-none text-foreground/80 leading-relaxed">
              <p>{data.deskripsi}</p>
            </div>
          </div>
        )}

        {/* Location link */}
        {data.lokasi && (
          <div className="mt-8">
            <a
              href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(data.lokasi + " Seruni Mumbul Lombok Timur")}`}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg border border-current/20 text-sm font-medium hover:bg-accent/5 transition-colors text-foreground/70 hover:text-foreground"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
              Lihat di Peta
            </a>
          </div>
        )}
      </main>
    </div>
  );
}

export function GaleriDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useGaleriById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const imageUrl = data.foto_url || null;
  const videoUrl = data.video_url || null;

  // Extract YouTube video ID for embed
  const getYouTubeId = (url: string) => {
    const match = url.match(/(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/);
    return match ? match[1] : null;
  };
  const youtubeId = videoUrl ? getYouTubeId(videoUrl) : null;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/galeri" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Galeri
        </Link>

        {/* Hero image */}
        {imageUrl && (
          <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm mb-6">
            {}
            <img src={imageUrl} alt={data.judul} className="w-full aspect-video object-cover" />
          </div>
        )}

        {/* Video embed */}
        {youtubeId && (
          <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm mb-6">
            <div className="relative aspect-video">
              <iframe
                src={`https://www.youtube.com/embed/${youtubeId}`}
                title={data.judul}
                className="absolute inset-0 w-full h-full"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            </div>
          </div>
        )}

        {/* Header */}
        <div className="space-y-2">
          {data.album && (
            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
              {data.album}
            </span>
          )}
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.judul}
          </h1>
          <p className="text-sm text-foreground/50">
            {(data as Galeri).tanggal ? formatTanggal((data as Galeri).tanggal) : ""}
          </p>
        </div>

        {/* Photo metadata */}
        {((data as Galeri).fotografer || (data as Galeri).sumber || (data as Galeri).deskripsi) && (
          <>
            <div className="mt-8 border-t border-current/15" />
            <div className="mt-6 grid sm:grid-cols-2 gap-4 text-sm">
              {(data as Galeri).fotografer && (
                <div className="flex items-center gap-2 text-foreground/60">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" /></svg>
                  <span>Fotografer: <b className="text-foreground">{(data as Galeri).fotografer}</b></span>
                </div>
              )}
              {(data as Galeri).sumber && (
                <div className="flex items-center gap-2 text-foreground/60">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z" /></svg>
                  <span>Sumber: <b className="text-foreground">{(data as Galeri).sumber}</b></span>
                </div>
              )}
            </div>
            {data.deskripsi && (
              <p className="mt-4 text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
            )}
          </>
        )}
      </main>
    </div>
  );
}

export function PengumumanDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = usePengumumanById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/pengumuman" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Pengumuman
        </Link>

        {/* Document card */}
        <div className="border border-current/20 rounded-xl overflow-hidden shadow-sm bg-background mt-2">
          {/* Document header */}
          <div className="bg-accent/5 border-b border-current/15 px-6 sm:px-10 py-8 text-center">
            {/* Coat of arms placeholder */}
            <div className="mx-auto w-12 h-12 rounded-full border-2 border-current/20 flex items-center justify-center mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-6 h-6 text-foreground/30"><path fillRule="evenodd" d="M3 6a3 3 0 013-3h2.25a3 3 0 013 3v2.25a3 3 0 01-3 3H6a3 3 0 01-3-3V6zM3.75 15.75A1.5 1.5 0 015.25 14.25h13.5a1.5 1.5 0 011.5 1.5v3a1.5 1.5 0 01-1.5 1.5H5.25a1.5 1.5 0 01-1.5-1.5v-3zM9 11.25a1.5 1.5 0 103 0 1.5 1.5 0 00-3 0z" clipRule="evenodd" /></svg>
            </div>
            <p className="font-display text-[10px] font-bold uppercase tracking-[0.22em] text-accent mb-1">Pengumuman Resmi Desa</p>
            <p className="text-xs text-foreground/50 font-mono">{data.nomor || "Tanpa Nomor"}</p>
            <p className="text-xs text-foreground/40 mt-1">{data.tanggal ? formatTanggal(data.tanggal) : ""}</p>
          </div>

          {/* Document body */}
          <div className="px-6 sm:px-10 py-8">
            <h1 className="font-display text-xl sm:text-2xl lg:text-3xl font-semibold leading-snug text-center text-foreground mb-8">
              {data.judul}
            </h1>
            {data.ringkasan && (
              <div className="text-sm leading-[1.9] text-foreground/80 space-y-4">
                {data.ringkasan.split('\n').map((para, i) => para.trim() ? (
                  <p key={i}>{para}</p>
                ) : <div key={i} className="h-2" />)}
              </div>
            )}
            {(data as any).lampiran_url && (
              <div className="mt-8 pt-6 border-t border-current/15">
                <p className="text-xs font-semibold text-foreground/50 uppercase tracking-wider mb-3">Lampiran</p>
                {}
                <img src={(data as any).lampiran_url} alt="Lampiran pengumuman" className="max-w-full rounded border border-current/15 max-h-96" />
              </div>
            )}
          </div>

          {/* Document footer */}
          <div className="px-6 sm:px-10 py-4 bg-accent/3 border-t border-current/10 text-center">
            <p className="text-[10px] text-foreground/40 uppercase tracking-widest">Kantor Desa Seruni Mumbul</p>
          </div>
        </div>
      </main>
    </div>
  );
}

export function PosyanduDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = usePosyanduById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;

  const totalBalita = data.jumlah_balita || 0;
  const hadir = data.hadir || 0;
  const hadirPct = totalBalita > 0 ? Math.round((hadir / totalBalita) * 100) : 0;

  // Color helper for nutrition status
  const nutritionColor = (field: string, value: number | null | undefined) => {
    if (value == null) return "text-foreground";
    if (field === "gizi_baik") return value >= 80 ? "text-green-600" : value >= 60 ? "text-amber-500" : "text-red-500";
    if (field === "gizi_kurang" || field === "gizi_buruk") return value === 0 ? "text-green-600" : value <= 5 ? "text-amber-500" : "text-red-500";
    return "text-foreground";
  };

  const metrics = [
    { label: "Jumlah Balita", value: data.jumlah_balita, icon: "👶", color: "bg-accent/10 text-accent" },
    { label: "Hadir", value: data.hadir, icon: "✓", color: "bg-green-100 text-green-700", pct: hadirPct },
    { label: "Gizi Baik", value: data.gizi_baik, icon: "✅", color: "bg-green-100 text-green-700" },
    { label: "Gizi Kurang", value: data.gizi_kurang, icon: "⚠", color: "bg-amber-100 text-amber-700" },
    { label: "Gizi Buruk", value: data.gizi_buruk ?? 0, icon: "❌", color: "bg-red-100 text-red-700" },
    { label: "Imunisasi Lengkap", value: data.imunisasi_lengkap, icon: "💉", color: "bg-blue-100 text-blue-700" },
    { label: "Ibu Hamil Dilayani", value: data.ibu_hamil_dilayani, icon: "🤰", color: "bg-purple-100 text-purple-700" },
  ];

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/posyandu" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Posyandu
        </Link>

        {/* Header */}
        <div className="space-y-1 mb-8">
          <div className="flex items-center gap-2">
            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
              Posyandu
            </span>
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.dusun}
          </h1>
          <p className="text-sm text-foreground/50">
            {data.periode ? `Periode: ${formatTanggal(data.periode)}` : "—"}
          </p>
        </div>

        {/* Metrics grid */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          {metrics.map((m) => (
            <div key={m.label} className="bg-background border border-current/15 rounded-xl p-4 flex flex-col gap-2 shadow-sm">
              <div className="flex items-center justify-between">
                <span className={`inline-flex items-center justify-center w-7 h-7 rounded-lg text-xs font-bold ${m.color}`}>
                  {m.icon}
                </span>
                {m.pct != null && (
                  <span className="text-[10px] font-semibold text-foreground/40">{m.pct}%</span>
                )}
              </div>
              <p className={`font-display text-2xl font-bold ${m.value != null && m.value > 0 ? m.color : "text-foreground/40"}`}>
                {m.value ?? "—"}
              </p>
              <p className="text-xs text-foreground/50 leading-tight">{m.label}</p>
              {/* Progress bar for Hadir */}
              {m.pct != null && (
                <div className="w-full bg-current/10 h-1.5 rounded-full mt-1">
                  <div className="bg-green-500 h-1.5 rounded-full transition-all" style={{ width: `${m.pct}%` }} />
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Nutrition summary bar */}
        {totalBalita > 0 && (
          <div className="mt-6 bg-background border border-current/15 rounded-xl p-5 shadow-sm">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Ringkasan Gizi</h3>
            <div className="flex gap-1 h-6 rounded-full overflow-hidden">
              {data.gizi_baik != null && totalBalita > 0 && (
                <div
                  className="bg-green-500 h-full transition-all rounded-l-full"
                  style={{ width: `${Math.round((data.gizi_baik / totalBalita) * 100)}%` }}
                  title={`Gizi Baik: ${data.gizi_baik}`}
                />
              )}
              {data.gizi_kurang != null && totalBalita > 0 && (
                <div
                  className="bg-amber-500 h-full transition-all"
                  style={{ width: `${Math.round((data.gizi_kurang / totalBalita) * 100)}%` }}
                  title={`Gizi Kurang: ${data.gizi_kurang}`}
                />
              )}
              {data.gizi_buruk != null && totalBalita > 0 && (
                <div
                  className="bg-red-500 h-full transition-all rounded-r-full"
                  style={{ width: `${Math.round((data.gizi_buruk / totalBalita) * 100)}%` }}
                  title={`Gizi Buruk: ${data.gizi_buruk}`}
                />
              )}
            </div>
            <div className="flex gap-4 mt-3 text-xs text-foreground/60">
              <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-green-500 inline-block" /> Gizi Baik {data.gizi_baik ?? 0}</span>
              <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-amber-500 inline-block" /> Gizi Kurang {data.gizi_kurang ?? 0}</span>
              <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-red-500 inline-block" /> Gizi Buruk {data.gizi_buruk ?? 0}</span>
            </div>
          </div>
        )}

        {/* Notes */}
        {data.catatan && (
          <div className="mt-6 bg-accent/5 border border-accent/20 rounded-xl p-5">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-accent mb-2">Catatan</h3>
            <p className="text-sm text-foreground/70 leading-relaxed italic">{data.catatan}</p>
          </div>
        )}
      </main>
    </div>
  );
}

export function StuntingDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useStuntingById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;

  const totalDiukur = data.balita_diukur || 0;

  // Severity coloring
  const severityClass = (value: number | null | undefined, label: string) => {
    if (value == null || totalDiukur === 0) return "bg-foreground/5 text-foreground/50";
    const pct = (value / totalDiukur) * 100;
    if (label === "Stunting" || label === "Wasting" || label === "Underweight") {
      if (pct === 0) return "bg-green-100 text-green-700";
      if (pct <= 10) return "bg-amber-100 text-amber-700";
      return "bg-red-100 text-red-700";
    }
    return "bg-foreground/5 text-foreground/50";
  };

  const metrics = [
    { label: "Balita Diukur", value: data.balita_diukur, icon: "👶", color: "bg-accent/10 text-accent" },
    { label: "Stunting", value: data.stunting, icon: "📏", color: "bg-red-100 text-red-700" },
    { label: "Wasting", value: data.wasting, icon: "⚖", color: "bg-amber-100 text-amber-700" },
    { label: "Underweight", value: data.underweight, icon: "📉", color: "bg-orange-100 text-orange-700" },
  ];

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/stunting" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Data Stunting
        </Link>

        {/* Header */}
        <div className="space-y-1 mb-8">
          <div className="flex items-center gap-2">
            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-red-100 text-red-700">
              Stunting
            </span>
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.dusun}
          </h1>
          <p className="text-sm text-foreground/50">
            {data.periode ? `Periode: ${formatTanggal(data.periode)}` : "—"}
          </p>
        </div>

        {/* Metrics grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          {metrics.map((m) => {
            const pct = totalDiukur > 0 && m.value != null ? Math.round((m.value / totalDiukur) * 100) : null;
            return (
              <div key={m.label} className="bg-background border border-current/15 rounded-xl p-4 flex flex-col gap-2 shadow-sm">
                <div className="flex items-center justify-between">
                  <span className={`inline-flex items-center justify-center w-7 h-7 rounded-lg text-xs font-bold ${m.color}`}>
                    {m.icon}
                  </span>
                  {pct != null && m.label !== "Balita Diukur" && (
                    <span className="text-[10px] font-semibold text-foreground/40">{pct}%</span>
                  )}
                </div>
                <p className={`font-display text-2xl font-bold ${severityClass(m.value, m.label)}`}>
                  {m.value ?? "—"}
                </p>
                <p className="text-xs text-foreground/50 leading-tight">{m.label}</p>
                {/* Progress bar */}
                {pct != null && m.label !== "Balita Diukur" && (
                  <div className="w-full bg-current/10 h-1.5 rounded-full mt-1">
                    <div className={`h-1.5 rounded-full transition-all ${m.label === "Stunting" ? "bg-red-500" : m.label === "Wasting" ? "bg-amber-500" : "bg-orange-500"}`} style={{ width: `${Math.min(pct, 100)}%` }} />
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Severity legend */}
        {totalDiukur > 0 && (
          <div className="mt-6 bg-background border border-current/15 rounded-xl p-5 shadow-sm">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Persentase Terhadap Total Diukur</h3>
            <div className="space-y-3">
              {[
                { label: "Stunting", value: data.stunting, color: "bg-red-500" },
                { label: "Wasting", value: data.wasting, color: "bg-amber-500" },
                { label: "Underweight", value: data.underweight, color: "bg-orange-500" },
              ].map((item) => {
                const pct = totalDiukur > 0 && item.value != null ? Math.round((item.value / totalDiukur) * 100) : 0;
                return (
                  <div key={item.label}>
                    <div className="flex justify-between text-xs text-foreground/60 mb-1">
                      <span>{item.label}</span>
                      <span>{pct}% ({item.value ?? 0} dari {totalDiukur})</span>
                    </div>
                    <div className="w-full bg-current/10 h-2 rounded-full">
                      <div className={`${item.color} h-2 rounded-full transition-all`} style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Intervensi */}
        {data.intervensi && (
          <div className="mt-6 bg-red-50 border border-red-200 rounded-xl p-5">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-red-700 mb-2">Intervensi</h3>
            <p className="text-sm text-foreground/80 leading-relaxed">{data.intervensi}</p>
          </div>
        )}
      </main>
    </div>
  );
}

export function UmkmDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useUmkmById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;

  // WhatsApp link if kontak exists
  const waLink = data.kontak
    ? `https://wa.me/${data.kontak.replace(/\D/g, "")}`
    : null;

  // Map link for address
  const mapLink = data.alamat
    ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent((data.alamat || "") + " Seruni Mumbul Lombok Timur")}`
    : null;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/potensi-desa" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Potensi Desa
        </Link>

        {/* Profile card */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm mt-2">
          {/* Card header with type badge */}
          <div className="px-6 pt-6 pb-4 border-b border-current/10">
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-2">
                {data.tipe && (
                  <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                    {data.tipe}
                  </span>
                )}
                <h1 className="font-display text-2xl sm:text-3xl font-semibold leading-tight text-foreground">
                  {data.nama}
                </h1>
              </div>
              {/* Owner avatar placeholder */}
              <div className="w-14 h-14 rounded-full bg-accent/10 border-2 border-accent/20 flex items-center justify-center flex-shrink-0">
                {data.pemilik ? (
                  <span className="text-lg font-bold text-accent">{data.pemilik[0].toUpperCase()}</span>
                ) : (
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-6 h-6 text-foreground/30"><path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" /></svg>
                )}
              </div>
            </div>
          </div>

          {/* Info grid */}
          <div className="px-6 py-5 grid sm:grid-cols-2 gap-4">
            {data.pemilik && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Pemilik</p>
                  <p className="text-sm font-medium text-foreground">{data.pemilik}</p>
                </div>
              </div>
            )}
            {data.sektor && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Sektor</p>
                  <p className="text-sm font-medium text-foreground">{data.sektor}</p>
                </div>
              </div>
            )}
            {data.dusun && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Dusun</p>
                  <p className="text-sm font-medium text-foreground">{data.dusun}</p>
                </div>
              </div>
            )}
            {data.kontak && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Kontak</p>
                  <p className="text-sm font-medium text-foreground">{data.kontak}</p>
                </div>
              </div>
            )}
          </div>

          {/* Address */}
          {(data as PotensiUmkm).alamat && (
            <div className="px-6 pb-5">
              <div className="bg-foreground/5 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40 flex-shrink-0 mt-0.5"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
                  <div>
                    <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Alamat</p>
                    <p className="text-sm text-foreground/80">{data.alamat}</p>
                    {mapLink && (
                      <a href={mapLink} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 text-xs text-accent hover:underline mt-2">
                        Lihat di Peta
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="none" className="w-3 h-3"><path d="M3 1h6m0 0v6M9 1l-8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
                      </a>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Description */}
          {data.deskripsi && (
            <div className="px-6 pb-6">
              <div className="border-t border-current/15 pt-5">
                <p className="text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
              </div>
            </div>
          )}

          {/* Action */}
          {waLink && (
            <div className="px-6 pb-6">
              <a
                href={waLink}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center gap-2 w-full sm:w-auto px-6 py-3 rounded-xl bg-green-500 hover:bg-green-600 text-white font-semibold text-sm transition-colors shadow-sm"
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                Hubungi via WhatsApp
              </a>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export function ProdukDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useProdukById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const imageUrl = data.foto_url || null;
  const harga = data.harga != null ? new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", minimumFractionDigits: 0 }).format(data.harga) : null;
  const waLink = (data as any).kontak_penjual
    ? `https://wa.me/${(data as any).kontak_penjual.replace(/\D/g, "")}?text=${encodeURIComponent(`Halo, saya tertarik dengan produk: ${data.nama}`)}`
    : null;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/marketplace" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Marketplace
        </Link>

        {/* Product layout: image left, info right (mobile: stacked) */}
        <div className="grid sm:grid-cols-2 gap-8 mt-2">
          {/* Image column */}
          <div className="space-y-3">
            {imageUrl ? (
              <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm bg-foreground/5">
                {}
                <img src={imageUrl} alt={data.nama} className="w-full aspect-square object-cover" />
              </div>
            ) : (
              <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm bg-foreground/5 flex items-center justify-center aspect-square">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-16 h-16 text-foreground/20"><path fillRule="evenodd" d="M3 3.5A1.5 1.5 0 014.5 2h15A1.5 1.5 0 0121 3.5v16.5a1.5 1.5 0 01-1.5 1.5H4.5A1.5 1.5 0 013 20V3.5zM12 7a3 3 0 100 6 3 3 0 000-6z" clipRule="evenodd" /></svg>
              </div>
            )}
            {/* Seller card */}
            {data.penjual_nama && (
              <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
                <div className="w-9 h-9 rounded-full bg-accent/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-xs font-bold text-accent">{data.penjual_nama[0].toUpperCase()}</span>
                </div>
                <div className="min-w-0">
                  <p className="text-xs font-semibold text-foreground truncate">{data.penjual_nama}</p>
                  <p className="text-[10px] text-foreground/40">Penjual</p>
                </div>
              </div>
            )}
          </div>

          {/* Info column */}
          <div className="space-y-5">
            {/* Category badge */}
            {data.kategori && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                {data.kategori}
              </span>
            )}

            {/* Product name */}
            <h1 className="font-display text-2xl sm:text-3xl font-semibold leading-tight text-foreground">
              {data.nama}
            </h1>

            {/* Price */}
            {harga && (
              <div className="bg-accent/5 border border-accent/15 rounded-xl p-4">
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Harga</p>
                <p className="font-display text-2xl sm:text-3xl font-bold text-accent">
                  {harga}
                </p>
              </div>
            )}

            {/* Info chips */}
            <div className="grid grid-cols-2 gap-2">
              {data.satuan && (
                <div className="bg-foreground/5 rounded-lg px-3 py-2.5">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Satuan</p>
                  <p className="text-sm font-medium text-foreground mt-0.5">{data.satuan}</p>
                </div>
              )}
              {data.stok != null && (
                <div className="bg-foreground/5 rounded-lg px-3 py-2.5">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Stok</p>
                  <p className={`text-sm font-medium mt-0.5 ${data.stok > 0 ? "text-green-600" : "text-red-500"}`}>
                    {data.stok > 0 ? `${data.stok} unit` : "Habis"}
                  </p>
                </div>
              )}
            </div>

            {/* Description */}
            {data.deskripsi && (
              <div className="border-t border-current/15 pt-5">
                <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-2">Deskripsi</h3>
                <p className="text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
              </div>
            )}

            {/* Order action */}
            {waLink && data.stok !== 0 && (
              <div className="pt-2">
                <a
                  href={waLink}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center justify-center gap-2 w-full px-6 py-3.5 rounded-xl bg-green-500 hover:bg-green-600 text-white font-semibold text-sm transition-colors shadow-sm"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                  Pesan via WhatsApp
                </a>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

export function WisataDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useWisataById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const hasCoords = data.latitude != null && data.longitude != null;

  // Parse fasilitas as comma-separated string or array
  const fasilitasList = data.fasilitas
    ? (Array.isArray(data.fasilitas) ? data.fasilitas : data.fasilitas.split(',').map((s: string) => s.trim()).filter(Boolean))
    : [];

  // Map link
  const mapLink = hasCoords
    ? `https://www.google.com/maps?q=${data.latitude},${data.longitude}`
    : (data as PotensiWisata).alamat
    ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(((data as PotensiWisata).alamat || "") + " Seruni Mumbul Lombok Timur")}`
    : null;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/potensi-desa" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Potensi Desa
        </Link>

        {/* Hero image */}
        {(data as any).foto_url && (
          <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm mb-8">
            {}
            <img src={data.foto_url} alt={data.nama} className="w-full aspect-video object-cover" />
          </div>
        )}

        {/* Header */}
        <div className="space-y-3">
          <div className="flex items-center gap-3 flex-wrap">
            {data.jenis && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                {data.jenis}
              </span>
            )}
            {(data as any).verified && (
              <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-[10px] font-semibold bg-green-100 text-green-700">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="currentColor" className="w-3 h-3"><path fillRule="evenodd" d="M9.965 3.035a.75.75 0 010 1.06L7.052 6.81l2.913 2.914a.75.75 0 11-1.06 1.06L6 7.87 4.035 9.836a.75.75 0 01-1.06-1.06l2.913-2.914L3.075 4.095a.75.75 0 111.06-1.06l2.913 2.914 2.914-2.913a.75.75 0 01.003 0z" clipRule="evenodd" /></svg>
                Terverifikasi
              </span>
            )}
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.nama}
          </h1>
        </div>

        {/* Info chips row */}
        <div className="mt-5 flex flex-wrap gap-y-2 gap-x-6 text-sm text-foreground/60">
          {data.dusun && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
              <span>{data.dusun}</span>
            </div>
          )}
          {hasCoords && (
            <div className="flex items-center gap-1.5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 flex-shrink-0"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
              <span>{data.latitude}, {data.longitude}</span>
            </div>
          )}
        </div>

        {/* Facilities */}
        {fasilitasList.length > 0 && (
          <div className="mt-6">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Fasilitas</h3>
            <div className="flex flex-wrap gap-2">
              {fasilitasList.map((f: string, i: number) => (
                <span key={i} className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-foreground/5 border border-current/15 text-xs font-medium text-foreground/70">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="none" className="w-3 h-3"><path d="M10 3.5v5L6 10.5 2 8.5V3.5l4 2.5V4.5L3 2.5 6 1l3 1.5-3 1.5v1.5L10 3.5z" fill="currentColor"/></svg>
                  {f}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Description */}
        {data.deskripsi && (
          <>
            <div className="mt-8 border-t border-current/15" />
            <div className="mt-6">
              <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Deskripsi</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
            </div>
          </>
        )}

        {/* Map embed */}
        {hasCoords && (
          <div className="mt-8">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Lokasi</h3>
            <div className="rounded-xl overflow-hidden border border-current/15 h-64">
              <iframe
                title={`Lokasi ${data.nama}`}
                src={`https://www.openstreetmap.org/export/embed.html?bbox=${Number(data.longitude) - 0.01},${Number(data.latitude) - 0.01},${Number(data.longitude) + 0.01},${Number(data.latitude) + 0.01}&layer=mapnik&marker=${data.latitude},${data.longitude}`}
                className="w-full h-full border-0"
              />
            </div>
            {mapLink && (
              <a
                href={mapLink}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 mt-3 text-sm text-accent hover:underline"
              >
                Buka di Google Maps
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="none" className="w-3 h-3"><path d="M3 1h6m0 0v6M9 1l-8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </a>
            )}
          </div>
        )}
      </main>
    </div>
  );
}

export function PembangunanDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = usePembangunanById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const progress = data.progress_persen ?? 0;
  const title = data.nama_kegiatan || data.judul || "Kegiatan Pembangunan";

  const anggaranFmt = data.anggaran != null
    ? new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", minimumFractionDigits: 0 }).format(data.anggaran)
    : null;

  // Status badge color
  const statusColor = (status: string) => {
    switch (status?.toLowerCase()) {
      case "selesai": return "bg-green-100 text-green-700";
      case "sedang berjalan": return "bg-blue-100 text-blue-700";
      case "gagal": return "bg-red-100 text-red-700";
      default: return "bg-foreground/10 text-foreground/70";
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/pembangunan" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Pembangunan
        </Link>

        {/* Header */}
        <div className="space-y-3">
          <div className="flex items-center gap-2 flex-wrap">
            {data.bidang && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                {data.bidang}
              </span>
            )}
            {data.status && (
              <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] ${statusColor(data.status)}`}>
                {data.status}
              </span>
            )}
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {title}
          </h1>
        </div>

        {/* Financial card */}
        {anggaranFmt && (
          <div className="mt-6 bg-accent/5 border border-accent/15 rounded-xl p-5 shadow-sm">
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Anggaran</p>
                <p className="font-display text-2xl sm:text-3xl font-bold text-accent">
                  {anggaranFmt}
                </p>
              </div>
              {(data as PembangunanDetail).sumber_dana && (
                <div className="text-right">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Sumber Dana</p>
                  <p className="text-sm font-medium text-foreground">{(data as PembangunanDetail).sumber_dana}</p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Progress card */}
        <div className="mt-4 bg-background border border-current/15 rounded-xl p-5 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/50">Progress</span>
            <span className={`text-xs font-bold ${progress === 100 ? "text-green-600" : progress > 50 ? "text-blue-600" : "text-amber-600"}`}>
              {progress}%
            </span>
          </div>
          <div className="w-full bg-current/10 h-3 rounded-full overflow-hidden">
            <div
              className={`h-3 rounded-full transition-all ${progress === 100 ? "bg-green-500" : progress > 50 ? "bg-blue-500" : "bg-amber-500"}`}
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Info grid */}
        <div className="mt-6 grid sm:grid-cols-2 gap-3">
          {data.tahun && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Tahun</p>
                <p className="text-sm font-medium text-foreground">{data.tahun}</p>
              </div>
            </div>
          )}
          {data.lokasi && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Lokasi</p>
                <p className="text-sm font-medium text-foreground">{data.lokasi}</p>
              </div>
            </div>
          )}
          {data.volume && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M4 4a2 2 0 011-1.617l7-3.5a2 2 0 011.765 0l7 3.5A2 2 0 0122 4v12a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 0v12h12V4H6z" clipRule="evenodd" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Volume</p>
                <p className="text-sm font-medium text-foreground">{data.volume}</p>
              </div>
            </div>
          )}
          {((data as PembangunanDetail).tanggal_mulai || (data as PembangunanDetail).tanggal_selesai) && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm.75-13a.75.75 0 00-1.5 0v5c0 .414.336.75.75.75h4a.75.75 0 000-1.5h-3.25V5z" clipRule="evenodd" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Durasi</p>
                <p className="text-sm font-medium text-foreground">
                  {(data as PembangunanDetail).tanggal_mulai ? formatTanggal((data as PembangunanDetail).tanggal_mulai) : "—"}
                  {(data as PembangunanDetail).tanggal_selesai ? ` — ${formatTanggal((data as PembangunanDetail).tanggal_selesai)}` : ""}
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Documentation images */}
        {(data as PembangunanDetail).foto_url && (
          <div className="mt-6">
            <div className="border-t border-current/15 pt-6">
              <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Dokumentasi</h3>
              <div className="rounded-xl overflow-hidden border border-current/15 shadow-sm">
                {}
                <img src={(data as PembangunanDetail).foto_url} alt={`Dokumentasi ${title}`} className="w-full aspect-video object-cover" />
              </div>
            </div>
          </div>
        )}

        {/* Description */}
        {data.keterangan && (
          <div className="mt-6 border-t border-current/15 pt-6">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Keterangan</h3>
            <p className="text-sm text-foreground/70 leading-relaxed">{data.keterangan}</p>
          </div>
        )}
      </main>
    </div>
  );
}

export function BansosDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useBansosById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const isActive = data.aktif === true || data.aktif === 1;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/bansos" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Bantuan Sosial
        </Link>

        {/* Program card */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm mt-2">
          {/* Card header */}
          <div className="px-6 pt-6 pb-4 border-b border-current/10">
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-2">
                {data.kode && (
                  <p className="text-[10px] font-mono font-semibold text-foreground/40 uppercase tracking-wider">{data.kode}</p>
                )}
                <h1 className="font-display text-xl sm:text-2xl lg:text-3xl font-semibold leading-snug text-foreground">
                  {data.nama}
                </h1>
              </div>
              <span className={`flex-shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${isActive ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}>
                <span className={`w-2 h-2 rounded-full ${isActive ? "bg-green-500" : "bg-red-500"}`} />
                {isActive ? "Aktif" : "Tidak Aktif"}
              </span>
            </div>
          </div>

          {/* Info grid */}
          <div className="px-6 py-5 grid sm:grid-cols-2 gap-4">
            {(data as BantuanSosial).sumber && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Sumber</p>
                  <p className="text-sm font-medium text-foreground">{(data as BantuanSosial).sumber}</p>
                </div>
              </div>
            )}
            {data.kuota != null && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Kuota</p>
                  <p className="text-sm font-medium text-foreground">{data.kuota} orang</p>
                </div>
              </div>
            )}
          </div>

          {/* Period */}
          {(data.periode_mulai || data.periode_selesai) && (
            <div className="px-6 pb-5">
              <div className="bg-foreground/5 rounded-lg p-4">
                <div className="flex items-center gap-3">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40 flex-shrink-0"><path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd" /></svg>
                  <div>
                    <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Periode</p>
                    <p className="text-sm text-foreground/80">
                      {data.periode_mulai ? formatTanggal(data.periode_mulai) : "—"}
                      {data.periode_selesai ? ` — ${formatTanggal(data.periode_selesai)}` : " — selesai"}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Description */}
          {data.deskripsi && (
            <div className="px-6 pb-6">
              <div className="border-t border-current/15 pt-5">
                <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Deskripsi Program</h3>
                <p className="text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
              </div>
            </div>
          )}

          {/* How to apply */}
          <div className="px-6 pb-6">
            <div className="bg-accent/5 border border-accent/15 rounded-xl p-5">
              <div className="flex items-center gap-2 mb-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-accent"><path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z" clipRule="evenodd" /></svg>
                <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-accent">Cara Mendaftar</h3>
              </div>
              <p className="text-sm text-foreground/60 leading-relaxed">
                Hubungi kantor desa untuk informasi dan pendaftaran program {data.nama}. Kuota terbatas, pastikan memenuhi syarat yang berlaku.
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

const ADUAN_STATUS_LABELS: Record<string, string> = {
  draft: "Draft",
  diajukan: "Diajukan",
  diverifikasi: "Diverifikasi",
  diproses: "Diproses",
  selesai: "Selesai",
  ditolak: "Ditolak",
  dibatalkan: "Dibatalkan",
};

export function AduanDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useAduanById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;
  const maskedNama = data.nama_pelapor ? `${data.nama_pelapor[0]}${"*".repeat(Math.max(0, data.nama_pelapor.length - 1))}` : null;
  const maskedKontak = data.kontak ? data.kontak.replace(/.(?=.{4})/g, "*") : null;

  // Status badge color
  const statusConfig: Record<string, { bg: string; text: string; dot: string }> = {
    selesai: { bg: "bg-green-100", text: "text-green-700", dot: "bg-green-500" },
    ditolak: { bg: "bg-red-100", text: "text-red-700", dot: "bg-red-500" },
    diproses: { bg: "bg-blue-100", text: "text-blue-700", dot: "bg-blue-500" },
    diverifikasi: { bg: "bg-purple-100", text: "text-purple-700", dot: "bg-purple-500" },
    diajukan: { bg: "bg-yellow-100", text: "text-yellow-700", dot: "bg-yellow-500" },
    draft: { bg: "bg-gray-100", text: "text-gray-700", dot: "bg-gray-400" },
    dibatalkan: { bg: "bg-gray-100", text: "text-gray-500", dot: "bg-gray-300" },
  };
  const statusCfg = statusConfig[data.status] || { bg: "bg-gray-100", text: "text-gray-700", dot: "bg-gray-400" };

  // Tanggal submission
  const submittedDate = data.tanggal ? formatTanggal(data.tanggal) : null;

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/aduan" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Aduan
        </Link>

        {/* Ticket header card */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm mt-2">
          <div className="px-6 pt-6 pb-5 border-b border-current/10">
            {/* Ticket number + status row */}
            <div className="flex items-center justify-between gap-4 flex-wrap">
              <div>
                {data.nomor_tiket && (
                  <p className="text-[10px] font-mono font-semibold text-foreground/40 uppercase tracking-wider mb-1">Tiket #{data.nomor_tiket}</p>
                )}
                <h1 className="font-display text-xl sm:text-2xl font-semibold leading-snug text-foreground">
                  {data.judul}
                </h1>
              </div>
              <div className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${statusCfg.bg} ${statusCfg.text}`}>
                <span className={`w-2 h-2 rounded-full flex-shrink-0 ${statusCfg.dot}`} />
                {ADUAN_STATUS_LABELS[data.status] || data.status}
              </div>
            </div>
          </div>

          {/* Reporter info */}
          <div className="px-6 py-5 grid sm:grid-cols-2 gap-4">
            {maskedNama && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Pelapor</p>
                  <p className="text-sm font-medium text-foreground">{maskedNama}</p>
                </div>
              </div>
            )}
            {maskedKontak && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Kontak</p>
                  <p className="text-sm font-medium text-foreground">{maskedKontak}</p>
                </div>
              </div>
            )}
            {data.kategori && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M17.25 6.622L14 3.372l-3.25 3.25A5.46 5.46 0 007.5 9.872a5.5 5.5 0 005.872 7.5 5.46 5.46 0 003.25-3.25L18.5 9l-1.25-2.378zM9.5 12.872a3.5 3.5 0 110-7 3.5 3.5 0 010 7z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Kategori</p>
                  <p className="text-sm font-medium text-foreground">{data.kategori}</p>
                </div>
              </div>
            )}
            {submittedDate && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Diajukan</p>
                  <p className="text-sm font-medium text-foreground">{submittedDate}</p>
                </div>
              </div>
            )}
            {data.lokasi && (
              <div className="sm:col-span-2 flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.274 1.765 11.842 11.842 0 00.976.734l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clipRule="evenodd" /></svg>
                </div>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Lokasi</p>
                  <p className="text-sm font-medium text-foreground">{data.lokasi}</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Complaint text */}
        <div className="mt-6">
          <div className="bg-background border border-current/15 rounded-xl p-5 shadow-sm">
            <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Isi Pengaduan</h3>
            <p className="text-sm text-foreground/80 leading-relaxed whitespace-pre-wrap">{data.isi}</p>
          </div>
        </div>

        {/* Attachments */}
        {(data as AduanWarga).lampiran_url && (
          <div className="mt-4">
            <div className="bg-background border border-current/15 rounded-xl p-5 shadow-sm">
              <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Lampiran</h3>
              {}
              <img src={(data as AduanWarga).lampiran_url} alt="Lampiran pengaduan" className="max-w-full rounded border border-current/15 max-h-72 object-contain" />
            </div>
          </div>
        )}

        {/* Admin response */}
        {data.tanggapan && (
          <div className="mt-4">
            <div className="bg-accent/5 border border-accent/20 rounded-xl p-5 shadow-sm">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-6 h-6 rounded-full bg-accent/20 flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="currentColor" className="w-3 h-3 text-accent"><path fillRule="evenodd" d="M10.53 2.47a.75.75 0 00-1.06 0L6.75 5.19 5.22 3.66a.75.75 0 00-1.06 1.06l1.78 1.78-1.78 1.78a.75.75 0 001.06 1.06l2.22-2.22 3.72 3.72a.75.75 0 001.06 0l4.25-4.25a.75.75 0 000-1.06.75.75 0 00-1.06 0L10.53 2.47z" clipRule="evenodd" /></svg>
                </div>
                <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-accent">Tanggapan Admin</h3>
              </div>
              <p className="text-sm text-foreground/80 leading-relaxed whitespace-pre-wrap">{data.tanggapan}</p>
              {data.ditanggapi_pada && (
                <p className="text-[10px] text-foreground/40 mt-3">
                  Ditanggapi pada: {formatTanggal(data.ditanggapi_pada)}
                </p>
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export function IdmIndikatorDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useIdmIndikatorById(id);
  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;

  // Score percentage (assuming score max is 100)
  const scorePct = data.skor != null ? Math.min(Math.max(data.skor, 0), 100) : 0;
  const scoreColor = scorePct >= 80 ? "text-green-600" : scorePct >= 60 ? "text-amber-500" : "text-red-500";
  const scoreBg = scorePct >= 80 ? "bg-green-500" : scorePct >= 60 ? "bg-amber-500" : "bg-red-500";

  // Score label
  const scoreLabel = scorePct >= 80 ? "Baik" : scorePct >= 60 ? "Cukup" : "Kurang";

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Back link */}
        <Link to="/status-idm" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Status IDM
        </Link>

        {/* Header */}
        <div className="space-y-1 mb-8">
          <div className="flex items-center gap-2">
            {data.dimensi && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.18em] bg-accent/10 text-accent">
                {data.dimensi}
              </span>
            )}
          </div>
          <h1 className="font-display text-2xl sm:text-3xl lg:text-4xl font-semibold leading-tight text-foreground">
            {data.indikator}
          </h1>
        </div>

        {/* Score dashboard card */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm">
          {/* Score display */}
          <div className="px-6 pt-6 pb-5 text-center">
            <div className="relative inline-flex items-center justify-center">
              {/* Progress ring (SVG) */}
              <svg className="w-40 h-40 -rotate-90" viewBox="0 0 160 160">
                <circle cx="80" cy="80" r="70" fill="none" stroke="currentColor" strokeWidth="12" className="text-foreground/10" />
                <circle
                  cx="80" cy="80" r="70" fill="none"
                  stroke={scorePct >= 80 ? "#16a34a" : scorePct >= 60 ? "#d97706" : "#dc2626"}
                  strokeWidth="12"
                  strokeLinecap="round"
                  strokeDasharray={`${2 * Math.PI * 70}`}
                  strokeDashoffset={`${2 * Math.PI * 70 * (1 - scorePct / 100)}`}
                  className="transition-all"
                />
              </svg>
              {/* Score center text */}
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className={`font-display text-4xl font-bold ${scoreColor}`}>
                  {data.skor != null ? data.skor : "—"}
                </span>
                <span className="text-xs text-foreground/40 mt-1">dari 100</span>
              </div>
            </div>
            <div className="mt-4">
              <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${scorePct >= 80 ? "bg-green-100 text-green-700" : scorePct >= 60 ? "bg-amber-100 text-amber-700" : "bg-red-100 text-red-700"}`}>
                {scoreLabel}
              </span>
            </div>
          </div>

          {/* Metrics row */}
          <div className="grid grid-cols-2 gap-px bg-current/10 border-t border-current/10">
            <div className="bg-background px-6 py-4 text-center">
              <p className={`font-display text-2xl font-bold ${scoreColor}`}>
                {data.nilai != null ? data.nilai : "—"}
              </p>
              <p className="text-[10px] uppercase tracking-[0.1em] text-foreground/40 mt-1">Nilai</p>
            </div>
            <div className="bg-background px-6 py-4 text-center border-l border-current/10">
              <p className={`font-display text-2xl font-bold ${scoreColor}`}>
                {data.tahun ?? "—"}
              </p>
              <p className="text-[10px] uppercase tracking-[0.1em] text-foreground/40 mt-1">Tahun</p>
            </div>
          </div>

          {/* Progress bar below */}
          <div className="px-6 pb-6 pt-2">
            <div className="flex justify-between text-xs text-foreground/50 mb-1.5">
              <span>Skor</span>
              <span>{scorePct}%</span>
            </div>
            <div className="w-full bg-foreground/10 h-2.5 rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full transition-all ${scoreBg}`}
                style={{ width: `${scorePct}%` }}
              />
            </div>
          </div>
        </div>

        {/* Info grid */}
        <div className="mt-6 grid sm:grid-cols-2 gap-3">
          {data.dimensi && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Dimensi</p>
                <p className="text-sm font-medium text-foreground">{data.dimensi}</p>
              </div>
            </div>
          )}
          {(data as IdmIndikator).sumber && (
            <div className="flex items-center gap-3 p-3 bg-background border border-current/15 rounded-lg">
              <div className="w-8 h-8 rounded-lg bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40"><path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z" /></svg>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40">Sumber</p>
                <p className="text-sm font-medium text-foreground">{(data as IdmIndikator).sumber}</p>
              </div>
            </div>
          )}
        </div>

        {/* Keterangan */}
        {data.keterangan && (
          <div className="mt-6">
            <div className="bg-background border border-current/15 rounded-xl p-5 shadow-sm">
              <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Keterangan</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">{data.keterangan}</p>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export function NotFoundPage() {
  return (
    <EditorialLayout
      eyebrow="404"
      judul="Halaman tidak ditemukan"
      deskripsi="Halaman yang Anda cari tidak tersedia atau telah dipindahkan."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "404" }]}
    >
      <SectionWrap>
        <Link to="/" className={btnPrimary}>Kembali ke Beranda</Link>
      </SectionWrap>
    </EditorialLayout>
  );
}
