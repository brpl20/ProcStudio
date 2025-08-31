# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id                                                                   :bigint           not null, primary key
#  bachelor                                                             :integer
#  compensations_five_years(Compensações realizadas nos últimos 5 anos) :boolean
#  compensations_service(Compensações de oficio)                        :boolean
#  deleted_at                                                           :datetime
#  extra_pending_document                                               :string
#  folder                                                               :string
#  gain_projection(Projeção de ganho)                                   :string
#  initial_atendee                                                      :integer
#  intern                                                               :integer
#  lawsuit(Possui ação Judicial)                                        :boolean
#  note                                                                 :string
#  number                                                               :integer
#  other_description(Descrição do outro tipo de assunto)                :text
#  partner_lawyer                                                       :integer
#  physical_lawyer                                                      :integer
#  rate_parceled_exfield                                                :string
#  responsible_lawyer                                                   :integer
#  work_status                                                          :string           default("active")
#  created_at                                                           :datetime         not null
#  updated_at                                                           :datetime         not null
#  created_by_id                                                        :bigint
#  law_area_id                                                          :bigint
#  team_id                                                              :bigint           not null
#
# Indexes
#
#  index_works_on_created_by_id  (created_by_id)
#  index_works_on_deleted_at     (deleted_at)
#  index_works_on_law_area_id    (law_area_id)
#  index_works_on_team_id        (team_id)
#  index_works_on_work_status    (work_status)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (law_area_id => law_areas.id)
#  fk_rails_...  (team_id => teams.id)
#
class Work < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :law_area, optional: true

  has_many :customer_works, -> { with_deleted }, dependent: :destroy
  has_many :profile_customers, -> { with_deleted }, through: :customer_works

  has_many :user_profile_works, dependent: :destroy
  has_many :user_profiles, through: :user_profile_works

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :documents, dependent: :destroy
  has_many :pending_documents, dependent: :destroy

  has_many :office_works, dependent: :destroy
  has_many :offices, through: :office_works

  has_many :recommendations, dependent: :destroy
  has_many :work_events, dependent: :destroy

  has_many :jobs

  # New associations for procedures
  has_many :procedures, dependent: :destroy
  has_many :root_procedures, -> { roots }, class_name: 'Procedure'

  # Honoraries can be at work level (global) or procedure level
  has_many :honoraries, dependent: :destroy
  has_one :global_honorary, -> { where(procedure_id: nil) }, class_name: 'Honorary'

  has_one :draft_work, class_name: 'Draft::Work', dependent: :destroy

  enum :work_status, {
    active: 'active',
    inactive: 'inactive',
    completed: 'completed',
    archived: 'archived'
  }

  validates :law_area, presence: true
  validates_with WorkAddressesValidator

  accepts_nested_attributes_for :documents, :pending_documents, :recommendations,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :procedures, :honoraries, :customer_works, :user_profile_works,
                                reject_if: :all_blank, allow_destroy: true

  scope :filter_by_customer_id, lambda { |customer_id|
    joins(:profile_customers).where(profile_customers: { id: customer_id })
  }

  # Helper methods for law_area integration
  def area_name
    law_area&.full_name
  end

  def main_area
    law_area&.main_area? ? law_area : law_area&.parent_area
  end

  def sub_area
    law_area&.sub_area? ? law_area : nil
  end

  # Get applicable powers based on law_area
  def applicable_powers
    return Power.none unless law_area

    law_area.applicable_powers
  end

  # Procedure management
  def has_procedures?
    procedures.any?
  end

  def active_procedures
    procedures.where(status: ['in_progress', 'paused'])
  end

  def add_procedure(type, **attributes)
    procedures.create!(
      procedure_type: type,
      law_area: law_area,
      **attributes
    )
  end

  def judicial_procedures
    procedures.judicial
  end

  def administrative_procedures
    procedures.administrative
  end

  def extrajudicial_procedures
    procedures.extrajudicial
  end

  # Honorary management
  def has_global_honorary?
    global_honorary.present?
  end

  def total_honorary_value
    honoraries.sum { |h| h.total_estimated_value || 0 }
  end

  # Financial summary across all procedures
  def financial_summary
    {
      total_claim: procedures.sum(:claim_value),
      total_conviction: procedures.sum(:conviction_value),
      total_received: procedures.sum(:received_value),
      total_honorary: total_honorary_value
    }
  end
end
