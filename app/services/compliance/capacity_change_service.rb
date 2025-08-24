# frozen_string_literal: true

module Compliance
  class CapacityChangeService
    attr_reader :profile_customer, :previous_capacity, :new_capacity

    def initialize(profile_customer)
      @profile_customer = profile_customer
    end

    def handle_manual_change
      return unless capacity_changed_manually?

      create_manual_change_notification
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

    def create_manual_change_notification
      title = determine_notification_title
      description = build_notification_description

      # Get team from customer's teams (using first team if multiple)
      team = profile_customer.customer&.teams&.first
      return unless team # Skip if no team associated

      ComplianceNotification.create!(
        notification_type: 'manual_capacity_update',
        title: title,
        description: description,
        status: 'pending',
        team: team,
        resource_type: 'ProfileCustomer',
        resource_id: profile_customer.id,
        metadata: {
          previous_capacity: previous_capacity,
          new_capacity: new_capacity,
          changed_at: Time.current.to_s,
          age: calculate_age
        }
      )
    end

    def determine_notification_title
      case new_capacity
      when 'able'
        'Customer capacity changed to fully capable'
      when 'relatively'
        'Customer capacity changed to relatively incapable'
      when 'unable'
        'Customer capacity changed to unable'
      else
        'Customer capacity updated'
      end
    end

    def build_notification_description
      age_info = profile_customer.birth.present? ? " (Age: #{calculate_age})" : ''

      "#{profile_customer.full_name} (CPF: #{profile_customer.cpf})#{age_info} " \
        "has had their capacity manually changed from '#{previous_capacity}' to '#{new_capacity}'. " \
        'This change may be due to medical or legal reasons. ' \
        'Please review and update all related documents and legal procedures.'
    end

    def calculate_age
      return nil if profile_customer.birth.blank?

      today = Date.current
      age = today.year - profile_customer.birth.year
      age -= 1 if today < profile_customer.birth + age.years
      age
    end
  end
end
