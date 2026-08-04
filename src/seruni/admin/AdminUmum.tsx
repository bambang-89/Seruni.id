import React, { useEffect, useState, useCallback } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useTenantId } from "../lib/tenant";
import { toast } from "sonner";
import { uploadFile } from "../lib/upload";
import { Save, UploadCloud, AlertCircle, ExternalLink, MapPin } from "lucide-react";
import { invalidatePageConfig } from "../lib/pageConfig";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { RegionSelector } from "../components/RegionSelector";
import { TagsInput } from "../components/TagsInput";

import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";

// --- Extended DB Types (kolom baru dari migrasi yg belum di-regenerate di types.ts) ---
interface TenantRow {
  id: string;
  nama_desa: string;
  kecamatan: string | null;
  kabupaten: string | null;
  provinsi: string | null;
  logo_url: string | null;
  logo_kabupaten_url: string | null;  // via migration 20260731000000
  logo_provinsi_url: string | null;   // via migration 20260731000000
  favicon_url: string | null;
  kode_desa: string | null;
  fonnte_token?: string | null;
  aktif: boolean;
  warna_primer: string;
  [key: string]: unknown;
}

interface SiteSettingsRow {
  id: string;
  tenant_id: string;
  nama_resmi: string;
  tagline: string | null;
  alamat_kantor: string | null;
  telepon: string | null;
  email: string | null;
  website: string | null;         // via migration 20260731000000
  kodepos: string | null;         // via migration 20260731000000
  jam_layanan: string | null;
  nomor_wa_resmi: string | null;
  maps_embed_url: string | null;
  dusun: string | null;           // via migration 20260731000000
  rt: string | null;              // via migration 20260731000000
  singkatan_desa: string | null;  // via migration (site_settings)
  singkatan_kades: string | null; // via migration (site_settings)
  social_media: unknown;
  wa_business_verified: boolean;
  [key: string]: unknown;
}

// --- Helpers & Parsing ---
function formatUrl(url: string) {
  if (!url) return "";
  let formattedUrl = url.trim();
  if (formattedUrl && !/^https?:\/\//i.test(formattedUrl)) {
    formattedUrl = `https://${formattedUrl}`;
  }
  return formattedUrl;
}

function parseIframeToUrl(input: string) {
  if (!input) return "";
  const srcMatch = input.match(/src="([^"]+)"/);
  if (srcMatch && srcMatch[1]) {
    return srcMatch[1];
  }
  return input;
}

// --- Validation Schema (Zod) ---
const formSchema = z.object({
  // Identitas Wilayah
  nama_desa: z.string().min(1, "Nama desa wajib diisi"),
  kecamatan: z.string().optional(),
  kabupaten: z.string().optional(),
  provinsi: z.string().optional(),
  singkatan_desa: z.string().max(10, "Maksimal 10 karakter").optional(),
  singkatan_kades: z.string().max(10, "Maksimal 10 karakter").optional(),
  dusun: z.string().optional(), // Legacy
  rt: z.string().optional(), // Legacy

  // Informasi Layanan & Publik
  tagline: z.string().optional(),
  jam_layanan: z.string().optional(),
  nomor_wa: z.string()
    .regex(/^[\d\s+\-()]*$/, "Format nomor WA tidak valid")
    .optional()
    .or(z.literal("")),
  fonnte_token: z.string().optional(),

  // Kontak & Alamat
  alamat: z.string().optional(),
  kodepos: z.string()
    .regex(/^\d{5}$/, "Kodepos harus 5 digit angka")
    .optional()
    .or(z.literal("")),
  kontak: z.string()
    .regex(/^[\d\s+\-()]*$/, "Format telepon tidak valid")
    .optional()
    .or(z.literal("")),
  email: z.string()
    .email("Format email tidak valid")
    .optional()
    .or(z.literal("")),
  website: z.string().optional(),
  maps_embed_url: z.string().optional(),

  // Akun Sosial Media
  sosmed_facebook: z.string().optional(),
  sosmed_instagram: z.string().optional(),
  sosmed_youtube: z.string().optional(),
  sosmed_tiktok: z.string().optional(),
  sosmed_twitter: z.string().optional(),

  // Logo & Visual
  logo_desa: z.string().optional(),
  logo_kabupaten: z.string().optional(),
  logo_provinsi: z.string().optional(),
  favicon: z.string().optional(),
});

type FormValues = z.infer<typeof formSchema>;

// --- Components ---
function ImageUpload({
  label,
  value,
  onUpload,
}: {
  label: string;
  value: string;
  onUpload: (e: React.ChangeEvent<HTMLInputElement>) => void;
}) {
  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium">{label}</label>
      <div className="flex items-center gap-4">
        {value ? (
          <div className="relative group">
            <img
              src={value}
              alt={label}
              className="h-16 w-16 object-contain bg-slate-100 border rounded"
            />
            <a
              href={value}
              target="_blank"
              rel="noopener noreferrer"
              className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 group-hover:opacity-100 rounded transition-opacity"
            >
              <ExternalLink className="w-4 h-4 text-white" />
            </a>
          </div>
        ) : (
          <div className="h-16 w-16 bg-slate-100 border rounded flex items-center justify-center text-slate-400 text-xs text-center">
            Belum ada
          </div>
        )}
        <label className="cursor-pointer bg-primary text-primary-foreground px-4 py-2 rounded text-sm hover:bg-primary/90 flex items-center gap-2">
          <UploadCloud className="w-4 h-4" />
          Upload {label}
          <input type="file" className="hidden" accept="image/*" onChange={onUpload} />
        </label>
      </div>
    </div>
  );
}

// --- Main Page Component ---
export default function AdminUmum() {
  const tenantId = useTenantId();
  const [loaded, setLoaded] = useState(false);
  const [busy, setBusy] = useState(false);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      nama_desa: "", kecamatan: "", kabupaten: "", provinsi: "", singkatan_desa: "", singkatan_kades: "",
      dusun: "", rt: "", tagline: "", jam_layanan: "", nomor_wa: "", alamat: "", kodepos: "",
      kontak: "", email: "", website: "", maps_embed_url: "",
      sosmed_facebook: "", sosmed_instagram: "", sosmed_youtube: "", sosmed_tiktok: "", sosmed_twitter: "",
      logo_desa: "", logo_kabupaten: "", logo_provinsi: "", favicon: ""
    }
  });

  const { isDirty } = form.formState;

  // Dirty-state browser guard
  useEffect(() => {
    const handler = (e: BeforeUnloadEvent) => {
      if (isDirty) {
        e.preventDefault();
        e.returnValue = "";
      }
    };
    window.addEventListener("beforeunload", handler);
    return () => window.removeEventListener("beforeunload", handler);
  }, [isDirty]);

  // Load from DB
  useEffect(() => {
    if (!tenantId) return;
    Promise.all([
      supabase.from("tenants").select("*").eq("id", tenantId).single(),
      supabase.from("site_settings").select("*").eq("tenant_id", tenantId).single(),
    ]).then(([resT, resS]) => {
      // Cast ke interface lokal karena types.ts belum di-regenerate setelah migrasi
      const t = resT.data as TenantRow | null;
      const s = resS.data as SiteSettingsRow | null;

      const smRaw = s?.social_media;
      const sm = (typeof smRaw === "string" ? JSON.parse(smRaw || "{}") : smRaw) as Record<string, string> || {};

      form.reset({
        nama_desa: t?.nama_desa || "",
        kecamatan: t?.kecamatan || "",
        kabupaten: t?.kabupaten || "",
        provinsi: t?.provinsi || "",
        logo_desa: t?.logo_url || "",
        logo_kabupaten: t?.logo_kabupaten_url || "",
        logo_provinsi: t?.logo_provinsi_url || "",
        favicon: t?.favicon_url || "",

        tagline: s?.tagline || "",
        alamat: s?.alamat_kantor || "",
        kodepos: s?.kodepos || "",
        kontak: s?.telepon || "",
        email: s?.email || "",
        website: s?.website || "",
        jam_layanan: s?.jam_layanan || "",
        nomor_wa: s?.nomor_wa_resmi || "",
        fonnte_token: (s as any)?.fonnte_token || t?.fonnte_token || "",
        maps_embed_url: s?.maps_embed_url || "",
        dusun: s?.dusun || "",
        rt: s?.rt || "",
        singkatan_desa: s?.singkatan_desa || "",
        singkatan_kades: s?.singkatan_kades || "",

        sosmed_facebook: sm.facebook || "",
        sosmed_instagram: sm.instagram || "",
        sosmed_youtube: sm.youtube || "",
        sosmed_tiktok: sm.tiktok || "",
        sosmed_twitter: sm.twitter || "",
      });

      setLoaded(true);
    });
  }, [tenantId, form]);

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>, field: keyof FormValues) => {
    const file = e.target.files?.[0];
    if (!file) return;
    toast.info("Mengunggah...");
    try {
      const result = await uploadFile(file, {
        entityType: "profil_desa",
        kategori: field === "favicon" ? "favicon" : "logo",
      });
      if (result?.url) {
        form.setValue(field, result.url, { shouldDirty: true });
        toast.success("Berhasil diunggah - jangan lupa klik Simpan");
      } else {
        toast.error(result.error || "Gagal mengunggah");
      }
    } catch (err: any) {
      toast.error(err.message || "Gagal mengunggah");
    }
  };

  const onSubmit = async (data: FormValues) => {
    setBusy(true);

    const sosmed: Record<string, string> = {};
    if (data.sosmed_facebook) sosmed.facebook = formatUrl(data.sosmed_facebook);
    if (data.sosmed_instagram) sosmed.instagram = formatUrl(data.sosmed_instagram);
    if (data.sosmed_youtube) sosmed.youtube = formatUrl(data.sosmed_youtube);
    if (data.sosmed_tiktok) sosmed.tiktok = formatUrl(data.sosmed_tiktok);
    if (data.sosmed_twitter) sosmed.twitter = formatUrl(data.sosmed_twitter);

    // Update state to formatted values
    form.setValue("sosmed_facebook", sosmed.facebook || "");
    form.setValue("sosmed_instagram", sosmed.instagram || "");
    form.setValue("sosmed_youtube", sosmed.youtube || "");
    form.setValue("sosmed_tiktok", sosmed.tiktok || "");
    form.setValue("sosmed_twitter", sosmed.twitter || "");
    form.setValue("website", formatUrl(data.website || ""));

    // Cast payload ke Record agar kolom baru (belum di types.ts) bisa di-update
    const tenantPayload: Record<string, unknown> = {
      nama_desa: data.nama_desa,
      kecamatan: data.kecamatan,
      kabupaten: data.kabupaten,
      provinsi: data.provinsi,
      logo_url: data.logo_desa,
      logo_kabupaten_url: data.logo_kabupaten,
      logo_provinsi_url: data.logo_provinsi,
      favicon_url: data.favicon,
      // fonnte_token disimpan di site_settings
    };

    const sitePayload: Record<string, unknown> = {
      tagline: data.tagline,
      alamat_kantor: data.alamat,
      telepon: data.kontak,
      email: data.email,
      website: formatUrl(data.website || ""),
      kodepos: data.kodepos,
      jam_layanan: data.jam_layanan,
      nomor_wa_resmi: data.nomor_wa,
      fonnte_token: data.fonnte_token || null,
      maps_embed_url: parseIframeToUrl(data.maps_embed_url || "") || null,
      dusun: data.dusun,
      rt: data.rt,
      singkatan_desa: data.singkatan_desa,
      singkatan_kades: data.singkatan_kades,
      social_media: sosmed,
    };

    const { error: e1 } = await supabase
      .from("tenants")
      .update(tenantPayload as any)
      .eq("id", tenantId as string);

    const { error: e2 } = await supabase
      .from("site_settings")
      .update(sitePayload as any)
      .eq("tenant_id", tenantId as string);

    setBusy(false);

    const errorMsgs = [e1?.message, e2?.message].filter(Boolean);
    if (errorMsgs.length > 0) {
      toast.error(`Gagal menyimpan: ${errorMsgs.join(" · ")}`);
    } else {
      toast.success("Pengaturan Umum berhasil disimpan!");
      form.reset(form.getValues()); // reset isDirty state
      try { invalidatePageConfig("*"); } catch (_) { /* ignore */ }
    }
  };

  if (!loaded) {
    return (
      <div className="p-6 flex items-center gap-2 text-muted-foreground">
        <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        Memuat pengaturan...
      </div>
    );
  }

  return (
    <div className="p-6 max-w-4xl mx-auto pb-28">
      {/* --- Page Header --- */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Pengaturan Umum</h1>
          <p className="text-muted-foreground text-sm">
            Identitas desa, kontak, logo, dan konfigurasi publik.
          </p>
        </div>
        <div className="flex items-center gap-3">
          {isDirty && (
            <span className="text-xs text-amber-600 bg-amber-50 border border-amber-200 px-2 py-1 rounded flex items-center gap-1">
              <AlertCircle className="w-3 h-3" /> Belum disimpan
            </span>
          )}
          <Button onClick={form.handleSubmit(onSubmit)} disabled={busy}>
            <Save className="w-4 h-4 mr-2" />
            {busy ? "Menyimpan..." : "Simpan"}
          </Button>
        </div>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <Tabs defaultValue="profil" className="w-full">
            <TabsList className="w-full justify-start border-b rounded-none h-auto p-0 bg-transparent mb-6">
              <TabsTrigger value="profil" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none px-6 py-3">Profil & Logo</TabsTrigger>
              <TabsTrigger value="kontak" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none px-6 py-3">Kontak & Lokasi</TabsTrigger>
              <TabsTrigger value="layanan" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none px-6 py-3">Layanan</TabsTrigger>
              <TabsTrigger value="sosmed" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none px-6 py-3">Sosial Media</TabsTrigger>
            </TabsList>

            {/* TAB: PROFIL & LOGO */}
            <TabsContent value="profil" className="space-y-6 mt-0">
              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Identitas Wilayah</h2>
                <div className="grid md:grid-cols-2 gap-4">
                  <RegionSelector
                    provinsi={form.watch("provinsi") || ""}
                    kabupaten={form.watch("kabupaten") || ""}
                    kecamatan={form.watch("kecamatan") || ""}
                    desa={form.watch("nama_desa") || ""}
                    onProvinsiChange={(val) => form.setValue("provinsi", val, { shouldDirty: true })}
                    onKabupatenChange={(val) => form.setValue("kabupaten", val, { shouldDirty: true })}
                    onKecamatanChange={(val) => form.setValue("kecamatan", val, { shouldDirty: true })}
                    onDesaChange={(val) => form.setValue("nama_desa", val, { shouldDirty: true })}
                  />
                  <FormField control={form.control} name="singkatan_desa" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Singkatan Desa</FormLabel>
                      <FormControl><Input placeholder="Contoh: SRMB" {...field} /></FormControl>
                      <FormDescription>Untuk format nomor surat.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="singkatan_kades" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Singkatan Jabatan Kades</FormLabel>
                      <FormControl><Input placeholder="Contoh: KDS" {...field} /></FormControl>
                      <FormDescription>Untuk format nomor surat.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <div className="md:col-span-2 mt-4 text-sm text-muted-foreground p-3 border rounded-md bg-muted/20">
                    <p className="font-semibold text-foreground">Pengaturan Wilayah (Dusun, RT, RW)</p>
                    <p>Pengelolaan data Dusun, RT, dan RW sekarang telah dipindahkan ke menu terpisah agar lebih terstruktur dan berelasi.</p>
                    <p className="mt-1">Silakan kelola di menu: <strong>Fondasi & Wilayah</strong> pada sidebar sebelah kiri.</p>
                  </div>
                </div>
              </section>

              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Logo & Visual</h2>
                <div className="grid md:grid-cols-2 gap-6">
                  <ImageUpload label="Logo Desa" value={form.watch("logo_desa") || ""} onUpload={(e) => handleUpload(e, "logo_desa")} />
                  <ImageUpload label="Favicon" value={form.watch("favicon") || ""} onUpload={(e) => handleUpload(e, "favicon")} />
                  <ImageUpload label="Logo Kabupaten" value={form.watch("logo_kabupaten") || ""} onUpload={(e) => handleUpload(e, "logo_kabupaten")} />
                  <ImageUpload label="Logo Provinsi" value={form.watch("logo_provinsi") || ""} onUpload={(e) => handleUpload(e, "logo_provinsi")} />
                </div>
              </section>
            </TabsContent>

            {/* TAB: KONTAK & LOKASI */}
            <TabsContent value="kontak" className="space-y-6 mt-0">
              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Kontak & Alamat</h2>
                <div className="grid md:grid-cols-2 gap-4">
                  <FormField control={form.control} name="alamat" render={({ field }) => (
                    <FormItem className="md:col-span-2"><FormLabel>Alamat Kantor Desa</FormLabel><FormControl><Input placeholder="Jln. Raya Seruni Mumbul No.1" {...field} /></FormControl><FormMessage /></FormItem>
                  )} />
                  <FormField control={form.control} name="kodepos" render={({ field }) => (
                    <FormItem><FormLabel>Kodepos</FormLabel><FormControl><Input placeholder="83654" {...field} /></FormControl><FormMessage /></FormItem>
                  )} />
                  <FormField control={form.control} name="kontak" render={({ field }) => (
                    <FormItem><FormLabel>Telepon / WA Admin</FormLabel><FormControl><Input placeholder="081234567890" {...field} /></FormControl><FormMessage /></FormItem>
                  )} />
                  <FormField control={form.control} name="email" render={({ field }) => (
                    <FormItem><FormLabel>Email Resmi</FormLabel><FormControl><Input type="email" placeholder="desa@seruni.id" {...field} /></FormControl><FormMessage /></FormItem>
                  )} />
                  <FormField control={form.control} name="website" render={({ field }) => (
                    <FormItem><FormLabel>Website</FormLabel><FormControl><Input placeholder="seruni.id" {...field} /></FormControl><FormMessage /></FormItem>
                  )} />
                </div>
              </section>

              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Peta Lokasi</h2>
                <FormField control={form.control} name="maps_embed_url" render={({ field }) => {
                  const mapsUrl = parseIframeToUrl(field.value || "");
                  return (
                    <FormItem>
                      <FormLabel>Google Maps Embed (URL atau Iframe)</FormLabel>
                      <FormControl>
                        <textarea
                          {...field}
                          rows={3}
                          className="w-full border border-input p-3 rounded-md text-sm font-mono focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent"
                          placeholder={'Bisa paste URL Embed atau langsung paste kode <iframe src="..."> dari Google Maps'}
                        />
                      </FormControl>
                      <FormDescription>Peta akan ditampilkan di halaman kontak.</FormDescription>
                      <FormMessage />
                      {mapsUrl && (
                        <div className="mt-4 rounded-md overflow-hidden border bg-muted" style={{ aspectRatio: "16/6" }}>
                          <iframe src={mapsUrl} className="w-full h-full border-0" loading="lazy" title="Preview Peta" />
                        </div>
                      )}
                    </FormItem>
                  );
                }} />
              </section>
            </TabsContent>

            {/* TAB: LAYANAN */}
            <TabsContent value="layanan" className="space-y-6 mt-0">
              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Informasi Layanan Publik</h2>
                <div className="grid gap-4">
                  <FormField control={form.control} name="tagline" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Tagline</FormLabel>
                      <FormControl><Input placeholder="Satu Data Desa. Pelayanan Terbuka." {...field} /></FormControl>
                      <FormDescription>Ditampilkan pada Header/Footer portal.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="jam_layanan" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Jam Layanan</FormLabel>
                      <FormControl><Input placeholder="Senin–Jumat · 08.00–15.00 WITA" {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="nomor_wa" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nomor WA Resmi (Layanan/Chatbot)</FormLabel>
                      <FormControl><Input placeholder="081234567890" {...field} /></FormControl>
                      <FormDescription>Digunakan untuk integrasi Chatbot WA dan tombol 'Hubungi Kami'.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="fonnte_token" render={({ field }) => (
                    <FormItem>
                      <FormLabel>API Key Fonnte (Token WA)</FormLabel>
                      <FormControl><Input type="password" placeholder="qHpiCwHavyAN..." {...field} /></FormControl>
                      <FormDescription>Token API Fonnte untuk mengirim notifikasi status surat secara otomatis.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )} />
                </div>
              </section>
            </TabsContent>

            {/* TAB: SOSMED */}
            <TabsContent value="sosmed" className="space-y-6 mt-0">
              <section className="bg-white p-6 rounded-lg border shadow-sm space-y-4">
                <h2 className="text-lg font-semibold border-b pb-2">Akun Sosial Media</h2>
                <p className="text-sm text-muted-foreground">Masukkan URL atau username. Sistem akan otomatis mengatur format linknya.</p>
                <div className="grid md:grid-cols-2 gap-4">
                  {(
                    [
                      ["sosmed_facebook", "Facebook", "facebook.com/desaseruni"],
                      ["sosmed_instagram", "Instagram", "instagram.com/desaseruni"],
                      ["sosmed_youtube", "YouTube", "youtube.com/@desaseruni"],
                      ["sosmed_tiktok", "TikTok", "tiktok.com/@desaseruni"],
                      ["sosmed_twitter", "Twitter / X", "twitter.com/desaseruni"],
                    ] as [keyof FormValues, string, string][]
                  ).map(([field, label, ph]) => (
                    <FormField key={field} control={form.control} name={field} render={({ field: formField }) => (
                      <FormItem>
                        <FormLabel>{label}</FormLabel>
                        <FormControl>
                          <Input placeholder={ph} {...formField} value={(formField.value as string) || ""} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )} />
                  ))}
                </div>
              </section>
            </TabsContent>

          </Tabs>
        </form>
      </Form>

      {/* --- Sticky bottom bar when dirty --- */}
      {isDirty && (
        <div className="fixed bottom-0 left-0 right-0 z-50 border-t border-amber-200 bg-amber-50 px-6 py-3 flex items-center justify-between shadow-lg">
          <span className="text-sm text-amber-700 font-medium flex items-center gap-2">
            <AlertCircle className="w-4 h-4" />
            Ada perubahan yang belum disimpan
          </span>
          <Button onClick={form.handleSubmit(onSubmit)} disabled={busy} className="bg-primary">
            <Save className="w-4 h-4 mr-2" />
            {busy ? "Menyimpan..." : "Simpan Sekarang"}
          </Button>
        </div>
      )}
    </div>
  );
}