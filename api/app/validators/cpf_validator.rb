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

    cpf_numbers = normalize_cpf(cpf)
    return false unless valid_cpf_format?(cpf_numbers)

    validate_check_digits(cpf_numbers)
  end

  def normalize_cpf(cpf)
    cpf.to_s.gsub(/[^0-9]/, '')
  end

  def valid_cpf_format?(cpf_numbers)
    cpf_numbers.length == 11 && cpf_numbers.chars.uniq.size > 1
  end

  def validate_check_digits(cpf_numbers)
    first_digit_valid?(cpf_numbers) && second_digit_valid?(cpf_numbers)
  end

  def first_digit_valid?(cpf_numbers)
    sum = calculate_sum(cpf_numbers, 9, 10)
    first_digit = ((sum * 10) % 11) % 10
    first_digit == cpf_numbers[9].to_i
  end

  def second_digit_valid?(cpf_numbers)
    sum = calculate_sum(cpf_numbers, 10, 11)
    second_digit = ((sum * 10) % 11) % 10
    second_digit == cpf_numbers[10].to_i
  end

  def calculate_sum(cpf_numbers, count, multiplier_start)
    sum = 0
    count.times { |i| sum += cpf_numbers[i].to_i * (multiplier_start - i) }
    sum
  end
end
