# frozen_string_literal: true

# This module is destinated to hold commom basic Mailjet configurations and methods
# to be used in other services
#
# it contains the following methods:
# - mailjet_service: returns the Mailjet::Send class
# - from: returns the default sender email and name
# - template_language: returns true if the template language is enabled
# - sandbox_mode?: returns true if the environment is development or test, it prevents email's from being sent while validating its payload.
# - call: sends the email using the Mailjet API
#
# [Mailjet API Documentation](https://dev.mailjet.com/email/guides/send-api-v31)
module Customers::Mail::MailjetService
  def mailjet_service
    Mailjet::Send
  end

  def from
    { Email: 'contato@brunopellizzetti.com.br', Name: 'Procstudio' }
  end

  def template_language
    true
  end

  def sandbox_mode?
    Rails.env.development? || Rails.env.test?
  end

  # Sends the email using Mailjet service.
  # @message (Hash): the email payload
  # @message[:From] (Hash): the sender email and name
  # @message[:To] (Array): the recipient email and name
  # @message[:TemplateID] (Integer): the template ID
  # @message[:TemplateLanguage] (Boolean): the template language
  # @message[:Subject] (String): the email subject
  # @message[:Variables] (Hash): the email variables
  #
  # Returns:
  # - If successful, returns the response from Mailjet service.
  # - If an error occurs, logs the error message and returns nil.
  def call
    mailjet_service.create(
      messages: [message],
      sandbox_mode: sandbox_mode?
    )
  rescue RestClient::BadRequest => e
    Rails.logger.error("[Mailjet Delivery Error]: #{e.message}")
  end
end
