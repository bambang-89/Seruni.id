import { lazy, Suspense, Component, ReactNode } from "react";
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import Layout from "./seruni/Layout";
import HomePage from "./seruni/HomePage";
import { StandaloneLayout } from "./seruni/ui";
import { AuthProvider } from "./seruni/lib/auth";
import { TenantProvider } from "./seruni/lib/tenant";
import { ConfirmPromptProvider } from "./seruni/ui/ConfirmDialog";
import LoginPage from "./seruni/admin/LoginPage";
import InitAdminPage from "./seruni/admin/InitAdminPage";
import { Toaster } from "sonner";
import { supabase } from "./integrations/supabase/client";

// Error Boundary - catches React component errors gracefully
class ErrorBoundary extends Component<{ children: ReactNode; fallback?: ReactNode }, { hasError: boolean; error?: Error }> {
  constructor(props: { children: ReactNode; fallback?: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError(error: Error) {
    console.error("React Error Boundary caught:", error);
    return { hasError: true, error };
  }
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error("Error Boundary error:", error, errorInfo);
  }
  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="text-center p-8 max-w-md">
            <div className="mb-4">
              <svg className="w-16 h-16 mx-auto text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.833-3.464-1.833A2.5 2.5 0 002.5 4.5c0 1.023.2 1.985.563 2.81M12 21a9 9 0 100-18 9 9 9 0 0018 9z" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Terjadi Kesalahan</h1>
            <p className="text-gray-600 mb-6">Kami mohon maaf, terjadi kesalahan tak terduga. Silakan coba muat ulang halaman.</p>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 bg-primary text-white rounded-lg font-medium hover:bg-primary/90 transition-colors"
            >
              Muat Ulang Halaman
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
const AdminDashboard = lazy(() => AP().then((m) => ({ default: m.AdminDashboard })));
const PamongAdmin = lazy(() => AP().then((m) => ({ default: m.PamongAdmin })));
const LembagaAdmin = lazy(() => AP().then((m) => ({ default: m.LembagaAdmin })));
const BeritaAdmin = lazy(() => AP().then((m) => ({ default: m.BeritaAdmin })));
const AgendaAdmin = lazy(() => AP().then((m) => ({ default: m.AgendaAdmin })));
const PengumumanAdmin = lazy(() => AP().then((m) => ({ default: m.PengumumanAdmin })));
const GaleriAdmin = lazy(() => AP().then((m) => ({ default: m.GaleriAdmin })));
const BidangTanahAdmin = lazy(() => AP().then((m) => ({ default: m.BidangTanahAdmin })));
const InfrastrukturAdmin = lazy(() => AP().then((m) => ({ default: m.InfrastrukturAdmin })));
const KegiatanPembangunanAdmin = lazy(() => AP().then((m) => ({ default: m.KegiatanPembangunanAdmin })));
const PosyanduAdmin = lazy(() => AP().then((m) => ({ default: m.PosyanduAdmin })));
const StuntingAdmin = lazy(() => AP().then((m) => ({ default: m.StuntingAdmin })));
const BansosAdmin = lazy(() => AP().then((m) => ({ default: m.BansosAdmin })));
const PenerimaBansosAdmin = lazy(() => AP().then((m) => ({ default: m.PenerimaBansosAdmin })));
const BencanaAdmin = lazy(() => AP().then((m) => ({ default: m.BencanaAdmin })));
const AduanAdmin = lazy(() => AP().then((m) => ({ default: m.AduanAdmin })));
const DptAdmin = lazy(() => AP().then((m) => ({ default: m.DptAdmin })));
const JenisSuratAdmin = lazy(() => AP().then((m) => ({ default: m.JenisSuratAdmin })));
const SuratTerbitAdmin = lazy(() => AP().then((m) => ({ default: m.SuratTerbitAdmin })));
const CetakSuratTerbitAdmin = lazy(() => AP().then((m) => ({ default: m.CetakSuratTerbitAdmin })));
const LanggananWaAdmin = lazy(() => AP().then((m) => ({ default: m.LanggananWaAdmin })));
const BroadcastAdmin = lazy(() => AP().then((m) => ({ default: m.BroadcastAdmin })));
const UmkmAdmin = lazy(() => AP().then((m) => ({ default: m.UmkmAdmin })));
const ProdukMarketplaceAdmin = lazy(() => AP().then((m) => ({ default: m.ProdukMarketplaceAdmin })));
const WisataAdmin = lazy(() => AP().then((m) => ({ default: m.WisataAdmin })));
const PbbAdmin = lazy(() => AP().then((m) => ({ default: m.PbbAdmin })));
const ApbdesAdmin = lazy(() => AP().then((m) => ({ default: m.ApbdesAdmin })));
const SuratAjuanAdmin = lazy(() => AP().then((m) => ({ default: m.SuratAjuanAdmin })));
const SuratAjuanPreviewPage = lazy(() => AP().then((m) => ({ default: m.SuratAjuanPreviewPage })));
const BalitaAdmin = lazy(() => AP().then((m) => ({ default: m.BalitaAdmin })));
const WaChatbotAdmin = lazy(() => AP().then((m) => ({ default: m.WaChatbotAdmin })));
const EventLogAdmin = lazy(() => AP().then((m) => ({ default: m.EventLogAdmin })));
const AdminUmum = lazy(() => import("./seruni/admin/AdminUmum"));
const SuratPersyaratanAdmin = lazy(() => AP().then((m) => ({ default: m.SuratPersyaratanAdmin })));
const WA = () => import("./seruni/admin/WilayahAdmin");
const RefDusunAdmin = lazy(() => WA().then((m) => ({ default: m.DusunAdmin })));
const RefRtAdmin = lazy(() => WA().then((m) => ({ default: m.RtAdmin })));
const RefRwAdmin = lazy(() => WA().then((m) => ({ default: m.RwAdmin })));
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
const HeroAdmin = lazy(() => import("./seruni/admin/HeroAdmin").then((m) => ({ default: m.HeroAdmin })));

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
const StatusIDMPage = lazy(() => P().then((m) => ({ default: m.StatusIDMPage })));
const StatistikPendudukPage = lazy(() => P().then((m) => ({ default: m.StatistikPendudukPage })));

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
const SuratAjuanFormPage = lazy(() => import("./seruni/SuratAjuanPage").then((m) => ({ default: m.default })));
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
const BansosPage = lazy(() => P().then((m) => ({ default: m.BansosPage })));
const StuntingPage = lazy(() => P().then((m) => ({ default: m.StuntingPage })));
const PosyanduPage = lazy(() => P().then((m) => ({ default: m.PosyanduPage })));
const BencanaPage = lazy(() => P().then((m) => ({ default: m.BencanaPage })));
const NotFoundPage = lazy(() => P().then((m) => ({ default: m.NotFoundPage })));

// Task F3 — Detail page lazy imports
const AgendaDetailPage = lazy(() => P().then((m) => ({ default: m.AgendaDetailPage })));
const GaleriDetailPage = lazy(() => P().then((m) => ({ default: m.GaleriDetailPage })));
const PengumumanDetailPage = lazy(() => P().then((m) => ({ default: m.PengumumanDetailPage })));
const PosyanduDetailPage = lazy(() => P().then((m) => ({ default: m.PosyanduDetailPage })));
const StuntingDetailPage = lazy(() => P().then((m) => ({ default: m.StuntingDetailPage })));
const UmkmDetailPage = lazy(() => P().then((m) => ({ default: m.UmkmDetailPage })));
const ProdukDetailPage = lazy(() => P().then((m) => ({ default: m.ProdukDetailPage })));
const WisataDetailPage = lazy(() => P().then((m) => ({ default: m.WisataDetailPage })));
const PembangunanDetailPage = lazy(() => P().then((m) => ({ default: m.PembangunanDetailPage })));
const BansosDetailPage = lazy(() => P().then((m) => ({ default: m.BansosDetailPage })));
const AduanDetailPage = lazy(() => P().then((m) => ({ default: m.AduanDetailPage })));
const IdmIndikatorDetailPage = lazy(() => P().then((m) => ({ default: m.IdmIndikatorDetailPage })));
const PendudukDetailPage = lazy(() => P().then((m) => ({ default: m.PendudukDetailPage })));
const KeluargaDetailPage = lazy(() => P().then((m) => ({ default: m.KeluargaDetailPage })));
const BalitaDetailPage = lazy(() => P().then((m) => ({ default: m.BalitaDetailPage })));
const BalitaPage = lazy(() => P().then((m) => ({ default: m.BalitaPage })));
const PertanahanPage = lazy(() => P().then((m) => ({ default: m.PertanahanPage })));
const BidangTanahDetailPage = lazy(() => P().then((m) => ({ default: m.BidangTanahDetailPage })));
const InfrastrukturPage = lazy(() => P().then((m) => ({ default: m.InfrastrukturPage })));
const InfrastrukturDetailPage = lazy(() => P().then((m) => ({ default: m.InfrastrukturDetailPage })));
const PbbPage = lazy(() => P().then((m) => ({ default: m.PbbPage })));
const PbbDetailPage = lazy(() => P().then((m) => ({ default: m.PbbDetailPage })));
const SuratTerbitPage = lazy(() => P().then((m) => ({ default: m.SuratTerbitPage })));
const SuratTerbitDetailPage = lazy(() => P().then((m) => ({ default: m.SuratTerbitDetailPage })));
const BencanaDetailPage = lazy(() => P().then((m) => ({ default: m.BencanaDetailPage })));
const UsulanWargaDetailPage = lazy(() => P().then((m) => ({ default: m.UsulanWargaDetailPage })));
const VotingTopikDetailPage = lazy(() => P().then((m) => ({ default: m.VotingTopikDetailPage })));
const RpjmdesBidangDetailPage = lazy(() => P().then((m) => ({ default: m.RpjmdesBidangDetailPage })));
const RpjmdesProgramDetailPage = lazy(() => P().then((m) => ({ default: m.RpjmdesProgramDetailPage })));
const RkpdesKegiatanDetailPage = lazy(() => P().then((m) => ({ default: m.RkpdesKegiatanDetailPage })));

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
    <ErrorBoundary>
      <AuthProvider>
        <TenantProvider supabaseClient={supabase} defaultTenantSlug="seruni-mumbul">
          <ConfirmPromptProvider>
          <Toaster position="top-right" richColors />
          <BrowserRouter>
            <Suspense fallback={<RouteFallback />}>
              <Routes>
            {/* Admin (di luar Layout publik) */}
            <Route path="/admin/login" element={<LoginPage />} />
            <Route path="/admin/init" element={<InitAdminPage />} />
            <Route path="/admin" element={<AdminShell />}>
            <Route index element={<AdminDashboard />} />
            <Route path="profil-desa" element={<AdminUmum />} />
            <Route path="struktur" element={<PamongAdmin />} />
            <Route path="wilayah" element={<RefDusunAdmin />} />
            <Route path="wilayah-rt" element={<RefRtAdmin />} />
            <Route path="wilayah-rw" element={<RefRwAdmin />} />
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
            <Route path="surat-terbit/cetak/:id" element={<CetakSuratTerbitAdmin />} />
            <Route path="langganan-wa" element={<LanggananWaAdmin />} />
            <Route path="broadcast" element={<BroadcastAdmin />} />
            <Route path="umkm" element={<UmkmAdmin />} />
            <Route path="produk" element={<ProdukMarketplaceAdmin />} />
            <Route path="wisata" element={<WisataAdmin />} />
            <Route path="pbb" element={<PbbAdmin />} />
            <Route path="apbdes" element={<ApbdesAdmin />} />
            <Route path="surat-ajuan" element={<SuratAjuanAdmin />} />
            <Route path="surat-ajuan/preview/:id" element={<SuratAjuanPreviewPage />} />
            <Route path="persyaratan-surat" element={<SuratPersyaratanAdmin />} />
            <Route path="balita" element={<BalitaAdmin />} />
            <Route path="wa-chatbot" element={<WaChatbotAdmin />} />
            <Route path="event-log" element={<EventLogAdmin />} />
            <Route path="site" element={<Navigate to="/admin/site/pages" replace />} />
            <Route path="site/pages" element={<PageConfigAdmin />} />
            <Route path="site/nav" element={<NavAdmin />} />
            <Route path="site/footer" element={<FooterAdmin />} />
            <Route path="site/draft-queue" element={<DraftQueueAdmin />} />
            <Route path="site/version-history" element={<VersionHistoryAdmin />} />
            <Route path="site/hero" element={<HeroAdmin />} />
            <Route path="workflow" element={<Navigate to="/admin/site/drafts" replace />} />
            <Route path="partisipasi" element={<Navigate to="/admin/usulan" replace />} />
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
            <Route path="*" element={
              <div className="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
                <h1 className="text-4xl font-bold text-gray-900 mb-2">404</h1>
                <h2 className="text-lg font-medium text-gray-700 mb-4">Halaman Tidak Ditemukan</h2>
                <p className="text-gray-500 mb-6">Maaf, jalur atau modul yang Anda tuju tidak tersedia atau belum dikonfigurasi.</p>
              </div>
            } />
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
          <Route path="kalender-desa" element={<KalenderPage />} />
          <Route path="galeri" element={<GaleriPage />} />
          <Route path="pengumuman" element={<PengumumanPage />} />

          {/* Layanan */}
          <Route path="layanan" element={<LayananPage />} />
          <Route path="layanan/surat" element={<LayananSuratPage />} />
          <Route path="layanan/surat/:id" element={<SuratAjuanFormPage />} />
          <Route path="layanan/pbb" element={<LayananPBBPage />} />
          <Route path="service-center" element={<ServiceCenterPage />} />
          <Route path="verifikasi" element={<VerifikasiPage />} />
          <Route path="layanan/verify/:id" element={<VerifikasiPage />} />
          <Route path="layanan/verify" element={<VerifikasiPage />} />
          <Route path="verify/:id" element={<VerifikasiPage />} />
          <Route path="verify" element={<VerifikasiPage />} />

          {/* Data & Statistik */}
          <Route path="statistik" element={<StatistikHubPage />} />
          <Route path="status-idm" element={<IDMLivePage />} />
          <Route path="status-idm-detail" element={<StatusIDMPage />} />
          <Route path="statistik/penduduk" element={<StatistikPendudukLivePage />} />
          <Route path="statistik-penduduk" element={<StatistikPendudukPage />} />
          <Route path="analisis" element={<AnalisisPage />} />
          <Route path="bansos" element={<BansosPage />} />
          <Route path="stunting" element={<StuntingPage />} />
          <Route path="posyandu" element={<PosyanduPage />} />
          <Route path="bencana" element={<BencanaPage />} />
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

          {/* Standalone Detail Pages */}
          <Route element={<StandaloneLayout />}>
            <Route path="berita/:slug" element={<BeritaDetailPage />} />
            <Route path="agenda/:id" element={<AgendaDetailPage />} />
            <Route path="galeri/:id" element={<GaleriDetailPage />} />
            <Route path="pengumuman/:id" element={<PengumumanDetailPage />} />
            <Route path="posyandu/:id" element={<PosyanduDetailPage />} />
            <Route path="stunting/:id" element={<StuntingDetailPage />} />
            <Route path="umkm/:id" element={<UmkmDetailPage />} />
            <Route path="produk/:id" element={<ProdukDetailPage />} />
            <Route path="wisata/:id" element={<WisataDetailPage />} />
            <Route path="pembangunan/:id" element={<PembangunanDetailPage />} />
            <Route path="bansos/:id" element={<BansosDetailPage />} />
            <Route path="aduan/:id" element={<AduanDetailPage />} />
            <Route path="idm-detail/:id" element={<IdmIndikatorDetailPage />} />
            <Route path="penduduk/:id" element={<PendudukDetailPage />} />
            <Route path="keluarga/:id" element={<KeluargaDetailPage />} />
            <Route path="balita" element={<BalitaPage />} />
            <Route path="balita/:id" element={<BalitaDetailPage />} />
            <Route path="pertanahan" element={<PertanahanPage />} />
            <Route path="pertanahan/:id" element={<BidangTanahDetailPage />} />
            <Route path="infrastruktur" element={<InfrastrukturPage />} />
            <Route path="infrastruktur/:id" element={<InfrastrukturDetailPage />} />
            <Route path="bencana/:id" element={<BencanaDetailPage />} />
            <Route path="usulan/:id" element={<UsulanWargaDetailPage />} />
            <Route path="voting/:id" element={<VotingTopikDetailPage />} />
            <Route path="pbb" element={<PbbPage />} />
            <Route path="pbb/:id" element={<PbbDetailPage />} />
            <Route path="surat-terbit" element={<SuratTerbitPage />} />
            <Route path="surat-terbit/:id" element={<SuratTerbitDetailPage />} />
            <Route path="rpjmdes-bidang/:id" element={<RpjmdesBidangDetailPage />} />
            <Route path="rpjmdes-program/:id" element={<RpjmdesProgramDetailPage />} />
            <Route path="rkpdes-kegiatan/:id" element={<RkpdesKegiatanDetailPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
        </Suspense>
        </BrowserRouter>
          </ConfirmPromptProvider>
        </TenantProvider>
      </AuthProvider>
    </ErrorBoundary>
  );
}