# frozen_string_literal: true

class PhoneNumberValidator < ActiveModel::Validator
  def validate(record)
    self.record = record

    record.errors.add(:phones, :taken) if duplicated_numbers?
  end

  attr_accessor :record

  def phone_numbers
    record.phones.map(&:phone_number)
  end

  def duplicated_numbers?
    phone_numbers.uniq.size != phone_numbers.size
  end
end
