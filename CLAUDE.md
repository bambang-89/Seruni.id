# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Produk: Seruni.id — Portal Desa Seruni Mumbul

Portal resmi Kantor Desa Seruni Mumbul (Kec. Pringgabaya, Kab. Lombok Timur, NTB). Multi-tenant SaaS untuk layanan desa dengan WA chatbot.

**Stack:** Next.js 14 App Router + Supabase + TypeScript + Tailwind CSS

**Stack target (per pedoman):** Next.js 14+ App Router + Drizzle ORM + PostgreSQL + BullMQ + NextAuth v5.

**Prinsip arsitektur produk (per PRD):**
- **"Satu Input, Banyak Dampak"** — setiap fakta dicatat sekali, tersebar ke seluruh modul via Event Propagation Layer.
- `penduduk` (Core Registry) = single source of truth untuk identitas warga di 10+ modul.
- Fakta turunan (IDM scoring, agregat, draft usulan) = HANYA ditulis oleh worker, tidak pernah diedit admin langsung.
- Append-only untuk histori transaksi kritikal (surat, voting, kepemilikan).

---

## Struktur Folder (next-app/)

```
src/
  app/
    page.tsx                    Halaman utama
    layout.tsx                  Root layout
    admin/                      Admin pages (CRUD)
    api/                        API routes
      berita/
      agenda/
      voting/
      bansos/
      posyandu/
      infrastruktur/
      pbb/
      penduduk/
      idm/scores/             IDM scoring endpoint
      wa-webhook/              WhatsApp webhook (Fonnte)
    status-idm/                Dashboard IDM publik
    statis/                    Halaman publik
  components/
    Header.tsx                 Header dengan theme dinamis
    Footer.tsx                 Footer dengan WA resmi
    Navigation.tsx             Navigation component
    WAChatbotWidget.tsx        Floating WA chat UI
    admin/
      TableCrud.tsx            Reusable CRUD table
  lib/
    supabase.ts                Supabase client
    idm-scoring.ts             IDM scoring formulas
    hooks/
      useZeroHardcode.ts       Zero-hardcode hooks
      useSiteSettings.ts
      useNavigation.ts
      useFeatureFlags.ts
    tenant.tsx                 TenantProvider context
workers/
  idm-scorer.ts               BullMQ IDM worker
  event-processor.ts           Event processor worker
  scheduler.ts                Worker scheduler
docs/
  PETA_DERIVATION_RULES_IDM.md  IDM formulas lengkap
  MULTITENANT_DEPLOYMENT.md    Deployment guide
```

---

## Teknologi & Konsep Kunci

| Aspek | Implementasi |
|---|---|
| **Auth** | Supabase Auth dengan email sintetis `nik-{NIK}@admin.seruni.local`. Roles via `user_roles` table. |
| **Database** | Supabase (PostgreSQL). Schema di `supabase/migrations/`. |
| **Multi-tenancy** | TenantProvider + middleware subdomain extraction. |
| **Event Propagation** | BullMQ workers untuk background processing. |
| **IDM Scoring** | `lib/idm-scoring.ts` dengan 30+ indikator. Worker di `workers/`. |
| **WA Chatbot** | Fonnte API integration via `/api/wa-webhook`. |

---

## Perintah Umum

```bash
cd next-app

# Development
npm run dev        # http://localhost:3000

# Production
npm run build      # Build production
npm run start      # Start production server

# Workers (separate terminal)
npx ts-node src/workers/idm-scorer.ts
npx ts-node src/workers/event-processor.ts

# Deploy
./scripts/deploy.sh production
```

---

## Rute Penting

| Route | Fungsi |
|---|---|
| `/` | Beranda portal publik |
| `/admin` | Dashboard admin |
| `/admin/penduduk` | CRUD Penduduk |
| `/admin/berita` | CRUD Berita |
| `/admin/voting` | CRUD Voting |
| `/status-idm` | Dashboard IDM publik |
| `/api/idm/scores` | IDM scoring endpoint |
| `/api/wa-webhook` | WA webhook Fonnte |

---

## API Endpoints

### IDM Scoring
```typescript
// GET - Ambil skor
GET /api/idm/scores?tenant_id=xxx

// POST - Recalculate
POST /api/idm/scores
Body: { tenant_id?: string } // omit untuk semua tenant
```

### WA Webhook
```typescript
// POST - Terima pesan dari Fonnte
POST /api/wa-webhook
Body: { from, message, type, timestamp }
```

---

## Zero-Hardcode Hooks

```typescript
// Site settings dari DB
const { settings } = useSiteSettings();

// Navigation dari DB
const { navigation } = useNavigation();

// Feature flags
const { flags } = useFeatureFlags();

// Current tenant
const { tenant } = useTenant();
```

---

## Environment Variables

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx

# Auth
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=xxx

# Fonnte WA
FONNTE_TOKEN=xxx

# Redis (BullMQ)
REDIS_URL=redis://localhost:6379
```

---

## Checklist Sebelum Coding

- [ ] Cek apakah tabel sudah ada di Supabase sebelum buat tabel baru
- [ ] Buat migration baru di `supabase/migrations/` dengan format `YYYYMMDDHHMMSS_<slug>.sql`
- [ ] Update sitemap entries di `scripts/generate-sitemap.ts` saat menambah route baru
- [ ] Gunakan enum types untuk semua status/kategori field
- [ ] Update `docs/PETA_DERIVATION_RULES_IDM.md` jika mengubah formulas

---

## Dokumentasi

- [docs/PETA_DERIVATION_RULES_IDM.md](docs/PETA_DERIVATION_RULES_IDM.md) - Formulas IDM lengkap
- [docs/MULTITENANT_DEPLOYMENT.md](docs/MULTITENANT_DEPLOYMENT.md) - Deployment guide production

---

## Referensi

- Supabase: https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq
- Fonnte API: https://api.fonnte.com
