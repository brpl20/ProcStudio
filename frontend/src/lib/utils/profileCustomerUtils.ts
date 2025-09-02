import type { ProfileCustomer } from '../api/types/customer.types';

/**
 * Get ProfileCustomer full name from name and last_name attributes
 */
export function getProfileCustomerFullName(profileCustomer: ProfileCustomer): string {
  const { name, last_name } = profileCustomer.attributes;

  const fullName = `${name ?? ''} ${last_name ?? ''}`.trim();

  return fullName || 'Nome não informado';
}

/**
 * Get ProfileCustomer CPF or CNPJ formatted
 */
export function getProfileCustomerCpfOrCpnj(profileCustomer: ProfileCustomer): string {
  const { cpf, cnpj } = profileCustomer.attributes;

  if (cpf && isValidCPF(cpf)) {
    return cpfMask(cpf);
  } else if (cnpj && isValidCNPJ(cnpj)) {
    return cnpjMask(cnpj);
  } else {
    return 'Não possui';
  }
}

/**
 * Simple CPF mask formatter
 */
function cpfMask(cpf: string): string {
  const cleanCpf = cpf.replace(/\D/g, '');
  return cleanCpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
}

/**
 * Simple CNPJ mask formatter
 */
function cnpjMask(cnpj: string): string {
  const cleanCnpj = cnpj.replace(/\D/g, '');
  return cleanCnpj.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
}

/**
 * Simple CPF validator
 */
function isValidCPF(cpf: string): boolean {
  const cleanCpf = cpf.replace(/\D/g, '');
  if (cleanCpf.length !== 11) {
    return false;
  }

  // Check for known invalid CPFs
  if (/^(\d)\1{10}$/.test(cleanCpf)) {
    return false;
  }

  // Validate CPF algorithm
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cleanCpf.charAt(i)) * (10 - i);
  }
  let remainder = 11 - (sum % 11);
  if (remainder === 10 || remainder === 11) {
    remainder = 0;
  }
  if (remainder !== parseInt(cleanCpf.charAt(9))) {
    return false;
  }

  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cleanCpf.charAt(i)) * (11 - i);
  }
  remainder = 11 - (sum % 11);
  if (remainder === 10 || remainder === 11) {
    remainder = 0;
  }
  if (remainder !== parseInt(cleanCpf.charAt(10))) {
    return false;
  }

  return true;
}

/**
 * Simple CNPJ validator
 */
function isValidCNPJ(cnpj: string): boolean {
  const cleanCnpj = cnpj.replace(/\D/g, '');
  if (cleanCnpj.length !== 14) {
    return false;
  }

  // Check for known invalid CNPJs
  if (/^(\d)\1{13}$/.test(cleanCnpj)) {
    return false;
  }

  // Validate CNPJ algorithm
  let sum = 0;
  let weight = 2;

  for (let i = 11; i >= 0; i--) {
    sum += parseInt(cleanCnpj.charAt(i)) * weight;
    weight = weight === 9 ? 2 : weight + 1;
  }

  let remainder = sum % 11;
  const digit1 = remainder < 2 ? 0 : 11 - remainder;

  if (digit1 !== parseInt(cleanCnpj.charAt(12))) {
    return false;
  }

  sum = 0;
  weight = 2;

  for (let i = 12; i >= 0; i--) {
    sum += parseInt(cleanCnpj.charAt(i)) * weight;
    weight = weight === 9 ? 2 : weight + 1;
  }

  remainder = sum % 11;
  const digit2 = remainder < 2 ? 0 : 11 - remainder;

  if (digit2 !== parseInt(cleanCnpj.charAt(13))) {
    return false;
  }

  return true;
}

/**
 * Translate customer type to Portuguese
 */
export function translateCustomerType(customerType: string): string {
  switch (customerType?.toLowerCase()) {
    case 'physical_person':
      return 'Pessoa Física';
    case 'legal_person':
      return 'Pessoa Jurídica';
    case 'counter':
      return 'Contador';
    case 'representative':
      return 'Representante Legal';
    default:
      return customerType || 'Não definido';
  }
}

/**
 * Format phone number with mask
 */
export function phoneMask(phone: string): string {
  const cleanPhone = phone.replace(/\D/g, '');

  if (cleanPhone.length === 10) {
    return cleanPhone.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
  } else if (cleanPhone.length === 11) {
    return cleanPhone.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  }

  return phone;
}
