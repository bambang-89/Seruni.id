# WORKFLOW SISTEM KESELURUHAN Seruni - Sistem Repository Unifikasi Informasi (KANTOR DESA VIRTUAL)

**Dokumen Integrasi Lintas-Modul — Single Source of Truth untuk arsitektur alur kerja**
Diturunkan dari `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md`, `PEDOMAN_MONOREPO_Seruni - Sistem Repository Unifikasi Informasi.md`, dan ke-24 dokumen `Sistem_*.md`. Jika ada perbedaan, `Seruni - Sistem Repository Unifikasi Informasi_MASTER_SPEC_FINAL.md` yang berlaku.

---

## 0. FILOSOFI & BACKBONE INTEGRASI

Prinsip tunggal Seruni - Sistem Repository Unifikasi Informasi: **"Satu Input, Banyak Dampak"**. Setiap fakta yang dicatat di satu modul **tidak** diduplikasi ke modul lain, melainkan **menyebar lewat Event Propagation Layer** yang menjadi tulang punggung (backbone) seluruh sistem.

```
                         ┌─────────────────────────────────────────────┐
                         │         EVENT PROPAGATION LAYER              │
   FAKTA MENTAH          │   domain_events (event_type, payload,        │
   (input manusia/       │   processed_at=NULL)                         │
    eksternal)           │        │                                     │
        │                │        ▼  BullMQ Worker (idempoten,          │
        └──────────────► │        ON CONFLICT DO UPDATE)                │
                         │        ├─► idm_skor_cache  (F3/IDM)          │
                         │        ├─► dashboard_agregat (Info Grafis)   │
                         │        ├─► notifikasi + outbox_pesan (F.Notif)│
                         │        ├─► peta_objek (F9/Pemetaan)          │
                         │        ├─► register_buku (F.Administrasi)    │
                         │        └─► sinkronisasi_job (F.Sinkronisasi) │
                         └─────────────────────────────────────────────┘
                                      │                    │
                                      ▼                    ▼
                         PORTAL PUBLIK (F.Informasi)   EKSTERNAL (OpenDK/Kemendagri/IDM)
```

**Tiga lapisan turunan (tidak pernah diinput manual):**

1. **Lapisan Skor** → `idm_skor_cache` + `idm_status_desa` (Kesimpulan akhir indeks desa).
2. **Lapisan Agregat** → `dashboard_agregat` (key-value granuler per `wilayah_id`: desa/dusun/RT-RW).
3. **Lapisan Presentasi** → `artikel_desa`/`agenda_kegiatan`/`galeri_desa` (F.Informasi), `peta_objek` (F9), `register_buku` (F.Administrasi_Umum), `outbox_pesan` (F.Notifikasi).

**Satu Core Registry:** `penduduk` (by NIK) adalah _Single Source of Truth_ identitas — 10+ modul mereferensi, tidak mengkopi identitas.

---

## 1. PETA 24 MODUL & PERANNYA

| #   | Modul (file)                     | Peran (Single Source of Truth)                                             | Kategori               | Turunan utama                              |
| --- | -------------------------------- | -------------------------------------------------------------------------- | ---------------------- | ------------------------------------------ |
| 1   | `Sistem_Penduduk.md`             | `penduduk` + `keluarga` + `log_penduduk`                                   | **Core Registry**      | Semua modul                                |
| 2   | `Sistem_Pengaturan_Desa.md`      | `pengguna` + `peran` + `modul` + `feature_flags`                           | **Fondasi/RBAC**       | Akses semua modul                          |
| 3   | `Sistem_Profile_Desa.md`         | `profil_desa` + `wilayah_batas` + `desa_pamong` + `lembaga_desa`           | **Fondasi/Identitas**  | Peta, TTE, IDM                             |
| 4   | `Sistem_Surat.md`                | `surat_jenis` + `surat_pengajuan` + `surat_dokumen`                        | Operasional            | Penduduk, Administrasi, IDM(45.b)          |
| 5   | `Sistem_Layanan_Mandiri_Desa.md` | `mandiri_sesi` + `mandiri_ajuan` + `mandiri_track`                         | Kanal Warga            | Surat, Aduan, Bansos                       |
| 6   | `Sistem_Keuangan.md`             | `apbdes` + `apbdes_realisasi` + `usulan_kegiatan`                          | Operasional            | Aset, IDM(46/47.a), PADes                  |
| 7   | `Sistem_PBB_Desa.md`             | `objek_pajak` + `wajib_pajak` + `pbb_tagihan`                              | Operasional            | Keuangan(PADes), IDM(22/47.a), Peta        |
| 8   | `Sistem_Pertanahan.md`           | `bidang_tanah` + `kepemilikan_bidang_tanah`                                | Fakta Spasial          | PBB, Aset, Peta, IDM(Lingkungan/Ekonomi)   |
| 9   | `Sistem_Pembangunan_Desa.md`     | `usulan_pembangunan` + `pembangunan` + `pembangunan_dokumentasi`           | Operasional            | Aset, IDM(Dimensi 1), Peta                 |
| 10  | `Sistem_Posyandu_Desa.md`        | `balita` + `ibu_hamil` + `posyandu_kunjungan`                              | Operasional            | Stunting, IDM(7.b), Surat                  |
| 11  | `Sistem_Stunting_Desa.md`        | `stunting_anak` + `stunting_intervensi` + `stunting_rekap`                 | Turunan Kesehatan      | Sosial(Bansos gizi), IDM                   |
| 12  | `Sistem_Sosial_Desa.md`          | `kpm` + `bansos_penerima` + `bpjs_peserta`                                 | Operasional            | IDM(Dimensi Sosial), Surat(465.x)          |
| 13  | `Sistem_bencana_Desa.md`         | `bencana_*` + `bencana_alert`                                              | Operasional+Eksternal  | Service Center, IDM, Peta                  |
| 14  | `Sistem_service_center_Desa.md`  | `pengaduan_desa` + `call_center_desa`                                      | Operasional            | IDM(Pelayanan), Surat, Administrasi        |
| 15  | `Sistem_Pemilu_Desa.md`          | `dpt` + `pemilihan` + `pemilihan_suara`                                    | Operasional            | IDM(Partisipasi), Informasi, Voting Musdes |
| 16  | `Sistem_Analisis_Desa.md`        | `analisis` + `analisis_respon` + `analisis_hasil`                          | Analitik               | IDM, Suplesi                               |
| 17  | `Sistem_Suplesi_Desa.md`         | `suplemen` + `suplemen_anggota` (JSONB)                                    | Fleksibel              | Analisis, Dashboard                        |
| 18  | `Sistem_Potensi_Desa.md`         | `bumdes` + `umkm` + `produk_marketplace` + `sektor_ekonomi` + `pariwisata` | Operasional+Ekonomi    | Peta, IDM(Ekonomi), Marketplace            |
| 19  | `Sistem_Administrasi_Umum.md`    | `buku_administrasi` + `register_buku` (9 BAU)                              | Presentasi/Register    | Audit, IDM                                 |
| 20  | `Sistem_Informasi.md`            | `artikel_desa` + `agenda_kegiatan` + `galeri_desa` + `produk_hukum`        | **Presentasi Akhir**   | Portal Publik                              |
| 21  | `Sistem_Pemetaan_Desa.md`        | `peta_layer` + `peta_objek` (F9)                                           | **Presentasi Spasial** | Portal Publik                              |
| 22  | `Sistem_Notifikasi_Desa.md`      | `notifikasi` + `outbox_pesan` + `otp_token`                                | **Channel Terpadu**    | Semua modul                                |
| 23  | `Sistem_Sinkronisasi_Desa.md`    | `sinkronisasi_job` + `sinkronisasi_mapping`                                | **Interoperabilitas**  | OpenDK/Kemendagri/IDM                      |
| 24  | `Sistem_IDM_Desa.md`             | `idm_status_desa` + `idm_skor_cache`                                       | **Kesimpulan Akhir**   | Dashboard Kades + Portal                   |

---

## 2. BACKBONE: EVENT PROPAGATION LAYER

### 2.1 Skema Event Bus

`domain_events(id, tenant_id, event_type, entity_id, payload JSONB, created_at, processed_at)`

- Setiap perubahan fakta mentah → `INSERT domain_events (processed_at = NULL)`.
- Worker (BullMQ) mengambil event belum diproses, menjalankan derivation rule, lalu `UPDATE domain_events SET processed_at = now()`.
- **Idempoten:** semua write turunan pakai `ON CONFLICT DO UPDATE`, bukan `INSERT` polos (retry aman).
- **Sizing bertahap:** MVP = 1 queue + job priority per dimensi; split ke 6 queue terpisah hanya bila lag terukur.

### 2.2 Enam Jalur Turunan (Fan-out)

| Jalur        | Tabel tujuan                        | Pemicu                                         | Konsumen                             |
| ------------ | ----------------------------------- | ---------------------------------------------- | ------------------------------------ |
| Skor IDM     | `idm_skor_cache`, `idm_status_desa` | Semua event operasional                        | Dashboard Kades, Portal              |
| Agregat      | `dashboard_agregat`                 | Semua event                                    | Informasi, Peta, Analisis            |
| Notifikasi   | `notifikasi`, `outbox_pesan`        | `*.dibuat/*.selesai/*.alert`                   | Warga, Perangkat (WA/SMS/email/push) |
| Peta         | `peta_objek`                        | `*.geom.berubah` / `*.ditambah`                | Peta Desa (F9)                       |
| Administrasi | `register_buku`                     | `surat.diterbitkan`, `aset`, `tanah`, `mutasi` | Sekretariat (BAU)                    |
| Sinkronisasi | `sinkronisasi_job`                  | `sinkron.dijadwalkan`                          | OpenDK/Kemendagri/IDM                |

### 2.3 Klasifikasi `sumber_data` IDM (penting)

- `operasional` → real-time via worker (benar-benar dihitung dari `domain_events`).
- `periodik_manual` → admin input via `/admin/pengaturan/idm`; dashboard wajib tampilkan **tanggal update terakhir** (bukan "real-time").
- `eksternal` → impor BPS/Kemendes/BMKG/SIKS-NG; bukan event internal.

---

## 3. JALUR DETAIL END-TO-END (JP-01 s.d JP-15)

Setiap jalur menunjukkan **urutan modul, event yang dilewati, dan validasi kritikal**.

### JP-01 — Warga Ajukan Surat (Web/WA → Surat → TTE → Turunan)

```
[Warga] Web/WA (Layanan Mandiri / Chatbot Fonnte)
   │  Pilih jenis surat → autofill NIK dari penduduk (Sistem_Penduduk)
   │  Isi DNA (field manual) → OTP (Sistem_Notifikasi) untuk transaksi
   ▼
[Surat] surat_pengajuan (status DIAJUKAN) ──► event: surat.diajukan
   │  ├─► Notifikasi: WA ke warga + admin (outbox_pesan)
   │  └─► mandiri_track update (Layanan Mandiri)
   ▼
[Admin] Verifikasi → DIVERIFIKASI ──► event: surat.diverifikasi
   ▼
[Kades/Sekdes] TTE (QR + document_hash) → DITANDATANGANI ──► event: surat.diterbitkan
   │  • Nomor surat auto-generate (klasifikasi arsip)
   │  • QR hanya setelah TTE sah
   ▼
[Notifikasi] Kirim PDF ber-QR ke WA warga → DIKIRIM
   ▼
[FAN-OUT surat.diterbitkan]
   ├─► Administrasi_Umum: auto-register Buku Agenda(keluar) + Ekspedisi
   ├─► IDM: rekalkulasi indikator 45.b (Pemanfaatan Teknologi Pelayanan)
   ├─► Penduduk: jika surat Kematian/Kelahiran/Pindah → event penduduk.status.berubah
   │       → log_penduduk + propagasi ke wajib_pajak/balita/usulan_votes/idm
   └─► Informasi: arsip tersedia, statistik surat naik
```

**Validasi kritikal:** NIK unik; nomor surat tidak diinput manual; QR hanya pasca-TTE; surat kematian wajib picu mutasi penduduk.

### JP-02 — Mutasi Penduduk (Core Registry → Seluruh Modul Terdampak)

```
[Admin/Warga] Input/ajukan perubahan (NIK) → validasi no_kk & wilayah_batas
   ▼
[Admin] Verifikasi (TOLAK→WA / TERIMA)
   ▼
UPDATE penduduk → event: penduduk.data.berubah
   └─ jika status dasar berubah (MATI/PINDAH/HILANG) → event: penduduk.status.berubah
   ▼
log_penduduk (kode_peristiwa) + penduduk_log (audit)
   ▼
[Worker] propagasi sinkron ke:
   ├─ wajib_pajak.nama (PBB)
   ├─ balita.orang_tua_* (Posyandu)
   ├─ usulan_votes (eligibilitas voting)
   ├─ idm_status_desa (skor kependudukan)
   ├─ surat (eligibilitas pengajuan)
   ├─ kpm (Sosial: mati/pindah → nonaktif otomatis)
   └─ suplemen_anggota (re-evaluasi keanggotaan)
```

**Kode peristiwa** (log_penduduk): 1 Lahir, 2 Mati, 3 Pindah Keluar, 4 Pindah Masuk, 5 Hamil, 6 Hilang, 7 Kembali, 9 Lainnya.
**Aturan:** field identitas (`nama`, `alamat`, `nik`) **tidak cascade otomatis** — sinkron via event; perubahan kritis wajib OTP.

### JP-03 — Usulan → RKPDes → Voting → APBDes → Realisasi → Aset → IDM

```
[Warga] Submit usulan (Bidang/Sub-Bidang dari RPJMDes) via Web/WA
   ▼ usulan_kegiatan (DIAJUKAN) ──► event: usulan.diajukan
[Admin] Verifikasi regulasi → LOLOS_VERIFIKASI / DITOLAK ──► event: usulan.lolos_verifikasi
   ▼ Masuk POOL_RKPDES (tayang publik)
[Warga] Dukung (OTP WA → verifikasi NIK) → usulan_votes (UNIQUE(usulan_id, nik))
   ▼ event: usulan.vote.bertambah → ranking real-time
[Musdes] Tetapkan RKPDes → DISETUJUI ──► event: musdes.usulan.ditetapkan
   ├─► IDM: indikator 46 (Musyawarah Desa)
   └─► Keuangan: draft APBDes (kode rekening sesuai Bidang/Sub-Bidang)
   ▼
[Keuangan] Susun APBDes (DRAFT → DISAHKAN) → apbdes
[Bendahara] Realisasi → apbdes_realisasi ──► event: apbdes.realisasi.dicatat
   ├─► IDM: tata kelola keuangan
   └─► jika jenis_belanja='modal' → worker INSERT aset_desa (draft, verifikasi)
   ▼
[Pembangunan] usulan_pembangunan → pembangunan (selesai) ──► event: pembangunan.selesai
   ├─► aset_desa otomatis (F8)
   ├─► IDM Dimensi 1 (Infrastruktur)
   └─► Peta (titik pembangunan) + Informasi (berita)
```

**Aturan:** voting hanya untuk `LOLOS_VERIFIKASI`; OTP wajib; APBDes dihitung dari RKPDes+voting, bukan diketik ulang.

### JP-04 — PBB (Pendaftaran → Tagihan → Bayar → PADes → IDM → Keuangan)

```
[Admin] Daftar wajib_pajak (← penduduk atau is_luar_desa) → kepemilikan_objek (persentase)
   ▼ objek_pajak (nop UNIQUE) → objek_pajak_lokasi (lat/long, zona_pbb)
   ▼ event: pbb.objek_pajak.didaftarkan
   ├─► Peta: layer objek_pajak
   ├─► IDM: total NJOP (Dimensi Ekonomi)
   └─► jika akses jalan buruk → draft usulan infrastruktur (menunggu_review)
[Sistem] Generate pbb_tagihan (belum_bayar) otomatis
[Wajib Pajak] Bayar via /pbb/bayar/{token} (QR) → pbb_pembayaran → status_bayar='lunas'
   ▼ event: pbb.tagihan.dibayar
   ├─► Keuangan: INSERT pades_pendapatan (sumber pbb) — tanpa input manual
   ├─► IDM: 47.a (PADes) + 22 (Ekonomi jika jenis_usaha)
   └─► Notifikasi: WA konfirmasi (info_instan)
```

**Aturan:** `kepemilikan_objek` & `objek_pajak_penghuni` append-only; `status_bayar` hanya via `pbb_pembayaran` tervalidasi.

### JP-05 — Kesehatan (Posyandu → Stunting → Sosial/Bansos → IDM → Surat)

```
[Kader] Input kunjungan (bb/tb/lingkar/imunisasi) — bisa offline, sync saat online
   ▼ posyandu_kunjungan (append-only) + posyandu_akses_log
   ▼ event: posyandu.kunjungan.dicatat
   ├─► IDM: skor 7.b (Aktivitas Posyandu, Dimensi Infrastruktur)
   ├─► dashboard_agregat (cakupan imunisasi/gizi per dusun)
   ├─► jika cakupan rendah → draft usulan gizi/imunisasi (W2)
   └─► Stunting: hitung bb/u,tb/u,bb/tb → stunting_anak
[Stunting] jika stunting → stunting_intervensi (gizi/vitamin/rujukan)
   ▼ event: stunting.dievaluasi
   ├─► IDM: kesehatan
   ├─► Sosial: bansos gizi / BPJS PBI otomatis (1-KPM View)
   └─► Surat: rujukan auto-fill (440.1/461/463/441/445)
[Jadwal] posyandu.jadwal.dibuat → agenda_kegiatan (auto) → Informasi + WA reminder
```

**Aturan RBAC:** akses data individu balita hanya `kader` (dusun terkait) & `admin_kesehatan`; Kades hanya agregat; `posyandu_akses_log` wajib.

### JP-06 — Bencana (BMKG → Alert → Eskalasi → Turunan)

```
[Ingest] BMKG API polling → bencana_prakiraan (parameter → skor_risiko → status)
   ▼ bencana.prakiraan (siaga/awas)
   ├─► bencana_alert + Notifikasi WA warga & Tim Siaga/Ambulance
   └─► dashboard_agregat (risiko per dusun)
[Kejadian] Tim Siaga/warga (via Service Center Kedaruratan) → bencana_kejadian
   ▼ event: bencana.kejadian
   ├─► Service Center: eskalasi Kedaruratan
   ├─► Posyandu: korban (balita/ibu_hamil)
   ├─► Sosial: bansos darurat
   ├─► IDM: ketahanan/bencana
   ├─► Surat: keterangan bencana
   └─► Administrasi_Umum: register kejadian
[bencana.selesai] → laporan ke Administrasi_Umum
```

**Aturan:** status `siaga`/`awas` → **wajib** alert otomatis; `bencana_kejadian` terhubung `penduduk` (korban, NIK).

### JP-07 — Pembangunan (Musrenbang → Pembangunan → Aset → IDM → Peta → Informasi)

```
[Musrenbang] Warga (Layanan Mandiri) → usulan_pembangunan (verifikasi TPK)
   ▼ event: pembangunan.diusulkan → agregat kebutuhan dusun
[Penetapan] disetujui → pembangunan (sumber_dana_id, anggaran)
   ▼ event: pembangunan.disetujui → draft apbdes_realisasi (Keuangan)
[Pelaksanaan] pembangunan_dokumentasi (foto %, tanggal) → Notifikasi WA warga
[Serah Terima] status=selesai → aset_desa otomatis (jika belanja modal)
   ▼ event: pembangunan.selesai
   ├─► IDM Dimensi 1 (Infrastruktur)
   ├─► dashboard_agregat (pembangunan per dusun)
   ├─► Administrasi_Umum (register buku pembangunan)
   ├─► Informasi (berita) + Peta (titik pembangunan, F9)
```

### JP-08 — Pertanahan (Bidang Tanah → PBB → Aset → Peta → Administrasi → IDM)

```
[Admin] Daftar bidang_tanah (POLYGON, luas, status) → kepemilikan_bidang_tanah (append-only)
   ▼ tanah_kas_desa / tanah_desa (persil khusus)
   ▼ event: tanah.dicatat → Peta (F9) + agregat wilayah + IDM Lingkungan
[Mutasi] bidang_tanah.dialihkan → worker:
   ├─ tutup kepemilikan lama (tanggal_selesai), insert baru
   ├─ auto-sync PBB (kepemilikan_objek)
   └─ auto-sync Administrasi_Umum (Buku Tanah Kas/Desa)
[Referensi] objek_pajak.bidang_tanah_id (PBB) & aset_desa.bidang_tanah_id (Keuangan)
   mereferensi, TIDAK menduplikasi luas/geom
[tanah.peruntukan.ubah] → IDM Ekonomi (NJOP) + rencana tata ruang
```

### JP-09 — Potensi Ekonomi (UMKM/BUMDes → Marketplace → Peta → IDM Ekonomi)

```
[Admin/BUMDes] Daftar bumdes/koperasi_desa → link lembaga_desa (Profile, PageDetail)
   ▼ event: bumdes.dibuat / koperasi.dibuat
[UMKM] pilih pemilik by NIK (penduduk) → umkm
   ▼ event: umkm.dibuat → profil publik + statistik wirausaha
[Marketplace] produk_marketplace (DRAFT→preview→PUBLISH)
   ▼ event: potensi.produk.terbit → section Marketplace Beranda + WA
[Pariwisata] pariwisata (dusun_id/geom) → event: potensi.wisata.terbit → Peta (F9)
[Sektor] sektor_ekonomi → event: ekonomi.sektor.dicatat → IDM Ekonomi + dashboard_agregat
```

### JP-10 — Pemilu (DPT → Pemilihan → Partisipasi IDM → Informasi)

```
[Admin] DPT dari penduduk (eligible: usia≥17, bukan TNI/Polri, HIDUP) → dpt
   ▼ event: dpt.berubah → rekap DPT + validasi pemilih voting musdes (F2)
[Pemilihan] pemilihan (jenis/tanggal) → daftar TPS
   ▼ event: pemilihan.dibuat → Agenda + Notifikasi warga
[Penghitungan] pemilihan_suara (unik per pemilihan,tps,calon) → rekap + WA
   ▼ event: pemilihan.selesai
   ├─► dashboard_agregat (partisipasi)
   ├─► IDM: partisipasi masyarakat
   └─► Informasi: pengumuman hasil
```

### JP-11 — Aduan (Service Center → Eskalasi → IDM → Surat → Administrasi)

```
[Warga] Lapor via Portal/WA (OTP) → pengaduan_desa (kategori, prioritas)
   │  KEDARURATAN → prioritas wajib kritis (tolak jika ringan)
   ▼ event: pengaduan.dibuat
   ├─► Notifikasi WA penanggung jawab
   ├─► IDM: pelayanan publik & responsivitas
   └─► dashboard_agregat (aduan per kategori/dusun)
[Triage] pengaduan_kategori × pengaduan_desa → pengaduan_penanganan
   │  KAMTIBMAS → hanya Bhabinkamtibmas/Babinsa (RBAC)
   │  KEDARURATAN → WA segera Tim Siaga & Ambulance
   ▼ event: pengaduan.kedaruratan / pengaduan.ditugaskan
[Penyelesaian] status selesai → Notifikasi WA pelapor
   ▼ event: pengaduan.selesai → dashboard_agregat + ulasan
[Layanan turunan] Surat tanggapan auto-fill + Administrasi_Umum register aduan
```

### JP-12 — Sinkronisasi Eksternal (OpenDK / Kemendagri / IDM)

```
[Jadwal/Trigger] sinkronisasi_job (tujuan, tipe push/pull, cron) → worker
   ▼ event: sinkron.dijadwalkan
[Push] ambil fact tables/domain_events → transform via sinkronisasi_mapping → API eksternal
[Pull] data eksternal (mis. Kemendagri) → update penduduk/wilayah_batas VIA EVENT
   ▼ event: penduduk.eksternal.berubah → propagasi ke modul terkait
[Log] sinkronisasi_log (sukses/gagal) → Notifikasi admin jika gagal
   ▼ event: sinkron.selesai / sinkron.gagal (retry terbatas)
```

**Aturan:** mapping di-DB (`sinkronisasi_mapping`); pull → update via event (bukan overwrite); kredensial di secret manager.

### JP-13 — Profil & Onboarding (Profile → Wilayah → Perangkat → TTE → Pengaturan/RBAC)

```
[Admin] Onboarding: Pilih Prov/Kab/Kec/Desa dari API Wilayah → kode_desa auto (immutable)
   ▼ profil_desa (draft) → topografi_desa → wilayah_batas (RT→RW→Dusun, self-referencing)
[Perangkat] desa_pamong (pilih dari penduduk by NIK) → jabatan, No.SK, foto + slug + page_detail
   ▼ (menjadi calon penanda tangan TTE surat: surat_dokumen.ttd_oleh_penduduk_id)
[Lembaga] lembaga_desa (nama bebas) + anggota_lembaga → page_detail + direktori
[Tampilan] site_settings, tenant_theme_config, site_content_blocks (draft→preview→Terapkan)
   ▼
[Pengaturan] pengguna (dari desa_pamong/penduduk) + peran (RBAC) + modul (feature_flags)
   ▼ event: pengguna.berubah / peran.berubah / modul.berubah → re-evaluasi akses semua modul
[Publish] Portal Publik + Peta Desa menampilkan profil terkini (read-only)
```

### JP-14 — Analisis & Suplesi (Suplesi → Analisis → IDM)

```
[Admin] Buat suplemen (mis. "Penyandang Disabilitas") → suplemen_anggota (penduduk, data JSONB)
   ▼ event: suplemen.anggota.ditambah → dashboard_agregat + Analisis (filter responden)
[Analisis] analisis (kemiskinan/partisipasi) → analisis_pertanyaan
   ▼ penduduk → analisis_respon → analisis_hasil (dihitung, bukan diketik)
   ▼ event: analisis.respon.dicatat / analisis.selesai
   ├─► dashboard_agregat (hasil per dusun)
   └─► IDM: indikator terkait
```

**Aturan:** `suplemen_anggota.penduduk_id` → `penduduk` (tidak duplikasi); data fleksibel di JSONB (tidak alter `penduduk`).

### JP-15 — Notifikasi Omnichannel (Semua Event → Satu Pintu)

```
[Event Masuk] domain_events (semua modul) → worker notifikasi
   ▼
[Resolusi] notifikasi_template (by kode_event) × tujuan → notifikasi (inbox) + outbox_pesan
   ▼
[Pengiriman] outbox_pesan (wa/sms/email/push) → Fonnte/SMS/SMTP → callback status
   ▼
[OTP] otp_token (login Layanan Mandiri / verifikasi Penduduk) → validasi → expired/hapus
```

**Aturan:** semua notifikasi keluar via `outbox_pesan` (satu pintu); teks di-DB (`notifikasi_template`); `otp_token` expire + max retry; `outbox_pesan` append-only (audit).

---

## 4. MATRIKS EVENT → DAMPAK LINTAS SISTEM

| Event                                                  | Sumber Modul   | Dampak ke Modul Lain                                                       |
| ------------------------------------------------------ | -------------- | -------------------------------------------------------------------------- |
| `penduduk.data.berubah`                                | Penduduk       | wajib_pajak, balita, usulan_votes, idm, surat, kpm, suplemen               |
| `penduduk.status.berubah`                              | Penduduk       | kpm(nonaktif), idm, surat(eligibilitas), suplemen                          |
| `penduduk.bpjs.berubah`                                | Sosial         | IDM(kesehatan), 1-KPM View                                                 |
| `penduduk.eksternal.berubah`                           | Sinkronisasi   | propagasi ke modul terkait (via event)                                     |
| `surat.diajukan`                                       | Surat/Mandiri  | Notifikasi, mandiri_track, Admin                                           |
| `surat.diverifikasi`                                   | Surat          | Admin, Notifikasi                                                          |
| `surat.diterbitkan`                                    | Surat          | Administrasi_Umum(BAU), IDM(45.b), Penduduk(mutasi), Informasi             |
| `usulan.diajukan`                                      | Keuangan       | Admin, Notifikasi                                                          |
| `usulan.lolos_verifikasi`                              | Keuangan       | Pool RKPDes, Voting                                                        |
| `usulan.vote.bertambah`                                | Keuangan       | Ranking RKPDes real-time                                                   |
| `musdes.usulan.ditetapkan`                             | Keuangan       | IDM(46), draft APBDes                                                      |
| `apbdes.realisasi.dicatat`                             | Keuangan       | IDM(tata kelola), aset_desa(modal)                                         |
| `pbb.objek_pajak.didaftarkan`                          | PBB            | Peta, IDM(NJOP), draft usulan infrastruktur                                |
| `pbb.tagihan.dibayar`                                  | PBB            | Keuangan(pades_pendapatan), IDM(47.a/22), Notifikasi                       |
| `posyandu.kunjungan.dicatat`                           | Posyandu       | IDM(7.b), dashboard, Stunting, draft usulan gizi                           |
| `ibu_hamil.dicatat`                                    | Posyandu       | Agenda, Notifikasi, Surat(440.1)                                           |
| `balita.dicatat`                                       | Posyandu       | Statistik kesehatan, IDM                                                   |
| `posyandu.jadwal.dibuat`                               | Posyandu       | agenda_kegiatan(Informasi), WA reminder                                    |
| `stunting.dievaluasi`                                  | Stunting       | IDM(kesehatan), Sosial(bansos gizi/PBI), Surat(rujukan)                    |
| `stunting.intervensi.dicatat`                          | Stunting       | Notifikasi ortu, Surat                                                     |
| `bansos.penerima.dicatat`                              | Sosial         | IDM(Dimensi Sosial), dashboard, draft usulan(ekstrem)                      |
| `bansos.penyaluran.dicatat`                            | Sosial         | Notifikasi KPM, agenda, Informasi                                          |
| `kpm.dicatat` / `dtks.sync`                            | Sosial         | eligibilitas surat 465.x, agregat kesejahteraan                            |
| `pembangunan.diusulkan`                                | Pembangunan    | usulan, agregat dusun                                                      |
| `pembangunan.disetujui`                                | Pembangunan    | draft apbdes_realisasi, sumber_dana                                        |
| `pembangunan.selesai`                                  | Pembangunan    | IDM(Dimensi 1), aset_desa, Administrasi_Umum, Informasi, Peta              |
| `bidang_tanah.dialihkan`                               | Pertanahan     | PBB(kepemilikan_objek), Administrasi_Umum(Buku Tanah)                      |
| `tanah.dicatat`                                        | Pertanahan     | Peta, agregat wilayah, IDM Lingkungan                                      |
| `tanah.peruntukan.ubah`                                | Pertanahan     | IDM Ekonomi(NJOP), tata ruang                                              |
| `bencana.prakiraan`                                    | Bencana        | bencana_alert, Notifikasi, dashboard                                       |
| `bencana.kejadian`                                     | Bencana        | Service Center, Posyandu, Sosial, IDM, Informasi, Surat, Administrasi      |
| `bencana.alert.dikirim`                                | Bencana        | WA warga & Tim Siaga/Ambulance                                             |
| `pengaduan.dibuat`                                     | Service Center | Notifikasi, IDM(pelayanan), dashboard                                      |
| `pengaduan.kedaruratan`                                | Service Center | Eskalasi WA Tim Siaga & Ambulance                                          |
| `pengaduan.ditugaskan`                                 | Service Center | BKD/Bhabinkamtibmas/Babinsa/Posbankum                                      |
| `pengaduan.selesai`                                    | Service Center | Notifikasi pelapor, dashboard, ulasan                                      |
| `call_center.terbit`                                   | Service Center | Portal & Informasi                                                         |
| `pemilihan.dibuat`                                     | Pemilu         | Agenda, Notifikasi                                                         |
| `pemilihan.selesai`                                    | Pemilu         | dashboard(partisipasi), IDM, Informasi                                     |
| `dpt.berubah`                                          | Pemilu         | rekap DPT, validasi voter musdes                                           |
| `analisis.respon.dicatat`                              | Analisis       | analisis_hasil, dashboard                                                  |
| `analisis.selesai`                                     | Analisis       | IDM, dashboard                                                             |
| `suplemen.anggota.ditambah`                            | Suplesi        | dashboard, Analisis                                                        |
| `bumdes.dibuat` / `koperasi.dibuat`                    | Potensi        | lembaga_desa, direktori, PageDetail                                        |
| `umkm.dibuat`                                          | Potensi        | profil publik, statistik wirausaha                                         |
| `potensi.produk.terbit`                                | Potensi        | Marketplace Beranda, Notifikasi                                            |
| `potensi.wisata.terbit`                                | Potensi        | Peta(F9), section Wisata                                                   |
| `ekonomi.sektor.dicatat`                               | Potensi        | IDM Ekonomi, dashboard                                                     |
| `informasi.berita.terbit`                              | Informasi      | Beranda, Notifikasi(info_instan)                                           |
| `agenda.dibuat`                                        | Informasi      | Kalender Desa, reminder subscriber                                         |
| `galeri.terbit`                                        | Informasi      | Beranda                                                                    |
| `wilayah.berubah`                                      | Profile        | Peta(layer batas_wilayah)                                                  |
| `perangkat.berubah`                                    | Profile        | Daftar TTE Surat (surat_dokumen.ttd_oleh_penduduk_id), IDM D5/Pemerintahan |
| `pbb.objek.ditambah`                                   | PBB            | Peta(layer objek_pajak)                                                    |
| `bencana.titik.ditambah`                               | Bencana        | Peta(layer titik_bencana)                                                  |
| `peta.objek.ditambah/.diubah`                          | Pemetaan       | re-render Peta Publik (cache)                                              |
| `sinkron.dijadwalkan`                                  | Sinkronisasi   | push/pull eksternal                                                        |
| `sinkron.selesai` / `sinkron.gagal`                    | Sinkronisasi   | dashboard, Notifikasi admin, retry                                         |
| `pengguna.berubah` / `peran.berubah` / `modul.berubah` | Pengaturan     | re-evaluasi RBAC semua modul, audit                                        |
| `otp.diminta`                                          | Notifikasi     | verifikasi login/perubahan data                                            |

---

## 5. ATURAN INTEGRASI KRITIS (CROSS-CUTTING)

1. **Append-only wajib** untuk: `log_penduduk`, `penduduk_log`, `surat_log_status`, `keuangan_log`, `pertanahan_log`, `posyandu_akses_log`, `pengaduan_penanganan`, `stunting_intervensi`, `log_administrasi`, `outbox_pesan`, `sinkronisasi_log`, `pengaturan_log`. Koreksi = entri pembatalan (`berlaku_sampai`/`tanggal_selesai`), bukan edit.
2. **Fakta turunan HANYA worker.** `idm_skor_cache`, `dashboard_agregat`, `peta_objek`, `register_buku` diisi lewat event, tidak pernah diinput manual di UI.
3. **Idempotensi.** Semua write turunan pakai `ON CONFLICT DO UPDATE` — retry aman, tidak efek ganda.
4. **Core Registry tunggal.** `penduduk` by NIK adalah sumber identitas; modul lain FK ke `penduduk.id`, tidak mengkopi NIK/nama.
5. **Satu pintu notifikasi.** Tidak ada modul kirim WA/SMS langsung — lewat `outbox_pesan`.
6. **Satu layer peta.** Geom tetap di tabel sumber; `peta_objek` hanya referensi (`ref_tabel`+`ref_id`).
7. **Auto-register BAU.** Entri Administrasi_Umum dari modul lain otomatis via event; sekretariat hanya verifikasi.
8. **Zero hardcode.** Teks/menu/tema/label dari `site_content_blocks`, `i18n_strings`, `feature_flags`, `site_navigation`, `tenant_theme_config`, `notifikasi_template`, `sinkronisasi_mapping`.
9. **RBAC ketat.** Warga akses data sendiri; kader hanya dusunnya; Kamtibmas hanya Bhabinkamtibmas/Babinsa; data individu balita tidak pernah publik.
10. **Manusia tetap berdaulat.** Draft usulan otomatis (IDM/gizi/infrastruktur) **wajib verifikasi manusia** (W2) sebelum masuk RKPDes/APBDes — sistem tidak eksekusi anggaran tanpa persetujuan.
11. **Draft→preview→publish.** Konten publik (Informasi, Potensi, Profile) wajib lewat status ini; tidak ada publish tanpa preview.
12. **Sumber data IDM eksplisit.** `operasional` (real-time) vs `periodik_manual`/`eksternal` (tampilkan tanggal update terakhir).

---

## 6. STATE MACHINE GLOBAL (Status Transisi Kunci)

| Entitas                               | Status flow                                                               |
| ------------------------------------- | ------------------------------------------------------------------------- |
| `surat_pengajuan`                     | DIAJUKAN → DIVERIFIKASI → DITANDATANGANI → DIKIRIM → ARSIP (atau DITOLAK) |
| `penduduk.status_dasar`               | HIDUP → MATI / PINDAH / HILANG / PERGI / TIDAK VALID                      |
| `usulan_kegiatan`                     | DIAJUKAN → LOLOS_VERIFIKASI → DISETUJUI_RKPDES (atau DITOLAK)             |
| `usulan_kegiatan_draft_otomatis`      | menunggu_review → (verifikasi manusia) → RKPDes                           |
| `pbb_tagihan.status_bayar`            | belum_bayar → sebagian → lunas                                            |
| `apbdes`                              | DRAFT → DISAHKAN                                                          |
| `pembangunan`                         | draft → berjalan → selesai                                                |
| `bencana_prakiraan.status`            | aman → waspada → siaga → awas                                             |
| `pengaduan_desa`                      | diajukan → ditugaskan → diproses → selesai                                |
| `bansos_penerima.status`              | aktif / nonaktif / ganda / tidak_valid                                    |
| `produk_marketplace` / `artikel_desa` | DRAFT → PUBLISH                                                           |
| `pengguna`                            | aktif / nonaktif (via peran × feature_flags)                              |

---

## 7. KESIMPULAN INTEGRASI

Seruni - Sistem Repository Unifikasi Informasi bukan kumpulan modul terpisah, melainkan **satu graf alur kerja** dengan:

- **Satu sumber identitas** (`penduduk`),
- **Satu bus event** (`domain_events` → worker),
- **Enam fan-out turunan** (IDM, Agregat, Notifikasi, Peta, Administrasi, Sinkronisasi),
- **Satu pintu presentasi** (Portal Publik via Informasi + Peta + Administrasi_Umum).

Setiap jalur (JP-01 s.d JP-15) di atas menjamin tidak ada input ganda: fakta dicatat sekali, dampaknya menyebar otomatis, dan keputusan anggaran/kebijakan tetap di tangan manusia (Musdes, Kades, admin) sesuai prinsip tata kelola yang baik.
