# frozen_string_literal: true

# == Schema Information
#
# Table name: user_society_compensations
#
#  id                 :bigint           not null, primary key
#  user_office_id     :bigint           not null
#  compensation_type  :string           not null
#  amount             :decimal(10, 2)   not null
#  payment_frequency  :string           not null
#  effective_date     :date             not null
#  end_date           :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_user_society_compensations_on_user_office_id  (user_office_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_office_id => user_offices.id)
#

class UserSocietyCompensation < ApplicationRecord
  belongs_to :user_office

  enum :compensation_type, {
    pro_labore: 'pro_labore',
    salary: 'salary',
    proportional: 'proportional'
  }

  enum :payment_frequency, {
    monthly: 'monthly',
    quarterly: 'quarterly',
    semi_annually: 'semi_annually',
    annually: 'annually'
  }

  validates :compensation_type, :amount, :effective_date, :payment_frequency, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :end_date_after_effective_date, if: -> { end_date.present? }

  # Delegates for convenience
  delegate :user, to: :user_office
  delegate :office, to: :user_office

  private

  def end_date_after_effective_date
    return unless end_date && effective_date

    return unless end_date <= effective_date

    errors.add(:end_date, 'deve ser posterior à data de início')
  end
end
