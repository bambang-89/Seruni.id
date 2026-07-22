# Sistem Pengaturan Desa (Admin & RBAC)

Sistem Pengaturan Desa mengelola **konfigurasi & hak akses tenant** (manajemen user, RBAC, menu, modul, tema) sebagai _Single Source of Truth_ administrasi aplikasi. Merujuk OpenSID (`tweb_user`/`tweb_grup`/`tweb_menu`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **satu pengguna → satu peran → mengontrol akses semua modul** via `feature_flags`.

## 1. Ringkasan Sistem Pengaturan (On Point)

- **Peran:** `pengguna` (user admin) + `peran` (RBAC) + `menu` (nav) + `modul` (feature per modul) + `pengaturan_aplikasi` = _Single Source of Truth_ konfigurasi & akses tenant.
- **Kanal:** Web admin (superadmin/kades) kelola user, role, menu, modul, tema.
- **RBAC:** `peran` (`kades`/`sekdes`/`admin_desa`/`kader_posyandu`/`admin_keuangan`/`admin_kesehatan`/`warga`/`dinas_pmd`) mengontrol akses tiap modul.
- **Integrasi:** Mengontrol semua modul; menu dari `site_navigation`; tema dari `tenant_theme_config`; fitur dari `feature_flags`.
- **Zero Hardcode:** Menu, label, teks dari `site_content_blocks`, `i18n_strings`, `site_navigation`.

## 2. Workflow Lengkap Sistem Pengaturan Komplit

```
[A] MANAJEMEN USER
    desa_pamong / penduduk → pengguna (username, password_hash, peran_id)
        ▼
[B] PENETAPAN HAK AKSES
    peran (RBAC) × modul (feature_flags) → hak akses per user
        ▼
[C] KONFIGURASI TAMPILAN & FITUR
    menu (site_navigation) · modul (feature_flags) · tema (tenant_theme_config) · teks (i18n_strings, site_content_blocks)
        ▼
[D] AUDIT
    pengaturan_log (setiap perubahan user/role/menu/modul)
```

**Aturan Kritikal:**

- `pengguna.peran_id` → `peran`; akses modul via `peran` × `feature_flags`.
- Warga (Layanan Mandiri) **tidak** masuk `pengguna` admin (terpisah di `penduduk_mandiri`).
- Perubahan konfigurasi → draft + "Terapkan" (sama dengan Profile).
- `pengaturan_log` append-only.

**Event & integrasi:**

| Event              | Sumber | Dampak ke modul lain                 |
| ------------------ | ------ | ------------------------------------ |
| `pengguna.berubah` | Admin  | Update akses, audit `pengaturan_log` |
| `peran.berubah`    | Admin  | Re-evaluasi RBAC semua modul         |
| `modul.berubah`    | Admin  | Toggle fitur (`feature_flags`)       |

## 3. Tabel Jenis Pengaturan Desa (OpenSID)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen OpenSID  | Kolom inti                                                                                                                                                       | Referensi FK                                       |
| --------------------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `pengguna`            | `tweb_user`        | `id`, `tenant_id`, `penduduk_id`→`penduduk.id` (nullable), `username`, `password_hash`, `peran_id`→`peran.id`, `aktif`                                           | `penduduk_id`→`penduduk.id`; `peran_id`→`peran.id` |
| `peran`               | `tweb_grup` (role) | `id`, `tenant_id`, `kode` (`kades`/`sekdes`/`admin_desa`/`kader_posyandu`/`admin_keuangan`/`admin_kesehatan`/`warga`/`dinas_pmd`), `nama`, `deskripsi`, `urutan` | `tenant_id`→`tenants.id`                           |
| `menu`                | `tweb_menu`        | `id`, `tenant_id`, `label`, `link`, `induk_id`→`menu.id`, `urutan`, `ikon`                                                                                       | `induk_id`→`menu.id`                               |
| `modul`               | Feature per modul  | `id`, `tenant_id`, `kode_modul`, `nama`, `flag_key`→`feature_flags.flag_key`, `aktif`                                                                            | `flag_key`→`feature_flags.flag_key`                |
| `pengaturan_aplikasi` | Config tenant      | `tenant_id` (PK), `nama_desa`, `kode_desa`, `alamat`, `kontak`, `zona_waktu`, `bahasa_default`                                                                   | `tenant_id`→`tenants.id`                           |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen      | Kolom inti                                                                                                                                 | Referensi FK                                                  |
| --------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| `desa_pamong`         | Sistem Profile | `id`, `tenant_id`, `penduduk_id`, `jabatan_id`, `nik`, `nama_lengkap`, `status`                                                            | `penduduk_id`→`penduduk.id`; `jabatan_id`→`jabatan_pamong.id` |
| `penduduk`            | Core Registry  | `id`, `nik`, `nama`, `status_dasar`                                                                                                        | `tenant_id`→`tenants.id`                                      |
| `site_navigation`     | Navigasi       | `id`, `tenant_id`, `label`, `link`, `urutan`, `induk_id`                                                                                   | `tenant_id`→`tenants.id`; `induk_id`→`site_navigation.id`     |
| `feature_flags`       | Toggle Modul   | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                   | `tenant_id`→`tenants.id`                                      |
| `tenant_theme_config` | Tema           | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                          | `tenant_id`→`tenants.id`                                      |
| `site_content_blocks` | CMS Section    | `id`, `tenant_id`, `halaman`, `tipe_blok`, `urutan`, `konten` (JSONB), `status`                                                            | `tenant_id`→`tenants.id`                                      |
| `i18n_strings`        | Teks UI        | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                | `tenant_id`→`tenants.id`                                      |
| `site_settings`       | Identitas      | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                  | `tenant_id`→`tenants.id`                                      |
| `domain_events`       | Event Bus      | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                              | `tenant_id`→`tenants.id`                                      |
| `pengaturan_log`      | Log Audit      | `id`, `tenant_id`, `entity` (`pengguna`/`peran`/`menu`/`modul`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                      |

### 3.3 Diagram integrasi

```
desa_pamong / penduduk ──► pengguna (username, password_hash, peran_id)
        │                        │
        │                        ▼
        │                 peran (RBAC) × modul/feature_flags → akses semua modul
        │                        │
        ├─ menu ───────────────► site_navigation (navigasi portal)
        ├─ tema ───────────────► tenant_theme_config
        └─ teks ───────────────► i18n_strings / site_content_blocks
                │
                ▼
        domain_events → pengaturan_log (audit setiap perubahan)
```

**Keterangan integrasi:** `pengguna` adalah akun admin desa (terikat `penduduk`/`desa_pamong`); `peran` mengontrol RBAC ke semua modul via `feature_flags`; `menu` dari `site_navigation`; tema dari `tenant_theme_config`; teks dari `i18n_strings`/`site_content_blocks`. Semua perubahan diaudit di `pengaturan_log`. Warga terpisah (`penduduk_mandiri` di Layanan Mandiri). Seluruh konfigurasi tanpa hardcode.
