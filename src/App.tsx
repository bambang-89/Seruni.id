import { lazy, Suspense, Component, ReactNode } from "react";
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import Layout from "./seruni/Layout";
import HomePage from "./seruni/HomePage";
import { AuthProvider } from "./seruni/lib/auth";
import { TenantProvider } from "./seruni/lib/tenant";
import LoginPage from "./seruni/admin/LoginPage";
import InitAdminPage from "./seruni/admin/InitAdminPage";
import { Toaster } from "sonner";
import { supabase } from "./integrations/supabase/client";

// Error Boundary component
class ErrorBoundary_disabled extends Component<{ children: ReactNode }, { hasError: boolean }> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100">
          <div className="text-center p-8">
            <h1 className="text-2xl font-bold mb-4">Terjadi kesalahan</h1>
            <p className="text-gray-600 mb-4">Halaman sedang dimuat ulang...</p>
            <button onClick={() => window.location.reload()} className="px-4 py-2 bg-primary text-white rounded">
              Reload
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

// Lazy-load admin bundles (heavy CRUD, only for signed-in admins).
const AdminShell = lazy(() => import("./seruni/admin/AdminShell"));
const AP = () => import("./seruni/admin/AdminPages");
const AO = () => import("./seruni/admin/AdminOps");
const AdminDashboard = lazy(() => AP().then((m) => ({ default: m.AdminDashboard })));
const ProfilDesaAdmin = lazy(() => AP().then((m) => ({ default: m.ProfilDesaAdmin })));
const PamongAdmin = lazy(() => AP().then((m) => ({ default: m.PamongAdmin })));
const DusunAdmin = lazy(() => AP().then((m) => ({ default: m.DusunAdmin })));
const LembagaAdmin = lazy(() => AP().then((m) => ({ default: m.LembagaAdmin })));
const BeritaAdmin = lazy(() => AP().then((m) => ({ default: m.BeritaAdmin })));
const AgendaAdmin = lazy(() => AP().then((m) => ({ default: m.AgendaAdmin })));
const PengumumanAdmin = lazy(() => AP().then((m) => ({ default: m.PengumumanAdmin })));
const GaleriAdmin = lazy(() => AP().then((m) => ({ default: m.GaleriAdmin })));
const BidangTanahAdmin = lazy(() => AO().then((m) => ({ default: m.BidangTanahAdmin })));
const InfrastrukturAdmin = lazy(() => AO().then((m) => ({ default: m.InfrastrukturAdmin })));
const KegiatanPembangunanAdmin = lazy(() => AO().then((m) => ({ default: m.KegiatanPembangunanAdmin })));
const PosyanduAdmin = lazy(() => AO().then((m) => ({ default: m.PosyanduAdmin })));
const StuntingAdmin = lazy(() => AO().then((m) => ({ default: m.StuntingAdmin })));
const BansosAdmin = lazy(() => AO().then((m) => ({ default: m.BansosAdmin })));
const PenerimaBansosAdmin = lazy(() => AO().then((m) => ({ default: m.PenerimaBansosAdmin })));
const BencanaAdmin = lazy(() => AO().then((m) => ({ default: m.BencanaAdmin })));
const AduanAdmin = lazy(() => AO().then((m) => ({ default: m.AduanAdmin })));
const DptAdmin = lazy(() => AO().then((m) => ({ default: m.DptAdmin })));
const JenisSuratAdmin = lazy(() => AO().then((m) => ({ default: m.JenisSuratAdmin })));
const EventLogAdmin = lazy(() => AO().then((m) => ({ default: m.EventLogAdmin })));
const SuratTerbitAdmin = lazy(() => AO().then((m) => ({ default: m.SuratTerbitAdmin })));
const LanggananWaAdmin = lazy(() => AO().then((m) => ({ default: m.LanggananWaAdmin })));
const BroadcastAdmin = lazy(() => AO().then((m) => ({ default: m.BroadcastAdmin })));
const UmkmAdmin = lazy(() => AO().then((m) => ({ default: m.UmkmAdmin })));
const ProdukMarketplaceAdmin = lazy(() => AO().then((m) => ({ default: m.ProdukMarketplaceAdmin })));
const WisataAdmin = lazy(() => AO().then((m) => ({ default: m.WisataAdmin })));
const PbbAdmin = lazy(() => AO().then((m) => ({ default: m.PbbAdmin })));
const ApbdesAdmin = lazy(() => AO().then((m) => ({ default: m.ApbdesAdmin })));
const AS = () => import("./seruni/admin/AdminSite");
const PageConfigAdmin = lazy(() => AS().then((m) => ({ default: m.PageConfigAdmin })));
const NavAdmin = lazy(() => AS().then((m) => ({ default: m.NavAdmin })));
const FooterAdmin = lazy(() => AS().then((m) => ({ default: m.FooterAdmin })));
const DraftQueueAdmin = lazy(() => AS().then((m) => ({ default: m.DraftQueueAdmin })));
const VersionHistoryAdmin = lazy(() => AS().then((m) => ({ default: m.VersionHistoryAdmin })));
const APR = () => import("./seruni/admin/AdminPartisipasi");
const RpjmdesPeriodeAdmin = lazy(() => APR().then((m) => ({ default: m.RpjmdesPeriodeAdmin })));
const RpjmdesBidangAdmin = lazy(() => APR().then((m) => ({ default: m.RpjmdesBidangAdmin })));
const RpjmdesProgramAdmin = lazy(() => APR().then((m) => ({ default: m.RpjmdesProgramAdmin })));
const RkpdesTahunAdmin = lazy(() => APR().then((m) => ({ default: m.RkpdesTahunAdmin })));
const RkpdesKegiatanAdmin = lazy(() => APR().then((m) => ({ default: m.RkpdesKegiatanAdmin })));
const UsulanAdmin = lazy(() => APR().then((m) => ({ default: m.UsulanAdmin })));
const VotingTopikAdmin = lazy(() => APR().then((m) => ({ default: m.VotingTopikAdmin })));
const VotingOpsiAdmin = lazy(() => APR().then((m) => ({ default: m.VotingOpsiAdmin })));
const AW = () => import("./seruni/admin/AdminWorkflow");
const SiteDraftAdmin = lazy(() => AW().then((m) => ({ default: m.SiteDraftAdmin })));
const SiteVersionAdmin = lazy(() => AW().then((m) => ({ default: m.SiteVersionAdmin })));
const VotingClosureAdmin = lazy(() => AW().then((m) => ({ default: m.VotingClosureAdmin })));

// Phase 2 + sisa Phase 5/6 — Penduduk & modul turunan
const APD = () => import("./seruni/admin/AdminPenduduk");
const KeluargaAdmin = lazy(() => APD().then((m) => ({ default: m.KeluargaAdmin })));
const PendudukAdmin = lazy(() => APD().then((m) => ({ default: m.PendudukAdmin })));
const BukuRegisterAdmin = lazy(() => APD().then((m) => ({ default: m.BukuRegisterAdmin })));
const IdmAdmin = lazy(() => APD().then((m) => ({ default: m.IdmAdmin })));
const AnalisisAdmin = lazy(() => APD().then((m) => ({ default: m.AnalisisAdmin })));
const SinkronLogAdmin = lazy(() => APD().then((m) => ({ default: m.SinkronLogAdmin })));
const SuplesiAdmin = lazy(() => APD().then((m) => ({ default: m.SuplesiAdmin })));

const PDP = () => import("./seruni/PendudukPages");
const StatistikPendudukLivePage = lazy(() => PDP().then((m) => ({ default: m.StatistikPendudukLivePage })));
const IDMLivePage = lazy(() => PDP().then((m) => ({ default: m.IDMLivePage })));
const AnalisisPage = lazy(() => PDP().then((m) => ({ default: m.AnalisisPage })));
const SuplesiPage = lazy(() => PDP().then((m) => ({ default: m.SuplesiPage })));

// Lazy-load public inner pages.
const P = () => import("./seruni/pages");
const ProfilDesaPage = lazy(() => P().then((m) => ({ default: m.ProfilDesaPage })));
const StrukturPage = lazy(() => P().then((m) => ({ default: m.StrukturPage })));
const WilayahPage = lazy(() => P().then((m) => ({ default: m.WilayahPage })));
const LembagaPage = lazy(() => P().then((m) => ({ default: m.LembagaPage })));
const BeritaListPage = lazy(() => P().then((m) => ({ default: m.BeritaListPage })));
const BeritaDetailPage = lazy(() => P().then((m) => ({ default: m.BeritaDetailPage })));
const KalenderPage = lazy(() => P().then((m) => ({ default: m.KalenderPage })));
const GaleriPage = lazy(() => P().then((m) => ({ default: m.GaleriPage })));
const PengumumanPage = lazy(() => P().then((m) => ({ default: m.PengumumanPage })));
const LayananPage = lazy(() => P().then((m) => ({ default: m.LayananPage })));
const LayananSuratPage = lazy(() => P().then((m) => ({ default: m.LayananSuratPage })));
const LayananPBBPage = lazy(() => P().then((m) => ({ default: m.LayananPBBPage })));
const ServiceCenterPage = lazy(() => P().then((m) => ({ default: m.ServiceCenterPage })));
const VerifikasiPage = lazy(() => P().then((m) => ({ default: m.VerifikasiPage })));
const StatistikHubPage = lazy(() => P().then((m) => ({ default: m.StatistikHubPage })));
const PembangunanPage = lazy(() => P().then((m) => ({ default: m.PembangunanPage })));
const PerencanaanPage = lazy(() => P().then((m) => ({ default: m.PerencanaanPage })));
const PotensiPage = lazy(() => P().then((m) => ({ default: m.PotensiPage })));
const MarketplacePage = lazy(() => P().then((m) => ({ default: m.MarketplacePage })));
const PetaPage = lazy(() => P().then((m) => ({ default: m.PetaPage })));
const LanggananWaPage = lazy(() => P().then((m) => ({ default: m.LanggananWaPage })));
const KeuanganPage = lazy(() => P().then((m) => ({ default: m.KeuanganPage })));
const NotFoundPage = lazy(() => P().then((m) => ({ default: m.NotFoundPage })));

// Phase 11 — Perencanaan & Partisipasi
const PP = () => import("./seruni/PartisipasiPages");
const RPJMDesPage = lazy(() => PP().then((m) => ({ default: m.RPJMDesPage })));
const RKPDesPage = lazy(() => PP().then((m) => ({ default: m.RKPDesPage })));
const UsulanPage = lazy(() => PP().then((m) => ({ default: m.UsulanPage })));
const VotingPage = lazy(() => PP().then((m) => ({ default: m.VotingPage })));
const RekapPage = lazy(() => PP().then((m) => ({ default: m.RekapPage })));

function RouteFallback() {
  return <div className="min-h-[40vh] grid place-items-center text-muted-foreground">Memuat…</div>;
}

export default function App() {
  return (
    <div>
      <AuthProvider>
        <TenantProvider supabaseClient={supabase} defaultTenantSlug="seruni-mumbul">
          <Toaster position="top-right" richColors />
          <BrowserRouter>
            <Suspense fallback={<RouteFallback />}>
              <Routes>
            {/* Admin (di luar Layout publik) */}
            <Route path="/admin/login" element={<LoginPage />} />
            <Route path="/admin/init" element={<InitAdminPage />} />
            <Route path="/admin" element={<AdminShell />}>
            <Route index element={<AdminDashboard />} />
            <Route path="profil-desa" element={<ProfilDesaAdmin />} />
            <Route path="struktur" element={<PamongAdmin />} />
            <Route path="wilayah" element={<DusunAdmin />} />
            <Route path="lembaga" element={<LembagaAdmin />} />
            <Route path="berita" element={<BeritaAdmin />} />
            <Route path="agenda" element={<AgendaAdmin />} />
            <Route path="pengumuman" element={<PengumumanAdmin />} />
            <Route path="galeri" element={<GaleriAdmin />} />
            {/* Modul operasional */}
            <Route path="pertanahan" element={<BidangTanahAdmin />} />
            <Route path="infrastruktur" element={<InfrastrukturAdmin />} />
            <Route path="kegiatan" element={<KegiatanPembangunanAdmin />} />
            <Route path="posyandu" element={<PosyanduAdmin />} />
            <Route path="stunting" element={<StuntingAdmin />} />
            <Route path="bansos" element={<BansosAdmin />} />
            <Route path="bansos-penerima" element={<PenerimaBansosAdmin />} />
            <Route path="bencana" element={<BencanaAdmin />} />
            <Route path="aduan" element={<AduanAdmin />} />
            <Route path="dpt" element={<DptAdmin />} />
            <Route path="jenis-surat" element={<JenisSuratAdmin />} />
            <Route path="surat-terbit" element={<SuratTerbitAdmin />} />
            <Route path="langganan-wa" element={<LanggananWaAdmin />} />
            <Route path="broadcast" element={<BroadcastAdmin />} />
            <Route path="umkm" element={<UmkmAdmin />} />
            <Route path="produk" element={<ProdukMarketplaceAdmin />} />
            <Route path="wisata" element={<WisataAdmin />} />
            <Route path="pbb" element={<PbbAdmin />} />
            <Route path="apbdes" element={<ApbdesAdmin />} />
            <Route path="event-log" element={<EventLogAdmin />} />
            <Route path="site/pages" element={<PageConfigAdmin />} />
            <Route path="site/nav" element={<NavAdmin />} />
            <Route path="site/footer" element={<FooterAdmin />} />
            <Route path="site/draft-queue" element={<DraftQueueAdmin />} />
            <Route path="site/version-history" element={<VersionHistoryAdmin />} />
            <Route path="rpjmdes-periode" element={<RpjmdesPeriodeAdmin />} />
            <Route path="rpjmdes-bidang" element={<RpjmdesBidangAdmin />} />
            <Route path="rpjmdes-program" element={<RpjmdesProgramAdmin />} />
            <Route path="rkpdes-tahun" element={<RkpdesTahunAdmin />} />
            <Route path="rkpdes-kegiatan" element={<RkpdesKegiatanAdmin />} />
            <Route path="usulan" element={<UsulanAdmin />} />
            <Route path="voting-topik" element={<VotingTopikAdmin />} />
            <Route path="voting-opsi" element={<VotingOpsiAdmin />} />
            <Route path="voting-closure" element={<VotingClosureAdmin />} />
            <Route path="site/drafts" element={<SiteDraftAdmin />} />
            <Route path="site/versions" element={<SiteVersionAdmin />} />
            <Route path="keluarga" element={<KeluargaAdmin />} />
            <Route path="penduduk" element={<PendudukAdmin />} />
            <Route path="buku-register" element={<BukuRegisterAdmin />} />
            <Route path="idm" element={<IdmAdmin />} />
            <Route path="analisis" element={<AnalisisAdmin />} />
            <Route path="sinkron-log" element={<SinkronLogAdmin />} />
            <Route path="suplesi" element={<SuplesiAdmin />} />
          </Route>

          <Route element={<Layout />}>
          <Route index element={<HomePage />} />

          {/* Profil */}
          <Route path="profil-desa" element={<ProfilDesaPage />} />
          <Route path="profil-desa/struktur" element={<StrukturPage />} />
          <Route path="profil-desa/wilayah" element={<WilayahPage />} />
          <Route path="profil-desa/lembaga" element={<LembagaPage />} />

          {/* Informasi */}
          <Route path="berita" element={<BeritaListPage />} />
          <Route path="berita/:slug" element={<BeritaDetailPage />} />
          <Route path="kalender-desa" element={<KalenderPage />} />
          <Route path="galeri" element={<GaleriPage />} />
          <Route path="pengumuman" element={<PengumumanPage />} />

          {/* Layanan */}
          <Route path="layanan" element={<LayananPage />} />
          <Route path="layanan/surat" element={<LayananSuratPage />} />
          <Route path="layanan/pbb" element={<LayananPBBPage />} />
          <Route path="service-center" element={<ServiceCenterPage />} />
          <Route path="verifikasi" element={<VerifikasiPage />} />

          {/* Data & Statistik */}
          <Route path="statistik" element={<StatistikHubPage />} />
          <Route path="status-idm" element={<IDMLivePage />} />
          <Route path="statistik/penduduk" element={<StatistikPendudukLivePage />} />
          <Route path="analisis" element={<AnalisisPage />} />
          <Route path="pembangunan" element={<PembangunanPage />} />
          <Route path="perencanaan" element={<PerencanaanPage />} />
          <Route path="perencanaan/rpjmdes" element={<RPJMDesPage />} />
          <Route path="perencanaan/rkpdes" element={<RKPDesPage />} />
          <Route path="perencanaan/rekap" element={<RekapPage />} />
          <Route path="partisipasi/usulan" element={<UsulanPage />} />
          <Route path="partisipasi/voting" element={<VotingPage />} />
          <Route path="keuangan" element={<KeuanganPage />} />

          {/* Potensi */}
          <Route path="potensi-desa" element={<PotensiPage />} />
          <Route path="marketplace" element={<MarketplacePage />} />

          {/* Peta */}
          <Route path="peta-desa" element={<PetaPage />} />

          {/* Notifikasi */}
          <Route path="langganan-wa" element={<LanggananWaPage />} />
          <Route path="layanan/suplesi" element={<SuplesiPage />} />

          {/* Redirects & 404 */}
          <Route path="kontak" element={<Navigate to="/service-center" replace />} />
          <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
        </Suspense>
        </BrowserRouter>
      </TenantProvider>
    </AuthProvider>
    </div>
  );
}