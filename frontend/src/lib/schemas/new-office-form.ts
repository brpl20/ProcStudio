/**
 * New Office Form Schema - Clean implementation for basic office creation
 * Uses existing API types without conflicts with legacy code
 */

import type { CreateOfficeRequest, Society, AccountingType } from '../api/types/office.types';
import { validateCNPJOptional } from '../validation/cnpj';

// New office form data - matches BasicInformation component exactly
export interface NewOfficeFormData {
  name: string;
  cnpj: string;
  society: string;
  accounting_type: string;
  foundation: string;
  site?: string;
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
    site: ''
  };
}

/**
 * Transform new office form data to API request format
 */
export function transformNewOfficeFormToApiRequest(formData: NewOfficeFormData): Partial<CreateOfficeRequest> {
  const apiData: Partial<CreateOfficeRequest> = {};

  if (formData.name?.trim()) {
    apiData.name = formData.name.trim();
  }

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

  return apiData;
}

/**
 * Check if new office form has any data (for dirty state)
 */
export function hasNewOfficeFormData(formData: NewOfficeFormData): boolean {
  return !!(
    formData.name?.trim() ||
    formData.cnpj?.trim() ||
    formData.society ||
    formData.accounting_type ||
    formData.foundation?.trim() ||
    formData.site?.trim()
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
    site: { required: false }
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

  // Iterate through all fields in the validation config
  for (const [fieldName, rules] of Object.entries(validationConfig)) {
    const fieldValue = formData[fieldName as keyof NewOfficeFormData];

    // Check required validation
    if (rules.required && (!fieldValue || !String(fieldValue).trim())) {
      const fieldLabel = getFieldLabel(fieldName);
      errors.push(`${fieldLabel} é obrigatório`);
      continue; // Skip custom validation if field is empty and required
    }

    // Apply custom validator if provided and field has value
    if (rules.customValidator && fieldValue) {
      const customError = rules.customValidator(fieldValue);
      if (customError) {
        errors.push(customError);
      }
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
    site: 'Site'
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