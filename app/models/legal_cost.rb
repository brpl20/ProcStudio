# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_costs
#
#  id                   :bigint           not null, primary key
#  admin_fee_percentage :decimal(5, 2)    default(0.0)
#  client_responsible   :boolean          default(TRUE)
#  include_in_invoices  :boolean          default(TRUE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  honorary_id          :bigint           not null
#
# Indexes
#
#  index_legal_costs_on_honorary_id  (honorary_id)
#
# Foreign Keys
#
#  fk_rails_...  (honorary_id => honoraries.id)
#
class LegalCost < ApplicationRecord
  belongs_to :honorary
  has_many :entries, class_name: 'LegalCostEntry', dependent: :destroy

  # Validations
  validates :admin_fee_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Scopes
  scope :client_responsible, -> { where(client_responsible: true) }
  scope :office_responsible, -> { where(client_responsible: false) }
  scope :invoiceable, -> { where(include_in_invoices: true) }

  # Instance methods
  def total_amount
    entries.sum(:amount)
  end

  def paid_amount
    entries.where(paid: true).sum(:amount)
  end

  def pending_amount
    entries.where(paid: false).sum(:amount)
  end

  def estimated_amount
    entries.where(estimated: true).sum(:amount)
  end

  def confirmed_amount
    entries.where(estimated: false).sum(:amount)
  end

  def overdue_entries
    entries.where(paid: false).where(due_date: ...Date.current)
  end

  def upcoming_entries(days = 30)
    entries.where(paid: false)
      .where(due_date: Date.current..(Date.current + days.days))
  end

  def total_with_admin_fee
    return total_amount if admin_fee_percentage.zero?

    total_amount * (1 + (admin_fee_percentage / 100.0))
  end

  def admin_fee_amount
    return 0 if admin_fee_percentage.zero?

    total_amount * (admin_fee_percentage / 100.0)
  end

  def summary
    {
      total: total_amount,
      paid: paid_amount,
      pending: pending_amount,
      overdue: overdue_entries.sum(:amount),
      estimated: estimated_amount,
      confirmed: confirmed_amount,
      admin_fee: admin_fee_amount,
      total_with_fee: total_with_admin_fee
    }
  end

  def add_entry(cost_type, name, amount, **options)
    entries.create!(
      cost_type: cost_type,
      name: name,
      amount: amount,
      **options
    )
  end
end
