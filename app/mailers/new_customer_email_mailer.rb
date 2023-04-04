# frozen_string_literal: true

class NewCustomerEmailMailer < ApplicationMailer
  def notify_new_customer(customer)
    @customer = customer

    p '+++++++++++++++++++++++++++++++++++++++++++'
    p ENV['EMAIL_PASSWORD']
    p '+++++++++++++++++++++++++++++++++++++++++++'

    mail(to: @customer.email, subject: 'Seu acesso ao sistema ProcStudio')
  end
end
