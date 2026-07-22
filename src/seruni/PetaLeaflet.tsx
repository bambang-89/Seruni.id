import { useEffect, useRef } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

// Fix default marker icons for Vite bundler
import icon from "leaflet/dist/images/marker-icon.png";
import icon2x from "leaflet/dist/images/marker-icon-2x.png";
import shadow from "leaflet/dist/images/marker-shadow.png";

const DefaultIcon = L.icon({
  iconRetinaUrl: icon2x,
  iconUrl: icon,
  shadowUrl: shadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});
L.Marker.prototype.options.icon = DefaultIcon;

export type MapPoint = {
  id: string;
  nama: string;
  jenis?: string;
  deskripsi?: string | null;
  latitude: number;
  longitude: number;
};

export function PetaLeaflet({ points, center = [-8.535, 116.655], zoom = 13 }: { points: MapPoint[]; center?: [number, number]; zoom?: number }) {
  const ref = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<L.Map | null>(null);

  useEffect(() => {
    if (!ref.current || mapRef.current) return;
    const map = L.map(ref.current, { scrollWheelZoom: false }).setView(center, zoom);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map);
    mapRef.current = map;
    return () => { map.remove(); mapRef.current = null; };
  }, []);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    const layer = L.layerGroup().addTo(map);
    const valid = points.filter((p) => Number.isFinite(p.latitude) && Number.isFinite(p.longitude));
    valid.forEach((p) => {
      L.marker([p.latitude, p.longitude])
        .addTo(layer)
        .bindPopup(
          `<div style="font-family:'Poppins',sans-serif;min-width:180px">
            <div style="font-size:10px;letter-spacing:0.2em;text-transform:uppercase;color:#FF9E20;font-weight:700">${p.jenis || ""}</div>
            <div style="font-weight:600;margin-top:4px">${p.nama}</div>
            ${p.deskripsi ? `<div style=\"font-size:12px;margin-top:6px;color:#444\">${p.deskripsi}</div>` : ""}
          </div>`
        );
    });
    if (valid.length) {
      const bounds = L.latLngBounds(valid.map((p) => [p.latitude, p.longitude] as [number, number]));
      map.fitBounds(bounds.pad(0.25));
    }
    return () => { layer.remove(); };
  }, [points]);

  return <div ref={ref} className="h-[560px] w-full" role="application" aria-label="Peta interaktif desa" />;
}