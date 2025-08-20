# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id                 :bigint           not null, primary key
#  category           :integer          not null
#  description        :string           not null
#  is_base            :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_team_id :bigint
#  law_area_id        :bigint
#
# Indexes
#
#  index_powers_on_category_and_law_area_id  (category,law_area_id)
#  index_powers_on_created_by_team_id        (created_by_team_id)
#  index_powers_on_is_base                   (is_base)
#  index_powers_on_law_area_id               (law_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_team_id => teams.id)
#  fk_rails_...  (law_area_id => law_areas.id)
#
class PowerSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :category, :law_area_id, :is_base

  attribute :category_name do |object|
    object.category&.humanize
  end

  attribute :law_area do |object|
    if object.law_area
      {
        id: object.law_area.id,
        name: object.law_area.name,
        code: object.law_area.code,
        full_name: object.law_area.full_name,
        parent_area: if object.law_area.parent_area
                       {
                         id: object.law_area.parent_area.id,
                         name: object.law_area.parent_area.name,
                         code: object.law_area.parent_area.code
                       }
                     end
      }
    end
  end

  attribute :full_description, &:full_description

  attribute :is_custom, &:custom_power?

  attribute :created_by_team do |object|
    if object.created_by_team
      {
        id: object.created_by_team.id,
        name: object.created_by_team.name
      }
    end
  end
end
