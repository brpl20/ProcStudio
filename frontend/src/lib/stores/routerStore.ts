import { writable, type Writable } from 'svelte/store';
import { guards } from '../router/guards';
// Define RouteGuard interface locally to avoid circular dependency
interface RouteGuard {
  canActivate: (params?: Record<string, string>) => Promise<boolean> | boolean;
  redirectTo?: string;
  onReject?: () => void;
}

interface RouterState {
  currentPath: string;
  params: Record<string, string>;
  query: Record<string, string>;
}

interface NavigationOptions {
  replace?: boolean;
  skipGuards?: boolean;
}

interface RouteDefinition {
  path: string;
  guards?: RouteGuard[];
  meta?: {
    requiresAuth?: boolean;
    roles?: string[];
    guestOnly?: boolean;
  };
}

class SecureRouter {
  private store: Writable<RouterState>;
  private handlePopState: (event: PopStateEvent) => void;
  private routes: Map<string, RouteDefinition> = new Map();
  private navigationInProgress = false;
  private currentNavigationController: AbortController | null = null;

  constructor() {
    const initialPath = typeof window !== 'undefined' ? window.location.pathname : '/';
    const initialSearch = typeof window !== 'undefined' ? window.location.search : '';

    this.store = writable<RouterState>({
      currentPath: initialPath,
      params: {},
      query: this.parseQuery(initialSearch)
    });

    this.initializeRoutes();

    this.handlePopState = async (event: PopStateEvent) => {
      const path = event.state?.path ?? (window.location.pathname + window.location.search);
      const [pathname, search] = path.split('?');

      let params: Record<string, string> = {};
      const route = this.findRoute(pathname);
      if (route) {
        params = this.extractParams(pathname, route.path);
      }

      const canNavigate = await this.checkGuards(pathname, params);
      if (!canNavigate) {
        const current = this.getCurrentPath();
        window.history.replaceState({ path: current }, '', current);
        return;
      }

      this.store.set({
        currentPath: pathname,
        params,
        query: this.parseQuery(search)
      });
    };

    if (typeof window !== 'undefined') {
      window.addEventListener('popstate', this.handlePopState);
    }
  }

  // Initialize route definitions with guards
  private initializeRoutes(): void {
    // Public routes
    this.routes.set('/', {
      path: '/',
      meta: { requiresAuth: false }
    });

    // Guest-only routes (redirect to dashboard if authenticated)
    this.routes.set('/login', {
      path: '/login',
      guards: [guards.guest()],
      meta: { guestOnly: true }
    });

    this.routes.set('/register', {
      path: '/register',
      guards: [guards.guest()],
      meta: { guestOnly: true }
    });

    // Protected routes - require authentication
    this.routes.set('/dashboard', {
      path: '/dashboard',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/teams', {
      path: '/teams',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/settings', {
      path: '/settings',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/reports', {
      path: '/reports',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/jobs', {
      path: '/jobs',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/works', {
      path: '/works',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/customers', {
      path: '/customers',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/customers/new', {
      path: '/customers/new',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/customers/edit/:id', {
      path: '/customers/edit/:id',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/customers/profile/:customerId', {
      path: '/customers/profile/:customerId',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/user-config', {
      path: '/user-config',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    this.routes.set('/admin', {
      path: '/admin',
      guards: [guards.auth()],
      meta: { requiresAuth: true }
    });

    // Beta/Test routes
    this.routes.set('/lawyers-test', {
      path: '/lawyers-test',
      guards: [
        guards.auth(),
        guards.feature('beta-features')
      ],
      meta: { requiresAuth: true }
    });

    this.routes.set('/lawyers-test-debug', {
      path: '/lawyers-test-debug',
      guards: [
        guards.auth(),
        guards.feature('beta-features')
      ],
      meta: { requiresAuth: true }
    });
  }

  // Find route definition for a path
  private findRoute(path: string): RouteDefinition | null {
    // First try exact match
    if (this.routes.has(path)) {
      return this.routes.get(path)!;
    }

    // Then try pattern matching for dynamic routes
    for (const [pattern, route] of this.routes) {
      if (this.matchPath(path, pattern)) {
        return route;
      }
    }

    // Check if it's a protected path prefix
    const protectedPrefixes = ['/customers', '/teams', '/admin', '/lawyers'];
    if (protectedPrefixes.some((prefix) => path.startsWith(prefix))) {
      // Return a default protected route
      return {
        path,
        guards: [guards.auth()],
        meta: { requiresAuth: true }
      };
    }

    return null;
  }

  // Match dynamic path patterns
  private matchPath(path: string, pattern: string): boolean {
    const pathParts = path.split('/');
    const patternParts = pattern.split('/');

    if (pathParts.length !== patternParts.length) {
      return false;
    }

    for (let i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        // Dynamic segment - matches anything
        continue;
      }
      if (patternParts[i] !== pathParts[i]) {
        return false;
      }
    }

    return true;
  }

  // Extract params from dynamic route
  private extractParams(path: string, pattern: string): Record<string, string> {
    const params: Record<string, string> = {};
    const pathParts = path.split('/');
    const patternParts = pattern.split('/');

    for (let i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        const paramName = patternParts[i].slice(1);
        params[paramName] = pathParts[i];
      }
    }

    return params;
  }

  // Parse query string into object
  private parseQuery(search?: string): Record<string, string> {
    const query: Record<string, string> = {};
    if (search) {
      const searchParams = new URLSearchParams(search);
      searchParams.forEach((value, key) => {
        query[key] = value;
      });
    }
    return query;
  }

  // Get current path from store
  private getCurrentPath(): string {
    const state = get(this.store);
    return state.currentPath;
  }

  // Sanitize path to prevent XSS
  private sanitizePath(path: string): string {
    // Type guard
    if (!path || typeof path !== 'string') {
      return '/';
    }

    // Ensure path starts with /
    if (!path.startsWith('/')) {
      path = '/' + path;
    }

    // Remove any potentially dangerous characters
    path = path.replace(/[<>\"']/g, '');

    // Validate against javascript: protocol
    if (path.toLowerCase().includes('javascript:')) {
      console.warn('[Router Security] Blocked navigation to javascript: URL');
      return '/';
    }

    // Remove duplicate slashes
    path = path.replace(/\/+/g, '/');

    return path;
  }

  // Check route guards
  private async checkGuards(path: string, params?: Record<string, string>): Promise<boolean> {
    const route = this.findRoute(path);

    // If no route found, allow navigation (will show 404 in App.svelte)
    if (!route) {
      // Only log in development mode
      if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
        console.log(`[Router] No route configuration for: ${path}`);
      }
      return true;
    }

    // Check route guards
    if (route.guards && route.guards.length > 0) {
      for (const guard of route.guards) {
        try {
          const canActivate = await guard.canActivate(params);

          if (!canActivate) {
            // Only log in development mode
            if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
              console.log(`[Router] Guard blocked navigation to: ${path}`);
            }

            // Call guard's rejection handler
            if (guard.onReject) {
              guard.onReject();
            }

            // Navigate to redirect path if specified
            if (guard.redirectTo) {
              // Store intended destination for post-login redirect
              if (route.meta?.requiresAuth) {
                sessionStorage.setItem('redirectAfterLogin', path);
              }

              // Navigate to redirect (skip guards to avoid infinite loop)
              setTimeout(() => {
                this.navigate(guard.redirectTo!, { skipGuards: true });
              }, 0);
            }

            return false;
          }
        } catch (error) {
          console.error('[Router] Guard error:', error);
          return false;
        }
      }
    }

    // Only log in development mode
    if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
      console.log(`[Router] Guards passed for: ${path}`);
    }
    return true;
  }

  // Main navigation method
  public async navigate(path: string, options: NavigationOptions = {}): Promise<boolean> {
    if (this.currentNavigationController) {
      this.currentNavigationController.abort();
    }

    if (this.navigationInProgress && !options.skipGuards) {
      console.warn('[Router] Navigation already in progress');
      return false;
    }

    this.navigationInProgress = true;
    this.currentNavigationController = new AbortController();

    try {
      path = this.sanitizePath(path);

      const [pathname, search] = path.split('?');
      const query = this.parseQuery(search);

      let params: Record<string, string> = {};
      const route = this.findRoute(pathname);
      if (route) {
        params = this.extractParams(pathname, route.path);
      }

      // Whitelist safe paths for skipGuards to prevent auth bypass
      const safeSkipPaths = ['/', '/login', '/register', '/dashboard'];
      if (options.skipGuards && !safeSkipPaths.includes(pathname)) {
        options.skipGuards = false;
      }

      if (!options.skipGuards) {
        const canNavigate = await this.checkGuards(pathname, params);
        if (!canNavigate) {
          if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
            console.log(`[Router] Navigation to ${pathname} blocked by guards`);
          }
          return false;
        }
      }

      if (this.currentNavigationController?.signal.aborted) {
        return false;
      }

      this.store.set({
        currentPath: pathname,
        params,
        query
      });

      try {
        if (!options.replace) {
          window.history.pushState({ path }, '', path);
        } else {
          window.history.replaceState({ path }, '', path);
        }
      } catch (error) {
        console.error('[Router] History update error:', error);
        return false;
      }

      if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
        console.log(`[Router] Successfully navigated to: ${pathname}`);
      }
      return true;
    } finally {
      this.navigationInProgress = false;
      this.currentNavigationController = null;
    }
  }

  // Navigate back in history
  public back(): void {
    window.history.back();
  }

  // Navigate forward in history
  public forward(): void {
    window.history.forward();
  }

  // Reload current route
  public async reload(): Promise<boolean> {
    const path = window.location.pathname + window.location.search;
    return this.navigate(path, { replace: true });
  }

  // Subscribe to route changes
  public subscribe(callback: (value: RouterState) => void): () => void {
    return this.store.subscribe(callback);
  }

  // Cleanup function to prevent memory leaks
  public destroy(): void {
    if (typeof window !== 'undefined') {
      window.removeEventListener('popstate', this.handlePopState);
    }
    if (this.currentNavigationController) {
      this.currentNavigationController.abort();
    }
  }
}

// Create and export singleton instance
export const router = new SecureRouter();

// Export types for external use
export type { RouterState, NavigationOptions, RouteDefinition };