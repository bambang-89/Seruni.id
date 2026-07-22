import { useEffect, useState } from "react";

/**
 * Reactive online/offline status. Reads navigator.onLine and subscribes to
 * the browser's online/offline events. Safe on SSR (defaults to true).
 */
export function useOnlineStatus(): boolean {
  const [online, setOnline] = useState<boolean>(
    typeof navigator === "undefined" ? true : navigator.onLine,
  );
  useEffect(() => {
    const up = () => setOnline(true);
    const down = () => setOnline(false);
    window.addEventListener("online", up);
    window.addEventListener("offline", down);
    return () => {
      window.removeEventListener("online", up);
      window.removeEventListener("offline", down);
    };
  }, []);
  return online;
}