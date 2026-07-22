# Sistem Administrasi Umum Desa

Sistem Administrasi Umum Desa mengelola **Buku Administrasi Umum (BAU)** per Permendagri 47/2016 dan sistem pencatatan registrasi terpadu. Diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven) merujuk OpenSID (`tweb_surat_masuk`/`keluar`, `tweb_inventaris_*`, `tweb_dokumen`, `tweb_wil_clusterdesa`). Kunci: **satu register buku → terintegrasi ke fakta domain** (tidak dual-entry).

## 1. Ringkasan Sistem Administrasi_Umum (On Point)

- **Peran:** `buku_administrasi` (katalog 9 buku BAU) + `register_buku` (entri bernomor) = _Single Source of Truth_ administrasi umum.
- **Kanal:** Web admin (sekretariat desa) catat & verifikasi; read-only untuk perangkat lain & audit.
- **Buku BAU:** Agenda, Ekspedisi, Inventaris, Tanah Kas Desa, Tanah Desa, Peraturan di Desa, Keputusan Kades, Laporan, Administrasi Kependudukan.
- **Registrasi:** Setiap entri bernomor urut + tanggal; `ref_id` mengaitkan ke entitas domain (surat, aset, tanah, produk hukum, penduduk) → integrasi nyata.
- **Keamanan:** Append-only (`log_administrasi`); nomor urut auto (tidak loncat); RBAC (sekretariat CRUD, lainnya read-only).

## 2. Workflow lengkap sistem Administrasi_Umum Komplit

```
[Admin/Sekretariat] Pilih Buku dari katalog (buku_administrasi)
        │
        ▼
1. Buku Agenda — catat Surat Masuk / Keluar
        │  → surat_masuk / surat_keluar (no_agenda auto)
        │  → surat keluar terkait surat_pengajuan (TTE selesai) auto-register
        ▼
2. Buku Ekspedisi — catat pengiriman surat keluar
        │  → ekspedisi_surat (cara_kirim, tgl kirim, penerima)
        ▼
3. Buku Inventaris Desa (BID) — catat barang/aset desa + KIB per item
        │  → inventaris_desa (No. Urut, Kode Barang, Nama, Jenis, Jumlah, Satuan, Kondisi, Lokasi, Asal Perolehan, Harga)
        │  → kib (Kartu Inventaris Barang: register, merk, ukuran, bahan, no. mesin/polisi, kondisi)
        │  → auto-sync dari aset_desa (F8) bila sumber APBDes
        ▼
4. Buku Tanah Kas Desa / Tanah Desa — catat persil
        │  → tanah_kas_desa / tanah_desa (auto-sync dari bidang_tanah)
        ▼
5. Buku Peraturan & Keputusan Kades — catat produk hukum
        │  → produk_hukum (auto-sync dari Sistem Informasi saat publish)
        ▼
6. Buku Laporan — catat laporan kades ke camat
        │  → laporan_desa (auto-sync dari laporan_realisasi / IDM)
        ▼
7. Buku Administrasi Kependudukan — register mutasi
        │  → register_penduduk (auto-sync dari log_penduduk)
        ▼
Semua entri → register_buku (no_urut, tanggal, isi JSONB, ref_id)
        │
        ▼
log_administrasi (append-only) · domain_events → dashboard administrasi
```

**Aturan kritikal:**

- `register_buku.no_urut` **auto-generate** per buku (tidak boleh input manual — cegah loncat/duplikat).
- `ref_id` wajib diisi bila entri bersumber dari modul lain (surat/aset/tanah/hukum/penduduk) → integrasi, bukan catat ulang.
- Entri dari modul lain (surat TTE selesai, aset dari belanja modal, tanah dari F7, produk hukum publish, mutasi penduduk) **otomatis** masuk register buku terkait via event — sekretariat tinggal verifikasi.
- Buku bersifat append-only; koreksi = entri pembatalan (berlaku_sampai), bukan edit.

**Event & integrasi:**

| Event                     | Sumber                | Dampak ke BAU                                  |
| ------------------------- | --------------------- | ---------------------------------------------- |
| `surat.diterbitkan`       | Modul Surat           | Auto-register Buku Agenda (keluar) + Ekspedisi |
| `aset.aktif`              | Modul Keuangan (F8)   | Auto-register Buku Inventaris                  |
| `bidang_tanah.dialihkan`  | Modul Pertanahan (F7) | Auto-register Buku Tanah Kas/Desa              |
| `produk_hukum.terbit`     | Sistem Informasi      | Auto-register Buku Peraturan/Keputusan         |
| `penduduk.status.berubah` | Modul Penduduk        | Auto-register Buku Adm Kependudukan            |
| `laporan.dibuat`          | Modul Keuangan        | Auto-register Buku Laporan                     |

## 3. Tabel Jenis Administrasi_Umum (OpenSID + Sistem Adm Desa)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)      | Ekuivalen OpenSID / BAU   | Kolom inti                                                                                                                                                                                                                         | Referensi FK                                                                                                                             |
| ------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `buku_administrasi` | Katalog BAU               | `id`, `tenant_id`, `kode_buku`, `nama_buku` (Agenda, Ekspedisi, Inventaris, Tanah Kas Desa, Tanah Desa, Peraturan, Keputusan Kades, Laporan, Adm Kependudukan), `kategori` (`umum`/`penduduk`/`keuangan`/`pembangunan`), `aktif`   | `tenant_id`→`tenants.id`                                                                                                                 |
| `register_buku`     | Entri Registrasi          | `id`, `tenant_id`, `buku_id`, `no_urut`, `tanggal`, `isi` (JSONB, field per buku), `ref_id` (FK opsional ke entitas), `ref_tabel`, `dicatat_oleh`                                                                                  | `buku_id`→`buku_administrasi.id`                                                                                                         |
| `surat_masuk`       | `tweb_surat_masuk`        | `id`, `tenant_id`, `no_agenda`, `tanggal_terima`, `pengirim`, `perihal`, `disposisi`, `file_path`                                                                                                                                  | `tenant_id`→`tenants.id`                                                                                                                 |
| `surat_keluar`      | `tweb_surat_keluar`       | `id`, `tenant_id`, `no_agenda`, `tanggal`, `tujuan`, `perihal`, `no_surat`, `surat_pengajuan_id` (nullable), `file_path`                                                                                                           | `surat_pengajuan_id`→`surat_pengajuan.id`                                                                                                |
| `ekspedisi_surat`   | Buku Ekspedisi            | `id`, `tenant_id`, `surat_keluar_id`, `tgl_kirim`, `cara_kirim`, `penerima`, `keterangan`                                                                                                                                          | `surat_keluar_id`→`surat_keluar.id`                                                                                                      |
| `inventaris_desa`   | `tweb_inventaris_*` (BID) | `id`, `tenant_id`, `no_urut`, `kode_barang`, `nama_barang`, `jenis_id` (kelompok), `jumlah`, `satuan`, `kondisi` (B/RB), `lokasi`, `asal_perolehan`, `harga_perolehan`, `tahun_perolehan`, `keterangan`, `aset_desa_id` (nullable) | `jenis_id`→`jenis_inventaris.id`; `kondisi`→`kondisi_inventaris.id`; `asal_perolehan`→`asal_perolehan.id`; `aset_desa_id`→`aset_desa.id` |
| `kib`               | Kartu Inventaris Barang   | `id`, `tenant_id`, `inventaris_id`, `no_kib`, `register`, `merk`, `ukuran`, `bahan`, `tahun_pembuatan`, `no_pabrik`, `no_rangka`, `no_mesin`, `no_polisi`, `no_bpkb`, `kondisi` (B/RB), `keterangan`                               | `inventaris_id`→`inventaris_desa.id`; `kondisi`→`kondisi_inventaris.id`                                                                  |
| `tanah_kas_desa`    | Buku Tanah Kas Desa       | `id`, `tenant_id`, `no_persil`, `luas_m2`, `lokasi`, `peruntukan`, `bidang_tanah_id`                                                                                                                                               | `bidang_tanah_id`→`bidang_tanah.id` (jenis=tanah_kas_desa)                                                                               |
| `tanah_desa`        | Buku Tanah Desa           | `id`, `tenant_id`, `no_persil`, `luas_m2`, `lokasi`, `peruntukan`, `bidang_tanah_id`                                                                                                                                               | `bidang_tanah_id`→`bidang_tanah.id`                                                                                                      |
| `produk_hukum`      | `tweb_dokumen`            | `id`, `tenant_id`, `jenis_id`, `nomor`, `tahun`, `tentang`, `sumber`, `preview_path`, `file_path`, `status`                                                                                                                        | `jenis_id`→`kategori_produk_hukum.id`                                                                                                    |
| `laporan_desa`      | Buku Laporan              | `id`, `tenant_id`, `jenis_laporan`, `periode`, `tanggal`, `file_path`, `status`                                                                                                                                                    | `tenant_id`→`tenants.id`                                                                                                                 |
| `register_penduduk` | Buku Adm Kependudukan     | `id`, `tenant_id`, `penduduk_id`, `kode_peristiwa`, `tanggal`, `keterangan`, `log_penduduk_id`                                                                                                                                     | `penduduk_id`→`penduduk.id`; `log_penduduk_id`→`log_penduduk.id`                                                                         |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)       | Ekuivalen BAU    | Kolom inti                                                                                              | Referensi FK                                               |
| -------------------- | ---------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `kategori_buku`      | Kelompok Buku    | `id`, `kode`, `nama` (`umum`/`penduduk`/`keuangan`/`pembangunan`), `urutan`                             | lookup                                                     |
| `jenis_inventaris`   | Jenis Barang     | `id`, `kode`, `nama` (tanah, bangunan, kendaraan, peralatan, dll), `urutan`                             | lookup                                                     |
| `kondisi_inventaris` | Kondisi Barang   | `id`, `kode`, `nama` (B = Baik, RB = Rusak Berat), `urutan`                                             | lookup                                                     |
| `asal_perolehan`     | Asal Perolehan   | `id`, `kode`, `nama` (beli, hibah, sumbangan, lainnya), `urutan`                                        | lookup                                                     |
| `disposisi_surat`    | Status Disposisi | `id`, `kode`, `nama` (diteruskan, ditindaklanjuti, diarsipkan, dll)                                     | lookup                                                     |
| `log_administrasi`   | Log Audit        | `id`, `tenant_id`, `buku_id`, `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`; `buku_id`→`buku_administrasi.id` |
| `domain_events`      | Event Bus        | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`           | `tenant_id`→`tenants.id`                                   |

### 3.3 Diagram integrasi

```
buku_administrasi (katalog 9 BAU) ──► register_buku (no_urut, isi JSONB, ref_id)
        │                                      │
        │  auto-register via event            ├─ surat_masuk / surat_keluar ──► ekspedisi_surat
        │                                      ├─ inventaris_desa (BID) ◄── aset_desa (F8)
        │                                      │      └─ kib (Kartu Inventaris Barang per item)
        │                                      ├─ tanah_kas_desa / tanah_desa ◄── bidang_tanah (F7)
        │                                      ├─ produk_hukum ◄── Sistem Informasi
        │                                      ├─ laporan_desa ◄── laporan_realisasi (Keuangan)
        │                                      └─ register_penduduk ◄── log_penduduk (Penduduk)
        │
        ▼
log_administrasi (append-only) · domain_events ──► Dashboard Administrasi
```

**Keterangan integrasi:** `buku_administrasi` mendefinisikan 9 buku BAU; `register_buku` mencatat entri bernomor dengan `ref_id` ke fakta domain sehingga tidak ada dual-entry. Surat (F1), Aset (F8), Tanah (F7), Produk Hukum (Informasi), Laporan (Keuangan), dan Mutasi Penduduk (F0) **otomatis** mengisi buku terkait via `domain_events` — sekretariat cukup verifikasi, bukan input ulang. Audit penuh di `log_administrasi`.

### 3.4 Buku Inventaris Desa (BID + KIB)

Buku Inventaris Desa (BID) merujuk Permendagri 47/2016 & OpenSID (`tweb_inventaris_*`). Terdiri dari **register BID** (`inventaris_desa`) + **Kartu Inventaris Barang (KIB)** (`kib`) per item.

**A. Kolom BID (`inventaris_desa`):**

| No  | Kolom             | Keterangan                                                                                                                     |
| --- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 1   | `no_urut`         | Nomor urut (auto per buku)                                                                                                     |
| 2   | `kode_barang`     | Kode barang (standar aset)                                                                                                     |
| 3   | `nama_barang`     | Nama/jenis barang                                                                                                              |
| 4   | `jenis_id`        | Kelompok: Tanah, Gedung & Bangunan, Peralatan & Mesin, Jalan/Irigasi/Jaringan, Aset Tetap Lainnya, Konstruksi Dalam Pengerjaan |
| 5   | `jumlah`          | Jumlah                                                                                                                         |
| 6   | `satuan`          | Satuan (unit, buah, m, dll)                                                                                                    |
| 7   | `kondisi`         | B (Baik) / RB (Rusak Berat) — `kondisi_inventaris`                                                                             |
| 8   | `lokasi`          | Letak barang di desa                                                                                                           |
| 9   | `asal_perolehan`  | Beli / Hibah / Sumbangan / Lainnya — `asal_perolehan`                                                                          |
| 10  | `harga_perolehan` | Nilai perolehan (Rp)                                                                                                           |
| 11  | `tahun_perolehan` | Tahun beli/perolehan                                                                                                           |
| 12  | `keterangan`      | Catatan tambahan                                                                                                               |

**B. KIB (`kib`) — kartu detail per item:** `no_kib`, `register`, `merk`, `ukuran`, `bahan`, `tahun_pembuatan`, `no_pabrik`, `no_rangka`, `no_mesin`, `no_polisi`, `no_bpkb`, `kondisi`, `keterangan` (FK `inventaris_id`→`inventaris_desa.id`).

**C. Integrasi:**

- `inventaris_desa.aset_desa_id` → `aset_desa` (Sistem Keuangan F8): belanja modal APBDes otomatis jadi entri BID via event `aset.aktif` (tidak dual-entry).
- `jenis_id` → `jenis_inventaris`, `kondisi` → `kondisi_inventaris`, `asal_perolehan` → `asal_perolehan` (lookup).
- Entri BID otomatis masuk `register_buku` (buku "Inventaris") dengan `ref_id` → `inventaris_desa.id`.
