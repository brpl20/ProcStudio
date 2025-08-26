/**
 * Brazilian States Constants
 * 
 * This file contains the list of Brazilian states used throughout the application.
 * Extracted from CustomerForm.svelte for better maintainability and reusability.
 */

export interface BrazilianState {
  value: string;
  label: string;
}

/**
 * Complete list of Brazilian states with their abbreviations and full names
 */
export const BRAZILIAN_STATES: BrazilianState[] = [
  { value: 'AC', label: 'Acre' },
  { value: 'AL', label: 'Alagoas' },
  { value: 'AP', label: 'Amapá' },
  { value: 'AM', label: 'Amazonas' },
  { value: 'BA', label: 'Bahia' },
  { value: 'CE', label: 'Ceará' },
  { value: 'DF', label: 'Distrito Federal' },
  { value: 'ES', label: 'Espírito Santo' },
  { value: 'GO', label: 'Goiás' },
  { value: 'MA', label: 'Maranhão' },
  { value: 'MT', label: 'Mato Grosso' },
  { value: 'MS', label: 'Mato Grosso do Sul' },
  { value: 'MG', label: 'Minas Gerais' },
  { value: 'PA', label: 'Pará' },
  { value: 'PB', label: 'Paraíba' },
  { value: 'PR', label: 'Paraná' },
  { value: 'PE', label: 'Pernambuco' },
  { value: 'PI', label: 'Piauí' },
  { value: 'RJ', label: 'Rio de Janeiro' },
  { value: 'RN', label: 'Rio Grande do Norte' },
  { value: 'RS', label: 'Rio Grande do Sul' },
  { value: 'RO', label: 'Rondônia' },
  { value: 'RR', label: 'Roraima' },
  { value: 'SC', label: 'Santa Catarina' },
  { value: 'SP', label: 'São Paulo' },
  { value: 'SE', label: 'Sergipe' },
  { value: 'TO', label: 'Tocantins' }
];

/**
 * Get a state by its abbreviation
 * @param abbreviation - The state abbreviation (e.g., 'SP', 'RJ')
 * @returns The state object or undefined if not found
 */
export function getStateByAbbreviation(abbreviation: string): BrazilianState | undefined {
  return BRAZILIAN_STATES.find(state => state.value === abbreviation);
}

/**
 * Get a state by its full name
 * @param name - The state full name (e.g., 'São Paulo', 'Rio de Janeiro')
 * @returns The state object or undefined if not found
 */
export function getStateByName(name: string): BrazilianState | undefined {
  return BRAZILIAN_STATES.find(state => state.label.toLowerCase() === name.toLowerCase());
}

/**
 * Get all state abbreviations
 * @returns Array of state abbreviations
 */
export function getStateAbbreviations(): string[] {
  return BRAZILIAN_STATES.map(state => state.value);
}

/**
 * Get all state names
 * @returns Array of state names
 */
export function getStateNames(): string[] {
  return BRAZILIAN_STATES.map(state => state.label);
}