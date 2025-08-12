# frozen_string_literal: true

# == Schema Information
#
# Table name: work_configurations
#
#  id              :bigint(8)        not null, primary key
#  work_id         :bigint(8)        not null
#  team_id         :bigint(8)        not null
#  configuration   :jsonb            not null
#  version         :integer          default(1), not null
#  status          :string           default("active")
#  notes           :text
#  created_by_id   :bigint(8)
#  updated_by_id   :bigint(8)
#  effective_from  :datetime         not null
#  effective_until :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class WorkConfiguration < ApplicationRecord
  belongs_to :work
  belongs_to :team
  belongs_to :created_by, class_name: 'Admin', optional: true
  belongs_to :updated_by, class_name: 'Admin', optional: true
  
  # JSON structure:
  # {
  #   "offices": [
  #     {
  #       "office_id": 1,
  #       "office_name": "São Paulo Office",
  #       "cnpj": "XX.XXX.XXX/0001-XX",
  #       "oab": "SP12345",
  #       "lawyers": [
  #         {"admin_id": 1, "profile_admin_id": 1, "name": "Dr. Silva", "oab": "SP123456", "role": "lead"}
  #       ]
  #     }
  #   ],
  #   "independent_lawyers": [
  #     {"admin_id": 3, "profile_admin_id": 3, "name": "Dr. Oliveira", "oab": "RJ456789", "role": "assistant"}
  #   ],
  #   "roles": {
  #     "lead_lawyer_id": 1,
  #     "assistant_lawyer_ids": [2, 3],
  #     "responsible_lawyer_id": 1
  #   },
  #   "fee_distribution": {
  #     "office_1": 70,
  #     "admin_3": 30
  #   }
  # }
  
  store_accessor :configuration, :offices, :independent_lawyers, :roles, :fee_distribution
  
  validates :work, presence: true
  validates :team, presence: true
  validates :version, presence: true, uniqueness: { scope: :work_id }
  validates :effective_from, presence: true
  validates :status, inclusion: { in: %w[active inactive superseded] }
  validate :configuration_structure
  validate :effective_dates_consistency
  
  before_create :set_version
  before_create :set_effective_from
  after_create :deactivate_previous_configurations
  
  scope :active, -> { where(status: 'active') }
  scope :current, -> { active.order(version: :desc).limit(1) }
  scope :historical, -> { where(status: 'superseded').order(version: :desc) }
  
  def participating_offices
    return [] unless offices.present?
    offices.map do |office_data|
      Office.find_by(id: office_data['office_id'])
    end.compact
  end
  
  def participating_lawyers
    lawyers = []
    
    # Lawyers from offices
    if offices.present?
      offices.each do |office_data|
        next unless office_data['lawyers'].present?
        office_data['lawyers'].each do |lawyer_data|
          lawyers << ProfileAdmin.find_by(id: lawyer_data['profile_admin_id'])
        end
      end
    end
    
    # Independent lawyers
    if independent_lawyers.present?
      independent_lawyers.each do |lawyer_data|
        lawyers << ProfileAdmin.find_by(id: lawyer_data['profile_admin_id'])
      end
    end
    
    lawyers.compact.uniq
  end
  
  def lead_lawyer
    return nil unless roles.present? && roles['lead_lawyer_id'].present?
    ProfileAdmin.find_by(id: roles['lead_lawyer_id'])
  end
  
  def assistant_lawyers
    return [] unless roles.present? && roles['assistant_lawyer_ids'].present?
    ProfileAdmin.where(id: roles['assistant_lawyer_ids'])
  end
  
  def responsible_lawyer
    return nil unless roles.present? && roles['responsible_lawyer_id'].present?
    ProfileAdmin.find_by(id: roles['responsible_lawyer_id'])
  end
  
  def all_participants
    {
      offices: participating_offices,
      lawyers: participating_lawyers,
      lead_lawyer: lead_lawyer,
      assistant_lawyers: assistant_lawyers,
      responsible_lawyer: responsible_lawyer
    }
  end
  
  def office_lawyers(office_id)
    return [] unless offices.present?
    
    office_data = offices.find { |o| o['office_id'] == office_id }
    return [] unless office_data && office_data['lawyers'].present?
    
    office_data['lawyers'].map do |lawyer_data|
      ProfileAdmin.find_by(id: lawyer_data['profile_admin_id'])
    end.compact
  end
  
  def to_snapshot
    {
      version: version,
      status: status,
      effective_from: effective_from,
      effective_until: effective_until,
      configuration: configuration,
      created_by: created_by&.email,
      created_at: created_at
    }
  end
  
  def create_new_version(new_configuration, admin = nil)
    new_config = work.work_configurations.build(
      team: team,
      configuration: new_configuration,
      created_by: admin,
      updated_by: admin,
      status: 'active'
    )
    
    if new_config.save
      self.update!(
        status: 'superseded',
        effective_until: Time.current,
        updated_by: admin
      )
    end
    
    new_config
  end
  
  private
  
  def set_version
    self.version = (work.work_configurations.maximum(:version) || 0) + 1
  end
  
  def set_effective_from
    self.effective_from ||= Time.current
  end
  
  def deactivate_previous_configurations
    work.work_configurations
        .where.not(id: id)
        .active
        .update_all(
          status: 'superseded',
          effective_until: effective_from,
          updated_at: Time.current
        )
  end
  
  def configuration_structure
    return if configuration.blank?
    
    # Validate offices structure
    if configuration['offices'].present?
      unless configuration['offices'].is_a?(Array)
        errors.add(:configuration, 'offices must be an array')
      end
    end
    
    # Validate independent_lawyers structure
    if configuration['independent_lawyers'].present?
      unless configuration['independent_lawyers'].is_a?(Array)
        errors.add(:configuration, 'independent_lawyers must be an array')
      end
    end
    
    # Validate fee_distribution percentages
    if configuration['fee_distribution'].present?
      total = configuration['fee_distribution'].values.sum(&:to_f)
      if total > 0 && total != 100.0
        errors.add(:configuration, 'fee_distribution must sum to 100%')
      end
    end
  end
  
  def effective_dates_consistency
    return unless effective_from.present? && effective_until.present?
    
    if effective_until <= effective_from
      errors.add(:effective_until, 'must be after effective_from')
    end
  end
end
