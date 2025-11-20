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

// Extend the form data type to include files
interface NewOfficeFormDataWithFiles extends NewOfficeFormData {
  logoFile: File | null;
  contractFiles: File[];
}

class NewOfficeStore {
  // Private state using Svelte 5 runes
  private state = $state({
    formData: {
      ...createDefaultNewOfficeFormData(),
      logoFile: null,
      contractFiles: []
    } as NewOfficeFormDataWithFiles,
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

  isQuoteConfigValid = $derived(
    this.state.formData.quote_value > 0 &&
    this.state.formData.number_of_quotes > 0
  );

  totalCapital = $derived(
    this.state.formData.quote_value * this.state.formData.number_of_quotes
  );

  // Update form field
  updateField<K extends keyof NewOfficeFormDataWithFiles>(
    field: K,
    value: NewOfficeFormDataWithFiles[K]
  ) {
    this.state.formData[field] = value;
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  // Update entire form data
  updateFormData(data: Partial<NewOfficeFormDataWithFiles>) {
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

  // Reset form
  resetForm() {
    this.state.formData = {
      ...createDefaultNewOfficeFormData(),
      logoFile: null,
      contractFiles: []
    };
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

  // Save new office and handle uploads
  async saveNewOffice(): Promise<Office | null> {
    if (!this.canSubmit) {
      this.state.formState.error = 'Formulário inválido ou incompleto';
      return null;
    }

    this.state.formState.saving = true;
    this.clearMessages();

    let createdOffice: Office | null = null;

    try {
      // 1. Create the office first
      const apiData = transformNewOfficeFormToApiRequest(this.state.formData);
      const response = await api.offices.createOffice(apiData);

      if (!response.success || !response.data) {
        this.state.formState.error = response.message || 'Erro ao criar escritório';
        return null;
      }

      createdOffice = response.data;
      this.state.currentOffice = createdOffice;
      this.state.formState.success = 'Escritório criado com sucesso!';

      // 2. If office is created, proceed to upload files
      const officeId = createdOffice.id;
      const { logoFile, contractFiles } = this.state.formData;
      const uploadPromises: Promise<any>[] = [];

      if (logoFile) {
        this.state.formState.success = 'Escritório criado! Enviando logo...';
        uploadPromises.push(api.offices.uploadOfficeLogo(officeId, logoFile));
      }

      if (contractFiles.length > 0) {
        this.state.formState.success = 'Escritório criado! Enviando contratos...';
        uploadPromises.push(api.offices.uploadOfficeContracts(officeId, contractFiles));
      }

      if (uploadPromises.length > 0) {
        const uploadResults = await Promise.all(uploadPromises);
        const allUploadsSuccessful = uploadResults.every(res => res.success);

        if (allUploadsSuccessful) {
          this.state.formState.success = 'Escritório e arquivos enviados com sucesso!';
        } else {
          this.state.formState.error = 'Escritório criado, mas houve um erro ao enviar um ou mais arquivos.';
        }
      }
      
      this.state.formState.isDirty = false;
      return createdOffice;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro inesperado';
      if (createdOffice) {
        this.state.formState.error = `Escritório criado, mas falha no envio de arquivos: ${errorMessage}`;
      } else {
        this.state.formState.error = `Erro ao criar escritório: ${errorMessage}`;
      }
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