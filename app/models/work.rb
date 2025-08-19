# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id                                                                   :bigint           not null, primary key
#  bachelor                                                             :integer
#  civel_area(Civil aréas)                                              :string
#  compensations_five_years(Compensações realizadas nos últimos 5 anos) :boolean
#  compensations_service(Compensações de oficio)                        :boolean
#  deleted_at                                                           :datetime
#  extra_pending_document                                               :string
#  folder                                                               :string
#  gain_projection(Projeção de ganho)                                   :string
#  initial_atendee                                                      :integer
#  intern                                                               :integer
#  laborite_areas(Trabalhista aréas)                                    :string
#  lawsuit(Possui ação Judicial)                                        :boolean
#  note                                                                 :string
#  number                                                               :integer
#  other_description(Descrição do outro tipo de assunto)                :text
#  partner_lawyer                                                       :integer
#  physical_lawyer                                                      :integer
#  procedure                                                            :string
#  procedures                                                           :text             default([]), is an Array
#  rate_parceled_exfield                                                :string
#  responsible_lawyer                                                   :integer
#  social_security_areas(Previdênciário aréas)                          :string
#  status                                                               :string           default("in_progress")
#  subject                                                              :string
#  tributary_areas(Tributário aréas)                                    :string
#  created_at                                                           :datetime         not null
#  updated_at                                                           :datetime         not null
#  created_by_id                                                        :bigint
#  team_id                                                              :bigint           not null
#
# Indexes
#
#  index_works_on_created_by_id  (created_by_id)
#  index_works_on_deleted_at     (deleted_at)
#  index_works_on_team_id        (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class Work < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team

  has_many :customer_works, -> { with_deleted }, dependent: :destroy
  has_many :profile_customers, -> { with_deleted }, through: :customer_works

  has_many :profile_admin_works, dependent: :destroy
  has_many :profile_admins, through: :profile_admin_works

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :documents, dependent: :destroy

  has_many :pending_documents, dependent: :destroy

  has_many :office_works, dependent: :destroy
  has_many :offices, through: :office_works

  has_many :recommendations, dependent: :destroy
  has_many :work_events, dependent: :destroy

  has_many :jobs

  has_many_attached :tributary_files

  has_one :honorary, dependent: :destroy
  has_one :draft_work, class_name: 'Draft::Work', dependent: :destroy

  enum :procedure, {
    administrative: 'administrativo',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }

  enum :subject, {
    administrative_subject: 'administrativo',
    civil: 'civel',
    criminal: 'criminal',
    social_security: 'previdenciario',
    laborite: 'trabalhista',
    tributary: 'tributario',
    tributary_pis: 'tributario_pis_confins',
    others: 'outros'
  }

  enum :civel_area, {
    family: 'familia',
    consumer: 'consumidor',
    moral_damages: 'danos morais'
  }

  enum :tributary_areas, {
    asphalt: 'asfalto',
    license: 'alvara',
    others_tributary: 'outros'
  }

  enum :social_security_areas, {
    retirement_by_time: 'aposentadoria_contribuicao',
    retirement_by_age: 'aposentadoria_idade',
    retirement_by_rural: 'aposentadoria_rural',
    disablement: 'invalidez',
    benefit_review: 'revisão_beneficio',
    administrative_services: 'servicos_administrativos'
  }

  enum :laborite_areas, {
    labor_claim: 'reclamatoria_trabalhista'
  }

  enum :status, {
    in_progress: 'in_progress',
    paused: 'paused',
    completed: 'completed'
  }

  validates :subject, presence: true
  validates_with WorkAddressesValidator

  accepts_nested_attributes_for :documents, :pending_documents, :recommendations, :honorary, reject_if: :all_blank,
                                                                                             allow_destroy: true

  scope :filter_by_customer_id, lambda { |customer_id|
    joins(:profile_customers).where(profile_customers: { id: customer_id })
  }
end
