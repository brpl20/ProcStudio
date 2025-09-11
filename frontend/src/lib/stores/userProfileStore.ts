// src/stores/userProfileStore.ts
import { writable, derived, get, type Writable, type Readable } from 'svelte/store';
import { authStore } from './authStore';
import { usersCacheStore } from './usersCacheStore';
import api from '../api/index';
import type { UserProfileData } from '../api/types/user.types';

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

    // Fetch current user profile - now uses cache first
    async fetchCurrentUser(userId: string): Promise<void> {
      if (!userId) {
        return;
      }

      update((state) => ({ ...state, isLoading: true, error: null }));

      try {
        // First, ensure cache is initialized
        await usersCacheStore.initialize();
        
        // Try to get from cache first
        let profile = usersCacheStore.getProfileByUserId(userId);
        
        if (profile) {
          console.log(`Found user profile in cache for user ${userId}`);
          update((state) => ({ ...state, profile, isLoading: false }));
          return;
        }

        // If not in cache or cache needs refresh, fetch from API
        if (usersCacheStore.needsRefresh()) {
          console.log('Cache needs refresh, fetching all profiles...');
          await usersCacheStore.fetchAllProfiles();
          profile = usersCacheStore.getProfileByUserId(userId);
        }

        if (profile) {
          update((state) => ({ ...state, profile, isLoading: false }));
        } else {
          // Fallback: try direct API call for specific profile
          console.log(`Profile not in cache for user ${userId}, trying direct API call...`);
          const response = await api.users.getUser(userId);
          
          if (response.data && response.included) {
            profile = api.users.extractUserProfile(response, userId);
            update((state) => ({ ...state, profile, isLoading: false }));
          } else {
            throw new Error('User profile not found');
          }
        }
      } catch (error: unknown) {
        console.error('Error fetching user profile:', error);
        update((state) => ({
          ...state,
          isLoading: false,
          error: (error as Error)?.message || 'Error fetching profile'
        }));
      }
    },

    // Set profile directly (useful when we have the data already)
    setProfile(profile: UserProfileData): void {
      update((state) => ({ ...state, profile, isLoading: false, error: null }));
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
