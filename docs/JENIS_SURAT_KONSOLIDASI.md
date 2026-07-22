# Konsolidasi Jenis Surat Layanan Desa (OpenSID)

Daftar master jenis surat hasil konsolidasi `surat.csv` + `surat2.csv`, siap di-seed ke tabel
`surat_jenis` (100% online, TTE + QR). Kolom: **Kode Klasifikasi | Kode Surat | Jenis Surat | DNA**
(field manual dari pemohon; field identitas auto-fill dari NIK). Semua surat memenuhi 4 pedoman:
kewenangan desa, DNA logis, 100% online (tanpa Pengantar RT/RW fisik), tanpa duplikat fungsi.

## A. Kependudukan & Domisili (474 / 475)

| Kode Klasifikasi | Kode Surat | Jenis Surat                                 | DNA (field manual)                                                                                       |
| ---------------- | ---------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| 474              | 474.0      | Surat Keterangan Domisili                   | Alamat domisili + RT/RW, sejak tanggal domisili, tujuan/keperluan                                        |
| 475              | 475.0      | Surat Keterangan Pindah Domisili            | Alamat tujuan + RT/RW, Kab/Kota tujuan, alasan pindah, daftar anggota pindah, No. Surat Pindah lama      |
| 474              | 474.1      | Surat Keterangan Bukan Penduduk Setempat    | NIK daerah lain, alamat KTP, keterangan keberadaan di desa, keperluan                                    |
| 474              | 474.2      | Surat Keterangan KK Sementara               | Alasan pembuatan KK baru, No. KK lama (ops), daftar anggota KK                                           |
| 474              | 474.3      | Surat Keterangan Beda Nama                  | Nama di dokumen lain, jenis dokumen, penyebab perbedaan, keperluan                                       |
| 474              | 474.4      | Surat Keterangan Penduduk (Biodata Lengkap) | Keperluan surat (identitas auto)                                                                         |
| 475              | 475.1      | Surat Keterangan Pendatang / Numpang KK     | NIK pendatang, asal Kota/Kab, alamat KTP asal, nama pemilik rumah tumpangan, hubungan, lama numpang      |
| 475              | 475.2      | Surat Keterangan Alamat Sementara           | Alamat KTP permanen, alamat sementara + RT/RW, sejak, perkiraan sampai, keperluan                        |
| 475              | 475.3      | Surat Keterangan Mutasi Penduduk Masuk      | NIK daerah asal, No. KK asal, Desa/Kec/Kab asal, No. Surat Pindah asal, tgl surat pindah, daftar anggota |
| 474              | 474.5      | Surat Keterangan Kepala Keluarga            | Daftar anggota keluarga (Nama+NIK+Hubungan)                                                              |
| 475              | 475.5      | Surat Keterangan Tidak Berada di Desa       | Tgl meninggalkan desa, perkiraan tgl kembali, tujuan kota, alasan                                        |

## B. Sosial & Ekonomi (465 / 440 / 300 / 474.6)

| Kode Klasifikasi | Kode Surat | Jenis Surat                              | DNA (field manual)                                                                          |
| ---------------- | ---------- | ---------------------------------------- | ------------------------------------------------------------------------------------------- |
| 465              | 465.0      | Surat Keterangan Tidak Mampu (SKTM)      | Penghasilan/bulan, jumlah tanggungan, kondisi tempat tinggal, sumber penghasilan, keperluan |
| 465              | 465.1      | Surat Keterangan Penerima Bantuan Sosial | Jenis bantuan (PKH/BPNT/BLT/PIP), No. DTKS, No. KKS, periode                                |
| 465              | 465.2      | Surat Keterangan Penghasilan             | Nama usaha, penghasilan tetap/tambahan/total per bulan, keperluan                           |
| 440              | 440.0      | Surat Keterangan Jamkesos / BPJS         | No. BPJS lama (ops), kategori peserta (PBI/PBPU/PPU), anggota didaftarkan, faskes           |
| 474              | 474.6      | Surat Keterangan Kehilangan              | Barang/dokumen hilang, No. dokumen, tgl diperkirakan hilang, lokasi, kronologi              |
| 300              | 300.0      | Surat Pengantar SKCK                     | Ciri fisik, keperluan SKCK, riwayat pidana                                                  |
| 300              | 300.1      | Surat Keterangan Kelakuan Baik           | Lama berdomisili di desa, riwayat catatan kriminal, keperluan                               |
| 465              | 465.4      | Surat Keterangan Tidak Punya Pekerjaan   | Status ketenagakerjaan, sejak tidak bekerja, alasan, keperluan                              |
| 465              | 465.5      | Surat Keterangan Warga Miskin Ekstrem    | Penghasilan/hari, jumlah tanggungan, kondisi tempat tinggal, sumber data P3KE/DTKS          |
| 465              | 465.6      | Surat Pengantar Pengiriman Bantuan       | Jenis bantuan, jumlah paket, nilai (Rp), sumber pengirim, nama penerima, alamat             |

## C. Pernikahan & Keluarga (451 / 477 / 474.7–474.9)

| Kode Klasifikasi | Kode Surat | Jenis Surat                           | DNA (field manual)                                                                             |
| ---------------- | ---------- | ------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 474              | 474.7      | Surat Keterangan Belum Menikah        | Nama ayah kandung, nama ibu kandung, keperluan                                                 |
| 451              | 451.0      | Surat Keterangan Nikah (N-1 s/d N-6)  | Data orang tua calon suami/istri, data saksi, No. Surat Pengantar Nikah                        |
| 477              | 477.0      | Surat Keterangan Nikah Non-Muslim     | Agama mempelai, keterangan status, No. akta nikah (nanti)                                      |
| 477              | 477.1      | Surat Keterangan Status Janda / Duda  | Nama mantan pasangan, penyebab status, No. akta cerai/putusan PA, data anak (ops)              |
| 474              | 474.8      | Surat Keterangan Hubungan Keluarga    | NIK pihak diterangkan, hubungan keluarga, No. KK bersama                                       |
| 474              | 474.9      | Surat Keterangan Ahli Waris           | Nama pewaris, tgl meninggal, tempat meninggal, No. akta kematian, daftar ahli waris            |
| 477              | 477.3      | Surat Keterangan Kelahiran            | Nama anak, JK, anak ke-, hari/tgl/jam lahir, tempat lahir, nama orang tua, No. akta (jika ada) |
| 477              | 477.4      | Surat Keterangan Kematian             | NIK almarhum, tgl meninggal, hari, sebab, tempat pemakaman, No. akta kematian                  |
| 451              | 451.1      | Surat Dispensasi Nikah (Pengantar PA) | Usia calon, alasan dispensasi, data orang tua/wali                                             |
| 451              | 451.2      | Surat Keterangan Wali Nikah Hakim     | Nama wali nasab, alasan wali tak bisa, data calon suami                                        |
| 451              | 451.3      | Surat Keterangan Tanah Wakaf          | Nama nadzir, peruntukan wakaf, lokasi, luas, No. akta wakaf (jika ada)                         |
| 451              | 451.4      | Surat Keterangan Numpang Nikah        | NIK calon pendatang, KUA asal, alasan numpang, data pasangan                                   |

## D. Usaha & Ekonomi (510 / 140 / 30.0 / 524 / 530)

| Kode Klasifikasi | Kode Surat | Jenis Surat                          | DNA (field manual)                                                                                  |
| ---------------- | ---------- | ------------------------------------ | --------------------------------------------------------------------------------------------------- |
| 510              | 510.0      | Surat Keterangan Usaha (SKU)         | Nama usaha, jenis bidang, komoditas, alamat usaha + RT/RW, berdiri sejak, jumlah karyawan           |
| 510              | 510.1      | Surat Keterangan Domisili Usaha      | Bentuk badan usaha, bidang usaha, alamat + RT/RW, No. NIB (ops)                                     |
| 140              | 140.0      | Surat Izin Keramaian                 | Nama penyelenggara/PIC, jenis acara (umum/hajatan), tgl, jam mulai–selesai, tempat, perkiraan massa |
| 30               | 30.0       | Surat Pengantar Peminjaman Tempat    | Nama peminjam/organisasi, nama tempat, tgl, jam, keperluan                                          |
| 524              | 524.0      | Surat Keterangan Peternak            | Jenis ternak, jumlah ekor, lokasi kandang, luas kandang                                             |
| 530              | 530.0      | Surat Keterangan Pengrajin / Seniman | Bidang kerajinan/seni, nama produk, nama sanggar, alamat workshop                                   |
| 510              | 510.2      | Surat Keterangan Pedagang Pasar      | Nama pasar, No. lapak/kios, komoditas, hari berdagang, sejak                                        |
| 510              | 510.3      | Surat Izin Reklame / Papan Nama      | Nama usaha, teks reklame, jenis reklame, ukuran, lokasi pemasangan                                  |

## E. Tanah & Properti (30 / 650)

| Kode Klasifikasi | Kode Surat | Jenis Surat                               | DNA (field manual)                                                              |
| ---------------- | ---------- | ----------------------------------------- | ------------------------------------------------------------------------------- |
| 30               | 30.1       | Surat Keterangan Kepemilikan Tanah        | Lokasi tanah, luas (m²), No. persil/blok, kelas tanah, batas, bukti kepemilikan |
| 30               | 30.2       | Surat Keterangan Tidak Sengketa Tanah     | Lokasi, luas, batas 4 penjuru, No. SPPT PBB, saksi 1 & 2                        |
| 30               | 30.3       | Surat Keterangan Hibah Tanah              | Data pemberi & penerima hibah, hubungan, lokasi, luas, dasar hibah              |
| 30               | 30.4       | Surat Keterangan Jual Beli Tanah          | Data penjual & pembeli, lokasi, luas, batas, harga jual, saksi                  |
| 650              | 650.0      | Surat Keterangan Kepemilikan Rumah        | Alamat rumah, luas tanah, luas bangunan, jenis bangunan, tahun dibangun         |
| 650              | 650.1      | Surat Keterangan Belum Memiliki Rumah     | Status tempat tinggal, nama pemilik, sejak, keperluan                           |
| 30               | 30.5       | Surat Keterangan Tanah Bengkok / Kas Desa | Jabatan penggarap, lokasi, luas, peruntukan                                     |
| 30               | 30.6       | Surat Keterangan Sporadik Tanah           | Lokasi, luas, batas 4 penjuru, bukti penguasaan                                 |
| 650              | 650.2      | Surat Pengantar IMB / PBG                 | Jenis bangunan, lokasi, luas tanah/bangunan, fungsi                             |
| 30               | 30.9       | Surat Pengantar PTSL                      | Lokasi tanah, luas, No. persil, bukti kepemilikan, No. bidang                   |

## F. Pendidikan (420)

| Kode Klasifikasi | Kode Surat | Jenis Surat                             | DNA (field manual)                                                    |
| ---------------- | ---------- | --------------------------------------- | --------------------------------------------------------------------- |
| 420              | 420.0      | Surat Keterangan untuk Beasiswa         | Jenjang, nama sekolah/kampus, prodi, prestasi/IPK, keperluan beasiswa |
| 420              | 420.1      | Surat Keterangan PPDB Zonasi            | Jenjang yang dituju, nama sekolah tujuan, jarak ke sekolah            |
| 420              | 420.2      | Surat Keterangan Penelitian / KKN / PKL | NIM/NIS, asal institusi, jenis kegiatan, tema, tgl mulai–selesai      |
| 420              | 420.3      | Surat Keterangan Putus Sekolah          | Jenjang terakhir, nama sekolah, kelas terakhir, tahun, alasan         |
| 420              | 420.4      | Surat Izin Mendirikan Sanggar / Kursus  | Nama lembaga, bidang, alamat, target peserta                          |
| 420              | 420.5      | Surat Aktif Sekolah (PIP/KPS)           | Nama sekolah, kelas, NISN, tahun ajaran, program diikuti              |

## G. Kesehatan & Khusus (461 / 463 / 445 / 440.1 / 441)

| Kode Klasifikasi | Kode Surat | Jenis Surat                             | DNA (field manual)                                                        |
| ---------------- | ---------- | --------------------------------------- | ------------------------------------------------------------------------- |
| 461              | 461.0      | Surat Keterangan Penyandang Disabilitas | Jenis disabilitas, tingkat, penyebab, alat bantu, keperluan               |
| 463              | 463.0      | Surat Keterangan Orang Terlantar        | Nama (ops), perkiraan usia, JK, ciri fisik, lokasi ditemukan, tgl         |
| 445              | 445.0      | Surat Keterangan Rawat Inap / Rujukan   | No. kartu BPJS, jenis layanan, keluhan/diagnosis, RS tujuan               |
| 463              | 463.1      | Surat Keterangan Lansia                 | Usia, kondisi kesehatan umum, penyakit kronis, keperluan                  |
| 463              | 463.2      | Surat Keterangan Anak Yatim / Piatu     | Status (yatim/piatu), nama ortu meninggal, tgl meninggal, keperluan       |
| 440              | 440.1      | Surat Keterangan Hamil / Ibu Melahirkan | NIK suami, kondisi (hamil/lahir), usia kehamilan/usia bayi, No. KIA (ops) |
| 441              | 441.0      | Surat Keterangan Gangguan Jiwa (ODGJ)   | Jenis gangguan, sejak tahun, status penanganan, keperluan                 |

## H. Surat Dinas & Internal Desa (80 / 90 / 890 / 140.1 / 141 / 30.7 / 140.3 / 30.8 / 60 / 140.4 / 610 / 50)

| Kode Klasifikasi | Kode Surat | Jenis Surat                          | DNA (field manual)                                                       |
| ---------------- | ---------- | ------------------------------------ | ------------------------------------------------------------------------ |
| 80               | 80.0       | Surat Undangan Rapat                 | Agenda, tgl, hari, jam, tempat, peserta                                  |
| 90               | 90.0       | Surat Tugas Perangkat Desa           | Rincian tugas, lokasi, tgl mulai–selesai                                 |
| 890              | 890.0      | Surat Izin Cuti Perangkat Desa       | Jenis cuti, tgl mulai–selesai, alasan, plt                               |
| 140              | 140.1      | Surat Pengantar ke Instansi Lain     | Instansi tujuan, keperluan/urusan, dokumen dibawa                        |
| 141              | 141.0      | Surat Keputusan Kepala Desa (SK)     | No. SK, perihal, pihak ditetapkan, jabatan, tgl berlaku–berakhir         |
| 140              | 140.2      | Surat Permohonan Bantuan             | Ditujukan ke, jenis bantuan, uraian, tujuan/manfaat, jml warga terdampak |
| 30               | 30.7       | Berita Acara Serah Terima            | Tgl, pihak I & II, nama barang/pekerjaan, lokasi                         |
| 140              | 140.3      | Surat Rekomendasi                    | NIK yang direkomendasikan, jabatan, hal, alasan, ditujukan ke            |
| 30               | 30.8       | Surat Pernyataan Tidak Ada Sengketa  | Pihak I & II, objek yang dinyatakan, lokasi objek, keterangan            |
| 60               | 60.0       | Nota Dinas                           | No. nota dinas, tgl, dari, kepada, hal, isi                              |
| 140              | 140.4      | Surat Perjanjian Kerjasama (MoU/PKS) | No. PKS, tgl, mitra/Pihak II, ruang lingkup, hak & kewajiban             |
| 610              | 610.0      | Surat Permohonan Perbaikan Jalan     | Nama ruas, lokasi/rute, panjang rusak, lebar, kondisi, status jalan      |
| 50               | 50.0       | Laporan Pelaksanaan Kegiatan         | Judul kegiatan, tgl, lokasi, peserta, pagu & realisasi                   |

## I. Pertanian & Lingkungan (520 / 523 / 360 / 620)

| Kode Klasifikasi | Kode Surat | Jenis Surat                               | DNA (field manual)                                               |
| ---------------- | ---------- | ----------------------------------------- | ---------------------------------------------------------------- |
| 520              | 520.0      | Surat Keterangan Petani                   | Komoditas utama, luas lahan, status kepemilikan, lokasi/blok     |
| 523              | 523.0      | Surat Keterangan Nelayan                  | Jenis nelayan, alat tangkap, jenis/ukuran kapal, No. registrasi  |
| 360              | 360.0      | Surat Keterangan Dampak Bencana           | Jenis bencana, tgl kejadian, lokasi, dampak jiwa/harta, kerugian |
| 520              | 520.1      | Surat Izin Penebangan Pohon               | Jenis pohon, jumlah, diameter, lokasi, alasan                    |
| 520              | 520.2      | Surat Keterangan Penggunaan Lahan         | Lokasi lahan, luas, peruntukan, status penguasaan                |
| 520              | 520.3      | Surat Keterangan Kelompok Tani / Nelayan  | Nama kelompok, jenis, ketua, jumlah anggota, No. HP              |
| 620              | 620.0      | Surat Keterangan Penggunaan Air / Irigasi | Sumber air, nama saluran, luas lahan diairi, lokasi              |

## J. Surat Umum & Lainnya (474.10 / 474.12 / 180 / 474.13 / 471 / 456 / 441.1 / 466 / 900 / 220 / 477.5 / 474.14 / 880)

| Kode Klasifikasi | Kode Surat | Jenis Surat                                    | DNA (field manual)                                                  |
| ---------------- | ---------- | ---------------------------------------------- | ------------------------------------------------------------------- |
| 474              | 474.10     | Surat Pengantar Pembuatan Dokumen Kependudukan | Jenis dokumen (KTP/KK/Akta), alasan, Kantor Dukcapil tujuan         |
| 474              | 474.12     | Surat Pernyataan Tanggung Jawab Mutlak (SPTJM) | Jenis SPTJM, isi pernyataan, 2 saksi (NIK), keperluan               |
| 180              | 180.0      | Surat Kuasa                                    | NIK penerima kuasa, nama, hubungan, hal yang dikuasakan             |
| 474              | 474.13     | Surat Permohonan Pindah Agama                  | Agama asal, agama sekarang, keterangan perpindahan, keperluan       |
| 471              | 471.0      | Surat Keterangan WNI Keturunan                 | Keturunan/etnis, generasi ke-, keperluan                            |
| 456              | 456.0      | Surat Keterangan Naik Haji / Umrah             | Jenis ibadah, tahun keberangkatan, No. porsi haji, nama pendamping  |
| 441              | 441.1      | Surat Pengantar Bebas Narkoba                  | Keperluan tes, tempat tes, riwayat narkoba                          |
| 471              | 471.1      | Surat Keterangan untuk Paspor                  | Tujuan pembuatan paspor, alamat domisili (auto), No. KK (auto)      |
| 471              | 471.2      | Surat Keterangan Calon TKI / PMI               | Negara tujuan, jenis pekerjaan, lembaga penempatan, No. pendaftaran |
| 466              | 466.0      | Surat Izin Penggalangan Dana                   | Nama organisasi, tujuan, target dana, metode, periode               |
| 900              | 900.0      | Surat Keterangan Bebas PBB                     | No. SPPT PBB, lokasi objek, luas, bebas PBB sampai tahun            |
| 220              | 220.0      | Surat Keterangan Keaktifan Organisasi          | Nama organisasi, jenis, ketua, jumlah anggota, tahun berdiri        |
| 477              | 477.5      | Surat Keterangan Belum Ada Akta Lahir          | TTL anak, JK, anak ke-, NIK ayah/ibu, keperluan                     |
| 474              | 474.14     | Surat Keterangan untuk Lamaran Kerja           | Posisi/perusahaan dilamar, keperluan                                |
| 880              | 880.0      | Surat Keterangan Pensiun / Purna Tugas         | Jabatan terakhir, instansi, mulai tugas, tgl pensiun                |

---

## Konsolidasi (ringkas)

**Penggabungan duplikat:** 477.2→477.1 (Janda/Duda) · 474.11→474.10 (Pengantar Dok. Kependudukan) ·
465.3→465.1 (Penerima Bansos) · 140.5→140.0 (Izin Keramaian) · 475.4→475.2 (Alamat Sementara) ·
474.4.3→474.4 · 593.8→30.4 · 593.2→30.6 · 593.3→30.4 · 474.2.5→477.0 · 474.2.4→451.2 ·
474.1.1→477.5 · 140.2(lama)→180.0 · 474.1→477.3 (lahir mati).

**Dikeluarkan (luar kewenangan desa):** 550.2 Kepemilikan Kendaraan (Samsat/Polri) ·
300.2 Buku Pas Lintas (Syahbandar/KSOP) · 474.2.2 Pengantar Rujuk/Cerai (KUA/PA) ·
465.1.1 Beda Identitas KIS (non-aktif, duplikat 474.3).

**Total: ~85 jenis surat** (dari ~123 entri gabungan) — semua 100% online, tanpa duplikat fungsi.
