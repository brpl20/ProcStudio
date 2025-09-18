// stores/officeStore.svelte.ts
import api from '../api';
import type {
  Office,
  CreateOfficeRequest,
  UpdateOfficeRequest,
  UserOffice,
  PartnershipType
} from '../api/types/office.types';

// Partner interface for managing partners
export interface Partner {
  lawyer_id: string;
  lawyer_name?: string;
  partnership_type: PartnershipType | '';
  ownership_percentage: number;
  is_managing_partner: boolean;
}

// Form data interface matching the OfficeForm needs
export interface OfficeFormData extends Omit<CreateOfficeRequest, 'user_offices_attributes'> {
  id?: number;
  // Financial Information
  quote_value: number;
  number_of_quotes: number;

  // Partners (replacing user_offices_attributes)
  partners: Partner[];

  // Profit distribution
  profit_distribution: 'proportional' | 'disproportional';

  // Social contract
  create_social_contract: boolean;
  social_contracts?: File[];

  // Pro-labore
  partners_with_pro_labore: boolean;
  pro_labore_partners: string[]; // lawyer IDs
}

class OfficeStore {
  // Private consolidated state
  private state = $state({
    offices: [] as Office[],
    currentOffice: null as Office | null,
    formData: this.getEmptyFormData(),
    loading: false,
    saving: false,
    error: null as string | null,
    initialized: false,
    status: 'idle' as 'idle' | 'loading' | 'saving' | 'success' | 'error'
  });

  // Race condition protection
  private fetchPromise: Promise<void> | null = null;
  private savePromise: Promise<Office | null> | null = null;

  // Request cancellation and cleanup
  private abortController: AbortController | null = null;
  private disposed = false;

  // Public getters for accessing state
  get offices() {
    return this.state.offices;
  }

  get currentOffice() {
    return this.state.currentOffice;
  }

  get formData() {
    return this.state.formData;
  }

  get loading() {
    return this.state.loading;
  }

  get saving() {
    return this.state.saving;
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
  officesCount = $derived(this.offices.length);
  activeOffices = $derived(this.offices.filter((office) => !office.deleted));
  totalQuotesValue = $derived(
    this.state.formData.quote_value * this.state.formData.number_of_quotes
  );
  formattedTotalQuotesValue = $derived(
    new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(this.totalQuotesValue)
  );

  // Partners validation
  totalOwnershipPercentage = $derived(
    this.state.formData.partners.reduce(
      (sum, partner) => sum + (partner.ownership_percentage || 0),
      0
    )
  );
  isOverPercentage = $derived(this.totalOwnershipPercentage > 100);
  hasManagingPartner = $derived(
    this.state.formData.partners.some(
      (p) => p.partnership_type === 'socio' && p.is_managing_partner
    )
  );

  // Helper to get empty form data
  private getEmptyFormData(): OfficeFormData {
    return {
      name: '',
      cnpj: '',
      oab_id: '',
      oab_status: '',
      oab_inscricao: '',
      oab_link: '',
      society: undefined,
      foundation: '',
      site: '',
      accounting_type: undefined,
      quote_value: 0,
      number_of_quotes: 0,
      phones_attributes: [{ phone_number: '' }],
      addresses_attributes: [
        {
          street: '',
          number: '',
          complement: '',
          neighborhood: '',
          city: '',
          state: '',
          zip_code: '',
          address_type: 'commercial'
        }
      ],
      emails_attributes: [{ email: '' }],
      bank_accounts_attributes: [
        {
          bank_name: '',
          type_account: '',
          agency: '',
          account: '',
          operation: '',
          pix: ''
        }
      ],
      partners: [
        {
          lawyer_id: '',
          partnership_type: '',
          ownership_percentage: 100,
          is_managing_partner: false
        }
      ],
      profit_distribution: 'proportional',
      create_social_contract: false,
      partners_with_pro_labore: false,
      pro_labore_partners: []
    };
  }

  // Methods
  async fetchOffices() {
    if (this.disposed) {
      return;
    }

    if (this.fetchPromise) {
      return this.fetchPromise;
    }

    this.fetchPromise = this.performFetch();

    try {
      await this.fetchPromise;
    } finally {
      this.fetchPromise = null;
    }
  }

  private async performFetch() {
    this.abortController = new AbortController();

    this.state.loading = true;
    this.state.error = null;
    this.state.status = 'loading';

    try {
      if (this.disposed) {
        this.abortController.abort();
        return;
      }

      const response = await api.offices.getOffices({
        signal: this.abortController.signal
      });

      if (!this.disposed && !this.abortController?.signal.aborted) {
        this.state.offices = response.data || [];
        this.state.initialized = true;
        this.state.status = 'success';
      }
    } catch (err) {
      if (!this.disposed && !this.abortController?.signal.aborted) {
        if (err instanceof Error && err.name === 'AbortError') {
          this.state.status = 'idle';
          this.state.error = null;
        } else {
          this.state.error = err instanceof Error ? err.message : 'Failed to fetch offices';
          this.state.status = 'error';
        }
      }
    } finally {
      if (!this.disposed) {
        this.state.loading = false;
      }
      this.abortController = null;
    }
  }

  // Load a specific office
  async loadOffice(id: number) {
    this.state.loading = true;
    this.state.error = null;

    try {
      const response = await api.offices.getOffice(id);

      if (response.success) {
        this.state.currentOffice = response.data;
        this.loadOfficeIntoForm(response.data);
      } else {
        this.state.error = response.message;
      }
    } catch (err) {
      this.state.error = err instanceof Error ? err.message : 'Failed to load office';
    } finally {
      this.state.loading = false;
    }
  }

  // Load office data into form
  private loadOfficeIntoForm(office: Office) {
    this.state.formData = {
      ...this.state.formData,
      id: office.id,
      name: office.name,
      cnpj: office.cnpj,
      oab_id: office.oab_id,
      oab_status: office.oab_status,
      oab_inscricao: office.oab_inscricao,
      oab_link: office.oab_link,
      society: office.society,
      foundation: office.foundation,
      site: office.site,
      accounting_type: office.accounting_type,
      quote_value: office.quote_value || 0,
      number_of_quotes: office.number_of_quotes || 0,
      phones_attributes: office.phones?.length ? office.phones : [{ phone_number: '' }],
      addresses_attributes: office.addresses?.length
        ? office.addresses
        : [
            {
              street: '',
              number: '',
              complement: '',
              neighborhood: '',
              city: '',
              state: '',
              zip_code: '',
              address_type: 'commercial'
            }
          ],
      emails_attributes: office.emails?.length ? office.emails : [{ email: '' }],
      bank_accounts_attributes: office.bank_accounts?.length
        ? office.bank_accounts
        : [
            {
              bank_name: '',
              type_account: '',
              agency: '',
              account: '',
              operation: '',
              pix: ''
            }
          ],
      // Convert user_offices to partners format
      partners: this.convertUserOfficesToPartners(office.user_offices),
      create_social_contract: office.social_contracts_with_metadata
        ? office.social_contracts_with_metadata.length > 0
        : false
    };
  }

  // Convert user_offices to partners format
  private convertUserOfficesToPartners(userOffices?: UserOffice[]): Partner[] {
    if (!userOffices || userOffices.length === 0) {
      return [
        {
          lawyer_id: '',
          partnership_type: '',
          ownership_percentage: 100,
          is_managing_partner: false
        }
      ];
    }

    return userOffices.map((uo) => ({
      lawyer_id: String(uo.user_id),
      partnership_type: uo.partnership_type || '',
      ownership_percentage: parseFloat(uo.partnership_percentage || '0'),
      is_managing_partner: false // This would need to be tracked separately
    }));
  }

  // Convert partners to user_offices_attributes
  private convertPartnersToUserOffices(partners: Partner[]): Omit<UserOffice, 'id'>[] {
    return partners
      .filter((p) => p.lawyer_id)
      .map((partner) => ({
        user_id: parseInt(partner.lawyer_id),
        partnership_type: partner.partnership_type as PartnershipType,
        partnership_percentage: String(partner.ownership_percentage)
      }));
  }

  // Save office (create or update)
  async saveOffice(): Promise<Office | null> {
    if (this.savePromise) {
      return this.savePromise;
    }

    this.savePromise = this.performSave();

    try {
      return await this.savePromise;
    } finally {
      this.savePromise = null;
    }
  }

  private async performSave(): Promise<Office | null> {
    this.state.saving = true;
    this.state.error = null;
    this.state.status = 'saving';

    try {
      // Prepare data for API
      const apiData = this.prepareFormDataForApi();

      let response;
      if (this.state.formData.id) {
        // Update existing office
        response = await api.offices.updateOffice(this.state.formData.id, apiData);
      } else {
        // Create new office
        response = await api.offices.createOffice(apiData);
      }

      if (response.success) {
        this.state.currentOffice = response.data;
        this.state.status = 'success';

        // Refresh offices list
        await this.fetchOffices();

        return response.data;
      } else {
        this.state.error = response.message;
        this.state.status = 'error';
        return null;
      }
    } catch (err) {
      this.state.error = err instanceof Error ? err.message : 'Failed to save office';
      this.state.status = 'error';
      return null;
    } finally {
      this.state.saving = false;
    }
  }

  // Prepare form data for API
  private prepareFormDataForApi(): CreateOfficeRequest | UpdateOfficeRequest {
    const formData = this.state.formData;

    return {
      name: formData.name,
      cnpj: formData.cnpj,
      oab_id: formData.oab_id,
      oab_status: formData.oab_status,
      oab_inscricao: formData.oab_inscricao,
      oab_link: formData.oab_link,
      society: formData.society,
      foundation: formData.foundation,
      site: formData.site,
      accounting_type: formData.accounting_type,
      quote_value: formData.quote_value,
      number_of_quotes: formData.number_of_quotes,
      phones_attributes: formData.phones_attributes.filter((p) => p.phone_number),
      addresses_attributes: formData.addresses_attributes.filter((a) => a.street || a.city),
      emails_attributes: formData.emails_attributes.filter((e) => e.email),
      bank_accounts_attributes: formData.bank_accounts_attributes.filter((b) => b.bank_name),
      user_offices_attributes: this.convertPartnersToUserOffices(formData.partners)
    };
  }

  // Upload social contracts
  async uploadSocialContracts(officeId: number, files: File[]): Promise<boolean> {
    try {
      const response = await api.offices.uploadSocialContracts(officeId, files);

      if (response.success) {
        // Reload office to get updated contracts
        await this.loadOffice(officeId);
        return true;
      } else {
        this.state.error = response.message;
        return false;
      }
    } catch (err) {
      this.state.error = err instanceof Error ? err.message : 'Failed to upload contracts';
      return false;
    }
  }

  // Initialize store
  async init() {
    if (!this.state.initialized) {
      await this.fetchOffices();
    }
  }

  // Refresh offices
  async refresh() {
    this.abortCurrentRequest();
    this.state.initialized = false;
    this.state.status = 'idle';
    await this.fetchOffices();
  }

  // Reset form data
  resetForm() {
    this.state.formData = this.getEmptyFormData();
    this.state.currentOffice = null;
  }

  // Update form field
  updateFormField<K extends keyof OfficeFormData>(field: K, value: OfficeFormData[K]) {
    this.state.formData[field] = value;
  }

  // Partner management methods
  addPartner() {
    this.state.formData.partners.push({
      lawyer_id: '',
      partnership_type: '',
      ownership_percentage: 0,
      is_managing_partner: false
    });

    // Recalculate percentages if needed
    this.recalculatePartnerPercentages();
  }

  removePartner(index: number) {
    if (this.state.formData.partners.length > 1) {
      this.state.formData.partners.splice(index, 1);
      this.recalculatePartnerPercentages();
    }
  }

  updatePartner(index: number, field: keyof Partner, value: string | number | boolean) {
    if (this.state.formData.partners[index]) {
      this.state.formData.partners[index][field] = value;

      // If updating percentage for 2 partners, adjust the other
      if (field === 'ownership_percentage' && this.state.formData.partners.length === 2) {
        const otherIndex = index === 0 ? 1 : 0;
        this.state.formData.partners[otherIndex].ownership_percentage = 100 - value;
      }
    }
  }

  private recalculatePartnerPercentages() {
    const count = this.state.formData.partners.length;
    if (count === 1) {
      this.state.formData.partners[0].ownership_percentage = 100;
    } else if (count === 2) {
      this.state.formData.partners[0].ownership_percentage = 50;
      this.state.formData.partners[1].ownership_percentage = 50;
    }
  }

  // Financial information methods
  updateQuoteValue(value: number) {
    this.state.formData.quote_value = value;
  }

  updateNumberOfQuotes(value: number) {
    this.state.formData.number_of_quotes = value;
  }

  // Nested attributes management
  addPhone() {
    this.state.formData.phones_attributes.push({ phone_number: '' });
  }

  removePhone(index: number) {
    if (this.state.formData.phones_attributes.length > 1) {
      this.state.formData.phones_attributes.splice(index, 1);
    }
  }

  addEmail() {
    this.state.formData.emails_attributes.push({ email: '' });
  }

  removeEmail(index: number) {
    if (this.state.formData.emails_attributes.length > 1) {
      this.state.formData.emails_attributes.splice(index, 1);
    }
  }

  addAddress() {
    this.state.formData.addresses_attributes.push({
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      address_type: 'commercial'
    });
  }

  removeAddress(index: number) {
    if (this.state.formData.addresses_attributes.length > 1) {
      this.state.formData.addresses_attributes.splice(index, 1);
    }
  }

  addBankAccount() {
    this.state.formData.bank_accounts_attributes.push({
      bank_name: '',
      type_account: '',
      agency: '',
      account: '',
      operation: '',
      pix: ''
    });
  }

  removeBankAccount(index: number) {
    if (this.state.formData.bank_accounts_attributes.length > 1) {
      this.state.formData.bank_accounts_attributes.splice(index, 1);
    }
  }

  // Cleanup and cancellation methods
  private abortCurrentRequest() {
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
    this.fetchPromise = null;
    this.savePromise = null;
  }

  cancel() {
    this.abortCurrentRequest();
    this.state.loading = false;
    this.state.saving = false;
    this.state.status = 'idle';
  }

  dispose() {
    if (this.disposed) {
      return;
    }

    this.disposed = true;
    this.abortCurrentRequest();

    // Clear state
    this.state.offices = [];
    this.state.currentOffice = null;
    this.state.formData = this.getEmptyFormData();
    this.state.loading = false;
    this.state.saving = false;
    this.state.error = null;
    this.state.initialized = false;
    this.state.status = 'idle';
  }

  get isDisposed() {
    return this.disposed;
  }
}

// Export singleton instance
export const officeStore = new OfficeStore();
