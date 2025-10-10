import type { Lawyer } from '../api/types/user.lawyer';

/**
 * Get the full name of a lawyer
 * @param lawyer - The lawyer object
 * @returns The full name as a string
 */
export function getFullName(lawyer: Lawyer): string {
  if (!lawyer?.attributes) return '';
  return `${lawyer.attributes.name} ${lawyer.attributes.last_name || ''}`.trim();
}

/**
 * Get lawyer display name with optional OAB
 * @param lawyer - The lawyer object
 * @param includeOab - Whether to include OAB number
 * @returns Formatted display name
 */
export function getLawyerDisplayName(lawyer: Lawyer, includeOab = false): string {
  const fullName = getFullName(lawyer);
  if (includeOab && lawyer.attributes?.oab) {
    return `${fullName} - OAB: ${lawyer.attributes.oab}`;
  }
  return fullName;
}

/**
 * Filter available lawyers excluding already selected ones
 * @param allLawyers - All available lawyers
 * @param selectedIds - IDs of already selected lawyers
 * @param excludeCurrentId - Optional ID to exclude from filtering
 * @returns Filtered list of available lawyers
 */
export function getAvailableLawyers(
  allLawyers: Lawyer[], 
  selectedIds: string[], 
  excludeCurrentId?: string
): Lawyer[] {
  const idsToExclude = excludeCurrentId 
    ? selectedIds.filter(id => id !== excludeCurrentId)
    : selectedIds;
    
  return allLawyers.filter(lawyer => !idsToExclude.includes(lawyer.id));
}

/**
 * Check if a lawyer is active
 * @param lawyer - The lawyer object
 * @returns True if lawyer is active
 */
export function isActiveLawyer(lawyer: Lawyer): boolean {
  return lawyer.attributes?.status === 'active';
}

/**
 * Sort lawyers by name
 * @param lawyers - Array of lawyers to sort
 * @param order - Sort order ('asc' or 'desc')
 * @returns Sorted array of lawyers
 */
export function sortLawyersByName(lawyers: Lawyer[], order: 'asc' | 'desc' = 'asc'): Lawyer[] {
  return [...lawyers].sort((a, b) => {
    const nameA = getFullName(a).toLowerCase();
    const nameB = getFullName(b).toLowerCase();
    
    if (order === 'asc') {
      return nameA.localeCompare(nameB);
    } else {
      return nameB.localeCompare(nameA);
    }
  });
}

/**
 * Normalize lawyer_id to string from various input formats
 * @param val - Lawyer ID as string, object with id, or null/undefined
 * @returns Normalized string ID or empty string
 */
export function toLawyerId(val: string | { id: string } | null | undefined): string {
  if (typeof val === 'string') return val;
  if (val && typeof val === 'object' && 'id' in val) return (val as any).id;
  return '';
}

/**
 * Format currency in Brazilian Real format
 * @param val - Number to format
 * @returns Formatted currency string
 */
export function formatCurrency(val: number): string {
  return val.toLocaleString('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}