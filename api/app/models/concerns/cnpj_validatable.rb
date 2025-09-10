# File: app/models/concerns/cnpj_validatable.rb
# frozen_string_literal: true

module CnpjValidatable
  extend ActiveSupport::Concern

  included do
    validates :cnpj, presence: true, uniqueness: true
    validate :cnpj_format_valid
    before_save :normalize_cnpj
  end

  # Instance methods available to including classes
  def formatted_cnpj
    return nil if cnpj.blank?

    clean = cnpj.gsub(/\D/, '')
    return cnpj if clean.length != 14

    "#{clean[0..1]}.#{clean[2..4]}.#{clean[5..7]}/#{clean[8..11]}-#{clean[12..13]}"
  end

  def cnpj_digits_only
    cnpj&.gsub(/\D/, '')
  end

  private

  def normalize_cnpj
    self.cnpj = cnpj.gsub(/\D/, '') if cnpj.present?
  end

  def cnpj_format_valid
    return if cnpj.blank?

    clean_cnpj = cnpj.gsub(/\D/, '')

    # Check basic format
    unless clean_cnpj.match?(/\A\d{14}\z/)
      errors.add(:cnpj, 'must have exactly 14 digits')
      return
    end

    # Check for invalid patterns (all same digits)
    if clean_cnpj.chars.uniq.length == 1
      errors.add(:cnpj, 'cannot have all identical digits')
      return
    end

    # Validate checksum
    return if valid_cnpj_checksum?(clean_cnpj)

    errors.add(:cnpj, 'has invalid checksum')
  end

  def valid_cnpj_checksum?(cnpj)
    return false if cnpj.length != 14

    digits = cnpj.chars.map(&:to_i)

    # Validate first check digit
    first_check = calculate_check_digit(digits[0..11], first_check_weights)
    return false if digits[12] != first_check

    # Validate second check digit
    second_check = calculate_check_digit(digits[0..12], second_check_weights)
    return false if digits[13] != second_check

    true
  end

  def calculate_check_digit(digits, weights)
    sum = digits.each_with_index.sum { |digit, index| digit * weights[index] }
    remainder = sum % 11
    remainder < 2 ? 0 : 11 - remainder
  end

  def first_check_weights
    [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  end

  def second_check_weights
    [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  end

  # Class methods
  module ClassMethods
    def find_by_cnpj(cnpj_input)
      clean_cnpj = cnpj_input.to_s.gsub(/\D/, '')
      find_by(cnpj: clean_cnpj)
    end

    def with_cnpj_like(partial_cnpj)
      clean_partial = partial_cnpj.to_s.gsub(/\D/, '')
      where('cnpj LIKE ?', "#{clean_partial}%")
    end
  end
end
