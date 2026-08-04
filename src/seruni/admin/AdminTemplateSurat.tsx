import React, { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "../lib/tenant";
import { toast } from "sonner";
import { Save } from "lucide-react";

export default function AdminTemplateSurat() {
  const tenantId = useTenantId();
  const [busy, setBusy] = useState(false);
  const [umum, setUmum] = useState<any>({});
  
  const [template, setTemplate] = useState({
    format_nomor: "[kode_surat]/[nomor]/[singkatan_kades].[singkatan_desa]/[bulan_romawi]/[tahun]",
    pejabat_nama: "",
    pejabat_jabatan: "Kepala Desa",
    tujuan_teks: "Kepada Yth.",
    pembuka_teks: "Dengan hormat,",
    pengantar_teks: "Berdasarkan permohonan dari pihak yang bersangkutan, bersama ini kami sampaikan [jenis_surat] atas nama:",
    penutup_teks: "Demikian Surat Keterangan ini dibuat dengan sebenarnya untuk dapat dipergunakan sebagaimana mestinya.",
  });

  useEffect(() => {
    if (!tenantId) return;
    
    // Load data umum
    Promise.all([
      supabase.from("tenants").select("*").eq("id", tenantId).single(),
      supabase.from("site_settings").select("*").eq("tenant_id", tenantId).single(),
      supabase.from("surat_template").select("*").eq("tenant_id", tenantId).maybeSingle()
    ]).then(([resT, resS, resTemplate]: [any, any, any]) => {
      setUmum({ ...resT.data, ...resS.data });
      if (resTemplate.data) {
        setTemplate({
          format_nomor: resTemplate.data.format_nomor || "[kode_surat]/[nomor]/[singkatan_kades].[singkatan_desa]/[bulan_romawi]/[tahun]",
          pejabat_nama: resTemplate.data.pejabat_nama || "",
          pejabat_jabatan: resTemplate.data.pejabat_jabatan || "",
          tujuan_teks: resTemplate.data.tujuan_teks || "Kepada Yth.",
          pembuka_teks: resTemplate.data.pembuka_teks || "Dengan hormat,",
          pengantar_teks: resTemplate.data.pengantar_teks || "Berdasarkan permohonan dari pihak yang bersangkutan, bersama ini kami sampaikan [jenis_surat] atas nama:",
          penutup_teks: resTemplate.data.penutup_teks || "",
        });
      }
    });
  }, [tenantId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setTemplate(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const save = async () => {
    setBusy(true);
    try {
      const { data: existing } = await supabase.from("surat_template").select("id").eq("tenant_id", tenantId).maybeSingle();
      if (existing) {
        await supabase.from("surat_template").update(template).eq("id", existing.id);
      } else {
        await supabase.from("surat_template").insert({ ...template, tenant_id: tenantId, is_default: true });
      }
      toast.success("Pengaturan Template Surat berhasil disimpan!");
    } catch (e: any) {
      toast.error(e.message || "Gagal menyimpan pengaturan template.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="p-6 max-w-5xl mx-auto pb-24">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Pengaturan Template Surat</h1>
          <p className="text-muted-foreground text-sm">Sesuaikan format cetak surat dan identitas penandatangan.</p>
        </div>
        <button
          onClick={save}
          disabled={busy}
          className="bg-primary text-primary-foreground px-4 py-2 rounded-md hover:bg-primary/90 flex items-center gap-2"
        >
          <Save className="w-4 h-4" />
          Simpan
        </button>
      </div>

      <div className="grid lg:grid-cols-2 gap-8">
        <div className="space-y-6">
          <div className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
            <h2 className="text-lg font-semibold border-b pb-2">1. Pengaturan Kop Surat</h2>
            <p className="text-sm text-muted-foreground">Data Kop Surat diambil otomatis dari <strong>Pengaturan Umum</strong>. Pastikan data di Pengaturan Umum sudah lengkap.</p>
          </div>

          <div className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
            <h2 className="text-lg font-semibold border-b pb-2">2. Format Penomoran Surat</h2>
            <div className="space-y-2">
              <label className="text-sm font-medium">Format Nomor</label>
              <input name="format_nomor" value={template.format_nomor} onChange={handleChange} className="w-full border p-2 rounded text-sm" />
              <p className="text-xs text-muted-foreground">Gunakan tag: [kode_surat], [nomor], [singkatan_kades], [singkatan_desa], [bulan_romawi], [tahun]</p>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
            <h2 className="text-lg font-semibold border-b pb-2">3. Identitas Penandatangan</h2>
            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Nama Pejabat</label>
                <input name="pejabat_nama" value={template.pejabat_nama} onChange={handleChange} placeholder="Contoh: H. SUDIRMAN, S.E." className="w-full border p-2 rounded text-sm" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Jabatan</label>
                <input name="pejabat_jabatan" value={template.pejabat_jabatan} onChange={handleChange} placeholder="Contoh: Kepala Desa" className="w-full border p-2 rounded text-sm" />
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
            <h2 className="text-lg font-semibold border-b pb-2">6. Teks Penutup</h2>
              <div className="space-y-2">
                <label className="text-sm font-medium">Teks Tujuan</label>
                <input name="tujuan_teks" value={template.tujuan_teks} onChange={handleChange} className="w-full border p-2 rounded text-sm" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Teks Pembuka (Salam)</label>
                <input name="pembuka_teks" value={template.pembuka_teks} onChange={handleChange} className="w-full border p-2 rounded text-sm" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Teks Pengantar</label>
                <textarea name="pengantar_teks" value={template.pengantar_teks} onChange={handleChange} rows={2} className="w-full border p-2 rounded text-sm" />
                <p className="text-xs text-muted-foreground">Gunakan tag: [jenis_surat]</p>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Teks Penutup</label>
                <textarea name="penutup_teks" value={template.penutup_teks} onChange={handleChange} rows={3} className="w-full border p-2 rounded text-sm" />
              </div>
          </div>
        </div>

        {/* Live Preview */}
        <div>
          <h2 className="text-lg font-semibold mb-4">Preview Template (Draft)</h2>
          <div className="bg-white p-8 border rounded-lg shadow-sm min-h-[600px] text-black" style={{ fontFamily: '"Times New Roman", Times, serif' }}>
            {/* Kop Surat */}
            <div className="flex items-center justify-between mb-4 pb-4 relative" style={{ borderBottom: "3px double black" }}>
              <div className="w-20 text-left">
                {umum.logo_kabupaten_url ? (
                  <img src={umum.logo_kabupaten_url} alt="Logo Kabupaten" className="w-20 h-24 object-contain" />
                ) : umum.logo_url ? (
                  <img src={umum.logo_url} alt="Logo Desa" className="w-20 h-24 object-contain" />
                ) : (
                  <div className="w-20 h-24 bg-gray-200 flex items-center justify-center text-xs text-center border">Logo<br/>Kabupaten</div>
                )}
              </div>
              <div className="flex-1 text-center px-2">
                <h3 className="text-xl font-bold uppercase">PEMERINTAH KABUPATEN {umum.kabupaten || "[Nama Kabupaten]"}</h3>
                <h3 className="text-xl font-bold uppercase">KECAMATAN {umum.kecamatan || "[Nama Kecamatan]"}</h3>
                <h2 className="text-2xl font-bold uppercase">DESA {umum.nama_desa || "[Nama Desa]"}</h2>
                <p className="text-sm mt-1 italic">
                  {umum.alamat_kantor || "[Alamat]"} &nbsp;|&nbsp; Kode Pos: {umum.kodepos || "[Kodepos]"}
                </p>
                <p className="text-sm italic">
                  Email: <span className="text-blue-600">{umum.email || "[Email]"}</span> &nbsp;&nbsp; Web: <span className="text-blue-600">{umum.website || "[Website]"}</span>
                </p>
              </div>
              <div className="w-20 text-right">
                {umum.logo_provinsi_url ? (
                  <img src={umum.logo_provinsi_url} alt="Logo Provinsi" className="w-20 h-24 object-contain" />
                ) : (
                  <div className="w-20 h-24 bg-gray-50 flex items-center justify-center text-[10px] text-center border text-gray-400">Logo<br/>Provinsi<br/>(Opsional)</div>
                )}
              </div>
            </div>

            {/* Nomor Surat */}
            <div className="text-center mb-8">
              <h4 className="text-lg font-bold underline underline-offset-4 uppercase">SURAT KETERANGAN ...</h4>
              <p className="text-sm">Nomor : {template.format_nomor}</p>
            </div>

            {/* Identitas Penduduk */}
            <div className="mb-6 space-y-1">
              <p>Yang bertanda tangan di bawah ini:</p>
              <div className="grid grid-cols-[150px_10px_1fr]">
                <div>Nama</div><div>:</div><div className="font-bold">{template.pejabat_nama || "[Nama Pejabat]"}</div>
                <div>Jabatan</div><div>:</div><div>{template.pejabat_jabatan || "[Jabatan]"}</div>
              </div>
              <p className="mt-4">Dengan ini menerangkan bahwa:</p>
              <div className="grid grid-cols-[150px_10px_1fr] ml-4 text-sm mt-2">
                <div>Nama Lengkap</div><div>:</div><div>[Identitas Pemohon]</div>
                <div>NIK</div><div>:</div><div>[NIK Pemohon]</div>
                <div>Tempat, Tgl Lahir</div><div>:</div><div>[Tempat, Tgl Lahir]</div>
              </div>
            </div>

            {/* Data & Narasi (DNA) */}
            <div className="mb-6 min-h-[100px] border border-dashed border-gray-300 p-4 bg-gray-50 flex items-center justify-center">
              <span className="text-gray-500 italic">Bagian DNA (Data & Narasi Ajuan) akan tampil di sini sesuai dengan jenis surat.</span>
            </div>

            {/* Penutup */}
            <div className="mb-8">
              <p>{template.penutup_teks}</p>
            </div>

            {/* TTD */}
            <div className="flex justify-end mt-12">
              <div className="text-center w-64">
                <p>{umum.nama_desa || "[Nama Desa]"}, 31 Juli 2026</p>
                <p className="font-bold mb-20">{template.pejabat_jabatan || "[Jabatan]"}</p>
                <p className="font-bold underline">{template.pejabat_nama || "[Nama Pejabat]"}</p>
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>
  );
}
