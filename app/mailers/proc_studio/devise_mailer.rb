class ProcStudio::DeviseMailer < Devise::Mailer
  include ProcStudio::UrlHelper

  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, _opts = {})
    return if Rails.env.test?

    confirmation_url = base_url + confirmation_path(token)
    Customers::Mail::WelcomeService.call(record, confirmation_url)
  end
end
