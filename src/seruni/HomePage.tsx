import { useState } from "react";
import { Link } from "react-router-dom";

import { SectionWrap, formatTanggal } from "./ui";
import { Seo } from "./lib/seo";
import { useSectionTitle } from "./lib/pageConfig";
import { useSiteSettings } from "./lib/zeroHardcode";
import {
  useStatistikDesa,
  useIdmData,
  usePembangunanData,
  useUsulanStats,
  useGaleri,
  useAgenda,
  useBerita,
  usePotensiProduk,
  usePotensiWisata,
  usePotensiUmkm,
  useSuratJenis,
  useLayananStatistik,
  useDusun,
  useAduanKategori,
  useProfilDesa,
  usePamong,
} from "./lib/queries";
import {
  Band,
  EditorialTitle,
  IntroBand,
  EditorialSplit,
  StatsBand,
  NumberedList,
  FeaturedCard,
  TileGrid,
  QuoteBand,
} from "./sections";
import { PageHero } from "./components/PageHero";
import { supabase } from "@/integrations/supabase/client";

function TaglineBar() {
  const { data: settings } = useSiteSettings();
  return (
    <div className="bg-accent text-[#0F0E0E] border-y border-[#0F0E0E]/10">
      <div className="mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 py-4 flex flex-wrap items-center justify-between gap-4">
        <span className="font-display text-[11px] sm:text-xs font-bold uppercase tracking-[0.28em]">
          {settings?.tagline ?? "Membangun Desa, Memberdayakan Masyarakat"}
        </span>
        <span className="font-display text-[10px] sm:text-[11px] font-semibold uppercase tracking-[0.28em] opacity-70 tabular-nums">
          {settings?.jam_layanan ?? "Senin - Jumat, 08:00 - 15:00"}
        </span>
      </div>
    </div>
  );
}

/* ============================================================
 * S1 · Sambutan + selayang pandang (editorial split)
 * ============================================================ */

function S1() {
  const { data: profilDesa } = useProfilDesa();
  const imageUrl = profilDesa?.gambar_hero_url ? supabase.storage.from('seruni-media').getPublicUrl(profilDesa.gambar_hero_url).data.publicUrl : undefined;
  
  return (
    <EditorialSplit
      kicker="Bagian Satu — Tentang"
      judul={profilDesa?.visi || ""}
      image={imageUrl}
      imageAlt="Potret Desa"
      tone="paper"
      href="/profil-desa"
      hrefLabel="Kenali Desa"
      sectionKey="home-tentang"
    >
      <p>
        {profilDesa?.sejarah?.[0] || ""}
      </p>
      <p>
        {profilDesa?.sejarah?.[1] || ""}
      </p>
    </EditorialSplit>
  );
}

/* ============================================================
 * S1.5 · Statistik desa (stats band, navy)
 * ============================================================ */

function StatistikBand() {
  const { data: statistik } = useStatistikDesa();
  return (
    <StatsBand
      kicker="Angka Desa · Diperbarui Rutin"
      tone="navy"
      sectionKey="home-statistik"
      items={[
        { nilai: `${statistik?.luas_wilayah_km2 ?? 0}`, label: "Luas Wilayah (km²)" },
        { nilai: (statistik?.jumlah_dusun ?? 0).toString(), label: "Jumlah Dusun" },
        { nilai: (statistik?.jumlah_penduduk ?? 0).toLocaleString("id-ID"), label: "Jumlah Penduduk", highlight: true },
        { nilai: (statistik?.jumlah_kk ?? 0).toLocaleString("id-ID"), label: "Jumlah Kepala Keluarga" },
      ]}
    />
  );
}

/* ============================================================
 * S2 · Indeks Desa Membangun (editorial ledger)
 * ============================================================ */

function S2() {
  const { data: idmData } = useIdmData();
  return (
    <Band id="idm" tone="neutral">
      <EditorialTitle
        kicker="Bagian Dua — Indeks Desa Membangun"
        judul={`Status ${idmData?.status ?? ""}, skor ${idmData?.skor_total.toFixed(4) ?? 0}.`}
        href="/status-idm"
        sectionKey="home-idm"
      />
      <div className="grid lg:grid-cols-[1fr_2fr] gap-10 lg:gap-16 items-start">
        <div className="border-t border-b border-[#0F0E0E]/20 py-8">
          <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] opacity-60">
            Skor Komposit
          </p>
          <p className="mt-4 font-display text-6xl sm:text-7xl font-bold italic tracking-tight tabular-nums text-primary">
            {idmData?.skor_total.toFixed(4) ?? 0}
          </p>
          <p className="mt-6 font-display text-xs font-bold uppercase tracking-[0.22em]">
            <span className="text-accent">■</span> Status · {idmData?.status ?? ""}
          </p>
          <p className="mt-6 text-sm leading-relaxed opacity-75">
            Diagregasi dari enam dimensi ketahanan desa dan dimutakhirkan pada
            setiap siklus pelaporan tahunan.
          </p>
        </div>
        <ul className="divide-y divide-[#0F0E0E]/15 border-y border-[#0F0E0E]/20">
          {(idmData?.dimensi ?? []).map((d, i) => (
            <li key={d.nama} className="py-5 grid grid-cols-[auto_1fr_auto] items-center gap-6">
              <span className="font-display text-xs font-light opacity-40 tabular-nums w-8">
                {String(i + 1).padStart(2, "0")}
              </span>
              <div>
                <div className="font-display text-base sm:text-lg font-semibold tracking-tight">
                  {d.nama}
                </div>
                <div className="mt-2 h-px w-full bg-[#0F0E0E]/10 relative">
                  <div className="absolute inset-y-0 left-0 bg-accent" style={{ width: `${(d.skor / 5) * 100}%`, height: "2px", top: "-0.5px" }} />
                </div>
              </div>
              <span className="font-display text-2xl font-bold italic tabular-nums text-primary">
                {d.skor.toFixed(1)}
                <span className="text-xs font-light opacity-40 ml-1">/5</span>
              </span>
            </li>
          ))}
        </ul>
      </div>
    </Band>
  );
}

/* ============================================================
 * S3 · Agenda mendatang (numbered list, navy)
 * ============================================================ */

function S3() {
  const { data: agendaData } = useAgenda();
  return (
    <Band id="agenda" tone="dark">
      <EditorialTitle
        kicker="Bagian Tiga — Agenda"
        judul="Yang akan berlangsung di desa."
        href="/kalender-desa"
        invert
        sectionKey="home-agenda"
      />
      <div className="grid lg:grid-cols-[3fr_2fr] gap-10 lg:gap-16 items-start">
        <NumberedList
          tone="dark"
          items={(agendaData ?? []).map((a) => ({
            kategori: a.jenis,
            judul: a.judul,
            meta: `${formatTanggal(a.tanggal)} · ${a.lokasi}`,
            href: `/kalender-desa`,
          }))}
        />
        <div className="border border-white/20 p-8 sm:p-10">
          <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-6">
            Langganan Notifikasi
          </p>
          <p className="font-display text-xl sm:text-2xl font-light leading-snug">
            Terima pengingat agenda dan pengumuman langsung ke WhatsApp resmi
            desa yang terverifikasi.
          </p>
          <Link
            to="/langganan-wa"
            className="mt-10 inline-block font-display text-[11px] font-bold uppercase tracking-[0.28em] border border-white/40 px-6 py-3 hover:border-accent hover:text-accent transition-colors"
          >
            Aktifkan Langganan
          </Link>
        </div>
      </div>
    </Band>
  );
}

/* ============================================================
 * S4 · Berita terbaru (featured card + list, paper)
 * ============================================================ */

function S4() {
  const { data: beritaData } = useBerita();
  const [utama, ...lainnya] = beritaData || [];
  return (
    <Band id="berita" tone="paper">
      <EditorialTitle
        kicker="Bagian Empat — Warta Desa"
        judul="Kabar terbaru dari lapangan."
        href="/berita"
        align="between"
        sectionKey="home-berita"
      />
      <div className="grid lg:grid-cols-[3fr_2fr] gap-10 lg:gap-16 items-start">
        {utama && (
          <FeaturedCard
            image={utama.foto_url ? supabase.storage.from('seruni-media').getPublicUrl(utama.foto_url).data.publicUrl : ""}
            imageAlt={utama.judul}
            kicker={utama.kategori}
            meta={formatTanggal(utama.tanggal)}
            judul={utama.judul}
            ringkasan={utama.ringkasan}
            href={`/berita/${utama.slug}`}
            cta="Baca Selengkapnya"
          />
        )}
        <ul className="divide-y divide-current/15 border-y border-current/20">
          {lainnya.map((b, i) => (
            <li key={b.slug} className="py-6">
              <Link to={`/berita/${b.slug}`} className="group block">
                <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                  {b.kategori} <span className="opacity-60">· {formatTanggal(b.tanggal)}</span>
                </p>
                <h4 className="mt-2 font-display text-lg sm:text-xl font-semibold leading-snug group-hover:text-accent transition-colors">
                  {b.judul}
                </h4>
                <p className="mt-2 text-sm opacity-70 line-clamp-2">{b.ringkasan}</p>
              </Link>
              {i === lainnya.length - 1 && null}
            </li>
          ))}
        </ul>
      </div>
    </Band>
  );
}

/* ============================================================
 * S5 · Layanan (editorial tile grid, navy)
 * ============================================================ */

function S5() {
  const { data: suratList } = useSuratJenis();
  const { data: statList } = useLayananStatistik();

  // Build lookup: prefix -> count_bulan_ini
  const statMap = new Map<string, number>();
  for (const s of statList ?? []) {
    if (!statMap.has(s.jenis_layanan)) {
      statMap.set(s.jenis_layanan, s.count_bulan_ini ?? 0);
    }
  }

  const prefixMap: Record<string, string> = {
    F1: "surat", F5: "pbb", SC: "aduan", BS: "bansos",
  };
  const getLayanan = (kode: string) => prefixMap[kode.split("_")[0]] ?? "surat";

  const dynamicData = (suratList ?? []).slice(0, 4).map((s) => ({
    kode: s.kode_surat,
    nama: s.nama,
    jumlah_bulan: statMap.get(getLayanan(s.kode_surat)) ?? 0,
  }));

  const layananData = dynamicData.length > 0 ? dynamicData : [
    { kode: "SKD", nama: "Surat Keterangan Domisili", jumlah_bulan: 0 },
    { kode: "F5_PBB", nama: "Pembayaran PBB Online", jumlah_bulan: 0 },
    { kode: "SPN", nama: "Surat Pengantar Nikah", jumlah_bulan: 0 },
    { kode: "INFRASTRUKTUR", nama: "Aduan Infrastruktur", jumlah_bulan: 0 },
  ];

  return (
    <Band id="layanan" tone="navy">
      <EditorialTitle
        kicker="Bagian Lima — Layanan"
        judul="Ajukan permohonan tanpa antre di kantor desa."
        href="/layanan"
        invert
        sectionKey="home-layanan"
      />
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-px bg-white/10">
        {layananData.map((l, i) => (
          <Link
            key={l.nama}
            to="/layanan"
            className="group bg-primary p-8 aspect-square flex flex-col justify-between hover:bg-accent hover:text-[#0F0E0E] transition-colors"
          >
            <span className="font-display text-xs font-light opacity-40 tabular-nums">
              {String(i + 1).padStart(2, "0")}
            </span>
            <div>
              <h3 className="font-display text-xl sm:text-2xl font-bold leading-[1.05] tracking-tight uppercase">
                {l.nama}
              </h3>
              <div className="mt-6 pt-4 border-t border-current/20 flex items-end justify-between">
                <span className="font-display text-[10px] font-bold uppercase tracking-[0.24em] opacity-70">
                  Bulan Ini
                </span>
                <span className="font-display text-3xl font-bold italic tabular-nums">
                  {l.jumlah_bulan}
                </span>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </Band>
  );
}

/* ============================================================
 * S6 · Marketplace UMKM (editorial split, paper)
 * ============================================================ */

function S6() {
  const { data: produkData } = usePotensiProduk({ featuredOnly: true });
  const Kolom = ({ judul, items }: { judul: string; items: { nama: string; harga: string; penjual: string; emoji: string }[] }) => (
    <div>
      <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-6">
        {judul}
      </p>
      <ul className="divide-y divide-current/15 border-y border-current/20">
        {items.map((p) => (
          <li key={p.nama} className="py-5 grid grid-cols-[1fr_auto] gap-6 items-baseline">
            <div className="min-w-0">
              <div className="font-display text-lg font-semibold leading-tight">{p.nama}</div>
              <div className="mt-1 text-xs uppercase tracking-[0.16em] opacity-60">{p.penjual}</div>
            </div>
            <div className="font-display text-lg font-bold italic tabular-nums text-primary whitespace-nowrap">
              {p.harga}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
  return (
    <EditorialSplit
      kicker="Bagian Enam — Marketplace Desa"
      judul="Kerja tangan warga, siap dipesan."
      image={""}
      imageAlt="Potret Produk"
      tone="paper"
      reverse
      href="/marketplace"
      hrefLabel="Jelajahi Marketplace"
      sectionKey="home-umkm"
    >
      <div className="grid sm:grid-cols-2 gap-10">
        <Kolom judul="Terlaris" items={(produkData ?? []).slice(0, 5).map((p) => ({ nama: p.nama, harga: p.harga ? `Rp ${Number(p.harga).toLocaleString('id-ID')}` : '—', penjual: p.penjual_nama ?? '—', emoji: '' }))} />
        <Kolom judul="Terbaru" items={(produkData ?? []).slice(0, 5).map((p) => ({ nama: p.nama, harga: p.harga ? `Rp ${Number(p.harga).toLocaleString('id-ID')}` : '—', penjual: p.penjual_nama ?? '—', emoji: '' }))} />
      </div>
    </EditorialSplit>
  );
}

/* ============================================================
 * S7 · Realisasi pembangunan (dark band, editorial ledger)
 * ============================================================ */

function S7() {
  const { data: pembangunanData } = usePembangunanData();
  return (
    <Band id="pembangunan" tone="dark">
      <EditorialTitle
        kicker="Bagian Tujuh — Pembangunan"
        judul="Realisasi kerja tahun berjalan."
        href="/pembangunan"
        invert
        sectionKey="home-pembangunan"
      />
      <div className="grid lg:grid-cols-3 gap-px bg-white/10 mb-14">
        {[
          { l: "Progres Fisik Rata-Rata", v: `${pembangunanData?.progres_fisik_avg ?? 0}`, suffix: "%" },
          { l: "Anggaran Terserap", v: `${pembangunanData?.anggaran_terserap_pct ?? 0}`, suffix: "%" },
          { l: "Aset Baru Terbentuk", v: (pembangunanData?.aset_baru ?? 0).toString(), suffix: "" },
        ].map((k) => (
          <div key={k.l} className="bg-[#0F0E0E] p-8 sm:p-10">
            <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {k.l}
            </p>
            <p className="mt-6 font-display text-5xl sm:text-6xl font-bold italic tracking-tight tabular-nums">
              {k.v}
              <span className="text-2xl font-light opacity-60 ml-1">{k.suffix}</span>
            </p>
          </div>
        ))}
      </div>
      <div>
        <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-8">
          Kegiatan Aktif
        </p>
        <ul className="divide-y divide-white/15 border-y border-white/20">
          {(pembangunanData?.kegiatan_aktif ?? []).map((k, i) => (
            <li key={k.nama} className="py-6 grid grid-cols-[auto_1fr_auto] gap-6 items-center">
              <span className="font-display text-xs font-light opacity-40 tabular-nums w-8">
                {String(i + 1).padStart(2, "0")}
              </span>
              <div>
                <div className="font-display text-base sm:text-lg font-semibold">{k.nama}</div>
                <div className="mt-3 h-px bg-white/15 relative">
                  <div className="absolute left-0 h-[2px] bg-accent -top-[0.5px]" style={{ width: `${k.progres}%` }} />
                </div>
              </div>
              <span className="font-display text-2xl font-bold italic tabular-nums">
                {k.progres}
                <span className="text-xs font-light opacity-40">%</span>
              </span>
            </li>
          ))}
        </ul>
      </div>
    </Band>
  );
}

/* ============================================================
 * S8 · Perencanaan / usulan warga (numbered, paper)
 * ============================================================ */

function S8() {
  const { data: usulanData } = useUsulanStats();
  const max = Math.max(...(usulanData?.top10 ?? []).map((u) => u.suara));
  return (
    <Band id="perencanaan" tone="neutral">
      <EditorialTitle
        kicker="Bagian Delapan — Perencanaan"
        judul="Sepuluh usulan warga dengan dukungan tertinggi."
        href="/perencanaan"
        sectionKey="home-perencanaan"
      />
      <p className="font-display text-sm sm:text-base opacity-75 mb-10 max-w-3xl">
        <span className="tabular-nums font-semibold text-primary">{usulanData?.total_usulan ?? 0}</span>{" "}
        usulan masuk ·{" "}
        <span className="tabular-nums font-semibold text-primary">
          {(usulanData?.partisipasi_voting ?? 0).toLocaleString("id-ID")}
        </span>{" "}
        suara terkumpul dari warga desa.
      </p>
      <ol className="divide-y divide-[#0F0E0E]/15 border-y border-[#0F0E0E]/25">
        {(usulanData?.top10 ?? []).map((u, i) => (
          <li key={u.judul} className="py-5 grid grid-cols-[auto_1fr_auto] gap-6 items-center">
            <span className="font-display text-2xl sm:text-3xl font-light italic opacity-30 tabular-nums w-12">
              {String(i + 1).padStart(2, "0")}
            </span>
            <div className="min-w-0">
              <div className="font-display text-base sm:text-lg font-semibold leading-snug">{u.judul}</div>
              <div className="mt-2 h-px bg-[#0F0E0E]/15 relative">
                <div className="absolute left-0 h-[2px] bg-accent -top-[0.5px]" style={{ width: `${(u.suara / max) * 100}%` }} />
              </div>
            </div>
            <span className="font-display text-lg sm:text-xl font-bold italic tabular-nums text-primary whitespace-nowrap">
              {u.suara}
              <span className="text-[10px] font-light opacity-60 ml-1 uppercase tracking-wider">suara</span>
            </span>
          </li>
        ))}
      </ol>
    </Band>
  );
}

/* ============================================================
 * S9 · Potensi desa (editorial split w/ landscape)
 * ============================================================ */

function S9() {
  const { data: wisataData } = usePotensiWisata();
  const override = useSectionTitle("/", "home-wisata");
  const finalKicker = override?.kicker || "";
  const finalJudul = override?.judul || "";

  const sektorData = [
    { nama: "Perikanan Tangkap", nilai: "Rp 4,2 M/thn" },
    { nama: "Pertanian Padi & Palawija", nilai: "Rp 3,1 M/thn" },
    { nama: "UMKM Kuliner & Kerajinan", nilai: "Rp 1,8 M/thn" },
    { nama: "Peternakan Sapi & Kambing", nilai: "Rp 1,2 M/thn" },
  ];
  return (
    <>
      <section className="relative bg-[#0F0E0E] text-white">
        <div className="relative aspect-[16/8] sm:aspect-[16/7] w-full overflow-hidden">
          <img
            src={""}
            alt="Lansekap Desa"
            className="absolute inset-0 h-full w-full object-cover"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0F0E0E] via-[#0F0E0E]/40 to-transparent" />
          <div className="absolute inset-x-0 bottom-0 mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 pb-10 sm:pb-14">
            <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-4">
              {finalKicker}
            </p>
            <h2 className="font-display text-3xl sm:text-5xl lg:text-6xl font-bold italic tracking-tight max-w-4xl leading-[1.02]">
              {finalJudul}
            </h2>
          </div>
        </div>
        <Band tone="dark">
          <div className="grid lg:grid-cols-3 gap-px bg-white/10">
            <div className="lg:col-span-2 bg-[#0F0E0E] p-8 sm:p-10">
              <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-8">
                Sektor Ekonomi Unggulan
              </p>
              <ul className="divide-y divide-white/15">
                {sektorData.map((s) => (
                  <li key={s.nama} className="py-4 grid grid-cols-[1fr_auto] items-baseline gap-6">
                    <span className="font-display text-lg sm:text-xl font-semibold">{s.nama}</span>
                    <span className="font-display text-base sm:text-lg font-bold italic tabular-nums text-accent">
                      {s.nilai}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="bg-[#0F0E0E] p-8 sm:p-10 flex flex-col">
              <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-8">
                Pariwisata
              </p>
              <ul className="space-y-4 flex-1">
                {(wisataData || []).map((p) => (
                  <li key={p.nama}>
                    <div className="font-display text-base font-semibold">{p.nama}</div>
                    <div className="font-display text-[10px] font-bold uppercase tracking-[0.24em] opacity-60 mt-1">
                      {p.tipe}
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>
          <div className="mt-10">
            <Link
              to="/potensi-desa"
              className="inline-block font-display text-[11px] font-bold uppercase tracking-[0.28em] border border-white/40 px-6 py-3 hover:border-accent hover:text-accent transition-colors"
            >
              Telusuri Potensi
            </Link>
          </div>
        </Band>
      </section>
    </>
  );
}

/* ============================================================
 * S9.5 · Quote kepala desa (dark band)
 * ============================================================ */

function QuoteKades() {
  const { data: pamongList } = usePamong();
  const kades = pamongList?.find(p => p.jabatan === 'Kepala Desa');

  return (
    <QuoteBand
      quote={kades ? "Terpercaya dalam membangun desa untuk masyarakat" : ""}
      nama={kades?.nama || ""}
      jabatan="Kepala Desa"
      image={kades?.foto_url ? supabase.storage.from('seruni-media').getPublicUrl(kades.foto_url).data.publicUrl : ""}
      imageAlt="Potret Kepala Desa"
    />
  );
}

/* ============================================================
 * S10 · Galeri (editorial gallery)
 * ============================================================ */

function S10() {
  const { data: galeriData } = useGaleri();
  return (
    <Band id="galeri" tone="paper">
      <EditorialTitle
        kicker="Bagian Sepuluh — Galeri"
        judul="Wajah desa dalam gambar."
        href="/galeri"
        align="between"
        sectionKey="home-galeri"
      />
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-px bg-current/10">
        {galeriData.map((g, i) => (
          <Link
            key={g.judul}
            to="/galeri"
            className="group relative aspect-square overflow-hidden bg-background"
          >
            <img
              src={g.foto_url ? supabase.storage.from('seruni-media').getPublicUrl(g.foto_url).data.publicUrl : ""}
              alt={g.judul}
              loading="lazy"
              className="absolute inset-0 h-full w-full object-cover grayscale group-hover:grayscale-0 transition-all duration-500 group-hover:scale-[1.04]"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-[#0F0E0E]/80 via-transparent to-transparent" />
            <div className="absolute inset-x-0 bottom-0 p-4 sm:p-5">
              <p className="font-display text-[10px] font-bold uppercase tracking-[0.24em] text-accent">
                {String(i + 1).padStart(2, "0")}
              </p>
              <p className="mt-1 font-display text-sm sm:text-base font-semibold text-white leading-snug">
                {g.judul}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </Band>
  );
}

/* ============================================================
 * S11 · Aduan warga (editorial form, neutral)
 * ============================================================ */

function S11() {
  const { data: settings } = useSiteSettings();
  const { data: dusunList } = useDusun();
  const { data: kategoriList } = useAduanKategori();
  const [kategori, setKategori] = useState<string>('');
  const [terkirim, setTerkirim] = useState(false);
  const [lokasi, setLokasi] = useState<string>('');
  const inputCls =
    "mt-2 w-full border border-[#0F0E0E]/30 bg-transparent px-4 py-3 font-display text-sm text-[#0F0E0E] placeholder:text-[#0F0E0E]/40 focus:outline-none focus:border-accent transition-colors";
  const labelCls = "block font-display text-[11px] font-bold uppercase tracking-[0.28em] opacity-70";
  return (
    <Band id="aduan" tone="neutral">
      <EditorialTitle
        kicker="Bagian Sebelas — Service Center"
        judul="Sampaikan aduan. Kami tindak lanjuti."
        href="/service-center"
        sectionKey="home-aduan"
      />
      <div className="grid lg:grid-cols-[2fr_3fr] gap-10 lg:gap-16">
        <div className="border-t border-[#0F0E0E]/25 pt-8 lg:col-span-2">
          <p className="font-display text-lg sm:text-xl font-light leading-snug">
            Setiap aduan diteruskan otomatis ke petugas Service Center dan
            dieskalasi sesuai kategori. Nomor tiket dikirim via WhatsApp resmi
            desa yang terverifikasi.
          </p>
          <div className="mt-8 pt-6 border-t border-[#0F0E0E]/25 flex flex-wrap items-center justify-between gap-6">
            <div className="space-y-3 font-display text-[11px] uppercase tracking-[0.28em] font-semibold">
              <p className="opacity-70 mt-2">
                Layanan &middot; <span className="opacity-100 tabular-nums">{settings?.jam_layanan ?? "Senin - Jumat, 08:00 - 15:00"}</span>
              </p>
              <p className="opacity-70">
                Darurat &middot; <span className="opacity-100 tabular-nums">{settings?.telepon_darurat ?? "112"}</span>
              </p>
            </div>
            <Link
              to="/service-center"
              className="inline-flex font-display text-[11px] font-bold uppercase tracking-[0.28em] bg-primary text-primary-foreground px-8 py-4 hover:bg-accent hover:text-[#0F0E0E] transition-colors"
            >
              Kirim Laporan / Aduan
            </Link>
          </div>
        </div>
      </div>
    </Band>
  );
}

/* ============================================================
 * S12 · Peta desa (editorial split with layers)
 * ============================================================ */

function S12() {
  const petaLayer = [
    { kode: "wilayah", label: "Batas Wilayah", aktif: true },
    { kode: "aset", label: "Aset", aktif: true },
    { kode: "pbb", label: "Objek Pajak PBB", aktif: false },
    { kode: "bencana", label: "Zona Rawan Bencana", aktif: true },
    { kode: "pariwisata", label: "Destinasi Wisata", aktif: true },
    { kode: "layanan", label: "Fasilitas Layanan Publik", aktif: true },
  ];
  return (
    <Band id="peta" tone="dark">
      <EditorialTitle
        kicker="Bagian Dua Belas — Peta Desa"
        judul="Sebaran dan profil wilayah, satu pandangan."
        href="/peta-desa"
        invert
        sectionKey="home-peta"
      />
      <div className="grid lg:grid-cols-[1fr_2fr] gap-px bg-white/10">
        <aside className="bg-[#0F0E0E] p-8 sm:p-10">
          <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-6">
            Layer Peta
          </p>
          <ul className="divide-y divide-white/15 border-y border-white/20">
            {petaLayer.map((l) => (
              <li key={l.kode} className="py-3 flex items-center gap-4">
                <input
                  id={`layer-${l.kode}`}
                  type="checkbox"
                  defaultChecked={l.aktif}
                  className="h-4 w-4 border border-white/40 bg-transparent accent-[hsl(var(--accent))]"
                />
                <label htmlFor={`layer-${l.kode}`} className="font-display text-sm font-medium">
                  {l.label}
                </label>
              </li>
            ))}
          </ul>
          <p className="mt-6 text-xs opacity-60 leading-relaxed">
            Data bidang tanah warga tidak ditampilkan publik demi privasi.
          </p>
        </aside>
        <div className="relative bg-[#0F0E0E] min-h-[420px] overflow-hidden">
          <img
            src={""}
            alt="Peta Interaktif"
            className="absolute inset-0 h-full w-full object-cover opacity-40"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-tr from-[#0F0E0E] via-transparent to-transparent" />
          <div className="relative h-full grid place-items-center p-10">
            <div className="max-w-md text-center">
              <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Peta Interaktif
              </p>
              <p className="mt-4 font-display text-2xl sm:text-3xl font-bold italic tracking-tight">
                Klik titik untuk detail aset, layanan, dan zona wilayah.
              </p>
              <Link
                to="/peta-desa"
                className="mt-8 inline-block font-display text-[11px] font-bold uppercase tracking-[0.28em] border border-white/40 px-6 py-3 hover:border-accent hover:text-accent transition-colors"
              >
                Buka Peta Penuh
              </Link>
            </div>
          </div>
        </div>
      </div>
    </Band>
  );
}

export default function HomePage() {
  return (
    <>
      <Seo
        title="Kantor Desa — Portal Layanan Desa"
        description="Portal resmi untuk layanan surat, APBDes, pengaduan, agenda, dan status IDM secara transparan."
        path="/"
        jsonLd={{
          "@context": "https://schema.org",
          "@type": "GovernmentOrganization",
          name: "Kantor Desa",
          address: {
            "@type": "PostalAddress",
            addressCountry: "ID",
          },
        }}
      />
      <PageHero route="/" />
      <TaglineBar />
      <IntroBand>
        Portal resmi — satu jendela untuk pelayanan warga, transparansi pembangunan, dan partisipasi publik. Ditulis oleh warga, untuk warga.
      </IntroBand>
      <S1 />
      <StatistikBand />
      <S2 />
      <S3 />
      <S4 />
      <S5 />
      <S6 />
      <S7 />
      <S8 />
      <S9 />
      <QuoteKades />
      <S10 />
      <S11 />
      <S12 />
    </>
  );
}