/**
 * User and UserProfile Types
 * Based on backend UserSerializer and UserProfileSerializer
 */

export interface UserAttributes {
  access_email: string;
  status: string;
  deleted: boolean;
}

export interface UserData {
  id: string;
  type: 'user';
  attributes: UserAttributes;
  relationships: {
    user_profile: {
      data: {
        id: string;
        type: 'user_profile';
      };
    };
  };
}

export interface UserProfileAttributes {
  role: string;
  name: string;
  last_name: string;
  status: string;
  access_email: string;
  deleted: boolean;
  emails: EmailAttributes[];
  bank_accounts: BankAccountAttributes[];
  phones: PhoneAttributes[];

  // Additional attributes shown on 'show' action
  user_id?: number;
  office_id?: number;
  gender?: string;
  oab?: string;
  rg?: string;
  cpf?: string;
  nationality?: string;
  origin?: string;
  civil_status?: string;
  birth?: string;
  mother_name?: string;
  addresses?: AddressAttributes[];

  // Avatar attributes
  avatar?: string;
  avatar_url?: string;
}

export interface UserProfileData {
  id: string;
  type: 'user_profile';
  attributes: UserProfileAttributes;
}

export interface EmailAttributes {
  id?: number;
  email: string;
}

export interface PhoneAttributes {
  id?: number;
  phone_number: string;
}

export interface BankAccountAttributes {
  id?: number;
  bank_name: string;
  type_account: string;
  agency: string;
  account: string;
  operation?: string;
  pix?: string;
}

export interface AddressAttributes {
  id?: number;
  description?: string;
  zip_code: string;
  number: string;
  street: string;
  neighborhood: string;
  city: string;
  state: string;
}

export interface UsersListResponse {
  data: UserData[];
  included?: UserProfileData[];
  meta?: {
    total_count: number;
  };
}

export interface UserResponse {
  data: UserData;
  included?: UserProfileData[];
}

export interface WhoAmIProfile {
  id: number;
  name: string;
  last_name: string;
  full_name: string;
  role: string;
  status: string;
  gender: string;
  oab: string;
  rg: string;
  cpf: string;
  nationality: string;
  origin: string | null;
  civil_status: string;
  birth: string;
  mother_name: string | null;
  avatar_url: string;
  created_at: string;
  updated_at: string;
}

export interface WhoAmITeam {
  id: number;
  name: string;
  subdomain: string;
}

export interface WhoAmIOffice {
  id: number;
  name: string;
  cnpj: string;
  partnership_type: string;
  partnership_percentage: string;
  entry_date: string | null;
}

export interface WhoAmIPhone {
  id: number;
  phone_number: string;
  phone_type: string | null;
}

export interface WhoAmIAddress {
  id: number;
  street: string;
  number: string;
  complement: string;
  neighborhood: string;
  city: string;
  state: string;
  zip_code: string;
  address_type: string;
}

export interface WhoAmIBankAccount {
  id: number;
  bank_name: string;
  type_account: string;
  agency: string;
  account: string;
  operation?: string;
  pix?: string;
}

export interface WhoAmIData {
  id: string;
  type: string;
  attributes: {
    email: string;
    status: string;
    created_at: string;
    updated_at: string;
    team: WhoAmITeam;
    profile: WhoAmIProfile;
    office: WhoAmIOffice | null;
    offices: WhoAmIOffice[];
    phones: WhoAmIPhone[];
    addresses: WhoAmIAddress[];
    bank_accounts: WhoAmIBankAccount[];
    works_count: number;
    jobs_count: number;
    deleted: boolean;
  };
}

export interface WhoAmIResponse {
  success: boolean;
  message: string;
  data: WhoAmIData;
}

export interface CreateUserRequest {
  user: {
    email: string;
    password: string;
    password_confirmation: string;
    oab?: string;
    team_id?: number;
  };
}

export interface UpdateUserRequest {
  user?: Partial<{
    email: string;
    status: string;
  }>;
}

export interface UpdateUserProfileRequest {
  user_profile: Partial<{
    role: string;
    name: string;
    last_name: string;
    status: string;
    gender: string;
    oab: string;
    rg: string;
    cpf: string;
    nationality: string;
    origin: string;
    civil_status: string;
    birth: string;
    mother_name: string;
    office_id: number;
    avatar: string;
  }>;
}

// Standardized API Response Types
export interface ApiSuccessResponse<T = unknown> {
  success: true;
  message: string;
  data: T;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  errors: string[];
}

export type ApiResponse<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse;
