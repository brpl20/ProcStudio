# frozen_string_literal: true

module Compliance
  class RepresentationNotificationService
    attr_reader :represent, :notification_type

    def initialize(represent, notification_type)
      @represent = represent
      @notification_type = notification_type
    end

    def call
      return unless should_notify?

      eligible_users = find_eligible_users
      eligible_users.find_each { |user| create_notification_for_user(user) }
    end

    private

    def should_notify?
      represent.team.present? && ['unable', 'relatively'].include?(represent.profile_customer&.capacity)
    end

    def find_eligible_users
      represent.team.users
        .joins(:user_profile)
        .where(user_profiles: { role: 'lawyer' })
        .where.not(user_profiles: { id: nil })
    end

    def create_notification_for_user(user)
      notification_attributes = build_notification_attributes(user.user_profile)
      Notification.create!(notification_attributes)
    rescue StandardError => e
      Rails.logger.error "Failed to create representation notification: #{e.message}"
    end

    def build_notification_attributes(user_profile)
      {
        user_profile: user_profile,
        notification_type: 'compliance',
        title: determine_notification_title,
        body: build_notification_description,
        priority: :normal,
        sender_type: 'Represent',
        sender_id: represent.id,
        action_url: "/customers/#{represent.profile_customer_id}/represents",
        data: build_notification_data
      }
    end

    def determine_notification_title
      I18n.t("pundit.represent.notifications.#{notification_type}.title",
             relationship_type: represent.relationship_type.capitalize)
    rescue I18n::MissingTranslationData
      I18n.t('pundit.represent.notifications.default.title')
    end

    def build_notification_description
      customer_name = represent.profile_customer&.full_name
      representor_name = represent.representor&.full_name

      I18n.t("pundit.represent.notifications.#{notification_type}.description",
             representor_name: representor_name,
             relationship_type: represent.relationship_type,
             customer_name: customer_name)
    rescue I18n::MissingTranslationData
      I18n.t('pundit.represent.notifications.default.description')
    end

    def build_notification_data
      {
        compliance_type: notification_type,
        profile_customer_id: represent.profile_customer_id,
        profile_customer_name: represent.profile_customer&.name,
        representor_id: represent.representor_id,
        representor_name: represent.representor&.name,
        relationship_type: represent.relationship_type,
        active: represent.active,
        changed_at: Time.current.to_s
      }
    end
  end
end
