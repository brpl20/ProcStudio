/**
 * Bank Account Types Constants
 * 
 * Standard bank account types used across the system
 */

export interface BankAccountType {
  value: string;
  label: string;
}

/**
 * Standard bank account types
 */
export const BANK_ACCOUNT_TYPES: BankAccountType[] = [
  { value: 'Corrente', label: 'Corrente' },
  { value: 'Poupança', label: 'Poupança' },
  { value: 'current', label: 'Corrente' },
  { value: 'savings', label: 'Poupança' }
];

/**
 * Get account type label by value
 */
export function getAccountTypeLabel(value: string): string {
  const accountType = BANK_ACCOUNT_TYPES.find(type => type.value === value);
  return accountType ? accountType.label : value;
}

/**
 * Normalize account type to standard values (Portuguese)
 */
export function normalizeAccountType(value: string): string {
  const lowerValue = value.toLowerCase();
  
  if (lowerValue === 'current' || lowerValue === 'corrente') {
    return 'Corrente';
  }
  
  if (lowerValue === 'savings' || lowerValue === 'poupança' || lowerValue === 'poupanca') {
    return 'Poupança';
  }
  
  return value;
}