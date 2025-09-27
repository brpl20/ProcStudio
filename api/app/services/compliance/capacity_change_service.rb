# frozen_string_literal: true

module Compliance
  class CapacityChangeService
    attr_reader :profile_customer, :previous_capacity, :new_capacity

    def initialize(profile_customer)
      @profile_customer = profile_customer
    end

    def handle_manual_change
      return unless capacity_changed_manually?

      # Use NotificationService for capacity change notification
      NotificationService.notify_capacity_change(
        profile_customer: profile_customer,
        old_capacity: previous_capacity,
        new_capacity: new_capacity,
        reason: 'manual_change'
      )
    end

    private

    def capacity_changed_manually?
      # Check if there's a PaperTrail version for this change
      return false unless profile_customer.versions.any?

      last_version = profile_customer.versions.last
      return false if last_version.changeset['capacity'].blank?

      @previous_capacity = last_version.changeset['capacity'][0]
      @new_capacity = last_version.changeset['capacity'][1]

      true
    end
  end
end
