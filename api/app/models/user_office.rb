# frozen_string_literal: true

# == Schema Information
#
# Table name: user_offices
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint           not null
#  office_id              :bigint           not null
#  partnership_type       :string           not null
#  partnership_percentage :decimal(5, 2)    default(0.0)
#  is_administrator       :boolean          default(FALSE), not null
#  cna_link               :string
#  entry_date             :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_user_offices_on_office_id              (office_id)
#  index_user_offices_on_user_id                (user_id)
#  index_user_offices_on_user_id_and_office_id  (user_id,office_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#

class UserOffice < ApplicationRecord
  belongs_to :user
  belongs_to :office

  has_many :compensations, class_name: 'UserSocietyCompensation', dependent: :destroy

  enum :partnership_type, {
    socio: 'socio',
    associado: 'associado',
    socio_de_servico: 'socio_de_servico'
  }

  validates :partnership_percentage, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 100
  }, if: -> { partnership_type == 'socio' }

  validates :partnership_percentage, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, if: -> { ['associado', 'socio_de_servico'].include?(partnership_type) }

  validates :is_administrator, inclusion: { in: [true, false] }

  validate :only_socio_can_be_administrator
  validate :entry_date_after_foundation, if: -> { office&.foundation.present? && entry_date.present? }
  validate :user_in_same_team_as_office

  accepts_nested_attributes_for :compensations, allow_destroy: true, reject_if: proc { |attrs|
    attrs.all? do |_, v|
      v.blank?
    end
  }

  # Callbacks to automatically sync UserProfile.office_id
  after_create :sync_user_profile_office
  after_destroy :clear_user_profile_office

  private

  def sync_user_profile_office
    # Find or create the user profile for this user
    profile = user.user_profile || user.build_user_profile

    # Update the office_id if it's not already set or is different
    if profile.office_id != office_id
      profile.update_column(:office_id, office_id)
      Rails.logger.info "UserProfile ##{profile.id} associated with Office ##{office_id} via UserOffice creation"
    end
  end

  def clear_user_profile_office
    # When a UserOffice is destroyed, clear the office_id from user_profile
    # Only if this is the user's only association with this office
    remaining_associations = UserOffice.where(user_id: user_id, office_id: office_id).count

    if remaining_associations.zero?
      profile = user.user_profile
      if profile&.office_id == office_id
        profile.update_column(:office_id, nil)
        Rails.logger.info "UserProfile ##{profile.id} disassociated from Office ##{office_id} via UserOffice destruction"
      end
    end
  end

  def only_socio_can_be_administrator
    return unless is_administrator && partnership_type != 'socio'

    errors.add(:is_administrator, 'apenas sócios podem ser administradores')
  end

  def entry_date_after_foundation
    return unless office&.foundation && entry_date

    return unless entry_date < office.foundation

    errors.add(:entry_date, 'deve ser posterior à data de fundação da sociedade')
  end

  def user_in_same_team_as_office
    return unless user && office

    return if user.team_id == office.team_id

    errors.add(:user_id, 'deve pertencer ao mesmo time do escritório')
  end
end
