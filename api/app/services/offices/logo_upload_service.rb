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

      # Use the new S3Manager upload method with user_profile
      file_metadata = @office.upload_logo(
        logo_file,
        user_profile: @current_user.user_profile,
        **build_metadata(metadata_params)
      )

      Result.new(
        success: true,
        message: 'Logo enviado com sucesso',
        data: {
          logo_url: @office.logo_url,
          file_metadata_id: file_metadata.id
        }
      )
    rescue StandardError => e
      Result.new(
        success: false,
        message: "Erro ao fazer upload do logo: #{e.message}"
      )
    end

    Result = Struct.new(:success, :message, :data, keyword_init: true)

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
        description: metadata_params[:description] || "Logo for #{@office.name}",
        custom_metadata: metadata_params[:custom_metadata]
      }.compact
    end
  end
end
