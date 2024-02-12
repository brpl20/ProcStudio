# frozen_string_literal: true

class Customers::Mail::WelcomeService < ApplicationService
  include Customers::Mail::MailjetService

  def initialize(customer)
    @customer = customer
  end

  private

  attr_reader :customer

  WELCOME_TO_PROCSTUDIO = 5_667_725

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
    "Boas-vindas ao Procstudio #{customer_name} - Seu Parceiro em Gestão de Processos"
  end

  def variables
    {
      customer_full_name: customer_name
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
