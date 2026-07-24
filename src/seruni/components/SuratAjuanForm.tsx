/**
 * Dynamic Surat Ajuan Form
 * Renders form fields based on surat_jenis_dna field definitions.
 * Used at /layanan/surat/:id route.
 */

import { useState, useCallback, useEffect, useRef } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import {
  useSuratDNAFields,
  type SuratDNAField,
  fetchPendudukByNik,
  fetchKewarganegaraan,
  composeAlamat,
  formatTanggalLahir,
  type IdentitasData,
} from "@/seruni/lib/queries";
import { UploadField } from "@/seruni/components/SuratDokumenUpload";

const inputCls =
  "mt-1 w-full border border-current/25 bg-transparent px-3 py-2 text-sm focus:outline-none focus:border-accent";
const btnPrimary =
  "inline-flex items-center gap-3 border border-accent bg-accent/10 text-accent px-6 py-3 font-display text-[11px] font-bold uppercase tracking-[0.28em] hover:bg-accent hover:text-primary transition-colors disabled:opacity-50";

function cn(...classes: (string | boolean | undefined)[]) {
  return classes.filter(Boolean).join(" ");
}

function RelationalSelectField({ field, value, onChange, error }: { field: SuratDNAField; value: unknown; onChange: (v: unknown) => void; error?: string }) {
  const [opts, setOpts] = useState<{value: string, label: string}[]>([]);
  const required = field.wajib;
  const helpText = field.help_text;
  
  useEffect(() => {
    const rawOptions = field.options;
    if (!rawOptions) {
      setOpts([]);
      return;
    }

    // 1. If string (legacy CSV)
    if (typeof rawOptions === "string") {
      const parsed = (rawOptions as string).split(",").map(s => ({ value: s.trim(), label: s.trim() }));
      setOpts(parsed);
      return;
    }

    // 2. If object (Relational mapping) -> e.g. { relation: { table: "wilayah_dusun", labelCol: "nama", valueCol: "nama" } }
    const obj = rawOptions as any;
    if (obj && obj.relation && obj.relation.table) {
      supabase.from(obj.relation.table).select(`${obj.relation.labelCol},${obj.relation.valueCol}`).then(({ data }) => {
        if (data) {
          setOpts(data.map((d: any) => ({
            value: d[obj.relation.valueCol],
            label: d[obj.relation.labelCol]
          })));
        }
      });
      return;
    }

    // 3. If array (JSON array)
    if (Array.isArray(rawOptions)) {
      setOpts(rawOptions.map(opt => ({ value: String(opt), label: String(opt) })));
      return;
    }

    setOpts([]);
  }, [field.options]);

  return (
    <div className="space-y-1">
      <label className="block text-sm">
        <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
          {field.label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </span>
        <select
          value={(value as string) || ""}
          onChange={(e) => onChange(e.target.value)}
          className={cn(inputCls, error ? "border-red-500" : "")}
        >
          <option value="">— Pilih —</option>
          {opts.map((opt) => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>
      </label>
      {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}

function FieldRenderer({
  field,
  value,
  onChange,
  error,
}: {
  field: SuratDNAField;
  value: unknown;
  onChange: (v: unknown) => void;
  error?: string;
}) {
  const placeholder = field.placeholder || "";
  const helpText = field.help_text;
  const required = field.wajib;

  switch (field.tipe) {
    case "textarea":
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <textarea
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              placeholder={placeholder}
              rows={4}
              maxLength={field.max_length || 2000}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    case "number":
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <input
              type="number"
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              placeholder={placeholder}
              min={field.min_value ?? undefined}
              max={field.max_value ?? undefined}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    case "date":
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <input
              type="date"
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    case "select":
      return <RelationalSelectField field={field} value={value} onChange={onChange} error={error} />;

    case "checkbox":
      return (
        <div className="space-y-1">
          <label className="flex items-center gap-3 text-sm cursor-pointer">
            <input
              type="checkbox"
              checked={(value as boolean) || false}
              onChange={(e) => onChange(e.target.checked)}
              className="accent-accent w-4 h-4"
            />
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
            </span>
          </label>
          {helpText && <p className="text-xs text-muted-foreground ml-7">{helpText}</p>}
          {error && <p className="text-xs text-red-500 ml-7">{error}</p>}
        </div>
      );

    case "phone":
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <input
              type="tel"
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              placeholder={placeholder || "08xxxxxxxxxx"}
              maxLength={20}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    case "email":
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <input
              type="email"
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              placeholder={placeholder || "email@contoh.com"}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    case "file":
      return (
        <div className="space-y-1">
          <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
            {field.label}
            {required && <span className="text-red-500 ml-1">*</span>}
          </span>
          <UploadField
            kategori="dokumen_pendukung"
            label=""
            description={helpText || `Upload ${field.label}`}
            value={value ? { url: value as string, namaFile: "", kategori: "dokumen_pendukung" } : undefined}
            onChange={(v) => onChange(v?.url || null)}
          />
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );

    default: // text
      return (
        <div className="space-y-1">
          <label className="block text-sm">
            <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
              {field.label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </span>
            <input
              type="text"
              value={(value as string) || ""}
              onChange={(e) => onChange(e.target.value)}
              placeholder={placeholder}
              maxLength={field.max_length || 500}
              minLength={field.min_length || undefined}
              className={cn(inputCls, error ? "border-red-500" : "")}
            />
          </label>
          {helpText && <p className="text-xs text-muted-foreground">{helpText}</p>}
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      );
  }
}

function validateField(field: SuratDNAField, value: unknown): string | null {
  if (!field.wajib) return null;

  const strVal = String(value ?? "").trim();
  const numVal = Number(value);

  if (field.tipe === "checkbox") {
    if (value !== true) return `${field.label} wajib dicentang`;
    return null;
  }

  if (!strVal) return `${field.label} wajib diisi`;

  if (field.tipe === "number" && !isNaN(numVal)) {
    if (field.min_value != null && numVal < field.min_value)
      return `${field.label} minimal ${field.min_value}`;
    if (field.max_value != null && numVal > field.max_value)
      return `${field.label} maksimal ${field.max_value}`;
  }

  if (field.tipe === "phone" && strVal) {
    const cleaned = strVal.replace(/\D/g, "");
    if (cleaned.length < 8 || cleaned.length > 15)
      return "Nomor telepon tidak valid";
  }

  if (field.tipe === "email" && strVal) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(strVal))
      return "Format email tidak valid";
  }

  if (field.min_length != null && strVal.length < field.min_length)
    return `${field.label} minimal ${field.min_length} karakter`;

  if (field.max_length != null && strVal.length > field.max_length)
    return `${field.label} maksimal ${field.max_length} karakter`;

  if (field.validation_pattern && strVal) {
    try {
      if (!new RegExp(field.validation_pattern).test(strVal))
        return `Format ${field.label} tidak sesuai`;
    } catch { /* ignore bad regex */ }
  }

  return null;
}

interface GroupedFields {
  [grup: string]: SuratDNAField[];
}

function groupFields(fields: SuratDNAField[]): GroupedFields {
  const groups: GroupedFields = {};
  for (const f of fields) {
    const g = f.grup || "Umum";
    if (!groups[g]) groups[g] = [];
    groups[g].push(f);
  }
  return groups;
}

// ===================== Main Form Component =====================

export function SuratAjuanForm() {
  const { id: jenisSuratId } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [jenisSurat, setJenisSurat] = useState<{ nama: string; kode_surat: string } | null>(null);
  const [nik, setNik] = useState("");
  const [nama, setNama] = useState("");
  const [kontak, setKontak] = useState("");
  const [keperluan, setKeperluan] = useState("");

// Identity autofill state
  const [identitas, setIdentitas] = useState<IdentitasData | null>(null);
  const [isLoadingLookup, setIsLoadingLookup] = useState(false);
  const [lookupError, setLookupError] = useState<string | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // DNA field values: field_name -> value
  const [dnaValues, setDnaValues] = useState<Record<string, unknown>>({});
  const [dnaErrors, setDnaErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState<{ nomor_tiket: string } | null>(null);

  const { data: dnaFields, loading: dnaLoading } = useSuratDNAFields(jenisSuratId ?? null);

  // Load jenis surat metadata
  useEffect(() => {
    if (!jenisSuratId) return;
    supabase
      .from("surat_jenis")
      .select("nama, kode_surat")
      .eq("id", jenisSuratId)
      .maybeSingle()
      .then(({ data, error }) => {
        if (data) {
          setJenisSurat(data);
        } else if (error || !data) {
          // If ID is not UUID or not found in DB
          setJenisSurat({ nama: "Formulir Surat", kode_surat: "SURAT" });
        }
      })
      .catch(() => {
        setJenisSurat({ nama: "Formulir Surat", kode_surat: "SURAT" });
      });
  }, [jenisSuratId]);


  const handleDnaChange = useCallback((fieldName: string, value: unknown) => {
    setDnaValues((prev) => ({ ...prev, [fieldName]: value }));
    // Clear error on change
    setDnaErrors((prev) => {
      const next = { ...prev };
      delete next[fieldName];
      return next;
    });
  }, []);

  // Autofill NIK — debounced lookup
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    // Clear state when NIK is cleared or too short
    if (nik.length === 0) {
      setIdentitas(null);
      setLookupError(null);
      setIsLoadingLookup(false);
      return;
    }

    if (nik.length !== 16) return;

    setIsLoadingLookup(true);
    setLookupError(null);

    debounceRef.current = setTimeout(async () => {
      try {
        const p = await fetchPendudukByNik(nik);
        if (p) {
          const kewarganegaraan = await fetchKewarganegaraan((p as any).warga_negara_id);
          const alamat_lengkap = composeAlamat(
            (p as any).dusun,
            (p as any).rt,
            (p as any).rw,
            (p as any).kecamatan,
            (p as any).kabupaten,
            (p as any).provinsi,
          );
          const genderMap: Record<string, string> = { L: "Laki-laki", P: "Perempuan" };
          const id: IdentitasData = {
            nik: (p as any).nik || nik,
            nama: (p as any).nama || "",
            tempat_lahir: (p as any).tempat_lahir || "",
            tanggal_lahir: (p as any).tanggal_lahir || "",
            jenis_kelamin: genderMap[(p as any).jenis_kelamin] || (p as any).jenis_kelamin || "-",
            pekerjaan: (p as any).pekerjaan || "-",
            kewarganegaraan,
            alamat_lengkap,
            nomor_hp: (p as any).nomor_hp || undefined,
          };
          setIdentitas(id);
          toast.success("Data penduduk ditemukan, form otomatis diisi.");
          if (!nama) setNama(id.nama);
          if (!kontak && id.nomor_hp) setKontak(id.nomor_hp);
          // Autofill matching DNA fields
          setDnaValues(prev => {
            const next = { ...prev };
            dnaFields.forEach(f => {
              if (f.field_name in p && !next[f.field_name]) {
                next[f.field_name] = (p as any)[f.field_name];
              }
            });
            return next;
          });
          // Clear errors for auto-filled fields
          setDnaErrors(prev => {
            const next = { ...prev };
            delete next.nama;
            dnaFields.forEach(f => {
              if (f.field_name in p) delete next[f.field_name];
            });
            return next;
          });
        } else {
          setIdentitas(null);
          setLookupError("NIK tidak ditemukan dalam database. Hubungi kantor desa.");
          setNama("");
          setKontak("");
        }
      } catch (e) {
        console.error("Autofill error:", e);
        setLookupError("Gagal lookup data penduduk.");
      } finally {
        setIsLoadingLookup(false);
      }
    }, 500);
  }, [nik, dnaFields]);

  function validateAll(): boolean {
    const errors: Record<string, string> = {};

    if (nik.trim().length !== 16) errors.nik = "NIK harus 16 digit";
    if (nama.trim().length < 2) errors.nama = "Nama minimal 2 karakter";
    const cleanPhone = kontak.replace(/\D/g, "");
    if (cleanPhone.length < 8) errors.kontak = "Nomor WhatsApp tidak valid";
    if (keperluan.trim().length < 10) errors.keperluan = "Keperluan minimal 10 karakter";

    for (const f of dnaFields) {
      const err = validateField(f, dnaValues[f.field_name]);
      if (err) errors[f.field_name] = err;
    }

    setDnaErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateAll()) {
      toast.error("Mohon lengkapi semua field wajib");
      return;
    }

    setSubmitting(true);
    try {
      // Build lampiran array from file-type DNA fields
      const lampiran: string[] = [];
      for (const f of dnaFields) {
        if (f.tipe === "file" && dnaValues[f.field_name]) {
          lampiran.push(dnaValues[f.field_name] as string);
        }
      }

      const payload: Record<string, unknown> = {
        nik: nik.trim(),
        nama: nama.trim(),
        kontak: kontak.trim(),
        jenis_surat_id: jenisSuratId,
        keperluan: keperluan.trim(),
        lampiran,
        data_dna: dnaValues,
      };

      // Add data_identitas if autofilled
      if (identitas) {
        payload.data_identitas = {
          tempat_lahir: identitas.tempat_lahir,
          tanggal_lahir: identitas.tanggal_lahir,
          jenis_kelamin: identitas.jenis_kelamin,
          pekerjaan: identitas.pekerjaan,
          kewarganegaraan: identitas.kewarganegaraan,
          alamat_lengkap: identitas.alamat_lengkap,
        };
      }

      const { data, error } = await (supabase.functions as any).invoke("submit-surat", {
        body: payload,
      });

      if (error || !data?.ok) {
        throw new Error(error?.message || (data as any)?.error || "Gagal mengirim pengajuan");
      }

      setSubmitted({ nomor_tiket: (data as any).nomor_tiket });
    } catch (err: any) {
      toast.error(err?.message || "Gagal mengirim pengajuan");
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <div className="max-w-2xl mx-auto py-16 text-center space-y-6">
        <div className="border-l-2 border-accent pl-6 text-left">
          <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">Berhasil</div>
          <div className="mt-2 font-display text-3xl font-semibold italic">Pengajuan Terkirim</div>
          <p className="mt-3 text-sm opacity-80 leading-relaxed">
            Pengajuan {jenisSurat?.nama || "surat"} Anda telah diterima. Tim desa akan memproses dalam 1–3 hari kerja.
          </p>
        </div>
        <div className="border border-accent/30 p-8 text-left space-y-4">
          <div>
            <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent opacity-60">Nomor Tiket</div>
            <div className="font-mono text-2xl text-accent">{submitted.nomor_tiket}</div>
          </div>
          <p className="text-sm opacity-70">
            Simpan nomor tiket ini untuk melacak status pengajuan di halaman Service Center.
          </p>
          <div className="flex gap-3 pt-2">
            <button
              onClick={() => navigate("/service-center")}
              className={btnPrimary}
            >
              Lacak Status
            </button>
            <button
              onClick={() => navigate("/layanan/surat")}
              className={btnPrimary}
            >
              Katalog Surat
            </button>
          </div>
        </div>
      </div>
    );
  }

  const grouped = groupFields(dnaFields);

  return (
    <form className="max-w-2xl mx-auto border border-current/20 p-6 sm:p-8 grid gap-6" onSubmit={handleSubmit}>
      {/* Header */}
      <div className="border-b border-current/15 pb-4">
        <div className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
          {jenisSurat?.kode_surat ?? "——"}
        </div>
        <h2 className="mt-1 font-display text-2xl font-semibold">
          {jenisSurat?.nama ?? "Memuat…"}
        </h2>
        <p className="mt-2 text-sm opacity-60">
          Pengajuan surat secara online. Data digunakan untuk keperluan administrasi desa.
        </p>
      </div>

      {/* Data Diri Pemohon */}
      <fieldset>
        <legend className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4 block">
          Data Diri Pemohon
        </legend>

        {/* NIK + Nama row */}
        <div className="grid sm:grid-cols-2 gap-5">
          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                NIK<span className="text-red-500 ml-1">*</span>
              </span>
              <div className="relative">
                <input
                  type="text"
                  value={nik}
                  inputMode="numeric"
                  data-testid="field-nik"
                  onChange={(e) => {
                    const val = e.target.value.replace(/\D/g, "").slice(0, 16);
                    setNik(val);
                    if (val.length === 0) {
                      setIdentitas(null);
                      setLookupError(null);
                      setNama("");
                      setKontak("");
                    }
                    setDnaErrors((p) => { const n = { ...p }; delete n.nik; return n; });
                  }}
                  placeholder="16 digit NIK"
                  maxLength={16}
                  className={cn(
                    inputCls,
                    "font-mono tabular-nums pr-8",
                    dnaErrors.nik || lookupError ? "border-red-500" : "",
                    identitas ? "border-green-500" : "",
                  )}
                />
                {isLoadingLookup && (
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 border-2 border-accent/30 border-t-accent rounded-full animate-spin" />
                )}
              </div>
            </label>
            {dnaErrors.nik && <p className="text-xs text-red-500">{dnaErrors.nik}</p>}
            {lookupError && <p className="text-xs text-red-500">{lookupError}</p>}
          </div>

          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Nama Lengkap<span className="text-red-500 ml-1">*</span>
              </span>
              <input
                type="text"
                value={nama}
                onChange={(e) => { setNama(e.target.value); setDnaErrors((p) => { const n = { ...p }; delete n.nama; return n; }); }}
                placeholder="Nama sesuai KTP"
                maxLength={120}
                readOnly={!!identitas}
                className={cn(inputCls, dnaErrors.nama ? "border-red-500" : "", identitas ? "bg-accent/5 cursor-not-allowed" : "")}
              />
            </label>
            {dnaErrors.nama && <p className="text-xs text-red-500">{dnaErrors.nama}</p>}
          </div>
        </div>

        {/* Verified badge */}
        {identitas && (
          <div className="mt-3 inline-flex items-center gap-2 bg-green-500/10 border border-green-500/30 text-green-600 text-xs px-3 py-1.5 rounded-full font-display font-bold uppercase tracking-wider" data-testid="badge-verified">
            <span className="w-1.5 h-1.5 bg-green-500 rounded-full" />
            Terverifikasi: {identitas.nama}
          </div>
        )}

        {/* Not found CTA */}
        {lookupError && !identitas && (
          <div className="mt-3 border border-red-500/30 bg-red-500/5 p-4 rounded space-y-2" data-testid="cta-not-found">
            <p className="text-sm text-red-600 font-medium">NIK tidak ditemukan dalam database.</p>
            <p className="text-xs opacity-70">Silakan hubungi Kantor Desa Seruni Mumbul untuk mendaftarkan data Anda.</p>
            <a
              href="https://wa.me/6287763170088"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 text-xs font-bold text-accent hover:underline"
            >
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
              Hubungi Kantor Desa
            </a>
          </div>
        )}

        {/* TTL */}
        <div className="mt-5 grid sm:grid-cols-2 gap-5">
          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Tempat, Tanggal Lahir
              </span>
              <input
                type="text"
                value={identitas ? formatTanggalLahir(identitas.tanggal_lahir, identitas.tempat_lahir) : ""}
                readOnly
                data-testid="field-ttl"
                className={cn(inputCls, "bg-accent/5 cursor-not-allowed text-sm")}
                placeholder="Otomatis terisi dari NIK"
              />
            </label>
          </div>

          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Jenis Kelamin
              </span>
              <input
                type="text"
                value={identitas?.jenis_kelamin || ""}
                readOnly
                data-testid="field-gender"
                className={cn(inputCls, "bg-accent/5 cursor-not-allowed text-sm")}
                placeholder="Otomatis terisi dari NIK"
              />
            </label>
          </div>

          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Pekerjaan
              </span>
              <input
                type="text"
                value={identitas?.pekerjaan || ""}
                readOnly
                data-testid="field-pekerjaan"
                className={cn(inputCls, "bg-accent/5 cursor-not-allowed text-sm")}
                placeholder="Otomatis terisi dari NIK"
              />
            </label>
          </div>

          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Kewarganegaraan
              </span>
              <input
                type="text"
                value={identitas?.kewarganegaraan || ""}
                readOnly
                data-testid="field-kewarganegaraan"
                className={cn(inputCls, "bg-accent/5 cursor-not-allowed text-sm")}
                placeholder="Otomatis terisi dari NIK"
              />
            </label>
          </div>

          <div className="sm:col-span-2 space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                Alamat Lengkap
              </span>
              <textarea
                value={identitas?.alamat_lengkap || ""}
                readOnly
                rows={2}
                data-testid="field-alamat"
                className={cn(inputCls, "bg-accent/5 cursor-not-allowed text-sm resize-none")}
                placeholder="Otomatis terisi dari NIK"
              />
            </label>
          </div>

          <div className="space-y-1">
            <label className="block text-sm">
              <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
                No. WhatsApp<span className="text-red-500 ml-1">*</span>
              </span>
              <input
                type="tel"
                value={kontak}
                data-testid="field-whatsapp"
                onChange={(e) => { setKontak(e.target.value); setDnaErrors((p) => { const n = { ...p }; delete n.kontak; return n; }); }}
                placeholder={identitas?.nomor_hp ? "" : "08xxxxxxxxxx"}
                maxLength={20}
                readOnly={!!identitas?.nomor_hp}
                className={cn(inputCls, dnaErrors.kontak ? "border-red-500" : "", identitas?.nomor_hp ? "bg-accent/5 cursor-not-allowed" : "")}
              />
            </label>
            {dnaErrors.kontak && <p className="text-xs text-red-500">{dnaErrors.kontak}</p>}
            <p className="text-[11px] opacity-50">Notifikasi status akan dikirim via WhatsApp</p>
          </div>
        </div>
      </fieldset>

      {/* Dynamic DNA Fields */}
      {dnaLoading ? (
        <p className="text-sm opacity-60">Memuat form…</p>
      ) : (
        Object.entries(grouped).map(([grup, fields]) => (
          <fieldset key={grup}>
            <legend className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent mb-4 block">
              {grup}
            </legend>
            <div className="grid sm:grid-cols-2 gap-5">
              {fields.map((field) => (
                <div
                  key={field.field_name}
                  className={field.tipe === "textarea" || field.tipe === "file" ? "sm:col-span-2" : ""}
                >
                  <FieldRenderer
                    field={field}
                    value={dnaValues[field.field_name]}
                    onChange={(v) => handleDnaChange(field.field_name, v)}
                    error={dnaErrors[field.field_name]}
                  />
                </div>
              ))}
            </div>
          </fieldset>
        ))
      )}

      {/* Keperluan */}
      <div className="space-y-1">
        <label className="block text-sm">
          <span className="font-display text-[10px] font-bold uppercase tracking-[0.28em] text-accent">
            Keperluan<span className="text-red-500 ml-1">*</span>
          </span>
          <textarea
            value={keperluan}
            onChange={(e) => { setKeperluan(e.target.value); setDnaErrors((p) => { const n = { ...p }; delete n.keperluan; return n; }); }}
            placeholder="Ceritakan keperluan pengajuan surat ini…"
            rows={4}
            maxLength={2000}
            className={`${inputCls} ${dnaErrors.keperluan ? "border-red-500" : ""}`}
          />
        </label>
        {dnaErrors.keperluan && <p className="text-xs text-red-500">{dnaErrors.keperluan}</p>}
        <p className="text-[11px] opacity-50">{keperluan.length}/2000 karakter</p>
      </div>

      {/* Notice */}
      <div className="border border-current/15 p-4 text-xs opacity-70 leading-relaxed">
        Dengan mengirim pengajuan ini, saya menyatakan bahwa data yang diberikan adalah benar dan dapat dipertanggungjawabkan.
      </div>

      <div className="flex gap-3">
        <button type="submit" disabled={submitting} className={`${btnPrimary} justify-center`}>
          {submitting ? "Mengirim…" : "Kirim Pengajuan"}
        </button>
        <button
          type="button"
          onClick={() => navigate("/layanan/surat")}
          className="inline-flex items-center gap-3 border border-current/25 px-6 py-3 font-display text-[11px] font-bold uppercase tracking-[0.28em] hover:bg-current/5 transition-colors"
        >
          Batal
        </button>
      </div>
    </form>
  );
}
