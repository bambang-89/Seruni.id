# Sistem Keuangan Desa

Sistem Keuangan Desa mengelola siklus perencanaan–penganggaran–realisasi mengikuti standar **SISKEUDES online** (Kemendagri) dan Permendagri 20/2018 (kode rekening). Alur: **RPJMDes → Usulan → RKPDes → Voting → APBDes → Laporan Realisasi**. Diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven, zero-hardcode input manual).

## 1. Ringkasan Sistem Keuangan (On Point)

- **Peran:** `apbdes` + `apbdes_realisasi` = _Single Source of Truth_ keuangan; RPJMDes/RKPDes adalah rencana sumber (bukan fakta final).
- **Kanal:** Web admin (perangkat desa/bendahara) input & verifikasi; Warga ajukan Usulan & Voting via Web/WA; Publik lihat transparansi & laporan.
- **Struktur anggaran:** Berjenjang **Bidang → Sub-Bidang → Kegiatan → Rekening Anggaran** (Permendagri 20/2018) — semua pilihan dari lookup, bukan ketik bebas.
- **Sumber dana:** ADD, Dana Desa, PADes, Bagi Hasil Pajak/Retribusi, Bantuan Prov/Kab, Lainnya.
- **Realisasi:** Dicatat per `kegiatan_desa` → `apbdes_realisasi` (jenis belanja); Laporan Fisik & Keuangan dipecah per Bulan/Semester/Tahun/Sumber Dana.
- **Keamanan:** Append-only (`keuangan_log`); belanja modal otomatis draft `aset_desa`; ekspor SISKEUDES/SIPADES via `ekspor_kepatuhan` (wajib verifikasi admin).

## 2. Workflow lengkap sistem Keuangan Komplit

```
[Admin] Susun RPJMDes (6 thn) — visi, misi, bidang (Permendagri 20/2018)
        │  status: DRAFT → DISAHKAN (musyawarah)
        ▼
1. Warga ajukan USULAN (kategori Bidang/Sub-Bidang dari RPJMDes) via Web/WA
        │  → usulan_kegiatan (status: DIAJUKAN)
        │  → [Admin] verifikasi regulasi → LOLOS_VERIFIKASI / DITOLAK
        ▼
2. [Admin] Susun RKPDes (tahun depan) — gabung Usulan lolos + input admin
        │  → rkpdes (status: DRAFT)
        ▼
3. VOTING RKPDes — warga pilih prioritas (OTP WA, 1 NIK 1x per item)
        │  → usulan_votes → ranking real-time
        │  → [Musdes] tetapkan RKPDes → status: DISETUJUI / DITETAPKAN_RKPDES
        ▼
4. [Admin] Susun APBDes (tahun depan) — dari RKPDes + Voting + input admin
        │  (Pendapatan: pades_pendapatan; Belanja: rkpdes → kegiatan_desa)
        │  → apbdes (status: DRAFT → DISAHKAN)
        ▼
5. Realisasi — [Bendahara] catat apbdes_realisasi per kegiatan (jenis belanja)
        │  → jika belanja MODAL → worker INSERT aset_desa (draft, verifikasi)
        │  → keuangan_log (append-only)
        ▼
6. Laporan Realisasi Fisik & Keuangan — filter Bulan/Semester/Tahun/Sumber Dana
        │  → laporan_realisasi (materialized view di atas apbdes_realisasi)
        ▼
7. [Admin] Ekspor SISKEUDES/SIPADES → ekspor_kepatuhan (verifikasi → status: DIUNDUH)
```

**Aturan kritikal:**

- `usulan_kegiatan.kategori_bidang`/`kategori_sub_bidang` **wajib dari lookup** (`bidang_kegiatan`/`sub_bidang`), bukan teks bebas.
- Voting: `UNIQUE(usulan_id, nik)` — 1 NIK 1x per item, OTP WA ke `penduduk.nomor_hp`; ranking hanya bahan pertimbangan Musdes (bukan keputusan final).
- `apbdes_realisasi` tidak diinput ganda — belanja modal otomatis draft `aset_desa` (F8), cegah data anggaran vs aset tidak sinkron.
- Laporan dihitung ulang dari `apbdes_realisasi` (fakta), bukan diisi manual.
- Ekspor SISKEUDES wajib verifikasi admin sebelum status `diunduh`.

**Event & integrasi:**

| Event                      | Sumber        | Dampak                                                                          |
| -------------------------- | ------------- | ------------------------------------------------------------------------------- |
| `usulan.vote.bertambah`    | Voting RKPDes | Ranking RKPDes real-time                                                        |
| `musdes.usulan.ditetapkan` | Musdes        | Skor IDM 46, draft APBDes                                                       |
| `apbdes.realisasi.dicatat` | Realisasi     | Skor IDM tata kelola keuangan; jika `jenis_belanja='modal'` → draft `aset_desa` |
| `pbb.tagihan.dibayar`      | Modul PBB     | `pades_pendapatan` (PADes)                                                      |
| `keuangan.laporan.dibuat`  | Laporan       | Transparansi beranda, ekspor SISKEUDES                                          |

## 3. Tabel Jenis Keuangan (SISKEUDES + Seruni - Sistem Repository Unifikasi Informasi)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)      | Ekuivalen SISKEUDES        | Kolom inti                                                                                                                                                                                                                                       | Referensi FK                                                                                                                              |
| ------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `rpjmdes`           | RPJMDes (6 thn)            | `id`, `tenant_id`, `tahun_awal`, `tahun_akhir`, `visi`, `misi[]`, `status` (`draft`/`disahkan`)                                                                                                                                                  | `tenant_id`→`tenants.id`                                                                                                                  |
| `usulan_kegiatan`   | Usulan (Musrenbang)        | `id`, `tenant_id`, `pengusul_penduduk_id`, `judul`, `deskripsi`, `kategori_bidang`, `kategori_sub_bidang`, `lokasi`, `estimasi_manfaat`, `status` (`diajukan`/`lolos_verifikasi`/`ditolak`/`ditetapkan_rkpdes`), `kode_rekening_saran`, `sumber` | `pengusul_penduduk_id`→`penduduk.id`; `kategori_bidang`→`bidang_kegiatan.nama`                                                            |
| `rkpdes`            | RKPDes                     | `id`, `tenant_id`, `tahun_anggaran`, `usulan_id` (nullable), `kegiatan`, `bidang_id`, `sub_bidang_id`, `rekening_id`, `sumber_dana`, `pagu`, `lokasi`, `status` (`draft`/`disetujui`/`ditetapkan`)                                               | `usulan_id`→`usulan_kegiatan.id`; `bidang_id`→`bidang_kegiatan.id`; `sub_bidang_id`→`sub_bidang.id`; `rekening_id`→`rekening_anggaran.id` |
| `usulan_votes`      | Voting Prioritas           | `id`, `usulan_id`, `nik`, `voted_at`, `UNIQUE(usulan_id, nik)`                                                                                                                                                                                   | `usulan_id`→`usulan_kegiatan.id`                                                                                                          |
| `apbdes`            | APBDes                     | `id`, `tenant_id`, `tahun_anggaran`, `rkpdes_id`, `total_pendapatan`, `total_belanja`, `status` (`draft`/`disahkan`)                                                                                                                             | `rkpdes_id`→`rkpdes.id`                                                                                                                   |
| `kegiatan_desa`     | Kegiatan (RAB)             | `id`, `tenant_id`, `nama_kegiatan`, `bidang_kegiatan_id`, `sumber_dana`, `tahun_anggaran`                                                                                                                                                        | `bidang_kegiatan_id`→`bidang_kegiatan.id`                                                                                                 |
| `apbdes_realisasi`  | Realisasi/SPJ              | `id`, `tenant_id`, `kegiatan_desa_id`, `jenis_belanja` (`operasional`/`modal`/`tak_terduga`/`transfer`), `keterangan`, `dicatat_oleh`, `created_at`                                                                                              | `kegiatan_desa_id`→`kegiatan_desa.id`                                                                                                     |
| `laporan_realisasi` | LRA (Fisik & Keuangan)     | `id`, `tenant_id`, `periode` (`bulan`/`semester`/`tahun`), `periode_nilai`, `sumber_dana`, `fisik_persen`, `keuangan_persen`, `serapan`                                                                                                          | `tenant_id`→`tenants.id`                                                                                                                  |
| `bidang_kegiatan`   | Bidang (1–5)               | `id`, `kode` (UQ), `nama` (5 bidang Permendagri 20/2018)                                                                                                                                                                                         | lookup                                                                                                                                    |
| `sub_bidang`        | Sub Bidang                 | `id`, `bidang_kegiatan_id`, `kode`, `nama`                                                                                                                                                                                                       | `bidang_kegiatan_id`→`bidang_kegiatan.id`                                                                                                 |
| `rekening_anggaran` | Rekening                   | `id`, `sub_bidang_id`, `kode_rekening` (UQ), `nama`                                                                                                                                                                                              | `sub_bidang_id`→`sub_bidang.id`                                                                                                           |
| `pades_pendapatan`  | Pendapatan Desa (dari PBB) | `id`, `tenant_id`, `tahun`, `sumber` (`pbb`/`retribusi`/`lainnya`), `nilai`, `pbb_tagihan_id` (nullable)                                                                                                                                         | `tenant_id`→`tenants.id`; `pbb_tagihan_id`→`pbb_tagihan.id`                                                                               |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)                   | Ekuivalen SISKEUDES | Kolom inti                                                                                                                                              | Referensi FK                                |
| -------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `sumber_dana`                    | Sumber Dana         | `id`, `kode`, `nama` (ADD, Dana Desa, PADes, BHPR, BHP, BKK, Lainnya), `urutan`                                                                         | lookup                                      |
| `jenis_belanja`                  | Jenis Belanja       | `id`, `kode`, `nama` (`operasional`/`modal`/`tak_terduga`/`transfer`)                                                                                   | lookup                                      |
| `periode_laporan`                | Periode             | `id`, `kode`, `nama` (`bulan`/`semester`/`tahun`)                                                                                                       | lookup                                      |
| `usulan_kegiatan_draft_otomatis` | Draft IDM           | `id`, `tenant_id`, `kategori`, `sumber_pemicu`, `sumber_ref_id`, `kode_rekening_saran`, `status` (`menunggu_review`/`diadopsi`/`diabaikan`)             | `tenant_id`→`tenants.id`                    |
| `aset_desa`                      | Aset (F8)           | `id`, `tenant_id`, `nama_aset`, `kategori`, `bidang_tanah_id`, `nilai_perolehan`, `sumber_perolehan`, `apbdes_realisasi_id`, `status` (`draft`/`aktif`) | `apbdes_realisasi_id`→`apbdes_realisasi.id` |
| `ekspor_kepatuhan`               | Ekspor SISKEUDES    | `id`, `tenant_id`, `jenis` (`siskeudes`/`sipades`), `periode`, `file_path`, `status` (`draft`/`diunduh`), `dicatat_oleh`                                | `tenant_id`→`tenants.id`                    |
| `keuangan_log`                   | Log Audit           | `id`, `tenant_id`, `entity` (`apbdes`/`realisasi`/`usulan`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at`                  | `tenant_id`→`tenants.id`                    |
| `domain_events`                  | Event Bus           | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                                                           | `tenant_id`→`tenants.id`                    |

### 3.3 Diagram integrasi

```
rpjmdes (6 thn) ──► bidang_kegiatan → sub_bidang → rekening_anggaran
                        │
                        ▼
usulan_kegiatan (warga, by RPJMDes bidang)
        │  verifikasi
        ▼
rkpdes (tahun depan: usulan + admin) ──► usulan_votes (Voting, OTP WA)
        │  Musdes tetapkan
        ▼
apbdes (tahun depan) ──► kegiatan_desa (RAB)
        │
        ▼
apbdes_realisasi (jenis belanja) ──┬──► laporan_realisasi (Bulan/Smt/Thn/Sumber Dana)
        │                           └──► aset_desa (jika modal, draft)
        │
        ▼
pades_pendapatan (PBB) · ekspor_kepatuhan (SISKEUDES) · IDM scoring
```

**Keterangan integrasi:** RPJMDes mengunci pohon Bidang→Sub-Bidang→Rekening (Permendagri 20/2018) yang dipakai seluruh usulan & anggaran; Usulan → RKPDes → Voting → APBDes adalah pipeline satu arah berjenjang; Realisasi menurunkan ke Laporan (fisik & keuangan), Aset (belanja modal), PADes (PBB), dan Ekspor SISKEUDES — semua tanpa dual-entry manual berkat event propagation.
