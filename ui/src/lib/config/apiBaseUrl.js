export function getApiBaseUrl() {
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }

  // In local runs (including custom UI ports like 3001),
  // default directly to the API service on port 4000.
  if (typeof window !== 'undefined') {
    const isLocalHost = ['localhost', '127.0.0.1'].includes(window.location.hostname);
    if (isLocalHost) {
      return 'http://localhost:4000/v1';
    }
  }

  // Keep relative path for non-local/proxied deployments.
  return '/api/v1';
}