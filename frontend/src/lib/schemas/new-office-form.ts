/**
 * New Office Form Schema - Complete implementation for office creation
 * Includes all fields required for the API request
 */

import type { 
  CreateOfficeRequest, 
  Society, 
  AccountingType,
  PartnerFormData,
  UserOffice,
  Compensation,
  CompensationType,
  PaymentFrequency 
} from '../api/types/office.types';
import { validateCNPJOptional } from '../validation/cnpj';

// Address data structure
export interface AddressData {
  street: string;
  number: string;
  complement: string;
  neighborhood: string;
  city: string;
  state: string;
  zip_code: string;
  address_type: string;
}

// Bank account data structure
export interface BankAccountData {
  bank_name: string;
  bank_number: string;
  type_account: string;
  agency: string;
  account: string;
  operation: string;
  pix: string;
}

// New office form data - Complete structure
export interface NewOfficeFormData {
  // Basic Information
  name: string;
  cnpj: string;
  society: string;
  accounting_type: string;
  foundation: string;
  site?: string;
  
  // Quote Configuration
  proportional: boolean;
  quote_value: number;
  number_of_quotes: number;
  
  // OAB Information
  oab_id?: string;
  oab_status?: string;
  oab_inscricao?: string;
  oab_link?: string;
  
  // Address
  address?: AddressData;
  
  // Email (separate from site)
  email?: string;
  
  // Phones
  phones: string[];
  
  // Bank Account
  bank_account?: BankAccountData;
  
  // Partners
  partners: PartnerFormData[];
  partnersWithProLabore: boolean;
  
  // Options
  create_social_contract: boolean;
  team_id?: number;
}

// Dynamic validation configuration
export interface FieldValidationRule {
  required?: boolean;
  customValidator?: (value: any) => string | null;
}

export interface FormValidationConfig {
  [fieldName: string]: FieldValidationRule;
}

// New office form state for UI feedback
export interface NewOfficeFormState {
  loading: boolean;
  saving: boolean;
  error: string | null;
  success: string | null;
  isDirty: boolean;
}

/**
 * Create default new office form data
 */
export function createDefaultNewOfficeFormData(): NewOfficeFormData {
  return {
    name: '',
    cnpj: '',
    society: '',
    accounting_type: '',
    foundation: '',
    site: '',
    email: '',
    proportional: true,
    quote_value: 0,
    number_of_quotes: 0,
    address: {
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      address_type: 'main'
    },
    oab_id: '',
    oab_status: '',
    oab_inscricao: '',
    oab_link: '',
    phones: [''], // Start with one empty phone field
    bank_account: {
      bank_name: '',
      bank_number: '',
      type_account: '',
      agency: '',
      account: '',
      operation: '',
      pix: ''
    },
    partners: [],
    partnersWithProLabore: false,
    create_social_contract: false,
    team_id: undefined
  };
}

/**
 * Transform partner form data to user office attributes for API
 */
function transformPartnerToUserOffice(partner: PartnerFormData): Omit<UserOffice, 'id'> {
  console.log('🔄 [transformPartnerToUserOffice] Input partner:', partner);
  
  // Extract user_id from lawyer_id (handle both string and object cases)
  let userId: number;
  if (typeof partner.lawyer_id === 'string') {
    userId = parseInt(partner.lawyer_id);
  } else if (typeof partner.lawyer_id === 'object' && partner.lawyer_id !== null && 'id' in partner.lawyer_id) {
    userId = parseInt((partner.lawyer_id as any).id);
  } else {
    console.error('❌ Invalid lawyer_id format:', partner.lawyer_id);
    throw new Error('Invalid lawyer_id format in partner data');
  }
  
  const userOffice: Omit<UserOffice, 'id'> = {
    user_id: userId,
    partnership_type: partner.partnership_type as any,
    partnership_percentage: partner.ownership_percentage,
    is_administrator: partner.is_managing_partner,
    entry_date: partner.entry_date || new Date().toISOString().split('T')[0]
  };

  // Add compensations if any
  const compensations: Omit<Compensation, 'id'>[] = [];
  
  // Add pro-labore if exists
  if (partner.pro_labore_amount && partner.pro_labore_amount > 0) {
    compensations.push({
      compensation_type: 'pro_labore' as CompensationType,
      amount: partner.pro_labore_amount,
      payment_frequency: 'monthly' as PaymentFrequency,
      effective_date: new Date().toISOString().split('T')[0],
      notes: 'Pró-labore do sócio administrador'
    });
  }
  
  // Add salary if exists
  if (partner.salary_amount && partner.salary_amount > 0) {
    compensations.push({
      compensation_type: 'salary' as CompensationType,
      amount: partner.salary_amount,
      payment_frequency: partner.payment_frequency || 'monthly' as PaymentFrequency,
      effective_date: partner.salary_start_date || new Date().toISOString().split('T')[0],
      end_date: partner.salary_end_date,
      notes: 'Salário do sócio'
    });
  }
  
  if (compensations.length > 0) {
    userOffice.compensations_attributes = compensations;
  }
  
  console.log('✅ [transformPartnerToUserOffice] Output userOffice:', userOffice);
  return userOffice;
}

/**
 * Transform new office form data to API request format
 */
export function transformNewOfficeFormToApiRequest(formData: NewOfficeFormData): CreateOfficeRequest {
  const apiData: CreateOfficeRequest = {
    name: formData.name.trim(),
    proportional: formData.proportional,
    quote_value: formData.quote_value,
    number_of_quotes: formData.number_of_quotes,
    create_social_contract: formData.create_social_contract
  };

  // Add optional fields
  if (formData.cnpj?.trim()) {
    apiData.cnpj = formData.cnpj.replace(/\D/g, ''); // Remove CNPJ formatting
  }

  if (formData.society) {
    apiData.society = formData.society as Society;
  }

  if (formData.accounting_type) {
    apiData.accounting_type = formData.accounting_type as AccountingType;
  }

  if (formData.foundation?.trim()) {
    apiData.foundation = formData.foundation.trim();
  }

  if (formData.site?.trim()) {
    apiData.site = formData.site.trim();
  }

  if (formData.team_id) {
    apiData.team_id = formData.team_id;
  }

  // Add OAB fields
  if (formData.oab_id?.trim()) {
    apiData.oab_id = formData.oab_id.trim();
  }

  if (formData.oab_status?.trim()) {
    apiData.oab_status = formData.oab_status.trim();
  }

  if (formData.oab_inscricao?.trim()) {
    apiData.oab_inscricao = formData.oab_inscricao.trim();
  }

  if (formData.oab_link?.trim()) {
    apiData.oab_link = formData.oab_link.trim();
  }

  // Add address
  if (formData.address) {
    const hasAddressData = Object.values(formData.address).some((v) => v?.toString().trim());
    if (hasAddressData) {
      apiData.addresses_attributes = [{
        street: formData.address.street,
        number: formData.address.number,
        complement: formData.address.complement,
        neighborhood: formData.address.neighborhood,
        city: formData.address.city,
        state: formData.address.state,
        zip_code: formData.address.zip_code,
        address_type: formData.address.address_type || 'main'
      }];
    }
  }

  // Add phones
  if (formData.phones && formData.phones.length > 0) {
    apiData.phones_attributes = formData.phones
      .filter(phone => phone.trim())
      .map(phone => ({ phone_number: phone.trim() }));
  }

  // Add partners as user offices
  if (formData.partners && formData.partners.length > 0) {
    console.log('🔄 [transformNewOfficeFormToApiRequest] Transforming partners:', formData.partners);
    apiData.user_offices_attributes = formData.partners.map(transformPartnerToUserOffice);
    console.log('✅ [transformNewOfficeFormToApiRequest] user_offices_attributes:', apiData.user_offices_attributes);
  }

  return apiData;
}

/**
 * Check if new office form has any data (for dirty state)
 */
export function hasNewOfficeFormData(formData: NewOfficeFormData): boolean {
  const hasAddressData = formData.address
    ? Object.values(formData.address).some((v) => v?.toString().trim())
    : false;

  return !!(
    formData.name?.trim() ||
    formData.cnpj?.trim() ||
    formData.society ||
    formData.accounting_type ||
    formData.foundation?.trim() ||
    formData.site?.trim() ||
    formData.quote_value > 0 ||
    formData.number_of_quotes > 0 ||
    formData.phones.length > 0 ||
    formData.partners.length > 0 ||
    hasAddressData
  );
}

/**
 * Create default validation configuration
 */
export function createDefaultValidationConfig(): FormValidationConfig {
  return {
    name: { required: true },
    cnpj: { required: false, customValidator: validateCNPJOptional },
    society: { required: false },
    accounting_type: { required: false },
    foundation: { required: false },
    site: { required: false },
    quote_value: { required: true },
    number_of_quotes: { required: true }
  };
}

/**
 * Validate new office form data with dynamic configuration
 */
export function validateNewOfficeForm(
  formData: NewOfficeFormData,
  validationConfig: FormValidationConfig = createDefaultValidationConfig()
): string[] {
  const errors: string[] = [];

  // Validate basic fields
  for (const [fieldName, rules] of Object.entries(validationConfig)) {
    const fieldValue = formData[fieldName as keyof NewOfficeFormData];

    // Check required validation
    if (rules.required) {
      if (fieldName === 'quote_value' || fieldName === 'number_of_quotes') {
        if (!fieldValue || Number(fieldValue) <= 0) {
          const fieldLabel = getFieldLabel(fieldName);
          errors.push(`${fieldLabel} deve ser maior que zero`);
          continue;
        }
      } else if (!fieldValue || !String(fieldValue).trim()) {
        const fieldLabel = getFieldLabel(fieldName);
        errors.push(`${fieldLabel} é obrigatório`);
        continue;
      }
    }

    // Apply custom validator if provided and field has value
    if (rules.customValidator && fieldValue) {
      const customError = rules.customValidator(fieldValue);
      if (customError) {
        errors.push(customError);
      }
    }
  }

  // Validate partners if quote configuration is set
  if (formData.quote_value > 0 && formData.number_of_quotes > 0) {
    if (formData.partners.length === 0) {
      errors.push('Adicione pelo menos um sócio ao quadro societário');
    } else {
      // Validate total ownership percentage
      const totalPercentage = formData.partners.reduce(
        (sum, partner) => sum + (partner.ownership_percentage || 0),
        0
      );
      
      if (totalPercentage !== 100) {
        errors.push(`A soma das participações deve ser 100% (atual: ${totalPercentage}%)`);
      }
      
      // Validate each partner
      formData.partners.forEach((partner, index) => {
        if (!partner.lawyer_id) {
          errors.push(`Selecione o advogado para o sócio ${index + 1}`);
        }
        if (!partner.partnership_type) {
          errors.push(`Defina o tipo de sociedade para o sócio ${index + 1}`);
        }
        if (!partner.ownership_percentage || partner.ownership_percentage <= 0) {
          errors.push(`Defina a participação para o sócio ${index + 1}`);
        }
      });
    }
  }

  return errors;
}

/**
 * Get user-friendly field labels
 */
function getFieldLabel(fieldName: string): string {
  const labels: Record<string, string> = {
    name: 'Nome do escritório',
    cnpj: 'CNPJ',
    society: 'Tipo de sociedade',
    accounting_type: 'Enquadramento contábil',
    foundation: 'Data de fundação',
    site: 'Site',
    address: 'Endereço',
    quote_value: 'Valor da cota',
    number_of_quotes: 'Número de cotas',
    proportional: 'Distribuição proporcional',
    partners: 'Sócios'
  };
  return labels[fieldName] || fieldName;
}

/**
 * Check if new office form is valid with dynamic configuration
 */
export function isNewOfficeFormValid(
  formData: NewOfficeFormData,
  validationConfig?: FormValidationConfig
): boolean {
  return validateNewOfficeForm(formData, validationConfig).length === 0;
}