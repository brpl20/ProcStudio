import type { Route } from './router.svelte';
import { guards } from './guards';

// Import pages
import LandingPage from '../pages/LandingPage.svelte';
import LoginPage from '../pages/LoginPage.svelte';
import RegisterPage from '../pages/RegisterPage.svelte';
import DashboardPage from '../pages/DashboardPage.svelte';
import TeamsPage from '../pages/TeamsPage.svelte';
import AdminPage from '../pages/AdminPage.svelte';
import SettingsPage from '../pages/SettingsPage.svelte';
import ReportsPage from '../pages/ReportsPage.svelte';
import JobsPage from '../pages/JobsPage.svelte';
import WorksPage from '../pages/WorksPage.svelte';
import CustomersPage from '../pages/CustomersPage.svelte';
import CustomersNewPage from '../pages/CustomersNewPage.svelte';
import CustomersEditPage from '../pages/CustomersEditPage.svelte';
import CustomerProfilePage from '../pages/CustomerProfilePage.svelte';
import UserConfigPage from '../pages/UserConfigPage.svelte';
import OfficeCreationPage from '../pages/Office/OfficeCreationPage.svelte';
import LawyersTestDebugPage from '../pages/LawyersTestDebugPage.svelte';

/**
 * Application Routes Configuration
 * Defines all routes with their components, guards, and metadata
 */
export const routes: Route[] = [
  // Public routes
  {
    path: '/',
    component: LandingPage,
    meta: {
      title: 'ProcStudio - Home'
    }
  },
  {
    path: '/login',
    component: LoginPage,
    guards: [guards.guest()],
    meta: {
      title: 'ProcStudio - Login'
    }
  },
  {
    path: '/register',
    component: RegisterPage,
    guards: [guards.guest()],
    meta: {
      title: 'ProcStudio - Cadastro'
    }
  },

  // Protected routes - require authentication
  {
    path: '/dashboard',
    component: DashboardPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Dashboard',
      requiresAuth: true
    }
  },
  {
    path: '/teams',
    component: TeamsPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Equipes',
      requiresAuth: true
    }
  },
  {
    path: '/settings',
    component: SettingsPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Configurações',
      requiresAuth: true
    }
  },
  {
    path: '/reports',
    component: ReportsPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Relatórios',
      requiresAuth: true
    }
  },
  {
    path: '/jobs',
    component: JobsPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Trabalhos',
      requiresAuth: true
    }
  },
  {
    path: '/works',
    component: WorksPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Processos',
      requiresAuth: true
    }
  },

  // Customer routes
  {
    path: '/customers',
    component: CustomersPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Clientes',
      requiresAuth: true
    }
  },
  {
    path: '/customers/new',
    component: CustomersNewPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Novo Cliente',
      requiresAuth: true
    }
  },
  {
    path: '/customers/edit/:id',
    component: CustomersEditPage,
    guards: [
      guards.auth()
      // Could add ownership check here
      // guards.resourceOwner('customer', async (id) => {
      //   const customer = await api.customers.get(id);
      //   return customer.team_id === currentUser.team_id;
      // })
    ],
    meta: {
      title: 'ProcStudio - Editar Cliente',
      requiresAuth: true
    }
  },
  {
    path: '/customers/profile/:customerId',
    component: CustomerProfilePage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Perfil do Cliente',
      requiresAuth: true
    }
  },

  // User configuration
  {
    path: '/user-config',
    component: UserConfigPage,
    guards: [guards.auth()],
    meta: {
      title: 'ProcStudio - Configuração do Usuário',
      requiresAuth: true
    }
  },

  // Admin routes - require admin role
  {
    path: '/admin',
    component: AdminPage,
    guards: [
      guards.combine(
        guards.auth(),
        guards.roles('admin', 'super_admin')
      )
    ],
    meta: {
      title: 'ProcStudio - Administração',
      requiresAuth: true,
      roles: ['admin', 'super_admin']
    }
  },

  // Test/Debug routes (should be disabled in production)
  {
    path: '/lawyers-test',
    component: OfficeCreationPage,
    guards: [
      guards.auth(),
      guards.feature('beta-features')
    ],
    meta: {
      title: 'ProcStudio - Teste Advogados',
      requiresAuth: true
    }
  },
  {
    path: '/lawyers-test-debug',
    component: LawyersTestDebugPage,
    guards: [
      guards.auth(),
      guards.feature('beta-features')
    ],
    meta: {
      title: 'ProcStudio - Debug Advogados',
      requiresAuth: true
    }
  }
];

// Route groups for navigation menus
export const navigationGroups = {
  main: [
    { path: '/dashboard', label: 'Dashboard', icon: 'home' },
    { path: '/customers', label: 'Clientes', icon: 'users' },
    { path: '/jobs', label: 'Trabalhos', icon: 'briefcase' },
    { path: '/works', label: 'Processos', icon: 'folder' },
    { path: '/teams', label: 'Equipes', icon: 'users-group' }
  ],
  admin: [
    { path: '/admin', label: 'Administração', icon: 'cog' },
    { path: '/reports', label: 'Relatórios', icon: 'chart' }
  ],
  user: [
    { path: '/user-config', label: 'Meu Perfil', icon: 'user' },
    { path: '/settings', label: 'Configurações', icon: 'settings' }
  ]
};

// Helper to get route by path
export function getRouteByPath(path: string): Route | undefined {
  return routes.find((route) => {
    // Check exact match first
    if (route.path === path) {
return true;
}

    // Check dynamic routes
    const routeParts = route.path.split('/');
    const pathParts = path.split('/');

    if (routeParts.length !== pathParts.length) {
return false;
}

    return routeParts.every((part, i) => {
      if (part.startsWith(':')) {
return true;
}
      return part === pathParts[i];
    });
  });
}

// Helper to check if user can access route
export async function canAccessRoute(path: string): Promise<boolean> {
  const route = getRouteByPath(path);
  if (!route) {
return false;
}

  if (!route.guards) {
return true;
}

  for (const guard of route.guards) {
    const canActivate = await guard.canActivate();
    if (!canActivate) {
return false;
}
  }

  return true;
}