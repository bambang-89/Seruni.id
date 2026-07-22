# Sistem Layanan Mandiri Desa

Sistem Layanan Mandiri Desa adalah **portal warga terautentikasi** (self-service) sebagai _Single Source of Truth_ layanan warga. Merujuk OpenSID (`tweb_penduduk_mandiri`/`Mandiri`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **warga login → ajukan surat, lihat data, track aduan/bansos, ubah data (OTP)** tanpa ke kantor.

## 1. Ringkasan Sistem Layanan Mandiri (On Point)

- **Peran:** `mandiri_sesi` (login) + `mandiri_ajuan` (pengajuan surat) + `mandiri_track` (track aduan/bansos) = _Single Source of Truth_ layanan warga terautentikasi.
- **Kanal:** Portal warga login (`penduduk_mandiri`) → ajukan surat, lihat data keluarga, track aduan (service_center), lihat bansos (Sosial), ubah data (Penduduk via OTP).
- **Integrasi:** Terhubung ke **Surat** (`surat_pengajuan` via `surat_jenis`), **service_center** (`pengaduan_desa`), **Sosial** (`kpm`), **Penduduk** (`penduduk_mandiri`, OTP via Notifikasi), **Notifikasi**.
- **RBAC:** Warga hanya akses data sendiri (scope `penduduk_id`/`keluarga_id`).
- **Zero Hardcode:** Menu layanan, teks dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Layanan Mandiri Komplit

```
[A] LOGIN
    penduduk_mandiri (NIK + password/OTP) → mandiri_sesi (token)
        ▼
[B] LAYANAN WARGA
    ├─ Ajukan Surat → mandiri_ajuan → surat_pengajuan (Sistem Surat, status: diajukan)
    ├─ Lihat Data Keluarga → penduduk/keluarga (read)
    ├─ Track Aduan → pengaduan_desa (service_center)
    ├─ Lihat Bansos → kpm / bansos_penerima (Sosial)
    └─ Ubah Data → penduduk (via OTP verifikasi, emit event)
        ▼
[C] NOTIFIKASI
    mandiri_ajuan / status → notifikasi (via Sistem Notifikasi)
        ▼
[D] EVENT PROPAGATION
    surat.diajukan / pengaduan.dibuat → worker → notifikasi & update mandiri_track
```

**Aturan Kritikal:**

- `mandiri_sesi` terikat `penduduk_mandiri` (FK `penduduk_id`) — tidak buat akun ganda.
- Ajuan surat → `surat_pengajuan` (identitas diambil dari `penduduk`, tidak input ulang); `mandiri_ajuan.surat_jenis_id` → `surat_jenis` (nama kanonik master jenis surat, bukan `surat_master`).
- Ubah data sensitif wajib **OTP** (via Sistem Notifikasi).
- RBAC: warga hanya akses data sendiri (scope `penduduk_id`/`keluarga_id`).

**Event & integrasi:**

| Event                   | Sumber          | Dampak                                                      |
| ----------------------- | --------------- | ----------------------------------------------------------- |
| `surat.diajukan`        | Layanan Mandiri | Masuk antrean TTE (Surat), notifikasi ke warga & admin      |
| `pengaduan.dibuat`      | Layanan Mandiri | Masuk service_center (Kedaruratan jika darurat), notifikasi |
| `penduduk.data.berubah` | Layanan Mandiri | Update `mandiri_track`, verifikasi OTP                      |

## 3. Tabel Jenis Layanan Mandiri Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)  | Ekuivalen OpenSID              | Kolom inti                                                                                                                                                                                                     | Referensi FK                                                                                              |
| --------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `mandiri_sesi`  | `tweb_penduduk_mandiri` (sesi) | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `token`, `login_at`, `expired_at`, `aktif`                                                                                                                     | `penduduk_id`→`penduduk.id`                                                                               |
| `mandiri_ajuan` | Pengajuan surat warga          | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `surat_jenis_id`→`surat_jenis.id`, `surat_pengajuan_id`→`surat_pengajuan.id` (nullable), `status` (`diajukan`/`verifikasi`/`selesai`/`ditolak`), `dibuat_pada` | `penduduk_id`→`penduduk.id`; `surat_jenis_id`→`surat_jenis.id`; `surat_pengajuan_id`→`surat_pengajuan.id` |
| `mandiri_track` | Track aduan/bansos             | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `jenis` (`aduan`/`bansos`), `ref_id`, `status_terakhir`, `diperbarui_pada`                                                                                     | `penduduk_id`→`penduduk.id`                                                                               |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen               | Kolom inti                                                                                                                                           | Referensi FK                                                    |
| --------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `penduduk_mandiri`    | `tweb_penduduk_mandiri` | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `nik`, `email`, `telepon`, `password_hash`, `token`                                                  | `penduduk_id`→`penduduk.id`                                     |
| `penduduk`            | Core Registry           | `id`, `nik`, `nama`, `status_kependudukan` (di sistem lain disebut `status_dasar`; `aktif`=HIDUP)                                                    | `tenant_id`→`tenants.id`                                        |
| `keluarga`            | Core Registry           | `id`, `no_kk`, `nik_kepala`, `alamat`, `dusun`, `rt`, `rw`                                                                                           | `tenant_id`→`tenants.id`                                        |
| `surat_pengajuan`     | Sistem Surat            | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `jenis_surat_id`→`surat_jenis.id`, `status` (`diajukan`/`verifikasi`/`ttd`/`selesai`), `dibuat_pada` | `penduduk_id`→`penduduk.id`; `jenis_surat_id`→`surat_jenis.id`  |
| `surat_jenis`         | Sistem Surat (master)   | `id`, `tenant_id`, `nama_jenis`, `template_field` (JSONB), `format_nomor_arsip`, `aktif`                                                             | `tenant_id`→`tenants.id`                                        |
| `pengaduan_desa`      | Sistem service_center   | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `kategori_id`, `subjek`, `status`                                                                    | `penduduk_id`→`penduduk.id`                                     |
| `kpm`                 | Sistem Sosial           | `id`, `tenant_id`, `keluarga_id`→`keluarga.id`, `kepala_penduduk_id`→`penduduk.id`, `no_kk`, `nama_kpm`                                              | `keluarga_id`→`keluarga.id`; `kepala_penduduk_id`→`penduduk.id` |
| `otp_token`           | Sistem Notifikasi       | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `tujuan`, `kode`, `expired_at`, `digunakan`                                                          | `penduduk_id`→`penduduk.id`                                     |
| `domain_events`       | Event Bus               | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                        | `tenant_id`→`tenants.id`                                        |
| `notifikasi`          | Sistem Notifikasi       | `id`, `tenant_id`, `penerima_tipe`, `penerima_id`, `judul`, `pesan`, `status_baca`, `tautan`                                                         | `tenant_id`→`tenants.id`                                        |
| `site_content_blocks` | CMS Section             | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                                      | `tenant_id`→`tenants.id`                                        |
| `feature_flags`       | Toggle Modul            | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                             | `tenant_id`→`tenants.id`                                        |
| `i18n_strings`        | Teks UI                 | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                          | `tenant_id`→`tenants.id`                                        |
| `tenant_theme_config` | Tema                    | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                    | `tenant_id`→`tenants.id`                                        |
| `site_settings`       | Identitas               | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                            | `tenant_id`→`tenants.id`                                        |
| `mandiri_log`         | Log Audit               | `id`, `tenant_id`, `entity` (`mandiri_ajuan`/`mandiri_track`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at`             | `tenant_id`→`tenants.id`                                        |

### 3.3 Diagram integrasi

```
penduduk_mandiri (NIK+password/OTP) ──► mandiri_sesi (token)
        │
        ├─► Ajukan Surat ──► mandiri_ajuan (surat_jenis_id→surat_jenis) ──► surat_pengajuan (Sistem Surat) → antrean TTE
        ├─► Lihat Data ───► penduduk / keluarga (Core Registry, read)
        ├─► Track Aduan ──► pengaduan_desa (service_center)
        ├─► Lihat Bansos ─► kpm / bansos_penerima (Sosial)
        └─► Ubah Data ────► penduduk (via otp_token / Sistem Notifikasi)
                │
                ▼
        domain_events → notifikasi (Sistem Notifikasi) · mandiri_track (status)
```

**Keterangan integrasi:** `mandiri_sesi` adalah pintu warga terautentikasi; semua layanan mengambil data dari Core Registry (`penduduk`/`keluarga`) tanpa duplikasi identitas. Ajuan surat → `surat_pengajuan` (Sistem Surat) via `surat_jenis` (master jenis surat kanonik); aduan → `pengaduan_desa` (service*center); bansos → `kpm` (Sosial); ubah data → `penduduk` via OTP (Sistem Notifikasi). Seluruh notifikasi via Sistem Notifikasi; tampilan dibentuk `site*\*`+`i18n_strings` tanpa hardcode.
