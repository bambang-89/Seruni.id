
import { Link, NavLink, Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "../lib/auth";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useSiteSettings } from "../lib/zeroHardcode";
import { useTenantId } from "../lib/tenant";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronDown, ChevronRight, LogOut, Menu, X, Home, Users, FileText, Settings, Database, Activity, Globe, LayoutDashboard, Heart, ShieldAlert, BookOpen, MessageSquare, CreditCard, Box, Map, Smartphone, PanelLeftClose, PanelLeftOpen } from "lucide-react";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from "@/components/ui/breadcrumb";

const navGroups = [
  {
    title: "Umum",
    icon: Home,
    items: [
      { to: "/admin", label: "Dashboard", end: true },
      { to: "/admin/profil-desa", label: "Identitas Desa" },
    ],
  },
  {
    title: "Pengaturan Penduduk",
    icon: Users,
    items: [
      { to: "/admin/penduduk", label: "Penduduk" },
      { to: "/admin/keluarga", label: "Kartu Keluarga" },
      { to: "/admin/suplesi", label: "Suplesi Data" },
    ],
  },
  {
    title: "Pengaturan Layanan",
    icon: FileText,
    items: [
      { to: "/admin/jenis-surat", label: "Daftar Jenis Surat" },
      { to: "/admin/persyaratan-surat", label: "Persyaratan Surat" },
      { to: "/admin/surat-ajuan", label: "Pengajuan Surat" },
      { to: "/admin/surat-terbit", label: "Surat Terbit" },
      { to: "/admin/buku-register", label: "Buku Register Surat" },
      { to: "/admin/template-surat", label: "Pengaturan Template Surat" },
      { to: "/admin/aduan", label: "Aduan Warga" },
    ],
  },
  {
    title: "Fondasi & Wilayah",
    icon: Database,
    items: [
      { to: "/admin/visi-misi", label: "Visi, Misi & Sejarah" },
      { to: "/admin/struktur", label: "Struktur Pamong" },
      { to: "/admin/wilayah", label: "Wilayah Dusun" },
      { to: "/admin/wilayah-rt", label: "Wilayah RT" },
      { to: "/admin/wilayah-rw", label: "Wilayah RW" },
      { to: "/admin/lembaga", label: "Lembaga" },
    ],
  },
  {
    title: "Partisipasi",
    icon: MessageSquare,
    items: [
      { to: "/admin/usulan", label: "Usulan Warga" },
      { to: "/admin/voting-topik", label: "Voting: Topik" },
      { to: "/admin/voting-opsi", label: "Voting: Opsi" },
      { to: "/admin/voting-closure", label: "Voting: Penutupan" },
    ],
  },
  {
    title: "Informasi",
    icon: BookOpen,
    items: [
      { to: "/admin/berita", label: "Berita" },
      { to: "/admin/agenda", label: "Agenda" },
      { to: "/admin/pengumuman", label: "Pengumuman" },
      { to: "/admin/galeri", label: "Galeri" },
    ],
  },
  {
    title: "WhatsApp",
    icon: Smartphone,
    items: [
      { to: "/admin/langganan-wa", label: "Langganan WA" },
      { to: "/admin/broadcast", label: "Broadcast WA" },
      { to: "/admin/wa-chatbot", label: "Chatbot Monitor" },
    ],
  },
  {
    title: "Keuangan & Pajak",
    icon: CreditCard,
    items: [
      { to: "/admin/apbdes", label: "APBDes" },
      { to: "/admin/pbb", label: "PBB Tagihan" },
    ],
  },
  {
    title: "Pembangunan",
    icon: Activity,
    items: [
      { to: "/admin/kegiatan", label: "Kegiatan" },
      { to: "/admin/infrastruktur", label: "Infrastruktur" },
    ],
  },
  {
    title: "Kesehatan",
    icon: Heart,
    items: [
      { to: "/admin/posyandu", label: "Posyandu" },
      { to: "/admin/balita", label: "Data Balita" },
      { to: "/admin/stunting", label: "Stunting" },
    ],
  },
  {
    title: "Sosial",
    icon: Users,
    items: [
      { to: "/admin/bansos", label: "Program Bansos" },
      { to: "/admin/bansos-penerima", label: "Penerima Bansos" },
    ],
  },
  {
    title: "Potensi & Peta",
    icon: Map,
    items: [
      { to: "/admin/umkm", label: "UMKM / BUMDes" },
      { to: "/admin/produk", label: "Produk Marketplace" },
      { to: "/admin/wisata", label: "Destinasi Wisata" },
    ],
  },
  {
    title: "Kebencanaan",
    icon: ShieldAlert,
    items: [{ to: "/admin/bencana", label: "Kejadian Bencana" }],
  },
  {
    title: "Pemilu",
    icon: Box,
    items: [{ to: "/admin/dpt", label: "DPT Pemilih" }],
  },
  {
    title: "Analisis & IDM",
    icon: Activity,
    items: [
      { to: "/admin/idm", label: "IDM Indikator" },
      { to: "/admin/analisis", label: "Analisis Snapshot" },
    ],
  },
  {
    title: "Perencanaan",
    icon: LayoutDashboard,
    items: [
      { to: "/admin/rpjmdes-periode", label: "RPJMDes: Periode" },
      { to: "/admin/rpjmdes-bidang", label: "RPJMDes: Bidang" },
      { to: "/admin/rpjmdes-program", label: "RPJMDes: Program" },
      { to: "/admin/rkpdes-tahun", label: "RKPDes: Tahun" },
      { to: "/admin/rkpdes-kegiatan", label: "RKPDes: Kegiatan" },
    ],
  },
  {
    title: "Audit & Sistem",
    icon: Settings,
    items: [
      { to: "/admin/sinkron-log", label: "Log Sinkronisasi" },
      { to: "/admin/event-log", label: "Event Log" },
    ],
  },
  {
    title: "Situs Publik",
    icon: Globe,
    items: [
      { to: "/admin/site/pages", label: "Halaman & Hero" },
      { to: "/admin/site/hero", label: "Manajemen Hero" },
      { to: "/admin/site/nav", label: "Menu Navbar" },
      { to: "/admin/site/footer", label: "Kolom Footer" },
      { to: "/admin/site/drafts", label: "Draft & Publish" },
      { to: "/admin/site/versions", label: "Riwayat Versi" },
    ],
  },
];

const NavGroup = ({ group, pathname, ajuanPendingCount, ajuanDiprosesCount, collapsed }: any) => {
  const isActive = group.items.some((item: any) => {
    const rawPath = pathname.replace("/admin", "").replace(/^\/|\/$/g, "");
    const normalizedPath = rawPath.replace(/\//g, "") || "dashboard";
    const itemPath = item.to.replace("/admin", "").replace(/\//g, "") || "dashboard";
    return normalizedPath === itemPath;
  });

  const [isOpen, setIsOpen] = useState(isActive);
  const Icon = group.icon;

  useEffect(() => {
    if (isActive && !isOpen && !collapsed) setIsOpen(true);
    if (collapsed && isOpen) setIsOpen(false);
  }, [isActive, collapsed, isOpen]);

  const toggleGroup = () => {
    if (collapsed) return; // Do not toggle if collapsed
    setIsOpen(!isOpen);
  };

  const groupContent = (
    <div className="mb-2">
      <button 
        onClick={toggleGroup} 
        className={`w-full flex items-center ${collapsed ? 'justify-center' : 'justify-between'} px-3 py-2.5 rounded-lg transition-all duration-200 ${isActive && collapsed ? "bg-primary text-primary-foreground" : isOpen ? "bg-primary/5 text-primary dark:bg-primary/10" : "text-muted-foreground hover:bg-muted hover:text-foreground"}`}
      >
        <div className="flex items-center gap-3">
          <Icon className="w-5 h-5 shrink-0" />
          {!collapsed && <span className="text-sm font-medium tracking-wide truncate">{group.title}</span>}
        </div>
        {!collapsed && (
          <motion.div animate={{ rotate: isOpen ? 180 : 0 }} transition={{ duration: 0.2 }}>
            <ChevronDown className="w-4 h-4 opacity-50 shrink-0" />
          </motion.div>
        )}
      </button>
      
      {!collapsed && (
        <AnimatePresence initial={false}>
          {isOpen && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: "auto", opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              transition={{ duration: 0.2, ease: "easeInOut" }}
              className="overflow-hidden"
            >
              <div className="space-y-1 mt-1 pl-4 border-l-2 border-border/50 ml-5 py-1">
                {group.items.map((n: any) => (
                  <NavLink
                    key={n.to}
                    to={n.to}
                    end={n.end}
                    className={({ isActive: linkActive }) =>
                      `block px-3 py-2 rounded-md text-sm font-medium transition-all relative overflow-hidden group ${
                        linkActive 
                          ? "text-primary bg-primary/5 font-semibold" 
                          : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                      }`
                    }
                  >
                    {({ isActive: linkActive }) => (
                      <>
                        {linkActive && (
                          <motion.div 
                            layoutId="active-nav-indicator"
                            className="absolute left-0 top-0 bottom-0 w-1 bg-primary rounded-r-full"
                            transition={{ type: "spring", stiffness: 300, damping: 30 }}
                          />
                        )}
                        <div className="flex items-center justify-between z-10 relative">
                          <span className="pl-1 truncate">{n.label}</span>
                          {n.to === "/admin/surat-ajuan" && ajuanPendingCount > 0 && (
                            <span className="bg-destructive text-destructive-foreground text-[10px] font-bold px-2 py-0.5 rounded-full shadow-sm animate-pulse">{ajuanPendingCount}</span>
                          )}
                          {n.to === "/admin/surat-terbit" && ajuanDiprosesCount > 0 && (
                            <span className="bg-amber-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full shadow-sm">{ajuanDiprosesCount}</span>
                          )}
                        </div>
                      </>
                    )}
                  </NavLink>
                ))}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      )}
    </div>
  );

  if (collapsed) {
    return (
      <TooltipProvider delayDuration={0}>
        <Tooltip>
          <TooltipTrigger asChild>
            {groupContent}
          </TooltipTrigger>
          <TooltipContent side="right" className="flex flex-col gap-1 p-2">
            <span className="font-semibold text-xs text-muted-foreground mb-1">{group.title}</span>
            {group.items.map((n: any) => (
              <NavLink key={n.to} to={n.to} end={n.end} className={({ isActive }) => `text-sm hover:underline ${isActive ? 'text-primary font-bold' : ''}`}>
                {n.label}
              </NavLink>
            ))}
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
  }

  return groupContent;
};

export default function AdminShell() {
  const { user, isAdmin, loading, signOut } = useAuth();
  const { data: settings } = useSiteSettings();
  const tenantId = useTenantId();
  const siteName = settings?.nama_resmi ?? "Desa Seruni";
  const loc = useLocation();

  const [ajuanPendingCount, setAjuanPendingCount] = useState(0);
  const [ajuanDiprosesCount, setAjuanDiprosesCount] = useState(0);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [pageTitle, setPageTitle] = useState("");

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 1024);
      if (window.innerWidth >= 1024) {
        setSidebarOpen(true);
      } else {
        setSidebarOpen(false);
      }
    };
    
    checkMobile();
    window.addEventListener("resize", checkMobile);
    return () => window.removeEventListener("resize", checkMobile);
  }, []);

  useEffect(() => {
    if (isMobile) {
      setSidebarOpen(false);
    }
  }, [loc.pathname, isMobile]);

  useEffect(() => {
    if (!isAdmin || !tenantId) return;

    const fetchCounts = async () => {
      const { count: pending } = await supabase
        .from("surat_ajuan")
        .select("*", { count: "exact", head: true })
        .eq("tenant_id", tenantId)
        .eq("status", "menunggu");
      const { count: diproses } = await supabase
        .from("surat_ajuan")
        .select("*", { count: "exact", head: true })
        .eq("tenant_id", tenantId)
        .eq("status", "diproses");
        
      setAjuanPendingCount(pending || 0);
      setAjuanDiprosesCount(diproses || 0);
    };

    fetchCounts();

    const sub = supabase
      .channel("surat_ajuan_changes")
      .on("postgres_changes", { event: "*", schema: "public", table: "surat_ajuan", filter: `tenant_id=eq.${tenantId}` }, () => {
        fetchCounts();
      })
      .subscribe();

    return () => {
      supabase.removeChannel(sub);
    };
  }, [isAdmin, tenantId]);

  useEffect(() => {
    const rawPath = loc.pathname.replace("/admin", "").replace(/^\/|\/$/g, "");
    const normalizedPath = rawPath.replace(/\//g, "") || "dashboard";
    const flat = Object.values(navGroups).flat();
    const match = flat.find((n: any) => n && n.to && n.to.replace("/admin", "").replace(/\//g, "") === normalizedPath);
    const title = (match as any)?.label || (normalizedPath === "dashboard" ? "Dashboard" : normalizedPath);
    setPageTitle(title);
    document.title = `${title} — ${siteName}`;
  }, [loc.pathname, siteName]);

  if (loading) {
    return (
      <div className="min-h-screen grid place-items-center bg-background">
        <motion.div 
          animate={{ scale: [1, 1.1, 1], opacity: [0.5, 1, 0.5] }} 
          transition={{ repeat: Infinity, duration: 1.5 }}
          className="text-primary flex flex-col items-center gap-4"
        >
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
          <p className="text-muted-foreground font-medium tracking-wide">Memuat sesi admin...</p>
        </motion.div>
      </div>
    );
  }
  
  if (!user) {
    return <Navigate to="/admin/login" replace state={{ from: loc.pathname }} />;
  }
  
  if (!isAdmin) {
    return (
      <div className="min-h-screen grid place-items-center p-8 bg-background">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="max-w-md text-center space-y-6 bg-card p-8 rounded-2xl shadow-lg border border-border"
        >
          <div className="w-16 h-16 bg-destructive/10 rounded-full flex items-center justify-center mx-auto">
            <ShieldAlert className="w-8 h-8 text-destructive" />
          </div>
          <div>
            <h1 className="font-display text-2xl font-bold text-foreground mb-2">Akses Ditolak</h1>
            <p className="text-muted-foreground">Akun Anda belum memiliki peran admin desa. Silakan hubungi pengelola untuk mendapatkan akses.</p>
          </div>
          <button 
            onClick={signOut} 
            className="w-full rounded-xl bg-primary text-primary-foreground px-4 py-3 text-sm font-semibold shadow-md hover:bg-primary/90 transition-all"
          >
            Keluar dari Akun
          </button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="h-screen flex bg-background text-foreground overflow-hidden selection:bg-primary/20">
      {/* Mobile Sidebar Overlay */}
      <AnimatePresence>
        {isMobile && sidebarOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSidebarOpen(false)}
            className="fixed inset-0 bg-background/80 backdrop-blur-sm z-40 lg:hidden"
          />
        )}
      </AnimatePresence>

      {/* Sidebar */}
      <AnimatePresence initial={false}>
        {(sidebarOpen || !isMobile) && (
          <motion.aside 
            initial={{ x: "-100%" }}
            animate={{ x: 0 }}
            exit={{ x: "-100%" }}
            transition={{ type: "spring", bounce: 0, duration: 0.3 }}
            className={`fixed lg:static inset-y-0 left-0 z-50 ${sidebarCollapsed ? "w-[72px]" : "w-72"} shrink-0 bg-card/50 backdrop-blur-xl flex flex-col h-full border-r border-border shadow-2xl lg:shadow-none transition-all duration-300`}
          >
            <div className={`px-4 py-6 border-b border-border flex items-center ${sidebarCollapsed ? 'justify-center' : 'justify-between'} shrink-0 bg-card/50 h-[73px]`}>
              {!sidebarCollapsed && (
                <div>
                  <div className="font-display text-[10px] font-bold uppercase tracking-[0.25em] text-primary mb-1">Admin Portal</div>
                  <div className="font-display text-lg font-bold leading-tight text-foreground line-clamp-1">{siteName}</div>
                </div>
              )}
              {sidebarCollapsed && (
                <div className="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary font-bold">
                  {siteName.charAt(0).toUpperCase()}
                </div>
              )}
              {isMobile && (
                <button 
                  onClick={() => setSidebarOpen(false)}
                  className="p-2 -mr-2 text-muted-foreground hover:bg-muted hover:text-foreground rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              )}
            </div>
            
            <nav className="flex-1 min-h-0 overflow-y-auto overflow-x-hidden px-3 py-6 custom-scrollbar space-y-1.5">
              {navGroups.map((g) => (
                <NavGroup 
                  key={g.title} 
                  group={g} 
                  pathname={loc.pathname} 
                  ajuanPendingCount={ajuanPendingCount} 
                  ajuanDiprosesCount={ajuanDiprosesCount} 
                  collapsed={sidebarCollapsed && !isMobile}
                />
              ))}
            </nav>
            
            <div className="p-3 border-t border-border bg-card/50 shrink-0 backdrop-blur-xl">
              <div className={`flex items-center ${sidebarCollapsed ? 'justify-center' : 'gap-3 px-3'} py-2 mb-2`}>
                <TooltipProvider delayDuration={0}>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold shrink-0">
                        {user.email?.charAt(0).toUpperCase() || 'A'}
                      </div>
                    </TooltipTrigger>
                    {sidebarCollapsed && <TooltipContent side="right">{user.email}</TooltipContent>}
                  </Tooltip>
                </TooltipProvider>
                {!sidebarCollapsed && (
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{user.email}</p>
                    <p className="text-xs text-muted-foreground truncate">Administrator</p>
                  </div>
                )}
              </div>
              
              {!sidebarCollapsed && (
                <>
                  <Link 
                    to="/" 
                    target="_blank"
                    className="w-full flex items-center justify-between px-4 py-2.5 rounded-lg text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors group"
                  >
                    <span>Lihat Situs Publik</span>
                    <Globe className="w-4 h-4 opacity-50 group-hover:opacity-100 transition-opacity shrink-0" />
                  </Link>
                  <button 
                    onClick={signOut} 
                    className="w-full flex items-center justify-between px-4 py-2.5 rounded-lg text-sm font-medium text-destructive hover:bg-destructive/10 transition-colors group"
                  >
                    <span>Keluar Aplikasi</span>
                    <LogOut className="w-4 h-4 opacity-50 group-hover:opacity-100 transition-opacity shrink-0" />
                  </button>
                </>
              )}
            </div>
          </motion.aside>
        )}
      </AnimatePresence>

      {/* Main Content Area */}
      <main className="flex-1 min-w-0 flex flex-col h-screen overflow-hidden bg-background">
        
        {/* Desktop Topbar */}
        {!isMobile && (
          <header className="h-[73px] flex items-center justify-between px-6 border-b border-border bg-card/50 backdrop-blur-xl z-30 shrink-0">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
                className="p-2 -ml-2 rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                title={sidebarCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
              >
                {sidebarCollapsed ? <PanelLeftOpen className="w-5 h-5" /> : <PanelLeftClose className="w-5 h-5" />}
              </button>
              
              <Breadcrumb>
                <BreadcrumbList>
                  <BreadcrumbItem>
                    <BreadcrumbLink asChild>
                      <Link to="/admin">Dashboard</Link>
                    </BreadcrumbLink>
                  </BreadcrumbItem>
                  {pageTitle !== "Dashboard" && (
                    <>
                      <BreadcrumbSeparator />
                      <BreadcrumbItem>
                        <BreadcrumbPage>{pageTitle}</BreadcrumbPage>
                      </BreadcrumbItem>
                    </>
                  )}
                </BreadcrumbList>
              </Breadcrumb>
            </div>
            
            <div className="flex items-center gap-4">
              <Link to="/" target="_blank" className="p-2 rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors" title="Lihat Situs Publik">
                <Globe className="w-5 h-5" />
              </Link>
              <div className="w-px h-6 bg-border mx-1"></div>
              <button onClick={signOut} className="flex items-center gap-2 p-2 rounded-md text-destructive hover:bg-destructive/10 transition-colors">
                <LogOut className="w-4 h-4" />
                <span className="text-sm font-medium">Keluar</span>
              </button>
            </div>
          </header>
        )}

        {/* Mobile Header */}
        {isMobile && (
          <header className="flex items-center justify-between p-4 border-b border-border bg-card/50 backdrop-blur-xl z-30 shrink-0">
            <div className="flex items-center gap-3">
              <button 
                onClick={() => setSidebarOpen(true)}
                className="p-2 -ml-2 text-muted-foreground hover:text-foreground transition-colors"
              >
                <Menu className="w-6 h-6" />
              </button>
              <span className="font-display font-semibold truncate">{pageTitle}</span>
            </div>
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-sm shrink-0">
              {user.email?.charAt(0).toUpperCase() || 'A'}
            </div>
          </header>
        )}

        {/* Page Content with Transitions */}
        <div className="flex-1 overflow-y-auto overflow-x-hidden relative scroll-smooth custom-scrollbar">
          <div className="p-4 sm:p-6 md:p-8 lg:p-10 max-w-7xl mx-auto w-full min-h-full pb-24">
            <AnimatePresence mode="wait">
              <motion.div
                key={loc.pathname}
                initial={{ opacity: 0, y: 15, filter: 'blur(4px)' }}
                animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
                exit={{ opacity: 0, y: -15, filter: 'blur(4px)' }}
                transition={{ duration: 0.3, ease: "easeInOut" }}
                className="h-full"
              >
                <Outlet />
              </motion.div>
            </AnimatePresence>
          </div>
        </div>
      </main>
    </div>
  );
}
