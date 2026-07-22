import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { TableCrud } from "./AdminPages";

function useOptions(table: string, labelKey: string) {
  const [opts, setOpts] = useState<{ value: string; label: string }[]>([]);
  useEffect(() => {
    (supabase.from(table as any) as any).select("*").then(({ data }: any) => {
      setOpts((data || []).map((r: any) => ({ value: r.id, label: String(r[labelKey] ?? r.nama ?? r.id) })));
    });
  }, [table, labelKey]);
  return opts;
}

export function KeluargaAdmin() {
  return (
    <TableCrud
      table="keluarga"
      title="Kartu Keluarga"
      desc="Registri KK sebagai fondasi data penduduk."
      orderBy="no_kk"
      blank={{ no_kk: "", kepala_nama: "", alamat: "", dusun: "", rt: "", rw: "", catatan: "" } as any}
      columns={[
        { key: "no_kk", label: "Nomor KK" },
        { key: "kepala_nama", label: "Nama Kepala Keluarga" },
        { key: "dusun", label: "Dusun" },
        { key: "rt", label: "RT" },
        { key: "rw", label: "RW" },
        { key: "alamat", label: "Alamat", type: "textarea" },
        { key: "catatan", label: "Catatan", type: "textarea" },
      ]}
    />
  );
}

export function PendudukAdmin() {
  const kkOpts = useOptions("keluarga", "no_kk");
  return (
    <TableCrud
      table="penduduk"
      title="Penduduk"
      desc="Data warga desa (NIK unik). Menjadi rujukan modul surat, bansos, pemilu, dan analisis."
      orderBy="nama"
      blank={{
        nik: "", nama: "", jenis_kelamin: "L", tempat_lahir: "", tanggal_lahir: null,
        agama: "", pendidikan: "", pekerjaan: "", status_kawin: "", hubungan_kk: "",
        keluarga_id: null, dusun: "", alamat: "", foto_url: "", status_hidup: "hidup", catatan: "",
      } as any}
      columns={[
        { key: "nik", label: "NIK (16 digit)" },
        { key: "nama", label: "Nama Lengkap" },
        { key: "jenis_kelamin", label: "Jenis Kelamin", type: "select", options: [
          { value: "L", label: "Laki-laki" }, { value: "P", label: "Perempuan" },
        ]},
        { key: "tempat_lahir", label: "Tempat Lahir" },
        { key: "tanggal_lahir", label: "Tanggal Lahir", type: "date" },
        { key: "agama", label: "Agama" },
        { key: "pendidikan", label: "Pendidikan" },
        { key: "pekerjaan", label: "Pekerjaan" },
        { key: "status_kawin", label: "Status Kawin", type: "select", options: [
          { value: "", label: "—" },
          { value: "belum_kawin", label: "Belum Kawin" },
          { value: "kawin", label: "Kawin" },
          { value: "cerai_hidup", label: "Cerai Hidup" },
          { value: "cerai_mati", label: "Cerai Mati" },
        ]},
        { key: "hubungan_kk", label: "Hubungan dgn KK" },
        { key: "keluarga_id", label: "Kartu Keluarga", type: "select", options: [{ value: "", label: "— tidak dipilih —" }, ...kkOpts] },
        { key: "dusun", label: "Dusun" },
        { key: "alamat", label: "Alamat", type: "textarea" },
        { key: "foto_url", label: "Foto (URL)", type: "image", imageFolder: "penduduk" },
        { key: "status_hidup", label: "Status", type: "select", options: [
          { value: "hidup", label: "Hidup" }, { value: "meninggal", label: "Meninggal" }, { value: "pindah", label: "Pindah" },
        ]},
        { key: "catatan", label: "Catatan", type: "textarea" },
      ]}
    />
  );
}

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
        { key: "pihak", label: "Pihak / Nama" },
        { key: "uraian", label: "Uraian", type: "textarea" },
        { key: "lampiran_url", label: "Lampiran (URL)", type: "image", imageFolder: "register" },
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
      blank={{ tahun: new Date().getFullYear(), dimensi: "IKS", indikator: "", nilai: 0, skor: 0, sumber: "", keterangan: "", published: false } as any}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "dimensi", label: "Dimensi", type: "select", options: [
          { value: "IKS", label: "IKS — Sosial" },
          { value: "IKE", label: "IKE — Ekonomi" },
          { value: "IKL", label: "IKL — Lingkungan/Ekologi" },
        ]},
        { key: "indikator", label: "Indikator" },
        { key: "nilai", label: "Nilai Mentah", type: "number" },
        { key: "skor", label: "Skor (0-1)", type: "number" },
        { key: "sumber", label: "Sumber Data" },
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
        { key: "target", label: "Sistem Target" },
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
        { key: "nama", label: "Nama" },
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
        { key: "lampiran_url", label: "Lampiran (URL)", type: "image", imageFolder: "suplesi" },
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