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

  /**
   * Gets a list of known valid CPFs for testing
   * @returns {string[]} Array of valid test CPFs
   */
  static getTestCPFs() {
    return [
      "058.802.539-96",
      "111.444.777-35",
      "123.456.789-09",
      "987.654.321-00",
      "147.258.369-27",
    ];
  }

  /**
   * Gets a random valid test CPF
   * @returns {string} A valid test CPF
   */
  static getRandomTestCPF() {
    const testCPFs = this.getTestCPFs();
    return testCPFs[Math.floor(Math.random() * testCPFs.length)];
  }

  /**
   * Creates test user objects with valid CPFs for E2E testing
   * @param {number} count - Number of test users to create
   * @returns {Object[]} Array of test user objects with valid CPFs
   */
  static createTestUsers(count = 3) {
    const roles = ["admin", "user", "lawyer"];
    const users = [];

    for (let i = 0; i < count; i++) {
      const role = roles[i % roles.length];
      users.push({
        email: `${role}${i > 0 ? i + 1 : ""}@e2etest.procstudio.com`,
        password: "E2ETestPass123!",
        role: role,
        cpf: this.generateUnformatted(),
        firstName: `Test${role.charAt(0).toUpperCase() + role.slice(1)}`,
        lastName: `User${i > 0 ? i + 1 : ""}`,
        phone: `(555) ${String(123 + i).padStart(3, "0")}-${String(4567 + i).padStart(4, "0")}`,
      });
    }

    return users;
  }

  /**
   * Creates test client objects with valid CPFs for E2E testing
   * @param {number} count - Number of test clients to create
   * @returns {Object[]} Array of test client objects with valid CPFs
   */
  static createTestClients(count = 2) {
    const clients = [];

    for (let i = 0; i < count; i++) {
      clients.push({
        name: `E2E Test Client ${i + 1}`,
        email: `client${i + 1}@e2etest.com`,
        phone: `(555) ${String(123 + i).padStart(3, "0")}-${String(4567 + i).padStart(4, "0")}`,
        cpf: this.generate(), // Use formatted CPF for display
        address: `${123 + i * 100} Test Street`,
        city: "São Paulo",
        state: "SP",
        zipCode: `${String(12345 + i).padStart(5, "0")}-${String(678 + i).padStart(3, "0")}`,
      });
    }

    return clients;
  }

  /**
   * Validates multiple CPFs at once
   * @param {string[]} cpfs - Array of CPFs to validate
   * @returns {Object} Validation results with valid/invalid counts
   */
  static validateMultiple(cpfs) {
    const results = {
      total: cpfs.length,
      valid: 0,
      invalid: 0,
      validCPFs: [],
      invalidCPFs: [],
    };

    cpfs.forEach((cpf) => {
      if (this.isValid(cpf)) {
        results.valid++;
        results.validCPFs.push(cpf);
      } else {
        results.invalid++;
        results.invalidCPFs.push(cpf);
      }
    });

    return results;
  }
}

module.exports = CPFGenerator;
