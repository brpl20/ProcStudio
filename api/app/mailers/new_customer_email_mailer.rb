# frozen_string_literal: true

class NewCustomerEmailMailer < ApplicationMailer
  def notify_new_customer(customer)
    @customer = customer

    Rails.logger.debug '+++++++++++++++++++++++++++++++++++++++++++'
    Rails.logger.debug ENV.fetch('EMAIL_PASSWORD', nil)
    Rails.logger.debug '+++++++++++++++++++++++++++++++++++++++++++'

    mail(to: @customer.email, subject: 'Seu acesso ao sistema ProcStudio')
  end
end
