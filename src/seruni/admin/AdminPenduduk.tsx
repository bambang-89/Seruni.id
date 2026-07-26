import { TableCrud } from "./AdminPages";
import { PendudukAdmin } from "./PendudukAdmin";
export function KeluargaAdmin() {
  return (
    <TableCrud
      table="keluarga"
      title="Kartu Keluarga"
      desc="Registri KK sebagai fondasi data penduduk."
      orderBy="no_kk"
      blank={{ no_kk: "", kepala_penduduk_id: "", alamat: "", dusun: "", rt: "", rw: "", catatan: "" } as any}
      columns={[
        { key: "no_kk", label: "Nomor KK" },
        { key: "kepala_penduduk_id", label: "Nama Kepala", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "id" } },
        { key: "dusun", label: "Dusun", type: "relation", relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } },
        { key: "rt", label: "RT" },
        { key: "rw", label: "RW" },
        { key: "alamat", label: "Alamat", type: "textarea" },
        { key: "catatan", label: "Catatan", type: "textarea" },
      ]}
    />
  );
}

export { PendudukAdmin };

export function BukuRegisterAdmin() {
  return (
    <TableCrud
      table="buku_register"
      title="Buku Register Administrasi"
      desc="Register administrasi umum desa: tamu, kejadian, keputusan, dsb."
      orderBy="tanggal"
      orderAsc={false}
      blank={{ jenis_buku: "", nomor: "", tanggal: null, uraian: "", pihak: "", lampiran_url: "", catatan: "" } as any}
      columns={[
        { key: "jenis_buku", label: "Jenis Buku", type: "select", options: [
          { value: "buku_tamu", label: "Buku Tamu" },
          { value: "buku_kejadian", label: "Buku Kejadian" },
          { value: "buku_keputusan_kades", label: "Keputusan Kepala Desa" },
          { value: "buku_peraturan_desa", label: "Peraturan Desa" },
          { value: "buku_agenda", label: "Agenda Surat" },
          { value: "buku_ekspedisi", label: "Ekspedisi Surat" },
          { value: "buku_inventaris", label: "Inventaris Aset" },
          { value: "buku_lainnya", label: "Lainnya" },
        ]},
        { key: "nomor", label: "Nomor" },
        { key: "tanggal", label: "Tanggal", type: "date" },
        { key: "pihak", label: "Pihak / Nama", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "nama" } },
        { key: "uraian", label: "Uraian", type: "textarea" },
        { key: "lampiran_url", label: "Lampiran", type: "image", imageFolder: "register" },
        { key: "catatan", label: "Catatan", type: "textarea" },
      ]}
    />
  );
}

export function IdmAdmin() {
  return (
    <TableCrud
      table="idm_indikator"
      title="IDM — Indikator Desa Membangun"
      desc="Indikator per dimensi IDM per tahun. Publikasikan untuk tampil di halaman IDM publik."
      orderBy="tahun"
      orderAsc={false}
      blank={{ tahun: new Date().getFullYear(), dimensi_nama: "IKS", indikator_nama: "", nilai: 0, skor: 0, sumber_data: "", keterangan: "", published: false } as any}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "dimensi_nama", label: "Dimensi", type: "select", options: [
          { value: "IKS", label: "IKS — Sosial" },
          { value: "IKE", label: "IKE — Ekonomi" },
          { value: "IKL", label: "IKL — Lingkungan/Ekologi" },
        ]},
        { key: "indikator_nama", label: "Indikator" },
        { key: "nilai", label: "Nilai Mentah", type: "number" },
        { key: "skor", label: "Skor (0-1)", type: "number" },
        { key: "sumber_data", label: "Sumber Data" },
        { key: "keterangan", label: "Keterangan", type: "textarea" },
        { key: "published", label: "Publikasi", type: "checkbox" },
      ]}
    />
  );
}

export function AnalisisAdmin() {
  return (
    <TableCrud
      table="analisis_snapshot"
      title="Analisis Desa"
      desc="Snapshot analisis / indikator gabungan (JSON) untuk ditayangkan publik."
      orderBy="tahun"
      orderAsc={false}
      blank={{ kategori: "kesehatan", judul: "", tahun: new Date().getFullYear(), nilai_json: {}, ringkasan: "", published: false } as any}
      columns={[
        { key: "kategori", label: "Kategori", type: "select", options: [
          { value: "kesehatan", label: "Kesehatan" },
          { value: "pendidikan", label: "Pendidikan" },
          { value: "ekonomi", label: "Ekonomi" },
          { value: "sosial", label: "Sosial" },
          { value: "infrastruktur", label: "Infrastruktur" },
          { value: "lingkungan", label: "Lingkungan" },
          { value: "pemerintahan", label: "Pemerintahan" },
        ]},
        { key: "judul", label: "Judul" },
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "ringkasan", label: "Ringkasan", type: "textarea" },
        { key: "published", label: "Publikasi", type: "checkbox" },
      ]}
    />
  );
}

export function SinkronLogAdmin() {
  return (
    <TableCrud
      table="sinkron_log"
      title="Log Sinkronisasi"
      desc="Riwayat pertukaran data ke sistem eksternal (Dukcapil, SIPD, Prodeskel, dsb)."
      orderBy="created_at"
      orderAsc={false}
      blank={{ target: "", arah: "keluar", status: "antre", jumlah: 0, pesan: "", payload: null } as any}
      columns={[
        { key: "target", label: "Sistem Target", type: "relation", relation: { table: "ref_sistem_target", labelCol: "nama", valueCol: "nama" } },
        { key: "arah", label: "Arah", type: "select", options: [
          { value: "keluar", label: "Keluar (kirim)" },
          { value: "masuk", label: "Masuk (terima)" },
        ]},
        { key: "status", label: "Status", type: "select", options: [
          { value: "antre", label: "Antre" }, { value: "berhasil", label: "Berhasil" }, { value: "gagal", label: "Gagal" },
        ]},
        { key: "jumlah", label: "Jumlah Record", type: "number" },
        { key: "pesan", label: "Pesan", type: "textarea" },
      ]}
    />
  );
}

export function SuplesiAdmin() {
  return (
    <TableCrud
      table="suplesi_data"
      title="Suplesi Data Warga"
      desc="Permintaan pembetulan / pemutakhiran data kependudukan."
      orderBy="created_at"
      orderAsc={false}
      blank={{ nik: "", nama: "", kontak: "", jenis: "koreksi_data", deskripsi: "", lampiran_url: "", status: "baru", tanggapan: "" } as any}
      columns={[
        { key: "nik", label: "NIK" },
        { key: "nama", label: "Nama", type: "relation", relation: { table: "penduduk", labelCol: "nama", valueCol: "nama" } },
        { key: "kontak", label: "Kontak" },
        { key: "jenis", label: "Jenis", type: "select", options: [
          { value: "koreksi_data", label: "Koreksi Data" },
          { value: "pindah_datang", label: "Pindah Datang" },
          { value: "pindah_keluar", label: "Pindah Keluar" },
          { value: "kematian", label: "Laporan Kematian" },
          { value: "kelahiran", label: "Laporan Kelahiran" },
          { value: "lainnya", label: "Lainnya" },
        ]},
        { key: "deskripsi", label: "Deskripsi", type: "textarea" },
        { key: "lampiran_url", label: "Lampiran", type: "image", imageFolder: "suplesi" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "baru", label: "Baru" }, { value: "diverifikasi", label: "Diverifikasi" },
          { value: "disetujui", label: "Disetujui" }, { value: "ditolak", label: "Ditolak" },
          { value: "selesai", label: "Selesai" },
        ]},
        { key: "tanggapan", label: "Tanggapan", type: "textarea" },
      ]}
    />
  );
}