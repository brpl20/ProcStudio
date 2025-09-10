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
FactoryBot.define do
  factory :law_area do
    sequence(:name) { |n| "Law Area #{n}" }
    sequence(:code) { |n| "LAW#{n}" }
    description { Faker::Lorem.paragraph }
    active { true }
    sort_order { 1 }
    parent_area { nil }
    created_by_team { nil }
  end
end
