
import api from '../api';
import type { Office, PartnerFormData } from '../api/types/office.types';
import type { NewOfficeFormData, NewOfficeFormState, FormValidationConfig } from '../schemas/new-office-form';
import {
  createDefaultNewOfficeFormData,
  transformNewOfficeFormToApiRequest,
  hasNewOfficeFormData,
  validateNewOfficeForm,
  createDefaultValidationConfig
} from '../schemas/new-office-form';

class NewOfficeStore {
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

  updateField<K extends keyof NewOfficeFormData>(
    field: K,
    value: NewOfficeFormData[K]
  ) {
    this.state.formData[field] = value;
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  updateFormData(data: Partial<NewOfficeFormData>) {
    Object.assign(this.state.formData, data);
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  updatePartners(partners: PartnerFormData[]) {
    this.state.formData.partners = partners;
    this.state.formState.isDirty = this.isDirty;
    this.clearMessages();
  }

  addPartner(partner: PartnerFormData) {
    this.state.formData.partners = [...this.state.formData.partners, partner];
    this.state.formState.isDirty = this.isDirty;
  }

  removePartner(index: number) {
    this.state.formData.partners = this.state.formData.partners.filter((_, i) => i !== index);
    this.state.formState.isDirty = this.isDirty;
  }

  updatePartner(index: number, partner: PartnerFormData) {
    if (index >= 0 && index < this.state.formData.partners.length) {
      this.state.formData.partners[index] = partner;
      this.state.formState.isDirty = this.isDirty;
    }
  }

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

  setValidationConfig(config: FormValidationConfig) {
    this.state.validationConfig = config;
  }

  clearMessages() {
    this.state.formState.error = null;
    this.state.formState.success = null;
  }

  async saveNewOffice(): Promise<Office | null> {
    if (!this.canSubmit) {
      this.state.formState.error = 'Formulário inválido ou incompleto';
      return null;
    }

    this.state.formState.saving = true;
    this.state.formState.error = null;
    this.state.formState.success = null;

    try {
      const officeApiData = transformNewOfficeFormToApiRequest(this.state.formData);

      const formDataPayload = new FormData();

     
      formDataPayload.append('office_data', JSON.stringify(officeApiData));

      if (this.state.formData.logo_file) {
        formDataPayload.append('logo', this.state.formData.logo_file);
      }

      if (this.state.formData.social_contract_files.length > 0) {
        this.state.formData.social_contract_files.forEach((file) => {
          formDataPayload.append('social_contract_files[]', file);
        });
      }

   
      const response = await api.offices.createOffice(formDataPayload);

      if (response.success && response.data) {
        this.state.currentOffice = response.data;
        this.state.formState.success = 'Escritório criado com sucesso!';
        this.state.formState.isDirty = false;
        this.updateField('logo_file', null);
        this.updateField('social_contract_files', []);
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


  getValidationErrors(): string[] {
    return validateNewOfficeForm(this.state.formData, this.state.validationConfig);
  }
}

export const newOfficeStore = new NewOfficeStore();