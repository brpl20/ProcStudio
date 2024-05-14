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
      "/primeiro-acesso?confirmation_token=#{token}"
    end
  end

  def update_password_path(token)
    if Rails.env.development? || Rails.env.test?
      "/api/v1/customer/password?reset_password_token=#{token}"
    else
      "/cadastrar-nova-senha?reset_password_token=#{token}"
    end
  end
end
