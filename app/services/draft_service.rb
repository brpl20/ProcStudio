# frozen_string_literal: true

class DraftService
  class << self
    def auto_save(draftable:, form_type:, data:, user: nil, customer: nil, team: nil)
      return unless should_save_draft?(data)

      Draft.transaction do
        draft = Draft.save_draft(
          draftable: draftable,
          form_type: form_type,
          data: sanitize_data(data),
          user: user,
          customer: customer,
          team: team
        )

        schedule_cleanup_job

        draft
      end
    end

    def recover_draft(draftable:, form_type:, user: nil, customer: nil)
      draft = find_active_draft(draftable, form_type, user, customer)
      return nil unless draft

      {
        id: draft.id,
        data: draft.data,
        expires_at: draft.expires_at,
        created_at: draft.created_at
      }
    end

    def merge_with_current(current_data, draft_data)
      return current_data if draft_data.blank?

      draft_data.deep_merge(current_data) do |_key, draft_val, current_val|
        current_val.presence || draft_val
      end
    end

    def cleanup_expired_drafts
      Draft.expired.update_all(status: 'expired')
      Draft.where(status: 'expired').where(updated_at: ...7.days.ago).destroy_all
    end

    private

    def should_save_draft?(data)
      return false if data.blank?

      data.values.any? { |v| v.present? && v != '' }
    end

    def sanitize_data(data)
      data.deep_transform_values do |value|
        case value
        when String
          value.strip
        when Array
          value.compact_blank
        else
          value
        end
      end
    end

    def find_active_draft(draftable, form_type, user, customer)
      scope = draftable.drafts.active.where(form_type: form_type)

      if user
        scope = scope.where(user: user)
      elsif customer
        scope = scope.where(customer: customer)
      end

      scope.first
    end

    def schedule_cleanup_job
      DraftCleanupJob.perform_in(1.day)
    rescue StandardError => e
      Rails.logger.error "Failed to schedule draft cleanup: #{e.message}"
    end
  end
end
