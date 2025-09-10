# frozen_string_literal: true

# == Schema Information
#
# Table name: honoraries
#
#  id                     :bigint           not null, primary key
#  deleted_at             :datetime
#  description            :text
#  fixed_honorary_value   :string
#  honorary_type          :string
#  name                   :string
#  parcelling             :boolean
#  parcelling_value       :string
#  percent_honorary_value :string
#  status                 :string           default("active")
#  work_prev              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  procedure_id           :bigint
#  work_id                :bigint
#
# Indexes
#
#  index_honoraries_on_deleted_at                (deleted_at)
#  index_honoraries_on_procedure_id              (procedure_id)
#  index_honoraries_on_status                    (status)
#  index_honoraries_on_work_id                   (work_id)
#  index_honoraries_on_work_id_and_procedure_id  (work_id,procedure_id)
#
# Foreign Keys
#
#  fk_rails_...  (procedure_id => procedures.id)
#  fk_rails_...  (work_id => works.id)
#
class Honorary < ApplicationRecord
  acts_as_paranoid

  # Associations - can be attached to Work (global) or Procedure (specific)
  belongs_to :work, optional: true
  belongs_to :procedure, optional: true

  has_many :components, -> { order(:position) },
           class_name: 'HonoraryComponent',
           dependent: :destroy

  has_one :legal_cost, dependent: :destroy
  has_many :legal_cost_entries, through: :legal_cost

  # Validations
  validates :name, presence: true
  validate :attached_to_work_or_procedure

  # Enums
  enum :status, {
    active: 'active',
    completed: 'completed',
    cancelled: 'cancelled'
  }

  enum :honorary_type, {
    work: 'trabalho',
    success: 'exito',
    both: 'ambos',
    bonus: 'pro_abono'
  }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :for_work, ->(work) { where(work: work, procedure: nil) }
  scope :for_procedure, ->(procedure) { where(procedure: procedure) }

  # Component accessor methods
  def fixed_fee_component
    components.active.find_by(component_type: 'fixed_fee')
  end

  def hourly_rate_component
    components.active.find_by(component_type: 'hourly_rate')
  end

  def success_fee_component
    components.active.find_by(component_type: 'success_fee')
  end

  def monthly_retainer_component
    components.active.find_by(component_type: 'monthly_retainer')
  end

  def add_component(type, details)
    components.create!(
      component_type: type,
      details: details,
      position: components.maximum(:position).to_i + 1
    )
  end

  def total_estimated_value
    components.active.sum { |c| c.calculate_total || 0 }
  end

  def is_global?
    work.present? && procedure.blank?
  end

  def is_procedure_specific?
    procedure.present?
  end

  def parent_work
    procedure.present? ? procedure.work : work
  end

  private

  def attached_to_work_or_procedure
    errors.add(:base, 'Honorary must be attached to either a Work or a Procedure') if work.blank? && procedure.blank?

    return unless procedure.present? && work.present? && procedure.work != work

    errors.add(:base, 'Procedure must belong to the same Work')
  end
end
