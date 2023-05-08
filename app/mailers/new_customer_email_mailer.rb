# frozen_string_literal: true

class NewCustomerEmailMailer < ApplicationMailer
  def notify_new_customer(customer)
    @customer = customer

    p '+++++++++++++++++++++++++++++++++++++++++++'
    p ENV.fetch('EMAIL_PASSWORD', nil)
    p '+++++++++++++++++++++++++++++++++++++++++++'

    mail(to: @customer.email, subject: 'Seu acesso ao sistema ProcStudio')
  end
end
