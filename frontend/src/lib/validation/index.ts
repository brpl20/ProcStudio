/**
 * Validation System
 * Centralized validation for forms with Brazilian document support
 */

// Export types
export type {
  ValidationResult,
  ValidationRule,
  FieldValidation,
  FormValidationState,
  ValidationConfig,
  FieldConfig,
  ValidationOptions
} from './types';

// Export email validators
export {
  validateEmail,
  validateEmailStrict,
  validateEmailRequired,
  validateEmailWithSuggestions,
  hasValidDomain
} from './email';

// Export CPF validators
export {
  validateCPF,
  validateCPFRequired,
  validateCPFWithFormat,
  isCPFValid,
  cleanCPF,
  formatCPF,
  maskCPF
} from './cpf';

// Export CNPJ validators
export {
  validateCNPJ,
  validateCNPJRequired,
  validateCNPJWithFormat,
  isCNPJValid,
  cleanCNPJ,
  formatCNPJ,
  maskCNPJ,
  getCNPJType
} from './cnpj';

// Export password validators
export {
  validatePasswordRequired,
  validatePasswordMinLength,
  validatePasswordMaxLength,
  validatePasswordStrong,
  validatePasswordMedium,
  validatePasswordNotCommon,
  createPasswordConfirmationValidator,
  calculatePasswordStrength,
  getPasswordStrengthLabel,
  passwordValidators
} from './password';

// Export birth date validators
export {
  validateBirthDate,
  validateBirthDateRequired,
  calculateAge,
  getCapacityFromAge,
  getCapacityFromBirthDate,
  formatBirthDate,
  parseBrazilianDate
} from './birthDate';

import type { ValidationRule, FieldValidation, FormValidationState } from './types';

/**
 * Common validation rules
 */
export const validationRules = {
  required: (message = 'Este campo é obrigatório'): ValidationRule => (value) => {
    if (!value || (typeof value === 'string' && !value.trim())) {
      return message;
    }
    return null;
  },

  minLength: (min: number, message?: string): ValidationRule => (value) => {
    if (!value) return null;
    if ((value as string).length < min) {
      return message || `Deve ter pelo menos ${min} caracteres`;
    }
    return null;
  },

  maxLength: (max: number, message?: string): ValidationRule => (value) => {
    if (!value) return null;
    if ((value as string).length > max) {
      return message || `Deve ter no máximo ${max} caracteres`;
    }
    return null;
  },

  pattern: (regex: RegExp, message: string): ValidationRule => (value) => {
    if (!value) return null;
    if (!regex.test(value as string)) {
      return message;
    }
    return null;
  },

  numeric: (message = 'Deve conter apenas números'): ValidationRule => (value) => {
    if (!value) return null;
    if (!/^\d+$/.test((value as string).replace(/\D/g, ''))) {
      return message;
    }
    return null;
  }
};

/**
 * Validate a single field with multiple rules
 */
export const validateField = (
  value: string,
  rules: ValidationRule[]
): string | null => {
  for (const rule of rules) {
    const result = rule(value);
    if (result) {
      return result;
    }
  }
  return null;
};

/**
 * Create field validation state
 */
export const createFieldValidation = (
  value = '',
  touched = false
): FieldValidation => ({
  value,
  error: null,
  touched,
  valid: true
});

/**
 * Validate form with multiple fields
 */
export const validateForm = (
  formData: Record<string, string>,
  fieldRules: Record<string, ValidationRule[]>
): FormValidationState => {
  const state: FormValidationState = {};

  Object.keys(formData).forEach(fieldName => {
    const value = formData[fieldName];
    const rules = fieldRules[fieldName] || [];
    const error = validateField(value, rules);

    state[fieldName] = {
      value,
      error,
      touched: true,
      valid: error === null
    };
  });

  return state;
};

/**
 * Check if form is valid
 */
export const isFormValid = (validationState: FormValidationState): boolean => {
  return Object.values(validationState).every(field => field.valid);
};

/**
 * Get form errors
 */
export const getFormErrors = (validationState: FormValidationState): string[] => {
  return Object.values(validationState)
    .filter(field => field.error)
    .map(field => field.error!);
};

/**
 * Auto-format Brazilian documents
 */
export const autoFormat = {
  cpf: (value: string): string => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length <= 11) {
      return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    }
    return value;
  },

  cnpj: (value: string): string => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length <= 14) {
      return cleaned.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
    return value;
  },

  phone: (value: string): string => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length <= 10) {
      return cleaned.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
    } else {
      return cleaned.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
    }
  }
};

/**
 * Common form field configurations
 */
export const commonFields = {
  email: {
    name: 'email',
    validation: {
      required: true,
      rules: [validationRules.required('Email é obrigatório')]
    }
  },

  cpf: {
    name: 'cpf',
    validation: {
      required: true,
      rules: [validationRules.required('CPF é obrigatório')]
    }
  },

  cnpj: {
    name: 'cnpj',
    validation: {
      required: true,
      rules: [validationRules.required('CNPJ é obrigatório')]
    }
  }
};