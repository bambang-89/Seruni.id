import React from "react";
import { TableCrud } from "../components/TableCrud";
import { PageTitle } from "./AdminPages";

export function DusunAdmin() {
  return (
    <>
      <PageTitle title="Dusun" desc="Daftar dusun di desa ini." />
      <TableCrud
        table="wilayah_dusun"
        title="Data Dusun"
        desc="Kelola data dusun."
        orderBy="nama"
        blank={{ nama: "", kode: "", kepala_nama: "", kepala_nik: "", no_kk_kpl: "" } as any}
        columns={[
          { key: "nama", label: "Nama Dusun" },
          { key: "kode", label: "Kode Dusun" },
          { key: "kepala_nama", label: "Nama Kepala" },
          { key: "kepala_nik", label: "NIK Kepala" },
        ]}
      />
    </>
  );
}

export function RtAdmin() {
  return (
    <>
      <PageTitle title="Rukun Tetangga (RT)" desc="Daftar RT tidak didukung sebagai relasi tabel saat ini." />
      <div className="p-4 bg-amber-50 text-amber-800 rounded-md">
        Saat ini RT disimpan sebagai input teks bebas pada data penduduk.
      </div>
    </>
  );
}

export function RwAdmin() {
  return (
    <>
      <PageTitle title="Rukun Warga (RW)" desc="Daftar RW tidak didukung sebagai relasi tabel saat ini." />
      <div className="p-4 bg-amber-50 text-amber-800 rounded-md">
        Saat ini RW disimpan sebagai input teks bebas pada data penduduk.
      </div>
    </>
  );
}
