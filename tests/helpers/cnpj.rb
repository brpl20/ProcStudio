# frozen_string_literal: true

# Brazilian CNPJ (Cadastro Nacional da Pessoa Jurídica) Generator
# Generates valid CNPJ numbers for testing purposes
class CnpjGenerator
  class << self
    # Generates a valid CNPJ number
    # @return [String] A valid CNPJ in the format XX.XXX.XXX/XXXX-XX
    def generate(formatted: true)
      # Generate first 12 digits randomly (8 digits for root + 4 for branch)
      first_eight = Array.new(8) { rand(10) }
      branch = [0, 0, 0, 1] # Standard branch number

      base_digits = first_eight + branch

      # Calculate first check digit
      first_check = calculate_first_check_digit(base_digits)

      # Calculate second check digit
      second_check = calculate_second_check_digit(base_digits + [first_check])

      # Combine all digits
      all_digits = base_digits + [first_check, second_check]

      # Return formatted or unformatted
      formatted ? format_cnpj(all_digits) : all_digits.join
    end

    # Generates a valid CNPJ number without formatting
    # @return [String] A valid CNPJ as 14 digits string
    def generate_unformatted
      generate(formatted: false)
    end

    # Formats CNPJ digits as XX.XXX.XXX/XXXX-XX
    # @param digits [Array<Integer>] 14 CNPJ digits
    # @return [String] Formatted CNPJ
    def format_cnpj(digits)
      cnpj = digits.join
      "#{cnpj[0..1]}.#{cnpj[2..4]}.#{cnpj[5..7]}/#{cnpj[8..11]}-#{cnpj[12..13]}"
    end

    # Validates a CNPJ number
    # @param cnpj [String] CNPJ to validate (formatted or unformatted)
    # @return [Boolean] True if CNPJ is valid
    def valid?(cnpj)
      return false if cnpj.nil?

      # Remove formatting
      clean_cnpj = cnpj.to_s.gsub(/\D/, '')

      # Check if has 14 digits
      return false if clean_cnpj.length != 14

      # Check if all digits are the same (invalid CNPJs)
      return false if clean_cnpj.chars.uniq.length == 1

      # Convert to array of integers
      digits = clean_cnpj.chars.map(&:to_i)

      # Validate first check digit
      first_check = calculate_first_check_digit(digits[0..11])
      return false if digits[12] != first_check

      # Validate second check digit
      second_check = calculate_second_check_digit(digits[0..12])
      return false if digits[13] != second_check

      true
    end

    # Generates multiple valid CNPJs for testing
    # @param count [Integer] Number of CNPJs to generate
    # @param formatted [Boolean] Whether to return formatted CNPJs
    # @return [Array<String>] Array of valid CNPJs
    def generate_multiple(count, formatted: true)
      Array.new(count) { generate(formatted: formatted) }
    end

    # Gets a list of known valid CNPJs for testing
    # @return [Array<String>] Array of valid test CNPJs
    def test_cnpjs
      [
        '11.222.333/0001-81',
        '11.444.777/0001-35',
        '00.000.000/0001-91',
        '11.111.111/1111-11',
        '22.222.222/2222-22'
      ]
    end

    # Gets a random valid test CNPJ
    # @return [String] A valid test CNPJ
    def random_test_cnpj
      test_cnpjs.sample
    end

    private

    # Calculates the first check digit of CNPJ
    # @param digits [Array<Integer>] First 12 digits of CNPJ
    # @return [Integer] First check digit
    def calculate_first_check_digit(digits)
      weights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

      sum = digits.each_with_index.reduce(0) do |acc, (digit, index)|
        acc + (digit * weights[index])
      end

      remainder = sum % 11
      remainder < 2 ? 0 : 11 - remainder
    end

    # Calculates the second check digit of CNPJ
    # @param digits [Array<Integer>] First 13 digits of CNPJ
    # @return [Integer] Second check digit
    def calculate_second_check_digit(digits)
      weights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

      sum = digits.each_with_index.reduce(0) do |acc, (digit, index)|
        acc + (digit * weights[index])
      end

      remainder = sum % 11
      remainder < 2 ? 0 : 11 - remainder
    end
  end
end

# Run when script is executed directly
puts "Generated CNPJ: #{CnpjGenerator.generate}" if __FILE__ == $PROGRAM_NAME
