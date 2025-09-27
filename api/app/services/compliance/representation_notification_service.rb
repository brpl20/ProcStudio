# frozen_string_literal: true

module Compliance
  # @deprecated Use NotificationService.notify_representation_change instead
  class RepresentationNotificationService
    attr_reader :represent, :notification_type

    def initialize(represent, notification_type)
      @represent = represent
      @notification_type = notification_type
    end

    def call
      # Delegate to NotificationService
      NotificationService.notify_representation_change(
        represent: represent,
        notification_type: notification_type
      )
    end
  end
end
