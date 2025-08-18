# frozen_string_literal: true

# == Schema Information
#
# Table name: team_customers
#
#  id             :bigint(8)        not null, primary key
#  team_id        :bigint(8)        not null
#  customer_id    :bigint(8)        not null
#  customer_email :string           not null
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class TeamCustomer < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :customer

  validates :customer_email, presence: true, uniqueness: { scope: :team_id }
  validates :customer_id, uniqueness: { scope: :team_id }

  before_validation :sync_customer_email

  private

  def sync_customer_email
    self.customer_email = customer&.email if customer&.email.present?
  end
end
