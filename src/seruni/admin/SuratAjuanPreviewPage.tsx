import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "../lib/tenant";

export function SuratAjuanPreviewPage() {
  const { id } = useParams<{ id: string }>();
  const tenantId = useTenantId();
  const [data, setData] = useState<any>(null);
  const [template, setTemplate] = useState<any>(null);
  const [umum, setUmum] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!id || !tenantId) return;

    const fetchData = async () => {
      setLoading(true);
      try {
        // Fetch ajuan and surat_jenis
        const { data: ajuan, error: ajuanError } = await supabase
          .from("surat_ajuan")
          .select("*, surat_jenis (nama, kode_surat), surat_ajuan_data (data_dna, data_identitas)")
          .eq("id", id)
          .single();

        if (ajuanError) throw ajuanError;

        // Fetch tenant settings for headers
        const [resT, resS, resTemplate] = await Promise.all([
          supabase.from("tenants").select("*").eq("id", tenantId).single(),
          supabase.from("site_settings").select("*").eq("tenant_id", tenantId).single(),
          supabase.from("surat_template").select("*").eq("tenant_id", tenantId).maybeSingle()
        ]);

        setData(ajuan);
        setUmum({ ...resT.data, ...resS.data });
        setTemplate(resTemplate.data || {
          format_nomor: "[KODE]/[NOMOR_URUT]/2026",
          pejabat_nama: "[Nama Pejabat]",
          pejabat_jabatan: "[Jabatan Pejabat]",
          penutup_teks: "Demikian surat keterangan ini dibuat dengan sebenarnya, untuk dipergunakan sebagaimana mestinya."
        });
      } catch (err: any) {
        console.error("Error fetching preview:", err);
        setErrorMsg(err.message || String(err));
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id, tenantId]);

  if (loading) return <div className="p-8 text-center text-muted-foreground">Memuat data...</div>;
  if (errorMsg) return <div className="p-8 text-center text-red-500 font-bold">Error: {errorMsg}</div>;
  if (!data) return <div className="p-8 text-center text-red-500 font-bold">Data ajuan tidak ditemukan.</div>;

  const ajuanData = Array.isArray(data.surat_ajuan_data) ? data.surat_ajuan_data[0] : data.surat_ajuan_data;
  const identitas = ajuanData?.data_identitas || {};
  const dna = ajuanData?.data_dna || {};
  const namaSurat = data.surat_jenis?.nama || "SURAT KETERANGAN";

  return (
    <div className="min-h-screen bg-gray-200 py-8 text-black" style={{ fontFamily: '"Times New Roman", Times, serif' }}>
      <div className="max-w-[210mm] min-h-[297mm] mx-auto bg-white shadow-lg print:shadow-none p-[20mm] print:p-0 print:m-0">
        
        {/* Header - Print Controls (Hidden when printing) */}
        <div className="mb-8 flex justify-end print:hidden border-b pb-4 border-gray-100">
          <button 
            onClick={() => window.print()} 
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-2"
          >
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6.728 9.69A3 3 0 0 0 6 11.815V19.5a.75.75 0 0 0 .75.75h10.5a.75.75 0 0 0 .75-.75v-7.685a3 3 0 0 0-.728-2.125m-10.5 0A3.375 3.375 0 0 1 9.75 6h4.5a3.375 3.375 0 0 1 2.25 1.19m-10.5 0v.75m10.5-.75v.75m-10.5 0h10.5" />
            </svg>
            Cetak Dokumen
          </button>
        </div>

        {/* Kop Surat */}
        <div className="flex items-center justify-between mb-4 pb-4 relative" style={{ borderBottom: "3px double black" }}>
          <div className="w-20 text-left">
            {umum?.logo_kabupaten_url ? (
              <img src={umum.logo_kabupaten_url} alt="Logo Kabupaten" className="w-20 h-24 object-contain" />
            ) : umum?.logo_url ? (
              <img src={umum.logo_url} alt="Logo Desa" className="w-20 h-24 object-contain" />
            ) : (
              <div className="w-20 h-24 bg-gray-200 flex items-center justify-center text-xs text-center border">Logo<br/>Kabupaten</div>
            )}
          </div>
          <div className="flex-1 text-center px-2">
            <h3 className="text-xl font-bold uppercase">PEMERINTAH KABUPATEN {umum?.kabupaten || "[KABUPATEN]"}</h3>
            <h3 className="text-xl font-bold uppercase">KECAMATAN {umum?.kecamatan || "[KECAMATAN]"}</h3>
            <h2 className="text-2xl font-bold uppercase">DESA {umum?.nama_desa || "[DESA]"}</h2>
            <p className="text-sm mt-1 italic">
              {umum?.alamat_kantor || "[Alamat Kantor]"} &nbsp;|&nbsp; Kode Pos: {umum?.kodepos || "..."}
            </p>
            <p className="text-sm italic">
              Email: <span>{umum?.email || "..."}</span> &nbsp;&nbsp; Web: <span>{umum?.website || "..."}</span>
            </p>
          </div>
          <div className="w-20 text-right">
            {umum?.logo_provinsi_url ? (
              <img src={umum.logo_provinsi_url} alt="Logo Provinsi" className="w-20 h-24 object-contain" />
            ) : (
              <div className="w-20 h-24" />
            )}
          </div>
        </div>

        {/* Nomor Surat */}
        <div className="text-center mb-8">
          <h4 className="text-lg font-bold underline underline-offset-4 uppercase">{namaSurat}</h4>
          <p className="text-sm">Nomor : {template?.format_nomor}</p>
        </div>

        {/* Identitas Penduduk */}
        <div className="mb-6 space-y-1">
          <p>Yang bertanda tangan di bawah ini:</p>
          <div className="grid grid-cols-[180px_10px_1fr] ml-4 mt-2">
            <div>Nama</div><div>:</div><div className="font-bold">{template?.pejabat_nama || "[Nama Pejabat]"}</div>
            <div>Jabatan</div><div>:</div><div>{template?.pejabat_jabatan || "[Jabatan Pejabat]"}</div>
          </div>
          <p className="mt-4">Dengan ini menerangkan bahwa:</p>
          <div className="grid grid-cols-[180px_10px_1fr] ml-4 text-sm mt-2 gap-y-1">
            <div>Nama Lengkap</div><div>:</div><div className="font-bold uppercase">{data.nama || "-"}</div>
            <div>NIK</div><div>:</div><div>{data.nik || "-"}</div>
            <div>Jenis Kelamin</div><div>:</div><div>{identitas.jenis_kelamin || "-"}</div>
            <div>Tempat, Tgl Lahir</div><div>:</div><div>{identitas.tempat_lahir || "-"}, {identitas.tanggal_lahir || identitas.tgl_lahir || "-"}</div>
            <div>Agama</div><div>:</div><div>{identitas.agama || "-"}</div>
            <div>Pekerjaan</div><div>:</div><div>{identitas.pekerjaan || "-"}</div>
            <div>Alamat</div><div>:</div><div>{identitas.alamat_lengkap || identitas.alamat || "-"}</div>
          </div>
        </div>

        {/* Data & Narasi (DNA) */}
        <div className="mb-6 mt-6">
          <p className="mb-2">Adapun menerangkan hal-hal sebagai berikut:</p>
          <div className="grid grid-cols-[180px_10px_1fr] ml-4 text-sm gap-y-1">
            {Object.keys(dna).length > 0 ? (
              Object.entries(dna).map(([key, value]) => (
                <React.Fragment key={key}>
                  <div className="capitalize">{key.replace(/_/g, ' ')}</div>
                  <div>:</div>
                  <div className="font-medium">{String(value)}</div>
                </React.Fragment>
              ))
            ) : (
              <div className="col-span-3 text-gray-500 italic">Tidak ada data tambahan.</div>
            )}
          </div>
        </div>

        {/* Penutup */}
        <div className="mb-12 mt-6">
          <p className="text-justify leading-relaxed indent-8">{template?.penutup_teks}</p>
        </div>

        {/* TTD */}
        <div className="flex justify-end mt-12 break-inside-avoid">
          <div className="text-center w-64">
            <p>{umum?.nama_desa || "[Nama Desa]"}, {new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}</p>
            <p className="font-bold mb-24">{template?.pejabat_jabatan || "[Jabatan]"}</p>
            <p className="font-bold underline">{template?.pejabat_nama || "[Nama Pejabat]"}</p>
          </div>
        </div>

      </div>
    </div>
  );
}
