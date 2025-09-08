import { getCurrentInssConstants } from '../constants/formOptions';

/**
 * Validates pro-labore amount based on current INSS regulations
 * @param amount - The pro-labore amount to validate
 * @returns Error message if invalid, null if valid
 */
export function validateProLaboreAmount(amount: number): string | null {
  const { minimumWage } = getCurrentInssConstants();

  if (amount < 0) {
    return 'Valor não pode ser negativo';
  }

  if (amount > 0 && amount < minimumWage) {
    return `Valor deve ser maior ou igual ao salário mínimo (R$ ${minimumWage.toLocaleString('pt-BR', { minimumFractionDigits: 2 })})`;
  }

  return null;
}
