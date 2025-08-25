<script>
  import { router } from '../stores/routerStore.js';

  export let items = [];

  // Breadcrumb padrão baseado na rota atual
  $: currentPath = $router.currentPath;
  $: defaultBreadcrumbs = generateBreadcrumbs(currentPath);
  $: displayItems = items.length > 0 ? items : defaultBreadcrumbs;

  function generateBreadcrumbs(path) {
    const routeMap = {
      '/dashboard': [{ label: 'Dashboard', path: '/dashboard', icon: 'home' }],
      '/teams': [{ label: 'Equipes', path: '/teams', icon: 'folder' }],
      '/admin': [{ label: 'Admin', path: '/admin', icon: 'folder' }],
      '/settings': [{ label: 'Configurações', path: '/settings', icon: 'folder' }],
      '/reports': [{ label: 'Relatórios', path: '/reports', icon: 'document' }],
      '/tasks': [{ label: 'Tarefas', path: '/tasks', icon: 'folder' }],
      '/works': [{ label: 'Trabalhos', path: '/works', icon: 'folder' }],
      '/customers': [{ label: 'Clientes', path: '/customers', icon: 'folder' }],
      '/customers/new': [
        { label: 'Clientes', path: '/customers', icon: 'folder' },
        { label: 'Novo Cliente', path: '/customers/new', icon: 'document' }
      ]
    };

    return routeMap[path] || [{ label: 'Dashboard', path: '/dashboard', icon: 'home' }];
  }

  function getIcon(iconType) {
    const icons = {
      home: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>',
      folder:
        '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>',
      document:
        '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>'
    };
    return icons[iconType] || icons.folder;
  }

  function navigateTo(path) {
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
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="h-4 w-4 stroke-current"
            >
              {@html getIcon(item.icon)}
            </svg>
            {item.label}
          </span>
        {:else}
          <!-- Items navegáveis -->
          <button
            class="inline-flex items-center gap-2 hover:text-primary cursor-pointer"
            on:click={() => navigateTo(item.path)}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="h-4 w-4 stroke-current"
            >
              {@html getIcon(item.icon)}
            </svg>
            {item.label}
          </button>
        {/if}
      </li>
    {/each}
  </ul>
</div>
