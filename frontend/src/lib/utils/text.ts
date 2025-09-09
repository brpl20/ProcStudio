/**
 * Truncates text to a specified length and adds ellipsis if needed
 * @param text - The text to truncate
 * @param maxLength - Maximum length including ellipsis
 * @returns Truncated text with ellipsis if needed
 */
export function truncateText(text: string, maxLength: number): string {
  if (!text) {
    return '';
  }
  if (text.length <= maxLength) {
    return text;
  }

  // Account for ellipsis (3 characters: "...")
  const truncatedLength = maxLength - 3;
  return text.substring(0, truncatedLength) + '...';
}

/**
 * Truncates text to 20 characters with ellipsis
 * @param text - The text to truncate
 * @returns Text truncated to 20 characters with ellipsis if needed
 */
export function truncateDescription(text: string): string {
  return truncateText(text, 25);
}
