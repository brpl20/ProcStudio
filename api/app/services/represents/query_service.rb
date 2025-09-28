# frozen_string_literal: true

module Represents
  class QueryService
    def initialize(current_team)
      @current_team = current_team
    end

    def call(profile_customer: nil, filters: {})
      represents = build_base_query(profile_customer)
      apply_filters(represents, filters)
    end

    def by_representor(representor_id)
      Represent.includes(:profile_customer)
        .by_representor(representor_id)
        .by_team(@current_team.id)
        .active
    end

    private

    attr_reader :current_team

    def build_base_query(profile_customer)
      if profile_customer
        profile_customer.represents
          .includes(:representor, :profile_customer)
          .by_team(current_team.id)
      else
        Represent.includes(:representor, :profile_customer)
          .by_team(current_team.id)
      end
    end

    def apply_filters(represents, filters)
      represents = filter_by_active_status(represents, filters[:active])
      represents = filter_by_relationship_type(represents, filters[:relationship_type])
      filter_by_current_status(represents, filters[:current])
    end

    def filter_by_active_status(represents, active_param)
      return represents if active_param.blank?

      active_param == 'true' ? represents.active : represents.inactive
    end

    def filter_by_relationship_type(represents, relationship_type)
      return represents if relationship_type.blank?

      represents.where(relationship_type: relationship_type)
    end

    def filter_by_current_status(represents, current_param)
      return represents unless current_param.present? && current_param == 'true'

      represents.current
    end
  end
end
