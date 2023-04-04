# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@procstudio.com.br'
  layout "mailer"
end
