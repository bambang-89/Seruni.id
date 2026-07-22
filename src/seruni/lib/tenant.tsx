// ============================================================
// MULTI-TENANT ROUTING — Vite/React SPA
//
// Since this is a SPA (not Next.js), subdomain routing is handled:
// 1. Client-side: parse hostname to extract subdomain
// 2. React Context: provide tenant context globally
// 3. Supabase: all queries filtered by tenant_id
//
// For Next.js migration: use middleware.ts for server-side subdomain parsing
// ============================================================

import { createContext, useContext, useEffect, useState, ReactNode } from "react";

// ============================================================
// TYPES
// ============================================================

export interface Tenant {
  id: string;
  slug: string;
  nama_resmi: string;
  tagline?: string;
  logo_url?: string;
  warna_primer?: string;
  warna_aksen?: string;
  kontak?: {
    telepon?: string;
    whatsapp?: string;
    email?: string;
  };
  alamat?: {
    jalan?: string;
    desa?: string;
    kecamatan?: string;
    kabupaten?: string;
    provinsi?: string;
    kodepos?: string;
  };
  jam_layanan?: {
    hari?: string;
    jam?: string;
  };
  is_active: boolean;
}

interface TenantContextValue {
  tenant: Tenant | null;
  loading: boolean;
  error: string | null;
  setTenantBySlug: (slug: string) => Promise<void>;
  setTenantById: (id: string) => Promise<void>;
}

// ============================================================
// CONTEXT
// ============================================================

const TenantContext = createContext<TenantContextValue | null>(null);

export function useTenant(): TenantContextValue {
  const ctx = useContext(TenantContext);
  if (!ctx) {
    throw new Error("useTenant() must be used within <TenantProvider>");
  }
  return ctx;
}

// ============================================================
// SUBDOMAIN PARSING
// ============================================================

/**
 * Parse subdomain from hostname
 * Examples:
 *   seruni.desa.id        → "seruni"
 *   localhost:8080        → null (falls back to default)
 *   app.seruni.com        → "app" (if allowed)
 */
export function parseSubdomain(hostname?: string): string | null {
  if (!hostname) return null;

  const host = hostname.split(":")[0]; // Remove port
  const parts = host.split(".");

  // localhost or single-word domain
  if (parts.length === 1) {
    return null;
  }

  // For domains like subdomain.seruni.id
  // parts[0] = subdomain, parts[1] = seruni, parts[2] = id
  if (parts.length >= 3) {
    const subdomain = parts[0].toLowerCase();

    // Skip common non-tenant subdomains
    const reserved = ["www", "api", "admin", "app", "mail", "webmail", "smtp", "ftp"];
    if (reserved.includes(subdomain)) {
      return null;
    }

    return subdomain;
  }

  return null;
}

/**
 * Get the base domain for the application
 */
export function getBaseDomain(): string {
  if (typeof window === "undefined") {
    return process.env.VITE_BASE_DOMAIN || "seruni.id";
  }

  const hostname = window.location.hostname;
  const parts = hostname.split(".");

  // If localhost, return as-is
  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return "localhost";
  }

  // Return last 2 parts for standard domains (seruni.id)
  if (parts.length >= 2) {
    return parts.slice(-2).join(".");
  }

  return hostname;
}

/**
 * Build URL with subdomain
 */
export function buildSubdomainUrl(subdomain: string, path: string = "/"): string {
  const base = getBaseDomain();
  const protocol = typeof window !== "undefined" ? window.location.protocol : "https:";
  return `${protocol}//${subdomain}.${base}${path}`;
}

// ============================================================
// TENANT PROVIDER
// ============================================================

interface TenantProviderProps {
  children: ReactNode;
  defaultTenantSlug?: string;
  supabaseClient?: any; // Supabase client
}

export function TenantProvider({
  children,
  defaultTenantSlug = "seruni-mumbul",
  supabaseClient,
}: TenantProviderProps) {
  const [tenant, setTenant] = useState<Tenant | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Initialize tenant on mount
  useEffect(() => {
    initTenant();
  }, []);

  async function initTenant() {
    setLoading(true);
    setError(null);

    try {
      // 1. Check URL subdomain first
      const subdomain = parseSubdomain(window.location.hostname);

      if (subdomain) {
        // Try to find tenant by slug (subdomain)
        await setTenantBySlug(subdomain);
        return;
      }

      // 2. Fallback to default tenant or from localStorage
      const savedTenantId = localStorage.getItem("seruni:tenant_id");
      if (savedTenantId) {
        await setTenantById(savedTenantId);
        return;
      }

      // 3. Use default
      await setTenantBySlug(defaultTenantSlug);
    } catch (err) {
      console.error("Failed to init tenant:", err);
      setError(err instanceof Error ? err.message : "Gagal memuat tenant");
    } finally {
      setLoading(false);
    }
  }

  async function setTenantBySlug(slug: string): Promise<void> {
    if (!supabaseClient) {
      // No Supabase client, try localStorage
      const saved = localStorage.getItem(`seruni:tenant:${slug}`);
      if (saved) {
        const t = JSON.parse(saved) as Tenant;
        setTenant(t);
        localStorage.setItem("seruni:tenant_id", t.id);
        return;
      }
      throw new Error("Tenant tidak ditemukan dan Supabase tidak tersedia");
    }

    const { data, error: err } = await supabaseClient
      .from("tenants")
      .select("*")
      .eq("slug", slug)
      .eq("is_active", true)
      .single();

    if (err || !data) {
      throw new Error(`Tenant "${slug}" tidak ditemukan`);
    }

    const t: Tenant = {
      id: data.id,
      slug: data.slug,
      nama_resmi: data.nama_resmi,
      tagline: data.tagline,
      logo_url: data.logo_url,
      warna_primer: data.warna_primer,
      warna_aksen: data.warna_aksen,
      kontak: data.kontak,
      alamat: data.alamat,
      jam_layanan: data.jam_layanan,
      is_active: data.is_active,
    };

    setTenant(t);
    localStorage.setItem("seruni:tenant_id", t.id);
    localStorage.setItem(`seruni:tenant:${slug}`, JSON.stringify(t));
  }

  async function setTenantById(id: string): Promise<void> {
    if (!supabaseClient) {
      throw new Error("Supabase client diperlukan untuk load tenant by ID");
    }

    const { data, error: err } = await supabaseClient
      .from("tenants")
      .select("*")
      .eq("id", id)
      .single();

    if (err || !data) {
      throw new Error("Tenant tidak ditemukan");
    }

    const t: Tenant = {
      id: data.id,
      slug: data.slug,
      nama_resmi: data.nama_resmi,
      tagline: data.tagline,
      logo_url: data.logo_url,
      warna_primer: data.warna_primer,
      warna_aksen: data.warna_aksen,
      kontak: data.kontak,
      alamat: data.alamat,
      jam_layanan: data.jam_layanan,
      is_active: data.is_active,
    };

    setTenant(t);
    localStorage.setItem("seruni:tenant_id", t.id);
    localStorage.setItem(`seruni:tenant:${t.slug}`, JSON.stringify(t));
  }

  return (
    <TenantContext.Provider
      value={{
        tenant,
        loading,
        error,
        setTenantBySlug,
        setTenantById,
      }}
    >
      {children}
    </TenantContext.Provider>
  );
}

// ============================================================
// HOOKS
// ============================================================

/**
 * Hook to get current tenant ID for Supabase queries
 * Automatically adds tenant_id filter to all queries
 */
export function useTenantId(): string | null {
  const { tenant } = useTenant();
  return tenant?.id ?? null;
}

/**
 * Hook to check if current tenant has a specific feature enabled
 */
export function useFeatureFlag(flagKey: string): boolean {
  const [enabled, setEnabled] = useState(false);
  const { tenant } = useTenant();

  useEffect(() => {
    if (!tenant) return;

    // Check localStorage first (cached)
    const cached = localStorage.getItem(`seruni:feature:${tenant.id}:${flagKey}`);
    if (cached !== null) {
      setEnabled(cached === "true");
      return;
    }

    // Note: In production, this would fetch from Supabase feature_flags table
    // For now, return true (enabled)
    setEnabled(true);
  }, [tenant, flagKey]);

  return enabled;
}

/**
 * Hook to get tenant-specific settings
 */
export function useTenantSettings() {
  const { tenant } = useTenant();

  return {
    primaryColor: tenant?.warna_primer ?? "#0f766e",
    accentColor: tenant?.warna_aksen ?? "#f59e0b",
    logoUrl: tenant?.logo_url,
    contact: tenant?.kontak,
    address: tenant?.alamat,
    serviceHours: tenant?.jam_layanan,
  };
}

// ============================================================
// WITH TENANT HOC
// ============================================================

/**
 * HOC to inject tenant context into a component
 */
export function withTenant<P extends object>(
  WrappedComponent: React.ComponentType<P>,
) {
  return function TenantizedComponent(props: P) {
    return (
      <TenantProvider>
        <WrappedComponent {...props} />
      </TenantProvider>
    );
  };
}

// ============================================================
// TENANT SWITCHER (for admin/testing)
// ============================================================

export function TenantSwitcher({ supabaseClient }: { supabaseClient: any }) {
  const { setTenantBySlug, tenant } = useTenant();
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadTenants();
  }, []);

  async function loadTenants() {
    if (!supabaseClient) return;
    setLoading(true);

    const { data } = await supabaseClient
      .from("tenants")
      .select("id, slug, nama_resmi")
      .eq("is_active", true);

    setTenants(
      (data ?? []).map((t: any) => ({
        id: t.id,
        slug: t.slug,
        nama_resmi: t.nama_resmi,
        is_active: true,
      })),
    );
    setLoading(false);
  }

  async function handleSwitch(slug: string) {
    await setTenantBySlug(slug);
    window.location.reload();
  }

  if (loading || tenants.length <= 1) return null;

  return (
    <div className="fixed bottom-4 right-4 z-50">
      <select
        value={tenant?.slug ?? ""}
        onChange={(e) => handleSwitch(e.target.value)}
        className="bg-card border border-border rounded-lg px-3 py-2 text-sm shadow-lg"
      >
        {tenants.map((t) => (
          <option key={t.id} value={t.slug}>
            {t.nama_resmi}
          </option>
        ))}
      </select>
    </div>
  );
}
