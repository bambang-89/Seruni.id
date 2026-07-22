# Sistem Penduduk Desa (Core Registry)

## 1. Ringkasan Sistem Penduduk (On Point)

- **Peran:** `penduduk` = _Single Source of Truth_ (Core Registry) untuk 10+ modul (surat, PBB, voting, posyandu, IDM, dll).
- **Kanal:** Web admin (perangkat desa) + Web/WA warga (ajukan perubahan & cek data).
- **Inti:** Data warga diinput by **NIK** (unik); mutasi & perubahan tercatat via `log_penduduk` (append-only); semua perubahan picu `domain_events` → sinkron ke modul lain.
- **Status dasar:** HIDUP · MATI · PINDAH · HILANG · PERGI · TIDAK VALID (atur eligibilitas surat/voting).
- **Keamanan:** `UNIQUE(tenant_id, nik)`; audit trail `penduduk_log`; RBAC (admin CRUD, kader read-only dusun, warga read-only record sendiri).
- **Referensi:** Sesuai OpenSID (`tweb_penduduk` + tabel pendukung), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`); tabel di bawah memakai nama Seruni - Sistem Repository Unifikasi Informasi dengan ekuivalen OpenSID.

## 2. Workflow Lengkap Pelayanan Penduduk Online

### A. Alur Umum (Admin & Warga)

```
[Admin/Perangkat] 1. Input/Impor penduduk (NIK unik)  ── atau
[Warga: Web/WA]   1. Ajukan perubahan data / mutasi
   │
   ▼
2. Validasi: NIK valid, no_kk terdaftar di keluarga,
   rt/rw/dusun cocok wilayah_batas
   │
   ▼
3. [Admin] Verifikasi (tolak/terima)
   ├── TOLAK ──► + alasan ──► WA ke pemohon ──► SELESAI
   │
   └── TERIMA ──► UPDATE penduduk  ──► event: penduduk.data.berubah
                      │
                      ▼
4. Jika status berubah (mati/pindah/hilang) ──► event: penduduk.status.berubah
   │
   ▼
5. Catat ke log_penduduk (kode_peristiwa) + penduduk_log (audit)
   │
   ▼
6. Worker propagasi sync ke: wajib_pajak, balita, usulan_votes,
   idm_status_desa, surat (eligibilitas)  ──► SELESAI
```

### B. Mutasi / Peristiwa (kode_peristiwa di `log_penduduk`)

| Kode | Peristiwa             | Dampak Status Dasar          | Tindakan                           |
| ---- | --------------------- | ---------------------------- | ---------------------------------- |
| 1    | Lahir                 | (tambah anggota baru, HIDUP) | Insert penduduk + link ke KK ortu  |
| 2    | Mati                  | → MATI                       | Set status_dasar, isi tgl & sebab  |
| 3    | Pindah Keluar         | → PINDAH                     | Set status, catat alamat tujuan    |
| 4    | Pindah Masuk / Datang | → HIDUP                      | Insert/aktifkan, link KK & cluster |
| 6    | Hilang                | → HILANG                     | Set status, catat tgl & lokasi     |
| 7    | Kembali               | → HIDUP                      | Aktifkan kembali                   |
| 5    | Hamil                 | (flag kesehatan)             | Link ke modul posyandu             |
| 9    | Perubahan Status Lain | sesuaikan                    | Edit field terkait                 |

### C. Perubahan Data & Verifikasi

- Field identitas (`nama`, `alamat`, `dusun/rt/rw`, `nik`) **tidak cascade otomatis** ke tabel lain — sinkron via event `penduduk.data.berubah` (mis. `wajib_pajak.nama`, `balita.orang_tua_*`).
- Perubahan kritis (NIK, status) wajib verifikasi admin + OTP (untuk warga).
- Semua UPDATE → `penduduk_log` (field_lama, field_baru, aktor_id, timestamp).

### D. Aturan Kritikal

- **NIK unik** per `tenant_id`; duplikat ditolak (cegah data ganda di surat/PBB/voting).
- **Status dasar** mengontrol eligibilitas: MATI/PINDAH/HILANG/PERGI/TIDAK VALID → tidak bisa ajukan surat atau voting.
- **id_cluster** wajib valid (ada di `wilayah_batas`) — dasar agregat dusun & IDM.
- **no_kk** wajib terdaftar di `keluarga` (kecuali pendatang proses).

### E. Event & Integrasi

| Event                     | Dipicu Saat                | Propagasi Ke                                                |
| ------------------------- | -------------------------- | ----------------------------------------------------------- |
| `penduduk.data.berubah`   | Edit nama/alamat/rt-rw/hp  | `wajib_pajak`, `balita`, WA bot session                     |
| `penduduk.status.berubah` | Mati/pindah/hilang/kembali | IDM populasi, eligibilitas surat & voting, posyandu agregat |
| `penduduk.bpjs.berubah`   | Edit status BPJS           | IDM indikator kesehatan                                     |

## 3. Tabel Jenis Penduduk (Induk & Pendukung, Terintegrasi)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)  | Ekuivalen OpenSID      | Kolom inti                                                                                                                                                                                                                                                                                                                                                                                                         | Referensi FK                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `penduduk`      | `tweb_penduduk`        | `id`, `nik` (UNIQUE), `nama`, `no_kk`, `id_kk`, `kk_level`, `sex`, `tempatlahir`, `tanggallahir`, `agama_id`, `pendidikan_id`, `pendidikan_sedang_id`, `pekerjaan_id`, `status_kawin`, `warganegara_id`, `golongan_darah_id`, `status_dasar`, `cacat_id`, `cara_kb_id`, `id_cluster`, `alamat`, `dusun`, `rw`, `rt`, `telepon`, `email`, `status_ktp`, `nama_ayah`, `nama_ibu`, `dokumen_pasport`, `dokumen_kitas` | `id_kk`→`keluarga.id`; `kk_level`→`penduduk_hubungan.id`; `sex`→`penduduk_sex.id`; `agama_id`→`penduduk_agama.id`; `pendidikan_id`→`penduduk_pendidikan.id`; `pendidikan_sedang_id`→`penduduk_pendidikan_sedang.id`; `pekerjaan_id`→`penduduk_pekerjaan.id`; `status_kawin`→`penduduk_kawin.id`; `warganegara_id`→`penduduk_warganegara.id`; `golongan_darah_id`→`penduduk_golongan_darah.id`; `status_dasar`→`penduduk_status.id`; `cacat_id`→`penduduk_cacat.id`; `cara_kb_id`→`penduduk_kb.id`; `id_cluster`→`wilayah_batas.id` |
| `keluarga`      | `tweb_keluarga`        | `id`, `no_kk` (UNIQUE), `nik_kepala`, `alamat`, `dusun`, `rw`, `rt`, `id_cluster`, `tgl_daftar`                                                                                                                                                                                                                                                                                                                    | `nik_kepala`→`penduduk.nik`; `id_cluster`→`wilayah_batas.id`                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `wilayah_batas` | `tweb_wil_clusterdesa` | `id`, `tenant_id`, `jenis` (`dusun`/`rw`/`rt`), `nama`, `geom` (POLYGON), `parent_id`                                                                                                                                                                                                                                                                                                                              | `parent_id`→`wilayah_batas.id` (self)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |

### 3.2 Tabel Pendukung (Lookup / Log / Akun)

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)               | Ekuivalen OpenSID                 | Isi / Contoh                                                                                              | Di-referensi oleh (FK dari `penduduk`)     |
| ---------------------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `penduduk_hubungan`          | `tweb_penduduk_hubungan`          | Kepala Keluarga, Suami, Istri, Anak, Menantu, Cucu, Orang Tua, Mertua, Famili Lain                        | `kk_level`                                 |
| `penduduk_sex`               | `tweb_penduduk_sex`               | Laki-laki, Perempuan                                                                                      | `sex`                                      |
| `penduduk_agama`             | `tweb_penduduk_agama`             | Islam, Kristen, Katolik, Hindu, Buddha, Kong Hu Cu                                                        | `agama_id`                                 |
| `penduduk_pendidikan`        | `tweb_penduduk_pendidikan`        | Tidak/Belum Sekolah, SD, SMP, SMA, D1, D2, D3, D4, S1, S2, S3                                             | `pendidikan_id`                            |
| `penduduk_pendidikan_sedang` | `tweb_penduduk_pendidikan_sedang` | Sedang SD, Sedang SMP, Sedang SMA, Sedang Kuliah                                                          | `pendidikan_sedang_id`                     |
| `penduduk_pekerjaan`         | `tweb_penduduk_pekerjaan`         | Belum Bekerja, Mengurus RT, Pelajar, PNS, TNI, Polri, Petani, Pedagang, Wiraswasta, Buruh, Pensiunan, dll | `pekerjaan_id`                             |
| `penduduk_kawin`             | `tweb_penduduk_kawin`             | Belum Kawin, Kawin, Cerai Hidup, Cerai Mati                                                               | `status_kawin`                             |
| `penduduk_warganegara`       | `tweb_penduduk_warganegara`       | WNI, WNA                                                                                                  | `warganegara_id`                           |
| `penduduk_golongan_darah`    | `tweb_penduduk_golongan_darah`    | A, B, AB, O, Tidak Tahu, Tidak Mengisi                                                                    | `golongan_darah_id`                        |
| `penduduk_cacat`             | `tweb_penduduk_cacat`             | Cacat Fisik, Netra, Rungu, Mental, Fisik & Mental, Lainnya                                                | `cacat_id`                                 |
| `penduduk_kb`                | `tweb_penduduk_kb`                | IUD, Suntik, Pil, Kondom, MOW, MOP, Tradisional, Lainnya                                                  | `cara_kb_id`                               |
| `penduduk_status`            | `tweb_penduduk_status`            | Hidup, Mati, Pindah, Hilang, Pergi, Tidak Valid                                                           | `status_dasar`                             |
| `log_penduduk`               | `log_penduduk`                    | `id`, `id_pend`, `kode_peristiwa` (1–9), `tgl_peristiwa`, `ref_surat`, `catatan`                          | `id_pend`→`penduduk.id` (log mutasi/audit) |
| `penduduk_mandiri`           | `tweb_penduduk_mandiri`           | `id_pend`, `nama`, `nik`, `email`, `telepon`, `password`, `token`                                         | `id_pend`→`penduduk.id` (akun login warga) |
| `penduduk_map`               | `tweb_penduduk_map`               | `id`, `id_pend`, `lat`, `lng`                                                                             | `id_pend`→`penduduk.id` (koordinat)        |

### 3.3 Diagram integrasi

```
wilayah_batas (dusun/rw/rt)
        ▲ id_cluster
        │
keluarga (no_kk) ──nik_kepala──► penduduk (NIK, induk)
        ▲ id_kk                         │  semua field *id/*_id → tabel lookup (3.2)
        │ kk_level                      ▼
        └── anggota keluarga      log_penduduk (mutasi) · penduduk_mandiri (akun) · penduduk_map (koordinat)
```

> **Catatan:** `penduduk` adalah fakta mentah tunggal; seluruh modul (surat, PBB, voting, posyandu, IDM) **mereferensi**, bukan menduplikasi data warga.
