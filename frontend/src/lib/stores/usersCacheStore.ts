// stores/usersCacheStore.ts
import { writable, derived, get, type Writable, type Readable } from 'svelte/store';
import api from '../api/index';
import type { UserProfileData } from '../api/types/user.types';

// Cache configuration
const CACHE_CONFIG = {
  STORAGE_KEY: 'users_profiles_cache',
  CACHE_DURATION: 1000 * 60 * 60 * 24, // 24 hours
  MAX_STORAGE_SIZE: 1024 * 1024 * 5 // 5MB limit for localStorage
} as const;

interface UsersCacheState {
  profiles: Map<string, UserProfileData>;
  avatarUrls: Map<string, string>;
  isLoading: boolean;
  isInitialized: boolean;
  error: string | null;
  lastFetched: number | null;
}

// Helper functions for localStorage
const storage = {
  save(profiles: Map<string, UserProfileData>, lastFetched: number): boolean {
    try {
      const data = {
        profiles: Array.from(profiles.entries()),
        lastFetched
      };
      const serialized = JSON.stringify(data);
      
      // Check size before saving
      if (serialized.length > CACHE_CONFIG.MAX_STORAGE_SIZE) {
        console.warn('Cache too large for localStorage, skipping persistence');
        return false;
      }
      
      localStorage.setItem(CACHE_CONFIG.STORAGE_KEY, serialized);
      return true;
    } catch (error) {
      console.error('Failed to save cache to localStorage:', error);
      return false;
    }
  },

  load(): { profiles: Map<string, UserProfileData>; lastFetched: number } | null {
    try {
      const stored = localStorage.getItem(CACHE_CONFIG.STORAGE_KEY);
      if (!stored) return null;

      const data = JSON.parse(stored);
      
      // Check if cache is expired
      if (data.lastFetched && Date.now() - data.lastFetched > CACHE_CONFIG.CACHE_DURATION) {
        localStorage.removeItem(CACHE_CONFIG.STORAGE_KEY);
        return null;
      }

      return {
        profiles: new Map(data.profiles),
        lastFetched: data.lastFetched
      };
    } catch (error) {
      console.error('Failed to load cache from localStorage:', error);
      localStorage.removeItem(CACHE_CONFIG.STORAGE_KEY);
      return null;
    }
  },

  clear(): void {
    localStorage.removeItem(CACHE_CONFIG.STORAGE_KEY);
  }
};

function createUsersCacheStore() {
  const initialState: UsersCacheState = {
    profiles: new Map(),
    avatarUrls: new Map(),
    isLoading: false,
    isInitialized: false,
    error: null,
    lastFetched: null
  };

  const { subscribe, set, update }: Writable<UsersCacheState> = writable(initialState);

  // Initialize from localStorage on creation
  async function initialize(forceRefresh = false): Promise<void> {
    const state = get({ subscribe });
    
    // Already initialized and not forcing refresh
    if (state.isInitialized && !forceRefresh) {
      return;
    }

    // Try to load from localStorage first
    if (!forceRefresh) {
      const cached = storage.load();
      if (cached) {
        console.log('Loaded user profiles from localStorage cache');
        const avatarUrls = new Map<string, string>();
        
        // Extract avatar URLs for quick access
        cached.profiles.forEach((profile, userId) => {
          const avatarUrl = profile.attributes?.avatar_url || profile.attributes?.avatar;
          if (avatarUrl) {
            avatarUrls.set(userId, avatarUrl);
          }
        });

        update((state) => ({
          ...state,
          profiles: cached.profiles,
          avatarUrls,
          lastFetched: cached.lastFetched,
          isInitialized: true
        }));
        return;
      }
    }

    // Fetch from API
    await fetchAllProfiles();
  }

  // Fetch all user profiles from API
  async function fetchAllProfiles(): Promise<void> {
    update((state) => ({ ...state, isLoading: true, error: null }));

    try {
      console.log('Fetching all user profiles from API...');
      const response = await api.users.getUserProfiles();
      
      if (response.success && response.data) {
        const profiles = new Map<string, UserProfileData>();
        const avatarUrls = new Map<string, string>();
        
        // Process all profiles
        response.data.forEach((profile: UserProfileData) => {
          profiles.set(profile.id, profile);
          
          // Extract avatar URL for quick access
          const avatarUrl = profile.attributes?.avatar_url || profile.attributes?.avatar;
          if (avatarUrl) {
            avatarUrls.set(profile.id, avatarUrl);
          }
        });

        const now = Date.now();

        // Save to localStorage
        storage.save(profiles, now);

        update((state) => ({
          ...state,
          profiles,
          avatarUrls,
          lastFetched: now,
          isLoading: false,
          isInitialized: true,
          error: null
        }));

        console.log(`Cached ${profiles.size} user profiles with ${avatarUrls.size} avatars`);
      } else {
        throw new Error('Invalid response format');
      }
    } catch (error: unknown) {
      console.error('Error fetching user profiles:', error);
      update((state) => ({
        ...state,
        isLoading: false,
        error: (error as Error)?.message || 'Failed to fetch user profiles'
      }));
    }
  }

  // Get a specific user profile from cache
  function getProfile(profileId: string): UserProfileData | undefined {
    const state = get({ subscribe });
    return state.profiles.get(profileId);
  }

  // Get user profile by user ID (searches through profiles)
  function getProfileByUserId(userId: string | number): UserProfileData | undefined {
    const state = get({ subscribe });
    const userIdStr = String(userId);
    
    // Search through profiles to find one with matching user_id
    for (const profile of state.profiles.values()) {
      if (String(profile.attributes?.user_id) === userIdStr) {
        return profile;
      }
    }
    return undefined;
  }

  // Get avatar URL for a user
  function getAvatarUrl(profileId: string): string | undefined {
    const state = get({ subscribe });
    return state.avatarUrls.get(profileId);
  }

  // Get avatar URL by user ID
  function getAvatarUrlByUserId(userId: string | number): string | undefined {
    const profile = getProfileByUserId(userId);
    return profile ? (profile.attributes?.avatar_url || profile.attributes?.avatar) : undefined;
  }

  // Get user profile by email (alternative lookup)
  function getProfileByEmail(email: string): UserProfileData | undefined {
    const state = get({ subscribe });
    
    for (const profile of state.profiles.values()) {
      if (profile.attributes?.access_email === email) {
        return profile;
      }
    }
    return undefined;
  }

  // Search profiles by name
  function searchProfiles(query: string): UserProfileData[] {
    const state = get({ subscribe });
    const lowerQuery = query.toLowerCase();
    
    return Array.from(state.profiles.values()).filter((profile) => {
      const name = profile.attributes?.name?.toLowerCase() || '';
      const lastName = profile.attributes?.last_name?.toLowerCase() || '';
      const email = profile.attributes?.access_email?.toLowerCase() || '';
      const oab = profile.attributes?.oab?.toLowerCase() || '';
      
      return (
        name.includes(lowerQuery) ||
        lastName.includes(lowerQuery) ||
        email.includes(lowerQuery) ||
        oab.includes(lowerQuery)
      );
    });
  }

  // Clear cache
  function clearCache(): void {
    storage.clear();
    set(initialState);
  }

  // Check if cache needs refresh
  function needsRefresh(): boolean {
    const state = get({ subscribe });
    if (!state.lastFetched) return true;
    
    return Date.now() - state.lastFetched > CACHE_CONFIG.CACHE_DURATION;
  }

  return {
    subscribe,
    initialize,
    fetchAllProfiles,
    getProfile,
    getProfileByUserId,
    getProfileByEmail,
    getAvatarUrl,
    getAvatarUrlByUserId,
    searchProfiles,
    clearCache,
    needsRefresh
  };
}

// Create the store instance
export const usersCacheStore = createUsersCacheStore();

// Derived store for all profiles as array
export const allUserProfiles: Readable<UserProfileData[]> = derived(
  usersCacheStore,
  ($cache) => Array.from($cache.profiles.values())
);

// Derived store for all avatar URLs
export const allAvatarUrls: Readable<Map<string, string>> = derived(
  usersCacheStore,
  ($cache) => $cache.avatarUrls
);

// Derived store for cache status
export const cacheStatus: Readable<{
  isLoading: boolean;
  isInitialized: boolean;
  profileCount: number;
  lastFetched: Date | null;
}> = derived(usersCacheStore, ($cache) => ({
  isLoading: $cache.isLoading,
  isInitialized: $cache.isInitialized,
  profileCount: $cache.profiles.size,
  lastFetched: $cache.lastFetched ? new Date($cache.lastFetched) : null
}));