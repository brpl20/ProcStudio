# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                    :bigint           not null, primary key
#  accounting_type       :string
#  cnpj                  :string
#  deleted_at            :datetime
#  foundation            :date
#  name                  :string
#  oab                   :string
#  site                  :string
#  society               :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  office_type_id        :bigint           not null
#  responsible_lawyer_id :integer
#  team_id               :bigint           not null
#
# Indexes
#
#  index_offices_on_accounting_type        (accounting_type)
#  index_offices_on_deleted_at             (deleted_at)
#  index_offices_on_office_type_id         (office_type_id)
#  index_offices_on_responsible_lawyer_id  (responsible_lawyer_id)
#  index_offices_on_team_id                (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_type_id => office_types.id)
#  fk_rails_...  (team_id => teams.id)
#
#  fk_rails_...  (office_type_id => office_types.id)
#  fk_rails_...  (team_id => teams.id)


class Office < ApplicationRecord
  include DeletedFilterConcern
  include CnpjValidatable

  acts_as_paranoid

  # puts '🏢 Creating Office Types...'
  # office_types = ['Advocacia', 'Consultoria', 'Contabilidade']
  # office_types.each do |type_name|
  #   OfficeType.find_or_create_by!(description: type_name) do |ot|
  #     puts "  ✅ Created office type: #{ot.description}"
  #   end
  # end


  belongs_to :team
  belongs_to :office_type
  belongs_to :responsible_lawyer, class_name: 'UserProfile', optional: true

  has_many :user_profiles, dependent: :destroy

  validate :responsible_lawyer_same_team, if: -> { responsible_lawyer.present? }
  has_one_attached :logo

  enum :society, {
    sole_proprietorship: 'sole_proprietorship',
    company: 'company',
    individual: 'individual'
  }

  enum :accounting_type, { # enquadramento contabil
    simple: 'simple',                  # simples
    real_profit: 'real_profit',        # lucro real
    presumed_profit: 'presumed_profit' # lucro presumido
  }

  # has_many :office_phones, dependent: :destroy
  # has_many :phones, through: :office_phones
  has_many :phones, as: :phoneable, dependent: :destroy
  
  has_many :addresses, as: :addressable, dependent: :destroy


  has_many :office_emails, dependent: :destroy
  has_many :emails, through: :office_emails

  has_many :office_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :office_bank_accounts

  has_many :office_works, dependent: :destroy
  has_many :works, through: :office_works

   # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :by_state, ->(state) { joins(:addresses).where(addresses: { state: state.upcase }) }
  scope :with_phones, -> { joins(:phones).distinct }
  scope :with_addresses, -> { joins(:addresses).distinct }


  # Nested attributes for API
  accepts_nested_attributes_for :phones, 
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['phone_number'].blank? }
    
  accepts_nested_attributes_for :addresses, 
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['street'].blank? || attrs['city'].blank? }


  accepts_nested_attributes_for :emails, :bank_accounts, reject_if: :all_blank

  with_options presence: true do
    validates :name
    # validates :cnpj # Now handled by CnpjValidatable module
    # validates :city
    # validates :zip_code
    # validates :street
    # validates :number
    # validates :neighborhood
    # validates :state
  end

  private

  def responsible_lawyer_same_team
    errors.add(:responsible_lawyer, 'deve pertencer ao mesmo team') unless responsible_lawyer.user.team == team
  end
end
