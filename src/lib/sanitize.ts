// XSS Prevention Utilities
// Sanitize user input to prevent injection attacks

/**
 * Sanitize HTML string - strips all HTML tags
 */
export function stripHtml(html: string): string {
  if (typeof document === "undefined") {
    return html.replace(/<[^>]*>/g, "");
  }
  const tmp = document.createElement("div");
  tmp.textContent = html;
  return tmp.innerHTML;
}

/**
 * Escape HTML entities for safe display in HTML context
 */
export function escapeHtml(str: string): string {
  const escapeMap: Record<string, string> = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#x27;",
    "/": "&#x2F;",
  };
  return String(str).replace(/[&<>"'/]/g, (char) => escapeMap[char] || char);
}

/**
 * Validate URL - only allow http/https protocols
 */
export function sanitizeUrl(url: string): string {
  try {
    const parsed = new URL(url);
    if (!["http:", "https:"].includes(parsed.protocol)) {
      return "#";
    }
    return url;
  } catch {
    return "#";
  }
}

/**
 * Sanitize object keys for safe database operations
 */
export function sanitizeObject<T extends Record<string, unknown>>(obj: T, allowedKeys: string[]): Partial<T> {
  const result: Partial<T> = {};
  for (const key of allowedKeys) {
    if (key in obj) {
      (result as Record<string, unknown>)[key] = obj[key];
    }
  }
  return result;
}

/**
 * Sanitize filename - remove path traversal attempts
 */
export function sanitizeFilename(filename: string): string {
  return filename.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 255);
}
