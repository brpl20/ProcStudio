# frozen_string_literal: true

module CredentialsHelper
  def self.get(*keys)
    env_var = keys.last.is_a?(String) ? keys.pop : nil
    Rails.application.credentials.dig(Rails.env.to_sym, *keys) || (env_var ? ENV.fetch(env_var) : nil)
  end
end
