# frozen_string_literal: true

class Customers::Mail::ResetPasswordService < ApplicationService
  include Customers::Mail::MailjetService

  def initialize(customer, password_url)
    @customer = customer
    @password_url = password_url
  end

  private

  attr_reader :customer, :password_url

  WELCOME_TO_PROCSTUDIO = 5_963_600

  def template_id
    WELCOME_TO_PROCSTUDIO
  end

  def customer_name
    @customer_name ||= customer.profile_customer_full_name || 'Cliente'
  end

  def to
    [{ Email: customer.email, Name: customer_name }]
  end

  def subject
    'Procstudio - Recuperação de Senha'
  end

  def variables
    {
      customer_full_name: customer_name,
      password_url: password_url
    }
  end

  def message
    {
      From: from,
      To: to,
      TemplateID: template_id,
      TemplateLanguage: template_language,
      Subject: subject,
      Variables: variables
    }
  end
end
