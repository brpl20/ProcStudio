/**
 * Office API Types
 * Types for office related API operations
 */

import type { Work } from './work.types';

// Enums for Office
export type Society = 'individual' | 'company';
export type AccountingType = 'simple' | 'real_profit' | 'presumed_profit';
export type PartnershipType = 'socio' | 'associado' | 'colaborador';

// Nested Types
export interface Phone {
  id?: number;
  phone_number: string;
  _destroy?: boolean;
}

export interface Address {
  id?: number;
  street: string;
  number?: string;
  complement?: string;
  neighborhood?: string;
  city: string;
  state: string;
  zip_code: string;
  address_type?: string;
  _destroy?: boolean;
}

export interface Email {
  id?: number;
  email: string;
  _destroy?: boolean;
}

export interface BankAccount {
  id?: number;
  bank_name: string;
  type_account?: string;
  agency: string;
  account: string;
  operation?: string;
  pix?: string;
  _destroy?: boolean;
}

// Compensation interface
export type CompensationType = 'pro_labore' | 'salary';
export type PaymentFrequency = 'monthly' | 'quarterly' | 'semi_annually' | 'annually';

export interface Compensation {
  id?: number;
  compensation_type: CompensationType;
  amount: number;
  payment_frequency: PaymentFrequency;
  effective_date: string; // YYYY-MM-DD format
  end_date?: string; // YYYY-MM-DD format
  notes?: string;
  _destroy?: boolean;
}

export interface UserOffice {
  id?: number;
  user_id: number;
  partnership_type?: PartnershipType;
  partnership_percentage?: number;
  is_administrator?: boolean;
  entry_date?: string; // YYYY-MM-DD format
  compensations_attributes?: Compensation[];
  _destroy?: boolean;
}

// Attachment types
export interface AttachmentMetadata {
  id?: number;
  blob_id: number;
  document_date?: string;
  document_type: 'logo' | 'social_contract';
  description?: string;
  custom_metadata?: Record<string, unknown>;
  uploaded_by_id?: number;
  created_at?: string;
  updated_at?: string;
}

export interface SocialContract {
  id: number;
  blob_id: number;
  filename: string;
  content_type: string;
  byte_size: number;
  created_at: string;
  url: string;
  download_url: string;
  // Metadata fields
  document_date?: string;
  description?: string;
  uploaded_by_id?: number;
  custom_metadata?: Record<string, unknown>;
}

export interface Lawyer {
  id: number;
  email: string;
  oab: string;
  name: string;
  partnership_type?: PartnershipType;
  partnership_percentage?: string;
}

// Main Office interface
export interface Office {
  id: number;
  name: string;
  cnpj: string;
  oab_id?: string;
  oab_status?: string;
  oab_inscricao?: string;
  oab_link?: string;
  society?: Society;
  foundation?: string;
  site?: string;
  accounting_type?: AccountingType;
  quote_value?: number;
  number_of_quotes?: number;
  total_quotes_value?: number;
  formatted_total_quotes_value?: string;
  proportional?: boolean;
  city?: string;
  state?: string;
  deleted?: boolean;
  team_id?: number;
  created_by_id?: number;
  deleted_by_id?: number;

  // Nested attributes
  phones?: Phone[];
  addresses?: Address[];
  emails?: Email[];
  bank_accounts?: BankAccount[];
  user_offices?: UserOffice[];
  works?: Work[];

  // Attachments
  logo_url?: string;
  social_contracts_with_metadata?: SocialContract[];

  // Timestamps
  created_at?: string;
  updated_at?: string;
  deleted_at?: string | null;
}

// Office with lawyers (for special endpoint)
export interface OfficeWithLawyers {
  id: number;
  name: string;
  quote_value?: number;
  number_of_quotes?: number;
  total_quotes_value?: number;
  lawyers: Lawyer[];
}

// Request Types
export interface CreateOfficeRequest {
  name: string;
  cnpj?: string;
  team_id?: number;
  oab_id?: string;
  oab_status?: string;
  oab_inscricao?: string;
  oab_link?: string;
  society?: Society;
  foundation?: string;
  site?: string;
  accounting_type?: AccountingType;
  quote_value?: number;
  number_of_quotes?: number;
  proportional?: boolean;
  create_social_contract?: boolean;
  logo?: File | string;
  phones_attributes?: Omit<Phone, 'id'>[];
  addresses_attributes?: Omit<Address, 'id'>[];
  emails_attributes?: Omit<Email, 'id'>[];
  bank_accounts_attributes?: Omit<BankAccount, 'id'>[];
  user_offices_attributes?: Omit<UserOffice, 'id'>[];
}

export interface UpdateOfficeRequest {
  name?: string;
  cnpj?: string;
  team_id?: number;
  oab_id?: string;
  oab_status?: string;
  oab_inscricao?: string;
  oab_link?: string;
  society?: Society;
  foundation?: string;
  site?: string;
  accounting_type?: AccountingType;
  quote_value?: number;
  number_of_quotes?: number;
  proportional?: boolean;
  create_social_contract?: boolean;
  logo?: File | string;
  phones_attributes?: Phone[];
  addresses_attributes?: Address[];
  emails_attributes?: Email[];
  bank_accounts_attributes?: BankAccount[];
  user_offices_attributes?: UserOffice[];
}

// Response Types
export interface OfficesListResponse {
  success: boolean;
  message: string;
  data: Office[];
  meta?: {
    total_count: number;
    current_page?: number;
    per_page?: number;
    total_pages?: number;
  };
}

export interface OfficeResponse {
  success: boolean;
  message: string;
  data: Office;
}

export interface CreateOfficeResponse {
  success: boolean;
  message: string;
  data: Office;
  errors?: string[];
}

export interface UpdateOfficeResponse {
  success: boolean;
  message: string;
  data: Office;
  errors?: string[];
}

export interface DeleteOfficeResponse {
  success: boolean;
  message: string;
  data?: {
    id: string | number;
  };
}

export interface RestoreOfficeResponse {
  success: boolean;
  message: string;
  data: Office;
  errors?: string[];
}

export interface OfficesWithLawyersResponse {
  success: boolean;
  message: string;
  data: OfficeWithLawyers[];
}

// JSON:API response types
export interface JsonApiOfficeData {
  id: string;
  type: 'office';
  attributes: {
    name: string;
    cnpj: string;
    site?: string;
    quote_value?: number;
    number_of_quotes: number;
    total_quotes_value: number;
    city?: string;
    state?: string;
    deleted: boolean;
    // Additional attributes for 'show' action
    society?: Society;
    foundation?: string;
    addresses?: Address[];
    phones?: Phone[];
    emails?: Email[];
    bank_accounts?: BankAccount[];
    works?: Work[];
    accounting_type?: AccountingType;
    oab_id?: string;
    oab_inscricao?: string;
    oab_link?: string;
    oab_status?: string;
    proportional?: boolean;
    formatted_total_quotes_value?: string;
    // Attachments
    logo_url?: string;
    social_contracts_with_metadata?: SocialContract[];
  };
}

export interface JsonApiOfficeWithLawyersData {
  id: string;
  type: 'office_with_lawyers';
  attributes: {
    name: string;
    quote_value?: number;
    number_of_quotes: number;
    total_quotes_value: number;
    lawyers: Lawyer[];
  };
}

export interface JsonApiOfficeResponse {
  success: boolean;
  message: string;
  data: JsonApiOfficeData;
}

export interface JsonApiOfficesListResponse {
  success: boolean;
  message: string;
  data: JsonApiOfficeData[];
  meta?: {
    total_count: number;
  };
}

export interface JsonApiOfficesWithLawyersResponse {
  success: boolean;
  message: string;
  data: JsonApiOfficeWithLawyersData[];
}

// Attachment-specific request types
export interface UploadLogoRequest {
  logo: File;
  document_date?: string;
  description?: string;
  custom_metadata?: Record<string, unknown>;
}

export interface UploadContractsRequest {
  contracts: File[];
  document_date?: string;
  description?: string;
  custom_metadata?: Record<string, unknown>;
  // Support for per-file metadata
  contract_metadata?: {
    [filename: string]: {
      document_date?: string;
      description?: string;
      custom_metadata?: Record<string, unknown>;
    };
  };
}

export interface UpdateAttachmentMetadataRequest {
  blob_id: number;
  document_date?: string;
  description?: string;
  custom_metadata?: Record<string, unknown>;
}

// Attachment-specific response types
export interface AttachmentOperationResponse {
  success: boolean;
  message: string;
  data?: Record<string, unknown>;
  errors?: string[];
}

// Form Data Types for UI State Management
export interface PartnerFormData {
  lawyer_id: string; // UserProfile ID (for backward compatibility)
  user_id?: string | number; // Actual User ID (for backend)
  lawyer_name?: string;
  partnership_type: string;
  ownership_percentage: number;
  is_managing_partner: boolean;
  pro_labore_amount?: number;
  entry_date?: string;
  // Additional compensation info
  salary_amount?: number;
  salary_start_date?: string;
  salary_end_date?: string;
  payment_frequency?: PaymentFrequency;
}

// Complete Office Form Data for UI
export interface OfficeFormData {
  // Basic Info
  name: string;
  cnpj: string;
  society: string;
  accounting_type: string;
  foundation: string;
  site: string;

  // Quote Configuration
  proportional: boolean;
  quote_value: number;
  number_of_quotes: number;

  // OAB
  oab_id: string;
  oab_status: string;
  oab_inscricao: string;
  oab_link: string;

  // Address
  address: Address;

  // Phones
  phones: string[];

  // Partners
  partners: PartnerFormData[];
  partnersWithProLabore: boolean;

  // Options
  create_social_contract: boolean;
  team_id?: number;
}
