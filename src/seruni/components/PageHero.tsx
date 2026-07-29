import React from 'react';
import { usePageHeroConfig } from '../lib/queries';
import { supabase } from '@/integrations/supabase/client';

export function PageHero({ route }: { route: string }) {
  const { data, loading } = usePageHeroConfig(route);

  const isHomepage = route === '/';
  const heightClass = isHomepage ? 'h-screen' : 'h-[55vh]';

  if (loading) {
    return <div className={`w-full ${heightClass} bg-[#0F0E0E] animate-pulse`} />;
  }

  const title = data?.title || (isHomepage ? "Desa Seruni Mumbul" : "Halaman");
  const subtitle = data?.subtitle || (isHomepage ? "Kecamatan Pringgabaya, Kabupaten Lombok Timur" : "");

  const imageUrl = data?.image_path
    ? (data.image_path.startsWith('http') ? data.image_path : supabase.storage.from('seruni-media').getPublicUrl(data.image_path).data.publicUrl)
    : null;

  const videoUrl = (isHomepage && data?.video_path)
    ? (data.video_path.startsWith('http') ? data.video_path : supabase.storage.from('seruni-media').getPublicUrl(data.video_path).data.publicUrl)
    : null;

  const hasMedia = !!(videoUrl || imageUrl);

  return (
    <div className={`relative w-full ${heightClass} overflow-hidden flex items-center bg-[#0F0E0E]`}>
      {/* Background media */}
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
          alt=""
          aria-hidden
          className="absolute inset-0 w-full h-full object-cover"
        />
      ) : null}

      {/* Gradient overlay: dark on left, transparent on right */}
      <div
        aria-hidden
        className="absolute inset-0"
        style={{
          background: hasMedia
            ? 'linear-gradient(to right, rgba(15,14,12,0.95) 0%, rgba(15,14,12,0.75) 45%, rgba(15,14,12,0.2) 80%, rgba(15,14,12,0) 100%)'
            : 'linear-gradient(135deg, #0f0e0e 0%, #1a1714 50%, #0f0e0e 100%)',
        }}
      />

      {/* Content — left-aligned, below fixed navbar */}
      <div className="relative z-10 w-full max-w-7xl mx-auto px-6 sm:px-8 lg:px-12 pt-20 md:pt-24">
        <div className="max-w-2xl">
          {/* Divider line */}
          <div className="w-12 h-px bg-accent mb-6" />

          {/* Title */}
          <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-bold text-white leading-[1.05] mb-4">
            {title}
          </h1>

          {/* Subtitle */}
          {subtitle && (
            <p className="text-base sm:text-lg text-white/80 leading-relaxed max-w-xl">
              {subtitle}
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
