// src/stores/userProfileStore.ts
import { writable, derived, type Writable, type Readable } from 'svelte/store';
import { authStore } from './authStore.js';
import api from '../api/index.ts';
import type { UserProfileData } from '../api/types/index.ts';

// Re-export the API type for convenience
export type UserProfile = UserProfileData;

interface UserProfileState {
  profile: UserProfileData | null;
  isLoading: boolean;
  error: string | null;
}

function createUserProfileStore() {
  const { subscribe, set, update }: Writable<UserProfileState> = writable({
    profile: null,
    isLoading: false,
    error: null
  });

  return {
    subscribe,

    // Fetch current user profile information
    async fetchCurrentUser(userId: string): Promise<void> {
      if (!userId) {
        return;
      }

      update((state) => ({ ...state, isLoading: true, error: null }));

      try {
        const response = await api.users.getUser(userId);

        // Extract user profile from the response
        if (response.data && response.included) {
          const profile = api.users.extractUserProfile(response, userId);
          update((state) => ({ ...state, profile, isLoading: false }));
        } else {
          throw new Error('Invalid response format');
        }
      } catch (error: any) {
        console.error('Error fetching user profile:', error);
        update((state) => ({
          ...state,
          isLoading: false,
          error: error.message || 'Error fetching profile'
        }));
      }
    },

    // Clear profile data
    clearProfile(): void {
      set({ profile: null, isLoading: false, error: null });
    }
  };
}

// Create the store
export const userProfileStore = createUserProfileStore();

// Create a derived store that automatically fetches the profile when auth changes
export const currentUserProfile: Readable<UserProfileData | null> = derived(
  [authStore, userProfileStore],
  ([$authStore, $userProfileStore], set) => {
    if ($authStore.isAuthenticated && $authStore.user?.data?.id && !$userProfileStore.profile) {
      userProfileStore.fetchCurrentUser($authStore.user.data.id);
    } else if (!$authStore.isAuthenticated) {
      userProfileStore.clearProfile();
    }
    set($userProfileStore.profile);
  },
  null
);
