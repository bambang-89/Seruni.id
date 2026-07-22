# Sistem IDM Desa

Dokumentasi sistem **IDM (Indeks Desa Membangun)** Seruni - Sistem Repository Unifikasi Informasi — merujuk OpenSID (`idm_indicators`, `tweb_`-derived) dan portal resmi **IDM Desa** (https://id.kemendesa.go.id/). Skor dihitung otomatis dari operasional harian (Event Propagation Layer), bukan kuesioner tahunan manual. **Sistem ini adalah kesimpulan akhir (Indeks Desa) yang menyerap event dari SELURUH modul** melalui `domain_events` → worker → `idm_skor_cache` → `idm_status_desa`.

---

## 1. Ringkasan Sistem IDM Desa (On Point)

- **Peran:** `idm_status_desa` + `idm_skor_cache` = _Single Source of Truth_ skor desa. Dibaca Portal Publik (badge status) & Dashboard Kades.
- **6 Dimensi IDM** (sesuai Permendes 21/2020 & 7/2023, portal id.kemendesa.go.id):
  1. **Sosial** — pendidikan, kesehatan, ketimpangan, sosial budaya.
  2. **Ekonomi** — PADes, keragaman usaha, akses pasar (indikator 22).
  3. **Lingkungan** — LP2B, sanitasi, air bersih, mitigasi bencana.
  4. **Infrastruktur & Pelayanan Dasar** — jalan, kesehatan (indikator 7.b Posyandu), pendidikan.
  5. **Tata Kelola Pemerintahan Desa** — musdes (46), PADes (47.a), transparansi, partisipasi.
  6. **Teknologi & Inovasi** — pemanfaatan teknologi pelayanan (45.b), inovasi desa.
- **Status Klasifikasi:** `sangat_tertinggal` < `tertinggal` < `berkembang` < `maju` < `mandiri` (diturunkan dari `total_skor`).
- **Info Grafis:** Dashboard materialized view di atas `idm_status_desa` + `dashboard_agregat` (key-value generik, granuler per `wilayah_id` = desa penuh / dusun / RT-RW) — tanpa angka hardcode.
- **Rekomendasi Arah Pembangunan:** Skor rendah per indikator → worker auto-`INSERT usulan_kegiatan_draft_otomatis` (kode rekening dari `idm_indicators.kode_rekening`, Permendes 7/2023) dengan status `menunggu_review` (wajib verifikasi manusia, tidak auto-approve).
- **Zero Hardcode:** Label dimensi/indikator, teks Info Grafis, navigasi dashboard dari `site_content_blocks`, `i18n_strings`, `feature_flags` — ganti tanpa redeploy.
- **Klasifikasi `sumber_data` indikator:**
  - `operasional` → real-time via worker (benar-benar dihitung dari `domain_events`).
  - `periodik_manual` → admin input berkala via `/admin/pengaturan/idm`; dashboard wajib tampilkan **tanggal update terakhir** (bukan "real-time").
  - `eksternal` → impor BPS/Kemendes SDGs; bukan event internal.

> **Blocker (⚠️):** Formula per-indikator menunggu `PETA_DERIVATION_RULES_IDM.md` & `idm_indicators.csv` (dari `KUESIONER_ID_2026_Lock.xlsx` sheet `RUMUSAN`). Tabel & worker skeleton sudah siap; jumlah pasti indikator **wajib diverifikasi manual** (jangan asumsikan "127").

---

## 2. Workflow Lengkap Sistem IDM Desa Komplit

```
[A] FAKTA MENTAH (input manusia / eksternal) — SELURUH MODUL
    penduduk · keluarga · surat_pengajuan · usulan_kegiatan · usulan_votes
    pbb_tagihan · apbdes_realisasi · balita · posyandu_kunjungan
    bidang_tanah · sektor_ekonomi · pariwisata · objek_pajak
    pembangunan · stunting_anak · kpm/bansos_penerima · bpjs_peserta
    analisis_respon · dpt/pemilihan · pengaduan_desa · bencana_alert
    profil_desa/desa_pamong (perangkat) · artikel_desa (konten)
        │  tiap perubahan → INSERT domain_events (processed_at = NULL)
        ▼
[B] EVENT PROPAGATION LAYER (BullMQ Worker, idempotent ON CONFLICT)
    domain_events ──► idm-processor (per dimensi; MVP = 1 queue + priority)
        │
        ├─► Jalankan derivation rule (PETA_DERIVATION_RULES_IDM.md — pending)
        ├─► Hitung nilai_agregat indikator (APM, cakupan imunisasi, PADes, stunting, partisipasi, dll)
        ├─► Bandingkan threshold idm_scoring_thresholds (skor 1–5)
        ├─► UPSERT idm_skor_cache (tenant_id, indikator_kode, skor, dihitung_pada)
        ├─► Jika skor < ambang ─► INSERT usulan_kegiatan_draft_otomatis
        │       (kode_rekening_saran ← idm_indicators.kode_rekening,
        │        status = menunggu_review → W2 verifikasi manusia → RKPDes)
        └─► Refresh idm_status_desa (total skor 6 dimensi → status desa)
        ▼
[C] DASHBOARD / INFO GRAFIS (materialized view, BUKAN input manual)
    idm_status_desa + dashboard_agregat ──► Portal Publik + Dashboard Kades
        ├─ Kartu ringkasan desa (wilayah_id = NULL)
        ├─ Breakdown per dusun/RT/RW (wilayah_id terisi)
        ├─ Tren waktu (periode bulanan/tahunan)
        └─ Rekomendasi arah pembangunan (dari indikator skor rendah)
```

**Pemetaan event → indikator (lengkap, seluruh modul):**

| Event                        | Dimensi           | Indikator                            | Efek Worker                                                  |
| ---------------------------- | ----------------- | ------------------------------------ | ------------------------------------------------------------ |
| `surat.diterbitkan`          | 6 (Teknologi)     | 45.b Pemanfaatan Teknologi Pelayanan | % surat digital vs manual dihitung ulang                     |
| `musdes.usulan.ditetapkan`   | 5 (Tata Kelola)   | 46 Musyawarah Desa                   | Frekuensi & partisipasi musdes                               |
| `pbb.tagihan.dibayar`        | 5 / 2             | 47.a PADes · 22 Ekonomi              | INSERT `pades_pendapatan`; rekal skor 47.a & 22 (jika usaha) |
| `posyandu.kunjungan.dicatat` | 4 (Infrastruktur) | 7.b Aktivitas Posyandu               | Skor posyandu + dashboard kesehatan                          |
| `penduduk.status.berubah`    | semua             | —                                    | Denominator rasio populasi (paling kritis)                   |
| `apbdes.realisasi.dicatat`   | 5                 | Tata Kelola Keuangan                 | Jika `jenis_belanja='modal'` → draft `aset_desa`             |
| `ekonomi.sektor.dicatat`     | 2                 | Ekonomi                              | Skor keragaman sektor → `dashboard_agregat`                  |
| `pariwisata.diterbitkan`     | 2                 | Ekonomi                              | Skor pariwisata → `dashboard_agregat` + `peta_objek`         |
| `pembangunan.selesai`        | 1 (Infrastruktur) | Infrastruktur                        | Skor D1 + `aset_desa` + `dashboard_agregat`                  |
| `stunting.dievaluasi`        | 1 (Kesehatan)     | Status gizi balita                   | Skor kesehatan + `dashboard_agregat` (stunting)              |
| `bansos.penerima.dicatat`    | 1 (Sosial)        | Kesejahteraan/ketimpangan            | Skor D1 Sosial + `dashboard_agregat` (sosial)                |
| `penduduk.bpjs.berubah`      | 1 (Kesehatan)     | Cakupan BPJS                         | Skor kesehatan + 1-KPM View                                  |
| `analisis.selesai`           | terkait           | Indikator analitik                   | Skor indikator terkait + `dashboard_agregat` (analisis)      |
| `pemilihan.selesai`          | 5 (Partisipasi)   | Partisipasi masyarakat               | Skor partisipasi + `dashboard_agregat` (pemilu)              |
| `pengaduan.dibuat`           | 5 (Tata Kelola)   | Pelayanan publik                     | Skor tata kelola + `dashboard_agregat` (aduan)               |
| `bencana.alert`              | 3 (Lingkungan)    | Mitigasi bencana                     | Skor D3 + `dashboard_agregat` (bencana)                      |
| `wilayah.berubah`            | —                 | —                                    | Granularitas agregat dusun/RT/RW                             |
| `perangkat.berubah`          | 5 (Pemerintahan)  | Kelembagaan                          | Daftar TTE & skor pemerintahan                               |
| `penduduk.eksternal.berubah` | semua             | —                                    | Pull Kemendagri → Core Registry update                       |

> Peta lengkap event lintas sistem juga ada di `SKEMA_DATABASE_ERD.md` §C7.1.

**Aturan Kritikal:**

- Tabel turunan (`idm_skor_cache`, `idm_status_desa`, `dashboard_agregat`, `pades_pendapatan`) **HANYA ditulis worker**, tidak pernah diedit admin langsung.
- Indikator `periodik_manual`/`eksternal` di-update via `/admin/pengaturan/idm`, bukan worker — dashboard tampilkan tanggal update terakhir.
- Draft usulan otomatis **wajib verifikasi manusia** (W2) sebelum masuk RKPDes — sistem tidak eksekusi anggaran tanpa persetujuan.
- Sizing worker bertahap: MVP 1 queue + priority per dimensi; split 6 queue hanya jika lag terukur.
- Migrasi urut (§C11): `idm_indicators` (seed) → `idm_scoring_thresholds` → `idm_skor_cache` → `idm_status_desa` → `dashboard_agregat` → `pades_pendapatan`.

---

## 3. Tabel Jenis IDM Desa

### 3.1 Tabel Induk

| Tabel                            | Fungsi                                                        | Kolom Kunci                                                                                                                                                                                                                                                                  | Relasi                                                      |
| -------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `idm_indicators`                 | Seed kuesioner (sama semua tenant, dari `idm_indicators.csv`) | `id`, `dimensi_no`, `dimensi_nama`, `subdim_kode`, `indikator_no`, `indikator_nama`, `indikator_skor_max`, `sub_kode`, `sub_pertanyaan`, `sub_skor_max`, `rekomendasi_intervensi`, `kode_rekening`, `pelaksana`, `sumber_data` (`operasional`/`periodik_manual`/`eksternal`) | seed-only                                                   |
| `idm_scoring_thresholds`         | Ambang nilai per skor 1–5                                     | `id`, `indikator_id`→`idm_indicators.id`, `skor_level` (1–5), `deskripsi_kondisi`, `nilai_ambang_bawah`, `nilai_ambang_atas`                                                                                                                                                 | `indikator_id`→`idm_indicators.id`                          |
| `idm_skor_cache`                 | Skor per indikator (HANYA worker)                             | `id`, `tenant_id`→`tenants.id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`, UNIQUE(`tenant_id`,`indikator_kode`)                                                                                                                                             | `tenant_id`→`tenants.id`                                    |
| `idm_status_desa`                | Klasifikasi akhir desa (dibaca Portal)                        | `tenant_id` (PK)→`tenants.id`, `total_skor`, `status` (`mandiri`/`maju`/`berkembang`/`tertinggal`/`sangat_tertinggal`), `updated_at`                                                                                                                                         | `tenant_id`→`tenants.id`                                    |
| `dashboard_agregat`              | Fakta turunan generik KV (Info Grafis)                        | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id` (NULL=desa penuh), `kategori`, `metrik_key`, `metrik_value`, `periode`, UNIQUE(`tenant_id`,`wilayah_id`,`kategori`,`metrik_key`,`periode`)                                                                                | `tenant_id`→`tenants.id`, `wilayah_id`→`wilayah_batas.id`   |
| `pades_pendapatan`               | PADes otomatis dari PBB (Dimensi 5)                           | `id`, `tenant_id`, `tahun`, `sumber` (`pbb`), `nilai`, `pbb_tagihan_id`                                                                                                                                                                                                      | `tenant_id`→`tenants.id`, `pbb_tagihan_id`→`pbb_tagihan.id` |
| `usulan_kegiatan_draft_otomatis` | Draft usulan dari skor rendah                                 | `id`, `tenant_id`, `kategori`, `sumber_pemicu`, `sumber_ref_id`, `kode_rekening_saran`→`idm_indicators`, `status` (`menunggu_review`/`diadopsi`/`diabaikan`)                                                                                                                 | `tenant_id`→`tenants.id`                                    |

### 3.2 Tabel Pendukung

| Tabel                 | Fungsi                                  | Kolom Kunci                                                                                                             | Relasi                   |
| --------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `domain_events`       | Log event (pemicu worker)               | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                           | `tenant_id`→`tenants.id` |
| `wilayah_batas`       | Granularitas agregat (desa/dusun/RT/RW) | `id`, `parent_id` (self), `jenis`, `nama`, `geom`                                                                       | self-ref `parent_id`     |
| `site_content_blocks` | Konten Info Grafis (zero hardcode)      | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`berita`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status` | `tenant_id`→`tenants.id` |
| `feature_flags`       | Toggle modul IDM/dimensi                | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                | `tenant_id`→`tenants.id` |
| `i18n_strings`        | Label dimensi/indikator/status          | `id`, `tenant_id`, `locale`, `key`, `value`                                                                             | `tenant_id`→`tenants.id` |
| `site_settings`       | Pengaturan tampilan portal              | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`               | `tenant_id`→`tenants.id` |
| `tenant_theme_config` | Tema dashboard IDM                      | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                       | `tenant_id`→`tenants.id` |
| `idm_log`             | Audit rekalkulasi (append-only)         | `id`, `tenant_id`, `indikator_kode`, `skor_lama`, `skor_baru`, `waktu`, `aktor_id`                                      | `tenant_id`→`tenants.id` |

### 3.3 Diagram Integrasi

```
                          ┌─────────────────────────────┐
    FAKTA MENTAH ────────►│       domain_events         │ (append-only)
    (SELURUH MODUL)       │  (processed_at = NULL)      │
                          └──────────────┬──────────────┘
                                         │ BullMQ worker (idempoten)
                                         ▼
                          ┌─────────────────────────────┐
    idm_indicators ──────►│   idm_scoring_thresholds    │ (seed CSV)
    (seed kuesioner)      │        (skor 1–5)           │
                          └──────────────┬──────────────┘
                                         │ UPSERT
                                         ▼
                          ┌─────────────────────────────┐
                          │      idm_skor_cache         │ (per indikator)
                          │  (tenant_id, indikator_kode)│
                          └──────────────┬──────────────┘
                                 ┌───────┴────────┐
                                 ▼                ▼
                     ┌──────────────────┐  ┌──────────────────────┐
                     │  idm_status_desa │  │  dashboard_agregat   │ (Info Grafis)
                     │ (status desa)    │  │  (KV per wilayah_id) │
                     └────────┬─────────┘  └──────────┬───────────┘
                              │                        │
                              ▼                        ▼
                     Portal Publik (badge)     Dashboard Kades + Rekomendasi
                              │                        │
                              │   skor < ambang        ▼
                              └──────────► usulan_kegiatan_draft_otomatis
                                            (kode_rekening_saran → W2 → RKPDes)
```

**Keterangan integrasi:** `domain_events` menyalurkan semua fakta mentah dari **seluruh modul** (Penduduk, Keluarga, Surat, Usulan/Voting, PBB, Keuangan, Posyandu, Pertanahan, Potensi, Pembangunan, Stunting, Sosial/Bansos/BPJS, Analisis, Pemilu, Service Center, Bencana, Profile/Perangkat, Informasi) ke worker IDM; `idm_indicators`+`idm_scoring_thresholds` menentukan skor; `idm_skor_cache`→`idm_status_desa`+`dashboard_agregat` menjadi Info Grafis tanpa angka hardcode; skor rendah memicu `usulan_kegiatan_draft_otomatis` yang mengalir ke Sistem Keuangan (RKPDes/APBDes). Seluruh tampilan dibentuk `site_*`+`i18n_strings` (zero hardcode). **Satu data masuk di modul mana pun → seluruh rantai di atas berjalan otomatis → kesimpulan Indeks Desa (IDM) ter-update.**
