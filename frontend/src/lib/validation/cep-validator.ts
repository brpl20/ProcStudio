/**
 * CEP Validator
 * Handles local CEP validation rules
 */
import type { ValidationRule } from './types';
import { CEPFormatter } from './cep-formatter';

export class CEPValidator {
  private static readonly ERROR_MESSAGES = {
    REQUIRED: 'CEP é obrigatório',
    INVALID_LENGTH: 'CEP deve ter 8 dígitos',
    INVALID_FORMAT: 'CEP deve conter apenas números',
    INVALID_PATTERN: 'CEP inválido'
  } as const;

  /**
   * Validate CEP format (optional field)
   */
  static validate: ValidationRule = (value) => {
    if (!value) {
      return null;
    }

    const cep = CEPFormatter.clean(value as string);
    if (!cep) {
      return null;
    }

    if (cep.length !== 8) {
      return this.ERROR_MESSAGES.INVALID_LENGTH;
    }

    if (!CEPFormatter.isValidFormat(cep)) {
      return this.ERROR_MESSAGES.INVALID_FORMAT;
    }

    if (CEPFormatter.hasInvalidPattern(cep)) {
      return this.ERROR_MESSAGES.INVALID_PATTERN;
    }

    return null;
  };

  /**
   * Validate required CEP field
   */
  static validateRequired: ValidationRule = (value) => {
    if (!value) {
      return this.ERROR_MESSAGES.REQUIRED;
    }

    const originalValue = value as string;
    const cleanedValue = CEPFormatter.clean(originalValue);

    if (originalValue.trim() && !cleanedValue) {
      return this.ERROR_MESSAGES.INVALID_FORMAT;
    }

    if (!cleanedValue) {
      return this.ERROR_MESSAGES.REQUIRED;
    }

    return this.validate(value);
  };

  /**
   * Check if CEP is valid (boolean return)
   */
  static isValid(cep: string): boolean {
    return this.validate(cep) === null;
  }
}