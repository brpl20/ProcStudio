/**
 * New Office Store - Clean implementation for basic office creation
 * Manages form state and API interactions without legacy conflicts
 */

import api from '../api';
import type { Office, CreateOfficeRequest } from '../api/types/office.types';
import type { NewOfficeFormData, NewOfficeFormState } from '../schemas/new-office-form';
import { 
  createDefaultNewOfficeFormData, 
  transformNewOfficeFormToApiRequest,
  hasNewOfficeFormData,
  validateNewOfficeForm
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
    currentOffice: null as Office | null
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

  // Derived state
  isDirty = $derived(hasNewOfficeFormData(this.state.formData));
  isValid = $derived(validateNewOfficeForm(this.state.formData).length === 0);
  canSubmit = $derived(
    this.isDirty && 
    this.isValid &&
    !this.state.formState.loading && 
    !this.state.formState.saving
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

  // Clear messages
  clearMessages() {
    this.state.formState.error = null;
    this.state.formState.success = null;
  }

  // Save new office
  async saveNewOffice(): Promise<Office | null> {
    if (!this.canSubmit) {
      return null;
    }

    this.state.formState.saving = true;
    this.state.formState.error = null;
    this.state.formState.success = null;

    try {
      // Transform form data to API format
      const apiData = transformNewOfficeFormToApiRequest(this.state.formData);
      
      // Call API
      const response = await api.offices.createOffice(apiData as CreateOfficeRequest);

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
    this.state.formData = {
      name: office.name || '',
      cnpj: office.cnpj || '',
      society: office.society || '',
      accounting_type: office.accounting_type || '',
      foundation: office.foundation || '',
      site: office.site || ''
    };
    this.state.formState.isDirty = false;
  }

  // Get validation errors
  getValidationErrors(): string[] {
    return validateNewOfficeForm(this.state.formData);
  }
}

// Export singleton instance
export const newOfficeStore = new NewOfficeStore();