# frozen_string_literal: true

module Offices
  class ContractsUploadService
    def initialize(office, current_user)
      @office = office
      @current_user = current_user
    end

    def call(contracts_params, metadata_params = {})
      return no_contracts_error if contracts_params.blank?

      contracts = Array(contracts_params)
      process_contracts(contracts, metadata_params)
    end

    Result = Struct.new(:success, :message, :uploaded_count, :errors, keyword_init: true)

    private

    attr_reader :office, :current_user

    def no_contracts_error
      Result.new(
        success: false,
        message: 'Nenhum contrato enviado',
        errors: []
      )
    end

    def process_contracts(contracts, metadata_params)
      uploaded_count = 0
      errors = []

      contracts.each do |contract|
        next unless valid_contract?(contract, errors)

        if upload_contract(contract, metadata_params)
          uploaded_count += 1
        else
          add_upload_error(contract, errors)
        end
      end

      build_result(uploaded_count, errors)
    end

    def valid_contract?(contract, errors)
      if contract.blank?
        errors << 'Contrato inválido'
        return false
      end
      true
    end

    def upload_contract(contract, metadata_params)
      metadata = build_contract_metadata(contract, metadata_params)
      office.upload_social_contract(contract, metadata)
    end

    def add_upload_error(contract, errors)
      filename = contract.original_filename
      error_message = office.errors[:social_contract]&.first
      errors << "Erro ao fazer upload de #{filename}: #{error_message}"
    end

    def build_contract_metadata(contract, params)
      {
        document_date: params[:document_date],
        description: params[:description] || contract.original_filename,
        custom_metadata: params[:custom_metadata],
        uploaded_by_id: current_user.id
      }
    end

    def build_result(uploaded_count, errors)
      if errors.empty?
        success_result(uploaded_count)
      else
        error_result(errors)
      end
    end

    def success_result(uploaded_count)
      Result.new(
        success: true,
        message: "#{uploaded_count} contrato(s) adicionado(s) com sucesso",
        uploaded_count: uploaded_count,
        errors: []
      )
    end

    def error_result(errors)
      Result.new(
        success: false,
        message: errors.first || 'Erro ao fazer upload dos contratos',
        errors: errors
      )
    end
  end
end
