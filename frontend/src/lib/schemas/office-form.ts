/**
 * Office Form Data Schemas and Utilities
 *
 * This file contains form data structures, default values, and utilities
 * for office forms, following the Svelte 5 reactive pattern.
 */

import type { Office, CreateOfficeRequest, Compensation } from '../api/types/office.types';

// Phone form structure
export interface PhoneFormData {
  phone_number: string;
  id?: number;
}

// Email form structure
export interface EmailFormData {
  email: string;
  id?: number;
}

// Address form structure
export interface AddressFormData {
  street: string;
  number: string;
  complement?: string;
  neighborhood: string;
  city: string;
  state: string;
  zip_code: string;
  address_type: 'main' | 'secondary';
  id?: number;
}

// Bank account form structure
export interface BankAccountFormData {
  bank_name: string;
  bank_number?: string;
  type_account: string;
  agency: string;
  account: string;
  operation?: string;
  pix?: string;
  id?: number;
}

// Partner/Lawyer association structure
export interface PartnerFormData {
  lawyer_id: string | number; // UserProfile ID (for backward compatibility)
  user_id?: string | number; // Actual User ID (for backend)
  lawyer_name: string;
  partnership_type: string;
  ownership_percentage: number;
  is_managing_partner: boolean;
  pro_labore_amount: number;
}

// Compensation form structure (matches API type)
export interface CompensationFormData {
  compensation_type: 'pro_labore' | 'salary';
  amount: number;
  payment_frequency: 'monthly' | 'weekly' | 'annually';
  effective_date: string; // YYYY-MM-DD format
  notes?: string;
  id?: number;
}

// User office attributes for API
export interface UserOfficeAttributes {
  user_id: number | string;
  partnership_type: string;
  partnership_percentage: string;
  is_administrator: boolean;
  compensations_attributes?: CompensationFormData[];
  _destroy: boolean;
}

// Main office form data structure
export interface OfficeFormData {
  // Basic information
  name: string;
  cnpj: string;
  society: 'individual' | 'company' | 'simple' | 'ltda' | 'eireli';
  foundation: string;
  site: string;
  accounting_type: 'simple' | 'presumed' | 'real' | 'mei';

  // OAB information
  oab_id: string;
  oab_status: string;
  oab_inscricao: string;
  oab_link: string;

  // Financial information
  quote_value: string;
  number_of_quotes: string;
  proportional: boolean;

  // CEP field (separate from address)
  zip_code: string;

  // Nested attributes
  phones_attributes: PhoneFormData[];
  emails_attributes: EmailFormData[];
  addresses_attributes: AddressFormData[];
  bank_accounts_attributes: BankAccountFormData[];

  // Files
  logo?: File | null;
  social_contracts?: File[];

  // Partnership data (not sent directly, processed separately)
  partners?: PartnerFormData[];
  profit_distribution?: 'proportional' | 'disproportional';
  create_social_contract?: boolean;
  partners_with_pro_labore?: boolean;
}

// Office form state management
export interface OfficeFormState {
  loading: boolean;
  error: string | null;
  success: string | null;
  isDirty: boolean;
}

/**
 * Create default office form data
 */
export const createDefaultOfficeFormData = (): OfficeFormData => ({
  // Basic information
  name: '',
  cnpj: '',
  society: 'individual',
  foundation: '',
  site: '',
  accounting_type: 'simple',

  // OAB information
  oab_id: '',
  oab_status: '',
  oab_inscricao: '',
  oab_link: '',

  // Financial information
  quote_value: '',
  number_of_quotes: '',
  proportional: true,

  // CEP field
  zip_code: '',

  // Nested attributes with at least one empty item
  phones_attributes: [{ phone_number: '' }],
  emails_attributes: [{ email: '' }],
  addresses_attributes: [
    {
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      address_type: 'main'
    }
  ],
  bank_accounts_attributes: [
    {
      bank_name: '',
      type_account: 'Corrente',
      agency: '',
      account: '',
      operation: '',
      pix: ''
    }
  ],

  // Partnership data
  partners: [
    {
      lawyer_id: '',
      lawyer_name: '',
      partnership_type: '',
      ownership_percentage: 100,
      is_managing_partner: false,
      pro_labore_amount: 0
    }
  ],
  profit_distribution: 'proportional',
  create_social_contract: false,
  partners_with_pro_labore: true
});

/**
 * Create default partner data
 */
export const createDefaultPartner = (isFirst: boolean = false): PartnerFormData => ({
  lawyer_id: '',
  lawyer_name: '',
  partnership_type: '',
  ownership_percentage: isFirst ? 100 : 0,
  is_managing_partner: false,
  pro_labore_amount: 0
});

/**
 * Transform form data to API request format
 * Properly serializes nested attributes and handles FormData when files are present
 */
export function transformToApiRequest(
  formData: OfficeFormData,
  partners: PartnerFormData[],
  profitDistribution: string,
  createSocialContract: boolean,
  partnersWithProLabore: boolean,
  isFormData: boolean = false
): CreateOfficeRequest | FormData {
  // Filter out empty nested attributes
  const filteredPhones = formData.phones_attributes.filter((p) => p.phone_number?.trim());
  const filteredEmails = formData.emails_attributes.filter((e) => e.email?.trim());
  const filteredAddresses = formData.addresses_attributes.filter((a) => a.street?.trim());
  const filteredBankAccounts = formData.bank_accounts_attributes.filter((b) => b.bank_name?.trim());

  // Transform partners to user_offices_attributes
  const userOfficesAttributes: UserOfficeAttributes[] = partners
    .filter((p) => p.lawyer_id && p.partnership_type)
    .map((p) => ({
      user_id: typeof p.lawyer_id === 'string' ? parseInt(p.lawyer_id) : p.lawyer_id,
      partnership_type: p.partnership_type,
      partnership_percentage: p.ownership_percentage.toString(),
      pro_labore_amount: p.pro_labore_amount,
      is_managing_partner: p.is_managing_partner || false,
      _destroy: false
    }));

  // Build the request payload
  const payload: Record<string, unknown> = {
    name: formData.name,
    cnpj: formData.cnpj,
    society: formData.society,
    foundation: formData.foundation,
    site: formData.site,
    accounting_type: formData.accounting_type,
    oab_id: formData.oab_id,
    oab_status: formData.oab_status,
    oab_inscricao: formData.oab_inscricao,
    oab_link: formData.oab_link,
    quote_value: formData.quote_value ? parseFloat(formData.quote_value) : undefined,
    number_of_quotes: formData.number_of_quotes ? parseInt(formData.number_of_quotes) : undefined,
    proportional: formData.proportional,

    // Add zip_code if present
    ...(formData.zip_code && { zip_code: formData.zip_code }),

    // Nested attributes
    phones_attributes: filteredPhones,
    addresses_attributes: filteredAddresses,
    emails_attributes: filteredEmails,
    bank_accounts_attributes: filteredBankAccounts,

    // Partnership data
    user_offices_attributes: userOfficesAttributes,
    profit_distribution: profitDistribution,
    create_social_contract: createSocialContract,
    partners_with_pro_labore: partnersWithProLabore
  };

  // If we have files, use FormData
  if (isFormData || formData.logo) {
    const formDataPayload = new FormData();

    // Add logo if present
    if (formData.logo) {
      formDataPayload.append('office[logo]', formData.logo);
    }

    // Add all scalar fields
    Object.entries(payload).forEach(([key, value]) => {
      if (
        value !== undefined &&
        value !== null &&
        !Array.isArray(value) &&
        typeof value !== 'object'
      ) {
        formDataPayload.append(`office[${key}]`, String(value));
      }
    });

    // Add nested attributes as JSON strings
    if (filteredPhones.length > 0) {
      formDataPayload.append('office[phones_attributes]', JSON.stringify(filteredPhones));
    }
    if (filteredAddresses.length > 0) {
      formDataPayload.append('office[addresses_attributes]', JSON.stringify(filteredAddresses));
    }
    if (filteredEmails.length > 0) {
      formDataPayload.append('office[emails_attributes]', JSON.stringify(filteredEmails));
    }
    if (filteredBankAccounts.length > 0) {
      formDataPayload.append(
        'office[bank_accounts_attributes]',
        JSON.stringify(filteredBankAccounts)
      );
    }
    if (userOfficesAttributes.length > 0) {
      formDataPayload.append(
        'office[user_offices_attributes]',
        JSON.stringify(userOfficesAttributes)
      );
    }

    return formDataPayload;
  }

  return payload as CreateOfficeRequest;
}

/**
 * Transform Office data from API to form data
 */
export function transformFromOffice(office: Office): OfficeFormData {
  return {
    name: office.name || '',
    cnpj: office.cnpj || '',
    society: office.society || 'individual',
    foundation: office.foundation || '',
    site: office.site || '',
    accounting_type: office.accounting_type || 'simple',
    oab_id: office.oab_id || '',
    oab_status: office.oab_status || '',
    oab_inscricao: office.oab_inscricao || '',
    oab_link: office.oab_link || '',
    quote_value: office.quote_value?.toString() || '',
    number_of_quotes: office.number_of_quotes?.toString() || '',
    proportional: office.proportional ?? true,

    phones_attributes:
      office.phones?.length > 0
        ? office.phones.map((p) => ({
            phone_number: p.phone_number,
            id: p.id
          }))
        : [{ phone_number: '' }],

    addresses_attributes:
      office.addresses?.length > 0
        ? office.addresses.map((a) => ({
            street: a.street || '',
            number: a.number || '',
            complement: a.complement || '',
            neighborhood: a.neighborhood || '',
            city: a.city || '',
            state: a.state || '',
            zip_code: a.zip_code || '',
            address_type: a.address_type || 'main',
            id: a.id
          }))
        : [
            {
              street: '',
              number: '',
              complement: '',
              neighborhood: '',
              city: '',
              state: '',
              zip_code: '',
              address_type: 'main'
            }
          ],

    emails_attributes:
      office.emails?.length > 0
        ? office.emails.map((e) => ({
            email: e.email,
            id: e.id
          }))
        : [{ email: '' }],

    bank_accounts_attributes:
      office.bank_accounts?.length > 0
        ? office.bank_accounts.map((b) => ({
            bank_name: b.bank_name || '',
            bank_number: b.bank_number,
            type_account: b.type_account || 'Corrente',
            agency: b.agency || '',
            account: b.account || '',
            operation: b.operation || '',
            pix: b.pix || '',
            id: b.id
          }))
        : [
            {
              bank_name: '',
              type_account: 'Corrente',
              agency: '',
              account: '',
              operation: '',
              pix: ''
            }
          ]
  };
}

/**
 * Validate form data before submission
 */
export function validateOfficeForm(
  formData: OfficeFormData,
  partners: PartnerFormData[]
): string[] {
  const errors: string[] = [];

  // Required fields validation
  if (!formData.name?.trim()) {
    errors.push('Nome do escritório é obrigatório');
  }

  if (!formData.cnpj?.trim()) {
    errors.push('CNPJ é obrigatório');
  }

  // Partner validation
  const hasValidPartners = partners.some((p) => p.lawyer_id && p.partnership_type);
  if (partners.length > 0 && !hasValidPartners) {
    errors.push('Ao adicionar sócios, é necessário selecionar o advogado e definir a função');
  }

  // Percentage validation for multiple partners
  if (partners.length > 1) {
    const totalPercentage = partners.reduce((sum, p) => sum + (p.ownership_percentage || 0), 0);
    if (totalPercentage !== 100) {
      errors.push(`A soma das participações deve ser 100% (atual: ${totalPercentage}%)`);
    }
  }

  return errors;
}

/**
 * Calculate total ownership percentage
 */
export function calculateTotalPercentage(partners: PartnerFormData[]): number {
  return partners.reduce((total, partner) => total + (partner.ownership_percentage || 0), 0);
}

/**
 * Check if total percentage exceeds 100%
 */
export function isOverPercentage(partners: PartnerFormData[]): boolean {
  return calculateTotalPercentage(partners) > 100;
}

// Form storage key for draft persistence
export const OFFICE_FORM_STORAGE_KEY = 'office_form_draft';
