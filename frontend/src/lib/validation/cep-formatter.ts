/**
 * CEP Formatter utilities
 * Handles all CEP string formatting operations
 */
export class CEPFormatter {
  private static readonly CEP_REGEX = /^\d{8}$/;
  private static readonly CEP_FORMAT_REGEX = /(\d{5})(\d{3})/;
  private static readonly NON_DIGIT_REGEX = /[^\d]/g;

  /**
   * Remove all non-numeric characters from CEP
   */
  static clean(cep: string): string {
    if (!cep) {
      return '';
    }
    return cep.replace(CEPFormatter.NON_DIGIT_REGEX, '');
  }

  /**
   * Format CEP for display (xxxxx-xxx)
   */
  static format(cep: string): string {
    const cleaned = CEPFormatter.clean(cep);
    if (cleaned.length !== 8) {
      return cep;
    }
    return cleaned.replace(CEPFormatter.CEP_FORMAT_REGEX, '$1-$2');
  }

  /**
   * Check if CEP has valid format
   */
  static isValidFormat(cep: string): boolean {
    const cleaned = CEPFormatter.clean(cep);
    return cleaned.length === 8 && CEPFormatter.CEP_REGEX.test(cleaned);
  }

  /**
   * Check for obviously invalid patterns
   */
  static hasInvalidPattern(cep: string): boolean {
    const cleaned = CEPFormatter.clean(cep);
    // All zeros or all same digits
    return cleaned === '00000000' || /^(\d)\1{7}$/.test(cleaned);
  }
}