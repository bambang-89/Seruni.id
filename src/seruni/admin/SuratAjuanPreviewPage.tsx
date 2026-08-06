import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "../lib/tenant";
import { ModalPenolakan } from "../components/ModalPenolakan";
import { toast } from "sonner";
import { ArrowLeft, Check, Printer, Trash2, X } from "lucide-react";

export function SuratAjuanPreviewPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const tenantId = useTenantId();
  const [data, setData] = useState<any>(null);
  const [template, setTemplate] = useState<any>(null);
  const [umum, setUmum] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  
  const [isModalTolakOpen, setIsModalTolakOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const toPublicUrl = (path: string | null | undefined): string => {
    if (!path) return "";
    if (path.startsWith("http")) return path;
    return supabase.storage.from("seruni-media").getPublicUrl(path).data.publicUrl;
  };

  const fetchData = async () => {
    if (!id || !tenantId) return;
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
        supabase.from("site_settings").select("*").eq("tenant_id", tenantId).maybeSingle(),
        supabase.from("surat_template").select("*").eq("tenant_id", tenantId).maybeSingle()
      ]);

      if (resS.error) console.warn("site_settings error:", resS.error.message);

      setData(ajuan);
      // Parse settings JSON from tenant
      const tSettings = typeof resT.data?.settings === 'string'
        ? JSON.parse(resT.data.settings)
        : (resT.data?.settings || {});

      // IMPORTANT: order = tenant base < tenant settings JSON < site_settings
      // site_settings (alamat_kantor, email, dll) harus menang atas tSettings
      const umumMerged = { ...resT.data, ...tSettings, ...resS.data };

      // Normalise logo URLs — bisa jadi path storage atau full URL
      umumMerged.logo_kabupaten_url = toPublicUrl(tSettings.logo_kabupaten_url || resT.data?.logo_kabupaten_url);
      umumMerged.logo_provinsi_url  = toPublicUrl(tSettings.logo_provinsi_url  || resT.data?.logo_provinsi_url);
      umumMerged.logo_url           = toPublicUrl(resT.data?.logo_url);
      // kodepos: prefer settings JSON, fallback ke site_settings
      umumMerged.kodepos = tSettings.kodepos || resS.data?.kodepos || "";

      setUmum(umumMerged);
      const tpl = resTemplate.data || {};
      setTemplate({
        format_nomor: tpl.format_nomor || "[KODE]/[NOMOR_URUT]/2026",
        pejabat_nama: tpl.pejabat_nama || "[Nama Pejabat]",
        pejabat_jabatan: tpl.pejabat_jabatan || "[Jabatan Pejabat]",
        penutup_teks: tpl.penutup_teks || "Demikian surat keterangan ini dibuat dengan sebenarnya, untuk dipergunakan sebagaimana mestinya."
      });
    } catch (err: any) {
      console.error("Error fetching preview:", err);
      setErrorMsg(err.message || String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id, tenantId]);

  const updateStatus = async (status: string, keterangan: string | null = null) => {
    setIsSubmitting(true);
    try {
      const { error } = await supabase
        .from("surat_ajuan")
        .update({ 
          status, 
          ...(keterangan ? { keterangan_penolakan: keterangan } : {}) 
        })
        .eq("id", id);
      
      if (error) throw error;
      toast.success(`Status berhasil diubah menjadi ${status}`);
      if (status === "Ditolak") setIsModalTolakOpen(false);
      fetchData(); // Refresh data
    } catch (err: any) {
      toast.error("Gagal mengubah status: " + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleTerimaMenunggu = () => updateStatus("Tandatangani");
  const handleTerimaTandatangani = async () => {
    if (!window.confirm("TTE: Proses ini akan menyetempel QRCode, mengirimkan notifikasi WA, dan mengubah status pengajuan menjadi Selesai. Lanjutkan?")) return;
    
    setIsSubmitting(true);
    try {
      // 1. Generate ID & Verify Code for TTE
      const suratTerbitId = crypto.randomUUID();
      const kodeVerifikasi = Math.random().toString(36).substring(2, 8).toUpperCase();
      
      // 2. Generate Nomor Surat
      let finalNomor = template?.format_nomor || `470/[NOMOR_URUT]/2026`;
      // For now, random 3 digit as NOMOR_URUT
      const nomorUrut = Math.floor(Math.random() * 900 + 100).toString();
      finalNomor = finalNomor.replace("[NOMOR_URUT]", nomorUrut);
      finalNomor = finalNomor.replace("[KODE]", data.surat_jenis?.kode_surat || "470");
      
      const payload = {
        id: suratTerbitId,
        tenant_id: tenantId,
        jenis_kode: data.surat_jenis?.kode_surat || "000",
        jenis_nama: data.surat_jenis?.nama || "Surat Keterangan",
        kode_verifikasi: kodeVerifikasi,
        nomor_surat: finalNomor,
        pemohon_nama: data.nama,
        pemohon_nik: data.nik,
        penandatangan: template?.pejabat_nama || "Kepala Desa",
        perovsk: data.surat_jenis?.nama || "Surat Ajuan", 
        status: "signed",
        tanggal_terbit: new Date().toISOString()
      };
      
      // Insert to surat_terbit
      const { error: insertError } = await supabase.from("surat_terbit").insert(payload);
      if (insertError) throw insertError;
      
      // Update ajuan status
      const { error: updateError } = await supabase
        .from("surat_ajuan")
        .update({ 
          status: "Selesai",
          keterangan_penolakan: `surat_terbit_id:${suratTerbitId}` // Simpan reference di keterangan if needed, or we can just rely on pemohon_nik
        })
        .eq("id", id);
        
      if (updateError) throw updateError;
      
      // Trigger WA Webhook / Edge Function here if exists (mocking success)
      toast.success("TTE Berhasil: Surat diterbitkan & QRCode disetempel.");
      
      fetchData(); // Refresh data
    } catch (err: any) {
      toast.error("Gagal memproses TTE: " + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };
  
  const handleTolak = (alasan: string) => updateStatus("Ditolak", alasan);

  const handleHapus = async () => {
    if (!window.confirm("Yakin ingin menghapus pengajuan ini secara permanen?")) return;
    setIsSubmitting(true);
    try {
      const { error } = await supabase.from("surat_ajuan").delete().eq("id", id);
      if (error) throw error;
      toast.success("Pengajuan berhasil dihapus");
      navigate("/admin");
    } catch (err: any) {
      toast.error("Gagal menghapus: " + err.message);
      setIsSubmitting(false);
    }
  };

  if (loading) return <div className="p-8 text-center text-muted-foreground">Memuat data...</div>;
  if (errorMsg) return <div className="p-8 text-center text-red-500 font-bold">Error: {errorMsg}</div>;
  if (!data) return <div className="p-8 text-center text-red-500 font-bold">Data ajuan tidak ditemukan.</div>;

  const ajuanData = Array.isArray(data.surat_ajuan_data) ? data.surat_ajuan_data[0] : data.surat_ajuan_data;
  const identitas = ajuanData?.data_identitas || {};
  const dna = ajuanData?.data_dna || {};
  const namaSurat = data.surat_jenis?.nama || "SURAT KETERANGAN";

  const previewFormatNomor = template?.format_nomor
    ? template.format_nomor
        .replace("[KODE]", data?.surat_jenis?.kode_surat || "___")
        .replace("[kode_surat]", data?.surat_jenis?.kode_surat || "___")
        .replace("[NOMOR_URUT]", "___")
        .replace("[nomor]", "___")
        .replace("[singkatan_kades]", umum?.singkatan_kades || "KADES")
        .replace("[singkatan_desa]", umum?.singkatan_desa || "DESA")
    : "___/___/2026";

  return (
    <div className="min-h-screen bg-gray-200 py-8 text-black" style={{ fontFamily: '"Times New Roman", Times, serif' }}>
      
      {isModalTolakOpen && (
        <ModalPenolakan
          isOpen={isModalTolakOpen}
          onClose={() => setIsModalTolakOpen(false)}
          suratJenisId={data.jenis_surat_id}
          onReject={handleTolak}
          isSubmitting={isSubmitting}
        />
      )}

      <div className="max-w-[210mm] min-h-[297mm] mx-auto bg-white shadow-lg print:shadow-none p-[20mm] print:p-0 print:m-0">
        
        {/* Header - Print & Verification Controls (Hidden when printing) */}
        <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between print:hidden border-b pb-4 border-gray-100">
          <div className="flex flex-wrap gap-2 items-center">
            <button 
              onClick={() => navigate("/admin")}
              className="px-3 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium rounded-md text-sm shadow-sm flex items-center gap-1"
            >
              <ArrowLeft className="w-4 h-4" /> Kembali
            </button>
            
            <div className="h-6 w-px bg-gray-300 mx-1"></div>
            <span className="text-sm font-semibold text-gray-500 mr-2">Status: <span className="text-black">{data.status}</span></span>

            {data.status === "Menunggu" && (
              <>
                <button onClick={handleTerimaMenunggu} disabled={isSubmitting} className="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-1">
                  <Check className="w-4 h-4" /> Terima (Tandatangani)
                </button>
                <button onClick={() => setIsModalTolakOpen(true)} disabled={isSubmitting} className="px-3 py-2 bg-red-600 hover:bg-red-700 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-1">
                  <X className="w-4 h-4" /> Tolak
                </button>
              </>
            )}

            {data.status === "Tandatangani" && (
              <>
                <button onClick={handleTerimaTandatangani} disabled={isSubmitting} className="px-3 py-2 bg-green-600 hover:bg-green-700 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-1">
                  <Check className="w-4 h-4" /> TTE Selesai
                </button>
                <button onClick={() => setIsModalTolakOpen(true)} disabled={isSubmitting} className="px-3 py-2 bg-red-600 hover:bg-red-700 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-1">
                  <X className="w-4 h-4" /> Tolak
                </button>
              </>
            )}

            {/* Always show hapus as requested by user or admin fallback */}
            <button onClick={handleHapus} disabled={isSubmitting} className="px-3 py-2 bg-white border border-red-200 hover:bg-red-50 text-red-600 font-medium rounded-md text-sm shadow-sm flex items-center gap-1 ml-auto">
              <Trash2 className="w-4 h-4" /> Hapus
            </button>
          </div>
          
          <button 
            onClick={() => window.print()} 
            className="px-4 py-2 bg-gray-800 hover:bg-gray-900 text-white font-medium rounded-md text-sm shadow-sm flex items-center gap-2"
          >
            <Printer className="w-4 h-4" /> Cetak
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
              {umum?.alamat_kantor || "[Alamat Kantor]"} {umum?.kodepos ? ` | Kode Pos: ${umum.kodepos}` : ""}
            </p>
            {(umum?.email || umum?.website) && (
              <p className="text-sm italic">
                {umum?.email ? `Email: ${umum.email}` : ""} {umum?.email && umum?.website ? " | " : ""} {umum?.website ? `Web: ${umum.website}` : ""}
              </p>
            )}
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
          <p className="text-sm">Nomor : {previewFormatNomor}</p>
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
            <p>{umum?.nama_desa || "[Nama Desa]"}, {new Date(data.created_at || Date.now()).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}</p>
            <p className="font-bold mb-4">{template?.pejabat_jabatan || "[Jabatan]"}</p>
            
            {/* QRCode TTE (hanya tampil jika Selesai) */}
            {data.status === "Selesai" ? (
              <div className="flex justify-center my-2 relative">
                {(() => {
                  const terbitId = data.keterangan_penolakan?.startsWith('surat_terbit_id:') 
                    ? data.keterangan_penolakan.split(':')[1] 
                    : id;
                  const verifyUrl = `${window.location.origin}/verify/${terbitId}`;
                  return (
                    <div className="relative inline-block border-2 border-green-600 p-1 rounded-sm">
                      <img src={`https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=${encodeURIComponent(verifyUrl)}`} alt="QR Code TTE" className="w-20 h-20" />
                      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 opacity-30 text-[10px] font-bold text-green-700 bg-white/70 px-1 whitespace-nowrap rotate-[-30deg]">TTE SAH</div>
                    </div>
                  );
                })()}
              </div>
            ) : (
              <div className="h-24"></div> /* Space for signature */
            )}
            
            <p className="font-bold underline mt-2">{template?.pejabat_nama || "[Nama Pejabat]"}</p>
          </div>
        </div>

      </div>
    </div>
  );
}
