import { writable } from 'svelte/store';

function createRouter() {
  const { subscribe, set, update } = writable({
    currentPath: '/',
    params: {},
    query: {}
  });

  return {
    subscribe,

    navigate(path) {
      // Simular navegação (em uma aplicação real usaria history API)
      const [pathname, search] = path.split('?');
      const query = {};

      if (search && typeof window !== 'undefined') {
        const searchParams = new URLSearchParams(search);
        for (const [key, value] of searchParams) {
          query[key] = value;
        }
      }

      set({
        currentPath: pathname,
        params: {},
        query
      });

      // Atualizar URL do browser (opcional)
      if (typeof window !== 'undefined') {
        window.history.pushState({}, '', path);
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
