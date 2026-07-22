import { useState } from "react";
import { Link } from "react-router-dom";
import {
  siteSettings as seedSettings,
  marketplaceProduk,
} from "./data";
import { SectionWrap, formatTanggal } from "./ui";
import { Seo } from "./lib/seo";
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
import heroImg from "@/assets/hero-village.jpg";
import portraitKades from "@/assets/portrait-kepala-desa.jpg";
import wartaPasar from "@/assets/warta-pasar.jpg";
import potensiLansekap from "@/assets/potensi-lansekap.jpg";
import umkmTenun from "@/assets/umkm-tenun.jpg";

function Hero() {
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const namaTanpaDesa = siteName.replace(/^Desa\s+/i, "");
  return (
    <section
      aria-label="Identitas desa"
      className="relative isolate overflow-hidden bg-primary text-primary-foreground min-h-screen"
    >
      {/* Full-bleed background photo */}
      <img
        src={heroImg}
        alt="Panorama pesisir dan pegunungan Desa Seruni Mumbul saat matahari terbenam"
        width={1920}
        height={1080}
        className="absolute inset-0 h-full w-full object-cover"
        fetchPriority="high"
      />
      {/* Cinematic scrim — dark top so navbar reads, dark bottom so wordmark reads */}
      <div aria-hidden className="absolute inset-0 bg-gradient-to-b from-primary/70 via-primary/20 to-primary/85" />
      <div aria-hidden className="absolute inset-x-0 top-0 h-40 bg-gradient-to-b from-black/60 to-transparent" />

      {/* Content layer — clear vertical rhythm so navbar never collides with copy */}
      <div className="relative flex flex-col min-h-screen pt-[180px] md:pt-[200px] pb-6">
        <div className="flex-1" />

        {/* Subtitle: hanya wilayah administratif */}
        <div className="mx-4 sm:mx-6 lg:mx-8 pb-4">
          <p className="font-display text-sm sm:text-base md:text-lg uppercase tracking-[0.28em] text-accent drop-shadow">
            {settings?.wilayah ?? seedSettings.wilayah}
          </p>
        </div>

        {/* Giant wordmark — auto-fit satu baris via SVG, tanpa prefix "Desa" */}
        <div className="relative">
          <div aria-hidden className="mx-4 sm:mx-6 lg:mx-8 border-t border-primary-foreground/40" />
          <div className="px-4 sm:px-6 lg:px-8 pt-3">
            <svg
              viewBox="0 0 100 15"
              preserveAspectRatio="xMidYMid meet"
              className="block w-full h-auto drop-shadow-lg"
              role="img"
              aria-label={siteName}
            >
              <text
                x="50"
                y="12.5"
                textAnchor="middle"
                fontFamily="var(--font-display, Poppins), sans-serif"
                fontWeight={500}
                fontSize="14"
                letterSpacing="-0.4"
                fill="#ffffff"
                style={{ opacity: 1 }}
              >
                {namaTanpaDesa}
              </text>
            </svg>
          </div>
        </div>
      </div>
    </section>
  );
}

function TaglineBar() {
  const { data: settings } = useSiteSettings();
  return (
    <div className="bg-accent text-[#0F0E0E] border-y border-[#0F0E0E]/10">
      <div className="mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 py-4 flex flex-wrap items-center justify-between gap-4">
        <span className="font-display text-[11px] sm:text-xs font-bold uppercase tracking-[0.28em]">
          {settings?.tagline ?? seedSettings.tagline}
        </span>
        <span className="font-display text-[10px] sm:text-[11px] font-semibold uppercase tracking-[0.28em] opacity-70 tabular-nums">
          {settings?.jam_layanan ?? seedSettings.jam_layanan}
        </span>
      </div>
    </div>
  );
}

/* ============================================================
 * S1 · Sambutan + selayang pandang (editorial split)
 * ============================================================ */

function S1() {
  return (
    <EditorialSplit
      kicker="Bagian Satu — Tentang"
      judul="Desa pesisir di kaki timur Rinjani."
      image={portraitKades}
      imageAlt="Potret Kepala Desa Seruni Mumbul"
      tone="paper"
      href="/profil-desa"
      hrefLabel="Kenali Desa"
    >
      <p>
        Seruni Mumbul dibentuk pada 1968 sebagai pemekaran dari Desa Pringgabaya.
        Dikenal dengan hamparan padi, tenun songket, dan pantai berpasir putih,
        desa ini berdiri di antara laut dan gunung — sebuah ruang hidup yang
        menautkan kerja tani, warisan tenun, dan keramahan warga pesisir.
      </p>
      <p>
        Portal ini adalah rumah data satu pintu: pelayanan, informasi
        pembangunan, dan partisipasi warga — semuanya terbuka dan dapat
        ditelusuri.
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
      items={[
        { nilai: `${statistik.luas_wilayah_km2}`, label: "Luas Wilayah (km²)" },
        { nilai: statistik.jumlah_dusun.toString(), label: "Jumlah Dusun" },
        { nilai: statistik.jumlah_penduduk.toLocaleString("id-ID"), label: "Jumlah Penduduk", highlight: true },
        { nilai: statistik.jumlah_kk.toLocaleString("id-ID"), label: "Jumlah Kepala Keluarga" },
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
        judul={`Status ${idmData.status}, skor ${idmData.skor_total.toFixed(4)}.`}
        href="/status-idm"
      />
      <div className="grid lg:grid-cols-[1fr_2fr] gap-10 lg:gap-16 items-start">
        <div className="border-t border-b border-[#0F0E0E]/20 py-8">
          <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] opacity-60">
            Skor Komposit
          </p>
          <p className="mt-4 font-display text-6xl sm:text-7xl font-bold italic tracking-tight tabular-nums text-primary">
            {idmData.skor_total.toFixed(4)}
          </p>
          <p className="mt-6 font-display text-xs font-bold uppercase tracking-[0.22em]">
            <span className="text-accent">■</span> Status · {idmData.status}
          </p>
          <p className="mt-6 text-sm leading-relaxed opacity-75">
            Diagregasi dari enam dimensi ketahanan desa dan dimutakhirkan pada
            setiap siklus pelaporan tahunan.
          </p>
        </div>
        <ul className="divide-y divide-[#0F0E0E]/15 border-y border-[#0F0E0E]/20">
          {idmData.dimensi.map((d, i) => (
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
      />
      <div className="grid lg:grid-cols-[3fr_2fr] gap-10 lg:gap-16 items-start">
        <NumberedList
          tone="dark"
          items={agendaData.map((a) => ({
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
      />
      <div className="grid lg:grid-cols-[3fr_2fr] gap-10 lg:gap-16 items-start">
        {utama && (
          <FeaturedCard
            image={wartaPasar}
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
  // TODO: Wire to useSuratAggregate hook
  const { data: layananData } = useState<Array<{kode: string; nama: string; jumlah_bulan: number}>>([
    { kode: "SKD", nama: "Surat Keterangan Domisili", jumlah_bulan: 128 },
    { kode: "F5_PBB", nama: "Pembayaran PBB Online", jumlah_bulan: 96 },
    { kode: "SPN", nama: "Surat Pengantar Nikah", jumlah_bulan: 42 },
    { kode: "INFRASTRUKTUR", nama: "Aduan Infrastruktur", jumlah_bulan: 37 },
  ]);
  return (
    <Band id="layanan" tone="navy">
      <EditorialTitle
        kicker="Bagian Lima — Layanan"
        judul="Ajukan permohonan tanpa antre di kantor desa."
        href="/layanan"
        invert
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
      image={umkmTenun}
      imageAlt="Tangan warga menenun kain songket di alat tenun kayu"
      tone="paper"
      reverse
      href="/marketplace"
      hrefLabel="Jelajahi Marketplace"
    >
      <div className="grid sm:grid-cols-2 gap-10">
        <Kolom judul="Terlaris" items={marketplaceProduk.terlaris} />
        <Kolom judul="Terbaru" items={marketplaceProduk.terbaru} />
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
      />
      <div className="grid lg:grid-cols-3 gap-px bg-white/10 mb-14">
        {[
          { l: "Progres Fisik Rata-Rata", v: `${pembangunanData.progres_fisik_avg}`, suffix: "%" },
          { l: "Anggaran Terserap", v: `${pembangunanData.anggaran_terserap_pct}`, suffix: "%" },
          { l: "Aset Baru Terbentuk", v: pembangunanData.aset_baru.toString(), suffix: "" },
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
          {pembangunanData.kegiatan_aktif.map((k, i) => (
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
  const max = Math.max(...(usulanData.top10 || []).map((u) => u.suara));
  return (
    <Band id="perencanaan" tone="neutral">
      <EditorialTitle
        kicker="Bagian Delapan — Perencanaan"
        judul="Sepuluh usulan warga dengan dukungan tertinggi."
        href="/perencanaan"
      />
      <p className="font-display text-sm sm:text-base opacity-75 mb-10 max-w-3xl">
        <span className="tabular-nums font-semibold text-primary">{usulanData.total_usulan}</span>{" "}
        usulan masuk ·{" "}
        <span className="tabular-nums font-semibold text-primary">
          {usulanData.partisipasi_voting.toLocaleString("id-ID")}
        </span>{" "}
        suara terkumpul dari warga desa.
      </p>
      <ol className="divide-y divide-[#0F0E0E]/15 border-y border-[#0F0E0E]/25">
        {usulanData.top10.map((u, i) => (
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
  const { data: umkmData } = usePotensiUmkm();
  // Transform data for display
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
            src={potensiLansekap}
            alt="Lansekap rice terraces dan pantai Desa Seruni Mumbul"
            className="absolute inset-0 h-full w-full object-cover"
            loading="lazy"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0F0E0E] via-[#0F0E0E]/40 to-transparent" />
          <div className="absolute inset-x-0 bottom-0 mx-auto max-w-7xl px-6 sm:px-8 lg:px-12 pb-10 sm:pb-14">
            <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-accent mb-4">
              Bagian Sembilan — Potensi Desa
            </p>
            <h2 className="font-display text-3xl sm:text-5xl lg:text-6xl font-bold italic tracking-tight max-w-4xl leading-[1.02]">
              Di antara laut, sawah, dan warisan tangan.
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
              <div className="mt-8 pt-6 border-t border-white/20">
                <p className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">BUMDes</p>
                <p className="mt-2 font-display text-lg font-semibold">{"BUMDes Bina Seruni Mandiri"}</p>
              </div>
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
  return (
    <QuoteBand
      quote="Pemerintahan desa yang baik tidak diukur dari kemegahan kantor, melainkan dari cepatnya warga mendapatkan haknya."
      nama="H. Amirudin, S.Sos"
      jabatan="Kepala Desa Seruni Mumbul"
      image={portraitKades}
      imageAlt="Potret Kepala Desa Seruni Mumbul"
    />
  );
}

/* ============================================================
 * S10 · Galeri (editorial gallery)
 * ============================================================ */

function S10() {
  const { data: galeriData } = useGaleri();
  const covers = [wartaPasar, umkmTenun, potensiLansekap, heroImg, portraitKades, wartaPasar];
  return (
    <Band id="galeri" tone="paper">
      <EditorialTitle
        kicker="Bagian Sepuluh — Galeri"
        judul="Wajah desa dalam gambar."
        href="/galeri"
        align="between"
      />
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-px bg-current/10">
        {galeriData.map((g, i) => (
          <Link
            key={g.judul}
            to="/galeri"
            className="group relative aspect-square overflow-hidden bg-background"
          >
            <img
              src={covers[i % covers.length]}
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
  // TODO: Wire to ref_aduan_kategori table
  const aduanKategori = [
    { kode: "infrastruktur", label: "Infrastruktur (jalan, jembatan, PJU)" },
    { kode: "pelayanan", label: "Pelayanan Publik" },
    { kode: "lingkungan", label: "Lingkungan & Kebersihan" },
    { kode: "sosial", label: "Kesejahteraan Sosial" },
    { kode: "keamanan", label: "Keamanan & Ketertiban" },
  ];
  const [kategori, setKategori] = useState<string>('infrastruktur');
  const [terkirim, setTerkirim] = useState(false);
  const inputCls =
    "mt-2 w-full border border-[#0F0E0E]/30 bg-transparent px-4 py-3 font-display text-sm text-[#0F0E0E] placeholder:text-[#0F0E0E]/40 focus:outline-none focus:border-accent transition-colors";
  const labelCls = "block font-display text-[11px] font-bold uppercase tracking-[0.28em] opacity-70";
  return (
    <Band id="aduan" tone="neutral">
      <EditorialTitle
        kicker="Bagian Sebelas — Service Center"
        judul="Sampaikan aduan. Kami tindak lanjuti."
        href="/service-center"
      />
      <div className="grid lg:grid-cols-[2fr_3fr] gap-10 lg:gap-16">
        <div className="border-t border-[#0F0E0E]/25 pt-8">
          <p className="font-display text-lg sm:text-xl font-light leading-snug">
            Setiap aduan diteruskan otomatis ke petugas Service Center dan
            dieskalasi sesuai kategori. Nomor tiket dikirim via WhatsApp resmi
            desa yang terverifikasi.
          </p>
          <div className="mt-8 pt-6 border-t border-[#0F0E0E]/25 space-y-3 font-display text-[11px] uppercase tracking-[0.28em] font-semibold">
            <p className="opacity-70">
              Layanan · <span className="opacity-100 tabular-nums">{seedSettings.jam_layanan}</span>
            </p>
            <p className="opacity-70">
              Darurat · <span className="opacity-100 tabular-nums">{seedSettings.telepon_darurat}</span>
            </p>
          </div>
        </div>
        {terkirim ? (
          <div className="border border-accent bg-accent/10 p-10">
            <p className="font-display text-[11px] font-bold uppercase tracking-[0.28em] text-primary">
              Aduan Diterima
            </p>
            <p className="mt-4 font-display text-2xl sm:text-3xl font-bold italic tracking-tight">
              Terima kasih atas partisipasi Anda.
            </p>
            <p className="mt-4 text-sm opacity-75">
              Nomor tiket telah dikirim ke nomor WhatsApp yang terdaftar.
            </p>
            <button
              type="button"
              onClick={() => setTerkirim(false)}
              className="mt-8 inline-block font-display text-[11px] font-bold uppercase tracking-[0.28em] border border-current px-6 py-3 hover:border-accent hover:text-accent transition-colors"
            >
              Kirim Aduan Lain
            </button>
          </div>
        ) : (
          <form
            className="border border-[#0F0E0E]/25 p-8 sm:p-10 space-y-6 bg-background"
            onSubmit={(e) => {
              e.preventDefault();
              setTerkirim(true);
            }}
          >
            <div className="grid sm:grid-cols-2 gap-6">
              <label>
                <span className={labelCls}>Kategori</span>
                <select
                  value={kategori}
                  onChange={(e) => setKategori(e.target.value)}
                  className={inputCls}
                >
                  {aduanKategori.map((k) => (
                    <option key={k.kode} value={k.kode}>
                      {k.label}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                <span className={labelCls}>Lokasi</span>
                <input
                  required
                  type="text"
                  placeholder="Dusun Karang Baru, RT 04"
                  className={inputCls}
                />
              </label>
            </div>
            <label className="block">
              <span className={labelCls}>Uraian Aduan</span>
              <textarea
                required
                rows={4}
                placeholder="Ceritakan kejadian, kapan terjadi, dan dampaknya."
                className={inputCls}
              />
            </label>
            <label className="block">
              <span className={labelCls}>Nomor WhatsApp Pelapor</span>
              <input
                required
                type="tel"
                placeholder="08xxxxxxxxxx"
                className={inputCls}
              />
            </label>
            <div className="pt-4 border-t border-[#0F0E0E]/20 flex flex-wrap items-center justify-between gap-4">
              <p className="text-xs opacity-60 max-w-sm">
                Data pelapor dirahasiakan. Verifikasi via OTP WhatsApp.
              </p>
              <button
                type="submit"
                className="font-display text-[11px] font-bold uppercase tracking-[0.28em] bg-primary text-primary-foreground px-6 py-3 hover:bg-accent hover:text-[#0F0E0E] transition-colors"
              >
                Kirim Aduan
              </button>
            </div>
          </form>
        )}
      </div>
    </Band>
  );
}

/* ============================================================
 * S12 · Peta desa (editorial split with layers)
 * ============================================================ */

function S12() {
  // Default layers - can be fetched from site_settings
  const petaLayer = [
    { kode: "wilayah", label: "Batas Wilayah & Burnett", aktif: true },
    { kode: "aset", label: "Aset Burnett", aktif: true },
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
            src={potensiLansekap}
            alt="Peta interaktif lansekap Desa Seruni Mumbul"
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
        title="Kantor Desa Seruni Mumbul — Portal Layanan Desa"
        description="Portal resmi Desa Seruni Mumbul: layanan surat, APBDes, pengaduan, agenda, dan status IDM secara transparan."
        path="/"
        jsonLd={{
          "@context": "https://schema.org",
          "@type": "GovernmentOrganization",
          name: "Kantor Desa Seruni Mumbul",
          address: {
            "@type": "PostalAddress",
            addressLocality: "Jerowaru",
            addressRegion: "Lombok Timur, NTB",
            addressCountry: "ID",
          },
        }}
      />
      <Hero />
      <TaglineBar />
      <IntroBand>
        Portal resmi Desa Seruni Mumbul — satu jendela untuk pelayanan warga,
        transparansi pembangunan, dan partisipasi publik. Ditulis oleh warga,
        untuk warga.
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