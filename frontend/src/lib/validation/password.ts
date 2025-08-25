/**
 * Password Validation
 * Validates passwords with configurable rules
 */

import type { ValidationRule } from './types';

/**
 * Minimum length validation
 */
export const validatePasswordMinLength = (minLength = 6): ValidationRule => (value) => {
  if (!value) {
    return null;
  }

  const password = value as string;
  if (password.length < minLength) {
    return `Senha deve ter pelo menos ${minLength} caracteres`;
  }

  return null;
};

/**
 * Maximum length validation
 */
export const validatePasswordMaxLength = (maxLength = 128): ValidationRule => (value) => {
  if (!value) {
    return null;
  }

  const password = value as string;
  if (password.length > maxLength) {
    return `Senha deve ter no máximo ${maxLength} caracteres`;
  }

  return null;
};

/**
 * Required password validation
 */
export const validatePasswordRequired: ValidationRule = (value) => {
  if (!value || !(value as string).trim()) {
    return 'Senha é obrigatória';
  }

  return null;
};

/**
 * Strong password validation
 * Requires at least one uppercase, one lowercase, one number, and one special character
 */
export const validatePasswordStrong: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  const password = value as string;

  // Check minimum length
  if (password.length < 8) {
    return 'Senha deve ter pelo menos 8 caracteres';
  }

  // Check for uppercase letter
  if (!/[A-Z]/.test(password)) {
    return 'Senha deve conter pelo menos uma letra maiúscula';
  }

  // Check for lowercase letter
  if (!/[a-z]/.test(password)) {
    return 'Senha deve conter pelo menos uma letra minúscula';
  }

  // Check for number
  if (!/[0-9]/.test(password)) {
    return 'Senha deve conter pelo menos um número';
  }

  // Check for special character
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    return 'Senha deve conter pelo menos um caractere especial';
  }

  return null;
};

/**
 * Medium strength password validation
 * Requires at least one letter and one number
 */
export const validatePasswordMedium: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  const password = value as string;

  // Check minimum length
  if (password.length < 6) {
    return 'Senha deve ter pelo menos 6 caracteres';
  }

  // Check for letter
  if (!/[a-zA-Z]/.test(password)) {
    return 'Senha deve conter pelo menos uma letra';
  }

  // Check for number
  if (!/[0-9]/.test(password)) {
    return 'Senha deve conter pelo menos um número';
  }

  return null;
};

/**
 * Check for common weak passwords
 */
const COMMON_WEAK_PASSWORDS = [
  '123456',
  'password',
  '12345678',
  'qwerty',
  'abc123',
  '123456789',
  'password123',
  '12345',
  'senha',
  'senha123',
  '123mudar',
  'admin',
  'usuario'
];

export const validatePasswordNotCommon: ValidationRule = (value) => {
  if (!value) {
    return null;
  }

  const password = (value as string).toLowerCase();

  if (COMMON_WEAK_PASSWORDS.includes(password)) {
    return 'Esta senha é muito comum. Por favor, escolha uma senha mais segura';
  }

  return null;
};

/**
 * Password confirmation validation
 * Note: This requires comparing with another field, so it's typically implemented
 * at the form level rather than as a standalone validator
 */
export const createPasswordConfirmationValidator = (getPassword: () => string): ValidationRule => (value) => {
  if (!value) {
    return 'Confirmação de senha é obrigatória';
  }

  const password = getPassword();
  const confirmation = value as string;

  if (password !== confirmation) {
    return 'As senhas não coincidem';
  }

  return null;
};

/**
 * Calculate password strength score (0-4)
 */
export const calculatePasswordStrength = (password: string): number => {
  let strength = 0;

  if (!password) {
    return strength;
  }

  // Length bonus
  if (password.length >= 8) {
    strength++;
  }
  if (password.length >= 12) {
    strength++;
  }

  // Complexity bonus
  if (/[a-z]/.test(password) && /[A-Z]/.test(password)) {
    strength++;
  }
  if (/[0-9]/.test(password)) {
    strength++;
  }
  if (/[^a-zA-Z0-9]/.test(password)) {
    strength++;
  }

  // Cap at 4
  return Math.min(strength, 4);
};

/**
 * Get password strength label
 */
export const getPasswordStrengthLabel = (strength: number): string => {
  switch (strength) {
  case 0:
    return 'Muito fraca';
  case 1:
    return 'Fraca';
  case 2:
    return 'Razoável';
  case 3:
    return 'Boa';
  case 4:
    return 'Excelente';
  default:
    return 'Muito fraca';
  }
};

/**
 * Combined validators for common use cases
 */
export const passwordValidators = {
  basic: [
    validatePasswordRequired,
    validatePasswordMinLength(6)
  ],

  medium: [
    validatePasswordRequired,
    validatePasswordMedium,
    validatePasswordNotCommon
  ],

  strong: [
    validatePasswordRequired,
    validatePasswordStrong,
    validatePasswordNotCommon
  ]
};