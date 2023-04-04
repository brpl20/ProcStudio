# frozen_string_literal: true

class NewCustomerEmailMailer < ApplicationMailer
  def notify_new_customer(customer)
    @customer = customer

    mail(to: @customer.email, subject: 'Seu acesso ao sistema ProcStudio')
  end
end
