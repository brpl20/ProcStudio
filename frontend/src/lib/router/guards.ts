import type { RouteGuard, RouteParams } from './router.svelte';
import api from '../api';
import { get } from 'svelte/store';
import { authStore } from '../stores/authStore';

/**
 * Authentication Guard
 * Validates user authentication status with backend
 */
export class AuthGuard implements RouteGuard {
  redirectTo = '/login';

  async canActivate(params?: RouteParams): Promise<boolean> {
    // First check local auth state
    const authState = get(authStore);
    
    if (!authState.isAuthenticated) {
      return false;
    }

    // Validate token with backend
    try {
      // This should be a lightweight endpoint that validates the current session
      const response = await api.users.whoami();
      
      if (!response || !response.data) {
        // Token is invalid, clear auth
        await authStore.logout();
        return false;
      }

      return true;
    } catch (error) {
      console.error('Auth validation failed:', error);
      await authStore.logout();
      return false;
    }
  }

  onReject() {
    // Store message for login page
    sessionStorage.setItem('authMessage', 'Por favor, faça login para continuar');
  }
}

/**
 * Guest Guard
 * Ensures user is NOT authenticated (for login/register pages)
 */
export class GuestGuard implements RouteGuard {
  redirectTo = '/dashboard';

  canActivate(): boolean {
    const authState = get(authStore);
    // If authenticated, redirect to dashboard
    return !authState.isAuthenticated;
  }
}

/**
 * Role-based Access Control Guard
 */
export class RoleGuard implements RouteGuard {
  redirectTo = '/unauthorized';

  constructor(private requiredRoles: string[]) {}

  canActivate(): boolean {
    const authState = get(authStore);
    
    if (!authState.isAuthenticated || !authState.user) {
      return false;
    }

    const userRoles = authState.user.data?.roles || [];
    
    // Check if user has at least one of the required roles
    return this.requiredRoles.some(role => userRoles.includes(role));
  }

  onReject() {
    sessionStorage.setItem('authMessage', 'Você não tem permissão para acessar esta página');
  }
}

/**
 * Profile Completion Guard
 * Ensures user has completed their profile
 */
export class ProfileCompleteGuard implements RouteGuard {
  redirectTo = '/profile/complete';

  canActivate(): boolean {
    const authState = get(authStore);
    
    if (!authState.isAuthenticated || !authState.user) {
      return false;
    }

    // Check if profile is complete
    return !authState.user.data?.needs_profile_completion;
  }

  onReject() {
    sessionStorage.setItem('profileMessage', 'Por favor, complete seu perfil para continuar');
  }
}

/**
 * Combined Guard
 * Runs multiple guards in sequence
 */
export class CombinedGuard implements RouteGuard {
  redirectTo?: string;

  constructor(private guards: RouteGuard[]) {
    // Use the redirectTo from the first guard that fails
    this.redirectTo = guards[0]?.redirectTo;
  }

  async canActivate(params?: RouteParams): Promise<boolean> {
    for (const guard of this.guards) {
      const result = await guard.canActivate(params);
      
      if (!result) {
        // Update redirectTo based on which guard failed
        this.redirectTo = guard.redirectTo;
        
        if (guard.onReject) {
          guard.onReject();
        }
        
        return false;
      }
    }
    
    return true;
  }
}

/**
 * Async Data Guard
 * Validates access based on async data (e.g., checking resource ownership)
 */
export class ResourceOwnerGuard implements RouteGuard {
  redirectTo = '/unauthorized';

  constructor(
    private resourceType: 'customer' | 'job' | 'team',
    private checkOwnership: (id: string) => Promise<boolean>
  ) {}

  async canActivate(params?: RouteParams): Promise<boolean> {
    if (!params?.id) {
      return false;
    }

    try {
      return await this.checkOwnership(params.id);
    } catch (error) {
      console.error(`Failed to check ${this.resourceType} ownership:`, error);
      return false;
    }
  }

  onReject() {
    sessionStorage.setItem('authMessage', `Você não tem acesso a este ${this.resourceType}`);
  }
}

/**
 * Feature Flag Guard
 * Controls access based on feature flags
 */
export class FeatureFlagGuard implements RouteGuard {
  redirectTo = '/';

  constructor(private featureKey: string) {}

  async canActivate(): Promise<boolean> {
    // This could check a feature flag service or configuration
    // For now, checking environment or config
    const features = {
      'new-ui': true,
      'beta-features': false,
      'admin-panel': true
    };

    return features[this.featureKey as keyof typeof features] || false;
  }

  onReject() {
    sessionStorage.setItem('featureMessage', 'Este recurso ainda não está disponível');
  }
}

// Export guard factory functions for convenience
export const guards = {
  auth: () => new AuthGuard(),
  guest: () => new GuestGuard(),
  roles: (...roles: string[]) => new RoleGuard(roles),
  profileComplete: () => new ProfileCompleteGuard(),
  combine: (...guards: RouteGuard[]) => new CombinedGuard(guards),
  resourceOwner: (type: 'customer' | 'job' | 'team', checker: (id: string) => Promise<boolean>) => 
    new ResourceOwnerGuard(type, checker),
  feature: (flag: string) => new FeatureFlagGuard(flag)
};