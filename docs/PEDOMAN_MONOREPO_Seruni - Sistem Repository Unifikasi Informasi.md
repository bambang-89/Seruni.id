# PEDOMAN WAJIB PENGEMBANGAN WEBSITE Seruni - Sistem Repository Unifikasi Informasi (KANTOR DESA VIRTUAL)

## Monorepo Architecture — Spesifikasi Lengkap, Terstruktur & Sistematis

---

**Versi:** 1.0 (Final Consolidated)  
**Tanggal:** 2026-07-18  
**Sumber:** Konsolidasi dari `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md`, `PRD_KANTOR_DESA_VIRTUAL.md`, `DESAIN_FRONTEND_KANTOR_DESA_VIRTUAL.md`, `SKEMA_DATABASE_ERD.md`, `WORKFLOW_SISTEM_KESELURUHAN.md`
**Status:** Dokumen Pedoman Wajib — Berlaku untuk seluruh tim pengembang (AI & manusia)

---

## DAFTAR ISI

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Arsitektur Monorepo & Teknologi](#2-arsitektur-monorepo--teknologi)
3. [Prinsip Desain Produk (Non-Negotiable)](#3-prinsip-desain-produk-non-negotiable)
4. [Sepuluh Fitur Andalan (F1–F10)](#4-sepuluh-fitur-andalan-f1f10)
5. [Skema Database & ERD Lengkap](#5-skema-database--erd-lengkap)
   - 5.1 [Konvensi Umum](#51-konvensi-umum-c1)
   - 5.2 [Core Registry & Kependudukan (C2)](#52-core-registry--kependudukan-c2)
   - 5.2.1 [Core Registry: `penduduk` sebagai Single Source of Truth](#521-core-registry-penduduk-sebagai-single-source-of-truth-referensi-sentral)
   - 5.3 [Modul Surat (F1 & F6) (C3)](#53-modul-surat-f1--f6-c3)
   - 5.4 [Modul Usulan & Voting (F2) (C4)](#54-modul-usulan--voting-f2-c4)
   - 5.5 [Modul PBB (F5) (C5)](#55-modul-pbb-f5-c5--mandiri--lengkap)
   - 5.6 [Modul APBDes / SISKEUDES (C6)](#56-modul-apbdes--siskeudes-c6)
   - 5.7 [Modul IDM / Event Propagation Layer (C7)](#57-modul-idm--event-propagation-layer-c7)
   - 5.8 [Kepatuhan & Data Sensitif (C8)](#58-kepatuhan--data-sensitif-c8)
   - 5.9 [Pertanahan, Aset, Pemetaan, Statistik & Agenda (F7–F10) (C9)](#59-pertanahan-aset-pemetaan-statistik--agenda-f7f10-c9)
   - 5.10 [Aturan Pemisahan Fakta Mentah vs Fakta Turunan (C10)](#510-aturan-pemisahan-fakta-mentah-vs-fakta-turunan-c10--wajib-dipatuhi)
6. [Alur Proses & State Machine (W1–W12)](#6-alur-proses--state-machine-w1w12)
7. [Desain Frontend & Zero-Hardcode Architecture](#7-desain-frontend--zero-hardcode-architecture)
8. [Event Propagation Layer & IDM Scoring](#8-event-propagation-layer--idm-scoring)
9. [Keamanan, Privasi & RBAC](#9-keamanan-privasi--rbac)
10. [Non-Functional Requirements](#10-non-functional-requirements)
11. [Struktur Routing Next.js App Router](#11-struktur-routing-nextjs-app-router)
12. [Urutan Migrasi Database](#12-urutan-migrasi-database)
13. [Blokir & Dependensi Eksternal](#13-blokir--dependensi-eksternal)
14. [Checklist Siap Implementasi](#14-checklist-siap-implementasi)

---

## 1. RINGKASAN EKSEKUTIF

### 1.1 Produk

**Kantor Desa Virtual (Seruni - Sistem Repository Unifikasi Informasi)** — Platform SaaS multi-tenant (subdomain per desa) yang menyatukan:

- **Registrasi & Kependudukan (Core Registry)** — Single Source of Truth data warga, basis untuk seluruh modul
- Layanan administrasi (surat, usulan, voting)
- Keuangan desa (PBB, APBDes, SISKEUDES/SIPADES export)
- Kesehatan (Posyandu, data balita)
- Ekonomi & pertanahan (objek pajak, bidang tanah, aset)
- Pemetaan partisipatif (GIS, lapor infrastruktur)
- Statistik & agenda terpadu

**Prinsip Inti:** **"Satu Input, Banyak Dampak"** — setiap fakta yang dicatat di satu modul otomatis menyebar ke modul lain lewat **Event Propagation Layer**, termasuk rekalkulasi skor **IDM (Indeks Desa Membangun)** secara real-time.

### 1.2 Target Pengguna

| Peran                         | Kebutuhan Utama                                                  |
| ----------------------------- | ---------------------------------------------------------------- |
| Warga                         | Ajukan surat, usulan & voting, cek info, bayar PBB               |
| Perangkat Desa (Admin/Sekdes) | Verifikasi surat, kelola keuangan, objek pajak, konten portal    |
| Kepala Desa                   | TTE surat, dashboard IDM & rekomendasi kebijakan, approve RKPDes |
| Kader Posyandu                | Catat kunjungan & data kesehatan balita                          |
| Dinas PMD Kabupaten           | Agregat IDM lintas-desa (akses terbatas)                         |

### 1.3 Non-Tujuan (Scope Exclusion)

- ❌ Bukan pengganti SISKEUDES/SIPADES resmi — hanya pelengkap transparansi & analitik (export file siap-unggah)
- ❌ Bukan sistem pajak negara (PPh/PPN) — hanya PBB-P2 tingkat desa
- ❌ Bukan pengganti Musyawarah Desa fisik — voting online pendukung, bukan pengganti

---

## 2. ARSITEKTUR MONOREPO & TEKNOLOGI

### 2.1 Stack Teknologi Wajib

| Layer            | Teknologi                                        | Alasan                                                |
| ---------------- | ------------------------------------------------ | ----------------------------------------------------- |
| **Frontend**     | Next.js 14+ (App Router, RSC, Server Actions)    | Multi-page architecture, SEO, mobile-first, streaming |
| **Backend/ORM**  | Drizzle ORM + PostgreSQL                         | Type-safe, performa, migrasi terstruktur              |
| **Database**     | PostgreSQL 15+ + PostGIS                         | Multi-tenant isolasi, JSONB, geospatial               |
| **Queue/Worker** | BullMQ (Redis)                                   | Event-driven IDM scoring, idempotent processing       |
| **Auth**         | NextAuth.js v5 (credentials + OTP WhatsApp)      | Role-based redirect, dual login path                  |
| **WhatsApp**     | Fonnte API                                       | Chatbot rule-based, tiering info_instan/transaksi     |
| **Styling**      | Tailwind CSS + CSS Variables (design tokens)     | Zero-hardcode theming, mobile-first                   |
| **Validation**   | Zod (schema per tipe blok, form, API)            | Runtime validation, type inference                    |
| **i18n**         | next-intl (berbasis `i18n_strings` DB)           | Multi-bahasa tanpa redeploy                           |
| **Deployment**   | Vercel (frontend) + Railway/Render (worker + DB) | Scalable, preview deployments                         |

### 2.2 Struktur Monorepo (Turborepo / Nx)

```
desaku-monorepo/
├── apps/
│   ├── web/                    # Next.js App Router (frontend utama)
│   ├── worker/                 # BullMQ workers (IDM, propagation, cron)
│   └── wa-bot/                 # WhatsApp chatbot handler (Fonnte webhook)
├── packages/
│   ├── db/                     # Drizzle schema, migrations, client
│   ├── ui/                     # Shared React components (design system)
│   ├── config/                 # Shared config (env, constants, feature flags)
│   ├── validators/             # Zod schemas (shared FE/BE)
│   ├── events/                 # Domain event types & publishers
│   └── utils/                  # Shared utilities (date, formatting, geo)
├── turbo.json                  # Turborepo pipeline config
├── package.json                # Workspace root
└── README.md
```

### 2.3 Konvensi Kode Wajib

- **TypeScript strict mode** — `noAny: true`, `strictNullChecks: true`
- **ESLint + Prettier** — konfigurasi shared di `packages/config`
- **Commit convention:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **Branch strategy:** `main` (protected), `develop`, feature branches `feat/<scope>`
- **Database migrations:** Drizzle Kit, file naming `0001_<table>.sql` per urutan §12

---

## 3. PRINSIP DESAIN PRODUK (NON-NEGOTIABLE)

> **7 Prinsip Arsitektur (dari Bagian A3 Master Spec) — WAJIB DIPATUHKAN SETIAP KODE:**

1. **Satu Sumber Kebenaran per Fakta** — Data warga hanya di `penduduk`; objek pajak hanya di `objek_pajak`; **tidak ada duplikasi antar modul**.
2. **Event Propagation Layer** — Semua perubahan fakta mentah menerbitkan `domain_events`; efek turunan (skor, dashboard, draft usulan) dihitung ulang oleh **worker**, tidak pernah diinput manual.
3. **Fakta Mentah vs Fakta Turunan Dipisah Tegas** — Tabel turunan (`idm_skor_cache`, `dashboard_agregat`, dll) **hanya ditulis oleh worker**, tidak pernah diedit admin langsung. Lihat §5.10 (C10).
4. **Privasi Berlapis** — Data sensitif (kesehatan individu, NIK penuh) dibatasi per peran; publik hanya melihat agregat.
5. **Kanal Setara** — Web dan WhatsApp berbagi state machine dan data yang sama — **tidak ada logika bisnis terduplikasi per kanal**.
6. **Zero Hardcode di Frontend** — Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen — **semua berasal dari config/database**. Detail penuh: §7.
7. **Tidak Ada Aksi Kritikal Tanpa Persetujuan Manusia** — Draft otomatis (usulan kegiatan, aset desa, ekspor kepatuhan) selalu berstatus menunggu review, **tidak pernah auto-approve/auto-eksekusi**.

---

## 4. SEPULUH FITUR ANDALAN (F1–F10)

### F0 — Registrasi & Kependudukan (Core Registry) ⭐ **FOUNDATION**

**User Story:** Sebagai perangkat desa, saya ingin mengelola data kependudukan (tambah, edit, impor Dukcapil, mutasi pindah/meninggal) secara terpusat sehingga seluruh modul lain (surat, voting, PBB, Posyandu, dll) otomatis menggunakan data yang sama tanpa duplikasi.

**Kriteria Penerimaan:**

- CRUD `penduduk` lengkap: NIK (unik per tenant), nama, jenis kelamin, tanggal lahir, status kependudukan (aktif/pindah/meninggal), nomor HP, BPJS, alamat, dusun/RT/RW
- **Import massal dari Dukcapil/Kemendagri** (CSV/Excel) dengan validasi NIK checksum, deduplikasi, dan preview sebelum commit
- **Auto-fill form di semua modul** (Surat F1, Voting F2, PBB F5, Posyandu F4, WA Bot F6) by NIK lookup
- **Status kependudukan** (`aktif`/`pindah`/`meninggal`) mengontrol eligibilitas di seluruh modul
- **Event-driven sync** via Event Propagation: `penduduk.dibuat`, `penduduk.data.berubah`, `penduduk.status.berubah`, `penduduk.bpjs.berubah` → worker update `wajib_pajak`, `balita`, `dashboard_agregat` (populasi), WA Bot session
- **RBAC ketat**: Admin desa full CRUD; Kader Posyandu read-only dusun sendiri; Warga read-only record sendiri; Dinas PMD hanya agregat cross-tenant
- **API Internal** untuk autofill: `GET /api/penduduk/by-nik/:nik` (F1/F6 surat), `GET /api/penduduk/by-nomor-hp/:hp` (F6 WA Bot), `GET /api/penduduk/aggregate/dusun` (F3 IDM, F4 Posyandu)
- **Audit trail lengkap**: Semua perubahan → `domain_events` + `penduduk_log` (append-only) dengan `aktor_id`, `field_lama`, `field_baru`, `timestamp`

**Diferensiator vs OpenSID:**

- `penduduk` sebagai **Core Registry terpisah** (bukan campur di modul surat), menjadi _single source of truth_ untuk 10+ modul
- Event-driven sync ke `wajib_pajak` (PBB), `balita` (Posyandu), `usulan_votes` (voting eligibility) — **bukan dual entry manual**
- Import Dukcapil dengan validasi checksum NIK otomatis (bukan cek manual)
- Soft delete via `status_kependudukan` (pindah/meninggal) menjaga histori IDM & audit

---

### F1 — Pelayanan Surat Online dengan TTE/QR Code

### F1 — Pelayanan Surat Online dengan TTE/QR Code

- Form auto-fill dari `penduduk` by NIK (zero input identitas manual)
- Status tracking real-time: `DIAJUKAN → DIVERIFIKASI → DITANDATANGANI → DIKIRIM → ARSIP` (atau `DITOLAK`)
- QR code → halaman verifikasi publik `/verifikasi/{uuid}`
- Kirim otomatis ke WhatsApp pemohon setelah TTE
- Nomor surat otomatis (klasifikasi arsip desa), **tidak boleh input manual**

### F2 — Usulan Kegiatan Online → RKPDes → Voting

- Submit usulan dengan kategori Bidang/Sub-Bidang (Permendagri 20/2018)
- Admin verifikasi kelayakan regulasi (checklist) sebelum tayang publik
- Voting: 1 NIK dukung banyak usulan berbeda, **1x per usulan** (`UNIQUE(usulan_id, nik)`), OTP WhatsApp
- Ranking real-time → bahan pertimbangan Musrenbangdes (bukan keputusan final otomatis)
- Usulan ditetapkan → masuk draft APBDes tahun berikutnya (kode rekening sesuai)

### F3 — Mesin Skoring IDM & Rekomendasi Kebijakan ⚠️ **BLOKIR**

- Skor 127 sub-indikator (6 dimensi) dihitung otomatis dari fakta operasional
- **Butuh:** `PETA_DERIVATION_RULES_IDM.md` & `idm_indicators.csv` (belum tersedia)
- Skor rendah → draft usulan kegiatan otomatis (kode rekening Permendes 7/2023)
- Dashboard: klasifikasi status desa + tren waktu, bukan snapshot
- **Jumlah indikator wajib diverifikasi manual** vs `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`

### F4 — Informasi Data Kesehatan (Posyandu)

- Kader input kunjungan (berat, tinggi, imunisasi) per balita
- **Data individu balita tidak pernah tampil publik** — hanya agregat per dusun/RT
- Indikasi gizi buruk → draft usulan intervensi + notifikasi admin/kader (bukan publik)
- RBAC ketat: `posyandu_akses_log` mencatat siapa akses data individu, kapan, peran apa

### F5 — Sistem Informasi PBB (Pajak Bumi & Bangunan)

- Wajib pajak entitas independen dari `penduduk` (boleh luar desa)
- Satu wajib pajak ↔ banyak objek pajak (kepemilikan bersama % didukung)
- Objek pajak: lokasi tanah & bangunan bisa beda koordinat
- Penghuni (penyewa/pesuruh) terpisah dari kepemilikan, **tidak pernah jadi wajib pajak**
- Tagihan menempel ke objek, histori kepemilikan **append-only** (`tanggal_selesai`)
- Bayar lunas → otomatis tambah PADes + rekalkulasi skor IDM (F3)

### F6 — Layanan Surat via WhatsApp Chatbot

- Bot rule-based (menu + regex sederhana), **bukan NLP kompleks**
- State percakapan tersimpan per nomor HP (`wa_chat_session`), auto-expire idle
- **Berbagi state machine yang sama dengan F1** — bukan sistem terpisah
- **Tiering (model PANDAWA/CHIKA BPJS):**
  - `info_instan`: cek status/info, jawab langsung 24 jam, **tanpa OTP, tanpa antrean admin**
  - `transaksi`: ajukan surat/usulan, **wajib OTP**, mengikuti state machine penuh, diproses admin **hanya jam kerja** (bot wajib sampaikan eksplisit)
- Nomor WA resmi tunggal, terverifikasi (centang hijau), dipublikasikan semua kanal

### F7 — Pertanahan

- Pendaftaran bidang tanah (NIB/girik/tanah kas desa) dengan riwayat kepemilikan **append-only**
- **Diferensiator:** `bidang_tanah` = fakta mentah tunggal untuk luas & lokasi — `objek_pajak` mereferensikannya, **bukan mencatat ulang**
- Event pengalihan kepemilikan tanah → otomatis mutakhirkan `wajib_pajak` PBB (menghilangkan dual entry rawan tidak sinkron di OpenSID)

### F8 — Aset & Inventaris Desa

- Pencatatan aset bergerak/tidak bergerak, termasuk tanah kas desa dari F7
- **Diferensiator:** Belanja modal dari `apbdes_realisasi` → otomatis buat draft entri aset — admin verifikasi, **bukan catat ulang manual**
- Penyusutan dihitung terjadwal (cron worker), bukan manual tahunan

### F9 — Pemetaan & GIS Partisipatif

- Batas wilayah dusun/RT/RW (poligon) + pelaporan titik infrastruktur warga (foto + lokasi)
- Verifikasi admin sebelum tampil publik (web/WA tier transaksi)
- **Diferensiator:** Peta = lapisan visual di atas data existing (objek pajak F7, posyandu F4, infrastruktur baru)
- Laporan infrastruktur rusak berat → otomatis draft usulan kegiatan (pola sama W3)
- **Privasi:** `bidang_tanah.lokasi_geom` milik warga **tidak pernah** tampil publik

### F10 — Statistik & Agenda Terpadu

- Statistik desa = live materialized view dari `domain_events` seluruh modul — **bukan input manual**
- Agenda/kalender terhubung otomatis ke jadwal Musdes (F2) & Posyandu (F4); admin hanya tambah kegiatan umum
- Reminder WA pakai kanal & tier `info_instan` F6 (opt-in per warga) — **tidak bikin sistem notifikasi baru**

---

## 5. SKEMA DATABASE & ERD LENGKAP

### 5.1 Konvensi Umum (C1)

- Semua tabel domain: `tenant_id UUID NOT NULL` (isolasi multi-tenant)
- PK: `UUID DEFAULT gen_random_uuid()`
- **Fakta mentah vs turunan dipisah tegas** (§5.10)
- Tabel transaksional kritikal: **append-only untuk histori** (status change = baris/log baru, bukan overwrite)

### 5.2 Core Registry & Kependudukan (C2)

```sql
-- tenants
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_desa VARCHAR(150) NOT NULL,
  subdomain VARCHAR(63) NOT NULL UNIQUE,
  kode_desa VARCHAR(13) NOT NULL UNIQUE,
  kecamatan VARCHAR(100), kabupaten VARCHAR(100), provinsi VARCHAR(100),
  aktif BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- REFERENCE TABLES (Tabel Referensi Standar Indonesia)
-- Disediakan sebagai global (bukan per-tenant) untuk konsistensi
-- nasional. Seed data mengikuti standar Kemendagri/BPS/Dukcapil.
-- ============================================================

-- ref_agama (Agama - sesuai UU No. 1/PNPS/1965 & Kemenag)
CREATE TABLE ref_agama (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,           -- 'ISLAM', 'KRISTEN', 'KATOLIK', 'HINDU', 'BUDDHA', 'KHONGHUCU', 'LAINNYA'
  nama VARCHAR(50) NOT NULL,                  -- 'Islam', 'Kristen Protestan', 'Katolik', 'Hindu', 'Buddha', 'Khonghucu', 'Lainnya'
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_pendidikan (Pendidikan Terakhir - standar BPS Susenas)
CREATE TABLE ref_pendidikan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,           -- 'TIDAK_SEKOLAH', 'SD', 'SMP', 'SMA', 'D1', 'D2', 'D3', 'D4', 'S1', 'S2', 'S3'
  nama VARCHAR(100) NOT NULL,                 -- 'Tidak/Belum Sekolah', 'SD/Sederajat', 'SMP/Sederajat', 'SMA/Sederajat', 'Diploma 1', 'Diploma 2', 'Diploma 3', 'Diploma 4/Sarjana Terapan', 'Sarjana (S1)', 'Magister (S2)', 'Doktor (S3)'
  jenjang VARCHAR(20),                        -- 'TIDAK', 'DASAR', 'MENENGAH', 'TINGGI'
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_pekerjaan (Pekerjaan - standar Klasifikasi Baku Pekerjaan Indonesia/KBPI 2014)
CREATE TABLE ref_pekerjaan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,           -- Kode KBPI 2014 (mis. '1111', '2111', '9111')
  nama VARCHAR(150) NOT NULL,                 -- Nama pekerjaan lengkap
  kelompok_utama VARCHAR(2),                  -- Kode kelompok utama KBPI (1-9)
  sub_kelompok VARCHAR(3),                    -- Kode sub kelompok
  kelompok_kecil VARCHAR(4),                  -- Kode kelompok kecil
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_status_perkawinan (Status Perkawinan - standar Dukcapil)
CREATE TABLE ref_status_perkawinan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,           -- 'BELUM_KAWIN', 'KAWIN', 'CERAI_HIDUP', 'CERAI_MATI'
  nama VARCHAR(50) NOT NULL,                  -- 'Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_golongan_darah (Golongan Darah)
CREATE TABLE ref_golongan_darah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(5) NOT NULL UNIQUE,            -- 'A', 'B', 'AB', 'O', 'TIDAK_TAHU'
  nama VARCHAR(20) NOT NULL,                  -- 'A', 'B', 'AB', 'O', 'Tidak Tahu'
  rhesus VARCHAR(10),                         -- 'POSITIF', 'NEGATIF', NULL
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_hubungan_keluarga (Hubungan Keluarga - standar KK/KTP)
CREATE TABLE ref_hubungan_keluarga (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,           -- 'KEPALA_KELUARGA', 'ISTRI', 'SUAMI', 'ANAK', 'MENANTU', 'CUCU', 'ORANG_TUA', 'MERTUA', 'LAINNYA'
  nama VARCHAR(50) NOT NULL,                  -- 'Kepala Keluarga', 'Istri', 'Suami', 'Anak', 'Menantu', 'Cucu', 'Orang Tua', 'Mertua', 'Lainnya'
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_warga_negara (Kewarganegaraan)
CREATE TABLE ref_warga_negara (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(10) NOT NULL UNIQUE,           -- 'WNI', 'WNA'
  nama VARCHAR(50) NOT NULL,                  -- 'Warga Negara Indonesia', 'Warga Negara Asing'
  negara_id VARCHAR(3),                       -- ISO 3166-1 alpha-3 (mis. 'IDN', 'USA', 'MYS') - nullable untuk WNI
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ref_jenis_identitas (Jenis Identitas - untuk pendataan non-KTP)
CREATE TABLE ref_jenis_identitas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(20) NOT NULL UNIQUE,           -- 'KTP', 'KK', 'PASSPOR', 'SIM', 'KITAS', 'KITAP', 'LAINNYA'
  nama VARCHAR(50) NOT NULL,
  urutan INT NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- ============================================================
-- SEED DATA UNTUK TABEL REFERENSI (Standar Indonesia)
-- Dijalankan sekali saat setup awal (global, bukan per tenant)
-- ============================================================

-- Seed ref_agama (Kode Kemendagri standar)
INSERT INTO ref_agama (kode, nama, nama_latin, urutan, aktif) VALUES
('01', 'Islam', 'Islam', 1, true),
('02', 'Kristen Protestan', 'Kristen Protestan', 2, true),
('03', 'Katolik', 'Katolik', 3, true),
('04', 'Hindu', 'Hindu', 4, true),
('05', 'Buddha', 'Buddha', 5, true),
('06', 'Khonghucu', 'Khonghucu', 6, true),
('07', 'Lainnya', 'Lainnya', 7, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_pendidikan (Kode BPS Susenas standar)
INSERT INTO ref_pendidikan (kode, nama, jenjang, urutan, aktif) VALUES
('01', 'Tidak/Belum Sekolah', 'Tidak Sekolah', 1, true),
('02', 'Belum Tamat SD', 'Dasar', 2, true),
('03', 'SD/Sederajat', 'Dasar', 3, true),
('04', 'SLTP/Sederajat', 'Menengah', 4, true),
('05', 'SLTA/Sederajat', 'Menengah', 5, true),
('06', 'Diploma I/II', 'Tinggi', 6, true),
('07', 'Diploma III', 'Tinggi', 7, true),
('08', 'Diploma IV/S1', 'Tinggi', 8, true),
('09', 'S2', 'Tinggi', 9, true),
('10', 'S3', 'Tinggi', 10, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_pekerjaan (Subset KBJI 2014 relevan desa - kode 4 digit)
INSERT INTO ref_pekerjaan (kode, nama, kelompok_utama, kategori_ekonomi, urutan, aktif) VALUES
-- Kelompok 6: Petani, Peternak, Perikanan, Kehutanan
('6110', 'Petani Padi', '6', 'pertanian', 1, true),
('6120', 'Petani Palawija', '6', 'pertanian', 2, true),
('6130', 'Petani Sayuran', '6', 'pertanian', 3, true),
('6140', 'Petani Buah-buahan', '6', 'pertanian', 4, true),
('6150', 'Petani Tanaman Rempah/Obat', '6', 'pertanian', 5, true),
('6210', 'Peternak', '6', 'pertanian', 10, true),
('6220', 'Buruh Tani/Peternak', '6', 'informal', 11, true),
('6310', 'Nelayan/Pemancing', '6', 'pertanian', 15, true),
('6320', 'Budidaya Perikanan', '6', 'pertanian', 16, true),
('6410', 'Pekerja Kehutanan', '6', 'pertanian', 20, true),
-- Kelompok 5: Pekerja Jasa & Penjual
('5110', 'Pedagang Kecil/Los', '5', 'informal', 30, true),
('5120', 'Warung/Kios', '5', 'informal', 31, true),
('5130', 'Pedagang Kaki Lima (PKL)', '5', 'informal', 32, true),
('5140', 'Pedagang Pasar', '5', 'informal', 33, true),
('5210', 'Ojek/Online', '5', 'informal', 35, true),
('5220', 'Supir/Taksi', '5', 'informal', 36, true),
('5310', 'Jasa Rumah Tangga (PRT)', '5', 'informal', 40, true),
('5320', 'Tukang Cukur/Salon', '5', 'informal', 41, true),
('5330', 'Bengkel/Montir', '5', 'informal', 42, true),
-- Kelompok 4: Pekerja Kantor/Administrasi
('4110', 'Karyawan Swasta', '4', 'formal', 50, true),
('4120', 'PNS/TNI/POLRI', '4', 'formal', 51, true),
('4130', 'BUMN/BUMD', '4', 'formal', 52, true),
('4140', 'Karyawan BUMDes', '4', 'formal', 53, true),
('4210', 'Administrasi Umum', '4', 'formal', 55, true),
('4220', 'Sekretaris/Administrasi', '4', 'formal', 56, true),
-- Kelompok 9: Pekerja Kasar
('9110', 'Buruh Bangunan', '9', 'informal', 60, true),
('9120', 'Buruh Pabrik', '9', 'formal', 61, true),
('9130', 'Buruh Kasar Lainnya', '9', 'informal', 62, true),
('9210', 'Kebersihan/Sampah', '9', 'informal', 65, true),
('9310', 'Petugas Keamanan/Satpam', '9', 'formal', 66, true),
-- Kelompok 0: Tidak Bekerja / Khusus
('0100', 'Pelajar/Mahasiswa', '0', 'tidak_bekerja', 70, true),
('0200', 'Ibu Rumah Tangga', '0', 'tidak_bekerja', 71, true),
('0300', 'Tidak Bekerja', '0', 'tidak_bekerja', 72, true),
('0400', 'Pensiunan', '0', 'tidak_bekerja', 73, true),
('0500', 'Mengurus Rumah Tangga', '0', 'tidak_bekerja', 74, true),
('0600', 'Lainnya', '0', 'lainnya', 75, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_status_perkawinan (Kode Kemendagri)
INSERT INTO ref_status_perkawinan (kode, nama, urutan, aktif) VALUES
('1', 'Belum Kawin', 1, true),
('2', 'Kawin', 2, true),
('3', 'Cerai Hidup', 3, true),
('4', 'Cerai Mati', 4, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_hubungan_keluarga (Kode BPS)
INSERT INTO ref_hubungan_keluarga (kode, nama, urutan, aktif) VALUES
('1', 'Kepala Keluarga', 1, true),
('2', 'Istri/Suami', 2, true),
('3', 'Anak', 3, true),
('4', 'Mertua', 4, true),
('5', 'Famili Lain', 5, true),
('6', 'Pembantu', 6, true),
('7', 'Lainnya', 7, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_golongan_darah
INSERT INTO ref_golongan_darah (kode, nama, rhesus, urutan, aktif) VALUES
('A', 'A', '+', 1, true),
('B', 'B', '+', 2, true),
('AB', 'AB', '+', 3, true),
('O', 'O', '+', 4, true),
('A-', 'A', '-', 5, true),
('B-', 'B', '-', 6, true),
('AB-', 'AB', '-', 7, true),
('O-', 'O', '-', 8, true),
('UNK', 'Tidak Tahu', NULL, 9, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_warga_negara (ISO 3166-1 alpha-3, prioritas ASEAN + Indonesia)
INSERT INTO ref_warga_negara (kode_iso, nama, is_asean, aktif) VALUES
('IDN', 'Indonesia', true, true),
('MYS', 'Malaysia', true, true),
('SGP', 'Singapura', true, true),
('BRN', 'Brunei Darussalam', true, true),
('PHL', 'Filipina', true, true),
('THA', 'Thailand', true, true),
('VNM', 'Vietnam', true, true),
('MMR', 'Myanmar', true, true),
('LAO', 'Laos', true, true),
('KHM', 'Kamboja', true, true),
('USA', 'Amerika Serikat', false, true),
('JPN', 'Jepang', false, true),
('CHN', 'China', false, true),
('AUS', 'Australia', false, true),
('SAU', 'Arab Saudi', false, true),
('ARE', 'Uni Emirat Arab', false, true),
('HKG', 'Hong Kong', false, true),
('TWN', 'Taiwan', false, true),
('KOR', 'Korea Selatan', false, true),
('NLD', 'Belanda', false, true)
ON CONFLICT (kode_iso) DO NOTHING;

-- Seed ref_cacat (Kode Kemensos)
INSERT INTO ref_cacat (kode, nama, kategori, urutan, aktif) VALUES
('N', 'Tidak Cacat', 'tidak', 0, true),
('A', 'Tuna Netra', 'sensorik', 1, true),
('B', 'Tuna Rungu', 'sensorik', 2, true),
('C', 'Tuna Wicara', 'sensorik', 3, true),
('D', 'Tuna Daksa', 'fisik', 4, true),
('E', 'Tuna Grahita', 'mental', 5, true),
('F', 'Tuna Laras', 'mental', 6, true),
('G', 'Tuna Netra & Rungu', 'ganda', 7, true),
('H', 'Lainnya', 'lainnya', 8, true)
ON CONFLICT (kode) DO NOTHING;

-- Seed ref_jenis_identitas
INSERT INTO ref_jenis_identitas (kode, nama, urutan, aktif) VALUES
('KTP', 'Kartu Tanda Penduduk', 1, true),
('KK', 'Kartu Keluarga', 2, true),
('PASSPOR', 'Paspor', 3, true),
('SIM', 'Surat Izin Mengemudi', 4, true),
('KITAS', 'Kartu Izin Tinggal Terbatas', 5, true),
('KITAP', 'Kartu Izin Tinggal Tetap', 6, true),
('LAINNYA', 'Lainnya', 7, true)
ON CONFLICT (kode) DO NOTHING;

-- ============================================================
-- PENDUDUK (Core Registry) — dengan FK ke tabel referensi
-- ============================================================

-- penduduk
CREATE TABLE penduduk (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nik VARCHAR(16) NOT NULL,
  nama VARCHAR(150) NOT NULL,
  jenis_kelamin VARCHAR(1) NOT NULL CHECK (jenis_kelamin IN ('L','P')),
  tempat_lahir VARCHAR(100),
  tanggal_lahir DATE,
  agama_id UUID REFERENCES ref_agama(id),                    -- FK ke ref_agama
  pendidikan_id UUID REFERENCES ref_pendidikan(id),          -- FK ke ref_pendidikan
  pekerjaan_id UUID REFERENCES ref_pekerjaan(id),            -- FK ke ref_pekerjaan
  status_perkawinan_id UUID REFERENCES ref_status_perkawinan(id), -- FK ke ref_status_perkawinan
  golongan_darah_id UUID REFERENCES ref_golongan_darah(id),  -- FK ke ref_golongan_darah
  warga_negara_id UUID REFERENCES ref_warga_negara(id),      -- FK ke ref_warga_negara (default WNI)
  status_kependudukan VARCHAR(20) NOT NULL DEFAULT 'aktif'
    CHECK (status_kependudukan IN ('aktif','pindah','meninggal')),
  nomor_hp VARCHAR(20),
  bpjs_status VARCHAR(20) CHECK (bpjs_status IN ('aktif','tidak_aktif','tidak_ada','tidak_diketahui')),
  bpjs_nomor VARCHAR(30),
  alamat TEXT,
  rt VARCHAR(5), rw VARCHAR(5),
  dusun_id UUID REFERENCES wilayah_batas(id),                -- FK ke wilayah_batas (jenis='dusun')
  rt_id UUID REFERENCES wilayah_batas(id),                   -- FK ke wilayah_batas (jenis='rt')
  rw_id UUID REFERENCES wilayah_batas(id),                   -- FK ke wilayah_batas (jenis='rw')
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, nik)
);
-- nomor_hp TIDAK UNIQUE — satu HP bisa dipakai bergantian anggota keluarga
-- dusun_id, rt_id, rw_id menggantikan field teks dusun/rt/rw untuk integritas referensial
```

### 5.2.1 Core Registry: `penduduk` sebagai Single Source of Truth (Referensi Sentral)

> **Prinsip:** `penduduk` adalah **tabel sentral (Core Registry)** yang menjadi _single source of truth_ untuk identitas warga di seluruh modul Seruni - Sistem Repository Unifikasi Informasi (F1–F10). Semua referensi ke identitas warga **harus** melalui `penduduk.id` (UUID) atau `penduduk.nik` (natural key) — **tidak ada duplikasi data identitas** di tabel lain.

#### A. ERD Hubungan Pusat (Visual Ringkas)

```
┌─────────────────┐        ┌──────────────────┐
│     tenants      │        │     penduduk      │  ← CORE REGISTRY
├─────────────────┤   1   N├──────────────────┤
│ id (PK)          ├───────┤ id (PK)            │
└─────────────────┘        │ tenant_id (FK)     │
                            │ nik (UQ per tenant)│
                            └────────┬─────────┘
                                     │ 1
                      ┌──────────────┼──────────────┬─────────────┐
                      │ N            │ N             │ N           │ N
               ┌──────▼─────┐  ┌──────▼──────┐  ┌──────▼─────┐ ┌────▼─────┐
               │  surat_    │  │  usulan_    │  │   pbb_     │ │  wa_chat_│
               │ pengajuan  │  │  votes      │  │ wajib_pajak│ │  session │
               │ (by NIK)   │  │ (by NIK)    │  │ (by NIK,   │ │(by nomor │
               └────────────┘  └─────────────┘  │  opsional) │ │   hp)    │
                                                └────────────┘ └──────────┘
                      │ N            │ N             │ N           │ N
               ┌──────▼─────┐  ┌──────▼──────┐  ┌──────▼─────┐ ┌────▼─────┐
               │  balita    │  │ posyandu_   │  │  agenda_   │ │  usulan_ │
               │ (orang_tua_│  │ kunjungan   │  │ subscriber │ │  kegiatan│
               │  penduduk_ │  │ (dicatat_   │  │ (nomor_hp) │ │ (pengusul_│
               │  id)       │  │  oleh_      │  └────────────┘ │  penduduk_│
               └────────────┘  │  penduduk_  │                 │  id)      │
                               │  id)        │                 └───────────┘
                               └─────────────┘
```

#### B. Daftar Lengkap Relasi Foreign Key ke `penduduk`

| Modul             | Tabel                      | Kolom FK                   | Jenis Relasi      | Catatan                                                                            |
| ----------------- | -------------------------- | -------------------------- | ----------------- | ---------------------------------------------------------------------------------- |
| **F1/F6 Surat**   | `surat_pengajuan`          | `penduduk_id`              | N:1 (wajib)       | Auto-fill identitas pemohon by NIK                                                 |
| **F2 Usulan**     | `usulan_kegiatan`          | `pengusul_penduduk_id`     | N:1 (nullable)    | Null jika sumber=`draft_otomatis`                                                  |
| **F2 Voting**     | `usulan_votes`             | `nik`                      | N:1 (natural key) | `UNIQUE(usulan_id, nik)` anti-spam; verifikasi OTP WA ke `penduduk.nomor_hp`       |
| **F4 Posyandu**   | `balita`                   | `orang_tua_penduduk_id`    | N:1               | Relasi anak-orang tua untuk agregasi per dusun                                     |
| **F4 Posyandu**   | `posyandu_kunjungan`       | `dicatat_oleh_penduduk_id` | N:1               | Audit trail: kader yang mencatat (harus warga desa)                                |
| **F5 PBB**        | `wajib_pajak`              | `penduduk_id`              | N:1 (nullable)    | Null jika `is_luar_desa=true`; NIK & nama tetap referensi ke `penduduk` jika warga |
| **F6 WA Bot**     | `wa_chat_session`          | `nomor_hp`                 | N:1 (natural key) | Lookup ke `penduduk` by `nomor_hp` untuk autofill & verifikasi NIK                 |
| **F7 Pertanahan** | `kepemilikan_bidang_tanah` | `penduduk_id`              | N:1 (nullable)    | Null jika milik desa (`tanah_kas_desa`)                                            |
| **F8 Aset**       | —                          | —                          | —                 | Tidak langsung relasi ke `penduduk` (aset = milik desa)                            |
| **F9 Pemetaan**   | `titik_infrastruktur`      | `pelapor_penduduk_id`      | N:1               | Pelapor warga (audit trail)                                                        |
| **F10 Agenda**    | `agenda_subscriber`        | `nomor_hp`                 | N:1 (natural key) | Opt-in reminder WA; lookup ke `penduduk` untuk validasi warga                      |
| **Auth/RBAC**     | (auth tables)              | `penduduk_id` / `nik`      | 1:1               | Mapping user account ↔ `penduduk` untuk role `warga`                               |

#### C. Pola Akses per Modul (Access Patterns)

| Modul             | Operasi Utama                                | Query Pattern                                                                                         | Index Penting                                        |
| ----------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| **F1 Surat**      | Auto-fill form by NIK                        | `SELECT * FROM penduduk WHERE tenant_id=? AND nik=?`                                                  | `UNIQUE(tenant_id, nik)`                             |
| **F1 Surat**      | Eligibilitas surat (status_kependudukan)     | `WHERE status_kependudukan='aktif'`                                                                   | Partial index on `status_kependudukan`               |
| **F2 Voting**     | Verifikasi NIK + OTP WA                      | `SELECT nomor_hp FROM penduduk WHERE tenant_id=? AND nik=? AND status_kependudukan='aktif'`           | `UNIQUE(tenant_id, nik)`                             |
| **F2 Voting**     | Cek sudah vote?                              | `SELECT 1 FROM usulan_votes WHERE usulan_id=? AND nik=?`                                              | `UNIQUE(usulan_id, nik)`                             |
| **F4 Posyandu**   | Agregat per dusun/RT                         | `JOIN balita ON balita.orang_tua_penduduk_id=penduduk.id WHERE penduduk.dusun=?`                      | Index `penduduk(dusun, rt, rw)`                      |
| **F4 Posyandu**   | RBAC kader (hanya dusun sendiri)             | `WHERE penduduk.dusun = kader_dusun`                                                                  | Index `penduduk(dusun)`                              |
| **F5 PBB**        | Sync wajib_pajak ↔ penduduk                  | `UPDATE wajib_pajak SET nama=..., alamat=... FROM penduduk WHERE wajib_pajak.penduduk_id=penduduk.id` | FK `wajib_pajak.penduduk_id`                         |
| **F6 WA Bot**     | Session by nomor_hp                          | `SELECT * FROM wa_chat_session WHERE tenant_id=? AND nomor_hp=?`                                      | `UNIQUE(tenant_id, nomor_hp)`                        |
| **F6 WA Bot**     | Autofill NIK dari nomor_hp                   | `SELECT nik, nama FROM penduduk WHERE tenant_id=? AND nomor_hp=? AND status_kependudukan='aktif'`     | Index `penduduk(nomor_hp)` (non-unique)              |
| **F7 Pertanahan** | Riwayat kepemilikan per warga                | `SELECT * FROM kepemilikan_bidang_tanah WHERE penduduk_id=? ORDER BY berlaku_dari`                    | Index `kepemilikan_bidang_tanah(penduduk_id)`        |
| **IDM Scoring**   | Populasi per dusun/RT/RW (denominator rasio) | `COUNT(*) GROUP BY dusun, rt, rw WHERE status_kependudukan='aktif'`                                   | Index `penduduk(dusun, rt, rw, status_kependudukan)` |

#### D. Aturan Integritas Data (Data Integrity Rules) — **WAJIB DIIMPLEMENTASIKAN**

1. **NIK Immutable** — `penduduk.nik` **tidak pernah di-UPDATE** setelah insert. Koreksi NIK = `INSERT` baru + `status_kependudukan='pindah'` pada lama + event `penduduk.nik.berubah` (jarang, hanya kesalahan input awal).

2. **Status Kependudukan Mengontrol Eligibilitas** — Semua modul **harus** memfilter `status_kependudukan='aktif'`:
   - Surat (F1): Hanya warga aktif bisa ajukan
   - Voting (F2): Hanya warga aktif bisa vote
   - PBB (F5): Wajib pajak luar desa (`is_luar_desa=true`) dikecualikan
   - Posyandu (F4): Balita orang tua pindah/meninggal → tidak dihitung di agregat

3. **Nomor HP Non-Unique tapi Terindeks** — `CREATE INDEX idx_penduduk_nomor_hp ON penduduk(tenant_id, nomor_hp) WHERE nomor_hp IS NOT NULL;` untuk lookup WA Bot & autofill.

4. **Soft Delete via Status** — Tidak ada `DELETE` pada `penduduk`. `status_kependudukan='pindah'`/`meninggal` = soft delete. Data historis dipertahankan untuk audit & IDM trend.

5. **Cascade Update Terbatas** — Perubahan `nama`, `alamat`, `dusun/rt/rw` di `penduduk` **tidak otomatis cascade** ke tabel lain (surat, wajib_pajak, balita, dll). Sinkronisasi via:
   - Event `penduduk.data.berubah` → worker update tabel referensi yang _perlu_ sync (mis. `wajib_pajak.nama`, `balita.orang_tua_nama` denormalisasi)
   - Atau: selalu `JOIN` ke `penduduk` saat query (disarankan untuk data identitas agar selalu fresh)

6. **RLS Policy (Row Level Security)** — PostgreSQL RLS **wajib** pada `penduduk`:
   ```sql
   ALTER TABLE penduduk ENABLE ROW LEVEL SECURITY;
   CREATE POLICY tenant_isolation ON penduduk
     USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
   -- Policy tambahan per role (kader hanya dusun sendiri, dll) di level application
   ```

#### E. Event Propagation dari `penduduk` (Event Sourcing)

| Event Type                | Trigger                                                  | Payload (JSONB)                                            | Konsumen (Worker)                                                         |
| ------------------------- | -------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------- |
| `penduduk.dibuat`         | INSERT `penduduk`                                        | `{nik, nama, dusun, rt, rw, tanggal_lahir, jenis_kelamin}` | IDM: update populasi denominator; Dashboard: update statistik warga       |
| `penduduk.data.berubah`   | UPDATE `nama`, `alamat`, `dusun`, `rt`, `rw`, `nomor_hp` | `{field_lama, field_baru, nik}`                            | Sync ke `wajib_pajak` (jika linked), `balita.orang_tua_*`, WA Bot session |
| `penduduk.status.berubah` | UPDATE `status_kependudukan`                             | `{status_lama, status_baru, nik}`                          | **Kritis**: Eligibilitas surat, voting, IDM populasi, Posyandu agregat    |
| `penduduk.bpjs.berubah`   | UPDATE `bpjs_status`                                     | `{status_lama, status_baru, nik}`                          | IDM: indikator kesehatan (BPJS coverage)                                  |

> **Catatan:** Event `penduduk.status.berubah` adalah **pemicu paling kritis** karena mempengaruhi denominator hampir semua rasio IDM (127 indikator banyak yang berbasis populasi).

#### F. RBAC & Privasi pada `penduduk`

| Peran              | Akses ke `penduduk`                                                 | Batasan                                 |
| ------------------ | ------------------------------------------------------------------- | --------------------------------------- |
| `warga`            | Hanya record sendiri (by NIK/login)                                 | Tidak bisa lihat warga lain             |
| `kader_posyandu`   | `SELECT` warga di dusun terkait (untuk verifikasi orang tua balita) | `WHERE dusun = kader_dusun`             |
| `admin_desa`       | `SELECT` semua warga tenant                                         | Full read, bisa UPDATE data demografis  |
| `admin_kesehatan`  | `SELECT` semua warga tenant                                         | Untuk validasi data balita lintas dusun |
| `sekdes` / `kades` | `SELECT` semua + `UPDATE` status_kependudukan                       | Approve pindah/meninggal                |
| `dinas_pmd`        | `SELECT` agregat (COUNT, GROUP BY dusun) cross-tenant               | **Tidak** akses NIK/nama individu       |

#### G. Migrasi & Seeding `penduduk` (Praktik Terbaik)

1. **Urutan Migrasi:** `penduduk` **harus** di-migrasi **kedua** (setelah `tenants`) — lihat §12 urutan migrasi.
2. **Seed Data Awal:** Import dari data Dukcapil/Kemendagri (CSV/Excel) via script migrasi terpisah (`0002_seed_penduduk.sql`).
3. **Validasi NIK:** Pastikan format 16 digit, checksum valid (algoritma NIK Indonesia), unik per tenant.
4. **Backfill `dusun/rt/rw`:** Harus konsisten dengan `wilayah_batas` (FK ke `wilayah_batas` where `jenis='dusun'`/`rt`/`rw` — _future enhancement: tambah FK eksplisit_).
5. **Nomor HP:** Bersihkan format (awal `62`/`08` → simpan sebagai `628xxxxxxxxxx` standar E.164 untuk WA API).

#### H. Checklist Implementasi Core Registry (Untuk Developer)

- [ ] Tabel `penduduk` dengan `UNIQUE(tenant_id, nik)` + index `nomor_hp` + index `dusun,rt,rw,status_kependudukan`
- [ ] RLS policy `tenant_isolation` aktif
- [ ] Event publisher untuk 4 event type di atas (menggunakan `packages/events`)
- [ ] Worker consumer untuk sinkronisasi `wajib_pajak`, `balita`, `dashboard_agregat` (populasi)
- [ ] API endpoint `GET /api/penduduk/by-nik/:nik` (internal, untuk autofill F1/F6)
- [ ] API endpoint `GET /api/penduduk/by-nomor-hp/:hp` (internal, untuk WA Bot lookup)
- [ ] Validasi NIK format & checksum di Zod schema (`packages/validators`)
- [ ] UI Admin: CRUD `penduduk` dengan filter dusun/RT/RW, status, pencarian NIK/nama
- [ ] Audit log: Semua UPDATE `penduduk` → `domain_events` + `penduduk_log` (tabel terpisah append-only)
- [ ] Test integrasi: Auto-fill surat (F1), voting OTP (F2), WA Bot session (F6), IDM populasi (F3)

````

### 5.3 Modul Surat (F1 & F6) (C3)

```sql
-- surat_jenis (admin CRUD, tidak hardcode)
CREATE TABLE surat_jenis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama_jenis VARCHAR(150) NOT NULL,
  template_field JSONB NOT NULL,        -- field non-identitas yang perlu diisi
  format_nomor_arsip VARCHAR(50) NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- surat_pengajuan
CREATE TABLE surat_pengajuan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_surat_id UUID NOT NULL REFERENCES surat_jenis(id),
  penduduk_id UUID NOT NULL REFERENCES penduduk(id),
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diajukan','diverifikasi','ditolak','ditandatangani','dikirim','arsip')),
  sumber_kanal VARCHAR(10) NOT NULL DEFAULT 'web' CHECK (sumber_kanal IN ('web','whatsapp')),
  nomor_surat VARCHAR(60) UNIQUE,        -- diisi saat status=ditandatangani
  data_form JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- surat_dokumen (1:1 dengan pengajuan, setelah TTE)
CREATE TABLE surat_dokumen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL UNIQUE REFERENCES surat_pengajuan(id),
  file_path TEXT NOT NULL,
  document_hash VARCHAR(128) NOT NULL,
  qr_uuid UUID NOT NULL DEFAULT gen_random_uuid(),
  ttd_oleh_penduduk_id UUID REFERENCES penduduk(id),
  tanggal_ttd TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- surat_log_status (append-only histori)
CREATE TABLE surat_log_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL REFERENCES surat_pengajuan(id),
  status_dari VARCHAR(20), status_ke VARCHAR(20) NOT NULL,
  aktor_id UUID, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- wa_chat_session (F6)
CREATE TABLE wa_chat_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  current_state VARCHAR(30) NOT NULL DEFAULT 'menu_utama',
  tier VARCHAR(15) NOT NULL DEFAULT 'transaksi'
    CHECK (tier IN ('info_instan','transaksi')),
  context_data JSONB NOT NULL DEFAULT '{}',
  surat_pengajuan_id UUID REFERENCES surat_pengajuan(id),
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(tenant_id, nomor_hp)
);
````

### 5.4 Modul Usulan & Voting (F2) (C4)

```sql
-- usulan_kegiatan
CREATE TABLE usulan_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  pengusul_penduduk_id UUID REFERENCES penduduk(id),
  judul VARCHAR(200) NOT NULL,
  deskripsi TEXT NOT NULL,
  kategori_bidang VARCHAR(100) NOT NULL,
  kategori_sub_bidang VARCHAR(100) NOT NULL,
  lokasi TEXT,
  estimasi_manfaat TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'diajukan'
    CHECK (status IN ('diajukan','ditolak','lolos_verifikasi','ditetapkan_rkpdes')),
  kode_rekening_saran VARCHAR(30),
  sumber VARCHAR(20) NOT NULL DEFAULT 'warga' CHECK (sumber IN ('warga','draft_otomatis')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- usulan_votes (UNIQUE constraint anti-spam)
CREATE TABLE usulan_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usulan_id UUID NOT NULL REFERENCES usulan_kegiatan(id),
  nik VARCHAR(16) NOT NULL,
  voted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(usulan_id, nik)
);

-- usulan_kegiatan_draft_otomatis (HANYA worker yang tulis)
CREATE TABLE usulan_kegiatan_draft_otomatis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kategori VARCHAR(50) NOT NULL,
  sumber_pemicu VARCHAR(100) NOT NULL,
  sumber_ref_id UUID NOT NULL,
  kode_rekening_saran VARCHAR(30),
  status VARCHAR(20) NOT NULL DEFAULT 'menunggu_review'
    CHECK (status IN ('menunggu_review','diadopsi','diabaikan')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 5.5 Modul PBB (F5) (C5) — **Mandiri & Lengkap**

```sql
-- wajib_pajak (independen dari penduduk)
CREATE TABLE wajib_pajak (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  penduduk_id UUID REFERENCES penduduk(id),
  nik VARCHAR(16) NOT NULL,
  nama VARCHAR(150) NOT NULL,
  alamat_domisili TEXT,
  is_luar_desa BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- objek_pajak (referensi bidang_tanah untuk luas & lokasi)
CREATE TABLE objek_pajak (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nop VARCHAR(30) NOT NULL,
  bidang_tanah_id UUID REFERENCES bidang_tanah(id),
  status VARCHAR(20) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif','nonaktif','sengketa')),
  jenis_usaha VARCHAR(100),
  nilai_njop_total NUMERIC(15,2) NOT NULL DEFAULT 0,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, nop)
);

-- objek_pajak_lokasi (tanah/bangunan, bisa beda koordinat)
CREATE TABLE objek_pajak_lokasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  jenis_lokasi VARCHAR(10) NOT NULL CHECK (jenis_lokasi IN ('tanah','bangunan')),
  latitude NUMERIC(10,7), longitude NUMERIC(10,7),
  luas_m2 NUMERIC(12,2) NOT NULL,
  kelas_njop VARCHAR(10) NOT NULL,
  nilai_njop_per_m2 NUMERIC(15,2) NOT NULL
);
CREATE INDEX idx_objek_pajak_lokasi_geo ON objek_pajak_lokasi(latitude, longitude);

-- objek_pajak_penghuni (penyewa/pesuruh — TIDAK wajib pajak)
CREATE TABLE objek_pajak_penghuni (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  nama_penghuni VARCHAR(150) NOT NULL,
  jenis_penghuni VARCHAR(20) NOT NULL CHECK (jenis_penghuni IN ('penyewa','pesuruh','lainnya')),
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE
);

-- kepemilikan_objek (append-only, pola sama bidang_tanah)
CREATE TABLE kepemilikan_objek (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wajib_pajak_id UUID NOT NULL REFERENCES wajib_pajak(id),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  persentase_kepemilikan NUMERIC(5,2) NOT NULL CHECK (persentase_kepemilikan > 0 AND persentase_kepemilikan <= 100),
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE
);

-- pbb_tagihan
CREATE TABLE pbb_tagihan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  objek_pajak_id UUID NOT NULL REFERENCES objek_pajak(id),
  tahun_pajak INT NOT NULL,
  jumlah_pokok NUMERIC(15,2) NOT NULL,
  denda NUMERIC(15,2) NOT NULL DEFAULT 0,
  status_bayar VARCHAR(15) NOT NULL DEFAULT 'belum_bayar'
    CHECK (status_bayar IN ('belum_bayar','sebagian','lunas')),
  snapshot_wajib_pajak_utama_id UUID NOT NULL REFERENCES wajib_pajak(id),
  tanggal_bayar TIMESTAMPTZ,
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(objek_pajak_id, tahun_pajak)
);
-- Event: pbb.tagihan.dibayar → worker INSERT pades_pendapatan + update idm_skor_cache
```

### 5.6 Modul APBDes / SISKEUDES (C6)

```sql
-- Referensi global (sama semua tenant, seed sekali)
CREATE TABLE bidang_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode VARCHAR(2) NOT NULL UNIQUE,  -- '1'..'5' Permendagri 20/2018
  nama VARCHAR(150) NOT NULL
);

CREATE TABLE sub_bidang (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_kegiatan_id UUID NOT NULL REFERENCES bidang_kegiatan(id),
  kode VARCHAR(10) NOT NULL,
  nama VARCHAR(200) NOT NULL,
  UNIQUE(bidang_kegiatan_id, kode)
);

CREATE TABLE rekening_anggaran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sub_bidang_id UUID NOT NULL REFERENCES sub_bidang(id),
  kode_rekening VARCHAR(30) NOT NULL UNIQUE,  -- konsisten dengan idm_indicators.kode_rekening
  nama_rekening VARCHAR(200) NOT NULL,
  jenis_belanja VARCHAR(15) NOT NULL CHECK (jenis_belanja IN ('operasional','modal','tak_terduga','transfer'))
);

-- kegiatan_desa (per tahun anggaran)
CREATE TABLE kegiatan_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  sub_bidang_id UUID NOT NULL REFERENCES sub_bidang(id),
  rekening_anggaran_id UUID NOT NULL REFERENCES rekening_anggaran(id),
  nama_kegiatan VARCHAR(200) NOT NULL,
  usulan_kegiatan_id UUID REFERENCES usulan_kegiatan(id),
  tahun_anggaran VARCHAR(4) NOT NULL,
  pagu_anggaran NUMERIC(15,2) NOT NULL,
  sumber_dana VARCHAR(20) NOT NULL DEFAULT 'add'
    CHECK (sumber_dana IN ('add','dana_desa','pad','bagi_hasil_pajak','lainnya')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- apbdes_realisasi (event source untuk ekspor & aset)
CREATE TABLE apbdes_realisasi (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kegiatan_desa_id UUID NOT NULL REFERENCES kegiatan_desa(id),
  jenis_belanja VARCHAR(15) NOT NULL CHECK (jenis_belanja IN ('operasional','modal','tak_terduga','transfer')),
  jumlah NUMERIC(15,2) NOT NULL,
  tanggal_realisasi DATE NOT NULL,
  keterangan TEXT,
  dicatat_oleh UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: apbdes.realisasi.dicatat → ekspor_kepatuhan (siskeudes), jika modal → draft aset_desa

-- pades_pendapatan (FAKTA TURUNAN — HANYA WORKER)
CREATE TABLE pades_pendapatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  sumber VARCHAR(20) NOT NULL CHECK (sumber IN ('pbb','retribusi','hibah','lainnya')),
  sumber_ref_id UUID,
  jumlah NUMERIC(15,2) NOT NULL,
  tanggal DATE NOT NULL,
  dicatat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- TIDAK ADA endpoint admin untuk INSERT manual (konsisten C10)
```

### 5.7 Modul IDM / Event Propagation Layer (C7)

```sql
-- domain_events (event sourcing)
CREATE TABLE domain_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  event_type VARCHAR(100) NOT NULL,
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ
);
CREATE INDEX idx_events_unprocessed ON domain_events(tenant_id, processed_at) WHERE processed_at IS NULL;

-- idm_indicators (seed dari idm_indicators.csv, sama semua tenant)
CREATE TABLE idm_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dimensi_no INT NOT NULL, dimensi_nama VARCHAR(100) NOT NULL,
  subdim_kode VARCHAR(20), subdim_nama VARCHAR(150),
  indikator_no INT NOT NULL, indikator_nama VARCHAR(200) NOT NULL,
  indikator_skor_max INT,
  sub_kode VARCHAR(10), sub_pertanyaan TEXT, sub_skor_max INT,
  rekomendasi_intervensi TEXT, kode_rekening VARCHAR(30), pelaksana TEXT,
  sumber_data VARCHAR(20) NOT NULL DEFAULT 'operasional'
    CHECK (sumber_data IN ('operasional','periodik_manual','eksternal'))
);

-- idm_scoring_thresholds (ambang per skor 1-5)
CREATE TABLE idm_scoring_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id),
  skor_level INT NOT NULL CHECK (skor_level BETWEEN 1 AND 5),
  deskripsi_kondisi TEXT NOT NULL,
  nilai_ambang_bawah NUMERIC, nilai_ambang_atas NUMERIC
);

-- idm_skor_cache (HANYA WORKER)
CREATE TABLE idm_skor_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  indikator_kode VARCHAR(30) NOT NULL,
  skor NUMERIC, nilai_agregat NUMERIC,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, indikator_kode)
);

-- idm_status_desa (klasifikasi akhir, dibaca Portal Publik)
CREATE TABLE idm_status_desa (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  total_skor NUMERIC NOT NULL,
  status VARCHAR(30) NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- dashboard_agregat (FAKTA TURUNAN — HANYA WORKER, generic key-value)
CREATE TABLE dashboard_agregat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  wilayah_id UUID REFERENCES wilayah_batas(id),
  kategori VARCHAR(40) NOT NULL,
  metrik_key VARCHAR(60) NOT NULL,
  metrik_value NUMERIC NOT NULL,
  periode VARCHAR(20) NOT NULL,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, wilayah_id, kategori, metrik_key, periode)
);
```

### 5.8 Kepatuhan & Data Sensitif (C8)

```sql
-- ekspor_kepatuhan (SISKEUDES/SIPADES export)
CREATE TABLE ekspor_kepatuhan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_ekspor VARCHAR(30) NOT NULL CHECK (jenis_ekspor IN ('siskeudes','sipades')),
  periode VARCHAR(20) NOT NULL,
  file_path TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diverifikasi_admin','diunduh')),
  dihasilkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- balita (fakta mentah F4)
CREATE TABLE balita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama VARCHAR(150) NOT NULL,
  tanggal_lahir DATE NOT NULL,
  orang_tua_penduduk_id UUID REFERENCES penduduk(id),
  dusun_id UUID REFERENCES wilayah_batas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- posyandu_kunjungan (fakta mentah, input kader)
CREATE TABLE posyandu_kunjungan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  balita_id UUID NOT NULL REFERENCES balita(id),
  tanggal DATE NOT NULL,
  berat_kg NUMERIC(5,2), tinggi_cm NUMERIC(5,2),
  imunisasi VARCHAR(50)[],
  status_gizi VARCHAR(20) CHECK (status_gizi IN ('baik','kurang','buruk','lebih')),
  dicatat_oleh_penduduk_id UUID REFERENCES penduduk(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- posyandu_akses_log (RBAC & audit)
CREATE TABLE posyandu_akses_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kunjungan_id UUID NOT NULL REFERENCES posyandu_kunjungan(id),
  diakses_oleh UUID NOT NULL,
  peran_pengakses VARCHAR(20) NOT NULL CHECK (peran_pengakses IN ('kader','admin_kesehatan','kades')),
  diakses_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 5.9 Pertanahan, Aset, Pemetaan, Statistik & Agenda (F7–F10) (C9)

```sql
-- F7. PERTANAHAN
CREATE TABLE bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_persil VARCHAR(50),
  jenis_alas_hak VARCHAR(20) NOT NULL CHECK (jenis_alas_hak IN ('shm','shgb','girik','tanah_kas_desa','lainnya')),
  luas_m2 NUMERIC(12,2) NOT NULL,
  lokasi_geom GEOMETRY(POLYGON, 4326),
  dusun_id UUID REFERENCES wilayah_batas(id),
  status VARCHAR(20) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif','sengketa','nonaktif')),
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE kepemilikan_bidang_tanah (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bidang_tanah_id UUID NOT NULL REFERENCES bidang_tanah(id),
  penduduk_id UUID REFERENCES penduduk(id),
  jenis_perolehan VARCHAR(20) NOT NULL CHECK (jenis_perolehan IN ('jual_beli','waris','hibah','girik_awal','pengadaan_desa')),
  berlaku_dari DATE NOT NULL,
  berlaku_sampai DATE,
  dicatat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Event: bidang_tanah.dialihkan → wajib_pajak (update), F9 peta, F8 aset (jika tanah_kas_desa)

-- F8. ASET & INVENTARIS
CREATE TABLE aset_desa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kode_aset VARCHAR(30) NOT NULL,
  nama_aset VARCHAR(200) NOT NULL,
  kategori VARCHAR(30) NOT NULL CHECK (kategori IN ('tanah','bangunan','kendaraan','peralatan','lainnya')),
  bidang_tanah_id UUID REFERENCES bidang_tanah(id),
  nilai_perolehan NUMERIC(15,2),
  tanggal_perolehan DATE,
  sumber_perolehan VARCHAR(20) CHECK (sumber_perolehan IN ('apbdes','hibah','tanah_kas_desa_lama')),
  apbdes_realisasi_id UUID REFERENCES apbdes_realisasi(id),
  kondisi VARCHAR(20) NOT NULL DEFAULT 'baik' CHECK (kondisi IN ('baik','rusak_ringan','rusak_berat')),
  status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','diverifikasi','aktif','dihapusbukukan')),
  dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE aset_penyusutan (FAKTA TURUNAN — cron worker tahunan)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aset_id UUID NOT NULL REFERENCES aset_desa(id),
  periode VARCHAR(10) NOT NULL,
  nilai_buku NUMERIC(15,2) NOT NULL,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- F9. PEMETAAN & GIS
CREATE TABLE wilayah_batas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis VARCHAR(10) NOT NULL CHECK (jenis IN ('dusun','rt','rw')),
  nama VARCHAR(100) NOT NULL,
  geom GEOMETRY(POLYGON, 4326) NOT NULL,
  parent_id UUID REFERENCES wilayah_batas(id)
);

CREATE TABLE titik_infrastruktur (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  pelapor_penduduk_id UUID REFERENCES penduduk(id),
  jenis VARCHAR(30) NOT NULL CHECK (jenis IN ('jalan_rusak','fasilitas_umum','lampu_jalan','lainnya')),
  deskripsi TEXT,
  foto_url TEXT,
  lokasi_geom GEOMETRY(POINT, 4326) NOT NULL,
  kondisi VARCHAR(20) CHECK (kondisi IN ('baik','rusak_ringan','rusak_berat')),
  status VARCHAR(20) NOT NULL DEFAULT 'dilaporkan' CHECK (status IN ('dilaporkan','diverifikasi','usulan_dibuat','selesai')),
  dilaporkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Privasi: bidang_tanah.lokasi_geom milik warga TIDAK tampil publik

-- F10. STATISTIK & AGENDA
CREATE TABLE agenda_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  judul VARCHAR(200) NOT NULL,
  jenis VARCHAR(20) NOT NULL CHECK (jenis IN ('musdes','posyandu','umum')),
  sumber_id UUID,
  waktu_mulai TIMESTAMPTZ NOT NULL,
  waktu_selesai TIMESTAMPTZ,
  lokasi TEXT,
  dibuat_otomatis BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE agenda_subscriber (
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  jenis_agenda VARCHAR(20)[] NOT NULL DEFAULT ARRAY['musdes','posyandu','umum'],
  PRIMARY KEY (tenant_id, nomor_hp)
);
-- Statistik: TIDAK ada tabel baru — materialized view di atas idm_status_desa, dashboard_agregat, aset_desa, bidang_tanah
```

### 5.10 Aturan Pemisahan Fakta Mentah vs Fakta Turunan (C10) — **WAJIB DIPATUHI**

| Kategori          | Tabel                                                                                                                                                                                                                                                                                                                                | Ditulis oleh                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| **Fakta mentah**  | `tenants`, `penduduk`, `surat_pengajuan`, `usulan_kegiatan` (sumber=warga), `usulan_votes`, `wajib_pajak`, `objek_pajak*`, `kepemilikan_objek`, `pbb_tagihan`, `bidang_kegiatan`, `sub_bidang`, `rekening_anggaran`, `kegiatan_desa`, `apbdes_realisasi`, `balita`, `posyandu_kunjungan`, `bidang_tanah`, `kepemilikan_bidang_tanah` | Manusia (form web/WA) atau integrasi eksternal |
| **Fakta turunan** | `idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `usulan_kegiatan_draft_otomatis`, `pades_pendapatan`, `aset_penyusutan`                                                                                                                                                                                                    | **HANYA** worker propagasi (BullMQ)            |

**Aturan tegas:** Tidak ada endpoint API yang mengizinkan admin meng-edit langsung tabel fakta turunan. Koreksi selalu dilakukan di fakta mentah, sistem menghitung ulang otomatis.

---

## 6. ALUR PROSES & STATE MACHINE (W1–W12)

### W1. Alur Surat Online (TTE/QR) — F1

```
[Warga: Web/WA] Pilih jenis surat
    │
    ▼
Form autofill dari `penduduk` (by NIK) ── field non-identitas diisi manual
    │
    ▼
Submit ──► status: DIAJUKAN ──► event: surat.diajukan
    │
    ▼
[Admin] Verifikasi kelengkapan & keabsahan data
    │
    ┌────┴────┐
    ▼         ▼
DITOLAK   DIVERIFIKASI ──► event: surat.diverifikasi
(+alasan)      │
    │           ▼
    │      [Kades/Sekdes] TTE (QR + hash dokumen)
    │           │
    │           ▼
    │      status: DITANDATANGANI ──► event: surat.diterbitkan
    │           │
    │           ▼
    │      Kirim otomatis via WA (Fonnte API) ──► status: DIKIRIM
    │           │
    │           ▼
    │      status: ARSIP (log lengkap: waktu, aktor tiap transisi)
    │
    ▼
[Warga] Notifikasi penolakan, dapat ajukan ulang dari DRAFT
```

**Event → Propagation:** `surat.diterbitkan` → Dimensi 6 IDM (indikator 45.b)
**Validasi kritikal:** Nomor surat auto-generate (format klasifikasi arsip), QR hanya setelah TTE sah.

### W2. Alur Usulan → RKPDes → Voting — F2

```
[Warga] Submit usulan (judul, kategori Bidang/Sub-Bidang, lokasi, estimasi manfaat)
    │
    ▼
status: DIAJUKAN ──► event: usulan.diajukan
    │
    ▼
[Admin] Verifikasi kelayakan regulasi (checklist: RPJMDes? duplikasi? kewenangan?)
    │
    ┌────┴────┐
    ▼         ▼
DITOLAK   LOLOS_VERIFIKASI ──► event: usulan.lolos_verifikasi
(+alasan)      │
                ▼
           Masuk POOL_RKPDES, tayang publik untuk voting
                │
                ▼
      [Warga] Dukung usulan (OTP WhatsApp → verifikasi NIK)
                │
                ▼
      INSERT usulan_votes (usulan_id, nik) ── UNIQUE(usulan_id, nik)
                │           (NIK boleh dukung usulan LAIN, tidak boleh ulang di usulan SAMA)
                ▼
      Ranking real-time (jumlah dukungan) ──► event: usulan.vote.bertambah
                │
                ▼
      [Musyawarah Desa] Bahan pertimbangan Musrenbangdes (keputusan final forum resmi)
                │
                ▼
           status: DITETAPKAN_RKPDES ──► event: musdes.usulan.ditetapkan
                │
                ▼
           [Modul Keuangan] Masuk draft APBDes tahun berikutnya (kode rekening sesuai)
```

**Validasi kritikal:** Voting hanya untuk status `LOLOS_VERIFIKASI`; verifikasi NIK wajib OTP WA.

### W3. Alur Mesin Skoring IDM (Event-Driven) — F3 ⚠️ **BUTUH PETA_DERIVATION_RULES_IDM.md**

```
[Modul manapun] Fakta mentah berubah (kunjungan posyandu, tagihan PBB, surat terbit, dst)
    │
    ▼
INSERT domain_events (event_type, entity_id, payload, processed_at=NULL)
    │
    ▼
[Worker BullMQ — queue per dimensi] Ambil event belum diproses
    │
    ▼
Jalankan derivation rule (lihat PETA_DERIVATION_RULES_IDM.md — BELUM TERSEDIA)
    │
    ├──► Hitung ulang nilai agregat indikator (APM, cakupan imunisasi, PADes)
    ├──► Bandingkan threshold dari `idm_scoring_thresholds` (seed idm_indicators.csv)
    ├──► UPSERT idm_skor_cache (tenant_id, indikator_kode, skor, dihitung_pada)
    ├──► Jika skor < ambang → INSERT usulan_kegiatan_draft_otomatis (status: menunggu_review)
    ▼
UPDATE domain_events SET processed_at = now()
    │
    ▼
[Trigger] Refresh idm_status_desa (total skor 6 dimensi → klasifikasi status desa)
    │
    ▼
Portal Publik & Dashboard menampilkan status terkini (read-only dari cache)
```

**Aturan kritikal:**

- Worker **idempotent** — `ON CONFLICT DO UPDATE` untuk tabel cache
- Draft usulan otomatis **wajib verifikasi manusia** (W2) sebelum masuk RKPDes
- Hanya berlaku untuk indikator `sumber_data = 'operasional'`
- `periodik_manual`/`eksternal` di-update lewat `/admin/pengaturan/idm` — dashboard wajib tampilkan tanggal update terakhir
- MVP: 1 queue dengan job priority per dimensi; split 6 queue hanya jika lag terukur melebihi threshold

### W4. Alur Data Kesehatan (Posyandu) — F4

```
[Kader] Input kunjungan balita (berat, tinggi, imunisasi, tanggal)
    │
    ▼
INSERT posyandu_kunjungan ──► event: posyandu.kunjungan.dicatat
    │
    ├──► [Worker] Hitung status gizi (Z-score)
    │        ├── Normal → update agregat dusun
    │        └── Terindikasi gizi buruk → INSERT usulan_kegiatan_draft_otomatis (intervensi_gizi, notifikasi HANYA admin & kader)
    ▼
[Worker] Update dashboard_agregat (cakupan imunisasi %, frekuensi kunjungan per dusun)
    │
    ▼
[Worker] Rekalkulasi skor indikator 7.b (Aktivitas Posyandu)
    │
    ▼
Portal Publik menampilkan agregat saja — tidak pernah data individu balita
```

**RBAC & Audit:** Setiap akses data individu balita dicatat di `posyandu_akses_log`. Akses dibatasi: kader (dusun terkait), admin_kesehatan; Kades hanya agregat.

### W5. Alur PBB — Pendaftaran hingga Pembayaran — F5

```
[Admin] Daftarkan wajib pajak baru (independen dari penduduk, boleh luar desa)
    │
    ▼
[Admin] Daftarkan objek pajak baru
    │
    ├──► Input lokasi (1..N: tanah/bangunan, beda koordinat)
    ├──► Input kepemilikan (kepemilikan_objek: wajib_pajak_id + objek_pajak_id + persentase)
    └──► (opsional) Input penghuni (penyewa/pesuruh — TIDAK masuk kepemilikan)
    │
    ▼
event: pbb.objek_pajak.didaftarkan
    │
    ├──► [Worker] Update total NJOP desa (basis skor Dimensi Ekonomi)
    ├──► Jika akses jalan buruk → draft usulan infrastruktur
    └──► Jika objek usaha → basis skor Keragaman Aktivitas Ekonomi
    │
    ▼
[Sistem] Generate tagihan tahunan otomatis (pbb_tagihan, status: belum_bayar)
    │
    ▼
[Wajib Pajak] Bayar (tunai/transfer/QRIS) ──► [Admin] Update status_bayar = lunas
    │
    ▼
event: pbb.tagihan.dibayar
    │
    ├──► [Worker] INSERT pades_pendapatan (sumber: pbb) — otomatis
    ├──► Rekalkulasi skor indikator 47.a (PADes)
    └──► Jika objek usaha → rekalkulasi skor indikator 22 (Ekonomi)
```

**Kepemilikan kritikal:** Perpindahan **tidak pernah UPDATE baris lama** — tutup `tanggal_selesai`, buat baris baru (histori tagihan tetap valid).

### W6. Alur WhatsApp Chatbot Surat — F6

```
[Warga] Kirim pesan ke nomor WA resmi (terverifikasi centang hijau)
    │
    ▼
[Bot] Cek wa_chat_session by nomor HP
    │
    ┌────┴────┐
    ▼         ▼
Belum ada   Ada session aktif
session         │
    │             ▼
    ▼        Lanjutkan dari state terakhir
Buat session baru, state: MENU_UTAMA
    │
    ▼
Bot: "Pilih layanan: 1) Cek info & status (instan)  2) Ajukan surat/usulan  3) Lapor infrastruktur"
    │
    ┌────┴────────────────────┐
    ▼                          ▼
tier: info_instan         tier: transaksi
    │                          │
    ▼                          ▼
Jawab langsung dari       Bot: "Mau ajukan surat apa?" (list menu jenis surat)
idm_status_desa /              │
dashboard_agregat /            ▼
status surat by NIK       [Warga] Pilih jenis surat ──► state: MENGISI_FORM
(read-only, TANPA OTP,              │
TANPA antrean admin)             ▼
    │                      Bot cek NIK dikenali? ──► Ya: autofill dari `penduduk`
    │                                        └──► Tidak: minta NIK verifikasi
    │
    ▼
Bot tampilkan ringkasan ──► state: KONFIRMASI
    │
    ▼
[Warga] "Ya" ──► Submit ke alur W1 (status: DIAJUKAN, sumber_kanal: whatsapp)
    │             session di-clear/expire
    ▼
Bot kirim update status otomatis di setiap transisi W1
    │
    ▼
Setelah DITANDATANGANI ──► Bot kirim PDF+QR langsung di chat
```

**Aturan kritikal:**

- Session auto-expire (30 menit idle)
- Bot rule-based (menu + regex sederhana)
- **Jam terima vs jam proses:** `info_instan` 24 jam nonstop; `transaksi` diterima 24 jam tapi diproses admin **hanya jam kerja** — bot wajib sampaikan eksplisit: _"Pesan tersimpan. Verifikasi diproses admin Senin–Jumat 08.00–15.00 WITA."_

### W7. Alur Ekspor Kepatuhan (SISKEUDES/SIPADES)

```
[Admin] Pilih periode & jenis ekspor (siskeudes/sipades)
    │
    ▼
[Sistem] Tarik data dari fakta turunan:
    ├── siskeudes ← apbdes_realisasi, pades_pendapatan
    └── sipades   ← objek_pajak, objek_pajak_lokasi
    │
    ▼
Generate file format resmi (CSV/XML Kemendagri) ──► status: draft
    │
    ▼
[Admin] Verifikasi isi file ──► status: diverifikasi_admin
    │
    ▼
[Admin] Unduh & unggah manual ke portal resmi ──► status: diunduh
```

**Kritikal:** Satu arah, tanpa API langsung; wajib verifikasi admin sebelum `diunduh`.

### W8. Alur Pertanahan — F7

```
[Admin] Daftarkan bidang tanah: nomor persil, jenis alas hak, luas, poligon lokasi
    │
    ▼
state: DIAJUKAN ──► [Admin verifikasi dokumen alas hak] ──► state: DISAHKAN
    │
    ▼
INSERT kepemilikan_bidang_tanah (berlaku_dari = hari ini, berlaku_sampai = null)
```

**Pengalihan kepemilikan:**

```
[Admin] Catat pengalihan ──► verifikasi dokumen (akta/surat waris) ──►
UPDATE kepemilikan lama SET berlaku_sampai = tanggal_alih
INSERT kepemilikan baru (berlaku_dari = tanggal_alih)
    │
    ▼
Terbitkan event: bidang_tanah.dialihkan
    │
    ┌────┴────┬──────────────┐
    ▼          ▼               ▼
PBB wajib_pajak   F9 peta re-render   F8 (jika tanah_kas_desa berpindah status)
diperbarui         poligon
otomatis
```

**Kritikal:** Riwayat append-only; pengalihan wajib verifikasi admin.

### W9. Alur Aset & Inventaris — F8

```
[Event] apbdes.realisasi.dicatat, jenis_belanja = 'modal'
    │
    ▼
[Worker] INSERT aset_desa (status: draft, apbdes_realisasi_id terisi otomatis)
    │
    ▼
[Admin] Buka antrean draft ──► verifikasi kesesuaian ──► status: diverifikasi
    │
    ▼
[Admin] Konfirmasi aset diterima/terpasang ──► status: aktif
```

**Penyusutan (cron worker tahunan):**

```
[Cron worker] Ambil semua aset_desa status='aktif'
    │
    ▼
Hitung nilai_buku sesuai kategori ──► INSERT aset_penyusutan (periode berjalan)
```

**Kritikal:** Aset dari belanja modal APBDes **tidak pernah dicatat manual dari nol** — selalu lewat draft otomatis + verifikasi.

### W10. Alur Pemetaan & GIS Partisipatif — F9

```
[Warga] Lapor infrastruktur via web/WA (tier: transaksi) — foto + lokasi + deskripsi
    │
    ▼
INSERT titik_infrastruktur (status: dilaporkan)
    │
    ▼
[Admin] Verifikasi laporan (cek foto & lokasi) ──► status: diverifikasi
    │
    ▼
Tampil di peta publik (layer titik_infrastruktur)
    │
    ┌────┴────┐
    ▼         ▼
kondisi baik   kondisi rusak_berat
    │             │
    ▼             ▼
status: selesai   Terbitkan draft usulan_kegiatan_draft_otomatis (reuse pola W3)
(jika sudah         status: usulan_dibuat
diperbaiki)
```

**Kritikal:** Peta publik = gabungan `wilayah_batas` + titik infrastruktur terverifikasi + tanah kas desa + lokasi posyandu. **Privasi:** `bidang_tanah.lokasi_geom` milik warga **tidak pernah** tampil publik.

### W11. Alur Statistik & Agenda Terpadu — F10

```
[Event] musdes.jadwal.ditetapkan (F2) atau posyandu.jadwal.ditetapkan (F4)
    │
    ▼
[Worker] INSERT agenda_kegiatan (dibuat_otomatis: true, sumber_id terisi)
    │
    ▼
Tampil di /kalender-desa (publik)
    │
    ▼
[Worker, H-1] Untuk setiap agenda_subscriber yg jenis_agenda cocok:
    kirim reminder WA tier info_instan
```

**Statistik:** Tidak ada alur input tersendiri — dashboard = materialized view di atas `idm_status_desa`, `dashboard_agregat`, `aset_desa`, `bidang_tanah` (di-refresh worker W3).
**Kritikal:** Reminder WA pakai kanal & tier `info_instan` F6; subscriber opt-in per jenis agenda.

### W12. Ringkasan Peta Event Lintas-Modul

| Event                                                     | Diterbitkan oleh         | Konsumen (efek turunan)                                                      |
| --------------------------------------------------------- | ------------------------ | ---------------------------------------------------------------------------- |
| `penduduk.status.berubah`                                 | Core Registry            | Semua rasio IDM berbasis populasi, eligibilitas surat, daftar pemilih voting |
| `posyandu.kunjungan.dicatat`                              | Modul Kesehatan          | Skor 7.b, dashboard kesehatan, draft usulan gizi                             |
| `surat.diterbitkan`                                       | Modul Surat              | Skor 45.b, arsip, notifikasi WA                                              |
| `usulan.vote.bertambah`                                   | Modul Voting             | Ranking RKPDes                                                               |
| `musdes.usulan.ditetapkan`                                | Modul Voting/Musdes      | Skor 46, draft APBDes                                                        |
| `pbb.tagihan.dibayar`                                     | Modul PBB                | PADes, skor 47.a, skor 22 (jika usaha)                                       |
| `pbb.objek_pajak.didaftarkan`                             | Modul PBB                | Total NJOP, draft usulan infrastruktur                                       |
| `apbdes.realisasi.dicatat`                                | Modul Keuangan           | Skor Dimensi Tata Kelola Keuangan; jika modal → draft `aset_desa` (F8)       |
| `wa.layanan.selesai`                                      | WA Chatbot               | Skor 45.c/d (kanal pelayanan)                                                |
| `bidang_tanah.dialihkan`                                  | Modul Pertanahan         | `wajib_pajak` (otomatis), poligon peta (F9), status tanah kas desa (F8)      |
| `infrastruktur.dilaporkan`                                | Modul Pemetaan           | Draft usulan kegiatan (jika rusak_berat), peta publik                        |
| `musdes.jadwal.ditetapkan` / `posyandu.jadwal.ditetapkan` | Modul Voting / Kesehatan | `agenda_kegiatan` otomatis, reminder WA (F10)                                |

---

## 7. DESAIN FRONTEND & ZERO-HARDCODE ARCHITECTURE

### 7.1 Tiga Prinsip Wajib (D0)

1. **Multi-Page, bukan SPA** — Setiap halaman punya route server-rendered sendiri (Next.js App Router). Navigasi = full page load dioptimalkan (RSC streaming), bukan client-side router tunggal. Penting untuk SEO portal publik & performa HP low-end warga desa.
2. **Mobile-First** — Semua breakpoint didesain dari 360px ke atas. Layout desktop = penambahan, bukan penyusutan dari desktop.
3. **Zero Hardcode** — **Tidak ada teks, warna tema, menu navigasi, atau struktur section yang ditulis tetap di kode komponen.** Semua berasal dari config/database (§7.2). Mengganti nama desa, logo, warna tema, urutan section beranda **tidak boleh butuh redeploy kode**.

### 7.2 Arsitektur "Zero Hardcode" (D1)

#### 7.2.1 Sumber Kebenaran Konten

| Tabel                 | Fungsi                                                                            |
| --------------------- | --------------------------------------------------------------------------------- |
| `tenant_theme_config` | Warna, logo, favicon, font pilihan (2-3 preset resmi)                             |
| `site_content_blocks` | Isi tiap section beranda (tipe, urutan, JSON konten)                              |
| `site_navigation`     | Menu header/footer, urutan, label, link (internal/eksternal), submenu             |
| `site_settings`       | Nama resmi desa, alamat kantor, jam layanan, kontak, nomor WA resmi terverifikasi |
| `feature_flags`       | Modul mana yang aktif per tenant (F1-F10 bisa dinyalakan/dimatikan)               |
| `i18n_strings`        | Semua label UI (default id-ID, siap tambah bahasa daerah/EN)                      |

#### 7.2.2 Skema Pendukung (D1.2)

```sql
-- tenant_theme_config
CREATE TABLE tenant_theme_config (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  logo_url TEXT, favicon_url TEXT,
  warna_primer VARCHAR(7), warna_aksen VARCHAR(7), warna_netral VARCHAR(7),
  preset_font VARCHAR(30) NOT NULL DEFAULT 'default'
);

-- site_content_blocks
CREATE TABLE site_content_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  halaman VARCHAR(30) NOT NULL,        -- 'beranda', 'profil-desa', dst
  tipe_blok VARCHAR(30) NOT NULL,      -- 'hero','statistik','berita','layanan_unggulan','peta','testimoni'
  urutan INT NOT NULL,
  konten JSONB NOT NULL,               -- struktur bebas per tipe, divalidasi Zod schema per tipe
  aktif BOOLEAN NOT NULL DEFAULT true
);

-- site_navigation
CREATE TABLE site_navigation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  posisi VARCHAR(10) NOT NULL CHECK (posisi IN ('header','footer')),
  label VARCHAR(60) NOT NULL, href TEXT NOT NULL,
  urutan INT NOT NULL, parent_id UUID REFERENCES site_navigation(id)
);

-- feature_flags
CREATE TABLE feature_flags (
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  fitur_kode VARCHAR(30) NOT NULL,     -- 'F1_SURAT','F2_USULAN','F5_PBB', dst
  aktif BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fitur_kode)
);

-- site_settings (tambahan WA resmi)
ALTER TABLE site_settings
  ADD COLUMN nomor_wa_resmi VARCHAR(20),
  ADD COLUMN wa_business_verified BOOLEAN NOT NULL DEFAULT false;
```

#### 7.2.3 Aturan Render (D1.3) — **WAJIB DIIMPLEMENTASIKAN**

- Setiap komponen section (`<HeroBlock>`, `<StatistikBlock>`, dst) menerima **props dari `konten` JSONB**, tervalidasi skema Zod per tipe — **bukan menerima teks langsung di JSX**.
- Navigasi header/footer di-render dari query `site_navigation`, **bukan array tetap di komponen `<Header>`**.
- Modul yang `feature_flags.aktif = false` **tidak muncul** di navigasi maupun dashboard admin — dicek di layer server sebelum render, **bukan disembunyikan pakai CSS**.
- Warna & font hanya diambil dari `tenant_theme_config`, diinjeksikan sebagai **CSS variable di root layout** (`--color-primer`, `--color-aksen`, dst) — komponen **tidak pernah menulis hex/nama warna langsung**.

### 7.3 Design Token System (D2)

#### 7.3.1 Palet Warna Default (D2.1) — Tenant boleh override primer/aksen dalam batas kontras WCAG

| Token                 | Hex                          | Peran                                                  |
| --------------------- | ---------------------------- | ------------------------------------------------------ |
| `--color-primer`      | `#1F4D3D` (hijau tua sawah)  | Header, tombol utama, identitas resmi                  |
| `--color-primer-dark` | `#12231C`                    | Mode gelap, footer                                     |
| `--color-aksen`       | `#C9A227` (emas padi)        | Highlight, status positif, elemen tanda tangan/stempel |
| `--color-siaga`       | `#A63D40` (merah bata pudar) | Status urgent/tolak, dipakai sangat terbatas           |
| `--color-netral-100`  | `#F6F3EA` (kertas)           | Background terang                                      |
| `--color-netral-900`  | `#1C1C1A`                    | Teks utama                                             |

**Filosofi:** Warna diambil dari elemen fisik nyata dunia desa — hijau sawah, emas padi, merah bata — **bukan palet AI-generik**. Terracotta (`#D97757`-ish) sengaja dihindari.

#### 7.3.2 Tipografi (D2.2)

| Peran                                 | Font                                      | Alasan                                                                     |
| ------------------------------------- | ----------------------------------------- | -------------------------------------------------------------------------- |
| Display (H1/Hero)                     | **Fraunces** (slab-serif, kontras tinggi) | Berkarakter seperti huruf pada kop surat/prasasti resmi                    |
| Body                                  | **Inter** atau **Plus Jakarta Sans**      | Netral, keterbacaan tinggi di layar kecil                                  |
| Data/Utility (NOP, kode surat, tabel) | **JetBrains Mono**                        | Membedakan data terstruktur dari teks naratif — penting di dashboard admin |

Preset font di `tenant_theme_config.preset_font` dibatasi 2-3 kombinasi resmi (bukan bebas pilih font apapun) supaya konsistensi visual antar-desa tetap terjaga.

#### 7.3.3 Signature Element — "Stempel Digital" (D2.3)

Elemen unik identitas produk: **badge melingkar bergaya stempel/cap resmi desa**, dipakai konsisten di:

- Halaman verifikasi surat (`/verifikasi/{uuid}`) — animasi ringan "cap menempel" saat verifikasi berhasil
- Badge status IDM di dashboard publik (lingkaran skor dengan tepi bertekstur seperti stempel)
- Watermark tipis pola garis radial (meniru guilloche pada stempel resmi) di background hero, opacity ≤4%

Ini **satu-satunya tempat "keberanian visual" dipakai** — bagian lain tetap tenang dan disiplin.

#### 7.3.4 Breakpoint Mobile-First (D2.4)

| Breakpoint     | Lebar   | Prioritas Layout                                       |
| -------------- | ------- | ------------------------------------------------------ |
| Base (default) | 360px+  | 1 kolom, navigasi hamburger, hero full-viewport-height |
| `sm:`          | 640px+  | Grid 2 kolom untuk kartu section                       |
| `md:`          | 768px+  | Navigasi header horizontal muncul                      |
| `lg:`          | 1024px+ | Grid 3-4 kolom, sidebar dashboard admin permanen       |
| `xl:`          | 1280px+ | Max-width content container aktif                      |

### 7.4 Halaman 1 — Landing Page / Beranda (D3)

#### 7.4.1 Struktur (Top to Bottom)

```
┌─────────────────────────────────────┐
│ HEADER (sticky)                       │
│ [Logo+Nama Desa]      [☰ mobile]      │  ← desktop: menu horizontal dari site_navigation
├─────────────────────────────────────┤
│                                         │
│         HERO — FULL VIEWPORT           │  ← 100dvh, TANPA CTA (sesuai brief)
│                                         │
│   [Headline dari content_blocks]        │
│   [Sub-headline]                          │
│   [Watermark stempel radial, opacity~4%]   │
│                                              │
│              ↓ scroll indicator                │
├─────────────────────────────────────┤
│ SECTION: Statistik Desa Real-Time      │  ← dari idm_status_desa & dashboard_agregat
│ (jumlah penduduk, status IDM, dst)      │     BUKAN angka statis di kode
├─────────────────────────────────────┤
│ SECTION: Layanan Unggulan               │  ← kartu per fitur AKTIF (feature_flags)
│ [Surat Online] [Usulan Kegiatan]          │     kartu tidak render jika modul nonaktif
│ [Info Kesehatan] [PBB Online]               │
├─────────────────────────────────────┤
│ SECTION: Berita & Pengumuman Terkini      │  ← dari tabel berita_desa (CMS ringan)
├─────────────────────────────────────┤
│ SECTION: Peta Sebaran & Profil Wilayah      │  ← embed peta dusun, dari data GIS objek desa
├─────────────────────────────────────┤
│ SECTION: Transparansi Anggaran (ringkas)      │ ← grafik ringkas realisasi APBDes
├─────────────────────────────────────┤
│ FOOTER                                          │
│ [Kontak] [Jam Layanan] [Menu footer dari nav]     │
│ [Link Verifikasi Dokumen] [Media Sosial]            │
└─────────────────────────────────────┘
```

#### 7.4.2 Catatan Hero (Tanpa CTA) (D3.2)

- Hero murni sebagai _tesis visual_: menegaskan identitas desa (nama, tagline dari `site_content_blocks` tipe `hero`), **tanpa tombol aksi** — sesuai permintaan eksplisit "No CTA". Ajakan bertindak dipindah ke section "Layanan Unggulan" di bawahnya.
- Elemen: nama resmi desa + kecamatan/kabupaten (dari `site_settings`), satu kalimat identitas singkat (dari `content_blocks`), watermark stempel radial halus, indikator scroll (bukan tombol).
- Tinggi hero: `min-h-[100dvh]` (bukan `100vh`, agar akurat di mobile browser dengan address bar dinamis).

#### 7.4.3 Mobile-First Behaviour (D3.3)

- Header mobile: logo + hamburger, menu full-screen overlay saat dibuka (bukan dropdown sempit).
- Section "Layanan Unggulan": mobile 1 kolom stack vertikal, `sm:` 2 kolom, `lg:` 4 kolom.
- Statistik desa: mobile carousel swipe horizontal, desktop grid statis.

### 7.5 Halaman 2 — Public Page (Template Generik) (D4)

Dipakai untuk semua halaman statis/dinamis publik: Profil Desa, Struktur Organisasi, Berita detail, Verifikasi Dokumen, Status IDM publik, dsb. **Satu template, konten dari `site_content_blocks` dengan `halaman` berbeda** — bukan halaman terpisah yang dihardcode per topik.

```
┌─────────────────────────────────────┐
│ HEADER (sama seperti beranda)          │
├─────────────────────────────────────┤
│ Breadcrumb (dinamis dari route)          │
├─────────────────────────────────────┤
│ Judul Halaman (dari site_content_blocks)   │
│ Konten Blok 1..N (render sesuai tipe_blok)    │
│   - teks kaya (rich text dari CMS)               │
│   - tabel data (mis. struktur organisasi)          │
│   - kartu berita terkait                              │
├─────────────────────────────────────┤
│ FOOTER                                                  │
└─────────────────────────────────────┘
```

**Kasus Khusus — Halaman Verifikasi Dokumen (`/verifikasi/[uuid]`):**

- Tidak pakai `site_content_blocks` (transaksional, bukan CMS), query langsung ke `surat_dokumen` by `qr_uuid`.
- Badge "Stempel Digital" (§7.3.3) dengan status: **Dokumen Sah** (hijau) atau **Tidak Ditemukan/Dicabut** (merah, `--color-siaga`).
- Metadata non-sensitif saja: jenis surat, nomor surat, tanggal terbit, penandatangan — **tidak menampilkan isi lengkap surat** (privasi pemohon).
- Footer menampilkan `nomor_wa_resmi` + badge "Nomor WA Resmi Terverifikasi" (jika `wa_business_verified = true`), dengan peringatan anti-penipuan.

### 7.6 Halaman 3 — Login Page (D5)

#### 7.6.1 Struktur (Mobile-First, Single Column)

```
┌───────────────────────┐
│                          │
│      [Logo Desa]           │  ← dari tenant_theme_config
│   Kantor Desa Virtual        │
│   {nama_desa dari settings}     │
│                                    │
│  ┌───────────────────────┐        │
│  │ [Input: NIK / Email]      │        │
│  │ [Input: Kata Sandi]         │        │
│  │ [ ] Ingat saya                 │        │
│  │ [Tombol: Masuk]                   │        │
│  │ Lupa kata sandi? →                   │        │
│  └───────────────────────┘        │
│                                    │
│  ── atau ──                          │
│  [Masuk dengan OTP WhatsApp]           │  ← selaras dengan verifikasi OTP di F2 (voting)
│                                    │
│  Belum punya akun? Daftar sebagai warga →│
└───────────────────────┘
```

#### 7.6.2 Aturan Desain (D5.2)

- Field & label **tidak hardcode teks Indonesia** — diambil dari `i18n_strings` (mis. `auth.login.title`, `auth.login.nik_label`) supaya siap multi-bahasa tanpa ubah kode.
- Dua jalur login: **NIK+password** (warga & admin) dan **OTP WhatsApp** (warga, konsisten dengan mekanisme OTP voting F2) — **bukan implementasi otentikasi terpisah**.
- Redirect setelah login **berbasis peran** (bukan hardcode): warga → `/beranda-warga`, admin/perangkat desa → `/admin/dashboard`, Kades → `/admin/dashboard?highlight=tte-pending`.
- Pesan error login: "errors don't apologize, tidak vague" — mis. _"NIK atau kata sandi tidak cocok. Coba lagi atau gunakan OTP WhatsApp."_ — bukan _"Terjadi kesalahan."_

### 7.7 Halaman 4 — Dashboard Admin: Pengaturan & Konfigurasi (D6)

Halaman yang **paling langsung menegakkan prinsip zero-hardcode** — di sinilah perangkat desa mengubah semua hal yang di halaman lain diambil dari config.

#### 7.7.1 Struktur (Mobile-First: Sidebar jadi Bottom-Sheet/Drawer di Mobile)

```
Mobile (360-767px):                    Desktop (1024px+):
┌─────────────────┐                  ┌───┬─────────────────────┐
│ Header + ☰ menu    │                  │Sid│ Header (breadcrumb)    │
├─────────────────┤                  │ebr├─────────────────────┤
│                     │                  │ar │                          │
│  Konten Pengaturan     │                  │   │   Konten Pengaturan       │
│  (1 kolom, per-seksi)     │                  │   │   (grid 2 kolom form)      │
│                              │                  │   │                              │
│  [Drawer navigasi seksi        │                  │   │                              │
│   muncul saat ☰ ditekan]           │                  │   │                              │
└─────────────────┘                  └───┴─────────────────────┘
```

#### 7.7.2 Seksi Pengaturan (Tiap Seksi = 1 Route, Bukan Tab JS Tersembunyi) (D6.2)

| Route                              | Konten                                                                                                                        | Tabel Target               |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `/admin/pengaturan/identitas`      | Nama desa, alamat, kontak, jam layanan                                                                                        | `site_settings`            |
| `/admin/pengaturan/tema`           | Logo, favicon, warna primer/aksen (color picker + validasi WCAG), preset font                                                 | `tenant_theme_config`      |
| `/admin/pengaturan/navigasi`       | CRUD menu header/footer, drag-to-reorder                                                                                      | `site_navigation`          |
| `/admin/pengaturan/konten-beranda` | CRUD section beranda (tambah/hapus/urutkan/edit blok)                                                                         | `site_content_blocks`      |
| `/admin/pengaturan/modul`          | Toggle aktif/nonaktif F1-F10 → `feature_flags`, dengan peringatan dampak                                                      | `feature_flags`            |
| `/admin/pengaturan/pengguna`       | Kelola akun admin/perangkat desa & peran (RBAC)                                                                               | (auth tables)              |
| `/admin/pengaturan/jenis-surat`    | CRUD `surat_jenis` — admin tambah jenis surat baru tanpa deploy                                                               | `surat_jenis`              |
| `/admin/pengaturan/idm`            | Lihat/override manual `idm_scoring_thresholds`, tampilkan label `sumber_data` & tanggal update terakhir untuk non-operasional | `idm_scoring_thresholds`   |
| `/admin/pengaturan/kepatuhan`      | Generate & unduh file ekspor SISKEUDES/SIPADES per periode, wajib verifikasi admin                                            | `ekspor_kepatuhan`         |
| `/admin/penduduk`                  | CRUD data warga, import Dukcapil, validasi NIK, filter dusun/RT/RW, status kependudukan, audit log                            | `penduduk`, `penduduk_log` |

#### 7.7.3 Pola Form Pengaturan (Konsisten Semua Seksi) (D6.3)

- Perubahan disimpan sebagai **draft dulu** jika berdampak publik luas (tema, navigasi) — tombol **"Terapkan Perubahan"** eksplisit, **bukan auto-save diam-diam**.
- Preview live di panel samping (desktop) / tab terpisah (mobile) sebelum "Terapkan" — supaya admin awam teknologi tidak salah publish.
- Validasi kontras warna otomatis saat pilih `warna_primer`/`warna_aksen` — tolak kombinasi gagal WCAG AA, pesan jelas: _"Kontras teks putih di atas warna ini terlalu rendah, coba warna lebih gelap."_

#### 7.7.4 Aksesibilitas & Kualitas Dasar (D6.4) — Berlaku Semua Halaman

- Fokus keyboard terlihat jelas (`:focus-visible` custom ring, bukan dihilangkan).
- `prefers-reduced-motion` dihormati — animasi stempel/watermark otomatis nonaktif.
- Kontras teks minimum WCAG AA di semua kombinasi token warna default.
- Semua form memiliki label eksplisit (bukan placeholder-as-label).

### 7.8 Halaman Modul Operasional F7–F10 (Kesetaraan OpenSID) (D7)

| Route                          | Fungsi                                                                                                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/admin/pertanahan`            | Daftar `bidang_tanah`, filter jenis alas hak & status                                                                                                                                |
| `/admin/pertanahan/[id]`       | Detail bidang tanah + riwayat `kepemilikan_bidang_tanah` (read-only, append-only) + form catat pengalihan                                                                            |
| `/admin/anggaran`              | CRUD `kegiatan_desa` per tahun anggaran (pilih `sub_bidang`+`rekening_anggaran`) dan input `apbdes_realisasi` — sumber data kartu "Transparansi Anggaran" beranda & ekspor SISKEUDES |
| `/admin/aset`                  | Daftar `aset_desa`, filter kategori & kondisi                                                                                                                                        |
| `/admin/aset/verifikasi-draft` | Antrean draft aset dari `apbdes.realisasi.dicatat` (belanja modal) menunggu verifikasi                                                                                               |
| `/admin/pemetaan`              | Kelola `wilayah_batas` (gambar/edit poligon dusun/RT/RW)                                                                                                                             |
| `/admin/pemetaan/laporan`      | Antrean `titik_infrastruktur` status `dilaporkan` menunggu verifikasi                                                                                                                |
| `/admin/agenda`                | CRUD `agenda_kegiatan` jenis `umum`; entri `musdes`/`posyandu` tampil read-only (dibuat otomatis)                                                                                    |
| `/peta-desa`                   | **Publik** — peta layer toggle: batas wilayah, tanah kas desa, titik infrastruktur terverifikasi, lokasi posyandu. **Tidak pernah** menampilkan `bidang_tanah` milik warga individu  |
| `/lapor-infrastruktur`         | **Publik** — form lapor warga (foto + lokasi + deskripsi), setara opsi 3 di menu WA                                                                                                  |
| `/kalender-desa`               | **Publik** — agenda kegiatan, filter jenis, tombol langganan reminder WA (`agenda_subscriber`)                                                                                       |
| `/transparansi/aset-desa`      | **Publik** — agregat nilai aset per kategori, bukan daftar rinci per unit                                                                                                            |
| `/transparansi/tanah-kas-desa` | **Publik** — agregat luas & jumlah bidang tanah kas desa                                                                                                                             |

#### 7.8.1 Prinsip Privasi Peta & Transparansi (D7.1)

- Layer peta publik hanya menampilkan data yang statusnya sudah terverifikasi admin — **tidak ada data mentah warga yang tampil langsung**.
- Halaman transparansi aset/tanah selalu agregat, konsisten dengan prinsip privasi F4 (data kesehatan) — detail per unit hanya untuk admin login.

---

## 8. EVENT PROPAGATION LAYER & IDM SCORING

### 8.1 Arsitektur Event-Driven

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│  Modul Operasional  │────►│  domain_events    │────►│  BullMQ Workers     │
│  (F1-F10)           │     │  (append-only)    │     │  (per dimensi IDM)  │
└─────────────────┘     └──────────────────┘     └──────────┬──────────┘
                                                             │
                              ┌──────────────────────────────┼──────────────────────────────┐
                              ▼                              ▼                              ▼
                       ┌───────────────┐             ┌───────────────┐             ┌───────────────┐
                       │ idm_skor_cache │             │dashboard_agregat│             │usulan_kegiatan_│
                       │ (per indikator) │             │ (generic KV)    │             │draft_otomatis   │
                       └───────────────┘             └───────────────┘             └───────────────┘
                              │                              │                              │
                              └──────────────────────────────┼──────────────────────────────┘
                                                             ▼
                                                    ┌───────────────────┐
                                                    │ idm_status_desa   │
                                                    │ (klasifikasi akhir)│
                                                    └───────────────────┘
                                                             │
                              ┌──────────────────────────────┼──────────────────────────────┐
                              ▼                              ▼                              ▼
                       ┌───────────────┐             ┌───────────────┐             ┌───────────────┐
                       │ Portal Publik │             │ Dashboard Admin│             │ WA Notifikasi │
                       │ (read-only)   │             │ (read-only)   │             │ (tier info_instan)│
                       └───────────────┘             └───────────────┘             └───────────────┘
```

### 8.2 Domain Events (Tabel `domain_events`)

- Setiap perubahan fakta mentah → `INSERT domain_events` dengan `processed_at = NULL`
- Worker BullMQ memproses per dimensi IDM (6 queue logis, MVP = 1 queue dengan priority)
- **Idempotency wajib:** Worker menggunakan `ON CONFLICT DO UPDATE` untuk tabel cache, bukan `INSERT` polos
- Setelah proses: `UPDATE domain_events SET processed_at = now()`

### 8.3 IDM Scoring Rules (⚠️ BUTUH `PETA_DERIVATION_RULES_IDM.md`)

- 127 sub-indikator (6 dimensi) dihitung dari fakta operasional
- Setiap indikator punya `sumber_data`: `operasional` (real-time via worker), `periodik_manual` (admin input berkala), `eksternal` (impor BPS/Kemendes)
- Threshold skor 1-5 di `idm_scoring_thresholds` (seed dari `idm_indicators.csv`)
- Skor rendah → otomatis `INSERT usulan_kegiatan_draft_otomatis` (status `menunggu_review`, **wajib review manusia**)
- Klasifikasi status desa: `Sangat Tertinggal` / `Tertinggal` / `Berkembang` / `Maju` / `Mandiri`

### 8.4 Worker Implementation Guidelines

```typescript
// packages/worker/src/processors/idm-processor.ts
interface IDMJobData {
  eventType: string;
  entityId: string;
  payload: Record<string, unknown>;
  tenantId: string;
}

// Processor per dimensi (atau priority job di 1 queue MVP)
export async function processIDMEvent(job: Job<IDMJobData>) {
  const { eventType, entityId, payload, tenantId } = job.data;

  // 1. Tentukan indikator yang terpengaruh oleh eventType ini
  const affectedIndicators = getAffectedIndicators(eventType);

  // 2. Untuk setiap indikator operasional:
  for (const indicator of affectedIndicators) {
    if (indicator.sumber_data !== "operasional") continue;

    // 3. Hitung ulang nilai agregat (query fakta mentah terkait)
    const nilaiAgregat = await calculateAggregate(indicator, tenantId, payload);

    // 4. Bandingkan dengan threshold → tentukan skor
    const skor = determineScore(indicator, nilaiAgregat);

    // 5. UPSERT idm_skor_cache (idempotent)
    await db
      .insert(idmSkorCache)
      .values({
        tenantId,
        indikatorKode: indicator.indikator_kode,
        skor,
        nilaiAgregat,
        dihitungPada: new Date(),
      })
      .onConflictDoUpdate({
        target: [idmSkorCache.tenantId, idmSkorCache.indikatorKode],
        set: { skor, nilaiAgregat, dihitungPada: new Date() },
      });

    // 6. Jika skor < ambang → buat draft usulan otomatis
    if (skor < indicator.ambangRendah) {
      await db.insert(usulanKegiatanDraftOtomatis).values({
        tenantId,
        kategori: indicator.rekomendasi_intervensi,
        sumberPemicu: eventType,
        sumberRefId: entityId,
        kodeRekeningSaran: indicator.kode_rekening,
        status: "menunggu_review",
      });
    }
  }

  // 7. Refresh idm_status_desa (total skor 6 dimensi)
  await refreshIDMStatusDesa(tenantId);

  // 8. Mark event processed
  await db
    .update(domainEvents)
    .set({ processedAt: new Date() })
    .where(eq(domainEvents.id, job.data.eventId));
}
```

---

## 9. KEAMANAN, PRIVASI & RBAC

### 9.1 Multi-Tenancy Isolation

- Setiap tabel domain: `tenant_id UUID NOT NULL` + index `(tenant_id, ...)`
- Row Level Security (RLS) PostgreSQL **wajib diaktifkan** untuk semua tabel tenant
- Middleware Next.js: validasi `subdomain` → `tenant_id` di setiap request

### 9.2 Role-Based Access Control (RBAC)

| Peran             | Akses Utama                                                                            |
| ----------------- | -------------------------------------------------------------------------------------- |
| `warga`           | Portal publik, ajukan surat, voting, bayar PBB, lapor infrastruktur                    |
| `kader_posyandu`  | Input kunjungan balita (hanya dusun terkait), lihat agregat dusun sendiri              |
| `admin_desa`      | Verifikasi surat, kelola keuangan, objek pajak, konten portal, pengguna                |
| `admin_keuangan`  | CRUD anggaran, realisasi, ekspor kepatuhan                                             |
| `admin_kesehatan` | Akses data individu balita lintas dusun, verifikasi draft usulan gizi                  |
| `sekdes`          | Semua admin + TTE surat, approve RKPDes                                                |
| `kades`           | Dashboard IDM, rekomendasi kebijakan, TTE surat, approve RKPDes, highlight tte-pending |
| `dinas_pmd`       | Read-only agregat IDM lintas-desa (cross-tenant, terbatas)                             |

### 9.3 Privasi Berlapis (Data Sensitif)

- **NIK penuh:** Tidak pernah tampil di UI publik, hanya di halaman admin yang terautentikasi
- **Data kesehatan individu balita:** Hanya `kader` (dusun terkait) & `admin_kesehatan`; Kades hanya agregat; dicatat di `posyandu_akses_log`
- **Kepemilikan tanah warga:** `bidang_tanah.lokasi_geom` **tidak pernah** tampil di peta publik
- **Verifikasi dokumen publik:** Hanya metadata non-sensitif (jenis, nomor, tanggal, penandatangan) — **tidak isi lengkap surat**

### 9.4 Keamanan Dokumen

- Hash dokumen (SHA-256) disimpan di `surat_dokumen.document_hash`
- QR code berisi `qr_uuid` → halaman verifikasi publik
- TTE (Tanda Tangan Elektronik) mengikuti regulasi Kominfo — implementasi detail di `ARSITEKTUR_SISTEM_TERINTEGRASI.md` (belum tersedia)

### 9.5 Audit Trail

- Semua transaksi kritikal: append-only log (`surat_log_status`, `posyandu_akses_log`, `domain_events`)
- Setiap log: `aktor_id`, `waktu`, `status_dari` → `status_ke`, `catatan`

---

## 10. NON-FUNCTIONAL REQUIREMENTS

| Aspek                   | Kebutuhan                                                                      | Implementasi                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| **Multi-tenancy**       | Subdomain per desa, isolasi data ketat                                         | `tenant_id` di setiap tabel + RLS PostgreSQL                                                     |
| **Kepatuhan regulasi**  | Permendagri 20/2018 (kode rekening), Permendes 21/2020 & 7/2023 (IDM/SDGs)     | Seed `bidang_kegiatan`, `sub_bidang`, `rekening_anggaran`, `idm_indicators` dari referensi resmi |
| **Auditability**        | Semua transaksi kritikal append-only dengan jejak waktu & aktor                | `*_log_status`, `domain_events`, `posyandu_akses_log`                                            |
| **Ketersediaan kanal**  | Web responsif + WhatsApp (Fonnte API)                                          | Next.js PWA + WA Bot rule-based                                                                  |
| **Keamanan dokumen**    | Hash dokumen + QR verifikasi publik                                            | `surat_dokumen.document_hash` + `qr_uuid`                                                        |
| **Skalabilitas worker** | Bertahap: MVP 1 queue priority per dimensi; split 6 queue jika lag > threshold | BullMQ + Redis, monitoring lag via `domain_events.processed_at`                                  |
| **Performa mobile**     | Mobile-first, 360px+, low-end HP warga desa                                    | RSC streaming, `100dvh` hero, lazy load, image optimization                                      |
| **Aksesibilitas**       | WCAG AA minimum                                                                | Focus visible, prefers-reduced-motion, kontras token, label eksplisit                            |
| **i18n**                | Default id-ID, siap bahasa daerah/EN                                           | `i18n_strings` DB + next-intl, zero hardcode teks                                                |

---

## 11. STRUKTUR ROUTING NEXT.JS APP ROUTER (D8)

```
app/
├── (public)/
│   ├── page.tsx                    ← Landing/Beranda (§7.4)
│   ├── [slug]/page.tsx             ← Public Page generik (§7.5), slug dari site_content_blocks
│   ├── verifikasi/[uuid]/page.tsx  ← Verifikasi dokumen (§7.5 kasus khusus)
│   ├── peta-desa/page.tsx          ← §7.8, layer wilayah_batas + titik_infrastruktur + tanah kas desa
│   ├── lapor-infrastruktur/page.tsx ← §7.8
│   ├── kalender-desa/page.tsx      ← §7.8
│   ├── transparansi/
│   │   ├── aset-desa/page.tsx      ← §7.8
│   │   └── tanah-kas-desa/page.tsx ← §7.8
│   └── layout.tsx                  ← Header+Footer dari site_navigation
├── login/page.tsx                  ← §7.6, layout khusus tanpa header/footer publik
├── admin/
│   ├── layout.tsx                  ← Sidebar admin, dicek feature_flags & RBAC
│   ├── dashboard/page.tsx
│   ├── penduduk/                   ← F0: Registrasi Penduduk (Core Registry)
│   │   ├── page.tsx                ← Daftar warga, filter, import Dukcapil
│   │   ├── [id]/page.tsx           ← Detail & edit warga
│   │   └── import/page.tsx         ← Import massal CSV/Excel dengan validasi
│   ├── pertanahan/
│   │   ├── page.tsx                ← §7.8
│   │   └── [id]/page.tsx           ← §7.8
│   ├── aset/
│   │   ├── page.tsx                ← §7.8
│   │   └── verifikasi-draft/page.tsx ← §7.8
│   ├── pemetaan/
│   │   ├── page.tsx                ← §7.8
│   │   └── laporan/page.tsx        ← §7.8
│   ├── agenda/page.tsx             ← §7.8
│   └── pengaturan/
│       ├── identitas/page.tsx
│       ├── tema/page.tsx
│       ├── navigasi/page.tsx
│       ├── konten-beranda/page.tsx
│       ├── modul/page.tsx
│       ├── pengguna/page.tsx
│       ├── jenis-surat/page.tsx
│       ├── idm/page.tsx
│       └── kepatuhan/page.tsx      ← §7.7.2, ekspor SISKEUDES/SIPADES
```

**Catatan Routing:**

- `(public)` = route group (tidak mempengaruhi URL), shared layout header/footer
- `admin/` = route group terpisah dengan layout sidebar + RBAC check
- `login/` = standalone layout (tanpa header/footer publik)
- Semua route admin dicek `feature_flags` & RBAC di `layout.tsx` sebelum render

---

## 12. URUTAN MIGRASI DATABASE (C11)

> **Urutan eksekusi SQL yang VALID** (bukan urutan halaman dokumen). Gunakan sebagai nama file migrasi Drizzle: `0001_tenants.sql`, `0002_ref_tables.sql`, `0003_penduduk.sql`, dst.

1. `tenants`
2. **Tabel Referensi Global (Global Reference Tables)** — tidak per-tenant, seed sekali untuk semua tenant:
   - `ref_agama`, `ref_pendidikan`, `ref_pekerjaan`, `ref_status_perkawinan`, `ref_hubungan_keluarga`, `ref_golongan_darah`, `ref_warga_negara`, `ref_cacat`, `ref_jenis_identitas`
   - Dijalankan **sebelum** `penduduk` karena `penduduk` memiliki FK ke tabel-tabel ini
3. `penduduk` (Core Registry)
4. `wilayah_batas` (self-referencing `parent_id`, tidak butuh tabel lain)
5. `bidang_tanah`, `kepemilikan_bidang_tanah`
6. `bidang_kegiatan` → `sub_bidang` → `rekening_anggaran`
7. `surat_jenis` → `surat_pengajuan` → `surat_dokumen`, `surat_log_status`, `wa_chat_session`
8. `usulan_kegiatan` → `usulan_votes`, `usulan_kegiatan_draft_otomatis`
9. `kegiatan_desa` → `apbdes_realisasi`
10. `wajib_pajak`, `objek_pajak` → `objek_pajak_lokasi`, `objek_pajak_penghuni`, `kepemilikan_objek` → `pbb_tagihan`
11. `balita` → `posyandu_kunjungan` → `posyandu_akses_log`
12. `domain_events`, `idm_indicators` → `idm_scoring_thresholds`, `idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `pades_pendapatan`
13. `ekspor_kepatuhan`
14. `aset_desa` → `aset_penyusutan`
15. `titik_infrastruktur`, `agenda_kegiatan` → `agenda_subscriber`

> **Catatan Integrasi Frontend (§D1.2):** Skema pendukung zero-hardcode (`tenant_theme_config`, `site_content_blocks`, `site_navigation`, `feature_flags`, `i18n_strings`, `site_settings`) **perlu ditambahkan ke migrasi bersama skema domain di atas, idealnya setelah langkah 1 (`tenants`)** karena semuanya mem-FK ke `tenants`.

---

## 13. BLOKIR & DEPENDENSI EKSTERNAL (BAGIAN E)

### 13.1 Dokumen yang Masih Belum Tersedia (Blocker Aktif)

| Dokumen                                         | Dibutuhkan Oleh                      | Dampak Jika Belum Ada                                                                                                                           |
| ----------------------------------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `PETA_DERIVATION_RULES_IDM.md`                  | F3, W3, `/admin/pengaturan/idm`      | **Blocker implementasi F3 penuh** — pemetaan event → formula skor per indikator belum ada. Tabel siap, logika kalkulasi belum bisa ditulis.     |
| `idm_indicators.csv`                            | F3, seed `idm_indicators`            | Jumlah pasti indikator ("127") **wajib diverifikasi manual**, bukan diasumsikan. Digenerate dari `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`. |
| `ARSITEKTUR_SISTEM_TERINTEGRASI.md`             | Rasional lintas fitur (lihat §13.2)  | Rasional teknis ada tapi belum formal — implementasi bisa lanjut dengan asumsi tertulis, perlu review ulang saat tersedia.                      |
| `KUESIONER_ID_2026_Lock.xlsx` (sheet `RUMUSAN`) | Sumber generate `idm_indicators.csv` | Prasyarat sebelum `idm_indicators.csv` bisa dibuat.                                                                                             |

### 13.2 Rasional Spesifik yang Menunggu `ARSITEKTUR_SISTEM_TERINTEGRASI.md`

1. **Tiering WhatsApp** (F6, W6) — pembagian `info_instan` vs `transaksi`, jam proses admin vs jam terima 24 jam
2. **Sizing worker bertahap** (A4, W3) — kapan 1 queue MVP harus dipecah jadi 6 queue per dimensi
3. **Klasifikasi `sumber_data` indikator IDM** (§5.7) — kriteria detail operasional vs periodik_manual vs eksternal
4. **Alur ekspor kepatuhan** (W7, §5.8, §7.7.2) — detail format CSV/XML resmi Kemendagri per jenis ekspor
5. **RBAC data kesehatan lintas-dusun** (W4, §5.8) — kebijakan eskalasi lintas-dusun perlu diformalkan
6. **Strategi offline-first kader Posyandu** (W4) — **BELUM TERJAWAB DI DOKUMEN MANAPUN**. Alur W4 berasumsi backend selalu online; ini blocker arsitektur untuk kader tanpa sinyal di lapangan.

### 13.3 Keputusan Desain yang Sudah Final (E3)

- ✅ **Modul PBB (F5) dan APBDes** mandiri — seluruh `CREATE TABLE` lengkap di §5.5 & §5.6, tidak bergantung berkas eksternal
- ✅ **Penamaan tabel wilayah**: `wilayah_batas` satu-satunya tabel wilayah (§5.9) — tidak ada tabel kedua tumpang tindih
- ✅ **Route `/admin/anggaran`** (§7.8) = halaman input resmi `kegiatan_desa`/`apbdes_realisasi` (§5.6), sumber data kartu "Transparansi Anggaran" beranda & ekspor SISKEUDES

---

## 14. CHECKLIST SIAP IMPLEMENTASI (SESSION STARTER)

Sebelum mulai coding, **WAJIB** diceklist:

- [ ] **Verifikasi jumlah indikator IDM sebenarnya** terhadap `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`, jangan asumsikan "127"
- [ ] **Jalankan migrasi sesuai urutan dependensi §12** (bukan urutan halaman dokumen)
- [ ] **Pastikan skema pendukung frontend (§7.2.2) masuk migrasi** bersama skema domain (setelah `tenants`)
- [ ] **Tunda implementasi F3 penuh** sampai `PETA_DERIVATION_RULES_IDM.md` dan `idm_indicators.csv` tersedia — tabel & worker skeleton bisa disiapkan lebih dulu, tapi formula skor per indikator menunggu dokumen tersebut
- [ ] **Tandai strategi offline-first Posyandu (§13.2 poin 6)** sebagai item riset terbuka, bukan asumsi diam-diam bahwa backend selalu online
- [ ] **Setup monorepo** (Turborepo/Nx) dengan struktur §2.2
- [ ] **Konfigurasi shared packages**: `db` (Drizzle), `ui` (design system), `validators` (Zod), `events` (domain event types), `config` (env/constants)
- [ ] **Setup CI/CD**: lint, typecheck, test, build, deploy preview (Vercel + Railway/Render)
- [ ] **Implementasi RLS PostgreSQL** untuk semua tabel tenant sejak migration pertama
- [ ] **Buat design system components** (`packages/ui`) berdasarkan token §7.3: `Button`, `Input`, `Card`, `Badge`, `Table`, `Modal`, `Drawer`, `StempelDigital`, `HeroBlock`, `StatistikBlock`, `LayananUnggulanBlock`, dll
- [ ] **Implementasi CSS variable injection** di root layout dari `tenant_theme_config`
- [ ] **Buat Zod schema per `tipe_blok`** untuk `site_content_blocks.konten` validation
- [ ] **Setup i18n** dengan `next-intl` + loader dari `i18n_strings` DB
- [ ] **Implementasi auth** (NextAuth v5): credentials (NIK+password) + OTP WhatsApp, role-based redirect
- [ ] **Implementasi WA Bot** (Fonnte webhook) dengan tiering `info_instan`/`transaksi` & session management
- [ ] **Implementasi F0 Registrasi Penduduk**: CRUD `penduduk`, import Dukcapil CSV/Excel dengan validasi NIK checksum, API internal autofill by NIK/HP, event publisher 4 event type, worker consumer sync ke `wajib_pajak`/`balita`/`dashboard_agregat`, RBAC per role, audit log `penduduk_log`

---

## PENUTUP

Dokumen ini adalah **konsolidasi lengkap dan final** dari 5 dokumen sumber Seruni - Sistem Repository Unifikasi Informasi. Setiap spesifikasi di sini **wajib dipatuhi** sebagai pedoman pengembangan website Kantor Desa Virtual (Seruni - Sistem Repository Unifikasi Informasi) dalam arsitektur monorepo.

**Prinsip utama yang tidak boleh dilanggar:**

1. **Zero Hardcode** — Semua konten, tema, navigasi, struktur dari DB/config
2. **Event-Driven** — Fakta mentah → `domain_events` → Worker → Fakta turunan (IDM, dashboard, draft usulan)
3. **Append-Only Histori** — Tidak pernah overwrite status kritikal, selalu log baru
4. **Privasi Berlapis** — Data sensitif dibatasi per peran, publik hanya agregat
5. **Kanal Setara** — Web & WA berbagi state machine & data yang sama
6. **Human-in-the-Loop** — Draft otomatis selalu butuh verifikasi manusia
7. **Mobile-First Multi-Page** — Next.js App Router, RSC streaming, 360px+ baseline

**Bloker utama saat ini:** `PETA_DERIVATION_RULES_IDM.md` dan `idm_indicators.csv` untuk F3. Semua modul lain (F0, F1, F2, F4, F5, F6, F7, F8, F9, F10) **siap diimplementasikan penuh** dengan spesifikasi yang sudah lengkap di dokumen ini.

---

_Dokumen ini bersifat living document — update saat dokumen blocker (§13) tersedia atau keputusan arsitektur berubah. Versi paling baru selalu mengacu ke `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md` sebagai sumber kebenaran tunggal._
