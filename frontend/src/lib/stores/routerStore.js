import { writable } from 'svelte/store';

function createRouter() {
  // Initialize with current path from browser
  const initialPath = typeof window !== 'undefined' ? window.location.pathname : '/';

  const { subscribe, set, update } = writable({
    currentPath: initialPath,
    params: {},
    query: {}
  });

  // Listen for browser back/forward button
  if (typeof window !== 'undefined') {
    window.addEventListener('popstate', (event) => {
      const path = window.location.pathname;
      const [pathname, search] = path.split('?');
      const query = {};

      if (search) {
        const searchParams = new window.URLSearchParams(search);
        for (const [key, value] of searchParams) {
          query[key] = value;
        }
      }

      set({
        currentPath: pathname,
        params: {},
        query
      });
    });
  }

  return {
    subscribe,

    navigate(path) {
      const [pathname, search] = path.split('?');
      const query = {};

      if (search && typeof window !== 'undefined') {
        const searchParams = new window.URLSearchParams(search);
        for (const [key, value] of searchParams) {
          query[key] = value;
        }
      }

      set({
        currentPath: pathname,
        params: {},
        query
      });

      // Atualizar URL do browser usando pushState
      if (typeof window !== 'undefined') {
        window.history.pushState({ path }, '', path);
      }
    },

    replace(path) {
      this.navigate(path);
      if (typeof window !== 'undefined') {
        window.history.replaceState({}, '', path);
      }
    },

    back() {
      if (typeof window !== 'undefined') {
        window.history.back();
      }
    }
  };
}

export const router = createRouter();
