import React from 'react';
import { usePageHeroConfig } from '../lib/queries';
import { supabase } from '@/integrations/supabase/client';

export function PageHero({ route }: { route: string }) {
  const { data, loading } = usePageHeroConfig(route);
  
  const isHomepage = route === '/';
  const heightClass = isHomepage ? 'h-screen' : 'h-[50vh]';

  if (loading) {
    return <div className={`w-full ${heightClass} bg-accent/20 animate-pulse`} />;
  }

  const title = data?.title || (isHomepage ? "Desa Seruni Mumbul" : "Halaman");
  const subtitle = data?.subtitle || (isHomepage ? "Kecamatan Pringgabaya, Kabupaten Lombok Timur" : "");

  const imageUrl = data?.image_path 
    ? (data.image_path.startsWith('http') ? data.image_path : supabase.storage.from('seruni-media').getPublicUrl(data.image_path).data.publicUrl) 
    : null;
    
  const videoUrl = (isHomepage && data?.video_path) 
    ? (data.video_path.startsWith('http') ? data.video_path : supabase.storage.from('seruni-media').getPublicUrl(data.video_path).data.publicUrl) 
    : null;

  return (
    <div className={`relative w-full ${heightClass} overflow-hidden flex items-center justify-center bg-[#0F0E0E]`}>
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
          alt={title} 
          className="absolute inset-0 w-full h-full object-cover"
        />
      ) : (
        <div className="absolute inset-0 bg-accent/20" /> // Fallback background
      )}
      
      {/* Dark Overlay 50% */}
      <div className="absolute inset-0 bg-black/60" />

      {/* Content */}
      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto">
        {title && (
          <h1 className="text-3xl md:text-5xl lg:text-6xl font-display font-bold text-white mb-4 uppercase tracking-wider">
            {title}
          </h1>
        )}
        {subtitle && (
          <p className="text-lg md:text-xl text-white/90 font-medium">
            {subtitle}
          </p>
        )}
      </div>
    </div>
  );
}
