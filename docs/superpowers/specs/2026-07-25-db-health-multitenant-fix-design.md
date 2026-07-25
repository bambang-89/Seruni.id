# Design: Database Health & Multi-Tenancy Fix — E2E

**Tanggal:** 2026-07-25
**Status:** Approved
**Stack:** Supabase (PostgreSQL) + Next.js App Router

---

## Tujuan

Memperbaiki semua gap kesehatan database di project Seruni.id secara bertahap dan terverifikasi:
1. Konsistensi multi-tenancy (`tenant_id`) di seluruh tabel
2. Keamanan & integritas (dead artifacts, broken isolation)
3. TableCrud auto-inject `tenant_id`
4. Cleanup & audit tooling

---

## Tenant UUID Reference

Tenant Seruni Mumbul: `d532ae95-0ad9-42bb-a6e8-5c840447c90e`

---

## Fase 1 — Tenant_ID Konsistensi

### Tabel yang belum punya `tenant_id` (perlu migration)

| # | Tabel | Modul | Priority |
|---|-------|-------|----------|
| 1 | `berita` | Konten | HIGH |
| 2 | `agenda` | Konten | HIGH |
| 3 | `pengumuman` | Konten | HIGH |
| 4 | `galeri` | Konten | HIGH |
| 5 | `idm_scoring_log` | IDM | HIGH |
| 6 | `audit_log` | Audit | HIGH |
| 7 | `event_log` | Event | HIGH |
| 8 | `perpustakaan_desa` | Perpustakaan | MEDIUM |
| 9 | `buku_perpustakaan` | Perpustakaan | MEDIUM |
| 10 | `pemilihan` | Pemilihan | MEDIUM |
| 11 | `calon_kades` | Pemilihan | MEDIUM |
| 12 | `posyandu_balita` | Posyandu | MEDIUM |
| 13 | `pbb_pembayaran` | PBB | MEDIUM |
| 14 | `bencana_bantuan` | Bencana | MEDIUM |
| 15 | `hero_slider` | Konten | LOW |
| 16 | `identitas_desa` | Pemerintahan | LOW |
| 17 | `apotek_desa`, `apotek_obat`, `apotek_resep` | Apotek | LOW |
| 18 | `user_profiles` | Auth | LOW |
| 19 | `domain_events` | Event | MEDIUM |

### Strategy per tabel
1. Check apakah kolom `tenant_id` sudah ada (idempotent)
2. Jika belum, `ALTER TABLE ADD COLUMN IF NOT EXISTS tenant_id uuid NOT NULL DEFAULT 'd532ae95-0ad9-42bb-a6e8-5c840447c90e'`
3. Jika `NOT NULL` tapi ada null rows, backfill dulu
4. Buat RLS policy: `tenant_filter(tenant_id)`
5. Hapus default after backfill (optional)

### Catatan khusus
- `event_log` tidak punya `tenant_id` sama sekali — perlu dibuat
- `domain_events` punya `tenant_id` nullable — perlu jadi `NOT NULL`
- `audit_log` perlu di-check apakah nama tabelnya `audit_trail` atau `audit_log`

---

## Fase 2 — Keamanan & Integritas

### Tasks

| # | Task | File/Query | Priority |
|---|------|------------|----------|
| 1 | Drop dead index `idx_keluarga_kepala` | Migration | CRITICAL |
| 2 | Drop dead columns `rt_id`, `rw_id` | Migration | HIGH |
| 3 | Fix `get_tenant_id()` — hapus fallback hardcoded `'seruni'` | `20260720100002_004_multi_tenancy.sql` | CRITICAL |
| 4 | Rename `_catatteknis` → `catatan_teknis` | `idm_scoring_log` | LOW |
| 5 | Tambah CHECK constraint NIK 16-digit | `penduduk` | MEDIUM |
| 6 | Tambah `tenant_id` ke `audit_trail` | Audit | MEDIUM |

### `get_tenant_id()` fix
```sql
-- SEBELUM (broken):
SELECT COALESCE(
  current_setting('app.current_tenant_id', true)::uuid,
  (SELECT id FROM tenants WHERE subdomain = 'seruni' LIMIT 1)
);

-- SESUDAH (safe — no hardcoded fallback):
SELECT current_setting('app.current_tenant_id', true)::uuid;
-- Caller MUST set the setting before calling, or raise an error
```

---

## Fase 3 — TableCrud Auto-Inject tenant_id

### Perubahan di `src/components/admin/TableCrud.tsx`

1. Terima `tenantId` dari props atau context
2. Saat INSERT — auto-set `tenant_id` jika kolom ada dan belum di-set
3. Saat UPDATE — jangan overwrite `tenant_id`
4. Tambahkan comment jelas untuk developer

### Komponen yang perlu di-test setelah perubahan
- BeritaAdmin, AgendaAdmin, GaleriAdmin
- ApotekAdmin, PerpustakaanAdmin
- PemilihanAdmin
- EventLog viewer (if exists)

---

## Fase 4 — Cleanup & Audit

### audit-db.mjs improvements
1. Ganti hardcoded relationship counts dengan live RPC calls
2. Check FK constraint existence (bukan hanya ada/tidak ada tabel)
3. Check orphan records di semua tabel dengan `tenant_id`
4. Export hasil ke JSON untuk tracking
5. Check `get_tenant_id()` behavior

### Migration history cleanup
- 106 migration files terlalu banyak dan noisy
- Buat dokumentasi `docs/superpowers/SPEC_MIGRATION_INVENTORY.md` yang merangkum semua migration yang ada dan kegunaannya
- Target: tidak perlu bikin migration baru untuk hal yang sudah ada di inventory

---

## Execution Model

**Pendekatan:** Satu-per-satu (idempotent migrations)
**Verifikasi:** Manual tiap langkah sebelum commit
**Pipeline:**

```
Migration dibuat (idempotent) → di-review → di-run ke Supabase → dicek hasilnya → commit
```

### Verifikasi checklist per langkah
- [ ] `SELECT tenant_id IS NULL FROM <tabel>` → harus 0 rows
- [ ] `\d <tabel>` → harus ada `tenant_id` column + index
- [ ] `SELECT schemaname, tablename, policyname FROM pg_policies WHERE policyname LIKE '%tenant%'` → harus ada policy
- [ ] CRUD test via TableCrud (berita/agenda sebagai pilot)
- [ ] `audit-db.mjs` → harus clean

---

## Referensi

- Tenant UUID: `d532ae95-0ad9-42bb-a6e8-5c840447c90e`
- Migration utama: `20260721000004_add_tenant_id.sql`
- RLS function: `get_tenant_id()`, `tenant_filter()`
- Specs existing: `docs/superpowers/specs/2026-07-24-surat-identitas-autofill-design.md`
- Audits existing: `docs/superpowers/audit/penduduk-database-audit.md`
