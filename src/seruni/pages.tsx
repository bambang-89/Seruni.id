import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import {
  siteSettings as seedSettings,
} from "./data";
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
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  return (
    <EditorialLayout
      eyebrow="Profil Desa"
      judul="Sejarah, Visi, dan Misi"
      deskripsi={`Kenali ${siteName} — dari sejarah pemekaran hingga arah pembangunan ke depan.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Profil Desa" }]}
    >
      <Seo title="Profil Desa" description={`Sejarah, visi, dan misi ${siteName}, ${settings?.wilayah ?? seedSettings.wilayah}.`} path="/profil-desa" />
      <SectionWrap>
        <div className="grid lg:grid-cols-3 gap-10 lg:gap-14">
          <article className="lg:col-span-2">
            <EditorialTitle kicker="Sejarah" judul="Perjalanan Desa" />
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
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
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
  return (
    <EditorialLayout
      eyebrow="Informasi"
      judul="Berita Desa"
      deskripsi="Kabar terbaru pembangunan, kesehatan, ekonomi, dan sosial dari Desa Seruni Mumbul."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Berita" }]}
    >
      <Seo title="Berita Desa" description="Kabar terbaru pembangunan, kesehatan, ekonomi, dan sosial Desa Seruni Mumbul." path="/berita" />
      <SectionWrap>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-x-8 gap-y-14">
          {beritaTerbaru.map((b) => (
            <Link key={b.slug} to={`/berita/${b.slug}`} className="group block">
              <div className="overflow-hidden mb-5 border-b border-current/15">
                <div className="relative aspect-[16/10] bg-primary text-primary-foreground">
                  {b.cover_url ? (
                    <img src={b.cover_url} alt={b.judul} loading="lazy" className="absolute inset-0 w-full h-full object-cover" />
                  ) : (
                    <div className="stempel-watermark absolute inset-0" style={{ color: "#fff" }} aria-hidden />
                  )}
                  <span className="absolute top-4 left-4 border border-accent text-accent px-3 py-1 font-display text-[10px] font-bold uppercase tracking-[0.22em] bg-primary/60">
                    {b.kategori}
                  </span>
                </div>
              </div>
              <time className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent tabular-nums">
                {formatTanggal(b.tanggal)}
              </time>
              <h3 className="mt-3 font-display text-xl sm:text-2xl font-semibold leading-snug group-hover:text-accent transition-colors">
                {b.judul}
              </h3>
              <p className="mt-3 text-sm leading-relaxed opacity-75 line-clamp-3">{b.ringkasan}</p>
            </Link>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function BeritaDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const { data: b, loading } = useBeritaBySlug(slug);
  if (loading) {
    return (
      <EditorialLayout eyebrow="Informasi" judul="Memuat berita…" crumbs={[{ label: "Beranda", to: "/" }, { label: "Berita", to: "/berita" }]}>
        <SectionWrap><p className="opacity-60">Sedang memuat…</p></SectionWrap>
      </EditorialLayout>
    );
  }
  if (!b) {
    return (
      <EditorialLayout eyebrow="Informasi" judul="Berita tidak ditemukan" crumbs={[{ label: "Beranda", to: "/" }, { label: "Berita", to: "/berita" }, { label: "Tidak ditemukan" }]}>
        <SectionWrap>
          <Link to="/berita" className={btnPrimary}>Kembali ke daftar berita</Link>
        </SectionWrap>
      </EditorialLayout>
    );
  }
  return (
    <EditorialLayout
      eyebrow={b.kategori}
      judul={b.judul}
      deskripsi={`${formatTanggal(b.tanggal)} · ${b.penulis}`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Berita", to: "/berita" }, { label: b.judul.slice(0, 40) + "…" }]}
    >
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
      <SectionWrap>
        <article className="max-w-3xl mx-auto">
          {b.cover_url && (
            <img src={b.cover_url} alt={b.judul} className="w-full aspect-[16/9] object-cover mb-10 border border-current/15" />
          )}
          <p className="text-xl leading-relaxed font-display italic border-l-2 border-accent pl-6 mb-10">{b.ringkasan}</p>
          <div className="space-y-5 text-base leading-relaxed opacity-90">
            {b.isi.map((p, i) => (<p key={i}>{p}</p>))}
          </div>
          <div className="mt-12 pt-6 border-t border-current/15">
            <Link to="/berita" className={btnPrimary}>Kembali ke daftar berita</Link>
          </div>
        </article>
      </SectionWrap>
    </EditorialLayout>
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
            <li key={a.slug} className="py-8 grid sm:grid-cols-[120px_1fr] gap-6 sm:gap-10 items-start">
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
            <figure key={g.judul} className="group relative aspect-square bg-primary text-primary-foreground overflow-hidden">
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
            </figure>
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
            <li key={p.nomor} className="py-6 grid sm:grid-cols-[220px_1fr] gap-4 sm:gap-10">
              <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                <div>No. {p.nomor}</div>
                <time className="block mt-1 opacity-70 tabular-nums">{formatTanggal(p.tanggal)}</time>
              </div>
              <div>
                <h3 className="font-display text-lg font-semibold leading-snug">{p.judul}</h3>
                <p className="mt-2 text-sm opacity-80 leading-relaxed">{p.ringkasan}</p>
              </div>
            </li>
          ))}
        </ul>
      </SectionWrap>
    </EditorialLayout>
  );
}

// ============================ Layanan ============================

export function LayananPage() {
  const catalog = [
    { to: "/layanan/surat", kicker: "Administrasi", judul: "Ajukan Surat Online", desc: "8 jenis surat, TTE & QR verifikasi, SLA 1–5 hari kerja." },
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
        <EditorialTitle kicker="Bulan Ini" judul="Layanan Terlaris" />
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
          {layananTerlaris.map((l) => (
            <div key={l.nama} className="bg-[#EAECF0] p-6">
              <div className="font-display text-4xl font-bold tabular-nums text-accent leading-none">
                {l.jumlah_bulan}
              </div>
              <div className="mt-2 font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-60">
                permohonan bulan ini
              </div>
              <div className="mt-4 pt-4 border-t border-current/15 font-display text-sm font-semibold">
                {l.nama}
              </div>
            </div>
          ))}
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function LayananSuratPage() {
  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Ajukan Surat Online"
      deskripsi="8 jenis surat resmi desa, semua bernomor auto-generate dan dilengkapi QR verifikasi."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Layanan", to: "/layanan" }, { label: "Surat" }]}
    >
      <SectionWrap>
        <div className="grid md:grid-cols-2 gap-px bg-current/15">
          {[
    { kode: "SKD", nama: "Surat Keterangan Domisili", sla_hari: 1 },
    { kode: "SKTM", nama: "Surat Keterangan Tidak Mampu", sla_hari: 2 },
    { kode: "SKU", nama: "Surat Keterangan Usaha", sla_hari: 2 },
    { kode: "SPN", nama: "Surat Pengantar Nikah", sla_hari: 3 },
    { kode: "SKW", nama: "Surat Keterangan Waris", sla_hari: 5 },
    { kode: "SKCK", nama: "Pengantar SKCK", sla_hari: 1 },
    { kode: "SKKL", nama: "Surat Keterangan Kelahiran", sla_hari: 1 },
    { kode: "SKKM", nama: "Surat Keterangan Kematian", sla_hari: 1 },
  ].map((s) => (
            <div key={s.kode} className="bg-background p-6 sm:p-8">
              <div className="flex items-center justify-between border-b border-current/15 pb-3">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Kode {s.kode}</span>
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.22em] opacity-70">SLA {s.sla_hari} hari kerja</span>
              </div>
              <h3 className="mt-4 font-display text-xl font-semibold leading-snug">{s.nama}</h3>
              <div className="mt-4 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Persyaratan</div>
              <ul className="mt-2 text-sm opacity-90 space-y-1.5">
                {s.syarat.map((x, i) => (
                  <li key={x} className="grid grid-cols-[24px_1fr] gap-2">
                    <span className="opacity-40 tabular-nums font-display">{String(i + 1).padStart(2, "0")}</span>
                    <span>{x}</span>
                  </li>
                ))}
              </ul>
              <button className={`${btnPrimary} mt-6 w-full justify-center`}>Ajukan {s.nama}</button>
            </div>
          ))}
        </div>
        <p className="mt-6 text-xs opacity-60">Login warga & pengajuan lengkap tersedia pada Phase 6 (Sistem Layanan Mandiri).</p>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function LayananPBBPage() {
  const currentYear = new Date().getFullYear();
  const [nop, setNop] = useState("");
  const [nik, setNik] = useState("");
  const [tahun, setTahun] = useState<number>(currentYear);
  const [hasil, setHasil] = useState<any>(null);
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
              <input value={nop} onChange={(e) => setNop(e.target.value)} maxLength={40} placeholder="52.03.140.007.001-0001.0" className={`${inputCls} font-mono`} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Tahun</span>
              <input type="number" min={2020} max={2100} value={tahun} onChange={(e) => setTahun(Number(e.target.value))} className={`${inputCls} tabular-nums`} />
            </label>
          </div>
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">NIK Wajib Pajak</span>
            <input value={nik} onChange={(e) => setNik(e.target.value)} maxLength={16} inputMode="numeric" placeholder="16 digit NIK sesuai SPPT" className={`${inputCls} font-mono tabular-nums`} />
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
  const [kategori, setKategori] = useState<string>(aduanKategori[0].kode);
  const [nama, setNama] = useState("");
  const [kontak, setKontak] = useState("");
  const [judul, setJudul] = useState("");
  const [lokasi, setLokasi] = useState("");
  const [isi, setIsi] = useState("");
  const [loading, setLoading] = useState(false);
  const [tiket, setTiket] = useState<string | null>(null);
  const [lacakNo, setLacakNo] = useState("");
  const [lacakHasil, setLacakHasil] = useState<any>(null);
  const [lacakLoading, setLacakLoading] = useState(false);

  async function submitAduan(e: React.FormEvent) {
    e.preventDefault();
    if (nama.trim().length < 2) return toast.error("Nama minimal 2 karakter");
    if (kontak.trim().length < 4) return toast.error("Kontak tidak valid");
    if (judul.trim().length < 4) return toast.error("Judul minimal 4 karakter");
    if (isi.trim().length < 10) return toast.error("Uraian minimal 10 karakter");
    setLoading(true);
    const { data, error } = await supabase.from("aduan_warga").insert({
      nama_pelapor: nama.trim(),
      kontak: kontak.trim(),
      kategori: kategori as any,
      judul: judul.trim(),
      isi: isi.trim(),
      lokasi: lokasi.trim() || null,
      status: "diajukan",
    }).select("nomor_tiket").single();
    setLoading(false);
    if (error) return toast.error(error.message);
    setTiket(data?.nomor_tiket ?? "-");
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
                  <select value={kategori} onChange={(e) => setKategori(e.target.value)} className={inputCls}>
                    {aduanKategori.map((k) => (<option key={k.kode} value={k.kode}>{k.label}</option>))}
                  </select>
                </label>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Lokasi</span>
                  <input value={lokasi} onChange={(e) => setLokasi(e.target.value)} type="text" placeholder="Contoh: Dusun Karang Baru RT 04" className={inputCls} />
                </label>
              </div>
              <div className="grid sm:grid-cols-2 gap-5">
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nama Pelapor</span>
                  <input required value={nama} onChange={(e) => setNama(e.target.value)} maxLength={120} className={inputCls} />
                </label>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor WhatsApp / Telepon</span>
                  <input required value={kontak} onChange={(e) => setKontak(e.target.value)} type="tel" maxLength={60} placeholder="08xxxxxxxxxx" className={inputCls} />
                </label>
              </div>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Judul Aduan</span>
                <input required value={judul} onChange={(e) => setJudul(e.target.value)} maxLength={160} className={inputCls} />
              </label>
              <label className="block text-sm">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Uraian Aduan</span>
                <textarea required rows={5} value={isi} onChange={(e) => setIsi(e.target.value)} maxLength={4000} placeholder="Ceritakan kejadian, kapan terjadi, dan dampaknya." className={inputCls} />
              </label>
              <button disabled={loading} type="submit" className={`${btnPrimary} justify-self-start disabled:opacity-50`}>{loading ? "Mengirim…" : "Kirim Aduan"}</button>
            </form>
          ) : (
            <div className="grid gap-6">
              <form className="grid gap-5 border border-current/20 p-6 sm:p-8" onSubmit={lacak}>
                <label className="block text-sm">
                  <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor Tiket</span>
                  <input required value={lacakNo} onChange={(e) => setLacakNo(e.target.value)} placeholder="ADN-2026-XXXXXX" className={`${inputCls} font-mono`} />
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
              <a href={`https://wa.me/${(settings?.nomor_wa_resmi ?? seedSettings.nomor_wa_resmi).replace(/\D/g, "")}`} className="font-medium hover:text-accent">{settings?.nomor_wa_resmi ?? seedSettings.nomor_wa_resmi}</a>
              {(settings?.wa_business_verified ?? seedSettings.wa_business_verified) && (<div className="text-[10px] font-bold uppercase tracking-[0.22em] text-accent mt-1">Terverifikasi</div>)}
            </div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Telepon Darurat</div><div className="font-medium tabular-nums">{settings?.telepon_darurat ?? seedSettings.telepon_darurat}</div></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Email</div><a href={`mailto:${settings?.email ?? seedSettings.email}`} className="font-medium hover:text-accent break-all">{settings?.email ?? seedSettings.email}</a></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Jam Layanan</div><div>{settings?.jam_layanan ?? seedSettings.jam_layanan}</div></div>
            <div className="text-sm"><div className="opacity-60 text-xs uppercase tracking-wider">Alamat</div><div>{settings?.alamat_kantor ?? seedSettings.alamat_kantor}</div></div>
          </aside>
        </div>
      </SectionWrap>
    </EditorialLayout>
  );
}

export function VerifikasiPage() {
  const [nomor, setNomor] = useState("");
  const [kode, setKode] = useState("");
  const [loading, setLoading] = useState(false);
  const [hasil, setHasil] = useState<any>(null);

  async function cek(e: React.FormEvent) {
    e.preventDefault();
    if (!nomor.trim() || !kode.trim()) return toast.error("Nomor & kode wajib diisi");
    setLoading(true);
    const { data, error } = await supabase.rpc("verifikasi_surat", { _nomor: nomor.trim(), _kode: kode.trim() });
    setLoading(false);
    if (error) return toast.error(error.message);
    const row = Array.isArray(data) ? data[0] : data;
    setHasil(row ?? { notfound: true });
  }
  return (
    <EditorialLayout
      eyebrow="Layanan"
      judul="Verifikasi Dokumen Surat"
      deskripsi="Cek keaslian surat desa dengan memasukkan nomor surat dan kode verifikasi yang tercetak pada dokumen."
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Verifikasi" }]}
    >
      <Seo title="Verifikasi Dokumen Surat" description="Cek keaslian surat resmi Desa Seruni Mumbul dengan nomor & kode verifikasi." path="/verifikasi" />
      <SectionWrap>
        <form className="max-w-xl border border-current/20 p-6 sm:p-8 grid gap-5" onSubmit={cek}>
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor Surat</span>
            <input value={nomor} onChange={(e) => setNomor(e.target.value)} placeholder="470/001/SM/2026" className={`${inputCls} font-mono`} />
          </label>
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Kode Verifikasi</span>
            <input value={kode} onChange={(e) => setKode(e.target.value)} placeholder="SRN-DEMO-001" className={`${inputCls} font-mono`} />
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
          { nilai: idm.skor_total.toFixed(4), label: "Skor Total IDM", highlight: true },
          { nilai: idm.status, label: "Status Desa" },
          { nilai: String(idm.dimensi.length), label: "Dimensi Dinilai" },
          { nilai: "5.0", label: "Skor Maksimum" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Enam Dimensi" judul="Rincian per Dimensi" />
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
      deskripsi={`Total ${(statistik?.jumlah_penduduk || 6842).toLocaleString("id-ID")} jiwa dalam ${(statistik?.jumlah_kk || 1937).toLocaleString("id-ID")} KK, tersebar di ${statistik?.jumlah_dusun || 6} dusun.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Penduduk" }]}
    >
      <Seo title="Statistik Penduduk" description="Distribusi penduduk berdasarkan usia, mata pencaharian, dan pendidikan." path="/statistik/penduduk" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: (statistik?.jumlah_penduduk || 6842).toLocaleString("id-ID"), label: "Total Jiwa", highlight: true },
          { nilai: (statistik?.jumlah_kk || 1937).toLocaleString("id-ID"), label: "Kepala Keluarga" },
          { nilai: String(statistik?.jumlah_dusun || 6), label: "Dusun" },
          { nilai: "6", label: "Kategori Data" },
        ]}
      />
      <SectionWrap>
        <div className="grid md:grid-cols-2 gap-10 lg:gap-14">
          {[
            { j: "Jenis Kelamin", d: statistikPenduduk.per_jenis_kelamin },
            { j: "Kelompok Umur", d: statistikPenduduk.per_umur },
            { j: "Pekerjaan", d: statistikPenduduk.per_pekerjaan },
            { j: "Pendidikan", d: statistikPenduduk.per_pendidikan },
          ].map((g) => (
            <div key={g.j}>
              <EditorialTitle kicker="Distribusi" judul={g.j} />
              <BarList items={g.d} />
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
          { nilai: `${pembangunan.progres_fisik_avg}%`, label: "Progres Fisik Rata-Rata", highlight: true },
          { nilai: `${pembangunan.anggaran_terserap_pct}%`, label: "Anggaran Terserap" },
          { nilai: pembangunan.aset_baru.toString(), label: "Aset Baru Terbentuk" },
          { nilai: String(pembangunan.kegiatan_aktif.length), label: "Kegiatan Aktif" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Realisasi 2026" judul="Kegiatan Aktif" />
        <ul className="space-y-6">
          {pembangunan.kegiatan_aktif.map((k) => (
            <li key={k.nama}>
              <EditorialProgress label={k.nama} value={k.progres} />
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
      deskripsi={`${perencanaanUsulan.total_usulan} usulan warga terkumpul, dengan ${perencanaanUsulan.partisipasi_voting.toLocaleString("id-ID")} suara pada periode Musrenbang 2027.`}
      crumbs={[{ label: "Beranda", to: "/" }, { label: "Statistik", to: "/statistik" }, { label: "Perencanaan" }]}
    >
      <Seo title="Perencanaan & Voting Usulan" description="RKPDes, usulan Musdes, dan prioritas pembangunan tahun berjalan." path="/perencanaan" />
      <StatsBand
        tone="dark"
        items={[
          { nilai: perencanaanUsulan.total_usulan.toLocaleString("id-ID"), label: "Total Usulan", highlight: true },
          { nilai: perencanaanUsulan.partisipasi_voting.toLocaleString("id-ID"), label: "Suara Partisipasi" },
          { nilai: String(perencanaanUsulan.top10.length), label: "Top Peringkat" },
          { nilai: "2027", label: "Periode Musrenbang" },
        ]}
      />
      <SectionWrap>
        <EditorialTitle kicker="Top 10" judul="Usulan Warga Terpilih" />
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
        <EditorialTitle kicker="UMKM" judul="Usaha Warga" />
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
              <article key={u.id} className="bg-background p-6">
                <span className="font-display text-2xl font-light opacity-25 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
                <div className="mt-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{u.sektor || "Usaha"}</div>
                <h3 className="mt-1 font-display text-lg font-semibold leading-snug">{u.nama}</h3>
                {u.pemilik && <div className="mt-1 text-xs opacity-70">Pemilik: {u.pemilik}</div>}
                {u.dusun && <div className="text-xs opacity-70">Dusun {u.dusun}</div>}
                {u.deskripsi && <p className="mt-3 text-sm leading-relaxed opacity-80">{u.deskripsi}</p>}
                {u.kontak && <div className="mt-3 pt-3 border-t border-current/15 text-xs tabular-nums">{u.kontak}</div>}
              </article>
            ))}
          </div>
        )}
      </SectionWrap>
      <SectionWrap id="pariwisata" alt>
        <EditorialTitle kicker="Destinasi" judul="Pariwisata Desa" />
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-px bg-current/15">
          {wisata.map((p, i) => (
            <article key={p.id} className="bg-[#EAECF0] p-6">
              <span className="font-display text-2xl font-light opacity-25 tabular-nums">{String(i + 1).padStart(2, "0")}</span>
              <div className="mt-3 font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">{p.jenis}</div>
              <h3 className="mt-1 font-display text-xl font-semibold leading-snug">{p.nama}</h3>
              {p.dusun && <div className="text-xs opacity-70 mt-1">Dusun {p.dusun}</div>}
              {p.deskripsi && <p className="mt-3 text-sm leading-relaxed opacity-80">{p.deskripsi}</p>}
              {p.fasilitas && <div className="mt-3 pt-3 border-t border-current/15 text-xs opacity-70">Fasilitas: {p.fasilitas}</div>}
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
              <h2 className="mt-3 font-display text-4xl sm:text-5xl lg:text-6xl font-bold italic tracking-tight leading-[1.05]">{bumdesUtama?.nama || potensi.bumdes}</h2>
              <p className="mt-6 max-w-2xl text-base leading-relaxed opacity-80">
                {bumdesUtama?.deskripsi || "Badan Usaha Milik Desa yang menaungi marketplace desa, unit simpan pinjam UMKM, dan pengelolaan aset wisata."}
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
          <EditorialTitle kicker="Produk" judul={grup.label} />
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-px bg-current/15">
              {grup.items.map((p) => (
                <article key={p.id} className={`${gi % 2 === 1 ? "bg-[#EAECF0]" : "bg-background"} p-5`}>
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
    ...(layer.dusun ? dusun.filter((d: any) => d.latitude != null && d.longitude != null).map((d: any) => ({
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
                <span>Titik Dusun <span className="opacity-60">({dusun.filter((d: any) => d.latitude != null).length})</span></span>
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
  const [nama, setNama] = useState("");
  const [nomor, setNomor] = useState("");
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
              <input required value={nama} onChange={(e) => setNama(e.target.value)} maxLength={120} type="text" className={inputCls} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Nomor WhatsApp</span>
              <input required value={nomor} onChange={(e) => setNomor(e.target.value)} type="tel" placeholder="08xxxxxxxxxx" className={inputCls} />
            </label>
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Dusun (opsional)</span>
              <input value={dusun} onChange={(e) => setDusun(e.target.value)} type="text" className={inputCls} />
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
              <EditorialTitle kicker="Belanja per Bidang" judul="Serapan Anggaran per Bidang" />
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