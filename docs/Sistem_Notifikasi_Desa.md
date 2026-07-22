# Sistem Notifikasi Desa

Sistem Notifikasi Desa adalah **channel pesan & notifikasi terpadu** (omnichannel WA/SMS/email/push + OTP) sebagai _Single Source of Truth_ komunikasi desa. Merujuk OpenSID (`tweb_notif`/`tweb_pesan`/`tweb_otp`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **semua modul emit event → worker → notifikasi + outbox_pesan** (satu pintu, tidak ada modul kirim langsung).

## 1. Ringkasan Sistem Notifikasi (On Point)

- **Peran:** `notifikasi` (inbox) + `notifikasi_template` + `outbox_pesan` (WA/SMS/email/push) + `otp_token` = _Single Source of Truth_ channel pesan & notifikasi.
- **Kanal:** Event-driven — semua modul emit event → worker → `outbox_pesan` (Fonnte WA / SMS gateway / SMTP) + `notifikasi` (inbox web/app).
- **OTP:** `otp_token` untuk login **Layanan Mandiri** & verifikasi perubahan **Penduduk**.
- **Integrasi:** Satu pintu notifikasi untuk Surat, Sosial, service_center, Bencana, Pembangunan, Posyandu, dll.
- **Zero Hardcode:** Teks pesan di `notifikasi_template` (DB); tidak hardcode string di kode.

## 2. Workflow Lengkap Sistem Notifikasi Komplit

```
[A] EVENT MASUK
    domain_events (dari semua modul) → worker notifikasi
        ▼
[B] RESOLUSI TEMPLATE & CHANNEL
    notifikasi_template (pilih pesan by event) × tujuan (user/warga/perangkat)
        │  → notifikasi (inbox) + outbox_pesan (WA/SMS/email/push)
        ▼
[C] PENGIRIMAN
    outbox_pesan (channel, tujuan, status: antri/terkirim/gagal) → Fonnte/SMS/SMTP
        │  → callback status
        ▼
[D] OTP
    otp_token (untuk login/verifikasi) → validasi → expired/hapus
```

**Aturan Kritikal:**

- Semua notifikasi keluar via `outbox_pesan` (satu pintu) — tidak ada modul kirim langsung.
- `notifikasi_template` di-DB (zero hardcode teks pesan).
- `otp_token` expire (TTL); max retry terbatas.
- `outbox_pesan` append-only log pengiriman (audit).

**Event & integrasi:**

| Event                                  | Sumber                     | Dampak                                                        |
| -------------------------------------- | -------------------------- | ------------------------------------------------------------- |
| `*.dibuat` / `*.selesai` (semua modul) | Modul terkait              | `notifikasi` + `outbox_pesan` (WA/SMS/email/push) ke penerima |
| `otp.diminta`                          | Layanan Mandiri / Penduduk | `otp_token` → verifikasi login/perubahan data                 |

## 3. Tabel Jenis Notifikasi Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen OpenSID | Kolom inti                                                                                                                                                                           | Referensi FK                    |
| --------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------- |
| `notifikasi`          | `tweb_notif`      | `id`, `tenant_id`, `penerima_tipe` (`user`/`warga`/`perangkat`), `penerima_id`, `judul`, `pesan`, `status_baca` (bool), `tautan`, `dibuat_pada`                                      | `tenant_id`→`tenants.id`        |
| `notifikasi_template` | Template pesan    | `id`, `tenant_id`, `kode_event`, `judul`, `isi` (JSONB, placeholder), `channel` (`wa`/`sms`/`email`/`push`), `aktif`                                                                 | `tenant_id`→`tenants.id`        |
| `outbox_pesan`        | `tweb_pesan`      | `id`, `tenant_id`, `notifikasi_id`→`notifikasi.id` (nullable), `channel` (`wa`/`sms`/`email`/`push`), `tujuan`, `isi`, `status` (`antri`/`terkirim`/`gagal`), `error`, `waktu_kirim` | `notifikasi_id`→`notifikasi.id` |
| `otp_token`           | `tweb_otp`        | `id`, `tenant_id`, `penduduk_id`→`penduduk.id` (nullable), `tujuan` (`login`/`verifikasi`), `kode`, `expired_at`, `digunakan` (bool)                                                 | `penduduk_id`→`penduduk.id`     |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen      | Kolom inti                                                                                                                                       | Referensi FK                                                  |
| --------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| `domain_events`       | Event Bus      | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                    | `tenant_id`→`tenants.id`                                      |
| `penduduk`            | Core Registry  | `id`, `nik`, `nama`, `nomor_hp` (tujuan WA/SMS)                                                                                                  | `tenant_id`→`tenants.id`                                      |
| `desa_pamong`         | Sistem Profile | `id`, `tenant_id`, `penduduk_id`, `jabatan_id`, `nik`, `nama_lengkap`, `status`                                                                  | `penduduk_id`→`penduduk.id`; `jabatan_id`→`jabatan_pamong.id` |
| `site_settings`       | Identitas      | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                        | `tenant_id`→`tenants.id`                                      |
| `feature_flags`       | Toggle Modul   | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                         | `tenant_id`→`tenants.id`                                      |
| `i18n_strings`        | Teks UI        | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                      | `tenant_id`→`tenants.id`                                      |
| `tenant_theme_config` | Tema           | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                | `tenant_id`→`tenants.id`                                      |
| `notifikasi_log`      | Log Audit      | `id`, `tenant_id`, `entity` (`notifikasi`/`outbox_pesan`/`otp_token`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                      |

### 3.3 Diagram integrasi

```
domain_events (Surat/Sosial/service_center/Bencana/Pembangunan/Posyandu/dll)
        │ worker
        ▼
notifikasi_template (by kode_event) → notifikasi (inbox) + outbox_pesan
        │                                        │
        │                                        ├─ WA (Fonnte) → warga/perangkat
        │                                        ├─ SMS gateway → warga
        │                                        ├─ Email (SMTP) → warga/perangkat
        │                                        └─ Push → app
        ▼
otp_token (login Layanan Mandiri / verifikasi Penduduk) → validasi → expired
```

**Keterangan integrasi:** `notifikasi` adalah channel terpadu; semua modul tidak kirim pesan langsung tetapi emit event → worker → `notifikasi_template` (zero hardcode) → `notifikasi` (inbox) + `outbox_pesan` (Fonnte WA / SMS / email / push) ke penerima (`penduduk`/`desa_pamong`). `otp_token` mendukung **Layanan Mandiri** & verifikasi **Penduduk**. Seluruh pengiriman tercatat append-only di `outbox_pesan` & `notifikasi_log` untuk audit.
