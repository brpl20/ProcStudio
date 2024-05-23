# frozen_string_literal: true

module ProcStudio::UrlHelper
  def base_client_url
    if production?
      'https://cliente.procstudio.com.br'
    elsif staging?
      'https://staging_cliente.procstudio.com.br'
    else
      'http://localhost:3000'
    end
  end

  def confirmation_path(token)
    if production? || staging?
      "/primeiro-acesso?confirmation_token=#{token}"
    else
      "/api/v1/customer/confirm?confirmation_token=#{token}"
    end
  end

  def update_password_path(token)
    if production? || staging?
      "/cadastrar-nova-senha?reset_password_token=#{token}"
    else
      "/api/v1/customer/password?reset_password_token=#{token}"
    end
  end

  def production?
    ENV.fetch('SERVER_ENV', 'development') == 'production'
  end

  def staging?
    ENV.fetch('SERVER_ENV', 'development') == 'staging'
  end
end
