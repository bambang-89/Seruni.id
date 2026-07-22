# SKEMA DATABASE & ERD — Kantor Desa Virtual (DESAKU)
PostgreSQL + Drizzle ORM · Referensi presisi untuk Claude Code

---

## 1. Konvensi Umum

- Semua tabel domain (kecuali tabel referensi global) memiliki `tenant_id UUID NOT NULL` untuk isolasi multi-tenant.
- Primary key: `UUID DEFAULT gen_random_uuid()` di semua tabel.
- Tabel fakta mentah vs fakta turunan dipisah tegas (lihat §7) — hanya fakta turunan yang boleh ditulis oleh worker.
- Semua tabel transaksional kritikal (surat, tagihan, kepemilikan, voting) bersifat **append-only untuk histori** — perubahan status dicatat sebagai baris/log baru, bukan overwrite.

---

## 2. ERD — Core Registry & Kependudukan

```
┌─────────────────┐        ┌──────────────────┐
│     tenants      │        │     penduduk      │
├─────────────────┤   1   N├──────────────────┤
│ id (PK)          ├───────┤ id (PK)            │
│ nama_desa        │        │ tenant_id (FK)     │
│ subdomain        │        │ nik (UQ per tenant)│
│ kode_desa        │        │ nama               │
└─────────────────┘        │ tanggal_lahir       │
                            │ status_kependudukan │
                            │ nomor_hp            │
                            │ bpjs_status         │
                            │ dusun, rt, rw       │
                            └────────┬─────────┘
                                     │ 1
                     ┌───────────────┼───────────────┬─────────────┐
                     │ N             │ N              │ N           │ N
              ┌──────▼─────┐  ┌──────▼──────┐  ┌──────▼─────┐ ┌────▼─────┐
              │   surat_    │  │  usulan_    │  │   pbb_     │ │  wa_chat_│
              │ pengajuan   │  │  votes      │  │ wajib_pajak│ │  session │
              │ (by NIK)    │  │ (by NIK)    │  │ (by NIK,   │ │(by nomor │
              └─────────────┘  └─────────────┘  │  opsional) │ │   hp)    │
                                                  └────────────┘ └──────────┘
```

---

## 3. ERD — Modul Surat (F1 & F6)

```
┌──────────────────┐        ┌───────────────────┐        ┌────────────────────┐
│   surat_jenis     │   1   N│  surat_pengajuan   │   1   1│   surat_dokumen     │
├──────────────────┤────────├───────────────────┤────────├────────────────────┤
│ id (PK)           │        │ id (PK)            │        │ id (PK)             │
│ nama_jenis        │        │ tenant_id (FK)     │        │ surat_pengajuan_id  │
│ template_field[]  │        │ jenis_surat_id (FK)│        │ file_path           │
│ format_nomor_arsip│        │ penduduk_id (FK)   │        │ document_hash       │
└──────────────────┘        │ status             │        │ qr_uuid             │
                             │ sumber_kanal        │        │ ttd_oleh (FK→penduduk│
                             │ (web/whatsapp)      │        │            /pejabat)│
                             │ nomor_surat          │        │ tanggal_ttd         │
                             │ data_form (JSONB)    │        └────────────────────┘
                             └─────────┬───────────┘
                                       │ 1
                                       │ N
                             ┌─────────▼───────────┐
                             │  surat_log_status     │
                             ├──────────────────────┤
                             │ id (PK)               │
                             │ surat_pengajuan_id(FK)│
                             │ status_dari, status_ke│
                             │ aktor_id, catatan      │
                             │ created_at             │
                             └──────────────────────┘

┌──────────────────────┐
│   wa_chat_session      │
├──────────────────────┤
│ id (PK)                │
│ tenant_id (FK)          │
│ nomor_hp                │
│ current_state           │  (MENU_UTAMA/MENGISI_FORM/KONFIRMASI)
│ context_data (JSONB)     │
│ surat_pengajuan_id (FK, nullable)
│ last_activity_at         │
│ expires_at               │
└──────────────────────┘
```

**Tabel:**
```sql
CREATE TABLE surat_jenis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nama_jenis VARCHAR(150) NOT NULL,
  template_field JSONB NOT NULL,        -- daftar field non-identitas yang perlu diisi
  format_nomor_arsip VARCHAR(50) NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT true
);

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

CREATE TABLE surat_dokumen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL UNIQUE REFERENCES surat_pengajuan(id),
  file_path TEXT NOT NULL,
  document_hash VARCHAR(128) NOT NULL,
  qr_uuid UUID NOT NULL DEFAULT gen_random_uuid(),
  ttd_oleh_penduduk_id UUID REFERENCES penduduk(id),  -- Kades/Sekdes
  tanggal_ttd TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE surat_log_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  surat_pengajuan_id UUID NOT NULL REFERENCES surat_pengajuan(id),
  status_dari VARCHAR(20), status_ke VARCHAR(20) NOT NULL,
  aktor_id UUID, catatan TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE wa_chat_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nomor_hp VARCHAR(20) NOT NULL,
  current_state VARCHAR(30) NOT NULL DEFAULT 'menu_utama',
  tier VARCHAR(15) NOT NULL DEFAULT 'transaksi'
    CHECK (tier IN ('info_instan','transaksi')),  -- info_instan: read-only, tanpa OTP, tanpa antrean admin
  context_data JSONB NOT NULL DEFAULT '{}',
  surat_pengajuan_id UUID REFERENCES surat_pengajuan(id),
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(tenant_id, nomor_hp)
);
```

---

## 4. ERD — Modul Usulan Kegiatan & Voting (F2)

```
┌───────────────────────┐        ┌──────────────────┐
│   usulan_kegiatan       │   1  N│  usulan_votes      │
├───────────────────────┤────────├──────────────────┤
│ id (PK)                  │      │ id (PK)             │
│ tenant_id (FK)            │     │ usulan_id (FK)       │
│ pengusul_penduduk_id (FK) │     │ nik                  │
│ judul, deskripsi           │    │ voted_at             │
│ kategori_bidang             │   │ UNIQUE(usulan_id,nik)│
│ kategori_sub_bidang          │  └──────────────────┘
│ lokasi, estimasi_manfaat      │
│ status ('diajukan'/            │
│  'lolos_verifikasi'/'ditolak'/ │
│  'ditetapkan_rkpdes')           │
│ kode_rekening_saran (nullable,  │  ← diisi otomatis jika berasal
│   FK-like ke idm_indicators)     │    dari usulan_kegiatan_draft_otomatis
│ sumber ('warga'/'draft_otomatis')│
│ created_at                        │
└───────────────────────┘

┌──────────────────────────────────┐
│  usulan_kegiatan_draft_otomatis     │   ← ditulis HANYA oleh worker propagasi
├──────────────────────────────────┤
│ id (PK)                            │
│ tenant_id (FK)                      │
│ kategori                             │
│ sumber_pemicu (event_type)            │
│ sumber_ref_id                          │
│ kode_rekening_saran                     │
│ status ('menunggu_review'/'diadopsi'/    │
│         'diabaikan')                      │
│ created_at                                 │
└──────────────────────────────────┘
```

```sql
CREATE TABLE usulan_kegiatan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  pengusul_penduduk_id UUID REFERENCES penduduk(id),  -- nullable jika sumber=draft_otomatis
  judul VARCHAR(200) NOT NULL,
  deskripsi TEXT NOT NULL,
  kategori_bidang VARCHAR(100) NOT NULL,     -- sesuai Permendagri 20/2018
  kategori_sub_bidang VARCHAR(100) NOT NULL,
  lokasi TEXT,
  estimasi_manfaat TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'diajukan'
    CHECK (status IN ('diajukan','ditolak','lolos_verifikasi','ditetapkan_rkpdes')),
  kode_rekening_saran VARCHAR(30),
  sumber VARCHAR(20) NOT NULL DEFAULT 'warga' CHECK (sumber IN ('warga','draft_otomatis')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE usulan_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usulan_id UUID NOT NULL REFERENCES usulan_kegiatan(id),
  nik VARCHAR(16) NOT NULL,
  voted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(usulan_id, nik)   -- kunci anti-spam: 1 NIK, 1x per usulan (bukan per sesi)
);

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

---

## 5. ERD — Modul PBB (F5)

*(detail relasi & alasan desain sudah dibahas di `pbb.schema.ts` — ringkasan ERD berikut untuk referensi cepat)*

```
┌────────────────┐          ┌─────────────────────┐          ┌────────────────┐
│  wajib_pajak     │  N    N │  kepemilikan_objek     │  N    1  │  objek_pajak     │
├────────────────┤──────────├─────────────────────┤──────────├────────────────┤
│ id (PK)           │        │ id (PK)                │        │ id (PK)          │
│ tenant_id          │        │ wajib_pajak_id (FK)     │        │ tenant_id         │
│ penduduk_id (FK,    │       │ objek_pajak_id (FK)      │       │ nop               │
│   nullable)           │     │ persentase_kepemilikan    │      │ status             │
│ nik, nama               │   │ tanggal_mulai               │    │ jenis_usaha         │
│ alamat_domisili           │ │ tanggal_selesai (null=aktif)  │  │ nilai_njop_total     │
│ is_luar_desa                │└─────────────────────┘        └────────┬─────────┘
└────────────────┘                                                     │ 1
                                                            ┌───────────┼───────────┐
                                                            │ N                    N │
                                                  ┌─────────▼─────────┐   ┌─────────▼──────────┐
                                                  │ objek_pajak_lokasi   │   │ objek_pajak_penghuni │
                                                  ├─────────────────┤   ├────────────────────┤
                                                  │ id (PK)              │   │ id (PK)                │
                                                  │ objek_pajak_id (FK)   │   │ objek_pajak_id (FK)     │
                                                  │ jenis_lokasi (tanah/   │  │ nama_penghuni            │
                                                  │  bangunan)               │ │ jenis_penghuni            │
                                                  │ latitude, longitude        │ (penyewa/pesuruh/dll)      │
                                                  │ luas_m2, kelas_njop           │ tanggal_mulai/selesai       │
                                                  └─────────────────┘   └────────────────────┘
                                                            │ 1
                                                            │ N
                                                  ┌─────────▼─────────┐
                                                  │   pbb_tagihan        │
                                                  ├─────────────────┤
                                                  │ id (PK)               │
                                                  │ objek_pajak_id (FK)    │
                                                  │ tahun_pajak              │
                                                  │ jumlah_pokok, denda        │
                                                  │ status_bayar                 │
                                                  │ snapshot_wajib_pajak_utama(FK)│
                                                  └─────────────────┘
```

DDL lengkap: lihat `pbb.schema.ts` (Drizzle ORM) — sudah final, mencakup semua constraint (`UNIQUE`, `CHECK persentase 0-100`, index koordinat untuk query GIS).

---

## 6. ERD — Modul IDM / Event Propagation Layer

```
┌───────────────────┐        ┌───────────────────────┐
│   domain_events      │        │  idm_indicators          │  ← seed dari idm_indicators.csv
├───────────────────┤        ├───────────────────────┤
│ id (PK)               │      │ id (PK)                    │
│ tenant_id               │    │ dimensi_no, dimensi_nama     │
│ event_type                │  │ subdim_kode, indikator_no      │
│ entity_id                    │ │ sub_kode, sub_pertanyaan          │
│ payload (JSONB)                │ │ skor_max                             │
│ created_at, processed_at          │ └───────────────────────┘
└───────────────────┘                        │ 1
        │ dikonsumsi oleh worker              │ N
        ▼                             ┌───────▼──────────────┐
┌───────────────────────┐             │ idm_scoring_thresholds │
│    idm_skor_cache        │◄─────────┤ (ambang nilai per skor)│
├───────────────────────┤   ditulis   └───────────────────────┘
│ id (PK)                  │   worker
│ tenant_id                  │
│ indikator_kode                │
│ skor, nilai_agregat               │
│ dihitung_pada                        │
│ UNIQUE(tenant_id, indikator_kode)       │
└───────────────────────┘
        │ agregat
        ▼
┌───────────────────────┐
│   idm_status_desa         │  ← klasifikasi akhir, dibaca Portal Publik
├───────────────────────┤
│ tenant_id (PK)             │
│ total_skor                    │
│ status ('mandiri'/'maju'/       │
│  'berkembang'/'tertinggal'/       │
│  'sangat_tertinggal')                │
│ updated_at                              │
└───────────────────────┘
```

```sql
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

CREATE TABLE idm_indicators (        -- seed dari idm_indicators.csv, sama untuk semua tenant
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dimensi_no INT NOT NULL, dimensi_nama VARCHAR(100) NOT NULL,
  subdim_kode VARCHAR(20), subdim_nama VARCHAR(150),
  indikator_no INT NOT NULL, indikator_nama VARCHAR(200) NOT NULL,
  indikator_skor_max INT,
  sub_kode VARCHAR(10), sub_pertanyaan TEXT, sub_skor_max INT,
  rekomendasi_intervensi TEXT, kode_rekening VARCHAR(30), pelaksana TEXT,
  sumber_data VARCHAR(20) NOT NULL DEFAULT 'operasional'
    CHECK (sumber_data IN ('operasional','periodik_manual','eksternal'))
    -- operasional: dihitung dari domain_events (benar-benar real-time)
    -- periodik_manual: diinput admin berkala, dashboard wajib tampilkan tanggal update terakhir
    -- eksternal: impor berkala dari BPS/Kemendes SDGs, bukan event internal
);

CREATE TABLE idm_scoring_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  indikator_id UUID NOT NULL REFERENCES idm_indicators(id),
  skor_level INT NOT NULL CHECK (skor_level BETWEEN 1 AND 5),
  deskripsi_kondisi TEXT NOT NULL,      -- dari kolom contoh_deskripsi_skor_maks
  nilai_ambang_bawah NUMERIC, nilai_ambang_atas NUMERIC   -- untuk indikator berbasis rasio
);

CREATE TABLE idm_skor_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  indikator_kode VARCHAR(30) NOT NULL,
  skor NUMERIC, nilai_agregat NUMERIC,
  dihitung_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(tenant_id, indikator_kode)
);

CREATE TABLE idm_status_desa (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
  total_skor NUMERIC NOT NULL,
  status VARCHAR(30) NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 6b. ERD — Kepatuhan Pelaporan & Akses Data Sensitif (tambahan sintesis)

```sql
CREATE TABLE ekspor_kepatuhan (       -- jalur konkret non-tujuan §1.3 PRD (SISKEUDES/SIPADES)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  jenis_ekspor VARCHAR(30) NOT NULL CHECK (jenis_ekspor IN ('siskeudes','sipades')),
  periode VARCHAR(20) NOT NULL,          -- mis. '2026-Q3'
  file_path TEXT NOT NULL,               -- format resmi CSV/XML sesuai spesifikasi Kemendagri
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','diverifikasi_admin','diunduh')),
  dihasilkan_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Sumber data: apbdes_realisasi/pades_pendapatan (siskeudes), pbb_objek_pajak/objek_pajak_lokasi (sipades)
-- Satu arah: hasilkan file siap-unggah, bukan integrasi API langsung

CREATE TABLE posyandu_akses_log (     -- RBAC & audit akses data individu balita (perluasan F4/W4)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  kunjungan_id UUID NOT NULL REFERENCES posyandu_kunjungan(id),
  diakses_oleh UUID NOT NULL,
  peran_pengakses VARCHAR(20) NOT NULL CHECK (peran_pengakses IN ('kader','admin_kesehatan','kades')),
  diakses_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Akses data individu dibatasi: kader (dusun terkait saja), admin_kesehatan; Kades hanya lihat agregat
-- kecuali eskalasi kasus gizi buruk yang sudah memicu usulan_kegiatan_draft_otomatis
```

---

## 7. Aturan Pemisahan Fakta Mentah vs Fakta Turunan

| Kategori | Tabel | Ditulis oleh |
|---|---|---|
| **Fakta mentah** | `penduduk`, `surat_pengajuan`, `usulan_kegiatan` (sumber=warga), `usulan_votes`, `pbb_*` (kecuali cache), `posyandu_kunjungan`, `apbdes_realisasi` | Manusia (form web/WA) atau integrasi eksternal |
| **Fakta turunan** | `idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `usulan_kegiatan_draft_otomatis`, `pades_pendapatan` (entri dari PBB) | **Hanya** worker propagasi (BullMQ) |

**Aturan tegas:** tidak ada endpoint API yang mengizinkan admin meng-edit langsung tabel fakta turunan. Koreksi selalu dilakukan di fakta mentah, sistem menghitung ulang otomatis.

---

## 8. Referensi Dokumen Terkait
- `PRD_KANTOR_DESA_VIRTUAL.md` — kebutuhan produk & kriteria penerimaan
- `WORKFLOW_KANTOR_DESA_VIRTUAL.md` — alur proses & state machine tiap fitur
- `PETA_DERIVATION_RULES_IDM.md` — pemetaan event ke efek turunan per dimensi IDM
- `idm_indicators.csv` — data seed 127 indikator IDM
- `pbb.schema.ts`, `pbb-derivation.worker.ts` — implementasi referensi domain PBB
- `ARSITEKTUR_SISTEM_TERINTEGRASI.md` — rasional tambahan §6b (`wa_layanan_tier`, `sumber_data`, `ekspor_kepatuhan`, `posyandu_akses_log`)
