# frozen_string_literal: true

# == Schema Information
#
# Table name: law_areas
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(TRUE), not null
#  code               :string           not null
#  description        :text
#  name               :string           not null
#  sort_order         :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_team_id :bigint
#  parent_area_id     :bigint
#
# Indexes
#
#  index_law_areas_on_active              (active)
#  index_law_areas_on_created_by_team_id  (created_by_team_id)
#  index_law_areas_on_parent_area_id      (parent_area_id)
#  index_law_areas_unique_code            (code,created_by_team_id,parent_area_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_team_id => teams.id)
#  fk_rails_...  (parent_area_id => law_areas.id)
#
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
