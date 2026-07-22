# Sistem Sinkronisasi Desa (Interoperabilitas)

Sistem Sinkronisasi Desa mengelola **pertukaran data eksternal** (OpenDK / Kemendagri / IDM) sebagai _Single Source of Truth_ interoperabilitas desa. Merujuk OpenSID (`tweb_sinkronisasi`/`Sinkronisasi`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **fact tables/domain_events → push ke eksternal; pull → update Core Registry via event** (mapping di-DB, zero hardcode).

## 1. Ringkasan Sistem Sinkronisasi (On Point)

- **Peran:** `sinkronisasi_job` + `sinkronisasi_mapping` + `sinkronisasi_log` = _Single Source of Truth_ pertukaran data eksternal.
- **Kanal:** Scheduled job / manual trigger → pull/push data ke sistem eksternal via API.
- **Tujuan:** **OpenDK** (data desa ke kabupaten), **Kemendagri** (kependudukan), **IDM** (skor indeks desa).
- **Integrasi:** Mengonsumsi `domain_events` / fact tables → kirim ke eksternal; menerima update (mis. kependudukan Kemendagri) → update Core Registry.
- **Zero Hardcode:** Endpoint & field mapping di-DB (`sinkronisasi_mapping`); kredensial di secret manager.

## 2. Workflow Lengkap Sistem Sinkronisasi Komplit

```
[A] JADWAL / TRIGGER
    sinkronisasi_job (tujuan, tipe: push/pull, jadwal) → worker
        ▼
[B] EKSEKUSI
    ambil data dari fact tables / domain_events → transform via sinkronisasi_mapping
        │  → kirim ke eksternal (OpenDK/Kemendagri/IDM) API
        ▼
[C] LOG & STATUS
    sinkronisasi_log (status: sukses/gagal, jumlah, error)
        │  → notifikasi ke admin jika gagal
        ▼
[D] TERIMA (pull)
    data eksternal (mis. Kemendagri) → update penduduk / wilayah_batas via event
```

**Aturan Kritikal:**

- `sinkronisasi_mapping` di-DB (field mapping antar sistem) — tidak hardcode di kode.
- Pull data eksternal → update via **event** (bukan overwrite langsung).
- `sinkronisasi_log` append-only; retry terbatas.
- Kredensial di secret manager (tidak disimpan di tabel).

**Event & integrasi:**

| Event                        | Sumber          | Dampak                                                      |
| ---------------------------- | --------------- | ----------------------------------------------------------- |
| `sinkron.dijadwalkan`        | Scheduler       | Push/pull ke eksternal (OpenDK/Kemendagri/IDM)              |
| `sinkron.selesai`            | Worker          | Update dashboard, notifikasi admin                          |
| `sinkron.gagal`              | Worker          | Notifikasi admin (Sistem Notifikasi), retry                 |
| `penduduk.eksternal.berubah` | Pull Kemendagri | Update `penduduk`/`wilayah_batas` via event (Core Registry) |

## 3. Tabel Jenis Sinkronisasi Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)         | Ekuivalen OpenSID   | Kolom inti                                                                                                                                  | Referensi FK                   |
| ---------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `sinkronisasi_job`     | `tweb_sinkronisasi` | `id`, `tenant_id`, `tujuan` (`opendk`/`kemendagri`/`idm`), `tipe` (`push`/`pull`), `jadwal_cron`, `last_run`, `status` (`aktif`/`nonaktif`) | `tenant_id`→`tenants.id`       |
| `sinkronisasi_mapping` | Field mapping       | `id`, `tenant_id`, `job_id`→`sinkronisasi_job.id`, `tabel_sumber`, `field_sumber`, `field_tujuan`, `transform`                              | `job_id`→`sinkronisasi_job.id` |
| `sinkronisasi_log`     | Log sync            | `id`, `tenant_id`, `job_id`→`sinkronisasi_job.id`, `waktu`, `status` (`sukses`/`gagal`), `jumlah_record`, `error`                           | `job_id`→`sinkronisasi_job.id` |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)     | Ekuivalen         | Kolom inti                                                                                                                  | Referensi FK                          |
| ------------------ | ----------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `domain_events`    | Event Bus         | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                               | `tenant_id`→`tenants.id`              |
| `penduduk`         | Core Registry     | `id`, `nik`, `nama`, `status_dasar` (target pull Kemendagri)                                                                | `tenant_id`→`tenants.id`              |
| `wilayah_batas`    | Wilayah           | `id`, `tenant_id`, `jenis`, `nama`, `geom`, `parent_id`                                                                     | `parent_id`→`wilayah_batas.id` (self) |
| `idm_skor_cache`   | Sistem IDM        | `id`, `tenant_id`, `indikator_kode`, `skor`, `nilai_agregat`, `dihitung_pada`                                               | `tenant_id`→`tenants.id`              |
| `tenants`          | Root tenant       | `id`, `nama_desa`, `subdomain`, `kode_desa`, `kecamatan`, `kabupaten`, `provinsi`, `aktif`                                  | —                                     |
| `feature_flags`    | Toggle Modul      | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                    | `tenant_id`→`tenants.id`              |
| `site_settings`    | Identitas         | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                   | `tenant_id`→`tenants.id`              |
| `notifikasi`       | Sistem Notifikasi | `id`, `tenant_id`, `penerima_tipe`, `penerima_id`, `judul`, `pesan`, `status_baca`, `tautan`                                | `tenant_id`→`tenants.id`              |
| `sinkronisasi_log` | Log Audit         | `id`, `tenant_id`, `entity` (`sinkronisasi_job`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`              |

### 3.3 Diagram integrasi

```
fact tables / domain_events ──► sinkronisasi_job (tujuan: opendk/kemendagri/idm)
        │                              │  sinkronisasi_mapping (transform)
        │                              ▼
        │                       eksternal API (push) ──► sinkronisasi_log
        │                              │
        │  (pull) ◄── eksternal (mis. Kemendagri)
        ▼                              │
penduduk / wilayah_batas ◄── event (Core Registry update)
        │
        ▼
domain_events → notifikasi (admin) · idm_skor_cache (jika tujuan=idm)
```

**Keterangan integrasi:** `sinkronisasi_job` mengatur pertukaran data ke OpenDK/Kemendagri/IDM; mapping di-DB (`sinkronisasi_mapping`, zero hardcode). Push dari fact tables/`domain_events`; pull mengupdate Core Registry (`penduduk`/`wilayah_batas`) via event (bukan overwrite). Semua tercatat di `sinkronisasi_log` & notifikasi ke admin (Sistem Notifikasi) jika gagal. Kredensial di secret manager, tidak di tabel.
