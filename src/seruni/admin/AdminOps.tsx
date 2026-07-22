import { useEffect, useState } from "react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { TableCrud, type Column } from "./AdminPages";
import { useBroadcasts, useBroadcastTargets, useEventLog } from "../lib/queries";

const WORKFLOW = [
  { value: "draft", label: "Draft" },
  { value: "diajukan", label: "Diajukan" },
  { value: "diverifikasi", label: "Diverifikasi" },
  { value: "diproses", label: "Diproses" },
  { value: "selesai", label: "Selesai" },
  { value: "ditolak", label: "Ditolak" },
];
const SEVERITY = [
  { value: "ringan", label: "Ringan" },
  { value: "sedang", label: "Sedang" },
  { value: "berat", label: "Berat" },
  { value: "kritis", label: "Kritis" },
];
const ADUAN_KATEGORI = [
  { value: "infrastruktur", label: "Infrastruktur" },
  { value: "layanan", label: "Layanan" },
  { value: "keamanan", label: "Keamanan" },
  { value: "lingkungan", label: "Lingkungan" },
  { value: "sosial", label: "Sosial" },
  { value: "lainnya", label: "Lainnya" },
];
const POTENSI_STATUS = [
  { value: "publish", label: "Publish" },
  { value: "draft", label: "Draft" },
];
const UMKM_TIPE = [
  { value: "umkm", label: "UMKM" },
  { value: "bumdes", label: "BUMDes" },
  { value: "koperasi", label: "Koperasi" },
];
const WISATA_JENIS = [
  { value: "bahari", label: "Bahari" },
  { value: "pegunungan", label: "Pegunungan" },
  { value: "budaya", label: "Budaya" },
  { value: "buatan", label: "Buatan" },
  { value: "kuliner", label: "Kuliner" },
];

const today = () => new Date().toISOString().slice(0, 10);

// ============ 1. Pertanahan ============
export function BidangTanahAdmin() {
  return (
    <TableCrud
      table="bidang_tanah"
      title="Pertanahan — Bidang Tanah"
      desc="Data persil tanah desa. Sensitif, hanya admin."
      orderBy="tanggal_daftar"
      orderAsc={false}
      blank={{ nomor_persil: "", pemilik_nama: "", pemilik_nik: "", dusun: "", luas_m2: 0, penggunaan: "", status_hak: "", nomor_sertifikat: "", tanggal_daftar: today(), catatan: "" }}
      columns={[
        { key: "nomor_persil", label: "No. Persil" },
        { key: "pemilik_nama", label: "Pemilik" },
        { key: "pemilik_nik", label: "NIK", hideInTable: true },
        { key: "dusun", label: "Dusun" },
        { key: "luas_m2", label: "Luas (m²)", type: "number", step: "0.01" },
        { key: "penggunaan", label: "Penggunaan" },
        { key: "status_hak", label: "Status Hak" },
        { key: "nomor_sertifikat", label: "No. Sertifikat", hideInTable: true },
        { key: "tanggal_daftar", label: "Tgl Daftar", type: "date" },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 2. Infrastruktur ============
export function InfrastrukturAdmin() {
  return (
    <TableCrud
      table="infrastruktur"
      title="Pembangunan — Infrastruktur"
      desc="Aset infrastruktur desa yang tampil di halaman Pembangunan."
      orderBy="nama"
      orderAsc
      blank={{ nama: "", jenis: "", dusun: "", kondisi: "baik", tahun_bangun: null, tahun_perbaikan: null, volume: "", sumber_dana: "", keterangan: "" }}
      columns={[
        { key: "nama", label: "Nama Aset" },
        { key: "jenis", label: "Jenis" },
        { key: "dusun", label: "Dusun" },
        { key: "kondisi", label: "Kondisi", type: "select", options: [
          { value: "baik", label: "Baik" },
          { value: "rusak-ringan", label: "Rusak Ringan" },
          { value: "rusak-berat", label: "Rusak Berat" },
        ]},
        { key: "tahun_bangun", label: "Th. Bangun", type: "number" },
        { key: "tahun_perbaikan", label: "Th. Perbaikan", type: "number", hideInTable: true },
        { key: "volume", label: "Volume", hideInTable: true },
        { key: "sumber_dana", label: "Sumber Dana", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 3. Kegiatan Pembangunan ============
export function KegiatanPembangunanAdmin() {
  return (
    <TableCrud
      table="kegiatan_pembangunan"
      title="Pembangunan — Kegiatan"
      desc="Kegiatan pembangunan tahunan. Perubahan status tercatat di log."
      orderBy="tahun"
      orderAsc={false}
      blank={{ tahun: new Date().getFullYear(), bidang: "", nama_kegiatan: "", lokasi: "", volume: "", anggaran: 0, realisasi: 0, sumber_dana: "", status: "draft", tanggal_mulai: null, tanggal_selesai: null, keterangan: "" }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "bidang", label: "Bidang" },
        { key: "nama_kegiatan", label: "Kegiatan" },
        { key: "lokasi", label: "Lokasi" },
        { key: "volume", label: "Volume", hideInTable: true },
        { key: "anggaran", label: "Anggaran", type: "number" },
        { key: "realisasi", label: "Realisasi", type: "number" },
        { key: "sumber_dana", label: "Sumber Dana", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "tanggal_mulai", label: "Mulai", type: "date", hideInTable: true },
        { key: "tanggal_selesai", label: "Selesai", type: "date", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 4. Posyandu ============
export function PosyanduAdmin() {
  return (
    <TableCrud
      table="posyandu_agregat"
      title="Posyandu — Rekap Bulanan"
      desc="Agregat posyandu per dusun per bulan."
      orderBy="periode"
      orderAsc={false}
      blank={{ periode: today(), dusun: "", jumlah_balita: 0, hadir: 0, gizi_baik: 0, gizi_kurang: 0, imunisasi_lengkap: 0, ibu_hamil_dilayani: 0, catatan: "" }}
      columns={[
        { key: "periode", label: "Periode", type: "date" },
        { key: "dusun", label: "Dusun" },
        { key: "jumlah_balita", label: "Balita", type: "number" },
        { key: "hadir", label: "Hadir", type: "number" },
        { key: "gizi_baik", label: "Gizi Baik", type: "number" },
        { key: "gizi_kurang", label: "Gizi Kurang", type: "number" },
        { key: "imunisasi_lengkap", label: "Imunisasi Lengkap", type: "number", hideInTable: true },
        { key: "ibu_hamil_dilayani", label: "Ibu Hamil Dilayani", type: "number", hideInTable: true },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 5. Stunting ============
export function StuntingAdmin() {
  return (
    <TableCrud
      table="stunting_agregat"
      title="Stunting — Rekap"
      desc="Agregat stunting per dusun per periode."
      orderBy="periode"
      orderAsc={false}
      blank={{ periode: today(), dusun: "", balita_diukur: 0, stunting: 0, wasting: 0, underweight: 0, intervensi: "" }}
      columns={[
        { key: "periode", label: "Periode", type: "date" },
        { key: "dusun", label: "Dusun" },
        { key: "balita_diukur", label: "Diukur", type: "number" },
        { key: "stunting", label: "Stunting", type: "number" },
        { key: "wasting", label: "Wasting", type: "number" },
        { key: "underweight", label: "Underweight", type: "number" },
        { key: "intervensi", label: "Intervensi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 6. Bantuan Sosial (program) ============
export function BansosAdmin() {
  return (
    <TableCrud
      table="bantuan_sosial"
      title="Sosial — Program Bantuan"
      desc="Program bansos yang berjalan di desa."
      orderBy="kode"
      orderAsc
      blank={{ kode: "", nama: "", sumber: "", deskripsi: "", periode_mulai: null, periode_selesai: null, kuota: null, aktif: true }}
      columns={[
        { key: "kode", label: "Kode" },
        { key: "nama", label: "Nama Program" },
        { key: "sumber", label: "Sumber" },
        { key: "kuota", label: "Kuota", type: "number" },
        { key: "periode_mulai", label: "Mulai", type: "date" },
        { key: "periode_selesai", label: "Selesai", type: "date" },
        { key: "aktif", label: "Aktif", type: "checkbox" },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 6b. Penerima Bansos (nested pilih program) ============
export function PenerimaBansosAdmin() {
  const [programs, setPrograms] = useState<{ id: string; nama: string; kode: string }[]>([]);
  const [bansosId, setBansosId] = useState<string>("");
  useEffect(() => {
    supabase.from("bantuan_sosial").select("id,nama,kode").order("nama").then(({ data }) => {
      const list = (data as any) || [];
      setPrograms(list);
      if (list.length && !bansosId) setBansosId(list[0].id);
    });
  }, []);

  if (!programs.length) {
    return (
      <div className="rounded-xl bg-card border border-border p-6 text-sm text-muted-foreground">
        Belum ada program bantuan sosial. Tambahkan program terlebih dahulu di menu "Program Bansos".
      </div>
    );
  }

  return (
    <div>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <label className="text-sm font-medium">Program:</label>
        <select
          value={bansosId}
          onChange={(e) => setBansosId(e.target.value)}
          className="rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          {programs.map((p) => (
            <option key={p.id} value={p.id}>{p.kode} — {p.nama}</option>
          ))}
        </select>
      </div>
      {bansosId && (
        <PenerimaBansosTable key={bansosId} bansosId={bansosId} />
      )}
    </div>
  );
}

function PenerimaBansosTable({ bansosId }: { bansosId: string }) {
  return (
    <TableCrud
      table="penerima_bansos"
      title="Sosial — Penerima"
      desc="Daftar penerima bansos untuk program terpilih."
      orderBy="nama"
      orderAsc
      blank={{ bansos_id: bansosId, nik: "", nama: "", dusun: "", status: "terdaftar", tanggal_salur: null, nominal: null, catatan: "" }}
      columns={[
        { key: "nik", label: "NIK" },
        { key: "nama", label: "Nama" },
        { key: "dusun", label: "Dusun" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "terdaftar", label: "Terdaftar" },
          { value: "diverifikasi", label: "Diverifikasi" },
          { value: "disalurkan", label: "Disalurkan" },
          { value: "dibatalkan", label: "Dibatalkan" },
        ]},
        { key: "tanggal_salur", label: "Tgl Salur", type: "date" },
        { key: "nominal", label: "Nominal", type: "number", step: "0.01" },
        { key: "catatan", label: "Catatan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 7. Bencana ============
export function BencanaAdmin() {
  return (
    <TableCrud
      table="bencana_kejadian"
      title="Bencana — Kejadian"
      desc="Catatan kejadian bencana di wilayah desa."
      orderBy="tanggal"
      orderAsc={false}
      blank={{ jenis: "", lokasi: "", dusun: "", tanggal: new Date().toISOString(), severity: "sedang", status: "diajukan", korban_jiwa: 0, korban_luka: 0, pengungsi: 0, kerugian_rp: 0, deskripsi: "", penanganan: "" }}
      columns={[
        { key: "jenis", label: "Jenis" },
        { key: "lokasi", label: "Lokasi" },
        { key: "dusun", label: "Dusun" },
        { key: "severity", label: "Severity", type: "select", options: SEVERITY },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "korban_jiwa", label: "Korban Jiwa", type: "number" },
        { key: "korban_luka", label: "Korban Luka", type: "number", hideInTable: true },
        { key: "pengungsi", label: "Pengungsi", type: "number", hideInTable: true },
        { key: "kerugian_rp", label: "Kerugian (Rp)", type: "number", step: "0.01", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "penanganan", label: "Penanganan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 8. Service Center — Aduan ============
export function AduanAdmin() {
  return (
    <TableCrud
      table="aduan_warga"
      title="Service Center — Aduan Warga"
      desc="Tiket aduan masuk. Tanggapi dan perbarui statusnya."
      orderBy="created_at"
      orderAsc={false}
      blank={{ nama_pelapor: "", kontak: "", kategori: "lainnya", judul: "", isi: "", lokasi: "", status: "diajukan", tanggapan: "" }}
      columns={[
        { key: "nomor_tiket", label: "No. Tiket", hideInTable: false, render: (r) => <span className="font-mono text-xs">{r.nomor_tiket}</span> },
        { key: "judul", label: "Judul" },
        { key: "nama_pelapor", label: "Pelapor" },
        { key: "kontak", label: "Kontak" },
        { key: "kategori", label: "Kategori", type: "select", options: ADUAN_KATEGORI },
        { key: "lokasi", label: "Lokasi", hideInTable: true },
        { key: "isi", label: "Isi Aduan", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: WORKFLOW },
        { key: "tanggapan", label: "Tanggapan Admin", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 9. Pemilu — DPT ============
export function DptAdmin() {
  return (
    <TableCrud
      table="dpt_pemilih"
      title="Pemilu — DPT"
      desc="Daftar Pemilih Tetap. Sensitif, akses admin saja."
      orderBy="nama"
      orderAsc
      blank={{ pemilu_kode: "", nik: "", nama: "", tempat_lahir: "", tanggal_lahir: null, jenis_kelamin: "L", dusun: "", rt: "", rw: "", tps: "", status: "aktif" }}
      columns={[
        { key: "pemilu_kode", label: "Kode Pemilu" },
        { key: "nik", label: "NIK" },
        { key: "nama", label: "Nama" },
        { key: "jenis_kelamin", label: "L/P", type: "select", options: [
          { value: "L", label: "Laki-laki" },
          { value: "P", label: "Perempuan" },
        ]},
        { key: "tempat_lahir", label: "Tempat Lahir", hideInTable: true },
        { key: "tanggal_lahir", label: "Tgl Lahir", type: "date", hideInTable: true },
        { key: "dusun", label: "Dusun" },
        { key: "rt", label: "RT" },
        { key: "rw", label: "RW" },
        { key: "tps", label: "TPS" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "aktif", label: "Aktif" },
          { value: "tidak-aktif", label: "Tidak Aktif" },
          { value: "pindah", label: "Pindah" },
          { value: "meninggal", label: "Meninggal" },
        ]},
      ]}
    />
  );
}

// ============ 10. Jenis Surat ============
export function JenisSuratAdmin() {
  return (
    <TableCrud
      table="surat_jenis"
      title="Layanan — Jenis Surat"
      desc="Katalog jenis surat (kode klasifikasi & DNA)."
      orderBy="kode_surat"
      orderAsc
      blank={{ kode_surat: "", kode_klasifikasi: "", nama: "", dna_field: "", aktif: true, urutan: 0 }}
      columns={[
        { key: "kode_surat", label: "Kode Surat" },
        { key: "kode_klasifikasi", label: "Kode Klasifikasi" },
        { key: "nama", label: "Nama Surat" },
        { key: "dna_field", label: "DNA Field", hideInTable: true },
        { key: "aktif", label: "Aktif", type: "checkbox" },
        { key: "urutan", label: "Urutan", type: "number" },
      ]}
    />
  );
}

// ============ 10b. Surat Terbit (verifikasi publik) ============
export function SuratTerbitAdmin() {
  return (
    <TableCrud
      table="surat_terbit"
      title="Layanan — Surat Terbit"
      desc="Daftar surat yang sudah diterbitkan. Nomor + kode verifikasi bisa dicek publik di halaman Verifikasi."
      orderBy="tanggal_terbit"
      orderAsc={false}
      blank={{ nomor_surat: "", kode_verifikasi: "", jenis_kode: "", jenis_nama: "", perihal: "", pemohon_nama: "", pemohon_nik: "", tanggal_terbit: today(), berlaku_sampai: null, status: "berlaku", penandatangan: "", keterangan: "" }}
      columns={[
        { key: "nomor_surat", label: "Nomor" },
        { key: "kode_verifikasi", label: "Kode Verifikasi" },
        { key: "jenis_kode", label: "Kode Jenis" },
        { key: "jenis_nama", label: "Jenis" },
        { key: "perihal", label: "Perihal" },
        { key: "pemohon_nama", label: "Pemohon" },
        { key: "pemohon_nik", label: "NIK Pemohon", hideInTable: true },
        { key: "tanggal_terbit", label: "Tgl Terbit", type: "date" },
        { key: "berlaku_sampai", label: "Berlaku Sampai", type: "date" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "berlaku", label: "Berlaku" },
          { value: "kadaluarsa", label: "Kadaluarsa" },
          { value: "dicabut", label: "Dicabut" },
        ]},
        { key: "penandatangan", label: "Ditandatangani", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 12. Langganan WA ============
export function LanggananWaAdmin() {
  return (
    <>
      <div className="mb-4 text-xs text-muted-foreground">
        Kelola pelanggan notifikasi WhatsApp. Untuk mengirim pesan, buka menu <b>Broadcast WA</b>.
      </div>
      <TableCrud
      table="langganan_wa"
      title="Notifikasi — Langganan WA"
      desc="Warga yang berlangganan notifikasi WhatsApp. Ekspor untuk broadcast."
      orderBy="created_at"
      orderAsc={false}
      blank={{ nama: "", nomor_wa: "", dusun: "", topik: [], status: "aktif" }}
      columns={[
        { key: "nama", label: "Nama" },
        { key: "nomor_wa", label: "Nomor WA" },
        { key: "dusun", label: "Dusun" },
        { key: "status", label: "Status", type: "select", options: [
          { value: "aktif", label: "Aktif" },
          { value: "nonaktif", label: "Nonaktif" },
        ]},
        { key: "topik", label: "Topik", hideInTable: true, render: (r: any) => Array.isArray(r.topik) ? r.topik.join(", ") : "-" },
      ]}
      />
    </>
  );
}

// ============ 13. PBB Tagihan ============
export function PbbAdmin() {
  const currentYear = new Date().getFullYear();
  return (
    <TableCrud
      table="pbb_tagihan"
      title="Pajak — PBB Tagihan"
      desc="Objek pajak PBB per tahun. Warga bisa mengecek NOP secara publik di halaman Layanan PBB."
      orderBy="nop"
      orderAsc
      blank={{ tahun: currentYear, nop: "", wajib_pajak_nama: "", wajib_pajak_nik: "", alamat_objek: "", dusun: "", luas_bumi_m2: 0, luas_bangunan_m2: 0, njop_bumi: 0, njop_bangunan: 0, pbb_terutang: 0, jatuh_tempo: `${currentYear}-09-30`, status_bayar: "belum_lunas", tanggal_bayar: null, metode_bayar: "", keterangan: "" }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "nop", label: "NOP" },
        { key: "wajib_pajak_nama", label: "Wajib Pajak" },
        { key: "wajib_pajak_nik", label: "NIK", hideInTable: true },
        { key: "alamat_objek", label: "Alamat Objek", hideInTable: true },
        { key: "dusun", label: "Dusun" },
        { key: "luas_bumi_m2", label: "Luas Bumi (m²)", type: "number", step: "0.01", hideInTable: true },
        { key: "luas_bangunan_m2", label: "Luas Bangunan (m²)", type: "number", step: "0.01", hideInTable: true },
        { key: "njop_bumi", label: "NJOP Bumi", type: "number", step: "0.01", hideInTable: true },
        { key: "njop_bangunan", label: "NJOP Bangunan", type: "number", step: "0.01", hideInTable: true },
        { key: "pbb_terutang", label: "PBB Terutang", type: "number", step: "0.01" },
        { key: "jatuh_tempo", label: "Jatuh Tempo", type: "date" },
        { key: "status_bayar", label: "Status", type: "select", options: [
          { value: "belum_lunas", label: "Belum Lunas" },
          { value: "lunas", label: "Lunas" },
          { value: "menunggak", label: "Menunggak" },
        ]},
        { key: "tanggal_bayar", label: "Tgl Bayar", type: "date", hideInTable: true },
        { key: "metode_bayar", label: "Metode Bayar", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 14. APBDes ============
export function ApbdesAdmin() {
  const currentYear = new Date().getFullYear();
  return (
    <TableCrud
      table="apbdes"
      title="Keuangan — APBDes"
      desc="Rincian pendapatan, belanja, dan pembiayaan APBDes. Publik dapat melihat di halaman Transparansi Keuangan."
      orderBy="urutan"
      orderAsc
      blank={{ tahun: currentYear, jenis: "belanja", kategori: "", sub_kategori: "", uraian: "", anggaran: 0, realisasi: 0, sumber_dana: "", keterangan: "", urutan: 0 }}
      columns={[
        { key: "tahun", label: "Tahun", type: "number" },
        { key: "jenis", label: "Jenis", type: "select", options: [
          { value: "pendapatan", label: "Pendapatan" },
          { value: "belanja", label: "Belanja" },
          { value: "pembiayaan", label: "Pembiayaan" },
        ]},
        { key: "kategori", label: "Kategori/Bidang" },
        { key: "sub_kategori", label: "Sub Kategori", hideInTable: true },
        { key: "uraian", label: "Uraian" },
        { key: "anggaran", label: "Anggaran", type: "number", step: "0.01" },
        { key: "realisasi", label: "Realisasi", type: "number", step: "0.01" },
        { key: "sumber_dana", label: "Sumber Dana" },
        { key: "urutan", label: "Urutan", type: "number", hideInTable: true },
        { key: "keterangan", label: "Keterangan", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

// ============ 11. Event Log (read only) ============
// ============ Phase 6B — Potensi UMKM / Produk / Wisata ============
export function UmkmAdmin() {
  return (
    <TableCrud
      table="potensi_umkm"
      title="Potensi — UMKM / BUMDes / Koperasi"
      desc="Lembaga & pelaku usaha desa yang tampil di halaman Potensi."
      orderBy="nama"
      orderAsc
      blank={{ tipe: "umkm", nama: "", pemilik: "", sektor: "", dusun: "", kontak: "", alamat: "", deskripsi: "", status: "publish" }}
      columns={[
        { key: "tipe", label: "Tipe", type: "select", options: UMKM_TIPE },
        { key: "nama", label: "Nama" },
        { key: "pemilik", label: "Pemilik / Pengelola" },
        { key: "sektor", label: "Sektor" },
        { key: "dusun", label: "Dusun" },
        { key: "kontak", label: "Kontak", hideInTable: true },
        { key: "alamat", label: "Alamat", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
      ]}
    />
  );
}

export function ProdukMarketplaceAdmin() {
  return (
    <TableCrud
      table="potensi_produk"
      title="Potensi — Produk Marketplace"
      desc="Katalog produk yang tampil di halaman Marketplace."
      orderBy="created_at"
      orderAsc={false}
      blank={{ penjual_nama: "", nama: "", kategori: "", harga: 0, satuan: "", stok: 0, deskripsi: "", foto_url: "", featured: false, status: "publish" }}
      columns={[
        { key: "nama", label: "Produk" },
        { key: "penjual_nama", label: "Penjual" },
        { key: "kategori", label: "Kategori" },
        { key: "harga", label: "Harga", type: "number", step: "0.01" },
        { key: "satuan", label: "Satuan" },
        { key: "stok", label: "Stok", type: "number" },
        { key: "featured", label: "Unggulan", type: "checkbox" },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
        { key: "foto_url", label: "Foto Produk", type: "image", imageFolder: "produk", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
      ]}
    />
  );
}

export function WisataAdmin() {
  return (
    <TableCrud
      table="potensi_wisata"
      title="Potensi — Destinasi Wisata"
      desc="Destinasi wisata yang tampil di halaman Potensi dan Peta Interaktif."
      orderBy="nama"
      orderAsc
      blank={{ nama: "", jenis: "bahari", dusun: "", deskripsi: "", latitude: null, longitude: null, foto_url: "", fasilitas: "", status: "publish" }}
      columns={[
        { key: "nama", label: "Nama" },
        { key: "jenis", label: "Jenis", type: "select", options: WISATA_JENIS },
        { key: "dusun", label: "Dusun" },
        { key: "latitude", label: "Latitude", type: "number", step: "0.000001" },
        { key: "longitude", label: "Longitude", type: "number", step: "0.000001" },
        { key: "fasilitas", label: "Fasilitas", hideInTable: true },
        { key: "foto_url", label: "Foto Destinasi", type: "image", imageFolder: "wisata", hideInTable: true },
        { key: "deskripsi", label: "Deskripsi", type: "textarea", hideInTable: true },
        { key: "status", label: "Status", type: "select", options: POTENSI_STATUS },
      ]}
    />
  );
}

export function EventLogAdmin() {
  const [entitas, setEntitas] = useState("");
  const [event, setEvent] = useState("");
  const [sejak, setSejak] = useState("");
  const { rows, loading, reload } = useEventLog({ entitas, event, sejak, limit: 300 });

  const eksporCsv = () => {
    const header = ["waktu", "event", "entitas", "entitas_id", "actor_nama", "actor_nik", "payload"];
    const lines = [header.join(",")].concat(
      rows.map((r) =>
        [
          new Date(r.created_at).toISOString(),
          r.event_name,
          r.entitas || "",
          r.entitas_id || "",
          r.actor_nama || "",
          r.actor_nik || "",
          `"${JSON.stringify(r.payload).replace(/"/g, '""')}"`,
        ].join(","),
      ),
    );
    const blob = new Blob([lines.join("\n")], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `event-log-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const badgeColor = (ev: string) => {
    if (ev.endsWith(".dihapus")) return "bg-red-100 text-red-800";
    if (ev.endsWith(".dipublish")) return "bg-emerald-100 text-emerald-800";
    if (ev.endsWith(".di_unpublish")) return "bg-amber-100 text-amber-800";
    if (ev.endsWith(".dibuat")) return "bg-sky-100 text-sky-800";
    return "bg-muted text-muted-foreground";
  };

  return (
    <>
      <div className="mb-6 flex items-end justify-between gap-4 flex-wrap">
        <div>
          <h1 className="font-display text-2xl font-bold">Event Log</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Jejak audit semua aksi admin (buat, ubah, hapus, publish/unpublish).
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={reload} className="rounded-md border border-border px-3 py-2 text-sm hover:bg-muted">Muat ulang</button>
          <button onClick={eksporCsv} className="rounded-md bg-primary text-primary-foreground px-3 py-2 text-sm hover:bg-primary/90">Ekspor CSV</button>
        </div>
      </div>

      <div className="mb-4 grid gap-3 sm:grid-cols-3 rounded-xl border border-border bg-card p-4">
        <label className="text-xs">
          <span className="block mb-1 font-medium">Entitas</span>
          <input value={entitas} onChange={(e) => setEntitas(e.target.value)} placeholder="mis. berita, aduan_warga" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
        </label>
        <label className="text-xs">
          <span className="block mb-1 font-medium">Event mengandung</span>
          <input value={event} onChange={(e) => setEvent(e.target.value)} placeholder="mis. dipublish, dihapus" className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
        </label>
        <label className="text-xs">
          <span className="block mb-1 font-medium">Sejak</span>
          <input type="datetime-local" value={sejak} onChange={(e) => setSejak(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
        </label>
      </div>

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Waktu</th>
              <th className="text-left px-4 py-3">Event</th>
              <th className="text-left px-4 py-3">Entitas</th>
              <th className="text-left px-4 py-3">Pelaku</th>
              <th className="text-left px-4 py-3">Detail</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={5} className="px-4 py-6 text-center text-muted-foreground">Belum ada aktivitas.</td></tr>}
            {rows.map((r) => {
              const diff = r.payload?.diff;
              return (
                <tr key={r.id} className="border-t border-border align-top">
                  <td className="px-4 py-3 tabular-nums whitespace-nowrap text-xs">{new Date(r.created_at).toLocaleString("id-ID")}</td>
                  <td className="px-4 py-3">
                    <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-mono ${badgeColor(r.event_name)}`}>{r.event_name}</span>
                  </td>
                  <td className="px-4 py-3 text-xs">
                    <div>{r.entitas}</div>
                    <div className="text-muted-foreground text-[10px] font-mono">{r.entitas_id?.slice(0, 8)}</div>
                  </td>
                  <td className="px-4 py-3 text-xs">
                    {r.actor_nama ? (
                      <>
                        <div className="font-medium">{r.actor_nama}</div>
                        {r.actor_nik && <div className="text-muted-foreground text-[10px] tabular-nums">NIK {r.actor_nik}</div>}
                      </>
                    ) : (
                      <span className="text-muted-foreground italic">sistem/warga</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-xs">
                    {diff && Object.keys(diff).length > 0 ? (
                      <ul className="space-y-1">
                        {Object.entries(diff).slice(0, 6).map(([k, v]: any) => (
                          <li key={k} className="font-mono text-[11px]">
                            <b>{k}</b>: <span className="text-red-600 line-through">{JSON.stringify(v.dari)}</span> → <span className="text-emerald-700">{JSON.stringify(v.ke)}</span>
                          </li>
                        ))}
                      </ul>
                    ) : r.payload?.pk ? (
                      <span className="font-mono text-[10px] text-muted-foreground">pk {String(r.payload.pk).slice(0, 8)}</span>
                    ) : (
                      <span className="font-mono text-[10px] text-muted-foreground">{JSON.stringify(r.payload).slice(0, 80)}</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ============ 15. Broadcast WA Dashboard ============

export function BroadcastAdmin() {
  const [reloadKey, setReloadKey] = useState(0);
  const { rows, loading } = useBroadcasts(reloadKey);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const badge = (s: string) => {
    const cls =
      s === "selesai" ? "bg-emerald-100 text-emerald-800" :
      s === "gagal" ? "bg-red-100 text-red-800" :
      s === "berjalan" ? "bg-sky-100 text-sky-800" :
      "bg-muted text-muted-foreground";
    return <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-medium uppercase ${cls}`}>{s}</span>;
  };

  return (
    <>
      <div className="mb-6 flex items-end justify-between gap-4 flex-wrap">
        <div>
          <h1 className="font-display text-2xl font-bold">Broadcast WhatsApp</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Riwayat pengiriman broadcast, status per target, dan kirim ulang untuk target gagal.
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setReloadKey((k) => k + 1)} className="rounded-md border border-border px-3 py-2 text-sm hover:bg-muted">Muat ulang</button>
          <button onClick={() => setShowForm((v) => !v)} className="rounded-md bg-primary text-primary-foreground px-3 py-2 text-sm hover:bg-primary/90">
            {showForm ? "Tutup form" : "Kirim broadcast baru"}
          </button>
        </div>
      </div>

      {showForm && <BroadcastForm onDone={() => { setShowForm(false); setReloadKey((k) => k + 1); }} />}

      <div className="overflow-x-auto rounded-xl bg-card border border-border">
        <table className="w-full text-sm">
          <thead className="bg-muted">
            <tr>
              <th className="text-left px-4 py-3">Waktu</th>
              <th className="text-left px-4 py-3">Pesan</th>
              <th className="text-left px-4 py-3">Filter</th>
              <th className="text-right px-4 py-3">Target</th>
              <th className="text-right px-4 py-3">Sukses</th>
              <th className="text-right px-4 py-3">Gagal</th>
              <th className="text-left px-4 py-3">Status</th>
              <th className="text-left px-4 py-3">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={8} className="px-4 py-6 text-center text-muted-foreground">Belum ada broadcast.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-t border-border align-top">
                <td className="px-4 py-3 tabular-nums text-xs whitespace-nowrap">{new Date(r.created_at).toLocaleString("id-ID")}</td>
                <td className="px-4 py-3 text-xs max-w-[320px]">
                  {r.judul && <div className="font-medium">{r.judul}</div>}
                  <div className="text-muted-foreground line-clamp-2">{r.pesan}</div>
                  {r.dry_run && <span className="text-[10px] italic text-amber-700">mode uji</span>}
                </td>
                <td className="px-4 py-3 text-xs">
                  {r.dusun_filter && <div>Dusun: {r.dusun_filter}</div>}
                  {r.topik && <div>Topik: {r.topik}</div>}
                  {!r.dusun_filter && !r.topik && <span className="text-muted-foreground">Semua</span>}
                </td>
                <td className="px-4 py-3 text-right tabular-nums">{r.total_target}</td>
                <td className="px-4 py-3 text-right tabular-nums text-emerald-700">{r.total_sukses}</td>
                <td className="px-4 py-3 text-right tabular-nums text-red-700">{r.total_gagal}</td>
                <td className="px-4 py-3">{badge(r.status)}</td>
                <td className="px-4 py-3">
                  <button onClick={() => setSelectedId(r.id)} className="text-xs underline hover:text-primary">
                    Detail →
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {selectedId && <BroadcastDetail id={selectedId} onClose={() => setSelectedId(null)} onRefresh={() => setReloadKey((k) => k + 1)} />}
    </>
  );
}

function BroadcastForm({ onDone }: { onDone: () => void }) {
  const [judul, setJudul] = useState("");
  const [pesan, setPesan] = useState("");
  const [dusun, setDusun] = useState("");
  const [topik, setTopik] = useState("");
  const [busy, setBusy] = useState(false);

  const kirim = async () => {
    if (!pesan.trim()) return toast.error("Pesan wajib diisi.");
    if (!confirm("Kirim broadcast sekarang?")) return;
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("wa-broadcast", {
      body: { judul: judul || undefined, pesan, dusun: dusun || undefined, topik: topik || undefined },
    });
    setBusy(false);
    if (error) return toast.error(error.message);
    if (data?.dryRun) toast.info(`Mode uji: ${data.total} target tercatat (FONNTE_TOKEN belum diset).`);
    else toast.success(`Terkirim: ${data?.sukses ?? 0} dari ${data?.total ?? 0}.`);
    setJudul(""); setPesan(""); setDusun(""); setTopik("");
    onDone();
  };

  return (
    <div className="mb-6 rounded-xl bg-card border border-border p-5 space-y-3">
      <h2 className="font-display text-lg font-semibold">Broadcast baru</h2>
      <div className="grid sm:grid-cols-2 gap-3">
        <label className="text-xs"><span className="block mb-1">Judul internal (opsional)</span>
          <input value={judul} onChange={(e) => setJudul(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="mis. Info Musdes Juli" />
        </label>
        <label className="text-xs"><span className="block mb-1">Filter Dusun (opsional)</span>
          <input value={dusun} onChange={(e) => setDusun(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Kosongkan = semua dusun" />
        </label>
        <label className="text-xs sm:col-span-2"><span className="block mb-1">Filter Topik (opsional)</span>
          <input value={topik} onChange={(e) => setTopik(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="mis. Pengumuman Resmi, Info Bencana" />
        </label>
      </div>
      <label className="text-xs block"><span className="block mb-1">Isi Pesan</span>
        <textarea rows={4} value={pesan} onChange={(e) => setPesan(e.target.value)} className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Contoh: [Info Desa] Musdes Sabtu 20 Juli 09.00 di Kantor Desa." />
      </label>
      <button onClick={kirim} disabled={busy} className="rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60">
        {busy ? "Mengirim…" : "Kirim sekarang"}
      </button>
    </div>
  );
}

function BroadcastDetail({ id, onClose, onRefresh }: { id: string; onClose: () => void; onRefresh: () => void }) {
  const [reloadKey, setReloadKey] = useState(0);
  const { rows, loading } = useBroadcastTargets(id, reloadKey);
  const [busy, setBusy] = useState(false);

  const gagalCount = rows.filter((r) => r.status === "gagal" || r.status === "pending").length;

  const retry = async () => {
    if (!confirm(`Kirim ulang ${gagalCount} target yang gagal/tertunda?`)) return;
    setBusy(true);
    const { data, error } = await supabase.functions.invoke("wa-broadcast", {
      body: { action: "retry", broadcastId: id },
    });
    setBusy(false);
    if (error) return toast.error(error.message);
    toast.success(`Retry: sukses ${data?.sukses ?? 0}, gagal ${data?.gagal ?? 0}.`);
    setReloadKey((k) => k + 1);
    onRefresh();
  };

  const badge = (s: string) => {
    const cls =
      s === "sukses" ? "bg-emerald-100 text-emerald-800" :
      s === "gagal" ? "bg-red-100 text-red-800" :
      "bg-amber-100 text-amber-800";
    return <span className={`inline-block rounded px-2 py-0.5 text-[10px] font-medium uppercase ${cls}`}>{s}</span>;
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-start justify-center p-4 sm:p-8 overflow-y-auto" role="dialog" aria-modal="true">
      <div className="bg-background border border-border w-full max-w-4xl shadow-2xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-border">
          <h2 className="font-display text-lg font-semibold">Detail Broadcast · {rows.length} target</h2>
          <div className="flex gap-2">
            {gagalCount > 0 && (
              <button onClick={retry} disabled={busy} className="rounded-md bg-primary text-primary-foreground px-3 py-1.5 text-sm hover:bg-primary/90 disabled:opacity-60">
                {busy ? "Mengirim…" : `Kirim ulang ${gagalCount} gagal`}
              </button>
            )}
            <button onClick={onClose} className="rounded-md border border-border px-3 py-1.5 text-sm hover:bg-muted">Tutup</button>
          </div>
        </div>
        <div className="max-h-[70vh] overflow-y-auto">
          <table className="w-full text-sm">
            <thead className="bg-muted sticky top-0">
              <tr>
                <th className="text-left px-4 py-2">Nomor</th>
                <th className="text-left px-4 py-2">Nama</th>
                <th className="text-left px-4 py-2">Dusun</th>
                <th className="text-left px-4 py-2">Status</th>
                <th className="text-right px-4 py-2">Percobaan</th>
                <th className="text-left px-4 py-2">Terkirim</th>
                <th className="text-left px-4 py-2">Error</th>
              </tr>
            </thead>
            <tbody>
              {loading && <tr><td colSpan={7} className="px-4 py-6 text-center text-muted-foreground">Memuat…</td></tr>}
              {rows.map((t) => (
                <tr key={t.id} className="border-t border-border align-top">
                  <td className="px-4 py-2 tabular-nums text-xs">{t.nomor_tujuan}</td>
                  <td className="px-4 py-2 text-xs">{t.nama || "-"}</td>
                  <td className="px-4 py-2 text-xs">{t.dusun || "-"}</td>
                  <td className="px-4 py-2">{badge(t.status)}</td>
                  <td className="px-4 py-2 text-right tabular-nums text-xs">{t.attempt}</td>
                  <td className="px-4 py-2 text-xs">{t.sent_at ? new Date(t.sent_at).toLocaleString("id-ID") : "-"}</td>
                  <td className="px-4 py-2 text-xs text-red-700 max-w-[240px] break-words">{t.error_message || "-"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}