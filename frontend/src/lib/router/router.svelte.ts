import type { Component } from 'svelte';
import api from '../api';

export interface RouteParams {
  [key: string]: string;
}

export interface RouteGuard {
  canActivate: (params?: RouteParams) => Promise<boolean> | boolean;
  redirectTo?: string;
  onReject?: () => void;
}

export interface Route {
  path: string;
  component: Component | (() => Promise<{ default: Component }>);
  guards?: RouteGuard[];
  meta?: {
    title?: string;
    requiresAuth?: boolean;
    roles?: string[];
  };
}

interface RouterState {
  currentPath: string;
  params: RouteParams;
  query: URLSearchParams;
  isNavigating: boolean;
}

class Router {
  private routes: Route[] = [];
  private state = $state<RouterState>({
    currentPath: window.location.pathname,
    params: {},
    query: new URLSearchParams(window.location.search),
    isNavigating: false
  });

  // Derived values using Svelte 5 runes
  currentPath = $derived(this.state.currentPath);
  params = $derived(this.state.params);
  query = $derived(this.state.query);
  isNavigating = $derived(this.state.isNavigating);

  currentRoute = $derived(() => {
    return this.findMatchingRoute(this.state.currentPath);
  });

  constructor() {
    // Listen to browser navigation
    window.addEventListener('popstate', this.handlePopState);
    
    // Intercept link clicks for SPA navigation
    document.addEventListener('click', this.handleLinkClick);
  }

  private handlePopState = () => {
    this.navigateToPath(window.location.pathname + window.location.search, false);
  };

  private handleLinkClick = (e: MouseEvent) => {
    // Check if it's a link click we should handle
    const target = (e.target as HTMLElement).closest('a');
    if (!target || target.origin !== window.location.origin) return;
    if (target.hasAttribute('data-native')) return;
    if (e.ctrlKey || e.metaKey || e.shiftKey) return;

    e.preventDefault();
    this.navigate(target.pathname + target.search);
  };

  setRoutes(routes: Route[]) {
    this.routes = routes;
    // Re-evaluate current route when routes change
    this.navigateToPath(this.state.currentPath, false);
  }

  private findMatchingRoute(path: string): { route: Route; params: RouteParams } | null {
    for (const route of this.routes) {
      const match = this.matchPath(path, route.path);
      if (match) {
        return { route, params: match.params };
      }
    }
    return null;
  }

  private matchPath(pathname: string, pattern: string): { params: RouteParams } | null {
    // Handle exact matches
    if (pathname === pattern) {
      return { params: {} };
    }

    // Handle dynamic segments
    const patternParts = pattern.split('/');
    const pathParts = pathname.split('/');

    if (patternParts.length !== pathParts.length) {
      // Check for optional trailing slash
      if (patternParts.length === pathParts.length - 1 && pathname.endsWith('/')) {
        pathParts.pop();
      } else {
        return null;
      }
    }

    const params: RouteParams = {};

    for (let i = 0; i < patternParts.length; i++) {
      const patternPart = patternParts[i];
      const pathPart = pathParts[i];

      if (patternPart.startsWith(':')) {
        // Dynamic segment
        const paramName = patternPart.slice(1);
        params[paramName] = pathPart;
      } else if (patternPart !== pathPart) {
        // Static segment doesn't match
        return null;
      }
    }

    return { params };
  }

  async navigate(path: string, replace = false) {
    await this.navigateToPath(path, true, replace);
  }

  private async navigateToPath(fullPath: string, updateHistory = true, replace = false) {
    // Parse path and query
    const [pathname, search] = fullPath.split('?');
    const query = new URLSearchParams(search || '');

    // Find matching route
    const match = this.findMatchingRoute(pathname);
    
    if (!match) {
      console.error(`No route found for path: ${pathname}`);
      // Navigate to 404 or home
      if (pathname !== '/') {
        this.navigate('/');
      }
      return;
    }

    // Set navigating state
    this.state.isNavigating = true;

    try {
      // Check guards
      if (match.route.guards) {
        for (const guard of match.route.guards) {
          const canActivate = await guard.canActivate(match.params);
          
          if (!canActivate) {
            if (guard.onReject) {
              guard.onReject();
            }
            
            if (guard.redirectTo) {
              // Store intended destination for post-login redirect
              if (match.route.meta?.requiresAuth) {
                sessionStorage.setItem('redirectAfterLogin', fullPath);
              }
              
              this.state.isNavigating = false;
              await this.navigate(guard.redirectTo, true);
              return;
            }
            
            this.state.isNavigating = false;
            return;
          }
        }
      }

      // Update state
      this.state.currentPath = pathname;
      this.state.params = match.params;
      this.state.query = query;

      // Update browser history
      if (updateHistory) {
        const url = fullPath;
        if (replace) {
          window.history.replaceState({ path: url }, '', url);
        } else {
          window.history.pushState({ path: url }, '', url);
        }
      }

      // Update document title if meta.title is provided
      if (match.route.meta?.title) {
        document.title = match.route.meta.title;
      }
    } finally {
      this.state.isNavigating = false;
    }
  }

  back() {
    window.history.back();
  }

  forward() {
    window.history.forward();
  }

  reload() {
    this.navigateToPath(this.state.currentPath + window.location.search, false);
  }

  // Helper method to build URLs with params
  buildPath(pattern: string, params?: Record<string, string>, query?: Record<string, string>): string {
    let path = pattern;
    
    // Replace params
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        path = path.replace(`:${key}`, value);
      });
    }
    
    // Add query string
    if (query) {
      const searchParams = new URLSearchParams(query);
      const queryString = searchParams.toString();
      if (queryString) {
        path += `?${queryString}`;
      }
    }
    
    return path;
  }

  // Check if current path matches a pattern
  isActive(pattern: string, exact = false): boolean {
    if (exact) {
      return this.state.currentPath === pattern;
    }
    return this.state.currentPath.startsWith(pattern);
  }

  destroy() {
    window.removeEventListener('popstate', this.handlePopState);
    document.removeEventListener('click', this.handleLinkClick);
  }
}

// Export singleton instance
export const router = new Router();

// Export navigation helpers
export function navigate(path: string, replace = false) {
  return router.navigate(path, replace);
}

export function back() {
  router.back();
}

export function isActive(pattern: string, exact = false): boolean {
  return router.isActive(pattern, exact);
}