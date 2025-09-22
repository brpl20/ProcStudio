/**
 * Brazilian CPF (Cadastro de Pessoas Físicas) Generator and Validator
 * Generates valid CPF numbers for testing purposes
 */

class CPFGenerator {
  /**
   * Generates a valid CPF number
   * @returns {string} A valid CPF in the format XXX.XXX.XXX-XX
   */
  static generate() {
    // Generate first 9 digits randomly
    const firstNineDigits = Array.from({ length: 9 }, () =>
      Math.floor(Math.random() * 10),
    );

    // Calculate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(firstNineDigits);

    // Calculate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit([
      ...firstNineDigits,
      firstCheckDigit,
    ]);

    // Combine all digits
    const allDigits = [...firstNineDigits, firstCheckDigit, secondCheckDigit];

    // Format as XXX.XXX.XXX-XX
    return this.formatCPF(allDigits);
  }

  /**
   * Generates a valid CPF number without formatting
   * @returns {string} A valid CPF as 11 digits string
   */
  static generateUnformatted() {
    // Generate first 9 digits randomly
    const firstNineDigits = Array.from({ length: 9 }, () =>
      Math.floor(Math.random() * 10),
    );

    // Calculate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(firstNineDigits);

    // Calculate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit([
      ...firstNineDigits,
      firstCheckDigit,
    ]);

    // Combine all digits
    const allDigits = [...firstNineDigits, firstCheckDigit, secondCheckDigit];

    return allDigits.join("");
  }

  /**
   * Calculates the first check digit of CPF
   * @param {number[]} digits - First 9 digits of CPF
   * @returns {number} First check digit
   */
  static calculateFirstCheckDigit(digits) {
    let sum = 0;
    for (let i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }

    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  /**
   * Calculates the second check digit of CPF
   * @param {number[]} digits - First 10 digits of CPF (9 digits + first check digit)
   * @returns {number} Second check digit
   */
  static calculateSecondCheckDigit(digits) {
    let sum = 0;
    for (let i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }

    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  /**
   * Formats CPF digits as XXX.XXX.XXX-XX
   * @param {number[]} digits - 11 CPF digits
   * @returns {string} Formatted CPF
   */
  static formatCPF(digits) {
    const cpfString = digits.join("");
    return `${cpfString.substring(0, 3)}.${cpfString.substring(3, 6)}.${cpfString.substring(6, 9)}-${cpfString.substring(9, 11)}`;
  }

  /**
   * Validates a CPF number
   * @param {string} cpf - CPF to validate (formatted or unformatted)
   * @returns {boolean} True if CPF is valid
   */
  static isValid(cpf) {
    // Remove formatting
    const cleanCPF = cpf.replace(/[^\d]/g, "");

    // Check if has 11 digits
    if (cleanCPF.length !== 11) return false;

    // Check if all digits are the same (invalid CPFs)
    if (/^(\d)\1{10}$/.test(cleanCPF)) return false;

    // Convert to array of numbers
    const digits = cleanCPF.split("").map(Number);

    // Validate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(digits.slice(0, 9));
    if (digits[9] !== firstCheckDigit) return false;

    // Validate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit(
      digits.slice(0, 10),
    );
    if (digits[10] !== secondCheckDigit) return false;

    return true;
  }

  /**
   * Generates multiple valid CPFs for testing
   * @param {number} count - Number of CPFs to generate
   * @param {boolean} formatted - Whether to return formatted CPFs
   * @returns {string[]} Array of valid CPFs
   */
  static generateMultiple(count, formatted = true) {
    return Array.from({ length: count }, () =>
      formatted ? this.generate() : this.generateUnformatted(),
    );
  }
}

const { spawn } = require('child_process');

function copyToClipboard(text) {
  return new Promise((resolve, reject) => {
    let cp;
    if (process.platform === 'darwin') {
      cp = spawn('pbcopy');
    } else if (process.platform === 'win32') {
      cp = spawn('clip');
    } else {
      // Linux/other: try xclip then xsel; ignore if not available
      cp = spawn('xclip', ['-selection', 'clipboard']);
      cp.on('error', () => {
        const cp2 = spawn('xsel', ['--clipboard', '--input']);
        cp2.on('error', reject);
        cp2.stdin.end(text);
        cp2.on('close', code => (code === 0 ? resolve() : reject(new Error('xsel failed'))));
      });
      cp.stdin.end(text);
      cp.on('close', code => (code === 0 ? resolve() : reject(new Error('xclip failed'))));
      return;
    }

    cp.on('error', reject);
    cp.stdin.end(text);
    cp.on('close', code => (code === 0 ? resolve() : reject(new Error('clipboard command failed'))));
  });
}

// Run when script is executed directly (not required as module)
if (require.main === module) {
  (async function main() {
    const cpf = CPFGenerator.generate();
    const useConsole = process.argv.includes('--console');
    
    console.log(cpf);
    
    if (!useConsole) {
      try {
        await copyToClipboard(cpf);
      } catch {}
    }
  })();
}

module.exports = CPFGenerator;