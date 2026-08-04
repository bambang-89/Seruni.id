import React, { useState, useEffect } from 'react';
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { PageTitle } from './AdminPages';
import { ImageField } from '../components/TableCrud';
import { StandaloneFormOverlay } from '../ui';
import { useTenantId } from '../lib/tenant';
import { useConfirm } from '../ui/ConfirmDialog';

type HeroRow = {
  id?: string;
  page_route: string;
  title: string;
  subtitle: string;
  image_path: string;
  video_path: string;
  is_active: boolean;
  tenant_id?: string;
};

const inp = "w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary";
const btnPri = "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-60";
const btnSec = "rounded-md border border-border bg-background px-3 py-1.5 text-sm hover:bg-muted";
const btnDanger = "rounded-md border border-destructive/40 text-destructive bg-background px-3 py-1.5 text-sm hover:bg-destructive/10";

export function HeroAdmin() {
  const [rows, setRows] = useState<HeroRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<HeroRow | null>(null);
  const tenantId = useTenantId();
  const confirm = useConfirm();

  const load = async () => {
    setLoading(true);
    const { data, error } = await supabase.from('page_hero_config').select('*').order('page_route');
    if (error) toast.error("Gagal memuat data: " + error.message);
    else setRows(data || []);
    setLoading(false);
  };

  useEffect(() => { load(); }, []);

  const save = async (row: HeroRow) => {
    if (!row.page_route?.trim()) {
      toast.error("Rute Halaman harus diisi");
      return;
    }
    
    const payload = { ...row };
    if (tenantId) payload.tenant_id = tenantId;
    
    if (payload.id) {
      const { id, ...updateData } = payload;
      const { error } = await supabase.from('page_hero_config').update(updateData).eq('id', id);
      if (error) toast.error(error.message);
      else { toast.success("Tersimpan."); setDraft(null); load(); }
    } else {
      const { error } = await supabase.from('page_hero_config').insert(payload);
      if (error) toast.error(error.message);
      else { toast.success("Tersimpan."); setDraft(null); load(); }
    }
  };

  const del = async (id: string) => {
    if (!(await confirm({ title: "Hapus hero konfigurasi ini?" }))) return;
    const { error } = await supabase.from('page_hero_config').delete().eq('id', id);
    if (error) toast.error(error.message);
    else { toast.success("Terhapus."); load(); }
  };

  const blankRow = (): HeroRow => ({
    page_route: "",
    title: "",
    subtitle: "",
    image_path: "",
    video_path: "",
    is_active: true
  });

  return (
    <div className="pb-20">
      <PageTitle title="Manajemen Hero" desc="Atur gambar, video (khusus homepage), dan teks judul hero untuk setiap halaman." />

      <div className="flex justify-end mb-4">
        <button onClick={() => setDraft(blankRow())} className={btnPri}>+ Tambah Konfigurasi Hero</button>
      </div>

      {draft && (
        <StandaloneFormOverlay title={`${draft.id ? "Edit" : "Tambah"} Hero (${draft.page_route || "Baru"})`} onClose={() => setDraft(null)}>
          <div className="space-y-4">
            <div>
              <label className="block text-xs font-medium mb-1">Rute Halaman (contoh: / atau /profil-desa)</label>
              <input value={draft.page_route} onChange={e => setDraft({ ...draft, page_route: e.target.value })} className={inp} placeholder="/" />
              <p className="text-[10px] text-muted-foreground mt-1">Hanya hero yang berada pada rute ini yang akan terpengaruh.</p>
            </div>
            
            <div>
              <label className="block text-xs font-medium mb-1">Judul Utama</label>
              <input value={draft.title} onChange={e => setDraft({ ...draft, title: e.target.value })} className={inp} placeholder="Desa Seruni Mumbul" />
            </div>

            <div>
              <label className="block text-xs font-medium mb-1">Sub Judul</label>
              <textarea rows={3} value={draft.subtitle} onChange={e => setDraft({ ...draft, subtitle: e.target.value })} className={inp} placeholder="Kecamatan Pringgabaya..." />
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium mb-1">Background Image</label>
                <ImageField value={draft.image_path || ""} folder="hero" onChange={(url: string) => setDraft({ ...draft, image_path: url })} />
              </div>
              
              <div>
                <label className="block text-xs font-medium mb-1">Background Video URL (opsional)</label>
                <input value={draft.video_path || ""} onChange={e => setDraft({ ...draft, video_path: e.target.value })} className={inp} placeholder="URL video /mp4" />
                <p className="text-[10px] text-muted-foreground mt-1">Jika diisi, akan prioritas ditampilkan daripada gambar (umumnya hanya dipakai di Homepage `/`).</p>
              </div>
            </div>

            <div className="flex items-center gap-2 pt-2 border-t mt-4">
              <input type="checkbox" checked={draft.is_active} onChange={e => setDraft({ ...draft, is_active: e.target.checked })} className="h-4 w-4 rounded border-gray-300" id="is_active_check" />
              <label htmlFor="is_active_check" className="text-sm font-medium">Aktif tampilkan hero ini</label>
            </div>

            <div className="flex justify-end gap-3 pt-4 border-t border-current/10 mt-6">
              <button onClick={() => setDraft(null)} className="px-4 py-2 text-sm bg-secondary text-secondary-foreground rounded-lg hover:opacity-90">Batal</button>
              <button onClick={() => save(draft)} className="px-4 py-2 text-sm bg-primary text-primary-foreground rounded-lg hover:opacity-90">Simpan</button>
            </div>
          </div>
        </StandaloneFormOverlay>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading && <p className="text-sm text-muted-foreground col-span-full">Memuat...</p>}
        {!loading && rows.length === 0 && <p className="text-sm text-muted-foreground col-span-full">Belum ada konfigurasi hero.</p>}
        {rows.map(r => (
          <div key={r.id} className="relative rounded-xl border border-border bg-card overflow-hidden flex flex-col group">
            <div className="aspect-[21/9] w-full bg-muted relative">
              {r.image_path ? (
                 <img src={r.image_path.startsWith('http') ? r.image_path : supabase.storage.from('seruni-media').getPublicUrl(r.image_path).data.publicUrl} alt="" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-xs text-muted-foreground">Tidak ada gambar</div>
              )}
              {r.video_path && (
                <div className="absolute top-2 right-2 bg-black/60 text-white text-[10px] px-2 py-1 rounded backdrop-blur-sm">
                  Berisi Video
                </div>
              )}
            </div>
            
            <div className="p-4 flex-1 flex flex-col">
              <div className="flex justify-between items-start mb-2">
                <span className="bg-primary/10 text-primary px-2 py-0.5 rounded text-[10px] font-mono font-bold tracking-wider">{r.page_route}</span>
                {!r.is_active && <span className="bg-destructive/10 text-destructive px-2 py-0.5 rounded text-[10px]">Non-aktif</span>}
              </div>
              <h3 className="font-semibold text-sm line-clamp-1 mb-1">{r.title || "(Tanpa Judul)"}</h3>
              <p className="text-xs text-muted-foreground line-clamp-2 mb-4 flex-1">{r.subtitle || "(Tanpa Sub Judul)"}</p>
              
              <div className="flex justify-end gap-2 mt-auto pt-3 border-t">
                <button onClick={() => setDraft(r)} className={btnSec}>Edit</button>
                <button onClick={() => r.id && del(r.id)} className={btnDanger}>Hapus</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
