# frozen_string_literal: true

module RepresentResponses
  extend ActiveSupport::Concern

  private

  def represent_success_response(message, data = nil, status = :ok)
    response = {
      success: true,
      message: message
    }
    response[:data] = data if data
    render json: response, status: status
  end

  def represent_error_response(message, errors = nil, status = :unprocessable_content)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def represent_not_found_response(message = 'Representação não encontrada')
    render json: {
      success: false,
      message: message
    }, status: :not_found
  end

  def represent_index_response(represents)
    render json: {
      success: true,
      message: 'Representações listadas com sucesso',
      data: represents.map { |r| Represents::SerializerService.call(r) },
      meta: {
        total_count: represents.count
      }
    }, status: :ok
  end
end
