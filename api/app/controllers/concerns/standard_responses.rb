# frozen_string_literal: true

module StandardResponses
  extend ActiveSupport::Concern

  private

  def render_success(message: nil, data: nil, status: :ok)
    response = {
      success: true,
      message: message || 'Request successful'
    }
    response[:data] = data if data.present?

    render json: response, status: status
  end

  def render_error(message: nil, errors: [], status: :unprocessable_content)
    render json: {
      success: false,
      message: message || errors.first || 'Request failed',
      errors: Array(errors)
    }, status: status
  end

  def render_created(resource, serializer_class = nil)
    if resource.persisted?
      data = if serializer_class
               serializer_class.new(resource).serializable_hash
             else
               resource.as_json
             end

      render_success(
        message: "#{resource.class.name} created successfully",
        data: data,
        status: :created
      )
    else
      render_error(
        message: resource.errors.full_messages.first,
        errors: resource.errors.full_messages
      )
    end
  end

  def render_updated(resource, serializer_class = nil)
    if resource.errors.empty?
      data = if serializer_class
               serializer_class.new(resource).serializable_hash
             else
               resource.as_json
             end

      render_success(
        message: "#{resource.class.name} updated successfully",
        data: data
      )
    else
      render_error(
        message: resource.errors.full_messages.first,
        errors: resource.errors.full_messages
      )
    end
  end

  def render_destroyed(resource_name = 'Resource')
    render_success(
      message: "#{resource_name} deleted successfully"
    )
  end

  def render_not_found(resource_name = 'Resource')
    render_error(
      message: "#{resource_name} not found",
      status: :not_found
    )
  end

  def render_unauthorized(message = 'Unauthorized')
    render_error(
      message: message,
      status: :unauthorized
    )
  end

  def render_forbidden(message = 'Forbidden')
    render_error(
      message: message,
      status: :forbidden
    )
  end
end
