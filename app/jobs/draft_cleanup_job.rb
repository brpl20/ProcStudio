# frozen_string_literal: true

class DraftCleanupJob < ApplicationJob
  queue_as :low

  def perform
    DraftService.cleanup_expired_drafts
    Rails.logger.info "Cleaned up #{Draft.expired.count} expired drafts"
  end
end
