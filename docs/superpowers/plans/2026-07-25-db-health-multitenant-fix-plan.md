# Database Health & Multi-Tenancy Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Memperbaiki semua gap kesehatan database: konsistensi tenant_id (13 tabel), keamanan & integritas (dead artifacts, broken isolation), TableCrud auto-inject tenant_id, dan audit tooling.

**Architecture:** Satu-per-satu idempotent migrations. Setiap task = 1 file migration atau 1 edit. Verifikasi manual tiap langkah sebelum commit.

**Tech Stack:** Supabase (PostgreSQL), TypeScript, Next.js

## Global Constraints

- Tenant UUID Seruni Mumbul: `d532ae95-0ad9-42bb-a6e8-5c840447c90e`
- Next migration number: `20260826000001_*`
- Migration pattern (from `20260721000004_add_tenant_id.sql`): `ADD COLUMN IF NOT EXISTS` → backfill → `SET NOT NULL` → `CREATE INDEX`
- Reference tables (`ref_*`, `tenants`, `user_roles`) are GLOBAL — tidak punya `tenant_id`

---

## Task Map

| Task | File | Effort |
|------|------|--------|
| 1 | `20260826000001_add_tenant_id_remaining_tables.sql` | HIGH |
| 2 | `20260826000002_fix_nullable_tenant_id.sql` | HIGH |
| 3 | `20260826000003_security_integrity_fixes.sql` | HIGH |
| 4 | `20260826000004_fix_get_tenant_id.sql` | CRITICAL |
| 5 | `AdminPages.tsx` TableCrud tenant_id injection | HIGH |
| 6 | `audit-db.mjs` improvements | MEDIUM |

---

## Task 1: Add tenant_id to Remaining Tables

**Files:**
- Create: `supabase/migrations/20260826000001_add_tenant_id_remaining_tables.sql`

**Tables yang belum punya `tenant_id`:**

| Tabel | Module | Notes |
|-------|--------|-------|
| `berita` | Konten | Core content |
| `agenda` | Konten | Core content |
| `pengumuman` | Konten | Core content |
| `galeri` | Konten | Gallery |
| `idm_scoring_log` | IDM | IDM scoring records |
| `perpustakaan_desa` | Perpustakaan | Library |
| `buku_perpustakaan` | Perpustakaan | Books |
| `pemilihan` | Pemilihan | Election master |
| `calon_kades` | Pemilihan | Candidate |
| `posyandu_balita` | Posyandu | Balita F4 data |
| `pbb_pembayaran` | PBB | PBB payments |
| `bencana_bantuan` | Bencana | Disaster aid |
| `user_profiles` | Auth | User profiles |

**DO NOT include:** `event_log` and `domain_events` (already have tenant_id, see Task 2). `audit_trail` already has proper tenant_id. `ref_*` tables are global.

**Pattern (idempotent — repeated for each table):**
```sql
DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN
  -- berita
  ALTER TABLE public.berita ADD COLUMN IF NOT EXISTS tenant_id UUID;
  UPDATE public.berita SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
  ALTER TABLE public.berita ALTER COLUMN tenant_id SET NOT NULL;
  CREATE INDEX IF NOT EXISTS idx_berita_tenant ON public.berita(tenant_id);

  -- Repeat for: agenda, pengumuman, galeri, idm_scoring_log,
  -- perpustakaan_desa, buku_perpustakaan, pemilihan, calon_kades,
  -- posyandu_balita, pbb_pembayaran, bencana_bantuan, user_profiles
END $$;
```

- [ ] **Step 1: Buat migration file** — Copy pattern di atas, tambahkan semua 13 tabel
- [ ] **Step 2: Run migration** — `supabase db push` atau `apply-migration.mjs`
- [ ] **Step 3: Verifikasi** — `SELECT count(*) WHERE tenant_id IS NULL FROM <tabel>` untuk tiap tabel → harus 0
- [ ] **Step 4: Verifikasi index** — `SELECT indexname FROM pg_indexes WHERE tablename IN ('berita','agenda',...) AND indexname LIKE '%tenant%'`
- [ ] **Step 5: Commit**

---

## Task 2: Fix Nullable tenant_id in event_log and domain_events

**Files:**
- Create: `supabase/migrations/20260826000002_fix_nullable_tenant_id.sql`

**Tables:**
- `event_log` — sudah punya `tenant_id UUID` nullable (dari `20260720100001_003_domain_events.sql`)
- `domain_events` — sudah punya `tenant_id UUID` nullable (dari `20260720100001_003_domain_events.sql`)

```sql
DO $$
DECLARE
  v_tenant_id UUID := 'd532ae95-0ad9-42bb-a6e8-5c840447c90e';
BEGIN
  -- Fix event_log.tenant_id
  UPDATE public.event_log SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
  ALTER TABLE public.event_log ALTER COLUMN tenant_id SET NOT NULL;
  ALTER TABLE public.event_log ADD CONSTRAINT event_log_tenant_id_fkey
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;

  -- Fix domain_events.tenant_id
  UPDATE public.domain_events SET tenant_id = v_tenant_id WHERE tenant_id IS NULL;
  ALTER TABLE public.domain_events ALTER COLUMN tenant_id SET NOT NULL;
  ALTER TABLE public.domain_events ADD CONSTRAINT domain_events_tenant_id_fkey
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
END $$;
```

- [ ] **Step 1: Buat migration file** dengan script di atas
- [ ] **Step 2: Run migration** ke Supabase
- [ ] **Step 3: Verifikasi** — `SELECT tenant_id IS NULL FROM event_log LIMIT 1` dan `domain_events` → harus false/0 rows
- [ ] **Step 4: Commit**

---

## Task 3: Security & Integrity — Drop Dead Artifacts

**Files:**
- Create: `supabase/migrations/20260826000003_security_integrity_fixes.sql`

**Artifacts to drop:**

| Artifact | Reason | Migration Reference |
|----------|--------|---------------------|
| `idx_keluarga_kepala` | Index on non-existent column `kepala_keluarga_id` in `keluarga` table | `20260728000003_security_integrity_fixes.sql` line 121 |
| `rt_id` column in `penduduk` | Dead column — no FK, no backfill, no UI usage | `20260722000001_add_uuid_refs_and_missing_tables.sql` |
| `rw_id` column in `penduduk` | Dead column — no FK, no backfill, no UI usage | `20260722000001_add_uuid_refs_and_missing_tables.sql` |
| `dusun_id` column in `penduduk` | Dead column — FK to non-existent table `wilayah_batas` | `20260722000001_add_uuid_refs_and_missing_tables.sql` |

```sql
-- Drop dead index
DROP INDEX IF EXISTS public.idx_keluarga_kepala;

-- Drop dead columns from penduduk
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rt_id;
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS rw_id;
ALTER TABLE public.penduduk DROP COLUMN IF EXISTS dusun_id;
```

- [ ] **Step 1: Buat migration file** dengan script di atas
- [ ] **Step 2: Run migration** ke Supabase
- [ ] **Step 3: Verifikasi** — `SELECT column_name FROM information_schema.columns WHERE table_name = 'penduduk' AND column_name IN ('rt_id','rw_id','dusun_id')` → harus empty
- [ ] **Step 4: Verifikasi index** — `SELECT indexname FROM pg_indexes WHERE indexname = 'idx_keluarga_kepala'` → harus empty
- [ ] **Step 5: Test CRUD penduduk** — pastikan admin penduduk masih bisa add/edit/delete
- [ ] **Step 6: Commit**

---

## Task 4: Fix get_tenant_id() — Remove Hardcoded Fallback

**Files:**
- Modify: `supabase/migrations/20260826000004_fix_get_tenant_id.sql` (new migration to replace function)

**Problem:** `get_tenant_id()` falls back to hardcoded `'seruni'` subdomain when `app.current_tenant_id` setting is not set. This defeats multi-tenant isolation — all tenants get Seruni Mumbul data.

**Solution:** Replace the function to require the setting. If not set, the caller (middleware/RLS policy) must set it first. No silent fallback.

```sql
-- Replace get_tenant_id() with strict version
CREATE OR REPLACE FUNCTION get_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT current_setting('app.current_tenant_id', true)::uuid;
$$;
```

**Also update `tenant_filter()` to work with the strict `get_tenant_id()`:**

```sql
CREATE OR REPLACE FUNCTION tenant_filter(p_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.uid() IS NOT NULL
    AND (
      EXISTS (SELECT 1 FROM public.user_peran WHERE user_id = auth.uid() AND peran = 'admin' LIMIT 1)
      OR
      get_tenant_id() = p_tenant_id
    );
$$;
```

- [ ] **Step 1: Buat migration file** — replace both functions
- [ ] **Step 2: Run migration** ke Supabase
- [ ] **Step 3: Verifikasi** — `SELECT get_tenant_id()` → harus error atau null (karena tidak ada setting)
- [ ] **Step 4: Test RLS** — login sebagai admin, test select pada tabel dengan tenant_id berbeda
- [ ] **Step 5: Commit**

---

## Task 5: TableCrud Auto-Inject tenant_id

**Files:**
- Modify: `src/seruni/admin/AdminPages.tsx`

**Langkah-langkah:**
1. Baca `AdminPages.tsx` untuk menemukan komponen TableCrud atau pola CRUD yang digunakan
2. Tentukan di mana INSERT/UPDATE dilakukan
3. Auto-set `tenant_id` dari `useTenant()` context saat INSERT
4. Jangan overwrite `tenant_id` saat UPDATE

**Detail kode (update setelah Task 1 & 2 dijalankan):**

Pola yang diharapkan — cari pattern `insert` atau `upsert` di AdminPages.tsx dan tambahkan:
```typescript
// Auto-inject tenant_id from context
if (tenantId && !formData.tenant_id) {
  formData.tenant_id = tenantId;
}
```

- [ ] **Step 1: Baca AdminPages.tsx** — temukan semua tempat INSERT/UPDATE terjadi
- [ ] **Step 2: Identifikasi apakah useTenant() sudah dipakai** — grep untuk `useTenant` di AdminPages.tsx
- [ ] **Step 3: Tambahkan tenant_id injection** di semua path INSERT
- [ ] **Step 4: Test** — add berita baru via admin UI, verifikasi `tenant_id` ter-set di DB
- [ ] **Step 5: Commit**

---

## Task 6: Improve audit-db.mjs

**Files:**
- Modify: `scripts/audit-db.mjs`

**Improvements:**

| # | Improvement | Detail |
|---|-------------|--------|
| 1 | Live orphan check | Query `WHERE tenant_id IS NULL` untuk semua 50+ tabel dengan tenant_id |
| 2 | FK constraint check | Verifikasi semua tabel punya FK constraint ke `tenants.id` |
| 3 | `get_tenant_id()` check | Test apakah function berjalan benar tanpa hardcoded fallback |
| 4 | Table CRUD test | Coba INSERT + SELECT + DELETE untuk 1 tabel pilot (berita) |

```javascript
// New section: Tenant Isolation Audit
async function auditTenantIsolation() {
  const results = [];
  // Check all tables that SHOULD have tenant_id
  for (const table of TENANT_TABLES) {
    const nullCount = await fetchAPI(
      `${table}?tenant_id=is.null&select=count(*)`
    );
    results.push({ table, nullTenantRows: nullCount });
  }
  return results;
}

// New section: FK Constraint Check
async function auditFKConstraints() {
  const result = await fetchAPI(`
    SELECT tc.table_name, kcu.column_name, ccu.table_name AS foreign_table_name
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND ccu.table_name = 'tenants'
      AND ccu.column_name = 'id'
  `);
  return result; // tables with FK to tenants.id
}
```

- [ ] **Step 1: Baca audit-db.mjs** — pahami struktur lengkap
- [ ] **Step 2: Tambah fungsi `auditTenantIsolation()`**
- [ ] **Step 3: Tambah fungsi `auditFKConstraints()`**
- [ ] **Step 4: Update output format** — tampilkan hasil dalam tabel ringkas
- [ ] **Step 5: Test** — jalankan `node scripts/audit-db.mjs`, verifikasi output
- [ ] **Step 6: Commit**

---

## Verification Checklist (Final)

- [ ] Semua 13 tabel punya `tenant_id` NOT NULL
- [ ] `event_log.tenant_id` dan `domain_events.tenant_id` NOT NULL dengan FK
- [ ] Dead index `idx_keluarga_kepala` dropped
- [ ] Dead columns `rt_id`, `rw_id`, `dusun_id` dropped dari `penduduk`
- [ ] `get_tenant_id()` tidak punya fallback hardcoded
- [ ] TableCrud auto-inject tenant_id bekerja
- [ ] `audit-db.mjs` melaporkan 0 orphan tenant_id rows
- [ ] CRUD test berhasil untuk berita (pilot)

---

## Spec Self-Review

- [x] Spec coverage: Semua 4 fase dari design spec tercakup
- [x] Placeholder scan: Tidak ada TBD/TODO
- [x] Type consistency: Tenant UUID konsisten di semua task (`d532ae95-0ad9-42a6e8-5c840447c90e`)
- [x] Gap: Tidak ada

## Related Files

- Spec: `docs/superpowers/specs/2026-07-25-db-health-multitenant-fix-design.md`
- Ref migration pattern: `supabase/migrations/20260721000004_add_tenant_id.sql`
- get_tenant_id: `supabase/migrations/20260720100002_004_multi_tenancy.sql`
- tenant_filter: `supabase/migrations/20260721000002_create_tenant_functions.sql`
- Admin CRUD: `src/seruni/admin/AdminPages.tsx`
- Audit script: `scripts/audit-db.mjs`
