# frozen_string_literal: true

# == Schema Information
#
# Table name: team_offices
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)        not null
#  office_id  :bigint(8)        not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TeamOffice < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :office
  
  validates :office_id, uniqueness: { scope: :team_id }
  
  scope :active, -> { where(deleted_at: nil) }
end
