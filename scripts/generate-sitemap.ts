// Runs before `vite dev` and `vite build` (predev/prebuild hooks);
// writes public/sitemap.xml with every public route of the Seruni portal.

import { writeFileSync } from "fs";
import { resolve } from "path";

// TODO: replace with the project URL once a custom domain is connected.
const BASE_URL = "";

interface Entry {
  path: string;
  changefreq?: "always" | "hourly" | "daily" | "weekly" | "monthly" | "yearly" | "never";
  priority?: string;
}

const entries: Entry[] = [
  { path: "/", changefreq: "daily", priority: "1.0" },
  { path: "/profil-desa", changefreq: "monthly", priority: "0.8" },
  { path: "/profil-desa/struktur", changefreq: "monthly", priority: "0.6" },
  { path: "/profil-desa/wilayah", changefreq: "monthly", priority: "0.6" },
  { path: "/profil-desa/lembaga", changefreq: "monthly", priority: "0.6" },
  { path: "/berita", changefreq: "daily", priority: "0.9" },
  { path: "/kalender-desa", changefreq: "weekly", priority: "0.7" },
  { path: "/galeri", changefreq: "weekly", priority: "0.6" },
  { path: "/pengumuman", changefreq: "weekly", priority: "0.7" },
  { path: "/layanan", changefreq: "monthly", priority: "0.8" },
  { path: "/layanan/surat", changefreq: "monthly", priority: "0.7" },
  { path: "/layanan/pbb", changefreq: "monthly", priority: "0.7" },
  { path: "/service-center", changefreq: "monthly", priority: "0.6" },
  { path: "/verifikasi", changefreq: "monthly", priority: "0.5" },
  { path: "/statistik", changefreq: "monthly", priority: "0.6" },
  { path: "/status-idm", changefreq: "monthly", priority: "0.6" },
  { path: "/statistik/penduduk", changefreq: "monthly", priority: "0.6" },
  { path: "/pembangunan", changefreq: "monthly", priority: "0.6" },
  { path: "/perencanaan", changefreq: "monthly", priority: "0.6" },
  { path: "/keuangan", changefreq: "monthly", priority: "0.7" },
  { path: "/potensi-desa", changefreq: "monthly", priority: "0.7" },
  { path: "/marketplace", changefreq: "weekly", priority: "0.7" },
  { path: "/peta-desa", changefreq: "monthly", priority: "0.6" },
  { path: "/langganan-wa", changefreq: "monthly", priority: "0.5" },
];

function render(list: Entry[]) {
  const urls = list.map((e) =>
    [
      "  <url>",
      `    <loc>${BASE_URL}${e.path}</loc>`,
      e.changefreq ? `    <changefreq>${e.changefreq}</changefreq>` : null,
      e.priority ? `    <priority>${e.priority}</priority>` : null,
      "  </url>",
    ]
      .filter(Boolean)
      .join("\n"),
  );
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...urls,
    "</urlset>",
  ].join("\n");
}

writeFileSync(resolve("public/sitemap.xml"), render(entries));
console.log(`sitemap.xml written (${entries.length} entries)`);