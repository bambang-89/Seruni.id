# Sistem Posyandu Desa

Sistem Posyandu Desa mengelola **informasi kesehatan desa** sebagai _Single Source of Truth_ untuk data kesehatan (balita, ibu hamil, imunisasi, gizi, lansia). Merujuk [e-Posyandu (eposyandu.edutic.id)](https://eposyandu.edutic.id/) diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven, offline-first kader). Kunci: **satu input kesehatan → menyebar ke IDM, Agenda, Surat, & Administrasi** tanpa duplikasi.

## 1. Ringkasan Sistem Posyandu (On Point)

- **Peran:** `balita` + `ibu_hamil` + `posyandu_kunjungan` = _Single Source of Truth_ kesehatan desa. Terhubung ke `penduduk` (Core Registry) sebagai ortu/ibu.
- **Kanal:** Web admin (kader posyandu) catat kunjungan (bisa **offline** → sync saat online); Portal Publik read-only (statistik agregat).
- **Cakupan:** Balita (0–59 bln: BB/TB/lingkar kepala, status gizi, imunisasi, vitamin A), Ibu Hamil (ANC), Ibu Menyusui, Lansia, Disabilitas — sesuai standar e-Posyandu.
- **Integrasi IDM:** `posyandu.kunjungan.dicatat` → worker rekalkulasi **skor 7.b (Aktivitas Posyandu, Dimensi Infrastruktur & Pelayanan Dasar)** + `dashboard_agregat` kesehatan + draft usulan gizi bila cakupan rendah.
- **Auto-sync:** Jadwal posyandu → `agenda_kegiatan` (jenis `posyandu`, `dibuat_otomatis=true`) → Sistem Informasi + reminder WA. Surat kesehatan (440.1, 461, 463, 441, 445) auto-fill dari data ini.
- **Zero Hardcode:** Label jenis imunisasi/gizi, teks dashboard dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Posyandu Komplit

```
[A] PENDAFTARAN (fakta mentah)
    penduduk (ortu/ibu) ──► balita (anak 0-5) / ibu_hamil (ANC)
        │  posyandu (profil fasilitas) + kader_posyandu (petugas)
        ▼
[B] KUNJUNGAN POSYANDU (kader, bisa offline)
    posyandu_kunjungan (bb, tb, lingkar kepala, status_gizi, imunisasi, vitamin A)
        │  → posyandu_akses_log (sync/audit)
        ▼
[C] EVENT PROPAGATION (worker)
    posyandu.kunjungan.dicatat ──► rekalkulasi idm_skor_cache (7.b)
                             ├─► dashboard_agregat (cakupan imunisasi, gizi)
                             ├─► jika cakupan rendah → draft usulan gizi/imunisasi (W2)
                             ▼
[D] JADWAL & NOTIFIKASI
    jadwal posyandu → agenda_kegiatan (posyandu, auto) → Sistem Informasi + WA reminder
        ▼
[E] PELAYANAN TURUNAN
    Surat kesehatan (440.1/461/463/441/445) auto-fill dari balita/ibu_hamil/penduduk
    Administrasi_Umum: register kesehatan auto-sync dari kunjungan
```

**Aturan Kritikal:**

- `balita.ortu_penduduk_id` / `ibu_hamil.penduduk_id` → `penduduk` (NIK unik) — tidak input ulang identitas.
- `posyandu_kunjungan` **append-only** per kunjungan; tidak edit histori timbang (audit via `posyandu_akses_log`).
- `posyandu.kunjungan.dicatat` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).
- Offline-first: kader simpan lokal, sync saat online; `posyandu_akses_log` mencatat status sync (riset terbuka, bukan asumsi selalu online).
- Status gizi dihitung dari BB/U, TB/U, BB/TB (standar WHO/e-Posyandu), bukan diketik manual.

**Event & integrasi:**

| Event                        | Sumber            | Dampak                                                         |
| ---------------------------- | ----------------- | -------------------------------------------------------------- |
| `posyandu.kunjungan.dicatat` | Kunjungan kader   | Skor IDM 7.b, `dashboard_agregat` kesehatan, draft usulan gizi |
| `ibu_hamil.dicatat`          | Registrasi ANC    | Agenda posyandu, notifikasi Bumil, surat 440.1                 |
| `balita.dicatat`             | Registrasi balita | Statistik kesehatan desa, agregat IDM                          |
| `penduduk.bpjs.berubah`      | Edit status BPJS  | IDM indikator kesehatan (cakupan BPJS)                         |
| `posyandu.jadwal.dibuat`     | Jadwal posyandu   | `agenda_kegiatan` (Sistem Informasi) + WA reminder             |

## 3. Tabel Jenis Posyandu Desa (e-Posyandu + Seruni - Sistem Repository Unifikasi Informasi)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)       | Ekuivalen e-Posyandu | Kolom inti                                                                                                                                                                                                                                         | Referensi FK                                                                         |
| -------------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `posyandu`           | Profil Posyandu      | `id`, `tenant_id`, `nama`, `dusun_id`→`wilayah_batas.id`, `alamat`, `hari_buka`, `jam_buka`, `jam_tutup`, `aktif`                                                                                                                                  | `dusun_id`→`wilayah_batas.id`                                                        |
| `kader_posyandu`     | Kader                | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `nama`, `no_hp`, `pelatihan`, `posyandu_id`→`posyandu.id`, `aktif`                                                                                                                                 | `penduduk_id`→`penduduk.id`; `posyandu_id`→`posyandu.id`                             |
| `balita`             | Data Balita          | `id`, `tenant_id`, `nik` (UQ), `nama`, `tgl_lahir`, `jenis_kelamin`, `ortu_penduduk_id`→`penduduk.id`, `status_gizi` (`buruk`/`kurang`/`baik`/`lebih`), `imunisasi_lengkap` (bool), `aktif`                                                        | `ortu_penduduk_id`→`penduduk.id`                                                     |
| `ibu_hamil`          | Data Bumil (ANC)     | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `tgl_hamil`, `usia_kehamilan` (minggu), `jumlah_janin`, `status` (`aktif`/`melahirkan`/`berhenti`), `kunjungan_anc`                                                                                | `penduduk_id`→`penduduk.id`                                                          |
| `posyandu_kunjungan` | Kunjungan            | `id`, `tenant_id`, `balita_id`→`balita.id`, `posyandu_id`→`posyandu.id`, `kader_id`→`kader_posyandu.id`, `tanggal`, `berat_badan`, `tinggi_badan`, `lingkar_kepala`, `status_gizi` (derived), `imunisasi_diberi`, `vitamin_a` (bool), `penyuluhan` | `balita_id`→`balita.id`; `posyandu_id`→`posyandu.id`; `kader_id`→`kader_posyandu.id` |
| `posyandu_akses_log` | Log Akses/Sync       | `id`, `tenant_id`, `kunjungan_id`→`posyandu_kunjungan.id`, `kader_id`, `waktu_akses`, `status_sync` (`lokal`/`terkirim`), `perangkat`                                                                                                              | `kunjungan_id`→`posyandu_kunjungan.id`; `kader_id`→`kader_posyandu.id`               |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen       | Kolom inti                                                                                                                                | Referensi FK                                              |
| --------------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `domain_events`       | Event Bus       | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                             | `tenant_id`→`tenants.id`                                  |
| `wilayah_batas`       | Wilayah         | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                                                               | `parent_id`→`wilayah_batas.id` (self)                     |
| `penduduk`            | Core Registry   | `id`, `nik`, `nama`, `status_ktp`, `bpjs_status`, `dusun`, `rt`, `rw` (referensi ortu/ibu)                                                | `tenant_id`→`tenants.id`                                  |
| `agenda_kegiatan`     | Agenda (F10)    | `id`, `tenant_id`, `judul`, `jenis` (`posyandu`), `dibuat_otomatis` (bool), `tanggal_mulai`, `lokasi`                                     | `tenant_id`→`tenants.id`                                  |
| `dashboard_agregat`   | Info Grafis IDM | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`kesehatan`), `metrik_key`, `metrik_value`, `periode`                     | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id` |
| `site_content_blocks` | CMS Section     | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status`                            | `tenant_id`→`tenants.id`                                  |
| `feature_flags`       | Toggle Modul    | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                  | `tenant_id`→`tenants.id`                                  |
| `i18n_strings`        | Teks UI         | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                               | `tenant_id`→`tenants.id`                                  |
| `tenant_theme_config` | Tema            | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                         | `tenant_id`→`tenants.id`                                  |
| `site_settings`       | Identitas       | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                 | `tenant_id`→`tenants.id`                                  |
| `posyandu_log`        | Log Audit       | `id`, `tenant_id`, `entity` (`balita`/`ibu_hamil`/`kunjungan`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                  |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, NIK) ──┬─► balita (ortu_penduduk_id) ──► posyandu_kunjungan
                                 │                                    │  (bb/tb/lingkar, gizi, imunisasi)
                                 └─► ibu_hamil (penduduk_id)           │
                                                                      ▼
                                                              posyandu_akses_log (offline sync)
                                                                      │
                                                                      ▼
                                                          domain_events: posyandu.kunjungan.dicatat
                                                                      │ worker
                                                        ┌─────────────┼─────────────────────┐
                                                        ▼             ▼                     ▼
                                              idm_skor_cache (7.b)  dashboard_agregat   draft usulan gizi
                                                        (IDM Dimensi 4)    (kesehatan)        (→ Sistem Keuangan W2)
                                                                      │
                                          posyandu (fasilitas) ──► agenda_kegiatan (posyandu, auto)
                                                                      │
                                                                      ▼
                                          Sistem Informasi (Beranda/Agenda) + WA reminder · Surat kesehatan (440.1/461/463/441/445)
```

**Keterangan integrasi:** `balita`/`ibu_hamil` terhubung ke `penduduk` (Sistem Penduduk, Core Registry) tanpa duplikasi identitas; `posyandu_kunjungan` menjadi fakta mentah yang via Event Propagation menyuplai `idm_skor_cache` (skor 7.b, Dimensi Infrastruktur & Pelayanan Dasar), `dashboard_agregat` (statistik kesehatan desa), dan draft usulan gizi ke Sistem Keuangan. Jadwal posyandu otomatis mengisi `agenda_kegiatan` (Sistem Informasi) + reminder WA; surat kesehatan (Sistem Surat) auto-fill dari data ini. Seluruh tampilan dibentuk `site_*`+`i18n_strings` (zero hardcode).
