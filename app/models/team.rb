# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  subdomain  :string           not null
#  settings   :jsonb
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Team < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  has_many :admins, dependent: :destroy
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
