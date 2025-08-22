/**
 * Email Validation
 * Validates email addresses with comprehensive rules
 */

import type { ValidationRule } from './types';

// Basic email regex pattern (more permissive)
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// More strict email regex
const STRICT_EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;

// Common email domains for additional validation
const COMMON_DOMAINS = [
  'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 
  'live.com', 'msn.com', 'icloud.com', 'me.com',
  'uol.com.br', 'terra.com.br', 'bol.com.br', 'ig.com.br'
];

/**
 * Basic email validation
 */
export const validateEmail: ValidationRule = (value) => {
  if (!value) return null;
  
  const email = (value as string).trim().toLowerCase();
  
  // Check if email is provided
  if (!email) return null;
  
  // Check basic format
  if (!EMAIL_REGEX.test(email)) {
    return 'Formato de email inválido';
  }
  
  // Check length
  if (email.length > 254) {
    return 'Email muito longo (máximo 254 caracteres)';
  }
  
  // Check for double dots
  if (email.includes('..')) {
    return 'Email não pode conter pontos consecutivos';
  }
  
  // Check local part length (before @)
  const localPart = email.split('@')[0];
  if (localPart.length > 64) {
    return 'Parte local do email muito longa (máximo 64 caracteres)';
  }
  
  return null;
};

/**
 * Strict email validation with additional checks
 */
export const validateEmailStrict: ValidationRule = (value) => {
  if (!value) return null;
  
  const email = (value as string).trim().toLowerCase();
  
  // First run basic validation
  const basicResult = validateEmail(email);
  if (basicResult) return basicResult;
  
  if (!email) return null;
  
  // Use more strict regex
  if (!STRICT_EMAIL_REGEX.test(email)) {
    return 'Formato de email inválido';
  }
  
  return null;
};

/**
 * Required email validation
 */
export const validateEmailRequired: ValidationRule = (value) => {
  if (!value || !(value as string).trim()) {
    return 'Email é obrigatório';
  }
  
  return validateEmail(value);
};

/**
 * Email validation with domain suggestions
 */
export const validateEmailWithSuggestions: ValidationRule = (value) => {
  if (!value) return null;
  
  const email = (value as string).trim().toLowerCase();
  const basicResult = validateEmail(email);
  
  if (basicResult) return basicResult;
  if (!email) return null;
  
  const domain = email.split('@')[1];
  
  // Check for common typos in popular domains
  const typoMap: Record<string, string> = {
    'gmial.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gmail.co': 'gmail.com',
    'yahooo.com': 'yahoo.com',
    'yahoo.co': 'yahoo.com',
    'hotmial.com': 'hotmail.com',
    'hotmai.com': 'hotmail.com'
  };
  
  if (typoMap[domain]) {
    return `Você quis dizer ${email.replace(domain, typoMap[domain])}?`;
  }
  
  return null;
};

/**
 * Check if email domain exists (basic check)
 */
export const hasValidDomain = (email: string): boolean => {
  const domain = email.split('@')[1];
  return COMMON_DOMAINS.includes(domain) || domain.includes('.');
};