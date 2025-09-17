// stores/lawyerStore.svelte.ts
import api from '../api';
import type { Lawyer } from '../api/types/user.lawyer';

class LawyerStore {
  // Reactive state
  lawyers = $state<Lawyer[]>([]);
  selectedLawyers = $state<Lawyer[]>([]);
  loading = $state(false);
  error = $state<string | null>(null);
  initialized = $state(false);

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
    if (this.loading) {
return;
}

    this.loading = true;
    this.error = null;

    try {
      // Fetch user profiles and filter lawyers
      const response = await api.users.getUserProfiles();

      // Filter only lawyers and transform to Lawyer type format
      this.lawyers = response.data?.filter((profile) =>
        profile.attributes.role === 'lawyer'
      ).map((profile) => ({
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

      this.initialized = true;
    } catch (err) {
      this.error = err instanceof Error ? err.message : 'Failed to fetch lawyers';
    } finally {
      this.loading = false;
    }
  }

  // Initialize store
  async init() {
    if (!this.initialized) {
      await this.fetchLawyers();
    }
  }

  // Refresh lawyers
  async refresh() {
    this.initialized = false;
    await this.fetchLawyers();
  }

  // Select a lawyer
  selectLawyer(lawyer: Lawyer) {
    if (!this.selectedLawyers.some((selected) => selected.id === lawyer.id)) {
      this.selectedLawyers.push(lawyer);
    }
  }

  // Unselect a lawyer
  unselectLawyer(lawyerId: string) {
    this.selectedLawyers = this.selectedLawyers.filter((lawyer) => lawyer.id !== lawyerId);
  }

  // Clear all selected lawyers
  clearSelectedLawyers() {
    this.selectedLawyers = [];
  }
}

// Export singleton instance
export const lawyerStore = new LawyerStore();
