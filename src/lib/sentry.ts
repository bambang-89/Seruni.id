// Sentry Error Tracking Initialization
// Only enable in production
import * as Sentry from "@sentry/react";

const SENTRY_DSN = import.meta.env.VITE_SENTRY_DSN;
const ENVIRONMENT = import.meta.env.MODE || "development";

export function initSentry() {
  if (!SENTRY_DSN || ENVIRONMENT !== "production") {
    console.log("Sentry: Disabled (not in production or no DSN configured");
    return;
  }

  Sentry.init({
    dsn: SENTRY_DSN,
    environment: ENVIRONMENT,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration(),
    ],
    tracesSampleRate: 0.1, // 10% of transactions
    replaysSessionSampleRate: 0.05, // 5% of sessions
    replaysOnErrorSampleRate: 1.0, // All error sessions
    beforeSend(event) {
      // Sanitize sensitive data
      if (event.user) {
        delete event.user.email;
        delete event.user.username;
      }
      // Remove potential sensitive headers
      if (event.request?.headers) {
        const cleanHeaders = { ...event.request.headers };
        delete cleanHeaders["authorization"];
        delete cleanHeaders["cookie"];
        delete cleanHeaders["x-api-key"];
        event.request.headers = cleanHeaders;
      }
      return event;
    },
    ignoreErrors: [
      "ResizeObserver loop",
      "Non-Error promise rejection",
      "Failed to load resource",
    ],
  });

  console.log("Sentry: Initialized in production mode");
}

export const logger = {
  setUser: (user: { id: string; email?: string } | null) => {
    if (ENVIRONMENT === "production" && SENTRY_DSN) {
      Sentry.setUser(user);
    }
  },
  captureException: (error: Error, context?: Record<string, unknown>) => {
    if (ENVIRONMENT === "production" && SENTRY_DSN) {
      Sentry.captureException(error, { extra: context });
    } else {
      console.error("[Error]", error, context);
    }
  },
  captureMessage: (message: string, level: "debug" | "info" | "warning" | "error" = "info") => {
    if (ENVIRONMENT === "production" && SENTRY_DSN) {
      Sentry.captureMessage(message, level);
    } else {
      console.log(`[${level}]`, message);
    }
  },
};
