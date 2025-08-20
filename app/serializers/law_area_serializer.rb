# frozen_string_literal: true

class LawAreaSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :code, :description, :active, :sort_order

  # Atributos computados
  attribute :full_name, &:full_name

  attribute :is_main_area, &:main_area?

  attribute :is_sub_area, &:sub_area?

  attribute :is_system_area, &:system_area?

  attribute :is_custom_area, &:custom_area?

  attribute :depth, &:depth

  attribute :hierarchy_path do |object|
    object.hierarchy_path.map { |area| { id: area.id, name: area.name } }
  end

  # Relacionamentos
  belongs_to :parent_area, serializer: LawAreaSerializer, if: proc { |record| record.parent_area.present? }

  has_many :sub_areas, serializer: LawAreaSerializer, if: proc { |record| record.sub_areas.any? }

  has_many :powers, serializer: PowerSerializer, if: proc { |record| record.powers.any? }

  attribute :created_by_team do |object|
    if object.created_by_team
      {
        id: object.created_by_team.id,
        name: object.created_by_team.name,
        subdomain: object.created_by_team.subdomain
      }
    end
  end

  # Contadores úteis
  attribute :sub_areas_count do |object|
    object.sub_areas.count
  end

  attribute :powers_count do |object|
    object.powers.count
  end
end
