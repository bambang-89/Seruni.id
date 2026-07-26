import React from 'react';
import { TableCrud, PageTitle } from './AdminPages';

export function HeroAdmin() {
  return (
    <div>
      <PageTitle title="Manajemen Hero" desc="Atur gambar, video (khusus homepage), dan teks judul hero untuk setiap halaman." />
      <TableCrud
        table="page_hero_config"
        title="Daftar Hero Halaman"
        desc="Kelola hero banner untuk setiap rute halaman publik."
        blank={{ page_route: "/", title: "", subtitle: "", image_path: "", video_path: "", is_active: true } as any}
        columns={[
          { key: "page_route", label: "Rute Halaman", type: "text" },
          { key: "title", label: "Judul", type: "text" },
          { key: "subtitle", label: "Sub Judul", type: "textarea", hideInTable: true },
          { key: "image_path", label: "Gambar (Semua Halaman)", type: "image", imageFolder: "hero" },
          { key: "video_path", label: "Video (Khusus /)", type: "video" as any, imageFolder: "hero", hideInTable: true },
          { key: "is_active", label: "Aktif", type: "checkbox" },
        ]}
      />
    </div>
  );
}
