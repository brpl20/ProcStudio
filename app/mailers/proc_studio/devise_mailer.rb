# frozen_string_literal: true

class ProcStudio::DeviseMailer < Devise::Mailer
  include ProcStudio::UrlHelper

  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, _opts = {})
    return if Rails.env.test? || Rails.env.development?

    confirmation_url = base_client_url + confirmation_path(token)
    Customers::Mail::WelcomeService.call(record, confirmation_url)
  end

  def reset_password_instructions(record, token, _opts = {})
    return if Rails.env.test? || Rails.env.development?

    password_url = base_client_url + update_password_path(token)
    Customers::Mail::ResetPasswordService.call(record, password_url)
  end
end
