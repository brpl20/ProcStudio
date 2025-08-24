# frozen_string_literal: true

class BirthDateValidator < ActiveModel::EachValidator
  MAX_AGE = 120

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    return if value.nil? && options[:allow_nil]

    validate_date_format(record, attribute, value)
    validate_not_future(record, attribute, value)
    validate_age_limit(record, attribute, value)
    set_capacity_based_on_age(record, value) if options[:set_capacity]
  end

  private

  def validate_date_format(record, attribute, value)
    return if value.blank?

    begin
      Date.parse(value.to_s)
    rescue ArgumentError
      record.errors.add(attribute, 'is not a valid date format')
    end
  end

  def validate_not_future(record, attribute, value)
    return if value.blank?

    begin
      date = Date.parse(value.to_s)
      record.errors.add(attribute, 'cannot be in the future') if date > Date.current
    rescue ArgumentError
      # Already handled in validate_date_format
    end
  end

  def validate_age_limit(record, attribute, value)
    return if value.blank?

    begin
      date = Date.parse(value.to_s)
      age = calculate_age(date)

      record.errors.add(attribute, "cannot be older than #{MAX_AGE} years") if age > MAX_AGE
    rescue ArgumentError
      # Already handled in validate_date_format
    end
  end

  def set_capacity_based_on_age(record, value)
    return if value.blank?
    return unless record.respond_to?(:capacity=)

    begin
      date = Date.parse(value.to_s)
      age = calculate_age(date)

      record.capacity = case age
                        when 0..15
                          'unable' # Menor absolutamente incapaz
                        when 16..17
                          'relative' # Menor relativamente incapaz
                        else
                          'able' # Maior de idade
                        end

      # Set capacity message for UI
      if record.respond_to?(:capacity_message=)
        record.capacity_message = case age
                                  when 0..15
                                    'Menor absolutamente incapaz: selecione um representante'
                                  when 16..17
                                    'Menor relativamente incapaz: selecione um assistente'
                                  end
      end
    rescue ArgumentError
      # Already handled in validate_date_format
    end
  end

  def calculate_age(birth_date)
    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end
end
