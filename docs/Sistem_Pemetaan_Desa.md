# Sistem Pemetaan Desa (GIS / F9)

Sistem Pemetaan Desa menyediakan **satu layer peta terpadu (F9)** sebagai _Single Source of Truth_ representasi spasial seluruh objek desa. Merujuk OpenSID (`tweb_area`/`tweb_garis`/`tweb_line`/`tweb_point`/`tweb_polygon`/`tweb_simbol`), diadaptasi ke skema Seruni - Sistem Repository Unifikasi Informasi (UUID + `tenant_id`, event-driven). Kunci: **setiap modul punya geom di tabelnya sendiri, lalu mereplikasi ke `peta_objek` via event** (ref_tabel+ref_id) — tidak duplikasi geometri.

## 1. Ringkasan Sistem Pemetaan (On Point)

- **Peran:** `peta_layer` + `peta_objek` + `peta_simbol` = _Single Source of Truth_ peta desa (F9). Satu sistem layer untuk semua titik/garis/poligon.
- **Kanal:** Web admin (sekretariat) kelola layer & objek; Peta Publik read-only (filter layer).
- **Layer:** `batas_wilayah`, `aset_desa`, `bidang_tanah` (Pertanahan), `objek_pajak` (PBB), `titik_bencana` (Bencana), `pariwisata` (Potensi), `titik_layanan` (service_center).
- **Referensi:** `peta_objek` mereferensi fakta domain via `ref_tabel`+`ref_id` (geom tetap di sumber).
- **Integrasi:** Semua modul yang punya geom (`wilayah_batas`, `bidang_tanah`, `objek_pajak_lokasi`, `bencana_titik`, `pariwisata`) → `peta_objek` otomatis via event.
- **Zero Hardcode:** Layer & simbol di-DB (`peta_layer`, `peta_simbol`); tidak hardcode nama layer di kode.

## 2. Workflow Lengkap Sistem Pemetaan Komplit

```
[A] DEFINISI LAYER
    peta_layer (kategori, warna, ikon) — mis. aset, pbb, bencana, potensi, layanan
        ▼
[B] INGEST OBJEK (dari modul lain via event)
    wilayah_batas / bidang_tanah / objek_pajak_lokasi / bencana_titik / pariwisata
        │  event *.geom.berubah → peta_objek (layer_id, ref_tabel, ref_id, geom, nama)
        ▼
[C] TAMPIL PUBLIK
    peta_objek → Peta Desa (F9) filter by layer
        │  → embed di Sistem Informasi / Profil Desa
        ▼
[D] EVENT PROPAGATION
    peta.objek.ditambah / .diubah → re-render peta publik (cache)
```

**Aturan Kritikal:**

- `peta_objek.ref_tabel`+`ref_id` → fakta domain (satu geom di sumber, tidak di `peta_objek`). Update geom di sumber → event → update `peta_objek`.
- Layer wajib terdaftar di `peta_layer` (tidak hardcode nama layer di kode).
- `peta_objek.geom` dikelola di sumber; peta hanya menampilkan (read-only spasial).

**Event & integrasi:**

| Event                    | Sumber           | Dampak ke peta_objek            |
| ------------------------ | ---------------- | ------------------------------- |
| `wilayah.berubah`        | Profile/Penduduk | Layer `batas_wilayah` re-render |
| `bidang_tanah.dialihkan` | Pertanahan (F7)  | Layer `bidang_tanah` update     |
| `pbb.objek.ditambah`     | PBB (F5)         | Layer `objek_pajak`             |
| `bencana.titik.ditambah` | Bencana          | Layer `titik_bencana`           |
| `potensi.wisata.terbit`  | Potensi          | Layer `pariwisata`              |

## 3. Tabel Jenis Pemetaan Desa (OpenSID / GIS)

### 3.1 Tabel Induk

| Tabel (Seruni - Sistem Repository Unifikasi Informasi) | Ekuivalen OpenSID                        | Kolom inti                                                                                                                   | Referensi FK               |
| -------------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `peta_layer`   | `tweb_area` (kategori)                   | `id`, `tenant_id`, `kode`, `nama` (batas/aset/pbb/bencana/potensi/layanan), `warna`, `ikon`, `urutan`, `aktif`               | `tenant_id`→`tenants.id`   |
| `peta_objek`   | `tweb_point`/`tweb_garis`/`tweb_polygon` | `id`, `tenant_id`, `layer_id`→`peta_layer.id`, `ref_tabel`, `ref_id`, `nama`, `geom`, `keterangan`, `dibuat_otomatis` (bool) | `layer_id`→`peta_layer.id` |
| `peta_simbol`  | `tweb_simbol`                            | `id`, `tenant_id`, `nama`, `file_path`, `urutan`                                                                             | `tenant_id`→`tenants.id`   |

### 3.2 Tabel Pendukung

| Tabel (Seruni - Sistem Repository Unifikasi Informasi)        | Ekuivalen              | Kolom inti                                                                                                            | Referensi FK                          |
| --------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `domain_events`       | Event Bus              | `id`, `tenant_id`, `event_type`, `entity_id`, `payload` (JSONB), `created_at`, `processed_at`                         | `tenant_id`→`tenants.id`              |
| `wilayah_batas`       | Wilayah (batas)        | `id`, `tenant_id`, `jenis`, `nama`, `geom`, `parent_id`                                                               | `parent_id`→`wilayah_batas.id` (self) |
| `bidang_tanah`        | Sistem Pertanahan (F7) | `id`, `tenant_id`, `luas_m2`, `geom`, `jenis_alas_hak`                                                                | `tenant_id`→`tenants.id`              |
| `objek_pajak_lokasi`  | Sistem PBB (F5)        | `id`, `tenant_id`, `objek_pajak_id`, `lat`, `lng`, `luas`, `kelas_njop`                                               | `tenant_id`→`tenants.id`              |
| `bencana_titik`       | Sistem Bencana         | `id`, `tenant_id`, `kategori_id`, `wilayah_id`, `nama_lokasi`, `geom`, `tingkat_risiko`                               | `wilayah_id`→`wilayah_batas.id`       |
| `pariwisata`          | Sistem Potensi         | `id`, `tenant_id`, `nama`, `dusun_id`→`wilayah_batas.id`, `geom`, `deskripsi`                                         | `dusun_id`→`wilayah_batas.id`         |
| `site_content_blocks` | CMS Section            | `id`, `tenant_id`, `halaman`, `tipe_blok` (`peta`), `urutan`, `konten` (JSONB), `status`                              | `tenant_id`→`tenants.id`              |
| `feature_flags`       | Toggle Modul           | `id`, `tenant_id`, `flag_key`, `enabled`                                                                              | `tenant_id`→`tenants.id`              |
| `i18n_strings`        | Teks UI                | `id`, `tenant_id`, `locale`, `key`, `value`                                                                           | `tenant_id`→`tenants.id`              |
| `tenant_theme_config` | Tema                   | `tenant_id` (PK), `logo`, `favicon`, `warna_primer`, `warna_aksen`, `preset_font`                                     | `tenant_id`→`tenants.id`              |
| `site_settings`       | Identitas              | `tenant_id` (PK), `nama_resmi`, `alamat_kantor`, `jam_layanan`, `kontak`, `nomor_wa_resmi`, `wa_verified`             | `tenant_id`→`tenants.id`              |
| `peta_log`            | Log Audit              | `id`, `tenant_id`, `entity` (`peta_objek`), `entity_id`, `aksi`, `aktor_id`, `field_lama`, `field_baru`, `created_at` | `tenant_id`→`tenants.id`              |

### 3.3 Diagram integrasi

```
peta_layer (kategori, warna, ikon) ──► peta_objek (ref_tabel + ref_id + geom)
        ▲                                     │
        │                                     ├─ wilayah_batas (Profile) ──► layer batas
        │                                     ├─ bidang_tanah (Pertanahan F7) ──► layer tanah
        │                                     ├─ objek_pajak_lokasi (PBB F5) ──► layer pbb
        │                                     ├─ bencana_titik (Bencana) ──► layer bencana
        │                                     └─ pariwisata (Potensi) ──► layer potensi
        │                                     (semua via event *.geom.berubah)
        ▼
domain_events: peta.objek.ditambah → re-render Peta Publik (F9) · embed Sistem Informasi
```

**Keterangan integrasi:** `peta_objek` adalah representasi tunggal semua geom desa; tiap modul menyimpan geom di tabelnya sendiri dan mereplikasi ke `peta_objek` via event (`ref_tabel`+`ref_id`) sehingga tidak ada duplikasi geometri. Layer dikelola di `peta_layer` (zero hardcode). Peta Publik (F9) menampilkan dengan filter layer, dan di-embed ke Sistem Informasi & Profil Desa. `peta_simbol` menyediakan ikon tiap jenis objek.
