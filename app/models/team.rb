# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string           not null
#  settings   :jsonb
#  subdomain  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_deleted_at  (deleted_at)
#  index_teams_on_subdomain   (subdomain) UNIQUE
#
class Team < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  has_many :users, dependent: :destroy
  has_many :offices, dependent: :destroy
  has_many :works, dependent: :destroy
  has_many :jobs, dependent: :destroy

  has_many :team_customers, dependent: :destroy
  has_many :customers, through: :team_customers

  before_validation :normalize_subdomain

  def to_s
    name
  end

  private

  def normalize_subdomain
    return if subdomain.blank?

    self.subdomain = subdomain.downcase.strip.gsub(/[^a-z0-9-]/, '-').squeeze('-').gsub(/^-|-$/, '')
  end
end
