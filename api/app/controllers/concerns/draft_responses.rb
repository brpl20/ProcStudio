# frozen_string_literal: true

module DraftResponses
  extend ActiveSupport::Concern

  private

  def render_success_response(message:, data:, meta: nil)
    response = { success: true, message: message, data: data }
    response[:meta] = meta if meta
    render json: response, status: :ok
  end

  def render_error_response(error, status = :internal_server_error)
    render json: {
      success: false,
      message: error.message,
      errors: [error.message]
    }, status: status
  end

  def render_new_record_recovery
    render json: {
      success: true,
      message: 'Rascunho de novo registro recuperado',
      data: Drafts::SerializerService.serialize_draft(@draft),
      is_new_record: true
    }, status: :ok
  end

  def render_existing_record_recovery
    @draft.recover!
    render json: {
      success: true,
      message: 'Rascunho recuperado com sucesso',
      data: Drafts::SerializerService.serialize_draft(@draft),
      is_new_record: false
    }, status: :ok
  end

  def render_missing_type_error
    render json: {
      success: false,
      message: 'Tipo de rascunho é obrigatório',
      errors: ['draftable_type é obrigatório']
    }, status: :bad_request
  end

  def render_invalid_type_error(message)
    render json: {
      success: false,
      message: "Tipo de rascunho desconhecido: #{params[:draftable_type]}",
      errors: [message]
    }, status: :bad_request
  end

  def render_record_not_found_error
    render json: {
      success: false,
      message: 'Registro não encontrado',
      errors: ["#{params[:draftable_type]} com ID #{params[:draftable_id]} não encontrado"]
    }, status: :not_found
  end

  def render_draft_not_found_error
    render json: {
      success: false,
      message: 'Rascunho não encontrado',
      errors: ['Rascunho não encontrado ou expirado']
    }, status: :not_found
  end
end
