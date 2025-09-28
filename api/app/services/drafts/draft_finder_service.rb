# frozen_string_literal: true

module Drafts
  class DraftFinderService
    def self.find_draft(params:, current_user:, current_team:, draftable: nil)
      if params[:id]
        find_by_id(params[:id])
      elsif params[:session_id].present? && params[:form_type].present?
        find_for_new_record(params, current_user, current_team)
      elsif draftable
        find_for_existing_record(draftable, params[:form_type])
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def self.find_by_id(id)
      Draft.find(id)
    end

    def self.find_for_new_record(params, current_user, current_team)
      Draft.find_draft_for_new_record(
        form_type: params[:form_type],
        user: current_user,
        team: current_team,
        session_id: params[:session_id]
      )
    end

    def self.find_for_existing_record(draftable, form_type)
      draftable.drafts.active.find_by!(form_type: form_type)
    end
  end
end
