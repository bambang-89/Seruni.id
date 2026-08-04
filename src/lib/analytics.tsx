import { useEffect, useCallback } from 'react';
import { useLocation } from 'react-router-dom';

/**
 * Simple analytics hook for page view tracking
 * Sends events to Supabase or external analytics service
 */

interface AnalyticsEvent {
  event: string;
  properties?: Record<string, string | number | boolean>;
}

interface UseAnalyticsReturn {
  trackPageView: (page?: string) => void;
  trackEvent: (event: string, properties?: Record<string, string | number | boolean>) => void;
}

export function useAnalytics(): UseAnalyticsReturn {
  const location = useLocation();

  // Track custom event
  const trackEvent = useCallback((
    event: string,
    properties?: Record<string, string | number | boolean>
  ) => {
    const eventData: AnalyticsEvent = {
      event,
      properties: {
        ...properties,
        timestamp: new Date().toISOString(),
        user_agent: navigator.userAgent,
        url: window.location.href,
      },
    };

    // Send to console in development
    if (import.meta.env.DEV) {
      console.log('[Analytics]', eventData);
    }

    // TODO: Send to analytics backend
    // Option 1: Supabase
    // supabase.from('analytics_events').insert(eventData)

    // Option 2: Google Analytics
    // gtag('event', event, eventData.properties)

    // Option 3: Custom endpoint
    // fetch('/api/analytics', { method: 'POST', body: JSON.stringify(eventData) })
  }, []);

  // Track page view
  const trackPageView = useCallback((page?: string) => {
    const path = page || location.pathname;
    trackEvent('page_view', {
      path,
      referrer: document.referrer,
      screen_width: window.innerWidth,
      screen_height: window.innerHeight,
    });
  }, [location.pathname, trackEvent]);

  // Auto-track page views on route change
  useEffect(() => {
    trackPageView();
  }, [trackPageView]);

  return { trackPageView, trackEvent };
}

/**
 * Simple analytics provider component
 * Wraps app to enable analytics tracking
 */
export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  const { trackPageView } = useAnalytics();

  useEffect(() => {
    // Initial page view
    trackPageView();

    // Track navigation
    const handleRouteChange = () => {
      trackPageView();
    };

    // Listen for SPA route changes
    window.addEventListener('popstate', handleRouteChange);

    return () => {
      window.removeEventListener('popstate', handleRouteChange);
    };
  }, [trackPageView]);

  return <>{children}</>;
}

/**
 * Analytics config
 */
export const analyticsConfig = {
  // Enable/disable analytics
  enabled: import.meta.env.PROD,

  // Sample rate (0-1) - 100% in production
  sampleRate: import.meta.env.PROD ? 1 : 0,

  // Session timeout in minutes
  sessionTimeout: 30,

  // Events to track
  trackEvents: {
    pageView: true,
    clicks: false, // Enable if needed
    formSubmissions: true,
    errors: true,
  },
};

/**
 * Page view statistics component
 * Shows basic stats on admin dashboard
 */
export function usePageStats(limit = 10) {
  // This would query analytics data from Supabase
  // For now, return mock structure
  return {
    topPages: [
      { path: '/', views: 1250 },
      { path: '/berita', views: 820 },
      { path: '/layanan', views: 650 },
      { path: '/status-idm', views: 420 },
      { path: '/profil-desa', views: 380 },
    ],
    totalViews: 3520,
    uniqueVisitors: 1250,
    avgSessionDuration: '2m 30s',
    bounceRate: '45%',
    loading: false,
  };
}
