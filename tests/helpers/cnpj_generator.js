/**
 * Brazilian CNPJ (Cadastro Nacional da Pessoa Jurídica) Generator and Validator
 * Generates valid CNPJ numbers for testing purposes
 */

class CNPJGenerator {
  /**
   * Generates a valid CNPJ number
   * @returns {string} A valid CNPJ in the format XX.XXX.XXX/XXXX-XX
   */
  static generate() {
    // Generate first 12 digits randomly
    const firstTwelveDigits = Array.from({ length: 12 }, () =>
      Math.floor(Math.random() * 10),
    );

    // Calculate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(firstTwelveDigits);

    // Calculate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit([
      ...firstTwelveDigits,
      firstCheckDigit,
    ]);

    // Combine all digits
    const allDigits = [...firstTwelveDigits, firstCheckDigit, secondCheckDigit];

    // Format as XX.XXX.XXX/XXXX-XX
    return this.formatCNPJ(allDigits);
  }

  /**
   * Generates a valid CNPJ number without formatting
   * @returns {string} A valid CNPJ as 14 digits string
   */
  static generateUnformatted() {
    // Generate first 12 digits randomly
    const firstTwelveDigits = Array.from({ length: 12 }, () =>
      Math.floor(Math.random() * 10),
    );

    // Calculate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(firstTwelveDigits);

    // Calculate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit([
      ...firstTwelveDigits,
      firstCheckDigit,
    ]);

    // Combine all digits
    const allDigits = [...firstTwelveDigits, firstCheckDigit, secondCheckDigit];

    return allDigits.join("");
  }

  /**
   * Calculates the first check digit of CNPJ
   * @param {number[]} digits - First 12 digits of CNPJ
   * @returns {number} First check digit
   */
  static calculateFirstCheckDigit(digits) {
    const weights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    let sum = 0;

    for (let i = 0; i < 12; i++) {
      sum += digits[i] * weights[i];
    }

    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  /**
   * Calculates the second check digit of CNPJ
   * @param {number[]} digits - First 13 digits of CNPJ (12 digits + first check digit)
   * @returns {number} Second check digit
   */
  static calculateSecondCheckDigit(digits) {
    const weights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    let sum = 0;

    for (let i = 0; i < 13; i++) {
      sum += digits[i] * weights[i];
    }

    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  /**
   * Formats CNPJ digits as XX.XXX.XXX/XXXX-XX
   * @param {number[]} digits - 14 CNPJ digits
   * @returns {string} Formatted CNPJ
   */
  static formatCNPJ(digits) {
    const cnpjString = digits.join("");
    return `${cnpjString.substring(0, 2)}.${cnpjString.substring(2, 5)}.${cnpjString.substring(5, 8)}/${cnpjString.substring(8, 12)}-${cnpjString.substring(12, 14)}`;
  }

  /**
   * Validates a CNPJ number
   * @param {string} cnpj - CNPJ to validate (formatted or unformatted)
   * @returns {boolean} True if CNPJ is valid
   */
  static isValid(cnpj) {
    // Remove formatting
    const cleanCNPJ = cnpj.replace(/[^\d]/g, "");

    // Check if has 14 digits
    if (cleanCNPJ.length !== 14) return false;

    // Check if all digits are the same (invalid CNPJs)
    if (/^(\d)\1{13}$/.test(cleanCNPJ)) return false;

    // Convert to array of numbers
    const digits = cleanCNPJ.split("").map(Number);

    // Validate first check digit
    const firstCheckDigit = this.calculateFirstCheckDigit(digits.slice(0, 12));
    if (digits[12] !== firstCheckDigit) return false;

    // Validate second check digit
    const secondCheckDigit = this.calculateSecondCheckDigit(
      digits.slice(0, 13),
    );
    if (digits[13] !== secondCheckDigit) return false;

    return true;
  }

  /**
   * Generates multiple valid CNPJs for testing
   * @param {number} count - Number of CNPJs to generate
   * @param {boolean} formatted - Whether to return formatted CNPJs
   * @returns {string[]} Array of valid CNPJs
   */
  static generateMultiple(count, formatted = true) {
    return Array.from({ length: count }, () =>
      formatted ? this.generate() : this.generateUnformatted(),
    );
  }

  /**
   * Gets a list of known valid CNPJs for testing
   * @returns {string[]} Array of valid test CNPJs
   */
  static getTestCNPJs() {
    return [
      "11.222.333/0001-81",
      "11.444.777/0001-61",
      "12.345.678/0001-95",
      "98.765.432/0001-10",
      "14.725.836/0001-09",
    ];
  }

  /**
   * Gets a random valid test CNPJ
   * @returns {string} A valid test CNPJ
   */
  static getRandomTestCNPJ() {
    const testCNPJs = this.getTestCNPJs();
    return testCNPJs[Math.floor(Math.random() * testCNPJs.length)];
  }

  /**
   * Creates test company objects with valid CNPJs for E2E testing
   * @param {number} count - Number of test companies to create
   * @returns {Object[]} Array of test company objects with valid CNPJs
   */
  static createTestCompanies(count = 3) {
    const companyTypes = ["Ltda", "S.A.", "EIRELI"];
    const companies = [];

    for (let i = 0; i < count; i++) {
      const type = companyTypes[i % companyTypes.length];
      companies.push({
        companyName: `E2E Test Company ${i + 1} ${type}`,
        tradeName: `Test Company ${i + 1}`,
        email: `company${i + 1}@e2etest.com`,
        phone: `(11) ${String(1234 + i).padStart(4, "0")}-${String(5678 + i).padStart(4, "0")}`,
        cnpj: this.generate(), // Use formatted CNPJ for display
        address: `${123 + i * 100} Business Street`,
        city: "São Paulo",
        state: "SP",
        zipCode: `${String(12345 + i).padStart(5, "0")}-${String(678 + i).padStart(3, "0")}`,
        businessType: type,
      });
    }

    return companies;
  }

  /**
   * Validates multiple CNPJs at once
   * @param {string[]} cnpjs - Array of CNPJs to validate
   * @returns {Object} Validation results with valid/invalid counts
   */
  static validateMultiple(cnpjs) {
    const results = {
      total: cnpjs.length,
      valid: 0,
      invalid: 0,
      validCNPJs: [],
      invalidCNPJs: [],
    };

    cnpjs.forEach((cnpj) => {
      if (this.isValid(cnpj)) {
        results.valid++;
        results.validCNPJs.push(cnpj);
      } else {
        results.invalid++;
        results.invalidCNPJs.push(cnpj);
      }
    });

    return results;
  }
}

module.exports = CNPJGenerator;
