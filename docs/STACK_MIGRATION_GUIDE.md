# Stack Migration Guide

**Target:** Vite + React SPA → Next.js 14+ App Router + Drizzle + NextAuth v5 + BullMQ

## Prinsip

1. **Incremental Migration** — Tidak harus selesai sekaligus. Component per component.
2. **Shared Types** — TypeScript types dari `src/integrations/supabase/types.ts` jadi single source.
3. **Hybrid Rendering** — Admin pages: SSR/SSG. Public pages: ISR (revalidate tiap 60 detik).

---

## Tahapan Migrasi

### Phase 1: Project Setup (1-2 minggu)
- [ ] Buat Next.js 14 project dengan App Router
- [ ] Setup Drizzle ORM dengan PostgreSQL connection
- [ ] Generate Drizzle schema dari `types.ts` yang sudah ada
- [ ] Setup NextAuth v5 dengan Supabase adapter
- [ ] Setup environment variables

### Phase 2: Auth Migration (1 minggu)
- [ ] Convert Supabase Auth → NextAuth v5
- [ ] Migrate user_roles table
- [ ] Setup session handling
- [ ] Test admin login flow

### Phase 3: Page Migration (2-4 minggu)
- [ ] Migrate Layout.tsx → app/layout.tsx
- [ ] Migrate public pages (Incremental Static Regeneration)
- [ ] Migrate admin pages (SSR dengan auth guard)
- [ ] Test semua route

### Phase 4: API Layer (1-2 minggu)
- [ ] Convert Supabase client → Drizzle ORM queries
- [ ] Setup API routes untuk edge functions
- [ ] Migrate hooks patterns ke Server Components / Route Handlers

### Phase 5: Background Jobs (1-2 minggu)
- [ ] Setup BullMQ dengan Redis
- [ ] Migrate event-processor cron → BullMQ worker
- [ ] Migrate IDM scorer → BullMQ worker
- [ ] Setup job scheduling

---

## Setup Checklist

### 1. Install Dependencies

```bash
# Core
npm install next@14 react react-dom

# Auth
npm install @auth/core @auth/drizzle-adapter next-auth@beta

# ORM
npm install drizzle-orm postgres
npm install -D drizzle-kit @types/pg

# Queue
npm install bullmq ioredis
npm install -D @types/ioredis

# UI (if needed)
npm install tailwindcss postcss autoprefixer
```

### 2. Drizzle Config

```typescript
// drizzle.config.ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  driver: "pg",
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!,
  },
});
```

### 3. Directory Structure

```
src/
  app/
    (auth)/
      login/page.tsx
      admin/page.tsx
    (public)/
      layout.tsx
      page.tsx
      layanan/page.tsx
    api/
      auth/[...nextauth]/route.ts
      webhooks/route.ts
  components/
  db/
    schema.ts
    queries.ts
  lib/
    auth.ts
    tenant.ts
  workers/
    event-processor.ts
    idm-scorer.ts
```

---

## Key Differences

| Aspect | Vite + React | Next.js 14 |
|---|---|---|
| Rendering | Client-side only | SSR/SSG/ISR |
| Routing | react-router | App Router (file-based) |
| Auth | Supabase Auth | NextAuth v5 |
| DB Client | Supabase JS | Drizzle ORM |
| Auth Guard | AdminShell | Middleware |
| API | Supabase RPC | Route Handlers |
| Background | pg_cron | BullMQ |

---

## Critical Migrations

### 1. Auth Guard

**Before (Vite):**
```tsx
function AdminShell({ children }) {
  const { user } = useAuth();
  if (!user) return <LoginPage />;
  // ...
}
```

**After (Next.js):**
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const session = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!session && request.nextUrl.pathname.startsWith("/admin")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
}
```

### 2. Data Fetching

**Before:**
```tsx
const { data } = await supabase.from("penduduk").select("*");
```

**After:**
```typescript
// src/db/queries.ts
export async function getPenduduk(tenantId: string) {
  return db.query.penduduk.findMany({
    where: eq(penduduk.tenantId, tenantId),
  });
}

// app/(public)/penduduk/page.tsx
export default async function PendudukPage() {
  const tenants = await getTenantFromSubdomain();
  const penduduk = await getPenduduk(tenants.id);
  return <PendudukList data={penduduk} />;
}
```

### 3. Event Processor

**Before (Edge Function + pg_cron):**
```typescript
// supabase/functions/event-processor/index.ts
Deno.serve(async (req) => {
  // process events
});
```

**After (BullMQ Worker):**
```typescript
// src/workers/event-processor.ts
import { Worker } from "bullmq";

const worker = new Worker("event-processor", async (job) => {
  await processEvents(job.data);
}, { connection: redisConnection });
```

---

## Migration Order

1. **Setup Next.js project** (isolated, parallel with existing Vite app)
2. **Auth** (most critical for admin)
3. **Public pages** (easiest to migrate)
4. **Admin pages** (complex state management)
5. **Background jobs** (can run parallel)
6. **Deploy & switch DNS**

---

## Rollback Plan

1. Keep Vite app on `app.vite.seruni.id`
2. Deploy Next.js to `app.seruni.id`
3. Monitor for 1 week
4. Switch DNS only after stability confirmed

---

## Testing Checklist

- [ ] Login/Logout flow
- [ ] Admin CRUD operations
- [ ] Public page rendering
- [ ] Tenant isolation (RLS)
- [ ] Event propagation
- [ ] IDM scoring
- [ ] WA Chatbot webhook
- [ ] Performance (Core Web Vitals)
