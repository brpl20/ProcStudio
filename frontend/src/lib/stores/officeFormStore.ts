// stores/officeFormStore.svelte.js
import api from '../api';

class OfficeFormLawyersStore {
  // Reactive state
  lawyers = $state([]);
  loading = $state(false);
  error = $state(null);
  initialized = $state(false);
  selectedPartners = $state([]);

  // Derived values
  get availableLawyers() {
    const selectedIds = this.selectedPartners.filter((id) => id && id !== '');
    return this.lawyers.filter((lawyer) => !selectedIds.includes(lawyer.id));
  }

  get availableCount() {
    return this.availableLawyers.length;
  }

  // Load lawyers from the backend
  async loadLawyers() {
    this.loading = true;
    this.error = null;

    try {
      const response = await api.users.getUserProfiles();

      if (response.success && response.data && Array.isArray(response.data)) {
        const lawyers = response.data
          .filter((profile) => profile.attributes?.role === 'lawyer')
          .map((profile) => ({
            id: profile.attributes.user_id || profile.id,
            attributes: {
              name: profile.attributes.name,
              last_name: profile.attributes.last_name,
              role: profile.attributes.role,
              email: profile.attributes.access_email,
              user_id: profile.attributes.user_id
            }
          }));

        this.lawyers = lawyers;
        this.initialized = true;
        return lawyers;
      } else {
        this.lawyers = [];
        this.error = 'Sem advogados cadastrados';
        this.initialized = true;
        return [];
      }
    } catch (err) {
      this.lawyers = [];
      this.error = err.message || 'Falha ao ler advogados';
      this.initialized = true;
      throw err;
    } finally {
      this.loading = false;
    }
  }

  // Partner selection methods
  addPartner(lawyerId, index = null) {
    if (index !== null && index >= 0) {
      const newSelected = [...this.selectedPartners];
      newSelected[index] = lawyerId;
      this.selectedPartners = newSelected;
    } else {
      this.selectedPartners = [...this.selectedPartners, lawyerId];
    }
  }

  removePartner(lawyerId) {
    this.selectedPartners = this.selectedPartners.filter((id) => id !== lawyerId);
  }

  updatePartnerAt(index, lawyerId) {
    const newSelected = [...this.selectedPartners];
    newSelected[index] = lawyerId || null;
    this.selectedPartners = newSelected;
  }

  clearPartners() {
    this.selectedPartners = [];
  }

  setAllPartners(lawyerIds) {
    this.selectedPartners = lawyerIds;
  }

  // Get available lawyers for a specific partner index
  getAvailableLawyersForPartnerIndex(currentIndex) {
    if (!this.lawyers || !Array.isArray(this.lawyers)) {
      return [];
    }

    // Get all selected IDs except for the current index
    const selectedIds = this.selectedPartners
      .filter((_, index) => index !== currentIndex)
      .filter((id) => id && id !== '');

    return this.lawyers.filter((lawyer) => !selectedIds.includes(lawyer.id));
  }

  // Utility methods
  findById(lawyerId) {
    // Convert to string for comparison to handle both string and number IDs
    return this.lawyers.find((lawyer) => String(lawyer.id) === String(lawyerId));
  }

  getFullName(lawyer) {
    if (!lawyer?.attributes) {
      return '';
    }
    const { name, last_name } = lawyer.attributes;
    return `${name || ''} ${last_name || ''}`.trim();
  }

  isAvailable(lawyerId) {
    return !this.selectedPartners.includes(lawyerId);
  }

  canAddMorePartners(currentPartnersCount) {
    return this.lawyers.length > currentPartnersCount;
  }

  reset() {
    this.lawyers = [];
    this.loading = false;
    this.error = null;
    this.initialized = false;
    this.selectedPartners = [];
  }
}

// Create singleton instance
export const officeFormLawyersStore = new OfficeFormLawyersStore();

// For compatibility if needed, export utils
export const officeFormLawyersUtils = {
  findById: (lawyerId) => officeFormLawyersStore.findById(lawyerId),
  getFullName: (lawyer) => officeFormLawyersStore.getFullName(lawyer),
  isAvailable: (lawyerId) => officeFormLawyersStore.isAvailable(lawyerId),
  getAvailableCount: () => officeFormLawyersStore.availableCount,
  canAddMorePartners: (count) => officeFormLawyersStore.canAddMorePartners(count)
};
