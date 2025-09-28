# frozen_string_literal: true

module Auth
  class ResponseBuilderService
    def self.build_response(token:, user:, user_profile: nil)
      response = { token: token }

      if user_profile.nil?
        build_incomplete_profile_response(response, user)
      else
        build_complete_profile_response(response, user_profile)
      end

      response
    end

    def self.build_incomplete_profile_response(response, user)
      response[:needs_profile_completion] = true
      response[:missing_fields] = ProfileCompletenessService.required_profile_fields
      response[:oab] = user.oab if user.oab.present?
      response[:message] = I18n.t('errors.messages.profile.incomplete')
      response
    end

    def self.build_complete_profile_response(response, user_profile)
      incomplete_fields = ProfileCompletenessService.check_completeness(user_profile)

      if incomplete_fields.any?
        build_partial_profile_response(response, user_profile, incomplete_fields)
      else
        build_success_response(response, user_profile)
      end

      add_profile_data(response, user_profile)
      response
    end

    def self.build_partial_profile_response(response, _user_profile, incomplete_fields)
      response[:needs_profile_completion] = true
      response[:missing_fields] = incomplete_fields
      response[:message] = I18n.t('errors.messages.profile.incomplete')
    end

    def self.build_success_response(response, _user_profile)
      response[:needs_profile_completion] = false
      response[:message] = 'Login realizado com sucesso'
    end

    def self.add_profile_data(response, user_profile)
      response[:role] = user_profile.role
      response[:name] = user_profile.name
      response[:last_name] = user_profile.last_name
      response[:oab] = user_profile.oab if user_profile.lawyer? && user_profile.oab.present?
      response[:gender] = user_profile.gender if user_profile.gender.present?
    end
  end
end
