/**
 * CPF Validation
 * Validates Brazilian CPF (Cadastro de Pessoa Física) documents
 */

import type { ValidationRule } from './types';

// Known invalid CPFs (all same digits)
const INVALID_CPFS = [
  '00000000000',
  '11111111111',
  '22222222222',
  '33333333333',
  '44444444444',
  '55555555555',
  '66666666666',
  '77777777777',
  '88888888888',
  '99999999999'
];

/**
 * Clean CPF string by removing all non-numeric characters
 */
export const cleanCPF = (cpf: string): string => {
  return cpf.replace(/[^\d]/g, '');
};

/**
 * Format CPF for display (xxx.xxx.xxx-xx)
 */
export const formatCPF = (cpf: string): string => {
  const cleaned = cleanCPF(cpf);
  if (cleaned.length !== 11) {
    return cpf;
  }

  return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
};

/**
 * Calculate CPF verification digits
 */
const calculateCPFDigits = (cpf: string): [number, number] => {
  // Calculate first verification digit
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cpf.charAt(i)) * (10 - i);
  }
  let remainder = 11 - (sum % 11);
  const digit1 = remainder > 9 ? 0 : remainder;

  // Calculate second verification digit
  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cpf.charAt(i)) * (11 - i);
  }
  remainder = 11 - (sum % 11);
  const digit2 = remainder > 9 ? 0 : remainder;

  return [digit1, digit2];
};

/**
 * Basic CPF validation
 */
export const validateCPF: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  // Remove special characters
  const cpf = cleanCPF(value as string);

  // Check if CPF is provided
  if (!cpf) {
    return null;
  }

  // Check length
  if (cpf.length !== 11) {
    return 'CPF deve ter 11 dígitos';
  }

  // Check if all digits are the same (invalid CPF)
  if (INVALID_CPFS.includes(cpf)) {
    return 'CPF inválido';
  }

  // Calculate verification digits
  const [digit1, digit2] = calculateCPFDigits(cpf);

  // Verify digits
  if (digit1 !== parseInt(cpf.charAt(9)) || digit2 !== parseInt(cpf.charAt(10))) {
    return 'CPF inválido: dígitos verificadores incorretos';
  }

  return null;
};

/**
 * Required CPF validation
 */
export const validateCPFRequired: ValidationRule = (value) => {
  if (!value || !cleanCPF(value as string)) {
    return 'CPF é obrigatório';
  }

  return validateCPF(value);
};

/**
 * CPF validation with formatting suggestion
 */
export const validateCPFWithFormat: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  const result = validateCPF(value);

  // If valid but not formatted, could suggest formatting
  if (!result) {
    // If it's valid but not formatted, we could return a suggestion
    // But for validation purposes, we'll just return null (valid)
    return null;
  }

  return result;
};

/**
 * Check if CPF is valid (boolean return)
 */
export const isCPFValid = (cpf: string): boolean => {
  return validateCPF(cpf) === null;
};

/**
 * Mask CPF for privacy (show only first 3 and last 2 digits)
 */
export const maskCPF = (cpf: string): string => {
  const cleaned = cleanCPF(cpf);
  if (cleaned.length !== 11) {
    return cpf;
  }

  return `${cleaned.substring(0, 3)}.***.**${cleaned.substring(9)}-**`;
};
