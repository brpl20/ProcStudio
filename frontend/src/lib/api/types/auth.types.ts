/**
 * Authentication Related Types
 */

export interface RegisterRequest {
  user: {
    email: string;
    password: string;
    password_confirmation: string;
    oab: string;
  };
}

export interface RegisterResponse {
  success: boolean;
  message?: string;
  data?: { id: number; email: string; created_at: string; updated_at: string };
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponseData {
  token: string;
  needs_profile_completion: boolean;
  missing_fields?: string[];
  role?: string;
  name?: string;
  last_name?: string;
  oab?: string;
  gender?: string;
  message?: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  data: LoginResponseData;
}

export interface ProfileCompletionData {
  cpf?: string;
  rg?: string;
  gender?: string;
  civil_status?: string;
  nationality?: string;
  birth?: string;
  phone?: string;
}

export interface ProfileCompletionResponse {
  success: boolean;
  message?: string;
  data?: { id: number; email: string; created_at: string; updated_at: string };
}

// NOVOS TYPES PARA CRIAÇÃO DE USUÁRIO POR OUTRO USUÁRIO

export interface Address {
  description?: string;
  zip_code: string;
  street: string;
  number: number;
  neighborhood: string;
  city: string;
  state: string;
}

export interface BankAccount {
  bank_name: string;
  type_account: string;
  agency: string;
  account: string;
  operation?: string;
  pix?: string;
}

export interface Phone {
  phone_number: string;
}

export interface Email {
  email: string;
}

export interface ProfileCreationData {
  role: string;
  name: string; // required*
  last_name?: string;
  gender?: string;
  oab: string; // required*
  rg?: string;
  cpf?: string;
  nationality?: string;
  civil_status?: string;
  birth?: string; // Using string for date format like "3/30/1980"
  mother_name?: string;
  status?: string;
  user_id: number; // required*
  created_at?: string; // required* (but might be auto-generated)
  updated_at?: string; // required* (but might be auto-generated)
  office_id?: number | null;
  origin?: string;
  deleted_at?: string;
  addresses_attributes?: Address[];
  bank_accounts_attributes?: BankAccount[];
  phones_attributes?: Phone[];
  emails_attributes?: Email[];
}

export interface UserProfilePayload {
  user_profile: ProfileCreationData;
}
