# frozen_string_literal: true

module Offices
  class AttachmentRemovalService
    def initialize(office)
      @office = office
    end

    def call(attachment_id)
      attachment = find_attachment(attachment_id)
      return attachment_not_found_error unless attachment

      remove_attachment_and_metadata(attachment)
      success_result(attachment_id)
    end

    Result = Struct.new(:success, :message, :data, keyword_init: true)

    private

    attr_reader :office

    def find_attachment(attachment_id)
      office.social_contracts.find(attachment_id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def remove_attachment_and_metadata(attachment)
      remove_metadata(attachment)
      attachment.purge
    end

    def remove_metadata(attachment)
      office.attachment_metadata.find_by(blob_id: attachment.blob.id)&.destroy
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
