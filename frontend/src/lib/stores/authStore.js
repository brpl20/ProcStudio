import { writable } from 'svelte/store';
import api from '../api/index';

function createAuthStore() {
  const { subscribe, set, update } = writable({
    isAuthenticated: false,
    user: null,
    currentView: 'login', // 'login' ou 'register'
    showProfileCompletion: false,
    profileData: null,
    missingFields: []
  });

  return {
    subscribe,

    // Inicializar autenticação
    init() {
      const isAuth = api.auth.isAuthenticated();
      update((state) => ({ ...state, isAuthenticated: isAuth }));
    },

    // Login bem-sucedido
    loginSuccess(userData) {
      update((state) => ({
        ...state,
        isAuthenticated: true,
        user: userData,
        showProfileCompletion: userData.data.needs_profile_completion,
        profileData: userData.data,
        missingFields: userData.data.missing_fields || []
      }));
    },

    // Registro bem-sucedido
    registerSuccess() {
      update((state) => ({ ...state, currentView: 'login' }));
    },

    // Alternar entre login/registro
    switchView() {
      update((state) => ({
        ...state,
        currentView: state.currentView === 'login' ? 'register' : 'login'
      }));
    },

    // Logout
    async logout() {
      try {
        await api.auth.logout();
      } catch (error) {
        console.error('Logout error:', error);
      } finally {
        set({
          isAuthenticated: false,
          user: null,
          currentView: 'login',
          showProfileCompletion: false,
          profileData: null,
          missingFields: []
        });
      }
    },

    // Completar perfil
    completeProfile(completionResult) {
      update((state) => ({
        ...state,
        showProfileCompletion: false,
        profileData: null,
        missingFields: [],
        user: completionResult.user ? { ...state.user, ...completionResult.user } : state.user
      }));
    },

    // Fechar modal de perfil
    closeProfileCompletion() {
      // Redireciona para logout se fechar sem completar
      this.logout();
    }
  };
}

export const authStore = createAuthStore();
