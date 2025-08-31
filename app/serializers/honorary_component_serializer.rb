# frozen_string_literal: true

class HonoraryComponentSerializer
  include JSONAPI::Serializer

  attributes :id, :component_type, :details, :position,
             :is_active, :created_at, :updated_at

  attribute :calculate_total, &:calculate_total

  attribute :display_name, &:display_name

  belongs_to :honorary
end
