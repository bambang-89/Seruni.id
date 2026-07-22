# Sistem Bencana Desa

Sistem Bencana Desa mengelola **pemetaan titik rawan & prediksi bencana realtime** sebagai _Single Source of Truth_ mitigasi desa. Merujuk OpenSID (`tweb_kejadian`) & sumber eksternal **BMKG** (serta sistem kebencanaan lainnya), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **parameter kredibel → skor risiko → peringatan dini otomatis**, berjalan realtime.

## 1. Ringkasan Sistem Bencana (On Point)

- **Peran:** `bencana_kategori` + `bencana_titik` + `bencana_prakiraan` + `bencana_kejadian` + `bencana_alert` = _Single Source of Truth_ pemetaan & prediksi bencana.
- **Kanal:** Ingest **BMKG API** (eksternal, polling berkala) → `bencana_prakiraan`; Web admin (Tim Siaga) catat `bencana_kejadian`; Portal & WhatsApp (Fonnte) untuk peringatan dini warga.
- **Pemetaan:** `bencana_titik` memetakan titik rawan per `wilayah_batas` (geom) + `bencana_kategori` dengan `tingkat_risiko` (rendah/sedang/tinggi) → overlay peta bahaya.
- **Prediksi Realtime:** `bencana_prakiraan` mengkalkulasi **parameter kredibel** (`debit_air`, `intensitas_hujan`, `kecepatan_angin`, dll) → `skor_risiko` (0–100) → `status` (`aman`/`waspada`/`siaga`/`awas`). Contoh: **banjir = f(debit_air, intensitas_hujan, kecepatan_angin)**.
- **Peringatan Dini:** `bencana_alert` otomatis saat status naik ke `siaga`/`awas` → notifikasi WA (Fonnte) + Portal + (opsional) sirene; target warga & **Tim Siaga Bencana / Ambulance** (`call_center_desa`).
- **Integrasi:** `bencana.kejadian` → eskalasi `service_center` (Kedaruratan), `Posyandu` (korban), `Sosial` (bansos darurat), `IDM`, `Informasi`, `Surat`, `Administrasi_Umum`.
- **Zero Hardcode:** Kategori, label status, parameter dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Bencana Komplit

```
[A] INGEST BMKG (eksternal, realtime)
    BMKG API (polling berkala) ──► bencana_prakiraan (kategori_id, parameter JSONB, skor_risiko, status, berlaku_hingga)
        │  kalkulasi: banjir = f(debit_air, intensitas_hujan, kecepatan_angin)
        ▼
[B] EVALUASI & PEMETAAN
    bencana_kategori (threshold) × bencana_prakiraan → status (aman/waspada/siaga/awas)
        │  bencana_titik (titik rawan per wilayah) → overlay peta bahaya
        ▼
[C] PERINGATAN DINI (jika status naik)
    bencana_alert (level, channel WA/portal/sirene, target) → notifikasi warga & Tim Siaga Bencana/Ambulance
        │  event bencana.prakiraan (siaga/awas)
        ▼
[D] KEJADIAN (fakta mentah, saat bencana terjadi)
    Tim Siaga / warga (via service_center Kedaruratan) → bencana_kejadian (kategori_id, titik_id, waktu, dampak, korban)
        │  → bencana_alert (level: awas) + notifikasi segera
        ▼
[E] EVENT PROPAGATION (worker)
    bencana.kejadian ──► rekalkulasi idm_skor_cache (ketahanan/bencana)
                    ├─► dashboard_agregat (risiko per dusun)
                    ├─► eskalasi: service_center (Kedaruratan), Posyandu (korban), Sosial (bansos darurat)
                    ▼
[F] LAYANAN TURUNAN
    Sistem Informasi (peta bahaya & pengumuman) · Surat keterangan bencana · Administrasi_Umum (register kejadian)
```

**Aturan Kritikal:**

- `bencana_prakiraan` adalah **fakta turunan** dari BMKG (eksternal) — di-poll berkala, bukan input manual.
- `bencana_titik.wilayah_id` → `wilayah_batas` (geom) — overlay peta bahaya per dusun/RT/RW.
- Status `siaga`/`awas` → **wajib** `bencana_alert` + notifikasi (otomatis via worker).
- `bencana_kejadian` terhubung ke `penduduk` (korban, NIK unik) & `bencana_titik` — tidak input ulang identitas.
- `bencana.kejadian` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                   | Sumber            | Dampak                                                                                     |
| ----------------------- | ----------------- | ------------------------------------------------------------------------------------------ |
| `bencana.prakiraan`     | BMKG poll         | Status siaga/awas → `bencana_alert`, notifikasi WA, `dashboard_agregat`                    |
| `bencana.kejadian`      | Tim Siaga / warga | Eskalasi `service_center` (Kedaruratan), `Posyandu`, `Sosial`, `IDM`, `Informasi`, `Surat` |
| `bencana.alert.dikirim` | Peringatan dini   | WA warga & Tim Siaga Bencana/Ambulance (`call_center_desa`)                                |
| `bencana.selesai`       | Penanganan        | Update status, laporan ke `Administrasi_Umum`                                              |

## 3. Tabel Jenis Bencana Desa (OpenSID + BMKG)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)      | Ekuivalen (OpenSID/Ref)   | Kolom inti                                                                                                                                                                                                                                                                                     | Referensi FK                                                                                        |
| ------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `bencana_kategori`  | Kategori Bencana          | `id`, `tenant_id`, `kode` (UQ), `nama` (BANJIR/LONGSOR/PUTING_BELIUNG/KEBAKARAN/GEMPA/DLL), `parameter_relevan` (JSONB: debit_air, intensitas_hujan, kecepatan_angin, dll), `ambang_batas` (JSONB), `aktif`                                                                                    | `tenant_id`→`tenants.id`                                                                            |
| `bencana_titik`     | Titik Rawan               | `id`, `tenant_id`, `kategori_id`→`bencana_kategori.id`, `wilayah_id`→`wilayah_batas.id`, `nama_lokasi`, `geom`, `tingkat_risiko` (`rendah`/`sedang`/`tinggi`), `keterangan`, `aktif`                                                                                                           | `kategori_id`→`bencana_kategori.id`; `wilayah_id`→`wilayah_batas.id`                                |
| `bencana_prakiraan` | Prakiraan Realtime (BMKG) | `id`, `tenant_id`, `kategori_id`→`bencana_kategori.id`, `titik_id`→`bencana_titik.id` (nullable), `sumber` (`bmkg`), `parameter` (JSONB: debit_air, intensitas_hujan, kecepatan_angin), `skor_risiko` (0–100), `status` (`aman`/`waspada`/`siaga`/`awas`), `waktu_prakiraan`, `berlaku_hingga` | `kategori_id`→`bencana_kategori.id`; `titik_id`→`bencana_titik.id`                                  |
| `bencana_kejadian`  | `tweb_kejadian` (OpenSID) | `id`, `tenant_id`, `kategori_id`→`bencana_kategori.id`, `titik_id`→`bencana_titik.id` (nullable), `wilayah_id`→`wilayah_batas.id`, `waktu_mulai`, `waktu_selesai` (nullable), `dampak`, `jumlah_korban`, `status` (`aktif`/`selesai`), `dicatat_oleh`                                          | `kategori_id`→`bencana_kategori.id`; `titik_id`→`bencana_titik.id`; `wilayah_id`→`wilayah_batas.id` |
| `bencana_alert`     | Peringatan Dini           | `id`, `tenant_id`, `ref_id` (prakiraan_id/kejadian_id), `level` (`waspada`/`siaga`/`awas`), `channel` (`wa`/`portal`/`sirene`), `target` (`warga`/`perangkat`/`tim_siaga`), `pesan`, `status_kirim` (`terkirim`/`gagal`), `waktu_kirim`                                                        | `tenant_id`→`tenants.id`                                                                            |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen             | Kolom inti                                                                                                                                                      | Referensi FK                                              |
| --------------------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `domain_events`       | Event Bus             | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                                   | `tenant_id`→`tenants.id`                                  |
| `penduduk`            | Core Registry         | `id`, `nik`, `nama`, `status_dasar` (korban)                                                                                                                    | `tenant_id`→`tenants.id`                                  |
| `wilayah_batas`       | Wilayah               | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                                                                                     | `parent_id`→`wilayah_batas.id` (self)                     |
| `call_center_desa`    | Sistem Service Center | `id`, `tenant_id`, `nama_layanan`, `nomor_telepon`, `penanggung_jawab`, `pamong_id`→`desa_pamong.id` (nullable), `aktif`                                        | `tenant_id`→`tenants.id`; `pamong_id`→`desa_pamong.id`    |
| `dashboard_agregat`   | Info Grafis IDM       | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`bencana`), `metrik_key`, `metrik_value`, `periode`                                             | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `site_content_blocks` | CMS Section           | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status`                                                  | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul          | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                                        | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI               | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                                     | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema                  | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                               | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas             | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                                       | `tenant_id`→`tenants.id`                                  |
| `bencana_log`         | Log Audit             | `id`, `tenant_id`, `entity` (`bencana_prakiraan`/`bencana_kejadian`/`bencana_alert`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
BMKG API (eksternal, poll) ──► bencana_prakiraan (parameter → skor_risiko → status)
                                    │        ├─► bencana_kategori (threshold & parameter relevan)
                                    │        ├─► bencana_titik (titik rawan, geom wilayah_batas)
                                    │        ▼
                                    │  status siaga/awas → bencana_alert (WA/portal/sirene)
                                    │        │  → notifikasi warga & Tim Siaga Bencana/Ambulance (call_center_desa)
                                    │        ▼
                                    │  bencana.kejadian (Tim Siaga / warga via service_center Kedaruratan)
                                    │        │
                                    │        ▼
                                    │  domain_events: bencana.kejadian
                                    │        │ worker
                                    │        ├─► idm_skor_cache (ketahanan/bencana)
                                    │        ├─► dashboard_agregat (risiko per dusun)
                                    │        ├─► eskalasi: service_center (Kedaruratan) · Posyandu (korban) · Sosial (bansos darurat)
                                    │        ▼
                                    ▼  Sistem Informasi (peta bahaya & pengumuman) · Surat keterangan bencana · Administrasi_Umum (register kejadian)
```

**Keterangan integrasi:** `bencana_prakiraan` mengonsumsi BMKG API (eksternal, realtime) dan mengkalkulasi **parameter kredibel** (`debit_air`, `intensitas_hujan`, `kecepatan_angin`, dll) per `bencana_kategori` → `skor_risiko` → `status`. `bencana_titik` memetakan titik rawan ke `wilayah_batas` (geom) untuk overlay peta bahaya. Saat status naik ke `siaga`/`awas`, `bencana_alert` otomatis mengirim peringatan dini (WA Fonnte / portal / sirene) ke warga & Tim Siaga Bencana/Ambulance (`call_center_desa`). `bencana_kejadian` (fakta mentah saat bencana terjadi, terhubung ke `penduduk` korban & `bencana_titik`) memicu event yang menyuplai `idm_skor_cache` (ketahanan), `dashboard_agregat`, dan eskalasi ke `service_center` (Kedaruratan), `Posyandu` (korban), `Sosial` (bansos darurat), `Sistem Informasi` (peta & pengumuman), `Surat` (keterangan bencana), `Administrasi_Umum` (register). Seluruh tampilan dibentuk `site*\*`+`i18n_strings` (zero hardcode).
