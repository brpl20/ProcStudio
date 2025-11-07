/**
 * New Office Store - Complete implementation for office creation
 * Manages form state and API interactions with full data structure
 */

import api from '../api';
import type { Office, CreateOfficeRequest, PartnerFormData } from '../api/types/office.types';
import type { NewOfficeFormData, NewOfficeFormState, FormValidationConfig } from '../schemas/new-office-form';
import {
  createDefaultNewOfficeFormData,
  transformNewOfficeFormToApiRequest,
  hasNewOfficeFormData,
  validateNewOfficeForm,
  createDefaultValidationConfig
} from '../schemas/new-office-form';

class NewOfficeStore {
  // Private state using Svelte 5 runes
  private state = $state({
    formData: createDefaultNewOfficeFormData(),
    formState: {
      loading: false,
      saving: false,
      error: null,
      success: null,
      isDirty: false
    } as NewOfficeFormState,
    currentOffice: null as Office | null,
    validationConfig: createDefaultValidationConfig()
  });

  // Public getters
  get formData() {
    return this.state.formData;
  }

  get formState() {
    return this.state.formState;
  }

  get currentOffice() {
    return this.state.currentOffice;
  }

  get validationConfig() {
    return this.state.validationConfig;
  }

  // Derived state
  isDirty = $derived(hasNewOfficeFormData(this.state.formData));
  isValid = $derived(validateNewOfficeForm(this.state.formData, this.state.validationConfig).length === 0);
  canSubmit = $derived(
    this.isDirty &&
    this.isValid &&
    !this.state.formState.loading &&
    !this.state.formState.saving
  );

  // Check if quote configuration is valid
  isQuoteConfigValid = $derived(
    this.state.formData.quote_value > 0 &&
    this.state.formData.number_of_quotes > 0
  );

  // Calculate total capital
  totalCapital = $derived(
    this.state.formData.quote_value * this.state.formData.number_of_quotes
  );

  // Update form field
  updateField<K extends keyof NewOfficeFormData>(
    field: K,
    value: NewOfficeFormData[K]
  ) {
    this.state.formData[field] = value;
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  // Update entire form data
  updateFormData(data: Partial<NewOfficeFormData>) {
    Object.assign(this.state.formData, data);
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  // Update partners array
  updatePartners(partners: PartnerFormData[]) {
    this.state.formData.partners = partners;
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  // Add a partner
  addPartner(partner: PartnerFormData) {
    this.state.formData.partners = [...this.state.formData.partners, partner];
    this.state.formState.isDirty = this.isDirty;
  }

  // Remove a partner
  removePartner(index: number) {
    this.state.formData.partners = this.state.formData.partners.filter((_, i) => i !== index);
    this.state.formState.isDirty = this.isDirty;
  }

  // Update a specific partner
  updatePartner(index: number, partner: PartnerFormData) {
    if (index >= 0 && index < this.state.formData.partners.length) {
      this.state.formData.partners[index] = partner;
      this.state.formState.isDirty = this.isDirty;
    }
  }

  // Reset form
  resetForm() {
    this.state.formData = createDefaultNewOfficeFormData();
    this.state.formState = {
      loading: false,
      saving: false,
      error: null,
      success: null,
      isDirty: false
    };
    this.state.currentOffice = null;
  }

  // Set validation configuration
  setValidationConfig(config: FormValidationConfig) {
    this.state.validationConfig = config;
  }

  // Clear messages
  clearMessages() {
    this.state.formState.error = null;
    this.state.formState.success = null;
  }

  // Save new office
  async saveNewOffice(): Promise<Office | null> {
    if (!this.canSubmit) {
      this.state.formState.error = 'Formulário inválido ou incompleto';
      return null;
    }

    this.state.formState.saving = true;
    this.state.formState.error = null;
    this.state.formState.success = null;

    try {
      // Transform form data to API format
      const apiData = transformNewOfficeFormToApiRequest(this.state.formData);

      // Call API with wrapped data
      const response = await api.offices.createOffice(apiData);

      if (response.success && response.data) {
        this.state.currentOffice = response.data;
        this.state.formState.success = 'Escritório criado com sucesso!';
        this.state.formState.isDirty = false;
        return response.data;
      } else {
        this.state.formState.error = response.message || 'Erro ao criar escritório';
        return null;
      }
    } catch (error) {
      this.state.formState.error = error instanceof Error
        ? error.message
        : 'Erro inesperado ao criar escritório';
      return null;
    } finally {
      this.state.formState.saving = false;
    }
  }

  // Load office for editing
  async loadNewOffice(id: number): Promise<boolean> {
    this.state.formState.loading = true;
    this.state.formState.error = null;

    try {
      const response = await api.offices.getOffice(id);

      if (response.success && response.data) {
        this.state.currentOffice = response.data;
        this.loadOfficeIntoForm(response.data);
        return true;
      } else {
        this.state.formState.error = response.message || 'Erro ao carregar escritório';
        return false;
      }
    } catch (error) {
      this.state.formState.error = error instanceof Error
        ? error.message
        : 'Erro inesperado ao carregar escritório';
      return false;
    } finally {
      this.state.formState.loading = false;
    }
  }

  // Load office data into form
  private loadOfficeIntoForm(office: Office) {
    // Basic information
    this.state.formData.name = office.name || '';
    this.state.formData.cnpj = office.cnpj || '';
    this.state.formData.society = office.society || '';
    this.state.formData.accounting_type = office.accounting_type || '';
    this.state.formData.foundation = office.foundation || '';
    this.state.formData.site = office.site || '';

    // Quote configuration
    this.state.formData.proportional = office.proportional ?? true;
    this.state.formData.quote_value = office.quote_value || 0;
    this.state.formData.number_of_quotes = office.number_of_quotes || 0;

    // OAB information
    this.state.formData.oab_id = office.oab_id || '';
    this.state.formData.oab_status = office.oab_status || '';
    this.state.formData.oab_inscricao = office.oab_inscricao || '';
    this.state.formData.oab_link = office.oab_link || '';

    // Address
    if (office.addresses && office.addresses.length > 0) {
      const address = office.addresses[0];
      this.state.formData.address = {
        street: address.street || '',
        number: address.number || '',
        complement: address.complement || '',
        neighborhood: address.neighborhood || '',
        city: address.city || '',
        state: address.state || '',
        zip_code: address.zip_code || '',
        address_type: address.address_type || 'main'
      };
    }

    // Phones
    if (office.phones && office.phones.length > 0) {
      this.state.formData.phones = office.phones.map((p) => p.phone_number);
    }

    // Partners (from user_offices)
    if (office.user_offices && office.user_offices.length > 0) {
      this.state.formData.partners = office.user_offices.map((uo) => {
        const partner: PartnerFormData = {
          lawyer_id: String(uo.user_id),
          partnership_type: uo.partnership_type || '',
          ownership_percentage: uo.partnership_percentage || 0,
          is_managing_partner: uo.is_administrator || false,
          entry_date: uo.entry_date
        };

        // Extract compensation data
        if (uo.compensations_attributes && uo.compensations_attributes.length > 0) {
          uo.compensations_attributes.forEach((comp) => {
            if (comp.compensation_type === 'pro_labore') {
              partner.pro_labore_amount = comp.amount;
            } else if (comp.compensation_type === 'salary') {
              partner.salary_amount = comp.amount;
              partner.salary_start_date = comp.effective_date;
              partner.salary_end_date = comp.end_date;
              partner.payment_frequency = comp.payment_frequency;
            }
          });

          this.state.formData.partnersWithProLabore = true;
        }

        return partner;
      });
    }

    this.state.formState.isDirty = false;
  }

  // Get validation errors with current config
  getValidationErrors(): string[] {
    return validateNewOfficeForm(this.state.formData, this.state.validationConfig);
  }
}

// Export singleton instance
export const newOfficeStore = new NewOfficeStore();