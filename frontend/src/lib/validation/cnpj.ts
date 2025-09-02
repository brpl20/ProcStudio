/**
 * CNPJ Validation
 * Validates Brazilian CNPJ (Cadastro Nacional da Pessoa Jurídica) documents
 */

import type { ValidationRule } from './types';

// Known invalid CNPJs (all same digits)
const INVALID_CNPJS = [
  '00000000000000',
  '11111111111111',
  '22222222222222',
  '33333333333333',
  '44444444444444',
  '55555555555555',
  '66666666666666',
  '77777777777777',
  '88888888888888',
  '99999999999999'
];

/**
 * Clean CNPJ string by removing all non-numeric characters
 */
export const cleanCNPJ = (cnpj: string): string => {
  return cnpj.replace(/[^\d]/g, '');
};

/**
 * Format CNPJ for display (xx.xxx.xxx/xxxx-xx)
 */
export const formatCNPJ = (cnpj: string): string => {
  const cleaned = cleanCNPJ(cnpj);
  if (cleaned.length !== 14) {
    return cnpj;
  }

  return cleaned.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
};

/**
 * Calculate CNPJ verification digits
 */
const calculateCNPJDigits = (cnpj: string): [number, number] => {
  // Weights for first digit calculation
  const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  // Calculate first verification digit
  let sum = 0;
  for (let i = 0; i < 12; i++) {
    sum += parseInt(cnpj.charAt(i)) * weights1[i];
  }
  let remainder = sum % 11;
  const digit1 = remainder < 2 ? 0 : 11 - remainder;

  // Weights for second digit calculation
  const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  // Calculate second verification digit
  sum = 0;
  for (let i = 0; i < 13; i++) {
    sum += parseInt(cnpj.charAt(i)) * weights2[i];
  }
  remainder = sum % 11;
  const digit2 = remainder < 2 ? 0 : 11 - remainder;

  return [digit1, digit2];
};

/**
 * Basic CNPJ validation
 */
export const validateCNPJ: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  // Remove special characters
  const cnpj = cleanCNPJ(value as string);

  // Check if CNPJ is provided
  if (!cnpj) {
    return null;
  }

  // Check length
  if (cnpj.length !== 14) {
    return 'CNPJ deve ter 14 dígitos';
  }

  // Check if all digits are the same (invalid CNPJ)
  if (INVALID_CNPJS.includes(cnpj)) {
    return 'CNPJ inválido';
  }

  // Calculate verification digits
  const [digit1, digit2] = calculateCNPJDigits(cnpj);

  // Verify digits
  if (digit1 !== parseInt(cnpj.charAt(12)) || digit2 !== parseInt(cnpj.charAt(13))) {
    return 'CNPJ inválido: dígitos verificadores incorretos';
  }

  return null;
};

/**
 * Required CNPJ validation
 */
export const validateCNPJRequired: ValidationRule = (value) => {
  if (!value || !cleanCNPJ(value as string)) {
    return 'CNPJ é obrigatório';
  }

  return validateCNPJ(value);
};

/**
 * CNPJ validation with formatting suggestion
 */
export const validateCNPJWithFormat: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  const result = validateCNPJ(value);

  // If valid but not formatted, could suggest formatting
  if (!result) {
    // If it's valid but not formatted, we'll just return null (valid)
    return null;
  }

  return result;
};

/**
 * Check if CNPJ is valid (boolean return)
 */
export const isCNPJValid = (cnpj: string): boolean => {
  return validateCNPJ(cnpj) === null;
};

/**
 * Mask CNPJ for privacy (show only first 2 and last 2 digits)
 */
export const maskCNPJ = (cnpj: string): string => {
  const cleaned = cleanCNPJ(cnpj);
  if (cleaned.length !== 14) {
    return cnpj;
  }

  return `${cleaned.substring(0, 2)}.***.***/****-${cleaned.substring(12)}`;
};

/**
 * Get CNPJ type based on the number pattern
 */
export const getCNPJType = (cnpj: string): string => {
  const cleaned = cleanCNPJ(cnpj);
  if (cleaned.length !== 14) {
    return 'Inválido';
  }

  // Matrix (first 8 digits identify the company)
  // Branch (digits 9-12 identify the branch, 0001 = headquarters)
  const branch = cleaned.substring(8, 12);

  if (branch === '0001') {
    return 'Matriz';
  } else {
    return `Filial ${branch}`;
  }
};
