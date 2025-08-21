# frozen_string_literal: true

class WorkAddressesValidator < ActiveModel::Validator
  def validate(record)
    @work = record

    validate_profile_customers_addresses
    validate_user_profiles_addresses
    validate_offices_addresses
    validate_represent_addresses
  end

  private

  def validate_profile_customers_addresses
    @work.profile_customers.each do |profile_customer|
      if profile_customer.addresses.blank?
        @work.errors.add(:profile_customers,
                         'endereço do cliente deve ser preenchido')
      end
    end
  end

  def validate_user_profiles_addresses
    @work.user_profiles.each do |user_profile|
      @work.errors.add(:user_profiles, 'endereço do usuário deve ser preenchido') if user_profile.addresses.blank?
    end
  end

  def validate_represent_addresses
    @work.profile_customers.each do |profile_customer|
      representor = profile_customer.represent&.representor

      @work.errors.add(:represent, 'endereço do representante deve ser preenchido') if representor&.addresses.blank?
    end
  end

  def validate_offices_addresses
    @work.offices.each do |office|
      @work.errors.add(:offices, 'rua do escritório deve ser preenchido') if office.street.blank?
      @work.errors.add(:offices, 'número do escritório deve ser preenchido') if office.number.blank?
      @work.errors.add(:offices, 'bairro do escritório deve ser preenchido') if office.neighborhood.blank?
      @work.errors.add(:offices, 'cidade do escritório deve ser preenchido') if office.city.blank?
    end
  end
end
