/**
 * Customer API Types
 * Types for customer related API operations
 */

export interface Customer {
  id: number;
  email?: string;
  access_email?: string;
  status: CustomerStatus;
  confirmed_at?: string | null;
  confirmed?: boolean;
  deleted?: boolean;
  created_by_id?: number;
  profile_customer_id?: number | null;
  profile_customer?: ProfileCustomer;

  // Timestamps
  created_at?: string;
  updated_at?: string;
  deleted_at?: string | null;
}

export type CustomerStatus = 'active' | 'inactive' | 'deceased';
export type CustomerType = 'physical_person' | 'legal_person' | 'representative' | 'counter';
export type Gender = 'male' | 'female' | 'other';
export type Nationality = 'brazilian' | 'foreigner';
export type CivilStatus = 'single' | 'married' | 'divorced' | 'widower' | 'union';
export type Capacity = 'able' | 'relatively' | 'unable';

export interface ProfileCustomer {
  id: string;
  type?: string;
  name?: string;
  deleted?: boolean;
  customer_id?: number;
  customer_type?: CustomerType;
  last_name?: string;
  status?: CustomerStatus;

  attributes: {
    id?: any;
    name?: string;
    customer_type: string;
    status?: number;
    customer_id?: number;
    last_name?: string;
    cpf?: string;
    rg?: string;
    birth?: string;
    gender?: string;
    cnpj?: string;
    civil_status?: string;
    nationality?: any;
    capacity?: string;
    profession?: string;
    company?: string;
    number_benefit?: string;
    nit?: string;
    mother_name?: string;
    default_phone?: string;
    default_email?: string;
    data?: any;
    representor?: any;
    issue_documents?: boolean;
    access_email?: string;
    cep?: any;
    street?: any;
    state?: any;
    city?: any;
    number?: any;
    description?: any;
    neighborhood?: any;
    represent_attributes?: any;
    profile_customer_id?: number;
    represent?: any;
    deleted?: boolean;
  };

  relationships?: {
    addresses?: any[];
    bank_accounts?: any[];
    emails?: any[];
    phones?: any[];
  };

  // Timestamps
  created_at?: string;
  updated_at?: string;
  deleted_at?: string | null;
}

export interface CreateCustomerRequest {
  email: string;
  access_email?: string;
  password: string;
  password_confirmation: string;
  status?: CustomerStatus;
}

export interface UpdateCustomerRequest {
  email?: string;
  access_email?: string;
  password?: string;
  password_confirmation?: string;
  status?: CustomerStatus;
}

export interface CreateProfileCustomerRequest {
  customer_type: CustomerType;
  name: string;
  last_name?: string;
  status?: CustomerStatus;
  customer_id?: number;

  // Personal information
  cpf?: string;
  cnpj?: string;
  rg?: string;
  birth?: string;
  gender?: Gender;
  nationality?: Nationality;
  civil_status?: CivilStatus;
  capacity?: Capacity;
  profession?: string;
  mother_name?: string;

  // Professional information
  company?: string;
  accountant_id?: number;

  // Social security
  number_benefit?: string;
  nit?: string;
  inss_password?: string;
}

export interface UpdateProfileCustomerRequest {
  customer_type?: CustomerType;
  name?: string;
  last_name?: string;
  status?: CustomerStatus;

  // Personal information
  cpf?: string;
  cnpj?: string;
  rg?: string;
  birth?: string;
  gender?: Gender;
  nationality?: Nationality;
  civil_status?: CivilStatus;
  capacity?: Capacity;
  profession?: string;
  mother_name?: string;

  // Professional information
  company?: string;
  accountant_id?: number;

  // Social security
  number_benefit?: string;
  nit?: string;
  inss_password?: string;
}

export interface CustomersListResponse {
  success: boolean;
  data: Customer[];
  meta?: {
    total_count: number;
  };
  message?: string;
}

export interface CustomerResponse {
  success: boolean;
  data: Customer;
  message?: string;
}

export interface CreateCustomerResponse {
  success: boolean;
  data: Customer;
  message?: string;
  errors?: Record<string, string>; // Field-specific errors from API
}

export interface UpdateCustomerResponse {
  success: boolean;
  data: Customer;
  message?: string;
  errors?: Record<string, string>; // Field-specific errors from API
}

export interface DeleteCustomerResponse {
  success: boolean;
  message?: string;
}

export interface ProfileCustomersListResponse {
  success: boolean;
  data: ProfileCustomer[];
  meta?: {
    total_count: number;
  };
  message?: string;
}

export interface ProfileCustomerResponse {
  success: boolean;
  data: ProfileCustomer;
  message?: string;
}

export interface CreateProfileCustomerResponse {
  success: boolean;
  data: ProfileCustomer;
  message?: string;
}

export interface UpdateProfileCustomerResponse {
  success: boolean;
  data: ProfileCustomer;
  message?: string;
}

export interface DeleteProfileCustomerResponse {
  success: boolean;
  message?: string;
}

// JSON:API response types
export interface JsonApiCustomerData {
  id: string;
  type: 'customer';
  attributes: {
    access_email: string;
    created_by_id: number;
    confirmed_at: string | null;
    profile_customer_id: number | null;
    status: CustomerStatus;
    created_at: string;
    confirmed: boolean;
    deleted: boolean;
  };
  relationships?: {
    teams?: {
      data: Array<{
        id: string;
        type: 'team';
      }>;
    };
    profile_customer?: {
      data: null | {
        id: string;
        type: 'profile_customer';
      };
    };
  };
}

export interface JsonApiCustomerResponse {
  success?: boolean;
  message?: string;
  data: JsonApiCustomerData;
  included?: any[];
}

export interface JsonApiCustomersListResponse {
  success?: boolean;
  message?: string;
  data: JsonApiCustomerData[];
  included?: any[];
  meta?: {
    total_count: number;
  };
}

// Customer Portal Types
export interface CustomerLoginRequest {
  email: string;
  password: string;
}

export interface CustomerLoginResponse {
  token: string;
  full_name: string;
}
