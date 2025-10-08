/**
 * New Office Form Schema - Clean implementation for basic office creation
 * Uses existing API types without conflicts with legacy code
 */

import type { CreateOfficeRequest, Society, AccountingType } from '../api/types/office.types';

// New office form data - matches BasicInformation component exactly
export interface NewOfficeFormData {
  name: string;
  cnpj: string;
  society: string;
  accounting_type: string;
  foundation: string;
  site?: string;
}

// New office form state for UI feedback
export interface NewOfficeFormState {
  loading: boolean;
  saving: boolean;
  error: string | null;
  success: string | null;
  isDirty: boolean;
}

/**
 * Create default new office form data
 */
export function createDefaultNewOfficeFormData(): NewOfficeFormData {
  return {
    name: '',
    cnpj: '',
    society: '',
    accounting_type: '',
    foundation: '',
    site: ''
  };
}

/**
 * Transform new office form data to API request format
 */
export function transformNewOfficeFormToApiRequest(formData: NewOfficeFormData): Partial<CreateOfficeRequest> {
  const apiData: Partial<CreateOfficeRequest> = {};

  if (formData.name?.trim()) {
    apiData.name = formData.name.trim();
  }

  if (formData.cnpj?.trim()) {
    apiData.cnpj = formData.cnpj.replace(/\D/g, ''); // Remove CNPJ formatting
  }

  if (formData.society) {
    apiData.society = formData.society as Society;
  }

  if (formData.accounting_type) {
    apiData.accounting_type = formData.accounting_type as AccountingType;
  }

  if (formData.foundation?.trim()) {
    apiData.foundation = formData.foundation.trim();
  }

  if (formData.site?.trim()) {
    apiData.site = formData.site.trim();
  }

  return apiData;
}

/**
 * Check if new office form has any data (for dirty state)
 */
export function hasNewOfficeFormData(formData: NewOfficeFormData): boolean {
  return !!(
    formData.name?.trim() ||
    formData.cnpj?.trim() ||
    formData.society ||
    formData.accounting_type ||
    formData.foundation?.trim() ||
    formData.site?.trim()
  );
}

/**
 * Validate new office form data
 */
export function validateNewOfficeForm(formData: NewOfficeFormData): string[] {
  const errors: string[] = [];

  if (!formData.name?.trim()) {
    errors.push('Nome do escritório é obrigatório');
  }

  return errors;
}

/**
 * Check if new office form is valid
 */
export function isNewOfficeFormValid(formData: NewOfficeFormData): boolean {
  return validateNewOfficeForm(formData).length === 0;
}