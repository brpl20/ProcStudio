/**
 * Validation Store
 * Svelte store for managing form validation state
 */

import { writable, derived } from 'svelte/store';
import type { FormValidationState, ValidationRule } from '../validation/types';
import { validateField, createFieldValidation } from '../validation/index';

interface ValidationStoreConfig {
  [fieldName: string]: ValidationRule[];
}

/**
 * Create a validation store for a form
 */
export function createValidationStore(config: ValidationStoreConfig) {
  // Initial state with empty field validations
  const initialState: FormValidationState = {};
  Object.keys(config).forEach((fieldName) => {
    initialState[fieldName] = createFieldValidation();
  });

  const { subscribe, set, update } = writable<FormValidationState>(initialState);

  return {
    subscribe,
    update, // Expose update method for custom validators

    /**
     * Validate a single field
     */
    validateField: (fieldName: string, value: string, touched = true) => {
      const rules = config[fieldName] || [];
      const error = validateField(value, rules);

      update((state) => ({
        ...state,
        [fieldName]: {
          value,
          error,
          touched,
          valid: error === null
        }
      }));

      return error === null;
    },

    /**
     * Set field value without validation
     */
    setFieldValue: (fieldName: string, value: string) => {
      update((state) => ({
        ...state,
        [fieldName]: {
          ...state[fieldName],
          value
        }
      }));
    },

    /**
     * Mark field as touched
     */
    touchField: (fieldName: string) => {
      update((state) => ({
        ...state,
        [fieldName]: {
          ...state[fieldName],
          touched: true
        }
      }));
    },

    /**
     * Validate all fields
     */
    validateAll: (formData: Record<string, string>) => {
      let allValid = true;

      update((state) => {
        const newState = { ...state };

        Object.keys(config).forEach((fieldName) => {
          const value = formData[fieldName] || '';
          const rules = config[fieldName] || [];
          const error = validateField(value, rules);

          newState[fieldName] = {
            value,
            error,
            touched: true,
            valid: error === null
          };

          if (error) {
            allValid = false;
          }
        });

        return newState;
      });

      return allValid;
    },

    /**
     * Reset validation state
     */
    reset: () => {
      const resetState: FormValidationState = {};
      Object.keys(config).forEach((fieldName) => {
        resetState[fieldName] = createFieldValidation();
      });
      set(resetState);
    },

    /**
     * Clear specific field error
     */
    clearFieldError: (fieldName: string) => {
      update((state) => ({
        ...state,
        [fieldName]: {
          ...state[fieldName],
          error: null,
          valid: true
        }
      }));
    }
  };
}

/**
 * Create derived stores for common validation checks
 */
export function createValidationHelpers(validationStore: ReturnType<typeof createValidationStore>) {
  return {
    // Check if form is valid
    isValid: derived(validationStore, ($state) =>
      Object.values($state).every((field) => field.valid)
    ),

    // Get all errors
    errors: derived(validationStore, ($state) =>
      Object.values($state)
        .filter((field) => field.error && field.touched)
        .map((field) => field.error!)
    ),

    // Check if any field has been touched
    isTouched: derived(validationStore, ($state) =>
      Object.values($state).some((field) => field.touched)
    ),

    // Get specific field validation
    getField: (fieldName: string) => derived(validationStore, ($state) => $state[fieldName])
  };
}

/**
 * Example usage store for customer form
 */
import { validateEmailRequired } from '../validation/email';
import { validateCPFRequired } from '../validation/cpf';
import { validatePasswordRequired, validatePasswordMinLength } from '../validation/password';
import { validationRules } from '../validation/index';

// Basic customer validation config (for CustomerForm without CPF)
export const customerBasicValidationConfig = {
  email: [validateEmailRequired],
  password: [
    validatePasswordRequired,
    validatePasswordMinLength(6)
  ],
  password_confirmation: [validationRules.required('Confirmação de senha é obrigatória')]
};

// Full customer validation config (with CPF for future profile forms)
export const customerValidationConfig = {
  email: [validateEmailRequired],
  cpf: [validateCPFRequired],
  password: [
    validatePasswordRequired,
    validatePasswordMinLength(6)
  ],
  password_confirmation: [validationRules.required('Confirmação de senha é obrigatória')]
};

// Create customer form validation store (uses basic config without CPF)
export const createCustomerValidationStore = () => {
  const store = createValidationStore(customerBasicValidationConfig);
  const helpers = createValidationHelpers(store);

  return {
    ...store,
    ...helpers,

    // Custom validation for password confirmation
    validatePasswordConfirmation: (password: string, confirmation: string) => {
      const isValid = password === confirmation;

      store.update((state) => ({
        ...state,
        password_confirmation: {
          ...state.password_confirmation,
          value: confirmation,
          error: isValid ? null : 'As senhas não coincidem',
          valid: isValid,
          touched: true
        }
      }));

      return isValid;
    }
  };
};

// Create customer profile validation store (with CPF for profile forms)
export const createCustomerProfileValidationStore = () => {
  const store = createValidationStore(customerValidationConfig);
  const helpers = createValidationHelpers(store);

  return {
    ...store,
    ...helpers,

    // Custom validation for password confirmation
    validatePasswordConfirmation: (password: string, confirmation: string) => {
      const isValid = password === confirmation;

      store.update((state) => ({
        ...state,
        password_confirmation: {
          ...state.password_confirmation,
          value: confirmation,
          error: isValid ? null : 'As senhas não coincidem',
          valid: isValid,
          touched: true
        }
      }));

      return isValid;
    }
  };
};
