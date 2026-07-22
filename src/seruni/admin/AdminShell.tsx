import { Link, NavLink, Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "../lib/auth";
import { siteSettings as seedSettings } from "../data";
import { useSiteSettings } from "../lib/zeroHardcode";

const navGroups: { title: string; items: { to: string; label: string; end?: boolean }[] }[] = [
  {
    title: "Umum",
    items: [{ to: "/admin", label: "Dashboard", end: true }],
  },
  {
    title: "Fondasi",
    items: [
      { to: "/admin/profil-desa", label: "Profil Desa" },
      { to: "/admin/struktur", label: "Struktur Pamong" },
      { to: "/admin/wilayah", label: "Wilayah Dusun" },
      { to: "/admin/lembaga", label: "Lembaga" },
    ],
  },
  {
    title: "Informasi",
    items: [
      { to: "/admin/berita", label: "Berita" },
      { to: "/admin/agenda", label: "Agenda" },
      { to: "/admin/pengumuman", label: "Pengumuman" },
      { to: "/admin/galeri", label: "Galeri" },
    ],
  },
  {
    title: "Layanan",
    items: [
      { to: "/admin/jenis-surat", label: "Jenis Surat" },
      { to: "/admin/surat-terbit", label: "Surat Terbit" },
      { to: "/admin/aduan", label: "Aduan Warga" },
      { to: "/admin/langganan-wa", label: "Langganan WA" },
      { to: "/admin/broadcast", label: "Broadcast WA" },
    ],
  },
  {
    title: "Keuangan & Pajak",
    items: [
      { to: "/admin/apbdes", label: "APBDes" },
      { to: "/admin/pbb", label: "PBB Tagihan" },
    ],
  },
  {
    title: "Pembangunan",
    items: [
      { to: "/admin/kegiatan", label: "Kegiatan" },
      { to: "/admin/infrastruktur", label: "Infrastruktur" },
    ],
  },
  {
    title: "Kesehatan",
    items: [
      { to: "/admin/posyandu", label: "Posyandu" },
      { to: "/admin/stunting", label: "Stunting" },
    ],
  },
  {
    title: "Sosial",
    items: [
      { to: "/admin/bansos", label: "Program Bansos" },
      { to: "/admin/bansos-penerima", label: "Penerima Bansos" },
    ],
  },
  {
    title: "Potensi & Peta",
    items: [
      { to: "/admin/umkm", label: "UMKM / BUMDes" },
      { to: "/admin/produk", label: "Produk Marketplace" },
      { to: "/admin/wisata", label: "Destinasi Wisata" },
    ],
  },
  {
    title: "Kebencanaan",
    items: [{ to: "/admin/bencana", label: "Kejadian Bencana" }],
  },
  {
    title: "Pemilu",
    items: [{ to: "/admin/dpt", label: "DPT Pemilih" }],
  },
  {
    title: "Kependudukan",
    items: [
      { to: "/admin/keluarga", label: "Kartu Keluarga" },
      { to: "/admin/penduduk", label: "Penduduk" },
      { to: "/admin/suplesi", label: "Suplesi Data" },
    ],
  },
  {
    title: "Analisis & IDM",
    items: [
      { to: "/admin/idm", label: "IDM Indikator" },
      { to: "/admin/analisis", label: "Analisis Snapshot" },
    ],
  },
  {
    title: "Administrasi Umum",
    items: [
      { to: "/admin/buku-register", label: "Buku Register" },
      { to: "/admin/sinkron-log", label: "Log Sinkronisasi" },
    ],
  },
  {
    title: "Audit",
    items: [{ to: "/admin/event-log", label: "Event Log" }],
  },
  {
    title: "Perencanaan",
    items: [
      { to: "/admin/rpjmdes-periode", label: "RPJMDes: Periode" },
      { to: "/admin/rpjmdes-bidang", label: "RPJMDes: Bidang" },
      { to: "/admin/rpjmdes-program", label: "RPJMDes: Program" },
      { to: "/admin/rkpdes-tahun", label: "RKPDes: Tahun" },
      { to: "/admin/rkpdes-kegiatan", label: "RKPDes: Kegiatan" },
    ],
  },
  {
    title: "Partisipasi",
    items: [
      { to: "/admin/usulan", label: "Usulan Warga" },
      { to: "/admin/voting-topik", label: "Voting: Topik" },
      { to: "/admin/voting-opsi", label: "Voting: Opsi" },
      { to: "/admin/voting-closure", label: "Voting: Penutupan" },
    ],
  },
  {
    title: "Situs Publik",
    items: [
      { to: "/admin/site/pages", label: "Halaman & Hero" },
      { to: "/admin/site/nav", label: "Menu Navbar" },
      { to: "/admin/site/footer", label: "Kolom Footer" },
      { to: "/admin/site/drafts", label: "Draft & Publish" },
      { to: "/admin/site/versions", label: "Riwayat Versi" },
    ],
  },
];

export default function AdminShell() {
  const { user, isAdmin, loading, signOut } = useAuth();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const loc = useLocation();

  if (loading) {
    return <div className="min-h-screen grid place-items-center text-muted-foreground">Memuat sesi…</div>;
  }
  if (!user) {
    return <Navigate to="/admin/login" replace state={{ from: loc.pathname }} />;
  }
  if (!isAdmin) {
    return (
      <div className="min-h-screen grid place-items-center p-8">
        <div className="max-w-md text-center space-y-4">
          <h1 className="font-display text-2xl font-bold">Akses ditolak</h1>
          <p className="text-muted-foreground">Akun Anda belum memiliki peran admin desa.</p>
          <button onClick={signOut} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium">
            Keluar
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex bg-secondary text-foreground">
      <aside className="w-64 shrink-0 bg-primary text-primary-foreground flex flex-col">
        <div className="px-5 py-5 border-b border-white/10">
          <div className="font-display text-xs uppercase tracking-widest text-accent">Admin Portal</div>
          <div className="font-display font-semibold leading-tight mt-1">{siteName}</div>
        </div>
        <nav className="flex-1 p-3 space-y-4 overflow-y-auto">
          {navGroups.map((g) => (
            <div key={g.title}>
              <div className="px-3 pb-1 text-[10px] uppercase tracking-widest text-primary-foreground/50 font-semibold">
                {g.title}
              </div>
              <div className="space-y-1">
                {g.items.map((n) => (
                  <NavLink
                    key={n.to}
                    to={n.to}
                    end={n.end}
                    className={({ isActive }) =>
                      `block px-3 py-2 rounded-md text-sm font-medium ${isActive ? "bg-accent text-primary" : "hover:bg-white/10"}`
                    }
                  >
                    {n.label}
                  </NavLink>
                ))}
              </div>
            </div>
          ))}
        </nav>
        <div className="p-3 border-t border-white/10 space-y-2">
          <Link to="/" className="block text-xs text-primary-foreground/70 hover:text-accent">
            ← Lihat portal publik
          </Link>
          <button onClick={signOut} className="w-full rounded-md bg-white/10 hover:bg-white/20 px-3 py-2 text-sm">
            Keluar
          </button>
        </div>
      </aside>
      <main className="flex-1 min-w-0">
        <div className="p-6 sm:p-8 max-w-5xl">
          <Outlet />
        </div>
      </main>
    </div>
  );
}