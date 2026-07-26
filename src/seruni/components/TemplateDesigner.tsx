/**
 * Surat Template Designer Component
 * Untuk membuat dan edit template KOP surat
 */

import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useUpload } from '@/seruni/lib/upload';
import { ImageWithFallback } from '@/components/figma/ImageWithFallback';

export type SuratTemplate = {
  id?: string;
  nama: string;
  kode: string;
  description?: string;
  is_default: boolean;
  is_active: boolean;

  // Header
  header_enabled: boolean;
  header_height: number;
  header_background_color: string;
  header_border_bottom_enabled: boolean;
  header_border_bottom_color: string;
  header_border_bottom_style: string;
  header_border_bottom_width: number;

  // Logo
  logo_kiri_url: string;
  logo_kiri_width: number;
  logo_kiri_height: number;
  logo_kiri_visible: boolean;
  logo_kanan_url: string;
  logo_kanan_width: number;
  logo_kanan_height: number;
  logo_kanan_visible: boolean;

  // Judul
  judul_instansi_enabled: boolean;
  judul_instansi_text: string;
  judul_instansi_font_size: number;
  judul_instansi_font_weight: string;

  sub_judul_instansi_text: string;
  sub_judul_font_size: number;

  nama_desa_text: string;
  nama_desa_font_size: number;
  nama_desa_font_weight: string;

  alamat_desa_text: string;
  alamat_font_size: number;

  // Garis
  garis_enabled: boolean;
  garis_color: string;
  garis_height: number;

  // Footer
  footer_ttd_kanan_enabled: boolean;
  footer_ttd_kanan_judul: string;
  footer_ttd_kanan_nama?: string;
  footer_ttd_kanan_nip?: string;

  // Page
  page_size: string;
  page_orientation: string;
};

interface TemplateDesignerProps {
  template?: SuratTemplate;
  onSave?: (template: SuratTemplate) => void;
  onPreview?: () => void;
}

/**
 * Template Designer Form
 */
export function TemplateDesigner({ template, onSave, onPreview }: TemplateDesignerProps) {
  const { upload } = useUpload();
  const [form, setForm] = useState<SuratTemplate>({
    nama: '',
    kode: '',
    description: '',
    is_default: false,
    is_active: true,
    header_enabled: true,
    header_height: 100,
    header_background_color: '#FFFFFF',
    header_border_bottom_enabled: true,
    header_border_bottom_color: '#000000',
    header_border_bottom_style: 'solid',
    header_border_bottom_width: 2,
    logo_kiri_url: '',
    logo_kiri_width: 60,
    logo_kiri_height: 60,
    logo_kiri_visible: true,
    logo_kanan_url: '',
    logo_kanan_width: 60,
    logo_kanan_height: 60,
    logo_kanan_visible: true,
    judul_instansi_enabled: true,
    judul_instansi_text: 'PEMERINTAH KABUPATEN LOMBOK TIMUR',
    judul_instansi_font_size: 14,
    judul_instansi_font_weight: 'bold',
    sub_judul_instansi_text: 'KECAMATAN PRINGGABAYA',
    sub_judul_font_size: 12,
    nama_desa_text: 'DESA SERUNI MUMBUL',
    nama_desa_font_size: 16,
    nama_desa_font_weight: 'bold',
    alamat_desa_text: 'Jl. Raya Seruni Mumbul No. 1, Pringgabaya, Lombok Timur 83654',
    alamat_font_size: 10,
    garis_enabled: true,
    garis_color: '#000000',
    garis_height: 2,
    footer_ttd_kanan_enabled: true,
    footer_ttd_kanan_judul: 'Kepala Desa',
    footer_ttd_kanan_nama: '',
    footer_ttd_kanan_nip: '',
    page_size: 'A4',
    page_orientation: 'portrait',
    ...template,
  });

  const [saving, setSaving] = useState(false);

  const updateField = useCallback((
    field: keyof SuratTemplate,
    value: any
  ) => {
    setForm(prev => ({ ...prev, [field]: value }));
  }, []);

  const handleLogoUpload = async (
    side: 'kiri' | 'kanan',
    file: File
  ) => {
    const result = await upload(file, {
      entityType: 'template',
      kategori: 'foto_profil',
    });

    if (result.success && result.url) {
      if (side === 'kiri') {
        updateField('logo_kiri_url', result.url);
      } else {
        updateField('logo_kanan_url', result.url);
      }
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const data = { ...form };
      delete (data as any).id; // Remove id for insert

      let result;
      if (template?.id) {
        result = await supabase
          .from('surat_template')
          .update(data)
          .eq('id', template.id)
          .select()
          .single();
      } else {
        result = await supabase
          .from('surat_template')
          .insert(data)
          .select()
          .single();
      }

      if (result.error) throw result.error;
      onSave?.(result.data);
    } catch (err) {
      console.error('Save failed:', err);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Basic Info */}
      <div className="grid gap-4 md:grid-cols-2">
        <div>
          <label className="block text-sm font-medium mb-1">Nama Template</label>
          <input
            type="text"
            value={form.nama}
            onChange={e => updateField('nama', e.target.value)}
            autoComplete="off"
            className="w-full border rounded-md px-3 py-2"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Kode</label>
          <input
            type="text"
            value={form.kode}
            onChange={e => updateField('kode', e.target.value)}
            autoComplete="off"
            className="w-full border rounded-md px-3 py-2"
          />
        </div>
      </div>

      {/* Header Settings */}
      <div className="border-t pt-4">
        <h3 className="font-semibold mb-4">Header / KOP Surat</h3>

        <div className="space-y-4">
          {/* Logo Section */}
          <div className="grid gap-4 md:grid-cols-2">
            {/* Logo Kiri */}
            <div className="border rounded-lg p-4">
              <h4 className="font-medium mb-2">Logo Kiri</h4>
              <div className="flex items-start gap-4">
                <div className="w-20 h-20 border rounded flex items-center justify-center bg-gray-50">
                  {form.logo_kiri_url ? (
                    <img
                      src={form.logo_kiri_url}
                      alt="Logo Kiri"
                      className="max-w-full max-h-full object-contain"
                    />
                  ) : (
                    <span className="text-gray-400 text-xs">No Logo</span>
                  )}
                </div>
                <div className="flex-1 space-y-2">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={e => {
                      const file = e.target.files?.[0];
                      if (file) handleLogoUpload('kiri', file);
                    }}
                    className="text-sm"
                  />
                  <label className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={form.logo_kiri_visible}
                      onChange={e => updateField('logo_kiri_visible', e.target.checked)}
                    />
                    Tampilkan
                  </label>
                </div>
              </div>
            </div>

            {/* Logo Kanan */}
            <div className="border rounded-lg p-4">
              <h4 className="font-medium mb-2">Logo Kanan</h4>
              <div className="flex items-start gap-4">
                <div className="w-20 h-20 border rounded flex items-center justify-center bg-gray-50">
                  {form.logo_kanan_url ? (
                    <img
                      src={form.logo_kanan_url}
                      alt="Logo Kanan"
                      className="max-w-full max-h-full object-contain"
                    />
                  ) : (
                    <span className="text-gray-400 text-xs">No Logo</span>
                  )}
                </div>
                <div className="flex-1 space-y-2">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={e => {
                      const file = e.target.files?.[0];
                      if (file) handleLogoUpload('kanan', file);
                    }}
                    className="text-sm"
                  />
                  <label className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={form.logo_kanan_visible}
                      onChange={e => updateField('logo_kanan_visible', e.target.checked)}
                    />
                    Tampilkan
                  </label>
                </div>
              </div>
            </div>
          </div>

          {/* Judul Instansi */}
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <label className="block text-sm font-medium mb-1">Judul Instansi</label>
              <input
                type="text"
                value={form.judul_instansi_text}
                onChange={e => updateField('judul_instansi_text', e.target.value)}
                autoComplete="off"
                className="w-full border rounded-md px-3 py-2"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Font Size</label>
              <input
                type="number"
                value={form.judul_instansi_font_size}
                onChange={e => updateField('judul_instansi_font_size', parseInt(e.target.value))}
                autoComplete="off"
                className="w-full border rounded-md px-3 py-2"
              />
            </div>
          </div>

          {/* Sub Judul */}
          <div>
            <label className="block text-sm font-medium mb-1">Sub Judul</label>
            <input
              type="text"
              value={form.sub_judul_instansi_text}
              onChange={e => updateField('sub_judul_instansi_text', e.target.value)}
              autoComplete="off"
              className="w-full border rounded-md px-3 py-2"
            />
          </div>

          {/* Nama Desa */}
          <div>
            <label className="block text-sm font-medium mb-1">Nama Desa</label>
            <input
              type="text"
              value={form.nama_desa_text}
              onChange={e => updateField('nama_desa_text', e.target.value)}
              autoComplete="off"
              className="w-full border rounded-md px-3 py-2 font-bold"
            />
          </div>

          {/* Alamat */}
          <div>
            <label className="block text-sm font-medium mb-1">Alamat</label>
            <input
              type="text"
              value={form.alamat_desa_text}
              onChange={e => updateField('alamat_desa_text', e.target.value)}
              autoComplete="off"
              className="w-full border rounded-md px-3 py-2"
            />
          </div>

          {/* Garis Pembatas */}
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={form.garis_enabled}
                onChange={e => updateField('garis_enabled', e.target.checked)}
              />
              Tampilkan Garis Pembatas
            </label>
            {form.garis_enabled && (
              <>
                <input
                  type="color"
                  value={form.garis_color}
                  onChange={e => updateField('garis_color', e.target.value)}
                  className="w-8 h-8 border rounded"
                />
                <input
                  type="number"
                  value={form.garis_height}
                  onChange={e => updateField('garis_height', parseInt(e.target.value))}
                  autoComplete="off"
                  className="w-16 border rounded px-2 py-1"
                  min={1}
                  max={10}
                />
              </>
            )}
          </div>
        </div>
      </div>

      {/* Footer Settings */}
      <div className="border-t pt-4">
        <h3 className="font-semibold mb-4">Footer / Tanda Tangan</h3>

        <div className="space-y-4">
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={form.footer_ttd_kanan_enabled}
              onChange={e => updateField('footer_ttd_kanan_enabled', e.target.checked)}
            />
            Tampilkan Tanda Tangan Kanan
          </label>

          {form.footer_ttd_kanan_enabled && (
            <div className="grid gap-4 md:grid-cols-3">
              <div>
                <label className="block text-sm font-medium mb-1">Judul</label>
                <input
                  type="text"
                  value={form.footer_ttd_kanan_judul}
                  onChange={e => updateField('footer_ttd_kanan_judul', e.target.value)}
                  autoComplete="off"
                  className="w-full border rounded-md px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Nama</label>
                <input
                  type="text"
                  value={form.footer_ttd_kanan_nama || ''}
                  onChange={e => updateField('footer_ttd_kanan_nama', e.target.value)}
                  autoComplete="off"
                  className="w-full border rounded-md px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">NIP</label>
                <input
                  type="text"
                  value={form.footer_ttd_kanan_nip || ''}
                  onChange={e => updateField('footer_ttd_kanan_nip', e.target.value)}
                  autoComplete="off"
                  className="w-full border rounded-md px-3 py-2"
                />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-4 pt-4 border-t">
        <button
          onClick={handleSave}
          disabled={saving}
          className="px-6 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50"
        >
          {saving ? 'Menyimpan...' : 'Simpan Template'}
        </button>
        <button
          onClick={onPreview}
          className="px-6 py-2 border rounded-md hover:bg-gray-50"
        >
          Preview
        </button>
      </div>
    </div>
  );
}

/**
 * Template List Component
 */
export function TemplateList({
  onSelect,
  selectedId,
}: {
  onSelect: (template: SuratTemplate) => void;
  selectedId?: string;
}) {
  const [templates, setTemplates] = useState<SuratTemplate[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from('surat_template')
      .select('*')
      .order('is_default', { ascending: false })
      .then(({ data }) => {
        setTemplates(data || []);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <div className="p-4">Memuat...</div>;
  }

  return (
    <div className="space-y-2">
      {templates.map(template => (
        <div
          key={template.id}
          onClick={() => onSelect(template)}
          className={`p-4 border rounded-lg cursor-pointer hover:bg-gray-50 ${
            selectedId === template.id ? 'border-primary bg-primary/5' : ''
          }`}
        >
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">{template.nama}</h4>
              <p className="text-sm text-gray-500">{template.kode}</p>
            </div>
            {template.is_default && (
              <span className="text-xs bg-primary/10 text-primary px-2 py-1 rounded">
                Default
              </span>
            )}
          </div>
        </div>
      ))}

      {templates.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          Belum ada template
        </div>
      )}
    </div>
  );
}
