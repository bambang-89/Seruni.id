# Seruni.id — Audit Fix Finalisasi

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Selesaikan seluruh tech debt dari audit security: tenant isolation di 3 admin hooks + eliminasi `as any` + composite index.

**Architecture:** Frontend React hooks (queries.ts) + database migration. Semua perubahan backward-compatible dan tidak mengubah behavior yang sudah difix.

## Global Constraints

- Tidak boleh mengubah behavior fix C-01/C-02/C-03 yang sudah committed
- Tenant isolation mengikuti pola yang sama: `let q = supabase.from(...); if (tenantId) q = q.eq("tenant_id", tenantId);`
- Migration harus idempotent (`CREATE INDEX CONCURRENTLY IF NOT EXISTS`)
- Build harus tetap PASS sebelum dan sesudah setiap task

---

### Task 1: Tenant Isolation — 3 Admin Hooks

**Files:**
- Modify: `src/seruni/lib/queries.ts:563-675`
- Verify: `src/seruni/admin/AdminOps.tsx` (caller sites)

**Interfaces:**
- Consumes: `useTenantId()` hook already present in file
- Produces: 3 hooks dengan `.eq("tenant_id", tenantId)` filter

Hooks yang perlu diperbaiki:

1. **`useEventLog`** (line 563): Tambahkan `.eq("tenant_id", tenantId)` ke query event_log
2. **`useBroadcasts`** (line 636): Tambahkan `.eq("tenant_id", tenantId)` ke query wa_broadcast
3. **`useBroadcastTargets`** (line 654): Tambahkan `.eq("tenant_id", tenantId)` ke query wa_broadcast_target

Pola pattern yang SUDAH VERIFIED di file ini:
```typescript
let q = supabase.from("table").select("*");
if (tenantId) q = q.eq("tenant_id", tenantId);
```

Tambahkan dependency `tenantId` ke useEffect dependency array jika belum ada.

- [ ] **Step 1: Read queries.ts lines 563-675** — pahami state awal
- [ ] **Step 2: Tambahkan tenant filter ke useEventLog**
- [ ] **Step 3: Tambahkan tenant filter ke useBroadcasts**
- [ ] **Step 4: Tambahkan tenant filter ke useBroadcastTargets**
- [ ] **Step 5: Run `npm run build`** — must pass
- [ ] **Step 6: Commit**

---

### Task 2: Eliminate `as any` di queries.ts

**Files:**
- Modify: `src/seruni/lib/queries.ts`

**Target:** Kurangi occurrences `as any` seminimal mungkin. Beberapa jelas necessary (Supabase dynamic return types), tapi banyak yang bisa ditargetkan dengan proper typing.

Scan file untuk semua `as any` patterns:

```bash
grep -n "as any" src/seruni/lib/queries.ts
```

Kategori yang bisa dieliminasi:
- `(data as unknown) || []` → bisa pakai type assertion langsung atau guard
- Pattern boilerplate `((x as unknown) || []) as T` → ekstrak helper function `nullable<T>`

Kategori yang TIDAK perlu diubah:
- `createClient<D.Database>(...)` calls
- fetch results dari Supabase yang return type-nya unknown by design

**Approach:** Buat helper `function safeData<T>(data: unknown): T[] { return (data as T[]) || []; }` — gunakan di semua tempat yang sama pattern-nya.

- [ ] **Step 1: Scan semua `as any` occurrences**
- [ ] **Step 2: Identifikasi patterns yang bisa dieliminasi vs necessary**
- [ ] **Step 3: Buat helper function jika pattern berulang**
- [ ] **Step 4: Replace occurrences satu per satu**
- [ ] **Step 5: Run `npm run build`** — must pass
- [ ] **Step 6: Commit**

---

### Task 3: Composite Index untuk Rate-Limit Query

**Files:**
- Create: `supabase/migrations/20260729000001_composite_event_log_index.sql`

**Interfaces:**
- Consumes: `event_log` table schema (dari types.ts)
- Produces: Migration file

Rate-limit query di edge functions:
```sql
SELECT id FROM event_log
WHERE event_name = 'usulan_warga.dibuat_publik'
  AND created_at >= '...'
  AND payload->>'fp' = '...'
  AND tenant_id = '...'
```

Index yang dibutuhkan:
```sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_log_rate_limit
ON event_log (event_name, created_at, (payload->>'fp'), tenant_id)
WHERE event_name IN ('usulan_warga.dibuat_publik', 'surat.diajukan');
```

- [ ] **Step 1: Buat migration dengan `CREATE INDEX CONCURRENTLY IF NOT EXISTS`**
- [ ] **Step 2: Commit**
- [ ] **Step 3: (Opsional) Jalankan manual untuk apply ke database production**

---

### Task 4: Final Verification

**Files:**
- Verify: seluruh project

- [ ] **Step 1: `npm run build`** — must pass with zero errors
- [ ] **Step 2: `npx playwright test`** — semua smoke tests harus pass
- [ ] **Step 3: `git log --oneline`** — verify semua commits bersih
- [ ] **Step 4: Commit final**

---

## Completion Criteria

- Build: PASS
- Smoke tests: PASS
- 3 admin hooks: tenant-isolated
- `as any`: diminimalisir
- Composite index: migration created
