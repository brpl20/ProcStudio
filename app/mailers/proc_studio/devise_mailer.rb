# frozen_string_literal: true

class ProcStudio::DeviseMailer < Devise::Mailer
  include ProcStudio::UrlHelper

  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, _opts = {})
    # Skip email sending in development/test
    return if Rails.env.local?
    return unless record.persisted?

    confirmation_url = base_client_url + confirmation_path(token)

    # Queue email delivery as a background job
    MailDeliveryJob.perform_later(
      'Customers::Mail::WelcomeService',
      record,
      confirmation_url
    )
  end

  def reset_password_instructions(record, token, _opts = {})
    # Skip email sending in development/test
    return if Rails.env.local?

    password_url = base_client_url + update_password_path(token)

    # Queue email delivery as a background job
    MailDeliveryJob.perform_later(
      'Customers::Mail::ResetPasswordService',
      record,
      password_url
    )
  end
end
