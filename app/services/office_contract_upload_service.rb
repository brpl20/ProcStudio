# frozen_string_literal: true

class OfficeContractUploadService
  ALLOWED_CONTENT_TYPES = [
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ].freeze

  attr_reader :office, :current_user, :errors

  def initialize(office, current_user)
    @office = office
    @current_user = current_user
    @errors = []
    @uploaded_contracts = []
  end

  def upload_contracts(contracts, params = {}) # rubocop:disable Naming/PredicateMethod
    return false if contracts.blank?

    contracts = Array(contracts)

    contracts.each do |contract|
      next unless valid_contract?(contract)

      metadata_params = build_metadata_params(contract, params)
      upload_contract(contract, metadata_params)
    end

    @errors.empty?
  end

  def uploaded_count
    @uploaded_contracts.count
  end

  def uploaded_filenames
    @uploaded_contracts
  end

  private

  def valid_contract?(contract)
    unless contract.content_type.in?(ALLOWED_CONTENT_TYPES)
      @errors << "Formato de arquivo inválido para #{contract.original_filename}. Use PDF ou DOCX"
      return false
    end
    true
  end

  def build_metadata_params(contract, params)
    filename_key = contract.original_filename

    {
      document_date: params["document_date_#{filename_key}"] || params[:document_date],
      description: params["description_#{filename_key}"] || params[:description],
      custom_metadata: params["custom_metadata_#{filename_key}"] || params[:custom_metadata],
      uploaded_by_id: current_user.id
    }
  end

  def upload_contract(contract, metadata_params)
    @office.upload_social_contract(contract, metadata_params)
    @uploaded_contracts << contract.original_filename
  rescue StandardError => e
    Rails.logger.error "Contract upload failed for #{contract.original_filename}: #{e.message}"
    @errors << "Erro ao fazer upload de #{contract.original_filename}: #{e.message}"
    false
  end
end
