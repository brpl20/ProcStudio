# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id                       :bigint(8)        not null, primary key
#  procedure                :string
#  subject                  :string
#  number                   :integer
#  rate_parceled_exfield    :string
#  folder                   :string
#  note                     :string
#  extra_pending_document   :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  civel_area               :string
#  social_security_areas    :string
#  laborite_areas           :string
#  tributary_areas          :string
#  other_description        :text
#  compensations_five_years :boolean
#  compensations_service    :boolean
#  lawsuit                  :boolean
#  gain_projection          :string
#  physical_lawyer          :integer
#  responsible_lawyer       :integer
#  partner_lawyer           :integer
#  intern                   :integer
#  bachelor                 :integer
#  initial_atendee          :integer
#  procedures               :text             default([]), is an Array
#  created_by_id            :bigint(8)
#  status                   :string           default("in_progress")
#  deleted_at               :datetime
#  team_id                  :bigint(8)
#
class Work < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team

  has_many :customer_works, -> { with_deleted }, dependent: :destroy
  has_many :profile_customers, -> { with_deleted }, through: :customer_works

  # Work configuration for tracking offices and lawyers
  has_many :work_configurations, dependent: :destroy
  has_one :current_configuration, 
          -> { where(status: 'active').order(version: :desc) }, 
          class_name: 'WorkConfiguration'

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :documents, dependent: :destroy

  has_many :pending_documents, dependent: :destroy

  has_many :recommendations, dependent: :destroy
  has_many :work_events, dependent: :destroy

  has_many :jobs

  has_many_attached :tributary_files

  has_one :honorary, dependent: :destroy
  has_one :draft_work, class_name: 'Draft::Work', dependent: :destroy

  enum procedure: {
    administrative: 'administrativo',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }

  enum subject: {
    administrative_subject: 'administrativo',
    civil: 'civel',
    criminal: 'criminal',
    social_security: 'previdenciario',
    laborite: 'trabalhista',
    tributary: 'tributario',
    tributary_pis: 'tributario_pis_confins',
    others: 'outros'
  }

  enum civel_area: {
    family: 'familia',
    consumer: 'consumidor',
    moral_damages: 'danos morais'
  }

  enum tributary_areas: {
    asphalt: 'asfalto',
    license: 'alvara',
    others_tributary: 'outros'
  }

  enum social_security_areas: {
    retirement_by_time: 'aposentadoria_contribuicao',
    retirement_by_age: 'aposentadoria_idade',
    retirement_by_rural: 'aposentadoria_rural',
    disablement: 'invalidez',
    benefit_review: 'revisão_beneficio',
    administrative_services: 'servicos_administrativos'
  }

  enum laborite_areas: {
    labor_claim: 'reclamatoria_trabalhista'
  }

  enum status: {
    in_progress: 'in_progress',
    paused: 'paused',
    completed: 'completed'
  }

  validates :subject, presence: true
  validates_with WorkAddressesValidator

  accepts_nested_attributes_for :documents, :pending_documents, :recommendations, :honorary, reject_if: :all_blank, allow_destroy: true

  scope :filter_by_customer_id, ->(customer_id) { joins(:profile_customers).where(profile_customers: { id: customer_id }) }
  scope :by_team, ->(team) { where(team: team) }

  after_create :set_team_on_associations
  after_update :set_team_on_associations

  # Helper methods for accessing configuration data
  def participating_offices
    current_configuration&.participating_offices || []
  end
  
  def participating_lawyers
    current_configuration&.participating_lawyers || []
  end
  
  def offices
    participating_offices
  end
  
  def profile_admins
    participating_lawyers
  end
  
  def lead_lawyer
    current_configuration&.lead_lawyer
  end
  
  def responsible_lawyer
    current_configuration&.responsible_lawyer
  end
  
  def assistant_lawyers
    current_configuration&.assistant_lawyers || []
  end
  
  def all_participants
    current_configuration&.all_participants || { offices: [], lawyers: [] }
  end
  
  def has_configuration?
    current_configuration.present?
  end
  
  def configuration_version
    current_configuration&.version || 0
  end
  
  def configuration_history
    work_configurations.order(version: :desc)
  end
  
  def add_office(office, lawyers = [], admin = nil)
    return false unless office.present?
    
    config = current_configuration || build_initial_configuration
    offices_data = config.configuration['offices'] || []
    
    office_data = {
      'office_id' => office.id,
      'office_name' => office.name,
      'cnpj' => office.cnpj,
      'oab' => office.oab_number,
      'lawyers' => lawyers.map { |lawyer|
        {
          'admin_id' => lawyer.admin_id,
          'profile_admin_id' => lawyer.id,
          'name' => lawyer.name,
          'oab' => lawyer.oab
        }
      }
    }
    
    offices_data << office_data
    config.configuration['offices'] = offices_data
    
    if config.persisted?
      config.create_new_version(config.configuration, admin)
    else
      config.save
    end
  end
  
  def add_independent_lawyer(profile_admin, role = nil, admin = nil)
    return false unless profile_admin.present?
    
    config = current_configuration || build_initial_configuration
    lawyers_data = config.configuration['independent_lawyers'] || []
    
    lawyer_data = {
      'admin_id' => profile_admin.admin_id,
      'profile_admin_id' => profile_admin.id,
      'name' => profile_admin.name,
      'oab' => profile_admin.oab,
      'role' => role
    }
    
    lawyers_data << lawyer_data
    config.configuration['independent_lawyers'] = lawyers_data
    
    if config.persisted?
      config.create_new_version(config.configuration, admin)
    else
      config.save
    end
  end

  private
  
  def build_initial_configuration
    work_configurations.build(
      team: team,
      configuration: {
        'offices' => [],
        'independent_lawyers' => [],
        'roles' => {},
        'fee_distribution' => {}
      },
      status: 'active',
      effective_from: Time.current
    )
  end

  def set_team_on_associations
    return unless team.present?

    documents.where(team: nil).update_all(team_id: team.id)
  end
end
