# frozen_string_literal: true

module Drafts
  class QueryService
    def self.build_query(current_user:, current_team:, draft_type: nil)
      drafts = Draft.active.unfulfilled
      drafts = apply_team_filter(drafts, current_team)
      drafts = apply_user_filter(drafts, current_user)
      apply_type_filter(drafts, draft_type)
    end

    def self.build_meta(drafts)
      {
        total_count: drafts.count,
        new_records_count: drafts.for_new_records.count,
        existing_records_count: drafts.for_existing_records.count
      }
    end

    def self.apply_team_filter(drafts, current_team)
      current_team ? drafts.where(team: current_team) : drafts
    end

    def self.apply_user_filter(drafts, current_user)
      current_user ? drafts.where(user: current_user) : drafts
    end

    def self.apply_type_filter(drafts, draft_type)
      case draft_type
      when 'new'
        drafts.for_new_records
      when 'existing'
        drafts.for_existing_records
      else
        drafts
      end
    end
  end
end
