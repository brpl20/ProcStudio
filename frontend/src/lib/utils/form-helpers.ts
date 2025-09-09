/**
 * Form Helper Utilities
 *
 * This file contains utility functions for form operations,
 * extracted from CustomerForm.svelte for better reusability.
 */

import type { CustomerFormData } from '../schemas/customer-form';
import { FORM_STORAGE_KEY } from '../schemas/customer-form';

/**
 * Generate a strong password
 * @param length - Password length (default: 12)
 * @returns Generated password string
 */
export function generateStrongPassword(length: number = 12): string {
  const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?';

  const allChars = lowercase + uppercase + numbers + symbols;
  let password = '';

  // Ensure at least one character from each category
  password += lowercase[Math.floor(Math.random() * lowercase.length)];
  password += uppercase[Math.floor(Math.random() * uppercase.length)];
  password += numbers[Math.floor(Math.random() * numbers.length)];
  password += symbols[Math.floor(Math.random() * symbols.length)];

  // Fill the rest randomly
  for (let i = 4; i < length; i++) {
    password += allChars[Math.floor(Math.random() * allChars.length)];
  }

  // Shuffle the password
  return password
    .split('')
    .sort(() => Math.random() - 0.5)
    .join('');
}

/**
 * Save form data to localStorage
 * @param formData - Form data to save
 * @param excludePasswords - Whether to exclude passwords for security (default: true)
 */
export function saveFormDraft(formData: CustomerFormData, excludePasswords: boolean = true): void {
  if (typeof localStorage === 'undefined') {
    return;
  }

  try {
    const draftData = { ...formData };

    if (excludePasswords) {
      draftData.customer_attributes = {
        ...draftData.customer_attributes,
        password: '',
        password_confirmation: ''
      };
    }

    localStorage.setItem(FORM_STORAGE_KEY, JSON.stringify(draftData));
  } catch {
    // Failed to save form draft
  }
}

/**
 * Load form data from localStorage
 * @returns Saved form data or null if not found
 */
export function loadFormDraft(): Partial<CustomerFormData> | null {
  if (typeof localStorage === 'undefined') {
    return null;
  }

  try {
    const savedData = localStorage.getItem(FORM_STORAGE_KEY);
    if (savedData) {
      return JSON.parse(savedData);
    }
  } catch {
    // Failed to load form draft
  }

  return null;
}

/**
 * Clear saved form data from localStorage
 */
export function clearFormDraft(): void {
  if (typeof localStorage === 'undefined') {
    return;
  }

  try {
    localStorage.removeItem(FORM_STORAGE_KEY);
  } catch {
    // Failed to clear form draft
  }
}

/**
 * Get gender-based civil status label
 * @param status - Civil status value
 * @param gender - Gender value
 * @returns Localized civil status label
 */
export function getCivilStatusLabel(status: string, gender: string): string {
  const labels: Record<string, Record<string, string>> = {
    single: { male: 'Solteiro', female: 'Solteira' },
    married: { male: 'Casado', female: 'Casada' },
    divorced: { male: 'Divorciado', female: 'Divorciada' },
    widower: { male: 'Viúvo', female: 'Viúva' },
    union: { male: 'Em união estável', female: 'Em união estável' }
  };

  return labels[status]?.[gender] || status;
}

/**
 * Get gender-based nationality label
 * @param nationality - Nationality value
 * @param gender - Gender value
 * @returns Localized nationality label
 */
export function getNationalityLabel(nationality: string, gender: string): string {
  const labels: Record<string, Record<string, string>> = {
    brazilian: { male: 'Brasileiro', female: 'Brasileira' },
    foreigner: { male: 'Estrangeiro', female: 'Estrangeira' }
  };

  return labels[nationality]?.[gender] || nationality;
}

/**
 * Validate guardian age against represented person's age
 * @param guardianBirth - Guardian's birth date
 * @param representedBirth - Represented person's birth date
 * @returns Validation result
 */
export function validateGuardianAge(
  guardianBirth: string,
  representedBirth: string
): {
  isValid: boolean;
  message: string;
} {
  if (!guardianBirth || !representedBirth) {
    return { isValid: true, message: '' };
  }

  const guardianDate = new Date(guardianBirth);
  const representedDate = new Date(representedBirth);

  const guardianAge = new Date().getFullYear() - guardianDate.getFullYear();
  const representedAge = new Date().getFullYear() - representedDate.getFullYear();

  // Guardian must be at least 18 years old and older than represented person
  if (guardianAge < 18) {
    return {
      isValid: false,
      message: 'O responsável deve ter pelo menos 18 anos'
    };
  }

  if (guardianAge <= representedAge) {
    return {
      isValid: false,
      message: 'O responsável deve ser mais velho que a pessoa representada'
    };
  }

  return { isValid: true, message: '' };
}

/**
 * Copy address data from one form to another
 * @param sourceAddress - Source address data
 * @returns Copied address data
 */
export function copyAddressData(sourceAddress: Record<string, unknown>): Record<string, unknown> {
  return { ...sourceAddress };
}

/**
 * Copy bank account data from one form to another
 * @param sourceBankAccount - Source bank account data
 * @returns Copied bank account data
 */
export function copyBankAccountData(
  sourceBankAccount: Record<string, unknown>
): Record<string, unknown> {
  return { ...sourceBankAccount };
}

/**
 * Format phone number for PIX key
 * @param phoneNumber - Phone number string
 * @returns Cleaned phone number (digits only)
 */
export function formatPhoneForPix(phoneNumber: string): string {
  return phoneNumber.replace(/\D/g, '');
}

/**
 * Format CPF for PIX key
 * @param cpf - CPF string
 * @returns Cleaned CPF (digits only)
 */
export function formatCpfForPix(cpf: string): string {
  return cpf.replace(/\D/g, '');
}

/**
 * Check if form data has changed
 * @param current - Current form data
 * @param initial - Initial form data
 * @returns True if form is dirty
 */
export function isFormDirty(
  current: Record<string, unknown>,
  initial: Record<string, unknown>
): boolean {
  return JSON.stringify(current) !== JSON.stringify(initial);
}

/**
 * Deep clone form data
 * @param data - Data to clone
 * @returns Cloned data
 */
export function cloneFormData<T>(data: T): T {
  return JSON.parse(JSON.stringify(data));
}
