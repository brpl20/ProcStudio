# frozen_string_literal: true

class MailDeliveryJob < ApplicationJob
  queue_as :mailers

  # Retry failed jobs with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Discard jobs that fail due to record not found (e.g., deleted records)
  discard_on ActiveRecord::RecordNotFound

  def perform(mail_service_class, *args)
    # Call the mail service with the provided arguments
    mail_service_class.constantize.call(*args)
  rescue StandardError => e
    Rails.logger.error "[MailDeliveryJob] Failed to deliver email: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    raise # Re-raise to trigger retry
  end
end
