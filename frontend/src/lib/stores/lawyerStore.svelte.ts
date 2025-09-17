// stores/lawyerStore.svelte.ts
import api from '../api';
import type { Lawyer } from '../api/types/user.lawyer';

class LawyerStore {
  // Private consolidated state
  private state = $state({
    lawyers: [] as Lawyer[],
    selectedLawyers: [] as Lawyer[],
    loading: false,
    error: null as string | null,
    initialized: false,
    status: 'idle' as 'idle' | 'loading' | 'success' | 'error'
  });

  // Race condition protection
  private fetchPromise: Promise<void> | null = null;

  // Request cancellation and cleanup
  private abortController: AbortController | null = null;
  private disposed = false;

  // Public getters for accessing state
  get lawyers() {
    return this.state.lawyers;
  }

  get selectedLawyers() {
    return this.state.selectedLawyers;
  }

  get loading() {
    return this.state.loading;
  }

  get error() {
    return this.state.error;
  }

  get initialized() {
    return this.state.initialized;
  }

  get status() {
    return this.state.status;
  }

  // Derived state
  lawyersCount = $derived(this.lawyers.length);
  activeLawyers = $derived(
    this.lawyers.filter(
      (lawyer) => lawyer.attributes.status === 'active' && !lawyer.attributes.deleted
    )
  );
  availableLawyers = $derived(
    this.activeLawyers.filter(
      (lawyer) => !this.selectedLawyers.some((selected) => selected.id === lawyer.id)
    )
  );
  selectedLawyersCount = $derived(this.selectedLawyers.length);
  remainingLawyersCount = $derived(this.availableLawyers.length);

  // Methods
  async fetchLawyers() {
    // Check if store is disposed
    if (this.disposed) {
      return;
    }

    // Return existing promise if already fetching
    if (this.fetchPromise) {
      return this.fetchPromise;
    }

    // Create and store the fetch promise
    this.fetchPromise = this.performFetch();

    try {
      await this.fetchPromise;
    } finally {
      // Clear the promise when done
      this.fetchPromise = null;
    }
  }

  private async performFetch() {
    // Create new AbortController for this request
    this.abortController = new AbortController();

    this.state.loading = true;
    this.state.error = null;
    this.state.status = 'loading';

    try {
      // Check if already disposed before making request
      if (this.disposed) {
        this.abortController.abort();
        return;
      }

      // Fetch user profiles and filter lawyers with abort signal
      const response = await api.users.getUserProfiles({
        signal: this.abortController.signal
      });

      // Filter only lawyers and transform to Lawyer type format
      // Alwasys check for null or empty attributes
      this.state.lawyers =
        response.data
          ?.filter((profile) => profile.attributes.role === 'lawyer')
          .map((profile) => ({
            id: profile.id,
            type: 'lawyer' as const,
            attributes: {
              role: 'lawyer' as const,
              name: profile.attributes.name,
              last_name: profile.attributes.last_name,
              status: profile.attributes.status,
              access_email: profile.attributes.access_email,
              user_id: profile.attributes.user_id,
              office_id: profile.attributes.office_id || null,
              gender: profile.attributes.gender as 'male' | 'female',
              oab: profile.attributes.oab || '',
              rg: profile.attributes.rg || '',
              cpf: profile.attributes.cpf || '',
              nationality: profile.attributes.nationality || '',
              origin: profile.attributes.origin || null,
              civil_status: profile.attributes.civil_status || '',
              birth: profile.attributes.birth || '',
              mother_name: profile.attributes.mother_name || null,
              deleted: profile.attributes.deleted,
              bank_accounts: profile.attributes.bank_accounts || [],
              phones: profile.attributes.phones || [],
              addresses: profile.attributes.addresses || [],
              avatar_url: profile.attributes.avatar_url || ''
            }
          })) || [];

      // Only update state if not disposed and not aborted
      if (!this.disposed && !this.abortController?.signal.aborted) {
        this.state.initialized = true;
        this.state.status = 'success';
      }
    } catch (err) {
      // Only update error state if not disposed and not aborted
      if (!this.disposed && !this.abortController?.signal.aborted) {
        if (err instanceof Error && err.name === 'AbortError') {
          this.state.status = 'idle';
          this.state.error = null;
        } else {
          this.state.error = err instanceof Error ? err.message : 'Failed to fetch lawyers';
          this.state.status = 'error';
        }
      }
    } finally {
      // Always clean up loading state and abort controller if not disposed
      if (!this.disposed) {
        this.state.loading = false;
      }
      this.abortController = null;
    }
  }

  // Initialize store
  async init() {
    if (!this.state.initialized) {
      await this.fetchLawyers();
    }
  }

  // Refresh lawyers
  async refresh() {
    // Cancel any existing fetch operation
    this.abortCurrentRequest();

    this.state.initialized = false;
    this.state.status = 'idle';
    await this.fetchLawyers();
  }

  // Select a lawyer
  selectLawyer(lawyer: Lawyer) {
    if (!this.state.selectedLawyers.some((selected) => selected.id === lawyer.id)) {
      this.state.selectedLawyers.push(lawyer);
    }
  }

  // Unselect a lawyer
  unselectLawyer(lawyerId: string) {
    this.state.selectedLawyers = this.state.selectedLawyers.filter(
      (lawyer) => lawyer.id !== lawyerId
    );
  }

  // Clear all selected lawyers
  clearSelectedLawyers() {
    this.state.selectedLawyers = [];
  }

  // Cleanup and cancellation methods
  private abortCurrentRequest() {
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
    this.fetchPromise = null;
  }

  /**
   * Cancel any in-flight requests
   */
  cancel() {
    this.abortCurrentRequest();
    this.state.loading = false;
    this.state.status = 'idle';
  }

  /**
   * Dispose of the store and cleanup resources
   * Call this when the component unmounts to prevent memory leaks
   */
  dispose() {
    if (this.disposed) {
      return;
    }

    this.disposed = true;

    // Cancel any in-flight requests
    this.abortCurrentRequest();

    // Clear state
    this.state.lawyers = [];
    this.state.selectedLawyers = [];
    this.state.loading = false;
    this.state.error = null;
    this.state.initialized = false;
    this.state.status = 'idle';
  }

  /**
   * Check if store is disposed
   */
  get isDisposed() {
    return this.disposed;
  }
}

// Export singleton instance
export const lawyerStore = new LawyerStore();
