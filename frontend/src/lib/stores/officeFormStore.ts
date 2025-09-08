import { writable, derived, get } from 'svelte/store';
import api from '../api';

// Create the base store for all lawyers
function createLawyersStore() {
  const { subscribe, set, update } = writable({
    lawyers: [],
    loading: false,
    error: null,
    initialized: false
  });

  return {
    subscribe,

    // Load lawyers from the backend
    async loadLawyers() {
      update((state) => ({ ...state, loading: true, error: null }));

      try {
        const response = await api.users.getUserProfiles();

        if (response.success && response.data && Array.isArray(response.data)) {
          const lawyers = response.data
            .filter((profile) => {
              return profile.attributes?.role === 'lawyer';
            })
            .map((profile) => {
              return {
                id: profile.attributes.user_id || profile.id,
                attributes: {
                  name: profile.attributes.name,
                  last_name: profile.attributes.last_name,
                  role: profile.attributes.role,
                  email: profile.attributes.access_email,
                  user_id: profile.attributes.user_id
                }
              };
            });

          set({
            lawyers,
            loading: false,
            error: null,
            initialized: true
          });

          return lawyers;
        } else {
          set({
            lawyers: [],
            loading: false,
            error: 'No lawyers data available',
            initialized: true
          });
          return [];
        }
      } catch (err) {
        set({
          lawyers: [],
          loading: false,
          error: err.message || 'Failed to load lawyers',
          initialized: true
        });
        throw err;
      }
    },

    // Reset the store
    reset() {
      set({
        lawyers: [],
        loading: false,
        error: null,
        initialized: false
      });
    },

    // Get lawyers list directly (useful for non-reactive contexts)
    getLawyers() {
      return get(this).lawyers;
    }
  };
}

// Create the store instance
export const officeFormLawyersStore = createLawyersStore();

// Create a store for selected partners
function createSelectedPartnersStore() {
  const { subscribe, set, update } = writable([]);

  return {
    subscribe,

    // Add a selected partner
    add(lawyerId, index = null) {
      update((selected) => {
        if (index !== null && index >= 0) {
          const newSelected = [...selected];
          newSelected[index] = lawyerId;
          return newSelected;
        }
        return [...selected, lawyerId];
      });
    },

    // Remove a selected partner
    remove(lawyerId) {
      update((selected) => selected.filter((id) => id !== lawyerId));
    },

    // Update a partner at specific index
    updateAt(index, lawyerId) {
      update((selected) => {
        const newSelected = [...selected];
        newSelected[index] = lawyerId || null;
        return newSelected;
      });
    },

    // Clear all selections
    clear() {
      set([]);
    },

    // Set all selections at once
    setAll(lawyerIds) {
      set(lawyerIds);
    },

    // Get current selections
    getSelected() {
      return get(this);
    }
  };
}

// Create the selected partners store instance
export const selectedPartnersStore = createSelectedPartnersStore();

// Derived store for available lawyers
// This automatically updates when either officeFormLawyersStore or selectedPartnersStore changes
export const availableLawyersStore = derived(
  [officeFormLawyersStore, selectedPartnersStore],
  ([$lawyersStore, $selectedPartners]) => {
    if (!$lawyersStore.lawyers) {
      return [];
    }

    // Filter out lawyers that are already selected
    const selectedIds = $selectedPartners.filter((id) => id && id !== '');
    return $lawyersStore.lawyers.filter((lawyer) => !selectedIds.includes(lawyer.id));
  }
);

// Helper function to get available lawyers for a specific partner index
// (excludes all selected lawyers except the one at currentIndex)
export function getAvailableLawyersForPartnerIndex(currentIndex) {
  const state = get(officeFormLawyersStore);
  const selected = get(selectedPartnersStore);

  if (!state.lawyers) {
    return [];
  }

  // Get all selected IDs except for the current index
  const selectedIds = selected
    .filter((_, index) => index !== currentIndex)
    .filter((id) => id && id !== '');

  const availableLawyers = state.lawyers.filter((lawyer) => !selectedIds.includes(lawyer.id));

  return availableLawyers;
}

// Utility functions for common operations
export const officeFormLawyersUtils = {
  // Find a lawyer by ID
  findById(lawyerId) {
    const state = get(officeFormLawyersStore);
    return state.lawyers.find((lawyer) => lawyer.id === lawyerId);
  },

  // Get full name of a lawyer
  getFullName(lawyer) {
    if (!lawyer?.attributes) {
      return '';
    }
    const { name, last_name } = lawyer.attributes;
    return `${name || ''} ${last_name || ''}`.trim();
  },

  // Check if a lawyer is available
  isAvailable(lawyerId) {
    const selected = get(selectedPartnersStore);
    return !selected.includes(lawyerId);
  },

  // Get count of available lawyers
  getAvailableCount() {
    const available = get(availableLawyersStore);
    return available.length;
  },

  // Check if there are more lawyers available than current partners
  canAddMorePartners(currentPartnersCount) {
    const state = get(officeFormLawyersStore);
    return state.lawyers.length > currentPartnersCount;
  }
};
