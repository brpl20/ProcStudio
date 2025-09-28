# frozen_string_literal: true

module Auth
  class ProfileCompletenessService
    REQUIRED_BASIC_FIELDS = [
      :name, :last_name, :cpf, :rg, :role, :gender, :civil_status, :nationality, :birth
    ].freeze

    REQUIRED_ASSOCIATIONS = [:phone, :address].freeze

    def self.check_completeness(user_profile)
      return REQUIRED_BASIC_FIELDS + REQUIRED_ASSOCIATIONS if user_profile.nil?

      missing_fields = check_basic_fields(user_profile)
      missing_fields += check_lawyer_fields(user_profile)
      missing_fields += check_associations(user_profile)
      missing_fields
    end

    def self.check_basic_fields(user_profile)
      REQUIRED_BASIC_FIELDS.select { |field| user_profile.public_send(field).blank? }
    end

    def self.check_lawyer_fields(user_profile)
      return [] unless user_profile.lawyer?
      return [] if user_profile.oab.present?

      [:oab]
    end

    def self.check_associations(user_profile)
      missing = []
      missing << :phone if user_profile.phones.empty?
      missing << :address if user_profile.addresses.empty?
      missing
    end

    def self.required_profile_fields
      REQUIRED_BASIC_FIELDS + REQUIRED_ASSOCIATIONS
    end
  end
end
