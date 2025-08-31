# frozen_string_literal: true

class LegalCostTypeSerializer
  include JSONAPI::Serializer

  attributes :id, :key, :name, :description, :category,
             :display_order, :active, :is_system,
             :metadata, :created_at, :updated_at

  attribute :display_name, &:display_name

  attribute :editable, &:editable?

  attribute :deletable, &:deletable?

  belongs_to :team, if: proc { |record| record.team.present? }
end
