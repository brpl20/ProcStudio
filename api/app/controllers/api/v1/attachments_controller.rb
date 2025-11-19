# frozen_string_literal: true

module Api
  module V1
    class AttachmentsController < BackofficeController
      include AttachmentTransferable

      # POST /api/v1/attachments/:id/transfer
      # Global attachment transfer endpoint
      # Supports transferring attachments between any models
      def transfer
        # The transfer logic is handled by the AttachmentTransferable concern
        super
      end

      private

      def perform_authorization
        # Authorization is handled within the transfer action by the concern
        skip_authorization if action_name == 'transfer'
      end
    end
  end
end