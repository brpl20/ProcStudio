# frozen_string_literal: true

module Drafts
  class SerializerService
    def self.serialize_draft(draft)
      {
        id: draft.id,
        draftable_type: draft.draftable_type,
        draftable_id: draft.draftable_id,
        form_type: draft.form_type,
        data: draft.data,
        status: draft.status,
        expires_at: draft.expires_at,
        created_at: draft.created_at,
        updated_at: draft.updated_at,
        user_id: draft.user_id,
        customer_id: draft.customer_id,
        team_id: draft.team_id,
        is_new_record: draft.for_new_record?,
        session_id: draft.session_id
      }
    end

    def self.serialize_drafts(drafts)
      drafts.map { |draft| serialize_draft(draft) }
    end
  end
end
