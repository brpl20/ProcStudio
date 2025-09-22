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
  include S3PathBuilder

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

  # Get logo URL from S3
  def logo_url
    return nil if logo_s3_key.blank?
    
    # If it's a local file reference (development without S3)
    if logo_s3_key.start_with?('local/')
      # Return a placeholder URL or path
      return "/placeholder/#{logo_s3_key}"
    end

    # Generate S3 URL if S3 is configured
    if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['S3_BUCKET'].present?
      s3_presigner.presigned_url(
        :get_object,
        bucket: ENV['S3_BUCKET'],
        key: logo_s3_key,
        expires_in: 3600 # 1 hour
      )
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error generating logo URL: #{e.message}"
    nil
  end

  # Upload logo to S3 with new architecture
  def upload_logo(file, metadata_params = {})
    Rails.logger.info "upload_logo called with file: #{file.inspect}"
    return false if file.blank?

    Rails.logger.info "File details - filename: #{file.original_filename}, content_type: #{file.content_type}, size: #{file.size}"
    extension = File.extname(file.original_filename).delete('.')
    s3_key = build_logo_s3_key(extension)
    Rails.logger.info "Generated S3 key: #{s3_key}"

    # Check if S3 is configured
    if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_BUCKET'].present?
      # Upload to S3
      file_content = file.respond_to?(:tempfile) ? file.tempfile.read : file.read
      file_content = file_content.force_encoding('BINARY') if file_content.respond_to?(:force_encoding)
      
      s3_client.put_object(
        bucket: ENV['S3_BUCKET'],
        key: s3_key,
        body: file_content,
        content_type: file.content_type,
        metadata: {
          'team-id' => team_id.to_s,
          'office-id' => id.to_s,
          'uploaded-by' => metadata_params[:uploaded_by_id].to_s
        }
      )
    else
      Rails.logger.warn "S3 not configured, storing file path reference only"
      # For development without S3, just store the filename
      s3_key = "local/#{s3_key}"
    end

    # Store the S3 key in database - skip validations to avoid partnership percentage issues
    Rails.logger.info "Updating logo_s3_key to: #{s3_key}"
    if update_attribute(:logo_s3_key, s3_key)
      Rails.logger.info "Logo S3 key updated successfully"
    else
      Rails.logger.error "Failed to update logo S3 key: #{errors.full_messages}"
      errors.add(:logo, "Failed to save logo reference")
      return false
    end

    # Create metadata record
    if metadata_params.present?
      attachment_metadata.create!(
        document_type: 'logo',
        s3_key: s3_key,
        filename: file.original_filename,
        content_type: file.content_type,
        byte_size: file.size,
        document_date: metadata_params[:document_date],
        description: metadata_params[:description],
        custom_metadata: metadata_params[:custom_metadata],
        uploaded_by_id: metadata_params[:uploaded_by_id]
      )
    end

    true
  rescue StandardError => e
    Rails.logger.error "Error uploading logo: #{e.message}"
    errors.add(:logo, "Failed to upload: #{e.message}")
    false
  end

  # Get social contracts with metadata from S3
  def social_contracts_with_metadata
    contracts = attachment_metadata.where(document_type: 'social_contract')

    contracts.map do |metadata|
      {
        id: metadata.id,
        s3_key: metadata.s3_key,
        filename: metadata.filename,
        content_type: metadata.content_type,
        byte_size: metadata.byte_size,
        created_at: metadata.created_at,
        url: generate_s3_url(metadata.s3_key),
        download_url: generate_s3_download_url(metadata.s3_key, metadata.filename),
        # Metadata fields
        document_date: metadata.document_date,
        description: metadata.description,
        uploaded_by_id: metadata.uploaded_by_id,
        custom_metadata: metadata.custom_metadata
      }
    end
  end

  # Upload social contract to S3 with new architecture
  def upload_social_contract(file, metadata_params = {})
    Rails.logger.info "upload_social_contract called with file: #{file.inspect}"
    return false if file.blank?

    extension = File.extname(file.original_filename).delete('.')
    s3_key = build_social_contract_s3_key(extension)
    Rails.logger.info "Generated S3 key for contract: #{s3_key}"

    # Check if S3 is configured
    if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_BUCKET'].present?
      # Upload to S3
      file_content = file.respond_to?(:tempfile) ? file.tempfile.read : file.read
      file_content = file_content.force_encoding('BINARY') if file_content.respond_to?(:force_encoding)
      
      s3_client.put_object(
        bucket: ENV['S3_BUCKET'],
        key: s3_key,
        body: file_content,
        content_type: file.content_type,
        metadata: {
          'team-id' => team_id.to_s,
          'office-id' => id.to_s,
          'uploaded-by' => metadata_params[:uploaded_by_id].to_s,
          'document-type' => 'social-contract'
        }
      )
    else
      Rails.logger.warn "S3 not configured for contracts, storing file path reference only"
      # For development without S3, just store the filename
      s3_key = "local/#{s3_key}"
    end

    # Create metadata record
    attachment_metadata.create!(
      document_type: 'social_contract',
      s3_key: s3_key,
      filename: file.original_filename,
      content_type: file.content_type,
      byte_size: file.size,
      document_date: metadata_params[:document_date],
      description: metadata_params[:description],
      custom_metadata: metadata_params[:custom_metadata],
      uploaded_by_id: metadata_params[:uploaded_by_id]
    )

    true
  rescue StandardError => e
    Rails.logger.error "Error uploading social contract: #{e.message}"
    errors.add(:social_contract, "Failed to upload: #{e.message}")
    false
  end

  # Generate S3 URL for any file
  def generate_s3_url(s3_key, expires_in: 3600)
    return nil if s3_key.blank?

    s3_presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch('S3_BUCKET', nil),
      key: s3_key,
      expires_in: expires_in
    )
  rescue StandardError => e
    Rails.logger.error "Error generating S3 URL: #{e.message}"
    nil
  end

  # Generate S3 download URL
  def generate_s3_download_url(s3_key, filename, expires_in: 3600)
    return nil if s3_key.blank?

    s3_presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch('S3_BUCKET', nil),
      key: s3_key,
      expires_in: expires_in,
      response_content_disposition: "attachment; filename=\"#{filename}\""
    )
  rescue StandardError => e
    Rails.logger.error "Error generating S3 download URL: #{e.message}"
    nil
  end

  private

  # S3 client instance
  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-west-2',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    )
  end

  # S3 presigner for generating presigned URLs
  def s3_presigner
    @s3_presigner ||= Aws::S3::Presigner.new(client: s3_client)
  end

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
