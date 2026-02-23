import { writable } from 'svelte/store';

// Current route store
export const currentRoute = writable({ page: 'home', params: {} });

// Navigate to a path using History API
export function navigateTo(path) {
  if (path.startsWith('/')) {
    window.history.pushState({}, '', path);
  } else {
    window.history.pushState({}, '', '/' + path);
  }
  handleRouteChange();
}

// Parse the current URL pathname into a route
export function handleRouteChange() {
  const pathname = window.location.pathname;
  
  if (pathname.startsWith('/resources/')) {
    const slug = pathname.substring('/resources/'.length);
    if (slug) {
      currentRoute.set({ page: 'resource', params: { slug } });
      return;
    }
  }

  if (pathname === '/dashboard/reviewer' || pathname === '/dashboard/reviewer/') {
    currentRoute.set({ page: 'reviewer-dashboard', params: {} });
    return;
  }

  // Simple page routes
  const page = pathname.replace(/^\//, '') || 'home';

  switch (page) {
    case 'signup':
    case 'signin':
    case 'activate':
    case 'submit':
    case 'home':
      currentRoute.set({ page, params: {} });
      break;
    default:
      // Unknown route → home
      currentRoute.set({ page: 'home', params: {} });
      break;
  }
}

// Initialize: listen for popstate (back/forward buttons) and intercept link clicks
if (typeof window !== 'undefined') {
  window.addEventListener('popstate', handleRouteChange);
  
  // Intercept clicks on internal links to use pushState instead of full reload
  document.addEventListener('click', (e) => {
    const anchor = e.target.closest('a');
    if (!anchor) return;
    
    const href = anchor.getAttribute('href');
    if (!href || href.startsWith('http') || href.startsWith('//') || anchor.target === '_blank') return;
    
    // Internal path link
    if (href.startsWith('/')) {
      e.preventDefault();
      navigateTo(href);
    }
  });
}
