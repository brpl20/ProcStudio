# frozen_string_literal: true

class LawAreaSerializer
  include JSONAPI::Serializer

  attributes :name, :code, :description, :active, :sort_order

  attribute :parent_area do |object|
    if object.parent_area
      {
        id: object.parent_area.id,
        name: object.parent_area.name,
        code: object.parent_area.code
      }
    end
  end

  attribute :sub_areas do |object|
    object.sub_areas.active.ordered.map do |area|
      {
        id: area.id,
        name: area.name,
        code: area.code,
        description: area.description
      }
    end
  end

  attribute :full_name, &:full_name

  attribute :is_main_area, &:main_area?

  attribute :is_sub_area, &:sub_area?

  attribute :is_system_area, &:system_area?

  attribute :is_custom_area, &:custom_area?

  attribute :applicable_powers_count do |object|
    object.applicable_powers.count
  end
end
