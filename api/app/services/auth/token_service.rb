# frozen_string_literal: true

module Auth
  class TokenService
    def self.generate_token(user:, user_profile: nil)
      token_data = build_token_data(user, user_profile)
      JWT.encode(token_data, Rails.application.secret_key_base)
    end

    def self.decode_token(token)
      secret_key = Rails.application.secret_key_base
      decoded_token = JWT.decode(token, secret_key)[0]
      ActiveSupport::HashWithIndifferentAccess.new(decoded_token)
    rescue JWT::DecodeError
      nil
    end

    def self.build_token_data(user, user_profile)
      token_data = {
        user_id: user.id,
        admin_id: user.id, # backward compatibility
        exp: 24.hours.from_now.to_i
      }

      return token_data unless user_profile

      token_data.merge(
        name: user_profile.name,
        last_name: user_profile.last_name,
        role: user_profile.role
      )
    end
  end
end
