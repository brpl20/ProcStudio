/**
 * Validation Types
 * Defines types for form validation system
 */

// Core validation types
export type ValidationResult = string | null;

export type ValidationRule = (value: unknown) => ValidationResult;

// Field validation state
export interface FieldValidation {
  value: string;
  error: string | null;
  touched: boolean;
  valid: boolean;
}

// Form validation state
export interface FormValidationState {
  [fieldName: string]: FieldValidation;
}

// Validation rule configuration
export interface ValidationConfig {
  required?: boolean;
  rules?: ValidationRule[];
  message?: string;
}

// Field configuration for forms
export interface FieldConfig {
  name: string;
  validation?: ValidationConfig;
}

// Validation options
export interface ValidationOptions {
  trim?: boolean;
  required?: boolean;
  skipEmpty?: boolean;
}
