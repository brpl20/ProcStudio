# frozen_string_literal: true

module Offices
  class LogoUploadService
    VALID_LOGO_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze

    def initialize(office, current_user)
      @office = office
      @current_user = current_user
    end

    def call(logo_file, metadata_params = {})
      return validation_error unless valid_logo_type?(logo_file)

      upload_metadata = build_metadata(metadata_params)
      @office.upload_logo(logo_file, upload_metadata)
    end

    Result = Struct.new(:success, :message, keyword_init: true)

    private

    attr_reader :office, :current_user

    def valid_logo_type?(logo_file)
      logo_file.content_type.in?(VALID_LOGO_TYPES)
    end

    def validation_error
      Result.new(
        success: false,
        message: 'Formato de arquivo inválido. Use imagens JPEG, PNG, GIF ou WEBP'
      )
    end

    def build_metadata(metadata_params)
      {
        document_date: metadata_params[:document_date],
        description: metadata_params[:description],
        custom_metadata: metadata_params[:custom_metadata],
        uploaded_by_id: current_user.id
      }
    end
  end
end
