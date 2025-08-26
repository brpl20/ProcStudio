/**
 * Customer Form Data Schemas
 * 
 * This file contains form data structures and default values for customer forms.
 * Uses existing customer types for consistency with the API.
 */

import type { 
  CustomerType, 
  Gender, 
  Nationality, 
  CivilStatus, 
  Capacity,
  CustomerStatus
} from '../api/types/customer.types';

// Address form structure
export interface AddressFormData {
  description: string;
  zip_code: string;
  street: string;
  city: string;
  number: string;
  neighborhood: string;
  state: string;
}

// Phone form structure
export interface PhoneFormData {
  phone_number: string;
}

// Email form structure
export interface EmailFormData {
  email: string;
}

// Bank account form structure
export interface BankAccountFormData {
  bank_name: string;
  type_account: 'Corrente' | 'Poupança';
  agency: string;
  account: string;
  operation: string;
  pix: string;
}

// Customer attributes for login
export interface CustomerAttributesFormData {
  email: string;
  password: string;
  password_confirmation: string;
}

// Main customer form data structure
export interface CustomerFormData {
  customer_type: CustomerType;
  name: string;
  last_name: string;
  status: CustomerStatus;
  cpf: string;
  rg: string;
  birth: string;
  gender: Gender;
  civil_status: CivilStatus;
  nationality: Nationality;
  capacity: Capacity;
  profession: string;
  mother_name: string;
  deceased_at: string;
  number_benefit: string;
  nit: string;
  inss_password: string;
  customer_attributes: CustomerAttributesFormData;
  addresses_attributes: AddressFormData[];
  phones_attributes: PhoneFormData[];
  emails_attributes: EmailFormData[];
  bank_accounts_attributes: BankAccountFormData[];
}

// Multi-step form state
export interface CustomerFormState {
  currentStep: number;
  totalSteps: number;
  showGuardianForm: boolean;
  useSameAddress: boolean;
  useSameBankAccount: boolean;
  uploadedFiles: File[];
  formIsDirty: boolean;
}

// Default form data
export const createDefaultCustomerFormData = (): CustomerFormData => ({
  customer_type: 'physical_person',
  name: '',
  last_name: '',
  status: 'active',
  cpf: '',
  rg: '',
  birth: '',
  gender: 'male',
  civil_status: 'single',
  nationality: 'brazilian',
  capacity: 'able',
  profession: '',
  mother_name: '',
  deceased_at: '',
  number_benefit: '',
  nit: '',
  inss_password: '',
  customer_attributes: {
    email: '',
    password: '',
    password_confirmation: ''
  },
  addresses_attributes: [
    {
      description: 'Home Address',
      zip_code: '',
      street: '',
      city: '',
      number: '',
      neighborhood: '',
      state: ''
    }
  ],
  phones_attributes: [
    {
      phone_number: ''
    }
  ],
  emails_attributes: [
    {
      email: ''
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
  ]
});

// Default guardian form data (same structure as customer)
export const createDefaultGuardianFormData = (): CustomerFormData => ({
  customer_type: 'physical_person',
  name: '',
  last_name: '',
  status: 'active',
  cpf: '',
  rg: '',
  birth: '',
  gender: 'male',
  civil_status: 'single',
  nationality: 'brazilian',
  capacity: 'able',
  profession: '',
  mother_name: '',
  deceased_at: '',
  number_benefit: '',
  nit: '',
  inss_password: '',
  customer_attributes: {
    email: '',
    password: '',
    password_confirmation: ''
  },
  addresses_attributes: [
    {
      description: 'Home Address',
      zip_code: '',
      street: '',
      city: '',
      number: '',
      neighborhood: '',
      state: ''
    }
  ],
  phones_attributes: [
    {
      phone_number: ''
    }
  ],
  emails_attributes: [
    {
      email: ''
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
  ]
});

// Default form state
export const createDefaultFormState = (): CustomerFormState => ({
  currentStep: 1,
  totalSteps: 2,
  showGuardianForm: false,
  useSameAddress: false,
  useSameBankAccount: false,
  uploadedFiles: [],
  formIsDirty: false
});

// Form storage key
export const FORM_STORAGE_KEY = 'customer_form_draft';

// Helper function to check if capacity requires guardian
export const requiresGuardian = (capacity: Capacity): boolean => {
  return capacity === 'unable' || capacity === 'relatively';
};

// Helper function to get guardian label based on capacity
export const getGuardianLabel = (capacity: Capacity): string => {
  return capacity === 'unable' ? 'Representante Legal' : 'Assistente Legal';
};

// Helper function to get relationship type
export const getRelationshipType = (capacity: Capacity): 'representation' | 'assistance' => {
  return capacity === 'unable' ? 'representation' : 'assistance';
};