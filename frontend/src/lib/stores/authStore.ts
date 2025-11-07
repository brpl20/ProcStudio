// stores/authStore.ts
import { writable, derived, type Writable, type Readable } from 'svelte/store';
import api from '../api/index';
import type { LoginResponse, ProfileCompletionResponse } from '../api/types';
import { notificationStore } from './notificationStore';

// Define the auth store state interface
interface AuthState {
  isAuthenticated: boolean;
  user: LoginResponse | null;
  currentView: 'login' | 'register';
  showProfileCompletion: boolean;
  profileData: LoginResponse['data'] | null;
  missingFields: string[];
}

// Initial state
const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  currentView: 'login',
  showProfileCompletion: false,
  profileData: null,
  missingFields: []
};

// Local storage keys
const STORAGE_KEYS = {
  USER_DATA: 'userData',
  AUTH_TOKEN: 'authToken'
} as const;

// Helper functions for localStorage operations
const storage = {
  getUserData(): LoginResponse | null {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.USER_DATA);
      return data ? JSON.parse(data) : null;
    } catch {
      return null;
    }
  },

  setUserData(userData: LoginResponse): void {
    localStorage.setItem(STORAGE_KEYS.USER_DATA, JSON.stringify(userData));
  },

  clearUserData(): void {
    localStorage.removeItem(STORAGE_KEYS.USER_DATA);
  }
};

function createAuthStore() {
  const { subscribe, set, update }: Writable<AuthState> = writable(initialState);

  // Initialize auth from stored data
  async function init(): Promise<void> {
    api.auth.initializeAuth();

    const isAuth = api.auth.isAuthenticated();

    if (!isAuth) {
      update((state) => ({
        ...state,
        isAuthenticated: false,
        user: null
      }));
      return;
    }

    const storedUserData = storage.getUserData();

    update((state) => ({
      ...state,
      isAuthenticated: true,
      user: storedUserData
    }));

    if (storedUserData?.token) {
      notificationStore.connect(storedUserData.token);
    }
  }

  // Handle successful login
  function loginSuccess(userData: LoginResponse): void {
    storage.setUserData(userData);

    update((state) => ({
      ...state,
      isAuthenticated: true,
      user: userData,
      showProfileCompletion: userData.data.needs_profile_completion,
      profileData: userData.data,
      missingFields: userData.data.missing_fields || []
    }));

    // Connect to WebSocket after successful login
    if (userData.token) {
      notificationStore.connect(userData.token);
    }
  }

  // Handle successful registration
  function registerSuccess(): void {
    update((state) => ({
      ...state,
      currentView: 'login'
    }));
  }

  // Toggle between login and register views
  function switchView(): void {
    update((state) => ({
      ...state,
      currentView: state.currentView === 'login' ? 'register' : 'login'
    }));
  }

  // Logout user
  async function logout(): Promise<void> {
    try {
      await api.auth.logout();
    } finally {
      notificationStore.disconnect();
      storage.clearUserData();
      sessionStorage.removeItem('redirectAfterLogin');
      sessionStorage.removeItem('authMessage');
      sessionStorage.removeItem('profileMessage');
      set(initialState);
    }
  }

  // Complete user profile
  function completeProfile(completionResult: ProfileCompletionResponse): void {
    update((state) => ({
      ...state,
      showProfileCompletion: false,
      profileData: null,
      missingFields: [],
      user: completionResult.data && state.user
        ? { ...state.user, data: { ...state.user.data, ...completionResult.data } }
        : state.user
    }));
  }

  // Close profile completion modal (triggers logout)
  function closeProfileCompletion(): void {
    logout();
  }

  return {
    subscribe,
    init,
    loginSuccess,
    registerSuccess,
    switchView,
    logout,
    completeProfile,
    closeProfileCompletion
  };
}

// Create the store instance
export const authStore = createAuthStore();

// Derived stores for specific auth state properties
export const isAuthenticated: Readable<boolean> = derived(
  authStore,
  ($authStore) => $authStore.isAuthenticated
);

export const currentUser: Readable<LoginResponse | null> = derived(
  authStore,
  ($authStore) => $authStore.user
);

export const needsProfileCompletion: Readable<boolean> = derived(
  authStore,
  ($authStore) => $authStore.showProfileCompletion
);

// Type exports for use in components
export type { AuthState };