# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                                       :bigint           not null, primary key
#  accounting_type                          :string
#  cnpj                                     :string
#  deleted_at                               :datetime
#  foundation                               :date
#  logo_s3_key                              :string
#  name                                     :string
#  number_of_quotes(Total number of quotes) :integer          default(0)
#  oab_inscricao                            :string
#  oab_link                                 :string
#  oab_status                               :string
#  quote_value(Value per quote in BRL)      :decimal(10, 2)
#  site                                     :string
#  society                                  :string
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  created_by_id                            :bigint
#  deleted_by_id                            :bigint
#  oab_id                                   :string
#  team_id                                  :bigint           not null
#
# Indexes
#
#  index_offices_on_accounting_type  (accounting_type)
#  index_offices_on_created_by_id    (created_by_id)
#  index_offices_on_deleted_at       (deleted_at)
#  index_offices_on_deleted_by_id    (deleted_by_id)
#  index_offices_on_logo_s3_key      (logo_s3_key)
#  index_offices_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (deleted_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class Office < ApplicationRecord
  include DeletedFilterConcern
  include CnpjValidatable
  include S3Attachable

  acts_as_paranoid

  belongs_to :team
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true

  # Relationships with users/lawyers
  has_many :user_offices, dependent: :destroy
  has_many :users, through: :user_offices
  has_many :compensations, through: :user_offices, class_name: 'UserSocietyCompensation'
  has_many :user_profiles, dependent: :nullify

  # Remove ActiveStorage attachments - using direct S3 integration
  # has_one_attached :logo, dependent: :purge_later
  # has_many_attached :social_contracts, dependent: :purge_later

  # Attachment metadata
  has_many :attachment_metadata, class_name: 'OfficeAttachmentMetadata', dependent: :destroy

  enum :society, {
    individual: 'individual', # Sociedade Unipessoal
    company: 'company' # Sociedade
  }

  enum :accounting_type, { # enquadramento contabil
    simple: 'simple',                  # simples
    real_profit: 'real_profit',        # lucro real
    presumed_profit: 'presumed_profit' # lucro presumido
  }

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

  accepts_nested_attributes_for :office_emails, :bank_accounts, :user_offices,
                                allow_destroy: true,
                                reject_if: :all_blank

  # Store email attributes for processing after save
  attr_accessor :pending_emails

  # Virtual attribute for triggering social contract upload (not persisted to database)
  attr_accessor :create_social_contract

  # Custom method to handle emails nested attributes
  def emails_attributes=(attributes)
    return if attributes.blank?

    # Store for processing after save
    @pending_emails = attributes
  end

  # Callback to process emails after the office is saved
  after_create :process_pending_emails
  after_update :process_pending_emails

  with_options presence: true do
    validates :name
  end

  validate :unipessoal_must_have_only_one_partner, if: -> { society == 'individual' }
  validate :partnership_percentage_sum_to_one_hundred
  validate :team_must_exist

  def total_quotes_value
    return 0.0 unless quote_value.present? && number_of_quotes.present?

    quote_value * number_of_quotes
  end

  def formatted_total_quotes_value
    "R$ #{format('%.2f', total_quotes_value).tr('.', ',')}"
  end


  private

  def unipessoal_must_have_only_one_partner
    return unless user_offices.where(partnership_type: 'socio').many?

    errors.add(:society, 'unipessoal deve ter apenas um sócio')
  end

  def partnership_percentage_sum_to_one_hundred
    # Skip validation if no partners yet or if it's a new record
    return if new_record? || user_offices.empty?

    total = user_offices.where(partnership_type: 'socio').sum(:partnership_percentage)

    # Allow a small margin of error for decimal precision issues (e.g., 33.33% × 3 = 99.99%)
    return if (99.98..100.02).cover?(total)

    errors.add(:base, 'A soma das porcentagens de participação dos sócios deve ser 100%')
  end

  def team_must_exist
    errors.add(:team_id, 'deve existir') unless Team.exists?(team_id)
  end

  def process_pending_emails
    return if @pending_emails.blank?

    # Handle both array and hash format
    attrs_array = @pending_emails.is_a?(Array) ? @pending_emails : @pending_emails.values

    attrs_array.each do |attrs|
      # Handle both string and symbol keys
      attrs = attrs.with_indifferent_access if attrs.respond_to?(:with_indifferent_access)

      next if attrs['_destroy'] == '1' || attrs[:_destroy] == '1'

      email_value = attrs['email'] || attrs[:email]
      next if email_value.blank?

      email = Email.find_or_create_by(email: email_value)
      office_emails.find_or_create_by(email: email) unless office_emails.exists?(email: email)
    end

    @pending_emails = nil
  end
end
