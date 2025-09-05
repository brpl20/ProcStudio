export interface CEPAddress {
  cep: string;
  street?: string;
  complement?: string;
  neighborhood?: string;
  city?: string;
  state?: string;
  ibge?: string;
  gia?: string;
  ddd?: string;
  siafi?: string;
}

export interface CEPValidationResult {
  isValid: boolean;
  message?: string;
  data?: CEPAddress;
}

export interface CEPApiConfig {
  baseUrl: string;
  timeout?: number;
  retryAttempts?: number;
}
