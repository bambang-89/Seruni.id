# Bansos Detail Page + Penerima Bansos — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesain `/bansos/:id` (publik) dengan stats + chart sebaran per dusun + tabel penerima. Upgrade `PenerimaBansosAdmin` dengan stats header + search/filter.

**Architecture:** Ubah `BansosDetailPage` di `pages.tsx` dari card sederhana jadi page lengkap dengan section stats, chart (Recharts), dan tabel penerima. Upgrade `usePenerimaBansos` hook dengan pagination + search. Tambah `usePenerimaBansosStats` hook.

**Tech Stack:** React hooks, Supabase client, Recharts (`BarChart`), Tailwind CSS. shadcn/ui chart wrapper dari `src/components/ui/chart.tsx`.

## Global Constraints

- Semua data dari Supabase, nol hardcode
- Layout standalone (tanpa navbar/hero), sticky back button
- Kontak/NK tampil masked untuk warga, terlihat admin
- Pakai `formatTanggal()` dari `ui.tsx` untuk tanggal
- Pakai pattern styling yang sudah ada di `AduanDetailPage` dan `PembangunanDetailPage`

---

## File Map

```
src/seruni/lib/queries.ts      — upgrade 2 hooks, tambah 1 hook baru
src/seruni/pages.tsx           — redesain BansosDetailPage
src/seruni/admin/AdminOps.tsx  — upgrade PenerimaBansosAdmin
```

---

## Task 1: Upgrade Hooks di queries.ts

**Files:**
- Modify: `src/seruni/lib/queries.ts:1036-1045` (usePenerimaBansos)
- Create: `src/seruni/lib/queries.ts` (usePenerimaBansosStats, added after usePenerimaBansos)

**Interfaces:**
- Consumes: `supabase` client, `bansosId` param
- Produces: `usePenerimaBansos(bansosId, options?)` → `{ data, loading, total }`, `usePenerimaBansosStats(bansosId)` → `{ total, aktif, nonaktif }`

- [ ] **Step 1: Ambil baris sekitar usePenerimaBansos untuk konteks**

Buka `src/seruni/lib/queries.ts` line 1036-1050. Function `usePenerimaBansos` ada di situ. Setelahnya (line 1047) ada comment `// ===================== Stunting & Posyandu =====================`.

- [ ] **Step 2: Ganti usePenerimaBansos dengan versi baru**

Replace entire `usePenerimaBansos` function (lines 1036-1045) dengan:

```typescript
export interface PenerimaBansosOptions {
  search?: string;
  dusun?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

export function usePenerimaBansos(bansosId?: string, opts: PenerimaBansosOptions = {}) {
  const { search = "", dusun = "", status = "", page = 0, pageSize = 20 } = opts;
  const [data, setData] = useState<PenerimaBansos[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!bansosId) { setData([]); setTotal(0); setLoading(false); return; }
    let q = supabase
      .from("penerima_bansos")
      .select("*", { count: "exact" })
      .eq("bansos_id", bansosId)
      .order("nama");

    if (search) {
      q = q.or(`nama.ilike.%${search}%,nik.ilike.%${search}%`);
    }
    if (dusun) {
      q = q.eq("dusun", dusun);
    }
    if (status) {
      q = q.eq("status", status);
    }

    q = q.range(page * pageSize, (page + 1) * pageSize - 1);

    q.then(({ data: r, count }) => {
      setData((r as unknown as PenerimaBansos[]) || []);
      setTotal(count || 0);
      setLoading(false);
    });
  }, [bansosId, search, dusun, status, page, pageSize]);

  return { data, loading, total };
}

export function usePenerimaBansosStats(bansosId?: string) {
  const [stats, setStats] = useState({ total: 0, aktif: 0, nonaktif: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!bansosId) { setStats({ total: 0, aktif: 0, nonaktif: 0 }); setLoading(false); return; }
    supabase
      .from("penerima_bansos")
      .select("status", { count: "exact", head: true })
      .eq("bansos_id", bansosId)
      .then(({ count: totalCount }: any) => {
        supabase
          .from("penerima_bansos")
          .select("status", { count: "exact", head: true })
          .eq("bansos_id", bansosId)
          .neq("status", "dibatalkan")
          .then(({ count: aktifCount }: any) => {
            setStats({
              total: totalCount || 0,
              aktif: aktifCount || 0,
              nonaktif: (totalCount || 0) - (aktifCount || 0),
            });
            setLoading(false);
          });
      });
  }, [bansosId]);

  return { stats, loading };
}
```

- [ ] **Step 3: Commit**

```bash
git add src/seruni/lib/queries.ts
git commit -m "feat(queries): upgrade usePenerimaBansos with search/filter/pagination + add usePenerimaBansosStats

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Redesain BansosDetailPage di pages.tsx

**Files:**
- Modify: `src/seruni/pages.tsx` — replace entire `BansosDetailPage` function (lines 3354-3460)
- Dependencies: `ChartContainer, ChartTooltipContent` dari `src/components/ui/chart.tsx`, `BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip` dari `recharts`, `usePenerimaBansos, useBansosById, usePenerimaBansosStats, BantuanSosial, PenerimaBansos` dari queries

**Interfaces:**
- Consumes: `useBansosById(id)`, `usePenerimaBansos(id, opts)`, `usePenerimaBansosStats(id)`
- Produces: `<BansosDetailPage>` component — full redesigned page

- [ ] **Step 1: Ambil konteks import dan type**

Buka `src/seruni/pages.tsx` line 1-50 untuk lihat import yang sudah ada. Pastikan `recharts` belum diimport di file ini.

Ambil juga `BansosDetailPage` lengkap (lines 3354-3460) sebagai referensi struktur existing.

- [ ] **Step 2: Tambah import recharts**

Tambahkan di area import (setelah existing import recharts jika ada, atau di grup import library):

```typescript
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { ChartContainer, ChartTooltipContent } from "@/components/ui/chart";
```

- [ ] **Step 3: Ganti fungsi BansosDetailPage**

Replace seluruh function `BansosDetailPage` (lines 3354-3460) dengan versi baru berikut:

```typescript
export function BansosDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data, loading: isLoading } = useBansosById(id);

  const [search, setSearch] = useState("");
  const [dusunFilter, setDusunFilter] = useState("");
  const [page, setPage] = useState(0);
  const pageSize = 20;

  const { data: penerima, loading: isPenerimaLoading, total } = usePenerimaBansos(id, {
    search,
    dusun: dusunFilter,
    page,
    pageSize,
  });
  const { stats } = usePenerimaBansosStats(id);

  if (isLoading) return <LoadingState />;
  if (!data) return <NotFoundState />;

  const isActive = data.aktif === true || data.aktif === 1;

  // Format nominal
  const fmtNominal = (n: number | null | undefined) =>
    n ? `Rp ${n.toLocaleString("id-ID")}` : "—";

  // Chart data — agregasi per dusun
  const chartData = (() => {
    if (!penerima.length) return [];
    const agg: Record<string, number> = {};
    penerima.forEach((p) => {
      const d = p.dusun || "Tidak diketahui";
      agg[d] = (agg[d] || 0) + 1;
    });
    return Object.entries(agg)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count);
  })();

  // Unique dusun for filter dropdown
  const dusunOptions = Array.from(
    new Set(penerima.map((p) => p.dusun).filter(Boolean) as string[])
  );

  const totalPages = Math.max(1, Math.ceil(total / pageSize));

  const STATUS_LABELS: Record<string, string> = {
    terdaftar: "Terdaftar",
    diverifikasi: "Diverifikasi",
    disebarkan: "Disalurkan",
    dibatalkan: "Dibatalkan",
    aktif: "Aktif",
  };

  const STATUS_COLORS: Record<string, string> = {
    aktif: "bg-green-100 text-green-700",
    diverifikasi: "bg-blue-100 text-blue-700",
    disebarkan: "bg-purple-100 text-purple-700",
    terdaftar: "bg-gray-100 text-gray-700",
    dibatalkan: "bg-gray-100 text-gray-400",
  };

  return (
    <div className="min-h-screen bg-background">
      <main className="max-w-4xl mx-auto px-4 sm:px-6 py-8 sm:py-12">

        {/* Back link */}
        <Link to="/bansos" className="inline-flex items-center gap-1.5 text-sm text-accent hover:underline mb-6">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4"><path fillRule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clipRule="evenodd" /></svg>
          Kembali ke Bantuan Sosial
        </Link>

        {/* Program Header Card */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm mb-6">
          <div className="px-6 pt-6 pb-4 border-b border-current/10">
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-2">
                {data.kode && (
                  <p className="text-[10px] font-mono font-semibold text-foreground/40 uppercase tracking-wider">{data.kode}</p>
                )}
                <h1 className="font-display text-xl sm:text-2xl lg:text-3xl font-semibold leading-snug text-foreground">
                  {data.nama}
                </h1>
                {data.sumber && (
                  <p className="text-sm text-foreground/60">{data.sumber}</p>
                )}
              </div>
              <span className={`flex-shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${isActive ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}>
                <span className={`w-2 h-2 rounded-full ${isActive ? "bg-green-500" : "bg-red-500"}`} />
                {isActive ? "Aktif" : "Tidak Aktif"}
              </span>
            </div>
          </div>

          {/* Stats Row */}
          <div className="px-6 py-5 grid grid-cols-3 gap-3">
            <div className="bg-foreground/5 rounded-lg p-4 text-center">
              <div className="font-display text-3xl font-bold text-accent tabular-nums">{stats.total}</div>
              <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-foreground/50">Penerima</div>
            </div>
            <div className="bg-foreground/5 rounded-lg p-4 text-center">
              <div className="font-display text-3xl font-bold text-accent tabular-nums">{data.kuota ?? "—"}</div>
              <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-foreground/50">Kuota</div>
            </div>
            <div className="bg-foreground/5 rounded-lg p-4 text-center">
              <div className="font-display text-lg font-bold text-accent tabular-nums">
                {stats.total > 0 && data.kuota ? `${Math.round((stats.total / data.kuota) * 100)}%` : "—"}
              </div>
              <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-foreground/50">Terpenuhi</div>
            </div>
          </div>

          {/* Period */}
          {(data.periode_mulai || data.periode_selesai) && (
            <div className="px-6 pb-5">
              <div className="bg-foreground/5 rounded-lg p-4 flex items-center gap-3">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 text-foreground/40 flex-shrink-0"><path fillRule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clipRule="evenodd" /></svg>
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-foreground/40 mb-1">Periode</p>
                  <p className="text-sm text-foreground/80">
                    {data.periode_mulai ? formatTanggal(data.periode_mulai) : "—"}
                    {data.periode_selesai ? ` — ${formatTanggal(data.periode_selesai)}` : " — selesai"}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Description */}
          {data.deskripsi && (
            <div className="px-6 pb-6">
              <div className="border-t border-current/15 pt-5">
                <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50 mb-3">Deskripsi Program</h3>
                <p className="text-sm text-foreground/70 leading-relaxed">{data.deskripsi}</p>
              </div>
            </div>
          )}
        </div>

        {/* Chart: Sebaran per Dusun */}
        {chartData.length > 0 && (
          <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm mb-6">
            <div className="px-6 pt-5 pb-4 border-b border-current/10">
              <h3 className="font-display text-xs font-semibold uppercase tracking-[0.1em] text-foreground/50">Sebaran Penerima per Dusun</h3>
            </div>
            <div className="px-6 py-5">
              <div className="h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData} layout="vertical" margin={{ left: 0, right: 24, top: 4, bottom: 4 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="current" strokeOpacity={0.1} />
                    <XAxis type="number" tick={{ fontSize: 11 }} />
                    <YAxis type="category" dataKey="name" tick={{ fontSize: 11 }} width={100} />
                    <Tooltip
                      content={({ active, payload, label }) => {
                        if (!active || !payload?.length) return null;
                        return (
                          <div className="bg-background border border-border rounded-lg shadow-lg px-3 py-2 text-sm">
                            <p className="font-medium">{label}</p>
                            <p className="text-accent font-bold">{payload[0].value} penerima</p>
                          </div>
                        );
                      }}
                    />
                    <Bar dataKey="count" fill="var(--accent)" radius={[0, 4, 4, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        )}

        {/* Daftar Penerima */}
        <div className="bg-background border border-current/15 rounded-xl overflow-hidden shadow-sm">
          <div className="px-6 pt-5 pb-4 border-b border-current/10 flex flex-wrap items-center justify-between gap-3">
            <h3 className="font-display text-sm font-semibold uppercase tracking-[0.1em] text-foreground/60">
              Daftar Penerima
              {total > 0 && <span className="ml-2 text-foreground/30">({total} total)</span>}
            </h3>

            {/* Search + Filter */}
            <div className="flex flex-wrap items-center gap-2">
              <div className="relative">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-foreground/30 pointer-events-none"><path fillRule="evenodd" d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z" clipRule="evenodd" /></svg>
                <input
                  type="text"
                  placeholder="Cari nama..."
                  value={search}
                  onChange={(e) => { setSearch(e.target.value); setPage(0); }}
                  className="pl-9 pr-3 py-2 rounded-md border border-border bg-background text-sm w-44"
                />
              </div>
              <select
                value={dusunFilter}
                onChange={(e) => { setDusunFilter(e.target.value); setPage(0); }}
                className="rounded-md border border-border bg-background px-3 py-2 text-sm"
              >
                <option value="">Semua Dusun</option>
                {dusunOptions.map((d) => (
                  <option key={d} value={d}>{d}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-current/15 bg-foreground/[0.02]">
                  <th className="py-3 px-4 text-left font-display text-[10px] font-bold uppercase tracking-[0.22em] text-foreground/50">Nama</th>
                  <th className="py-3 px-4 text-left font-display text-[10px] font-bold uppercase tracking-[0.22em] text-foreground/50 hidden sm:table-cell">NIK</th>
                  <th className="py-3 px-4 text-left font-display text-[10px] font-bold uppercase tracking-[0.22em] text-foreground/50">Dusun</th>
                  <th className="py-3 px-4 text-right font-display text-[10px] font-bold uppercase tracking-[0.22em] text-foreground/50 hidden sm:table-cell">Nominal</th>
                  <th className="py-3 px-4 text-center font-display text-[10px] font-bold uppercase tracking-[0.22em] text-foreground/50">Status</th>
                </tr>
              </thead>
              <tbody>
                {isPenerimaLoading ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-foreground/40 text-sm">Memuat...</td>
                  </tr>
                ) : penerima.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-foreground/40 text-sm">Belum ada data penerima.</td>
                  </tr>
                ) : (
                  penerima.map((p) => (
                    <tr key={p.id} className="border-b border-current/10 hover:bg-foreground/[0.02] transition-colors">
                      <td className="py-3 px-4 font-medium text-foreground">{p.nama || "—"}</td>
                      <td className="py-3 px-4 text-foreground/50 font-mono text-xs hidden sm:table-cell">
                        {p.nik ? "████████" : "—"}
                      </td>
                      <td className="py-3 px-4 text-foreground/70">{p.dusun || "—"}</td>
                      <td className="py-3 px-4 text-right font-medium tabular-nums text-foreground/80 hidden sm:table-cell">
                        {fmtNominal(p.nominal)}
                      </td>
                      <td className="py-3 px-4 text-center">
                        <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold ${STATUS_COLORS[p.status] || "bg-gray-100 text-gray-700"}`}>
                          {STATUS_LABELS[p.status] || p.status}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="px-6 py-4 border-t border-current/10 flex items-center justify-between">
              <button
                onClick={() => setPage((p) => Math.max(0, p - 1))}
                disabled={page === 0}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md border border-border text-sm disabled:opacity-40 hover:bg-foreground/[0.02] transition-colors"
              >
                ← Prev
              </button>
              <span className="text-sm text-foreground/50">
                Halaman {page + 1} / {totalPages}
              </span>
              <button
                onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                disabled={page >= totalPages - 1}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md border border-border text-sm disabled:opacity-40 hover:bg-foreground/[0.02] transition-colors"
              >
                Next →
              </button>
            </div>
          )}
        </div>

      </main>
    </div>
  );
}
```

CATATAN: Jika `BansosDetailPage` ternyata ada di file yang berbeda (cek App.tsx lazy import line 166 — `BansosDetailPage` dari `./seruni/pages`), maka edit dilakukan di `src/seruni/pages.tsx`.

- [ ] **Step 3: Commit**

```bash
git add src/seruni/pages.tsx
git commit -m "feat(bansos): redesain detail page dengan stats, chart sebaran per dusun, dan tabel penerima

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Upgrade PenerimaBansosAdmin di AdminOps.tsx

**Files:**
- Modify: `src/seruni/admin/AdminOps.tsx:324-389`
- Dependencies: `usePenerimaBansosStats` dari queries, `useState` React

**Interfaces:**
- Consumes: `usePenerimaBansosStats(bansosId)`, existing `PenerimaBansosTable` component
- Produces: Updated `PenerimaBansosAdmin` with stats cards header

- [ ] **Step 1: Ambil konteks dan import**

Buka `src/seruni/admin/AdminOps.tsx` line 1-30 untuk lihat import yang sudah ada. Pastikan `usePenerimaBansosStats` perlu diimport dari queries. Cek apakah file ini mengimport dari queries.ts atau inline.

Ambil `PenerimaBansosAdmin` function lengkap (lines 324-389).

- [ ] **Step 2: Tambah import useState jika belum ada**

Jika `useState` belum diimport di file ini, tambahkan:
```typescript
import { useState, useEffect } from "react";
```

Pastikan `usePenerimaBansosStats` dan `supabase` sudah accessible. Dari kode existing, `supabase` sudah diimport dan `useEffect` sudah ada.

- [ ] **Step 3: Upgrade PenerimaBansosAdmin**

Replace entire `PenerimaBansosAdmin` function (lines 324-362, sebelum `PenerimaBansosTable`) dengan versi baru yang punya stats header:

```typescript
export function PenerimaBansosAdmin() {
  const [programs, setPrograms] = useState<{ id: string; nama: string; kode: string }[]>([]);
  const [bansosId, setBansosId] = useState<string>("");
  useEffect(() => {
    supabase.from("bantuan_sosial").select("id,nama,kode").order("nama").then(({ data }) => {
      const list = (data as any) || [];
      setPrograms(list);
      if (list.length && !bansosId) setBansosId(list[0].id);
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const { stats, loading: isStatsLoading } = usePenerimaBansosStats(bansosId);

  if (!programs.length) {
    return (
      <div className="rounded-xl bg-card border border-border p-6 text-sm text-muted-foreground">
        Belum ada program bantuan sosial. Tambahkan program terlebih dahulu di menu "Program Bansos".
      </div>
    );
  }

  return (
    <div>
      {/* Stats Header */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="bg-card border border-border rounded-xl p-4 text-center">
          <div className="font-display text-3xl font-bold text-accent tabular-nums">
            {isStatsLoading ? "..." : stats.total}
          </div>
          <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-muted-foreground">Total</div>
        </div>
        <div className="bg-card border border-border rounded-xl p-4 text-center">
          <div className="font-display text-3xl font-bold text-green-600 tabular-nums">
            {isStatsLoading ? "..." : stats.aktif}
          </div>
          <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-muted-foreground">Aktif</div>
        </div>
        <div className="bg-card border border-border rounded-xl p-4 text-center">
          <div className="font-display text-3xl font-bold text-gray-400 tabular-nums">
            {isStatsLoading ? "..." : stats.nonaktif}
          </div>
          <div className="mt-1 font-display text-[10px] font-bold uppercase tracking-[0.2em] text-muted-foreground">Nonaktif</div>
        </div>
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-3">
        <label className="text-sm font-medium">Program:</label>
        <select
          value={bansosId}
          onChange={(e) => setBansosId(e.target.value)}
          className="rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          {programs.map((p) => (
            <option key={p.id} value={p.id}>{p.kode} — {p.nama}</option>
          ))}
        </select>
      </div>
      {bansosId && (
        <PenerimaBansosTable key={bansosId} bansosId={bansosId} />
      )}
    </div>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add src/seruni/admin/AdminOps.tsx
git commit -m "feat(admin): tambah stats header di PenerimaBansosAdmin dengan total/aktif/nonaktif

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Fix Schema — Cek Kolom tanggal_salur

**Files:**
- Modify: `supabase/migrations/` (create fix migration jika perlu)
- Check: `src/seruni/admin/AdminOps.tsx:384` (kolom tanggal_salur di TableCrud columns)

- [ ] **Step 1: Cek apakah kolom tanggal_salur ada di database**

Jalankan di Supabase SQL Editor:

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'penerima_bansos'
ORDER BY ordinal_position;
```

Cek apakah `tanggal_salur` muncul di hasil.

- [ ] **Step 2: Jika kolom tidak ada, buat migration**

Jika `tanggal_salur` TIDAK ada, buat file migration baru:

```sql
-- supabase/migrations/YYYYMMDDXXXXXX_add_penerima_bansos_columns.sql
ALTER TABLE public.penerima_bansos
  ADD COLUMN IF NOT EXISTS tanggal_salur DATE,
  ADD COLUMN IF NOT EXISTS tanggal_daftar DATE DEFAULT CURRENT_DATE;
```

Jika kolom SUDAH ada, tidak perlu buat migration.

- [ ] **Step 3: Commit jika ada perubahan migration**

```bash
git add supabase/migrations/
git commit -m "fix(db): tambah kolom tanggal_salur dan tanggal_daftar ke penerima_bansos

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Verifikasi — Build & Test

- [ ] **Step 1: Run build**

```bash
cd e:/Seruni.id && npm run build 2>&1 | tail -20
```

Expected: Build succeeds with 0 errors.

- [ ] **Step 2: Test BansosDetailPage manually**

Buka `http://localhost:8080/bansos` → klik salah satu program → pastikan:
1. Stats cards tampil (total penerima, kuota, % terpenuhi)
2. Chart sebaran per burnett tampil jika ada data
3. Tabel penerima tampil dengan search dan filter
4. Pagination berfungsi
5. NIK tampil sebagai "████████" (masked)
6. Status badge berwarna sesuai

- [ ] **Step 3: Test admin page**

Buka `http://localhost:8080/admin/bansos-penerima` → pastikan:
1. Stats header tampil (total/aktif/nonaktif)
2. Dropdown program berfungsi
3. Tabel penerima berfungsi dengan CRUD

- [ ] **Step 4: Final commit jika semua pass**

```bash
git add -A
git commit -m "feat: complete bansos detail page dan penerima bansos admin upgrade

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Spec Coverage Checklist

| Requirement | Task |
|-------------|------|
| Layout standalone, sticky back button | Task 2 |
| Header card (kode, nama, sumber, aktif badge) | Task 2 |
| 3 stats cards (penerima, kuota, % terpenuhi) | Task 2 |
| Periode dan deskripsi | Task 2 |
| Chart sebaran per burnett (Recharts) | Task 2 |
| Tabel penerima (nama, NIK masked, burnett, nominal, status) | Task 2 |
| Search + filter burnett | Task 2 |
| Pagination 20/page | Task 2 |
| usePenerimaBansos upgraded (search/filter/page) | Task 1 |
| usePenerimaBansosStats hook | Task 1 |
| Admin stats header (total/aktif/nonaktif) | Task 3 |
| Fix schema tanggal_salur | Task 4 |
| Build succeeds | Task 5 |
