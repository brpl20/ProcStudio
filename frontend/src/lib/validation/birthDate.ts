/**
 * Birth Date Validation
 * Validates birth dates with age capacity calculation
 */

import type { ValidationRule } from './types';

const MAX_AGE = 120;

/**
 * Calculate age from birth date
 */
export const calculateAge = (birthDate: string | Date): number => {
  const birth = typeof birthDate === 'string' ? new Date(birthDate) : birthDate;
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  
  return age;
};

/**
 * Determine legal capacity based on age
 */
export const getCapacityFromAge = (age: number): {
  capacity: 'able' | 'relative' | 'unable';
  message?: string;
} => {
  if (age < 16) {
    return {
      capacity: 'unable',
      message: 'Menor absolutamente incapaz: selecione um representante'
    };
  } else if (age < 18) {
    return {
      capacity: 'relative',
      message: 'Menor relativamente incapaz: selecione um assistente'
    };
  } else {
    return {
      capacity: 'able'
    };
  }
};

/**
 * Basic birth date validation
 */
export const validateBirthDate: ValidationRule = (value) => {
  if (!value) return null;
  
  const dateStr = value as string;
  const date = new Date(dateStr);
  
  // Check if date is valid
  if (isNaN(date.getTime())) {
    return 'Data de nascimento inválida';
  }
  
  // Check if date is in the future
  if (date > new Date()) {
    return 'Data de nascimento não pode ser no futuro';
  }
  
  // Check maximum age
  const age = calculateAge(date);
  if (age > MAX_AGE) {
    return `Idade não pode ser maior que ${MAX_AGE} anos`;
  }
  
  return null;
};

/**
 * Required birth date validation
 */
export const validateBirthDateRequired: ValidationRule = (value) => {
  if (!value) {
    return 'Data de nascimento é obrigatória';
  }
  
  return validateBirthDate(value);
};

/**
 * Get capacity info from birth date
 */
export const getCapacityFromBirthDate = (birthDate: string | Date | null): {
  capacity: 'able' | 'relative' | 'unable';
  message?: string;
} | null => {
  if (!birthDate) return null;
  
  try {
    const age = calculateAge(birthDate);
    return getCapacityFromAge(age);
  } catch {
    return null;
  }
};

/**
 * Format date for display (DD/MM/YYYY)
 */
export const formatBirthDate = (date: string | Date): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  if (isNaN(d.getTime())) return '';
  
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  
  return `${day}/${month}/${year}`;
};

/**
 * Parse Brazilian date format (DD/MM/YYYY) to ISO
 */
export const parseBrazilianDate = (dateStr: string): string => {
  const parts = dateStr.split('/');
  if (parts.length !== 3) return dateStr;
  
  const [day, month, year] = parts;
  return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
};