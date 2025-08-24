# frozen_string_literal: true

class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    return if value.nil? && options[:allow_nil]

    return if valid_cpf?(value)

    record.errors.add(attribute, options[:message] || 'is not a valid CPF')
  end

  private

  def valid_cpf?(cpf)
    return false if cpf.nil?

    # Remove non-numeric characters
    cpf_numbers = cpf.to_s.gsub(/[^0-9]/, '')

    # CPF must have 11 digits
    return false unless cpf_numbers.length == 11

    # Check for known invalid CPFs (all same digits)
    return false if cpf_numbers.chars.uniq.size == 1

    # Calculate first check digit
    sum = 0
    9.times { |i| sum += cpf_numbers[i].to_i * (10 - i) }
    first_digit = ((sum * 10) % 11) % 10

    return false unless first_digit == cpf_numbers[9].to_i

    # Calculate second check digit
    sum = 0
    10.times { |i| sum += cpf_numbers[i].to_i * (11 - i) }
    second_digit = ((sum * 10) % 11) % 10

    second_digit == cpf_numbers[10].to_i
  end
end
