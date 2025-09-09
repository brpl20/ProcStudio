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
    async init() {
      const isAuth = api.auth.isAuthenticated();
      if (isAuth) {
        // Recuperar dados do usuário do localStorage se disponível
        const storedUserData = localStorage.getItem('userData');
        if (storedUserData) {
          try {
            const userData = JSON.parse(storedUserData);
            update((state) => ({
              ...state,
              isAuthenticated: true,
              user: userData
            }));
          } catch (error) {
            // Error parsing stored user data
            update((state) => ({ ...state, isAuthenticated: isAuth }));
          }
        } else {
          update((state) => ({ ...state, isAuthenticated: isAuth }));
        }
      } else {
        update((state) => ({ ...state, isAuthenticated: false, user: null }));
      }
    },

    // Login bem-sucedido
    loginSuccess(userData) {
      // Salvar dados do usuário no localStorage
      if (userData) {
        localStorage.setItem('userData', JSON.stringify(userData));
      }
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
        // Logout error
      } finally {
        // Limpar dados do localStorage
        localStorage.removeItem('userData');
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
