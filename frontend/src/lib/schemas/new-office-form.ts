
import type { BankAccount, Address, Phone, CreateOfficeRequest, PartnerFormData } from '../api/types/office.types';


export interface NewOfficeFormData {
  name: string;
  cnpj: string;
  society: string;
  accounting_type: string;
  foundation: string;
  site: string;
  proportional: boolean;
  quote_value: number;
  number_of_quotes: number;
  oab_id: string;
  oab_status: string;
  oab_inscricao: string;
  oab_link: string;
  address: Address;
  phones: string[];
  email: string;
  bank_account: BankAccount;
  partners: PartnerFormData[];
  partnersWithProLabore: boolean;
  create_social_contract: boolean;

  logo_file: File | null;
  social_contract_files: File[];
}


export interface NewOfficeFormState {
  loading: boolean;
  saving: boolean;
  error: string | null;
  success: string | null;
  isDirty: boolean;
}

export interface FormValidationConfig {
  cnpjRequired: boolean;
}


export function createDefaultNewOfficeFormData(): NewOfficeFormData {
  return {
    name: '',
    cnpj: '',
    society: 'sociedade_individual',
    accounting_type: 'caixa',
    foundation: '',
    site: '',
    proportional: true,
    quote_value: 0,
    number_of_quotes: 0,
    oab_id: '',
    oab_status: 'regular',
    oab_inscricao: '',
    oab_link: '',
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
    phones: [''],
    email: '',
    bank_account: {
      bank_code: '',
      agency_number: '',
      agency_check_digit: '',
      account_number: '',
      account_check_digit: '',
      account_type: 'checking',
      pix_key_type: '',
      pix_key: ''
    },
    partners: [],
    partnersWithProLabore: false,
    create_social_contract: false,

    logo_file: null,
    social_contract_files: []
  };
}


export function createDefaultValidationConfig(): FormValidationConfig {
  return {
    cnpjRequired: true
  };
}


export function hasNewOfficeFormData(formData: NewOfficeFormData): boolean {
  const defaultData = createDefaultNewOfficeFormData();
  return (
    formData.name !== defaultData.name ||
    formData.cnpj !== defaultData.cnpj ||
    formData.email !== defaultData.email ||
    formData.phones.some(p => p !== '') ||
    formData.address.zip_code !== defaultData.address.zip_code ||
    formData.partners.length > 0 ||
    !!formData.logo_file ||
    formData.social_contract_files.length > 0
  );
}


export function validateNewOfficeForm(formData: NewOfficeFormData, config: FormValidationConfig): string[] {
  const errors: string[] = [];
  if (!formData.name) errors.push('O nome do escritório é obrigatório.');
  if (config.cnpjRequired && !formData.cnpj) errors.push('O CNPJ é obrigatório.');
  return errors;
}

export function transformNewOfficeFormToApiRequest(formData: NewOfficeFormData): CreateOfficeRequest {
  return {
    office: {
      name: formData.name,
      cnpj: formData.cnpj,
      society: formData.society,
      accounting_type: formData.accounting_type,
      foundation: formData.foundation,
      site: formData.site,
      proportional: formData.proportional,
      quote_value: formData.quote_value,
      number_of_quotes: formData.number_of_quotes,
      oab_id: formData.oab_id,
      oab_status: formData.oab_status,
      oab_inscricao: formData.oab_inscricao,
      oab_link: formData.oab_link,
      create_social_contract: formData.create_social_contract,
      addresses_attributes: [formData.address],
      phones_attributes: formData.phones.filter(p => p).map(p => ({ phone_number: p })),
      email: formData.email,
      bank_accounts_attributes: [formData.bank_account],
      user_offices_attributes: formData.partners.map(partner => ({
        user_id: partner.lawyer_id,
        partnership_type: partner.partnership_type,
        partnership_percentage: partner.ownership_percentage,
        is_administrator: partner.is_managing_partner,
        entry_date: partner.entry_date,
      })),
    }
  };
}

export function isNewOfficeFormValid(formData: NewOfficeFormData): boolean {
 
  const config = createDefaultValidationConfig();
  
  return validateNewOfficeForm(formData, config).length === 0;
}