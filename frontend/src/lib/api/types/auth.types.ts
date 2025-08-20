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
  data?: any;
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
  data?: any;
}