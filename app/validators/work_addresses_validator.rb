# frozen_string_literal: true

class WorkAddressesValidator < ActiveModel::Validator
  def validate(record)
    @work = record

    validate_profile_customers_addresses
    validate_profile_admins_addresses
    validate_offices_addresses
  end

  private

  def validate_profile_customers_addresses
    @work.profile_customers.each do |profile_customer|
      @work.errors.add(:profile_customers, 'endereço do cliente deve ser preenchido') if profile_customer.addresses.blank?
    end
  end

  def validate_profile_admins_addresses
    @work.profile_admins.each do |profile_admin|
      @work.errors.add(:profile_admins, 'endereço do advogado deve ser preenchido') if profile_admin.addresses.blank?
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
