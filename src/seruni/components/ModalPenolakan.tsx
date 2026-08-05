import React, { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";
import { Loader2 } from "lucide-react";
import { useTenantId } from "../lib/tenant";

interface ModalPenolakanProps {
  isOpen: boolean;
  onClose: () => void;
  suratJenisId: string;
  onReject: (alasan: string) => void;
  isSubmitting: boolean;
}

export function ModalPenolakan({ isOpen, onClose, suratJenisId, onReject, isSubmitting }: ModalPenolakanProps) {
  const tenantId = useTenantId();
  const [selectedSyarat, setSelectedSyarat] = useState<string[]>([]);
  const [catatanTambahan, setCatatanTambahan] = useState("");

  const { data: persyaratan, isLoading } = useQuery({
    queryKey: ["surat_persyaratan", tenantId, suratJenisId],
    queryFn: async () => {
      if (!tenantId || !suratJenisId) return [];
      const { data, error } = await supabase
        .from("surat_persyaratan")
        .select("*")
        .eq("tenant_id", tenantId)
        .eq("surat_jenis_id", suratJenisId)
        .order("created_at", { ascending: true });
        
      if (error) {
        console.error("Error fetching persyaratan:", error);
        return [];
      }
      return data || [];
    },
    enabled: !!tenantId && !!suratJenisId && isOpen,
  });

  const handleToggle = (nama: string) => {
    setSelectedSyarat(prev => 
      prev.includes(nama) ? prev.filter(p => p !== nama) : [...prev, nama]
    );
  };

  const handleConfirm = () => {
    const alasan = [];
    if (selectedSyarat.length > 0) {
      alasan.push("Persyaratan yang tidak dipenuhi:\n" + selectedSyarat.map(s => "- " + s).join("\n"));
    }
    if (catatanTambahan.trim()) {
      alasan.push("Catatan:\n" + catatanTambahan.trim());
    }
    
    if (alasan.length === 0) {
      alasan.push("Ditolak tanpa alasan spesifik.");
    }
    
    onReject(alasan.join("\n\n"));
  };

  // Reset state when opened
  React.useEffect(() => {
    if (isOpen) {
      setSelectedSyarat([]);
      setCatatanTambahan("");
    }
  }, [isOpen]);

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Tolak Pengajuan Surat</DialogTitle>
        </DialogHeader>
        
        <div className="py-4 space-y-4">
          <p className="text-sm text-gray-500">
            Silakan pilih persyaratan mana saja yang tidak dipenuhi oleh pemohon.
          </p>
          
          {isLoading ? (
            <div className="flex justify-center p-4">
              <Loader2 className="w-6 h-6 animate-spin text-gray-400" />
            </div>
          ) : persyaratan && persyaratan.length > 0 ? (
            <div className="space-y-2 border rounded-md p-3 max-h-60 overflow-y-auto">
              {persyaratan.map((item) => (
                <label key={item.id} className="flex items-start space-x-3 cursor-pointer p-1">
                  <input
                    type="checkbox"
                    className="mt-1"
                    checked={selectedSyarat.includes(item.nama_persyaratan)}
                    onChange={() => handleToggle(item.nama_persyaratan)}
                  />
                  <span className="text-sm">{item.nama_persyaratan}</span>
                </label>
              ))}
            </div>
          ) : (
            <p className="text-sm italic text-gray-400 p-2 text-center bg-gray-50 rounded">
              Tidak ada data persyaratan untuk jenis surat ini.
            </p>
          )}

          <div className="space-y-2">
            <label className="text-sm font-medium">Catatan Tambahan (Opsional)</label>
            <textarea
              className="w-full border rounded-md p-2 text-sm min-h-[80px]"
              placeholder="Tuliskan alasan penolakan secara spesifik..."
              value={catatanTambahan}
              onChange={(e) => setCatatanTambahan(e.target.value)}
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose} disabled={isSubmitting}>
            Batal
          </Button>
          <Button variant="destructive" onClick={handleConfirm} disabled={isSubmitting || (selectedSyarat.length === 0 && !catatanTambahan.trim())}>
            {isSubmitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            Tolak Pengajuan
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
