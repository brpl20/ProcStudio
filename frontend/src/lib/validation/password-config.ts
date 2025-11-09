/**
 * Password Configuration and Advanced Validation
 * Configurable password requirements with instant validation
 */

export interface PasswordConfig {
  minLength: number;
  minNumbers: number;
  minSpecialChars: number;
  minUppercase: number;
  minLowercase: number;
  requireStrong: boolean;
}

// Default password configuration
export const DEFAULT_PASSWORD_CONFIG: PasswordConfig = {
  minLength: 6,
  minNumbers: 1,
  minSpecialChars: 1,
  minUppercase: 1,
  minLowercase: 0, // Not required by default but can be configured
  requireStrong: true
};

// Special characters that are considered valid
export const SPECIAL_CHARACTERS = '!@#$%^&*()_+-=[]{}|;:"\',.<>?/\\`~';

export interface PasswordValidationResult {
  isValid: boolean;
  errors: string[];
  strength: number; // 0-5 scale
  details: {
    hasMinLength: boolean;
    hasMinNumbers: boolean;
    hasMinSpecialChars: boolean;
    hasMinUppercase: boolean;
    hasMinLowercase: boolean;
    lengthCount: number;
    numbersCount: number;
    specialCharsCount: number;
    uppercaseCount: number;
    lowercaseCount: number;
  };
}

/**
 * Count occurrences of a pattern in a string
 */
function countMatches(str: string, pattern: RegExp): number {
  const matches = str.match(pattern);
  return matches ? matches.length : 0;
}

/**
 * Validate password against configuration
 */
export function validatePassword(
  password: string,
  config: PasswordConfig = DEFAULT_PASSWORD_CONFIG
): PasswordValidationResult {
  const errors: string[] = [];

  // Count different character types
  const lengthCount = password.length;
  const numbersCount = countMatches(password, /[0-9]/g);
  const specialCharsCount = countMatches(password, /[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/g);
  const uppercaseCount = countMatches(password, /[A-Z]/g);
  const lowercaseCount = countMatches(password, /[a-z]/g);

  // Check requirements
  const hasMinLength = lengthCount >= config.minLength;
  const hasMinNumbers = numbersCount >= config.minNumbers;
  const hasMinSpecialChars = specialCharsCount >= config.minSpecialChars;
  const hasMinUppercase = uppercaseCount >= config.minUppercase;
  const hasMinLowercase = lowercaseCount >= config.minLowercase;

  // Build error messages
  if (!hasMinLength) {
    errors.push(`Mínimo de ${config.minLength} caracteres`);
  }
  if (!hasMinNumbers && config.minNumbers > 0) {
    errors.push(`Mínimo de ${config.minNumbers} número${config.minNumbers > 1 ? 's' : ''}`);
  }
  if (!hasMinSpecialChars && config.minSpecialChars > 0) {
    errors.push(`Mínimo de ${config.minSpecialChars} caractere${config.minSpecialChars > 1 ? 's' : ''} especial${config.minSpecialChars > 1 ? 'is' : ''}`);
  }
  if (!hasMinUppercase && config.minUppercase > 0) {
    errors.push(`Mínimo de ${config.minUppercase} letra${config.minUppercase > 1 ? 's' : ''} maiúscula${config.minUppercase > 1 ? 's' : ''}`);
  }
  if (!hasMinLowercase && config.minLowercase > 0) {
    errors.push(`Mínimo de ${config.minLowercase} letra${config.minLowercase > 1 ? 's' : ''} minúscula${config.minLowercase > 1 ? 's' : ''}`);
  }

  // Calculate strength (0-5)
  let strength = 0;
  if (lengthCount >= 6) {
    strength++;
  }
  if (lengthCount >= 8) {
    strength++;
  }
  if (lengthCount >= 12) {
    strength++;
  }
  if (numbersCount > 0) {
    strength++;
  }
  if (specialCharsCount > 0) {
    strength++;
  }
  if (uppercaseCount > 0 && lowercaseCount > 0) {
    strength++;
  }

  // Cap strength at 5
  strength = Math.min(strength, 5);

  return {
    isValid: errors.length === 0,
    errors,
    strength,
    details: {
      hasMinLength,
      hasMinNumbers,
      hasMinSpecialChars,
      hasMinUppercase,
      hasMinLowercase,
      lengthCount,
      numbersCount,
      specialCharsCount,
      uppercaseCount,
      lowercaseCount
    }
  };
}

/**
 * Validate password confirmation
 */
export function validatePasswordConfirmation(
  password: string,
  confirmation: string
): { isValid: boolean; error?: string } {
  if (!confirmation) {
    return { isValid: false, error: 'Confirmação de senha é obrigatória' };
  }

  if (password !== confirmation) {
    return { isValid: false, error: 'As senhas não coincidem' };
  }

  return { isValid: true };
}

/**
 * Get strength label in Portuguese
 */
export function getStrengthLabel(strength: number): string {
  switch (strength) {
    case 0:
      return 'Muito fraca';
    case 1:
      return 'Fraca';
    case 2:
      return 'Razoável';
    case 3:
      return 'Boa';
    case 4:
      return 'Forte';
    case 5:
      return 'Muito forte';
    default:
      return 'Muito fraca';
  }
}

/**
 * Get strength color for UI
 */
export function getStrengthColor(strength: number): string {
  switch (strength) {
    case 0:
    case 1:
      return 'error'; // Red
    case 2:
      return 'warning'; // Yellow
    case 3:
      return 'info'; // Blue
    case 4:
    case 5:
      return 'success'; // Green
    default:
      return 'error';
  }
}

/**
 * Format requirements for display
 */
export function formatRequirements(config: PasswordConfig = DEFAULT_PASSWORD_CONFIG): string[] {
  const requirements: string[] = [];

  requirements.push(`Mínimo de ${config.minLength} caracteres`);

  if (config.minNumbers > 0) {
    requirements.push(`Pelo menos ${config.minNumbers} número${config.minNumbers > 1 ? 's' : ''}`);
  }

  if (config.minSpecialChars > 0) {
    requirements.push(`Pelo menos ${config.minSpecialChars} caractere${config.minSpecialChars > 1 ? 's' : ''} especial${config.minSpecialChars > 1 ? 'is' : ''}`);
  }

  if (config.minUppercase > 0) {
    requirements.push(`Pelo menos ${config.minUppercase} letra${config.minUppercase > 1 ? 's' : ''} maiúscula${config.minUppercase > 1 ? 's' : ''}`);
  }

  if (config.minLowercase > 0) {
    requirements.push(`Pelo menos ${config.minLowercase} letra${config.minLowercase > 1 ? 's' : ''} minúscula${config.minLowercase > 1 ? 's' : ''}`);
  }

  return requirements;
}

/**
 * Real-time password validation for UI feedback
 */
export function getPasswordFeedback(
  password: string,
  config: PasswordConfig = DEFAULT_PASSWORD_CONFIG
): {
  requirements: Array<{ text: string; met: boolean }>;
  strength: number;
  strengthLabel: string;
  strengthColor: string;
  isValid: boolean;
} {
  const validation = validatePassword(password, config);

  const requirements = [
    {
      text: `Mínimo de ${config.minLength} caracteres`,
      met: validation.details.hasMinLength
    }
  ];

  if (config.minNumbers > 0) {
    requirements.push({
      text: `Pelo menos ${config.minNumbers} número${config.minNumbers > 1 ? 's' : ''}`,
      met: validation.details.hasMinNumbers
    });
  }

  if (config.minSpecialChars > 0) {
    requirements.push({
      text: `Pelo menos ${config.minSpecialChars} caractere${config.minSpecialChars > 1 ? 's' : ''} especial${config.minSpecialChars > 1 ? 'is' : ''}`,
      met: validation.details.hasMinSpecialChars
    });
  }

  if (config.minUppercase > 0) {
    requirements.push({
      text: `Pelo menos ${config.minUppercase} letra${config.minUppercase > 1 ? 's' : ''} maiúscula${config.minUppercase > 1 ? 's' : ''}`,
      met: validation.details.hasMinUppercase
    });
  }

  if (config.minLowercase > 0) {
    requirements.push({
      text: `Pelo menos ${config.minLowercase} letra${config.minLowercase > 1 ? 's' : ''} minúscula${config.minLowercase > 1 ? 's' : ''}`,
      met: validation.details.hasMinLowercase
    });
  }

  return {
    requirements,
    strength: validation.strength,
    strengthLabel: getStrengthLabel(validation.strength),
    strengthColor: getStrengthColor(validation.strength),
    isValid: validation.isValid
  };
}