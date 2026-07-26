import React from 'react';
import { usePageHeroConfig } from '../lib/queries';
import { supabase } from '@/integrations/supabase/client';

export function PageHero({ route }: { route: string }) {
  const { data, loading } = usePageHeroConfig(route);
  
  if (loading || !data) return null;
  
  const isHomepage = route === '/';
  // Use 100vh for homepage if desired, or 50vh based on request. 
  // User asked for 50vh for all pages except detail & admin, but homepage might be full screen.
  // Actually user said "di seluruh halaman Publik kecuali Detailpage dan Homepage... tambahkan Hero dengan ukuran tinggi 50%".
  // "DAN UNTUK SEMUA HALAMAN tanpa terkecuali tambahkan Pengaturan... khusus homepage, selain gambar, user juga bisa menambahkan Video".
  // So homepage keeps its own size (maybe 100vh) but gets the background from this config.
  // For other pages it is 50vh.
  const heightClass = isHomepage ? 'h-screen' : 'h-[50vh]';

  const imageUrl = data.image_path ? supabase.storage.from('seruni-media').getPublicUrl(data.image_path).data.publicUrl : null;
  const videoUrl = (isHomepage && data.video_path) ? supabase.storage.from('seruni-media').getPublicUrl(data.video_path).data.publicUrl : null;

  return (
    <div className={`relative w-full ${heightClass} overflow-hidden flex items-center justify-center`}>
      {videoUrl ? (
        <video 
          src={videoUrl} 
          autoPlay 
          loop 
          muted 
          playsInline 
          className="absolute inset-0 w-full h-full object-cover"
        />
      ) : imageUrl ? (
        <img 
          src={imageUrl} 
          alt={data.title || "Hero Background"} 
          className="absolute inset-0 w-full h-full object-cover"
        />
      ) : (
        <div className="absolute inset-0 bg-accent/20" /> // Fallback background
      )}
      
      {/* Dark Overlay 50% */}
      <div className="absolute inset-0 bg-black/50" />

      {/* Content */}
      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto">
        {data.title && (
          <h1 className="text-3xl md:text-5xl lg:text-6xl font-display font-bold text-white mb-4 uppercase tracking-wider">
            {data.title}
          </h1>
        )}
        {data.subtitle && (
          <p className="text-lg md:text-xl text-white/90 font-medium">
            {data.subtitle}
          </p>
        )}
      </div>
    </div>
  );
}
