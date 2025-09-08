<script lang="ts">
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons.svelte';

  interface BreadcrumbItem {
    label: string;
    path?: string;
    icon: string;
  }

  interface Props {
    items?: BreadcrumbItem[];
  }

  const { items = [] }: Props = $props();

  // Breadcrumb padrão baseado na rota atual
  const currentPath = $derived($router.currentPath);
  const defaultBreadcrumbs = $derived(generateBreadcrumbs(currentPath));
  const displayItems = $derived(items.length > 0 ? items : defaultBreadcrumbs);

  function generateBreadcrumbs(path: string): BreadcrumbItem[] {
    const routeMap: Record<string, BreadcrumbItem[]> = {
      '/dashboard': [{ label: 'Dashboard', path: '/dashboard', icon: 'dashboard' }],
      '/teams': [{ label: 'Equipes', path: '/teams', icon: 'teams' }],
      '/admin': [{ label: 'Admin', path: '/admin', icon: 'admin' }],
      '/settings': [{ label: 'Configurações', path: '/settings', icon: 'settings' }],
      '/reports': [{ label: 'Relatórios', path: '/reports', icon: 'reports' }],
      '/tasks': [{ label: 'Tarefas', path: '/tasks', icon: 'tasks' }],
      '/works': [{ label: 'Trabalhos', path: '/works', icon: 'work' }],
      '/customers': [{ label: 'Clientes', path: '/customers', icon: 'customer' }],
      '/customers/new': [
        { label: 'Clientes', path: '/customers', icon: 'customer' },
        { label: 'Novo Cliente', path: '/customers/new', icon: 'customer' }
      ]
    };

    return routeMap[path] || [{ label: 'Dashboard', path: '/dashboard', icon: 'dashboard' }];
  }

  function navigateTo(path?: string): void {
    if (path) {
      router.navigate(path);
    }
  }
</script>

<div class="breadcrumbs text-sm bg-base-200 px-4 py-2">
  <ul>
    {#each displayItems as item, index}
      <li>
        {#if index === displayItems.length - 1}
          <!-- Último item (atual) - não clicável -->
          <span class="inline-flex items-center gap-2 opacity-70">
            <Icon name={item.icon} className="h-4 w-4" />
            {item.label}
          </span>
        {:else}
          <!-- Items navegáveis -->
          <button
            class="inline-flex items-center gap-2 hover:text-primary cursor-pointer"
            onclick={() => navigateTo(item.path)}
          >
            <Icon name={item.icon} className="h-4 w-4" />
            {item.label}
          </button>
        {/if}
      </li>
    {/each}
  </ul>
</div>
