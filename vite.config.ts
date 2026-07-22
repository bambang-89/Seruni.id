import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";
import { VitePWA } from "vite-plugin-pwa";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  server: {
    host: "::",
    port: 8080,
  },
  plugins: [
    react(),
    mode === "development" && componentTagger(),
    VitePWA({
      registerType: "autoUpdate",
      injectRegister: null,
      filename: "sw.js",
      devOptions: { enabled: false },
      includeAssets: ["favicon.ico", "apple-touch-icon.png", "robots.txt"],
      manifest: {
        name: "Kantor Desa Seruni Mumbul",
        short_name: "Seruni Mumbul",
        description:
          "Portal resmi Kantor Desa Seruni Mumbul — layanan surat, APBDes, pengaduan, agenda, dan status IDM.",
        start_url: "/",
        scope: "/",
        display: "standalone",
        background_color: "#ffffff",
        theme_color: "#015967",
        lang: "id",
        icons: [
          { src: "/pwa-192.png", sizes: "192x192", type: "image/png" },
          { src: "/pwa-512.png", sizes: "512x512", type: "image/png" },
          { src: "/pwa-512.png", sizes: "512x512", type: "image/png", purpose: "any maskable" },
        ],
      },
      workbox: {
        globPatterns: ["**/*.{js,css,html,ico,png,svg,webp,woff2}"],
        navigateFallback: "/index.html",
        navigateFallbackDenylist: [/^\/~oauth/, /^\/admin/, /^\/functions\//],
        cleanupOutdatedCaches: true,
        runtimeCaching: [
          {
            urlPattern: ({ request }) => request.mode === "navigate",
            handler: "NetworkFirst",
            options: {
              cacheName: "html-nav",
              networkTimeoutSeconds: 3,
            },
          },
          {
            // Supabase REST public reads for Potensi/Marketplace/Wisata
            urlPattern: ({ url, request }) =>
              request.method === "GET" &&
              /supabase\.co$/i.test(url.hostname) &&
              /\/rest\/v1\/(potensi_umkm|potensi_produk|potensi_wisata|wilayah_dusun|profil_desa|desa_pamong|lembaga_desa|berita|agenda|pengumuman|galeri|page_config|nav_item|footer_column)(\?|$)/.test(url.pathname + url.search),
            handler: "NetworkFirst",
            options: {
              cacheName: "seruni-public-data",
              networkTimeoutSeconds: 3,
              expiration: { maxEntries: 80, maxAgeSeconds: 60 * 60 * 24 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            // Signed-URL images served from the seruni-media bucket
            urlPattern: ({ url }) =>
              /supabase\.co$/i.test(url.hostname) &&
              url.pathname.includes("/storage/v1/object/") &&
              url.pathname.includes("/seruni-media/"),
            handler: "CacheFirst",
            options: {
              cacheName: "seruni-media",
              expiration: { maxEntries: 120, maxAgeSeconds: 60 * 60 * 24 * 7 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: ({ url }) =>
              url.origin === "https://fonts.googleapis.com" ||
              url.origin === "https://fonts.gstatic.com",
            handler: "CacheFirst",
            options: {
              cacheName: "google-fonts",
              expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 * 24 * 365 },
            },
          },
          {
            urlPattern: ({ request, sameOrigin }) =>
              sameOrigin && ["image", "font"].includes(request.destination),
            handler: "CacheFirst",
            options: {
              cacheName: "assets",
              expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 * 30 },
            },
          },
        ],
      },
    }),
  ].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          "vendor-react": ["react", "react-dom", "react-router-dom"],
          "vendor-charts": ["recharts"],
          "vendor-map": ["leaflet", "react-leaflet"],
          "vendor-supabase": ["@supabase/supabase-js"],
        },
      },
    },
  },
}));
