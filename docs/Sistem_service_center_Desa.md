# Sistem Service Center Desa

Sistem Service Center Desa mengelola **layanan Aduan Masyarakat & Call Center Desa** sebagai _Single Source of Truth_ penanganan pengaduan dan direktori layanan darurat/koordinasi. Merujuk OpenSID (`tweb_pengaduan`) & layanan Aduan Masyarakat, diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **satu aduan → terkategori, ter-eskalasi, ter-track** hingga selesai, tanpa duplikasi.

## 1. Ringkasan Sistem Service Center (On Point)

- **Peran:** `pengaduan_desa` + `pengaduan_kategori` + `pengaduan_penanganan` + `call_center_desa` = _Single Source of Truth_ aduan & call center desa.
- **Kanal:** Portal Publik / WhatsApp chatbot (Fonnte) untuk warga lapor; Web admin (operator desa) triage & eskalasi; akses khusus **Bhabinkamtibmas & Babinsa** untuk kategori Kamtibmas.
- **Kategori Aduan:** `POSBANKU` (bantuan hukum), `INFRASTRUKTUR` (kerusakan), `KAMTIBMAS` (keamanan & ketertiban — akses Bhabinkamtibmas/Babinsa), `KEDARURATAN` (bencana/musibah — wajib prioritas kritis, **TIDAK** untuk aduan ringan), `ULASAN_PELAYANAN` (pengaduan/ulasan pelayanan desa).
- **Call Center:** Direktori nomor koordinasi/darurat — Admin Desa, BKD (Badan Keamanan Desa), Bhabinkamtibmas, Babinsa, Posbankum, Tim Siaga Bencana, Ambulance Desa.
- **Penanganan:** `pengaduan_penanganan` menugaskan aduan ke penanggung jawab (`admin_desa`/`bkd`/`bhabinkamtibmas`/`babinsa`/`posbankum`/`tim_siaga_bencana`/`ambulance_desa`) — append-only, status ter-tracking.
- **Integrasi IDM:** `pengaduan.dibuat`/`pengaduan.selesai` → worker rekalkulasi indikator **pelayanan publik & responsivitas** (Dimensi Pelayanan IDM).
- **Zero Hardcode:** Kategori, label status, teks call center dari `site_content_blocks`, `i18n_strings`, `feature_flags`.

## 2. Workflow Lengkap Sistem Service Center Komplit

```
[A] PELAPORAN (fakta mentah)
    penduduk (Core Registry, NIK) ──► pengaduan_desa (kategori_id, subjek, isi, lokasi, bukti, prioritas)
        │  via Portal Publik / WhatsApp chatbot (Fonnte, transaksi OTP)
        │  validasi: kategori KEDARURATAN → prioritas wajib kritis (tolak jika ringan)
        ▼
[B] TRIAGE & ESKALASI
    pengaduan_kategori (tentukan jenis) × pengaduan_desa → pengaduan_penanganan (ditugaskan_ke, penanggung_jawab, status)
        │  Kamtibmas → hanya Bhabinkamtibmas/Babinsa (RBAC) yg bisa lihat & tangani
        │  Kedaruratan → notifikasi segera WA ke Tim Siaga Bencana & Ambulance Desa
        ▼
[C] PENANGANAN & PENYELESAIAN
    pengaduan_penanganan (tindakan, status: ditugaskan → diproses → selesai)
        │  → update pengaduan_desa.status = selesai, tgl_selesai
        │  → notifikasi WA ke pelapor (info_instan)
        ▼
[D] EVENT PROPAGATION (worker)
    pengaduan.dibuat / pengaduan.selesai ──► rekalkulasi idm_skor_cache (pelayanan publik)
                                        ├─► dashboard_agregat (aduan per kategori/dusun)
                                        ├─► call_center_desa (direktori publik)
                                        ▼
[E] LAYANAN TURUNAN
    1-Kategori View (semua aduan + status) · Sistem Informasi (pengumuman call center)
    Administrasi_Umum: register aduan · Surat tanggapan aduan (auto-fill)
```

**Aturan Kritikal:**

- `pengaduan_desa.penduduk_id` → `penduduk` (NIK unik) — tidak input ulang identitas pelapor.
- Kategori `KEDARURATAN` wajib `prioritas = kritis`; sistem **menolak** aduan ringan pada kategori ini (validasi bisnis).
- Kategori `KAMTIBMAS` akses terbatas: hanya **Bhabinkamtibmas & Babinsa** (RBAC) yang dapat lihat & tangani.
- `pengaduan_penanganan` **append-only**; perubahan status = entri baru, bukan edit (audit penuh).
- `pengaduan.dibuat` → `idm_skor_cache` & `dashboard_agregat` **HANYA worker** (fakta turunan).

**Event & integrasi:**

| Event                   | Sumber               | Dampak                                                                            |
| ----------------------- | -------------------- | --------------------------------------------------------------------------------- |
| `pengaduan.dibuat`      | Pelaporan            | Notifikasi WA penanggung jawab, `idm_skor_cache` (pelayanan), `dashboard_agregat` |
| `pengaduan.kedaruratan` | Kategori Kedaruratan | Eskalasi WA segera Tim Siaga Bencana & Ambulance Desa                             |
| `pengaduan.ditugaskan`  | Triage               | Penanganan oleh BKD/Bhabinkamtibmas/Babinsa/Posbankum                             |
| `pengaduan.selesai`     | Penyelesaian         | Notifikasi WA pelapor, `dashboard_agregat`, ulasan                                |
| `call_center.terbit`    | Direktori            | Publikasi nomor di Portal & Sistem Informasi                                      |

## 3. Tabel Jenis Service Center Desa (OpenSID + Aduan Masyarakat)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)         | Ekuivalen (OpenSID/Ref)    | Kolom inti                                                                                                                                                                                                                                                                                                                           | Referensi FK                                                              |
| ---------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------- |
| `pengaduan_desa`       | `tweb_pengaduan` / Profile | `id`, `tenant_id`, `penduduk_id`→`penduduk.id`, `kategori_id`→`pengaduan_kategori.id`, `subjek`, `isi`, `lokasi`, `bukti_path` (nullable), `prioritas` (`rendah`/`sedang`/`tinggi`/`kritis`), `status` (`baru`/`proses`/`selesai`), `tanggal`, `tgl_selesai` (nullable)                                                              | `penduduk_id`→`penduduk.id`; `kategori_id`→`pengaduan_kategori.id`        |
| `pengaduan_kategori`   | Kategori Aduan             | `id`, `tenant_id`, `kode` (UQ), `nama` (POSBANKU/INFRASTRUKTUR/KAMTIBMAS/KEDARURATAN/ULASAN_PELAYANAN), `akses_role` (`publik`/`bhabinkamtibmas_babinsa`), `is_darurat` (bool), `prioritas_default`, `deskripsi`, `aktif`                                                                                                            | `tenant_id`→`tenants.id`                                                  |
| `pengaduan_penanganan` | Penugasan & Eskalasi       | `id`, `tenant_id`, `pengaduan_id`→`pengaduan_desa.id`, `kategori_id`→`pengaduan_kategori.id`, `ditugaskan_ke` (`admin_desa`/`bkd`/`bhabinkamtibmas`/`babinsa`/`posbankum`/`tim_siaga_bencana`/`ambulance_desa`), `penanggung_jawab`, `tindakan`, `status` (`ditugaskan`/`diproses`/`selesai`), `tgl_tugas`, `tgl_selesai` (nullable) | `pengaduan_id`→`pengaduan_desa.id`; `kategori_id`→`pengaduan_kategori.id` |
| `call_center_desa`     | Direktori Layanan Darurat  | `id`, `tenant_id`, `nama_layanan` (Admin Desa/BKD/Bhabinkamtibmas/Babinsa/Posbankum/Tim Siaga Bencana/Ambulance Desa), `nomor_telepon`, `penanggung_jawab`, `lembaga` (nullable), `pamong_id`→`desa_pamong.id` (nullable), `jam_layanan`, `aktif`                                                                                    | `tenant_id`→`tenants.id`; `pamong_id`→`desa_pamong.id`                    |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen           | Kolom inti                                                                                                                                                          | Referensi FK                                                  |
| --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `domain_events`       | Event Bus           | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                                       | `tenant_id`→`tenants.id`                                      |
| `penduduk`            | Core Registry       | `id`, `nik`, `nama`, `status_dasar` (pelapor)                                                                                                                       | `tenant_id`→`tenants.id`                                      |
| `desa_pamong`         | Sistem Profile_Desa | `id`, `tenant_id`, `penduduk_id`, `jabatan_id`, `nik`, `nama_lengkap`, `status` (`aktif`/`nonaktif`)                                                                | `penduduk_id`→`penduduk.id`; `jabatan_id`→`jabatan_pamong.id` |
| `wilayah_batas`       | Wilayah             | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom`, `parent_id`                                                                                         | `parent_id`→`wilayah_batas.id` (self)                         |
| `dashboard_agregat`   | Info Grafis IDM     | `id`, `tenant_id`, `wilayah_id`→`wilayah_batas.id`, `kategori` (`pelayanan`), `metrik_key`, `metrik_value`, `periode`                                               | `tenant_id`→`tenants.id`; `wilayah_id`→`wilayah_batas.id`     |
| `site_content_blocks` | CMS Section         | `id`, `tenant_id`, `halaman`, `tipe_blok` (`statistik`/`layanan`/`peta`), `urutan`, `konten` (JSONB), `status`                                                      | `tenant_id`→`tenants.id`                                      |
| `feature_flags`       | Toggle Modul        | `id`, `tenant_id`, `flag_key`, `enabled`                                                                                                                            | `tenant_id`→`tenants.id`                                      |
| `i18n_strings`        | Teks UI             | `id`, `tenant_id`, `locale`, `key`, `value`                                                                                                                         | `tenant_id`→`tenants.id`                                      |
| `tenant_theme_config` | Tema                | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                                                                   | `tenant_id`→`tenants.id`                                      |
| `site_settings`       | Identitas           | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`                                                           | `tenant_id`→`tenants.id`                                      |
| `service_center_log`  | Log Audit           | `id`, `tenant_id`, `entity` (`pengaduan_desa`/`pengaduan_penanganan`/`call_center_desa`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`                                      |

### 3.3 Diagram integrasi

```
penduduk (Core Registry, NIK) ──► pengaduan_desa (kategori, prioritas, status)
                                    │        ├─► pengaduan_kategori (POSBANKU/INFRA/KAMTIBMAS/KEDARURATAN/ULASAN)
                                    │        │       ├─ Kamtibmas → akses Bhabinkamtibmas/Babinsa (RBAC)
                                    │        │       └─ Kedaruratan → prioritas wajib kritis
                                    │        ├─► pengaduan_penanganan (ditugaskan_ke: BKD/Bhabin/Babinsa/Posbankum/TimSiaga/Ambulance)
                                    │        │       (append-only, status ter-tracking)
                                    │        ▼
                                    │  call_center_desa (direktori nomor: Admin/BKD/Bhabin/Babinsa/Posbankum/TimSiaga/Ambulance)
                                    │        │
                                    │        ▼
                                    │  domain_events: pengaduan.dibuat / .kedaruratan / .selesai
                                    │        │ worker
                                    │        ├─► idm_skor_cache (pelayanan publik)
                                    │        ├─► dashboard_agregat (aduan per kategori/dusun)
                                    │        ├─► notifikasi WA (Fonnte): pelapor & penanggung jawab
                                    │        ▼
                                    ▼  Sistem Informasi (pengumuman call center) · Administrasi_Umum (register aduan) · Surat tanggapan
```

**Keterangan integrasi:** `pengaduan_desa` menjembatani ke `penduduk` (Core Registry) tanpa duplikasi identitas pelapor; `pengaduan_kategori` mengelompokkan 5 jenis aduan dengan aturan akses (Kamtibmas → Bhabinkamtibmas/Babinsa; Kedaruratan → wajib prioritas kritis). `pengaduan_penanganan` menugaskan & melacak penanganan secara append-only ke penanggung jawab (admin desa/BKD/Bhabinkamtibmas/Babinsa/Posbankum/Tim Siaga Bencana/Ambulance Desa) yang terdaftar di `call_center_desa`. Event `pengaduan.*` menyuplai `idm_skor_cache` (indikator pelayanan publik), `dashboard_agregat`, dan notifikasi WA (Fonnte) ke pelapor & penanggung jawab; Sistem Informasi mempublikasikan direktori call center, Administrasi_Umum meregister aduan, dan Surat tanggapan auto-fill dari data ini. Seluruh tampilan dibentuk `site*\*`+`i18n_strings` (zero hardcode).
