<script lang="ts">
  import { router, type RouterState } from '../stores/routerStore';
  import Icon from '../icons/icons.svelte';

  interface BreadcrumbItem {
    label: string;
    path?: string;
    icon: string;
  }

  interface Props {
    items?: BreadcrumbItem[];
  }

  const { items = [] }: Props = $props();

  const currentPath = $derived($router.currentPath);
  const defaultBreadcrumbs = $derived(generateBreadcrumbs(currentPath, $router.params));
  const displayItems = $derived(items.length > 0 ? items : defaultBreadcrumbs);

  function generateBreadcrumbs(path: string, params: Record<string, string>): BreadcrumbItem[] {
    const segmentConfig: Record<string, { label: string; icon: string }> = {
      'dashboard': { label: 'Dashboard', icon: 'dashboard' },
      'teams': { label: 'Equipes', icon: 'teams' },
      'admin': { label: 'Admin', icon: 'admin' },
      'settings': { label: 'Configurações', icon: 'settings' },
      'reports': { label: 'Relatórios', icon: 'reports' },
      'jobs': { label: 'Jobs', icon: 'tasks' },
      'works': { label: 'Trabalhos', icon: 'work' },
      'customers': { label: 'Clientes', icon: 'customer' },
      'user-config': { label: 'Configurações de Usuário', icon: 'user' },
      'new': { label: 'Novo', icon: 'add' },
      'edit': { label: 'Editar', icon: 'edit' },
      'profile': { label: 'Perfil', icon: 'user' }
    };

    const breadcrumbs: BreadcrumbItem[] = [{
      label: 'Dashboard',
      path: '/dashboard',
      icon: 'dashboard'
    }];

    if (path === '/' || path === '/dashboard') {
      return breadcrumbs;
    }
    
    const pathSegments = path.replace(/^\//, '').split('/');
    let currentBuiltPath = '';
    const paramValues = new Set(Object.values(params));

    for (const segment of pathSegments) {
      currentBuiltPath += `/${segment}`;

      if (segment === 'dashboard') continue;

      if (paramValues.has(segment)) {
        continue;
      }
      
      const config = segmentConfig[segment];
      
      if (config) {
        breadcrumbs.push({
          label: config.label,
          path: currentBuiltPath,
          icon: config.icon
        });
      } else {
        breadcrumbs.push({
          label: segment.charAt(0).toUpperCase() + segment.slice(1),
          path: currentBuiltPath,
          icon: 'folder'
        });
      }
    }

    return breadcrumbs;
  }

  function navigateTo(path?: string): void {
    if (path) {
      router.navigate(path);
    }
  }
</script>

<nav class="bg-[#eef0ef] border-b border-gray-200 shadow-sm">
  <div class="px-6 py-4">
    <ol class="flex items-center space-x-2 text-sm">
      {#each displayItems as item, index}
        <li class="flex items-center">
          {#if index > 0}
            <svg class="w-5 h-5 text-gray-400 mx-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          {/if}
          
          {#if index === displayItems.length - 1}
            <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#01013D] text-white font-medium shadow-sm">
              <Icon name={item.icon} className="h-4 w-4" />
              <span>{item.label}</span>
            </div>
          {:else}
            <button
              class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-[#01013D] font-medium hover:bg-white hover:shadow-sm transition-all duration-200 hover:text-[#0277EE] group"
              onclick={() => navigateTo(item.path)}
            >
              <Icon name={item.icon} className="h-4 w-4 group-hover:scale-110 transition-transform duration-200" />
              <span>{item.label}</span>
            </button>
          {/if}
        </li>
      {/each}
    </ol>
  </div>
</nav>
