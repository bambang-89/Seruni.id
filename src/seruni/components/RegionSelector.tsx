import React, { useEffect, useState } from "react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";

interface Region {
  id: string;
  name: string;
}

interface RegionSelectorProps {
  provinsi: string;
  kabupaten: string;
  kecamatan: string;
  desa: string;
  onProvinsiChange: (val: string) => void;
  onKabupatenChange: (val: string) => void;
  onKecamatanChange: (val: string) => void;
  onDesaChange: (val: string) => void;
}

export function RegionSelector({
  provinsi,
  kabupaten,
  kecamatan,
  desa,
  onProvinsiChange,
  onKabupatenChange,
  onKecamatanChange,
  onDesaChange
}: RegionSelectorProps) {
  const [provinces, setProvinces] = useState<Region[]>([]);
  const [regencies, setRegencies] = useState<Region[]>([]);
  const [districts, setDistricts] = useState<Region[]>([]);
  const [villages, setVillages] = useState<Region[]>([]);

  const [loadingProv, setLoadingProv] = useState(false);
  const [loadingReg, setLoadingReg] = useState(false);
  const [loadingDist, setLoadingDist] = useState(false);
  const [loadingVill, setLoadingVill] = useState(false);

  const [selectedProvId, setSelectedProvId] = useState<string>("");
  const [selectedRegId, setSelectedRegId] = useState<string>("");
  const [selectedDistId, setSelectedDistId] = useState<string>("");

  useEffect(() => {
    setLoadingProv(true);
    fetch("https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json")
      .then(res => res.json())
      .then((data: Region[]) => {
        setProvinces(data);
        if (provinsi) {
          const found = data.find(p => p.name === provinsi);
          if (found) setSelectedProvId(found.id);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingProv(false));
  }, [provinsi]);

  useEffect(() => {
    if (!selectedProvId) {
      setRegencies([]);
      return;
    }
    setLoadingReg(true);
    fetch(`https://www.emsifa.com/api-wilayah-indonesia/api/regencies/${selectedProvId}.json`)
      .then(res => res.json())
      .then((data: Region[]) => {
        setRegencies(data);
        if (kabupaten) {
          const found = data.find(r => r.name === kabupaten);
          if (found) setSelectedRegId(found.id);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingReg(false));
  }, [selectedProvId, kabupaten]);

  useEffect(() => {
    if (!selectedRegId) {
      setDistricts([]);
      return;
    }
    setLoadingDist(true);
    fetch(`https://www.emsifa.com/api-wilayah-indonesia/api/districts/${selectedRegId}.json`)
      .then(res => res.json())
      .then((data: Region[]) => {
        setDistricts(data);
        if (kecamatan) {
          const found = data.find(d => d.name === kecamatan);
          if (found) setSelectedDistId(found.id);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingDist(false));
  }, [selectedRegId, kecamatan]);

  useEffect(() => {
    if (!selectedDistId) {
      setVillages([]);
      return;
    }
    setLoadingVill(true);
    fetch(`https://www.emsifa.com/api-wilayah-indonesia/api/villages/${selectedDistId}.json`)
      .then(res => res.json())
      .then((data: Region[]) => {
        setVillages(data);
      })
      .catch(() => {})
      .finally(() => setLoadingVill(false));
  }, [selectedDistId]);

  return (
    <>
      <div className="space-y-2">
        <label className="text-sm font-medium">Provinsi</label>
        <Select 
          value={provinsi} 
          onValueChange={(val) => {
            onProvinsiChange(val);
            const found = provinces.find(p => p.name === val);
            setSelectedProvId(found?.id || "");
            onKabupatenChange("");
            onKecamatanChange("");
            onDesaChange("");
          }}
          disabled={loadingProv}
        >
          <SelectTrigger>
            <SelectValue placeholder="Pilih Provinsi" />
            {loadingProv && <Loader2 className="w-4 h-4 animate-spin ml-2" />}
          </SelectTrigger>
          <SelectContent>
            {provinces.map(p => (
              <SelectItem key={p.id} value={p.name}>{p.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Kabupaten/Kota</label>
        <Select 
          value={kabupaten} 
          onValueChange={(val) => {
            onKabupatenChange(val);
            const found = regencies.find(r => r.name === val);
            setSelectedRegId(found?.id || "");
            onKecamatanChange("");
            onDesaChange("");
          }}
          disabled={!selectedProvId || loadingReg}
        >
          <SelectTrigger>
            <SelectValue placeholder="Pilih Kabupaten/Kota" />
            {loadingReg && <Loader2 className="w-4 h-4 animate-spin ml-2" />}
          </SelectTrigger>
          <SelectContent>
            {regencies.map(r => (
              <SelectItem key={r.id} value={r.name}>{r.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Kecamatan</label>
        <Select 
          value={kecamatan} 
          onValueChange={(val) => {
            onKecamatanChange(val);
            const found = districts.find(d => d.name === val);
            setSelectedDistId(found?.id || "");
            onDesaChange("");
          }}
          disabled={!selectedRegId || loadingDist}
        >
          <SelectTrigger>
            <SelectValue placeholder="Pilih Kecamatan" />
            {loadingDist && <Loader2 className="w-4 h-4 animate-spin ml-2" />}
          </SelectTrigger>
          <SelectContent>
            {districts.map(d => (
              <SelectItem key={d.id} value={d.name}>{d.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Desa/Kelurahan *</label>
        <Select 
          value={desa} 
          onValueChange={(val) => onDesaChange(val)}
          disabled={!selectedDistId || loadingVill}
        >
          <SelectTrigger>
            <SelectValue placeholder="Pilih Desa" />
            {loadingVill && <Loader2 className="w-4 h-4 animate-spin ml-2" />}
          </SelectTrigger>
          <SelectContent>
            {villages.map(v => (
              <SelectItem key={v.id} value={v.name}>{v.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
    </>
  );
}
