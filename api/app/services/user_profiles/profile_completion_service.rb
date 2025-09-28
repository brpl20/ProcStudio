# frozen_string_literal: true

module UserProfiles
  class ProfileCompletionService
    def initialize(user)
      @user = user
    end

    def call(params)
      user_profile = find_or_build_profile

      ActiveRecord::Base.transaction do
        update_basic_profile(user_profile, params)
        process_phone_data(user_profile, params)
        process_addresses_data(user_profile, params)
      end

      Result.success(user_profile)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages)
    rescue StandardError => e
      Rails.logger.error "Error completing profile: #{e.message}"
      Result.failure([e.message])
    end

    private

    attr_reader :user

    def find_or_build_profile
      user.user_profile || user.build_user_profile
    end

    def update_basic_profile(user_profile, params)
      basic_params = extract_basic_params(params)
      user_profile.update!(basic_params) if basic_params.present?
    end

    def extract_basic_params(params)
      params.except(:phone, :addresses_attributes, :phones_attributes)
    end

    def process_phone_data(user_profile, params)
      process_legacy_phone(user_profile, params)
      process_nested_phones(user_profile, params)
    end

    def process_legacy_phone(user_profile, params)
      phone_number = params[:phone]
      return if phone_number.blank?

      create_or_update_phone(user_profile, phone_number)
    end

    def process_nested_phones(user_profile, params)
      phones_attrs = params[:phones_attributes]
      return if phones_attrs.blank?

      phones_attrs.each do |phone_attr|
        create_or_update_phone(user_profile, phone_attr[:phone_number])
      end
    end

    def create_or_update_phone(user_profile, phone_number)
      existing_phone = user_profile.phones.find_by(phone_number: phone_number)
      return if existing_phone

      user_profile.phones.create!(phone_number: phone_number)
    end

    def process_addresses_data(user_profile, params)
      addresses_attrs = params[:addresses_attributes]
      return if addresses_attrs.blank?

      addresses_attrs.each do |address_attr|
        create_address(user_profile, address_attr)
      end
    end

    def create_address(user_profile, address_attr)
      user_profile.addresses.create!(
        street: address_attr[:street],
        number: address_attr[:number],
        neighborhood: address_attr[:neighborhood],
        city: address_attr[:city],
        state: address_attr[:state],
        zip_code: address_attr[:zip_code],
        complement: address_attr[:description],
        address_type: 'main'
      )
    end

    class Result
      attr_reader :user_profile, :errors

      def initialize(success:, user_profile: nil, errors: nil)
        @success = success
        @user_profile = user_profile
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def self.success(user_profile)
        new(success: true, user_profile: user_profile)
      end

      def self.failure(errors)
        new(success: false, errors: errors)
      end
    end
  end
end
