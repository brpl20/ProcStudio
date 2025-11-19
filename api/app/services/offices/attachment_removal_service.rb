# frozen_string_literal: true

module Offices
  class AttachmentRemovalService
    def initialize(office)
      @office = office
    end

    def call(attachment_id)
      file_metadata = find_file_metadata(attachment_id)
      return attachment_not_found_error unless file_metadata

      remove_file(file_metadata)
      success_result(attachment_id)
    end

    Result = Struct.new(:success, :message, :data, keyword_init: true)

    private

    attr_reader :office

    def find_file_metadata(attachment_id)
      # Find FileMetadata that belongs to this office
      office.file_metadata.find_by(id: attachment_id)
    end

    def remove_file(file_metadata)
      # Delete the FileMetadata record
      # The before_destroy callback will handle S3 deletion
      file_metadata.destroy
    rescue StandardError => e
      Rails.logger.error "Failed to remove file: #{e.message}"
      raise
    end

    def attachment_not_found_error
      Result.new(
        success: false,
        message: 'Anexo não encontrado'
      )
    end

    def success_result(attachment_id)
      Result.new(
        success: true,
        message: 'Anexo removido com sucesso',
        data: { id: attachment_id }
      )
    end
  end
end
