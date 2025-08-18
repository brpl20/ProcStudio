# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                  :bigint(8)        not null, primary key
#  description         :string
#  deadline            :date             not null
#  status              :string
#  priority            :string
#  comment             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_admin_id    :bigint(8)
#  work_id             :bigint(8)
#  profile_customer_id :bigint(8)
#  created_by_id       :bigint(8)
#  deleted_at          :datetime
#  team_id             :bigint(8)        not null
#
class Job < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :work, optional: true
  belongs_to :profile_customer, optional: true
  belongs_to :profile_admin

  validate :work_same_team, if: -> { work.present? }
  validate :customer_same_team, if: -> { profile_customer.present? }
  validate :admin_same_team

  enum :status, {
    pending: 'pending',
    delayed: 'delayed',
    finished: 'finished'
  }

  after_find :check_and_update_status

  private

  def check_and_update_status
    return unless status == 'pending'
    return unless deadline < Time.zone.today

    self.status = 'delayed'
    save!
  end

  def work_same_team
    errors.add(:work, 'deve ser do mesmo team') unless work.team == team
  end

  def customer_same_team
    customer_teams = profile_customer.customer.teams
    errors.add(:profile_customer, 'deve pertencer ao mesmo team') unless customer_teams.include?(team)
  end

  def admin_same_team
    errors.add(:profile_admin, 'deve pertencer ao mesmo team') unless profile_admin.admin.team == team
  end
end
