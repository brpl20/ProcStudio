# frozen_string_literal: true

module ProcStudio::UrlHelper
  def base_url
    if Rails.env.development? || Rails.env.test?
      'http://localhost:3000'
    else
      'https://staging_cliente.procstudio.com.br'
    end
  end

  def confirmation_path(token)
    if Rails.env.development? || Rails.env.test?
      "/api/v1/customer/confirm?confirmation_token=#{token}"
    else
      "?confirmation_token=#{token}"
    end
  end
end
